extends Node

const MUTATIONS_DATA = preload("res://data/mutations.gd")

const SPIKE_RING_SCENE: PackedScene = preload("res://scenes/modules/spike_ring.tscn")
const ORBITER_SCENE: PackedScene = preload("res://scenes/modules/orbiter.tscn")
const MEMBRANE_SCENE: PackedScene = preload("res://scenes/modules/membrane.tscn")
const PULSE_NOVA_SCENE: PackedScene = preload("res://scenes/modules/pulse_nova.tscn")
const ACID_TRAIL_SCENE: PackedScene = preload("res://scenes/modules/acid_trail.tscn")
const PROTO_PULSE_SCENE: PackedScene = preload("res://scenes/modules/proto_pulse.tscn")
const PUNCTURE_LANCE_SCENE: PackedScene = preload("res://scenes/modules/puncture_lance.tscn")
const CHAIN_BLOOM_SCENE: PackedScene = preload("res://scenes/modules/chain_bloom.tscn")
const LEECH_TENDRIL_SCENE: PackedScene = preload("res://scenes/modules/leech_tendril.tscn")
const HOST_OVERRIDE_SCENE: PackedScene = preload("res://scenes/modules/host_override.tscn")

const VARIANTS: Dictionary = {
	"lytic": "Lytic Strain",
	"pandemic": "Pandemic Strain",
	"parasitic": "Parasitic Strain"
}

const VARIANT_STARTER_MUTATION: Dictionary = {
	"lytic": "razor_halo",
	"pandemic": "infective_secretion",
	"parasitic": "leech_tendril"
}

const MUTATION_SCENES_BY_ID: Dictionary = {
	"proto_pulse": PROTO_PULSE_SCENE,
	"razor_halo": SPIKE_RING_SCENE,
	"puncture_lance": PUNCTURE_LANCE_SCENE,
	"lytic_burst": PULSE_NOVA_SCENE,
	"infective_secretion": ACID_TRAIL_SCENE,
	"virion_orbit": ORBITER_SCENE,
	"chain_bloom": CHAIN_BLOOM_SCENE,
	"leech_tendril": LEECH_TENDRIL_SCENE,
	"protein_shell": MEMBRANE_SCENE,
	"host_override": HOST_OVERRIDE_SCENE
}

const STAT_DEFS: Dictionary = {
	"offense_boost": {
		"id": "offense_boost",
		"name": "Cytotoxicity",
		"short_by_level": {1: "+8% damage", 2: "+16% damage", 3: "+24% damage"},
		"description": "Increase damage dealt by all modules and spells.",
		"icon_id": "stat_offense",
		"max_level": 3
	},
	"defense_boost": {
		"id": "defense_boost",
		"name": "Reinforced Envelope",
		"short_by_level": {1: "-8% incoming", 2: "-15% incoming", 3: "-22% incoming"},
		"description": "Reduce incoming damage from hostile sources.",
		"icon_id": "stat_defense",
		"max_level": 3
	},
	"pickup_radius_boost": {
		"id": "pickup_radius_boost",
		"name": "Collector Tendrils",
		"short_by_level": {1: "+35% pickup", 2: "+70% pickup", 3: "+110% pickup"},
		"description": "Increase pickup radius for biomass collection.",
		"icon_id": "stat_pickup",
		"max_level": 3
	},
	"move_speed_boost": {
		"id": "move_speed_boost",
		"name": "Motility Shift",
		"short_by_level": {1: "+6% move", 2: "+12% move", 3: "+18% move"},
		"description": "Increase movement speed.",
		"icon_id": "stat_speed",
		"max_level": 3
	},
	"cooldown_boost": {
		"id": "cooldown_boost",
		"name": "Replication Tempo",
		"short_by_level": {1: "-6% cooldown", 2: "-12% cooldown", 3: "-18% cooldown"},
		"description": "Reduce global module cooldowns.",
		"icon_id": "stat_cooldown",
		"max_level": 3
	},
	"vitality_boost": {
		"id": "vitality_boost",
		"name": "Viral Mass",
		"short_by_level": {1: "+15 HP", 2: "+30 HP", 3: "+50 HP"},
		"description": "Increase max HP and heal instantly on upgrade.",
		"icon_id": "stat_vitality",
		"max_level": 3
	}
}

