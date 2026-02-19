extends RefCounted

const CONFIG_PATH: String = "user://gameplay_settings.cfg"
const CONFIG_SECTION: String = "gameplay"
const CONFIG_KEY_DIFFICULTY: String = "difficulty"
const DEFAULT_DIFFICULTY_ID: String = "medium"
const DIFFICULTY_PRESETS: Dictionary = {
	"easy": {
		"name": "Easy",
		"enemy_speed_multiplier": 0.88,
		"enemy_hp_multiplier": 0.82,
		"enemy_damage_multiplier": 0.78
	},
	"medium": {
		"name": "Medium",
		"enemy_speed_multiplier": 1.0,
		"enemy_hp_multiplier": 1.0,
		"enemy_damage_multiplier": 1.0
	},
	"hard": {
		"name": "Hard",
		"enemy_speed_multiplier": 1.18,
		"enemy_hp_multiplier": 1.25,
		"enemy_damage_multiplier": 1.25
	}
}

static func get_ordered_difficulty_ids() -> Array[String]:
	return ["easy", "medium", "hard"]

static func sanitize_difficulty_id(difficulty_id: String) -> String:
	var normalized_id: String = difficulty_id.strip_edges().to_lower()
	if DIFFICULTY_PRESETS.has(normalized_id):
		return normalized_id
	return DEFAULT_DIFFICULTY_ID

static func get_difficulty_data(difficulty_id: String) -> Dictionary:
	var safe_id: String = sanitize_difficulty_id(difficulty_id)
	return DIFFICULTY_PRESETS.get(safe_id, DIFFICULTY_PRESETS[DEFAULT_DIFFICULTY_ID])

static func get_difficulty_display_name(difficulty_id: String) -> String:
	var data: Dictionary = get_difficulty_data(difficulty_id)
	return String(data.get("name", "Medium"))

static func load_difficulty_id() -> String:
	var config := ConfigFile.new()
	var load_result: int = config.load(CONFIG_PATH)
	if load_result != OK:
		return DEFAULT_DIFFICULTY_ID
	var saved_id: String = String(config.get_value(CONFIG_SECTION, CONFIG_KEY_DIFFICULTY, DEFAULT_DIFFICULTY_ID))
	return sanitize_difficulty_id(saved_id)

static func save_difficulty_id(difficulty_id: String) -> void:
	var safe_id: String = sanitize_difficulty_id(difficulty_id)
	var config := ConfigFile.new()
	config.set_value(CONFIG_SECTION, CONFIG_KEY_DIFFICULTY, safe_id)
	config.save(CONFIG_PATH)
