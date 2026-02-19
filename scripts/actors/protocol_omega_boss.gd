extends CharacterBody2D

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/actors/enemy_projectile.tscn")
const TELEGRAPH_SCENE: PackedScene = preload("res://scenes/systems/omega_telegraph.tscn")
const ENEMY_BASIC_SCENE: PackedScene = preload("res://scenes/actors/enemy_basic.tscn")
const ENEMY_DASHER_SCENE: PackedScene = preload("res://scenes/actors/enemy_dasher.tscn")

signal defeated(world_position: Vector2, boss_node: Node)
signal health_changed(current_hp: int, max_hp: int)
signal phase_changed(new_phase: int)

@export var max_hp: int = 2400
@export var move_speed: float = 72.0
@export var contact_damage: int = 26
@export var contact_cooldown_seconds: float = 0.30
@export var preferred_range: float = 220.0
@export var retreat_range: float = 145.0
@export var strafe_speed_multiplier: float = 0.82
@export var orient_to_player: bool = true
@export var orientation_rotation_offset_degrees: float = -90.0
@export var idle_animation_name: StringName = &"idle"
@export var move_animation_name: StringName = &"move"
@export var cast_animation_name: StringName = &"cast"
@export var hit_animation_name: StringName = &"hit"
@export var death_animation_name: StringName = &"death"
@export var hit_flash_color: Color = Color(1.0, 0.82, 0.64, 1.0)
@export var hit_flash_duration_seconds: float = 0.10
@export var phase_2_threshold_ratio: float = 0.70
@export var phase_3_threshold_ratio: float = 0.35
@export var phase_shift_lock_seconds: float = 0.65
@export var projectile_damage: int = 14
@export var projectile_speed: float = 460.0
@export var projectile_life_seconds: float = 2.6
@export var projectile_hit_radius: float = 10.0
@export var projectile_spawn_distance: float = 52.0
@export var radial_burst_radius: float = 150.0
@export var radial_burst_telegraph_seconds: float = 0.62
@export var radial_burst_interval_phase_1: float = 4.4
@export var radial_burst_interval_phase_2: float = 3.5
@export var radial_burst_interval_phase_3: float = 2.7
@export var radial_projectile_count_phase_1: int = 12
@export var radial_projectile_count_phase_2: int = 16
@export var radial_projectile_count_phase_3: int = 20
@export var targeted_blast_radius: float = 94.0
@export var targeted_blast_telegraph_seconds: float = 0.70
@export var targeted_blast_interval_phase_1: float = 5.6
@export var targeted_blast_interval_phase_2: float = 4.6
@export var targeted_blast_interval_phase_3: float = 3.7
@export var targeted_blast_damage_phase_1: int = 20
@export var targeted_blast_damage_phase_2: int = 28
@export var targeted_blast_damage_phase_3: int = 36
@export var targeted_blast_projectile_count_phase_1: int = 6
@export var targeted_blast_projectile_count_phase_2: int = 8
@export var targeted_blast_projectile_count_phase_3: int = 10
@export var summon_telegraph_radius: float = 120.0
@export var summon_telegraph_seconds: float = 0.58
@export var summon_interval_phase_2: float = 13.5
@export var summon_interval_phase_3: float = 10.0
@export var summon_count_phase_2: int = 2
@export var summon_count_phase_3: int = 3
@export var summon_spawn_radius_min: float = 110.0
@export var summon_spawn_radius_max: float = 240.0
@export var summon_support_speed_multiplier: float = 1.22
@export var summon_support_hp_multiplier: float = 1.45
@export var summon_support_damage_multiplier: float = 1.22
@export var telegraph_fill_color: Color = Color(1.0, 0.24, 0.16, 0.20)
@export var telegraph_outline_color: Color = Color(1.0, 0.74, 0.34, 0.98)
@export var bounds_padding: float = 56.0
@export var debug_log_boss: bool = false

