extends Node2D

@onready var player: Node = $Player
@onready var hp_label: Label = $UiHud/HPLabel

func _ready() -> void:
	if player != null and player.has_signal("hp_changed"):
		player.connect("hp_changed", Callable(self, "_on_player_hp_changed"))

	if player != null:
		var current_hp_value = player.get("current_hp")
		var max_hp_value = player.get("max_hp")
		if current_hp_value != null and max_hp_value != null:
			_on_player_hp_changed(current_hp_value, max_hp_value)

func _on_player_hp_changed(current_hp: int, max_hp: int) -> void:
	if hp_label == null:
		return
	hp_label.text = "HP: %d/%d" % [current_hp, max_hp]
