extends Node2D

const BIOMASS_PICKUP_SCENE: PackedScene = preload("res://scenes/systems/biomass_pickup.tscn")
const CONTAINMENT_SWEEP_SCENE: PackedScene = preload("res://scenes/systems/containment_sweep_hazard.tscn")
const BIOHAZARD_LEAK_ZONE_SCENE: PackedScene = preload("res://scenes/systems/biohazard_leak_zone.tscn")
const STRAIN_BLOOM_ELITE_SCENE: PackedScene = preload("res://scenes/actors/enemy_dasher.tscn")
const MUTATIONS_DATA = preload("res://data/mutations.gd")
const MUTATION_ICON_SPIKES: Texture2D = preload("res://art/sprites/ui/mutation_spikes.png")
const MUTATION_ICON_ORBITERS: Texture2D = preload("res://art/sprites/ui/mutation_orbiters.png")
const MUTATION_ICON_MEMBRANE: Texture2D = preload("res://art/sprites/ui/mutation_membrane.png")
const MUTATION_ICON_PULSE_NOVA: Texture2D = preload("res://art/sprites/ui/mutation_pulse_nova.png")
const MUTATION_ICON_ACID_TRAIL: Texture2D = preload("res://art/sprites/ui/mutation_acid_trail.png")
const MUTATION_ICON_METABOLISM: Texture2D = preload("res://art/sprites/ui/mutation_metabolism.png")
const MUTATION_ICON_BY_ID: Dictionary = {
	"spikes": MUTATION_ICON_SPIKES,
	"orbiters": MUTATION_ICON_ORBITERS,
	"membrane": MUTATION_ICON_MEMBRANE,
	"pulse_nova": MUTATION_ICON_PULSE_NOVA,
	"acid_trail": MUTATION_ICON_ACID_TRAIL,
	"metabolism": MUTATION_ICON_METABOLISM
}
const SYNERGY_ICON_ID_BY_RULE_ID: Dictionary = {
	"contact_burst": "spikes",
	"orbit_sustain": "orbiters",
	"infection_burst": "acid_trail",
	"contact_sustain": "membrane"
}
const INVENTORY_MUTATION_IDS: Array[String] = [
	"spikes",
	"orbiters",
	"membrane",
	"pulse_nova",
	"acid_trail",
	"metabolism"
]
const MUTATION_TAG_SYNERGY_RULES: Array[Dictionary] = [
	{
		"id": "contact_burst",
		"name": "Predatory Burst",
		"tags": ["contact", "burst"],
		"module_damage_multiplier": 1.10
	},
	{
		"id": "orbit_sustain",
		"name": "Rotary Homeostasis",
		"tags": ["orbit", "sustain"],
		"orbiter_speed_multiplier": 1.18,
		"passive_regen_per_second": 0.8
	},
	{
		"id": "infection_burst",
		"name": "Volatile Secretion",
		"tags": ["infection", "burst"],
		"pulse_radius_multiplier": 1.12,
		"acid_lifetime_multiplier": 1.15
	},
	{
		"id": "contact_sustain",
		"name": "Armored Pressure",
		"tags": ["contact", "sustain"],
		"external_damage_multiplier": 0.92
	}
]

@onready var player: Node = get_node_or_null("Player")
@onready var xp_system: Node = get_node_or_null("XpSystem")
@onready var mutation_system: Node = get_node_or_null("MutationSystem")
@onready var hp_label: Label = get_node_or_null("UiHud/HPLabel")
@onready var metabolism_label: Label = get_node_or_null("UiHud/MetabolismLabel")
@onready var xp_bar: ProgressBar = get_node_or_null("UiHud/XPBar")
@onready var level_label: Label = get_node_or_null("UiHud/LevelLabel")
@onready var timer_label: Label = get_node_or_null("UiHud/TimerLabel")
@onready var crisis_debug_label: Label = get_node_or_null("UiHud/CrisisDebugLabel")
@onready var lineage_label: Label = get_node_or_null("UiHud/LineageLabel")
@onready var arena_tint_rect: ColorRect = get_node_or_null("ColorRect")
@onready var ui_hud_layer: CanvasLayer = get_node_or_null("UiHud")
@onready var run_inventory_bar: Control = get_node_or_null("UiHud/RunInventoryBar")
@onready var run_inventory_rows: VBoxContainer = get_node_or_null("UiHud/RunInventoryBar/Rows")
@onready var run_inventory_mutation_entries: HFlowContainer = get_node_or_null("UiHud/RunInventoryBar/Rows/BuildRow/BuildEntries")
@onready var run_inventory_reward_entries: HFlowContainer = get_node_or_null("UiHud/RunInventoryBar/Rows/RewardRow/RewardEntries")
@onready var run_inventory_synergy_entries: HFlowContainer = get_node_or_null("UiHud/RunInventoryBar/Rows/SynergyRow/SynergyEntries")
@onready var levelup_ui: CanvasLayer = get_node_or_null("UiLevelup")
@onready var levelup_title_label: Label = get_node_or_null("UiLevelup/Root/Layout/TitleLabel")
@onready var levelup_lineage_prompt_label: Label = get_node_or_null("UiLevelup/Root/Layout/LineagePromptLabel")
@onready var levelup_help_label: Label = get_node_or_null("UiLevelup/Root/Layout/HelpLabel")
@onready var levelup_choices_row: HBoxContainer = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow")
@onready var levelup_choice_1: Button = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton1")
@onready var levelup_choice_2: Button = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton2")
@onready var levelup_choice_3: Button = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton3")
@onready var levelup_choice_1_icon: TextureRect = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton1/MutationIcon")
@onready var levelup_choice_2_icon: TextureRect = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton2/MutationIcon")
@onready var levelup_choice_3_icon: TextureRect = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton3/MutationIcon")
@onready var levelup_choice_1_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton1/MutationText")
@onready var levelup_choice_2_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton2/MutationText")
@onready var levelup_choice_3_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/ChoicesRow/ChoiceButton3/MutationText")
@onready var lineage_choices_column: VBoxContainer = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn")
@onready var lineage_choice_1: Button = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton1")
@onready var lineage_choice_2: Button = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton2")
@onready var lineage_choice_3: Button = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton3")
@onready var lineage_choice_1_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton1/LineageText")
@onready var lineage_choice_2_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton2/LineageText")
@onready var lineage_choice_3_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton3/LineageText")
@onready var lineage_bottom_padding: Control = get_node_or_null("UiLevelup/Root/Layout/LineageBottomPadding")
@onready var game_over_ui: CanvasLayer = get_node_or_null("GameOver")
@onready var game_over_stats_label: Label = get_node_or_null("GameOver/Root/StatsLabel")
@onready var game_over_reason_label: Label = get_node_or_null("GameOver/Root/ReasonLabel")
@onready var game_over_main_menu_button: Button = get_node_or_null("GameOver/Root/MainMenuButton")
@onready var victory_ui: CanvasLayer = get_node_or_null("Victory")
@onready var victory_stats_label: Label = get_node_or_null("Victory/Root/StatsLabel")
@onready var victory_summary_label: Label = get_node_or_null("Victory/Root/SummaryLabel")
@onready var victory_detail_label: Label = get_node_or_null("Victory/Root/DetailLabel")
@onready var victory_main_menu_button: Button = get_node_or_null("Victory/Root/MainMenuButton")
@onready var pause_menu_ui: CanvasLayer = get_node_or_null("PauseMenu")
@onready var pause_resume_button: Button = get_node_or_null("PauseMenu/Root/Content/Buttons/ResumeButton")
@onready var pause_options_button: Button = get_node_or_null("PauseMenu/Root/Content/Buttons/OptionsButton")
@onready var pause_main_menu_button: Button = get_node_or_null("PauseMenu/Root/Content/Buttons/MainMenuButton")
@onready var pause_options_panel: PanelContainer = get_node_or_null("PauseMenu/Root/Content/OptionsPanel")
@onready var pause_sfx_slider: HSlider = get_node_or_null("PauseMenu/Root/Content/OptionsPanel/Padding/AudioRows/SfxRow/SfxSlider")
@onready var pause_sfx_mute_toggle: CheckButton = get_node_or_null("PauseMenu/Root/Content/OptionsPanel/Padding/AudioRows/SfxRow/SfxMuteToggle")
@onready var pause_music_slider: HSlider = get_node_or_null("PauseMenu/Root/Content/OptionsPanel/Padding/AudioRows/MusicRow/MusicSlider")
@onready var pause_music_mute_toggle: CheckButton = get_node_or_null("PauseMenu/Root/Content/OptionsPanel/Padding/AudioRows/MusicRow/MusicMuteToggle")
@onready var crisis_director: Node = get_node_or_null("CrisisDirector")
@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")

var elapsed_seconds: float = 0.0
var level_reached: int = 1
var run_ended: bool = false
var run_paused_for_levelup: bool = false
var run_paused_for_menu: bool = false
var pending_levelup_count: int = 0
var debug_log_drops: bool = false
var levelup_options: Array = []
var lineage_selection_active: bool = false
var crisis_reward_selection_active: bool = false
var active_crisis_reward_id: String = ""
var crisis_reward_options: Array = []
var game_over_main_menu_requested: bool = false
var _last_player_hp: int = -1
var _pending_crisis_failure_audio: bool = false
var _last_run_end_reason: String = ""
var _last_containment_sweep_hit_seconds: float = -1000.0
var _syncing_audio_controls: bool = false
var _active_containment_sweeps: Array[Node2D] = []
var _active_biohazard_leaks: Array[Node2D] = []
var _final_crisis_elites: Array[Node2D] = []
var _biohazard_leak_spawner_active: bool = false
var _biohazard_leak_spawn_accumulator: float = 0.0
var _biohazard_leak_position_sample_accumulator: float = 0.0
var _biohazard_leak_elapsed_seconds: float = 0.0
var _biohazard_recent_player_positions: Array = []
var _final_crisis_active: bool = false
var _final_containment_wave_elapsed_seconds: float = 0.0
var _strain_bloom_elite_target: Node2D
var _strain_bloom_active: bool = false
var _strain_bloom_elite_killed: bool = false
var _reward_module_damage_multiplier: float = 1.0
var _reward_orbiter_speed_multiplier: float = 1.0
var _reward_pulse_radius_multiplier: float = 1.0
var _reward_acid_lifetime_multiplier: float = 1.0
var _reward_move_speed_multiplier: float = 1.0
var _reward_external_damage_multiplier: float = 1.0
var _reward_bonus_max_hp_flat: int = 0
var _reward_passive_regen_per_second: float = 0.0
var _reward_passive_regen_progress: float = 0.0
var _synergy_module_damage_multiplier: float = 1.0
var _synergy_orbiter_speed_multiplier: float = 1.0
var _synergy_pulse_radius_multiplier: float = 1.0
var _synergy_acid_lifetime_multiplier: float = 1.0
var _synergy_move_speed_multiplier: float = 1.0
var _synergy_external_damage_multiplier: float = 1.0
var _synergy_passive_regen_per_second: float = 0.0
var _active_tag_synergy_ids: Array[String] = []
var _last_logged_tag_synergy_signature: String = ""
var _run_mutation_inventory_levels: Dictionary = {}
var _run_reward_inventory: Dictionary = {}
var _run_reward_inventory_order: Array[String] = []
var _inventory_tooltip_panel: PanelContainer
var _inventory_tooltip_title_label: Label
var _inventory_tooltip_body_label: Label
var _inventory_tooltip_slot: Control
var _synergy_popup_panel: PanelContainer
var _synergy_popup_title_label: Label
var _synergy_popup_body_label: Label
var _synergy_popup_queue: Array[Dictionary] = []
var _synergy_popup_active: bool = false
var _synergy_popup_elapsed_seconds: float = 0.0
var _synergy_popup_current_duration_seconds: float = 0.0
var _final_crisis_intro_popup_shown: bool = false
var _run_intro_popup_shown: bool = false
var _base_arena_tint_color: Color = Color(0.0, 0.40392157, 0.5647059, 0.22)
@export var debug_allow_grant_xp: bool = false
@export var debug_grant_xp_amount: int = 20
@export var debug_fast_forward_seconds: float = 10.0
@export var debug_log_crisis_timeline: bool = true
@export var debug_log_tag_synergies: bool = true
@export var debug_show_crisis_banner: bool = true
@export var enable_tag_synergies: bool = true
@export var synergy_popup_enabled: bool = true
@export var synergy_popup_duration_seconds: float = 3.4
@export var synergy_popup_fade_seconds: float = 0.36
@export var final_crisis_intro_popup_enabled: bool = true
@export var run_intro_popup_enabled: bool = true
@export var run_intro_popup_duration_seconds: float = 8.0
@export var enable_crisis_ui_accents: bool = true
@export var crisis_spawn_wait_multiplier_active: float = 1.45
@export var containment_sweep_concurrent_count: int = 2
@export var containment_sweep_spacing: float = 220.0
@export var containment_sweep_contact_damage: int = 50
@export var containment_sweep_contact_cooldown_seconds: float = 0.45
@export var final_containment_concurrent_count: int = 2
@export var final_containment_spacing: float = 220.0
@export var final_containment_wave_duration_seconds: float = 16.5
@export var final_containment_wave_interval_seconds: float = 7.2
@export var final_containment_pass_count: int = 1
@export var biohazard_leak_initial_spawn_count: int = 0
@export var biohazard_leak_spawn_interval_seconds: float = 1.0
@export var final_biohazard_spawn_interval_multiplier: float = 0.70
@export var final_biohazard_max_active_bonus: int = 8
@export var biohazard_leak_player_position_sample_interval_seconds: float = 0.20
@export var biohazard_leak_player_position_history_seconds: float = 10.0
@export var biohazard_leak_player_position_min_age_seconds: float = 1.2
@export var biohazard_leak_max_active_zones: int = 28
@export var biohazard_leak_min_distance_between_zones: float = 165.0
@export var biohazard_leak_spawn_resolve_attempts: int = 10
@export var biohazard_leak_prediction_strength: float = 0.70
@export var biohazard_leak_prediction_extra_lead_seconds: float = 0.25
@export var biohazard_leak_prediction_window_seconds: float = 2.4
@export var biohazard_leak_prediction_path_factor: float = 0.80
@export var biohazard_leak_target_attraction_weight: float = 0.22
@export var biohazard_leak_collision_radius: float = 94.0
@export var biohazard_leak_damage_tick_amount: int = 5
@export var biohazard_leak_damage_tick_interval_seconds: float = 0.2
@export var biohazard_leak_telegraph_duration_min: float = 0.45
@export var biohazard_leak_telegraph_duration_max: float = 0.95
@export var strain_bloom_elite_spawn_radius_min: float = 180.0
@export var strain_bloom_elite_spawn_radius_max: float = 280.0
@export var strain_bloom_elite_speed_multiplier: float = 1.45
@export var strain_bloom_elite_hp_multiplier: float = 4.0
@export var strain_bloom_elite_damage_multiplier: float = 1.8
@export var strain_bloom_elite_scale_multiplier: float = 1.55
@export var strain_bloom_elite_tint: Color = Color(0.62, 1.0, 0.22, 1.0)
@export var final_crisis_elite_count: int = 2

const LINEAGE_CHOICES: Array[String] = ["predator", "swarm", "bulwark"]

func _ready() -> void:
	_reset_runtime_state()
	if arena_tint_rect != null:
		_base_arena_tint_color = arena_tint_rect.color

	if OS.has_feature("standalone") and not OS.has_feature("dev_cheats"):
		debug_allow_grant_xp = false

	if player != null and player.has_signal("hp_changed"):
		player.connect("hp_changed", Callable(self, "_on_player_hp_changed"))
	if player != null and player.has_signal("died"):
		player.connect("died", Callable(self, "_on_player_died"))
	if xp_system != null and xp_system.has_signal("xp_changed"):
		xp_system.connect("xp_changed", Callable(self, "_on_xp_changed"))
	if xp_system != null and xp_system.has_signal("level_changed"):
		xp_system.connect("level_changed", Callable(self, "_on_level_changed"))
	if xp_system != null and xp_system.has_signal("leveled_up"):
		xp_system.connect("leveled_up", Callable(self, "_on_player_leveled_up"))
	if mutation_system != null and mutation_system.has_method("setup"):
		mutation_system.call("setup", player)
	if mutation_system != null and mutation_system.has_signal("lineage_changed"):
		mutation_system.connect("lineage_changed", Callable(self, "_on_lineage_changed"))
	if mutation_system != null and mutation_system.has_signal("mutation_applied"):
		mutation_system.connect("mutation_applied", Callable(self, "_on_mutation_applied"))
	_sync_mutation_inventory_levels()
	_apply_runtime_reward_effects()
	_ensure_inventory_tooltip_ui()
	_ensure_synergy_popup_ui()
	_refresh_run_inventory_ui()

	if player != null:
		var current_hp_value = player.get("current_hp")
		var max_hp_value = player.get("max_hp")
		if current_hp_value != null and max_hp_value != null:
			_on_player_hp_changed(current_hp_value, max_hp_value)
	if xp_system != null:
		var current_xp_value = xp_system.get("current_xp")
		var xp_to_next_level_value = xp_system.get("xp_to_next_level")
		var current_level_value = xp_system.get("current_level")
		if current_xp_value != null and xp_to_next_level_value != null:
			_on_xp_changed(int(current_xp_value), int(xp_to_next_level_value))
		if current_level_value != null:
			_on_level_changed(int(current_level_value))
	_update_timer_label()
	_refresh_lineage_labels()
	_refresh_metabolism_hud()
	_setup_crisis_director()
	_update_crisis_debug_banner()
	_setup_audio_controls()
	_play_music("bgm_main")
	_queue_run_intro_popup()

	for node in get_tree().get_nodes_in_group("biomass_pickups"):
		_connect_biomass_pickup(node as Node)
	for node in get_tree().get_nodes_in_group("enemies"):
		_connect_enemy_death(node as Node)
	get_tree().connect("node_added", Callable(self, "_on_tree_node_added"))

	if game_over_ui != null:
		game_over_ui.visible = false
	if victory_ui != null:
		victory_ui.visible = false

	if game_over_main_menu_button != null:
		game_over_main_menu_button.disabled = false
		var game_over_main_menu_callable := Callable(self, "_on_game_over_main_menu_pressed")
		if not game_over_main_menu_button.pressed.is_connected(game_over_main_menu_callable):
			game_over_main_menu_button.pressed.connect(game_over_main_menu_callable)
	if victory_main_menu_button != null:
		victory_main_menu_button.disabled = false
		var victory_main_menu_callable := Callable(self, "_on_game_over_main_menu_pressed")
		if not victory_main_menu_button.pressed.is_connected(victory_main_menu_callable):
			victory_main_menu_button.pressed.connect(victory_main_menu_callable)

	if pause_menu_ui != null:
		pause_menu_ui.visible = false
	if pause_options_panel != null:
		pause_options_panel.visible = false
	if pause_resume_button != null:
		var resume_callable := Callable(self, "_on_pause_resume_pressed")
		if not pause_resume_button.pressed.is_connected(resume_callable):
			pause_resume_button.pressed.connect(resume_callable)
	if pause_options_button != null:
		var options_callable := Callable(self, "_on_pause_options_pressed")
		if not pause_options_button.pressed.is_connected(options_callable):
			pause_options_button.pressed.connect(options_callable)
	if pause_main_menu_button != null:
		var main_menu_callable := Callable(self, "_on_pause_main_menu_pressed")
		if not pause_main_menu_button.pressed.is_connected(main_menu_callable):
			pause_main_menu_button.pressed.connect(main_menu_callable)

	if levelup_ui != null:
		levelup_ui.visible = false

	if levelup_choice_1 != null:
		levelup_choice_1.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(0))
	if levelup_choice_2 != null:
		levelup_choice_2.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(1))
	if levelup_choice_3 != null:
		levelup_choice_3.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(2))
	if lineage_choice_1 != null:
		lineage_choice_1.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(0))
	if lineage_choice_2 != null:
		lineage_choice_2.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(1))
	if lineage_choice_3 != null:
		lineage_choice_3.connect("pressed", Callable(self, "_on_levelup_choice_pressed").bind(2))
	_set_levelup_mode(false)

