extends CharacterBody2D

signal hp_changed(current_hp: int, max_hp: int)
signal died

@export var move_speed: float = 260.0
@export var max_hp: int = 100
@export var invulnerability_seconds: float = 0.5
@export var visual_radius: float = 12.0
@export var visual_color: Color = Color(1, 1, 1, 1)
@export var lineage_accent_color: Color = Color(1, 1, 1, 0)
@export var lineage_accent_width: float = 2.0
@export var debug_log_damage: bool = false

var current_hp: int
var _invulnerable_until_ms: int = 0
var incoming_damage_multiplier: float = 1.0

func _ready() -> void:
	current_hp = max_hp
	add_to_group("player")
	hp_changed.emit(current_hp, max_hp)
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, visual_radius, visual_color)
	if lineage_accent_color.a > 0.01:
		draw_arc(Vector2.ZERO, visual_radius + 4.0, 0.0, TAU, 48, lineage_accent_color, lineage_accent_width, true)

func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed
	move_and_slide()

func take_damage(amount: int) -> void:
	if amount <= 0:
		return

	var now_ms := Time.get_ticks_msec()
	if now_ms < _invulnerable_until_ms:
		return

	var final_amount: int = max(1, int(round(float(amount) * incoming_damage_multiplier)))
	_invulnerable_until_ms = now_ms + int(invulnerability_seconds * 1000.0)
	current_hp = max(0, current_hp - final_amount)
	if debug_log_damage:
		print(
			"Player took ",
			final_amount,
			" damage (raw ",
			amount,
			", x",
			incoming_damage_multiplier,
			"). HP: ",
			current_hp,
			"/",
			max_hp
		)
	hp_changed.emit(current_hp, max_hp)

	if current_hp == 0:
		died.emit()

func set_incoming_damage_multiplier(multiplier: float) -> void:
	incoming_damage_multiplier = clampf(multiplier, 0.05, 1.0)

func set_lineage_accent(color: Color) -> void:
	lineage_accent_color = color
	queue_redraw()
