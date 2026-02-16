extends Node2D

@export var orbiter_damage: int = 6
@export var base_orbit_radius: float = 24.0
@export var base_orbit_speed_rps: float = 2.5
@export var orbiter_collision_radius: float = 9.0
@export var orbiter_color: Color = Color(0.85, 0.95, 1.0, 1.0)
@export var damage_interval_seconds: float = 0.2
@export var debug_log_hits: bool = true

var orbiter_level: int = 0
var _elapsed_seconds: float = 0.0
var _current_orbit_radius: float = 24.0
var _current_orbit_speed_rps: float = 2.5
var _target_last_hit_time: Dictionary = {}

func _ready() -> void:
	add_to_group("player_modules")
	set_level(0)

func _physics_process(delta: float) -> void:
	if orbiter_level <= 0:
		return

	_elapsed_seconds += delta
	_update_orbiter_positions()
	_deal_contact_damage_tick()
	queue_redraw()

func set_level(new_level: int) -> void:
	orbiter_level = clampi(new_level, 0, 3)
	_configure_level_stats()
	_rebuild_orbiter_areas()
	_update_orbiter_positions()
	queue_redraw()

func _configure_level_stats() -> void:
	_current_orbit_radius = base_orbit_radius
	_current_orbit_speed_rps = base_orbit_speed_rps

	if orbiter_level >= 3:
		_current_orbit_speed_rps = base_orbit_speed_rps * 1.5

func _rebuild_orbiter_areas() -> void:
	for child in get_children():
		child.queue_free()
	_target_last_hit_time.clear()

	var orbiter_count: int = _get_orbiter_count_for_level(orbiter_level)
	for _i in range(orbiter_count):
		var orbiter_area := Area2D.new()
		orbiter_area.monitoring = true
		orbiter_area.monitorable = true
		orbiter_area.collision_layer = 0
		orbiter_area.collision_mask = 1

		var collision_shape := CollisionShape2D.new()
		var circle_shape := CircleShape2D.new()
		circle_shape.radius = orbiter_collision_radius
		collision_shape.shape = circle_shape

		orbiter_area.add_child(collision_shape)
		add_child(orbiter_area)

func _update_orbiter_positions() -> void:
	var orbiter_count: int = _get_orbiter_count_for_level(orbiter_level)
	if orbiter_count <= 0:
		return

	for i in range(get_child_count()):
		var orbiter_area := get_child(i) as Area2D
		if orbiter_area == null:
			continue

		var normalized_index := float(i) / float(orbiter_count)
		var angle := (TAU * normalized_index) + (_elapsed_seconds * TAU * _current_orbit_speed_rps)
		orbiter_area.position = Vector2.RIGHT.rotated(angle) * _current_orbit_radius

func _deal_contact_damage_tick() -> void:
	for child in get_children():
		var orbiter_area := child as Area2D
		if orbiter_area == null:
			continue

		for body in orbiter_area.get_overlapping_bodies():
			var target := body as Node
			if target == null:
				continue
			if not target.is_in_group("enemies"):
				continue
			if not target.has_method("take_damage"):
				continue
			if not _can_hit_target_now(target):
				continue

			target.call("take_damage", orbiter_damage)
			if debug_log_hits:
				print("Orbiter hit enemy for ", orbiter_damage)

func _can_hit_target_now(target: Node) -> bool:
	var target_id: int = target.get_instance_id()
	var now_time: float = _elapsed_seconds

	if not _target_last_hit_time.has(target_id):
		_target_last_hit_time[target_id] = now_time
		return true

	var last_hit_time: float = float(_target_last_hit_time[target_id])
	if (now_time - last_hit_time) < damage_interval_seconds:
		return false

	_target_last_hit_time[target_id] = now_time
	return true

func _get_orbiter_count_for_level(level: int) -> int:
	match level:
		1:
			return 1
		2, 3:
			return 2
		_:
			return 0

func _draw() -> void:
	for child in get_children():
		var orbiter_area := child as Area2D
		if orbiter_area == null:
			continue
		draw_circle(orbiter_area.position, orbiter_collision_radius, orbiter_color)
