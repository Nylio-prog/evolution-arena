extends Area2D

signal collected(amount: int)

@export var xp_value: int = 10
@export var debug_log_collect: bool = true

func _ready() -> void:
	add_to_group("biomass_pickups")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body == null:
		return
	if not body.is_in_group("player"):
		return

	if debug_log_collect:
		print("Biomass collected for ", xp_value, " XP")
	collected.emit(xp_value)
	queue_free()