const OFFENSE_MULTIPLIER_BY_LEVEL: Dictionary = {0: 1.0, 1: 1.08, 2: 1.16, 3: 1.24}
const DEFENSE_MULTIPLIER_BY_LEVEL: Dictionary = {0: 1.0, 1: 0.92, 2: 0.85, 3: 0.78}
const PICKUP_MULTIPLIER_BY_LEVEL: Dictionary = {0: 1.0, 1: 1.35, 2: 1.70, 3: 2.10}
const MOVE_MULTIPLIER_BY_LEVEL: Dictionary = {0: 1.0, 1: 1.06, 2: 1.12, 3: 1.18}
const COOLDOWN_MULTIPLIER_BY_LEVEL: Dictionary = {0: 1.0, 1: 0.94, 2: 0.88, 3: 0.82}
const VITALITY_HP_BONUS_BY_LEVEL: Dictionary = {0: 0, 1: 15, 2: 30, 3: 50}
const VITALITY_HEAL_ON_PICK_BY_LEVEL: Dictionary = {1: 8, 2: 12, 3: 18}

signal mutation_applied(mutation_id: String, new_level: int)
signal lineage_changed(lineage_id: String, lineage_name: String)
signal variant_changed(variant_id: String, variant_name: String)

@export var debug_log_weighted_rolls: bool = false

var player: Node2D
var mutation_defs: Dictionary = {}
var mutation_levels: Dictionary = {}
var stat_levels: Dictionary = {}
var current_levelup_options: Array[Dictionary] = []
var current_lineage_id: String = ""

var module_instances: Dictionary = {}
var _module_base_cache: Dictionary = {}

var runtime_module_damage_multiplier: float = 1.0
var runtime_orbiter_speed_multiplier: float = 1.0
var runtime_pulse_radius_multiplier: float = 1.0
var runtime_acid_lifetime_multiplier: float = 1.0

var _stat_damage_multiplier: float = 1.0
var _stat_defense_multiplier: float = 1.0
var _stat_pickup_multiplier: float = 1.0
var _stat_move_speed_multiplier: float = 1.0
var _stat_cooldown_multiplier: float = 1.0
var _stat_bonus_max_hp: int = 0

func _ready() -> void:
	mutation_defs = MUTATIONS_DATA.get_all()
	_initialize_runtime_state()

func setup(player_node: Node) -> void:
	player = player_node as Node2D
	if player == null:
		return
	if get_mutation_level("proto_pulse") <= 0:
		apply_mutation("proto_pulse")
	_apply_stat_effects_to_player()
	_apply_runtime_modifiers_to_modules()

func _initialize_runtime_state() -> void:
	mutation_levels.clear()
	for mutation_id_variant in mutation_defs.keys():
		var mutation_id: String = String(mutation_id_variant)
		mutation_levels[mutation_id] = 0

	stat_levels.clear()
	for stat_id_variant in STAT_DEFS.keys():
		var stat_id: String = String(stat_id_variant)
		stat_levels[stat_id] = 0

func get_levelup_options(count: int = 3) -> Array[Dictionary]:
	var safe_count: int = maxi(1, count)
	var spell_option_pool: Array[Dictionary] = _build_available_spell_options()
	var stat_option_pool: Array[Dictionary] = _build_available_stat_options()

	var selected_options: Array[Dictionary] = []
	if spell_option_pool.is_empty():
		selected_options = _pick_weighted_options(stat_option_pool, safe_count)
		current_levelup_options = selected_options
		return selected_options

	var target_spell_count: int = mini(2, safe_count - 1)
	if safe_count <= 2:
		target_spell_count = 1
	if target_spell_count <= 0:
		target_spell_count = 1
	selected_options.append_array(_pick_weighted_options(spell_option_pool, target_spell_count))

	var stat_pick_count: int = safe_count - selected_options.size()
	if stat_pick_count > 0:
		selected_options.append_array(_pick_weighted_options(stat_option_pool, stat_pick_count))

	if selected_options.size() < safe_count:
		var fill_pool: Array[Dictionary] = []
		fill_pool.append_array(spell_option_pool)
		fill_pool.append_array(stat_option_pool)
		selected_options.append_array(_pick_weighted_options(fill_pool, safe_count - selected_options.size(), selected_options))

	selected_options = _shuffle_options(selected_options)
	if selected_options.size() > safe_count:
		selected_options.resize(safe_count)

	current_levelup_options = selected_options
	return selected_options