var current_hp: int = 0
var _phase: int = 1
var _player: Node2D
var _arena_bounds: Rect2 = Rect2(Vector2(-4096.0, -4096.0), Vector2(8192.0, 8192.0))
var _has_arena_bounds: bool = false
var _radial_timer_seconds: float = 0.0
var _targeted_timer_seconds: float = 0.0
var _summon_timer_seconds: float = 0.0
var _phase_lock_time_left: float = 0.0
var _next_contact_time_seconds: float = 0.0
var _strafe_sign: float = 1.0
var _strafe_switch_time_left: float = 0.0
var _pending_attacks: Array[Dictionary] = []
var _is_dying: bool = false
var _is_playing_hit_animation: bool = false
var _is_casting_animation: bool = false
var _cast_animation_timeout_left: float = 0.0
var _hit_flash_time_left: float = 0.0
var _base_sprite_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
var _difficulty_speed_multiplier_applied: float = 1.0
var _difficulty_hp_multiplier_applied: float = 1.0
var _difficulty_damage_multiplier_applied: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")

func _ready() -> void:
	current_hp = maxi(1, max_hp)
	add_to_group("enemies")
	add_to_group("hostile_enemies")
	add_to_group("boss_enemies")
	add_to_group("crisis_runtime_nodes")
	_strafe_sign = -1.0 if randf() < 0.5 else 1.0
	_strafe_switch_time_left = randf_range(0.65, 1.45)
	_reset_attack_timers(true)
	_setup_animated_sprite()
	_emit_health_changed()
	set_physics_process(true)

func initialize_for_final_event(player_node: Node2D, arena_bounds: Rect2) -> void:
	if player_node != null and is_instance_valid(player_node):
		_player = player_node
	if arena_bounds.size.x > 1.0 and arena_bounds.size.y > 1.0:
		_arena_bounds = arena_bounds
		_has_arena_bounds = true

func get_current_hp() -> int:
	return current_hp

func get_max_hp() -> int:
	return max_hp

func get_phase() -> int:
	return _phase

func apply_difficulty_multipliers(speed_multiplier: float, hp_multiplier: float, damage_multiplier: float) -> void:
	var safe_speed_multiplier: float = maxf(0.1, speed_multiplier)
	var safe_hp_multiplier: float = maxf(0.1, hp_multiplier)
	var safe_damage_multiplier: float = maxf(0.1, damage_multiplier)

	var speed_ratio: float = safe_speed_multiplier / maxf(0.1, _difficulty_speed_multiplier_applied)
	var hp_ratio_scale: float = safe_hp_multiplier / maxf(0.1, _difficulty_hp_multiplier_applied)
	var damage_ratio: float = safe_damage_multiplier / maxf(0.1, _difficulty_damage_multiplier_applied)

	var hp_ratio: float = 1.0
	if max_hp > 0 and current_hp > 0:
		hp_ratio = clampf(float(current_hp) / float(max_hp), 0.0, 1.0)

	move_speed = maxf(1.0, move_speed * speed_ratio)
	max_hp = maxi(1, int(round(float(max_hp) * hp_ratio_scale)))
	current_hp = maxi(1, int(round(float(max_hp) * hp_ratio)))
	contact_damage = maxi(1, int(round(float(contact_damage) * damage_ratio)))
	projectile_damage = maxi(1, int(round(float(projectile_damage) * damage_ratio)))
	targeted_blast_damage_phase_1 = maxi(1, int(round(float(targeted_blast_damage_phase_1) * damage_ratio)))
	targeted_blast_damage_phase_2 = maxi(1, int(round(float(targeted_blast_damage_phase_2) * damage_ratio)))
	targeted_blast_damage_phase_3 = maxi(1, int(round(float(targeted_blast_damage_phase_3) * damage_ratio)))

	_difficulty_speed_multiplier_applied = safe_speed_multiplier
	_difficulty_hp_multiplier_applied = safe_hp_multiplier
	_difficulty_damage_multiplier_applied = safe_damage_multiplier
	_emit_health_changed()

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	if _is_dying:
		return
	if current_hp <= 0:
		return

	current_hp = maxi(0, current_hp - amount)
	_emit_health_changed()
	_trigger_hit_flash()
	_trigger_hit_animation()
	_try_advance_phase()

	if current_hp > 0:
		return
	_begin_defeat()

func _physics_process(delta: float) -> void:
	if _is_dying:
		return
	_tick_pending_attacks(delta)
	_tick_cast_animation_timeout(delta)
	_update_hit_flash(delta)

	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(_player):
		velocity = Vector2.ZERO
		move_and_slide()
		_update_animation_state(false)
		return

	if _phase_lock_time_left > 0.0:
		_phase_lock_time_left = maxf(0.0, _phase_lock_time_left - delta)
		velocity = Vector2.ZERO
		move_and_slide()
		_update_animation_state(false)
		return

	var to_player: Vector2 = _player.global_position - global_position
	velocity = _compute_movement_velocity(to_player, delta)
	move_and_slide()
	_clamp_to_arena_bounds()
	_update_visual_orientation(to_player)
	_try_contact_damage()
	_tick_attack_timers(delta)
	_update_animation_state(velocity.length() > 0.05)

