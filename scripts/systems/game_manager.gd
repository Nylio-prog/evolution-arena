extends Node2D

const BIOMASS_PICKUP_SCENE: PackedScene = preload("res://scenes/systems/biomass_pickup.tscn")
const MUTATION_ICON_SPIKES: Texture2D = preload("res://art/sprites/ui/mutation_spikes.png")
const MUTATION_ICON_ORBITERS: Texture2D = preload("res://art/sprites/ui/mutation_orbiters.png")
const MUTATION_ICON_MEMBRANE: Texture2D = preload("res://art/sprites/ui/mutation_membrane.png")
const MUTATION_ICON_PULSE_NOVA: Texture2D = preload("res://art/sprites/ui/mutation_pulse_nova.png")
const MUTATION_ICON_ACID_TRAIL: Texture2D = preload("res://art/sprites/ui/mutation_acid_trail.png")
const MUTATION_ICON_METABOLISM: Texture2D = preload("res://art/sprites/ui/mutation_metabolism.png")
const MUTATION_ICON_BY_ID: Dictionary = {
	"spikes": MUTATION_ICON_SPIKES,
	"orbiters": MUTATION_ICON_ORBITERS,
	"membrane": MUTATION_ICON_MEMBRANE,
	"pulse_nova": MUTATION_ICON_PULSE_NOVA,
	"acid_trail": MUTATION_ICON_ACID_TRAIL,
	"metabolism": MUTATION_ICON_METABOLISM
}

@onready var player: Node = get_node_or_null("Player")
@onready var xp_system: Node = get_node_or_null("XpSystem")
@onready var mutation_system: Node = get_node_or_null("MutationSystem")
@onready var hp_label: Label = get_node_or_null("UiHud/HPLabel")
@onready var metabolism_label: Label = get_node_or_null("UiHud/MetabolismLabel")
@onready var xp_bar: ProgressBar = get_node_or_null("UiHud/XPBar")
@onready var level_label: Label = get_node_or_null("UiHud/LevelLabel")
@onready var timer_label: Label = get_node_or_null("UiHud/TimerLabel")
@onready var lineage_label: Label = get_node_or_null("UiHud/LineageLabel")
@onready var audio_button: Button = get_node_or_null("UiHud/AudioButton")
@onready var audio_panel: Control = get_node_or_null("UiHud/AudioPanel")
@onready var sfx_slider: HSlider = get_node_or_null("UiHud/AudioPanel/Padding/Rows/SfxSlider")
@onready var sfx_mute_toggle: CheckButton = get_node_or_null("UiHud/AudioPanel/Padding/Rows/SfxMuteToggle")
@onready var music_slider: HSlider = get_node_or_null("UiHud/AudioPanel/Padding/Rows/MusicSlider")
@onready var music_mute_toggle: CheckButton = get_node_or_null("UiHud/AudioPanel/Padding/Rows/MusicMuteToggle")
@onready var levelup_ui: CanvasLayer = get_node_or_null("UiLevelup")
@onready var levelup_lineage_prompt_label: Label = get_node_or_null("UiLevelup/Root/Layout/LineagePromptLabel")
@onready var levelup_help_label: Label = get_node_or_null("UiLevelup/Root/Layout/HelpLabel")
@onready var levelup_choices_row: HBoxContainer = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow")
@onready var levelup_choice_1: Button = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton1")
@onready var levelup_choice_2: Button = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton2")
@onready var levelup_choice_3: Button = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton3")
@onready var levelup_choice_1_icon: TextureRect = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton1/MutationIcon")
@onready var levelup_choice_2_icon: TextureRect = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton2/MutationIcon")
@onready var levelup_choice_3_icon: TextureRect = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton3/MutationIcon")
@onready var levelup_choice_1_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton1/MutationText")
@onready var levelup_choice_2_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton2/MutationText")
@onready var levelup_choice_3_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton3/MutationText")
@onready var lineage_choices_column: VBoxContainer = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn")
@onready var lineage_choice_1: Button = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton1")
@onready var lineage_choice_2: Button = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton2")
@onready var lineage_choice_3: Button = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton3")
@onready var lineage_choice_1_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton1/LineageText")
@onready var lineage_choice_2_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton2/LineageText")
@onready var lineage_choice_3_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton3/LineageText")
@onready var lineage_bottom_padding: Control = get_node_or_null("UiLevelup/Root/Layout/LineageBottomPadding")
@onready var game_over_ui: CanvasLayer = get_node_or_null("GameOver")
@onready var game_over_stats_label: Label = get_node_or_null("GameOver/Root/StatsLabel")
@onready var game_over_restart_button: Button = get_node_or_null("GameOver/Root/RestartButton")
@onready var pause_menu_ui: CanvasLayer = get_node_or_null("PauseMenu")
@onready var pause_resume_button: Button = get_node_or_null("PauseMenu/Root/Content/Buttons/ResumeButton")
@onready var pause_options_button: Button = get_node_or_null("PauseMenu/Root/Content/Buttons/OptionsButton")
@onready var pause_main_menu_button: Button = get_node_or_null("PauseMenu/Root/Content/Buttons/MainMenuButton")
@onready var pause_options_panel: PanelContainer = get_node_or_null("PauseMenu/Root/Content/OptionsPanel")
@onready var pause_sfx_slider: HSlider = get_node_or_null("PauseMenu/Root/Content/OptionsPanel/Padding/AudioRows/SfxRow/SfxSlider")
@onready var pause_sfx_mute_toggle: CheckButton = get_node_or_null("PauseMenu/Root/Content/OptionsPanel/Padding/AudioRows/SfxRow/SfxMuteToggle")
@onready var pause_music_slider: HSlider = get_node_or_null("PauseMenu/Root/Content/OptionsPanel/Padding/AudioRows/MusicRow/MusicSlider")
@onready var pause_music_mute_toggle: CheckButton = get_node_or_null("PauseMenu/Root/Content/OptionsPanel/Padding/AudioRows/MusicRow/MusicMuteToggle")
@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")

