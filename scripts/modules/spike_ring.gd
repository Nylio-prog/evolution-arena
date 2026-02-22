extends Node2D

const SPIKE_SPRITE_TEXTURE: Texture2D = preload("res://art/sprites/modules/razor_halo_blade.png")

@export var spike_damage: int = 6
@export var spike_distance: float = 42.0
@export var spike_collision_radius: float = 14.0
@export var spike_color: Color = Color(0.95, 0.95, 0.95, 1.0)
@export var spike_outline_color: Color = Color(0.1, 0.1, 0.1, 0.9)
@export var spike_sprite_texture: Texture2D = SPIKE_SPRITE_TEXTURE
@export var spike_sprite_world_size_multiplier: float = 5.2
@export var spike_facing_offset_degrees: float = -90.0
@export var preserve_template_visual_scale: bool = true
@export var preserve_template_collision_shape_size: bool = true
@export var damage_interval_seconds: float = 0.14
@export var hit_sfx_cooldown_seconds: float = 0.08
@export var level_1_rotation_speed_rps: float = 0.38
@export var level_2_rotation_speed_rps: float = 0.52
@export var level_3_rotation_speed_rps: float = 0.68
@export var level_4_rotation_speed_rps: float = 0.82
@export var level_5_rotation_speed_rps: float = 0.96
@export var sustain_unlock_level: int = 2
@export var sustain_heal_per_enemy_hit: int = 1
@export var sustain_heal_per_level_bonus: int = 0
@export var sustain_max_enemy_hits_per_tick: int = 1
@export var debug_log_hits: bool = false

@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")
@onready var spike_template: Area2D = get_node_or_null("SpikeTemplate")

var spike_level: int = 0
var _damage_tick_accumulator: float = 0.0
var _hit_sfx_cooldown_left: float = 0.0
var _runtime_spike_areas: Array[Area2D] = []
var _cached_player: Node = null

func _ready() -> void:
	add_to_group("player_modules")
	set_level(0)

func _process(delta: float) -> void:
	if spike_level <= 0:
		return

	rotation += TAU * _get_rotation_speed_for_level(spike_level) * delta
	_hit_sfx_cooldown_left = maxf(0.0, _hit_sfx_cooldown_left - delta)

	_damage_tick_accumulator += delta
	if _damage_tick_accumulator < damage_interval_seconds:
		return
	_damage_tick_accumulator = 0.0
	_deal_contact_damage_tick()

func set_level(new_level: int) -> void:
	spike_level = clampi(new_level, 0, 5)
	_rebuild_spike_areas()
	_refresh_spike_visuals()
	queue_redraw()

func set_lineage_color(color: Color) -> void:
	spike_color = color
	spike_outline_color = color.darkened(0.8)
	_refresh_spike_visuals()
	queue_redraw()

func _rebuild_spike_areas() -> void:
	for spike_area in _runtime_spike_areas:
		if spike_area == null:
			continue
		if not is_instance_valid(spike_area):
			continue
		spike_area.queue_free()
	_runtime_spike_areas.clear()

	var spike_count := _get_spike_count_for_level(spike_level)
	for i in range(spike_count):
		var angle := (TAU * float(i)) / float(spike_count)
		var direction := Vector2.RIGHT.rotated(angle)
		var spike_area := _build_spike_area_instance()
		spike_area.position = direction * spike_distance
		spike_area.rotation = angle + deg_to_rad(spike_facing_offset_degrees)
		spike_area.monitoring = true
		spike_area.monitorable = true
		spike_area.visible = true
		_refresh_spike_area_collision(spike_area)
		_refresh_spike_area_visual(spike_area)

		add_child(spike_area)
		_runtime_spike_areas.append(spike_area)

func _deal_contact_damage_tick() -> void:
	var did_hit_target: bool = false
	var unique_enemy_hits: Dictionary = {}
	for spike_area in _runtime_spike_areas:
		if spike_area == null:
			continue
		if not is_instance_valid(spike_area):
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
			did_hit_target = true
			unique_enemy_hits[target.get_instance_id()] = true
			if debug_log_hits:
				print("Spike hit enemy for ", spike_damage)
	if did_hit_target and _hit_sfx_cooldown_left <= 0.0:
		_play_sfx("sfx_razor_halo_hit", -8.0, randf_range(0.94, 1.08))
		_hit_sfx_cooldown_left = maxf(0.02, hit_sfx_cooldown_seconds)
	_apply_contact_sustain(unique_enemy_hits.size())

func _get_spike_count_for_level(level: int) -> int:
	match level:
		1:
			return 4
		2:
			return 6
		3:
			return 8
		4:
			return 10
		5:
			return 12
		_:
			return 0

