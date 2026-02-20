extends Control

@export_file("*.tscn") var arena_scene_path: String = "res://scenes/arena.tscn"
const GAMEPLAY_SETTINGS = preload("res://scripts/systems/gameplay_settings.gd")

@onready var play_button: Button = get_node_or_null("Root/MenuPanel/Content/Buttons/PlayButton")
@onready var options_button: Button = get_node_or_null("Root/MenuPanel/Content/Buttons/OptionsButton")
@onready var credits_button: Button = get_node_or_null("Root/MenuPanel/Content/Buttons/CreditsButton")
@onready var quit_button: Button = get_node_or_null("Root/MenuPanel/Content/Buttons/QuitButton")
@onready var options_panel: PanelContainer = get_node_or_null("OptionsPanel")
@onready var credits_panel: PanelContainer = get_node_or_null("CreditsPanel")
@onready var difficulty_panel: PanelContainer = get_node_or_null("DifficultyPanel")
@onready var sfx_slider: HSlider = get_node_or_null("OptionsPanel/OptionsContent/AudioRows/SfxRow/SfxSlider")
@onready var sfx_mute_toggle: CheckButton = get_node_or_null("OptionsPanel/OptionsContent/AudioRows/SfxRow/SfxMuteToggle")
@onready var music_slider: HSlider = get_node_or_null("OptionsPanel/OptionsContent/AudioRows/MusicRow/MusicSlider")
@onready var music_mute_toggle: CheckButton = get_node_or_null("OptionsPanel/OptionsContent/AudioRows/MusicRow/MusicMuteToggle")
@onready var fps_limit_option_button: OptionButton = get_node_or_null("OptionsPanel/OptionsContent/FpsLimitRow/FpsLimitOptionButton")
@onready var options_difficulty_row: HBoxContainer = get_node_or_null("OptionsPanel/OptionsContent/DifficultyRow")
@onready var difficulty_option_button: OptionButton = get_node_or_null("DifficultyPanel/DifficultyContent/DifficultyPickerRow/DifficultyOptionButton")
@onready var difficulty_description_label: Label = get_node_or_null("DifficultyPanel/DifficultyContent/DifficultyDescriptionPanel/DifficultyDescriptionPadding/DifficultyDescription")
@onready var difficulty_confirm_button: Button = get_node_or_null("DifficultyPanel/DifficultyContent/DifficultyButtons/ConfirmDifficultyButton")
@onready var difficulty_cancel_button: Button = get_node_or_null("DifficultyPanel/DifficultyContent/DifficultyButtons/CancelDifficultyButton")
@onready var close_options_button: Button = get_node_or_null("OptionsPanel/OptionsContent/CloseOptionsButton")
@onready var close_credits_button: Button = get_node_or_null("CreditsPanel/CreditsContent/CloseCreditsButton")
@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")

var _arena_preload_started: bool = false
var _arena_preload_ready: bool = false
var _arena_preload_failed: bool = false
var _arena_scene_cache: PackedScene
var _play_requested_while_loading: bool = false
var _sfx_reentry_guard: bool = false
var _selected_difficulty_id: String = "medium"
var _selected_fps_limit_id: String = "unlimited"
var _syncing_fps_controls: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GAMEPLAY_SETTINGS.apply_saved_fps_limit()
	_connect_ui()
	_set_options_visible(false)
	_set_credits_visible(false)
	_set_difficulty_visible(false)
	_setup_difficulty_controls()
	_setup_audio_controls()
	_play_music("bgm_menu_loop")
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
	if difficulty_panel != null and difficulty_panel.visible:
		_set_difficulty_visible(false)
		_play_sfx("sfx_ui_click")
		get_viewport().set_input_as_handled()
		return
	if options_panel != null and options_panel.visible:
		_set_options_visible(false)
		_play_sfx("sfx_ui_click")
		get_viewport().set_input_as_handled()
		return
	if credits_panel != null and credits_panel.visible:
		_set_credits_visible(false)
		_play_sfx("sfx_ui_click")
		get_viewport().set_input_as_handled()
		return

