extends Node2D

@export var base_scan_interval_seconds: float = 2.2
@export var base_range: float = 220.0
@export var base_host_duration_seconds: float = 8.0
@export var base_max_hosts: int = 1
@export var conversion_flash_color: Color = Color(0.62, 1.0, 0.84, 1.0)
@export var debug_log_conversion: bool = false

@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")

var override_level: int = 0
var _runtime_cooldown_multiplier: float = 1.0
var _time_until_scan: float = 0.0
var _last_conversion_position: Vector2 = Vector2.ZERO
var _last_conversion_flash_time: float = 0.0

func _ready() -> void:
	add_to_group("player_modules")
	set_level(0)

func _physics_process(delta: float) -> void:
	if override_level <= 0:
		return
	_time_until_scan = maxf(0.0, _time_until_scan - delta)
	_last_conversion_flash_time = maxf(0.0, _last_conversion_flash_time - delta)
	if _time_until_scan > 0.0:
		if _last_conversion_flash_time > 0.0:
			queue_redraw()
		return

	_try_convert_target()
	_time_until_scan = _get_effective_scan_interval_seconds()
	queue_redraw()

func set_level(new_level: int) -> void:
	override_level = clampi(new_level, 0, 5)
	_time_until_scan = minf(_time_until_scan, _get_effective_scan_interval_seconds())

func set_runtime_modifiers(_damage_multiplier: float, cooldown_multiplier: float) -> void:
	_runtime_cooldown_multiplier = maxf(0.1, cooldown_multiplier)

func _get_effective_scan_interval_seconds() -> float:
	if override_level <= 0:
		return 999.0
	var interval_seconds: float = base_scan_interval_seconds
	match override_level:
		2:
			interval_seconds *= 0.88
		3:
			interval_seconds *= 0.76
		4:
			interval_seconds *= 0.66
		5:
			interval_seconds *= 0.58
	return maxf(0.20, interval_seconds * _runtime_cooldown_multiplier)

func _get_effective_range() -> float:
	if override_level <= 0:
		return 0.0
	var range_value: float = base_range
	match override_level:
		2:
			range_value += 40.0
		3:
			range_value += 70.0
		4:
			range_value += 100.0
		5:
			range_value += 130.0
	return range_value

func _get_conversion_threshold_ratio() -> float:
	match override_level:
		1:
			return 0.25
		2:
			return 0.40
		3:
			return 0.55
		4:
			return 0.65
		5:
			return 0.75
		_:
			return 0.0

func _get_effective_host_duration() -> float:
	var duration_seconds: float = base_host_duration_seconds
	match override_level:
		2:
			duration_seconds += 3.0
		3:
			duration_seconds += 6.0
		4:
			duration_seconds += 9.0
		5:
			duration_seconds += 12.0
	return duration_seconds

func _get_effective_max_hosts() -> int:
	var host_count: int = base_max_hosts
	match override_level:
		2:
			host_count += 1
		3:
			host_count += 2
		4:
			host_count += 3
		5:
			host_count += 4
	return maxi(1, host_count)

func _count_active_hosts() -> int:
	var host_count: int = 0
	for host_variant in get_tree().get_nodes_in_group("allied_hosts"):
		var host_node := host_variant as Node
		if host_node == null:
			continue
		if not is_instance_valid(host_node):
			continue
		if host_node.is_queued_for_deletion():
			continue
		host_count += 1
	return host_count

func _try_convert_target() -> void:
	if _count_active_hosts() >= _get_effective_max_hosts():
		return

	var owner_player := get_parent() as Node2D
	if owner_player == null:
		return

	var range_value: float = _get_effective_range()
	var threshold_ratio: float = _get_conversion_threshold_ratio()
	var best_target: Node2D
	var best_score: float = INF
	for enemy_variant in get_tree().get_nodes_in_group("enemies"):
		var enemy_node := enemy_variant as Node2D
		if enemy_node == null:
			continue
		if enemy_node.is_in_group("elite_enemies"):
			continue
		if enemy_node.has_method("is_elite_enemy") and bool(enemy_node.call("is_elite_enemy")):
			continue
		if enemy_node.has_method("is_converted_host") and bool(enemy_node.call("is_converted_host")):
			continue
		if not enemy_node.has_method("convert_to_host_ally"):
			continue
		if not enemy_node.has_method("get_current_hp") or not enemy_node.has_method("get_max_hp"):
			continue
		var distance_to_enemy: float = owner_player.global_position.distance_to(enemy_node.global_position)
		if distance_to_enemy > range_value:
			continue
		var hp_value: int = int(enemy_node.call("get_current_hp"))
		var max_hp_value: int = maxi(1, int(enemy_node.call("get_max_hp")))
		var hp_ratio: float = float(hp_value) / float(max_hp_value)
		if hp_ratio > threshold_ratio:
			continue
		if distance_to_enemy < best_score:
			best_score = distance_to_enemy
			best_target = enemy_node

	if best_target == null:
		return
	if not bool(best_target.call("convert_to_host_ally", _get_effective_host_duration())):
		return

	if owner_player.has_method("heal"):
		owner_player.call("heal", 2 + override_level)
	_last_conversion_position = to_local(best_target.global_position)
	_last_conversion_flash_time = 0.16
	_play_sfx("sfx_host_override_cast", -4.0, randf_range(0.97, 1.04))
	if debug_log_conversion:
		print("Host Override converted target at ", best_target.global_position)

func _draw() -> void:
	if _last_conversion_flash_time <= 0.0:
		return
	var ratio: float = clampf(_last_conversion_flash_time / 0.16, 0.0, 1.0)
	var color_now: Color = conversion_flash_color
	color_now.a = conversion_flash_color.a * ratio
	draw_circle(_last_conversion_position, 18.0 + (12.0 * (1.0 - ratio)), color_now)

func _play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id, volume_db_offset, pitch_scale)