func _compute_movement_velocity(to_player: Vector2, delta: float) -> Vector2:
	var distance_to_player: float = to_player.length()
	if distance_to_player <= 0.001:
		return Vector2.ZERO

	var to_player_direction: Vector2 = to_player / distance_to_player
	var safe_preferred_range: float = maxf(8.0, preferred_range)
	var safe_retreat_range: float = minf(safe_preferred_range - 10.0, retreat_range)

	if distance_to_player > safe_preferred_range:
		return to_player_direction * move_speed
	if distance_to_player < safe_retreat_range:
		return -to_player_direction * move_speed

	_strafe_switch_time_left = maxf(0.0, _strafe_switch_time_left - delta)
	if _strafe_switch_time_left <= 0.0:
		_strafe_sign *= -1.0
		_strafe_switch_time_left = randf_range(0.55, 1.25)
	var strafe_direction: Vector2 = Vector2(-to_player_direction.y, to_player_direction.x) * _strafe_sign
	var phase_speed_boost: float = 1.0 + (float(_phase - 1) * 0.06)
	return strafe_direction * (move_speed * strafe_speed_multiplier * phase_speed_boost)

func _tick_attack_timers(delta: float) -> void:
	_radial_timer_seconds = maxf(0.0, _radial_timer_seconds - delta)
	_targeted_timer_seconds = maxf(0.0, _targeted_timer_seconds - delta)
	_summon_timer_seconds = maxf(0.0, _summon_timer_seconds - delta)

	if _radial_timer_seconds <= 0.0:
		_queue_radial_burst()
		_radial_timer_seconds = _get_radial_interval_seconds_for_phase()

	if _targeted_timer_seconds <= 0.0:
		_queue_targeted_blast()
		_targeted_timer_seconds = _get_targeted_interval_seconds_for_phase()

	if _phase >= 2 and _summon_timer_seconds <= 0.0:
		_queue_support_summon()
		_summon_timer_seconds = _get_summon_interval_seconds_for_phase()

func _tick_pending_attacks(delta: float) -> void:
	for index in range(_pending_attacks.size() - 1, -1, -1):
		var pending_entry: Dictionary = _pending_attacks[index]
		var time_left: float = float(pending_entry.get("time_left", 0.0))
		time_left = maxf(0.0, time_left - delta)
		if time_left > 0.0:
			pending_entry["time_left"] = time_left
			_pending_attacks[index] = pending_entry
			continue

		var attack_kind: String = String(pending_entry.get("kind", ""))
		match attack_kind:
			"radial_burst":
				var origin_position: Vector2 = global_position
				var origin_variant: Variant = pending_entry.get("origin", global_position)
				if origin_variant is Vector2:
					origin_position = origin_variant
				_execute_radial_burst(origin_position)
			"targeted_blast":
				var impact_position: Vector2 = global_position
				var impact_variant: Variant = pending_entry.get("impact_position", global_position)
				if impact_variant is Vector2:
					impact_position = impact_variant
				var impact_radius: float = float(pending_entry.get("impact_radius", targeted_blast_radius))
				var impact_damage: int = int(pending_entry.get("impact_damage", targeted_blast_damage_phase_1))
				_execute_targeted_blast(impact_position, impact_radius, impact_damage)
			"support_summon":
				var summon_origin: Vector2 = global_position
				var summon_origin_variant: Variant = pending_entry.get("summon_origin", global_position)
				if summon_origin_variant is Vector2:
					summon_origin = summon_origin_variant
				var summon_count: int = int(pending_entry.get("summon_count", 1))
				_execute_support_summon(summon_origin, summon_count)
			_:
				pass
		_pending_attacks.remove_at(index)

func _queue_radial_burst() -> void:
	var cast_position: Vector2 = global_position
	_spawn_telegraph(cast_position, radial_burst_radius, radial_burst_telegraph_seconds)
	_pending_attacks.append({
		"kind": "radial_burst",
		"time_left": radial_burst_telegraph_seconds,
		"origin": cast_position
	})
	_start_cast_animation(radial_burst_telegraph_seconds)
	if debug_log_boss:
		print("[ProtocolOmegaBoss] Queued radial burst")