func _reset_runtime_state() -> void:
	elapsed_seconds = 0.0
	level_reached = 1
	run_ended = false
	run_paused_for_levelup = false
	run_paused_for_menu = false
	pending_levelup_count = 0
	levelup_options.clear()
	lineage_selection_active = false
	crisis_reward_selection_active = false
	active_crisis_reward_id = ""
	crisis_reward_options.clear()
	_reward_module_damage_multiplier = 1.0
	_reward_orbiter_speed_multiplier = 1.0
	_reward_pulse_radius_multiplier = 1.0
	_reward_acid_lifetime_multiplier = 1.0
	_reward_move_speed_multiplier = 1.0
	_reward_external_damage_multiplier = 1.0
	_reward_bonus_max_hp_flat = 0
	_reward_passive_regen_per_second = 0.0
	_reward_passive_regen_progress = 0.0
	_synergy_module_damage_multiplier = 1.0
	_synergy_orbiter_speed_multiplier = 1.0
	_synergy_pulse_radius_multiplier = 1.0
	_synergy_acid_lifetime_multiplier = 1.0
	_synergy_move_speed_multiplier = 1.0
	_synergy_external_damage_multiplier = 1.0
	_synergy_passive_regen_per_second = 0.0
	_active_tag_synergy_ids.clear()
	_last_logged_tag_synergy_signature = ""
	_run_mutation_inventory_levels.clear()
	_run_reward_inventory.clear()
	_run_reward_inventory_order.clear()
	_final_crisis_intro_popup_shown = false
	_run_intro_popup_shown = false
	_synergy_popup_queue.clear()
	_hide_synergy_popup(false)
	_final_crisis_active = false
	_final_containment_wave_elapsed_seconds = 0.0
	_hide_inventory_tooltip()
	game_over_main_menu_requested = false
	_last_player_hp = -1
	_pending_crisis_failure_audio = false
	_last_run_end_reason = ""
	_last_containment_sweep_hit_seconds = -1000.0
	_clear_containment_sweep()
	_clear_biohazard_leaks()
	_clear_final_crisis_elites()
	_clear_strain_bloom_state()
	if crisis_director != null and crisis_director.has_method("reset_runtime_state"):
		crisis_director.call("reset_runtime_state")
	_apply_crisis_ui_accent("idle", "", 0.0)
	_refresh_run_inventory_ui()

func _setup_crisis_director() -> void:
	if crisis_director == null:
		return

	if crisis_director.has_method("reset_runtime_state"):
		crisis_director.call("reset_runtime_state")

	if crisis_director.has_signal("crisis_phase_changed"):
		var phase_changed_callable := Callable(self, "_on_crisis_phase_changed")
		if not crisis_director.is_connected("crisis_phase_changed", phase_changed_callable):
			crisis_director.connect("crisis_phase_changed", phase_changed_callable)
	if crisis_director.has_signal("crisis_started"):
		var crisis_started_callable := Callable(self, "_on_crisis_started")
		if not crisis_director.is_connected("crisis_started", crisis_started_callable):
			crisis_director.connect("crisis_started", crisis_started_callable)
	if crisis_director.has_signal("crisis_reward_started"):
		var reward_started_callable := Callable(self, "_on_crisis_reward_started")
		if not crisis_director.is_connected("crisis_reward_started", reward_started_callable):
			crisis_director.connect("crisis_reward_started", reward_started_callable)
	if crisis_director.has_signal("final_crisis_completed"):
		var final_completed_callable := Callable(self, "_on_final_crisis_completed")
		if not crisis_director.is_connected("final_crisis_completed", final_completed_callable):
			crisis_director.connect("final_crisis_completed", final_completed_callable)

	_set_crisis_spawn_throttle(false)

func _tick_crisis_director(delta: float) -> void:
	if crisis_director == null:
		return
	if not crisis_director.has_method("tick"):
		return
	crisis_director.call("tick", delta, elapsed_seconds)

func _on_crisis_phase_changed(new_phase: String, crisis_id: String) -> void:
	var crisis_active: bool = (new_phase == "active" or new_phase == "final")
	var is_final_purge_phase: bool = (new_phase == "final" and crisis_id == "purge_protocol")
	_set_crisis_spawn_throttle(crisis_active)
	_apply_crisis_ui_accent(new_phase, crisis_id, _get_crisis_phase_time_remaining())
	if new_phase == "reward" and crisis_id == "strain_bloom":
		_handle_strain_bloom_timeout()
	if _strain_bloom_active and crisis_id != "strain_bloom":
		_clear_strain_bloom_state()
	if _final_crisis_active and not is_final_purge_phase:
		_stop_final_crisis_composition()
	if not ((new_phase == "active" and crisis_id == "containment_sweep") or is_final_purge_phase):
		_clear_containment_sweep()
	if not ((new_phase == "active" and crisis_id == "biohazard_leak") or is_final_purge_phase):
		_clear_biohazard_leaks()
	_update_crisis_debug_banner()

	if not debug_log_crisis_timeline:
		return
	if crisis_id.is_empty():
		print("[GameManager] Crisis phase -> %s at %.1fs" % [new_phase, elapsed_seconds])
	else:
		print("[GameManager] Crisis phase -> %s (%s) at %.1fs" % [new_phase, crisis_id, elapsed_seconds])

func _set_crisis_spawn_throttle(active: bool) -> void:
	var target_multiplier: float = 1.0
	if active:
		target_multiplier = maxf(1.0, crisis_spawn_wait_multiplier_active)

	for spawner_variant in get_tree().get_nodes_in_group("enemy_spawners"):
		var spawner_node := spawner_variant as Node
		if spawner_node == null:
			continue
		if not spawner_node.has_method("set_crisis_spawn_wait_multiplier"):
			continue
		spawner_node.call("set_crisis_spawn_wait_multiplier", target_multiplier)

func _start_final_crisis_composition(active_duration_seconds: float) -> void:
	_final_crisis_active = true
	_final_containment_wave_elapsed_seconds = 0.0
	_spawn_containment_sweep(
		maxf(1.0, final_containment_wave_duration_seconds),
		maxi(1, final_containment_concurrent_count),
		maxf(40.0, final_containment_spacing),
		maxi(1, final_containment_pass_count)
	)
	_spawn_biohazard_leaks(active_duration_seconds)
	_spawn_final_crisis_elites(maxi(1, final_crisis_elite_count))
	if debug_log_crisis_timeline:
		print("[GameManager] Final composition armed: sweep + leaks + %d elites" % maxi(1, final_crisis_elite_count))

func _stop_final_crisis_composition() -> void:
	_final_crisis_active = false
	_final_containment_wave_elapsed_seconds = 0.0
	_clear_final_crisis_elites()

func _tick_final_crisis_layers(delta: float) -> void:
	if not _final_crisis_active:
		return
	if delta <= 0.0:
		return

	_final_containment_wave_elapsed_seconds += delta
	var wave_interval: float = maxf(1.0, final_containment_wave_interval_seconds)
	if _final_containment_wave_elapsed_seconds < wave_interval:
		return
	if not _active_containment_sweeps.is_empty():
		return

	_final_containment_wave_elapsed_seconds = 0.0
	_spawn_containment_sweep(
		maxf(1.0, final_containment_wave_duration_seconds),
		maxi(1, final_containment_concurrent_count),
		maxf(40.0, final_containment_spacing),
		maxi(1, final_containment_pass_count)
	)

func _spawn_final_crisis_elites(count: int) -> void:
	var spawn_count: int = maxi(0, count)
	if spawn_count <= 0:
		return

	var player_node := player as Node2D
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node == null:
		return

	for _spawn_index in range(spawn_count):
		var elite_node := STRAIN_BLOOM_ELITE_SCENE.instantiate() as Node2D
		if elite_node == null:
			continue

		var min_spawn_radius: float = maxf(40.0, strain_bloom_elite_spawn_radius_min)
		var max_spawn_radius: float = maxf(min_spawn_radius + 1.0, strain_bloom_elite_spawn_radius_max)
		var spawn_radius: float = randf_range(min_spawn_radius, max_spawn_radius)
		var spawn_angle: float = randf() * TAU
		elite_node.global_position = player_node.global_position + Vector2.RIGHT.rotated(spawn_angle) * spawn_radius

		var spawn_parent: Node = get_tree().current_scene
		if spawn_parent == null:
			spawn_parent = self
		spawn_parent.add_child(elite_node)

		_configure_strain_bloom_elite(elite_node)
		_connect_enemy_death(elite_node)
		_final_crisis_elites.append(elite_node)

		var elite_died_callable := Callable(self, "_on_final_crisis_elite_died").bind(elite_node)
		if elite_node.has_signal("died") and not elite_node.is_connected("died", elite_died_callable):
			elite_node.connect("died", elite_died_callable)

func _on_final_crisis_elite_died(_world_position: Vector2, elite_node: Node2D) -> void:
	if elite_node == null:
		return
	_final_crisis_elites.erase(elite_node)

func _clear_final_crisis_elites() -> void:
	for elite_node in _final_crisis_elites:
		if elite_node == null:
			continue
		if not is_instance_valid(elite_node):
			continue
		elite_node.queue_free()
	_final_crisis_elites.clear()

func _spawn_strain_bloom_elite() -> void:
	_clear_strain_bloom_state()

	var player_node := player as Node2D
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node == null:
		return

	var elite_node := STRAIN_BLOOM_ELITE_SCENE.instantiate() as Node2D
	if elite_node == null:
		return

	var min_spawn_radius: float = maxf(40.0, strain_bloom_elite_spawn_radius_min)
	var max_spawn_radius: float = maxf(min_spawn_radius + 1.0, strain_bloom_elite_spawn_radius_max)
	var spawn_radius: float = randf_range(min_spawn_radius, max_spawn_radius)
	var spawn_angle: float = randf() * TAU
	elite_node.global_position = player_node.global_position + Vector2.RIGHT.rotated(spawn_angle) * spawn_radius

	var spawn_parent: Node = get_tree().current_scene
	if spawn_parent == null:
		spawn_parent = self
	spawn_parent.add_child(elite_node)

	_configure_strain_bloom_elite(elite_node)
	_connect_enemy_death(elite_node)
	_connect_strain_bloom_elite(elite_node)
	_strain_bloom_active = true
	_strain_bloom_elite_killed = false
	_strain_bloom_elite_target = elite_node

	if debug_log_crisis_timeline:
		print("[GameManager] Strain Bloom elite spawned at ", elite_node.global_position)

func _connect_strain_bloom_elite(elite_node: Node2D) -> void:
	if elite_node == null:
		return
	if not elite_node.has_signal("died"):
		return
	var elite_died_callable := Callable(self, "_on_strain_bloom_elite_died").bind(elite_node)
	if elite_node.is_connected("died", elite_died_callable):
		return
	elite_node.connect("died", elite_died_callable)

func _on_strain_bloom_elite_died(_world_position: Vector2, elite_node: Node2D) -> void:
	if elite_node != _strain_bloom_elite_target:
		return
	_strain_bloom_elite_killed = true
	_strain_bloom_elite_target = null
	if debug_log_crisis_timeline:
		print("[GameManager] Strain Bloom elite eliminated with %.1fs remaining" % _get_crisis_phase_time_remaining())
	_complete_strain_bloom_early()

func _complete_strain_bloom_early() -> void:
	if crisis_director == null:
		return
	if not crisis_director.has_method("complete_active_crisis_early"):
		return
	var completed_early: bool = bool(crisis_director.call("complete_active_crisis_early", "strain_bloom"))
	if debug_log_crisis_timeline and completed_early:
		print("[GameManager] Strain Bloom completed early by elite kill")

func _handle_strain_bloom_timeout() -> void:
	if not _strain_bloom_active:
		return
	if _is_strain_bloom_elite_alive():
		if debug_log_crisis_timeline:
			print("[GameManager] Strain Bloom failed (elite alive at timeout)")
		_fail_run_immediately("Strain Bloom objective failed")
		_clear_strain_bloom_state()
		return
	if debug_log_crisis_timeline:
		print("[GameManager] Strain Bloom success before timeout")
	_clear_strain_bloom_state()

func _is_strain_bloom_elite_alive() -> bool:
	return _strain_bloom_elite_target != null and is_instance_valid(_strain_bloom_elite_target)

func _clear_strain_bloom_state() -> void:
	_strain_bloom_active = false
	_strain_bloom_elite_killed = false
	_strain_bloom_elite_target = null

func _configure_strain_bloom_elite(enemy_node: Node2D) -> void:
	if enemy_node == null:
		return

	var speed_multiplier: float = maxf(0.1, strain_bloom_elite_speed_multiplier)
	var hp_multiplier: float = maxf(0.1, strain_bloom_elite_hp_multiplier)
	var damage_multiplier: float = maxf(0.1, strain_bloom_elite_damage_multiplier)
	var scale_multiplier: float = maxf(0.1, strain_bloom_elite_scale_multiplier)

	if enemy_node.has_method("apply_elite_profile"):
		enemy_node.call(
			"apply_elite_profile",
			speed_multiplier,
			hp_multiplier,
			damage_multiplier,
			scale_multiplier,
			strain_bloom_elite_tint
		)
		return

	enemy_node.scale *= scale_multiplier

func _spawn_containment_sweep(
	active_duration_seconds: float,
	concurrent_count_override: int = -1,
	spacing_override: float = -1.0,
	pass_count_override: int = -1
) -> void:
	_clear_containment_sweep()

	var sweep_center: Vector2 = Vector2.ZERO
	var player_node := player as Node2D
	if player_node != null:
		sweep_center = player_node.global_position
		var spawn_offset: Vector2 = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(80.0, 190.0)
		sweep_center += spawn_offset

	var sweep_pass_count: int = 3
	if active_duration_seconds > 20.0:
		sweep_pass_count = 4
	if pass_count_override > 0:
		sweep_pass_count = pass_count_override
	var concurrent_count: int = maxi(1, containment_sweep_concurrent_count)
	if concurrent_count_override > 0:
		concurrent_count = maxi(1, concurrent_count_override)
	var spacing: float = maxf(40.0, containment_sweep_spacing)
	if spacing_override > 0.0:
		spacing = maxf(40.0, spacing_override)
	var split_axis: Vector2 = Vector2.RIGHT.rotated(randf() * TAU).normalized()

	for i in range(concurrent_count):
		var sweep_node := CONTAINMENT_SWEEP_SCENE.instantiate() as Node2D
		if sweep_node == null:
			continue

		add_child(sweep_node)
		_active_containment_sweeps.append(sweep_node)

		var centered_index: float = float(i) - (float(concurrent_count - 1) * 0.5)
		var local_center: Vector2 = sweep_center + (split_axis * centered_index * spacing)

		if sweep_node.has_method("set"):
			sweep_node.set("sweep_pass_count", sweep_pass_count)

		if sweep_node.has_method("begin_sweep"):
			sweep_node.call("begin_sweep", local_center, active_duration_seconds)

		var sweep_finished_callable := Callable(self, "_on_containment_sweep_finished").bind(sweep_node)
		if sweep_node.has_signal("sweep_finished") and not sweep_node.is_connected("sweep_finished", sweep_finished_callable):
			sweep_node.connect("sweep_finished", sweep_finished_callable)

		var player_contacted_callable := Callable(self, "_on_containment_sweep_player_contacted")
		if sweep_node.has_signal("player_contacted") and not sweep_node.is_connected("player_contacted", player_contacted_callable):
			sweep_node.connect("player_contacted", player_contacted_callable)

func _clear_containment_sweep() -> void:
	for sweep_node in _active_containment_sweeps:
		if sweep_node == null:
			continue
		if not is_instance_valid(sweep_node):
			continue
		sweep_node.queue_free()
	_active_containment_sweeps.clear()

func _on_containment_sweep_finished(sweep_node: Node2D) -> void:
	if sweep_node != null:
		_active_containment_sweeps.erase(sweep_node)

func _spawn_biohazard_leaks(_active_duration_seconds: float) -> void:
	_clear_biohazard_leaks()
	_biohazard_leak_elapsed_seconds = 0.0
	_set_biohazard_leak_spawner_active(true)

	var player_node: Node2D = _get_biohazard_player_node()
	if player_node != null:
		_record_biohazard_player_position(player_node.global_position)

	var initial_spawn_count: int = maxi(0, biohazard_leak_initial_spawn_count)
	for _spawn_index in range(initial_spawn_count):
		_spawn_one_biohazard_leak()

	if debug_log_crisis_timeline:
		print("[GameManager] Biohazard leak spawner started")

func _set_biohazard_leak_spawner_active(active: bool) -> void:
	_biohazard_leak_spawner_active = active
	if not active:
		_biohazard_leak_spawn_accumulator = 0.0
		_biohazard_leak_position_sample_accumulator = 0.0
		_biohazard_leak_elapsed_seconds = 0.0
		_biohazard_recent_player_positions.clear()

func _tick_biohazard_leak_spawner(delta: float) -> void:
	if not _biohazard_leak_spawner_active:
		return
	if delta <= 0.0:
		return

	var player_node: Node2D = _get_biohazard_player_node()
	if player_node == null:
		return

	_biohazard_leak_elapsed_seconds += delta
	_biohazard_leak_position_sample_accumulator += delta
	var sample_interval: float = maxf(0.05, biohazard_leak_player_position_sample_interval_seconds)
	while _biohazard_leak_position_sample_accumulator >= sample_interval:
		_biohazard_leak_position_sample_accumulator -= sample_interval
		_record_biohazard_player_position(player_node.global_position)
	_prune_biohazard_position_history()

	var max_active_zones: int = maxi(1, biohazard_leak_max_active_zones)
	if _final_crisis_active:
		max_active_zones += maxi(0, final_biohazard_max_active_bonus)
	if _active_biohazard_leaks.size() >= max_active_zones:
		return

	_biohazard_leak_spawn_accumulator += delta
	var spawn_interval: float = maxf(0.05, biohazard_leak_spawn_interval_seconds)
	if _final_crisis_active:
		var final_interval_multiplier: float = clampf(final_biohazard_spawn_interval_multiplier, 0.15, 1.0)
		spawn_interval = maxf(0.05, spawn_interval * final_interval_multiplier)
	while _biohazard_leak_spawn_accumulator >= spawn_interval:
		_biohazard_leak_spawn_accumulator -= spawn_interval
		if _active_biohazard_leaks.size() >= max_active_zones:
			break
		_spawn_one_biohazard_leak(player_node)

