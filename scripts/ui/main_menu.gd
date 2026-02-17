extends Control

@export_file("*.tscn") var arena_scene_path: String = "res://scenes/arena.tscn"

@onready var play_button: Button = get_node_or_null("Root/MenuPanel/Content/Buttons/PlayButton")
@onready var options_button: Button = get_node_or_null("Root/MenuPanel/Content/Buttons/OptionsButton")
@onready var quit_button: Button = get_node_or_null("Root/MenuPanel/Content/Buttons/QuitButton")
@onready var options_panel: PanelContainer = get_node_or_null("OptionsPanel")
@onready var close_options_button: Button = get_node_or_null("OptionsPanel/OptionsContent/CloseOptionsButton")
@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_connect_ui()
	_set_options_visible(false)
	_play_music("bgm_main")

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
	if not ResourceLoader.exists(arena_scene_path, "PackedScene"):
		push_error("MainMenu missing arena scene at: %s" % arena_scene_path)
		return
	get_tree().change_scene_to_file(arena_scene_path)

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

func _set_options_visible(visible: bool) -> void:
	if options_panel != null:
		options_panel.visible = visible

func _play_sfx(event_id: String) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id)

func _play_music(track_id: String) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_music"):
		return
	audio_manager.call("play_music", track_id)
