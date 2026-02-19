extends Node2D

@export var base_pulse_damage: int = 6
@export var base_pulse_radius: float = 92.0
@export var base_pulse_interval_seconds: float = 1.35
@export var pulse_visual_duration_seconds: float = 0.26
@export var pulse_color: Color = Color(0.78, 0.94, 1.0, 0.92)
@export var pulse_visual_animation_name: StringName = &"pulse"
@export var pulse_visual_scale_multiplier: float = 1.0
@export var auto_scale_visual_to_radius: bool = false
@export var use_preview_collision_radius_as_base: bool = true
@export var sync_preview_collision_to_pulse_radius: bool = false
@export var enforce_level1_base_radius_match: bool = true
@export var preview_collision_visible_in_game: bool = false
@export var debug_show_radius_ring: bool = true
@export var debug_log_hits: bool = false

@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")
@onready var pulse_visual_sprite: AnimatedSprite2D = get_node_or_null("PulseAnimatedSprite")
@onready var range_collision_shape: CollisionShape2D = get_node_or_null("RangePreviewArea/CollisionShape2D")

var pulse_level: int = 0
var _runtime_damage_multiplier: float = 1.0
var _runtime_radius_multiplier: float = 1.0
var _runtime_cooldown_multiplier: float = 1.0
var _time_until_next_pulse: float = 0.0
var _pulse_visual_time_left: float = 0.0
var _pulse_visual_radius: float = 0.0
var _pulse_visual_base_scale: Vector2 = Vector2.ONE
var _authored_preview_base_radius: float = -1.0

func _ready() -> void:
	add_to_group("player_modules")
	_setup_preview_collision()
	_setup_pulse_visual_sprite()
	set_level(0)

func _physics_process(delta: float) -> void:
	if pulse_level <= 0:
		return
	_time_until_next_pulse = maxf(0.0, _time_until_next_pulse - delta)
	if _time_until_next_pulse <= 0.0:
		_emit_pulse()
		_time_until_next_pulse = _get_effective_interval_seconds()

	if _pulse_visual_time_left > 0.0:
		_pulse_visual_time_left = maxf(0.0, _pulse_visual_time_left - delta)
		_update_pulse_visual()
	if _should_draw_debug_radius_ring():
		queue_redraw()

func set_level(new_level: int) -> void:
	var previous_level: int = pulse_level
	pulse_level = clampi(new_level, 0, 5)
	_time_until_next_pulse = minf(_time_until_next_pulse, _get_effective_interval_seconds())
	if pulse_level > 0 and previous_level <= 0:
		_time_until_next_pulse = minf(0.15, _get_effective_interval_seconds())
	_sync_preview_collision_radius()
	_update_pulse_visual()
	queue_redraw()

func set_runtime_modifiers(damage_multiplier: float, radius_multiplier: float, cooldown_multiplier: float) -> void:
	_runtime_damage_multiplier = maxf(0.1, damage_multiplier)
	_runtime_radius_multiplier = maxf(0.1, radius_multiplier)
	_runtime_cooldown_multiplier = maxf(0.1, cooldown_multiplier)
	_sync_preview_collision_radius()
	_update_pulse_visual_transform()

func _get_effective_interval_seconds() -> float:
	var base_interval: float = base_pulse_interval_seconds
	match pulse_level:
		2:
			base_interval *= 0.82
		3:
			base_interval *= 0.74
		4:
			base_interval *= 0.67
		5:
			base_interval *= 0.60
	return maxf(0.18, base_interval * _runtime_cooldown_multiplier)

func _get_effective_pulse_damage() -> int:
	var damage_value: float = float(base_pulse_damage)
	match pulse_level:
		2:
			damage_value *= 1.35
		3:
			damage_value *= 1.65
		4:
			damage_value *= 2.00
		5:
			damage_value *= 2.35
	damage_value *= _runtime_damage_multiplier
	return maxi(1, int(round(damage_value)))

func _get_effective_pulse_radius() -> float:
	var radius_value: float = _get_configured_base_radius()
	if enforce_level1_base_radius_match and pulse_level <= 1:
		return maxf(8.0, radius_value)
	match pulse_level:
		2:
			radius_value += 12.0
		3:
			radius_value += 24.0
		4:
			radius_value += 38.0
		5:
			radius_value += 54.0
	radius_value *= _runtime_radius_multiplier
	return maxf(8.0, radius_value)

func _get_configured_base_radius() -> float:
	if not use_preview_collision_radius_as_base:
		return base_pulse_radius
	if _authored_preview_base_radius > 0.0:
		return maxf(8.0, _authored_preview_base_radius)
	if range_collision_shape == null:
		return base_pulse_radius
	var circle_shape := range_collision_shape.shape as CircleShape2D
	if circle_shape == null:
		return base_pulse_radius
	return maxf(8.0, circle_shape.radius)