var elapsed_seconds: float = 0.0
var level_reached: int = 1
var run_ended: bool = false
var run_paused_for_levelup: bool = false
var run_paused_for_menu: bool = false
var pending_levelup_count: int = 0
var debug_log_drops: bool = false
var levelup_options: Array = []
var lineage_selection_active: bool = false
var restart_requested: bool = false
var _last_player_hp: int = -1
var _syncing_audio_controls: bool = false
@export var debug_allow_grant_xp: bool = false
@export var debug_grant_xp_amount: int = 20

const LINEAGE_CHOICES: Array[String] = ["predator", "swarm", "bulwark"]

func _ready() -> void:
	if OS.has_feature("standalone") and not OS.has_feature("dev_cheats"):
		debug_allow_grant_xp = false

	if player != null and player.has_signal("hp_changed"):
		player.connect("hp_changed", Callable(self, "_on_player_hp_changed"))
	if player != null and player.has_signal("died"):
		player.connect("died", Callable(self, "_on_player_died"))
	if xp_system != null and xp_system.has_signal("xp_changed"):
		xp_system.connect("xp_changed", Callable(self, "_on_xp_changed"))
	if xp_system != null and xp_system.has_signal("level_changed"):
		xp_system.connect("level_changed", Callable(self, "_on_level_changed"))
	if xp_system != null and xp_system.has_signal("leveled_up"):
		xp_system.connect("leveled_up", Callable(self, "_on_player_leveled_up"))
	if mutation_system != null and mutation_system.has_method("setup"):
		mutation_system.call("setup", player)
	if mutation_system != null and mutation_system.has_signal("lineage_changed"):
		mutation_system.connect("lineage_changed", Callable(self, "_on_lineage_changed"))
	if mutation_system != null and mutation_system.has_signal("mutation_applied"):
		mutation_system.connect("mutation_applied", Callable(self, "_on_mutation_applied"))

	if player != null:
		var current_hp_value = player.get("current_hp")
		var max_hp_value = player.get("max_hp")
		if current_hp_value != null and max_hp_value != null:
			_on_player_hp_changed(current_hp_value, max_hp_value)
	if xp_system != null:
		var current_xp_value = xp_system.get("current_xp")
		var xp_to_next_level_value = xp_system.get("xp_to_next_level")
		var current_level_value = xp_system.get("current_level")
		if current_xp_value != null and xp_to_next_level_value != null:
			_on_xp_changed(int(current_xp_value), int(xp_to_next_level_value))
		if current_level_value != null:
			_on_level_changed(int(current_level_value))
	_update_timer_label()
	_refresh_lineage_labels()
	_refresh_metabolism_hud()
	_setup_audio_controls()
	_play_music("bgm_main")

	for node in get_tree().get_nodes_in_group("biomass_pickups"):
		_connect_biomass_pickup(node as Node)
	for node in get_tree().get_nodes_in_group("enemies"):
		_connect_enemy_death(node as Node)
	get_tree().connect("node_added", Callable(self, "_on_tree_node_added"))

	if game_over_ui != null:
		game_over_ui.visible = false

	if game_over_restart_button != null:
		game_over_restart_button.disabled = false
		game_over_restart_button.connect("pressed", Callable(self, "_on_restart_pressed"))

	if pause_menu_ui != null:
		pause_menu_ui.visible = false
	if pause_options_panel != null:
		pause_options_panel.visible = false
	if pause_resume_button != null:
		var resume_callable := Callable(self, "_on_pause_resume_pressed")
		if not pause_resume_button.pressed.is_connected(resume_callable):
			pause_resume_button.pressed.connect(resume_callable)
	if pause_options_button != null:
		var options_callable := Callable(self, "_on_pause_options_pressed")
		if not pause_options_button.pressed.is_connected(options_callable):
			pause_options_button.pressed.connect(options_callable)
	if pause_main_menu_button != null:
		var main_menu_callable := Callable(self, "_on_pause_main_menu_pressed")
		if not pause_main_menu_button.pressed.is_connected(main_menu_callable):
			pause_main_menu_button.pressed.connect(main_menu_callable)

	if levelup_ui != null:
		levelup_ui.visible = false

	if levelup_choice_1 != null:
		levelup_choice_1.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(0))
	if levelup_choice_2 != null:
		levelup_choice_2.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(1))
	if levelup_choice_3 != null:
		levelup_choice_3.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(2))
	if lineage_choice_1 != null:
		lineage_choice_1.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(0))
	if lineage_choice_2 != null:
		lineage_choice_2.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(1))
	if lineage_choice_3 != null:
		lineage_choice_3.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(2))
	_set_levelup_mode(false)

