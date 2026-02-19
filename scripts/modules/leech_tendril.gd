extends Node2D

@export var base_drain_damage: int = 4
@export var base_heal_per_tick: int = 1
@export var base_tick_interval_seconds: float = 0.72
@export var base_range: float = 170.0
@export var tether_template_animation: StringName = &"beam"
@export var tether_thickness_scale: float = 0.24
@export var tether_alpha: float = 0.92
@export var tether_start_offset: float = 18.0
@export var tether_end_offset: float = 0.0
@export var tether_z_index: int = -1
@export var drain_sfx_cooldown_seconds: float = 0.34
@export var debug_log_drain: bool = false

@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")
@onready var beam_template: AnimatedSprite2D = get_node_or_null("BeamTemplate")

var tendril_level: int = 0
var _runtime_damage_multiplier: float = 1.0
var _runtime_cooldown_multiplier: float = 1.0
var _time_until_tick: float = 0.0
var _tether_targets: Array[Node2D] = []
var _drain_sfx_cooldown_left: float = 0.0
var _drain_sfx_should_be_active: bool = false
var _tether_beam_roots: Array[Node2D] = []
var _tether_beam_sprites: Array[AnimatedSprite2D] = []
var _tether_frame_size: Vector2 = Vector2(96.0, 96.0)
var _tether_template_scale: Vector2 = Vector2.ONE
var _tether_resolved_animation: StringName = StringName()
var _has_valid_beam_template: bool = false

func _ready() -> void:
	add_to_group("player_modules")
	_setup_beam_template()
	set_level(0)
	_sync_tether_visual_pool()

func _physics_process(delta: float) -> void:
	if tendril_level <= 0:
		_stop_drain_sfx_if_needed()
		_tether_targets.clear()
		_update_tether_visuals()
		return
	_drain_sfx_cooldown_left = maxf(0.0, _drain_sfx_cooldown_left - delta)

	_time_until_tick = maxf(0.0, _time_until_tick - delta)
	if _time_until_tick > 0.0:
		if not _has_any_valid_tether_target():
			_stop_drain_sfx_if_needed()
		_update_tether_visuals()
		return

	_apply_drain_tick()
	_time_until_tick = _get_effective_tick_interval_seconds()
	_update_tether_visuals()

func set_level(new_level: int) -> void:
	tendril_level = clampi(new_level, 0, 5)
	_time_until_tick = minf(_time_until_tick, _get_effective_tick_interval_seconds())
	_sync_tether_visual_pool()
	_update_tether_visuals()

func set_runtime_modifiers(damage_multiplier: float, cooldown_multiplier: float) -> void:
	_runtime_damage_multiplier = maxf(0.1, damage_multiplier)
	_runtime_cooldown_multiplier = maxf(0.1, cooldown_multiplier)

func get_regen_per_second_estimate() -> float:
	if tendril_level <= 0:
		return 0.0
	var targets: int = _get_tether_target_count()
	var heal_per_tick: int = _get_effective_heal_per_tick()
	var max_total_heal_per_tick: int = _get_effective_max_total_heal_per_tick()
	var tick_interval: float = _get_effective_tick_interval_seconds()
	if tick_interval <= 0.0:
		return 0.0
	var total_heal_per_tick: int = mini(targets * heal_per_tick, max_total_heal_per_tick)
	return float(total_heal_per_tick) / tick_interval

func _get_effective_tick_interval_seconds() -> float:
	if tendril_level <= 0:
		return 999.0
	var tick_interval: float = base_tick_interval_seconds
	match tendril_level:
		2:
			tick_interval = base_tick_interval_seconds * 0.92
		3:
			tick_interval = base_tick_interval_seconds * 0.84
		4:
			tick_interval = base_tick_interval_seconds * 0.78
		5:
			tick_interval = base_tick_interval_seconds * 0.72
	return maxf(0.18, tick_interval * _runtime_cooldown_multiplier)

func _get_effective_range() -> float:
	if tendril_level <= 0:
		return 0.0
	var range_value: float = base_range
	match tendril_level:
		2:
			range_value += 20.0
		3:
			range_value += 36.0
		4:
			range_value += 52.0
		5:
			range_value += 70.0
	return range_value

func _get_effective_damage_per_tick() -> int:
	if tendril_level <= 0:
		return 0
	var damage_value: float = float(base_drain_damage)
	match tendril_level:
		2:
			damage_value *= 1.25
		3:
			damage_value *= 1.48
		4:
			damage_value *= 1.75
		5:
			damage_value *= 2.05
	damage_value *= _runtime_damage_multiplier
	return maxi(1, int(round(damage_value)))

func _get_effective_heal_per_tick() -> int:
	if tendril_level <= 0:
		return 0
	match tendril_level:
		1:
			return maxi(1, base_heal_per_tick)
		2:
			return maxi(1, base_heal_per_tick)
		3:
			return maxi(1, base_heal_per_tick + 1)
		4:
			return maxi(1, base_heal_per_tick + 1)
		5:
			return maxi(1, base_heal_per_tick + 1)
	return 0

