extends CharacterBody2D

signal died(world_position: Vector2)
signal died_detailed(world_position: Vector2, enemy_node: Node)

@export var move_speed: float = 90.0
@export var max_hp: int = 15
@export var contact_damage: int = 10
@export var dot_damage_multiplier: float = 0.90
@export var idle_animation_name: StringName = &"idle"
@export var move_animation_name: StringName = &"move"
@export var hit_animation_name: StringName = &"hit"
@export var orient_to_player: bool = true
@export var orientation_rotation_offset_degrees: float = 0.0
@export var visual_offset: Vector2 = Vector2.ZERO
@export var sprite_scale: Vector2 = Vector2.ONE
@export var sprite_modulate: Color = Color(1, 1, 1, 1)
@export var hit_flash_color: Color = Color(0.2, 0.2, 0.2, 1)
@export var hit_flash_duration: float = 0.10
@export var hit_punch_scale_multiplier: float = 1.2
@export var debug_log_damage: bool = false
@export var player_contact_cooldown_seconds: float = 0.20
@export var infection_tick_interval_seconds: float = 0.65
@export var conversion_visual_tint: Color = Color(0.42, 1.0, 0.82, 1.0)
@export var converted_damage_multiplier: float = 0.65
@export var converted_contact_cooldown_seconds: float = 0.30

var current_hp: int
var _player: Node2D
var _hit_flash_time_left: float = 0.0
var _base_sprite_modulate: Color = Color(1, 1, 1, 1)
var _base_sprite_scale: Vector2 = Vector2.ONE
var _is_playing_hit_animation: bool = false
var _is_elite: bool = false
var _is_converted_host: bool = false
var _conversion_time_left: float = 0.0
var _infection_time_left: float = 0.0
var _infection_stacks: int = 0
var _infection_tick_accumulator: float = 0.0
var _viral_mark_time_left: float = 0.0
var _viral_mark_damage_multiplier: float = 1.0
var _next_player_contact_time_seconds: float = 0.0
var _player_collision_exception_added: bool = false
var _next_converted_contact_time_by_target_id: Dictionary = {}
var _difficulty_speed_multiplier_applied: float = 1.0
var _difficulty_hp_multiplier_applied: float = 1.0
var _difficulty_damage_multiplier_applied: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies")
	add_to_group("hostile_enemies")
	_setup_animated_sprite()

func _draw() -> void:
	if not _is_elite:
		return

	var marker_radius: float = _get_elite_marker_radius()
	draw_circle(Vector2.ZERO, marker_radius + 6.0, Color(1.0, 0.85, 0.2, 0.13))
	draw_arc(Vector2.ZERO, marker_radius, 0.0, TAU, 52, Color(1.0, 0.95, 0.4, 0.95), 4.0, true)
	draw_arc(Vector2.ZERO, marker_radius + 5.0, 0.0, TAU, 52, Color(1.0, 0.45, 0.2, 0.9), 2.2, true)

	for i in range(4):
		var angle: float = PI * 0.25 + PI * 0.5 * float(i)
		var dir: Vector2 = Vector2.RIGHT.rotated(angle)
		draw_line(
			dir * (marker_radius + 3.0),
			dir * (marker_radius + 12.0),
			Color(1.0, 0.95, 0.4, 1.0),
			3.0
		)
	_draw_elite_health_bar(marker_radius)

func _physics_process(delta: float) -> void:
	_tick_status_effects(delta)

	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	_ensure_player_collision_exception()

	var movement_target: Node2D = _get_movement_target()
	if not is_instance_valid(movement_target):
		velocity = Vector2.ZERO
		move_and_slide()
		_update_animation_state(false)
		return

	var to_target := movement_target.global_position - global_position
	velocity = to_target.normalized() * move_speed
	move_and_slide()
	_update_visual_orientation(to_target)
	_apply_contact_damage()
	_update_hit_flash(delta)
	_update_animation_state(velocity.length() > 0.01)

