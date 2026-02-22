extends Area2D

signal sweep_finished()
signal player_contacted(player_node: Node)

@export var telegraph_duration_seconds: float = 1.15
@export var sweep_duration_seconds: float = 5.5
@export var sweep_length: float = 2800.0
@export var sweep_width: float = 96.0
@export var sweep_travel_distance: float = 1320.0
@export var use_scene_collision_shape_size: bool = true
@export var sweep_pass_count: int = 3
@export var sweep_angle_jitter_degrees: float = 12.0
@export var lane_offset_range: float = 220.0
@export var pass_speed_ramp_per_pass: float = 0.16
@export var telegraph_color: Color = Color(1.0, 0.54, 0.26, 0.22)
@export var active_color: Color = Color(1.0, 0.25, 0.18, 0.64)
@export var telegraph_pulse_hz: float = 5.0
@export var sprite_telegraph_alpha: float = 0.42
@export var sprite_active_alpha: float = 0.86
@export var debug_log_events: bool = false

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var visual_polygon: Polygon2D = get_node_or_null("VisualPolygon")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var _phase: String = "idle"
var _phase_time_seconds: float = 0.0
var _sweep_center: Vector2 = Vector2.ZERO
var _sweep_angle: float = 0.0
var _travel_axis: Vector2 = Vector2.RIGHT
var _start_position: Vector2 = Vector2.ZERO
var _end_position: Vector2 = Vector2.ZERO
var _total_pass_count: int = 1
var _pass_index: int = 0
var _runtime_speed_multiplier: float = 1.0

func set_runtime_speed_multiplier(multiplier: float) -> void:
	_runtime_speed_multiplier = maxf(0.1, multiplier)

func _ready() -> void:
	add_to_group("crisis_runtime_nodes")
	_configure_geometry()
	_setup_animated_sprite()
	_connect_signals()
	_set_active_collision(false)
	_update_visual()

func begin_sweep(center_position: Vector2, override_sweep_duration_seconds: float = -1.0) -> void:
	_sweep_center = center_position
	if override_sweep_duration_seconds > 0.0:
		var pass_count_for_timing: int = maxi(1, sweep_pass_count)
		var total_telegraph_time: float = telegraph_duration_seconds * float(pass_count_for_timing)
		var active_time_budget: float = maxf(1.0, override_sweep_duration_seconds - total_telegraph_time)
		var per_pass_target: float = maxf(1.6, active_time_budget / float(pass_count_for_timing))
		sweep_duration_seconds = per_pass_target

	_total_pass_count = maxi(1, sweep_pass_count)
	_pass_index = 0
	_configure_pass_geometry(_pass_index)
	_enter_phase("telegraph")

func _process(delta: float) -> void:
	if _phase == "idle" or _phase == "done":
		return

	_phase_time_seconds += delta

	if _phase == "telegraph":
		if _phase_time_seconds >= telegraph_duration_seconds:
			_enter_phase("active")
	elif _phase == "active":
		var pass_speed_scale: float = (1.0 + (float(_pass_index) * pass_speed_ramp_per_pass)) * _runtime_speed_multiplier
		var effective_duration: float = maxf(0.35, sweep_duration_seconds / pass_speed_scale)
		var normalized_time: float = clampf(_phase_time_seconds / maxf(0.01, effective_duration), 0.0, 1.0)
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
		if not use_scene_collision_shape_size:
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

func _setup_animated_sprite() -> void:
	if animated_sprite == null:
		return
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(&"sweep"):
		animated_sprite.play(&"sweep")
	animated_sprite.visible = true

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
		if _pass_index + 1 < _total_pass_count:
			_pass_index += 1
			_configure_pass_geometry(_pass_index)
			_enter_phase("telegraph")
			return
		if debug_log_events:
			print("[ContainmentSweep] Sweep finished")
		sweep_finished.emit()
		queue_free()

func _set_active_collision(active: bool) -> void:
	monitoring = active
	monitorable = active

func _configure_pass_geometry(pass_index: int) -> void:
	var pass_ratio: float = 0.0
	if _total_pass_count > 1:
		pass_ratio = float(pass_index) / float(_total_pass_count - 1)
	var deterministic_angle_bias: float = lerpf(-1.0, 1.0, pass_ratio)

	var angle_jitter_radians: float = deg_to_rad(sweep_angle_jitter_degrees)
	_sweep_angle = randf() * TAU
	_sweep_angle += deterministic_angle_bias * angle_jitter_radians
	rotation = _sweep_angle

	var long_axis: Vector2 = Vector2.RIGHT.rotated(_sweep_angle)
	_travel_axis = Vector2(-long_axis.y, long_axis.x).normalized()

	var lane_offset: float = randf_range(-lane_offset_range, lane_offset_range)
	var pass_center: Vector2 = _sweep_center + (_travel_axis * lane_offset)
	var half_travel: float = sweep_travel_distance * 0.5
	_start_position = pass_center - (_travel_axis * half_travel)
	_end_position = pass_center + (_travel_axis * half_travel)
	global_position = _start_position

func _update_visual() -> void:
	if visual_polygon != null:
		if _phase == "telegraph":
			var pulse: float = (sin(_phase_time_seconds * telegraph_pulse_hz * TAU) + 1.0) * 0.5
			var color_now: Color = telegraph_color
			color_now.a = lerpf(telegraph_color.a * 0.55, telegraph_color.a, pulse)
			visual_polygon.color = color_now
		elif _phase == "active":
			visual_polygon.color = active_color
		else:
			visual_polygon.color = Color(active_color.r, active_color.g, active_color.b, 0.0)

	if animated_sprite == null:
		return
	if not animated_sprite.is_playing():
		if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(&"sweep"):
			animated_sprite.play(&"sweep")
	if _phase == "telegraph":
		var pulse: float = (sin(_phase_time_seconds * telegraph_pulse_hz * TAU) + 1.0) * 0.5
		var modulate_now: Color = Color(1.0, 1.0, 1.0, lerpf(sprite_telegraph_alpha * 0.7, sprite_telegraph_alpha, pulse))
		animated_sprite.modulate = modulate_now
		return
	if _phase == "active":
		animated_sprite.modulate = Color(1.0, 1.0, 1.0, sprite_active_alpha)
		return
	animated_sprite.modulate = Color(1.0, 1.0, 1.0, 0.0)

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