func apply_option_index(index: int) -> bool:
	if index < 0 or index >= current_levelup_options.size():
		return false

	var option: Dictionary = current_levelup_options[index]
	var option_type: String = String(option.get("option_type", "mutation"))
	if option_type == "stat":
		return _apply_stat_upgrade(String(option.get("id", "")))
	return apply_mutation(String(option.get("id", "")))

func apply_mutation(mutation_id: String) -> bool:
	if mutation_id.is_empty():
		return false
	if not mutation_defs.has(mutation_id):
		return false
	if not _is_mutation_unlockable_for_current_state(mutation_id):
		return false

	var current_level: int = get_mutation_level(mutation_id)
	var max_level: int = _get_mutation_max_level(mutation_id)
	if current_level >= max_level:
		return false

	var new_level: int = current_level + 1
	mutation_levels[mutation_id] = new_level
	_ensure_module_instance(mutation_id)
	_apply_module_level(mutation_id, new_level)
	_apply_runtime_modifiers_to_modules()
	mutation_applied.emit(mutation_id, new_level)
	return true

func choose_lineage(lineage_id: String) -> bool:
	var normalized_id: String = lineage_id.strip_edges().to_lower()
	if not VARIANTS.has(normalized_id):
		return false
	if not current_lineage_id.is_empty() and current_lineage_id != normalized_id:
		return false

	current_lineage_id = normalized_id
	var starter_mutation_id: String = String(VARIANT_STARTER_MUTATION.get(current_lineage_id, ""))
	if not starter_mutation_id.is_empty() and get_mutation_level(starter_mutation_id) <= 0:
		apply_mutation(starter_mutation_id)

	var current_name: String = get_current_lineage_name()
	lineage_changed.emit(current_lineage_id, current_name)
	variant_changed.emit(current_lineage_id, current_name)
	return true

func choose_variant(variant_id: String) -> bool:
	return choose_lineage(variant_id)

func get_current_lineage_id() -> String:
	return current_lineage_id

func get_current_variant_id() -> String:
	return get_current_lineage_id()

func get_current_lineage_name() -> String:
	if current_lineage_id.is_empty():
		return "None"
	return String(VARIANTS.get(current_lineage_id, current_lineage_id.capitalize()))

func get_current_variant_name() -> String:
	return get_current_lineage_name()

func get_mutation_level(mutation_id: String) -> int:
	return int(mutation_levels.get(mutation_id, 0))

func get_stat_level(stat_id: String) -> int:
	return int(stat_levels.get(stat_id, 0))

func get_metabolism_regen_per_second() -> float:
	var leech_node: Node = module_instances.get("leech_tendril", null)
	if leech_node != null and leech_node.has_method("get_regen_per_second_estimate"):
		return float(leech_node.call("get_regen_per_second_estimate"))
	return 0.0

func get_module_instance(mutation_id: String) -> Node:
	if not module_instances.has(mutation_id):
		return null
	var module_node: Node = module_instances.get(mutation_id, null)
	if module_node == null:
		return null
	if not is_instance_valid(module_node):
		return null
	return module_node

func set_runtime_crisis_reward_modifiers(module_damage_multiplier: float, orbiter_speed_multiplier: float, pulse_radius_multiplier: float, acid_lifetime_multiplier: float) -> void:
	runtime_module_damage_multiplier = maxf(0.1, module_damage_multiplier)
	runtime_orbiter_speed_multiplier = maxf(0.1, orbiter_speed_multiplier)
	runtime_pulse_radius_multiplier = maxf(0.1, pulse_radius_multiplier)
	runtime_acid_lifetime_multiplier = maxf(0.1, acid_lifetime_multiplier)
	_apply_runtime_modifiers_to_modules()

func _build_available_spell_options() -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	for mutation_id_variant in mutation_defs.keys():
		var mutation_id: String = String(mutation_id_variant)
		if not _is_mutation_unlockable_for_current_state(mutation_id):
			continue
		var current_level: int = get_mutation_level(mutation_id)
		var max_level: int = _get_mutation_max_level(mutation_id)
		if current_level >= max_level:
			continue
		options.append(_build_mutation_option(mutation_id))
	return options

