extends Node

const BUS_MASTER := "Master"
const BUS_SFX := "SFX"
const BUS_MUSIC := "Music"
const DEFAULT_SFX_POLYPHONY := 8
const DEFAULT_STREAM_PATHS: Dictionary = {
	# Canonical R5 IDs from plan/release5_assets_prompts.md
	"sfx_ui_click": "res://audio/sfx/sfx_ui_click.wav",
	"sfx_ui_hover": "res://audio/sfx/sfx_ui_hover.wav",
	"sfx_pickup_biomass": "res://audio/sfx/sfx_pickup_biomass.wav",
	"sfx_enemy_death": "res://audio/sfx/sfx_enemy_death.wav",
	"sfx_enemy_elite_death": "res://audio/sfx/sfx_enemy_elite_death.wav",
	"sfx_levelup": "res://audio/sfx/sfx_levelup.wav",
	"sfx_player_hit": "res://audio/sfx/sfx_player_hit.wav",
	"sfx_variant_pick": "res://audio/sfx/sfx_variant_pick.wav",
	"sfx_event_start": "res://audio/sfx/sfx_event_start.wav",
	"sfx_event_clear": "res://audio/sfx/sfx_event_clear.wav",
	"sfx_defeat": "res://audio/sfx/sfx_defeat.wav",
	"sfx_victory": "res://audio/sfx/sfx_victory.wav",
	"sfx_boss_spawn": "res://audio/sfx/sfx_boss_spawn.wav",
	"sfx_boss_phase_shift": "res://audio/sfx/sfx_boss_phase_shift.wav",
	"sfx_proto_pulse": "res://audio/sfx/sfx_proto_pulse.wav",
	"sfx_razor_halo_hit": "res://audio/sfx/sfx_razor_halo_hit.wav",
	"sfx_puncture_lance_fire": "res://audio/sfx/sfx_puncture_lance_fire.wav",
	"sfx_lytic_burst": "res://audio/sfx/sfx_lytic_burst.wav",
	"sfx_infective_trail_tick": "res://audio/sfx/sfx_infective_trail_tick.wav",
	"sfx_chain_bloom": "res://audio/sfx/sfx_chain_bloom.wav",
	"sfx_leech_tendril_loop": "res://audio/sfx/sfx_leech_tendril_loop.wav",
	"sfx_host_override_cast": "res://audio/sfx/sfx_host_override_cast.wav",
	"bgm_main": "res://audio/music/bgm_run_loop.mp3",
	"bgm_menu_loop": "res://audio/music/bgm_menu_loop.mp3",
	"bgm_boss_loop": "res://audio/music/bgm_boss_loop.mp3",
	"bgm_victory_sting": "res://audio/music/bgm_victory_sting.mp3",
	"bgm_defeat_sting": "res://audio/music/bgm_defeat_sting.mp3",

	# Backward-compat aliases used by current gameplay code paths.
	"ui_click": "res://audio/sfx/sfx_ui_click.wav",
	"pickup": "res://audio/sfx/sfx_pickup_biomass.wav",
	"enemy_death": "res://audio/sfx/sfx_enemy_death.wav",
	"levelup": "res://audio/sfx/sfx_levelup.wav",
	"player_hit": "res://audio/sfx/sfx_player_hit.wav",
	"player_death": "res://audio/sfx/sfx_defeat.wav",
	"crisis_start": "res://audio/sfx/sfx_event_start.wav",
	"crisis_success": "res://audio/sfx/sfx_event_clear.wav",
	"crisis_fail": "res://audio/sfx/sfx_defeat.wav",
	"final_crisis_start": "res://audio/sfx/sfx_boss_spawn.wav",
	"victory": "res://audio/sfx/sfx_victory.wav"
}
const SFX_EVENT_COOLDOWN_SEC: Dictionary = {
	"sfx_ui_click": 0.04,
	"sfx_ui_hover": 0.04,
	"sfx_pickup_biomass": 0.05,
	"sfx_player_hit": 0.12,
	"sfx_enemy_death": 0.09,
	"sfx_enemy_elite_death": 0.12,
	"sfx_event_start": 0.15,
	"sfx_event_clear": 0.15,
	"sfx_defeat": 0.2,
	"sfx_boss_spawn": 0.25,
	"sfx_boss_phase_shift": 0.2,
	"sfx_victory": 0.2,
	"sfx_proto_pulse": 0.10,
	"sfx_razor_halo_hit": 0.03,
	"sfx_puncture_lance_fire": 0.05,
	"sfx_lytic_burst": 0.12,
	"sfx_infective_trail_tick": 0.08,
	"sfx_chain_bloom": 0.08,
	"sfx_leech_tendril_loop": 0.2,
	"sfx_host_override_cast": 0.15,

	# Backward-compat aliases.
	"ui_click": 0.04,
	"pickup": 0.05,
	"player_hit": 0.12,
	"enemy_death": 0.09,
	"crisis_start": 0.15,
	"crisis_success": 0.15,
	"crisis_fail": 0.2,
	"final_crisis_start": 0.25,
	"victory": 0.2
}

