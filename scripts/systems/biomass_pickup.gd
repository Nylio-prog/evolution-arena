extends Area2D

signal collected(amount: int)

@export var xp_value: int = 6
@export var pickup_animation_name: StringName = &"default"
@export var sprite_scale: Vector2 = Vector2.ONE
@export var sprite_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var spawn_pop_duration: float = 0.18
@export var spawn_pop_overshoot: float = 1.35
@export var collect_feedback_duration: float = 0.16
@export var collect_scale_multiplier: float = 1.55
@export var collect_rise_pixels: float = 18.0
@export var idle_pulse_amplitude: float = 0.08
@export var idle_pulse_speed_hz: float = 1.8
@export var auto_collect_base_radius: float = 48.0
@export var debug_log_collect: bool = false

@onready var visual_animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var _is_collecting: bool = false
var _sprite_tween: Tween
var _player: Node2D
var _base_visual_scale: Vector2 = Vector2.ONE
var _idle_pulse_phase: float = 0.0

func _ready() -> void:
	add_to_group("biomass_pickups")
	body_entered.connect(_on_body_entered)
	_idle_pulse_phase = randf_range(0.0, TAU)
	_refresh_visual_sprite()
	_play_spawn_feedback()

func _physics_process(delta: float) -> void:
	if _is_collecting:
		return
	_update_idle_pulse(delta)
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null:
		return

	var pickup_multiplier: float = 1.0
	if _player.has_method("get_pickup_radius_multiplier"):
		pickup_multiplier = float(_player.call("get_pickup_radius_multiplier"))
	var auto_collect_radius: float = maxf(8.0, auto_collect_base_radius * pickup_multiplier)
	if global_position.distance_to(_player.global_position) <= auto_collect_radius:
		_on_body_entered(_player)

func _on_body_entered(body: Node) -> void:
	if body == null:
		return
	if not body.is_in_group("player"):
		return
	if _is_collecting:
		return

	if debug_log_collect:
		print("Biomass collected for ", xp_value, " XP")
	_is_collecting = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	collected.emit(xp_value)
	_play_collect_feedback()

func _refresh_visual_sprite() -> void:
	if visual_animated_sprite == null:
		push_error("BiomassPickup requires an AnimatedSprite2D child node.")
		return

	_base_visual_scale = visual_animated_sprite.scale
	visual_animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if visual_animated_sprite.sprite_frames == null:
		push_error("BiomassPickup AnimatedSprite2D requires authored SpriteFrames.")
		return

	var resolved_animation_name: StringName = pickup_animation_name
	if resolved_animation_name.is_empty() or not visual_animated_sprite.sprite_frames.has_animation(resolved_animation_name):
		var animation_names: PackedStringArray = visual_animated_sprite.sprite_frames.get_animation_names()
		if animation_names.is_empty():
			push_error("BiomassPickup AnimatedSprite2D has no animations.")
			return
		resolved_animation_name = StringName(animation_names[0])

	visual_animated_sprite.play(resolved_animation_name)
	visual_animated_sprite.scale = Vector2(_base_visual_scale.x * sprite_scale.x, _base_visual_scale.y * sprite_scale.y)
	visual_animated_sprite.modulate = sprite_modulate
	visual_animated_sprite.visible = true

func _play_spawn_feedback() -> void:
	var visual_node: Node2D = _get_visual_node()
	if visual_node == null:
		return

	var base_scale: Vector2 = Vector2(_base_visual_scale.x * sprite_scale.x, _base_visual_scale.y * sprite_scale.y)
	var intro_scale: Vector2 = base_scale * 0.7
	var overshoot_scale: Vector2 = base_scale * maxf(1.0, spawn_pop_overshoot)
	visual_node.scale = intro_scale

	_stop_sprite_tween()
	_sprite_tween = create_tween()
	_sprite_tween.tween_property(visual_node, "scale", overshoot_scale, spawn_pop_duration * 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_sprite_tween.tween_property(visual_node, "scale", base_scale, spawn_pop_duration * 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _play_collect_feedback() -> void:
	var visual_node: Node2D = _get_visual_node()
	if visual_node == null:
		queue_free()
		return

	var start_modulate: Color = sprite_modulate
	if visual_animated_sprite != null:
		start_modulate = visual_animated_sprite.modulate
	var end_modulate: Color = start_modulate
	end_modulate.a = 0.0
	var target_scale: Vector2 = visual_node.scale * maxf(1.0, collect_scale_multiplier)
	var target_position: Vector2 = visual_node.position + Vector2(0.0, -collect_rise_pixels)

	_stop_sprite_tween()
	_sprite_tween = create_tween()
	_sprite_tween.set_parallel(true)
	_sprite_tween.tween_property(visual_node, "modulate", end_modulate, collect_feedback_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_sprite_tween.tween_property(visual_node, "scale", target_scale, collect_feedback_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_sprite_tween.tween_property(visual_node, "position", target_position, collect_feedback_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_sprite_tween.finished.connect(_on_collect_feedback_finished)

func _on_collect_feedback_finished() -> void:
	queue_free()

func _stop_sprite_tween() -> void:
	if is_instance_valid(_sprite_tween):
		_sprite_tween.kill()

func _get_visual_node() -> Node2D:
	return visual_animated_sprite

func _update_idle_pulse(delta: float) -> void:
	var visual_node: Node2D = _get_visual_node()
	if visual_node == null:
		return
	if _is_visual_tween_running():
		return

	var safe_amplitude: float = clampf(idle_pulse_amplitude, 0.0, 0.5)
	var safe_speed_hz: float = maxf(0.1, idle_pulse_speed_hz)
	_idle_pulse_phase += delta * TAU * safe_speed_hz
	var pulse_factor: float = 1.0 + sin(_idle_pulse_phase) * safe_amplitude
	visual_node.scale = _get_base_visual_scale() * pulse_factor

func _is_visual_tween_running() -> bool:
	if not is_instance_valid(_sprite_tween):
		return false
	return _sprite_tween.is_running()

func _get_base_visual_scale() -> Vector2:
	return Vector2(_base_visual_scale.x * sprite_scale.x, _base_visual_scale.y * sprite_scale.y)