func _build_available_stat_options() -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	for stat_id_variant in STAT_DEFS.keys():
		var stat_id: String = String(stat_id_variant)
		var level_value: int = get_stat_level(stat_id)
		var def: Dictionary = STAT_DEFS.get(stat_id, {})
		var max_level: int = int(def.get("max_level", 0))
		if level_value >= max_level:
			continue
		options.append(_build_stat_option(stat_id))
	return options

func _build_mutation_option(mutation_id: String) -> Dictionary:
	var mutation_def: Dictionary = mutation_defs.get(mutation_id, {})
	var current_level: int = get_mutation_level(mutation_id)
	var next_level: int = current_level + 1
	var levels: Dictionary = mutation_def.get("levels", {})
	var level_data: Dictionary = levels.get(next_level, {})
	var variant_id: String = String(mutation_def.get("variant", ""))
	var favored: bool = (not current_lineage_id.is_empty() and variant_id == current_lineage_id)
	return {
		"id": mutation_id,
		"name": String(mutation_def.get("name", mutation_id.capitalize())),
		"next_level": next_level,
		"short": String(level_data.get("short", mutation_def.get("short", ""))),
		"description": String(level_data.get("description", mutation_def.get("description", ""))),
		"lineages": mutation_def.get("lineages", []),
		"is_favored": favored,
		"icon_id": String(mutation_def.get("icon_id", mutation_id)),
		"option_type": "mutation",
		"weight": _get_mutation_roll_weight(mutation_id, mutation_def)
	}

func _build_stat_option(stat_id: String) -> Dictionary:
	var def: Dictionary = STAT_DEFS.get(stat_id, {})
	var next_level: int = get_stat_level(stat_id) + 1
	var short_by_level: Dictionary = def.get("short_by_level", {})
	var short_text: String = String(short_by_level.get(next_level, ""))
	return {
		"id": stat_id,
		"name": String(def.get("name", stat_id.capitalize())),
		"next_level": next_level,
		"short": short_text,
		"description": String(def.get("description", "")),
		"lineages": [],
		"is_favored": false,
		"icon_id": String(def.get("icon_id", stat_id)),
		"option_type": "stat",
		"weight": _get_stat_roll_weight(stat_id)
	}

func _get_mutation_roll_weight(mutation_id: String, mutation_def: Dictionary) -> float:
	var weight: float = 1.0
	var current_level: int = get_mutation_level(mutation_id)
	if current_level == 0:
		weight += 1.3

	var tier_name: String = String(mutation_def.get("tier", ""))
	if current_level == 0 and (tier_name == "core" or tier_name == "capstone"):
		weight += 1.0

	var variant_id: String = String(mutation_def.get("variant", ""))
	if current_lineage_id.is_empty():
		if variant_id == "universal":
			weight += 1.0
		else:
			weight *= 0.35
	else:
		if variant_id == current_lineage_id:
			weight += 2.1
		elif variant_id == "universal":
			weight += 0.35
		else:
			weight *= 0.20

	var affinity_dict: Dictionary = mutation_def.get("lineage_affinity", {})
	if not current_lineage_id.is_empty() and affinity_dict.has(current_lineage_id):
		weight += float(affinity_dict.get(current_lineage_id, 0.0))

	return maxf(0.01, weight)

func _get_stat_roll_weight(stat_id: String) -> float:
	var current_level: int = get_stat_level(stat_id)
	if current_level <= 0:
		return 1.3
	if current_level == 1:
		return 1.1
	return 0.95

func _pick_weighted_options(pool: Array[Dictionary], count: int, exclude_options: Array[Dictionary] = []) -> Array[Dictionary]:
	var picked: Array[Dictionary] = []
	if count <= 0:
		return picked
	if pool.is_empty():
		return picked

	var working_pool: Array[Dictionary] = []
	for option in pool:
		if not (option is Dictionary):
			continue
		if _contains_option_by_id(exclude_options, option):
			continue
		working_pool.append(option)

	while picked.size() < count and not working_pool.is_empty():
		var selected_index: int = _pick_weighted_index(working_pool)
		if selected_index < 0 or selected_index >= working_pool.size():
			break
		var selected_option: Dictionary = working_pool[selected_index]
		picked.append(selected_option)
		working_pool.remove_at(selected_index)

	return picked