func _get_biohazard_player_node() -> Node2D:
	var player_node: Node2D = player as Node2D
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as Node2D
	return player_node

func _record_biohazard_player_position(player_position: Vector2) -> void:
	_biohazard_recent_player_positions.append({
		"position": player_position,
		"time": _biohazard_leak_elapsed_seconds
	})

func _prune_biohazard_position_history() -> void:
	var max_age_seconds: float = maxf(2.0, biohazard_leak_player_position_history_seconds)
	for index in range(_biohazard_recent_player_positions.size() - 1, -1, -1):
		var entry_variant: Variant = _biohazard_recent_player_positions[index]
		if not (entry_variant is Dictionary):
			_biohazard_recent_player_positions.remove_at(index)
			continue
		var entry: Dictionary = entry_variant
		var sample_time: float = float(entry.get("time", -1.0))
		var age_seconds: float = _biohazard_leak_elapsed_seconds - sample_time
		if age_seconds > max_age_seconds:
			_biohazard_recent_player_positions.remove_at(index)

func _spawn_one_biohazard_leak(optional_player_node: Node2D = null) -> void:
	var player_node: Node2D = optional_player_node
	if player_node == null:
		player_node = _get_biohazard_player_node()
	if player_node == null:
		return

	var min_telegraph_duration: float = maxf(0.05, biohazard_leak_telegraph_duration_min)
	var max_telegraph_duration: float = maxf(min_telegraph_duration, biohazard_leak_telegraph_duration_max)

	var telegraph_duration: float = randf_range(min_telegraph_duration, max_telegraph_duration)
	var leak_center: Vector2 = _select_biohazard_spawn_position(player_node, telegraph_duration)

	var leak_zone := BIOHAZARD_LEAK_ZONE_SCENE.instantiate() as Node2D
	if leak_zone == null:
		return
	add_child(leak_zone)
	_active_biohazard_leaks.append(leak_zone)

	leak_zone.set("collision_radius", maxf(8.0, biohazard_leak_collision_radius))
	leak_zone.set("damage_tick_amount", maxi(1, biohazard_leak_damage_tick_amount))
	leak_zone.set("damage_tick_interval_seconds", maxf(0.01, biohazard_leak_damage_tick_interval_seconds))
	leak_zone.set("telegraph_duration_seconds", telegraph_duration)

	if leak_zone.has_method("begin_leak"):
		leak_zone.call("begin_leak", leak_center)
	else:
		leak_zone.global_position = leak_center

	var leak_finished_callable := Callable(self, "_on_biohazard_leak_finished").bind(leak_zone)
	if leak_zone.has_signal("leak_finished") and not leak_zone.is_connected("leak_finished", leak_finished_callable):
		leak_zone.connect("leak_finished", leak_finished_callable)
	var leak_exposed_callable := Callable(self, "_on_biohazard_leak_player_exposed")
	if leak_zone.has_signal("player_exposed") and not leak_zone.is_connected("player_exposed", leak_exposed_callable):
		leak_zone.connect("player_exposed", leak_exposed_callable)

func _select_biohazard_spawn_position(player_node: Node2D, telegraph_duration_seconds: float) -> Vector2:
	var lead_seconds: float = maxf(0.0, telegraph_duration_seconds + biohazard_leak_prediction_extra_lead_seconds)
	var trend_velocity: Vector2 = _get_biohazard_trend_velocity(player_node)
	var predicted_player_position: Vector2 = _predict_player_position(player_node, lead_seconds)
	var candidate_positions: Array[Vector2] = []
	var min_age_seconds: float = maxf(0.0, biohazard_leak_player_position_min_age_seconds)
	var path_factor: float = clampf(biohazard_leak_prediction_path_factor, 0.0, 1.5)
	var projection_offset: Vector2 = trend_velocity * lead_seconds * path_factor

	for entry_variant in _biohazard_recent_player_positions:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		var sample_time: float = float(entry.get("time", -1.0))
		if sample_time < 0.0:
			continue
		var age_seconds: float = _biohazard_leak_elapsed_seconds - sample_time
		if age_seconds < min_age_seconds:
			continue
		var position_variant: Variant = entry.get("position", null)
		if not (position_variant is Vector2):
			continue
		var sample_position: Vector2 = position_variant
		candidate_positions.append(sample_position)
		candidate_positions.append(sample_position + projection_offset)

	if candidate_positions.is_empty():
		for entry_variant in _biohazard_recent_player_positions:
			if not (entry_variant is Dictionary):
				continue
			var entry: Dictionary = entry_variant
			var position_variant: Variant = entry.get("position", null)
			if not (position_variant is Vector2):
				continue
			var sample_position: Vector2 = position_variant
			candidate_positions.append(sample_position)
			candidate_positions.append(sample_position + projection_offset)

	if candidate_positions.is_empty():
		return predicted_player_position

	var best_position: Vector2 = candidate_positions[0]
	var best_score: float = -INF
	var prediction_strength: float = clampf(biohazard_leak_prediction_strength, 0.0, 1.0)
	var attraction_weight: float = clampf(biohazard_leak_target_attraction_weight, 0.0, 1.0)
	for candidate_position in candidate_positions:
		var candidate_position_vec: Vector2 = candidate_position
		var leak_distance: float = _get_biohazard_min_distance_to_existing(candidate_position_vec)
		var predicted_distance: float = candidate_position_vec.distance_to(predicted_player_position)
		var candidate_score: float = leak_distance
		candidate_score -= predicted_distance * prediction_strength
		candidate_score -= predicted_distance * attraction_weight
		candidate_score += randf_range(0.0, 10.0)
		if candidate_score > best_score:
			best_score = candidate_score
			best_position = candidate_position_vec

	var min_separation: float = maxf(24.0, biohazard_leak_min_distance_between_zones)
	return _resolve_biohazard_spawn_position(best_position, predicted_player_position, min_separation, attraction_weight)

func _resolve_biohazard_spawn_position(
	base_position: Vector2,
	target_position: Vector2,
	min_separation: float,
	attraction_weight: float
) -> Vector2:
	var resolved_position: Vector2 = base_position
	var best_score: float = _get_biohazard_min_distance_to_existing(base_position)
	best_score -= base_position.distance_to(target_position) * attraction_weight

	if _get_biohazard_min_distance_to_existing(base_position) >= min_separation:
		return base_position

	var attempts: int = maxi(1, biohazard_leak_spawn_resolve_attempts)
	for _attempt_index in range(attempts):
		var angle: float = randf() * TAU
		var offset_distance: float = randf_range(min_separation * 0.45, min_separation * 1.2)
		var candidate_position: Vector2 = base_position + Vector2.RIGHT.rotated(angle) * offset_distance
		var leak_distance: float = _get_biohazard_min_distance_to_existing(candidate_position)
		var candidate_score: float = leak_distance - (candidate_position.distance_to(target_position) * attraction_weight)
		if candidate_score > best_score:
			best_score = candidate_score
			resolved_position = candidate_position
			if leak_distance >= min_separation:
				break

	return resolved_position

func _predict_player_position(player_node: Node2D, lead_seconds: float) -> Vector2:
	if player_node == null:
		return Vector2.ZERO
	var current_position: Vector2 = player_node.global_position
	var trend_velocity: Vector2 = _get_biohazard_trend_velocity(player_node)
	if trend_velocity.length_squared() > 0.0001:
		return current_position + trend_velocity * maxf(0.0, lead_seconds)
	return current_position

func _get_biohazard_trend_velocity(player_node: Node2D) -> Vector2:
	if player_node == null:
		return Vector2.ZERO

	var fallback_velocity: Vector2 = Vector2.ZERO
	var velocity_variant: Variant = player_node.get("velocity")
	if velocity_variant is Vector2:
		fallback_velocity = velocity_variant

	var prediction_window: float = maxf(0.25, biohazard_leak_prediction_window_seconds)
	var weighted_velocity: Vector2 = Vector2.ZERO
	var total_weight: float = 0.0

	for index in range(1, _biohazard_recent_player_positions.size()):
		var previous_variant: Variant = _biohazard_recent_player_positions[index - 1]
		var current_variant: Variant = _biohazard_recent_player_positions[index]
		if not (previous_variant is Dictionary) or not (current_variant is Dictionary):
			continue

		var previous_entry: Dictionary = previous_variant
		var current_entry: Dictionary = current_variant
		var previous_time: float = float(previous_entry.get("time", -1.0))
		var current_time: float = float(current_entry.get("time", -1.0))
		if previous_time < 0.0 or current_time < 0.0:
			continue
		var delta_time: float = current_time - previous_time
		if delta_time <= 0.0001:
			continue

		var segment_age: float = _biohazard_leak_elapsed_seconds - current_time
		if segment_age > prediction_window:
			continue

		var previous_position_variant: Variant = previous_entry.get("position", null)
		var current_position_variant: Variant = current_entry.get("position", null)
		if not (previous_position_variant is Vector2) or not (current_position_variant is Vector2):
			continue

		var previous_position: Vector2 = previous_position_variant
		var current_position: Vector2 = current_position_variant
		var segment_velocity: Vector2 = (current_position - previous_position) / delta_time
		var recency_weight: float = clampf(1.0 - (segment_age / prediction_window), 0.12, 1.0)
		weighted_velocity += segment_velocity * recency_weight
		total_weight += recency_weight

	var trend_velocity: Vector2 = fallback_velocity
	if total_weight > 0.0:
		trend_velocity = weighted_velocity / total_weight
		if fallback_velocity.length_squared() > 0.0001:
			trend_velocity = trend_velocity.lerp(fallback_velocity, 0.25)

	return trend_velocity

func _get_biohazard_min_distance_to_existing(target_position: Vector2) -> float:
	var min_distance: float = INF
	for leak_zone in _active_biohazard_leaks:
		if leak_zone == null:
			continue
		if not is_instance_valid(leak_zone):
			continue
		var candidate_distance: float = target_position.distance_to(leak_zone.global_position)
		min_distance = minf(min_distance, candidate_distance)
	if min_distance == INF:
		return 999999.0
	return min_distance

func _clear_biohazard_leaks() -> void:
	_set_biohazard_leak_spawner_active(false)
	for leak_zone in _active_biohazard_leaks:
		if leak_zone == null:
			continue
		if not is_instance_valid(leak_zone):
			continue
		leak_zone.queue_free()
	_active_biohazard_leaks.clear()
	_clear_untracked_biohazard_leaks()

func _clear_untracked_biohazard_leaks() -> void:
	for leak_variant in get_tree().get_nodes_in_group("biohazard_leaks"):
		var leak_node := leak_variant as Node
		if leak_node == null:
			continue
		if not is_instance_valid(leak_node):
			continue
		leak_node.queue_free()

func _on_biohazard_leak_finished(leak_zone: Node2D) -> void:
	if leak_zone != null:
		_active_biohazard_leaks.erase(leak_zone)

func _on_biohazard_leak_player_exposed(_player_node: Node) -> void:
	if not _is_biohazard_leak_crisis_active():
		return
	if debug_log_crisis_timeline:
		print("[GameManager] Biohazard leak exposure - damage applied")

func _is_biohazard_leak_crisis_active() -> bool:
	if crisis_director == null:
		return false
	if not crisis_director.has_method("get_phase"):
		return false
	if not crisis_director.has_method("get_active_crisis_id"):
		return false
	var phase_name: String = String(crisis_director.call("get_phase"))
	var crisis_id: String = String(crisis_director.call("get_active_crisis_id"))
	return phase_name == "active" and crisis_id == "biohazard_leak"

func _on_containment_sweep_player_contacted(_player_node: Node) -> void:
	if run_ended:
		return
	if player == null:
		return
	if not player.has_method("take_damage"):
		return
	var cooldown_seconds: float = maxf(0.0, containment_sweep_contact_cooldown_seconds)
	if (elapsed_seconds - _last_containment_sweep_hit_seconds) < cooldown_seconds:
		return
	_last_containment_sweep_hit_seconds = elapsed_seconds
	player.call("take_damage", maxi(1, containment_sweep_contact_damage))
	if debug_log_crisis_timeline:
		print("[GameManager] Containment sweep hit player for ", containment_sweep_contact_damage)

func _fail_run_immediately(reason_text: String = "") -> void:
	if run_ended:
		return
	_pending_crisis_failure_audio = true
	_last_run_end_reason = _resolve_failure_reason(reason_text)
	if debug_log_crisis_timeline and not reason_text.is_empty():
		print("[GameManager] Crisis failure: %s at %.1fs" % [reason_text, elapsed_seconds])
	if player == null:
		return

	if player.has_method("force_die"):
		player.call("force_die")
		return

	if player.has_method("take_damage"):
		var max_hp_value: int = int(player.get("max_hp"))
		player.call("take_damage", maxi(9999, max_hp_value * 10))

func _update_crisis_debug_banner() -> void:
	var phase_name: String = "idle"
	var crisis_id: String = ""
	var phase_seconds_remaining: float = 0.0
	var next_crisis_seconds: float = 0.0

	if crisis_director != null and crisis_director.has_method("get_phase"):
		phase_name = String(crisis_director.call("get_phase"))
		if crisis_director.has_method("get_active_crisis_id"):
			crisis_id = String(crisis_director.call("get_active_crisis_id"))
		if crisis_director.has_method("get_phase_time_remaining"):
			phase_seconds_remaining = float(crisis_director.call("get_phase_time_remaining"))
		if crisis_director.has_method("get_time_until_next_crisis"):
			next_crisis_seconds = float(crisis_director.call("get_time_until_next_crisis", elapsed_seconds))

	_apply_crisis_ui_accent(phase_name, crisis_id, phase_seconds_remaining)

	if crisis_debug_label == null:
		return
	if not debug_show_crisis_banner:
		crisis_debug_label.visible = false
		return
	if crisis_director == null:
		crisis_debug_label.visible = false
		return
	if not crisis_director.has_method("get_phase"):
		crisis_debug_label.visible = false
		return

	var timer_text: String = ""
	if phase_name == "idle":
		timer_text = "Next in %.1fs" % next_crisis_seconds
	else:
		timer_text = "T-%.1fs" % phase_seconds_remaining

	var objective_text: String = _get_crisis_objective_text(phase_name, crisis_id)
	crisis_debug_label.visible = true
	crisis_debug_label.text = "CRISIS: %s | %s\nObjective: %s" % [
		phase_name.to_upper(),
		timer_text,
		objective_text
	]

func _get_crisis_objective_text(phase_name: String, crisis_id: String) -> String:
	match phase_name:
		"idle":
			return "Prepare for incoming containment event"
		"active":
			match crisis_id:
				"containment_sweep":
					return "Evade containment sweep - %d damage on contact" % maxi(1, containment_sweep_contact_damage)
				"strain_bloom":
					if _is_strain_bloom_elite_alive():
						return "Kill elite before timer expires"
					if _strain_bloom_elite_killed:
						return "Elite down - hold until reward"
					return "Locate and eliminate elite strain"
				"biohazard_leak":
					return "Avoid leak zones - heavy damage over time"
				_:
					return "Survive active crisis"
		"reward":
			return "Choose crisis reward"
		"final":
			return "Survive purge protocol: sweeps, leaks, elite hunters"
		"victory":
			return "Run clear - outbreak ascendant"
		_:
			return "--"

func _get_crisis_accent_color(phase_name: String, crisis_id: String) -> Color:
	match phase_name:
		"idle":
			return Color(0.63, 0.78, 0.87, 1.0)
		"active":
			match crisis_id:
				"containment_sweep":
					return Color(1.0, 0.58, 0.32, 1.0)
				"strain_bloom":
					return Color(0.60, 1.0, 0.36, 1.0)
				"biohazard_leak":
					return Color(0.48, 1.0, 0.52, 1.0)
				_:
					return Color(1.0, 0.78, 0.42, 1.0)
		"reward":
			return Color(1.0, 0.86, 0.52, 1.0)
		"final":
			return Color(1.0, 0.34, 0.30, 1.0)
		"victory":
			return Color(0.60, 1.0, 0.82, 1.0)
		_:
			return Color(0.63, 0.78, 0.87, 1.0)

func _apply_crisis_ui_accent(phase_name: String, crisis_id: String, phase_seconds_remaining: float) -> void:
	if not enable_crisis_ui_accents:
		if arena_tint_rect != null:
			arena_tint_rect.color = _base_arena_tint_color
		if timer_label != null:
			timer_label.remove_theme_color_override("font_color")
		if crisis_debug_label != null:
			crisis_debug_label.remove_theme_color_override("font_color")
		return

	var accent_color: Color = _get_crisis_accent_color(phase_name, crisis_id)
	var accent_strength: float = 0.0
	match phase_name:
		"idle":
			accent_strength = 0.0
		"active":
			accent_strength = 0.26
		"reward":
			accent_strength = 0.18
		"final":
			accent_strength = 0.40
		"victory":
			accent_strength = 0.20
		_:
			accent_strength = 0.0

	if (phase_name == "active" or phase_name == "final") and phase_seconds_remaining > 0.0 and phase_seconds_remaining <= 3.0:
		accent_strength += 0.12
	accent_strength = clampf(accent_strength, 0.0, 0.55)

	if arena_tint_rect != null:
		var target_tint_color: Color = _base_arena_tint_color.lerp(accent_color, accent_strength)
		target_tint_color.a = _base_arena_tint_color.a + (0.22 * accent_strength)
		arena_tint_rect.color = target_tint_color

	if timer_label != null:
		var timer_mix: float = 0.0
		if accent_strength > 0.001:
			timer_mix = minf(0.75, accent_strength + 0.08)
		var timer_font_color: Color = Color(1.0, 1.0, 1.0, 1.0).lerp(accent_color, timer_mix)
		timer_label.add_theme_color_override("font_color", timer_font_color)

	if crisis_debug_label != null:
		var banner_font_color: Color = accent_color
		banner_font_color.a = 0.95
		crisis_debug_label.add_theme_color_override("font_color", banner_font_color)

