extends Area2D

signal sweep_finished()
signal player_contacted(player_node: Node)

@export var telegraph_duration_seconds: float = 0.9
@export var sweep_duration_seconds: float = 4.0
@export var sweep_length: float = 2800.0
@export var sweep_width: float = 140.0
@export var sweep_travel_distance: float = 1700.0
@export var telegraph_color: Color = Color(1.0, 0.54, 0.26, 0.22)
@export var active_color: Color = Color(1.0, 0.25, 0.18, 0.64)
@export var telegraph_pulse_hz: float = 5.0
@export var debug_log_events: bool = false

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var visual_polygon: Polygon2D = get_node_or_null("VisualPolygon")

var _phase: String = "idle"
var _phase_time_seconds: float = 0.0
var _sweep_center: Vector2 = Vector2.ZERO
var _sweep_angle: float = 0.0
var _travel_axis: Vector2 = Vector2.RIGHT
var _start_position: Vector2 = Vector2.ZERO
var _end_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("crisis_runtime_nodes")
	_configure_geometry()
	_connect_signals()
	_set_active_collision(false)
	_update_visual()

func begin_sweep(center_position: Vector2, override_sweep_duration_seconds: float = -1.0) -> void:
	_sweep_center = center_position
	if override_sweep_duration_seconds > 0.0:
		sweep_duration_seconds = maxf(0.5, override_sweep_duration_seconds)

	_sweep_angle = randf() * TAU
	rotation = _sweep_angle
	var long_axis: Vector2 = Vector2.RIGHT.rotated(_sweep_angle)
	_travel_axis = Vector2(-long_axis.y, long_axis.x).normalized()

	var half_travel: float = sweep_travel_distance * 0.5
	_start_position = _sweep_center - (_travel_axis * half_travel)
	_end_position = _sweep_center + (_travel_axis * half_travel)
	global_position = _start_position
	_enter_phase("telegraph")

func _process(delta: float) -> void:
	if _phase == "idle" or _phase == "done":
		return

	_phase_time_seconds += delta

	if _phase == "telegraph":
		if _phase_time_seconds >= telegraph_duration_seconds:
			_enter_phase("active")
	elif _phase == "active":
		var normalized_time: float = clampf(_phase_time_seconds / maxf(0.01, sweep_duration_seconds), 0.0, 1.0)
		global_position = _start_position.lerp(_end_position, normalized_time)
		if normalized_time >= 1.0:
			_enter_phase("done")

	_update_visual()

func _configure_geometry() -> void:
	if collision_shape != null:
		var rectangle_shape: RectangleShape2D = collision_shape.shape as RectangleShape2D
		if rectangle_shape == null:
			rectangle_shape = RectangleShape2D.new()
			collision_shape.shape = rectangle_shape
		rectangle_shape.size = Vector2(sweep_length, sweep_width)

	if visual_polygon != null:
		var half_length: float = sweep_length * 0.5
		var half_width: float = sweep_width * 0.5
		visual_polygon.polygon = PackedVector2Array([
			Vector2(-half_length, -half_width),
			Vector2(half_length, -half_width),
			Vector2(half_length, half_width),
			Vector2(-half_length, half_width)
		])

func _connect_signals() -> void:
	var body_entered_callable := Callable(self, "_on_body_entered")
	if not body_entered.is_connected(body_entered_callable):
		body_entered.connect(body_entered_callable)

func _enter_phase(next_phase: String) -> void:
	_phase = next_phase
	_phase_time_seconds = 0.0
	if _phase == "telegraph":
		_set_active_collision(false)
		if debug_log_events:
			print("[ContainmentSweep] Telegraph started")
		return
	if _phase == "active":
		global_position = _start_position
		_set_active_collision(true)
		if debug_log_events:
			print("[ContainmentSweep] Sweep active")
		return
	if _phase == "done":
		_set_active_collision(false)
		if debug_log_events:
			print("[ContainmentSweep] Sweep finished")
		sweep_finished.emit()
		queue_free()

func _set_active_collision(active: bool) -> void:
	monitoring = active
	monitorable = active

func _update_visual() -> void:
	if visual_polygon == null:
		return

	if _phase == "telegraph":
		var pulse: float = (sin(_phase_time_seconds * telegraph_pulse_hz * TAU) + 1.0) * 0.5
		var color_now: Color = telegraph_color
		color_now.a = lerpf(telegraph_color.a * 0.55, telegraph_color.a, pulse)
		visual_polygon.color = color_now
		return
	if _phase == "active":
		visual_polygon.color = active_color
		return
	visual_polygon.color = Color(active_color.r, active_color.g, active_color.b, 0.0)

func _on_body_entered(body: Node) -> void:
	if _phase != "active":
		return
	if body == null:
		return
	if not body.is_in_group("player"):
		return
	player_contacted.emit(body)
	if debug_log_events:
		print("[ContainmentSweep] Player contacted sweep")
