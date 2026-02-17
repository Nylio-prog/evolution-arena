extends Area2D

signal leak_finished()
signal player_exposed(player_node: Node)

@export var telegraph_duration_seconds: float = 0.45
@export var active_duration_seconds: float = 0.0
@export var collision_radius: float = 94.0
@export var damage_tick_amount: int = 5
@export var damage_tick_interval_seconds: float = 0.2
@export var use_sprite_visual_when_available: bool = true
@export var sprite_telegraph_alpha: float = 0.38
@export var sprite_active_alpha: float = 0.92
@export var telegraph_pulse_hz: float = 3.2
@export var debug_log_events: bool = false

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var _phase: String = "idle"
var _phase_elapsed_seconds: float = 0.0
var _active_phase_duration_seconds: float = 0.0
var _tracked_players: Array[Node] = []
var _damage_tick_elapsed_by_player: Dictionary = {}
var _sprite_animation_name: StringName = StringName()

func _ready() -> void:
	add_to_group("crisis_runtime_nodes")
	_connect_signals()
	_setup_animated_sprite()
	_set_collision_active(false)
	_apply_collision_radius()
	_update_sprite_visual()

func begin_leak(center_position: Vector2, override_active_duration_seconds: float = -1.0) -> void:
	global_position = center_position
	_active_phase_duration_seconds = active_duration_seconds
	if override_active_duration_seconds > 0.0:
		_active_phase_duration_seconds = override_active_duration_seconds

	_tracked_players.clear()
	_damage_tick_elapsed_by_player.clear()
	_apply_collision_radius()
	_enter_phase("telegraph")

func _process(delta: float) -> void:
	if _phase == "idle" or _phase == "done":
		return

	_phase_elapsed_seconds += delta
	if _phase == "telegraph":
		if _phase_elapsed_seconds >= telegraph_duration_seconds:
			_enter_phase("active")
	elif _phase == "active":
		_sync_overlapping_players()
		_apply_player_damage(delta)
		if _active_phase_duration_seconds > 0.0 and _phase_elapsed_seconds >= _active_phase_duration_seconds:
			_enter_phase("done")

	_update_sprite_visual()

func _draw() -> void:
	pass

func _connect_signals() -> void:
	var body_entered_callable := Callable(self, "_on_body_entered")
	if not body_entered.is_connected(body_entered_callable):
		body_entered.connect(body_entered_callable)

	var body_exited_callable := Callable(self, "_on_body_exited")
	if not body_exited.is_connected(body_exited_callable):
		body_exited.connect(body_exited_callable)

func _setup_animated_sprite() -> void:
	if animated_sprite == null:
		push_error("BiohazardLeakZone requires an AnimatedSprite2D child node.")
		return

	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if animated_sprite.sprite_frames == null:
		push_error("BiohazardLeakZone AnimatedSprite2D requires SpriteFrames.")
		return

	if animated_sprite.sprite_frames.has_animation(&"default"):
		_sprite_animation_name = &"default"
	else:
		var animation_names: PackedStringArray = animated_sprite.sprite_frames.get_animation_names()
		if not animation_names.is_empty():
			_sprite_animation_name = StringName(animation_names[0])
	if _sprite_animation_name.is_empty():
		push_error("BiohazardLeakZone AnimatedSprite2D has no animation to play.")
		return

	animated_sprite.play(_sprite_animation_name)
	animated_sprite.visible = false

func _enter_phase(next_phase: String) -> void:
	_phase = next_phase
	_phase_elapsed_seconds = 0.0
	if _phase == "telegraph":
		_set_collision_active(false)
		return
	if _phase == "active":
		_set_collision_active(true)
		return
	if _phase == "done":
		_set_collision_active(false)
		_tracked_players.clear()
		_damage_tick_elapsed_by_player.clear()
		_update_sprite_visual()
		if debug_log_events:
			print("[BiohazardLeak] Zone finished")
		leak_finished.emit()
		queue_free()

func _set_collision_active(active: bool) -> void:
	monitoring = active
	monitorable = active

func _apply_collision_radius() -> void:
	if collision_shape == null:
		return
	var circle_shape: CircleShape2D = collision_shape.shape as CircleShape2D
	if circle_shape == null:
		circle_shape = CircleShape2D.new()
		collision_shape.shape = circle_shape
	circle_shape.radius = maxf(8.0, collision_radius)

func _update_sprite_visual() -> void:
	if animated_sprite == null:
		return
	if not use_sprite_visual_when_available:
		animated_sprite.visible = false
		return
	if _phase == "idle" or _phase == "done":
		animated_sprite.visible = false
		return

	animated_sprite.visible = true
	if not _sprite_animation_name.is_empty() and not animated_sprite.is_playing():
		animated_sprite.play(_sprite_animation_name)

	if _phase == "telegraph":
		var pulse: float = (sin(_phase_elapsed_seconds * telegraph_pulse_hz * TAU) + 1.0) * 0.5
		animated_sprite.modulate = Color(1.0, 1.0, 1.0, lerpf(sprite_telegraph_alpha * 0.65, sprite_telegraph_alpha, pulse))
		return
	if _phase == "active":
		animated_sprite.modulate = Color(1.0, 1.0, 1.0, sprite_active_alpha)
		return
	animated_sprite.modulate = Color(1.0, 1.0, 1.0, 0.0)

func _sync_overlapping_players() -> void:
	for body_variant in get_overlapping_bodies():
		var body_node := body_variant as Node
		if body_node == null:
			continue
		if not body_node.is_in_group("player"):
			continue
		if _tracked_players.has(body_node):
			continue
		_tracked_players.append(body_node)
		_damage_tick_elapsed_by_player[body_node] = 0.0

func _apply_player_damage(delta: float) -> void:
	var tick_interval_seconds: float = maxf(0.01, damage_tick_interval_seconds)
	var tick_amount: int = maxi(1, damage_tick_amount)

	for player_index in range(_tracked_players.size() - 1, -1, -1):
		var player_node: Node = _tracked_players[player_index]
		if player_node == null or not is_instance_valid(player_node):
			_tracked_players.remove_at(player_index)
			continue
		if not player_node.is_in_group("player"):
			continue
		if not player_node.has_method("take_damage") and not player_node.has_method("take_dot_damage"):
			continue

		var elapsed_variant: Variant = _damage_tick_elapsed_by_player.get(player_node, 0.0)
		var elapsed_seconds: float = float(elapsed_variant) + delta
		while elapsed_seconds >= tick_interval_seconds:
			elapsed_seconds -= tick_interval_seconds
			if player_node.has_method("take_dot_damage"):
				player_node.call("take_dot_damage", tick_amount)
			else:
				player_node.call("take_damage", tick_amount)
		_damage_tick_elapsed_by_player[player_node] = elapsed_seconds

func _on_body_entered(body: Node) -> void:
	if _phase != "active":
		return
	if body == null:
		return
	if not body.is_in_group("player"):
		return
	player_exposed.emit(body)
	if _tracked_players.has(body):
		return
	_tracked_players.append(body)
	_damage_tick_elapsed_by_player[body] = 0.0

func _on_body_exited(body: Node) -> void:
	if body == null:
		return
	if _tracked_players.has(body):
		_tracked_players.erase(body)
	_damage_tick_elapsed_by_player.erase(body)
