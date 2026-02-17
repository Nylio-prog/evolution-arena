extends CharacterBody2D

signal died(world_position: Vector2)

@export var move_speed: float = 60.0
@export var dash_speed: float = 220.0
@export var max_hp: int = 12
@export var contact_damage: int = 10
@export var visual_radius: float = 9.0
@export var idle_animation_name: StringName = &"idle"
@export var move_animation_name: StringName = &"move"
@export var windup_animation_name: StringName = &"windup"
@export var dash_animation_name: StringName = &"dash"
@export var hit_animation_name: StringName = &"hit"
@export var orient_to_player: bool = true
@export var orientation_rotation_offset_degrees: float = -4.0
@export var collision_rotates_with_facing: bool = true
@export var visual_offset: Vector2 = Vector2.ZERO
@export var sprite_scale: Vector2 = Vector2(0.14, 0.14)
@export var sprite_modulate: Color = Color(1, 1, 1, 1)
@export var hit_flash_color: Color = Color(0.7, 1, 1, 1)
@export var hit_flash_duration: float = 0.10
@export var hit_punch_scale_multiplier: float = 1.15
@export var dash_interval_seconds: float = 1.45
@export var dash_duration_seconds: float = 0.66
@export var dash_windup_seconds: float = 0.20
@export var windup_indicator_radius_offset: float = 9.0
@export var windup_indicator_line_width: float = 2.4
@export var debug_log_dash: bool = false

var current_hp: int
var _player: Node2D
var _dash_timer: float = 0.0
var _dash_time_left: float = 0.0
var _dash_windup_left: float = 0.0
var _dash_direction: Vector2 = Vector2.ZERO
var _hit_flash_time_left: float = 0.0
var _base_sprite_modulate: Color = Color(1, 1, 1, 1)
var _base_sprite_scale: Vector2 = Vector2.ONE
var _is_playing_hit_animation: bool = false
var _base_collision_shape_rotation: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies")
	_setup_animated_sprite()
	queue_redraw()

func _draw() -> void:
	if _dash_windup_left > 0.0:
		var indicator_radius: float = visual_radius + windup_indicator_radius_offset
		draw_arc(Vector2.ZERO, indicator_radius, 0.0, TAU, 36, Color(1.0, 0.8, 0.2, 1.0), windup_indicator_line_width, true)
		var windup_dir: Vector2 = _dash_direction
		if windup_dir.length_squared() > 0.001:
			draw_line(Vector2.ZERO, windup_dir * (indicator_radius + 5.0), Color(1.0, 0.85, 0.3, 1.0), 2.0)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D

	if not is_instance_valid(_player):
		velocity = Vector2.ZERO
		move_and_slide()
		_update_animation_state(false)
		return

	_update_dash_state(delta)
	move_and_slide()
	_apply_contact_damage()
	_update_hit_flash(delta)
	_update_animation_state(velocity.length() > 0.01)
	_update_visual_orientation(_get_facing_direction())
	queue_redraw()

func _update_dash_state(delta: float) -> void:
	if _dash_windup_left > 0.0:
		_dash_windup_left = maxf(0.0, _dash_windup_left - delta)
		velocity = Vector2.ZERO
		if _dash_windup_left <= 0.0:
			_dash_time_left = dash_duration_seconds
		return

	if _dash_time_left > 0.0:
		_dash_time_left = maxf(0.0, _dash_time_left - delta)
		velocity = _dash_direction * dash_speed
		return

	var to_player: Vector2 = _player.global_position - global_position
	velocity = to_player.normalized() * move_speed

	_dash_timer += delta
	if _dash_timer < dash_interval_seconds:
		return

	_dash_timer = 0.0
	if to_player.length() <= 0.01:
		return
	_dash_direction = to_player.normalized()
	_dash_windup_left = dash_windup_seconds
	if debug_log_dash:
		print("Dasher preparing dash")

func _apply_contact_damage() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider() as Node
		if collider == null:
			continue
		if not collider.is_in_group("player"):
			continue
		if collider.has_method("take_damage"):
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
		push_error("EnemyDasher requires an AnimatedSprite2D child node named AnimatedSprite2D.")
		return
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	animated_sprite.position = visual_offset
	_base_sprite_scale = sprite_scale
	animated_sprite.scale = _base_sprite_scale
	_base_sprite_modulate = sprite_modulate
	animated_sprite.modulate = _base_sprite_modulate
	if collision_shape != null:
		_base_collision_shape_rotation = collision_shape.rotation
	if not animated_sprite.animation_finished.is_connected(Callable(self, "_on_animated_sprite_animation_finished")):
		animated_sprite.animation_finished.connect(Callable(self, "_on_animated_sprite_animation_finished"))
	_play_base_animation(false)

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
	if _dash_windup_left > 0.0:
		_play_specific_animation(windup_animation_name)
		return
	if _dash_time_left > 0.0:
		_play_specific_animation(dash_animation_name)
		return
	_play_base_animation(is_moving)

func _play_base_animation(is_moving: bool) -> void:
	var target_animation: StringName = move_animation_name if is_moving else idle_animation_name
	_play_specific_animation(target_animation)

func _play_specific_animation(animation_name: StringName) -> void:
	if animated_sprite == null:
		return
	if not _has_animation(animation_name):
		return
	if animated_sprite.animation == animation_name and animated_sprite.is_playing():
		return
	animated_sprite.play(animation_name)

func _has_animation(animation_name: StringName) -> bool:
	if animated_sprite == null:
		return false
	if animated_sprite.sprite_frames == null:
		return false
	return animated_sprite.sprite_frames.has_animation(animation_name)

func _get_facing_direction() -> Vector2:
	if _dash_windup_left > 0.0 or _dash_time_left > 0.0:
		return _dash_direction
	if velocity.length_squared() > 0.0001:
		return velocity.normalized()
	if is_instance_valid(_player):
		return (_player.global_position - global_position).normalized()
	return Vector2.ZERO

func _update_visual_orientation(direction: Vector2) -> void:
	if animated_sprite == null:
		return
	if not orient_to_player:
		return
	if direction.length_squared() <= 0.0001:
		return

	var base_angle: float = direction.angle()
	var offset_radians: float = deg_to_rad(orientation_rotation_offset_degrees)
	var visual_rotation: float = base_angle + offset_radians
	animated_sprite.rotation = visual_rotation
	if collision_rotates_with_facing and collision_shape != null:
		collision_shape.rotation = _base_collision_shape_rotation + visual_rotation

func _on_animated_sprite_animation_finished() -> void:
	if animated_sprite == null:
		return
	if animated_sprite.animation != hit_animation_name:
		return
	_is_playing_hit_animation = false
	_update_animation_state(velocity.length() > 0.01)
