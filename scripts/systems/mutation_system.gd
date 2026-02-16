extends Node

const MUTATIONS_DATA = preload("res://data/mutations.gd")
const SPIKE_RING_SCENE: PackedScene = preload("res://scenes/modules/spike_ring.tscn")
const ORBITER_SCENE: PackedScene = preload("res://scenes/modules/orbiter.tscn")
const MEMBRANE_SCENE: PackedScene = preload("res://scenes/modules/membrane.tscn")
const PULSE_NOVA_SCENE: PackedScene = preload("res://scenes/modules/pulse_nova.tscn")
const ACID_TRAIL_SCENE: PackedScene = preload("res://scenes/modules/acid_trail.tscn")
const METABOLISM_SCENE: PackedScene = preload("res://scenes/modules/metabolism.tscn")
const LINEAGES: Dictionary = {
	"predator": "Predator",
	"swarm": "Swarm",
	"bulwark": "Bulwark"
}
const LINEAGE_VISUALS: Dictionary = {
	"predator": {
		"player_accent": Color(1.0, 0.45, 0.25, 0.95),
		"spike_color": Color(1.0, 0.55, 0.35, 1.0),
		"orbiter_color": Color(1.0, 0.45, 0.35, 1.0),
		"membrane_color": Color(1.0, 0.50, 0.30, 0.85),
		"pulse_color": Color(1.0, 0.58, 0.42, 1.0),
		"acid_color": Color(1.0, 0.57, 0.32, 0.55),
		"metabolism_color": Color(1.0, 0.67, 0.40, 0.95)
	},
	"swarm": {
		"player_accent": Color(0.35, 1.0, 0.85, 0.95),
		"spike_color": Color(0.55, 1.0, 0.90, 1.0),
		"orbiter_color": Color(0.40, 1.0, 0.85, 1.0),
		"membrane_color": Color(0.45, 1.0, 0.90, 0.85),
		"pulse_color": Color(0.38, 1.0, 0.88, 1.0),
		"acid_color": Color(0.42, 1.0, 0.86, 0.55),
		"metabolism_color": Color(0.48, 1.0, 0.84, 0.95)
	},
	"bulwark": {
		"player_accent": Color(1.0, 0.85, 0.35, 0.95),
		"spike_color": Color(1.0, 0.90, 0.45, 1.0),
		"orbiter_color": Color(1.0, 0.85, 0.55, 1.0),
		"membrane_color": Color(1.0, 0.90, 0.55, 0.88),
		"pulse_color": Color(1.0, 0.90, 0.58, 1.0),
		"acid_color": Color(0.95, 0.92, 0.52, 0.55),
		"metabolism_color": Color(1.0, 0.94, 0.62, 0.95)
	}
}
const DEFAULT_PLAYER_ACCENT: Color = Color(1.0, 1.0, 1.0, 0.0)
const DEFAULT_SPIKE_COLOR: Color = Color(0.95, 0.95, 0.95, 1.0)
const DEFAULT_ORBITER_COLOR: Color = Color(0.85, 0.95, 1.0, 1.0)
const DEFAULT_MEMBRANE_COLOR: Color = Color(0.75, 0.95, 1.0, 0.8)
const DEFAULT_PULSE_COLOR: Color = Color(0.75, 0.95, 1.0, 0.95)
const DEFAULT_ACID_COLOR: Color = Color(0.42, 1.0, 0.86, 0.50)
const DEFAULT_METABOLISM_COLOR: Color = Color(0.75, 1.0, 0.78, 0.95)
const WEIGHT_BASE: float = 1.0
const WEIGHT_DEFAULT_SAME_LINEAGE_BONUS: float = 2.0
const WEIGHT_DEFAULT_OFF_LINEAGE_BONUS: float = 0.2

signal mutation_applied(mutation_id: String, new_level: int)
signal lineage_changed(lineage_id: String, lineage_name: String)

@export_range(0, 3) var starting_spikes_level: int = 1
@export_range(0, 3) var starting_orbiters_level: int = 0
@export_range(0, 3) var starting_membrane_level: int = 0
@export_range(0, 3) var starting_pulse_nova_level: int = 0
@export_range(0, 3) var starting_acid_trail_level: int = 0
@export_range(0, 3) var starting_metabolism_level: int = 0
@export var debug_log_weighted_rolls: bool = false

