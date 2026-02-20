extends Node

signal crisis_phase_changed(new_phase: String, crisis_id: String)
signal crisis_started(crisis_id: String, is_final: bool, duration_seconds: float)
signal crisis_reward_started(crisis_id: String, duration_seconds: float)
signal final_crisis_completed()
signal final_crisis_failed(crisis_id: String)

const EVENT_SCHEDULE: Array[Dictionary] = [
	{"id": "uv_sweep_grid", "start": 50.0, "duration": 14.0, "reward": 5.0, "final": false},
	{"id": "hunter_deployment", "start": 105.0, "duration": 16.0, "reward": 5.0, "final": false},
	{"id": "decon_flood", "start": 160.0, "duration": 17.0, "reward": 5.0, "final": false},
	{"id": "containment_warden", "start": 220.0, "duration": 24.0, "reward": 6.0, "final": false},
	{"id": "hunter_deployment", "start": 275.0, "duration": 15.0, "reward": 5.0, "final": false},
	{"id": "containment_seal", "start": 330.0, "duration": 17.0, "reward": 5.0, "final": false},
	{"id": "protocol_omega_core", "start": 395.0, "duration": 90.0, "reward": 0.0, "final": true}
]

@export var debug_log_state: bool = true

var _phase: String = "idle"
var _active_crisis_id: String = ""
var _is_final_crisis: bool = false
var _phase_elapsed_seconds: float = 0.0
var _active_duration_seconds: float = 0.0
var _active_reward_duration_seconds: float = 0.0
var _next_event_index: int = 0
var _final_crisis_completed: bool = false

func reset_runtime_state() -> void:
	_phase = "idle"
	_active_crisis_id = ""
	_is_final_crisis = false
	_phase_elapsed_seconds = 0.0
	_active_duration_seconds = 0.0
	_active_reward_duration_seconds = 0.0
	_next_event_index = 0
	_final_crisis_completed = false

func tick(delta: float, run_elapsed_seconds: float) -> void:
	if delta <= 0.0:
		return
	if _final_crisis_completed:
		return

	if _phase == "idle":
		_process_idle(run_elapsed_seconds)
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
		"active", "reward", "final":
			return maxf(0.0, _active_duration_seconds - _phase_elapsed_seconds)
		_:
			return 0.0

func get_time_until_next_crisis(run_elapsed_seconds: float) -> float:
	if _phase != "idle":
		return 0.0
	if _next_event_index >= EVENT_SCHEDULE.size():
		return 0.0
	var next_event: Dictionary = EVENT_SCHEDULE[_next_event_index]
	return maxf(0.0, float(next_event.get("start", 0.0)) - run_elapsed_seconds)

func get_final_crisis_start_seconds() -> float:
	for event_def in EVENT_SCHEDULE:
		if bool(event_def.get("final", false)):
			return float(event_def.get("start", 0.0))
	return 450.0

func debug_force_next_active_crisis(run_elapsed_seconds: float) -> bool:
	if _final_crisis_completed:
		return false
	if _next_event_index >= EVENT_SCHEDULE.size() and _phase == "idle":
		return false

	if _phase == "active" or _phase == "reward":
		_enter_idle_phase()

	if _next_event_index >= EVENT_SCHEDULE.size():
		return false

	var event_def: Dictionary = EVENT_SCHEDULE[_next_event_index]
	var event_start: float = float(event_def.get("start", 0.0))
	if run_elapsed_seconds < event_start:
		_start_event(event_def)
		_next_event_index += 1
		return true

	_start_event(event_def)
	_next_event_index += 1
	return true

func complete_active_crisis_early(expected_crisis_id: String = "") -> bool:
	if _phase != "active":
		return false
	if _is_final_crisis:
		return false
	if not expected_crisis_id.is_empty() and _active_crisis_id != expected_crisis_id:
		return false

	_enter_reward_phase(_active_reward_duration_seconds)
	return true