func _process(delta: float) -> void:
	if run_ended:
		return
	if run_paused_for_menu:
		return
	if run_paused_for_levelup:
		return
	elapsed_seconds += delta
	_update_timer_label()

func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event != null and key_event.pressed and not key_event.echo:
		if key_event.keycode == KEY_G and _can_use_debug_xp_cheat():
			_debug_grant_xp()
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_ESCAPE and not run_ended and not run_paused_for_levelup:
			if run_paused_for_menu:
				_close_pause_menu()
			else:
				_open_pause_menu()
			get_viewport().set_input_as_handled()
			return

	if not run_paused_for_levelup:
		return
	if run_ended:
		return

	if key_event == null:
		return
	if not key_event.pressed:
		return
	if key_event.echo:
		return

	match key_event.keycode:
		KEY_1, KEY_KP_1:
			_on_levelup_choice_pressed(0)
			get_viewport().set_input_as_handled()
		KEY_2, KEY_KP_2:
			_on_levelup_choice_pressed(1)
			get_viewport().set_input_as_handled()
		KEY_3, KEY_KP_3:
			_on_levelup_choice_pressed(2)
			get_viewport().set_input_as_handled()

func _on_player_hp_changed(current_hp: int, max_hp: int) -> void:
	if hp_label != null:
		hp_label.text = "HP: %d/%d" % [current_hp, max_hp]
	if _last_player_hp >= 0 and current_hp < _last_player_hp:
		_play_sfx("player_hit")
	_last_player_hp = current_hp

func _on_xp_changed(current_xp: int, xp_to_next_level: int) -> void:
	if xp_bar == null:
		return
	xp_bar.min_value = 0.0
	xp_bar.max_value = float(xp_to_next_level)
	xp_bar.value = float(current_xp)

func _on_level_changed(current_level: int) -> void:
	level_reached = current_level
	if level_label == null:
		return
	level_label.text = "Level: %d" % current_level

func _on_lineage_changed(_lineage_id: String, _lineage_name: String) -> void:
	_refresh_lineage_labels()
	_refresh_metabolism_hud()

func _on_mutation_applied(_mutation_id: String, _new_level: int) -> void:
	_refresh_metabolism_hud()