func _pick_weighted_index(options: Array[Dictionary]) -> int:
	if options.is_empty():
		return -1
	var total_weight: float = 0.0
	for option in options:
		total_weight += maxf(0.01, float(option.get("weight", 1.0)))
	if total_weight <= 0.01:
		return randi() % options.size()

	var roll: float = randf() * total_weight
	var accumulated: float = 0.0
	for i in range(options.size()):
		accumulated += maxf(0.01, float(options[i].get("weight", 1.0)))
		if roll <= accumulated:
			return i
	return options.size() - 1

func _contains_option_by_id(options: Array[Dictionary], target_option: Dictionary) -> bool:
	var target_id: String = String(target_option.get("id", ""))
	if target_id.is_empty():
		return false
	for option in options:
		if String(option.get("id", "")) == target_id:
			return true
	return false

func _shuffle_options(options: Array[Dictionary]) -> Array[Dictionary]:
	var shuffled: Array[Dictionary] = options.duplicate()
	if shuffled.size() <= 1:
		return shuffled
	for i in range(shuffled.size() - 1, 0, -1):
		var j: int = randi() % (i + 1)
		var temp: Dictionary = shuffled[i]
		shuffled[i] = shuffled[j]
		shuffled[j] = temp
	return shuffled

func _is_mutation_unlockable_for_current_state(mutation_id: String) -> bool:
	if not mutation_defs.has(mutation_id):
		return false
	var mutation_def: Dictionary = mutation_defs.get(mutation_id, {})
	var variant_id: String = String(mutation_def.get("variant", ""))
	if variant_id != "universal":
		if current_lineage_id.is_empty():
			return false
		if variant_id != current_lineage_id:
			return false

	var required_list_variant: Variant = mutation_def.get("required_mutations", [])
	if required_list_variant is Array:
		var required_list: Array = required_list_variant
		for required_id_variant in required_list:
			var required_id: String = String(required_id_variant)
			if get_mutation_level(required_id) <= 0:
				return false
	return true

func _get_mutation_max_level(mutation_id: String) -> int:
	var mutation_def: Dictionary = mutation_defs.get(mutation_id, {})
	return int(mutation_def.get("max_level", 0))

func _ensure_module_instance(mutation_id: String) -> void:
	if module_instances.has(mutation_id):
		var existing_node: Node = module_instances.get(mutation_id, null)
		if existing_node != null and is_instance_valid(existing_node):
			return
		module_instances.erase(mutation_id)

	if not MUTATION_SCENES_BY_ID.has(mutation_id):
		return
	if player == null:
		return

	var scene_variant: Variant = MUTATION_SCENES_BY_ID.get(mutation_id, null)
	var module_scene: PackedScene = scene_variant as PackedScene
	if module_scene == null:
		return
	var module_node := module_scene.instantiate() as Node2D
	if module_node == null:
		return
	player.add_child(module_node)
	module_instances[mutation_id] = module_node
	_cache_module_base_values(mutation_id, module_node)

func _cache_module_base_values(mutation_id: String, module_node: Node) -> void:
	var base_entry: Dictionary = {}
	if module_node == null:
		_module_base_cache[mutation_id] = base_entry
		return

	match mutation_id:
		"razor_halo":
			base_entry["spike_damage"] = int(module_node.get("spike_damage"))
			base_entry["damage_interval_seconds"] = float(module_node.get("damage_interval_seconds"))
		"virion_orbit":
			base_entry["orbiter_damage"] = int(module_node.get("orbiter_damage"))
			base_entry["base_orbit_speed_rps"] = float(module_node.get("base_orbit_speed_rps"))
		"lytic_burst":
			base_entry["base_pulse_damage"] = int(module_node.get("base_pulse_damage"))
			base_entry["base_pulse_radius"] = float(module_node.get("base_pulse_radius"))
			base_entry["base_pulse_interval_seconds"] = float(module_node.get("base_pulse_interval_seconds"))
		"infective_secretion":
			base_entry["base_damage_per_tick"] = int(module_node.get("base_damage_per_tick"))
			base_entry["base_lifetime_seconds"] = float(module_node.get("base_lifetime_seconds"))
			base_entry["base_spawn_interval_seconds"] = float(module_node.get("base_spawn_interval_seconds"))
			base_entry["base_damage_tick_interval_seconds"] = float(module_node.get("base_damage_tick_interval_seconds"))
	_module_base_cache[mutation_id] = base_entry

func _apply_module_level(mutation_id: String, new_level: int) -> void:
	var module_node: Node = module_instances.get(mutation_id, null)
	if module_node == null:
		return
	if module_node.has_method("set_level"):
		module_node.call("set_level", new_level)

