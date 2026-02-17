extends Node2D

const SPIKE_SPRITE_TEXTURE: Texture2D = preload("res://art/sprites/mutations/mutation_spike.png")

@export var spike_damage: int = 8
@export var spike_distance: float = 36.0
@export var spike_collision_radius: float = 8.0
@export var spike_color: Color = Color(0.95, 0.95, 0.95, 1.0)
@export var spike_outline_color: Color = Color(0.1, 0.1, 0.1, 0.9)
@export var spike_sprite_texture: Texture2D = SPIKE_SPRITE_TEXTURE
@export var spike_sprite_world_size_multiplier: float = 5.2
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
	spike_level = clampi(new_level, 0, 3)
	_rebuild_spike_areas()
	_refresh_spike_visuals()
	queue_redraw()

func set_lineage_color(color: Color) -> void:
	spike_color = color
	spike_outline_color = color.darkened(0.8)
	_refresh_spike_visuals()
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

		var visual_sprite := Sprite2D.new()
		visual_sprite.name = "VisualSprite"
		visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		visual_sprite.texture = spike_sprite_texture
		visual_sprite.scale = _compute_spike_sprite_scale()
		visual_sprite.modulate = spike_color
		visual_sprite.rotation = angle - (PI * 0.5)
		spike_area.add_child(visual_sprite)

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
	pass

func _refresh_spike_visuals() -> void:
	for child in get_children():
		var spike_area := child as Area2D
		if spike_area == null:
			continue
		var visual_sprite := spike_area.get_node_or_null("VisualSprite") as Sprite2D
		if visual_sprite == null:
			continue
		visual_sprite.texture = spike_sprite_texture
		visual_sprite.scale = _compute_spike_sprite_scale()
		visual_sprite.modulate = spike_color

func _compute_spike_sprite_scale() -> Vector2:
	if spike_sprite_texture == null:
		return Vector2.ONE
	var texture_width: float = maxf(1.0, spike_sprite_texture.get_size().x)
	var desired_diameter: float = spike_collision_radius * 2.0 * spike_sprite_world_size_multiplier
	var uniform_scale: float = desired_diameter / texture_width
	return Vector2(uniform_scale, uniform_scale)