func _connect_ui() -> void:
	var play_callable := Callable(self, "_on_play_pressed")
	if play_button != null and not play_button.pressed.is_connected(play_callable):
		play_button.pressed.connect(play_callable)

	var options_callable := Callable(self, "_on_options_pressed")
	if options_button != null and not options_button.pressed.is_connected(options_callable):
		options_button.pressed.connect(options_callable)

	var credits_callable := Callable(self, "_on_credits_pressed")
	if credits_button != null and not credits_button.pressed.is_connected(credits_callable):
		credits_button.pressed.connect(credits_callable)

	var quit_callable := Callable(self, "_on_quit_pressed")
	if quit_button != null and not quit_button.pressed.is_connected(quit_callable):
		quit_button.pressed.connect(quit_callable)

	var close_options_callable := Callable(self, "_on_close_options_pressed")
	if close_options_button != null and not close_options_button.pressed.is_connected(close_options_callable):
		close_options_button.pressed.connect(close_options_callable)

	var close_credits_callable := Callable(self, "_on_close_credits_pressed")
	if close_credits_button != null and not close_credits_button.pressed.is_connected(close_credits_callable):
		close_credits_button.pressed.connect(close_credits_callable)

	var confirm_difficulty_callable := Callable(self, "_on_confirm_difficulty_pressed")
	if difficulty_confirm_button != null and not difficulty_confirm_button.pressed.is_connected(confirm_difficulty_callable):
		difficulty_confirm_button.pressed.connect(confirm_difficulty_callable)

	var cancel_difficulty_callable := Callable(self, "_on_cancel_difficulty_pressed")
	if difficulty_cancel_button != null and not difficulty_cancel_button.pressed.is_connected(cancel_difficulty_callable):
		difficulty_cancel_button.pressed.connect(cancel_difficulty_callable)

func _on_play_pressed() -> void:
	_play_sfx("sfx_ui_click")
	_set_options_visible(false)
	_set_credits_visible(false)
	_open_difficulty_panel()

func _on_options_pressed() -> void:
	_play_sfx("sfx_ui_click")
	if options_panel == null:
		return
	_set_difficulty_visible(false)
	_set_credits_visible(false)
	_set_options_visible(not options_panel.visible)

func _on_close_options_pressed() -> void:
	_play_sfx("sfx_ui_click")
	_set_options_visible(false)

func _on_credits_pressed() -> void:
	_play_sfx("sfx_ui_click")
	if credits_panel == null:
		return
	_set_difficulty_visible(false)
	_set_options_visible(false)
	_set_credits_visible(not credits_panel.visible)

func _on_close_credits_pressed() -> void:
	_play_sfx("sfx_ui_click")
	_set_credits_visible(false)

func _on_quit_pressed() -> void:
	_play_sfx("sfx_ui_click")
	get_tree().quit()

func _set_options_visible(should_show: bool) -> void:
	if options_panel != null:
		options_panel.visible = should_show

func _set_credits_visible(should_show: bool) -> void:
	if credits_panel != null:
		credits_panel.visible = should_show

func _set_difficulty_visible(should_show: bool) -> void:
	if difficulty_panel != null:
		difficulty_panel.visible = should_show

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

	_setup_fps_limit_controls()

func _setup_fps_limit_controls() -> void:
	if fps_limit_option_button == null:
		return
	_selected_fps_limit_id = GAMEPLAY_SETTINGS.load_fps_limit_id()
	_style_option_picker(fps_limit_option_button)
	fps_limit_option_button.clear()

	var fps_limit_ids: Array[String] = GAMEPLAY_SETTINGS.get_ordered_fps_limit_ids()
	var selected_index: int = 0
	for index in range(fps_limit_ids.size()):
		var fps_limit_id: String = String(fps_limit_ids[index])
		var display_name: String = GAMEPLAY_SETTINGS.get_fps_limit_display_name(fps_limit_id)
		fps_limit_option_button.add_item(display_name)
		if fps_limit_id == _selected_fps_limit_id:
			selected_index = index

	var selected_callable := Callable(self, "_on_fps_limit_option_selected")
	if not fps_limit_option_button.item_selected.is_connected(selected_callable):
		fps_limit_option_button.item_selected.connect(selected_callable)

	_syncing_fps_controls = true
	fps_limit_option_button.select(selected_index)
	_syncing_fps_controls = false
	GAMEPLAY_SETTINGS.apply_fps_limit_id(_selected_fps_limit_id)

