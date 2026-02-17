extends CharacterBody2D

signal died(world_position: Vector2)

@export var move_speed: float = 90.0
@export var max_hp: int = 15
@export var contact_damage: int = 10
@export var idle_animation_name: StringName = &"idle"
@export var move_animation_name: StringName = &"move"
@export var hit_animation_name: StringName = &"hit"
@export var orient_to_player: bool = true
@export var orientation_rotation_offset_degrees: float = 0.0
@export var visual_offset: Vector2 = Vector2.ZERO
@export var sprite_scale: Vector2 = Vector2(0.15, 0.15)
@export var sprite_modulate: Color = Color(1, 1, 1, 1)
@export var hit_flash_color: Color = Color(0.2, 0.2, 0.2, 1)
@export var hit_flash_duration: float = 0.10
@export var hit_punch_scale_multiplier: float = 1.2
@export var debug_log_damage: bool = false

var current_hp: int
var _player: Node2D
var _hit_flash_time_left: float = 0.0
var _base_sprite_modulate: Color = Color(1, 1, 1, 1)
var _base_sprite_scale: Vector2 = Vector2.ONE
var _is_playing_hit_animation: bool = false
var _is_elite: bool = false

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies")
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

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D

	if not is_instance_valid(_player):
		velocity = Vector2.ZERO
		move_and_slide()
		_update_animation_state(false)
		return

	var to_player := _player.global_position - global_position
	velocity = to_player.normalized() * move_speed
	move_and_slide()
	_update_visual_orientation(to_player)
	_apply_contact_damage()
	_update_hit_flash(delta)
	_update_animation_state(velocity.length() > 0.01)

func _apply_contact_damage() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider() as Node
		if collider == null:
			continue
		if not collider.is_in_group("player"):
			continue
		if collider.has_method("take_damage"):
			if debug_log_damage:
				print("Enemy hit player for ", contact_damage)
			collider.call("take_damage", contact_damage)

func take_damage(amount: int) -> void:
	if amount <= 0:
		return

	current_hp = max(0, current_hp - amount)
	if current_hp > 0:
		_trigger_hit_flash()
		_trigger_hit_animation()
	if current_hp == 0:
		died.emit(global_position)
		queue_free()

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
		animated_sprite.modulate = _base_sprite_modulate
		animated_sprite.scale = _base_sprite_scale

func _setup_animated_sprite() -> void:
	if animated_sprite == null:
		push_error("EnemyBasic requires an AnimatedSprite2D child node named AnimatedSprite2D.")
		return
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	animated_sprite.position = visual_offset
	_base_sprite_scale = sprite_scale
	animated_sprite.scale = _base_sprite_scale
	_base_sprite_modulate = sprite_modulate
	animated_sprite.modulate = _base_sprite_modulate
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