func _apply_stat_upgrade(stat_id: String) -> bool:
	if not STAT_DEFS.has(stat_id):
		return false
	var def: Dictionary = STAT_DEFS.get(stat_id, {})
	var current_level: int = get_stat_level(stat_id)
	var max_level: int = int(def.get("max_level", 0))
	if current_level >= max_level:
		return false

	var new_level: int = current_level + 1
	stat_levels[stat_id] = new_level

	if stat_id == "vitality_boost" and player != null and player.has_method("heal"):
		var heal_amount: int = int(VITALITY_HEAL_ON_PICK_BY_LEVEL.get(new_level, 0))
		if heal_amount > 0:
			player.call("heal", heal_amount)

	_apply_stat_effects_to_player()
	_apply_runtime_modifiers_to_modules()
	return true

func _apply_stat_effects_to_player() -> void:
	if player == null:
		return

	var offense_level: int = get_stat_level("offense_boost")
	var defense_level: int = get_stat_level("defense_boost")
	var pickup_level: int = get_stat_level("pickup_radius_boost")
	var move_level: int = get_stat_level("move_speed_boost")
	var cooldown_level: int = get_stat_level("cooldown_boost")
	var vitality_level: int = get_stat_level("vitality_boost")

	_stat_damage_multiplier = float(OFFENSE_MULTIPLIER_BY_LEVEL.get(offense_level, 1.0))
	_stat_defense_multiplier = float(DEFENSE_MULTIPLIER_BY_LEVEL.get(defense_level, 1.0))
	_stat_pickup_multiplier = float(PICKUP_MULTIPLIER_BY_LEVEL.get(pickup_level, 1.0))
	_stat_move_speed_multiplier = float(MOVE_MULTIPLIER_BY_LEVEL.get(move_level, 1.0))
	_stat_cooldown_multiplier = float(COOLDOWN_MULTIPLIER_BY_LEVEL.get(cooldown_level, 1.0))
	_stat_bonus_max_hp = int(VITALITY_HP_BONUS_BY_LEVEL.get(vitality_level, 0))

	if player.has_method("set_stat_move_speed_multiplier"):
		player.call("set_stat_move_speed_multiplier", _stat_move_speed_multiplier)
	if player.has_method("set_stat_max_hp_flat"):
		player.call("set_stat_max_hp_flat", _stat_bonus_max_hp)
	if player.has_method("set_stat_incoming_damage_multiplier"):
		player.call("set_stat_incoming_damage_multiplier", _stat_defense_multiplier)
	if player.has_method("set_pickup_radius_multiplier"):
		player.call("set_pickup_radius_multiplier", _stat_pickup_multiplier)

func _apply_runtime_modifiers_to_modules() -> void:
	for mutation_id_variant in module_instances.keys():
		var mutation_id: String = String(mutation_id_variant)
		var module_node: Node = module_instances.get(mutation_id, null)
		if module_node == null or not is_instance_valid(module_node):
			continue
		_apply_runtime_to_module(mutation_id, module_node)

func _apply_runtime_to_module(mutation_id: String, module_node: Node) -> void:
	var total_damage_multiplier: float = runtime_module_damage_multiplier * _stat_damage_multiplier
	var total_cooldown_multiplier: float = _stat_cooldown_multiplier

	match mutation_id:
		"proto_pulse":
			if module_node.has_method("set_runtime_modifiers"):
				module_node.call("set_runtime_modifiers", total_damage_multiplier, runtime_pulse_radius_multiplier, total_cooldown_multiplier)
		"razor_halo":
			_apply_runtime_to_razor_halo(module_node, total_damage_multiplier, total_cooldown_multiplier)
		"puncture_lance":
			if module_node.has_method("set_runtime_modifiers"):
				module_node.call("set_runtime_modifiers", total_damage_multiplier, total_cooldown_multiplier)
		"lytic_burst":
			_apply_runtime_to_lytic_burst(module_node, total_damage_multiplier, total_cooldown_multiplier)
		"infective_secretion":
			_apply_runtime_to_infective_secretion(module_node, total_damage_multiplier, total_cooldown_multiplier)
		"virion_orbit":
			_apply_runtime_to_virion_orbit(module_node, total_damage_multiplier)
		"chain_bloom":
			if module_node.has_method("set_runtime_modifiers"):
				module_node.call("set_runtime_modifiers", total_damage_multiplier)
		"leech_tendril":
			if module_node.has_method("set_runtime_modifiers"):
				module_node.call("set_runtime_modifiers", total_damage_multiplier, total_cooldown_multiplier)
		"protein_shell":
			pass
		"host_override":
			if module_node.has_method("set_runtime_modifiers"):
				module_node.call("set_runtime_modifiers", 1.0, total_cooldown_multiplier)

