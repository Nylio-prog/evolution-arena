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

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies")
	_setup_animated_sprite()

func _draw() -> void:
	pass

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