@export var default_sfx_volume_db: float = -6.0
@export var default_music_volume_db: float = -16.0
@export var sfx_polyphony: int = DEFAULT_SFX_POLYPHONY
@export var debug_log_missing_streams: bool = false

var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _music_fade_tween: Tween
var _stream_cache: Dictionary = {}
var _sfx_volume_linear: float = 1.0
var _music_volume_linear: float = 1.0
var _sfx_muted: bool = false
var _music_muted: bool = false
var _last_sfx_played_at: Dictionary = {}
var _sfx_dispatch_depth: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_audio_buses()
	_create_players()
	_set_default_bus_volumes()
	_preload_optional_streams()

func play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> bool:
	if _sfx_dispatch_depth >= 8:
		if debug_log_missing_streams:
			print("AudioManager: blocked recursive play_sfx call for ", event_id)
		return false
	_sfx_dispatch_depth += 1
	var played: bool = _play_sfx_internal(event_id, volume_db_offset, pitch_scale)
	_sfx_dispatch_depth = maxi(0, _sfx_dispatch_depth - 1)
	return played

func stop_sfx(event_id: String) -> void:
	if event_id.is_empty():
		return
	var target_stream: AudioStream = _get_stream(event_id)
	if target_stream == null:
		return
	for player in _sfx_players:
		if player == null:
			continue
		if not player.playing:
			continue
		if player.stream != target_stream:
			continue
		player.stop()
	_last_sfx_played_at.erase(event_id)

func _play_sfx_internal(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> bool:
	if _is_sfx_rate_limited(event_id):
		return false

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
	_last_sfx_played_at[event_id] = _get_time_seconds()
	return true

func play_music(track_id: String = "bgm_main", restart_if_same: bool = false) -> bool:
	if _music_player == null:
		return false
	if _music_fade_tween != null and is_instance_valid(_music_fade_tween):
		_music_fade_tween.kill()
		_music_fade_tween = null

	var stream: AudioStream = _get_stream(track_id)
	if stream == null and track_id != "bgm_main":
		# Keep runtime resilient when an optional track ID is requested but only bgm_main exists.
		stream = _get_stream("bgm_main")
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

	var mp3_stream: AudioStreamMP3 = stream as AudioStreamMP3
	if mp3_stream != null:
		mp3_stream.loop = true
		return

	var wav_stream: AudioStreamWAV = stream as AudioStreamWAV
	if wav_stream != null:
		wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

func stop_music() -> void:
	if _music_fade_tween != null and is_instance_valid(_music_fade_tween):
		_music_fade_tween.kill()
		_music_fade_tween = null
	if _music_player != null:
		_music_player.stop()
		_music_player.volume_db = 0.0

func fade_out_music(duration_seconds: float = 1.0) -> void:
	if _music_player == null:
		return
	if not _music_player.playing:
		return
	if _music_fade_tween != null and is_instance_valid(_music_fade_tween):
		_music_fade_tween.kill()
		_music_fade_tween = null

	var fade_duration: float = maxf(0.01, duration_seconds)
	_music_fade_tween = create_tween()
	_music_fade_tween.tween_property(_music_player, "volume_db", -80.0, fade_duration)
	_music_fade_tween.tween_callback(Callable(self, "_finish_music_fade_out"))

func _finish_music_fade_out() -> void:
	if _music_player == null:
		return
	_music_player.stop()
	_music_player.volume_db = 0.0
	_music_fade_tween = null

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
	_sfx_muted = muted
	var bus_index: int = AudioServer.get_bus_index(BUS_SFX)
	if bus_index >= 0:
		AudioServer.set_bus_mute(bus_index, muted)

func set_music_muted(muted: bool) -> void:
	_music_muted = muted
	var bus_index: int = AudioServer.get_bus_index(BUS_MUSIC)
	if bus_index >= 0:
		AudioServer.set_bus_mute(bus_index, muted)

func get_sfx_muted() -> bool:
	return _sfx_muted

func get_music_muted() -> bool:
	return _music_muted

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
	set_sfx_muted(false)
	set_music_muted(false)

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

func _is_sfx_rate_limited(event_id: String) -> bool:
	if not SFX_EVENT_COOLDOWN_SEC.has(event_id):
		return false

	var cooldown_seconds: float = float(SFX_EVENT_COOLDOWN_SEC.get(event_id, 0.0))
	if cooldown_seconds <= 0.0:
		return false

	var now_seconds: float = _get_time_seconds()
	var last_played_seconds: float = float(_last_sfx_played_at.get(event_id, -1000.0))
	return (now_seconds - last_played_seconds) < cooldown_seconds

func _get_time_seconds() -> float:
	return float(Time.get_ticks_usec()) / 1000000.0
