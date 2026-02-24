extends RefCounted

const CONFIG_PATH: String = "user://gameplay_settings.cfg"
const CONFIG_SECTION: String = "gameplay"
const INPUT_CONFIG_SECTION: String = "input_bindings"
const CONFIG_KEY_DIFFICULTY: String = "difficulty"
const CONFIG_KEY_FPS_LIMIT: String = "fps_limit"
const DEFAULT_DIFFICULTY_ID: String = "medium"
const DEFAULT_FPS_LIMIT_ID: String = "unlimited"
const DEFAULT_INPUT_BINDINGS: Dictionary = {
	"move_left": KEY_A,
	"move_right": KEY_D,
	"move_up": KEY_W,
	"move_down": KEY_S,
	"spell": KEY_Q
}
const INPUT_ACTION_DISPLAY_NAMES: Dictionary = {
	"move_left": "Move Left",
	"move_right": "Move Right",
	"move_up": "Move Up",
	"move_down": "Move Down",
	"spell": "Cast Spell"
}
const ORDERED_INPUT_ACTIONS: Array[String] = [
	"move_up",
	"move_left",
	"move_down",
	"move_right",
	"spell"
]
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
const FPS_LIMIT_PRESETS: Dictionary = {
	"30": {
		"name": "30",
		"max_fps": 30
	},
	"60": {
		"name": "60",
		"max_fps": 60
	},
	"144": {
		"name": "144",
		"max_fps": 144
	},
	"240": {
		"name": "240",
		"max_fps": 240
	},
	"unlimited": {
		"name": "Unlimited",
		"max_fps": 0
	}
}

static func get_ordered_difficulty_ids() -> Array[String]:
	return ["easy", "medium", "hard"]

static func sanitize_difficulty_id(difficulty_id: String) -> String:
	var normalized_id: String = difficulty_id.strip_edges().to_lower()
	if DIFFICULTY_PRESETS.has(normalized_id):
		return normalized_id
	return DEFAULT_DIFFICULTY_ID

static func get_ordered_fps_limit_ids() -> Array[String]:
	return ["30", "60", "144", "240", "unlimited"]

static func sanitize_fps_limit_id(fps_limit_id: String) -> String:
	var normalized_id: String = fps_limit_id.strip_edges().to_lower()
	if FPS_LIMIT_PRESETS.has(normalized_id):
		return normalized_id
	return DEFAULT_FPS_LIMIT_ID

static func get_difficulty_data(difficulty_id: String) -> Dictionary:
	var safe_id: String = sanitize_difficulty_id(difficulty_id)
	return DIFFICULTY_PRESETS.get(safe_id, DIFFICULTY_PRESETS[DEFAULT_DIFFICULTY_ID])

static func get_difficulty_display_name(difficulty_id: String) -> String:
	var data: Dictionary = get_difficulty_data(difficulty_id)
	return String(data.get("name", "Medium"))

static func get_fps_limit_data(fps_limit_id: String) -> Dictionary:
	var safe_id: String = sanitize_fps_limit_id(fps_limit_id)
	return FPS_LIMIT_PRESETS.get(safe_id, FPS_LIMIT_PRESETS[DEFAULT_FPS_LIMIT_ID])

static func get_fps_limit_display_name(fps_limit_id: String) -> String:
	var data: Dictionary = get_fps_limit_data(fps_limit_id)
	return String(data.get("name", "Unlimited"))

static func get_fps_limit_value(fps_limit_id: String) -> int:
	var data: Dictionary = get_fps_limit_data(fps_limit_id)
	return maxi(0, int(data.get("max_fps", 0)))

static func load_difficulty_id() -> String:
	var config := ConfigFile.new()
	var load_result: int = config.load(CONFIG_PATH)
	if load_result != OK:
		return DEFAULT_DIFFICULTY_ID
	var saved_id: String = String(config.get_value(CONFIG_SECTION, CONFIG_KEY_DIFFICULTY, DEFAULT_DIFFICULTY_ID))
	return sanitize_difficulty_id(saved_id)

static func load_fps_limit_id() -> String:
	var config := ConfigFile.new()
	var load_result: int = config.load(CONFIG_PATH)
	if load_result != OK:
		return DEFAULT_FPS_LIMIT_ID
	var saved_id: String = String(config.get_value(CONFIG_SECTION, CONFIG_KEY_FPS_LIMIT, DEFAULT_FPS_LIMIT_ID))
	return sanitize_fps_limit_id(saved_id)

static func save_difficulty_id(difficulty_id: String) -> void:
	var safe_id: String = sanitize_difficulty_id(difficulty_id)
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	config.set_value(CONFIG_SECTION, CONFIG_KEY_DIFFICULTY, safe_id)
	config.save(CONFIG_PATH)

static func save_fps_limit_id(fps_limit_id: String) -> void:
	var safe_id: String = sanitize_fps_limit_id(fps_limit_id)
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	config.set_value(CONFIG_SECTION, CONFIG_KEY_FPS_LIMIT, safe_id)
	config.save(CONFIG_PATH)

static func apply_fps_limit_id(fps_limit_id: String) -> void:
	Engine.max_fps = get_fps_limit_value(fps_limit_id)