func _queue_targeted_blast() -> void:
	var projected_position: Vector2 = _predict_player_position(0.38 + float(_phase - 1) * 0.08)
	_spawn_telegraph(projected_position, targeted_blast_radius, targeted_blast_telegraph_seconds)
	_pending_attacks.append({
		"kind": "targeted_blast",
		"time_left": targeted_blast_telegraph_seconds,
		"impact_position": projected_position,
		"impact_radius": targeted_blast_radius,
		"impact_damage": _get_targeted_damage_for_phase()
	})
	_start_cast_animation(targeted_blast_telegraph_seconds)
	if debug_log_boss:
		print("[ProtocolOmegaBoss] Queued targeted blast at ", projected_position)

func _queue_support_summon() -> void:
	var summon_count: int = _get_support_summon_count_for_phase()
	_spawn_telegraph(global_position, summon_telegraph_radius, summon_telegraph_seconds)
	_pending_attacks.append({
		"kind": "support_summon",
		"time_left": summon_telegraph_seconds,
		"summon_origin": global_position,
		"summon_count": summon_count
	})
	_start_cast_animation(summon_telegraph_seconds)
	if debug_log_boss:
		print("[ProtocolOmegaBoss] Queued support summon (count=", summon_count, ")")

func _execute_radial_burst(origin_position: Vector2) -> void:
	var projectile_count: int = _get_radial_projectile_count_for_phase()
	if projectile_count <= 0:
		return
	for projectile_index in range(projectile_count):
		var ratio: float = float(projectile_index) / float(projectile_count)
		var base_angle: float = ratio * TAU
		var angle_jitter: float = randf_range(-0.035, 0.035)
		var direction: Vector2 = Vector2.RIGHT.rotated(base_angle + angle_jitter)
		_fire_projectile(origin_position, direction, projectile_damage + (_phase - 1) * 2)
	_play_sfx("sfx_boss_phase_shift", -8.0, randf_range(0.94, 1.02))

func _execute_targeted_blast(impact_position: Vector2, impact_radius: float, impact_damage: int) -> void:
	var player_node: Node = _player
	if player_node != null and player_node.has_method("take_damage"):
		var distance_to_player: float = impact_position.distance_to(_player.global_position)
		if distance_to_player <= impact_radius:
			player_node.call("take_damage", maxi(1, impact_damage))

	var projectile_count: int = _get_targeted_projectile_count_for_phase()
	var splash_projectile_damage: int = maxi(1, int(round(float(impact_damage) * 0.5)))
	if projectile_count > 0:
		for projectile_index in range(projectile_count):
			var ratio: float = float(projectile_index) / float(projectile_count)
			var angle: float = ratio * TAU
			var direction: Vector2 = Vector2.RIGHT.rotated(angle)
			_fire_projectile(impact_position, direction, splash_projectile_damage)
	_play_sfx("sfx_boss_phase_shift", -7.0, randf_range(1.0, 1.06))

func _execute_support_summon(summon_origin: Vector2, summon_count: int) -> void:
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		current_scene = self
	var safe_count: int = maxi(0, summon_count)
	if safe_count <= 0:
		return

	var min_radius: float = maxf(30.0, summon_spawn_radius_min)
	var max_radius: float = maxf(min_radius + 1.0, summon_spawn_radius_max)
	for summon_index in range(safe_count):
		var support_scene: PackedScene = ENEMY_BASIC_SCENE
		if _phase >= 3 and (summon_index % 2 == 1):
			support_scene = ENEMY_DASHER_SCENE
		var support_enemy := support_scene.instantiate() as Node2D
		if support_enemy == null:
			continue
		var spawn_angle: float = randf() * TAU
		var spawn_radius: float = randf_range(min_radius, max_radius)
		support_enemy.global_position = summon_origin + Vector2.RIGHT.rotated(spawn_angle) * spawn_radius
		current_scene.add_child(support_enemy)
		if support_enemy.has_method("apply_spawn_scaling"):
			support_enemy.call(
				"apply_spawn_scaling",
				summon_support_speed_multiplier,
				summon_support_hp_multiplier,
				summon_support_damage_multiplier
			)
	_play_sfx("sfx_boss_spawn", -7.0, randf_range(1.06, 1.14))