func _on_crisis_started(crisis_id: String, is_final: bool, duration_seconds: float) -> void:
	if is_final:
		_play_sfx("final_crisis_start", -3.0, 0.82)
	else:
		_play_sfx("crisis_start", -6.0, 0.9)

	if is_final and crisis_id == "purge_protocol":
		_start_final_crisis_composition(duration_seconds)
		if final_crisis_intro_popup_enabled and not _final_crisis_intro_popup_shown:
			_final_crisis_intro_popup_shown = true
			_queue_runtime_popup(
				"FINAL CRISIS STARTED",
				"Purge protocol engaged. Survive sweeps, leaks, and elite hunters.",
				true
			)
	if not is_final and crisis_id == "containment_sweep":
		_spawn_containment_sweep(duration_seconds)
	if not is_final and crisis_id == "biohazard_leak":
		_spawn_biohazard_leaks(duration_seconds)
	if not is_final and crisis_id == "strain_bloom":
		_spawn_strain_bloom_elite()

	if not debug_log_crisis_timeline:
		return
	if is_final:
		print("[GameManager] Final crisis started: %s (%.1fs)" % [crisis_id, duration_seconds])
	else:
		print("[GameManager] Crisis started: %s (%.1fs)" % [crisis_id, duration_seconds])

func _on_crisis_reward_started(crisis_id: String, duration_seconds: float) -> void:
	if crisis_id == "biohazard_leak":
		_clear_biohazard_leaks()
		call_deferred("_verify_biohazard_cleanup")
	var reward_prompt_opened: bool = _open_crisis_reward_prompt(crisis_id)
	_play_sfx("crisis_success", -4.5, 1.08)
	if not debug_log_crisis_timeline:
		return
	print("[GameManager] Crisis reward started: %s (%.1fs)" % [crisis_id, duration_seconds])
	if reward_prompt_opened:
		print("[GameManager] Reward prompt opened with %d options for %s" % [crisis_reward_options.size(), crisis_id])

func _on_final_crisis_completed() -> void:
	if run_ended:
		return
	_end_run_common()
	_fade_out_music(1.1)
	_play_sfx("victory", 1.5, 1.0)
	_show_victory()
	if not debug_log_crisis_timeline:
		return
	print("[GameManager] Final crisis completed at %.1fs" % elapsed_seconds)

func _verify_biohazard_cleanup() -> void:
	var leaks_left: int = 0
	for leak_variant in get_tree().get_nodes_in_group("biohazard_leaks"):
		var leak_node := leak_variant as Node
		if leak_node == null:
			continue
		if not is_instance_valid(leak_node):
			continue
		leaks_left += 1
	if debug_log_crisis_timeline:
		print("[GameManager] Biohazard cleanup check: %d leak nodes remaining" % leaks_left)

func _get_crisis_phase_time_remaining() -> float:
	if crisis_director == null:
		return 0.0
	if not crisis_director.has_method("get_phase_time_remaining"):
		return 0.0
	return float(crisis_director.call("get_phase_time_remaining"))

func _process(delta: float) -> void:
	_update_inventory_tooltip_position()
	_tick_synergy_popup(delta)
	if run_ended:
		return
	if run_paused_for_menu:
		return
	if run_paused_for_levelup:
		return
	elapsed_seconds += delta
	_update_timer_label()
	_tick_reward_passive_regen(delta)
	_tick_crisis_director(delta)
	_tick_biohazard_leak_spawner(delta)
	_tick_final_crisis_layers(delta)
	_update_crisis_debug_banner()

func _get_total_bonus_regen_per_second() -> float:
	return maxf(0.0, _reward_passive_regen_per_second + _synergy_passive_regen_per_second)

func _tick_reward_passive_regen(delta: float) -> void:
	var bonus_regen_per_second: float = _get_total_bonus_regen_per_second()
	if bonus_regen_per_second <= 0.0:
		return
	if player == null:
		return
	if not player.has_method("heal"):
		return

	_reward_passive_regen_progress += bonus_regen_per_second * delta
	if _reward_passive_regen_progress < 1.0:
		return

	var heal_amount: int = int(floor(_reward_passive_regen_progress))
	if heal_amount <= 0:
		return

	_reward_passive_regen_progress -= float(heal_amount)
	player.call("heal", heal_amount)

func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event != null and key_event.pressed and not key_event.echo:
		if key_event.keycode == KEY_G and _can_use_debug_xp_cheat():
			_debug_grant_xp()
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_T and _can_use_debug_xp_cheat():
			_debug_fast_forward_time()
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_N and _can_use_debug_xp_cheat():
			_debug_force_next_crisis()
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_J and _can_use_debug_xp_cheat():
			_debug_jump_to_final_crisis_threshold()
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_ESCAPE and not run_ended and not run_paused_for_levelup:
			if run_paused_for_menu:
				_close_pause_menu()
			else:
				_open_pause_menu()
			get_viewport().set_input_as_handled()
			return

	if not run_paused_for_levelup:
		return
	if run_ended:
		return

	if key_event == null:
		return
	if not key_event.pressed:
		return
	if key_event.echo:
		return

	match key_event.keycode:
		KEY_1, KEY_KP_1:
			_on_levelup_choice_pressed(0)
			get_viewport().set_input_as_handled()
		KEY_2, KEY_KP_2:
			_on_levelup_choice_pressed(1)
			get_viewport().set_input_as_handled()
		KEY_3, KEY_KP_3:
			_on_levelup_choice_pressed(2)
			get_viewport().set_input_as_handled()

func _on_player_hp_changed(current_hp: int, max_hp: int) -> void:
	if hp_label != null:
		hp_label.text = "HP: %d/%d" % [current_hp, max_hp]
	if _last_player_hp >= 0 and current_hp < _last_player_hp:
		_play_sfx("player_hit")
	_last_player_hp = current_hp

func _on_xp_changed(current_xp: int, xp_to_next_level: int) -> void:
	if xp_bar == null:
		return
	xp_bar.min_value = 0.0
	xp_bar.max_value = float(xp_to_next_level)
	xp_bar.value = float(current_xp)

func _on_level_changed(current_level: int) -> void:
	level_reached = current_level
	if level_label == null:
		return
	level_label.text = "Level: %d" % current_level

func _on_lineage_changed(_lineage_id: String, _lineage_name: String) -> void:
	_refresh_lineage_labels()
	_refresh_metabolism_hud()

func _on_mutation_applied(_mutation_id: String, _new_level: int) -> void:
	_sync_mutation_inventory_levels()
	_apply_runtime_reward_effects()
	_refresh_run_inventory_ui()
	_refresh_metabolism_hud()

func _refresh_lineage_labels() -> void:
	var current_lineage_name: String = _get_current_lineage_name()

	if lineage_label != null:
		lineage_label.text = "Lineage: %s" % current_lineage_name

	_refresh_choice_panel_labels()

func _refresh_choice_panel_labels() -> void:
	if levelup_title_label != null:
		if crisis_reward_selection_active:
			levelup_title_label.text = "CRISIS REWARD"
		else:
			levelup_title_label.text = "EVOLVE"

	if levelup_lineage_prompt_label != null:
		if crisis_reward_selection_active:
			levelup_lineage_prompt_label.text = "Choose one adaptation"
		elif lineage_selection_active:
			levelup_lineage_prompt_label.text = "Choose your lineage"
		else:
			levelup_lineage_prompt_label.text = "Choose your mutation"

	if levelup_help_label != null:
		if crisis_reward_selection_active:
			levelup_help_label.text = "Crisis bonus applies immediately for this run."
		elif lineage_selection_active:
			levelup_help_label.text = "Choose once. It grants a core mutation and biases future options."
		else:
			levelup_help_label.text = "Tip: * marks options favored by your lineage."

func _refresh_metabolism_hud() -> void:
	if metabolism_label == null:
		return
	var metabolism_level: int = 0
	var metabolism_regen_per_second: float = 0.0
	if mutation_system != null and mutation_system.has_method("get_mutation_level"):
		metabolism_level = int(mutation_system.call("get_mutation_level", "metabolism"))
	if mutation_system != null and mutation_system.has_method("get_metabolism_regen_per_second"):
		metabolism_regen_per_second = float(mutation_system.call("get_metabolism_regen_per_second"))

	var bonus_regen_per_second: float = _get_total_bonus_regen_per_second()
	var total_regen_per_second: float = metabolism_regen_per_second + bonus_regen_per_second
	if total_regen_per_second <= 0.0:
		metabolism_label.visible = false
		return

	metabolism_label.visible = true
	if bonus_regen_per_second > 0.0:
		metabolism_label.text = "Regen: +%.1f/s (L%d + Bonus)" % [total_regen_per_second, metabolism_level]
		return
	metabolism_label.text = "Regen: +%.1f/s (L%d)" % [total_regen_per_second, metabolism_level]

func _build_inventory_slot_stylebox(slot_style_kind: String) -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.050, 0.080, 0.112, 0.96)
	stylebox.border_width_left = 1
	stylebox.border_width_top = 1
	stylebox.border_width_right = 1
	stylebox.border_width_bottom = 1
	match slot_style_kind:
		"reward":
			stylebox.border_color = Color(0.86, 0.76, 0.42, 0.85)
		"synergy":
			stylebox.border_color = Color(0.56, 0.94, 0.76, 0.90)
		_:
			stylebox.border_color = Color(0.48, 0.80, 0.96, 0.85)
	stylebox.corner_radius_top_left = 6
	stylebox.corner_radius_top_right = 6
	stylebox.corner_radius_bottom_right = 6
	stylebox.corner_radius_bottom_left = 6
	return stylebox

func _sync_mutation_inventory_levels() -> void:
	if mutation_system == null:
		return
	if not mutation_system.has_method("get_mutation_level"):
		return
	for mutation_id in INVENTORY_MUTATION_IDS:
		var level_value: int = int(mutation_system.call("get_mutation_level", mutation_id))
		_run_mutation_inventory_levels[mutation_id] = maxi(0, level_value)

func _register_run_reward_inventory(reward_id: String, reward_name: String, icon_id: String, reward_description: String) -> void:
	if reward_id.is_empty():
		return
	if not _run_reward_inventory.has(reward_id):
		_run_reward_inventory_order.append(reward_id)
		_run_reward_inventory[reward_id] = {
			"name": reward_name,
			"icon_id": icon_id,
			"description": reward_description,
			"count": 0
		}

	var entry: Dictionary = _run_reward_inventory.get(reward_id, {})
	entry["name"] = reward_name
	entry["icon_id"] = icon_id
	entry["description"] = reward_description
	entry["count"] = int(entry.get("count", 0)) + 1
	_run_reward_inventory[reward_id] = entry

func _refresh_run_inventory_ui() -> void:
	if run_inventory_mutation_entries == null or run_inventory_reward_entries == null or run_inventory_synergy_entries == null:
		return
	if run_inventory_bar != null:
		run_inventory_bar.visible = true

	_hide_inventory_tooltip()
	_clear_inventory_entries(run_inventory_mutation_entries)
	_clear_inventory_entries(run_inventory_reward_entries)
	_clear_inventory_entries(run_inventory_synergy_entries)

	var has_mutation_entry: bool = false
	for mutation_id in INVENTORY_MUTATION_IDS:
		var level_value: int = int(_run_mutation_inventory_levels.get(mutation_id, 0))
		if level_value <= 0:
			continue
		has_mutation_entry = true
		_add_inventory_icon_slot(
			run_inventory_mutation_entries,
			_get_icon_for_inventory_id(mutation_id),
			str(level_value),
			"mutation",
			"mutation",
			mutation_id
		)
	if not has_mutation_entry:
		_add_inventory_placeholder(run_inventory_mutation_entries, "None")

	var has_reward_entry: bool = false
	for reward_id in _run_reward_inventory_order:
		if not _run_reward_inventory.has(reward_id):
			continue
		var entry: Dictionary = _run_reward_inventory.get(reward_id, {})
		var icon_id: String = String(entry.get("icon_id", ""))
		var count_value: int = int(entry.get("count", 0))
		if count_value <= 0:
			continue
		has_reward_entry = true
		_add_inventory_icon_slot(
			run_inventory_reward_entries,
			_get_icon_for_inventory_id(icon_id),
			str(count_value),
			"reward",
			"reward",
			reward_id
		)
	if not has_reward_entry:
		_add_inventory_placeholder(run_inventory_reward_entries, "None")

	var has_synergy_entry: bool = false
	var ordered_synergy_ids: Array[String] = _active_tag_synergy_ids.duplicate()
	ordered_synergy_ids.sort()
	for synergy_id in ordered_synergy_ids:
		has_synergy_entry = true
		_add_inventory_icon_slot(
			run_inventory_synergy_entries,
			_get_synergy_icon_for_rule(synergy_id),
			"",
			"synergy",
			"synergy",
			synergy_id
		)
	if not has_synergy_entry:
		_add_inventory_placeholder(run_inventory_synergy_entries, "None")

	call_deferred("_update_run_inventory_bar_height")

func _clear_inventory_entries(container: Control) -> void:
	for child in container.get_children():
		child.queue_free()

func _add_inventory_icon_slot(
	container: HFlowContainer,
	icon_texture: Texture2D,
	value_text: String,
	slot_style_kind: String,
	entry_kind: String,
	entry_id: String
) -> void:
	var slot := Panel.new()
	slot.custom_minimum_size = Vector2(52.0, 52.0)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	slot.add_theme_stylebox_override("panel", _build_inventory_slot_stylebox(slot_style_kind))
	container.add_child(slot)

	var icon := TextureRect.new()
	icon.anchor_right = 1.0
	icon.anchor_bottom = 1.0
	icon.offset_left = 4.0
	icon.offset_top = 4.0
	icon.offset_right = -4.0
	icon.offset_bottom = -4.0
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = icon_texture
	icon.modulate = Color(1.0, 1.0, 1.0, 0.95)
	slot.add_child(icon)

	if not value_text.strip_edges().is_empty():
		var value_label := Label.new()
		value_label.text = value_text
		value_label.anchor_left = 1.0
		value_label.anchor_top = 1.0
		value_label.anchor_right = 1.0
		value_label.anchor_bottom = 1.0
		value_label.offset_left = -21.0
		value_label.offset_top = -21.0
		value_label.offset_right = -6.0
		value_label.offset_bottom = -6.0
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		value_label.add_theme_font_size_override("font_size", 16)
		value_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.98))
		value_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
		value_label.add_theme_constant_override("outline_size", 2)
		slot.add_child(value_label)

	if not entry_id.is_empty():
		slot.mouse_entered.connect(Callable(self, "_on_inventory_slot_mouse_entered").bind(slot, entry_kind, entry_id))
		slot.mouse_exited.connect(Callable(self, "_on_inventory_slot_mouse_exited").bind(slot))

func _add_inventory_placeholder(container: HFlowContainer, text_value: String) -> void:
	var placeholder := Label.new()
	placeholder.text = text_value
	placeholder.add_theme_font_size_override("font_size", 13)
	placeholder.add_theme_color_override("font_color", Color(0.74, 0.80, 0.86, 0.75))
	container.add_child(placeholder)

func _get_icon_for_inventory_id(icon_id: String) -> Texture2D:
	if not MUTATION_ICON_BY_ID.has(icon_id):
		return null
	var icon_variant: Variant = MUTATION_ICON_BY_ID.get(icon_id)
	return icon_variant as Texture2D

func _get_synergy_icon_for_rule(synergy_id: String) -> Texture2D:
	var icon_id: String = String(SYNERGY_ICON_ID_BY_RULE_ID.get(synergy_id, ""))
	if icon_id.is_empty():
		return null
	return _get_icon_for_inventory_id(icon_id)

func _update_run_inventory_bar_height() -> void:
	if run_inventory_bar == null or run_inventory_rows == null:
		return
	var min_height: float = run_inventory_rows.get_combined_minimum_size().y + 4.0
	var desired_height: float = maxf(104.0, min_height)
	run_inventory_bar.offset_bottom = run_inventory_bar.offset_top + desired_height

func _build_inventory_tooltip_stylebox() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.035, 0.058, 0.086, 0.97)
	stylebox.border_width_left = 1
	stylebox.border_width_top = 1
	stylebox.border_width_right = 1
	stylebox.border_width_bottom = 1
	stylebox.border_color = Color(0.46, 0.78, 0.95, 0.88)
	stylebox.corner_radius_top_left = 7
	stylebox.corner_radius_top_right = 7
	stylebox.corner_radius_bottom_right = 7
	stylebox.corner_radius_bottom_left = 7
	return stylebox

func _ensure_inventory_tooltip_ui() -> void:
	if _inventory_tooltip_panel != null and is_instance_valid(_inventory_tooltip_panel):
		return
	if ui_hud_layer == null:
		return

	_inventory_tooltip_panel = PanelContainer.new()
	_inventory_tooltip_panel.name = "RunInventoryTooltip"
	_inventory_tooltip_panel.visible = false
	_inventory_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_inventory_tooltip_panel.z_index = 90
	_inventory_tooltip_panel.add_theme_stylebox_override("panel", _build_inventory_tooltip_stylebox())
	ui_hud_layer.add_child(_inventory_tooltip_panel)

	var padding := MarginContainer.new()
	padding.add_theme_constant_override("margin_left", 10)
	padding.add_theme_constant_override("margin_top", 8)
	padding.add_theme_constant_override("margin_right", 10)
	padding.add_theme_constant_override("margin_bottom", 10)
	_inventory_tooltip_panel.add_child(padding)

	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 4)
	padding.add_child(rows)

	_inventory_tooltip_title_label = Label.new()
	_inventory_tooltip_title_label.add_theme_font_size_override("font_size", 18)
	_inventory_tooltip_title_label.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 1.0))
	rows.add_child(_inventory_tooltip_title_label)

	_inventory_tooltip_body_label = Label.new()
	_inventory_tooltip_body_label.custom_minimum_size = Vector2(300.0, 0.0)
	_inventory_tooltip_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_inventory_tooltip_body_label.add_theme_font_size_override("font_size", 15)
	_inventory_tooltip_body_label.add_theme_color_override("font_color", Color(0.86, 0.93, 0.98, 0.96))
	rows.add_child(_inventory_tooltip_body_label)

func _build_synergy_popup_stylebox() -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.032, 0.070, 0.078, 0.94)
	stylebox.border_width_left = 1
	stylebox.border_width_top = 1
	stylebox.border_width_right = 1
	stylebox.border_width_bottom = 1
	stylebox.border_color = Color(0.50, 0.95, 0.76, 0.95)
	stylebox.corner_radius_top_left = 8
	stylebox.corner_radius_top_right = 8
	stylebox.corner_radius_bottom_right = 8
	stylebox.corner_radius_bottom_left = 8
	return stylebox

