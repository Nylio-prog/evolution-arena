extends Node2D

const ACID_TRAIL_SPRITE_TEXTURE: Texture2D = preload("res://art/sprites/modules/infective_trail_pool_sheet.png")

class TrailSegment:
	extends RefCounted
	var area: Area2D
	var collision_shape: CollisionShape2D
	var visual: Sprite2D
	var rotation_seed: float = 0.0
	var age_seconds: float = 0.0
	var active: bool = false

@export var base_damage_per_tick: int = 3
@export var base_radius: float = 17.0
@export var base_spawn_interval_seconds: float = 0.36
@export var base_lifetime_seconds: float = 1.8
@export var base_damage_tick_interval_seconds: float = 0.50
@export var min_spawn_distance: float = 13.0
@export var max_segment_pool_size: int = 24
@export var trail_color: Color = Color(0.42, 1.0, 0.86, 0.50)
@export var trail_sprite_texture: Texture2D = ACID_TRAIL_SPRITE_TEXTURE
@export var trail_sheet_columns: int = 3
@export var trail_sheet_rows: int = 3
@export var trail_sprite_scale_multiplier: float = 1.55
@export var tick_sfx_cooldown_seconds: float = 0.16
@export var debug_log_hits: bool = false

@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")

var acid_trail_level: int = 0
var _segments: Array[TrailSegment] = []
var _target_last_hit_seconds: Dictionary = {}
var _damaged_target_ids_this_step: Dictionary = {}
var _world_container: Node2D
var _owns_world_container: bool = false
var _has_last_player_position: bool = false
var _last_player_position: Vector2 = Vector2.ZERO
var _elapsed_seconds: float = 0.0
var _spawn_timer_seconds: float = 0.0
var _trail_radius: float = 0.0
var _damage_per_tick: int = 0
var _trail_lifetime_seconds: float = 0.0
var _spawn_interval_seconds: float = 0.0
var _damage_tick_interval_seconds: float = 0.0
var _tick_sfx_cooldown_left: float = 0.0
var _resolved_trail_sprite_texture: Texture2D = null

func _ready() -> void:
	add_to_group("player_modules")
	_resolve_trail_visual_texture()
	set_level(0)

func _exit_tree() -> void:
	for segment in _segments:
		if segment == null:
			continue
		if segment.area != null and is_instance_valid(segment.area):
			segment.area.queue_free()
	_segments.clear()
	_target_last_hit_seconds.clear()

	if _owns_world_container and _world_container != null and is_instance_valid(_world_container):
		if _world_container.get_child_count() == 0:
			_world_container.queue_free()
	_world_container = null
	_owns_world_container = false

func _physics_process(delta: float) -> void:
	if acid_trail_level <= 0:
		return

	var owner_player: Node2D = get_parent() as Node2D
	if owner_player == null:
		return

	_elapsed_seconds += delta
	_spawn_timer_seconds = maxf(0.0, _spawn_timer_seconds - delta)
	_tick_sfx_cooldown_left = maxf(0.0, _tick_sfx_cooldown_left - delta)
	_damaged_target_ids_this_step.clear()

	if not _has_last_player_position:
		_last_player_position = owner_player.global_position
		_has_last_player_position = true

	var movement_distance: float = owner_player.global_position.distance_to(_last_player_position)
	if movement_distance >= min_spawn_distance and _spawn_timer_seconds <= 0.0:
		_spawn_segment(owner_player.global_position)
		_spawn_timer_seconds = _spawn_interval_seconds
		_last_player_position = owner_player.global_position

	_update_segments(delta)

func set_level(new_level: int) -> void:
	acid_trail_level = clampi(new_level, 0, 3)
	_configure_level_stats()
	_update_all_segment_shapes()

func set_lineage_color(color: Color) -> void:
	trail_color = color
	for segment in _segments:
		if segment == null or not segment.active:
			continue
		_update_segment_visual(segment, 1.0)