func _refresh_lineage_labels() -> void:
	var current_lineage_name: String = _get_current_lineage_name()

	if lineage_label != null:
		lineage_label.text = "Lineage: %s" % current_lineage_name

	if levelup_lineage_prompt_label != null:
		if lineage_selection_active:
			levelup_lineage_prompt_label.text = "Choose your lineage"
		else:
			levelup_lineage_prompt_label.text = "Choose your mutation"

	if levelup_help_label != null:
		if lineage_selection_active:
			levelup_help_label.text = "Choose once. It grants a core mutation and biases future options."
		else:
			levelup_help_label.text = "Tip: * marks options favored by your lineage."

func _refresh_metabolism_hud() -> void:
	if metabolism_label == null:
		return
	if mutation_system == null:
		metabolism_label.visible = false
		return
	if not mutation_system.has_method("get_mutation_level"):
		metabolism_label.visible = false
		return

	var metabolism_level: int = int(mutation_system.call("get_mutation_level", "metabolism"))
	if metabolism_level <= 0:
		metabolism_label.visible = false
		return

	var regen_per_second: float = 0.0
	if mutation_system.has_method("get_metabolism_regen_per_second"):
		regen_per_second = float(mutation_system.call("get_metabolism_regen_per_second"))

	metabolism_label.visible = true
	metabolism_label.text = "Regen: +%.1f/s (L%d)" % [regen_per_second, metabolism_level]

func _on_tree_node_added(node: Node) -> void:
	_connect_enemy_death(node)
	_connect_biomass_pickup(node)

func _connect_enemy_death(node: Node) -> void:
	if node == null:
		return
	if node == player:
		return
	if not node.has_signal("died"):
		return
	if not node.has_method("take_damage"):
		return

	var death_callable := Callable(self, "_on_enemy_died")
	if node.is_connected("died", death_callable):
		return
	node.connect("died", death_callable)

func _connect_biomass_pickup(node: Node) -> void:
	if node == null:
		return
	if not node.has_signal("collected"):
		return

	var collected_callable := Callable(self, "_on_biomass_collected")
	if node.is_connected("collected", collected_callable):
		return
	node.connect("collected", collected_callable)

func _on_biomass_collected(amount: int) -> void:
	if xp_system == null:
		return
	if not xp_system.has_method("add_xp"):
		return
	xp_system.call("add_xp", amount)
	_play_sfx("pickup")

func _on_enemy_died(world_position: Vector2) -> void:
	if debug_log_drops:
		print("Enemy died at ", world_position, " -> spawning biomass")
	_play_sfx("enemy_death")
	call_deferred("_spawn_biomass_pickup", world_position)

func _spawn_biomass_pickup(world_position: Vector2) -> void:
	var pickup := BIOMASS_PICKUP_SCENE.instantiate() as Node2D
	if pickup == null:
		return
	add_child(pickup)
	var offset := Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
	pickup.global_position = world_position + offset
	if debug_log_drops:
		print("Biomass spawned at ", pickup.global_position)

func _on_player_died() -> void:
	if run_ended:
		return

	pending_levelup_count = 0
	run_paused_for_levelup = false
	run_paused_for_menu = false
	if levelup_ui != null:
		levelup_ui.visible = false
	if pause_menu_ui != null:
		pause_menu_ui.visible = false
	run_ended = true
	_play_sfx("player_death")
	_stop_music()
	_set_gameplay_active(false)
	_show_game_over()

func _set_gameplay_active(active: bool) -> void:
	if player != null:
		player.set_physics_process(active)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		var enemy_node := enemy as Node
		if enemy_node == null:
			continue
		enemy_node.set_physics_process(active)

	for module_node_raw in get_tree().get_nodes_in_group("player_modules"):
		var module_node := module_node_raw as Node
		if module_node == null:
			continue
		module_node.set_process(active)
		module_node.set_physics_process(active)

	for spawner_node_raw in get_tree().get_nodes_in_group("enemy_spawners"):
		var spawner_node := spawner_node_raw as Node
		if spawner_node == null:
			continue
		if spawner_node.has_method("set_spawning_enabled"):
			spawner_node.call("set_spawning_enabled", active)