func _spawn_telegraph(center_position: Vector2, telegraph_radius: float, telegraph_duration: float) -> void:
	var telegraph_node := TELEGRAPH_SCENE.instantiate() as Node2D
	if telegraph_node == null:
		return
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		current_scene = self
	current_scene.add_child(telegraph_node)
	if telegraph_node.has_method("configure"):
		telegraph_node.call(
			"configure",
			center_position,
			maxf(2.0, telegraph_radius),
			maxf(0.02, telegraph_duration),
			telegraph_fill_color,
			telegraph_outline_color
		)
	else:
		telegraph_node.global_position = center_position

func _fire_projectile(origin_position: Vector2, direction: Vector2, damage_value: int) -> void:
	var safe_direction: Vector2 = direction.normalized()
	if safe_direction.length_squared() <= 0.0001:
		safe_direction = Vector2.RIGHT

	var projectile := PROJECTILE_SCENE.instantiate() as Area2D
	if projectile == null:
		return
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		current_scene = self
	current_scene.add_child(projectile)
	projectile.global_position = origin_position + safe_direction * projectile_spawn_distance
	projectile.set("move_speed", maxf(40.0, projectile_speed))
	projectile.set("life_seconds", maxf(0.08, projectile_life_seconds))
	projectile.set("hit_radius", maxf(1.0, projectile_hit_radius))
	if projectile.has_method("setup"):
		projectile.call("setup", safe_direction, maxi(1, damage_value), true)

func _predict_player_position(lead_seconds: float) -> Vector2:
	if not is_instance_valid(_player):
		return global_position
	var predicted_position: Vector2 = _player.global_position
	var velocity_variant: Variant = _player.get("velocity")
	if velocity_variant is Vector2:
		var player_velocity: Vector2 = velocity_variant
		predicted_position += player_velocity * maxf(0.0, lead_seconds)
	return _clamp_point_to_arena(predicted_position)

func _try_contact_damage() -> void:
	if not is_instance_valid(_player):
		return
	if not _player.has_method("take_damage"):
		return
	var now_seconds: float = float(Time.get_ticks_usec()) / 1000000.0
	if now_seconds < _next_contact_time_seconds:
		return

	var contact_radius: float = _get_collision_radius() + _get_player_collision_radius()
	var distance_sq: float = global_position.distance_squared_to(_player.global_position)
	if distance_sq > contact_radius * contact_radius:
		return

	_player.call("take_damage", maxi(1, contact_damage))
	_next_contact_time_seconds = now_seconds + maxf(0.05, contact_cooldown_seconds)

func _get_collision_radius() -> float:
	if collision_shape == null:
		return 24.0
	var circle_shape := collision_shape.shape as CircleShape2D
	if circle_shape == null:
		return 24.0
	return maxf(4.0, circle_shape.radius)

func _get_player_collision_radius() -> float:
	if not is_instance_valid(_player):
		return 12.0
	var player_collision_shape: CollisionShape2D = _player.get_node_or_null("CollisionShape2D")
	if player_collision_shape == null:
		return 12.0
	var player_circle_shape := player_collision_shape.shape as CircleShape2D
	if player_circle_shape == null:
		return 12.0
	return maxf(2.0, player_circle_shape.radius)

func _clamp_to_arena_bounds() -> void:
	if not _has_arena_bounds:
		return
	global_position = _clamp_point_to_arena(global_position)

func _clamp_point_to_arena(target_point: Vector2) -> Vector2:
	if not _has_arena_bounds:
		return target_point
	var safe_padding: float = maxf(0.0, bounds_padding)
	var min_x: float = _arena_bounds.position.x + safe_padding
	var max_x: float = _arena_bounds.position.x + _arena_bounds.size.x - safe_padding
	var min_y: float = _arena_bounds.position.y + safe_padding
	var max_y: float = _arena_bounds.position.y + _arena_bounds.size.y - safe_padding
	return Vector2(
		clampf(target_point.x, min_x, max_x),
		clampf(target_point.y, min_y, max_y)
	)

func _setup_animated_sprite() -> void:
	if animated_sprite == null:
		push_warning("ProtocolOmegaBoss requires AnimatedSprite2D child named AnimatedSprite2D.")
		return
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_base_sprite_modulate = animated_sprite.modulate
	if animated_sprite.sprite_frames == null:
		push_warning("ProtocolOmegaBoss AnimatedSprite2D has no SpriteFrames yet.")
		return
	_play_base_animation(false)
	if not animated_sprite.animation_finished.is_connected(Callable(self, "_on_animated_sprite_animation_finished")):
		animated_sprite.animation_finished.connect(Callable(self, "_on_animated_sprite_animation_finished"))