func _emit_pulse() -> void:
	var owner_player := get_parent() as Node2D
	if owner_player == null:
		return

	var pulse_radius: float = _get_runtime_query_radius(_get_effective_pulse_radius())
	var pulse_damage: int = _get_effective_pulse_damage()
	var hits: int = 0
	var query_targets: Array[Node2D] = _collect_query_targets(owner_player)
	for enemy_node in query_targets:
		if enemy_node == null:
			continue
		if not enemy_node.has_method("take_damage"):
			continue
		enemy_node.call("take_damage", pulse_damage)
		hits += 1

	_pulse_visual_time_left = pulse_visual_duration_seconds
	_pulse_visual_radius = pulse_radius
	_play_pulse_visual()
	_update_pulse_visual()
	queue_redraw()
	_play_sfx("sfx_proto_pulse", -5.0, randf_range(0.95, 1.05))
	if debug_log_hits:
		print(
			"Proto Pulse hit ",
			hits,
			" target(s) for ",
			pulse_damage,
			" | radius=",
			pulse_radius,
			" | base_radius=",
			_get_configured_base_radius(),
			" | level=",
			pulse_level,
			" | runtime_mult=",
			_runtime_radius_multiplier
		)

func _play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id, volume_db_offset, pitch_scale)

func _draw() -> void:
	if _should_draw_debug_radius_ring():
		var debug_radius: float = _get_runtime_query_radius(_get_effective_pulse_radius())
		draw_arc(Vector2.ZERO, debug_radius, 0.0, TAU, 72, Color(0.65, 0.95, 1.0, 0.5), 1.8, true)

func _should_draw_debug_radius_ring() -> bool:
	if not debug_show_radius_ring:
		return false
	if pulse_level <= 0:
		return false
	var tree: SceneTree = get_tree()
	if tree == null:
		return false
	return tree.debug_collisions_hint

func _setup_preview_collision() -> void:
	if range_collision_shape == null:
		return
	var circle_shape := range_collision_shape.shape as CircleShape2D
	if circle_shape == null:
		circle_shape = CircleShape2D.new()
		range_collision_shape.shape = circle_shape
	_authored_preview_base_radius = maxf(8.0, circle_shape.radius)
	range_collision_shape.visible = preview_collision_visible_in_game
	_sync_preview_collision_radius()

func _setup_pulse_visual_sprite() -> void:
	if pulse_visual_sprite == null:
		push_warning("ProtoPulse expects an AnimatedSprite2D child named PulseAnimatedSprite.")
		return
	pulse_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_pulse_visual_base_scale = pulse_visual_sprite.scale
	pulse_visual_sprite.visible = false
	var add_material := CanvasItemMaterial.new()
	add_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	pulse_visual_sprite.material = add_material
	if pulse_visual_sprite.sprite_frames == null:
		push_warning("ProtoPulse has no SpriteFrames on PulseAnimatedSprite. Add your animation in editor.")

func _sync_preview_collision_radius() -> void:
	if not sync_preview_collision_to_pulse_radius:
		return
	if range_collision_shape == null:
		return
	var circle_shape := range_collision_shape.shape as CircleShape2D
	if circle_shape == null:
		circle_shape = CircleShape2D.new()
		range_collision_shape.shape = circle_shape
	circle_shape.radius = _get_effective_pulse_radius()

func _play_pulse_visual() -> void:
	if pulse_visual_sprite == null or not is_instance_valid(pulse_visual_sprite):
		return
	if pulse_level <= 0:
		pulse_visual_sprite.visible = false
		return
	var sprite_frames: SpriteFrames = pulse_visual_sprite.sprite_frames
	if sprite_frames == null:
		pulse_visual_sprite.visible = false
		return
	var animation_name: StringName = pulse_visual_animation_name
	if animation_name.is_empty() or not sprite_frames.has_animation(animation_name):
		var animation_names: PackedStringArray = sprite_frames.get_animation_names()
		if animation_names.is_empty():
			pulse_visual_sprite.visible = false
			return
		animation_name = StringName(animation_names[0])

	_update_pulse_visual_transform()
	pulse_visual_sprite.visible = true
	pulse_visual_sprite.frame = 0
	pulse_visual_sprite.play(animation_name)

