extends CharacterBody2D

signal died(world_position: Vector2)

@export var move_speed: float = 60.0
@export var dash_speed: float = 220.0
@export var max_hp: int = 12
@export var contact_damage: int = 12
@export var visual_radius: float = 9.0
@export var visual_color: Color = Color(1.0, 0.45, 0.2, 1.0)
@export var dash_interval_seconds: float = 1.25
@export var dash_duration_seconds: float = 0.66
@export var dash_windup_seconds: float = 0.14
@export var debug_log_dash: bool = false

var current_hp: int
var _player: Node2D
var _dash_timer: float = 0.0
var _dash_time_left: float = 0.0
var _dash_windup_left: float = 0.0
var _dash_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies")
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, visual_radius, visual_color)
	if _dash_windup_left > 0.0:
		draw_arc(Vector2.ZERO, visual_radius + 4.0, 0.0, TAU, 32, Color(1.0, 0.8, 0.2, 1.0), 2.0, true)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D

	if not is_instance_valid(_player):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_update_dash_state(delta)
	move_and_slide()
	_apply_contact_damage()

func _update_dash_state(delta: float) -> void:
	if _dash_windup_left > 0.0:
		_dash_windup_left = maxf(0.0, _dash_windup_left - delta)
		velocity = Vector2.ZERO
		if _dash_windup_left <= 0.0:
			_dash_time_left = dash_duration_seconds
		queue_redraw()
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
	queue_redraw()

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
	if current_hp == 0:
		died.emit(global_position)
		queue_free()