func _apply_contact_damage() -> void:
	if not _is_converted_host:
		_try_damage_player_by_contact_range()
		return

	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider() as Node
		if collider == null:
			continue
		if not collider.is_in_group("hostile_enemies"):
			continue
		if collider == self:
			continue
		if not _can_hit_converted_target_now(collider):
			continue
		if collider.has_method("take_damage"):
			collider.call("take_damage", maxi(1, int(round(float(contact_damage) * converted_damage_multiplier))))

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	if current_hp <= 0:
		return

	var final_amount: int = amount
	if _viral_mark_time_left > 0.0:
		final_amount = maxi(1, int(round(float(amount) * _viral_mark_damage_multiplier)))

	current_hp = max(0, current_hp - final_amount)
	if _is_elite:
		queue_redraw()
	if current_hp > 0:
		_trigger_hit_flash()
		_trigger_hit_animation()
	if current_hp == 0:
		died.emit(global_position)
		died_detailed.emit(global_position, self)
		queue_free()

func _draw_elite_health_bar(marker_radius: float) -> void:
	if max_hp <= 0:
		return
	var hp_ratio: float = clampf(float(current_hp) / float(max_hp), 0.0, 1.0)
	var bar_width: float = maxf(52.0, marker_radius * 2.35)
	var bar_height: float = 8.0
	var bar_y: float = marker_radius + 18.0
	var bg_rect := Rect2(
		Vector2(-bar_width * 0.5, bar_y),
		Vector2(bar_width, bar_height)
	)
	draw_rect(bg_rect, Color(0.05, 0.07, 0.09, 0.88), true)
	draw_rect(bg_rect, Color(0.0, 0.0, 0.0, 0.9), false, 1.0, true)

	var fill_width: float = maxf(0.0, (bar_width - 2.0) * hp_ratio)
	if fill_width <= 0.0:
		return
	var fill_rect := Rect2(
		Vector2(bg_rect.position.x + 1.0, bg_rect.position.y + 1.0),
		Vector2(fill_width, bar_height - 2.0)
	)
	draw_rect(fill_rect, Color(0.97, 0.24, 0.24, 0.95), true)

func take_dot_damage(amount: int) -> void:
	if amount <= 0:
		return
	var scaled_amount: int = maxi(1, int(round(float(amount) * clampf(dot_damage_multiplier, 0.1, 3.0))))
	take_damage(scaled_amount)

func apply_infection(duration_seconds: float = 2.6, stack_count: int = 1) -> void:
	if duration_seconds <= 0.0:
		return
	_infection_time_left = maxf(_infection_time_left, duration_seconds)
	_infection_stacks = clampi(_infection_stacks + maxi(1, stack_count), 1, 6)

func is_infected() -> bool:
	return _infection_time_left > 0.0

func get_infection_stacks() -> int:
	return _infection_stacks

func apply_viral_mark(duration_seconds: float, damage_multiplier: float = 1.2) -> void:
	_viral_mark_time_left = maxf(_viral_mark_time_left, duration_seconds)
	_viral_mark_damage_multiplier = maxf(1.0, damage_multiplier)

func convert_to_host_ally(duration_seconds: float) -> bool:
	if duration_seconds <= 0.0:
		return false
	if _is_elite:
		return false
	if _is_converted_host:
		_conversion_time_left = maxf(_conversion_time_left, duration_seconds)
		return true
	_is_converted_host = true
	_conversion_time_left = duration_seconds
	if is_in_group("enemies"):
		remove_from_group("enemies")
	if is_in_group("hostile_enemies"):
		remove_from_group("hostile_enemies")
	if is_in_group("elite_enemies"):
		remove_from_group("elite_enemies")
	add_to_group("allied_hosts")
	if animated_sprite != null:
		animated_sprite.modulate = conversion_visual_tint
	return true

func is_converted_host() -> bool:
	return _is_converted_host

func is_elite_enemy() -> bool:
	return _is_elite

func get_current_hp() -> int:
	return current_hp

func get_max_hp() -> int:
	return max_hp