func _update_pulse_visual() -> void:
	if pulse_visual_sprite == null or not is_instance_valid(pulse_visual_sprite):
		return
	if pulse_level <= 0 or _pulse_visual_time_left <= 0.0:
		pulse_visual_sprite.visible = false
		pulse_visual_sprite.stop()
		return

	_update_pulse_visual_transform()
	pulse_visual_sprite.visible = true
	var fade_ratio: float = clampf(_pulse_visual_time_left / maxf(0.01, pulse_visual_duration_seconds), 0.0, 1.0)
	var color_now: Color = pulse_color
	color_now.a = clampf(0.88 * pow(fade_ratio, 0.65), 0.0, 1.0)
	pulse_visual_sprite.modulate = color_now

func _update_pulse_visual_transform() -> void:
	if pulse_visual_sprite == null or not is_instance_valid(pulse_visual_sprite):
		return
	if not auto_scale_visual_to_radius:
		return
	var frame_size: Vector2 = _get_first_animation_frame_size()
	if frame_size.x <= 1.0 or frame_size.y <= 1.0:
		return
	var desired_diameter: float = maxf(1.0, _pulse_visual_radius * 2.0 * pulse_visual_scale_multiplier)
	var scale_x: float = desired_diameter / maxf(1.0, frame_size.x)
	var scale_y: float = desired_diameter / maxf(1.0, frame_size.y)
	pulse_visual_sprite.scale = Vector2(
		_pulse_visual_base_scale.x * scale_x,
		_pulse_visual_base_scale.y * scale_y
	)

func _get_first_animation_frame_size() -> Vector2:
	if pulse_visual_sprite == null:
		return Vector2.ZERO
	var sprite_frames: SpriteFrames = pulse_visual_sprite.sprite_frames
	if sprite_frames == null:
		return Vector2.ZERO
	var animation_name: StringName = pulse_visual_animation_name
	if animation_name.is_empty() or not sprite_frames.has_animation(animation_name):
		var animation_names: PackedStringArray = sprite_frames.get_animation_names()
		if animation_names.is_empty():
			return Vector2.ZERO
		animation_name = StringName(animation_names[0])
	var frame_count: int = sprite_frames.get_frame_count(animation_name)
	if frame_count <= 0:
		return Vector2.ZERO
	var frame_texture: Texture2D = sprite_frames.get_frame_texture(animation_name, 0)
	if frame_texture == null:
		return Vector2.ZERO
	return frame_texture.get_size()

func _collect_query_targets(owner_player: Node2D) -> Array[Node2D]:
	var targets: Array[Node2D] = []
	if owner_player == null:
		return targets
	var world_2d: World2D = owner_player.get_world_2d()
	if world_2d == null:
		return targets
	var space_state: PhysicsDirectSpaceState2D = world_2d.direct_space_state
	if space_state == null:
		return targets

	var query_shape: Shape2D = null
	var query_transform: Transform2D = Transform2D(0.0, owner_player.global_position)
	if range_collision_shape != null and range_collision_shape.shape != null:
		query_shape = range_collision_shape.shape
		query_transform = range_collision_shape.global_transform
	if query_shape == null:
		var fallback_shape := CircleShape2D.new()
		fallback_shape.radius = _get_effective_pulse_radius()
		query_shape = fallback_shape

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = query_shape
	query.transform = query_transform
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.collision_mask = _get_query_collision_mask()
	query.exclude = [owner_player.get_rid()]

	var hits_variant: Array[Dictionary] = space_state.intersect_shape(query, 256)
	var seen_ids: Dictionary = {}
	for hit_entry in hits_variant:
		var collider_variant: Variant = hit_entry.get("collider", null)
		var collider_node: Node = collider_variant as Node
		if collider_node == null:
			continue
		if not collider_node.is_in_group("enemies"):
			continue
		var target_node: Node2D = collider_node as Node2D
		if target_node == null:
			continue
		var target_id: int = target_node.get_instance_id()
		if seen_ids.has(target_id):
			continue
		seen_ids[target_id] = true
		targets.append(target_node)
	return targets

func _get_query_collision_mask() -> int:
	if range_collision_shape != null:
		var preview_area := range_collision_shape.get_parent() as Area2D
		if preview_area != null:
			var mask_value: int = preview_area.collision_mask
			if mask_value > 0:
				return mask_value
	return 0x7fffffff

func _get_runtime_query_radius(fallback_radius: float) -> float:
	if range_collision_shape == null:
		return fallback_radius
	var circle_shape := range_collision_shape.shape as CircleShape2D
	if circle_shape == null:
		return fallback_radius
	var shape_global_scale: Vector2 = range_collision_shape.global_scale
	var scale_factor: float = maxf(absf(shape_global_scale.x), absf(shape_global_scale.y))
	if scale_factor <= 0.001:
		scale_factor = 1.0
	return maxf(1.0, circle_shape.radius * scale_factor)
