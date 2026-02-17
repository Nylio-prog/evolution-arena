extends Node

signal crisis_phase_changed(new_phase: String, crisis_id: String)
signal crisis_started(crisis_id: String, is_final: bool, duration_seconds: float)
signal crisis_reward_started(crisis_id: String, duration_seconds: float)
signal final_crisis_completed()

const CRISIS_TYPES: Array[String] = [
	"containment_sweep",
	"strain_bloom",
	"biohazard_leak"
]

@export var debug_log_state: bool = true
@export var first_crisis_delay_seconds: float = 45.0
@export var crisis_interval_seconds: float = 50.0
@export var crisis_duration_seconds: float = 14.0
@export var reward_duration_seconds: float = 6.0
@export var final_crisis_start_seconds: float = 480.0
@export var final_crisis_duration_seconds: float = 25.0

var _phase: String = "idle"
var _active_crisis_id: String = ""
var _is_final_crisis: bool = false
var _phase_elapsed_seconds: float = 0.0
var _next_regular_crisis_start_seconds: float = 0.0
var _next_crisis_index: int = 0
var _final_crisis_completed: bool = false

func reset_runtime_state() -> void:
	_phase = "idle"
	_active_crisis_id = ""
	_is_final_crisis = false
	_phase_elapsed_seconds = 0.0
	_next_regular_crisis_start_seconds = first_crisis_delay_seconds
	_next_crisis_index = 0
	_final_crisis_completed = false

func tick(delta: float, run_elapsed_seconds: float) -> void:
	if delta <= 0.0:
		return
	if _final_crisis_completed:
		return

	if _phase == "idle":
		_process_idle(delta, run_elapsed_seconds)
		return

	_phase_elapsed_seconds += delta
	if _phase == "active":
		_process_active()
		return
	if _phase == "reward":
		_process_reward()
		return
	if _phase == "final":
		_process_final()
		return

func get_phase() -> String:
	return _phase

func get_active_crisis_id() -> String:
	return _active_crisis_id

func get_phase_time_remaining() -> float:
	match _phase:
		"active":
			return maxf(0.0, crisis_duration_seconds - _phase_elapsed_seconds)
		"reward":
			return maxf(0.0, reward_duration_seconds - _phase_elapsed_seconds)
		"final":
			return maxf(0.0, final_crisis_duration_seconds - _phase_elapsed_seconds)
		_:
			return 0.0

func get_time_until_next_crisis(run_elapsed_seconds: float) -> float:
	if _phase != "idle":
		return 0.0
	if _final_crisis_completed:
		return 0.0

	var time_until_final: float = maxf(0.0, final_crisis_start_seconds - run_elapsed_seconds)
	var time_until_regular: float = maxf(0.0, _next_regular_crisis_start_seconds - run_elapsed_seconds)
	if _next_regular_crisis_start_seconds < final_crisis_start_seconds:
		return minf(time_until_regular, time_until_final)
	return time_until_final

func _process_idle(_delta: float, run_elapsed_seconds: float) -> void:
	if run_elapsed_seconds >= final_crisis_start_seconds:
		_start_crisis("purge_protocol", true)
		return

	if run_elapsed_seconds < _next_regular_crisis_start_seconds:
		return

	var crisis_id: String = _get_next_regular_crisis_id()
	_start_crisis(crisis_id, false)
	_next_regular_crisis_start_seconds += crisis_interval_seconds

func _process_active() -> void:
	if _phase_elapsed_seconds < crisis_duration_seconds:
		return

	_enter_reward_phase()

func _process_reward() -> void:
	if _phase_elapsed_seconds < reward_duration_seconds:
		return

	_enter_idle_phase()

func _process_final() -> void:
	if _phase_elapsed_seconds < final_crisis_duration_seconds:
		return

	_phase = "victory"
	_final_crisis_completed = true
	_emit_phase_changed("victory", _active_crisis_id)
	if debug_log_state:
		print("[CrisisDirector] Final crisis completed -> victory")
	final_crisis_completed.emit()

func _start_crisis(crisis_id: String, is_final: bool) -> void:
	_phase_elapsed_seconds = 0.0
	_active_crisis_id = crisis_id
	_is_final_crisis = is_final

	if is_final:
		_phase = "final"
		_emit_phase_changed("final", _active_crisis_id)
		crisis_started.emit(_active_crisis_id, true, final_crisis_duration_seconds)
		if debug_log_state:
			print("[CrisisDirector] Final crisis started: %s (%.1fs)" % [_active_crisis_id, final_crisis_duration_seconds])
		return

	_phase = "active"
	_emit_phase_changed("active", _active_crisis_id)
	crisis_started.emit(_active_crisis_id, false, crisis_duration_seconds)
	if debug_log_state:
		print("[CrisisDirector] Crisis started: %s (%.1fs)" % [_active_crisis_id, crisis_duration_seconds])

func _enter_reward_phase() -> void:
	_phase = "reward"
	_phase_elapsed_seconds = 0.0
	_emit_phase_changed("reward", _active_crisis_id)
	crisis_reward_started.emit(_active_crisis_id, reward_duration_seconds)
	if debug_log_state:
		print("[CrisisDirector] Reward phase: %s (%.1fs)" % [_active_crisis_id, reward_duration_seconds])

func _enter_idle_phase() -> void:
	_phase = "idle"
	_phase_elapsed_seconds = 0.0
	_active_crisis_id = ""
	_is_final_crisis = false
	_emit_phase_changed("idle", "")
	if debug_log_state:
		print("[CrisisDirector] Back to idle")

func _get_next_regular_crisis_id() -> String:
	if CRISIS_TYPES.is_empty():
		return "containment_sweep"
	var crisis_id: String = CRISIS_TYPES[_next_crisis_index]
	_next_crisis_index = (_next_crisis_index + 1) % CRISIS_TYPES.size()
	return crisis_id

func _emit_phase_changed(phase_name: String, crisis_id: String) -> void:
	crisis_phase_changed.emit(phase_name, crisis_id)