func apply_spawn_scaling(speed_multiplier: float, hp_multiplier: float, damage_multiplier: float) -> void:
	var safe_speed_multiplier: float = maxf(0.1, speed_multiplier)
	var safe_hp_multiplier: float = maxf(0.1, hp_multiplier)
	var safe_damage_multiplier: float = maxf(0.1, damage_multiplier)
	move_speed = maxf(1.0, move_speed * safe_speed_multiplier)
	max_hp = maxi(1, int(round(float(max_hp) * safe_hp_multiplier)))
	current_hp = max_hp
	contact_damage = maxi(1, int(round(float(contact_damage) * safe_damage_multiplier)))

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

	_difficulty_speed_multiplier_applied = safe_speed_multiplier
	_difficulty_hp_multiplier_applied = safe_hp_multiplier
	_difficulty_damage_multiplier_applied = safe_damage_multiplier

func apply_elite_profile(
	speed_multiplier: float,
	hp_multiplier: float,
	damage_multiplier: float,
	scale_multiplier: float,
	elite_modulate: Color
) -> void:
	var safe_speed_multiplier: float = maxf(0.1, speed_multiplier)
	var safe_hp_multiplier: float = maxf(0.1, hp_multiplier)
	var safe_damage_multiplier: float = maxf(0.1, damage_multiplier)
	var safe_scale_multiplier: float = maxf(0.1, scale_multiplier)

	move_speed = maxf(1.0, move_speed * safe_speed_multiplier)
	max_hp = maxi(1, int(round(float(max_hp) * safe_hp_multiplier)))
	current_hp = max_hp
	contact_damage = maxi(1, int(round(float(contact_damage) * safe_damage_multiplier)))
	scale *= safe_scale_multiplier

	sprite_modulate = elite_modulate
	_base_sprite_modulate = sprite_modulate
	_is_elite = true
	if not is_in_group("elite_enemies"):
		add_to_group("elite_enemies")
	z_index = max(z_index, 5)
	if animated_sprite != null:
		animated_sprite.modulate = _base_sprite_modulate
	queue_redraw()

func _get_elite_marker_radius() -> float:
	var marker_radius: float = 24.0
	if collision_shape == null:
		return marker_radius
	var circle_shape := collision_shape.shape as CircleShape2D
	if circle_shape != null:
		marker_radius = maxf(marker_radius, circle_shape.radius + 9.0)
	return marker_radius

func _trigger_hit_flash() -> void:
	if animated_sprite == null:
		return
	_hit_flash_time_left = maxf(hit_flash_duration, 0.01)
	animated_sprite.modulate = hit_flash_color
	animated_sprite.scale = _base_sprite_scale * maxf(1.0, hit_punch_scale_multiplier)

func _update_hit_flash(delta: float) -> void:
	if _hit_flash_time_left <= 0.0:
		return
	_hit_flash_time_left = maxf(0.0, _hit_flash_time_left - delta)
	if _hit_flash_time_left <= 0.0 and animated_sprite != null:
		animated_sprite.modulate = conversion_visual_tint if _is_converted_host else _base_sprite_modulate
		animated_sprite.scale = _base_sprite_scale

func _setup_animated_sprite() -> void:
	if animated_sprite == null:
		push_error("EnemyBasic requires an AnimatedSprite2D child node named AnimatedSprite2D.")
		return
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	animated_sprite.position += visual_offset
	_base_sprite_scale = Vector2(animated_sprite.scale.x * sprite_scale.x, animated_sprite.scale.y * sprite_scale.y)
	animated_sprite.scale = _base_sprite_scale
	_base_sprite_modulate = sprite_modulate
	animated_sprite.modulate = _base_sprite_modulate
	if animated_sprite.sprite_frames == null:
		push_error("EnemyBasic AnimatedSprite2D requires authored SpriteFrames (no auto generation).")
		return
	if not animated_sprite.animation_finished.is_connected(Callable(self, "_on_animated_sprite_animation_finished")):
		animated_sprite.animation_finished.connect(Callable(self, "_on_animated_sprite_animation_finished"))
	_play_base_animation(false)

func _update_visual_orientation(to_player: Vector2) -> void:
	if animated_sprite == null:
		return
	if not orient_to_player:
		return
	if to_player.length_squared() <= 0.0001:
		return

	var base_angle: float = to_player.angle()
	var offset_radians: float = deg_to_rad(orientation_rotation_offset_degrees)
	animated_sprite.rotation = base_angle + offset_radians

