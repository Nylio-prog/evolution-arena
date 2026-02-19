extends Node2D

const MAX_BLOOM_EVENTS_PER_PASS: int = 256

class BloomPulse:
	extends RefCounted
	var position: Vector2
	var radius: float
	var time_left: float

@export var base_bloom_damage: int = 9
@export var base_bloom_radius: float = 90.0
@export var bloom_visual_duration_seconds: float = 0.22
@export var bloom_color: Color = Color(0.40, 1.0, 0.66, 0.9)
@export var debug_log_bloom: bool = false

@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")

var bloom_level: int = 0
var _runtime_damage_multiplier: float = 1.0
var _connected_enemy_ids: Dictionary = {}
var _active_visual_pulses: Array[BloomPulse] = []
var _pending_bloom_events: Array[Dictionary] = []
var _bloom_processing_scheduled: bool = false
var _is_processing_bloom_events: bool = false
var _queued_or_processed_source_enemy_ids: Dictionary = {}
var _sfx_reentry_guard: bool = false

func _ready() -> void:
	add_to_group("player_modules")
	set_level(0)
	for enemy_variant in get_tree().get_nodes_in_group("hostile_enemies"):
		_connect_enemy(enemy_variant as Node)
	var tree_node_added_callable := Callable(self, "_on_tree_node_added")
	if not get_tree().node_added.is_connected(tree_node_added_callable):
		get_tree().node_added.connect(tree_node_added_callable)

func _process(delta: float) -> void:
	if _active_visual_pulses.is_empty():
		return
	for index in range(_active_visual_pulses.size() - 1, -1, -1):
		var pulse: BloomPulse = _active_visual_pulses[index]
		if pulse == null:
			_active_visual_pulses.remove_at(index)
			continue
		pulse.time_left = maxf(0.0, pulse.time_left - delta)
		if pulse.time_left <= 0.0:
			_active_visual_pulses.remove_at(index)
	if not _active_visual_pulses.is_empty():
		queue_redraw()

func set_level(new_level: int) -> void:
	bloom_level = clampi(new_level, 0, 5)

func set_runtime_modifiers(damage_multiplier: float) -> void:
	_runtime_damage_multiplier = maxf(0.1, damage_multiplier)

func _on_tree_node_added(node: Node) -> void:
	_connect_enemy(node)

func _connect_enemy(node: Node) -> void:
	if node == null:
		return
	if not node.has_signal("died_detailed"):
		return
	var enemy_id: int = node.get_instance_id()
	if _connected_enemy_ids.has(enemy_id):
		return
	_connected_enemy_ids[enemy_id] = true
	var died_callable := Callable(self, "_on_enemy_died_detailed")
	node.connect("died_detailed", died_callable)

func _on_enemy_died_detailed(world_position: Vector2, enemy_node: Node) -> void:
	if bloom_level <= 0:
		return
	if enemy_node == null:
		return
	if not enemy_node.has_method("is_infected"):
		return
	if not bool(enemy_node.call("is_infected")):
		return
	var source_enemy_id: int = enemy_node.get_instance_id()
	_queue_bloom_event(world_position, source_enemy_id)

func _queue_bloom_event(world_position: Vector2, source_enemy_id: int) -> void:
	if source_enemy_id != 0:
		if _queued_or_processed_source_enemy_ids.has(source_enemy_id):
			return
		_queued_or_processed_source_enemy_ids[source_enemy_id] = true

	_pending_bloom_events.append({
		"position": world_position,
		"source_enemy_id": source_enemy_id
	})
	if _bloom_processing_scheduled:
		return
	_bloom_processing_scheduled = true
	call_deferred("_process_pending_bloom_events")

