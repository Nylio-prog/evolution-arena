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

class TrailVisualPoint:
	extends RefCounted
	var world_position: Vector2 = Vector2.ZERO
	var age_seconds: float = 0.0

@export var base_damage_per_tick: int = 3
@export var base_radius: float = 17.0
@export var base_spawn_interval_seconds: float = 0.36
@export var base_lifetime_seconds: float = 1.8
@export var base_damage_tick_interval_seconds: float = 0.50
@export var min_spawn_distance: float = 13.0
@export var max_segment_pool_size: int = 24
@export var trail_color: Color = Color(1.0, 1.0, 1.0, 0.95)
@export var trail_sprite_texture: Texture2D = ACID_TRAIL_SPRITE_TEXTURE
@export var trail_sheet_columns: int = 3
@export var trail_sheet_rows: int = 3
@export var trail_sprite_scale_multiplier: float = 1.55
@export var use_spritesheet_frames_for_segments: bool = true
@export var segment_visual_additive_blend: bool = false
@export var segment_visual_z_index: int = -2
@export var use_lineage_tint: bool = false
@export_range(0.0, 1.0, 0.01) var lineage_tint_strength: float = 0.20
@export var enable_continuous_fog_visual: bool = false
@export var segment_visual_alpha_scale: float = 1.0
@export var fog_visual_lifetime_seconds: float = 2.6
@export var fog_visual_point_spacing: float = 5.5
@export var fog_soft_width_multiplier: float = 2.9
@export var fog_core_width_multiplier: float = 2.0
@export var fog_soft_alpha_scale: float = 0.28
@export var fog_core_alpha_scale: float = 0.60
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
var _trail_frame_textures: Array[Texture2D] = []
var _lineage_color: Color = Color(1.0, 1.0, 1.0, 1.0)
var _fog_visual_points: Array[TrailVisualPoint] = []
var _fog_line_soft: Line2D
var _fog_line_core: Line2D
var _fog_last_world_position: Vector2 = Vector2.ZERO
var _fog_has_last_position: bool = false

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
	_clear_fog_visual()

func _physics_process(delta: float) -> void:
	if acid_trail_level <= 0:
		_clear_fog_visual()
		return

	var owner_player: Node2D = get_parent() as Node2D
	if owner_player == null:
		_clear_fog_visual()
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

	_tick_fog_visual(owner_player.global_position, delta)
	_update_segments(delta)

func set_level(new_level: int) -> void:
	acid_trail_level = clampi(new_level, 0, 5)
	_configure_level_stats()
	_update_all_segment_shapes()
	_refresh_fog_visual_style()
	if acid_trail_level <= 0:
		_clear_fog_visual()

func set_lineage_color(color: Color) -> void:
	_lineage_color = color
	for segment in _segments:
		if segment == null or not segment.active:
			continue
		_update_segment_visual(segment, 1.0)
	_refresh_fog_visual_style()

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
		4:
			_damage_per_tick = int(round(float(base_damage_per_tick) * 1.80))
			_trail_radius = base_radius + 4.5
			_spawn_interval_seconds = maxf(0.16, base_spawn_interval_seconds * 0.74)
			_trail_lifetime_seconds = base_lifetime_seconds + 1.25
			_damage_tick_interval_seconds = maxf(0.18, base_damage_tick_interval_seconds * 0.74)
		5:
			_damage_per_tick = int(round(float(base_damage_per_tick) * 2.10))
			_trail_radius = base_radius + 6.0
			_spawn_interval_seconds = maxf(0.14, base_spawn_interval_seconds * 0.66)
			_trail_lifetime_seconds = base_lifetime_seconds + 1.70
			_damage_tick_interval_seconds = maxf(0.16, base_damage_tick_interval_seconds * 0.66)
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
	visual.z_index = segment_visual_z_index
	visual.visible = false
	if segment_visual_additive_blend:
		var add_material := CanvasItemMaterial.new()
		add_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		visual.material = add_material
	else:
		visual.material = null
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
			segment.visual.z_index = segment_visual_z_index

