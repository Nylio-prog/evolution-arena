extends Node2D

@onready var player: Node = get_node_or_null("Player")
@onready var xp_system: Node = get_node_or_null("XpSystem")
@onready var hp_label: Label = get_node_or_null("UiHud/HPLabel")
@onready var xp_bar: ProgressBar = get_node_or_null("UiHud/XPBar")
@onready var level_label: Label = get_node_or_null("UiHud/LevelLabel")
@onready var levelup_ui: CanvasLayer = get_node_or_null("UiLevelup")
@onready var levelup_choice_1: Button = get_node_or_null("UiLevelup/Root/ChoiceButton1")
@onready var levelup_choice_2: Button = get_node_or_null("UiLevelup/Root/ChoiceButton2")
@onready var levelup_choice_3: Button = get_node_or_null("UiLevelup/Root/ChoiceButton3")
@onready var game_over_ui: CanvasLayer = get_node_or_null("GameOver")
@onready var game_over_stats_label: Label = get_node_or_null("GameOver/Root/StatsLabel")
@onready var game_over_restart_button: Button = get_node_or_null("GameOver/Root/RestartButton")

var elapsed_seconds: float = 0.0
var level_reached: int = 1
var run_ended: bool = false
var run_paused_for_levelup: bool = false

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

	for node in get_tree().get_nodes_in_group("biomass_pickups"):
		_connect_biomass_pickup(node as Node)
	get_tree().connect("node_added", Callable(self, "_on_tree_node_added"))

	if game_over_ui != null:
		game_over_ui.visible = false

	if game_over_restart_button != null:
		game_over_restart_button.connect("pressed", Callable(self, "_on_restart_pressed"))

	if levelup_ui != null:
		levelup_ui.visible = false

	if levelup_choice_1 != null:
		levelup_choice_1.connect("pressed", Callable(self, "_on_levelup_choice_pressed"))
	if levelup_choice_2 != null:
		levelup_choice_2.connect("pressed", Callable(self, "_on_levelup_choice_pressed"))
	if levelup_choice_3 != null:
		levelup_choice_3.connect("pressed", Callable(self, "_on_levelup_choice_pressed"))

func _process(delta: float) -> void:
	if run_ended:
		return
	if run_paused_for_levelup:
		return
	elapsed_seconds += delta

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

func _on_tree_node_added(node: Node) -> void:
	_connect_biomass_pickup(node)

func _connect_biomass_pickup(node: Node) -> void:
	if node == null:
		return
	if not node.is_in_group("biomass_pickups"):
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

func _show_game_over() -> void:
	if game_over_stats_label != null:
		game_over_stats_label.text = "Time: %ds | Level: %d" % [int(elapsed_seconds), level_reached]

	if game_over_ui != null:
		game_over_ui.visible = true

func _on_player_leveled_up(_new_level: int) -> void:
	if run_ended:
		return
	run_paused_for_levelup = true
	_set_gameplay_active(false)
	if levelup_ui != null:
		levelup_ui.visible = true

func _on_levelup_choice_pressed() -> void:
	if run_ended:
		return
	if levelup_ui != null:
		levelup_ui.visible = false
	run_paused_for_levelup = false
	_set_gameplay_active(true)

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
