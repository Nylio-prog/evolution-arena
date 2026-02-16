extends Node

const BUS_MASTER := "Master"
const BUS_SFX := "SFX"
const BUS_MUSIC := "Music"
const DEFAULT_SFX_POLYPHONY := 8
const DEFAULT_STREAM_PATHS: Dictionary = {
	"ui_click": "res://audio/sfx/ui_click.wav",
	"pickup": "res://audio/sfx/pickup.wav",
	"enemy_death": "res://audio/sfx/enemy_death.wav",
	"levelup": "res://audio/sfx/levelup.wav",
	"player_hit": "res://audio/sfx/player_hit.wav",
	"player_death": "res://audio/sfx/player_death.wav",
	"bgm_main": "res://audio/music/bgm.ogg"
}

@export var default_sfx_volume_db: float = -6.0
@export var default_music_volume_db: float = -10.0
@export var sfx_polyphony: int = DEFAULT_SFX_POLYPHONY
@export var debug_log_missing_streams: bool = false

var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _stream_cache: Dictionary = {}
var _sfx_volume_linear: float = 1.0
var _music_volume_linear: float = 1.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_audio_buses()
	_create_players()
	_set_default_bus_volumes()
	_preload_optional_streams()

func play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> bool:
	var stream: AudioStream = _get_stream(event_id)
	if stream == null:
		return false

	var player: AudioStreamPlayer = _get_available_sfx_player()
	if player == null:
		return false

	player.stream = stream
	player.volume_db = volume_db_offset
	player.pitch_scale = clampf(pitch_scale, 0.5, 2.0)
	player.play()
	return true

func play_music(track_id: String = "bgm_main", restart_if_same: bool = false) -> bool:
	if _music_player == null:
		return false

	var stream: AudioStream = _get_stream(track_id)
	if stream == null:
		return false
	_ensure_stream_loops(stream)

	if _music_player.stream == stream and _music_player.playing and not restart_if_same:
		return true

	_music_player.stream = stream
	_music_player.volume_db = 0.0
	_music_player.pitch_scale = 1.0
	_music_player.play()
	return true

func _ensure_stream_loops(stream: AudioStream) -> void:
	if stream == null:
		return

	var ogg_stream: AudioStreamOggVorbis = stream as AudioStreamOggVorbis
	if ogg_stream != null:
		ogg_stream.loop = true
		return

	var wav_stream: AudioStreamWAV = stream as AudioStreamWAV
	if wav_stream != null:
		wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

func stop_music() -> void:
	if _music_player != null:
		_music_player.stop()

func set_sfx_volume_linear(value: float) -> void:
	_sfx_volume_linear = clampf(value, 0.0, 1.0)
	var bus_index: int = AudioServer.get_bus_index(BUS_SFX)
	if bus_index < 0:
		return
	AudioServer.set_bus_volume_db(bus_index, _linear_to_db_safe(_sfx_volume_linear))

func set_music_volume_linear(value: float) -> void:
	_music_volume_linear = clampf(value, 0.0, 1.0)
	var bus_index: int = AudioServer.get_bus_index(BUS_MUSIC)
	if bus_index < 0:
		return
	AudioServer.set_bus_volume_db(bus_index, _linear_to_db_safe(_music_volume_linear))

func get_sfx_volume_linear() -> float:
	return _sfx_volume_linear

func get_music_volume_linear() -> float:
	return _music_volume_linear

func set_sfx_muted(muted: bool) -> void:
	var bus_index: int = AudioServer.get_bus_index(BUS_SFX)
	if bus_index >= 0:
		AudioServer.set_bus_mute(bus_index, muted)

func set_music_muted(muted: bool) -> void:
	var bus_index: int = AudioServer.get_bus_index(BUS_MUSIC)
	if bus_index >= 0:
		AudioServer.set_bus_mute(bus_index, muted)

func _ensure_audio_buses() -> void:
	var master_index: int = AudioServer.get_bus_index(BUS_MASTER)
	if master_index < 0:
		return

	var sfx_index: int = AudioServer.get_bus_index(BUS_SFX)
	if sfx_index < 0:
		AudioServer.add_bus(AudioServer.get_bus_count())
		sfx_index = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(sfx_index, BUS_SFX)
		AudioServer.set_bus_send(sfx_index, BUS_MASTER)

	var music_index: int = AudioServer.get_bus_index(BUS_MUSIC)
	if music_index < 0:
		AudioServer.add_bus(AudioServer.get_bus_count())
		music_index = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(music_index, BUS_MUSIC)
		AudioServer.set_bus_send(music_index, BUS_MASTER)

func _create_players() -> void:
	if _music_player == null:
		_music_player = AudioStreamPlayer.new()
		_music_player.name = "MusicPlayer"
		_music_player.bus = BUS_MUSIC
		add_child(_music_player)

	if not _sfx_players.is_empty():
		return

	var target_polyphony: int = maxi(1, sfx_polyphony)
	for i in range(target_polyphony):
		var player := AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % i
		player.bus = BUS_SFX
		add_child(player)
		_sfx_players.append(player)

func _set_default_bus_volumes() -> void:
	set_sfx_volume_linear(db_to_linear(default_sfx_volume_db))
	set_music_volume_linear(db_to_linear(default_music_volume_db))

func _preload_optional_streams() -> void:
	_stream_cache.clear()
	for event_id_variant in DEFAULT_STREAM_PATHS.keys():
		var event_id: String = String(event_id_variant)
		var path: String = String(DEFAULT_STREAM_PATHS.get(event_id, ""))
		var stream: AudioStream = _try_load_stream(path)
		_stream_cache[event_id] = stream

func _get_stream(event_id: String) -> AudioStream:
	if _stream_cache.has(event_id):
		var cached_variant: Variant = _stream_cache.get(event_id, null)
		return cached_variant as AudioStream

	var path: String = String(DEFAULT_STREAM_PATHS.get(event_id, ""))
	if path.is_empty():
		return null
	var stream: AudioStream = _try_load_stream(path)
	_stream_cache[event_id] = stream
	return stream

func _try_load_stream(path: String) -> AudioStream:
	if path.is_empty():
		return null
	if not ResourceLoader.exists(path, "AudioStream"):
		if debug_log_missing_streams:
			print("AudioManager: missing stream ", path)
		return null

	var resource: Resource = load(path)
	return resource as AudioStream

func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if player == null:
			continue
		if not player.playing:
			return player

	if _sfx_players.is_empty():
		return null
	return _sfx_players[0]

func _linear_to_db_safe(value: float) -> float:
	var clamped_value: float = clampf(value, 0.0, 1.0)
	if clamped_value <= 0.0001:
		return -80.0
	return linear_to_db(clamped_value)
