extends CharacterBody2D

signal died(world_position: Vector2)

@export var move_speed: float = 90.0
@export var max_hp: int = 15
@export var contact_damage: int = 10
@export var sprite_texture: Texture2D
@export_file("*.png", "*.webp", "*.jpg", "*.jpeg", "*.svg") var default_sprite_path: String = "res://art/sprites/enemies/enemy_basic.png"
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

@onready var visual_sprite: Sprite2D = get_node_or_null("VisualSprite")

func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies")
	_refresh_visual_sprite()
	queue_redraw()

func _draw() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D

	if not is_instance_valid(_player):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_player := _player.global_position - global_position
	velocity = to_player.normalized() * move_speed
	move_and_slide()
	_apply_contact_damage()
	_update_hit_flash(_delta)

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
	if current_hp == 0:
		died.emit(global_position)
		queue_free()

func _trigger_hit_flash() -> void:
	if visual_sprite == null:
		return
	_hit_flash_time_left = maxf(hit_flash_duration, 0.01)
	visual_sprite.modulate = hit_flash_color
	visual_sprite.scale = _base_sprite_scale * maxf(1.0, hit_punch_scale_multiplier)

func _update_hit_flash(delta: float) -> void:
	if _hit_flash_time_left <= 0.0:
		return
	_hit_flash_time_left = maxf(0.0, _hit_flash_time_left - delta)
	if _hit_flash_time_left == 0.0 and visual_sprite != null:
		visual_sprite.modulate = _base_sprite_modulate
		visual_sprite.scale = _base_sprite_scale

func _refresh_visual_sprite() -> void:
	if visual_sprite == null:
		push_error("EnemyBasic requires a VisualSprite child node.")
		return

	var resolved_texture: Texture2D = sprite_texture
	if resolved_texture == null and ResourceLoader.exists(default_sprite_path, "Texture2D"):
		var loaded_resource: Resource = load(default_sprite_path)
		resolved_texture = loaded_resource as Texture2D

	visual_sprite.texture = resolved_texture
	_base_sprite_scale = sprite_scale
	visual_sprite.scale = _base_sprite_scale
	_base_sprite_modulate = sprite_modulate
	visual_sprite.modulate = _base_sprite_modulate
	visual_sprite.visible = true
	if resolved_texture == null:
		push_error("EnemyBasic sprite missing. Assign sprite_texture or add file: %s" % default_sprite_path)