var player: Node2D
var mutation_defs: Dictionary = {}
var mutation_levels: Dictionary = {}
var current_levelup_options: Array[Dictionary] = []
var current_lineage_id: String = ""

var spike_ring_instance: Node2D
var orbiter_instance: Node2D
var membrane_instance: Node2D
var pulse_nova_instance: Node2D
var acid_trail_instance: Node2D
var metabolism_instance: Node2D

func _ready() -> void:
	mutation_defs = MUTATIONS_DATA.get_all()
	_initialize_levels()

func setup(player_node: Node) -> void:
	player = player_node as Node2D
	_apply_starting_loadout()
	_apply_lineage_visuals()

func get_levelup_options(count: int = 3) -> Array[Dictionary]:
	var available_ids: Array[String] = _get_available_mutation_ids()
	if available_ids.is_empty():
		current_levelup_options = []
		return current_levelup_options

	if debug_log_weighted_rolls:
		_debug_print_roll_candidates(available_ids)

	var selected_ids: Array[String] = []
	if current_lineage_id.is_empty():
		var first_pass_pool: Array[String] = []
		first_pass_pool.append_array(available_ids)

		while selected_ids.size() < count and not first_pass_pool.is_empty():
			var selected_id: String = _pick_weighted_mutation_id(first_pass_pool)
			if selected_id.is_empty():
				break
			selected_ids.append(selected_id)
			first_pass_pool.erase(selected_id)

		while selected_ids.size() < count and not available_ids.is_empty():
			var filler_id: String = _pick_weighted_mutation_id(available_ids)
			if filler_id.is_empty():
				break
			selected_ids.append(filler_id)
	else:
		while selected_ids.size() < count and not available_ids.is_empty():
			var selected_id_with_replacement: String = _pick_weighted_mutation_id(available_ids)
			if selected_id_with_replacement.is_empty():
				break
			selected_ids.append(selected_id_with_replacement)

	var options: Array[Dictionary] = []
	for mutation_id in selected_ids:
		options.append(_build_option(mutation_id))

	current_levelup_options = options
	if debug_log_weighted_rolls:
		_debug_print_selected_options(selected_ids)
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
	_apply_lineage_visuals()
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
	for _i in range(clampi(starting_membrane_level, 0, _get_mutation_max_level("membrane"))):
		apply_mutation("membrane")
	for _i in range(clampi(starting_pulse_nova_level, 0, _get_mutation_max_level("pulse_nova"))):
		apply_mutation("pulse_nova")
	for _i in range(clampi(starting_acid_trail_level, 0, _get_mutation_max_level("acid_trail"))):
		apply_mutation("acid_trail")
	for _i in range(clampi(starting_metabolism_level, 0, _get_mutation_max_level("metabolism"))):
		apply_mutation("metabolism")

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
	var lineage_tags: Array[String] = _get_mutation_lineage_tags(mutation_def)
	var favored: bool = _is_mutation_favored_for_current_lineage(mutation_def)

	var option: Dictionary = {
		"id": mutation_id,
		"name": String(mutation_def.get("name", mutation_id.capitalize())),
		"next_level": next_level,
		"short": String(level_data.get("short", "")),
		"description": String(level_data.get("description", mutation_def.get("description", ""))),
		"lineages": lineage_tags,
		"is_favored": favored
	}
	return option

func _pick_weighted_mutation_id(candidate_ids: Array[String]) -> String:
	if candidate_ids.is_empty():
		return ""

	var total_weight: float = 0.0
	var weights: Array[float] = []
	for mutation_id in candidate_ids:
		var weight: float = _get_mutation_weight(mutation_id)
		weights.append(weight)
		total_weight += weight

	if total_weight <= 0.0:
		return candidate_ids[randi() % candidate_ids.size()]

	var roll: float = randf() * total_weight
	var running_weight: float = 0.0
	for i in range(candidate_ids.size()):
		running_weight += weights[i]
		if roll <= running_weight:
			return candidate_ids[i]

	return candidate_ids[candidate_ids.size() - 1]