static func apply_saved_fps_limit() -> void:
	apply_fps_limit_id(load_fps_limit_id())

static func get_ordered_input_action_ids() -> Array[String]:
	return ORDERED_INPUT_ACTIONS.duplicate()

static func get_input_action_display_name(action_id: String) -> String:
	var safe_action_id: String = _sanitize_input_action_id(action_id)
	if safe_action_id.is_empty():
		return "Input"
	return String(INPUT_ACTION_DISPLAY_NAMES.get(safe_action_id, safe_action_id.replace("_", " ").capitalize()))

static func get_input_action_display(action_id: String) -> String:
	var physical_keycode: int = get_input_action_physical_keycode(action_id)
	var key_text: String = OS.get_keycode_string(physical_keycode).strip_edges()
	if key_text.is_empty():
		var fallback_keycode: int = _get_default_input_keycode(action_id)
		if fallback_keycode > 0:
			key_text = OS.get_keycode_string(fallback_keycode).strip_edges()
	if key_text.is_empty():
		return "Unbound"
	return key_text

static func get_input_action_physical_keycode(action_id: String) -> int:
	var safe_action_id: String = _sanitize_input_action_id(action_id)
	if safe_action_id.is_empty():
		return 0
	if not InputMap.has_action(safe_action_id):
		return _get_default_input_keycode(safe_action_id)

	for event_variant in InputMap.action_get_events(safe_action_id):
		if not (event_variant is InputEventKey):
			continue
		var key_event: InputEventKey = event_variant as InputEventKey
		if key_event == null:
			continue
		if int(key_event.physical_keycode) > 0:
			return int(key_event.physical_keycode)
		if int(key_event.keycode) > 0:
			return int(key_event.keycode)

	return _get_default_input_keycode(safe_action_id)

static func apply_saved_input_bindings() -> void:
	var config := ConfigFile.new()
	var load_result: int = config.load(CONFIG_PATH)

	for action_id in get_ordered_input_action_ids():
		_ensure_input_action_has_binding(action_id)
		if load_result != OK:
			continue
		if not config.has_section_key(INPUT_CONFIG_SECTION, action_id):
			continue
		var saved_keycode: int = int(config.get_value(INPUT_CONFIG_SECTION, action_id, 0))
		if saved_keycode <= 0:
			continue
		_apply_input_action_binding(action_id, saved_keycode)

static func save_input_binding(action_id: String, physical_keycode: int) -> bool:
	var safe_action_id: String = _sanitize_input_action_id(action_id)
	if safe_action_id.is_empty():
		return false
	var safe_keycode: int = maxi(0, physical_keycode)
	if safe_keycode <= 0:
		return false

	_ensure_input_action_has_binding(safe_action_id)
	if not _apply_input_action_binding(safe_action_id, safe_keycode):
		return false

	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	config.set_value(INPUT_CONFIG_SECTION, safe_action_id, safe_keycode)
	config.save(CONFIG_PATH)
	return true

static func _sanitize_input_action_id(action_id: String) -> String:
	var normalized_id: String = action_id.strip_edges().to_lower()
	if ORDERED_INPUT_ACTIONS.has(normalized_id):
		return normalized_id
	return ""

static func _get_default_input_keycode(action_id: String) -> int:
	var safe_action_id: String = _sanitize_input_action_id(action_id)
	if safe_action_id.is_empty():
		return 0
	return int(DEFAULT_INPUT_BINDINGS.get(safe_action_id, 0))

static func _ensure_input_action_has_binding(action_id: String) -> void:
	var safe_action_id: String = _sanitize_input_action_id(action_id)
	if safe_action_id.is_empty():
		return
	if not InputMap.has_action(safe_action_id):
		InputMap.add_action(safe_action_id)

	var has_key_binding: bool = false
	for event_variant in InputMap.action_get_events(safe_action_id):
		if event_variant is InputEventKey:
			has_key_binding = true
			break
	if has_key_binding:
		return

	var default_keycode: int = _get_default_input_keycode(safe_action_id)
	if default_keycode > 0:
		_apply_input_action_binding(safe_action_id, default_keycode)

static func _apply_input_action_binding(action_id: String, physical_keycode: int) -> bool:
	var safe_action_id: String = _sanitize_input_action_id(action_id)
	if safe_action_id.is_empty():
		return false
	if not InputMap.has_action(safe_action_id):
		return false
	var safe_keycode: int = maxi(0, physical_keycode)
	if safe_keycode <= 0:
		return false

	var preserved_events: Array[InputEvent] = []
	for event_variant in InputMap.action_get_events(safe_action_id):
		if event_variant is InputEventKey:
			continue
		var input_event: InputEvent = event_variant as InputEvent
		if input_event == null:
			continue
		preserved_events.append(input_event.duplicate())

	InputMap.action_erase_events(safe_action_id)
	for event in preserved_events:
		InputMap.action_add_event(safe_action_id, event)

	var key_event := InputEventKey.new()
	key_event.physical_keycode = safe_keycode
	InputMap.action_add_event(safe_action_id, key_event)
	return true
