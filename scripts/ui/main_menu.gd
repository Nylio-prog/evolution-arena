extends Control

@export_file("*.tscn") var arena_scene_path: String = "res://scenes/arena.tscn"

@onready var play_button: Button = get_node_or_null("Root/MenuPanel/Content/Buttons/PlayButton")
@onready var options_button: Button = get_node_or_null("Root/MenuPanel/Content/Buttons/OptionsButton")
@onready var quit_button: Button = get_node_or_null("Root/MenuPanel/Content/Buttons/QuitButton")
@onready var options_panel: PanelContainer = get_node_or_null("OptionsPanel")
@onready var sfx_slider: HSlider = get_node_or_null("OptionsPanel/OptionsContent/AudioRows/SfxRow/SfxSlider")
@onready var sfx_mute_toggle: CheckButton = get_node_or_null("OptionsPanel/OptionsContent/AudioRows/SfxRow/SfxMuteToggle")
@onready var music_slider: HSlider = get_node_or_null("OptionsPanel/OptionsContent/AudioRows/MusicRow/MusicSlider")
@onready var music_mute_toggle: CheckButton = get_node_or_null("OptionsPanel/OptionsContent/AudioRows/MusicRow/MusicMuteToggle")
@onready var close_options_button: Button = get_node_or_null("OptionsPanel/OptionsContent/CloseOptionsButton")
@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")

var _arena_preload_started: bool = false
var _arena_preload_ready: bool = false
var _arena_preload_failed: bool = false
var _arena_scene_cache: PackedScene
var _play_requested_while_loading: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_connect_ui()
	_set_options_visible(false)
	_setup_audio_controls()
	_stop_music()
	_begin_arena_preload()

func _process(_delta: float) -> void:
	_poll_arena_preload()

func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null:
		return
	if not key_event.pressed or key_event.echo:
		return
	if key_event.keycode != KEY_ESCAPE:
		return
	if options_panel == null or not options_panel.visible:
		return

	_set_options_visible(false)
	_play_sfx("ui_click")
	get_viewport().set_input_as_handled()

func _connect_ui() -> void:
	var play_callable := Callable(self, "_on_play_pressed")
	if play_button != null and not play_button.pressed.is_connected(play_callable):
		play_button.pressed.connect(play_callable)

	var options_callable := Callable(self, "_on_options_pressed")
	if options_button != null and not options_button.pressed.is_connected(options_callable):
		options_button.pressed.connect(options_callable)

	var quit_callable := Callable(self, "_on_quit_pressed")
	if quit_button != null and not quit_button.pressed.is_connected(quit_callable):
		quit_button.pressed.connect(quit_callable)

	var close_options_callable := Callable(self, "_on_close_options_pressed")
	if close_options_button != null and not close_options_button.pressed.is_connected(close_options_callable):
		close_options_button.pressed.connect(close_options_callable)

func _on_play_pressed() -> void:
	_play_sfx("ui_click")
	if _arena_preload_ready and _arena_scene_cache != null:
		get_tree().change_scene_to_packed(_arena_scene_cache)
		return
	if _arena_preload_failed:
		if not ResourceLoader.exists(arena_scene_path, "PackedScene"):
			push_error("MainMenu missing arena scene at: %s" % arena_scene_path)
			return
		get_tree().change_scene_to_file(arena_scene_path)
		return

	_begin_arena_preload()
	_play_requested_while_loading = true
	if play_button != null:
		play_button.disabled = true
		play_button.text = "Loading..."

func _on_options_pressed() -> void:
	_play_sfx("ui_click")
	if options_panel == null:
		return
	_set_options_visible(not options_panel.visible)

func _on_close_options_pressed() -> void:
	_play_sfx("ui_click")
	_set_options_visible(false)

func _on_quit_pressed() -> void:
	_play_sfx("ui_click")
	get_tree().quit()

func _set_options_visible(should_show: bool) -> void:
	if options_panel != null:
		options_panel.visible = should_show