func _update_segment_visual(segment: TrailSegment, life_ratio: float) -> void:
	if segment.visual == null:
		return
	if enable_continuous_fog_visual and segment_visual_alpha_scale <= 0.001:
		segment.visual.visible = false
		return
	if _resolved_trail_sprite_texture == null:
		segment.visual.visible = false
		return

	var clamped_ratio: float = clampf(life_ratio, 0.0, 1.0)
	var color_now: Color = trail_color
	if use_lineage_tint:
		var lineage_rgb: Color = Color(_lineage_color.r, _lineage_color.g, _lineage_color.b, 1.0)
		color_now = color_now.lerp(lineage_rgb, clampf(lineage_tint_strength, 0.0, 1.0))
	color_now.a = trail_color.a * segment_visual_alpha_scale * (0.35 + (0.65 * clamped_ratio))
	segment.visual.modulate = color_now
	if not _trail_frame_textures.is_empty():
		var total_frames: int = _trail_frame_textures.size()
		var progress: float = 1.0 - clamped_ratio
		var frame_index: int = clampi(int(floor(progress * float(total_frames))), 0, total_frames - 1)
		segment.visual.texture = _trail_frame_textures[frame_index]
	else:
		segment.visual.texture = _resolved_trail_sprite_texture

	var texture_width: float = maxf(1.0, _resolved_trail_sprite_texture.get_size().x)
	var desired_diameter: float = _trail_radius * 2.0 * trail_sprite_scale_multiplier
	var base_scale: float = desired_diameter / texture_width
	var scale_factor: float = base_scale * (0.90 + (0.18 * clamped_ratio))
	segment.visual.scale = Vector2(scale_factor, scale_factor)
	segment.visual.rotation = segment.rotation_seed + ((_elapsed_seconds + segment.age_seconds) * 0.7)

func _resolve_trail_visual_texture() -> void:
	_trail_frame_textures.clear()
	_resolved_trail_sprite_texture = trail_sprite_texture
	if trail_sprite_texture == null:
		return
	var columns: int = maxi(1, trail_sheet_columns)
	var rows: int = maxi(1, trail_sheet_rows)
	if columns <= 1 and rows <= 1:
		return
	if not use_spritesheet_frames_for_segments:
		var first_frame_texture: Texture2D = SpritesheetFrames.build_first_frame_texture(trail_sprite_texture, columns, rows)
		if first_frame_texture != null:
			_resolved_trail_sprite_texture = first_frame_texture
		return

	var texture_size: Vector2 = trail_sprite_texture.get_size()
	if texture_size.x <= 1.0 or texture_size.y <= 1.0:
		return
	var cell_width: float = floor(texture_size.x / float(columns))
	var cell_height: float = floor(texture_size.y / float(rows))
	if cell_width <= 1.0 or cell_height <= 1.0:
		return

	for frame_index in range(columns * rows):
		var cell_x: int = frame_index % columns
		var cell_y: int = int(floor(float(frame_index) / float(columns)))
		var atlas := AtlasTexture.new()
		atlas.atlas = trail_sprite_texture
		atlas.region = Rect2(
			Vector2(float(cell_x) * cell_width, float(cell_y) * cell_height),
			Vector2(cell_width, cell_height)
		)
		_trail_frame_textures.append(atlas)
	if not _trail_frame_textures.is_empty():
		_resolved_trail_sprite_texture = _trail_frame_textures[0]

func _play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id, volume_db_offset, pitch_scale)

func _tick_fog_visual(player_world_position: Vector2, delta: float) -> void:
	if not enable_continuous_fog_visual:
		_clear_fog_visual()
		return

	_ensure_world_container()
	_ensure_fog_visual_nodes()
	if _world_container == null:
		return

	if not _fog_has_last_position:
		_fog_last_world_position = player_world_position
		_fog_has_last_position = true
		_add_fog_visual_point(player_world_position, true)

	var spacing: float = maxf(1.0, fog_visual_point_spacing)
	var movement: Vector2 = player_world_position - _fog_last_world_position
	var movement_distance: float = movement.length()
	if movement_distance >= spacing:
		var direction: Vector2 = movement / movement_distance
		var cursor: Vector2 = _fog_last_world_position
		var advanced_distance: float = 0.0
		while (movement_distance - advanced_distance) >= spacing:
			cursor += direction * spacing
			_add_fog_visual_point(cursor)
			advanced_distance += spacing
		# Preserve the leftover sub-spacing distance so the trail keeps accumulating.
		_fog_last_world_position = cursor

	var max_age: float = maxf(0.2, fog_visual_lifetime_seconds)
	var kept_points: Array[TrailVisualPoint] = []
	for point in _fog_visual_points:
		if point == null:
			continue
		point.age_seconds += delta
		if point.age_seconds <= max_age:
			kept_points.append(point)
	_fog_visual_points = kept_points

	_refresh_fog_visual_points()

