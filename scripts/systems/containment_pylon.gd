extends StaticBody2D

const DEFAULT_PYLON_TEXTURE: Texture2D = preload("res://art/sprites/events/containment_pylon.png")

signal destroyed(world_position: Vector2, pylon_node: Node)
signal died(world_position: Vector2)

@export var max_hp: int = 95
@export var dot_damage_multiplier: float = 0.90
@export var collision_radius: float = 28.0
@export var base_tint: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var hurt_flash_color: Color = Color(1.0, 0.74, 0.55, 1.0)
@export var hurt_flash_duration: float = 0.08
@export var pylon_texture: Texture2D = DEFAULT_PYLON_TEXTURE
@export var pylon_scale: Vector2 = Vector2.ONE
@export var shield_scale: Vector2 = Vector2.ONE
@export var shield_animation_name: StringName = &"shield"
@export var debug_log_damage: bool = false

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var shield_sprite: AnimatedSprite2D = get_node_or_null("ShieldSprite")

var current_hp: int = 0
var _flash_time_left: float = 0.0
var _base_sprite_scale: Vector2 = Vector2.ONE
var _base_shield_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	current_hp = max_hp
	add_to_group("containment_pylons")
	add_to_group("enemies")
	add_to_group("hostile_enemies")
	_setup_collision()
	_setup_visuals()

func _process(delta: float) -> void:
	if _flash_time_left <= 0.0:
		return
	_flash_time_left = maxf(0.0, _flash_time_left - delta)
	if _flash_time_left <= 0.0 and sprite != null:
		sprite.modulate = base_tint

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	if current_hp <= 0:
		return
	current_hp = max(0, current_hp - amount)
	_trigger_hurt_flash()
	if debug_log_damage:
		print("[ContainmentPylon] took ", amount, ", hp ", current_hp, "/", max_hp)
	if current_hp > 0:
		return
	destroyed.emit(global_position, self)
	died.emit(global_position)
	queue_free()

func take_dot_damage(amount: int) -> void:
	if amount <= 0:
		return
	var scaled_amount: int = maxi(1, int(round(float(amount) * clampf(dot_damage_multiplier, 0.1, 3.0))))
	take_damage(scaled_amount)

func get_current_hp() -> int:
	return current_hp

func get_max_hp() -> int:
	return max_hp

func _setup_collision() -> void:
	if collision_shape == null:
		return
	var circle_shape := collision_shape.shape as CircleShape2D
	if circle_shape == null:
		circle_shape = CircleShape2D.new()
		collision_shape.shape = circle_shape
	circle_shape.radius = maxf(6.0, collision_radius)

func _setup_visuals() -> void:
	if sprite != null:
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		_base_sprite_scale = sprite.scale
		sprite.texture = pylon_texture
		sprite.scale = Vector2(_base_sprite_scale.x * pylon_scale.x, _base_sprite_scale.y * pylon_scale.y)
		sprite.modulate = base_tint

	if shield_sprite == null:
		return
	shield_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_base_shield_scale = shield_sprite.scale
	shield_sprite.scale = Vector2(_base_shield_scale.x * shield_scale.x, _base_shield_scale.y * shield_scale.y)
	if shield_sprite.sprite_frames == null:
		push_error("ContainmentPylon ShieldSprite requires authored SpriteFrames.")
		shield_sprite.visible = false
		return
	if shield_sprite.sprite_frames.has_animation(shield_animation_name):
		shield_sprite.play(shield_animation_name)
		shield_sprite.visible = true
		return
	var animation_names: PackedStringArray = shield_sprite.sprite_frames.get_animation_names()
	if animation_names.is_empty():
		push_error("ContainmentPylon ShieldSprite has no animations.")
		shield_sprite.visible = false
		return
	shield_sprite.play(StringName(animation_names[0]))
	shield_sprite.visible = true

func _trigger_hurt_flash() -> void:
	if sprite == null:
		return
	_flash_time_left = maxf(0.01, hurt_flash_duration)
	sprite.modulate = hurt_flash_color