func _setup_audio_controls() -> void:
	var sfx_value: float = 0.5
	var music_value: float = 0.4
	var sfx_muted: bool = false
	var music_muted: bool = false

	if audio_manager != null:
		if audio_manager.has_method("get_sfx_volume_linear"):
			sfx_value = float(audio_manager.call("get_sfx_volume_linear"))
		if audio_manager.has_method("get_music_volume_linear"):
			music_value = float(audio_manager.call("get_music_volume_linear"))
		if audio_manager.has_method("get_sfx_muted"):
			sfx_muted = bool(audio_manager.call("get_sfx_muted"))
		if audio_manager.has_method("get_music_muted"):
			music_muted = bool(audio_manager.call("get_music_muted"))

	if sfx_slider != null:
		sfx_slider.value = sfx_value
		var sfx_changed_callable := Callable(self, "_on_sfx_slider_value_changed")
		if not sfx_slider.value_changed.is_connected(sfx_changed_callable):
			sfx_slider.value_changed.connect(sfx_changed_callable)
		_on_sfx_slider_value_changed(sfx_slider.value)

	if sfx_mute_toggle != null:
		sfx_mute_toggle.button_pressed = sfx_muted
		var sfx_toggle_callable := Callable(self, "_on_sfx_mute_toggled")
		if not sfx_mute_toggle.toggled.is_connected(sfx_toggle_callable):
			sfx_mute_toggle.toggled.connect(sfx_toggle_callable)
		_on_sfx_mute_toggled(sfx_mute_toggle.button_pressed)

	if music_slider != null:
		music_slider.value = music_value
		var music_changed_callable := Callable(self, "_on_music_slider_value_changed")
		if not music_slider.value_changed.is_connected(music_changed_callable):
			music_slider.value_changed.connect(music_changed_callable)
		_on_music_slider_value_changed(music_slider.value)

	if music_mute_toggle != null:
		music_mute_toggle.button_pressed = music_muted
		var music_toggle_callable := Callable(self, "_on_music_mute_toggled")
		if not music_mute_toggle.toggled.is_connected(music_toggle_callable):
			music_mute_toggle.toggled.connect(music_toggle_callable)
		_on_music_mute_toggled(music_mute_toggle.button_pressed)

func _on_sfx_slider_value_changed(value: float) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("set_sfx_volume_linear"):
		return
	audio_manager.call("set_sfx_volume_linear", value)

func _on_music_slider_value_changed(value: float) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("set_music_volume_linear"):
		return
	audio_manager.call("set_music_volume_linear", value)

func _on_sfx_mute_toggled(pressed: bool) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("set_sfx_muted"):
		return
	audio_manager.call("set_sfx_muted", pressed)

func _on_music_mute_toggled(pressed: bool) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("set_music_muted"):
		return
	audio_manager.call("set_music_muted", pressed)

func _play_sfx(event_id: String) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id)

func _stop_music() -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("stop_music"):
		return
	audio_manager.call("stop_music")

func _begin_arena_preload() -> void:
	if _arena_preload_started:
		return
	if arena_scene_path.is_empty():
		_arena_preload_failed = true
		return
	if not ResourceLoader.exists(arena_scene_path, "PackedScene"):
		_arena_preload_failed = true
		return

	var request_error: int = ResourceLoader.load_threaded_request(arena_scene_path, "PackedScene", true)
	if request_error != OK:
		_arena_preload_failed = true
		return
	_arena_preload_started = true
	set_process(true)

func _poll_arena_preload() -> void:
	if not _arena_preload_started:
		return
	if _arena_preload_ready:
		return
	if _arena_preload_failed:
		return

	var progress: Array = []
	var status: int = ResourceLoader.load_threaded_get_status(arena_scene_path, progress)
	if status == ResourceLoader.THREAD_LOAD_FAILED:
		_arena_preload_failed = true
		_restore_play_button_after_loading()
		return
	if status != ResourceLoader.THREAD_LOAD_LOADED:
		return

	var loaded_resource_variant: Variant = ResourceLoader.load_threaded_get(arena_scene_path)
	var loaded_scene: PackedScene = loaded_resource_variant as PackedScene
	if loaded_scene == null:
		_arena_preload_failed = true
		_restore_play_button_after_loading()
		return

	_arena_scene_cache = loaded_scene
	_arena_preload_ready = true
	_restore_play_button_after_loading()
	if _play_requested_while_loading:
		_play_requested_while_loading = false
		get_tree().change_scene_to_packed(_arena_scene_cache)

func _restore_play_button_after_loading() -> void:
	if play_button == null:
		return
	play_button.disabled = false
	play_button.text = "Play"