func _update_visual_orientation(to_player: Vector2) -> void:
	if animated_sprite == null:
		return
	if not orient_to_player:
		return
	if to_player.length_squared() <= 0.0001:
		return
	var angle_to_player: float = to_player.angle()
	var offset_radians: float = deg_to_rad(orientation_rotation_offset_degrees)
	animated_sprite.rotation = angle_to_player + offset_radians

func _start_cast_animation(lock_seconds: float) -> void:
	if animated_sprite == null:
		return
	if not _has_animation(cast_animation_name):
		return
	_is_casting_animation = true
	_cast_animation_timeout_left = maxf(_cast_animation_timeout_left, maxf(0.05, lock_seconds))
	animated_sprite.play(cast_animation_name)
	_phase_lock_time_left = maxf(_phase_lock_time_left, lock_seconds)

func _trigger_hit_animation() -> void:
	if animated_sprite == null:
		return
	if _is_casting_animation:
		return
	if not _has_animation(hit_animation_name):
		return
	_is_playing_hit_animation = true
	animated_sprite.play(hit_animation_name)

func _trigger_hit_flash() -> void:
	if animated_sprite == null:
		return
	_hit_flash_time_left = maxf(0.02, hit_flash_duration_seconds)
	animated_sprite.modulate = hit_flash_color

func _update_hit_flash(delta: float) -> void:
	if animated_sprite == null:
		return
	if _hit_flash_time_left <= 0.0:
		return
	_hit_flash_time_left = maxf(0.0, _hit_flash_time_left - delta)
	if _hit_flash_time_left <= 0.0:
		animated_sprite.modulate = _base_sprite_modulate

func _update_animation_state(is_moving: bool) -> void:
	if animated_sprite == null:
		return
	if _is_playing_hit_animation or _is_casting_animation:
		return
	_play_base_animation(is_moving)

func _play_base_animation(is_moving: bool) -> void:
	if animated_sprite == null:
		return
	if animated_sprite.sprite_frames == null:
		return
	var target_animation: StringName = move_animation_name if is_moving else idle_animation_name
	if not _has_animation(target_animation):
		return
	if animated_sprite.animation == target_animation and animated_sprite.is_playing():
		return
	animated_sprite.play(target_animation)

func _has_animation(animation_name: StringName) -> bool:
	if animated_sprite == null:
		return false
	if animated_sprite.sprite_frames == null:
		return false
	return animated_sprite.sprite_frames.has_animation(animation_name)

func _on_animated_sprite_animation_finished() -> void:
	if animated_sprite == null:
		return
	var current_animation: StringName = animated_sprite.animation
	if current_animation == cast_animation_name:
		_is_casting_animation = false
		_cast_animation_timeout_left = 0.0
		_play_base_animation(velocity.length() > 0.01)
		return
	if current_animation == hit_animation_name:
		_is_playing_hit_animation = false
		_play_base_animation(velocity.length() > 0.01)
		return
	if current_animation == death_animation_name and _is_dying:
		_finalize_defeat()

func _begin_defeat() -> void:
	if _is_dying:
		return
	_is_dying = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	_pending_attacks.clear()
	_emit_health_changed()
	_play_sfx("sfx_enemy_elite_death", -2.0, 0.92)
	if animated_sprite != null and _has_animation(death_animation_name):
		animated_sprite.play(death_animation_name)
		var death_delay: float = _estimate_animation_duration(death_animation_name)
		var death_timer: SceneTreeTimer = get_tree().create_timer(maxf(0.15, death_delay))
		death_timer.timeout.connect(Callable(self, "_finalize_defeat"))
		return
	_finalize_defeat()

func _finalize_defeat() -> void:
	if not is_inside_tree():
		return
	defeated.emit(global_position, self)
	queue_free()

func _estimate_animation_duration(animation_name: StringName) -> float:
	if animated_sprite == null:
		return 0.45
	if animated_sprite.sprite_frames == null:
		return 0.45
	if not animated_sprite.sprite_frames.has_animation(animation_name):
		return 0.45
	var frame_count: int = animated_sprite.sprite_frames.get_frame_count(animation_name)
	var animation_speed: float = animated_sprite.sprite_frames.get_animation_speed(animation_name)
	if frame_count <= 0:
		return 0.45
	if animation_speed <= 0.01:
		animation_speed = 8.0
	return float(frame_count) / animation_speed