func _ensure_synergy_popup_ui() -> void:
	if _synergy_popup_panel != null and is_instance_valid(_synergy_popup_panel):
		return
	if ui_hud_layer == null:
		return

	_synergy_popup_panel = PanelContainer.new()
	_synergy_popup_panel.name = "SynergyPopup"
	_synergy_popup_panel.visible = false
	_synergy_popup_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_synergy_popup_panel.z_index = 95
	_synergy_popup_panel.add_theme_stylebox_override("panel", _build_synergy_popup_stylebox())
	_synergy_popup_panel.anchor_left = 0.5
	_synergy_popup_panel.anchor_top = 0.0
	_synergy_popup_panel.anchor_right = 0.5
	_synergy_popup_panel.anchor_bottom = 0.0
	_synergy_popup_panel.offset_left = -250.0
	_synergy_popup_panel.offset_top = 72.0
	_synergy_popup_panel.offset_right = 250.0
	_synergy_popup_panel.offset_bottom = 138.0
	ui_hud_layer.add_child(_synergy_popup_panel)

	var popup_padding := MarginContainer.new()
	popup_padding.add_theme_constant_override("margin_left", 12)
	popup_padding.add_theme_constant_override("margin_top", 8)
	popup_padding.add_theme_constant_override("margin_right", 12)
	popup_padding.add_theme_constant_override("margin_bottom", 9)
	_synergy_popup_panel.add_child(popup_padding)

	var popup_rows := VBoxContainer.new()
	popup_rows.add_theme_constant_override("separation", 2)
	popup_padding.add_child(popup_rows)

	_synergy_popup_title_label = Label.new()
	_synergy_popup_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_synergy_popup_title_label.add_theme_font_size_override("font_size", 19)
	_synergy_popup_title_label.add_theme_color_override("font_color", Color(0.89, 1.0, 0.93, 1.0))
	popup_rows.add_child(_synergy_popup_title_label)

	_synergy_popup_body_label = Label.new()
	_synergy_popup_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_synergy_popup_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_synergy_popup_body_label.add_theme_font_size_override("font_size", 15)
	_synergy_popup_body_label.add_theme_color_override("font_color", Color(0.76, 0.95, 0.86, 0.98))
	popup_rows.add_child(_synergy_popup_body_label)

func _queue_synergy_popup(synergy_id: String) -> void:
	if not synergy_popup_enabled:
		return
	if synergy_id.is_empty():
		return

	var rule: Dictionary = _get_synergy_rule_by_id(synergy_id)
	if rule.is_empty():
		return

	var popup_title: String = "Synergy Activated: %s" % _get_synergy_rule_name(synergy_id)
	var popup_body: String = _build_synergy_popup_body_text(rule)
	_queue_runtime_popup(popup_title, popup_body, false)

func _queue_run_intro_popup() -> void:
	if _run_intro_popup_shown:
		return
	if not run_intro_popup_enabled:
		return

	var popup_title: String = "OUTBREAK BRIEFING"
	var popup_body: String = "Move with WASD.\nCollect biomass to level up.\nAt Level 2, choose your lineage (starter mutation).\nPick mutations to shape your build.\nSurvive crises and beat the final purge."
	_queue_runtime_popup(
		popup_title,
		popup_body,
		true,
		maxf(3.0, run_intro_popup_duration_seconds),
		true
	)
	_run_intro_popup_shown = true

func _queue_runtime_popup(
	title_text: String,
	body_text: String,
	prioritize: bool = false,
	custom_duration_seconds: float = -1.0,
	force_when_disabled: bool = false
) -> void:
	if not force_when_disabled and not synergy_popup_enabled:
		return
	var popup_entry: Dictionary = {
		"title": title_text,
		"body": body_text
	}
	if custom_duration_seconds > 0.0:
		popup_entry["duration_seconds"] = custom_duration_seconds
	if prioritize:
		_synergy_popup_queue.push_front(popup_entry)
	else:
		_synergy_popup_queue.append(popup_entry)
	_start_next_synergy_popup_if_idle()

func _queue_newly_activated_synergy_popups(previous_active_synergy_ids: Array[String]) -> void:
	if not synergy_popup_enabled:
		return
	if _active_tag_synergy_ids.is_empty():
		return

	var previous_id_set: Dictionary = {}
	for previous_id in previous_active_synergy_ids:
		previous_id_set[previous_id] = true

	for synergy_id in _active_tag_synergy_ids:
		if previous_id_set.has(synergy_id):
			continue
		_queue_synergy_popup(synergy_id)

	_start_next_synergy_popup_if_idle()

func _start_next_synergy_popup_if_idle() -> void:
	if _synergy_popup_active:
		return
	if _synergy_popup_queue.is_empty():
		return

	var popup_entry_variant: Variant = _synergy_popup_queue.pop_front()
	if not (popup_entry_variant is Dictionary):
		return
	var popup_entry: Dictionary = popup_entry_variant
	var popup_title: String = String(popup_entry.get("title", "Synergy Activated"))
	var popup_body: String = String(popup_entry.get("body", ""))
	var popup_duration_seconds: float = float(popup_entry.get("duration_seconds", synergy_popup_duration_seconds))
	_show_synergy_popup(popup_title, popup_body, popup_duration_seconds)

func _show_synergy_popup(title_text: String, body_text: String, duration_seconds: float = -1.0) -> void:
	_ensure_synergy_popup_ui()
	if _synergy_popup_panel == null:
		return
	if _synergy_popup_title_label == null or _synergy_popup_body_label == null:
		return

	_synergy_popup_title_label.text = title_text
	_synergy_popup_body_label.text = body_text
	_synergy_popup_panel.visible = true
	var popup_alpha_color: Color = _synergy_popup_panel.modulate
	popup_alpha_color.a = 0.0
	_synergy_popup_panel.modulate = popup_alpha_color
	_synergy_popup_active = true
	_synergy_popup_elapsed_seconds = 0.0
	var resolved_duration_seconds: float = synergy_popup_duration_seconds
	if duration_seconds > 0.0:
		resolved_duration_seconds = duration_seconds
	_synergy_popup_current_duration_seconds = maxf(0.8, resolved_duration_seconds)

func _hide_synergy_popup(clear_queue: bool = false) -> void:
	if clear_queue:
		_synergy_popup_queue.clear()
	_synergy_popup_active = false
	_synergy_popup_elapsed_seconds = 0.0
	_synergy_popup_current_duration_seconds = 0.0
	if _synergy_popup_panel == null:
		return
	if not is_instance_valid(_synergy_popup_panel):
		return
	_synergy_popup_panel.visible = false
	var popup_color: Color = _synergy_popup_panel.modulate
	popup_color.a = 1.0
	_synergy_popup_panel.modulate = popup_color

func _tick_synergy_popup(delta: float) -> void:
	if not _synergy_popup_active:
		_start_next_synergy_popup_if_idle()
		return
	if _synergy_popup_panel == null or not is_instance_valid(_synergy_popup_panel):
		_synergy_popup_active = false
		return

	_synergy_popup_elapsed_seconds += maxf(0.0, delta)
	var popup_duration: float = maxf(0.8, _synergy_popup_current_duration_seconds)
	var fade_duration: float = clampf(synergy_popup_fade_seconds, 0.05, popup_duration * 0.45)

	var alpha_value: float = 1.0
	if _synergy_popup_elapsed_seconds <= fade_duration:
		alpha_value = _synergy_popup_elapsed_seconds / maxf(0.001, fade_duration)
	elif _synergy_popup_elapsed_seconds >= popup_duration - fade_duration:
		alpha_value = (popup_duration - _synergy_popup_elapsed_seconds) / maxf(0.001, fade_duration)
	alpha_value = clampf(alpha_value, 0.0, 1.0)

	var popup_color: Color = _synergy_popup_panel.modulate
	popup_color.a = alpha_value
	_synergy_popup_panel.modulate = popup_color

	if _synergy_popup_elapsed_seconds < popup_duration:
		return
	_hide_synergy_popup(false)
	_start_next_synergy_popup_if_idle()

func _build_synergy_popup_body_text(rule: Dictionary) -> String:
	var effects: Array[String] = []
	for effect_line in _build_synergy_effect_lines(rule):
		effects.append(String(effect_line).replace("Effect: ", ""))
	var effect_summary: String = " | ".join(effects)
	var required_tags: Array[String] = _get_synergy_required_tag_ids(rule)
	if required_tags.is_empty():
		return effect_summary
	if effect_summary.is_empty():
		return "Triggered by %s" % " + ".join(required_tags)
	return "%s\nTriggered by %s" % [effect_summary, " + ".join(required_tags)]

func _on_inventory_slot_mouse_entered(slot: Control, entry_kind: String, entry_id: String) -> void:
	if slot == null or not is_instance_valid(slot):
		return
	if entry_id.is_empty():
		return

	var tooltip_title: String = ""
	var tooltip_body: String = _build_inventory_tooltip_body(entry_kind, entry_id)
	if tooltip_body.is_empty():
		return

	if entry_kind == "reward":
		tooltip_title = _get_reward_display_name(entry_id)
	elif entry_kind == "synergy":
		tooltip_title = _get_synergy_display_name(entry_id)
	else:
		tooltip_title = _get_mutation_display_name(entry_id)

	_show_inventory_tooltip(tooltip_title, tooltip_body, slot)

func _on_inventory_slot_mouse_exited(slot: Control) -> void:
	if _inventory_tooltip_slot != slot:
		return
	_hide_inventory_tooltip()

func _show_inventory_tooltip(title_text: String, body_text: String, slot: Control) -> void:
	_ensure_inventory_tooltip_ui()
	if _inventory_tooltip_panel == null:
		return
	if _inventory_tooltip_title_label == null or _inventory_tooltip_body_label == null:
		return

	_inventory_tooltip_slot = slot
	_inventory_tooltip_title_label.text = title_text
	_inventory_tooltip_body_label.text = body_text
	_inventory_tooltip_panel.visible = true
	_inventory_tooltip_panel.size = _inventory_tooltip_panel.get_combined_minimum_size()
	_update_inventory_tooltip_position()

func _hide_inventory_tooltip() -> void:
	_inventory_tooltip_slot = null
	if _inventory_tooltip_panel != null and is_instance_valid(_inventory_tooltip_panel):
		_inventory_tooltip_panel.visible = false

func _update_inventory_tooltip_position() -> void:
	if _inventory_tooltip_panel == null or not is_instance_valid(_inventory_tooltip_panel):
		return
	if not _inventory_tooltip_panel.visible:
		return
	if _inventory_tooltip_slot == null or not is_instance_valid(_inventory_tooltip_slot):
		_hide_inventory_tooltip()
		return

	var tooltip_size: Vector2 = _inventory_tooltip_panel.get_combined_minimum_size()
	_inventory_tooltip_panel.size = tooltip_size

	var pointer_pos: Vector2 = get_viewport().get_mouse_position()
	var desired_pos: Vector2 = pointer_pos + Vector2(16.0, 16.0)
	var viewport_size: Vector2 = get_viewport_rect().size
	desired_pos.x = clampf(desired_pos.x, 8.0, viewport_size.x - tooltip_size.x - 8.0)
	desired_pos.y = clampf(desired_pos.y, 8.0, viewport_size.y - tooltip_size.y - 8.0)
	_inventory_tooltip_panel.position = desired_pos

func _build_inventory_tooltip_body(entry_kind: String, entry_id: String) -> String:
	match entry_kind:
		"mutation":
			return _build_mutation_tooltip_text(entry_id)
		"reward":
			return _build_reward_tooltip_text(entry_id)
		"synergy":
			return _build_synergy_tooltip_text(entry_id)
		_:
			return ""

func _get_mutation_display_name(mutation_id: String) -> String:
	var defs: Dictionary = MUTATIONS_DATA.get_all()
	var mutation_def: Dictionary = defs.get(mutation_id, {})
	var fallback_name: String = mutation_id.replace("_", " ").capitalize()
	return String(mutation_def.get("name", fallback_name))

func _get_mutation_max_level(mutation_id: String) -> int:
	var defs: Dictionary = MUTATIONS_DATA.get_all()
	var mutation_def: Dictionary = defs.get(mutation_id, {})
	return maxi(1, int(mutation_def.get("max_level", 3)))

func _get_mutation_module_instance(mutation_id: String) -> Node:
	if mutation_system == null:
		return null

	var property_name: String = ""
	match mutation_id:
		"spikes":
			property_name = "spike_ring_instance"
		"orbiters":
			property_name = "orbiter_instance"
		"membrane":
			property_name = "membrane_instance"
		"pulse_nova":
			property_name = "pulse_nova_instance"
		"acid_trail":
			property_name = "acid_trail_instance"
		"metabolism":
			property_name = "metabolism_instance"
		_:
			return null
	if property_name.is_empty():
		return null
	if not _node_has_property(mutation_system, property_name):
		return null
	return mutation_system.get(property_name) as Node

func _node_has_property(node: Object, property_name: String) -> bool:
	if node == null:
		return false
	for property_data in node.get_property_list():
		if String(property_data.get("name", "")) == property_name:
			return true
	return false

func _get_node_int_value(node: Node, property_name: String, fallback_value: int) -> int:
	if node == null:
		return fallback_value
	if not _node_has_property(node, property_name):
		return fallback_value
	var value: Variant = node.get(property_name)
	if value == null:
		return fallback_value
	return int(value)

func _get_node_float_value(node: Node, property_name: String, fallback_value: float) -> float:
	if node == null:
		return fallback_value
	if not _node_has_property(node, property_name):
		return fallback_value
	var value: Variant = node.get(property_name)
	if value == null:
		return fallback_value
	return float(value)

func _build_mutation_tooltip_text(mutation_id: String) -> String:
	var level_value: int = int(_run_mutation_inventory_levels.get(mutation_id, 0))
	if level_value <= 0:
		return "Not acquired in this run."

	match mutation_id:
		"spikes":
			var spike_module: Node = _get_mutation_module_instance("spikes")
			var spike_damage: int = _get_node_int_value(spike_module, "spike_damage", 8)
			var spike_tick_seconds: float = _get_node_float_value(spike_module, "damage_interval_seconds", 0.2)
			var spike_distance: float = _get_node_float_value(spike_module, "spike_distance", 36.0)
			var spike_hit_radius: float = _get_node_float_value(spike_module, "spike_collision_radius", 8.0)
			var spike_count: int = 4
			match level_value:
				2:
					spike_count = 6
				3:
					spike_count = 8
			return "Level: %d/%d\nDamage: %d every %.2fs\nSpike count: %d\nReach distance: %.0f\nHit radius: %.1f" % [
				level_value,
				_get_mutation_max_level("spikes"),
				spike_damage,
				spike_tick_seconds,
				spike_count,
				spike_distance,
				spike_hit_radius
			]
		"orbiters":
			var orbiter_module: Node = _get_mutation_module_instance("orbiters")
			var orbiter_damage: int = _get_node_int_value(orbiter_module, "orbiter_damage", 6)
			var orbiter_tick_seconds: float = _get_node_float_value(orbiter_module, "damage_interval_seconds", 0.2)
			var orbiter_radius: float = _get_node_float_value(orbiter_module, "_current_orbit_radius", 30.0)
			var orbiter_speed: float = _get_node_float_value(orbiter_module, "_current_orbit_speed_rps", 2.5)
			var orbiter_count: int = 1 if level_value == 1 else 2
			return "Level: %d/%d\nDamage: %d every %.2fs\nOrbiter count: %d\nOrbit radius: %.0f\nOrbit speed: %.2f rot/s" % [
				level_value,
				_get_mutation_max_level("orbiters"),
				orbiter_damage,
				orbiter_tick_seconds,
				orbiter_count,
				orbiter_radius,
				orbiter_speed
			]
		"membrane":
			var module_damage_multiplier: float = 1.0
			var total_damage_multiplier: float = 1.0
			if player != null:
				module_damage_multiplier = clampf(float(player.get("_module_incoming_damage_multiplier")), 0.05, 1.0)
				total_damage_multiplier = clampf(float(player.get("incoming_damage_multiplier")), 0.05, 1.0)
			var membrane_reduction_pct: float = (1.0 - module_damage_multiplier) * 100.0
			var total_reduction_pct: float = (1.0 - total_damage_multiplier) * 100.0
			if absf(total_reduction_pct - membrane_reduction_pct) > 0.05:
				return "Level: %d/%d\nMembrane reduction: %.1f%%\nTotal incoming reduction: %.1f%%" % [
					level_value,
					_get_mutation_max_level("membrane"),
					membrane_reduction_pct,
					total_reduction_pct
				]
			return "Level: %d/%d\nIncoming damage reduction: %.1f%%" % [
				level_value,
				_get_mutation_max_level("membrane"),
				membrane_reduction_pct
			]
		"pulse_nova":
			var pulse_module: Node = _get_mutation_module_instance("pulse_nova")
			var pulse_damage: int = _get_node_int_value(pulse_module, "_pulse_damage", 8)
			var pulse_radius: float = _get_node_float_value(pulse_module, "_pulse_radius", 80.0)
			var pulse_interval: float = _get_node_float_value(pulse_module, "_pulse_interval_seconds", 1.85)
			return "Level: %d/%d\nPulse damage: %d\nPulse radius: %.0f\nPulse interval: %.2fs" % [
				level_value,
				_get_mutation_max_level("pulse_nova"),
				pulse_damage,
				pulse_radius,
				pulse_interval
			]
		"acid_trail":
			var acid_module: Node = _get_mutation_module_instance("acid_trail")
			var acid_damage: int = _get_node_int_value(acid_module, "_damage_per_tick", 3)
			var acid_radius: float = _get_node_float_value(acid_module, "_trail_radius", 17.0)
			var acid_tick_seconds: float = _get_node_float_value(acid_module, "_damage_tick_interval_seconds", 0.45)
			var acid_spawn_interval: float = _get_node_float_value(acid_module, "_spawn_interval_seconds", 0.30)
			var acid_lifetime: float = _get_node_float_value(acid_module, "_trail_lifetime_seconds", 2.1)
			return "Level: %d/%d\nDOT: %d every %.2fs\nZone radius: %.1f\nSpawn interval: %.2fs\nZone lifetime: %.2fs" % [
				level_value,
				_get_mutation_max_level("acid_trail"),
				acid_damage,
				acid_tick_seconds,
				acid_radius,
				acid_spawn_interval,
				acid_lifetime
			]
		"metabolism":
			var module_regen: float = 0.0
			if mutation_system != null and mutation_system.has_method("get_metabolism_regen_per_second"):
				module_regen = maxf(0.0, float(mutation_system.call("get_metabolism_regen_per_second")))
			var bonus_regen: float = maxf(0.0, _get_total_bonus_regen_per_second())
			var total_regen: float = module_regen + bonus_regen
			if bonus_regen > 0.0:
				return "Level: %d/%d\nMutation regen: +%.1f HP/s\nBonus regen: +%.1f HP/s\nTotal regen: +%.1f HP/s" % [
					level_value,
					_get_mutation_max_level("metabolism"),
					module_regen,
					bonus_regen,
					total_regen
				]
			return "Level: %d/%d\nPassive regen: +%.1f HP/s" % [
				level_value,
				_get_mutation_max_level("metabolism"),
				module_regen
			]
		_:
			return "Level: %d/%d" % [level_value, _get_mutation_max_level(mutation_id)]

func _get_reward_display_name(reward_id: String) -> String:
	var entry: Dictionary = _run_reward_inventory.get(reward_id, {})
	var stored_name: String = String(entry.get("name", ""))
	if not stored_name.is_empty():
		return stored_name
	return reward_id.replace("_", " ").capitalize()

func _get_synergy_display_name(synergy_id: String) -> String:
	return _get_synergy_rule_name(synergy_id)

