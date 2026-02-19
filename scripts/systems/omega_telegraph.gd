extends Node2D

signal telegraph_finished(telegraph_node: Node2D)

@export var radius: float = 84.0
@export var duration_seconds: float = 0.65
@export var line_width: float = 3.0
@export var fill_color: Color = Color(1.0, 0.32, 0.18, 0.20)
@export var outline_color: Color = Color(1.0, 0.74, 0.34, 0.98)
@export var pulse_frequency: float = 4.0
@export var pulse_amplitude: float = 0.06

var _time_left_seconds: float = 0.0

func _ready() -> void:
	add_to_group("crisis_runtime_nodes")
	_time_left_seconds = maxf(0.02, duration_seconds)
	set_process(true)
	queue_redraw()

func configure(
	world_position: Vector2,
	new_radius: float,
	new_duration_seconds: float,
	new_fill_color: Color,
	new_outline_color: Color
) -> void:
	global_position = world_position
	radius = maxf(2.0, new_radius)
	duration_seconds = maxf(0.02, new_duration_seconds)
	fill_color = new_fill_color
	outline_color = new_outline_color
	_time_left_seconds = duration_seconds
	queue_redraw()

func _process(delta: float) -> void:
	_time_left_seconds = maxf(0.0, _time_left_seconds - delta)
	if _time_left_seconds <= 0.0:
		telegraph_finished.emit(self)
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var safe_duration: float = maxf(0.02, duration_seconds)
	var remaining_ratio: float = clampf(_time_left_seconds / safe_duration, 0.0, 1.0)
	var elapsed_ratio: float = 1.0 - remaining_ratio
	var pulse_scale: float = 1.0 + sin(elapsed_ratio * TAU * pulse_frequency) * pulse_amplitude
	var draw_radius: float = maxf(2.0, radius * pulse_scale)

	var live_fill: Color = fill_color
	live_fill.a = fill_color.a * (0.65 + remaining_ratio * 0.35)
	draw_circle(Vector2.ZERO, draw_radius, live_fill)

	var live_outline: Color = outline_color
	live_outline.a = outline_color.a * (0.55 + remaining_ratio * 0.45)
	draw_arc(Vector2.ZERO, draw_radius, 0.0, TAU, 72, live_outline, maxf(1.0, line_width), true)