func _configure_level_stats() -> void:
	match acid_trail_level:
		1:
			_damage_per_tick = base_damage_per_tick
			_trail_radius = base_radius
			_spawn_interval_seconds = base_spawn_interval_seconds
			_trail_lifetime_seconds = base_lifetime_seconds
			_damage_tick_interval_seconds = base_damage_tick_interval_seconds
		2:
			_damage_per_tick = int(round(float(base_damage_per_tick) * 1.25))
			_trail_radius = base_radius + 1.5
			_spawn_interval_seconds = maxf(0.22, base_spawn_interval_seconds * 0.90)
			_trail_lifetime_seconds = base_lifetime_seconds + 0.45
			_damage_tick_interval_seconds = maxf(0.24, base_damage_tick_interval_seconds * 0.90)
		3:
			_damage_per_tick = int(round(float(base_damage_per_tick) * 1.50))
			_trail_radius = base_radius + 3.0
			_spawn_interval_seconds = maxf(0.19, base_spawn_interval_seconds * 0.82)
			_trail_lifetime_seconds = base_lifetime_seconds + 0.85
			_damage_tick_interval_seconds = maxf(0.21, base_damage_tick_interval_seconds * 0.82)
		_:
			_damage_per_tick = 0
			_trail_radius = 0.0
			_spawn_interval_seconds = 999.0
			_trail_lifetime_seconds = 0.0
			_damage_tick_interval_seconds = 999.0

func _update_segments(delta: float) -> void:
	for segment in _segments:
		if segment == null or not segment.active:
			continue

		segment.age_seconds += delta
		var life_ratio: float = 1.0 - (segment.age_seconds / maxf(0.01, _trail_lifetime_seconds))
		if life_ratio <= 0.0:
			_deactivate_segment(segment)
			continue

		_update_segment_visual(segment, life_ratio)
		_apply_segment_damage(segment)

func _apply_segment_damage(segment: TrailSegment) -> void:
	if segment.area == null:
		return

	for body_variant in segment.area.get_overlapping_bodies():
		var target: Node = body_variant as Node
		if target == null:
			continue
		if not target.is_in_group("enemies"):
			continue
		if not target.has_method("take_damage"):
			continue

		var target_id: int = target.get_instance_id()
		if _damaged_target_ids_this_step.has(target_id):
			continue
		if not _can_damage_target(target_id):
			continue

		if target.has_method("take_dot_damage"):
			target.call("take_dot_damage", _damage_per_tick)
		else:
			target.call("take_damage", _damage_per_tick)
		if target.has_method("apply_infection"):
			target.call("apply_infection", 2.8, 1)
		_target_last_hit_seconds[target_id] = _elapsed_seconds
		_damaged_target_ids_this_step[target_id] = true
		if debug_log_hits:
			print("Acid Trail hit enemy for ", _damage_per_tick)
		if _tick_sfx_cooldown_left <= 0.0:
			_play_sfx("sfx_infective_trail_tick", -8.0, randf_range(0.94, 1.08))
			_tick_sfx_cooldown_left = maxf(0.05, tick_sfx_cooldown_seconds)

func _can_damage_target(target_id: int) -> bool:
	if not _target_last_hit_seconds.has(target_id):
		return true

	var last_hit_seconds: float = float(_target_last_hit_seconds.get(target_id, -1000.0))
	return (_elapsed_seconds - last_hit_seconds) >= _damage_tick_interval_seconds

func _spawn_segment(world_position: Vector2) -> void:
	_ensure_world_container()
	if _world_container == null:
		return

	var segment: TrailSegment = _take_segment_for_reuse()
	if segment == null:
		return

	segment.active = true
	segment.age_seconds = 0.0
	if segment.area != null:
		segment.area.global_position = world_position
		segment.area.visible = true
	if segment.collision_shape != null:
		segment.collision_shape.disabled = false
	if segment.visual != null:
		segment.visual.visible = true
		segment.rotation_seed = randf_range(-PI, PI)
		segment.visual.rotation = segment.rotation_seed
	_update_segment_visual(segment, 1.0)

func _take_segment_for_reuse() -> TrailSegment:
	for segment in _segments:
		if segment != null and not segment.active:
			return segment

	if _segments.size() < maxi(1, max_segment_pool_size):
		var created_segment: TrailSegment = _create_segment()
		if created_segment != null:
			_segments.append(created_segment)
			return created_segment

	return _get_oldest_active_segment()

