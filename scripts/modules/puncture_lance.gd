extends Node2D

const PUNCTURE_LANCE_PROJECTILE_TEXTURE: Texture2D = preload("res://art/sprites/modules/puncture_lance_projectile.png")

class LanceTracer:
	extends RefCounted
	var from_pos: Vector2
	var to_pos: Vector2
	var time_left: float
	var total_time: float

@export var base_damage: int = 12
@export var base_interval_seconds: float = 1.2
@export var target_range: float = 320.0
@export var tracer_duration_seconds: float = 0.10
@export var tracer_color: Color = Color(0.72, 0.95, 1.0, 0.46)
@export var tracer_line_width: float = 2.6
@export var tracer_projectile_texture: Texture2D = PUNCTURE_LANCE_PROJECTILE_TEXTURE
@export var tracer_projectile_scale: float = 0.14
@export var tracer_projectile_color: Color = Color(1.0, 0.97, 0.90, 0.97)
@export var debug_log_hits: bool = false

@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")

var lance_level: int = 0
var _runtime_damage_multiplier: float = 1.0
var _runtime_cooldown_multiplier: float = 1.0
var _time_until_next_volley: float = 0.0
var _tracers: Array[LanceTracer] = []

func _ready() -> void:
	add_to_group("player_modules")
	set_level(0)

func _physics_process(delta: float) -> void:
	_update_tracers(delta)
	if lance_level <= 0:
		return

	_time_until_next_volley = maxf(0.0, _time_until_next_volley - delta)
	if _time_until_next_volley > 0.0:
		return

	_fire_volley()
	_time_until_next_volley = _get_effective_interval_seconds()

func set_level(new_level: int) -> void:
	lance_level = clampi(new_level, 0, 5)
	_time_until_next_volley = minf(_time_until_next_volley, _get_effective_interval_seconds())

func set_runtime_modifiers(damage_multiplier: float, cooldown_multiplier: float) -> void:
	_runtime_damage_multiplier = maxf(0.1, damage_multiplier)
	_runtime_cooldown_multiplier = maxf(0.1, cooldown_multiplier)

func _get_effective_interval_seconds() -> float:
	if lance_level <= 0:
		return 999.0
	var interval_seconds: float = base_interval_seconds
	match lance_level:
		2:
			interval_seconds = base_interval_seconds * 0.84
		3:
			interval_seconds = base_interval_seconds * 0.72
		4:
			interval_seconds = base_interval_seconds * 0.62
		5:
			interval_seconds = base_interval_seconds * 0.53
	return maxf(0.18, interval_seconds * _runtime_cooldown_multiplier)

func _get_effective_damage() -> int:
	if lance_level <= 0:
		return 0
	var damage_value: float = float(base_damage)
	match lance_level:
		2:
			damage_value *= 1.20
		3:
			damage_value *= 1.38
		4:
			damage_value *= 1.58
		5:
			damage_value *= 1.80
	damage_value *= _runtime_damage_multiplier
	return maxi(1, int(round(damage_value)))

func _get_targets_per_volley() -> int:
	match lance_level:
		1:
			return 1
		2:
			return 2
		3:
			return 3
		4:
			return 4
		5:
			return 5
		_:
			return 0

func _fire_volley() -> void:
	var owner_player := get_parent() as Node2D
	if owner_player == null:
		return

	var origin: Vector2 = owner_player.global_position
	var candidates: Array[Node2D] = []
	for enemy_variant in get_tree().get_nodes_in_group("enemies"):
		var enemy_node := enemy_variant as Node2D
		if enemy_node == null:
			continue
		if not enemy_node.has_method("take_damage"):
			continue
		if origin.distance_to(enemy_node.global_position) > target_range:
			continue
		candidates.append(enemy_node)

	if candidates.is_empty():
		return
	candidates.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return origin.distance_squared_to(a.global_position) < origin.distance_squared_to(b.global_position)
	)

	var hits: int = 0
	var damage_amount: int = _get_effective_damage()
	var max_hits: int = _get_targets_per_volley()
	for i in range(mini(max_hits, candidates.size())):
		var target_node: Node2D = candidates[i]
		if target_node == null or not is_instance_valid(target_node):
			continue
		target_node.call("take_damage", damage_amount)
		if lance_level >= 3 and target_node.has_method("apply_viral_mark"):
			target_node.call("apply_viral_mark", 2.0, 1.22)
		_spawn_tracer(origin, target_node.global_position)
		hits += 1

	if debug_log_hits and hits > 0:
		print("Puncture Lance hit ", hits, " target(s) for ", damage_amount)
	if hits > 0:
		_play_sfx("sfx_puncture_lance_fire", -4.0, randf_range(0.97, 1.05))

func _spawn_tracer(from_pos: Vector2, to_pos: Vector2) -> void:
	var tracer := LanceTracer.new()
	tracer.from_pos = to_local(from_pos)
	tracer.to_pos = to_local(to_pos)
	tracer.time_left = tracer_duration_seconds
	tracer.total_time = maxf(0.01, tracer_duration_seconds)
	_tracers.append(tracer)
	queue_redraw()

func _update_tracers(delta: float) -> void:
	if _tracers.is_empty():
		return
	for index in range(_tracers.size() - 1, -1, -1):
		var tracer: LanceTracer = _tracers[index]
		if tracer == null:
			_tracers.remove_at(index)
			continue
		tracer.time_left = maxf(0.0, tracer.time_left - delta)
		if tracer.time_left <= 0.0:
			_tracers.remove_at(index)
	if not _tracers.is_empty():
		queue_redraw()

func _draw() -> void:
	for tracer in _tracers:
		if tracer == null:
			continue
		var ratio: float = clampf(tracer.time_left / maxf(0.01, tracer.total_time), 0.0, 1.0)
		var progress: float = 1.0 - ratio
		var color_now: Color = tracer_color
		color_now.a = tracer_color.a * ratio
		draw_line(tracer.from_pos, tracer.to_pos, color_now, tracer_line_width)
		_draw_tracer_projectile(tracer, progress, ratio)

func _draw_tracer_projectile(tracer: LanceTracer, progress: float, alpha_ratio: float) -> void:
	if tracer_projectile_texture == null:
		return
	var direction: Vector2 = tracer.to_pos - tracer.from_pos
	if direction.length_squared() <= 0.0001:
		return

	var position_now: Vector2 = tracer.from_pos.lerp(tracer.to_pos, progress)
	var angle_now: float = direction.angle()
	var texture_size: Vector2 = tracer_projectile_texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	var color_now: Color = tracer_projectile_color
	color_now.a = tracer_projectile_color.a * alpha_ratio

	draw_set_transform(position_now, angle_now, Vector2(tracer_projectile_scale, tracer_projectile_scale))
	draw_texture(tracer_projectile_texture, -texture_size * 0.5, color_now)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id, volume_db_offset, pitch_scale)