func _get_mutation_weight(mutation_id: String) -> float:
	var mutation_def: Dictionary = mutation_defs.get(mutation_id, {})
	if current_lineage_id.is_empty():
		return WEIGHT_BASE

	var lineage_bonus: float = _get_lineage_affinity_bonus(mutation_def)
	return WEIGHT_BASE + lineage_bonus

func _is_mutation_favored_for_current_lineage(mutation_def: Dictionary) -> bool:
	if current_lineage_id.is_empty():
		return false

	var lineage_affinity: Dictionary = _get_mutation_lineage_affinity(mutation_def)
	if lineage_affinity.has(current_lineage_id):
		return true

	var lineage_tags: Array[String] = _get_mutation_lineage_tags(mutation_def)
	return lineage_tags.has(current_lineage_id)

func _get_lineage_affinity_bonus(mutation_def: Dictionary) -> float:
	if current_lineage_id.is_empty():
		return 0.0

	var lineage_affinity: Dictionary = _get_mutation_lineage_affinity(mutation_def)
	if lineage_affinity.has(current_lineage_id):
		return float(lineage_affinity.get(current_lineage_id, WEIGHT_DEFAULT_SAME_LINEAGE_BONUS))

	var lineage_tags: Array[String] = _get_mutation_lineage_tags(mutation_def)
	if lineage_tags.has(current_lineage_id):
		return WEIGHT_DEFAULT_SAME_LINEAGE_BONUS

	return WEIGHT_DEFAULT_OFF_LINEAGE_BONUS

func _get_mutation_lineage_affinity(mutation_def: Dictionary) -> Dictionary:
	var affinity: Dictionary = {}
	var affinity_variant: Variant = mutation_def.get("lineage_affinity", {})
	if affinity_variant is Dictionary:
		var affinity_dict: Dictionary = affinity_variant
		for raw_key in affinity_dict.keys():
			var lineage_key: String = String(raw_key).to_lower()
			affinity[lineage_key] = float(affinity_dict.get(raw_key, 0.0))
	return affinity

