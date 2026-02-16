extends Node2D

@onready var player: Node = get_node_or_null("Player")
@onready var hp_label: Label = get_node_or_null("UiHud/HPLabel")
@onready var game_over_ui: CanvasLayer = get_node_or_null("GameOver")
@onready var game_over_stats_label: Label = get_node_or_null("GameOver/Root/StatsLabel")
@onready var game_over_restart_button: Button = get_node_or_null("GameOver/Root/RestartButton")

var elapsed_seconds: float = 0.0
var level_reached: int = 1
var run_ended: bool = false

func _ready() -> void:
	if player != null and player.has_signal("hp_changed"):
		player.connect("hp_changed", Callable(self, "_on_player_hp_changed"))
	if player != null and player.has_signal("died"):
		player.connect("died", Callable(self, "_on_player_died"))

	if player != null:
		var current_hp_value = player.get("current_hp")
		var max_hp_value = player.get("max_hp")
		if current_hp_value != null and max_hp_value != null:
			_on_player_hp_changed(current_hp_value, max_hp_value)

	if game_over_ui != null:
		game_over_ui.visible = false

	if game_over_restart_button != null:
		game_over_restart_button.connect("pressed", Callable(self, "_on_restart_pressed"))

func _process(delta: float) -> void:
	if run_ended:
		return
	elapsed_seconds += delta

func _on_player_hp_changed(current_hp: int, max_hp: int) -> void:
	if hp_label == null:
		return
	hp_label.text = "HP: %d/%d" % [current_hp, max_hp]

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

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
