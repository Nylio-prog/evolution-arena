extends Node2D

const ORBITER_SPRITE_TEXTURE: Texture2D = preload("res://art/sprites/modules/virion_orbiter.png")

@export var orbiter_damage: int = 6
@export var base_orbit_radius: float = 72.0
@export var orbit_radius_bonus_level_2: float = 18.0
@export var orbit_radius_bonus_level_3: float = 34.0
@export var orbit_radius_bonus_level_4: float = 52.0
@export var orbit_radius_bonus_level_5: float = 74.0
@export var base_orbit_speed_rps: float = 2.5
@export var orbiter_collision_radius: float = 9.0
@export var orbiter_color: Color = Color(0.85, 0.95, 1.0, 1.0)
@export var orbiter_outline_color: Color = Color(0.08, 0.14, 0.18, 0.95)
@export var orbiter_sprite_texture: Texture2D = ORBITER_SPRITE_TEXTURE
@export var orbiter_sprite_world_size_multiplier: float = 2.2
@export var damage_interval_seconds: float = 0.2
@export var hit_sfx_cooldown_seconds: float = 0.1
@export var debug_log_hits: bool = false

@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")

var orbiter_level: int = 0
var _elapsed_seconds: float = 0.0
var _current_orbit_radius: float = 72.0
var _current_orbit_speed_rps: float = 2.5
var _target_last_hit_time: Dictionary = {}
var _hit_sfx_cooldown_left: float = 0.0

func _ready() -> void:
	add_to_group("player_modules")
	set_level(0)

func _physics_process(delta: float) -> void:
	if orbiter_level <= 0:
		return

	_elapsed_seconds += delta
	_hit_sfx_cooldown_left = maxf(0.0, _hit_sfx_cooldown_left - delta)
	_update_orbiter_positions()
	_deal_contact_damage_tick()
	queue_redraw()

func set_level(new_level: int) -> void:
	orbiter_level = clampi(new_level, 0, 5)
	_configure_level_stats()
	_rebuild_orbiter_areas()
	_update_orbiter_positions()
	_refresh_orbiter_visuals()
	queue_redraw()

func set_lineage_color(color: Color) -> void:
	orbiter_color = color
	orbiter_outline_color = color.darkened(0.75)
	_refresh_orbiter_visuals()
	queue_redraw()

func _configure_level_stats() -> void:
	_current_orbit_radius = base_orbit_radius
	_current_orbit_speed_rps = base_orbit_speed_rps
	if orbiter_level >= 2:
		_current_orbit_radius += maxf(0.0, orbit_radius_bonus_level_2)
	if orbiter_level >= 3:
		_current_orbit_radius += maxf(0.0, orbit_radius_bonus_level_3)
	if orbiter_level >= 4:
		_current_orbit_radius += maxf(0.0, orbit_radius_bonus_level_4)
	if orbiter_level >= 5:
		_current_orbit_radius += maxf(0.0, orbit_radius_bonus_level_5)

	if orbiter_level >= 3:
		_current_orbit_speed_rps = base_orbit_speed_rps * 1.5
	if orbiter_level >= 4:
		_current_orbit_speed_rps = base_orbit_speed_rps * 1.8
	if orbiter_level >= 5:
		_current_orbit_speed_rps = base_orbit_speed_rps * 2.1

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

		var visual_sprite := Sprite2D.new()
		visual_sprite.name = "VisualSprite"
		visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		visual_sprite.texture = orbiter_sprite_texture
		visual_sprite.scale = _compute_orbiter_sprite_scale()
		visual_sprite.modulate = orbiter_color
		orbiter_area.add_child(visual_sprite)

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
		var visual_sprite := orbiter_area.get_node_or_null("VisualSprite") as Sprite2D
		if visual_sprite != null:
			visual_sprite.rotation = angle

func _deal_contact_damage_tick() -> void:
	var did_hit_target: bool = false
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
			if target.has_method("apply_infection"):
				target.call("apply_infection", 2.0, 1)
			did_hit_target = true
			if debug_log_hits:
				print("Orbiter hit enemy for ", orbiter_damage)
	if did_hit_target and _hit_sfx_cooldown_left <= 0.0:
		_play_sfx("sfx_razor_halo_hit", -8.5, randf_range(0.95, 1.06))
		_hit_sfx_cooldown_left = maxf(0.03, hit_sfx_cooldown_seconds)

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
		4:
			return 3
		5:
			return 4
		_:
			return 0

func _draw() -> void:
	pass

func _refresh_orbiter_visuals() -> void:
	for child in get_children():
		var orbiter_area := child as Area2D
		if orbiter_area == null:
			continue
		var visual_sprite := orbiter_area.get_node_or_null("VisualSprite") as Sprite2D
		if visual_sprite == null:
			continue
		visual_sprite.texture = orbiter_sprite_texture
		visual_sprite.scale = _compute_orbiter_sprite_scale()
		visual_sprite.modulate = orbiter_color

func _compute_orbiter_sprite_scale() -> Vector2:
	if orbiter_sprite_texture == null:
		return Vector2.ONE
	var texture_width: float = maxf(1.0, orbiter_sprite_texture.get_size().x)
	var desired_diameter: float = orbiter_collision_radius * 2.0 * orbiter_sprite_world_size_multiplier
	var uniform_scale: float = desired_diameter / texture_width
	return Vector2(uniform_scale, uniform_scale)

func _play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id, volume_db_offset, pitch_scale)
