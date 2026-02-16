extends Node2D

@export var base_pulse_damage: int = 10
@export var base_pulse_radius: float = 72.0
@export var base_pulse_interval_seconds: float = 1.6
@export var pulse_visual_duration_seconds: float = 0.22
@export var pulse_color: Color = Color(0.75, 0.95, 1.0, 0.95)
@export var pulse_outline_color: Color = Color(0.12, 0.2, 0.26, 1.0)
@export var debug_log_hits: bool = false

var pulse_level: int = 0
var _pulse_damage: int = 0
var _pulse_radius: float = 0.0
var _pulse_interval_seconds: float = 999.0
var _time_until_next_pulse: float = 0.0
var _pulse_visual_time_left: float = 0.0

func _ready() -> void:
	add_to_group("player_modules")
	set_level(0)

func _physics_process(delta: float) -> void:
	if pulse_level <= 0:
		return

	_time_until_next_pulse = maxf(0.0, _time_until_next_pulse - delta)
	if _time_until_next_pulse <= 0.0:
		_emit_pulse()
		_time_until_next_pulse = _pulse_interval_seconds

	if _pulse_visual_time_left > 0.0:
		_pulse_visual_time_left = maxf(0.0, _pulse_visual_time_left - delta)
		queue_redraw()

func set_level(new_level: int) -> void:
	pulse_level = clampi(new_level, 0, 3)
	_configure_level_stats()
	_time_until_next_pulse = minf(_time_until_next_pulse, _pulse_interval_seconds)
	queue_redraw()

func set_lineage_color(color: Color) -> void:
	pulse_color = color
	pulse_outline_color = color.darkened(0.75)
	queue_redraw()

func _configure_level_stats() -> void:
	match pulse_level:
		1:
			_pulse_damage = base_pulse_damage
			_pulse_radius = base_pulse_radius
			_pulse_interval_seconds = base_pulse_interval_seconds
		2:
			_pulse_damage = int(round(float(base_pulse_damage) * 1.4))
			_pulse_radius = base_pulse_radius + 20.0
			_pulse_interval_seconds = maxf(0.35, base_pulse_interval_seconds * 0.82)
		3:
			_pulse_damage = int(round(float(base_pulse_damage) * 1.8))
			_pulse_radius = base_pulse_radius + 40.0
			_pulse_interval_seconds = maxf(0.30, base_pulse_interval_seconds * 0.68)
		_:
			_pulse_damage = 0
			_pulse_radius = 0.0
			_pulse_interval_seconds = 999.0

func _emit_pulse() -> void:
	if pulse_level <= 0:
		return

	var owner_player := get_parent() as Node2D
	if owner_player == null:
		return

	var hit_count: int = 0
	var pulse_origin: Vector2 = owner_player.global_position
	for enemy_variant in get_tree().get_nodes_in_group("enemies"):
		var enemy_node := enemy_variant as Node2D
		if enemy_node == null:
			continue
		if not enemy_node.has_method("take_damage"):
			continue

		var distance_to_enemy: float = pulse_origin.distance_to(enemy_node.global_position)
		if distance_to_enemy > _pulse_radius:
			continue

		enemy_node.call("take_damage", _pulse_damage)
		hit_count += 1

	if debug_log_hits:
		print("Pulse Nova hit ", hit_count, " enemy(s) for ", _pulse_damage)

	_pulse_visual_time_left = pulse_visual_duration_seconds
	queue_redraw()

func _draw() -> void:
	if pulse_level <= 0:
		return
	if _pulse_visual_time_left <= 0.0:
		return

	var normalized: float = 1.0 - (_pulse_visual_time_left / maxf(0.01, pulse_visual_duration_seconds))
	var radius_now: float = lerpf(8.0, _pulse_radius, normalized)
	var alpha_factor: float = 1.0 - normalized

	var ring_color: Color = pulse_color
	ring_color.a = clampf(0.85 * alpha_factor, 0.0, 1.0)
	var outline_color: Color = pulse_outline_color
	outline_color.a = clampf(0.95 * alpha_factor, 0.0, 1.0)

	draw_arc(Vector2.ZERO, radius_now, 0.0, TAU, 72, ring_color, 3.0, true)
	draw_arc(Vector2.ZERO, radius_now + 3.0, 0.0, TAU, 72, outline_color, 1.5, true)
