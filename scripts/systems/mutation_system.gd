extends Node

const MUTATIONS_DATA = preload("res://data/mutations.gd")
const SPIKE_RING_SCENE: PackedScene = preload("res://scenes/modules/spike_ring.tscn")
const ORBITER_SCENE: PackedScene = preload("res://scenes/modules/orbiter.tscn")
const LINEAGES: Dictionary = {
	"predator": "Predator",
	"swarm": "Swarm",
	"bulwark": "Bulwark"
}

signal mutation_applied(mutation_id: String, new_level: int)
signal lineage_changed(lineage_id: String, lineage_name: String)

@export_range(0, 3) var starting_spikes_level: int = 1
@export_range(0, 3) var starting_orbiters_level: int = 0

var player: Node2D
var mutation_defs: Dictionary = {}
var mutation_levels: Dictionary = {}
var current_levelup_options: Array[Dictionary] = []
var current_lineage_id: String = ""

var spike_ring_instance: Node2D
var orbiter_instance: Node2D

func _ready() -> void:
	mutation_defs = MUTATIONS_DATA.get_all()
	_initialize_levels()

func setup(player_node: Node) -> void:
	player = player_node as Node2D
	_apply_starting_loadout()

func get_levelup_options(count: int = 3) -> Array[Dictionary]:
	var available_ids: Array[String] = _get_available_mutation_ids()
	if available_ids.is_empty():
		current_levelup_options = []
		return current_levelup_options

	var selected_ids: Array[String] = []
	var pool: Array[String] = []
	pool.append_array(available_ids)

	while selected_ids.size() < count and pool.size() > 0:
		var index: int = randi() % pool.size()
		selected_ids.append(pool[index])
		pool.remove_at(index)

	while selected_ids.size() < count:
		var filler_index: int = randi() % available_ids.size()
		selected_ids.append(available_ids[filler_index])

	var options: Array[Dictionary] = []
	for mutation_id in selected_ids:
		options.append(_build_option(mutation_id))

	current_levelup_options = options
	return current_levelup_options

func apply_option_index(index: int) -> bool:
	if index < 0 or index >= current_levelup_options.size():
		return false

	var option: Dictionary = current_levelup_options[index]
	var mutation_id: String = String(option.get("id", ""))
	return apply_mutation(mutation_id)

func apply_mutation(mutation_id: String) -> bool:
	if not mutation_defs.has(mutation_id):
		return false

	var current_level: int = int(mutation_levels.get(mutation_id, 0))
	var max_level: int = _get_mutation_max_level(mutation_id)
	if current_level >= max_level:
		return false

	var new_level: int = current_level + 1
	mutation_levels[mutation_id] = new_level
	_apply_mutation_effect(mutation_id, new_level)
	mutation_applied.emit(mutation_id, new_level)
	return true

func choose_lineage(lineage_id: String) -> bool:
	var normalized_id: String = lineage_id.strip_edges().to_lower()
	if not LINEAGES.has(normalized_id):
		return false
	if not current_lineage_id.is_empty() and current_lineage_id != normalized_id:
		return false

	current_lineage_id = normalized_id
	lineage_changed.emit(current_lineage_id, get_current_lineage_name())
	return true

func get_current_lineage_id() -> String:
	return current_lineage_id

func get_current_lineage_name() -> String:
	if current_lineage_id.is_empty():
		return "None"
	return String(LINEAGES.get(current_lineage_id, current_lineage_id.capitalize()))

func _initialize_levels() -> void:
	mutation_levels.clear()
	for id_value in mutation_defs.keys():
		var mutation_id: String = String(id_value)
		mutation_levels[mutation_id] = 0

func _apply_starting_loadout() -> void:
	if player == null:
		return

	for _i in range(clampi(starting_spikes_level, 0, _get_mutation_max_level("spikes"))):
		apply_mutation("spikes")
	for _i in range(clampi(starting_orbiters_level, 0, _get_mutation_max_level("orbiters"))):
		apply_mutation("orbiters")

func _get_available_mutation_ids() -> Array[String]:
	var ids: Array[String] = []
	for id_value in mutation_defs.keys():
		var mutation_id: String = String(id_value)
		var current_level: int = int(mutation_levels.get(mutation_id, 0))
		if current_level < _get_mutation_max_level(mutation_id):
			ids.append(mutation_id)
	return ids

func _build_option(mutation_id: String) -> Dictionary:
	var mutation_def: Dictionary = mutation_defs.get(mutation_id, {})
	var current_level: int = int(mutation_levels.get(mutation_id, 0))
	var next_level: int = current_level + 1
	var levels: Dictionary = mutation_def.get("levels", {})
	var level_data: Dictionary = levels.get(next_level, {})

	var option: Dictionary = {
		"id": mutation_id,
		"name": String(mutation_def.get("name", mutation_id.capitalize())),
		"next_level": next_level,
		"short": String(level_data.get("short", "")),
		"description": String(level_data.get("description", mutation_def.get("description", "")))
	}
	return option

func _apply_mutation_effect(mutation_id: String, new_level: int) -> void:
	if player == null:
		return

	match mutation_id:
		"spikes":
			_ensure_spike_ring()
			if spike_ring_instance != null and spike_ring_instance.has_method("set_level"):
				spike_ring_instance.call("set_level", new_level)
		"orbiters":
			_ensure_orbiter()
			if orbiter_instance != null and orbiter_instance.has_method("set_level"):
				orbiter_instance.call("set_level", new_level)

func _ensure_spike_ring() -> void:
	if spike_ring_instance != null:
		return
	if player == null:
		return

	spike_ring_instance = SPIKE_RING_SCENE.instantiate() as Node2D
	if spike_ring_instance != null:
		player.add_child(spike_ring_instance)

func _ensure_orbiter() -> void:
	if orbiter_instance != null:
		return
	if player == null:
		return

	orbiter_instance = ORBITER_SCENE.instantiate() as Node2D
	if orbiter_instance != null:
		player.add_child(orbiter_instance)

func _get_mutation_max_level(mutation_id: String) -> int:
	var mutation_def: Dictionary = mutation_defs.get(mutation_id, {})
	return int(mutation_def.get("max_level", 0))