func _show_game_over() -> void:
	if game_over_stats_label != null:
		game_over_stats_label.text = "Time: %ds | Level: %d | Lineage: %s" % [
			int(elapsed_seconds),
			level_reached,
			_get_current_lineage_name()
		]

	if game_over_ui != null:
		game_over_ui.visible = true

func _update_timer_label() -> void:
	if timer_label == null:
		return
	timer_label.text = "Time: %ds" % int(elapsed_seconds)

func _on_player_leveled_up(_new_level: int) -> void:
	if run_ended:
		return
	if run_paused_for_menu:
		pending_levelup_count += 1
		return
	if run_paused_for_levelup:
		pending_levelup_count += 1
		return

	_open_levelup_prompt()

func _on_levelup_choice_pressed(choice_index: int) -> void:
	if run_ended:
		return
	_play_sfx("ui_click")

	if lineage_selection_active:
		var lineage_applied: bool = _apply_lineage_choice(choice_index)
		if not lineage_applied:
			return
		_refresh_lineage_labels()
	else:
		if mutation_system != null and mutation_system.has_method("apply_option_index"):
			mutation_system.call("apply_option_index", choice_index)

	if pending_levelup_count > 0:
		pending_levelup_count -= 1
		var did_open_prompt: bool = _open_levelup_prompt(false)
		if did_open_prompt:
			return
		pending_levelup_count = 0

	_close_levelup_prompt()

func _on_restart_pressed() -> void:
	if restart_requested:
		return
	restart_requested = true
	if game_over_restart_button != null:
		game_over_restart_button.disabled = true
	_play_sfx("ui_click")
	call_deferred("_reload_current_scene_deferred")

func _on_pause_resume_pressed() -> void:
	_close_pause_menu()

func _on_pause_options_pressed() -> void:
	if pause_options_panel != null:
		var should_show_options: bool = not pause_options_panel.visible
		pause_options_panel.visible = should_show_options
		if should_show_options:
			_refresh_audio_controls_from_manager()
	_play_sfx("ui_click")

func _on_pause_main_menu_pressed() -> void:
	_play_sfx("ui_click")
	run_paused_for_menu = false
	if pause_menu_ui != null:
		pause_menu_ui.visible = false
	call_deferred("_go_to_main_menu_deferred")

func _open_pause_menu() -> void:
	if run_ended or run_paused_for_levelup or run_paused_for_menu:
		return
	run_paused_for_menu = true
	_set_gameplay_active(false)
	if pause_options_panel != null:
		pause_options_panel.visible = false
	if pause_menu_ui != null:
		pause_menu_ui.visible = true
	_play_sfx("ui_click")

func _close_pause_menu(play_click_sound: bool = true) -> void:
	if not run_paused_for_menu:
		return

	run_paused_for_menu = false
	if pause_menu_ui != null:
		pause_menu_ui.visible = false
	if pause_options_panel != null:
		pause_options_panel.visible = false
	if play_click_sound:
		_play_sfx("ui_click")

	var opened_levelup_prompt: bool = false
	if pending_levelup_count > 0 and not run_ended:
		pending_levelup_count -= 1
		opened_levelup_prompt = _open_levelup_prompt(false)
		if not opened_levelup_prompt:
			pending_levelup_count = 0

	if not opened_levelup_prompt:
		_set_gameplay_active(true)

func _go_to_main_menu_deferred() -> void:
	var main_menu_scene_path: String = "res://scenes/main_menu.tscn"
	if not ResourceLoader.exists(main_menu_scene_path, "PackedScene"):
		push_error("Main menu scene missing at: %s" % main_menu_scene_path)
		_set_gameplay_active(true)
		return
	get_tree().change_scene_to_file(main_menu_scene_path)

func _refresh_levelup_choice_text() -> Array:
	var options: Array = []
	_set_levelup_mode(false)
	_refresh_lineage_labels()
	if mutation_system != null and mutation_system.has_method("get_levelup_options"):
		var options_variant: Variant = mutation_system.call("get_levelup_options", 3)
		if options_variant is Array:
			options = options_variant

	_set_choice_button_text(levelup_choice_1, levelup_choice_1_icon, levelup_choice_1_text, options, 0)
	_set_choice_button_text(levelup_choice_2, levelup_choice_2_icon, levelup_choice_2_text, options, 1)
	_set_choice_button_text(levelup_choice_3, levelup_choice_3_icon, levelup_choice_3_text, options, 2)
	return options