func _get_effective_max_total_heal_per_tick() -> int:
	match tendril_level:
		1:
			return 1
		2:
			return 1
		3:
			return 2
		4:
			return 2
		5:
			return 3
		_:
			return 0

func _get_tether_target_count() -> int:
	match tendril_level:
		1, 2:
			return 1
		3:
			return 2
		4:
			return 2
		5:
			return 2
		_:
			return 0

func _apply_drain_tick() -> void:
	var owner_player := get_parent() as Node2D
	if owner_player == null:
		return

	var origin: Vector2 = owner_player.global_position
	var range_value: float = _get_effective_range()
	var candidates: Array[Node2D] = []
	for enemy_variant in get_tree().get_nodes_in_group("enemies"):
		var enemy_node := enemy_variant as Node2D
		if enemy_node == null:
			continue
		if not enemy_node.has_method("take_damage"):
			continue
		if origin.distance_to(enemy_node.global_position) > range_value:
			continue
		candidates.append(enemy_node)

	if candidates.is_empty():
		_stop_drain_sfx_if_needed()
		_tether_targets.clear()
		return

	candidates.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		var a_priority: int = _get_target_priority(a)
		var b_priority: int = _get_target_priority(b)
		if a_priority != b_priority:
			return a_priority > b_priority
		return origin.distance_squared_to(a.global_position) < origin.distance_squared_to(b.global_position)
	)

	var max_targets: int = _get_tether_target_count()
	var damage_amount: int = _get_effective_damage_per_tick()
	var heal_amount: int = _get_effective_heal_per_tick()
	var applied_heal: int = 0
	_tether_targets.clear()
	for i in range(mini(max_targets, candidates.size())):
		var target_node: Node2D = candidates[i]
		if target_node == null or not is_instance_valid(target_node):
			continue
		target_node.call("take_damage", damage_amount)
		if target_node.has_method("apply_infection"):
			target_node.call("apply_infection", 1.6, 1)
		_tether_targets.append(target_node)
		applied_heal += heal_amount

	if applied_heal > 0 and owner_player.has_method("heal"):
		applied_heal = mini(applied_heal, _get_effective_max_total_heal_per_tick())
		owner_player.call("heal", applied_heal)
	if applied_heal > 0 and _drain_sfx_cooldown_left <= 0.0:
		_play_sfx("sfx_leech_tendril_loop", -9.0, randf_range(0.96, 1.04))
		_drain_sfx_should_be_active = true
		_drain_sfx_cooldown_left = maxf(0.08, drain_sfx_cooldown_seconds)
	elif applied_heal <= 0:
		_stop_drain_sfx_if_needed()
	if debug_log_drain and applied_heal > 0:
		print("Leech Tendril healed ", applied_heal, " HP")

func _get_target_priority(target_node: Node2D) -> int:
	if target_node == null:
		return 0
	if target_node.is_in_group("boss_enemies"):
		return 300
	if target_node.is_in_group("elite_enemies"):
		return 200
	if target_node.has_method("is_elite_enemy") and bool(target_node.call("is_elite_enemy")):
		return 200
	return 100

func _sync_tether_visual_pool() -> void:
	var expected_count: int = _get_tether_target_count()
	expected_count = clampi(expected_count, 0, 4)

	while _tether_beam_roots.size() < expected_count:
		var beam_root := Node2D.new()
		beam_root.z_index = tether_z_index
		beam_root.visible = false
		add_child(beam_root)

		var beam_sprite: AnimatedSprite2D = _create_runtime_beam_sprite()
		beam_root.add_child(beam_sprite)

		_tether_beam_roots.append(beam_root)
		_tether_beam_sprites.append(beam_sprite)

	while _tether_beam_roots.size() > expected_count:
		var old_root: Node2D = _tether_beam_roots.pop_back()
		if old_root != null and is_instance_valid(old_root):
			old_root.queue_free()

	while _tether_beam_sprites.size() > expected_count:
		_tether_beam_sprites.pop_back()

func _update_tether_visuals() -> void:
	var beam_count: int = mini(_tether_beam_roots.size(), _tether_beam_sprites.size())
	if tendril_level <= 0 or _tether_targets.is_empty():
		for i in range(beam_count):
			_set_beam_visible(i, false)
		return

	for i in range(beam_count):
		var target_node: Node2D = null
		if i < _tether_targets.size():
			target_node = _tether_targets[i]

		if target_node == null or not is_instance_valid(target_node):
			_set_beam_visible(i, false)
			continue

		var target_local: Vector2 = to_local(target_node.global_position)
		_update_beam_transform(i, target_local)