func _get_oldest_active_segment() -> TrailSegment:
	var selected_segment: TrailSegment = null
	var oldest_age_seconds: float = -1.0
	for segment in _segments:
		if segment == null or not segment.active:
			continue
		if segment.age_seconds > oldest_age_seconds:
			oldest_age_seconds = segment.age_seconds
			selected_segment = segment
	return selected_segment

func _deactivate_segment(segment: TrailSegment) -> void:
	segment.active = false
	segment.age_seconds = 0.0
	if segment.visual != null:
		segment.visual.visible = false
	if segment.collision_shape != null:
		segment.collision_shape.disabled = true
	if segment.area != null:
		segment.area.visible = false

func _create_segment() -> TrailSegment:
	if _world_container == null:
		return null

	var area := Area2D.new()
	area.monitoring = true
	area.monitorable = true
	area.collision_layer = 0
	area.collision_mask = 1
	area.visible = false

	var collision_shape := CollisionShape2D.new()
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = _trail_radius
	collision_shape.shape = circle_shape
	collision_shape.disabled = true
	area.add_child(collision_shape)

	var visual := Sprite2D.new()
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	visual.texture = _resolved_trail_sprite_texture
	visual.visible = false
	var add_material := CanvasItemMaterial.new()
	add_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	visual.material = add_material
	area.add_child(visual)

	_world_container.add_child(area)

	var segment := TrailSegment.new()
	segment.area = area
	segment.collision_shape = collision_shape
	segment.visual = visual
	return segment

func _ensure_world_container() -> void:
	if _world_container != null and is_instance_valid(_world_container):
		return

	var scene_root: Node = get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root

	var existing_container: Node = scene_root.get_node_or_null("AcidTrailSegments")
	if existing_container != null and existing_container is Node2D:
		_world_container = existing_container as Node2D
		_owns_world_container = false
		return

	var container := Node2D.new()
	container.name = "AcidTrailSegments"
	container.z_index = -1
	scene_root.add_child(container)
	_world_container = container
	_owns_world_container = true

func _update_all_segment_shapes() -> void:
	for segment in _segments:
		if segment == null:
			continue
		if segment.collision_shape != null:
			var shape_variant: Variant = segment.collision_shape.shape
			var circle_shape: CircleShape2D = shape_variant as CircleShape2D
			if circle_shape != null:
				circle_shape.radius = _trail_radius
		if segment.visual != null:
			segment.visual.texture = _resolved_trail_sprite_texture

func _update_segment_visual(segment: TrailSegment, life_ratio: float) -> void:
	if segment.visual == null:
		return
	if _resolved_trail_sprite_texture == null:
		segment.visual.visible = false
		return

	var clamped_ratio: float = clampf(life_ratio, 0.0, 1.0)
	var color_now: Color = trail_color
	color_now.a = trail_color.a * (0.35 + (0.65 * clamped_ratio))
	segment.visual.modulate = color_now
	segment.visual.texture = _resolved_trail_sprite_texture

	var texture_width: float = maxf(1.0, _resolved_trail_sprite_texture.get_size().x)
	var desired_diameter: float = _trail_radius * 2.0 * trail_sprite_scale_multiplier
	var base_scale: float = desired_diameter / texture_width
	var scale_factor: float = base_scale * (0.90 + (0.18 * clamped_ratio))
	segment.visual.scale = Vector2(scale_factor, scale_factor)
	segment.visual.rotation = segment.rotation_seed + ((_elapsed_seconds + segment.age_seconds) * 0.7)

func _resolve_trail_visual_texture() -> void:
	_resolved_trail_sprite_texture = trail_sprite_texture
	if trail_sprite_texture == null:
		return
	var columns: int = maxi(1, trail_sheet_columns)
	var rows: int = maxi(1, trail_sheet_rows)
	if columns <= 1 and rows <= 1:
		return
	var first_frame_texture: Texture2D = SpritesheetFrames.build_first_frame_texture(trail_sprite_texture, columns, rows)
	if first_frame_texture != null:
		_resolved_trail_sprite_texture = first_frame_texture

func _play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id, volume_db_offset, pitch_scale)
