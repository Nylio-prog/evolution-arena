extends Node

const ENEMY_BASIC_SCENE: PackedScene = preload("res://scenes/actors/enemy_basic.tscn")
const ENEMY_DASHER_SCENE: PackedScene = preload("res://scenes/actors/enemy_dasher.tscn")

@export var initial_wait_time: float = 1.0
@export var min_wait_time: float = 0.25
@export var ramp_duration_seconds: float = 120.0
@export var spawn_distance: float = 480.0
@export var dasher_initial_ratio: float = 0.35
@export var dasher_max_ratio: float = 0.60
@export var dasher_ramp_start_seconds: float = 0.0
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

	var angle: float = randf() * TAU
	var offset := Vector2.RIGHT.rotated(angle) * spawn_distance
	var enemy_scene: PackedScene = _select_enemy_scene()
	var enemy_instance := enemy_scene.instantiate() as Node2D
	if enemy_instance == null:
		return

	enemy_instance.global_position = _player.global_position + offset
	var spawn_parent: Node = get_tree().current_scene
	if spawn_parent == null:
		spawn_parent = get_tree().root
	spawn_parent.add_child(enemy_instance)

	if debug_log_spawn:
		print("Spawned enemy at ", enemy_instance.global_position)

func _select_enemy_scene() -> PackedScene:
	var active_ramp_duration: float = maxf(1.0, ramp_duration_seconds - dasher_ramp_start_seconds)
	var ramp_ratio: float = clampf((_elapsed_seconds - dasher_ramp_start_seconds) / active_ramp_duration, 0.0, 1.0)
	var current_dasher_ratio: float = lerpf(dasher_initial_ratio, dasher_max_ratio, ramp_ratio)
	if randf() < current_dasher_ratio:
		return ENEMY_DASHER_SCENE
	return ENEMY_BASIC_SCENE

func _update_spawn_wait_time() -> void:
	if spawn_timer == null:
		return

	var ramp_ratio: float = clampf(_elapsed_seconds / ramp_duration_seconds, 0.0, 1.0)
	var current_wait_time: float = lerpf(initial_wait_time, min_wait_time, ramp_ratio)
	spawn_timer.wait_time = current_wait_time * _crisis_spawn_wait_multiplier