func _on_fps_limit_option_selected(index: int) -> void:
	if _syncing_fps_controls:
		return
	if fps_limit_option_button == null:
		return
	var fps_limit_ids: Array[String] = GAMEPLAY_SETTINGS.get_ordered_fps_limit_ids()
	if fps_limit_ids.is_empty():
		return
	var clamped_index: int = clampi(index, 0, fps_limit_ids.size() - 1)
	_selected_fps_limit_id = GAMEPLAY_SETTINGS.sanitize_fps_limit_id(String(fps_limit_ids[clamped_index]))
	GAMEPLAY_SETTINGS.save_fps_limit_id(_selected_fps_limit_id)
	GAMEPLAY_SETTINGS.apply_fps_limit_id(_selected_fps_limit_id)
	_play_sfx("sfx_ui_click")

func _setup_difficulty_controls() -> void:
	_selected_difficulty_id = GAMEPLAY_SETTINGS.load_difficulty_id()
	if options_difficulty_row != null:
		options_difficulty_row.visible = false
	if difficulty_option_button == null:
		return

	_style_difficulty_picker()
	difficulty_option_button.clear()
	var difficulty_ids: Array[String] = GAMEPLAY_SETTINGS.get_ordered_difficulty_ids()
	var selected_index: int = 0
	for index in range(difficulty_ids.size()):
		var difficulty_id: String = String(difficulty_ids[index])
		var display_name: String = GAMEPLAY_SETTINGS.get_difficulty_display_name(difficulty_id)
		difficulty_option_button.add_item(display_name)
		if difficulty_id == _selected_difficulty_id:
			selected_index = index

	var selected_callable := Callable(self, "_on_difficulty_option_selected")
	if not difficulty_option_button.item_selected.is_connected(selected_callable):
		difficulty_option_button.item_selected.connect(selected_callable)
	difficulty_option_button.select(selected_index)
	_refresh_difficulty_description()

func _on_difficulty_option_selected(index: int) -> void:
	if difficulty_option_button == null:
		return
	var difficulty_ids: Array[String] = GAMEPLAY_SETTINGS.get_ordered_difficulty_ids()
	if difficulty_ids.is_empty():
		return
	var clamped_index: int = clampi(index, 0, difficulty_ids.size() - 1)
	_selected_difficulty_id = GAMEPLAY_SETTINGS.sanitize_difficulty_id(String(difficulty_ids[clamped_index]))
	_refresh_difficulty_description()
	_play_sfx("sfx_ui_click")

func _open_difficulty_panel() -> void:
	_selected_difficulty_id = GAMEPLAY_SETTINGS.load_difficulty_id()
	if difficulty_option_button != null:
		var difficulty_ids: Array[String] = GAMEPLAY_SETTINGS.get_ordered_difficulty_ids()
		var selected_index: int = 0
		for index in range(difficulty_ids.size()):
			if String(difficulty_ids[index]) == _selected_difficulty_id:
				selected_index = index
				break
		difficulty_option_button.select(selected_index)
	_refresh_difficulty_description()
	_set_difficulty_visible(true)

func _on_confirm_difficulty_pressed() -> void:
	_play_sfx("sfx_ui_click")
	GAMEPLAY_SETTINGS.save_difficulty_id(_selected_difficulty_id)
	_set_difficulty_visible(false)
	_start_arena_run()

func _on_cancel_difficulty_pressed() -> void:
	_play_sfx("sfx_ui_click")
	_set_difficulty_visible(false)

func _refresh_difficulty_description() -> void:
	if difficulty_description_label == null:
		return
	difficulty_description_label.text = _build_difficulty_description(_selected_difficulty_id)

func _build_difficulty_description(difficulty_id: String) -> String:
	var safe_difficulty_id: String = GAMEPLAY_SETTINGS.sanitize_difficulty_id(difficulty_id)
	var difficulty_data: Dictionary = GAMEPLAY_SETTINGS.get_difficulty_data(safe_difficulty_id)
	var speed_multiplier: float = float(difficulty_data.get("enemy_speed_multiplier", 1.0))
	var hp_multiplier: float = float(difficulty_data.get("enemy_hp_multiplier", 1.0))
	var damage_multiplier: float = float(difficulty_data.get("enemy_damage_multiplier", 1.0))
	var summary: String = "Standard run pressure."
	match safe_difficulty_id:
		"easy":
			summary = "Forgiving pressure. Best for learning builds."
		"hard":
			summary = "High pressure. Enemies are much deadlier."

	return "Enemy pressure profile: %s\nEnemy HP: x%.2f\nEnemy Damage: x%.2f\nEnemy Speed: x%.2f" % [
		summary,
		hp_multiplier,
		damage_multiplier,
		speed_multiplier
	]

