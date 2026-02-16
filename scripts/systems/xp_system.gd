extends Node

signal xp_changed(current_xp: int, xp_to_next_level: int)
signal level_changed(current_level: int)
signal leveled_up(new_level: int)

@export var debug_log_xp: bool = true

var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 10

func _ready() -> void:
	xp_to_next_level = _xp_required_for_level(current_level)
	level_changed.emit(current_level)
	xp_changed.emit(current_xp, xp_to_next_level)

func add_xp(amount: int) -> void:
	if amount <= 0:
		return

	current_xp += amount
	if debug_log_xp:
		print("XP +", amount, " -> ", current_xp, "/", xp_to_next_level)

	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		current_level += 1
		xp_to_next_level = _xp_required_for_level(current_level)
		level_changed.emit(current_level)
		leveled_up.emit(current_level)
		if debug_log_xp:
			print("Leveled up to ", current_level, ". Next XP: ", xp_to_next_level)

	xp_changed.emit(current_xp, xp_to_next_level)

func _xp_required_for_level(level: int) -> int:
	return 10 + (level - 1) * 5
