extends Node

signal xp_changed(current_xp: int, xp_to_next_level: int)
signal level_changed(current_level: int)
signal leveled_up(new_level: int)

@export var debug_log_xp: bool = false
@export var base_xp_requirement: int = 12
@export var per_level_xp_increment: int = 7
@export var quadratic_growth_start_level: int = 5
@export var quadratic_growth_per_level_squared: int = 3
@export var late_growth_start_level: int = 11
@export var late_growth_per_level: int = 6

var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 12

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
	var level_offset: int = maxi(0, level - 1)
	var linear_component: int = base_xp_requirement + (level_offset * per_level_xp_increment)
	var quadratic_offset: int = maxi(0, level - quadratic_growth_start_level)
	var quadratic_component: int = quadratic_offset * quadratic_offset * quadratic_growth_per_level_squared
	var late_offset: int = maxi(0, level - late_growth_start_level)
	var late_component: int = late_offset * late_growth_per_level
	return maxi(1, linear_component + quadratic_component + late_component)