func _build_reward_tooltip_text(reward_id: String) -> String:
	var entry: Dictionary = _run_reward_inventory.get(reward_id, {})
	var count_value: int = maxi(0, int(entry.get("count", 0)))
	if count_value <= 0:
		return "Not acquired in this run."

	var description: String = String(entry.get("description", ""))
	var lines: Array[String] = []
	lines.append("Stacks: %d" % count_value)
	if not description.is_empty():
		lines.append(description)

	match reward_id:
		"sweep_breach_lenses":
			var this_reward_bonus_pct: float = (pow(1.15, float(count_value)) - 1.0) * 100.0
			lines.append("This reward total: +%.1f%% module damage" % this_reward_bonus_pct)
			lines.append("Run total module damage: +%.1f%%" % ((_reward_module_damage_multiplier - 1.0) * 100.0))
		"sweep_phase_ducts":
			var this_move_bonus_pct: float = (pow(1.12, float(count_value)) - 1.0) * 100.0
			lines.append("This reward total: +%.1f%% movement speed" % this_move_bonus_pct)
			lines.append("Run total movement speed: +%.1f%%" % ((_reward_move_speed_multiplier - 1.0) * 100.0))
			if player != null:
				lines.append("Current move speed: %.1f" % float(player.get("move_speed")))
		"sweep_reactive_shell":
			var this_reduction_pct: float = (1.0 - pow(0.88, float(count_value))) * 100.0
			lines.append("This reward total: %.1f%% less incoming dmg" % this_reduction_pct)
			lines.append("Run external reduction: %.1f%%" % ((1.0 - _reward_external_damage_multiplier) * 100.0))
			if player != null:
				lines.append("Current total reduction: %.1f%%" % ((1.0 - float(player.get("incoming_damage_multiplier"))) * 100.0))
		"bloom_overclock_core":
			var overclock_bonus_pct: float = (pow(1.20, float(count_value)) - 1.0) * 100.0
			lines.append("This reward total: +%.1f%% module damage" % overclock_bonus_pct)
			lines.append("Run total module damage: +%.1f%%" % ((_reward_module_damage_multiplier - 1.0) * 100.0))
		"bloom_hunters_gyro":
			var gyro_bonus_pct: float = (pow(1.25, float(count_value)) - 1.0) * 100.0
			lines.append("This reward total: +%.1f%% orbiter speed" % gyro_bonus_pct)
			lines.append("Run total orbiter speed: +%.1f%%" % ((_reward_orbiter_speed_multiplier - 1.0) * 100.0))
		"bloom_adaptive_skin":
			lines.append("This reward total: +%d max HP" % (count_value * 15))
			lines.append("Run bonus max HP: +%d" % _reward_bonus_max_hp_flat)
			if player != null:
				lines.append("Current max HP: %d" % int(player.get("max_hp")))
		"leak_detox_glands":
			lines.append("This reward total: +%.1f HP/s regen" % (2.0 * float(count_value)))
			lines.append("Run bonus regen: +%.1f HP/s" % _get_total_bonus_regen_per_second())
		"leak_acid_recycler":
			var recycler_bonus_pct: float = (pow(1.30, float(count_value)) - 1.0) * 100.0
			lines.append("This reward total: +%.1f%% acid lifetime" % recycler_bonus_pct)
			lines.append("Run acid lifetime bonus: +%.1f%%" % ((_reward_acid_lifetime_multiplier - 1.0) * 100.0))
		"leak_nova_condenser":
			var condenser_bonus_pct: float = (pow(1.20, float(count_value)) - 1.0) * 100.0
			lines.append("This reward total: +%.1f%% pulse radius" % condenser_bonus_pct)
			lines.append("Run pulse radius bonus: +%.1f%%" % ((_reward_pulse_radius_multiplier - 1.0) * 100.0))
		"fallback_hardened_membrane":
			lines.append("This reward total: +%d max HP" % (count_value * 10))
			lines.append("Run bonus max HP: +%d" % _reward_bonus_max_hp_flat)
		"fallback_spike_density":
			var density_bonus_pct: float = (pow(1.10, float(count_value)) - 1.0) * 100.0
			lines.append("This reward total: +%.1f%% module damage" % density_bonus_pct)
			lines.append("Run total module damage: +%.1f%%" % ((_reward_module_damage_multiplier - 1.0) * 100.0))
		"fallback_metabolic_burst":
			var burst_bonus_pct: float = (pow(1.08, float(count_value)) - 1.0) * 100.0
			lines.append("This reward total: +%.1f%% movement speed" % burst_bonus_pct)
			lines.append("Run total movement speed: +%.1f%%" % ((_reward_move_speed_multiplier - 1.0) * 100.0))
		_:
			lines.append("Applies a run-wide crisis modifier.")

	return "\n".join(lines)

func _build_synergy_tooltip_text(synergy_id: String) -> String:
	var rule: Dictionary = _get_synergy_rule_by_id(synergy_id)
	if rule.is_empty():
		return "Unknown synergy."

	var lines: Array[String] = []
	lines.append("Status: Active")
	for effect_line in _build_synergy_effect_lines(rule):
		lines.append(effect_line)

	var required_tags: Array[String] = _get_synergy_required_tag_ids(rule)
	if not required_tags.is_empty():
		lines.append("Activation: %s" % " + ".join(required_tags))
		lines.append("Activated this run by:")
		var current_sources: Dictionary = _build_active_tag_sources()
		for tag_id in required_tags:
			var source_names: Array[String] = []
			if current_sources.has(tag_id):
				var tag_source_values: Array = current_sources.get(tag_id, [])
				for source_value in tag_source_values:
					source_names.append(String(source_value))
			if source_names.is_empty():
				lines.append("%s from: (missing)" % tag_id)
			else:
				lines.append("%s from: %s" % [tag_id, ", ".join(source_names)])

	return "\n".join(lines)

func _get_synergy_rule_by_id(synergy_id: String) -> Dictionary:
	if synergy_id.is_empty():
		return {}
	for rule_variant in MUTATION_TAG_SYNERGY_RULES:
		if not (rule_variant is Dictionary):
			continue
		var rule: Dictionary = rule_variant
		if String(rule.get("id", "")) == synergy_id:
			return rule
	return {}

func _get_synergy_required_tag_ids(rule: Dictionary) -> Array[String]:
	var required_tags: Array[String] = []
	var required_tags_variant: Variant = rule.get("tags", [])
	if not (required_tags_variant is Array):
		return required_tags
	var required_tags_array: Array = required_tags_variant
	for raw_tag in required_tags_array:
		var tag_id: String = String(raw_tag).strip_edges().to_lower()
		if tag_id.is_empty():
			continue
		required_tags.append(tag_id)
	return required_tags

func _build_active_tag_sources() -> Dictionary:
	var sources_by_tag: Dictionary = {}
	var mutation_defs: Dictionary = MUTATIONS_DATA.get_all()
	for mutation_id in INVENTORY_MUTATION_IDS:
		var level_value: int = int(_run_mutation_inventory_levels.get(mutation_id, 0))
		if level_value <= 0:
			continue
		if not mutation_defs.has(mutation_id):
			continue
		var mutation_def: Dictionary = mutation_defs.get(mutation_id, {})
		var tags_variant: Variant = mutation_def.get("tags", [])
		if not (tags_variant is Array):
			continue
		var tags_array: Array = tags_variant
		var mutation_name_with_level: String = "%s L%d" % [_get_mutation_display_name(mutation_id), level_value]
		for raw_tag in tags_array:
			var tag_id: String = String(raw_tag).strip_edges().to_lower()
			if tag_id.is_empty():
				continue
			var tag_sources: Array = sources_by_tag.get(tag_id, [])
			tag_sources.append(mutation_name_with_level)
			sources_by_tag[tag_id] = tag_sources
	return sources_by_tag