func _set_choice_button_text(button: Button, icon: TextureRect, rich_text: RichTextLabel, options: Array, index: int) -> void:
	if button == null:
		return
	if index >= options.size():
		button.text = "No Mutation"
		if icon != null:
			icon.visible = false
		if rich_text != null:
			rich_text.text = "[center]No Mutation[/center]"
		return

	if not (options[index] is Dictionary):
		button.text = "No Mutation"
		if icon != null:
			icon.visible = false
		if rich_text != null:
			rich_text.text = "[center]No Mutation[/center]"
		return

	var option: Dictionary = options[index]
	_set_choice_icon(icon, option)
	var plain_text: String = _format_mutation_option_text(option)
	button.text = plain_text
	if rich_text != null:
		button.text = ""
		rich_text.text = _format_mutation_option_bbcode(option)

func _set_choice_icon(icon: TextureRect, option: Dictionary) -> void:
	if icon == null:
		return

	var mutation_id: String = String(option.get("id", ""))
	if mutation_id.is_empty() or not MUTATION_ICON_BY_ID.has(mutation_id):
		icon.texture = null
		icon.visible = false
		return

	var icon_texture_variant: Variant = MUTATION_ICON_BY_ID.get(mutation_id, null)
	var icon_texture: Texture2D = icon_texture_variant as Texture2D
	icon.texture = icon_texture
	icon.visible = icon_texture != null

func _format_mutation_option_text(option: Dictionary) -> String:
	var mutation_name: String = String(option.get("name", "Mutation"))
	var next_level: int = int(option.get("next_level", 1))
	var summary_text: String = String(option.get("short", ""))
	var favored: bool = bool(option.get("is_favored", false))
	if favored:
		mutation_name = "* " + mutation_name
	if summary_text.is_empty():
		summary_text = String(option.get("description", ""))

	if summary_text.is_empty():
		return "%s L%d" % [mutation_name, next_level]
	return "%s L%d\n%s" % [mutation_name, next_level, summary_text]

func _format_mutation_option_bbcode(option: Dictionary) -> String:
	var mutation_name: String = String(option.get("name", "Mutation"))
	var next_level: int = int(option.get("next_level", 1))
	var summary_text: String = String(option.get("short", ""))
	var favored: bool = bool(option.get("is_favored", false))
	var title_text: String = "%s L%d" % [mutation_name, next_level]
	if favored:
		title_text = "* " + title_text
	if summary_text.is_empty():
		summary_text = String(option.get("description", ""))

	if summary_text.is_empty():
		if favored:
			return "[center][b][color=#ffd966]%s[/color][/b][/center]" % [title_text]
		return "[center][b]%s[/b][/center]" % [title_text]

	if favored:
		return "[center][b][color=#ffd966]%s[/color][/b]\n%s[/center]" % [title_text, summary_text]
	return "[center][b]%s[/b]\n%s[/center]" % [title_text, summary_text]

func _should_prompt_lineage_now() -> bool:
	if level_reached < 2:
		return false
	if mutation_system == null:
		return false
	if not mutation_system.has_method("get_current_lineage_id"):
		return false

	var lineage_id_variant: Variant = mutation_system.call("get_current_lineage_id")
	var current_lineage_id: String = String(lineage_id_variant)
	return current_lineage_id.is_empty()

func _set_lineage_choice_button_texts() -> void:
	_set_levelup_mode(true)
	if levelup_lineage_prompt_label != null:
		levelup_lineage_prompt_label.text = "Choose your lineage"
	_set_lineage_choice_text(
		lineage_choice_1,
		lineage_choice_1_text,
		"Predator",
		"Aggressive close-range pressure",
		"Starter: Pulse Nova L1"
	)
	_set_lineage_choice_text(
		lineage_choice_2,
		lineage_choice_2_text,
		"Swarm",
		"Orbit and area control growth",
		"Starter: Orbiters L1"
	)
	_set_lineage_choice_text(
		lineage_choice_3,
		lineage_choice_3_text,
		"Bulwark",
		"Defensive sustain and spacing",
		"Starter: Membrane L1"
	)