func _add_fog_visual_point(world_position: Vector2, force_add: bool = false) -> void:
	if not force_add and not _fog_visual_points.is_empty():
		var last_point: TrailVisualPoint = _fog_visual_points[_fog_visual_points.size() - 1]
		if last_point != null:
			var min_distance: float = maxf(0.5, fog_visual_point_spacing * 0.45)
			if world_position.distance_to(last_point.world_position) < min_distance:
				return
	var point := TrailVisualPoint.new()
	point.world_position = world_position
	point.age_seconds = 0.0
	_fog_visual_points.append(point)

func _ensure_fog_visual_nodes() -> void:
	if not enable_continuous_fog_visual:
		return
	if _world_container == null:
		return

	if _fog_line_soft == null or not is_instance_valid(_fog_line_soft):
		_fog_line_soft = Line2D.new()
		_fog_line_soft.name = "AcidTrailFogSoft"
		_fog_line_soft.antialiased = true
		_fog_line_soft.texture_mode = Line2D.LINE_TEXTURE_NONE
		_fog_line_soft.begin_cap_mode = Line2D.LINE_CAP_ROUND
		_fog_line_soft.end_cap_mode = Line2D.LINE_CAP_ROUND
		_fog_line_soft.joint_mode = Line2D.LINE_JOINT_ROUND
		_fog_line_soft.z_index = -3
		_world_container.add_child(_fog_line_soft)

	if _fog_line_core == null or not is_instance_valid(_fog_line_core):
		_fog_line_core = Line2D.new()
		_fog_line_core.name = "AcidTrailFogCore"
		_fog_line_core.antialiased = true
		_fog_line_core.texture_mode = Line2D.LINE_TEXTURE_NONE
		_fog_line_core.begin_cap_mode = Line2D.LINE_CAP_ROUND
		_fog_line_core.end_cap_mode = Line2D.LINE_CAP_ROUND
		_fog_line_core.joint_mode = Line2D.LINE_JOINT_ROUND
		_fog_line_core.z_index = -2
		_world_container.add_child(_fog_line_core)

	_refresh_fog_visual_style()

func _refresh_fog_visual_style() -> void:
	var fog_soft_color: Color = trail_color
	fog_soft_color.a = clampf(trail_color.a * fog_soft_alpha_scale, 0.0, 1.0)
	var fog_core_color: Color = trail_color
	fog_core_color.a = clampf(trail_color.a * fog_core_alpha_scale, 0.0, 1.0)

	var soft_gradient := Gradient.new()
	soft_gradient.add_point(0.00, Color(fog_soft_color.r, fog_soft_color.g, fog_soft_color.b, 0.0))
	soft_gradient.add_point(0.28, Color(fog_soft_color.r, fog_soft_color.g, fog_soft_color.b, fog_soft_color.a * 0.55))
	soft_gradient.add_point(1.00, fog_soft_color)

	var core_gradient := Gradient.new()
	core_gradient.add_point(0.00, Color(fog_core_color.r, fog_core_color.g, fog_core_color.b, 0.0))
	core_gradient.add_point(0.24, Color(fog_core_color.r, fog_core_color.g, fog_core_color.b, fog_core_color.a * 0.65))
	core_gradient.add_point(1.00, fog_core_color)

	var soft_width: float = maxf(2.0, _trail_radius * 2.0 * maxf(1.0, fog_soft_width_multiplier))
	var core_width: float = maxf(2.0, _trail_radius * 2.0 * maxf(1.0, fog_core_width_multiplier))

	if _fog_line_soft != null and is_instance_valid(_fog_line_soft):
		_fog_line_soft.width = soft_width
		_fog_line_soft.gradient = soft_gradient
	if _fog_line_core != null and is_instance_valid(_fog_line_core):
		_fog_line_core.width = core_width
		_fog_line_core.gradient = core_gradient

func _refresh_fog_visual_points() -> void:
	var packed_points := PackedVector2Array()
	if _world_container != null and is_instance_valid(_world_container):
		for point in _fog_visual_points:
			if point == null:
				continue
			packed_points.append(_world_container.to_local(point.world_position))

	if _fog_line_soft != null and is_instance_valid(_fog_line_soft):
		_fog_line_soft.points = packed_points
	if _fog_line_core != null and is_instance_valid(_fog_line_core):
		_fog_line_core.points = packed_points

func _clear_fog_visual() -> void:
	_fog_visual_points.clear()
	_fog_has_last_position = false
	if _fog_line_soft != null and is_instance_valid(_fog_line_soft):
		_fog_line_soft.points = PackedVector2Array()
	if _fog_line_core != null and is_instance_valid(_fog_line_core):
		_fog_line_core.points = PackedVector2Array()
