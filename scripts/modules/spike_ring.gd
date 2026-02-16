extends Node2D

@export var spike_damage: int = 8
@export var spike_distance: float = 26.0
@export var spike_collision_radius: float = 5.0
@export var spike_color: Color = Color(0.95, 0.95, 0.95, 1.0)
@export var damage_interval_seconds: float = 0.2
@export var debug_log_hits: bool = false

var spike_level: int = 0
var _damage_tick_accumulator: float = 0.0

func _ready() -> void:
	add_to_group("player_modules")
	set_level(0)

func _process(delta: float) -> void:
	if spike_level <= 0:
		return

	_damage_tick_accumulator += delta
	if _damage_tick_accumulator < damage_interval_seconds:
		return
	_damage_tick_accumulator = 0.0
	_deal_contact_damage_tick()

func set_level(new_level: int) -> void:
	spike_level = clamp(new_level, 0, 3)
	_rebuild_spike_areas()
	queue_redraw()

func _rebuild_spike_areas() -> void:
	for child in get_children():
		child.queue_free()

	var spike_count := _get_spike_count_for_level(spike_level)
	for i in range(spike_count):
		var angle := (TAU * float(i)) / float(spike_count)
		var direction := Vector2.RIGHT.rotated(angle)
		var spike_area := Area2D.new()
		spike_area.position = direction * spike_distance
		spike_area.monitoring = true
		spike_area.monitorable = true

		var collision_shape := CollisionShape2D.new()
		var circle_shape := CircleShape2D.new()
		circle_shape.radius = spike_collision_radius
		collision_shape.shape = circle_shape

		spike_area.add_child(collision_shape)
		add_child(spike_area)

func _deal_contact_damage_tick() -> void:
	for child in get_children():
		var spike_area := child as Area2D
		if spike_area == null:
			continue

		for body in spike_area.get_overlapping_bodies():
			var target := body as Node
			if target == null:
				continue
			if not target.is_in_group("enemies"):
				continue
			if not target.has_method("take_damage"):
				continue

			target.call("take_damage", spike_damage)
			if debug_log_hits:
				print("Spike hit enemy for ", spike_damage)

func _get_spike_count_for_level(level: int) -> int:
	match level:
		1:
			return 4
		2:
			return 6
		3:
			return 8
		_:
			return 0

func _draw() -> void:
	var spike_count := _get_spike_count_for_level(spike_level)
	if spike_count <= 0:
		return

	for i in range(spike_count):
		var angle := (TAU * float(i)) / float(spike_count)
		var direction := Vector2.RIGHT.rotated(angle)
		var tip := direction * (spike_distance + 8.0)
		var base_center := direction * (spike_distance - 4.0)
		var normal := Vector2(-direction.y, direction.x)
		var left := base_center + normal * 4.0
		var right := base_center - normal * 4.0
		draw_colored_polygon(PackedVector2Array([tip, left, right]), spike_color)