func _set_lineage_choice_text(
	button: Button,
	rich_text: RichTextLabel,
	title_text: String,
	description_text: String,
	starter_text: String
) -> void:
	if button == null:
		return
	if rich_text == null:
		button.text = "%s\n%s\n%s" % [title_text, description_text, starter_text]
		return
	button.text = ""
	rich_text.text = _format_lineage_choice_bbcode(title_text, description_text, starter_text)

func _format_lineage_choice_bbcode(title_text: String, description_text: String, starter_text: String) -> String:
	return "[center][b]%s[/b]\n%s\n[color=#9ec4d6]%s[/color][/center]" % [
		title_text,
		description_text,
		starter_text
	]

func _apply_lineage_choice(choice_index: int) -> bool:
	if mutation_system == null:
		return false
	if not mutation_system.has_method("choose_lineage"):
		return false
	if choice_index < 0 or choice_index >= LINEAGE_CHOICES.size():
		return false

	var lineage_id: String = LINEAGE_CHOICES[choice_index]
	var applied: bool = bool(mutation_system.call("choose_lineage", lineage_id))
	if not applied:
		return false
	lineage_selection_active = false
	return true

func _set_levelup_mode(lineage_mode: bool) -> void:
	if levelup_choices_row != null:
		levelup_choices_row.visible = not lineage_mode
	if lineage_choices_column != null:
		lineage_choices_column.visible = lineage_mode
	if lineage_bottom_padding != null:
		lineage_bottom_padding.visible = lineage_mode

func _get_current_lineage_name() -> String:
	if mutation_system != null and mutation_system.has_method("get_current_lineage_name"):
		var lineage_name_variant: Variant = mutation_system.call("get_current_lineage_name")
		return String(lineage_name_variant)
	return "None"

func _debug_grant_xp() -> void:
	if not _can_use_debug_xp_cheat():
		return
	if xp_system == null:
		return
	if not xp_system.has_method("add_xp"):
		return

	xp_system.call("add_xp", debug_grant_xp_amount)
	print("Debug XP granted: +", debug_grant_xp_amount)

func _can_use_debug_xp_cheat() -> bool:
	if not debug_allow_grant_xp:
		return false
	if OS.has_feature("editor"):
		return true
	return OS.has_feature("dev_cheats")

func _play_sfx(event_id: String) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id)

func _setup_audio_controls() -> void:
	if audio_panel != null:
		audio_panel.visible = false
	if pause_options_panel != null:
		pause_options_panel.visible = false

	if audio_button != null:
		var audio_button_callable := Callable(self, "_on_audio_button_pressed")
		if not audio_button.pressed.is_connected(audio_button_callable):
			audio_button.pressed.connect(audio_button_callable)

	if sfx_slider != null:
		var sfx_slider_callable := Callable(self, "_on_sfx_slider_value_changed")
		if not sfx_slider.value_changed.is_connected(sfx_slider_callable):
			sfx_slider.value_changed.connect(sfx_slider_callable)
	if pause_sfx_slider != null:
		var pause_sfx_slider_callable := Callable(self, "_on_sfx_slider_value_changed")
		if not pause_sfx_slider.value_changed.is_connected(pause_sfx_slider_callable):
			pause_sfx_slider.value_changed.connect(pause_sfx_slider_callable)

	if sfx_mute_toggle != null:
		var sfx_mute_callable := Callable(self, "_on_sfx_mute_toggled")
		if not sfx_mute_toggle.toggled.is_connected(sfx_mute_callable):
			sfx_mute_toggle.toggled.connect(sfx_mute_callable)
	if pause_sfx_mute_toggle != null:
		var pause_sfx_mute_callable := Callable(self, "_on_sfx_mute_toggled")
		if not pause_sfx_mute_toggle.toggled.is_connected(pause_sfx_mute_callable):
			pause_sfx_mute_toggle.toggled.connect(pause_sfx_mute_callable)

	if music_slider != null:
		var music_slider_callable := Callable(self, "_on_music_slider_value_changed")
		if not music_slider.value_changed.is_connected(music_slider_callable):
			music_slider.value_changed.connect(music_slider_callable)
	if pause_music_slider != null:
		var pause_music_slider_callable := Callable(self, "_on_music_slider_value_changed")
		if not pause_music_slider.value_changed.is_connected(pause_music_slider_callable):
			pause_music_slider.value_changed.connect(pause_music_slider_callable)

	if music_mute_toggle != null:
		var music_mute_callable := Callable(self, "_on_music_mute_toggled")
		if not music_mute_toggle.toggled.is_connected(music_mute_callable):
			music_mute_toggle.toggled.connect(music_mute_callable)
	if pause_music_mute_toggle != null:
		var pause_music_mute_callable := Callable(self, "_on_music_mute_toggled")
		if not pause_music_mute_toggle.toggled.is_connected(pause_music_mute_callable):
			pause_music_mute_toggle.toggled.connect(pause_music_mute_callable)

	_refresh_audio_controls_from_manager()