func _style_option_picker(option_button: OptionButton) -> void:
	if option_button == null:
		return
	option_button.flat = false
	option_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	option_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

	var border_color := Color(0.40, 0.73, 0.96, 0.82)
	var normal_style := _create_flat_stylebox(Color(0.05, 0.11, 0.18, 0.98), border_color, 9, 1)
	var hover_style := _create_flat_stylebox(Color(0.08, 0.15, 0.24, 0.99), Color(0.56, 0.85, 1.0, 0.95), 9, 1)
	var pressed_style := _create_flat_stylebox(Color(0.10, 0.19, 0.29, 0.99), Color(0.66, 0.90, 1.0, 1.0), 9, 1)
	var disabled_style := _create_flat_stylebox(Color(0.05, 0.10, 0.16, 0.90), Color(0.35, 0.55, 0.70, 0.55), 9, 1)
	normal_style.content_margin_left = 14.0
	normal_style.content_margin_right = 36.0
	hover_style.content_margin_left = 14.0
	hover_style.content_margin_right = 36.0
	pressed_style.content_margin_left = 14.0
	pressed_style.content_margin_right = 36.0
	disabled_style.content_margin_left = 14.0
	disabled_style.content_margin_right = 36.0

	option_button.add_theme_stylebox_override("normal", normal_style)
	option_button.add_theme_stylebox_override("hover", hover_style)
	option_button.add_theme_stylebox_override("pressed", pressed_style)
	option_button.add_theme_stylebox_override("focus", hover_style)
	option_button.add_theme_stylebox_override("disabled", disabled_style)
	option_button.add_theme_color_override("font_color", Color(0.92, 0.97, 1.0, 1.0))
	option_button.add_theme_color_override("font_hover_color", Color(0.97, 0.99, 1.0, 1.0))
	option_button.add_theme_color_override("font_focus_color", Color(0.97, 0.99, 1.0, 1.0))
	option_button.add_theme_color_override("font_pressed_color", Color(0.97, 0.99, 1.0, 1.0))
	option_button.add_theme_color_override("font_disabled_color", Color(0.70, 0.80, 0.89, 0.85))

	var popup: PopupMenu = option_button.get_popup()
	if popup == null:
		return
	popup.add_theme_stylebox_override("panel", _create_flat_stylebox(Color(0.04, 0.10, 0.17, 0.99), border_color, 8, 1))
	popup.add_theme_stylebox_override("hover", _create_flat_stylebox(Color(0.09, 0.18, 0.28, 0.99), Color(0.60, 0.88, 1.0, 0.85), 4, 1))
	popup.add_theme_color_override("font_color", Color(0.91, 0.97, 1.0, 1.0))
	popup.add_theme_color_override("font_hover_color", Color(0.98, 1.0, 1.0, 1.0))
	popup.add_theme_color_override("font_disabled_color", Color(0.67, 0.77, 0.86, 0.75))
	popup.add_theme_color_override("font_separator_color", Color(0.63, 0.82, 0.95, 0.75))
	popup.add_theme_color_override("font_accelerator_color", Color(0.72, 0.87, 0.97, 0.85))

func _style_difficulty_picker() -> void:
	if difficulty_option_button == null:
		return
	_style_option_picker(difficulty_option_button)

func _create_flat_stylebox(background: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	return style

func _start_arena_run() -> void:
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
	if _sfx_reentry_guard:
		return
	if audio_manager == null:
		return
	if audio_manager == self:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	_sfx_reentry_guard = true
	audio_manager.call("play_sfx", event_id)
	_sfx_reentry_guard = false

func _stop_music() -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("stop_music"):
		return
	audio_manager.call("stop_music")

func _play_music(track_id: String = "bgm_menu_loop") -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_music"):
		return
	audio_manager.call("play_music", track_id)

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
