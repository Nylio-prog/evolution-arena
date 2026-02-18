extends Node

const ENEMY_BASIC_SCENE: PackedScene = preload("res://scenes/actors/enemy_basic.tscn")
const ENEMY_DASHER_SCENE: PackedScene = preload("res://scenes/actors/enemy_dasher.tscn")
const ENEMY_RANGED_SCENE: PackedScene = preload("res://scenes/actors/enemy_ranged.tscn")

@export var initial_wait_time: float = 1.30
@export var min_wait_time: float = 0.22
@export var ramp_duration_seconds: float = 220.0
@export var spawn_ramp_delay_seconds: float = 24.0
@export var spawn_distance: float = 480.0
@export var dasher_initial_ratio: float = 0.35
@export var dasher_max_ratio: float = 0.68
@export var dasher_ramp_start_seconds: float = 0.0
@export var dasher_ratio_wave_strength: float = 0.14
@export var dasher_ratio_wave_period_seconds: float = 34.0
@export var ranged_initial_ratio: float = 0.0
@export var ranged_max_ratio: float = 0.34
@export var ranged_ramp_start_seconds: float = 115.0
@export var ranged_ratio_wave_strength: float = 0.08
@export var ranged_ratio_wave_period_seconds: float = 41.0
@export var batch_ramp_start_seconds: float = 70.0
@export var batch_ramp_end_seconds: float = 360.0
@export var max_spawn_batch: int = 5
@export var post_ramp_batch_growth_interval_seconds: float = 55.0
@export var post_ramp_batch_growth_max_bonus: int = 3
@export var spawn_speed_ramp_start_seconds: float = 70.0
@export var spawn_speed_ramp_end_seconds: float = 260.0
@export var spawn_speed_max_multiplier: float = 1.14
@export var spawn_hp_ramp_start_seconds: float = 45.0
@export var spawn_hp_ramp_end_seconds: float = 300.0
@export var spawn_hp_max_multiplier: float = 1.32
@export var spawn_damage_ramp_start_seconds: float = 130.0
@export var spawn_damage_ramp_end_seconds: float = 360.0
@export var spawn_damage_max_multiplier: float = 1.10
@export var debug_log_spawn: bool = false

@onready var spawn_timer: Timer = get_node_or_null("SpawnTimer")

var _player: Node2D
var _elapsed_seconds: float = 0.0
var _crisis_spawn_wait_multiplier: float = 1.0

func _ready() -> void:
	add_to_group("enemy_spawners")
	if spawn_timer != null:
		spawn_timer.wait_time = initial_wait_time
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _process(delta: float) -> void:
	_elapsed_seconds += delta
	_update_spawn_wait_time()

func set_spawning_enabled(enabled: bool) -> void:
	set_process(enabled)
	if spawn_timer == null:
		return

	if enabled:
		spawn_timer.start()
	else:
		spawn_timer.stop()

func debug_advance_time(seconds: float) -> void:
	if seconds <= 0.0:
		return
	_elapsed_seconds += seconds
	_update_spawn_wait_time()

func set_crisis_spawn_wait_multiplier(multiplier: float) -> void:
	_crisis_spawn_wait_multiplier = clampf(multiplier, 1.0, 4.0)
	_update_spawn_wait_time()

func _on_spawn_timer_timeout() -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(_player):
		return

	var spawn_count: int = _get_spawn_batch_count()
	for _spawn_index in range(spawn_count):
		var angle: float = randf() * TAU
		var offset := Vector2.RIGHT.rotated(angle) * spawn_distance
		var enemy_scene: PackedScene = _select_enemy_scene()
		var enemy_instance := _spawn_enemy_scene(enemy_scene, _player.global_position + offset)
		if enemy_instance == null:
			continue
		if debug_log_spawn:
			print("Spawned enemy at ", enemy_instance.global_position)

func _select_enemy_scene() -> PackedScene:
	var active_ramp_duration: float = maxf(1.0, ramp_duration_seconds - dasher_ramp_start_seconds)
	var ramp_ratio: float = clampf((_elapsed_seconds - dasher_ramp_start_seconds) / active_ramp_duration, 0.0, 1.0)
	var current_dasher_ratio: float = _compute_enemy_ratio(
		dasher_initial_ratio,
		dasher_max_ratio,
		ramp_ratio,
		dasher_ratio_wave_strength,
		dasher_ratio_wave_period_seconds
	)
	var ranged_ramp_duration: float = maxf(1.0, ramp_duration_seconds - ranged_ramp_start_seconds)
	var ranged_ratio: float = clampf((_elapsed_seconds - ranged_ramp_start_seconds) / ranged_ramp_duration, 0.0, 1.0)
	var current_ranged_ratio: float = _compute_enemy_ratio(
		ranged_initial_ratio,
		ranged_max_ratio,
		ranged_ratio,
		ranged_ratio_wave_strength,
		ranged_ratio_wave_period_seconds
	)

	var total_special_ratio: float = clampf(current_dasher_ratio + current_ranged_ratio, 0.0, 0.92)
	var roll: float = randf()
	if roll < current_ranged_ratio:
		return ENEMY_RANGED_SCENE
	if roll < total_special_ratio:
		return ENEMY_DASHER_SCENE
	return ENEMY_BASIC_SCENE