func _refresh_audio_controls_from_manager() -> void:
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

	_syncing_audio_controls = true
	_set_sfx_slider_values(sfx_value)
	_set_music_slider_values(music_value)
	_set_sfx_mute_values(sfx_muted)
	_set_music_mute_values(music_muted)
	_syncing_audio_controls = false

func _set_sfx_slider_values(value: float) -> void:
	if sfx_slider != null:
		sfx_slider.value = value
	if pause_sfx_slider != null:
		pause_sfx_slider.value = value

func _set_music_slider_values(value: float) -> void:
	if music_slider != null:
		music_slider.value = value
	if pause_music_slider != null:
		pause_music_slider.value = value

func _set_sfx_mute_values(value: bool) -> void:
	if sfx_mute_toggle != null:
		sfx_mute_toggle.button_pressed = value
	if pause_sfx_mute_toggle != null:
		pause_sfx_mute_toggle.button_pressed = value

func _set_music_mute_values(value: bool) -> void:
	if music_mute_toggle != null:
		music_mute_toggle.button_pressed = value
	if pause_music_mute_toggle != null:
		pause_music_mute_toggle.button_pressed = value

func _on_audio_button_pressed() -> void:
	if audio_panel != null:
		audio_panel.visible = not audio_panel.visible
	_play_sfx("ui_click")

func _on_sfx_slider_value_changed(value: float) -> void:
	if _syncing_audio_controls:
		return
	if audio_manager == null:
		return
	if not audio_manager.has_method("set_sfx_volume_linear"):
		return
	audio_manager.call("set_sfx_volume_linear", value)
	_syncing_audio_controls = true
	_set_sfx_slider_values(value)
	_syncing_audio_controls = false

func _on_music_slider_value_changed(value: float) -> void:
	if _syncing_audio_controls:
		return
	if audio_manager == null:
		return
	if not audio_manager.has_method("set_music_volume_linear"):
		return
	audio_manager.call("set_music_volume_linear", value)
	_syncing_audio_controls = true
	_set_music_slider_values(value)
	_syncing_audio_controls = false

func _on_sfx_mute_toggled(pressed: bool) -> void:
	if _syncing_audio_controls:
		return
	if audio_manager == null:
		return
	if not audio_manager.has_method("set_sfx_muted"):
		return
	audio_manager.call("set_sfx_muted", pressed)
	_syncing_audio_controls = true
	_set_sfx_mute_values(pressed)
	_syncing_audio_controls = false

func _on_music_mute_toggled(pressed: bool) -> void:
	if _syncing_audio_controls:
		return
	if audio_manager == null:
		return
	if not audio_manager.has_method("set_music_muted"):
		return
	audio_manager.call("set_music_muted", pressed)
	_syncing_audio_controls = true
	_set_music_mute_values(pressed)
	_syncing_audio_controls = false

func _play_music(track_id: String = "bgm_main") -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_music"):
		return
	audio_manager.call("play_music", track_id)

func _stop_music() -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("stop_music"):
		return
	audio_manager.call("stop_music")

func _open_levelup_prompt(play_sound: bool = true) -> bool:
	if _should_prompt_lineage_now():
		lineage_selection_active = true
		_set_lineage_choice_button_texts()
	else:
		lineage_selection_active = false
		levelup_options = _refresh_levelup_choice_text()
		if levelup_options.is_empty():
			return false

	run_paused_for_levelup = true
	if play_sound:
		_play_sfx("levelup")
	_set_gameplay_active(false)
	if levelup_ui != null:
		levelup_ui.visible = true
	return true

func _close_levelup_prompt() -> void:
	if levelup_ui != null:
		levelup_ui.visible = false
	run_paused_for_levelup = false
	_set_gameplay_active(true)

func _reload_current_scene_deferred() -> void:
	get_tree().reload_current_scene()