func _get_mutation_lineage_tags(mutation_def: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	var lineages_variant: Variant = mutation_def.get("lineages", [])
	if lineages_variant is Array:
		for raw_tag in lineages_variant:
			tags.append(String(raw_tag).to_lower())
		return tags

	var single_lineage: String = String(mutation_def.get("lineage", "")).strip_edges().to_lower()
	if not single_lineage.is_empty():
		tags.append(single_lineage)
	return tags

func _debug_print_roll_candidates(candidate_ids: Array[String]) -> void:
	var lineage_label: String = get_current_lineage_name()
	var parts: Array[String] = []
	for mutation_id in candidate_ids:
		var weight: float = _get_mutation_weight(mutation_id)
		parts.append("%s=%.2f" % [mutation_id, weight])
	print("Roll candidates (lineage=", lineage_label, "): ", _join_string_array(parts))

func _debug_print_selected_options(selected_ids: Array[String]) -> void:
	print("Roll selected: ", _join_string_array(selected_ids))

func _join_string_array(values: Array[String]) -> String:
	var result: String = ""
	for i in range(values.size()):
		if i > 0:
			result += ", "
		result += values[i]
	return result

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
		"membrane":
			_ensure_membrane()
			if membrane_instance != null and membrane_instance.has_method("set_level"):
				membrane_instance.call("set_level", new_level)
		"pulse_nova":
			_ensure_pulse_nova()
			if pulse_nova_instance != null and pulse_nova_instance.has_method("set_level"):
				pulse_nova_instance.call("set_level", new_level)
		"acid_trail":
			_ensure_acid_trail()
			if acid_trail_instance != null and acid_trail_instance.has_method("set_level"):
				acid_trail_instance.call("set_level", new_level)
		"metabolism":
			_ensure_metabolism()
			if metabolism_instance != null and metabolism_instance.has_method("set_level"):
				metabolism_instance.call("set_level", new_level)
	_apply_lineage_visuals()

func _ensure_spike_ring() -> void:
	if spike_ring_instance != null:
		return
	if player == null:
		return

	spike_ring_instance = SPIKE_RING_SCENE.instantiate() as Node2D
	if spike_ring_instance != null:
		player.add_child(spike_ring_instance)
		_apply_lineage_visuals()

func _ensure_orbiter() -> void:
	if orbiter_instance != null:
		return
	if player == null:
		return

	orbiter_instance = ORBITER_SCENE.instantiate() as Node2D
	if orbiter_instance != null:
		player.add_child(orbiter_instance)
		_apply_lineage_visuals()

func _ensure_membrane() -> void:
	if membrane_instance != null:
		return
	if player == null:
		return

	membrane_instance = MEMBRANE_SCENE.instantiate() as Node2D
	if membrane_instance != null:
		player.add_child(membrane_instance)
		_apply_lineage_visuals()

func _ensure_pulse_nova() -> void:
	if pulse_nova_instance != null:
		return
	if player == null:
		return

	pulse_nova_instance = PULSE_NOVA_SCENE.instantiate() as Node2D
	if pulse_nova_instance != null:
		player.add_child(pulse_nova_instance)
		_apply_lineage_visuals()

func _ensure_acid_trail() -> void:
	if acid_trail_instance != null:
		return
	if player == null:
		return

	acid_trail_instance = ACID_TRAIL_SCENE.instantiate() as Node2D
	if acid_trail_instance != null:
		player.add_child(acid_trail_instance)
		_apply_lineage_visuals()

func _ensure_metabolism() -> void:
	if metabolism_instance != null:
		return
	if player == null:
		return

	metabolism_instance = METABOLISM_SCENE.instantiate() as Node2D
	if metabolism_instance != null:
		player.add_child(metabolism_instance)
		_apply_lineage_visuals()

func get_mutation_level(mutation_id: String) -> int:
	return int(mutation_levels.get(mutation_id, 0))

func get_metabolism_regen_per_second() -> float:
	if metabolism_instance == null:
		return 0.0
	if not metabolism_instance.has_method("get_regen_per_second"):
		return 0.0
	return float(metabolism_instance.call("get_regen_per_second"))

func _get_mutation_max_level(mutation_id: String) -> int:
	var mutation_def: Dictionary = mutation_defs.get(mutation_id, {})
	return int(mutation_def.get("max_level", 0))

func _apply_lineage_visuals() -> void:
	var style: Dictionary = {}
	if LINEAGE_VISUALS.has(current_lineage_id):
		style = LINEAGE_VISUALS.get(current_lineage_id, {})

	var player_accent: Color = Color(style.get("player_accent", DEFAULT_PLAYER_ACCENT))
	var spike_color: Color = Color(style.get("spike_color", DEFAULT_SPIKE_COLOR))
	var orbiter_color: Color = Color(style.get("orbiter_color", DEFAULT_ORBITER_COLOR))
	var membrane_color: Color = Color(style.get("membrane_color", DEFAULT_MEMBRANE_COLOR))
	var pulse_color: Color = Color(style.get("pulse_color", DEFAULT_PULSE_COLOR))
	var acid_color: Color = Color(style.get("acid_color", DEFAULT_ACID_COLOR))
	var metabolism_color: Color = Color(style.get("metabolism_color", DEFAULT_METABOLISM_COLOR))

	if player != null and player.has_method("set_lineage_accent"):
		player.call("set_lineage_accent", player_accent)
	if spike_ring_instance != null and spike_ring_instance.has_method("set_lineage_color"):
		spike_ring_instance.call("set_lineage_color", spike_color)
	if orbiter_instance != null and orbiter_instance.has_method("set_lineage_color"):
		orbiter_instance.call("set_lineage_color", orbiter_color)
	if membrane_instance != null and membrane_instance.has_method("set_lineage_color"):
		membrane_instance.call("set_lineage_color", membrane_color)
	if pulse_nova_instance != null and pulse_nova_instance.has_method("set_lineage_color"):
		pulse_nova_instance.call("set_lineage_color", pulse_color)
	if acid_trail_instance != null and acid_trail_instance.has_method("set_lineage_color"):
		acid_trail_instance.call("set_lineage_color", acid_color)
	if metabolism_instance != null and metabolism_instance.has_method("set_lineage_color"):
		metabolism_instance.call("set_lineage_color", metabolism_color)