func _get_rotation_speed_for_level(level: int) -> float:
	match level:
		1:
			return maxf(0.0, level_1_rotation_speed_rps)
		2:
			return maxf(0.0, level_2_rotation_speed_rps)
		3:
			return maxf(0.0, level_3_rotation_speed_rps)
		4:
			return maxf(0.0, level_4_rotation_speed_rps)
		5:
			return maxf(0.0, level_5_rotation_speed_rps)
		_:
			return 0.0

func _draw() -> void:
	pass

func _refresh_spike_visuals() -> void:
	for spike_area in _runtime_spike_areas:
		if spike_area == null:
			continue
		if not is_instance_valid(spike_area):
			continue
		_refresh_spike_area_visual(spike_area)

func _compute_spike_sprite_scale() -> Vector2:
	if spike_sprite_texture == null:
		return Vector2.ONE
	var texture_width: float = maxf(1.0, spike_sprite_texture.get_size().x)
	var desired_diameter: float = spike_collision_radius * 2.0 * spike_sprite_world_size_multiplier
	var uniform_scale: float = desired_diameter / texture_width
	return Vector2(uniform_scale, uniform_scale)

func _play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id, volume_db_offset, pitch_scale)

func _apply_contact_sustain(unique_hit_count: int) -> void:
	if spike_level < maxi(1, sustain_unlock_level):
		return
	if unique_hit_count <= 0:
		return
	if sustain_max_enemy_hits_per_tick <= 0:
		return
	var player_node: Node = _get_player_node()
	if player_node == null:
		return
	if not player_node.has_method("heal"):
		return

	var heal_per_enemy_hit: int = _get_sustain_heal_per_enemy_hit_for_level(spike_level)
	var effective_hit_count: int = mini(unique_hit_count, sustain_max_enemy_hits_per_tick)
	if effective_hit_count <= 0:
		return
	var heal_amount: int = heal_per_enemy_hit * effective_hit_count
	if heal_amount <= 0:
		return
	player_node.call("heal", heal_amount)

func _get_sustain_heal_per_enemy_hit_for_level(level: int) -> int:
	if level < maxi(1, sustain_unlock_level):
		return 0
	var safe_level: int = clampi(level, 0, 5)
	var heal_value: int = maxi(0, sustain_heal_per_enemy_hit)
	# Buff starts at L3 as requested.
	if safe_level >= 3:
		heal_value += 1
	if safe_level >= 4:
		heal_value += 1
	if safe_level >= 5:
		heal_value += 1
	heal_value += maxi(0, safe_level - 2) * maxi(0, sustain_heal_per_level_bonus)
	return maxi(0, heal_value)

func _get_player_node() -> Node:
	if _cached_player != null and is_instance_valid(_cached_player):
		return _cached_player
	var parent_node: Node = get_parent()
	if parent_node != null and is_instance_valid(parent_node) and parent_node.is_in_group("player"):
		_cached_player = parent_node
		return _cached_player
	var scene_tree: SceneTree = get_tree()
	if scene_tree == null:
		return null
	_cached_player = scene_tree.get_first_node_in_group("player")
	return _cached_player

func _build_spike_area_instance() -> Area2D:
	if spike_template != null:
		var duplicated_template := spike_template.duplicate() as Area2D
		if duplicated_template != null:
			duplicated_template.name = "Spike"
			return duplicated_template

	var fallback_area := Area2D.new()
	fallback_area.name = "Spike"
	var collision_shape := CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = spike_collision_radius
	collision_shape.shape = circle_shape
	fallback_area.add_child(collision_shape)

	var visual_sprite := Sprite2D.new()
	visual_sprite.name = "VisualSprite"
	fallback_area.add_child(visual_sprite)
	return fallback_area

func _refresh_spike_area_collision(spike_area: Area2D) -> void:
	if spike_area == null:
		return
	if preserve_template_collision_shape_size and spike_template != null:
		return
	var collision_shape := spike_area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		return
	var circle_shape := collision_shape.shape as CircleShape2D
	if circle_shape == null:
		return
	circle_shape.radius = spike_collision_radius

func _refresh_spike_area_visual(spike_area: Area2D) -> void:
	if spike_area == null:
		return
	var visual_sprite := spike_area.get_node_or_null("VisualSprite") as Sprite2D
	if visual_sprite == null:
		return
	visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	visual_sprite.texture = spike_sprite_texture
	if not (preserve_template_visual_scale and spike_template != null):
		visual_sprite.scale = _compute_spike_sprite_scale()
	visual_sprite.modulate = spike_color
