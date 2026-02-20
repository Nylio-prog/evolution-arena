extends Area2D

signal expired(projectile_node: Node)

@export var move_speed: float = 420.0
@export var damage: int = 8
@export var life_seconds: float = 2.2
@export var hit_radius: float = 9.0
@export var hostile_projectile: bool = true
@export var projectile_tint: Color = Color(1.0, 0.86, 0.58, 0.98)
@export var projectile_animation_name: StringName = &"default"
@export var debug_log_hits: bool = false

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var _direction: Vector2 = Vector2.RIGHT
var _time_left: float = 0.0
var _source_attacker: Node = null

func _ready() -> void:
	add_to_group("enemy_projectiles")
	_time_left = maxf(0.05, life_seconds)
	_apply_collision_radius()
	_apply_visual()
	_connect_signals()

func setup(direction: Vector2, hit_damage: int, is_hostile: bool, source_attacker: Node = null) -> void:
	if direction.length_squared() > 0.0001:
		_direction = direction.normalized()
	else:
		_direction = Vector2.RIGHT
	damage = maxi(1, hit_damage)
	hostile_projectile = is_hostile
	_source_attacker = source_attacker
	rotation = _direction.angle()

func _physics_process(delta: float) -> void:
	_time_left = maxf(0.0, _time_left - delta)
	if _time_left <= 0.0:
		_expire()
		return
	global_position += _direction * move_speed * delta

func _connect_signals() -> void:
	var body_entered_callable := Callable(self, "_on_body_entered")
	if not body_entered.is_connected(body_entered_callable):
		body_entered.connect(body_entered_callable)

func _apply_collision_radius() -> void:
	if collision_shape == null:
		return
	var circle_shape := collision_shape.shape as CircleShape2D
	if circle_shape == null:
		circle_shape = CircleShape2D.new()
		collision_shape.shape = circle_shape
	circle_shape.radius = maxf(2.0, hit_radius)

func _apply_visual() -> void:
	if animated_sprite == null:
		push_error("EnemyProjectile requires AnimatedSprite2D with authored SpriteFrames.")
		return
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	animated_sprite.modulate = projectile_tint
	if animated_sprite.sprite_frames == null:
		push_error("EnemyProjectile AnimatedSprite2D has no SpriteFrames.")
		return
	var animation_name: StringName = projectile_animation_name
	if not animated_sprite.sprite_frames.has_animation(animation_name):
		var animation_names: PackedStringArray = animated_sprite.sprite_frames.get_animation_names()
		if animation_names.is_empty():
			push_error("EnemyProjectile AnimatedSprite2D has no animations.")
			return
		animation_name = StringName(animation_names[0])
	animated_sprite.play(animation_name)
	animated_sprite.visible = true

func _on_body_entered(body: Node) -> void:
	if body == null:
		return
	if hostile_projectile:
		if not body.is_in_group("player"):
			return
		if body.has_method("take_damage"):
			var damage_source: Node = self
			if _source_attacker != null and is_instance_valid(_source_attacker):
				damage_source = _source_attacker
			body.call("take_damage", damage, damage_source)
			if debug_log_hits:
				print("[EnemyProjectile] hit player for ", damage)
		_expire()
		return

	if not body.is_in_group("hostile_enemies"):
		return
	if body.has_method("take_damage"):
		body.call("take_damage", damage)
		if debug_log_hits:
			print("[EnemyProjectile] allied host projectile hit enemy for ", damage)
	_expire()

func _expire() -> void:
	expired.emit(self)
	queue_free()