func _process_pending_bloom_events() -> void:
	_bloom_processing_scheduled = false
	if _is_processing_bloom_events:
		return
	_is_processing_bloom_events = true
	var processed_count: int = 0
	while not _pending_bloom_events.is_empty():
		var event_data: Dictionary = _pending_bloom_events.pop_front()
		var world_position: Vector2 = event_data.get("position", Vector2.ZERO)
		var source_enemy_id: int = int(event_data.get("source_enemy_id", 0))
		_trigger_bloom(world_position, source_enemy_id)
		processed_count += 1
		if processed_count >= MAX_BLOOM_EVENTS_PER_PASS:
			break
	_is_processing_bloom_events = false

	if _pending_bloom_events.is_empty():
		_queued_or_processed_source_enemy_ids.clear()

	if not _pending_bloom_events.is_empty() and not _bloom_processing_scheduled:
		_bloom_processing_scheduled = true
		call_deferred("_process_pending_bloom_events")

func _get_effective_damage() -> int:
	var damage_value: float = float(base_bloom_damage)
	match bloom_level:
		2:
			damage_value *= 1.25
		3:
			damage_value *= 1.55
		4:
			damage_value *= 1.85
		5:
			damage_value *= 2.20
	damage_value *= _runtime_damage_multiplier
	return maxi(1, int(round(damage_value)))

func _get_effective_radius() -> float:
	var radius_value: float = base_bloom_radius
	match bloom_level:
		2:
			radius_value += 26.0
		3:
			radius_value += 52.0
		4:
			radius_value += 80.0
		5:
			radius_value += 110.0
	return radius_value

func _get_chain_infection_stack_bonus() -> int:
	if bloom_level >= 5:
		return 4
	if bloom_level >= 4:
		return 3
	if bloom_level >= 3:
		return 2
	if bloom_level >= 2:
		return 1
	return 0

func _trigger_bloom(world_position: Vector2, source_enemy_id: int = 0) -> void:
	var radius_value: float = _get_effective_radius()
	var damage_amount: int = _get_effective_damage()
	var affected_count: int = 0
	for enemy_variant in get_tree().get_nodes_in_group("enemies"):
		var enemy_node := enemy_variant as Node2D
		if enemy_node == null:
			continue
		if source_enemy_id != 0 and enemy_node.get_instance_id() == source_enemy_id:
			continue
		if not _is_enemy_still_alive(enemy_node):
			continue
		if world_position.distance_to(enemy_node.global_position) > radius_value:
			continue
		if enemy_node.has_method("take_damage"):
			enemy_node.call("take_damage", damage_amount)
		if _is_enemy_still_alive(enemy_node) and enemy_node.has_method("apply_infection"):
			enemy_node.call("apply_infection", 2.2, 1 + _get_chain_infection_stack_bonus())
		affected_count += 1

	var pulse := BloomPulse.new()
	pulse.position = to_local(world_position)
	pulse.radius = radius_value
	pulse.time_left = bloom_visual_duration_seconds
	_active_visual_pulses.append(pulse)
	queue_redraw()

	if debug_log_bloom:
		print("Chain Bloom triggered at ", world_position, " hitting ", affected_count)
	_play_sfx("sfx_chain_bloom", -5.0, randf_range(0.96, 1.05))

func _is_enemy_still_alive(enemy_node: Node) -> bool:
	if enemy_node == null:
		return false
	if enemy_node.has_method("get_current_hp"):
		return int(enemy_node.call("get_current_hp")) > 0
	return true

func _draw() -> void:
	for pulse in _active_visual_pulses:
		if pulse == null:
			continue
		var ratio: float = clampf(pulse.time_left / maxf(0.01, bloom_visual_duration_seconds), 0.0, 1.0)
		var ring_radius: float = pulse.radius * (1.0 - ratio)
		var color_now: Color = bloom_color
		color_now.a = bloom_color.a * ratio
		draw_arc(pulse.position, ring_radius, 0.0, TAU, 48, color_now, 3.0, true)

func _play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void:
	if _sfx_reentry_guard:
		return
	if audio_manager == null:
		return
	if audio_manager == self:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	_sfx_reentry_guard = true
	audio_manager.call("play_sfx", event_id, volume_db_offset, pitch_scale)
	_sfx_reentry_guard = false
