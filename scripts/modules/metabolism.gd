extends Node2D

@export var base_regen_per_second: float = 1.8
@export var regen_tick_cap_per_frame: int = 8
@export var aura_color: Color = Color(0.75, 1.0, 0.78, 0.9)
@export var aura_radius: float = 20.0
@export var aura_width: float = 1.8

var metabolism_level: int = 0
var _regen_per_second: float = 0.0
var _regen_progress: float = 0.0
var _visual_time: float = 0.0

func _ready() -> void:
	add_to_group("player_modules")
	set_level(0)

func _physics_process(delta: float) -> void:
	if metabolism_level <= 0:
		return

	var owner_player: Node = get_parent()
	if owner_player == null:
		return
	if not owner_player.has_method("heal"):
		return

	_regen_progress += _regen_per_second * delta
	if _regen_progress < 1.0:
		return

	var heal_amount: int = int(floor(_regen_progress))
	heal_amount = mini(heal_amount, maxi(1, regen_tick_cap_per_frame))
	_regen_progress -= float(heal_amount)
	owner_player.call("heal", heal_amount)

func _process(delta: float) -> void:
	if metabolism_level <= 0:
		return
	_visual_time += delta
	queue_redraw()

func set_level(new_level: int) -> void:
	metabolism_level = clampi(new_level, 0, 3)
	_configure_regen()
	queue_redraw()

func set_lineage_color(color: Color) -> void:
	aura_color = color
	queue_redraw()

func get_regen_per_second() -> float:
	return _regen_per_second

func _configure_regen() -> void:
	match metabolism_level:
		1:
			_regen_per_second = base_regen_per_second
		2:
			_regen_per_second = base_regen_per_second * 2.0
		3:
			_regen_per_second = base_regen_per_second * 3.2
		_:
			_regen_per_second = 0.0

func _draw() -> void:
	if metabolism_level <= 0:
		return

	var pulse: float = (sin(_visual_time * 4.4) + 1.0) * 0.5
	var outer_radius: float = aura_radius + (pulse * 2.0) + float(metabolism_level)
	var ring_color: Color = aura_color
	ring_color.a = 0.24 + (0.16 * pulse)
	draw_arc(Vector2.ZERO, outer_radius, 0.0, TAU, 48, ring_color, aura_width + (0.4 * float(metabolism_level)), true)