func _try_advance_phase() -> void:
	if max_hp <= 0:
		return
	var hp_ratio: float = float(current_hp) / float(max_hp)
	if _phase == 1 and hp_ratio <= clampf(phase_2_threshold_ratio, 0.05, 0.95):
		_set_phase(2)
		return
	if _phase == 2 and hp_ratio <= clampf(phase_3_threshold_ratio, 0.02, 0.90):
		_set_phase(3)
		return

func _set_phase(new_phase: int) -> void:
	var clamped_phase: int = clampi(new_phase, 1, 3)
	if clamped_phase <= _phase:
		return
	_phase = clamped_phase
	phase_changed.emit(_phase)
	_phase_lock_time_left = maxf(_phase_lock_time_left, maxf(0.0, phase_shift_lock_seconds))
	_reset_attack_timers(false)
	_play_sfx("sfx_boss_phase_shift", -4.0, randf_range(0.9, 1.0))
	if debug_log_boss:
		print("[ProtocolOmegaBoss] Entered phase ", _phase)

func _reset_attack_timers(use_random_stagger: bool) -> void:
	if use_random_stagger:
		_radial_timer_seconds = randf_range(1.3, 2.4)
		_targeted_timer_seconds = randf_range(2.0, 3.1)
		_summon_timer_seconds = randf_range(5.0, 7.0)
		return
	_radial_timer_seconds = minf(1.2, _get_radial_interval_seconds_for_phase() * 0.35)
	_targeted_timer_seconds = minf(1.8, _get_targeted_interval_seconds_for_phase() * 0.42)
	_summon_timer_seconds = minf(3.0, _get_summon_interval_seconds_for_phase() * 0.50)

func _get_radial_interval_seconds_for_phase() -> float:
	match _phase:
		2:
			return maxf(0.7, radial_burst_interval_phase_2)
		3:
			return maxf(0.5, radial_burst_interval_phase_3)
		_:
			return maxf(0.8, radial_burst_interval_phase_1)

func _get_targeted_interval_seconds_for_phase() -> float:
	match _phase:
		2:
			return maxf(0.7, targeted_blast_interval_phase_2)
		3:
			return maxf(0.5, targeted_blast_interval_phase_3)
		_:
			return maxf(0.8, targeted_blast_interval_phase_1)

func _get_summon_interval_seconds_for_phase() -> float:
	match _phase:
		3:
			return maxf(1.0, summon_interval_phase_3)
		2:
			return maxf(1.0, summon_interval_phase_2)
		_:
			return 9999.0

func _get_radial_projectile_count_for_phase() -> int:
	match _phase:
		2:
			return maxi(1, radial_projectile_count_phase_2)
		3:
			return maxi(1, radial_projectile_count_phase_3)
		_:
			return maxi(1, radial_projectile_count_phase_1)

func _get_targeted_damage_for_phase() -> int:
	match _phase:
		2:
			return maxi(1, targeted_blast_damage_phase_2)
		3:
			return maxi(1, targeted_blast_damage_phase_3)
		_:
			return maxi(1, targeted_blast_damage_phase_1)

func _get_targeted_projectile_count_for_phase() -> int:
	match _phase:
		2:
			return maxi(0, targeted_blast_projectile_count_phase_2)
		3:
			return maxi(0, targeted_blast_projectile_count_phase_3)
		_:
			return maxi(0, targeted_blast_projectile_count_phase_1)

func _get_support_summon_count_for_phase() -> int:
	match _phase:
		3:
			return maxi(1, summon_count_phase_3)
		2:
			return maxi(1, summon_count_phase_2)
		_:
			return 0

func _emit_health_changed() -> void:
	health_changed.emit(current_hp, max_hp)

func _play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id, volume_db_offset, pitch_scale)

func _tick_cast_animation_timeout(delta: float) -> void:
	if not _is_casting_animation:
		return
	_cast_animation_timeout_left = maxf(0.0, _cast_animation_timeout_left - delta)
	if _cast_animation_timeout_left > 0.0:
		return
	_is_casting_animation = false
	_play_base_animation(velocity.length() > 0.01)
