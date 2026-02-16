extends CharacterBody2D

signal died(world_position: Vector2)

@export var move_speed: float = 90.0
@export var max_hp: int = 15
@export var contact_damage: int = 10
@export var visual_radius: float = 10.0
@export var visual_color: Color = Color(1, 0.2, 0.2, 1)
@export var debug_log_damage: bool = true

var current_hp: int
var _player: Node2D

func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies")
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, visual_radius, visual_color)

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
	if current_hp == 0:
		died.emit(global_position)
		queue_free()
