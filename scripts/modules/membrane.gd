extends Node2D

@export var membrane_color: Color = Color(0.75, 0.95, 1.0, 0.8)
@export var base_radius: float = 20.0
@export var radius_per_level: float = 4.0
@export var base_thickness: float = 2.0

var membrane_level: int = 0

func _ready() -> void:
	add_to_group("player_modules")
	set_level(0)

func set_level(new_level: int) -> void:
	membrane_level = clampi(new_level, 0, 3)
	_apply_to_player()
	queue_redraw()

func _apply_to_player() -> void:
	var owner_player := get_parent() as Node
	if owner_player == null:
		return
	if not owner_player.has_method("set_incoming_damage_multiplier"):
		return

	owner_player.call("set_incoming_damage_multiplier", _get_damage_multiplier_for_level(membrane_level))

func _get_damage_multiplier_for_level(level: int) -> float:
	match level:
		1:
			return 0.85
		2:
			return 0.70
		3:
			return 0.55
		_:
			return 1.0

func _draw() -> void:
	if membrane_level <= 0:
		return

	var radius: float = base_radius + (radius_per_level * float(membrane_level))
	var thickness: float = base_thickness + float(membrane_level)
	var fill_color := membrane_color
	fill_color.a = 0.08 * float(membrane_level)

	draw_circle(Vector2.ZERO, radius - (thickness * 0.6), fill_color)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, membrane_color, thickness, true)