func spawn_enemy_immediate(enemy_scene: PackedScene, world_position: Vector2, apply_scaling: bool = true) -> Node2D:
	return _spawn_enemy_scene(enemy_scene, world_position, apply_scaling)

func debug_get_elapsed_seconds() -> float:
	return _elapsed_seconds

func _spawn_enemy_scene(enemy_scene: PackedScene, world_position: Vector2, apply_scaling: bool = true) -> Node2D:
	if enemy_scene == null:
		return null
	var enemy_instance := enemy_scene.instantiate() as Node2D
	if enemy_instance == null:
		return null
	enemy_instance.global_position = world_position
	if apply_scaling:
		_apply_runtime_spawn_scaling(enemy_instance)
	var spawn_parent: Node = get_tree().current_scene
	if spawn_parent == null:
		spawn_parent = get_tree().root
	spawn_parent.add_child(enemy_instance)
	return enemy_instance

func _compute_enemy_ratio(
	initial_ratio: float,
	max_ratio: float,
	ramp_ratio: float,
	wave_strength: float,
	wave_period_seconds: float
) -> float:
	var ratio_value: float = lerpf(initial_ratio, max_ratio, clampf(ramp_ratio, 0.0, 1.0))
	var period_seconds: float = maxf(4.0, wave_period_seconds)
	var wave_phase: float = (_elapsed_seconds / period_seconds) * TAU
	var wave_offset: float = sin(wave_phase) * clampf(wave_strength, 0.0, 0.45)
	return clampf(ratio_value + wave_offset, 0.0, 0.90)

func _get_spawn_batch_count() -> int:
	var safe_max_spawn_batch: int = maxi(1, max_spawn_batch)
	var clamped_start: float = maxf(0.0, batch_ramp_start_seconds)
	var clamped_end: float = maxf(clamped_start + 0.01, batch_ramp_end_seconds)
	var ramp_ratio: float = clampf((_elapsed_seconds - clamped_start) / (clamped_end - clamped_start), 0.0, 1.0)
	var base_batch: int = 1 + int(floor(ramp_ratio * float(safe_max_spawn_batch - 1)))

	var post_ramp_bonus: int = 0
	if _elapsed_seconds > clamped_end:
		var growth_interval: float = maxf(1.0, post_ramp_batch_growth_interval_seconds)
		var bonus_steps: int = int(floor((_elapsed_seconds - clamped_end) / growth_interval))
		post_ramp_bonus = mini(maxi(0, post_ramp_batch_growth_max_bonus), maxi(0, bonus_steps))

	var hard_cap: int = safe_max_spawn_batch + maxi(0, post_ramp_batch_growth_max_bonus)
	return clampi(base_batch + post_ramp_bonus, 1, hard_cap)

func _apply_runtime_spawn_scaling(enemy_instance: Node2D) -> void:
	if enemy_instance == null:
		return
	if not enemy_instance.has_method("apply_spawn_scaling"):
		return

	var speed_multiplier: float = _compute_ramp_multiplier(
		spawn_speed_ramp_start_seconds,
		spawn_speed_ramp_end_seconds,
		spawn_speed_max_multiplier
	)
	var hp_multiplier: float = _compute_ramp_multiplier(
		spawn_hp_ramp_start_seconds,
		spawn_hp_ramp_end_seconds,
		spawn_hp_max_multiplier
	)
	var damage_multiplier: float = _compute_ramp_multiplier(
		spawn_damage_ramp_start_seconds,
		spawn_damage_ramp_end_seconds,
		spawn_damage_max_multiplier
	)
	enemy_instance.call("apply_spawn_scaling", speed_multiplier, hp_multiplier, damage_multiplier)

func _compute_ramp_multiplier(start_seconds: float, end_seconds: float, max_multiplier: float) -> float:
	if max_multiplier <= 1.0:
		return 1.0
	var clamped_start: float = maxf(0.0, start_seconds)
	var clamped_end: float = maxf(clamped_start + 0.01, end_seconds)
	var ramp_ratio: float = clampf((_elapsed_seconds - clamped_start) / (clamped_end - clamped_start), 0.0, 1.0)
	return lerpf(1.0, max_multiplier, ramp_ratio)

func _update_spawn_wait_time() -> void:
	if spawn_timer == null:
		return

	var effective_elapsed_seconds: float = maxf(0.0, _elapsed_seconds - spawn_ramp_delay_seconds)
	var ramp_ratio: float = clampf(effective_elapsed_seconds / maxf(1.0, ramp_duration_seconds), 0.0, 1.0)
	var current_wait_time: float = lerpf(initial_wait_time, min_wait_time, ramp_ratio)
	spawn_timer.wait_time = current_wait_time * _crisis_spawn_wait_multiplier