func _apply_runtime_to_razor_halo(module_node: Node, damage_multiplier: float, cooldown_multiplier: float) -> void:
	var base_entry: Dictionary = _module_base_cache.get("razor_halo", {})
	var base_damage: int = int(base_entry.get("spike_damage", module_node.get("spike_damage")))
	var base_interval: float = float(base_entry.get("damage_interval_seconds", module_node.get("damage_interval_seconds")))
	module_node.set("spike_damage", maxi(1, int(round(float(base_damage) * damage_multiplier))))
	module_node.set("damage_interval_seconds", maxf(0.06, base_interval * cooldown_multiplier))
	if module_node.has_method("set_level"):
		module_node.call("set_level", get_mutation_level("razor_halo"))

func _apply_runtime_to_virion_orbit(module_node: Node, damage_multiplier: float) -> void:
	var base_entry: Dictionary = _module_base_cache.get("virion_orbit", {})
	var base_damage: int = int(base_entry.get("orbiter_damage", module_node.get("orbiter_damage")))
	var base_speed: float = float(base_entry.get("base_orbit_speed_rps", module_node.get("base_orbit_speed_rps")))
	module_node.set("orbiter_damage", maxi(1, int(round(float(base_damage) * damage_multiplier))))
	module_node.set("base_orbit_speed_rps", maxf(0.1, base_speed * runtime_orbiter_speed_multiplier))
	if module_node.has_method("set_level"):
		module_node.call("set_level", get_mutation_level("virion_orbit"))

func _apply_runtime_to_lytic_burst(module_node: Node, damage_multiplier: float, cooldown_multiplier: float) -> void:
	var base_entry: Dictionary = _module_base_cache.get("lytic_burst", {})
	var base_damage: int = int(base_entry.get("base_pulse_damage", module_node.get("base_pulse_damage")))
	var base_radius: float = float(base_entry.get("base_pulse_radius", module_node.get("base_pulse_radius")))
	var base_interval: float = float(base_entry.get("base_pulse_interval_seconds", module_node.get("base_pulse_interval_seconds")))
	module_node.set("base_pulse_damage", maxi(1, int(round(float(base_damage) * damage_multiplier))))
	module_node.set("base_pulse_radius", maxf(8.0, base_radius * runtime_pulse_radius_multiplier))
	module_node.set("base_pulse_interval_seconds", maxf(0.18, base_interval * cooldown_multiplier))
	if module_node.has_method("set_level"):
		module_node.call("set_level", get_mutation_level("lytic_burst"))

func _apply_runtime_to_infective_secretion(module_node: Node, damage_multiplier: float, cooldown_multiplier: float) -> void:
	var base_entry: Dictionary = _module_base_cache.get("infective_secretion", {})
	var base_damage: int = int(base_entry.get("base_damage_per_tick", module_node.get("base_damage_per_tick")))
	var base_lifetime: float = float(base_entry.get("base_lifetime_seconds", module_node.get("base_lifetime_seconds")))
	var base_spawn_interval: float = float(base_entry.get("base_spawn_interval_seconds", module_node.get("base_spawn_interval_seconds")))
	var base_tick_interval: float = float(base_entry.get("base_damage_tick_interval_seconds", module_node.get("base_damage_tick_interval_seconds")))
	module_node.set("base_damage_per_tick", maxi(1, int(round(float(base_damage) * damage_multiplier))))
	module_node.set("base_lifetime_seconds", maxf(0.1, base_lifetime * runtime_acid_lifetime_multiplier))
	module_node.set("base_spawn_interval_seconds", maxf(0.08, base_spawn_interval * cooldown_multiplier))
	module_node.set("base_damage_tick_interval_seconds", maxf(0.08, base_tick_interval * cooldown_multiplier))
	if module_node.has_method("set_level"):
		module_node.call("set_level", get_mutation_level("infective_secretion"))
