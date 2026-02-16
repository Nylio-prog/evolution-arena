extends Node2D

const BIOMASS_PICKUP_SCENE: PackedScene = preload("res://scenes/systems/biomass_pickup.tscn")

@onready var player: Node = get_node_or_null("Player")
@onready var xp_system: Node = get_node_or_null("XpSystem")
@onready var mutation_system: Node = get_node_or_null("MutationSystem")
@onready var hp_label: Label = get_node_or_null("UiHud/HPLabel")
@onready var xp_bar: ProgressBar = get_node_or_null("UiHud/XPBar")
@onready var level_label: Label = get_node_or_null("UiHud/LevelLabel")
@onready var timer_label: Label = get_node_or_null("UiHud/TimerLabel")
@onready var lineage_label: Label = get_node_or_null("UiHud/LineageLabel")
@onready var levelup_ui: CanvasLayer = get_node_or_null("UiLevelup")
@onready var levelup_lineage_prompt_label: Label = get_node_or_null("UiLevelup/Root/Layout/LineagePromptLabel")
@onready var levelup_choice_1: Button = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton1")
@onready var levelup_choice_2: Button = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton2")
@onready var levelup_choice_3: Button = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton3")
@onready var game_over_ui: CanvasLayer = get_node_or_null("GameOver")
@onready var game_over_stats_label: Label = get_node_or_null("GameOver/Root/StatsLabel")
@onready var game_over_restart_button: Button = get_node_or_null("GameOver/Root/RestartButton")

var elapsed_seconds: float = 0.0
var level_reached: int = 1
var run_ended: bool = false
var run_paused_for_levelup: bool = false
var debug_log_drops: bool = false
var levelup_options: Array = []

func _ready() -> void:
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

	for node in get_tree().get_nodes_in_group("biomass_pickups"):
		_connect_biomass_pickup(node as Node)
	for node in get_tree().get_nodes_in_group("enemies"):
		_connect_enemy_death(node as Node)
	get_tree().connect("node_added", Callable(self, "_on_tree_node_added"))

	if game_over_ui != null:
		game_over_ui.visible = false

	if game_over_restart_button != null:
		game_over_restart_button.connect("pressed", Callable(self, "_on_restart_pressed"))

	if levelup_ui != null:
		levelup_ui.visible = false

	if levelup_choice_1 != null:
		levelup_choice_1.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(0))
	if levelup_choice_2 != null:
		levelup_choice_2.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(1))
	if levelup_choice_3 != null:
		levelup_choice_3.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(2))

func _process(delta: float) -> void:
	if run_ended:
		return
	if run_paused_for_levelup:
		return
	elapsed_seconds += delta
	_update_timer_label()

func _unhandled_input(event: InputEvent) -> void:
	if not run_paused_for_levelup:
		return
	if run_ended:
		return

	var key_event := event as InputEventKey
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
	if hp_label == null:
		return
	hp_label.text = "HP: %d/%d" % [current_hp, max_hp]

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

func _refresh_lineage_labels() -> void:
	var current_lineage_name: String = "None"
	if mutation_system != null and mutation_system.has_method("get_current_lineage_name"):
		var lineage_name_variant: Variant = mutation_system.call("get_current_lineage_name")
		current_lineage_name = String(lineage_name_variant)

	if lineage_label != null:
		lineage_label.text = "Lineage: %s" % current_lineage_name

	if levelup_lineage_prompt_label != null:
		if current_lineage_name == "None":
			levelup_lineage_prompt_label.text = "Choose your lineage"
		else:
			levelup_lineage_prompt_label.text = "Lineage: %s" % current_lineage_name

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

func _on_enemy_died(world_position: Vector2) -> void:
	if debug_log_drops:
		print("Enemy died at ", world_position, " -> spawning biomass")
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
	run_ended = true
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
		game_over_stats_label.text = "Time: %ds | Level: %d" % [int(elapsed_seconds), level_reached]

	if game_over_ui != null:
		game_over_ui.visible = true

func _update_timer_label() -> void:
	if timer_label == null:
		return
	timer_label.text = "Time: %ds" % int(elapsed_seconds)

func _on_player_leveled_up(_new_level: int) -> void:
	if run_ended:
		return
	levelup_options = _refresh_levelup_choice_text()
	if levelup_options.is_empty():
		return

	run_paused_for_levelup = true
	_set_gameplay_active(false)
	if levelup_ui != null:
		levelup_ui.visible = true

func _on_levelup_choice_pressed(choice_index: int) -> void:
	if run_ended:
		return

	if mutation_system != null and mutation_system.has_method("apply_option_index"):
		mutation_system.call("apply_option_index", choice_index)

	if levelup_ui != null:
		levelup_ui.visible = false
	run_paused_for_levelup = false
	_set_gameplay_active(true)

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _refresh_levelup_choice_text() -> Array:
	var options: Array = []
	if mutation_system != null and mutation_system.has_method("get_levelup_options"):
		var options_variant: Variant = mutation_system.call("get_levelup_options", 3)
		if options_variant is Array:
			options = options_variant

	_set_choice_button_text(levelup_choice_1, options, 0)
	_set_choice_button_text(levelup_choice_2, options, 1)
	_set_choice_button_text(levelup_choice_3, options, 2)
	return options

func _set_choice_button_text(button: Button, options: Array, index: int) -> void:
	if button == null:
		return
	if index >= options.size():
		button.text = "No Mutation"
		return

	if not (options[index] is Dictionary):
		button.text = "No Mutation"
		return

	var option: Dictionary = options[index]
	button.text = _format_mutation_option_text(option)

func _format_mutation_option_text(option: Dictionary) -> String:
	var mutation_name: String = String(option.get("name", "Mutation"))
	var next_level: int = int(option.get("next_level", 1))
	var short_text: String = String(option.get("short", ""))
	if short_text.is_empty():
		return "%s L%d" % [mutation_name, next_level]
	return "%s L%d - %s" % [mutation_name, next_level, short_text]