func complete_reward_phase_early() -> bool:
	if _phase != "reward":
		return false
	_enter_idle_phase()
	return true

func complete_final_crisis_early(expected_crisis_id: String = "") -> bool:
	if _phase != "final":
		return false
	if not expected_crisis_id.is_empty() and _active_crisis_id != expected_crisis_id:
		return false
	if _final_crisis_completed:
		return false

	_phase = "victory"
	_final_crisis_completed = true
	_emit_phase_changed("victory", _active_crisis_id)
	if debug_log_state:
		print("[EventDirector] Final event completed early by boss defeat")
	final_crisis_completed.emit()
	return true

func _process_idle(run_elapsed_seconds: float) -> void:
	if _next_event_index >= EVENT_SCHEDULE.size():
		return
	var next_event: Dictionary = EVENT_SCHEDULE[_next_event_index]
	var start_time: float = float(next_event.get("start", 0.0))
	if run_elapsed_seconds < start_time:
		return
	_start_event(next_event)
	_next_event_index += 1

func _process_active() -> void:
	if _phase_elapsed_seconds < _active_duration_seconds:
		return
	if _active_reward_duration_seconds > 0.0:
		_enter_reward_phase(_active_reward_duration_seconds)
		return
	_enter_idle_phase()

func _process_reward() -> void:
	if _phase_elapsed_seconds < _active_duration_seconds:
		return
	_enter_idle_phase()

func _process_final() -> void:
	if _phase_elapsed_seconds < _active_duration_seconds:
		return
	_phase = "failed"
	_final_crisis_completed = true
	_emit_phase_changed("failed", _active_crisis_id)
	if debug_log_state:
		print("[EventDirector] Final event timer expired -> failure")
	final_crisis_failed.emit(_active_crisis_id)

func _start_event(event_def: Dictionary) -> void:
	_active_crisis_id = String(event_def.get("id", ""))
	_is_final_crisis = bool(event_def.get("final", false))
	_phase_elapsed_seconds = 0.0
	_active_duration_seconds = maxf(1.0, float(event_def.get("duration", 10.0)))
	_active_reward_duration_seconds = maxf(0.0, float(event_def.get("reward", 0.0)))

	if _is_final_crisis:
		_phase = "final"
		_emit_phase_changed("final", _active_crisis_id)
		crisis_started.emit(_active_crisis_id, true, _active_duration_seconds)
		if debug_log_state:
			print("[EventDirector] Final event started: %s (%.1fs)" % [_active_crisis_id, _active_duration_seconds])
		return

	_phase = "active"
	_emit_phase_changed("active", _active_crisis_id)
	crisis_started.emit(_active_crisis_id, false, _active_duration_seconds)
	if debug_log_state:
		print("[EventDirector] Event started: %s (%.1fs)" % [_active_crisis_id, _active_duration_seconds])

func _enter_reward_phase(duration_seconds: float) -> void:
	_phase = "reward"
	_phase_elapsed_seconds = 0.0
	_active_duration_seconds = maxf(0.1, duration_seconds)
	_emit_phase_changed("reward", _active_crisis_id)
	crisis_reward_started.emit(_active_crisis_id, _active_duration_seconds)
	if debug_log_state:
		print("[EventDirector] Reward phase: %s (%.1fs)" % [_active_crisis_id, _active_duration_seconds])

func _enter_idle_phase() -> void:
	_phase = "idle"
	_phase_elapsed_seconds = 0.0
	_active_duration_seconds = 0.0
	_active_reward_duration_seconds = 0.0
	_active_crisis_id = ""
	_is_final_crisis = false
	_emit_phase_changed("idle", "")
	if debug_log_state:
		print("[EventDirector] Back to idle")

func _emit_phase_changed(phase_name: String, crisis_id: String) -> void:
	crisis_phase_changed.emit(phase_name, crisis_id)