func _trigger_hit_animation() -> void:
	if animated_sprite == null:
		return
	if not _has_animation(hit_animation_name):
		return
	_is_playing_hit_animation = true
	animated_sprite.play(hit_animation_name)

func _update_animation_state(is_moving: bool) -> void:
	if animated_sprite == null:
		return
	if _is_playing_hit_animation:
		return
	_play_base_animation(is_moving)

func _play_base_animation(is_moving: bool) -> void:
	if animated_sprite == null:
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
	if animated_sprite.animation != hit_animation_name:
		return
	_is_playing_hit_animation = false
	_play_base_animation(velocity.length() > 0.01)

func _tick_status_effects(delta: float) -> void:
	if _viral_mark_time_left > 0.0:
		_viral_mark_time_left = maxf(0.0, _viral_mark_time_left - delta)
	if _infection_time_left > 0.0:
		_infection_time_left = maxf(0.0, _infection_time_left - delta)
		_infection_tick_accumulator += delta
		var tick_interval: float = maxf(0.10, infection_tick_interval_seconds)
		while _infection_tick_accumulator >= tick_interval:
			_infection_tick_accumulator -= tick_interval
			take_dot_damage(maxi(1, _infection_stacks))
	else:
		_infection_stacks = 0
		_infection_tick_accumulator = 0.0

	if _is_converted_host:
		_conversion_time_left = maxf(0.0, _conversion_time_left - delta)
		if _conversion_time_left <= 0.0:
			queue_free()

func _get_movement_target() -> Node2D:
	if _is_converted_host:
		return _find_nearest_hostile_enemy()
	return _player

func _find_nearest_hostile_enemy() -> Node2D:
	var nearest_enemy: Node2D
	var nearest_distance_sq: float = INF
	for enemy_variant in get_tree().get_nodes_in_group("hostile_enemies"):
		var enemy_node := enemy_variant as Node2D
		if enemy_node == null:
			continue
		if enemy_node == self:
			continue
		var distance_sq: float = global_position.distance_squared_to(enemy_node.global_position)
		if distance_sq < nearest_distance_sq:
			nearest_distance_sq = distance_sq
			nearest_enemy = enemy_node
	return nearest_enemy

func _ensure_player_collision_exception() -> void:
	if _player_collision_exception_added:
		return
	if not is_instance_valid(_player):
		return
	add_collision_exception_with(_player)
	_player_collision_exception_added = true

func _try_damage_player_by_contact_range() -> void:
	if not is_instance_valid(_player):
		return
	var now_seconds: float = float(Time.get_ticks_usec()) / 1000000.0
	if now_seconds < _next_player_contact_time_seconds:
		return
	if not _player.has_method("take_damage"):
		return
	if not _player.is_in_group("player"):
		return

	var contact_distance: float = _get_contact_radius() + _get_player_contact_radius()
	var distance_sq: float = global_position.distance_squared_to(_player.global_position)
	if distance_sq > contact_distance * contact_distance:
		return

	if debug_log_damage:
		print("Enemy hit player for ", contact_damage)
	_player.call("take_damage", contact_damage)
	_next_player_contact_time_seconds = now_seconds + maxf(0.05, player_contact_cooldown_seconds)

func _can_hit_converted_target_now(target: Node) -> bool:
	if target == null:
		return false
	var target_id: int = target.get_instance_id()
	var now_seconds: float = float(Time.get_ticks_usec()) / 1000000.0
	var next_allowed_seconds: float = float(_next_converted_contact_time_by_target_id.get(target_id, 0.0))
	if now_seconds < next_allowed_seconds:
		return false
	_next_converted_contact_time_by_target_id[target_id] = now_seconds + maxf(0.05, converted_contact_cooldown_seconds)
	return true

func _get_contact_radius() -> float:
	if collision_shape == null:
		return 12.0
	var circle_shape := collision_shape.shape as CircleShape2D
	if circle_shape != null:
		return maxf(1.0, circle_shape.radius)
	return 12.0

func _get_player_contact_radius() -> float:
	if not is_instance_valid(_player):
		return 12.0
	var player_visual_radius_variant: Variant = _player.get("visual_radius")
	if player_visual_radius_variant != null:
		return maxf(1.0, float(player_visual_radius_variant))
	return 12.0