func _build_synergy_effect_lines(rule: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	if rule.has("module_damage_multiplier"):
		var module_multiplier: float = float(rule.get("module_damage_multiplier", 1.0))
		lines.append("Effect: %+.1f%% module damage" % ((module_multiplier - 1.0) * 100.0))
	if rule.has("orbiter_speed_multiplier"):
		var orbiter_multiplier: float = float(rule.get("orbiter_speed_multiplier", 1.0))
		lines.append("Effect: %+.1f%% orbiter speed" % ((orbiter_multiplier - 1.0) * 100.0))
	if rule.has("pulse_radius_multiplier"):
		var pulse_multiplier: float = float(rule.get("pulse_radius_multiplier", 1.0))
		lines.append("Effect: %+.1f%% pulse radius" % ((pulse_multiplier - 1.0) * 100.0))
	if rule.has("acid_lifetime_multiplier"):
		var acid_multiplier: float = float(rule.get("acid_lifetime_multiplier", 1.0))
		lines.append("Effect: %+.1f%% acid lifetime" % ((acid_multiplier - 1.0) * 100.0))
	if rule.has("move_speed_multiplier"):
		var speed_multiplier: float = float(rule.get("move_speed_multiplier", 1.0))
		lines.append("Effect: %+.1f%% movement speed" % ((speed_multiplier - 1.0) * 100.0))
	if rule.has("external_damage_multiplier"):
		var damage_multiplier: float = float(rule.get("external_damage_multiplier", 1.0))
		lines.append("Effect: %.1f%% less incoming damage" % ((1.0 - damage_multiplier) * 100.0))
	if rule.has("passive_regen_per_second"):
		var regen_value: float = float(rule.get("passive_regen_per_second", 0.0))
		lines.append("Effect: +%.1f HP/s passive regen" % regen_value)
	if lines.is_empty():
		lines.append("Effect: Enables a run-wide passive bonus.")
	return lines

func _on_tree_node_added(node: Node) -> void:
	_connect_enemy_death(node)
	_connect_biomass_pickup(node)

func _connect_enemy_death(node: Node) -> void:
	if node == null:
		return
	if node == player:
		return
	if not node.has_signal("died"):
		return
	if not node.has_method("take_damage"):
		return

	var death_callable := Callable(self, "_on_enemy_died")
	if node.is_connected("died", death_callable):
		return
	node.connect("died", death_callable)

func _connect_biomass_pickup(node: Node) -> void:
	if node == null:
		return
	if not node.has_signal("collected"):
		return

	var collected_callable := Callable(self, "_on_biomass_collected")
	if node.is_connected("collected", collected_callable):
		return
	node.connect("collected", collected_callable)

func _on_biomass_collected(amount: int) -> void:
	if xp_system == null:
		return
	if not xp_system.has_method("add_xp"):
		return
	xp_system.call("add_xp", amount)
	_play_sfx("pickup")

func _on_enemy_died(world_position: Vector2) -> void:
	if debug_log_drops:
		print("Enemy died at ", world_position, " -> spawning biomass")
	_play_sfx("enemy_death")
	call_deferred("_spawn_biomass_pickup", world_position)

func _spawn_biomass_pickup(world_position: Vector2) -> void:
	var pickup := BIOMASS_PICKUP_SCENE.instantiate() as Node2D
	if pickup == null:
		return
	add_child(pickup)
	var offset := Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
	pickup.global_position = world_position + offset
	if debug_log_drops:
		print("Biomass spawned at ", pickup.global_position)

func _on_player_died() -> void:
	if run_ended:
		return

	_end_run_common()
	if _last_run_end_reason.is_empty():
		_last_run_end_reason = _resolve_default_death_reason()
	if _pending_crisis_failure_audio:
		_play_sfx("crisis_fail", -2.0, 0.95)
		_pending_crisis_failure_audio = false
	else:
		_play_sfx("player_death")
	_stop_music()
	_show_game_over()

func _end_run_common() -> void:
	pending_levelup_count = 0
	run_paused_for_levelup = false
	run_paused_for_menu = false
	lineage_selection_active = false
	crisis_reward_selection_active = false
	active_crisis_reward_id = ""
	crisis_reward_options.clear()
	if levelup_ui != null:
		levelup_ui.visible = false
	if pause_menu_ui != null:
		pause_menu_ui.visible = false
	if crisis_debug_label != null:
		crisis_debug_label.visible = false
	if game_over_ui != null:
		game_over_ui.visible = false
	if victory_ui != null:
		victory_ui.visible = false
	_hide_synergy_popup(true)
	_stop_final_crisis_composition()
	_clear_containment_sweep()
	_clear_biohazard_leaks()
	_clear_strain_bloom_state()
	run_ended = true
	_set_gameplay_active(false)

func _set_gameplay_active(active: bool) -> void:
	if player != null:
		player.set_physics_process(active)

	for enemy in get_tree().get_nodes_in_group("enemies"):
		var enemy_node := enemy as Node
		if enemy_node == null:
			continue
		enemy_node.set_physics_process(active)

	for module_node_raw in get_tree().get_nodes_in_group("player_modules"):
		var module_node := module_node_raw as Node
		if module_node == null:
			continue
		module_node.set_process(active)
		module_node.set_physics_process(active)

	for spawner_node_raw in get_tree().get_nodes_in_group("enemy_spawners"):
		var spawner_node := spawner_node_raw as Node
		if spawner_node == null:
			continue
		if spawner_node.has_method("set_spawning_enabled"):
			spawner_node.call("set_spawning_enabled", active)

	for crisis_runtime_raw in get_tree().get_nodes_in_group("crisis_runtime_nodes"):
		var crisis_runtime_node := crisis_runtime_raw as Node
		if crisis_runtime_node == null:
			continue
		crisis_runtime_node.set_process(active)
		crisis_runtime_node.set_physics_process(active)

func _show_game_over() -> void:
	if game_over_stats_label != null:
		game_over_stats_label.text = "Time: %ds | Level: %d | Lineage: %s" % [
			int(elapsed_seconds),
			level_reached,
			_get_current_lineage_name()
		]
	if game_over_reason_label != null:
		game_over_reason_label.text = "Cause: %s" % _last_run_end_reason

	if game_over_ui != null:
		game_over_ui.visible = true

func _resolve_failure_reason(reason_text: String) -> String:
	var normalized_reason: String = reason_text.strip_edges().to_lower()
	match normalized_reason:
		"strain bloom objective failed":
			return "Elite survived the Strain Bloom timer."
		_:
			if reason_text.strip_edges().is_empty():
				return _resolve_default_death_reason()
			return reason_text.strip_edges()

func _resolve_default_death_reason() -> String:
	var phase_name: String = ""
	var crisis_id: String = ""
	if crisis_director != null and crisis_director.has_method("get_phase"):
		phase_name = String(crisis_director.call("get_phase"))
	if crisis_director != null and crisis_director.has_method("get_active_crisis_id"):
		crisis_id = String(crisis_director.call("get_active_crisis_id"))

	if phase_name == "active":
		match crisis_id:
			"containment_sweep":
				return "Caught by containment sweep."
			"strain_bloom":
				return "Overwhelmed during Strain Bloom."
			"biohazard_leak":
				return "Severe contamination exposure."
	if phase_name == "final":
		return "Contained during Purge Protocol."
	return "Overwhelmed by hostile strains."

func _show_victory() -> void:
	_apply_crisis_ui_accent("victory", "purge_protocol", 0.0)
	if victory_stats_label != null:
		victory_stats_label.text = "Time: %ds | Level: %d | Lineage: %s" % [
			int(elapsed_seconds),
			level_reached,
			_get_current_lineage_name()
		]
	if victory_summary_label != null:
		victory_summary_label.text = _build_victory_summary_line()
	if victory_detail_label != null:
		victory_detail_label.text = _build_victory_detail_line()

	if victory_ui != null:
		victory_ui.visible = true

func _build_victory_summary_line() -> String:
	var mutation_count: int = 0
	for mutation_id in INVENTORY_MUTATION_IDS:
		if int(_run_mutation_inventory_levels.get(mutation_id, 0)) > 0:
			mutation_count += 1

	var reward_count: int = 0
	for reward_id in _run_reward_inventory_order:
		var reward_entry: Dictionary = _run_reward_inventory.get(reward_id, {})
		if int(reward_entry.get("count", 0)) > 0:
			reward_count += 1

	var synergy_count: int = _active_tag_synergy_ids.size()
	return "Mutations: %d | Rewards: %d | Synergies: %d" % [mutation_count, reward_count, synergy_count]

func _build_victory_detail_line() -> String:
	var final_hp_text: String = "0/0"
	if player != null:
		var current_hp_value: int = int(player.get("current_hp"))
		var max_hp_value: int = int(player.get("max_hp"))
		final_hp_text = "%d/%d" % [maxi(0, current_hp_value), maxi(1, max_hp_value)]
	return "Final HP: %s" % final_hp_text

func _update_timer_label() -> void:
	if timer_label == null:
		return
	timer_label.text = "Time: %ds" % int(elapsed_seconds)

func _on_player_leveled_up(_new_level: int) -> void:
	if run_ended:
		return
	if run_paused_for_menu:
		_queue_pending_levelup("pause_menu")
		return
	if run_paused_for_levelup:
		_queue_pending_levelup("levelup_or_reward_prompt")
		return

	_open_levelup_prompt()

func _queue_pending_levelup(reason: String = "") -> void:
	pending_levelup_count += 1
	if not debug_log_crisis_timeline:
		return
	if reason.is_empty():
		print("[GameManager] Level-up queued. Pending: %d" % pending_levelup_count)
		return
	print("[GameManager] Level-up queued (%s). Pending: %d" % [reason, pending_levelup_count])

func _on_levelup_choice_pressed(choice_index: int) -> void:
	if run_ended:
		return
	_play_sfx("ui_click")

	if crisis_reward_selection_active:
		var reward_applied: bool = _apply_crisis_reward_choice(choice_index)
		if not reward_applied:
			return
		_finish_crisis_reward_prompt()
		return

	if lineage_selection_active:
		var lineage_applied: bool = _apply_lineage_choice(choice_index)
		if not lineage_applied:
			return
		_refresh_lineage_labels()
	else:
		if mutation_system != null and mutation_system.has_method("apply_option_index"):
			mutation_system.call("apply_option_index", choice_index)

	if pending_levelup_count > 0:
		pending_levelup_count -= 1
		var did_open_prompt: bool = _open_levelup_prompt(false)
		if did_open_prompt:
			return
		pending_levelup_count = 0

	_close_levelup_prompt()

func _on_game_over_main_menu_pressed() -> void:
	if game_over_main_menu_requested:
		return
	game_over_main_menu_requested = true
	if game_over_main_menu_button != null:
		game_over_main_menu_button.disabled = true
	if victory_main_menu_button != null:
		victory_main_menu_button.disabled = true
	_play_sfx("ui_click")
	call_deferred("_go_to_main_menu_deferred")

func _on_pause_resume_pressed() -> void:
	_close_pause_menu()

func _on_pause_options_pressed() -> void:
	if pause_options_panel != null:
		var should_show_options: bool = not pause_options_panel.visible
		pause_options_panel.visible = should_show_options
		if should_show_options:
			_refresh_audio_controls_from_manager()
	_play_sfx("ui_click")

func _on_pause_main_menu_pressed() -> void:
	_play_sfx("ui_click")
	run_paused_for_menu = false
	if pause_menu_ui != null:
		pause_menu_ui.visible = false
	call_deferred("_go_to_main_menu_deferred")

func _open_pause_menu() -> void:
	if run_ended or run_paused_for_levelup or run_paused_for_menu:
		return
	run_paused_for_menu = true
	_set_gameplay_active(false)
	if pause_options_panel != null:
		pause_options_panel.visible = false
	if pause_menu_ui != null:
		pause_menu_ui.visible = true
	_play_sfx("ui_click")

func _close_pause_menu(play_click_sound: bool = true) -> void:
	if not run_paused_for_menu:
		return

	run_paused_for_menu = false
	if pause_menu_ui != null:
		pause_menu_ui.visible = false
	if pause_options_panel != null:
		pause_options_panel.visible = false
	if play_click_sound:
		_play_sfx("ui_click")

	var opened_levelup_prompt: bool = false
	if pending_levelup_count > 0 and not run_ended:
		pending_levelup_count -= 1
		opened_levelup_prompt = _open_levelup_prompt(false)
		if not opened_levelup_prompt:
			pending_levelup_count = 0

	if not opened_levelup_prompt:
		_set_gameplay_active(true)

func _go_to_main_menu_deferred() -> void:
	var main_menu_scene_path: String = "res://scenes/main_menu.tscn"
	if not ResourceLoader.exists(main_menu_scene_path, "PackedScene"):
		push_error("Main menu scene missing at: %s" % main_menu_scene_path)
		_set_gameplay_active(true)
		return
	get_tree().change_scene_to_file(main_menu_scene_path)

func _refresh_levelup_choice_text() -> Array:
	var options: Array = []
	_set_levelup_mode(false)
	_refresh_lineage_labels()
	if mutation_system != null and mutation_system.has_method("get_levelup_options"):
		var options_variant: Variant = mutation_system.call("get_levelup_options", 3)
		if options_variant is Array:
			options = options_variant

	_set_choice_button_text(levelup_choice_1, levelup_choice_1_icon, levelup_choice_1_text, options, 0)
	_set_choice_button_text(levelup_choice_2, levelup_choice_2_icon, levelup_choice_2_text, options, 1)
	_set_choice_button_text(levelup_choice_3, levelup_choice_3_icon, levelup_choice_3_text, options, 2)
	return options

func _set_choice_button_text(button: Button, icon: TextureRect, rich_text: RichTextLabel, options: Array, index: int) -> void:
	if button == null:
		return
	if index >= options.size():
		button.text = "No Mutation"
		if icon != null:
			icon.visible = false
		if rich_text != null:
			rich_text.text = "[center]No Mutation[/center]"
		return

	if not (options[index] is Dictionary):
		button.text = "No Mutation"
		if icon != null:
			icon.visible = false
		if rich_text != null:
			rich_text.text = "[center]No Mutation[/center]"
		return

	var option: Dictionary = options[index]
	_set_choice_icon(icon, option)
	var plain_text: String = _format_mutation_option_text(option)
	button.text = plain_text
	if rich_text != null:
		button.text = ""
		rich_text.text = _format_mutation_option_bbcode(option)

func _set_choice_icon(icon: TextureRect, option: Dictionary) -> void:
	if icon == null:
		return

	var mutation_id: String = String(option.get("id", ""))
	var icon_id: String = String(option.get("icon_id", mutation_id))
	if icon_id.is_empty() or not MUTATION_ICON_BY_ID.has(icon_id):
		icon.texture = null
		icon.visible = false
		return

	var icon_texture_variant: Variant = MUTATION_ICON_BY_ID.get(icon_id, null)
	var icon_texture: Texture2D = icon_texture_variant as Texture2D
	icon.texture = icon_texture
	icon.visible = icon_texture != null

func _get_spike_count_for_level(level_value: int) -> int:
	match level_value:
		1:
			return 4
		2:
			return 6
		3:
			return 8
		_:
			return 0

func _get_orbiter_count_for_level(level_value: int) -> int:
	match level_value:
		1:
			return 1
		2, 3:
			return 2
		_:
			return 0

func _get_membrane_reduction_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 15.0
		2:
			return 30.0
		3:
			return 45.0
		_:
			return 0.0

func _get_pulse_damage_for_level(level_value: int) -> int:
	match level_value:
		1:
			return 8
		2:
			return int(round(8.0 * 1.35))
		3:
			return int(round(8.0 * 1.75))
		_:
			return 0

func _get_pulse_radius_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 80.0
		2:
			return 96.0
		3:
			return 110.0
		_:
			return 0.0

func _get_pulse_interval_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 1.85
		2:
			return maxf(0.40, 1.85 * 0.86)
		3:
			return maxf(0.34, 1.85 * 0.74)
		_:
			return 999.0

func _get_acid_damage_for_level(level_value: int) -> int:
	match level_value:
		1:
			return 3
		2:
			return int(round(3.0 * 1.33))
		3:
			return int(round(3.0 * 1.65))
		_:
			return 0

func _get_acid_radius_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 17.0
		2:
			return 19.0
		3:
			return 21.5
		_:
			return 0.0

func _get_acid_lifetime_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 2.1
		2:
			return 2.8
		3:
			return 3.3
		_:
			return 0.0

func _get_acid_tick_interval_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 0.45
		2:
			return maxf(0.20, 0.45 * 0.84)
		3:
			return maxf(0.18, 0.45 * 0.72)
		_:
			return 999.0

func _get_metabolism_regen_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 1.8
		2:
			return 3.6
		3:
			return 5.76
		_:
			return 0.0

func _get_preview_module_damage_multiplier() -> float:
	return maxf(0.1, _reward_module_damage_multiplier * _synergy_module_damage_multiplier)

func _get_preview_orbiter_speed_multiplier() -> float:
	return maxf(0.1, _reward_orbiter_speed_multiplier * _synergy_orbiter_speed_multiplier)

func _get_preview_pulse_radius_multiplier() -> float:
	return maxf(0.1, _reward_pulse_radius_multiplier * _synergy_pulse_radius_multiplier)

func _get_preview_acid_lifetime_multiplier() -> float:
	return maxf(0.1, _reward_acid_lifetime_multiplier * _synergy_acid_lifetime_multiplier)

func _build_mutation_gain_summary_for_level(mutation_id: String, level_value: int) -> String:
	var clamped_level: int = clampi(level_value, 1, 3)
	var module_damage_multiplier: float = _get_preview_module_damage_multiplier()
	match mutation_id:
		"spikes":
			var spike_count: int = _get_spike_count_for_level(clamped_level)
			var spike_damage: int = maxi(1, int(round(8.0 * module_damage_multiplier)))
			return "Gain: %d spikes | %d dmg every 0.20s" % [spike_count, spike_damage]
		"orbiters":
			var orbiter_count: int = _get_orbiter_count_for_level(clamped_level)
			var orbiter_damage: int = maxi(1, int(round(6.0 * module_damage_multiplier)))
			var orbiter_speed: float = 2.5
			if clamped_level >= 3:
				orbiter_speed *= 1.5
			orbiter_speed *= _get_preview_orbiter_speed_multiplier()
			return "Gain: %d cells | %d dmg every 0.20s | %.2f rot/s" % [orbiter_count, orbiter_damage, orbiter_speed]
		"membrane":
			var membrane_reduction: float = _get_membrane_reduction_for_level(clamped_level)
			return "Gain: %.0f%% less incoming damage" % membrane_reduction
		"pulse_nova":
			var pulse_damage: int = maxi(1, int(round(float(_get_pulse_damage_for_level(clamped_level)) * module_damage_multiplier)))
			var pulse_radius: float = _get_pulse_radius_for_level(clamped_level) * _get_preview_pulse_radius_multiplier()
			var pulse_interval: float = _get_pulse_interval_for_level(clamped_level)
			return "Gain: %d pulse dmg | %.0f range | every %.2fs" % [pulse_damage, pulse_radius, pulse_interval]
		"acid_trail":
			var acid_damage: int = maxi(1, int(round(float(_get_acid_damage_for_level(clamped_level)) * module_damage_multiplier)))
			var acid_tick_interval: float = _get_acid_tick_interval_for_level(clamped_level)
			var acid_radius: float = _get_acid_radius_for_level(clamped_level)
			var acid_lifetime: float = _get_acid_lifetime_for_level(clamped_level) * _get_preview_acid_lifetime_multiplier()
			return "Gain: %d DOT every %.2fs | %.1f radius | %.2fs duration" % [acid_damage, acid_tick_interval, acid_radius, acid_lifetime]
		"metabolism":
			var regen_per_second: float = _get_metabolism_regen_for_level(clamped_level)
			return "Gain: +%.1f HP/s passive regen" % regen_per_second
		_:
			return ""

func _build_mutation_option_description_text(option: Dictionary) -> String:
	var description_text: String = String(option.get("description", "")).strip_edges()
	if description_text.is_empty():
		description_text = String(option.get("short", "")).strip_edges()
	return description_text

func _format_mutation_option_text(option: Dictionary) -> String:
	if _is_crisis_reward_option(option):
		var reward_name: String = String(option.get("name", "Reward"))
		var reward_summary: String = String(option.get("short", ""))
		if reward_summary.is_empty():
			reward_summary = String(option.get("description", ""))
		if reward_summary.is_empty():
			return reward_name
		return "%s\n%s" % [reward_name, reward_summary]

	var mutation_name: String = String(option.get("name", "Mutation"))
	var next_level: int = int(option.get("next_level", 1))
	var mutation_id: String = String(option.get("id", "")).strip_edges().to_lower()
	var summary_text: String = _build_mutation_option_description_text(option)
	var gain_text: String = _build_mutation_gain_summary_for_level(mutation_id, next_level)
	var favored: bool = bool(option.get("is_favored", false))
	if favored:
		mutation_name = "* " + mutation_name
	if summary_text.is_empty() and gain_text.is_empty():
		return "%s L%d" % [mutation_name, next_level]
	if gain_text.is_empty():
		return "%s L%d\n%s" % [mutation_name, next_level, summary_text]
	if summary_text.is_empty():
		return "%s L%d\n%s" % [mutation_name, next_level, gain_text]
	return "%s L%d\n%s\n%s" % [mutation_name, next_level, summary_text, gain_text]

func _format_mutation_option_bbcode(option: Dictionary) -> String:
	if _is_crisis_reward_option(option):
		var reward_name: String = String(option.get("name", "Reward"))
		var reward_summary: String = String(option.get("short", ""))
		if reward_summary.is_empty():
			reward_summary = String(option.get("description", ""))
		if reward_summary.is_empty():
			return "[center][b]%s[/b][/center]" % reward_name
		return "[center][b]%s[/b]\n%s[/center]" % [reward_name, reward_summary]

	var mutation_name: String = String(option.get("name", "Mutation"))
	var next_level: int = int(option.get("next_level", 1))
	var mutation_id: String = String(option.get("id", "")).strip_edges().to_lower()
	var summary_text: String = _build_mutation_option_description_text(option)
	var gain_text: String = _build_mutation_gain_summary_for_level(mutation_id, next_level)
	var favored: bool = bool(option.get("is_favored", false))
	var title_text: String = "%s L%d" % [mutation_name, next_level]
	if favored:
		title_text = "* " + title_text
	if summary_text.is_empty() and gain_text.is_empty():
		if favored:
			return "[center][b][color=#ffd966]%s[/color][/b][/center]" % [title_text]
		return "[center][b]%s[/b][/center]" % [title_text]

	var body_lines: Array[String] = []
	if not summary_text.is_empty():
		body_lines.append(summary_text)
	if not gain_text.is_empty():
		body_lines.append("[color=#9ec4d6]%s[/color]" % gain_text)
	var body_text: String = "\n".join(body_lines)

	if favored:
		return "[center][b][color=#ffd966]%s[/color][/b]\n%s[/center]" % [title_text, body_text]
	return "[center][b]%s[/b]\n%s[/center]" % [title_text, body_text]

func _is_crisis_reward_option(option: Dictionary) -> bool:
	return bool(option.get("is_crisis_reward", false))

func _should_prompt_lineage_now() -> bool:
	if level_reached < 2:
		return false
	if mutation_system == null:
		return false
	if not mutation_system.has_method("get_current_lineage_id"):
		return false

	var lineage_id_variant: Variant = mutation_system.call("get_current_lineage_id")
	var current_lineage_id: String = String(lineage_id_variant)
	return current_lineage_id.is_empty()

func _set_lineage_choice_button_texts() -> void:
	_set_levelup_mode(true)
	_refresh_choice_panel_labels()
	_set_lineage_choice_text(
		lineage_choice_1,
		lineage_choice_1_text,
		"Predator",
		"Aggressive close-range pressure",
		_build_lineage_starter_text("predator"),
		"Favored rolls: Spikes, Pulse Nova, Acid Trail"
	)
	_set_lineage_choice_text(
		lineage_choice_2,
		lineage_choice_2_text,
		"Swarm",
		"Orbit and area control growth",
		_build_lineage_starter_text("swarm"),
		"Favored rolls: Orbiters, Pulse Nova, Metabolism"
	)
	_set_lineage_choice_text(
		lineage_choice_3,
		lineage_choice_3_text,
		"Bulwark",
		"Defensive sustain and spacing",
		_build_lineage_starter_text("bulwark"),
		"Favored rolls: Membrane, Spikes, Metabolism"
	)

func _build_lineage_starter_text(lineage_id: String) -> String:
	match lineage_id:
		"predator":
			return "Starter: Pulse Nova L1 - %s" % _build_mutation_gain_summary_for_level("pulse_nova", 1)
		"swarm":
			return "Starter: Orbiters L1 - %s" % _build_mutation_gain_summary_for_level("orbiters", 1)
		"bulwark":
			return "Starter: Membrane L1 - %s" % _build_mutation_gain_summary_for_level("membrane", 1)
		_:
			return "Starter: None"

func _set_lineage_choice_text(
	button: Button,
	rich_text: RichTextLabel,
	title_text: String,
	description_text: String,
	starter_text: String,
	favored_text: String
) -> void:
	if button == null:
		return
	if rich_text == null:
		button.text = "%s\n%s\n%s\n%s" % [title_text, description_text, starter_text, favored_text]
		return
	button.text = ""
	rich_text.text = _format_lineage_choice_bbcode(title_text, description_text, starter_text, favored_text)

func _format_lineage_choice_bbcode(title_text: String, description_text: String, starter_text: String, favored_text: String) -> String:
	return "[center][b]%s[/b]\n%s\n[color=#9ec4d6]%s[/color]\n[color=#7fa4b6]%s[/color][/center]" % [
		title_text,
		description_text,
		starter_text,
		favored_text
	]

func _apply_lineage_choice(choice_index: int) -> bool:
	if mutation_system == null:
		return false
	if not mutation_system.has_method("choose_lineage"):
		return false
	if choice_index < 0 or choice_index >= LINEAGE_CHOICES.size():
		return false

	var lineage_id: String = LINEAGE_CHOICES[choice_index]
	var applied: bool = bool(mutation_system.call("choose_lineage", lineage_id))
	if not applied:
		return false
	lineage_selection_active = false
	return true

func _set_levelup_mode(lineage_mode: bool) -> void:
	if levelup_choices_row != null:
		levelup_choices_row.visible = not lineage_mode
	if lineage_choices_column != null:
		lineage_choices_column.visible = lineage_mode
	if lineage_bottom_padding != null:
		lineage_bottom_padding.visible = lineage_mode

func _get_current_lineage_name() -> String:
	if mutation_system != null and mutation_system.has_method("get_current_lineage_name"):
		var lineage_name_variant: Variant = mutation_system.call("get_current_lineage_name")
		return String(lineage_name_variant)
	return "None"

func _debug_grant_xp() -> void:
	if not _can_use_debug_xp_cheat():
		return
	if xp_system == null:
		return
	if not xp_system.has_method("add_xp"):
		return

	xp_system.call("add_xp", debug_grant_xp_amount)
	print("Debug XP granted: +", debug_grant_xp_amount)

func _debug_fast_forward_time() -> void:
	if not _can_use_debug_xp_cheat():
		return
	if run_ended:
		return
	if run_paused_for_levelup or run_paused_for_menu:
		return

	var seconds_to_skip: float = maxf(0.0, debug_fast_forward_seconds)
	if seconds_to_skip <= 0.0:
		return

	elapsed_seconds += seconds_to_skip
	_update_timer_label()
	_tick_crisis_director(seconds_to_skip)
	_tick_biohazard_leak_spawner(seconds_to_skip)

	for spawner_variant in get_tree().get_nodes_in_group("enemy_spawners"):
		var spawner_node := spawner_variant as Node
		if spawner_node == null:
			continue
		if not spawner_node.has_method("debug_advance_time"):
			continue
		spawner_node.call("debug_advance_time", seconds_to_skip)

	print("Debug fast-forward: +%.1fs (run time now %.1fs)" % [seconds_to_skip, elapsed_seconds])

func _debug_force_next_crisis() -> void:
	if not _can_use_debug_xp_cheat():
		return
	if run_ended:
		return
	if run_paused_for_levelup or run_paused_for_menu:
		return
	if crisis_director == null:
		return
	if not crisis_director.has_method("debug_force_next_active_crisis"):
		return

	var jumped: bool = bool(crisis_director.call("debug_force_next_active_crisis", elapsed_seconds))
	if jumped:
		_update_crisis_debug_banner()
		print("Debug crisis jump: moved to next active crisis")

func _debug_jump_to_final_crisis_threshold() -> void:
	if not _can_use_debug_xp_cheat():
		return
	if run_ended:
		return
	if run_paused_for_levelup or run_paused_for_menu:
		return
	if crisis_director == null:
		return

	var final_threshold_seconds: float = 240.0
	if crisis_director.has_method("get_final_crisis_start_seconds"):
		final_threshold_seconds = float(crisis_director.call("get_final_crisis_start_seconds"))
	else:
		var threshold_variant: Variant = crisis_director.get("final_crisis_start_seconds")
		if threshold_variant != null:
			final_threshold_seconds = float(threshold_variant)

	var target_time_seconds: float = maxf(elapsed_seconds, final_threshold_seconds + 0.1)
	elapsed_seconds = target_time_seconds
	_update_timer_label()
	_tick_crisis_director(0.1)
	_tick_biohazard_leak_spawner(0.1)
	_update_crisis_debug_banner()
	print("Debug jump: moved to final crisis threshold at %.1fs" % elapsed_seconds)

func _can_use_debug_xp_cheat() -> bool:
	if not debug_allow_grant_xp:
		return false
	if OS.has_feature("editor"):
		return true
	return OS.has_feature("dev_cheats")

func _play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id, volume_db_offset, pitch_scale)