func _update_beam_transform(beam_index: int, target_local: Vector2) -> void:
	if beam_index < 0 or beam_index >= _tether_beam_roots.size():
		return
	var beam_root: Node2D = _tether_beam_roots[beam_index]
	var beam_sprite: AnimatedSprite2D = _tether_beam_sprites[beam_index]
	if beam_root == null or not is_instance_valid(beam_root):
		return
	if beam_sprite == null or not is_instance_valid(beam_sprite):
		return

	var total_distance: float = target_local.length()
	if total_distance <= 0.001:
		_set_beam_visible(beam_index, false)
		return

	var direction: Vector2 = target_local / total_distance
	var start_distance: float = maxf(0.0, tether_start_offset)
	var end_distance: float = maxf(0.0, tether_end_offset)
	var beam_length: float = total_distance - start_distance - end_distance
	if beam_length <= 2.0:
		_set_beam_visible(beam_index, false)
		return

	beam_root.position = direction * start_distance
	beam_root.rotation = direction.angle()
	_set_beam_visible(beam_index, true)

	if _has_valid_beam_template and not _tether_resolved_animation.is_empty():
		if beam_sprite.sprite_frames != null and beam_sprite.sprite_frames.has_animation(_tether_resolved_animation):
			beam_sprite.animation = _tether_resolved_animation
			if not beam_sprite.is_playing():
				beam_sprite.play(_tether_resolved_animation)

	var frame_width: float = maxf(1.0, _tether_frame_size.x)
	var frame_height: float = maxf(1.0, _tether_frame_size.y)
	beam_sprite.position = Vector2.ZERO
	beam_sprite.offset = Vector2(0.0, -frame_height * 0.5)
	var base_scale_x: float = maxf(0.01, _tether_template_scale.x)
	var base_scale_y: float = maxf(0.01, _tether_template_scale.y)
	beam_sprite.scale = Vector2(
		(beam_length / frame_width) * base_scale_x,
		maxf(0.05, tether_thickness_scale * base_scale_y)
	)
	beam_sprite.modulate = Color(1.0, 1.0, 1.0, clampf(tether_alpha, 0.0, 1.0))

func _set_beam_visible(beam_index: int, value: bool) -> void:
	if beam_index < 0 or beam_index >= _tether_beam_roots.size():
		return
	var beam_root: Node2D = _tether_beam_roots[beam_index]
	if beam_root == null or not is_instance_valid(beam_root):
		return
	beam_root.visible = value
	if beam_index >= _tether_beam_sprites.size():
		return
	var beam_sprite: AnimatedSprite2D = _tether_beam_sprites[beam_index]
	if beam_sprite == null or not is_instance_valid(beam_sprite):
		return
	beam_sprite.visible = value

func _setup_beam_template() -> void:
	_has_valid_beam_template = false
	_tether_resolved_animation = StringName()
	_tether_frame_size = Vector2(96.0, 96.0)
	_tether_template_scale = Vector2.ONE

	if beam_template == null:
		push_error("LeechTendril requires an AnimatedSprite2D child named BeamTemplate.")
		return
	beam_template.visible = false
	_tether_template_scale = beam_template.scale

	if beam_template.sprite_frames == null:
		push_error("LeechTendril BeamTemplate requires authored SpriteFrames.")
		return

	var animation_name: StringName = tether_template_animation
	if animation_name.is_empty() or not beam_template.sprite_frames.has_animation(animation_name):
		var animation_names: PackedStringArray = beam_template.sprite_frames.get_animation_names()
		if animation_names.is_empty():
			push_error("LeechTendril BeamTemplate has no animations.")
			return
		animation_name = StringName(animation_names[0])

	_tether_resolved_animation = animation_name
	if beam_template.sprite_frames.get_frame_count(_tether_resolved_animation) > 0:
		var first_frame_texture: Texture2D = beam_template.sprite_frames.get_frame_texture(_tether_resolved_animation, 0)
		if first_frame_texture != null:
			var frame_size: Vector2 = first_frame_texture.get_size()
			if frame_size.x > 1.0 and frame_size.y > 1.0:
				_tether_frame_size = frame_size
	_has_valid_beam_template = true

func _create_runtime_beam_sprite() -> AnimatedSprite2D:
	var beam_sprite: AnimatedSprite2D
	if beam_template != null:
		beam_sprite = beam_template.duplicate() as AnimatedSprite2D
	if beam_sprite == null:
		beam_sprite = AnimatedSprite2D.new()
	beam_sprite.visible = false
	beam_sprite.centered = false
	beam_sprite.modulate = Color(1.0, 1.0, 1.0, clampf(tether_alpha, 0.0, 1.0))

	if _has_valid_beam_template and beam_sprite.sprite_frames != null:
		if beam_sprite.sprite_frames.has_animation(_tether_resolved_animation):
			beam_sprite.animation = _tether_resolved_animation
			beam_sprite.play(_tether_resolved_animation)
			return beam_sprite
	beam_sprite.stop()
	return beam_sprite

func _play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id, volume_db_offset, pitch_scale)

func _stop_drain_sfx_if_needed() -> void:
	if not _drain_sfx_should_be_active:
		return
	if audio_manager == null:
		_drain_sfx_should_be_active = false
		return
	if audio_manager.has_method("stop_sfx"):
		audio_manager.call("stop_sfx", "sfx_leech_tendril_loop")
	_drain_sfx_should_be_active = false

func _has_any_valid_tether_target() -> bool:
	for target_node in _tether_targets:
		if target_node == null:
			continue
		if not is_instance_valid(target_node):
			continue
		return true
	return false