func _setup_audio_controls() -> void:
	if pause_options_panel != null:
		pause_options_panel.visible = false

	if pause_sfx_slider != null:
		var pause_sfx_slider_callable := Callable(self, "_on_sfx_slider_value_changed")
		if not pause_sfx_slider.value_changed.is_connected(pause_sfx_slider_callable):
			pause_sfx_slider.value_changed.connect(pause_sfx_slider_callable)

	if pause_sfx_mute_toggle != null:
		var pause_sfx_mute_callable := Callable(self, "_on_sfx_mute_toggled")
		if not pause_sfx_mute_toggle.toggled.is_connected(pause_sfx_mute_callable):
			pause_sfx_mute_toggle.toggled.connect(pause_sfx_mute_callable)

	if pause_music_slider != null:
		var pause_music_slider_callable := Callable(self, "_on_music_slider_value_changed")
		if not pause_music_slider.value_changed.is_connected(pause_music_slider_callable):
			pause_music_slider.value_changed.connect(pause_music_slider_callable)

	if pause_music_mute_toggle != null:
		var pause_music_mute_callable := Callable(self, "_on_music_mute_toggled")
		if not pause_music_mute_toggle.toggled.is_connected(pause_music_mute_callable):
			pause_music_mute_toggle.toggled.connect(pause_music_mute_callable)

	_refresh_audio_controls_from_manager()

func _refresh_audio_controls_from_manager() -> void:
	var sfx_value: float = 0.5
	var music_value: float = 0.4
	var sfx_muted: bool = false
	var music_muted: bool = false
	if audio_manager != null:
		if audio_manager.has_method("get_sfx_volume_linear"):
			sfx_value = float(audio_manager.call("get_sfx_volume_linear"))
		if audio_manager.has_method("get_music_volume_linear"):
			music_value = float(audio_manager.call("get_music_volume_linear"))
		if audio_manager.has_method("get_sfx_muted"):
			sfx_muted = bool(audio_manager.call("get_sfx_muted"))
		if audio_manager.has_method("get_music_muted"):
			music_muted = bool(audio_manager.call("get_music_muted"))

	_syncing_audio_controls = true
	_set_sfx_slider_values(sfx_value)
	_set_music_slider_values(music_value)
	_set_sfx_mute_values(sfx_muted)
	_set_music_mute_values(music_muted)
	_syncing_audio_controls = false

func _set_sfx_slider_values(value: float) -> void:
	if pause_sfx_slider != null:
		pause_sfx_slider.value = value

func _set_music_slider_values(value: float) -> void:
	if pause_music_slider != null:
		pause_music_slider.value = value

func _set_sfx_mute_values(value: bool) -> void:
	if pause_sfx_mute_toggle != null:
		pause_sfx_mute_toggle.button_pressed = value

func _set_music_mute_values(value: bool) -> void:
	if pause_music_mute_toggle != null:
		pause_music_mute_toggle.button_pressed = value

func _on_sfx_slider_value_changed(value: float) -> void:
	if _syncing_audio_controls:
		return
	if audio_manager == null:
		return
	if not audio_manager.has_method("set_sfx_volume_linear"):
		return
	audio_manager.call("set_sfx_volume_linear", value)
	_syncing_audio_controls = true
	_set_sfx_slider_values(value)
	_syncing_audio_controls = false

func _on_music_slider_value_changed(value: float) -> void:
	if _syncing_audio_controls:
		return
	if audio_manager == null:
		return
	if not audio_manager.has_method("set_music_volume_linear"):
		return
	audio_manager.call("set_music_volume_linear", value)
	_syncing_audio_controls = true
	_set_music_slider_values(value)
	_syncing_audio_controls = false

func _on_sfx_mute_toggled(pressed: bool) -> void:
	if _syncing_audio_controls:
		return
	if audio_manager == null:
		return
	if not audio_manager.has_method("set_sfx_muted"):
		return
	audio_manager.call("set_sfx_muted", pressed)
	_syncing_audio_controls = true
	_set_sfx_mute_values(pressed)
	_syncing_audio_controls = false

func _on_music_mute_toggled(pressed: bool) -> void:
	if _syncing_audio_controls:
		return
	if audio_manager == null:
		return
	if not audio_manager.has_method("set_music_muted"):
		return
	audio_manager.call("set_music_muted", pressed)
	_syncing_audio_controls = true
	_set_music_mute_values(pressed)
	_syncing_audio_controls = false

func _play_music(track_id: String = "bgm_main") -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_music"):
		return
	audio_manager.call("play_music", track_id)

func _stop_music() -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("stop_music"):
		return
	audio_manager.call("stop_music")

func _fade_out_music(duration_seconds: float = 1.0) -> void:
	if audio_manager == null:
		return
	if audio_manager.has_method("fade_out_music"):
		audio_manager.call("fade_out_music", duration_seconds)
		return
	_stop_music()

func _open_crisis_reward_prompt(crisis_id: String) -> bool:
	var options: Array = _build_crisis_reward_options(crisis_id)
	if options.is_empty():
		return false

	# If a normal level-up prompt is already open, preserve it in queue.
	if run_paused_for_levelup and not crisis_reward_selection_active:
		_queue_pending_levelup("deferred_by_crisis_reward")

	active_crisis_reward_id = crisis_id
	crisis_reward_selection_active = true
	lineage_selection_active = false
	crisis_reward_options = options

	_set_levelup_mode(false)
	_refresh_lineage_labels()
	_set_choice_button_text(levelup_choice_1, levelup_choice_1_icon, levelup_choice_1_text, crisis_reward_options, 0)
	_set_choice_button_text(levelup_choice_2, levelup_choice_2_icon, levelup_choice_2_text, crisis_reward_options, 1)
	_set_choice_button_text(levelup_choice_3, levelup_choice_3_icon, levelup_choice_3_text, crisis_reward_options, 2)

	run_paused_for_levelup = true
	_set_gameplay_active(false)
	if levelup_ui != null:
		levelup_ui.visible = true
	_play_sfx("levelup")
	return true

func _build_crisis_reward_options(crisis_id: String) -> Array:
	match crisis_id:
		"containment_sweep":
			return [
				_build_crisis_reward_option(
					"sweep_breach_lenses",
					"Breach Lenses",
					"+15% module damage for this run.",
					"spikes"
				),
				_build_crisis_reward_option(
					"sweep_phase_ducts",
					"Phase Ducts",
					"+12% movement speed for this run.",
					"metabolism"
				),
				_build_crisis_reward_option(
					"sweep_reactive_shell",
					"Reactive Shell",
					"-12% incoming damage for this run.",
					"membrane"
				)
			]
		"strain_bloom":
			return [
				_build_crisis_reward_option(
					"bloom_overclock_core",
					"Overclock Core",
					"+20% contact damage for this run.",
					"pulse_nova"
				),
				_build_crisis_reward_option(
					"bloom_hunters_gyro",
					"Hunter's Gyro",
					"+25% orbiter speed for this run.",
					"orbiters"
				),
				_build_crisis_reward_option(
					"bloom_adaptive_skin",
					"Adaptive Skin",
					"+15 max HP for this run.",
					"membrane"
				)
			]
		"biohazard_leak":
			return [
				_build_crisis_reward_option(
					"leak_detox_glands",
					"Detox Glands",
					"+2.0 HP regen per second for this run.",
					"metabolism"
				),
				_build_crisis_reward_option(
					"leak_acid_recycler",
					"Acid Recycler",
					"+30% acid trail uptime for this run.",
					"acid_trail"
				),
				_build_crisis_reward_option(
					"leak_nova_condenser",
					"Nova Condenser",
					"+20% pulse nova radius for this run.",
					"pulse_nova"
				)
			]
		_:
			return [
				_build_crisis_reward_option(
					"fallback_hardened_membrane",
					"Hardened Membrane",
					"+10 max HP for this run.",
					"membrane"
				),
				_build_crisis_reward_option(
					"fallback_spike_density",
					"Spike Density",
					"+10% module damage for this run.",
					"spikes"
				),
				_build_crisis_reward_option(
					"fallback_metabolic_burst",
					"Metabolic Burst",
					"+8% movement speed for this run.",
					"metabolism"
				)
			]

func _build_crisis_reward_option(option_id: String, option_name: String, option_description: String, icon_id: String) -> Dictionary:
	return {
		"id": option_id,
		"name": option_name,
		"description": option_description,
		"short": option_description,
		"icon_id": icon_id,
		"is_crisis_reward": true
	}

func _apply_crisis_reward_choice(choice_index: int) -> bool:
	if choice_index < 0 or choice_index >= crisis_reward_options.size():
		return false
	if not (crisis_reward_options[choice_index] is Dictionary):
		return false

	var reward_option: Dictionary = crisis_reward_options[choice_index]
	var reward_id: String = String(reward_option.get("id", ""))
	var reward_name: String = String(reward_option.get("name", "Crisis Reward"))
	var reward_icon_id: String = String(reward_option.get("icon_id", ""))
	var reward_description: String = String(reward_option.get("description", ""))
	var reward_applied: bool = _apply_crisis_reward_effect(reward_id)
	if not reward_applied:
		return false
	_register_run_reward_inventory(reward_id, reward_name, reward_icon_id, reward_description)
	_refresh_run_inventory_ui()
	_apply_runtime_reward_effects()
	_refresh_metabolism_hud()
	if debug_log_crisis_timeline:
		print("[GameManager] Crisis reward selected: %s (%s)" % [reward_name, reward_id])
	return true

func _apply_crisis_reward_effect(reward_id: String) -> bool:
	match reward_id:
		"sweep_breach_lenses":
			_reward_module_damage_multiplier *= 1.15
		"sweep_phase_ducts":
			_reward_move_speed_multiplier *= 1.12
		"sweep_reactive_shell":
			_reward_external_damage_multiplier *= 0.88
		"bloom_overclock_core":
			_reward_module_damage_multiplier *= 1.20
		"bloom_hunters_gyro":
			_reward_orbiter_speed_multiplier *= 1.25
		"bloom_adaptive_skin":
			_reward_bonus_max_hp_flat += 15
		"leak_detox_glands":
			_reward_passive_regen_per_second += 2.0
		"leak_acid_recycler":
			_reward_acid_lifetime_multiplier *= 1.30
		"leak_nova_condenser":
			_reward_pulse_radius_multiplier *= 1.20
		"fallback_hardened_membrane":
			_reward_bonus_max_hp_flat += 10
		"fallback_spike_density":
			_reward_module_damage_multiplier *= 1.10
		"fallback_metabolic_burst":
			_reward_move_speed_multiplier *= 1.08
		_:
			return false
	return true

func _apply_runtime_reward_effects() -> void:
	_recompute_active_tag_synergies()
	_apply_runtime_reward_effects_to_player()
	_apply_runtime_reward_effects_to_mutation_system()

func _apply_runtime_reward_effects_to_player() -> void:
	if player == null:
		return
	var total_move_speed_multiplier: float = maxf(0.1, _reward_move_speed_multiplier * _synergy_move_speed_multiplier)
	var total_external_damage_multiplier: float = clampf(
		_reward_external_damage_multiplier * _synergy_external_damage_multiplier,
		0.05,
		1.0
	)
	if player.has_method("set_bonus_move_speed_multiplier"):
		player.call("set_bonus_move_speed_multiplier", total_move_speed_multiplier)
	if player.has_method("set_bonus_max_hp_flat"):
		player.call("set_bonus_max_hp_flat", maxi(0, _reward_bonus_max_hp_flat))
	if player.has_method("set_external_incoming_damage_multiplier"):
		player.call("set_external_incoming_damage_multiplier", total_external_damage_multiplier)

func _apply_runtime_reward_effects_to_mutation_system() -> void:
	if mutation_system == null:
		return
	if not mutation_system.has_method("set_runtime_crisis_reward_modifiers"):
		return
	var total_module_damage_multiplier: float = maxf(0.1, _reward_module_damage_multiplier * _synergy_module_damage_multiplier)
	var total_orbiter_speed_multiplier: float = maxf(0.1, _reward_orbiter_speed_multiplier * _synergy_orbiter_speed_multiplier)
	var total_pulse_radius_multiplier: float = maxf(0.1, _reward_pulse_radius_multiplier * _synergy_pulse_radius_multiplier)
	var total_acid_lifetime_multiplier: float = maxf(0.1, _reward_acid_lifetime_multiplier * _synergy_acid_lifetime_multiplier)
	mutation_system.call(
		"set_runtime_crisis_reward_modifiers",
		total_module_damage_multiplier,
		total_orbiter_speed_multiplier,
		total_pulse_radius_multiplier,
		total_acid_lifetime_multiplier
	)

func _collect_active_mutation_tags() -> Dictionary:
	var active_tags: Dictionary = {}
	var mutation_defs: Dictionary = MUTATIONS_DATA.get_all()
	for mutation_id in INVENTORY_MUTATION_IDS:
		var level_value: int = int(_run_mutation_inventory_levels.get(mutation_id, 0))
		if level_value <= 0:
			continue
		if not mutation_defs.has(mutation_id):
			continue
		var mutation_def: Dictionary = mutation_defs.get(mutation_id, {})
		var tags_variant: Variant = mutation_def.get("tags", [])
		if not (tags_variant is Array):
			continue
		var tags_array: Array = tags_variant
		for raw_tag in tags_array:
			var tag_id: String = String(raw_tag).strip_edges().to_lower()
			if tag_id.is_empty():
				continue
			active_tags[tag_id] = true
	return active_tags

func _are_synergy_tags_active(required_tags_variant: Variant, active_tags: Dictionary) -> bool:
	if not (required_tags_variant is Array):
		return false
	var required_tags: Array = required_tags_variant
	if required_tags.is_empty():
		return false
	for raw_tag in required_tags:
		var required_tag_id: String = String(raw_tag).strip_edges().to_lower()
		if required_tag_id.is_empty():
			return false
		if not active_tags.has(required_tag_id):
			return false
	return true

func _recompute_active_tag_synergies() -> void:
	var previous_active_synergy_ids: Array[String] = _active_tag_synergy_ids.duplicate()
	_synergy_module_damage_multiplier = 1.0
	_synergy_orbiter_speed_multiplier = 1.0
	_synergy_pulse_radius_multiplier = 1.0
	_synergy_acid_lifetime_multiplier = 1.0
	_synergy_move_speed_multiplier = 1.0
	_synergy_external_damage_multiplier = 1.0
	_synergy_passive_regen_per_second = 0.0
	_active_tag_synergy_ids.clear()

	if not enable_tag_synergies:
		_queue_newly_activated_synergy_popups(previous_active_synergy_ids)
		_maybe_log_active_tag_synergies()
		return

	var active_tags: Dictionary = _collect_active_mutation_tags()
	for rule_variant in MUTATION_TAG_SYNERGY_RULES:
		if not (rule_variant is Dictionary):
			continue
		var rule: Dictionary = rule_variant
		if not _are_synergy_tags_active(rule.get("tags", []), active_tags):
			continue

		var rule_id: String = String(rule.get("id", ""))
		if not rule_id.is_empty():
			_active_tag_synergy_ids.append(rule_id)

		_synergy_module_damage_multiplier *= float(rule.get("module_damage_multiplier", 1.0))
		_synergy_orbiter_speed_multiplier *= float(rule.get("orbiter_speed_multiplier", 1.0))
		_synergy_pulse_radius_multiplier *= float(rule.get("pulse_radius_multiplier", 1.0))
		_synergy_acid_lifetime_multiplier *= float(rule.get("acid_lifetime_multiplier", 1.0))
		_synergy_move_speed_multiplier *= float(rule.get("move_speed_multiplier", 1.0))
		_synergy_external_damage_multiplier *= float(rule.get("external_damage_multiplier", 1.0))
		_synergy_passive_regen_per_second += float(rule.get("passive_regen_per_second", 0.0))

	_queue_newly_activated_synergy_popups(previous_active_synergy_ids)
	_maybe_log_active_tag_synergies()

func _build_tag_synergy_debug_signature() -> String:
	if _active_tag_synergy_ids.is_empty():
		return ""
	var ordered_synergy_ids: Array[String] = _active_tag_synergy_ids.duplicate()
	ordered_synergy_ids.sort()
	return "|".join(ordered_synergy_ids)

func _get_synergy_rule_name(synergy_id: String) -> String:
	if synergy_id.is_empty():
		return "Unknown"
	for rule_variant in MUTATION_TAG_SYNERGY_RULES:
		if not (rule_variant is Dictionary):
			continue
		var rule: Dictionary = rule_variant
		var rule_id: String = String(rule.get("id", ""))
		if rule_id != synergy_id:
			continue
		var rule_name: String = String(rule.get("name", ""))
		if rule_name.is_empty():
			break
		return rule_name
	return synergy_id.replace("_", " ").capitalize()

func _maybe_log_active_tag_synergies() -> void:
	if not debug_log_tag_synergies:
		return

	var current_signature: String = _build_tag_synergy_debug_signature()
	if current_signature == _last_logged_tag_synergy_signature:
		return
	_last_logged_tag_synergy_signature = current_signature

	if _active_tag_synergy_ids.is_empty():
		print("[Synergy] Active: none")
		return

	var synergy_names: Array[String] = []
	for synergy_id in _active_tag_synergy_ids:
		synergy_names.append(_get_synergy_rule_name(synergy_id))
	synergy_names.sort()
	print("[Synergy] Active: %s" % ", ".join(synergy_names))

func _finish_crisis_reward_prompt() -> void:
	crisis_reward_selection_active = false
	active_crisis_reward_id = ""
	crisis_reward_options.clear()
	_complete_reward_phase_if_active()

	if pending_levelup_count > 0:
		pending_levelup_count -= 1
		var did_open_prompt: bool = _open_levelup_prompt(false)
		if did_open_prompt:
			return
		pending_levelup_count = 0

	_close_levelup_prompt()

func _complete_reward_phase_if_active() -> void:
	if crisis_director == null:
		return
	if not crisis_director.has_method("complete_reward_phase_early"):
		return
	var completed_early: bool = bool(crisis_director.call("complete_reward_phase_early"))
	if debug_log_crisis_timeline and completed_early:
		print("[GameManager] Crisis reward phase completed early via selection")

func _open_levelup_prompt(play_sound: bool = true) -> bool:
	if run_ended:
		return false
	if run_paused_for_menu:
		_queue_pending_levelup("pause_menu_active")
		return false
	if crisis_reward_selection_active:
		_queue_pending_levelup("crisis_reward_active")
		return false

	crisis_reward_selection_active = false
	active_crisis_reward_id = ""
	crisis_reward_options.clear()

	if _should_prompt_lineage_now():
		lineage_selection_active = true
		_set_lineage_choice_button_texts()
	else:
		lineage_selection_active = false
		levelup_options = _refresh_levelup_choice_text()
		if levelup_options.is_empty():
			return false

	run_paused_for_levelup = true
	if play_sound:
		_play_sfx("levelup")
	_set_gameplay_active(false)
	if levelup_ui != null:
		levelup_ui.visible = true
	return true

func _close_levelup_prompt() -> void:
	if levelup_ui != null:
		levelup_ui.visible = false
	run_paused_for_levelup = false
	crisis_reward_selection_active = false
	active_crisis_reward_id = ""
	crisis_reward_options.clear()
	_refresh_lineage_labels()
	_set_gameplay_active(true)
