extends Node2D

const BIOMASS_PICKUP_SCENE: PackedScene = preload("res://scenes/systems/biomass_pickup.tscn")
const CONTAINMENT_SWEEP_SCENE: PackedScene = preload("res://scenes/systems/containment_sweep_hazard.tscn")
const BIOHAZARD_LEAK_ZONE_SCENE: PackedScene = preload("res://scenes/systems/biohazard_leak_zone.tscn")
const STRAIN_BLOOM_ELITE_SCENE: PackedScene = preload("res://scenes/actors/enemy_elite.tscn")
const ANTIVIRAL_DRONE_SCENE: PackedScene = preload("res://scenes/actors/enemy_ranged.tscn")
const CONTAINMENT_PYLON_SCENE: PackedScene = preload("res://scenes/systems/containment_pylon.tscn")
const GENOME_CACHE_POD_SCENE: PackedScene = preload("res://scenes/systems/genome_cache_pod.tscn")
const PROTOCOL_OMEGA_BOSS_SCENE: PackedScene = preload("res://scenes/actors/protocol_omega_boss.tscn")
const LEECH_TENDRIL_SCENE: PackedScene = preload("res://scenes/modules/leech_tendril.tscn")
const MUTATIONS_DATA = preload("res://data/mutations.gd")
const MUTATION_ICON_PROTO_PULSE: Texture2D = preload("res://art/sprites/ui/icons/icon_proto_pulse.png")
const MUTATION_ICON_RAZOR_HALO: Texture2D = preload("res://art/sprites/ui/icons/icon_razor_halo.png")
const MUTATION_ICON_PUNCTURE_LANCE: Texture2D = preload("res://art/sprites/ui/icons/icon_puncture_lance.png")
const MUTATION_ICON_LYTIC_BURST: Texture2D = preload("res://art/sprites/ui/icons/icon_lytic_burst.png")
const MUTATION_ICON_INFECTIVE_SECRETION: Texture2D = preload("res://art/sprites/ui/icons/icon_infective_secretion.png")
const MUTATION_ICON_VIRION_ORBIT: Texture2D = preload("res://art/sprites/ui/icons/icon_virion_orbit.png")
const MUTATION_ICON_CHAIN_BLOOM: Texture2D = preload("res://art/sprites/ui/icons/icon_chain_bloom.png")
const MUTATION_ICON_LEECH_TENDRIL: Texture2D = preload("res://art/sprites/ui/icons/icon_leech_tendril.png")
const MUTATION_ICON_PROTEIN_SHELL: Texture2D = preload("res://art/sprites/ui/icons/icon_protein_shell.png")
const MUTATION_ICON_HOST_OVERRIDE: Texture2D = preload("res://art/sprites/ui/icons/icon_host_override.png")
const MUTATION_ICON_STAT_OFFENSE: Texture2D = preload("res://art/sprites/ui/icons/icon_stat_offense.png")
const MUTATION_ICON_STAT_DEFENSE: Texture2D = preload("res://art/sprites/ui/icons/icon_stat_defense.png")
const MUTATION_ICON_STAT_PICKUP: Texture2D = preload("res://art/sprites/ui/icons/icon_stat_pickup.png")
const MUTATION_ICON_STAT_SPEED: Texture2D = preload("res://art/sprites/ui/icons/icon_stat_speed.png")
const MUTATION_ICON_STAT_COOLDOWN: Texture2D = preload("res://art/sprites/ui/icons/icon_stat_cooldown.png")
const MUTATION_ICON_STAT_VITALITY: Texture2D = preload("res://art/sprites/ui/icons/icon_stat_vitality.png")
const MUTATION_ICON_RECOMB_LYTIC_PAIR: Texture2D = preload("res://art/sprites/ui/icons/icon_recomb_lytic_pair.png")
const MUTATION_ICON_RECOMB_LYTIC_APEX: Texture2D = preload("res://art/sprites/ui/icons/icon_recomb_lytic_apex.png")
const MUTATION_ICON_RECOMB_PANDEMIC_PAIR: Texture2D = preload("res://art/sprites/ui/icons/icon_recomb_pandemic_pair.png")
const MUTATION_ICON_RECOMB_PANDEMIC_APEX: Texture2D = preload("res://art/sprites/ui/icons/icon_recomb_pandemic_apex.png")
const MUTATION_ICON_RECOMB_PARASITIC_PAIR: Texture2D = preload("res://art/sprites/ui/icons/icon_recomb_parasitic_pair.png")
const MUTATION_ICON_RECOMB_PARASITIC_APEX: Texture2D = preload("res://art/sprites/ui/icons/icon_recomb_parasitic_apex.png")
const ICON_BACKGROUND_TEXTURE: Texture2D = preload("res://art/sprites/ui/icons/icon_background.png")
const VARIANT_ICON_LYTIC: Texture2D = preload("res://art/sprites/ui/icons/icon_razor_halo.png")
const VARIANT_ICON_PANDEMIC: Texture2D = preload("res://art/sprites/ui/icons/icon_infective_secretion.png")
const VARIANT_ICON_PARASITIC: Texture2D = preload("res://art/sprites/ui/icons/icon_leech_tendril.png")
const VARIANT_CAST_ICON_LYTIC_DASH: Texture2D = preload("res://art/sprites/ui/icons/icon_variant_cast_lytic_dash.png")
const VARIANT_CAST_ICON_PANDEMIC_CAMOUFLAGE: Texture2D = preload("res://art/sprites/ui/icons/icon_variant_cast_pandemic_camouflage.png")
const VARIANT_CAST_ICON_PARASITIC_SIPHON: Texture2D = preload("res://art/sprites/ui/icons/icon_variant_cast_parasitic_siphon.png")
const GAMEPLAY_SETTINGS = preload("res://scripts/systems/gameplay_settings.gd")
const RUN_INVENTORY_SLOT_SIZE: float = 64.0
const RUN_INVENTORY_ICON_PADDING: float = 5.0
const RUN_INVENTORY_VALUE_INSET: float = 7.0
const RUN_INVENTORY_VALUE_BOX_SIZE: float = 18.0
const ICON_TEMPLATE_BASE_META_KEY: StringName = &"icon_template_base"
const ICON_TEMPLATE_BG_NODE_PREFIX: String = "__IconTemplateBg_"
const ICON_TEMPLATE_CHOICE_ICON_INSET: float = 11.0
const ICON_TEMPLATE_LINEAGE_ICON_INSET: float = 8.0
const ICON_TEMPLATE_INVENTORY_ICON_INSET: float = 6.0
const ICON_TEMPLATE_BG_EXPAND: float = 2.0
const SCORE_HISTORY_FILE_PATH: String = "user://run_score_history.json"
const SCORE_HISTORY_MAX_ENTRIES: int = 30
const MUTATION_ICON_BY_ID: Dictionary = {
	"proto_pulse": MUTATION_ICON_PROTO_PULSE,
	"razor_halo": MUTATION_ICON_RAZOR_HALO,
	"puncture_lance": MUTATION_ICON_PUNCTURE_LANCE,
	"lytic_burst": MUTATION_ICON_LYTIC_BURST,
	"infective_secretion": MUTATION_ICON_INFECTIVE_SECRETION,
	"virion_orbit": MUTATION_ICON_VIRION_ORBIT,
	"chain_bloom": MUTATION_ICON_CHAIN_BLOOM,
	"leech_tendril": MUTATION_ICON_LEECH_TENDRIL,
	"protein_shell": MUTATION_ICON_PROTEIN_SHELL,
	"host_override": MUTATION_ICON_HOST_OVERRIDE,
	"offense_boost": MUTATION_ICON_STAT_OFFENSE,
	"defense_boost": MUTATION_ICON_STAT_DEFENSE,
	"pickup_radius_boost": MUTATION_ICON_STAT_PICKUP,
	"move_speed_boost": MUTATION_ICON_STAT_SPEED,
	"cooldown_boost": MUTATION_ICON_STAT_COOLDOWN,
	"vitality_boost": MUTATION_ICON_STAT_VITALITY,
	"stat_offense": MUTATION_ICON_STAT_OFFENSE,
	"stat_defense": MUTATION_ICON_STAT_DEFENSE,
	"stat_pickup": MUTATION_ICON_STAT_PICKUP,
	"stat_speed": MUTATION_ICON_STAT_SPEED,
	"stat_cooldown": MUTATION_ICON_STAT_COOLDOWN,
	"stat_vitality": MUTATION_ICON_STAT_VITALITY,
	"icon_recomb_lytic_pair": MUTATION_ICON_RECOMB_LYTIC_PAIR,
	"icon_recomb_lytic_apex": MUTATION_ICON_RECOMB_LYTIC_APEX,
	"icon_recomb_pandemic_pair": MUTATION_ICON_RECOMB_PANDEMIC_PAIR,
	"icon_recomb_pandemic_apex": MUTATION_ICON_RECOMB_PANDEMIC_APEX,
	"icon_recomb_parasitic_pair": MUTATION_ICON_RECOMB_PARASITIC_PAIR,
	"icon_recomb_parasitic_apex": MUTATION_ICON_RECOMB_PARASITIC_APEX
}
const SYNERGY_ICON_ID_BY_RULE_ID: Dictionary = {
	"lytic_pair": "icon_recomb_lytic_pair",
	"lytic_apex": "icon_recomb_lytic_apex",
	"pandemic_pair": "icon_recomb_pandemic_pair",
	"pandemic_apex": "icon_recomb_pandemic_apex",
	"parasitic_pair": "icon_recomb_parasitic_pair",
	"parasitic_apex": "icon_recomb_parasitic_apex"
}
const INVENTORY_MUTATION_IDS: Array[String] = [
	"proto_pulse",
	"razor_halo",
	"puncture_lance",
	"lytic_burst",
	"infective_secretion",
	"virion_orbit",
	"chain_bloom",
	"leech_tendril",
	"protein_shell",
	"host_override"
]
const BIOMASS_BONUS_CRISIS_IDS: Array[String] = [
	"containment_warden"
]
const MUTATION_TAG_SYNERGY_RULES: Array[Dictionary] = [
	{
		"id": "lytic_pair",
		"name": "Lytic Pressure",
		"tags": ["lytic_starter", "lytic_core"],
		"module_damage_multiplier": 1.18
	},
	{
		"id": "lytic_apex",
		"name": "Lytic Overrun",
		"tags": ["lytic_starter", "lytic_core", "lytic_capstone"],
		"module_damage_multiplier": 1.14,
		"pulse_radius_multiplier": 1.12
	},
	{
		"id": "pandemic_pair",
		"name": "Volatile Secretion",
		"tags": ["pandemic_starter", "pandemic_core"],
		"module_damage_multiplier": 1.08,
		"acid_lifetime_multiplier": 1.32,
		"pulse_radius_multiplier": 1.14
	},
	{
		"id": "pandemic_apex",
		"name": "Epidemic Cascade",
		"tags": ["pandemic_starter", "pandemic_core", "pandemic_capstone"],
		"module_damage_multiplier": 1.18,
		"acid_lifetime_multiplier": 1.22
	},
	{
		"id": "parasitic_pair",
		"name": "Armored Pressure",
		"tags": ["parasitic_starter", "parasitic_core"],
		"module_damage_multiplier": 1.08,
		"external_damage_multiplier": 0.90
	},
	{
		"id": "parasitic_apex",
		"name": "Host Dominion",
		"tags": ["parasitic_starter", "parasitic_core", "parasitic_capstone"],
		"passive_regen_per_second": 1.2,
		"external_damage_multiplier": 0.94,
		"module_damage_multiplier": 1.10
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
@onready var timer_backdrop: Panel = get_node_or_null("UiHud/TimerBackdrop")
@onready var score_label: Label = get_node_or_null("UiHud/ScoreLabel")
@onready var score_backdrop: Panel = get_node_or_null("UiHud/ScoreBackdrop")
@onready var crisis_debug_label: Label = get_node_or_null("UiHud/CrisisDebugLabel")
@onready var crisis_backdrop: Panel = get_node_or_null("UiHud/CrisisBackdrop")
@onready var boss_backdrop: Panel = get_node_or_null("UiHud/BossBackdrop")
@onready var boss_icon: TextureRect = get_node_or_null("UiHud/BossIcon")
@onready var boss_name_label: Label = get_node_or_null("UiHud/BossNameLabel")
@onready var boss_health_bar: ProgressBar = get_node_or_null("UiHud/BossHealthBar")
@onready var lineage_label: Label = get_node_or_null("UiHud/LineageLabel")
@onready var variant_cast_panel: Panel = get_node_or_null("UiHud/VariantCastPanel")
@onready var variant_cast_label: Label = get_node_or_null("UiHud/VariantCastPanel/VariantCastLabel")
@onready var variant_cast_state_label: Label = get_node_or_null("UiHud/VariantCastPanel/VariantCastStateLabel")
@onready var variant_cast_icon: TextureRect = get_node_or_null("UiHud/VariantCastPanel/VariantCastIcon")
@onready var variant_cast_overlay: ColorRect = get_node_or_null("UiHud/VariantCastPanel/VariantCastIcon/VariantCastCooldownOverlay")
@onready var variant_cast_cooldown_label: Label = get_node_or_null("UiHud/VariantCastPanel/VariantCastIcon/VariantCastCooldownLabel")
@onready var arena_background_sprite: Sprite2D = get_node_or_null("ArenaSprite")
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
@onready var lineage_choices_column: BoxContainer = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn")
@onready var lineage_choice_1: Button = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton1")
@onready var lineage_choice_2: Button = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton2")
@onready var lineage_choice_3: Button = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton3")
@onready var lineage_choice_1_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton1/LineageText")
@onready var lineage_choice_2_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton2/LineageText")
@onready var lineage_choice_3_text: RichTextLabel = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton3/LineageText")
@onready var lineage_choice_1_icon: TextureRect = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton1/LineageIcon")
@onready var lineage_choice_2_icon: TextureRect = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton2/LineageIcon")
@onready var lineage_choice_3_icon: TextureRect = get_node_or_null("UiLevelup/Root/Layout/LineageChoicesColumn/LineageButton3/LineageIcon")
@onready var lineage_bottom_padding: Control = get_node_or_null("UiLevelup/Root/Layout/LineageBottomPadding")
@onready var game_over_ui: CanvasLayer = get_node_or_null("GameOver")
@onready var game_over_stats_label: Label = get_node_or_null("GameOver/Root/StatsLabel")
@onready var game_over_score_label: Label = get_node_or_null("GameOver/Root/ScoreLabel")
@onready var game_over_meta_stats_label: Label = get_node_or_null("GameOver/Root/MetaStatsLabel")
@onready var game_over_reason_label: Label = get_node_or_null("GameOver/Root/ReasonLabel")
@onready var game_over_main_menu_button: Button = get_node_or_null("GameOver/Root/MainMenuButton")
@onready var victory_ui: CanvasLayer = get_node_or_null("Victory")
@onready var victory_stats_label: Label = get_node_or_null("Victory/Root/StatsLabel")
@onready var victory_score_label: Label = get_node_or_null("Victory/Root/ScoreLabel")
@onready var victory_meta_stats_label: Label = get_node_or_null("Victory/Root/MetaStatsLabel")
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
@onready var pause_fps_option_button: OptionButton = get_node_or_null("PauseMenu/Root/Content/OptionsPanel/Padding/AudioRows/FpsRow/FpsOptionButton")
@onready var pause_stats_text: RichTextLabel = get_node_or_null("PauseMenu/Root/StatsPanel/StatsPadding/StatsColumn/StatsText")
@onready var crisis_director: Node = get_node_or_null("CrisisDirector")
@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")
@onready var postprocess_overlay: ColorRect = get_node_or_null("PostProcessLayer/PostProcessOverlay")

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
var genome_cache_selection_active: bool = false
var active_crisis_reward_id: String = ""
var crisis_reward_options: Array = []
var pending_genome_cache_prompt_count: int = 0
var game_over_main_menu_requested: bool = false
var _last_player_hp: int = -1
var _pending_crisis_failure_audio: bool = false
var _last_run_end_reason: String = ""
var _last_containment_sweep_hit_seconds: float = -1000.0
var _syncing_audio_controls: bool = false
var _sfx_reentry_guard: bool = false
var _active_containment_sweeps: Array[Node2D] = []
var _active_biohazard_leaks: Array[Node2D] = []
var _final_crisis_elites: Array[Node2D] = []
var _protocol_omega_boss_target: Node2D
var _protocol_omega_boss_phase: int = 1
var _active_antiviral_drones: Array[Node2D] = []
var _active_containment_pylons: Array[Node2D] = []
var _active_genome_cache_pods: Array[Node2D] = []
var _containment_pylon_arrows: Dictionary = {}
var _containment_arrow_elapsed_seconds: float = 0.0
var _genome_cache_spawned_count: int = 0
var _genome_cache_next_spawn_time_seconds: float = 0.0
var _biohazard_leak_spawner_active: bool = false
var _biohazard_leak_spawn_accumulator: float = 0.0
var _biohazard_leak_position_sample_accumulator: float = 0.0
var _biohazard_leak_elapsed_seconds: float = 0.0
var _biohazard_recent_player_positions: Array = []
var _final_crisis_active: bool = false
var _final_containment_wave_elapsed_seconds: float = 0.0
var _containment_seal_active: bool = false
var _containment_seal_destroyed_count: int = 0
var _strain_bloom_elite_target: Node2D
var _strain_bloom_active: bool = false
var _strain_bloom_elite_killed: bool = false
var _strain_bloom_crisis_id: String = ""
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
var _mass_biomass_collect_active: bool = false
var _final_crisis_intro_popup_shown: bool = false
var _run_intro_popup_shown: bool = false
var _run_score_value: int = 0
var _best_score_value: int = 0
var _score_enemy_points: int = 0
var _score_level_points: int = 0
var _score_event_points: int = 0
var _score_bonus_points: int = 0
var _score_event_clear_count: int = 0
var _score_record_written: bool = false
var _score_history_entries: Array[Dictionary] = []
var _final_victory_sequence_active: bool = false
var _final_victory_resolution_started: bool = false
var _cached_biomass_pickup_base_radius: float = -1.0
var _postprocess_shader_material: ShaderMaterial
var _selected_difficulty_id: String = "medium"
var _enemy_difficulty_speed_multiplier: float = 1.0
var _enemy_difficulty_hp_multiplier: float = 1.0
var _enemy_difficulty_damage_multiplier: float = 1.0
var _variant_cast_cooldown_left: float = 0.0
var _parasitic_siphon_time_left: float = 0.0
var _parasitic_siphon_tick_left: float = 0.0
var _parasitic_siphon_sfx_cooldown_left: float = 0.0
var _variant_cast_hud_icon_variant_id: String = ""
var _parasitic_siphon_beam_frames: SpriteFrames
var _parasitic_siphon_beam_animation: StringName = &"default"
var _parasitic_siphon_beam_frame_size: Vector2 = Vector2(128.0, 128.0)
var _parasitic_siphon_beam_template_scale: Vector2 = Vector2.ONE
var _has_parasitic_siphon_beam_template: bool = false
@export var debug_allow_grant_xp: bool = false
@export var debug_grant_xp_amount: int = 20
@export var biomass_xp_multiplier: float = 1.35
@export var elite_biomass_xp_bonus: int = 6
@export var score_time_linear_per_second: float = 8.0
@export var score_time_quadratic_per_second: float = 0.16
@export var score_enemy_kill_base_points: int = 24
@export var score_elite_kill_base_points: int = 110
@export var score_enemy_time_multiplier_per_second: float = 0.004
@export var score_enemy_level_multiplier_per_level: float = 0.055
@export var score_levelup_base_points: int = 90
@export var score_levelup_curve_exponent: float = 1.30
@export var score_event_clear_base_points: int = 260
@export var score_event_clear_growth: float = 1.32
@export var score_victory_bonus_points: int = 2500
@export var debug_fast_forward_seconds: float = 10.0
@export var debug_log_crisis_timeline: bool = true
@export var debug_log_tag_synergies: bool = true
@export var debug_show_crisis_banner: bool = true
@export var enable_tag_synergies: bool = true
@export var synergy_popup_enabled: bool = true
@export var synergy_popup_duration_seconds: float = 4.8
@export var synergy_popup_fade_seconds: float = 0.36
@export var runtime_popup_top_offset: float = 150.0
@export var variant_cast_keycode: int = KEY_Q
@export var variant_cast_cooldown_seconds: float = 10.0
@export var variant_cast_overlay_max_alpha: float = 0.78
@export var variant_cast_icon_dim_alpha_on_cooldown: float = 0.56
@export var variant_cast_decimal_display_threshold_seconds: float = 5.0
@export var variant_cast_panel_spacing_from_inventory: float = 12.0
@export var variant_cast_scaling_target_level: int = 35
@export var lytic_cast_cooldown_level1_seconds: float = 15.0
@export var lytic_cast_cooldown_target_seconds: float = 3.0
@export var lytic_cast_dash_distance: float = 210.0
@export var lytic_cast_dash_distance_target: float = 520.0
@export var lytic_cast_dash_duration_seconds: float = 0.16
@export var lytic_cast_dash_duration_target_seconds: float = 0.22
@export var lytic_cast_dash_invulnerability_seconds: float = 0.42
@export var lytic_cast_dash_invulnerability_target_seconds: float = 0.68
@export var pandemic_cast_cooldown_level1_seconds: float = 15.0
@export var pandemic_cast_cooldown_target_seconds: float = 6.0
@export var pandemic_cast_camouflage_duration_seconds: float = 2.6
@export var pandemic_cast_camouflage_duration_target_seconds: float = 4.0
@export var pandemic_cast_camouflage_move_speed_multiplier: float = 1.12
@export var pandemic_cast_camouflage_move_speed_multiplier_target: float = 1.30
@export var parasitic_cast_cooldown_level1_seconds: float = 15.0
@export var parasitic_cast_cooldown_target_seconds: float = 5.5
@export var parasitic_cast_siphon_duration_seconds: float = 1.0
@export var parasitic_cast_siphon_duration_target_seconds: float = 2.4
@export var parasitic_cast_siphon_tick_interval_seconds: float = 0.33
@export var parasitic_cast_siphon_tick_interval_target_seconds: float = 0.16
@export var parasitic_cast_siphon_radius: float = 210.0
@export var parasitic_cast_siphon_radius_target: float = 360.0
@export var parasitic_cast_siphon_hit_all_nearby: bool = true
@export var parasitic_cast_siphon_max_targets: int = 4
@export var parasitic_cast_siphon_max_targets_target: int = 8
@export var parasitic_cast_siphon_damage_per_tick: int = 7
@export var parasitic_cast_siphon_damage_per_tick_target: int = 17
@export var parasitic_cast_siphon_heal_per_hit: int = 1
@export var parasitic_cast_siphon_heal_per_hit_target: int = 3
@export var parasitic_cast_siphon_elite_damage_multiplier: float = 0.60
@export var parasitic_cast_siphon_elite_damage_multiplier_target: float = 1.0
@export var parasitic_cast_siphon_visual_max_beams: int = 18
@export var parasitic_cast_siphon_visual_duration_seconds: float = 0.17
@export var parasitic_cast_siphon_visual_beam_thickness_scale: float = 0.24
@export var parasitic_cast_siphon_visual_beam_start_offset: float = 18.0
@export var parasitic_cast_siphon_visual_beam_end_offset: float = 0.0
@export var parasitic_cast_siphon_visual_ring_width: float = 3.0
@export var parasitic_cast_siphon_visual_color: Color = Color(0.54, 1.0, 0.76, 0.92)
@export var parasitic_cast_siphon_sfx_interval_seconds: float = 0.24
@export var base_passive_regen_per_second: float = 1.0
@export var run_intro_popup_top_offset: float = 170.0
@export var final_crisis_intro_popup_enabled: bool = true
@export var run_intro_popup_enabled: bool = true
@export var run_intro_popup_duration_seconds: float = 8.0
@export var enable_crisis_ui_accents: bool = true
@export var enable_crisis_postprocess_tint: bool = true
@export var crisis_postprocess_base_tint: Color = Color(0.98, 1.0, 1.03, 1.0)
@export var crisis_postprocess_event_tint: Color = Color(1.08, 0.92, 0.93, 1.0)
@export var crisis_postprocess_active_tint_strength: float = 0.12
@export var crisis_postprocess_reward_tint_strength: float = 0.07
@export var crisis_postprocess_final_tint_strength: float = 0.18
@export var crisis_postprocess_breath_amplitude: float = 0.05
@export var crisis_postprocess_breath_speed_hz: float = 0.82
@export var crisis_spawn_wait_multiplier_active: float = 1.45
@export var containment_sweep_concurrent_count: int = 3
@export var containment_sweep_spacing: float = 220.0
@export var containment_sweep_contact_damage: int = 50
@export var containment_sweep_contact_cooldown_seconds: float = 0.45
@export var containment_sweep_base_speed_multiplier: float = 1.10
@export var containment_sweep_speed_multiplier_easy: float = 1.00
@export var containment_sweep_speed_multiplier_medium: float = 1.12
@export var containment_sweep_speed_multiplier_hard: float = 1.24
@export var final_containment_concurrent_count: int = 3
@export var final_containment_spacing: float = 220.0
@export var final_containment_wave_duration_seconds: float = 16.5
@export var final_containment_wave_interval_seconds: float = 6.0
@export var final_containment_pass_count: int = 2
@export var final_boss_name: String = "PROTOCOL OMEGA"
@export var final_boss_spawn_radius: float = 280.0
@export var final_boss_min_spawn_distance_to_player: float = 180.0
@export var final_boss_damage_multiplier_easy: float = 1.20
@export var final_boss_damage_multiplier_medium: float = 1.85
@export var final_boss_damage_multiplier_hard: float = 2.45
@export var final_boss_death_slowmo_scale: float = 0.22
@export var final_boss_death_victory_delay_seconds: float = 2.0
@export var biohazard_leak_initial_spawn_count: int = 2
@export var biohazard_leak_initial_spawn_bonus_easy: int = 0
@export var biohazard_leak_initial_spawn_bonus_medium: int = 1
@export var biohazard_leak_initial_spawn_bonus_hard: int = 2
@export var biohazard_leak_spawn_interval_seconds: float = 0.72
@export var biohazard_leak_spawn_interval_multiplier_easy: float = 1.0
@export var biohazard_leak_spawn_interval_multiplier_medium: float = 0.82
@export var biohazard_leak_spawn_interval_multiplier_hard: float = 0.68
@export var final_biohazard_spawn_interval_multiplier: float = 0.70
@export var final_biohazard_max_active_bonus: int = 8
@export var biohazard_leak_player_position_sample_interval_seconds: float = 0.20
@export var biohazard_leak_player_position_history_seconds: float = 10.0
@export var biohazard_leak_player_position_min_age_seconds: float = 1.2
@export var biohazard_leak_max_active_zones: int = 36
@export var biohazard_leak_max_active_bonus_easy: int = 0
@export var biohazard_leak_max_active_bonus_medium: int = 8
@export var biohazard_leak_max_active_bonus_hard: int = 16
@export var biohazard_leak_min_distance_between_zones: float = 165.0
@export var biohazard_leak_spawn_resolve_attempts: int = 10
@export var biohazard_leak_prediction_strength: float = 0.70
@export var biohazard_leak_prediction_extra_lead_seconds: float = 0.25
@export var biohazard_leak_prediction_window_seconds: float = 2.4
@export var biohazard_leak_prediction_path_factor: float = 0.80
@export var biohazard_leak_target_attraction_weight: float = 0.22
@export var biohazard_leak_collision_radius: float = 94.0
@export var biohazard_leak_damage_tick_amount: int = 7
@export var biohazard_leak_damage_tick_interval_seconds: float = 0.2
@export var biohazard_leak_telegraph_duration_min: float = 0.45
@export var biohazard_leak_telegraph_duration_max: float = 0.95
@export var strain_bloom_elite_spawn_radius_min: float = 180.0
@export var strain_bloom_elite_spawn_radius_max: float = 280.0
@export var strain_bloom_elite_speed_multiplier: float = 1.45
@export var strain_bloom_elite_hp_multiplier: float = 15.0
@export var strain_bloom_first_elite_hp_ratio: float = 0.3333
@export var strain_bloom_elite_damage_multiplier: float = 4.0
@export var strain_bloom_elite_scale_multiplier: float = 2.0
@export var strain_bloom_elite_tint: Color = Color(0.62, 1.0, 0.22, 1.0)
@export var antiviral_drone_wave_count: int = 4
@export var containment_seal_pylon_count: int = 3
@export var containment_seal_pylon_spawn_radius_min: float = 200.0
@export var containment_seal_pylon_spawn_radius_max: float = 340.0
@export var containment_seal_fail_if_objective_alive: bool = true
@export var genome_cache_spawn_initial_delay_seconds: float = 70.0
@export var genome_cache_spawn_interval_seconds: float = 60.0
@export var genome_cache_spawn_interval_random_seconds: float = 5.0
@export var genome_cache_spawn_interval_random_ratio_cap: float = 0.20
@export var genome_cache_max_active_count: int = 1
@export var genome_cache_max_spawns_per_run: int = 7
@export var genome_cache_spawn_radius_min: float = 200.0
@export var genome_cache_spawn_radius_max: float = 360.0
@export var genome_cache_spawn_attempts: int = 10
@export var genome_cache_spawn_margin_from_bounds: float = 32.0
@export var containment_pylon_arrow_color: Color = Color(1.0, 0.23, 0.18, 1.0)
@export var containment_pylon_arrow_ring_radius: float = 108.0
@export var containment_pylon_arrow_vertical_offset: float = -24.0
@export var containment_pylon_arrow_size: float = 22.0
@export var containment_pylon_arrow_pulse_speed: float = 6.8
@export var containment_pylon_arrow_min_alpha: float = 0.55
@export var containment_pylon_arrow_max_alpha: float = 0.98
@export var containment_pylon_arrow_z_index: int = 450
@export var use_background_sprite_for_arena_bounds: bool = true
@export var arena_world_center: Vector2 = Vector2(960.0, 540.0)
@export var arena_world_size: Vector2 = Vector2(2048.0, 2048.0)
@export var arena_player_border_overflow_margin: float = 16.0
@export var arena_camera_border_overflow_margin: float = 0.0

const LINEAGE_CHOICES: Array[String] = ["lytic", "pandemic", "parasitic"]

func _ready() -> void:
	_load_score_history()
	_reset_runtime_state()
	_load_run_difficulty_settings()
	GAMEPLAY_SETTINGS.apply_saved_fps_limit()
	_cache_postprocess_shader_material()
	_cache_parasitic_siphon_beam_template()

	if OS.has_feature("standalone") and not OS.has_feature("dev_cheats"):
		debug_allow_grant_xp = false

	_configure_world_camera_and_bounds()

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
	if mutation_system != null and mutation_system.has_method("get_mutation_level") and mutation_system.has_method("apply_mutation"):
		var proto_level: int = int(mutation_system.call("get_mutation_level", "proto_pulse"))
		if proto_level <= 0:
			mutation_system.call("apply_mutation", "proto_pulse")
	if mutation_system != null and mutation_system.has_signal("lineage_changed"):
		mutation_system.connect("lineage_changed", Callable(self, "_on_lineage_changed"))
	if mutation_system != null and mutation_system.has_signal("variant_changed"):
		mutation_system.connect("variant_changed", Callable(self, "_on_variant_changed"))
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
	_refresh_variant_cast_hud()
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
	_apply_difficulty_to_active_enemies()
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

func _configure_world_camera_and_bounds() -> void:
	if player == null:
		return
	var arena_bounds: Rect2 = _resolve_arena_world_bounds()
	var player_overflow_margin: float = maxf(0.0, arena_player_border_overflow_margin)
	var camera_overflow_margin: float = maxf(0.0, arena_camera_border_overflow_margin)
	var movement_bounds: Rect2 = arena_bounds.grow(player_overflow_margin)
	var camera_bounds: Rect2 = arena_bounds.grow(camera_overflow_margin)
	if player.has_method("set_world_movement_bounds"):
		player.call("set_world_movement_bounds", movement_bounds, true)
	if player.has_method("configure_follow_camera"):
		player.call("configure_follow_camera", camera_bounds, true)

func _resolve_arena_world_bounds() -> Rect2:
	var background_sprite: Sprite2D = arena_background_sprite
	if background_sprite == null:
		background_sprite = get_node_or_null("ArenaSprite")
	if background_sprite == null:
		background_sprite = get_node_or_null("Sprite2D")
	if use_background_sprite_for_arena_bounds and background_sprite != null and background_sprite.texture != null:
		var texture_size: Vector2 = background_sprite.texture.get_size()
		var sprite_scale_abs: Vector2 = background_sprite.scale.abs()
		var world_size: Vector2 = Vector2(texture_size.x * sprite_scale_abs.x, texture_size.y * sprite_scale_abs.y)
		if world_size.x > 1.0 and world_size.y > 1.0:
			var top_left: Vector2 = background_sprite.global_position
			if background_sprite.centered:
				top_left -= world_size * 0.5
			return Rect2(top_left, world_size)

	var fallback_size: Vector2 = Vector2(maxf(256.0, arena_world_size.x), maxf(256.0, arena_world_size.y))
	var fallback_top_left: Vector2 = arena_world_center - (fallback_size * 0.5)
	return Rect2(fallback_top_left, fallback_size)

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
	genome_cache_selection_active = false
	pending_genome_cache_prompt_count = 0
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
	_variant_cast_cooldown_left = 0.0
	_parasitic_siphon_time_left = 0.0
	_parasitic_siphon_tick_left = 0.0
	_parasitic_siphon_sfx_cooldown_left = 0.0
	_variant_cast_hud_icon_variant_id = ""
	if player != null and player.has_method("set_variant_cast_rooted"):
		player.call("set_variant_cast_rooted", false)
	_reset_score_runtime()
	_restore_global_time_scale()
	_final_victory_sequence_active = false
	_final_victory_resolution_started = false
	_clear_containment_sweep()
	_clear_biohazard_leaks()
	_clear_final_crisis_elites()
	_clear_protocol_omega_boss()
	_clear_antiviral_drones()
	_clear_containment_pylons()
	_clear_genome_cache_pods()
	_clear_strain_bloom_state()
	_containment_seal_active = false
	_containment_seal_destroyed_count = 0
	_genome_cache_spawned_count = 0
	_schedule_next_genome_cache_spawn(true)
	if crisis_director != null and crisis_director.has_method("reset_runtime_state"):
		crisis_director.call("reset_runtime_state")
	_apply_crisis_ui_accent("idle", "", 0.0)
	_set_boss_health_ui_visible(false)
	_sync_player_level_spell_scaling()
	_refresh_run_inventory_ui()

func _reset_score_runtime() -> void:
	_run_score_value = 0
	_score_enemy_points = 0
	_score_level_points = 0
	_score_event_points = 0
	_score_bonus_points = 0
	_score_event_clear_count = 0
	_score_record_written = false
	_recalculate_run_score()

func _recalculate_run_score() -> void:
	var safe_elapsed_seconds: float = maxf(0.0, elapsed_seconds)
	var time_points_float: float = (safe_elapsed_seconds * score_time_linear_per_second) + (safe_elapsed_seconds * safe_elapsed_seconds * score_time_quadratic_per_second)
	var time_points: int = maxi(0, int(round(time_points_float)))
	_run_score_value = maxi(0, time_points + _score_enemy_points + _score_level_points + _score_event_points + _score_bonus_points)

func _add_enemy_score(is_elite_enemy: bool) -> void:
	var base_points: int = score_enemy_kill_base_points
	if is_elite_enemy:
		base_points = score_elite_kill_base_points
	var elapsed_multiplier: float = 1.0 + (maxf(0.0, elapsed_seconds) * maxf(0.0, score_enemy_time_multiplier_per_second))
	var level_multiplier: float = 1.0 + (float(maxi(0, level_reached - 1)) * maxf(0.0, score_enemy_level_multiplier_per_level))
	var gained_points: int = maxi(1, int(round(float(base_points) * elapsed_multiplier * level_multiplier)))
	_score_enemy_points += gained_points
	_recalculate_run_score()

func _add_levelup_score(current_level: int) -> void:
	if current_level <= 1:
		return
	var level_curve_exponent: float = maxf(1.0, score_levelup_curve_exponent)
	var gained_points: int = maxi(1, int(round(float(score_levelup_base_points) * pow(float(current_level), level_curve_exponent))))
	_score_level_points += gained_points
	_recalculate_run_score()

func _add_event_clear_score() -> void:
	_score_event_clear_count += 1
	var growth_multiplier: float = pow(maxf(1.0, score_event_clear_growth), float(maxi(0, _score_event_clear_count - 1)))
	var gained_points: int = maxi(1, int(round(float(score_event_clear_base_points) * growth_multiplier)))
	_score_event_points += gained_points
	_recalculate_run_score()

func _add_victory_score_bonus() -> void:
	_score_bonus_points += maxi(0, score_victory_bonus_points)
	_recalculate_run_score()

func _load_score_history() -> void:
	_score_history_entries.clear()
	_best_score_value = 0
	if not FileAccess.file_exists(SCORE_HISTORY_FILE_PATH):
		return
	var score_file: FileAccess = FileAccess.open(SCORE_HISTORY_FILE_PATH, FileAccess.READ)
	if score_file == null:
		return
	var raw_json: String = score_file.get_as_text()
	score_file.close()
	if raw_json.strip_edges().is_empty():
		return
	var parsed_variant: Variant = JSON.parse_string(raw_json)
	if not (parsed_variant is Dictionary):
		return
	var parsed_data: Dictionary = parsed_variant as Dictionary
	_best_score_value = maxi(0, int(parsed_data.get("best_score", 0)))
	var history_variant: Variant = parsed_data.get("history", [])
	if history_variant is Array:
		for entry_variant in history_variant:
			if not (entry_variant is Dictionary):
				continue
			var entry_data: Dictionary = entry_variant as Dictionary
			var score_value: int = maxi(0, int(entry_data.get("score", 0)))
			var time_seconds_value: int = maxi(0, int(entry_data.get("time_seconds", 0)))
			var level_value: int = maxi(1, int(entry_data.get("level", 1)))
			var variant_name: String = String(entry_data.get("variant", "None"))
			var result_tag: String = String(entry_data.get("result", "defeat"))
			var reason_text: String = String(entry_data.get("reason", ""))
			var timestamp_unix: int = int(entry_data.get("timestamp_unix", 0))
			_score_history_entries.append({
				"score": score_value,
				"time_seconds": time_seconds_value,
				"level": level_value,
				"variant": variant_name,
				"result": result_tag,
				"reason": reason_text,
				"timestamp_unix": timestamp_unix
			})
	_score_history_entries.sort_custom(Callable(self, "_sort_score_entry_descending"))
	while _score_history_entries.size() > SCORE_HISTORY_MAX_ENTRIES:
		_score_history_entries.remove_at(_score_history_entries.size() - 1)
	if not _score_history_entries.is_empty():
		_best_score_value = maxi(_best_score_value, int(_score_history_entries[0].get("score", 0)))

func _save_score_history() -> void:
	var payload: Dictionary = {
		"version": 1,
		"best_score": _best_score_value,
		"history": _score_history_entries
	}
	var score_file: FileAccess = FileAccess.open(SCORE_HISTORY_FILE_PATH, FileAccess.WRITE)
	if score_file == null:
		return
	score_file.store_string(JSON.stringify(payload, "\t"))
	score_file.close()

func _sort_score_entry_descending(a: Dictionary, b: Dictionary) -> bool:
	return int(a.get("score", 0)) > int(b.get("score", 0))

func _finalize_run_score_record(result_tag: String, reason_text: String = "") -> void:
	if _score_record_written:
		return
	_score_record_written = true
	_recalculate_run_score()
	_score_history_entries.append({
		"score": _run_score_value,
		"time_seconds": int(elapsed_seconds),
		"level": maxi(1, level_reached),
		"variant": _get_current_lineage_name(),
		"result": result_tag,
		"reason": reason_text.strip_edges(),
		"timestamp_unix": int(Time.get_unix_time_from_system())
	})
	_score_history_entries.sort_custom(Callable(self, "_sort_score_entry_descending"))
	while _score_history_entries.size() > SCORE_HISTORY_MAX_ENTRIES:
		_score_history_entries.remove_at(_score_history_entries.size() - 1)
	_best_score_value = maxi(_best_score_value, _run_score_value)
	_save_score_history()

func _get_highest_score_value() -> int:
	return _best_score_value

func _format_score_value(score_value: int) -> String:
	var clamped_value: int = maxi(0, score_value)
	var raw_text: String = str(clamped_value)
	var grouped: String = ""
	var digit_count: int = 0
	for index in range(raw_text.length() - 1, -1, -1):
		grouped = raw_text[index] + grouped
		digit_count += 1
		if digit_count == 3 and index > 0:
			grouped = "," + grouped
			digit_count = 0
	return grouped

func _load_run_difficulty_settings() -> void:
	_selected_difficulty_id = GAMEPLAY_SETTINGS.load_difficulty_id()
	var difficulty_data: Dictionary = GAMEPLAY_SETTINGS.get_difficulty_data(_selected_difficulty_id)
	_enemy_difficulty_speed_multiplier = maxf(0.1, float(difficulty_data.get("enemy_speed_multiplier", 1.0)))
	_enemy_difficulty_hp_multiplier = maxf(0.1, float(difficulty_data.get("enemy_hp_multiplier", 1.0)))
	_enemy_difficulty_damage_multiplier = maxf(0.1, float(difficulty_data.get("enemy_damage_multiplier", 1.0)))

func _apply_difficulty_to_active_enemies() -> void:
	var visited_enemy_ids: Dictionary = {}
	var groups_to_scan: Array[String] = ["enemies", "hostile_enemies", "boss_enemies"]
	for group_name in groups_to_scan:
		for enemy_variant in get_tree().get_nodes_in_group(group_name):
			var enemy_node := enemy_variant as Node
			if enemy_node == null or not is_instance_valid(enemy_node):
				continue
			var enemy_id: int = enemy_node.get_instance_id()
			if visited_enemy_ids.has(enemy_id):
				continue
			visited_enemy_ids[enemy_id] = true
			_apply_enemy_difficulty_to_node(enemy_node)

func _apply_enemy_difficulty_to_node(enemy_node: Node) -> void:
	if enemy_node == null or not is_instance_valid(enemy_node):
		return
	if not enemy_node.has_method("apply_difficulty_multipliers"):
		return
	enemy_node.call(
		"apply_difficulty_multipliers",
		_enemy_difficulty_speed_multiplier,
		_enemy_difficulty_hp_multiplier,
		_enemy_difficulty_damage_multiplier
	)

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
	if crisis_director.has_signal("final_crisis_failed"):
		var final_failed_callable := Callable(self, "_on_final_crisis_failed")
		if not crisis_director.is_connected("final_crisis_failed", final_failed_callable):
			crisis_director.connect("final_crisis_failed", final_failed_callable)

	_set_crisis_spawn_throttle(false)

func _tick_crisis_director(delta: float) -> void:
	if crisis_director == null:
		return
	if not crisis_director.has_method("tick"):
		return
	crisis_director.call("tick", delta, elapsed_seconds)

func _on_crisis_phase_changed(new_phase: String, crisis_id: String) -> void:
	var crisis_active: bool = (new_phase == "active" or new_phase == "final")
	var is_final_purge_phase: bool = (new_phase == "final" and crisis_id == "protocol_omega_core")
	_set_crisis_spawn_throttle(crisis_active)
	_apply_crisis_ui_accent(new_phase, crisis_id, _get_crisis_phase_time_remaining())
	if new_phase == "reward" and _is_elite_objective_crisis(crisis_id):
		_handle_strain_bloom_timeout()
	if new_phase == "reward" and crisis_id == "containment_seal":
		_handle_containment_seal_timeout()
	if _strain_bloom_active and crisis_id != _strain_bloom_crisis_id:
		_clear_strain_bloom_state()
	if _final_crisis_active and not is_final_purge_phase:
		_stop_final_crisis_composition()
	if not (_is_sweep_crisis(crisis_id) or is_final_purge_phase):
		_clear_containment_sweep()
	if not (_is_leak_crisis(crisis_id) or is_final_purge_phase):
		_clear_biohazard_leaks()
	if not (_is_antiviral_drone_crisis(crisis_id) or is_final_purge_phase):
		_clear_antiviral_drones()
	if not (_is_containment_seal_crisis(crisis_id) or is_final_purge_phase):
		_clear_containment_pylons()
	_update_crisis_debug_banner()

	if not debug_log_crisis_timeline:
		return
	if crisis_id.is_empty():
		print("[GameManager] Event phase -> %s at %.1fs" % [new_phase, elapsed_seconds])
	else:
		print("[GameManager] Event phase -> %s (%s) at %.1fs" % [new_phase, crisis_id, elapsed_seconds])

func _is_sweep_crisis(crisis_id: String) -> bool:
	return crisis_id == "uv_sweep_grid" or crisis_id == "quarantine_lattice" or crisis_id == "containment_seal"

func _is_leak_crisis(crisis_id: String) -> bool:
	return crisis_id == "decon_flood"

func _is_elite_objective_crisis(crisis_id: String) -> bool:
	return crisis_id == "hunter_deployment" or crisis_id == "containment_warden"

func _is_biomass_bonus_crisis(crisis_id: String) -> bool:
	return BIOMASS_BONUS_CRISIS_IDS.has(crisis_id)

func _is_antiviral_drone_crisis(crisis_id: String) -> bool:
	return crisis_id == "antiviral_drone_burst"

func _is_containment_seal_crisis(crisis_id: String) -> bool:
	return crisis_id == "containment_seal"

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

func _start_final_crisis_composition(_active_duration_seconds: float) -> void:
	_final_crisis_active = true
	_final_containment_wave_elapsed_seconds = 0.0
	_clear_final_crisis_elites()
	_clear_protocol_omega_boss()
	_clear_biohazard_leaks()
	_spawn_protocol_omega_boss()
	_play_sfx("sfx_boss_phase_shift", -3.0, randf_range(0.96, 1.04))
	_spawn_containment_sweep(
		maxf(1.0, final_containment_wave_duration_seconds),
		maxi(1, final_containment_concurrent_count),
		maxf(40.0, final_containment_spacing),
		maxi(1, final_containment_pass_count)
	)
	if debug_log_crisis_timeline:
		print("[GameManager] Final composition armed: OMEGA boss + sweeps")

func _stop_final_crisis_composition() -> void:
	_final_crisis_active = false
	_final_containment_wave_elapsed_seconds = 0.0
	_clear_protocol_omega_boss()
	_clear_final_crisis_elites()

func _tick_final_crisis_layers(delta: float) -> void:
	if not _final_crisis_active:
		return
	if delta <= 0.0:
		return
	if not _is_protocol_omega_alive():
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

func _spawn_protocol_omega_boss() -> void:
	if _is_protocol_omega_alive():
		return

	var player_node := player as Node2D
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node == null:
		return

	var boss_node := PROTOCOL_OMEGA_BOSS_SCENE.instantiate() as Node2D
	if boss_node == null:
		return

	var arena_bounds: Rect2 = _resolve_arena_world_bounds()
	var safe_spawn_radius: float = maxf(80.0, final_boss_spawn_radius)
	var min_player_distance: float = maxf(20.0, final_boss_min_spawn_distance_to_player)
	var spawn_position: Vector2 = player_node.global_position + Vector2.RIGHT * safe_spawn_radius
	var found_spawn: bool = false

	var attempts_left: int = 18
	while attempts_left > 0:
		attempts_left -= 1
		var angle: float = randf() * TAU
		var candidate_position: Vector2 = player_node.global_position + Vector2.RIGHT.rotated(angle) * safe_spawn_radius
		var clamped_position: Vector2 = Vector2(
			clampf(candidate_position.x, arena_bounds.position.x + 48.0, arena_bounds.position.x + arena_bounds.size.x - 48.0),
			clampf(candidate_position.y, arena_bounds.position.y + 48.0, arena_bounds.position.y + arena_bounds.size.y - 48.0)
		)
		if clamped_position.distance_to(player_node.global_position) < min_player_distance:
			continue
		spawn_position = clamped_position
		found_spawn = true
		break

	if not found_spawn:
		spawn_position = Vector2(
			clampf(spawn_position.x, arena_bounds.position.x + 48.0, arena_bounds.position.x + arena_bounds.size.x - 48.0),
			clampf(spawn_position.y, arena_bounds.position.y + 48.0, arena_bounds.position.y + arena_bounds.size.y - 48.0)
		)

	var spawn_parent: Node = get_tree().current_scene
	if spawn_parent == null:
		spawn_parent = self
	spawn_parent.add_child(boss_node)
	boss_node.global_position = spawn_position
	_protocol_omega_boss_target = boss_node
	_protocol_omega_boss_phase = 1

	if boss_node.has_method("initialize_for_final_event"):
		boss_node.call("initialize_for_final_event", player_node, arena_bounds)
	if boss_node.has_signal("defeated"):
		var defeated_callable := Callable(self, "_on_protocol_omega_boss_defeated")
		if not boss_node.is_connected("defeated", defeated_callable):
			boss_node.connect("defeated", defeated_callable)
	if boss_node.has_signal("health_changed"):
		var health_callable := Callable(self, "_on_protocol_omega_boss_health_changed")
		if not boss_node.is_connected("health_changed", health_callable):
			boss_node.connect("health_changed", health_callable)
	if boss_node.has_signal("phase_changed"):
		var phase_callable := Callable(self, "_on_protocol_omega_boss_phase_changed")
		if not boss_node.is_connected("phase_changed", phase_callable):
			boss_node.connect("phase_changed", phase_callable)
	call_deferred("_apply_final_boss_difficulty_damage_bonus", boss_node)

	var boss_max_hp: int = 1
	if boss_node.has_method("get_max_hp"):
		boss_max_hp = maxi(1, int(boss_node.call("get_max_hp")))
	_on_protocol_omega_boss_health_changed(boss_max_hp, boss_max_hp)
	_set_boss_health_ui_visible(true)

func _apply_final_boss_difficulty_damage_bonus(boss_node: Node2D) -> void:
	if boss_node == null:
		return
	if not is_instance_valid(boss_node):
		return
	if not boss_node.has_method("apply_final_boss_damage_bonus"):
		return
	var damage_multiplier: float = _get_final_boss_damage_bonus_for_selected_difficulty()
	boss_node.call("apply_final_boss_damage_bonus", damage_multiplier)

func _get_final_boss_damage_bonus_for_selected_difficulty() -> float:
	match _selected_difficulty_id:
		"easy":
			return maxf(0.1, final_boss_damage_multiplier_easy)
		"hard":
			return maxf(0.1, final_boss_damage_multiplier_hard)
		_:
			return maxf(0.1, final_boss_damage_multiplier_medium)

func _clear_protocol_omega_boss() -> void:
	if _protocol_omega_boss_target != null and is_instance_valid(_protocol_omega_boss_target):
		_protocol_omega_boss_target.queue_free()
	_protocol_omega_boss_target = null
	_protocol_omega_boss_phase = 1
	_set_boss_health_ui_visible(false)

func _is_protocol_omega_alive() -> bool:
	return _protocol_omega_boss_target != null and is_instance_valid(_protocol_omega_boss_target)

func _on_protocol_omega_boss_health_changed(current_hp: int, max_hp: int) -> void:
	if boss_health_bar != null:
		boss_health_bar.max_value = float(maxi(1, max_hp))
		boss_health_bar.value = float(clampi(current_hp, 0, maxi(1, max_hp)))
	if boss_name_label != null:
		boss_name_label.text = "BOSS: %s  (%d%%)" % [
			final_boss_name,
			int(round((float(clampi(current_hp, 0, maxi(1, max_hp))) / float(maxi(1, max_hp))) * 100.0))
		]

func _on_protocol_omega_boss_phase_changed(new_phase: int) -> void:
	_protocol_omega_boss_phase = clampi(new_phase, 1, 3)
	_queue_runtime_popup(
		"OMEGA PHASE %d" % _protocol_omega_boss_phase,
		"Containment routines intensified.",
		true,
		2.2,
		false,
		runtime_popup_top_offset + 96.0
	)

func _on_protocol_omega_boss_defeated(_world_position: Vector2, boss_node: Node2D) -> void:
	if boss_node != _protocol_omega_boss_target:
		return
	_protocol_omega_boss_target = null
	_set_boss_health_ui_visible(false)
	_final_victory_sequence_active = true
	_final_victory_resolution_started = false
	_set_global_time_scale(maxf(0.05, final_boss_death_slowmo_scale))
	_play_sfx("sfx_enemy_elite_death", -2.0, 0.92)
	if crisis_director != null and crisis_director.has_method("complete_final_crisis_early"):
		var completed: bool = bool(crisis_director.call("complete_final_crisis_early", "protocol_omega_core"))
		if completed:
			return
	_on_final_crisis_completed()

func _set_boss_health_ui_visible(should_show: bool) -> void:
	if boss_backdrop != null:
		boss_backdrop.visible = should_show
	if boss_icon != null:
		boss_icon.visible = should_show
	if boss_name_label != null:
		boss_name_label.visible = should_show
	if boss_health_bar != null:
		boss_health_bar.visible = should_show

func _set_global_time_scale(scale_value: float) -> void:
	Engine.time_scale = clampf(scale_value, 0.05, 1.0)

func _restore_global_time_scale() -> void:
	Engine.time_scale = 1.0

func _clear_final_crisis_elites() -> void:
	for elite_node in _final_crisis_elites:
		if elite_node == null:
			continue
		if not is_instance_valid(elite_node):
			continue
		elite_node.queue_free()
	_final_crisis_elites.clear()

func _spawn_antiviral_drone_wave(count: int) -> void:
	var spawn_count: int = maxi(0, count)
	if spawn_count <= 0:
		return
	var player_node := player as Node2D
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node == null:
		return

	for _spawn_index in range(spawn_count):
		var drone_node := ANTIVIRAL_DRONE_SCENE.instantiate() as Node2D
		if drone_node == null:
			continue
		var spawn_radius: float = randf_range(130.0, 320.0)
		var spawn_angle: float = randf() * TAU
		drone_node.global_position = player_node.global_position + Vector2.RIGHT.rotated(spawn_angle) * spawn_radius
		var spawn_parent: Node = get_tree().current_scene
		if spawn_parent == null:
			spawn_parent = self
		spawn_parent.add_child(drone_node)
		_connect_enemy_death(drone_node)
		_active_antiviral_drones.append(drone_node)

func _clear_antiviral_drones() -> void:
	for drone_node in _active_antiviral_drones:
		if drone_node == null:
			continue
		if not is_instance_valid(drone_node):
			continue
		drone_node.queue_free()
	_active_antiviral_drones.clear()

func _start_containment_seal_objective(crisis_id: String = "containment_seal") -> void:
	_clear_containment_pylons()
	_containment_seal_active = true
	_containment_seal_destroyed_count = 0

	var pylon_count: int = maxi(1, containment_seal_pylon_count)
	var player_node := player as Node2D
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node == null:
		return

	for pylon_index in range(pylon_count):
		var pylon_node := CONTAINMENT_PYLON_SCENE.instantiate() as Node2D
		if pylon_node == null:
			continue

		var ring_ratio: float = float(pylon_index) / float(maxi(1, pylon_count))
		var base_angle: float = ring_ratio * TAU
		var jitter: float = randf_range(-0.14, 0.14)
		var spawn_angle: float = base_angle + jitter
		var min_radius: float = maxf(80.0, containment_seal_pylon_spawn_radius_min)
		var max_radius: float = maxf(min_radius + 1.0, containment_seal_pylon_spawn_radius_max)
		var spawn_radius: float = randf_range(min_radius, max_radius)
		pylon_node.global_position = player_node.global_position + Vector2.RIGHT.rotated(spawn_angle) * spawn_radius

		var spawn_parent: Node = get_tree().current_scene
		if spawn_parent == null:
			spawn_parent = self
		spawn_parent.add_child(pylon_node)
		_active_containment_pylons.append(pylon_node)
		_connect_enemy_death(pylon_node)

		if pylon_node.has_signal("destroyed"):
			var destroyed_callable := Callable(self, "_on_containment_pylon_destroyed").bind(pylon_node, crisis_id)
			if not pylon_node.is_connected("destroyed", destroyed_callable):
				pylon_node.connect("destroyed", destroyed_callable)

func _on_containment_pylon_destroyed(
	_world_position: Vector2,
	_signal_pylon_node: Node,
	pylon_node: Node2D,
	crisis_id: String
) -> void:
	_containment_seal_destroyed_count += 1
	if pylon_node != null:
		_active_containment_pylons.erase(pylon_node)
		_remove_containment_pylon_arrow(pylon_node)
	_prune_containment_pylons()
	_update_crisis_debug_banner()
	if not _containment_seal_active:
		return
	if not _active_containment_pylons.is_empty():
		return
	if crisis_director == null:
		return
	if not crisis_director.has_method("complete_active_crisis_early"):
		return
	var completed: bool = bool(crisis_director.call("complete_active_crisis_early", crisis_id))
	if completed and debug_log_crisis_timeline:
		print("[GameManager] Containment Seal completed early by pylon destruction")

func _handle_containment_seal_timeout() -> void:
	if not _containment_seal_active:
		return
	_prune_containment_pylons()
	if containment_seal_fail_if_objective_alive and not _active_containment_pylons.is_empty():
		if debug_log_crisis_timeline:
			print("[GameManager] Containment Seal failed (pylons still active at timeout)")
		_fail_run_immediately("Containment seal objective failed")
	_clear_containment_pylons()
	_containment_seal_active = false

func _clear_containment_pylons() -> void:
	for pylon_node in _active_containment_pylons:
		if pylon_node == null:
			continue
		if not is_instance_valid(pylon_node):
			continue
		pylon_node.queue_free()
	_active_containment_pylons.clear()
	_clear_containment_pylon_arrows()
	_containment_seal_active = false
	_containment_seal_destroyed_count = 0

func _prune_containment_pylons() -> void:
	var active_pylon_ids: Dictionary = {}
	for idx in range(_active_containment_pylons.size() - 1, -1, -1):
		var pylon_node: Node2D = _active_containment_pylons[idx]
		if pylon_node == null or not is_instance_valid(pylon_node):
			_active_containment_pylons.remove_at(idx)
			continue
		active_pylon_ids[pylon_node.get_instance_id()] = true
	for arrow_id_variant in _containment_pylon_arrows.keys():
		var arrow_id: int = int(arrow_id_variant)
		if active_pylon_ids.has(arrow_id):
			continue
		var stale_arrow := _containment_pylon_arrows.get(arrow_id, null) as Node2D
		if stale_arrow != null and is_instance_valid(stale_arrow):
			stale_arrow.queue_free()
		_containment_pylon_arrows.erase(arrow_id)

func _get_active_containment_pylon_count() -> int:
	_prune_containment_pylons()
	return _active_containment_pylons.size()

func _schedule_next_genome_cache_spawn(use_initial_delay: bool = false) -> void:
	var base_delay_seconds: float = genome_cache_spawn_interval_seconds
	if use_initial_delay:
		base_delay_seconds = genome_cache_spawn_initial_delay_seconds
	base_delay_seconds = maxf(4.0, base_delay_seconds)
	var variance_seconds: float = maxf(0.0, genome_cache_spawn_interval_random_seconds)
	var random_ratio_cap: float = clampf(genome_cache_spawn_interval_random_ratio_cap, 0.0, 0.45)
	if random_ratio_cap > 0.0:
		variance_seconds = minf(variance_seconds, base_delay_seconds * random_ratio_cap)
	var jitter_seconds: float = 0.0
	if variance_seconds > 0.0:
		jitter_seconds = randf_range(-variance_seconds, variance_seconds)
	_genome_cache_next_spawn_time_seconds = elapsed_seconds + maxf(4.0, base_delay_seconds + jitter_seconds)

func _has_available_stat_upgrades_for_genome_cache() -> bool:
	if mutation_system == null:
		return false
	if not mutation_system.has_method("has_available_stat_upgrades"):
		return true
	return bool(mutation_system.call("has_available_stat_upgrades"))

func _tick_genome_cache_spawner(_delta: float) -> void:
	if run_ended:
		return
	if not _has_available_stat_upgrades_for_genome_cache():
		return

	_prune_genome_cache_pods()
	if _genome_cache_spawned_count >= maxi(0, genome_cache_max_spawns_per_run):
		return
	if elapsed_seconds < _genome_cache_next_spawn_time_seconds:
		return
	if _active_genome_cache_pods.size() >= maxi(1, genome_cache_max_active_count):
		return

	var spawned: bool = _spawn_genome_cache_pod()
	if not spawned:
		_genome_cache_next_spawn_time_seconds = elapsed_seconds + 6.0
		return
	_genome_cache_spawned_count += 1
	_schedule_next_genome_cache_spawn(false)

func _spawn_genome_cache_pod() -> bool:
	if GENOME_CACHE_POD_SCENE == null:
		return false

	var player_node := player as Node2D
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node == null:
		return false

	var cache_node := GENOME_CACHE_POD_SCENE.instantiate() as Node2D
	if cache_node == null:
		return false
	cache_node.global_position = _resolve_genome_cache_spawn_position(player_node)

	var spawn_parent: Node = get_tree().current_scene
	if spawn_parent == null:
		spawn_parent = self
	spawn_parent.add_child(cache_node)
	_active_genome_cache_pods.append(cache_node)

	if cache_node.has_signal("destroyed"):
		var destroyed_callable := Callable(self, "_on_genome_cache_pod_destroyed").bind(cache_node)
		if not cache_node.is_connected("destroyed", destroyed_callable):
			cache_node.connect("destroyed", destroyed_callable)

	_queue_runtime_popup(
		"GENOME CACHE DETECTED",
		"Destroy it to choose one stat-only adaptation.",
		true,
		3.2,
		false,
		runtime_popup_top_offset + 74.0
	)
	return true

func _resolve_genome_cache_spawn_position(player_node: Node2D) -> Vector2:
	var arena_bounds: Rect2 = _resolve_arena_world_bounds()
	var margin_value: float = maxf(0.0, genome_cache_spawn_margin_from_bounds)
	var min_x: float = arena_bounds.position.x + margin_value
	var max_x: float = arena_bounds.position.x + arena_bounds.size.x - margin_value
	var min_y: float = arena_bounds.position.y + margin_value
	var max_y: float = arena_bounds.position.y + arena_bounds.size.y - margin_value

	var min_radius: float = maxf(40.0, genome_cache_spawn_radius_min)
	var max_radius: float = maxf(min_radius + 1.0, genome_cache_spawn_radius_max)
	var attempts: int = maxi(1, genome_cache_spawn_attempts)
	var fallback_position: Vector2 = Vector2(
		clampf(player_node.global_position.x, min_x, max_x),
		clampf(player_node.global_position.y, min_y, max_y)
	)
	var best_position: Vector2 = fallback_position
	var best_distance_score: float = -INF
	for _attempt_index in range(attempts):
		var spawn_angle: float = randf() * TAU
		var spawn_radius: float = randf_range(min_radius, max_radius)
		var candidate_position: Vector2 = player_node.global_position + Vector2.RIGHT.rotated(spawn_angle) * spawn_radius
		candidate_position = Vector2(
			clampf(candidate_position.x, min_x, max_x),
			clampf(candidate_position.y, min_y, max_y)
		)

		var nearest_existing_dist_sq: float = INF
		for existing_cache in _active_genome_cache_pods:
			var existing_node := existing_cache as Node2D
			if existing_node == null or not is_instance_valid(existing_node):
				continue
			var dist_sq: float = candidate_position.distance_squared_to(existing_node.global_position)
			nearest_existing_dist_sq = minf(nearest_existing_dist_sq, dist_sq)
		if nearest_existing_dist_sq < 120.0 * 120.0:
			continue

		var distance_score: float = candidate_position.distance_squared_to(player_node.global_position)
		if distance_score > best_distance_score:
			best_distance_score = distance_score
			best_position = candidate_position

	return best_position

func _on_genome_cache_pod_destroyed(_world_position: Vector2, _signal_cache_node: Node, cache_node: Node2D) -> void:
	if cache_node != null:
		_active_genome_cache_pods.erase(cache_node)
	_prune_genome_cache_pods()

	var opened_prompt: bool = _open_genome_cache_prompt(true)
	if opened_prompt:
		return
	if not _has_available_stat_upgrades_for_genome_cache():
		_queue_runtime_popup(
			"GENOME CACHE",
			"All core stats are already maxed for this run.",
			true,
			2.8,
			false,
			runtime_popup_top_offset + 74.0
		)

func _clear_genome_cache_pods() -> void:
	for cache_variant in _active_genome_cache_pods:
		var cache_node := cache_variant as Node2D
		if cache_node == null:
			continue
		if not is_instance_valid(cache_node):
			continue
		cache_node.queue_free()
	_active_genome_cache_pods.clear()

func _prune_genome_cache_pods() -> void:
	for index in range(_active_genome_cache_pods.size() - 1, -1, -1):
		var cache_node := _active_genome_cache_pods[index] as Node2D
		if cache_node == null or not is_instance_valid(cache_node):
			_active_genome_cache_pods.remove_at(index)

func _tick_containment_pylon_arrows(delta: float) -> void:
	if not _containment_seal_active:
		_clear_containment_pylon_arrows()
		return
	_prune_containment_pylons()
	if _active_containment_pylons.is_empty():
		_clear_containment_pylon_arrows()
		return

	var player_node := player as Node2D
	if player_node == null:
		player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node == null:
		_clear_containment_pylon_arrows()
		return

	_containment_arrow_elapsed_seconds += maxf(0.0, delta)
	var ring_radius: float = maxf(24.0, containment_pylon_arrow_ring_radius)
	var vertical_offset: Vector2 = Vector2(0.0, containment_pylon_arrow_vertical_offset)
	var pulse: float = (sin(_containment_arrow_elapsed_seconds * containment_pylon_arrow_pulse_speed) + 1.0) * 0.5
	var alpha_value: float = lerpf(containment_pylon_arrow_min_alpha, containment_pylon_arrow_max_alpha, pulse)
	var scale_value: float = lerpf(0.92, 1.10, pulse)

	for pylon_node in _active_containment_pylons:
		if pylon_node == null or not is_instance_valid(pylon_node):
			continue
		var arrow_marker: Node2D = _get_or_create_containment_pylon_arrow(pylon_node)
		if arrow_marker == null or not is_instance_valid(arrow_marker):
			continue
		var direction: Vector2 = pylon_node.global_position - player_node.global_position
		if direction.length_squared() < 0.001:
			direction = Vector2.RIGHT
		var normalized_direction: Vector2 = direction.normalized()
		arrow_marker.global_position = player_node.global_position + normalized_direction * ring_radius + vertical_offset
		arrow_marker.rotation = normalized_direction.angle()
		arrow_marker.scale = Vector2.ONE * scale_value
		arrow_marker.modulate = Color(
			containment_pylon_arrow_color.r,
			containment_pylon_arrow_color.g,
			containment_pylon_arrow_color.b,
			clampf(alpha_value, 0.0, 1.0)
		)

func _get_or_create_containment_pylon_arrow(pylon_node: Node2D) -> Node2D:
	if pylon_node == null:
		return null
	var pylon_id: int = pylon_node.get_instance_id()
	if _containment_pylon_arrows.has(pylon_id):
		var existing_arrow := _containment_pylon_arrows.get(pylon_id, null) as Node2D
		if existing_arrow != null and is_instance_valid(existing_arrow):
			return existing_arrow

	var arrow_marker: Polygon2D = _build_containment_arrow_marker()
	add_child(arrow_marker)
	_containment_pylon_arrows[pylon_id] = arrow_marker
	return arrow_marker

func _build_containment_arrow_marker() -> Polygon2D:
	var arrow_marker := Polygon2D.new()
	var marker_size: float = maxf(8.0, containment_pylon_arrow_size)
	arrow_marker.polygon = PackedVector2Array([
		Vector2(marker_size, 0.0),
		Vector2(-marker_size * 0.52, marker_size * 0.44),
		Vector2(-marker_size * 0.12, 0.0),
		Vector2(-marker_size * 0.52, -marker_size * 0.44)
	])
	arrow_marker.color = containment_pylon_arrow_color
	arrow_marker.z_as_relative = false
	arrow_marker.z_index = containment_pylon_arrow_z_index
	return arrow_marker

func _remove_containment_pylon_arrow(pylon_node: Node2D) -> void:
	if pylon_node == null:
		return
	var pylon_id: int = pylon_node.get_instance_id()
	if not _containment_pylon_arrows.has(pylon_id):
		return
	var arrow_marker := _containment_pylon_arrows.get(pylon_id, null) as Node2D
	if arrow_marker != null and is_instance_valid(arrow_marker):
		arrow_marker.queue_free()
	_containment_pylon_arrows.erase(pylon_id)

func _clear_containment_pylon_arrows() -> void:
	for arrow_variant in _containment_pylon_arrows.values():
		var arrow_marker := arrow_variant as Node2D
		if arrow_marker == null:
			continue
		if not is_instance_valid(arrow_marker):
			continue
		arrow_marker.queue_free()
	_containment_pylon_arrows.clear()
	_containment_arrow_elapsed_seconds = 0.0

func _spawn_strain_bloom_elite(crisis_id: String = "hunter_deployment") -> void:
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

	_configure_strain_bloom_elite(elite_node, crisis_id)
	_connect_enemy_death(elite_node)
	_connect_strain_bloom_elite(elite_node)
	_strain_bloom_active = true
	_strain_bloom_elite_killed = false
	_strain_bloom_elite_target = elite_node
	_strain_bloom_crisis_id = crisis_id

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
	var expected_crisis_id: String = _strain_bloom_crisis_id
	var completed_early: bool = bool(crisis_director.call("complete_active_crisis_early", expected_crisis_id))
	if debug_log_crisis_timeline and completed_early:
		print("[GameManager] Elite objective completed early by elite kill (%s)" % expected_crisis_id)

func _handle_strain_bloom_timeout() -> void:
	if not _strain_bloom_active:
		return
	if _is_strain_bloom_elite_alive():
		if debug_log_crisis_timeline:
			print("[GameManager] Strain Bloom failed (elite alive at timeout)")
		_fail_run_immediately("Containment hunter objective failed")
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
	_strain_bloom_crisis_id = ""

func _configure_strain_bloom_elite(enemy_node: Node2D, crisis_id: String = "") -> void:
	if enemy_node == null:
		return

	var speed_multiplier: float = maxf(0.1, strain_bloom_elite_speed_multiplier)
	var hp_multiplier: float = maxf(0.1, strain_bloom_elite_hp_multiplier)
	if crisis_id == "hunter_deployment":
		var first_elite_ratio: float = clampf(strain_bloom_first_elite_hp_ratio, 0.1, 1.0)
		hp_multiplier = maxf(0.1, hp_multiplier * first_elite_ratio)
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
	var sweep_speed_multiplier: float = _get_containment_sweep_speed_multiplier_for_selected_difficulty()
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
		if sweep_node.has_method("set_runtime_speed_multiplier"):
			sweep_node.call("set_runtime_speed_multiplier", sweep_speed_multiplier)

		if sweep_node.has_method("begin_sweep"):
			sweep_node.call("begin_sweep", local_center, active_duration_seconds)

		var sweep_finished_callable := Callable(self, "_on_containment_sweep_finished").bind(sweep_node)
		if sweep_node.has_signal("sweep_finished") and not sweep_node.is_connected("sweep_finished", sweep_finished_callable):
			sweep_node.connect("sweep_finished", sweep_finished_callable)

		var player_contacted_callable := Callable(self, "_on_containment_sweep_player_contacted")
		if sweep_node.has_signal("player_contacted") and not sweep_node.is_connected("player_contacted", player_contacted_callable):
			sweep_node.connect("player_contacted", player_contacted_callable)

func _get_containment_sweep_speed_multiplier_for_selected_difficulty() -> float:
	var base_multiplier: float = maxf(0.1, containment_sweep_base_speed_multiplier)
	var difficulty_multiplier: float = 1.0
	match _selected_difficulty_id:
		"easy":
			difficulty_multiplier = maxf(0.1, containment_sweep_speed_multiplier_easy)
		"hard":
			difficulty_multiplier = maxf(0.1, containment_sweep_speed_multiplier_hard)
		_:
			difficulty_multiplier = maxf(0.1, containment_sweep_speed_multiplier_medium)
	return base_multiplier * difficulty_multiplier

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

	var initial_spawn_count: int = maxi(
		0,
		biohazard_leak_initial_spawn_count + _get_biohazard_initial_spawn_bonus_for_selected_difficulty()
	)
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
	max_active_zones += maxi(0, _get_biohazard_max_active_bonus_for_selected_difficulty())
	if _final_crisis_active:
		max_active_zones += maxi(0, final_biohazard_max_active_bonus)
	if _active_biohazard_leaks.size() >= max_active_zones:
		return

	_biohazard_leak_spawn_accumulator += delta
	var spawn_interval: float = maxf(0.05, biohazard_leak_spawn_interval_seconds)
	spawn_interval *= _get_biohazard_spawn_interval_multiplier_for_selected_difficulty()
	if _final_crisis_active:
		var final_interval_multiplier: float = clampf(final_biohazard_spawn_interval_multiplier, 0.15, 1.0)
		spawn_interval = maxf(0.05, spawn_interval * final_interval_multiplier)
	while _biohazard_leak_spawn_accumulator >= spawn_interval:
		_biohazard_leak_spawn_accumulator -= spawn_interval
		if _active_biohazard_leaks.size() >= max_active_zones:
			break
		_spawn_one_biohazard_leak(player_node)

func _get_biohazard_spawn_interval_multiplier_for_selected_difficulty() -> float:
	match _selected_difficulty_id:
		"easy":
			return clampf(biohazard_leak_spawn_interval_multiplier_easy, 0.25, 2.0)
		"hard":
			return clampf(biohazard_leak_spawn_interval_multiplier_hard, 0.25, 2.0)
		_:
			return clampf(biohazard_leak_spawn_interval_multiplier_medium, 0.25, 2.0)

func _get_biohazard_max_active_bonus_for_selected_difficulty() -> int:
	match _selected_difficulty_id:
		"easy":
			return maxi(0, biohazard_leak_max_active_bonus_easy)
		"hard":
			return maxi(0, biohazard_leak_max_active_bonus_hard)
		_:
			return maxi(0, biohazard_leak_max_active_bonus_medium)

func _get_biohazard_initial_spawn_bonus_for_selected_difficulty() -> int:
	match _selected_difficulty_id:
		"easy":
			return maxi(0, biohazard_leak_initial_spawn_bonus_easy)
		"hard":
			return maxi(0, biohazard_leak_initial_spawn_bonus_hard)
		_:
			return maxi(0, biohazard_leak_initial_spawn_bonus_medium)

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
	return phase_name == "active" and crisis_id == "decon_flood"

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
	_restore_global_time_scale()
	_final_victory_sequence_active = false
	_final_victory_resolution_started = false
	_pending_crisis_failure_audio = true
	_last_run_end_reason = _resolve_failure_reason(reason_text)
	if debug_log_crisis_timeline and not reason_text.is_empty():
		print("[GameManager] Event failure: %s at %.1fs" % [reason_text, elapsed_seconds])
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

	var show_crisis_banner: bool = true
	if crisis_debug_label == null:
		show_crisis_banner = false
	if not debug_show_crisis_banner:
		show_crisis_banner = false
	if crisis_director == null:
		show_crisis_banner = false
	elif not crisis_director.has_method("get_phase"):
		show_crisis_banner = false

	if crisis_backdrop != null:
		crisis_backdrop.visible = show_crisis_banner
	if crisis_debug_label == null:
		return
	if not show_crisis_banner:
		crisis_debug_label.visible = false
		return

	var timer_text: String = ""
	if phase_name == "idle":
		timer_text = "Next in %.1fs" % next_crisis_seconds
	else:
		timer_text = "T-%.1fs" % phase_seconds_remaining

	var objective_text: String = _get_crisis_objective_text(phase_name, crisis_id)
	crisis_debug_label.visible = true
	crisis_debug_label.text = "EVENT: %s | %s\nObjective: %s" % [
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
				"uv_sweep_grid":
					return "Evade flame sweeps - %d damage on contact" % maxi(1, containment_sweep_contact_damage)
				"hunter_deployment":
					if _is_strain_bloom_elite_alive():
						return "Kill elite before timer expires"
					if _strain_bloom_elite_killed:
						return "Elite down - hold until reward"
					return "Locate and eliminate elite variant"
				"decon_flood":
					return "Avoid leak zones - heavy damage over time"
				"quarantine_lattice":
					return "Navigate lattice sweeps and keep moving"
				"antiviral_drone_burst":
					return "Eliminate hunters while dodging burst lanes"
				"containment_seal":
					var pylons_remaining: int = _get_active_containment_pylon_count()
					var pylons_total: int = maxi(1, containment_seal_pylon_count)
					var pylons_destroyed: int = maxi(0, pylons_total - pylons_remaining)
					return "Destroy containment pylons (%d/%d)" % [pylons_destroyed, pylons_total]
				"containment_warden":
					return "Mid boss: eliminate the Warden (bonus: absorb all map biomass at reward)"
				_:
					return "Survive active event"
		"reward":
			if _is_biomass_bonus_crisis(crisis_id):
				return "Choose event reward, then absorb all map biomass as a bonus"
			return "Choose event reward"
		"final":
			if _is_protocol_omega_alive():
				return "Final boss: defeat Protocol OMEGA (%d%% HP)" % _get_protocol_omega_hp_percent()
			return "Final boss: OMEGA destabilized"
		"victory":
			return "Run clear - outbreak ascendant"
		_:
			return "--"

func _get_protocol_omega_hp_percent() -> int:
	if not _is_protocol_omega_alive():
		return 0
	var max_hp_value: int = 1
	if _protocol_omega_boss_target.has_method("get_max_hp"):
		max_hp_value = maxi(1, int(_protocol_omega_boss_target.call("get_max_hp")))
	var current_hp_value: int = max_hp_value
	if _protocol_omega_boss_target.has_method("get_current_hp"):
		current_hp_value = clampi(int(_protocol_omega_boss_target.call("get_current_hp")), 0, max_hp_value)
	return int(round((float(current_hp_value) / float(max_hp_value)) * 100.0))

func _get_crisis_accent_color(phase_name: String, crisis_id: String) -> Color:
	match phase_name:
		"idle":
			return Color(0.63, 0.78, 0.87, 1.0)
		"active":
			match crisis_id:
				"uv_sweep_grid":
					return Color(1.0, 0.58, 0.32, 1.0)
				"hunter_deployment":
					return Color(0.60, 1.0, 0.36, 1.0)
				"decon_flood":
					return Color(0.48, 1.0, 0.52, 1.0)
				"quarantine_lattice":
					return Color(0.72, 0.85, 1.0, 1.0)
				"antiviral_drone_burst":
					return Color(1.0, 0.72, 0.38, 1.0)
				"containment_seal":
					return Color(1.0, 0.52, 0.45, 1.0)
				"containment_warden":
					return Color(1.0, 0.30, 0.30, 1.0)
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
		_apply_crisis_postprocess_tint(phase_name, crisis_id, phase_seconds_remaining, 0.0)
		if timer_label != null:
			timer_label.remove_theme_color_override("font_color")
		if score_label != null:
			score_label.remove_theme_color_override("font_color")
		if timer_backdrop != null:
			timer_backdrop.self_modulate = Color(1, 1, 1, 1)
		if score_backdrop != null:
			score_backdrop.self_modulate = Color(1, 1, 1, 1)
		if crisis_debug_label != null:
			crisis_debug_label.remove_theme_color_override("font_color")
		if crisis_backdrop != null:
			crisis_backdrop.self_modulate = Color(1, 1, 1, 1)
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

	if timer_label != null:
		var timer_mix: float = 0.0
		if accent_strength > 0.001:
			timer_mix = minf(0.45, accent_strength + 0.05)
		var timer_font_color: Color = Color(1.0, 1.0, 1.0, 1.0).lerp(accent_color, timer_mix)
		timer_label.add_theme_color_override("font_color", timer_font_color)
	if score_label != null:
		var score_mix: float = 0.0
		if accent_strength > 0.001:
			score_mix = minf(0.45, accent_strength + 0.05)
		var score_font_color: Color = Color(1.0, 1.0, 1.0, 1.0).lerp(accent_color, score_mix)
		score_label.add_theme_color_override("font_color", score_font_color)
	if timer_backdrop != null:
		var timer_panel_mix: float = minf(0.25, accent_strength + 0.03)
		var timer_panel_modulate: Color = Color(1.0, 1.0, 1.0, 1.0).lerp(
			Color(
				lerpf(1.0, accent_color.r, 0.18),
				lerpf(1.0, accent_color.g, 0.18),
				lerpf(1.0, accent_color.b, 0.18),
				1.0
			),
			timer_panel_mix
		)
		timer_backdrop.self_modulate = timer_panel_modulate
	if score_backdrop != null:
		var score_panel_mix: float = minf(0.25, accent_strength + 0.03)
		var score_panel_modulate: Color = Color(1.0, 1.0, 1.0, 1.0).lerp(
			Color(
				lerpf(1.0, accent_color.r, 0.18),
				lerpf(1.0, accent_color.g, 0.18),
				lerpf(1.0, accent_color.b, 0.18),
				1.0
			),
			score_panel_mix
		)
		score_backdrop.self_modulate = score_panel_modulate

	if crisis_debug_label != null:
		var banner_font_color: Color = Color(0.95, 0.97, 1.0, 1.0).lerp(accent_color, 0.58)
		banner_font_color.a = 0.98
		crisis_debug_label.add_theme_color_override("font_color", banner_font_color)
	if crisis_backdrop != null:
		var crisis_panel_mix: float = minf(0.30, accent_strength + 0.05)
		var crisis_panel_modulate: Color = Color(1.0, 1.0, 1.0, 1.0).lerp(
			Color(
				lerpf(1.0, accent_color.r, 0.22),
				lerpf(1.0, accent_color.g, 0.22),
				lerpf(1.0, accent_color.b, 0.22),
				1.0
			),
			crisis_panel_mix
		)
		crisis_backdrop.self_modulate = crisis_panel_modulate
	_apply_crisis_postprocess_tint(phase_name, crisis_id, phase_seconds_remaining, accent_strength)

func _cache_postprocess_shader_material() -> void:
	_postprocess_shader_material = null
	if postprocess_overlay == null:
		return
	var shader_material := postprocess_overlay.material as ShaderMaterial
	if shader_material == null:
		return
	_postprocess_shader_material = shader_material
	_set_postprocess_tint(crisis_postprocess_base_tint)

func _set_postprocess_tint(tint_color: Color) -> void:
	if _postprocess_shader_material == null:
		return
	var tint_vector: Vector3 = Vector3(
		clampf(tint_color.r, 0.0, 2.0),
		clampf(tint_color.g, 0.0, 2.0),
		clampf(tint_color.b, 0.0, 2.0)
	)
	_postprocess_shader_material.set_shader_parameter("color_tint", tint_vector)

func _apply_crisis_postprocess_tint(phase_name: String, crisis_id: String, phase_seconds_remaining: float, ui_accent_strength: float) -> void:
	if _postprocess_shader_material == null:
		_cache_postprocess_shader_material()
	if _postprocess_shader_material == null:
		return
	if not enable_crisis_postprocess_tint:
		_set_postprocess_tint(crisis_postprocess_base_tint)
		return

	var target_tint_strength: float = 0.0
	var pulse_amplitude: float = 0.0
	match phase_name:
		"active":
			target_tint_strength = crisis_postprocess_active_tint_strength + (ui_accent_strength * 0.20)
			pulse_amplitude = crisis_postprocess_breath_amplitude
		"reward":
			target_tint_strength = crisis_postprocess_reward_tint_strength + (ui_accent_strength * 0.08)
			pulse_amplitude = crisis_postprocess_breath_amplitude * 0.45
		"final":
			target_tint_strength = crisis_postprocess_final_tint_strength + (ui_accent_strength * 0.22)
			pulse_amplitude = crisis_postprocess_breath_amplitude * 1.2
		_:
			target_tint_strength = 0.0
			pulse_amplitude = 0.0

	if (phase_name == "active" or phase_name == "final") and phase_seconds_remaining > 0.0 and phase_seconds_remaining <= 3.0:
		target_tint_strength += 0.03

	target_tint_strength = clampf(target_tint_strength, 0.0, 0.45)
	pulse_amplitude = clampf(pulse_amplitude, 0.0, 0.20)

	var pulse_strength: float = 0.0
	if pulse_amplitude > 0.0 and target_tint_strength > 0.0:
		var phase_offset: float = 0.0
		if not crisis_id.is_empty():
			phase_offset = float(abs(crisis_id.hash() % 360)) * 0.0174532925
		var pulse_speed_hz: float = maxf(0.05, crisis_postprocess_breath_speed_hz)
		pulse_strength = sin((elapsed_seconds * pulse_speed_hz * TAU) + phase_offset)

	var final_strength: float = target_tint_strength + (pulse_strength * pulse_amplitude * 0.5)
	final_strength = clampf(final_strength, 0.0, 0.48)
	var resolved_tint: Color = crisis_postprocess_base_tint.lerp(crisis_postprocess_event_tint, final_strength)
	_set_postprocess_tint(resolved_tint)

func _on_crisis_started(crisis_id: String, is_final: bool, duration_seconds: float) -> void:
	if is_final:
		_play_sfx("sfx_boss_spawn", -3.0, 0.82)
	else:
		_play_sfx("sfx_event_start", -6.0, 0.9)

	if is_final and crisis_id == "protocol_omega_core":
		_start_final_crisis_composition(duration_seconds)
		_play_music("bgm_boss_loop")
		if final_crisis_intro_popup_enabled and not _final_crisis_intro_popup_shown:
			_final_crisis_intro_popup_shown = true
			_queue_runtime_popup(
				"FINAL BOSS: OMEGA CORE",
				"Containment core engaged. Defeat Protocol OMEGA while surviving layered hazards.",
				true,
				-1.0,
				false,
				runtime_popup_top_offset + 60.0
			)
	if not is_final:
		match crisis_id:
			"uv_sweep_grid":
				_spawn_containment_sweep(duration_seconds, 4, maxf(120.0, containment_sweep_spacing * 0.88), 2)
			"hunter_deployment":
				_spawn_strain_bloom_elite(crisis_id)
			"decon_flood":
				_spawn_biohazard_leaks(duration_seconds)
			"quarantine_lattice":
				_spawn_containment_sweep(duration_seconds, 7, maxf(70.0, containment_sweep_spacing * 0.52), 4)
			"antiviral_drone_burst":
				_spawn_antiviral_drone_wave(maxi(2, antiviral_drone_wave_count))
				_spawn_containment_sweep(duration_seconds, 4, maxf(80.0, containment_sweep_spacing * 0.62), 3)
			"containment_seal":
				_spawn_containment_sweep(duration_seconds, 8, maxf(65.0, containment_sweep_spacing * 0.48), 4)
				_start_containment_seal_objective(crisis_id)
			"containment_warden":
				_spawn_strain_bloom_elite(crisis_id)
				_spawn_containment_sweep(duration_seconds, 6, maxf(80.0, containment_sweep_spacing * 0.58), 3)

	if not debug_log_crisis_timeline:
		return
	if is_final:
		print("[GameManager] Final event started: %s (%.1fs)" % [crisis_id, duration_seconds])
	else:
		print("[GameManager] Event started: %s (%.1fs)" % [crisis_id, duration_seconds])

func _on_crisis_reward_started(crisis_id: String, duration_seconds: float) -> void:
	if crisis_id == "decon_flood":
		_clear_biohazard_leaks()
		call_deferred("_verify_biohazard_cleanup")
	_add_event_clear_score()
	var reward_prompt_opened: bool = _open_crisis_reward_prompt(crisis_id)
	_play_sfx("sfx_event_clear", -4.5, 1.08)
	if not debug_log_crisis_timeline:
		return
	print("[GameManager] Event reward started: %s (%.1fs)" % [crisis_id, duration_seconds])
	if reward_prompt_opened:
		print("[GameManager] Reward prompt opened with %d options for %s" % [crisis_reward_options.size(), crisis_id])

func _on_final_crisis_completed() -> void:
	if run_ended:
		return
	if _final_victory_sequence_active:
		_start_final_victory_resolution_after_slowmo()
		return
	_finalize_victory_run()

func _start_final_victory_resolution_after_slowmo() -> void:
	if _final_victory_resolution_started:
		return
	_final_victory_resolution_started = true
	call_deferred("_resolve_final_victory_after_slowmo")

func _resolve_final_victory_after_slowmo() -> void:
	var delay_seconds: float = maxf(0.0, final_boss_death_victory_delay_seconds)
	if delay_seconds > 0.0:
		var slowmo_timer: SceneTreeTimer = get_tree().create_timer(delay_seconds, true, false, true)
		await slowmo_timer.timeout
	if run_ended:
		_restore_global_time_scale()
		return
	_finalize_victory_run()

func _finalize_victory_run() -> void:
	_restore_global_time_scale()
	_set_boss_health_ui_visible(false)
	_add_victory_score_bonus()
	_finalize_run_score_record("victory", "Protocol OMEGA neutralized")
	_end_run_common()
	_fade_out_music(1.1)
	_play_sfx("sfx_victory", 1.5, 1.0)
	_show_victory()
	if not debug_log_crisis_timeline:
		return
	print("[GameManager] Final event completed at %.1fs" % elapsed_seconds)

func _on_final_crisis_failed(crisis_id: String) -> void:
	if run_ended:
		return
	if crisis_id != "protocol_omega_core":
		return
	_restore_global_time_scale()
	_final_victory_sequence_active = false
	_final_victory_resolution_started = false
	_fail_run_immediately("Protocol OMEGA containment window expired")

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
	_refresh_variant_cast_hud()
	if run_ended:
		return
	if run_paused_for_menu:
		return
	if run_paused_for_levelup:
		return
	elapsed_seconds += delta
	_recalculate_run_score()
	_update_timer_label()
	_tick_reward_passive_regen(delta)
	_tick_variant_cast(delta)
	_refresh_variant_cast_hud()
	_tick_crisis_director(delta)
	_tick_biohazard_leak_spawner(delta)
	_tick_final_crisis_layers(delta)
	_tick_genome_cache_spawner(delta)
	_tick_containment_pylon_arrows(delta)
	_update_crisis_debug_banner()

func _get_total_bonus_regen_per_second() -> float:
	return maxf(0.0, base_passive_regen_per_second + _reward_passive_regen_per_second + _synergy_passive_regen_per_second)

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

func _tick_variant_cast(delta: float) -> void:
	_variant_cast_cooldown_left = maxf(0.0, _variant_cast_cooldown_left - delta)
	_parasitic_siphon_sfx_cooldown_left = maxf(0.0, _parasitic_siphon_sfx_cooldown_left - delta)
	if _parasitic_siphon_time_left <= 0.0:
		return

	var previous_channel_time: float = _parasitic_siphon_time_left
	_parasitic_siphon_time_left = maxf(0.0, _parasitic_siphon_time_left - delta)
	if previous_channel_time > 0.0 and _parasitic_siphon_time_left <= 0.0:
		if player != null and player.has_method("set_variant_cast_rooted"):
			player.call("set_variant_cast_rooted", false)
	_parasitic_siphon_tick_left -= delta
	if _parasitic_siphon_tick_left > 0.0:
		return

	_parasitic_siphon_tick_left = maxf(0.08, _get_parasitic_siphon_tick_interval_for_level())
	_apply_parasitic_siphon_tick()

func _try_cast_variant_ability() -> bool:
	if run_ended or run_paused_for_menu or run_paused_for_levelup:
		return false
	if crisis_reward_selection_active or lineage_selection_active or genome_cache_selection_active:
		return false
	if player == null:
		return false
	if _variant_cast_cooldown_left > 0.0:
		return false

	var variant_id: String = _get_current_variant_id_for_rewards()
	if variant_id.is_empty():
		return false

	var did_cast: bool = false
	match variant_id:
		"lytic":
			did_cast = _cast_lytic_variant_ability()
		"pandemic":
			did_cast = _cast_pandemic_variant_ability()
		"parasitic":
			did_cast = _cast_parasitic_variant_ability()
		_:
			did_cast = false

	if did_cast:
		_variant_cast_cooldown_left = _get_variant_cast_cooldown_for_variant(variant_id)
		_refresh_variant_cast_hud()
	return did_cast

func _cast_lytic_variant_ability() -> bool:
	if player == null:
		return false
	if not player.has_method("cast_variant_dash"):
		return false
	var player_node := player as Node2D
	var dash_direction: Vector2 = _resolve_lytic_dash_direction(player_node)
	return bool(
		player.call(
			"cast_variant_dash",
			dash_direction,
			maxf(24.0, _get_lytic_dash_distance_for_level()),
			maxf(0.04, _get_lytic_dash_duration_for_level()),
			maxf(0.0, _get_lytic_dash_invulnerability_for_level())
		)
	)

func _resolve_lytic_dash_direction(player_node: Node2D) -> Vector2:
	if player_node != null:
		var to_mouse: Vector2 = get_global_mouse_position() - player_node.global_position
		if to_mouse.length_squared() > 0.0001:
			return to_mouse.normalized()
	return _resolve_variant_cast_direction()

func _cast_pandemic_variant_ability() -> bool:
	if player == null:
		return false
	if not player.has_method("activate_variant_camouflage"):
		return false
	return bool(
		player.call(
			"activate_variant_camouflage",
			maxf(0.05, _get_pandemic_camouflage_duration_for_level()),
			maxf(1.0, _get_pandemic_camouflage_move_speed_multiplier_for_level())
		)
	)

func _cast_parasitic_variant_ability() -> bool:
	var safe_duration: float = maxf(0.1, _get_parasitic_siphon_duration_for_level())
	_parasitic_siphon_time_left = maxf(_parasitic_siphon_time_left, safe_duration)
	_parasitic_siphon_tick_left = 0.0
	if player != null and player.has_method("set_variant_cast_rooted"):
		player.call("set_variant_cast_rooted", true)
	return true

func _apply_parasitic_siphon_tick() -> void:
	var player_node := player as Node2D
	if player_node == null:
		return

	var safe_radius: float = maxf(24.0, _get_parasitic_siphon_radius_for_level())
	var safe_radius_sq: float = safe_radius * safe_radius
	var candidates: Array[Dictionary] = []
	for enemy_variant in get_tree().get_nodes_in_group("hostile_enemies"):
		var enemy_node := enemy_variant as Node2D
		if enemy_node == null:
			continue
		if not is_instance_valid(enemy_node):
			continue
		if enemy_node == player_node:
			continue
		var distance_sq: float = player_node.global_position.distance_squared_to(enemy_node.global_position)
		if distance_sq > safe_radius_sq:
			continue
		candidates.append({
			"node": enemy_node,
			"distance_sq": distance_sq
		})

	if candidates.is_empty():
		return

	candidates.sort_custom(Callable(self, "_sort_siphon_candidate_by_distance"))
	var target_count: int = candidates.size()
	if not parasitic_cast_siphon_hit_all_nearby:
		target_count = mini(candidates.size(), maxi(1, _get_parasitic_siphon_max_targets_for_level()))
	var base_damage: int = maxi(1, _get_parasitic_siphon_damage_per_tick_for_level())
	var elite_damage_multiplier: float = _get_parasitic_siphon_elite_multiplier_for_level()
	var heal_per_hit: int = maxi(0, _get_parasitic_siphon_heal_per_hit_for_level())
	var total_heal: int = 0
	var drained_targets: Array[Node2D] = []

	for i in range(target_count):
		var candidate: Dictionary = candidates[i]
		var target := candidate.get("node", null) as Node2D
		if target == null:
			continue
		if not target.has_method("take_damage"):
			continue

		var damage_to_apply: int = base_damage
		if _is_elite_or_boss_target(target):
			damage_to_apply = maxi(
				1,
				int(round(float(base_damage) * clampf(elite_damage_multiplier, 0.1, 1.5)))
			)
		target.call("take_damage", damage_to_apply)
		drained_targets.append(target)
		total_heal += heal_per_hit

	if total_heal > 0 and player_node.has_method("heal"):
		player_node.call("heal", total_heal)
	if not drained_targets.is_empty():
		_spawn_parasitic_siphon_visual(player_node.global_position, drained_targets, safe_radius)
		if _parasitic_siphon_sfx_cooldown_left <= 0.0:
			_play_sfx("sfx_leech_tendril_loop", -8.0, randf_range(0.96, 1.04))
			_parasitic_siphon_sfx_cooldown_left = maxf(0.08, parasitic_cast_siphon_sfx_interval_seconds)

func _sort_siphon_candidate_by_distance(a: Dictionary, b: Dictionary) -> bool:
	return float(a.get("distance_sq", INF)) < float(b.get("distance_sq", INF))

func _is_elite_or_boss_target(target: Node2D) -> bool:
	if target == null:
		return false
	if target == _protocol_omega_boss_target:
		return true
	if target.is_in_group("elite_enemies"):
		return true
	if target.has_method("is_elite_enemy"):
		return bool(target.call("is_elite_enemy"))
	return false

func _resolve_variant_cast_direction() -> Vector2:
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_direction.length_squared() > 0.0001:
		return input_direction.normalized()

	var player_node := player as Node2D
	if player_node == null:
		return Vector2.RIGHT

	var player_velocity_variant: Variant = player_node.get("velocity")
	if player_velocity_variant is Vector2:
		var player_velocity: Vector2 = player_velocity_variant
		if player_velocity.length_squared() > 0.0001:
			return player_velocity.normalized()

	var nearest_enemy: Node2D = _find_nearest_hostile_enemy(player_node.global_position, 520.0)
	if nearest_enemy != null:
		var to_enemy: Vector2 = nearest_enemy.global_position - player_node.global_position
		if to_enemy.length_squared() > 0.0001:
			return to_enemy.normalized()
	return Vector2.RIGHT

func _find_nearest_hostile_enemy(origin: Vector2, max_distance: float = 0.0) -> Node2D:
	var best_target: Node2D
	var best_distance_sq: float = INF
	var max_distance_sq: float = INF
	if max_distance > 0.0:
		max_distance_sq = max_distance * max_distance

	for enemy_variant in get_tree().get_nodes_in_group("hostile_enemies"):
		var enemy_node := enemy_variant as Node2D
		if enemy_node == null:
			continue
		if not is_instance_valid(enemy_node):
			continue
		var distance_sq: float = origin.distance_squared_to(enemy_node.global_position)
		if distance_sq > max_distance_sq:
			continue
		if distance_sq >= best_distance_sq:
			continue
		best_distance_sq = distance_sq
		best_target = enemy_node
	return best_target

func _get_variant_cast_level_progress() -> float:
	var target_level: int = maxi(2, variant_cast_scaling_target_level)
	var safe_level: int = maxi(1, level_reached)
	var denominator: float = float(target_level - 1)
	if denominator <= 0.0:
		return 1.0
	return clampf((float(safe_level) - 1.0) / denominator, 0.0, 1.0)

func _scale_variant_cast_float(level_one_value: float, target_level_value: float) -> float:
	return lerpf(level_one_value, target_level_value, _get_variant_cast_level_progress())

func _scale_variant_cast_int(level_one_value: int, target_level_value: int) -> int:
	return int(round(_scale_variant_cast_float(float(level_one_value), float(target_level_value))))

func _get_variant_cast_cooldown_for_variant(variant_id: String) -> float:
	match variant_id:
		"lytic":
			return maxf(0.1, _scale_variant_cast_float(lytic_cast_cooldown_level1_seconds, lytic_cast_cooldown_target_seconds))
		"pandemic":
			return maxf(0.1, _scale_variant_cast_float(pandemic_cast_cooldown_level1_seconds, pandemic_cast_cooldown_target_seconds))
		"parasitic":
			return maxf(0.1, _scale_variant_cast_float(parasitic_cast_cooldown_level1_seconds, parasitic_cast_cooldown_target_seconds))
		_:
			return maxf(0.1, variant_cast_cooldown_seconds)

func _get_lytic_dash_distance_for_level() -> float:
	return _scale_variant_cast_float(lytic_cast_dash_distance, lytic_cast_dash_distance_target)

func _get_lytic_dash_duration_for_level() -> float:
	return _scale_variant_cast_float(lytic_cast_dash_duration_seconds, lytic_cast_dash_duration_target_seconds)

func _get_lytic_dash_invulnerability_for_level() -> float:
	return _scale_variant_cast_float(lytic_cast_dash_invulnerability_seconds, lytic_cast_dash_invulnerability_target_seconds)

func _get_pandemic_camouflage_duration_for_level() -> float:
	return _scale_variant_cast_float(pandemic_cast_camouflage_duration_seconds, pandemic_cast_camouflage_duration_target_seconds)

func _get_pandemic_camouflage_move_speed_multiplier_for_level() -> float:
	return maxf(
		1.0,
		_scale_variant_cast_float(
			pandemic_cast_camouflage_move_speed_multiplier,
			pandemic_cast_camouflage_move_speed_multiplier_target
		)
	)

func _get_parasitic_siphon_duration_for_level() -> float:
	return _scale_variant_cast_float(parasitic_cast_siphon_duration_seconds, parasitic_cast_siphon_duration_target_seconds)

func _get_parasitic_siphon_tick_interval_for_level() -> float:
	return _scale_variant_cast_float(parasitic_cast_siphon_tick_interval_seconds, parasitic_cast_siphon_tick_interval_target_seconds)

func _get_parasitic_siphon_radius_for_level() -> float:
	return _scale_variant_cast_float(parasitic_cast_siphon_radius, parasitic_cast_siphon_radius_target)

func _get_parasitic_siphon_max_targets_for_level() -> int:
	return maxi(1, _scale_variant_cast_int(parasitic_cast_siphon_max_targets, parasitic_cast_siphon_max_targets_target))

func _get_parasitic_siphon_damage_per_tick_for_level() -> int:
	return maxi(1, _scale_variant_cast_int(parasitic_cast_siphon_damage_per_tick, parasitic_cast_siphon_damage_per_tick_target))

func _get_parasitic_siphon_heal_per_hit_for_level() -> int:
	return maxi(0, _scale_variant_cast_int(parasitic_cast_siphon_heal_per_hit, parasitic_cast_siphon_heal_per_hit_target))

func _get_parasitic_siphon_elite_multiplier_for_level() -> float:
	return _scale_variant_cast_float(
		parasitic_cast_siphon_elite_damage_multiplier,
		parasitic_cast_siphon_elite_damage_multiplier_target
	)

func _spawn_parasitic_siphon_visual(origin: Vector2, drained_targets: Array[Node2D], radius: float) -> void:
	if drained_targets.is_empty():
		return
	var visual_root := Node2D.new()
	visual_root.global_position = origin
	visual_root.z_index = -2
	add_child(visual_root)

	var beam_color: Color = parasitic_cast_siphon_visual_color
	var beam_count: int = mini(drained_targets.size(), maxi(1, parasitic_cast_siphon_visual_max_beams))
	for beam_index in range(beam_count):
		var target_node: Node2D = drained_targets[beam_index]
		if target_node == null or not is_instance_valid(target_node):
			continue
		var target_local: Vector2 = target_node.global_position - origin
		var total_distance: float = target_local.length()
		if total_distance <= 1.0:
			continue
		var direction: Vector2 = target_local / total_distance
		var start_offset: float = maxf(0.0, parasitic_cast_siphon_visual_beam_start_offset)
		var end_offset: float = maxf(0.0, parasitic_cast_siphon_visual_beam_end_offset)
		var beam_length: float = total_distance - start_offset - end_offset
		if beam_length <= 2.0:
			continue

		if _has_parasitic_siphon_beam_template:
			var beam_root := Node2D.new()
			beam_root.position = direction * start_offset
			beam_root.rotation = direction.angle()
			visual_root.add_child(beam_root)

			var beam_sprite: AnimatedSprite2D = _create_parasitic_siphon_beam_sprite()
			beam_root.add_child(beam_sprite)
			beam_sprite.modulate = beam_color
			var frame_width: float = maxf(1.0, _parasitic_siphon_beam_frame_size.x)
			var frame_height: float = maxf(1.0, _parasitic_siphon_beam_frame_size.y)
			var thickness_scale: float = maxf(0.02, parasitic_cast_siphon_visual_beam_thickness_scale)
			beam_sprite.position = Vector2.ZERO
			beam_sprite.offset = Vector2(0.0, -frame_height * 0.5)
			beam_sprite.scale = Vector2(
				(beam_length / frame_width) * _parasitic_siphon_beam_template_scale.x,
				thickness_scale * _parasitic_siphon_beam_template_scale.y
			)
		else:
			var beam_line := Line2D.new()
			beam_line.width = maxf(1.0, parasitic_cast_siphon_visual_beam_thickness_scale * 14.0)
			beam_line.default_color = beam_color
			beam_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
			beam_line.end_cap_mode = Line2D.LINE_CAP_ROUND
			beam_line.antialiased = true
			beam_line.add_point(direction * (start_offset + beam_length))
			beam_line.add_point(direction * start_offset)
			visual_root.add_child(beam_line)

	var ring_line := Line2D.new()
	ring_line.width = maxf(1.0, parasitic_cast_siphon_visual_ring_width)
	ring_line.default_color = Color(beam_color.r, beam_color.g, beam_color.b, beam_color.a * 0.72)
	ring_line.antialiased = true
	ring_line.closed = true
	var ring_radius: float = maxf(24.0, radius * 0.92)
	var ring_segments: int = 36
	for segment_index in range(ring_segments):
		var t: float = float(segment_index) / float(ring_segments)
		var angle: float = t * TAU
		ring_line.add_point(Vector2(cos(angle), sin(angle)) * ring_radius)
	visual_root.add_child(ring_line)

	visual_root.scale = Vector2(0.82, 0.82)
	var visual_duration: float = maxf(0.05, parasitic_cast_siphon_visual_duration_seconds)
	var fade_tween: Tween = create_tween()
	fade_tween.set_parallel(true)
	fade_tween.tween_property(visual_root, "scale", Vector2(1.06, 1.06), visual_duration)
	fade_tween.tween_property(visual_root, "modulate:a", 0.0, visual_duration)
	fade_tween.finished.connect(Callable(visual_root, "queue_free"))

func _cache_parasitic_siphon_beam_template() -> void:
	_has_parasitic_siphon_beam_template = false
	_parasitic_siphon_beam_frames = null
	_parasitic_siphon_beam_animation = &"default"
	_parasitic_siphon_beam_frame_size = Vector2(128.0, 128.0)
	_parasitic_siphon_beam_template_scale = Vector2.ONE
	if LEECH_TENDRIL_SCENE == null:
		return

	var template_root: Node = LEECH_TENDRIL_SCENE.instantiate()
	if template_root == null:
		return
	var beam_template: AnimatedSprite2D = template_root.get_node_or_null("BeamTemplate") as AnimatedSprite2D
	if beam_template != null and beam_template.sprite_frames != null:
		var template_frames: SpriteFrames = beam_template.sprite_frames.duplicate(true) as SpriteFrames
		if template_frames != null:
			_parasitic_siphon_beam_frames = template_frames
			_parasitic_siphon_beam_template_scale = beam_template.scale
			if template_frames.get_animation_names().size() > 0:
				_parasitic_siphon_beam_animation = template_frames.get_animation_names()[0]
			if template_frames.has_animation(_parasitic_siphon_beam_animation) and template_frames.get_frame_count(_parasitic_siphon_beam_animation) > 0:
				var first_frame: Texture2D = template_frames.get_frame_texture(_parasitic_siphon_beam_animation, 0)
				if first_frame != null:
					_parasitic_siphon_beam_frame_size = first_frame.get_size()
			_has_parasitic_siphon_beam_template = true

	template_root.free()

func _create_parasitic_siphon_beam_sprite() -> AnimatedSprite2D:
	var beam_sprite := AnimatedSprite2D.new()
	beam_sprite.centered = false
	beam_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	beam_sprite.modulate = parasitic_cast_siphon_visual_color
	if _parasitic_siphon_beam_frames != null:
		beam_sprite.sprite_frames = _parasitic_siphon_beam_frames
		if _parasitic_siphon_beam_frames.has_animation(_parasitic_siphon_beam_animation):
			beam_sprite.animation = _parasitic_siphon_beam_animation
			beam_sprite.play(_parasitic_siphon_beam_animation)
	return beam_sprite

func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event != null and key_event.pressed and not key_event.echo:
		if key_event.keycode == variant_cast_keycode:
			if _try_cast_variant_ability():
				get_viewport().set_input_as_handled()
				return
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
		if (key_event.keycode == KEY_J or key_event.keycode == KEY_L) and _can_use_debug_xp_cheat():
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
		_play_sfx("sfx_player_hit")
	_last_player_hp = current_hp

func _on_xp_changed(current_xp: int, xp_to_next_level: int) -> void:
	if xp_bar == null:
		return
	xp_bar.min_value = 0.0
	xp_bar.max_value = float(xp_to_next_level)
	xp_bar.value = float(current_xp)

func _on_level_changed(current_level: int) -> void:
	level_reached = current_level
	_add_levelup_score(current_level)
	_sync_player_level_spell_scaling()
	if level_label != null:
		level_label.text = "Level: %d" % current_level
	_update_timer_label()

func _sync_player_level_spell_scaling() -> void:
	if mutation_system == null:
		return
	if not mutation_system.has_method("set_runtime_player_level"):
		return
	mutation_system.call("set_runtime_player_level", maxi(1, level_reached))

func _on_lineage_changed(_lineage_id: String, _lineage_name: String) -> void:
	_refresh_lineage_labels()

func _on_variant_changed(_variant_id: String, _variant_name: String) -> void:
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
		lineage_label.text = "Variant: %s" % current_lineage_name

	_refresh_variant_cast_hud()
	_refresh_choice_panel_labels()

func _refresh_variant_cast_hud() -> void:
	if variant_cast_panel == null:
		return

	_layout_variant_cast_hud_panel()

	var variant_id: String = _get_current_variant_id_for_rewards()
	var has_variant: bool = not variant_id.is_empty()
	variant_cast_panel.visible = has_variant and not run_ended
	if not variant_cast_panel.visible and _inventory_tooltip_slot == variant_cast_panel:
		_hide_inventory_tooltip()
	if not has_variant:
		_variant_cast_hud_icon_variant_id = ""
		if _inventory_tooltip_slot == variant_cast_panel:
			_hide_inventory_tooltip()
		return

	if variant_cast_label != null:
		var key_text: String = _get_variant_cast_key_display()
		variant_cast_label.text = key_text

	if variant_id != _variant_cast_hud_icon_variant_id:
		_variant_cast_hud_icon_variant_id = variant_id
		var variant_icon: Texture2D = _get_variant_cast_icon_for_variant(variant_id)
		if variant_cast_icon != null:
			_apply_icon_template(variant_cast_icon, variant_icon, "lineage", ICON_TEMPLATE_INVENTORY_ICON_INSET)

	var safe_cooldown: float = _get_variant_cast_cooldown_for_variant(variant_id)
	var cooldown_ratio: float = clampf(_variant_cast_cooldown_left / safe_cooldown, 0.0, 1.0)
	var icon_alpha: float = lerpf(1.0, clampf(variant_cast_icon_dim_alpha_on_cooldown, 0.15, 1.0), cooldown_ratio)

	if variant_cast_icon != null:
		variant_cast_icon.modulate = Color(1.0, 1.0, 1.0, icon_alpha)

	if variant_cast_overlay != null and variant_cast_icon != null:
		var overlay_size: Vector2 = variant_cast_icon.size
		var top_fill_offset: float = overlay_size.y * (1.0 - cooldown_ratio)
		var overlay_color: Color = variant_cast_overlay.color
		overlay_color.a = clampf(variant_cast_overlay_max_alpha, 0.0, 1.0)
		variant_cast_overlay.color = overlay_color
		variant_cast_overlay.offset_top = top_fill_offset
		variant_cast_overlay.visible = cooldown_ratio > 0.001

	if variant_cast_state_label != null:
		if variant_id == "parasitic" and _parasitic_siphon_time_left > 0.001:
			variant_cast_state_label.text = "CHANNEL"
		elif _variant_cast_cooldown_left > 0.001:
			variant_cast_state_label.text = "COOLDOWN"
		else:
			variant_cast_state_label.text = "READY"

	if variant_cast_cooldown_label != null:
		if _variant_cast_cooldown_left > 0.001:
			if _variant_cast_cooldown_left <= maxf(0.1, variant_cast_decimal_display_threshold_seconds):
				variant_cast_cooldown_label.text = "%.1f" % _variant_cast_cooldown_left
			else:
				variant_cast_cooldown_label.text = "%d" % int(ceil(_variant_cast_cooldown_left))
		else:
			variant_cast_cooldown_label.text = ""

func _get_variant_cast_icon_for_variant(variant_id: String) -> Texture2D:
	match variant_id:
		"lytic":
			return VARIANT_CAST_ICON_LYTIC_DASH
		"pandemic":
			return VARIANT_CAST_ICON_PANDEMIC_CAMOUFLAGE
		"parasitic":
			return VARIANT_CAST_ICON_PARASITIC_SIPHON
		_:
			return null

func _get_variant_cast_key_display() -> String:
	var key_text: String = OS.get_keycode_string(variant_cast_keycode).strip_edges()
	if key_text.is_empty():
		key_text = "Q"
	return key_text

func _layout_variant_cast_hud_panel() -> void:
	if variant_cast_panel == null:
		return

	var panel_width: float = variant_cast_panel.offset_right - variant_cast_panel.offset_left
	if panel_width <= 1.0:
		panel_width = maxf(160.0, variant_cast_panel.get_combined_minimum_size().x)

	var panel_height: float = variant_cast_panel.offset_bottom - variant_cast_panel.offset_top
	if panel_height <= 1.0:
		panel_height = maxf(64.0, variant_cast_panel.get_combined_minimum_size().y)

	var desired_left: float = variant_cast_panel.offset_left
	var desired_top: float = variant_cast_panel.offset_top

	if run_inventory_bar != null:
		desired_left = run_inventory_bar.offset_left
		desired_top = run_inventory_bar.offset_top
		if run_inventory_rows != null:
			desired_top += run_inventory_rows.get_combined_minimum_size().y
		else:
			desired_top += run_inventory_bar.offset_bottom - run_inventory_bar.offset_top
		desired_top += maxf(0.0, variant_cast_panel_spacing_from_inventory)

	variant_cast_panel.offset_left = desired_left
	variant_cast_panel.offset_right = desired_left + panel_width
	variant_cast_panel.offset_top = desired_top
	variant_cast_panel.offset_bottom = desired_top + panel_height

func _refresh_choice_panel_labels() -> void:
	if levelup_title_label != null:
		if crisis_reward_selection_active:
			levelup_title_label.text = "EVENT REWARD"
		elif genome_cache_selection_active:
			levelup_title_label.text = "GENOME CACHE"
		else:
			levelup_title_label.text = "EVOLVE"

	if levelup_lineage_prompt_label != null:
		if crisis_reward_selection_active:
			levelup_lineage_prompt_label.text = "Choose one adaptation"
		elif genome_cache_selection_active:
			levelup_lineage_prompt_label.text = "Choose one stat adaptation"
		elif lineage_selection_active:
			levelup_lineage_prompt_label.text = "Choose your variant"
		else:
			levelup_lineage_prompt_label.text = "Choose your mutation or stat"

	if levelup_help_label != null:
		if crisis_reward_selection_active:
			if _is_biomass_bonus_crisis(active_crisis_reward_id):
				levelup_help_label.text = "Event bonus applies immediately. End bonus: absorb all map biomass."
			else:
				levelup_help_label.text = "Event bonus applies immediately for this run."
		elif genome_cache_selection_active:
			levelup_help_label.text = "Cache breach grants a stat-only boost."
		elif lineage_selection_active:
			levelup_help_label.text = "Choose once. It grants your starter spell and biases future options."
		else:
			levelup_help_label.text = "Gold titles indicate options aligned with your variant."

func _refresh_metabolism_hud() -> void:
	if metabolism_label == null:
		return
	metabolism_label.visible = false

func _build_inventory_slot_stylebox(slot_style_kind: String) -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	stylebox.border_width_left = 0
	stylebox.border_width_top = 0
	stylebox.border_width_right = 0
	stylebox.border_width_bottom = 0
	match slot_style_kind:
		"reward":
			stylebox.border_color = Color(0.86, 0.76, 0.42, 0.0)
		"synergy":
			stylebox.border_color = Color(0.56, 0.94, 0.76, 0.0)
		_:
			stylebox.border_color = Color(0.48, 0.80, 0.96, 0.0)
	stylebox.corner_radius_top_left = 6
	stylebox.corner_radius_top_right = 6
	stylebox.corner_radius_bottom_right = 6
	stylebox.corner_radius_bottom_left = 6
	return stylebox

func _get_icon_template_tint(template_kind: String) -> Color:
	match template_kind:
		"reward":
			return Color(1.0, 1.0, 1.0, 0.95)
		"synergy":
			return Color(1.0, 1.0, 1.0, 0.95)
		"lineage":
			return Color(0.76, 0.90, 1.0, 0.95)
		"favored":
			return Color(1.0, 0.90, 0.56, 0.95)
		_:
			return Color(0.84, 0.94, 1.0, 0.95)

func _ensure_icon_template_base(icon_rect: TextureRect) -> Dictionary:
	if icon_rect == null:
		return {}
	if icon_rect.has_meta(ICON_TEMPLATE_BASE_META_KEY):
		var existing_meta_variant: Variant = icon_rect.get_meta(ICON_TEMPLATE_BASE_META_KEY)
		if existing_meta_variant is Dictionary:
			return existing_meta_variant

	var base_data: Dictionary = {
		"anchor_left": icon_rect.anchor_left,
		"anchor_top": icon_rect.anchor_top,
		"anchor_right": icon_rect.anchor_right,
		"anchor_bottom": icon_rect.anchor_bottom,
		"offset_left": icon_rect.offset_left,
		"offset_top": icon_rect.offset_top,
		"offset_right": icon_rect.offset_right,
		"offset_bottom": icon_rect.offset_bottom,
		"grow_horizontal": icon_rect.grow_horizontal,
		"grow_vertical": icon_rect.grow_vertical
	}
	icon_rect.set_meta(ICON_TEMPLATE_BASE_META_KEY, base_data)
	return base_data

func _apply_icon_template_rect_from_base(icon_rect: TextureRect, base_data: Dictionary, inset: float) -> void:
	if icon_rect == null:
		return
	icon_rect.anchor_left = float(base_data.get("anchor_left", icon_rect.anchor_left))
	icon_rect.anchor_top = float(base_data.get("anchor_top", icon_rect.anchor_top))
	icon_rect.anchor_right = float(base_data.get("anchor_right", icon_rect.anchor_right))
	icon_rect.anchor_bottom = float(base_data.get("anchor_bottom", icon_rect.anchor_bottom))
	var grow_horizontal_value: int = int(base_data.get("grow_horizontal", int(icon_rect.grow_horizontal)))
	var grow_vertical_value: int = int(base_data.get("grow_vertical", int(icon_rect.grow_vertical)))
	icon_rect.grow_horizontal = grow_horizontal_value as Control.GrowDirection
	icon_rect.grow_vertical = grow_vertical_value as Control.GrowDirection
	icon_rect.offset_left = float(base_data.get("offset_left", icon_rect.offset_left)) + inset
	icon_rect.offset_top = float(base_data.get("offset_top", icon_rect.offset_top)) + inset
	icon_rect.offset_right = float(base_data.get("offset_right", icon_rect.offset_right)) - inset
	icon_rect.offset_bottom = float(base_data.get("offset_bottom", icon_rect.offset_bottom)) - inset

func _ensure_icon_background_for_rect(icon_rect: TextureRect) -> TextureRect:
	if icon_rect == null:
		return null
	var parent_control := icon_rect.get_parent() as Control
	if parent_control == null:
		return null

	var background_name: String = "%s%s" % [ICON_TEMPLATE_BG_NODE_PREFIX, icon_rect.name]
	var background_rect: TextureRect = parent_control.get_node_or_null(NodePath(background_name)) as TextureRect
	if background_rect == null:
		background_rect = TextureRect.new()
		background_rect.name = background_name
		background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		background_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		parent_control.add_child(background_rect)

	var icon_index: int = icon_rect.get_index()
	var background_index: int = background_rect.get_index()
	var target_index: int = icon_index
	if background_index < icon_index:
		target_index = maxi(0, icon_index - 1)
	parent_control.move_child(background_rect, target_index)
	return background_rect

func _apply_icon_template(
	icon_rect: TextureRect,
	icon_texture: Texture2D,
	template_kind: String,
	icon_inset: float,
	background_expand: float = ICON_TEMPLATE_BG_EXPAND
) -> void:
	if icon_rect == null:
		return

	var base_data: Dictionary = _ensure_icon_template_base(icon_rect)
	var has_icon: bool = icon_texture != null
	var background_rect: TextureRect = _ensure_icon_background_for_rect(icon_rect)
	if background_rect != null:
		_apply_icon_template_rect_from_base(background_rect, base_data, -background_expand)
		background_rect.texture = ICON_BACKGROUND_TEXTURE
		background_rect.modulate = _get_icon_template_tint(template_kind)
		background_rect.visible = has_icon and ICON_BACKGROUND_TEXTURE != null

	_apply_icon_template_rect_from_base(icon_rect, base_data, icon_inset)
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.texture = icon_texture
	icon_rect.modulate = Color(1.0, 1.0, 1.0, 0.98)
	icon_rect.visible = has_icon

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
	slot.custom_minimum_size = Vector2(RUN_INVENTORY_SLOT_SIZE, RUN_INVENTORY_SLOT_SIZE)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	slot.add_theme_stylebox_override("panel", _build_inventory_slot_stylebox(slot_style_kind))
	container.add_child(slot)

	var icon := TextureRect.new()
	icon.anchor_right = 1.0
	icon.anchor_bottom = 1.0
	icon.offset_left = RUN_INVENTORY_ICON_PADDING
	icon.offset_top = RUN_INVENTORY_ICON_PADDING
	icon.offset_right = -RUN_INVENTORY_ICON_PADDING
	icon.offset_bottom = -RUN_INVENTORY_ICON_PADDING
	slot.add_child(icon)
	_apply_icon_template(icon, icon_texture, slot_style_kind, ICON_TEMPLATE_INVENTORY_ICON_INSET)

	if not value_text.strip_edges().is_empty():
		var value_label := Label.new()
		value_label.text = value_text
		value_label.anchor_left = 1.0
		value_label.anchor_top = 1.0
		value_label.anchor_right = 1.0
		value_label.anchor_bottom = 1.0
		value_label.offset_left = -(RUN_INVENTORY_VALUE_INSET + RUN_INVENTORY_VALUE_BOX_SIZE)
		value_label.offset_top = -(RUN_INVENTORY_VALUE_INSET + RUN_INVENTORY_VALUE_BOX_SIZE)
		value_label.offset_right = -RUN_INVENTORY_VALUE_INSET
		value_label.offset_bottom = -RUN_INVENTORY_VALUE_INSET
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
	_synergy_popup_panel.offset_top = runtime_popup_top_offset
	_synergy_popup_panel.offset_right = 250.0
	_synergy_popup_panel.offset_bottom = runtime_popup_top_offset + 66.0
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
	var popup_body: String = "Move with WASD.\nCollect biomass to level up.\nAt Level 2, choose your variant starter spell and unlock your Q ability.\nPress Q to cast your variant ability (cooldown and scale with level).\nPick mutations and stats to shape your build.\nSurvive containment events and defeat the final OMEGA boss."
	_queue_runtime_popup(
		popup_title,
		popup_body,
		true,
		maxf(3.0, run_intro_popup_duration_seconds),
		true,
		maxf(0.0, run_intro_popup_top_offset)
	)
	_run_intro_popup_shown = true

func _queue_runtime_popup(
	title_text: String,
	body_text: String,
	prioritize: bool = false,
	custom_duration_seconds: float = -1.0,
	force_when_disabled: bool = false,
	top_offset_override: float = -1.0
) -> void:
	if not force_when_disabled and not synergy_popup_enabled:
		return
	var popup_entry: Dictionary = {
		"title": title_text,
		"body": body_text
	}
	if custom_duration_seconds > 0.0:
		popup_entry["duration_seconds"] = custom_duration_seconds
	if top_offset_override >= 0.0:
		popup_entry["top_offset"] = top_offset_override
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
	var popup_top_offset: float = float(popup_entry.get("top_offset", runtime_popup_top_offset))
	_show_synergy_popup(popup_title, popup_body, popup_duration_seconds, popup_top_offset)

func _show_synergy_popup(title_text: String, body_text: String, duration_seconds: float = -1.0, top_offset: float = -1.0) -> void:
	_ensure_synergy_popup_ui()
	if _synergy_popup_panel == null:
		return
	if _synergy_popup_title_label == null or _synergy_popup_body_label == null:
		return

	var resolved_top_offset: float = runtime_popup_top_offset
	if top_offset >= 0.0:
		resolved_top_offset = top_offset
	var panel_height: float = _synergy_popup_panel.offset_bottom - _synergy_popup_panel.offset_top
	if panel_height <= 0.0:
		panel_height = 66.0
	_synergy_popup_panel.offset_top = resolved_top_offset
	_synergy_popup_panel.offset_bottom = resolved_top_offset + panel_height

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
	var trigger_sources: Array[String] = _get_synergy_trigger_source_names(rule)
	if trigger_sources.is_empty():
		return effect_summary
	var trigger_text: String = " + ".join(trigger_sources)
	if effect_summary.is_empty():
		return "Triggered by %s" % trigger_text
	return "%s\nTriggered by %s" % [effect_summary, trigger_text]

func _get_synergy_trigger_source_names(rule: Dictionary) -> Array[String]:
	var trigger_names: Array[String] = []
	var required_tags: Array[String] = _get_synergy_required_tag_ids(rule)
	if required_tags.is_empty():
		return trigger_names

	var active_sources: Dictionary = _build_active_tag_sources()
	for tag_id in required_tags:
		var source_names: Array[String] = []
		if active_sources.has(tag_id):
			var source_variants: Array = active_sources.get(tag_id, [])
			for source_value in source_variants:
				var source_name_with_level: String = String(source_value).strip_edges()
				if source_name_with_level.is_empty():
					continue
				var clean_source_name: String = _strip_level_suffix(source_name_with_level)
				if source_names.has(clean_source_name):
					continue
				source_names.append(clean_source_name)

		if source_names.is_empty():
			trigger_names.append(_format_synergy_tag_display_name(tag_id))
			continue

		if source_names.size() == 1:
			trigger_names.append(source_names[0])
			continue

		trigger_names.append("/".join(source_names))

	return trigger_names

func _strip_level_suffix(source_name_with_level: String) -> String:
	var text_value: String = source_name_with_level.strip_edges()
	var level_separator_index: int = text_value.rfind(" L")
	if level_separator_index < 0:
		return text_value
	var suffix_text: String = text_value.substr(level_separator_index + 2).strip_edges()
	if not suffix_text.is_valid_int():
		return text_value
	return text_value.substr(0, level_separator_index).strip_edges()

func _format_synergy_tag_display_name(tag_id: String) -> String:
	match tag_id:
		"lytic_starter":
			return "Lytic starter"
		"lytic_core":
			return "Lytic core"
		"lytic_capstone":
			return "Lytic capstone"
		"pandemic_starter":
			return "Pandemic starter"
		"pandemic_core":
			return "Pandemic core"
		"pandemic_capstone":
			return "Pandemic capstone"
		"parasitic_starter":
			return "Parasitic starter"
		"parasitic_core":
			return "Parasitic core"
		"parasitic_capstone":
			return "Parasitic capstone"
		_:
			return tag_id.replace("_", " ").capitalize()

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

func _on_variant_cast_panel_mouse_entered() -> void:
	if variant_cast_panel == null or not is_instance_valid(variant_cast_panel):
		return
	if not variant_cast_panel.visible:
		return
	var variant_id: String = _get_current_variant_id_for_rewards()
	if variant_id.is_empty():
		return
	var tooltip_title: String = _build_variant_cast_tooltip_title(variant_id)
	var tooltip_body: String = _build_variant_cast_tooltip_body(variant_id)
	if tooltip_body.is_empty():
		return
	_show_inventory_tooltip(tooltip_title, tooltip_body, variant_cast_panel)

func _on_variant_cast_panel_mouse_exited() -> void:
	if _inventory_tooltip_slot != variant_cast_panel:
		return
	_hide_inventory_tooltip()

func _build_variant_cast_tooltip_title(variant_id: String) -> String:
	var key_text: String = _get_variant_cast_key_display()
	match variant_id:
		"lytic":
			return "%s: Predator Dash" % key_text
		"pandemic":
			return "%s: Viral Camouflage" % key_text
		"parasitic":
			return "%s: Siphon Pulse" % key_text
		_:
			return "%s: Variant Cast" % key_text

func _build_variant_cast_tooltip_body(variant_id: String) -> String:
	var lines: PackedStringArray = PackedStringArray()
	var cooldown_seconds: float = _get_variant_cast_cooldown_for_variant(variant_id)
	var ready_in_seconds: float = maxf(0.0, _variant_cast_cooldown_left)

	match variant_id:
		"lytic":
			lines.append("Dash toward your cursor and ignore damage during the dash.")
			lines.append("Damage: 0 (mobility cast)")
			lines.append("Dash distance: %.0f" % _get_lytic_dash_distance_for_level())
			lines.append("Dash duration: %.2fs" % _get_lytic_dash_duration_for_level())
			lines.append("Invulnerability: %.2fs" % _get_lytic_dash_invulnerability_for_level())
		"pandemic":
			lines.append("Enter camouflage and become untargetable briefly.")
			lines.append("Damage: 0 (utility cast)")
			lines.append("Camouflage duration: %.2fs" % _get_pandemic_camouflage_duration_for_level())
			var move_speed_bonus_percent: float = (_get_pandemic_camouflage_move_speed_multiplier_for_level() - 1.0) * 100.0
			lines.append("Move speed while active: +%d%%" % int(round(move_speed_bonus_percent)))
		"parasitic":
			var channel_seconds: float = _get_parasitic_siphon_duration_for_level()
			var tick_seconds: float = _get_parasitic_siphon_tick_interval_for_level()
			var tick_damage: int = _get_parasitic_siphon_damage_per_tick_for_level()
			var heal_per_hit: int = _get_parasitic_siphon_heal_per_hit_for_level()
			var tick_count: int = maxi(1, int(ceil(channel_seconds / maxf(0.01, tick_seconds))))
			var damage_per_target: int = tick_damage * tick_count
			lines.append("Channel in place and drain enemies in a radius.")
			lines.append("Damage: %d per tick (~%d per target per cast)" % [tick_damage, damage_per_target])
			lines.append("Channel duration: %.2fs" % channel_seconds)
			lines.append("Tick interval: %.2fs" % tick_seconds)
			lines.append("Drain radius: %.0f" % _get_parasitic_siphon_radius_for_level())
			if parasitic_cast_siphon_hit_all_nearby:
				lines.append("Targets: all nearby enemies")
			else:
				lines.append("Targets: up to %d" % _get_parasitic_siphon_max_targets_for_level())
			lines.append("Heal: +%d per enemy hit per tick" % heal_per_hit)
		_:
			return ""

	lines.append("")
	lines.append("Cooldown: %.1fs" % cooldown_seconds)
	if ready_in_seconds > 0.001:
		lines.append("Ready in: %.1fs" % ready_in_seconds)
	else:
		lines.append("Ready now")
	return "\n".join(lines)

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
	if mutation_system.has_method("get_module_instance"):
		return mutation_system.call("get_module_instance", mutation_id) as Node

	var property_name: String = ""
	match mutation_id:
		"spikes", "razor_halo":
			property_name = "spike_ring_instance"
		"orbiters", "virion_orbit":
			property_name = "orbiter_instance"
		"membrane", "protein_shell":
			property_name = "membrane_instance"
		"pulse_nova", "lytic_burst":
			property_name = "pulse_nova_instance"
		"acid_trail", "infective_secretion":
			property_name = "acid_trail_instance"
		"metabolism", "leech_tendril":
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

	var mutation_defs: Dictionary = MUTATIONS_DATA.get_all()
	var mutation_def: Dictionary = mutation_defs.get(mutation_id, {})
	var max_level_value: int = _get_mutation_max_level(mutation_id)
	var lines: Array[String] = []
	lines.append("Level: %d/%d" % [level_value, max_level_value])

	var description_text: String = String(mutation_def.get("description", "")).strip_edges()
	if not description_text.is_empty():
		lines.append(description_text)

	var gain_summary: String = _build_mutation_gain_summary_for_level(mutation_id, level_value)
	if not gain_summary.is_empty():
		lines.append(gain_summary)

	if mutation_id == "leech_tendril" and mutation_system != null and mutation_system.has_method("get_metabolism_regen_per_second"):
		lines.append("Current drain regen: +%.1f HP/s" % float(mutation_system.call("get_metabolism_regen_per_second")))
	if mutation_id == "protein_shell" and player != null:
		var incoming_multiplier: float = clampf(float(player.get("incoming_damage_multiplier")), 0.05, 1.0)
		lines.append("Current total reduction: %.1f%%" % ((1.0 - incoming_multiplier) * 100.0))
		if player.has_method("get_damage_reflect_ratio"):
			lines.append("Current reflect: %.1f%%" % (float(player.call("get_damage_reflect_ratio")) * 100.0))
	if mutation_id == "host_override":
		var host_count: int = 0
		for host_variant in get_tree().get_nodes_in_group("allied_hosts"):
			var host_node := host_variant as Node
			if host_node == null:
				continue
			if not is_instance_valid(host_node):
				continue
			host_count += 1
		lines.append("Active converted hosts: %d" % host_count)

	return "\n".join(lines)

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
		"focused_instability", "lance_overclock", "containment_breach", "epidemic_catalyst", "viral_density":
			lines.append("Run total ability damage: +%.1f%%" % ((_reward_module_damage_multiplier - 1.0) * 100.0))
		"kinetic_reframing", "adaptive_shelling":
			lines.append("Run total movement speed: +%.1f%%" % ((_reward_move_speed_multiplier - 1.0) * 100.0))
			if player != null:
				lines.append("Current move speed: %.1f" % float(player.get("move_speed")))
		"metabolic_surge":
			lines.append("Run orbiter speed bonus: +%.1f%%" % ((_reward_orbiter_speed_multiplier - 1.0) * 100.0))
			lines.append("Run secretion lifetime bonus: +%.1f%%" % ((_reward_acid_lifetime_multiplier - 1.0) * 100.0))
		"hemotrophic_loop":
			lines.append("Passive regen: +%.1f HP/s" % _get_total_bonus_regen_per_second())
			lines.append("Run bonus max HP: +%d" % _reward_bonus_max_hp_flat)
		_:
			lines.append("Applies a run-wide event modifier.")

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
	var trigger_names: Array[String] = _get_synergy_trigger_source_names(rule)
	if not required_tags.is_empty():
		if trigger_names.is_empty():
			lines.append("Activation: %s" % " + ".join(required_tags))
		else:
			lines.append("Activation: %s" % " + ".join(trigger_names))
		lines.append("Activated this run by:")
		var current_sources: Dictionary = _build_active_tag_sources()
		for tag_id in required_tags:
			var tag_display_name: String = _format_synergy_tag_display_name(tag_id)
			var source_names: Array[String] = []
			if current_sources.has(tag_id):
				var tag_source_values: Array = current_sources.get(tag_id, [])
				for source_value in tag_source_values:
					var source_name_with_level: String = String(source_value).strip_edges()
					if source_name_with_level.is_empty():
						continue
					var clean_source_name: String = _strip_level_suffix(source_name_with_level)
					if source_names.has(clean_source_name):
						continue
					source_names.append(clean_source_name)
			if source_names.is_empty():
				lines.append("%s from: (missing)" % tag_display_name)
			else:
				lines.append("%s from: %s" % [tag_display_name, ", ".join(source_names)])

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
		lines.append("Effect: %+.1f%% ability damage" % ((module_multiplier - 1.0) * 100.0))
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
	if node != null and node.has_method("apply_difficulty_multipliers"):
		call_deferred("_apply_enemy_difficulty_to_node", node)

func _connect_enemy_death(node: Node) -> void:
	if node == null:
		return
	if node == player:
		return
	if not node.has_signal("died"):
		return
	if not node.has_method("take_damage"):
		return

	if node.has_signal("died_detailed"):
		var detailed_callable := Callable(self, "_on_enemy_died_detailed")
		if node.is_connected("died_detailed", detailed_callable):
			return
		node.connect("died_detailed", detailed_callable)
		return

	var death_callable := Callable(self, "_on_enemy_died")
	if not node.is_connected("died", death_callable):
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
	if not _mass_biomass_collect_active:
		_play_sfx("sfx_pickup_biomass")

func _on_enemy_died(world_position: Vector2) -> void:
	_handle_enemy_death(world_position, null)

func _on_enemy_died_detailed(world_position: Vector2, enemy_node: Node) -> void:
	_handle_enemy_death(world_position, enemy_node)

func _handle_enemy_death(world_position: Vector2, enemy_node: Node) -> void:
	if debug_log_drops:
		print("Enemy died at ", world_position, " -> spawning biomass")
	var is_elite_enemy: bool = false
	if enemy_node != null and enemy_node.is_in_group("elite_enemies"):
		is_elite_enemy = true
	_add_enemy_score(is_elite_enemy)
	if is_elite_enemy:
		_play_sfx("sfx_enemy_elite_death")
	else:
		_play_sfx("sfx_enemy_death")
	call_deferred("_spawn_biomass_pickup", world_position, is_elite_enemy)

func _spawn_biomass_pickup(world_position: Vector2, is_elite_enemy: bool = false) -> void:
	var pickup := BIOMASS_PICKUP_SCENE.instantiate() as Node2D
	if pickup == null:
		return

	var base_xp_value: int = int(pickup.get("xp_value"))
	var scaled_xp_value: int = maxi(1, int(round(float(base_xp_value) * maxf(0.1, biomass_xp_multiplier))))
	if is_elite_enemy:
		scaled_xp_value += maxi(0, elite_biomass_xp_bonus)
	pickup.set("xp_value", scaled_xp_value)

	add_child(pickup)
	var offset := Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
	pickup.global_position = world_position + offset
	if debug_log_drops:
		print("Biomass spawned at ", pickup.global_position, " (xp=", scaled_xp_value, ", elite=", is_elite_enemy, ")")

func _on_player_died() -> void:
	if run_ended:
		return
	_restore_global_time_scale()
	_final_victory_sequence_active = false
	_final_victory_resolution_started = false

	if _last_run_end_reason.is_empty():
		_last_run_end_reason = _resolve_default_death_reason()
	_finalize_run_score_record("defeat", _last_run_end_reason)
	_end_run_common()
	if _pending_crisis_failure_audio:
		_play_sfx("sfx_defeat", -2.0, 0.95)
		_pending_crisis_failure_audio = false
	else:
		_play_sfx("sfx_defeat")
	_stop_music()
	_show_game_over()

func _end_run_common() -> void:
	pending_levelup_count = 0
	run_paused_for_levelup = false
	run_paused_for_menu = false
	lineage_selection_active = false
	crisis_reward_selection_active = false
	genome_cache_selection_active = false
	pending_genome_cache_prompt_count = 0
	active_crisis_reward_id = ""
	crisis_reward_options.clear()
	if levelup_ui != null:
		levelup_ui.visible = false
	if pause_menu_ui != null:
		pause_menu_ui.visible = false
	if crisis_debug_label != null:
		crisis_debug_label.visible = false
	if crisis_backdrop != null:
		crisis_backdrop.visible = false
	if game_over_ui != null:
		game_over_ui.visible = false
	if victory_ui != null:
		victory_ui.visible = false
	_hide_synergy_popup(true)
	_stop_final_crisis_composition()
	_clear_containment_sweep()
	_clear_biohazard_leaks()
	_clear_antiviral_drones()
	_clear_containment_pylons()
	_clear_genome_cache_pods()
	_clear_strain_bloom_state()
	_containment_seal_active = false
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

	for ally_host in get_tree().get_nodes_in_group("allied_hosts"):
		var ally_host_node := ally_host as Node
		if ally_host_node == null:
			continue
		ally_host_node.set_physics_process(active)

	for projectile_variant in get_tree().get_nodes_in_group("enemy_projectiles"):
		var projectile_node := projectile_variant as Node
		if projectile_node == null:
			continue
		projectile_node.set_process(active)
		projectile_node.set_physics_process(active)

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
		game_over_stats_label.text = "Variant: %s" % _get_current_lineage_name()
	if game_over_score_label != null:
		game_over_score_label.text = "Score: %s" % _format_score_value(_run_score_value)
	if game_over_meta_stats_label != null:
		game_over_meta_stats_label.text = "Time: %ds | Level: %d | Best Score: %s" % [
			int(elapsed_seconds),
			level_reached,
			_format_score_value(_get_highest_score_value())
		]
	if game_over_reason_label != null:
		game_over_reason_label.text = "Cause: %s" % _last_run_end_reason

	if game_over_ui != null:
		game_over_ui.visible = true

func _resolve_failure_reason(reason_text: String) -> String:
	var normalized_reason: String = reason_text.strip_edges().to_lower()
	match normalized_reason:
		"containment hunter objective failed":
			return "Containment hunter objective failed."
		"containment seal objective failed":
			return "Containment seal objective failed."
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
			"uv_sweep_grid":
				return "Caught by flame sweep."
			"hunter_deployment", "containment_warden":
				return "Eliminated during hunter deployment."
			"decon_flood":
				return "Severe contamination exposure."
			"quarantine_lattice":
				return "Trapped in quarantine lattice."
			"antiviral_drone_burst":
				return "Hit by antiviral burst."
			"containment_seal":
				return "Sealed by containment protocol."
	if phase_name == "final":
		return "Contained by Protocol OMEGA."
	return "Overwhelmed by hostile variants."

func _show_victory() -> void:
	_apply_crisis_ui_accent("victory", "protocol_omega_core", 0.0)
	if victory_stats_label != null:
		victory_stats_label.text = "Variant: %s" % _get_current_lineage_name()
	if victory_score_label != null:
		victory_score_label.text = "Score: %s" % _format_score_value(_run_score_value)
	if victory_meta_stats_label != null:
		victory_meta_stats_label.text = "Level: %d | Best Score: %s" % [
			level_reached,
			_format_score_value(_get_highest_score_value())
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
	if timer_label != null:
		timer_label.text = "Time: %ds" % int(elapsed_seconds)
	if score_label != null:
		score_label.text = "Score: %s" % _format_score_value(_run_score_value)

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
	if lineage_selection_active:
		_play_sfx("sfx_variant_pick")
	else:
		_play_sfx("sfx_ui_click")

	if crisis_reward_selection_active:
		var reward_applied: bool = _apply_crisis_reward_choice(choice_index)
		if not reward_applied:
			return
		_finish_crisis_reward_prompt()
		return

	if genome_cache_selection_active:
		if mutation_system != null and mutation_system.has_method("apply_option_index"):
			mutation_system.call("apply_option_index", choice_index)
		_finish_genome_cache_prompt()
		return

	if lineage_selection_active:
		var lineage_applied: bool = _apply_lineage_choice(choice_index)
		if not lineage_applied:
			return
		_refresh_lineage_labels()
	else:
		if mutation_system != null and mutation_system.has_method("apply_option_index"):
			mutation_system.call("apply_option_index", choice_index)

	if pending_genome_cache_prompt_count > 0:
		pending_genome_cache_prompt_count -= 1
		var did_open_cache_prompt: bool = _open_genome_cache_prompt(false, true)
		if did_open_cache_prompt:
			return
		pending_genome_cache_prompt_count = 0

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
	_play_sfx("sfx_ui_click")
	call_deferred("_go_to_main_menu_deferred")

func _on_pause_resume_pressed() -> void:
	_close_pause_menu()

func _on_pause_options_pressed() -> void:
	if pause_options_panel != null:
		var should_show_options: bool = not pause_options_panel.visible
		pause_options_panel.visible = should_show_options
		if should_show_options:
			_refresh_audio_controls_from_manager()
	_play_sfx("sfx_ui_click")

func _on_pause_main_menu_pressed() -> void:
	_play_sfx("sfx_ui_click")
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
	_refresh_pause_stats_panel()
	if pause_menu_ui != null:
		pause_menu_ui.visible = true
	_play_sfx("sfx_ui_click")

func _close_pause_menu(play_click_sound: bool = true) -> void:
	if not run_paused_for_menu:
		return

	run_paused_for_menu = false
	if pause_menu_ui != null:
		pause_menu_ui.visible = false
	if pause_options_panel != null:
		pause_options_panel.visible = false
	if play_click_sound:
		_play_sfx("sfx_ui_click")

	var opened_levelup_prompt: bool = false
	if pending_levelup_count > 0 and not run_ended:
		pending_levelup_count -= 1
		opened_levelup_prompt = _open_levelup_prompt(false)
		if not opened_levelup_prompt:
			pending_levelup_count = 0

	if not opened_levelup_prompt:
		_set_gameplay_active(true)

func _get_biomass_auto_collect_base_radius() -> float:
	if _cached_biomass_pickup_base_radius > 0.0:
		return _cached_biomass_pickup_base_radius

	var resolved_radius: float = 48.0
	var probe_pickup := BIOMASS_PICKUP_SCENE.instantiate() as Node
	if probe_pickup != null:
		var radius_variant: Variant = probe_pickup.get("auto_collect_base_radius")
		if radius_variant != null:
			resolved_radius = maxf(8.0, float(radius_variant))
		probe_pickup.free()

	_cached_biomass_pickup_base_radius = maxf(8.0, resolved_radius)
	return _cached_biomass_pickup_base_radius

func _refresh_pause_stats_panel() -> void:
	if pause_stats_text == null:
		return

	var hp_current: int = 0
	var hp_max: int = 0
	var move_speed_value: float = 0.0
	var incoming_damage_multiplier_value: float = 1.0
	var damage_reflect_ratio_value: float = 0.0
	var block_chance_value: float = 0.0
	var pickup_radius_multiplier_value: float = 1.0
	var pickup_radius_flat_bonus_value: float = 0.0
	var pickup_radius_value: float = _get_biomass_auto_collect_base_radius()
	if player != null:
		hp_current = int(player.get("current_hp"))
		hp_max = maxi(1, int(player.get("max_hp")))
		move_speed_value = float(player.get("move_speed"))
		incoming_damage_multiplier_value = clampf(float(player.get("incoming_damage_multiplier")), 0.05, 1.0)
		if player.has_method("get_damage_reflect_ratio"):
			damage_reflect_ratio_value = clampf(float(player.call("get_damage_reflect_ratio")), 0.0, 1.0)
		if player.has_method("get_block_chance"):
			block_chance_value = clampf(float(player.call("get_block_chance")), 0.0, 0.95)
		if player.has_method("get_pickup_radius_multiplier"):
			pickup_radius_multiplier_value = maxf(0.1, float(player.call("get_pickup_radius_multiplier")))
		if player.has_method("get_pickup_radius_flat_bonus"):
			pickup_radius_flat_bonus_value = maxf(0.0, float(player.call("get_pickup_radius_flat_bonus")))
	pickup_radius_value = maxf(8.0, (pickup_radius_value + pickup_radius_flat_bonus_value) * pickup_radius_multiplier_value)

	var xp_current: int = 0
	var xp_to_next: int = 1
	if xp_system != null:
		xp_current = int(xp_system.get("current_xp"))
		xp_to_next = maxi(1, int(xp_system.get("xp_to_next_level")))

	var event_snapshot: Dictionary = _get_pause_event_snapshot()
	var phase_name: String = String(event_snapshot.get("phase_name", "idle"))
	var phase_time_remaining: float = maxf(0.0, float(event_snapshot.get("phase_time_remaining", 0.0)))
	var next_event_seconds: float = maxf(0.0, float(event_snapshot.get("next_event_seconds", 0.0)))
	var objective_text: String = String(event_snapshot.get("objective", "--"))

	var damage_reduction_percent: float = maxf(0.0, (1.0 - incoming_damage_multiplier_value) * 100.0)
	var rewards_collected_count: int = _get_pause_total_reward_stack_count()
	var active_synergy_count: int = _active_tag_synergy_ids.size()
	var build_count: int = _get_pause_total_build_count()

	var lines: Array[String] = []
	lines.append("[table=2]")
	_append_pause_stats_heading(lines, "RUN OVERVIEW")
	_append_pause_stats_row(lines, "Time", "%ds" % int(elapsed_seconds))
	_append_pause_stats_row(lines, "Score", _format_score_value(_run_score_value))
	_append_pause_stats_row(lines, "Best Score", _format_score_value(_get_highest_score_value()))
	_append_pause_stats_row(lines, "Difficulty", GAMEPLAY_SETTINGS.get_difficulty_display_name(_selected_difficulty_id))
	_append_pause_stats_row(lines, "Variant", _get_current_lineage_name())
	_append_pause_stats_row(lines, "Level", str(level_reached))
	_append_pause_stats_row(lines, "XP", "%d / %d" % [xp_current, xp_to_next])
	_append_pause_stats_row(lines, "Build Entries", str(build_count))
	_append_pause_stats_row(lines, "Reward Stacks", str(rewards_collected_count))
	_append_pause_stats_row(lines, "Active Synergies", str(active_synergy_count))
	_append_pause_stats_spacer(lines)

	_append_pause_stats_heading(lines, "SURVIVAL")
	_append_pause_stats_row(lines, "HP", "%d / %d" % [hp_current, hp_max])
	_append_pause_stats_row(lines, "Move Speed", "%.1f" % move_speed_value)
	_append_pause_stats_row(lines, "Incoming Damage", "x%.2f (%.1f%% reduced)" % [incoming_damage_multiplier_value, damage_reduction_percent])
	_append_pause_stats_row(lines, "Damage Reflect", "%.1f%%" % (damage_reflect_ratio_value * 100.0))
	_append_pause_stats_row(lines, "Block Chance", "%.1f%%" % (block_chance_value * 100.0))
	_append_pause_stats_row(lines, "Pickup Radius", "%.0f" % pickup_radius_value)
	_append_pause_stats_row(lines, "Passive Regen", "+%.1f HP/s" % _get_total_bonus_regen_per_second())
	_append_pause_stats_spacer(lines)

	_append_pause_stats_heading(lines, "MULTIPLIERS")
	_append_pause_stats_row(lines, "Ability Damage", "x%.2f" % _get_preview_module_damage_multiplier())
	_append_pause_stats_row(lines, "Orbiter Speed", "x%.2f" % _get_preview_orbiter_speed_multiplier())
	_append_pause_stats_row(lines, "Pulse Radius", "x%.2f" % _get_preview_pulse_radius_multiplier())
	_append_pause_stats_row(lines, "Trail Lifetime", "x%.2f" % _get_preview_acid_lifetime_multiplier())
	_append_pause_stats_spacer(lines)

	_append_pause_stats_heading(lines, "STAT LEVELS")
	_append_pause_stats_row(lines, "Cytotoxicity", "L%d" % _get_pause_stat_level("offense_boost"))
	_append_pause_stats_row(lines, "Reinforced Envelope", "L%d" % _get_pause_stat_level("defense_boost"))
	_append_pause_stats_row(lines, "Collector Tendrils", "L%d" % _get_pause_stat_level("pickup_radius_boost"))
	_append_pause_stats_row(lines, "Motility Shift", "L%d" % _get_pause_stat_level("move_speed_boost"))
	_append_pause_stats_row(lines, "Replication Tempo", "L%d" % _get_pause_stat_level("cooldown_boost"))
	_append_pause_stats_row(lines, "Viral Mass", "L%d" % _get_pause_stat_level("vitality_boost"))
	_append_pause_stats_spacer(lines)

	_append_pause_stats_heading(lines, "ABILITY LEVELS")
	var has_any_module: bool = false
	for mutation_id in INVENTORY_MUTATION_IDS:
		var module_level: int = _get_pause_mutation_level(mutation_id)
		if module_level <= 0:
			continue
		has_any_module = true
		_append_pause_stats_row(lines, _get_mutation_display_name(mutation_id), "L%d" % module_level)
	if not has_any_module:
		_append_pause_stats_row(lines, "Abilities", "None")
	_append_pause_stats_spacer(lines)

	_append_pause_stats_heading(lines, "EVENT STATUS")
	_append_pause_stats_row(lines, "Phase", _format_pause_phase_name(phase_name))
	if phase_name == "idle":
		_append_pause_stats_row(lines, "Next Event", "in %.1fs" % next_event_seconds)
	else:
		_append_pause_stats_row(lines, "Time Remaining", "%.1fs" % phase_time_remaining)
	_append_pause_stats_row(lines, "Objective", objective_text)
	lines.append("[/table]")

	pause_stats_text.text = "\n".join(lines)

func _append_pause_stats_row(lines: Array[String], stat_label: String, stat_value: String) -> void:
	var safe_label: String = _sanitize_pause_stats_text(stat_label)
	var safe_value: String = _sanitize_pause_stats_text(stat_value)
	lines.append(
		"[cell][color=#7fa6bc]%s[/color][/cell][cell][right][color=#eaf5ff][b]%s[/b][/color][/right][/cell]" % [
			safe_label,
			safe_value
		]
	)

func _append_pause_stats_heading(lines: Array[String], heading_text: String) -> void:
	var safe_heading: String = _sanitize_pause_stats_text(heading_text)
	lines.append("[cell][color=#a6d7f0][b]%s[/b][/color][/cell][cell][/cell]" % safe_heading)

func _append_pause_stats_spacer(lines: Array[String]) -> void:
	lines.append("[cell] [/cell][cell] [/cell]")

func _sanitize_pause_stats_text(source_text: String) -> String:
	return source_text.replace("[", "(").replace("]", ")")

func _get_pause_stat_level(stat_id: String) -> int:
	if mutation_system == null:
		return 0
	if not mutation_system.has_method("get_stat_level"):
		return 0
	return maxi(0, int(mutation_system.call("get_stat_level", stat_id)))

func _get_pause_mutation_level(mutation_id: String) -> int:
	if mutation_system == null:
		return 0
	if not mutation_system.has_method("get_mutation_level"):
		return 0
	return maxi(0, int(mutation_system.call("get_mutation_level", mutation_id)))

func _get_pause_total_build_count() -> int:
	var count_value: int = 0
	for mutation_id in INVENTORY_MUTATION_IDS:
		if _get_pause_mutation_level(mutation_id) > 0:
			count_value += 1
	return count_value

func _get_pause_total_reward_stack_count() -> int:
	var total_stacks: int = 0
	for reward_id in _run_reward_inventory_order:
		if not _run_reward_inventory.has(reward_id):
			continue
		var reward_entry: Dictionary = _run_reward_inventory.get(reward_id, {})
		total_stacks += maxi(0, int(reward_entry.get("count", 0)))
	return total_stacks

func _get_pause_event_snapshot() -> Dictionary:
	var phase_name: String = "idle"
	var crisis_id: String = ""
	var phase_time_remaining: float = 0.0
	var next_event_seconds: float = 0.0
	if crisis_director != null:
		if crisis_director.has_method("get_phase"):
			phase_name = String(crisis_director.call("get_phase"))
		if crisis_director.has_method("get_active_crisis_id"):
			crisis_id = String(crisis_director.call("get_active_crisis_id"))
		if crisis_director.has_method("get_phase_time_remaining"):
			phase_time_remaining = float(crisis_director.call("get_phase_time_remaining"))
		if crisis_director.has_method("get_time_until_next_crisis"):
			next_event_seconds = float(crisis_director.call("get_time_until_next_crisis", elapsed_seconds))
	return {
		"phase_name": phase_name,
		"phase_time_remaining": phase_time_remaining,
		"next_event_seconds": next_event_seconds,
		"objective": _get_crisis_objective_text(phase_name, crisis_id)
	}

func _format_pause_phase_name(phase_name: String) -> String:
	var trimmed_phase_name: String = phase_name.strip_edges()
	if trimmed_phase_name.is_empty():
		return "Idle"
	var phase_words: PackedStringArray = trimmed_phase_name.replace("_", " ").split(" ", false)
	if phase_words.is_empty():
		return trimmed_phase_name.capitalize()
	var titled_words: Array[String] = []
	for raw_word in phase_words:
		var word_text: String = String(raw_word)
		if word_text.is_empty():
			continue
		titled_words.append(word_text.capitalize())
	if titled_words.is_empty():
		return trimmed_phase_name.capitalize()
	return " ".join(titled_words)

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
		button.text = ""
		button.disabled = true
		if icon != null:
			_apply_icon_template(icon, null, "choice", ICON_TEMPLATE_CHOICE_ICON_INSET)
		if rich_text != null:
			rich_text.text = "[center]No Mutation[/center]"
		return

	if not (options[index] is Dictionary):
		button.text = ""
		button.disabled = true
		if icon != null:
			_apply_icon_template(icon, null, "choice", ICON_TEMPLATE_CHOICE_ICON_INSET)
		if rich_text != null:
			rich_text.text = "[center]No Mutation[/center]"
		return

	var option: Dictionary = options[index]
	button.disabled = false
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
	var template_kind: String = "mutation"
	if _is_crisis_reward_option(option):
		template_kind = "reward"
	if icon_id.is_empty() or not MUTATION_ICON_BY_ID.has(icon_id):
		_apply_icon_template(icon, null, template_kind, ICON_TEMPLATE_CHOICE_ICON_INSET)
		return

	var icon_texture_variant: Variant = MUTATION_ICON_BY_ID.get(icon_id, null)
	var icon_texture: Texture2D = icon_texture_variant as Texture2D
	_apply_icon_template(icon, icon_texture, template_kind, ICON_TEMPLATE_CHOICE_ICON_INSET)

func _get_spike_count_for_level(level_value: int) -> int:
	match level_value:
		1:
			return 4
		2:
			return 6
		3:
			return 8
		4:
			return 10
		5:
			return 12
		_:
			return 0

func _get_orbiter_count_for_level(level_value: int) -> int:
	match level_value:
		1:
			return 1
		2, 3:
			return 2
		4:
			return 3
		5:
			return 4
		_:
			return 0

func _get_membrane_reduction_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 10.0
		2:
			return 19.0
		3:
			return 28.0
		4:
			return 36.0
		5:
			return 44.0
		_:
			return 0.0

func _get_membrane_reflect_percent_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 4.0
		2:
			return 6.0
		3:
			return 8.0
		4:
			return 10.0
		5:
			return 12.0
		_:
			return 0.0

func _get_lytic_guard_block_chance_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 0.12
		2:
			return 0.20
		3:
			return 0.29
		4:
			return 0.37
		5:
			return 0.45
		_:
			return 0.0

func _get_razor_halo_heal_per_hit_for_level(level_value: int) -> int:
	match level_value:
		2:
			return 1
		3:
			return 2
		4:
			return 3
		5:
			return 4
		_:
			return 0

func _get_pulse_damage_for_level(level_value: int) -> int:
	match level_value:
		1:
			return 8
		2:
			return int(round(8.0 * 1.45))
		3:
			return int(round(8.0 * 1.90))
		4:
			return int(round(8.0 * 2.35))
		5:
			return int(round(8.0 * 2.80))
		_:
			return 0

func _get_pulse_radius_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 80.0
		2:
			return 100.0
		3:
			return 118.0
		4:
			return 138.0
		5:
			return 160.0
		_:
			return 0.0

func _get_pulse_interval_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 1.85
		2:
			return maxf(0.36, 1.85 * 0.84)
		3:
			return maxf(0.30, 1.85 * 0.70)
		4:
			return maxf(0.26, 1.85 * 0.60)
		5:
			return maxf(0.22, 1.85 * 0.52)
		_:
			return 999.0

func _get_acid_damage_for_level(level_value: int) -> int:
	match level_value:
		1:
			return 3
		2:
			return int(round(3.0 * 1.25))
		3:
			return int(round(3.0 * 1.50))
		4:
			return int(round(3.0 * 1.80))
		5:
			return int(round(3.0 * 2.10))
		_:
			return 0

func _get_acid_radius_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 17.0
		2:
			return 18.5
		3:
			return 20.0
		4:
			return 21.5
		5:
			return 23.0
		_:
			return 0.0

func _get_acid_lifetime_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 1.8
		2:
			return 2.25
		3:
			return 2.65
		4:
			return 3.05
		5:
			return 3.5
		_:
			return 0.0

func _get_acid_tick_interval_for_level(level_value: int) -> float:
	match level_value:
		1:
			return 0.50
		2:
			return maxf(0.24, 0.50 * 0.90)
		3:
			return maxf(0.21, 0.50 * 0.82)
		4:
			return maxf(0.18, 0.50 * 0.74)
		5:
			return maxf(0.16, 0.50 * 0.66)
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
		4:
			return 8.1
		5:
			return 10.8
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
	var clamped_level: int = clampi(level_value, 1, 5)
	var previous_level: int = maxi(0, clamped_level - 1)
	var module_damage_multiplier: float = _get_preview_module_damage_multiplier()
	match mutation_id:
		"proto_pulse":
			var curr_damage_scale: float = 1.0
			match clamped_level:
				2:
					curr_damage_scale = 1.35
				3:
					curr_damage_scale = 1.65
				4:
					curr_damage_scale = 2.0
				5:
					curr_damage_scale = 2.35
			var prev_damage_scale: float = 0.0
			match previous_level:
				1:
					prev_damage_scale = 1.0
				2:
					prev_damage_scale = 1.35
				3:
					prev_damage_scale = 1.65
				4:
					prev_damage_scale = 2.0
				5:
					prev_damage_scale = 2.35
			var curr_damage: int = maxi(1, int(round(6.0 * curr_damage_scale * module_damage_multiplier)))
			var prev_damage: int = 0
			if previous_level > 0:
				prev_damage = maxi(1, int(round(6.0 * prev_damage_scale * module_damage_multiplier)))

			var curr_radius_base: float = 92.0
			match clamped_level:
				2:
					curr_radius_base += 12.0
				3:
					curr_radius_base += 24.0
				4:
					curr_radius_base += 38.0
				5:
					curr_radius_base += 54.0
			var prev_radius_base: float = 0.0
			if previous_level > 0:
				prev_radius_base = 92.0
				match previous_level:
					2:
						prev_radius_base += 12.0
					3:
						prev_radius_base += 24.0
					4:
						prev_radius_base += 38.0
					5:
						prev_radius_base += 54.0
			var curr_radius: float = curr_radius_base * _get_preview_pulse_radius_multiplier()
			var prev_radius: float = prev_radius_base * _get_preview_pulse_radius_multiplier()

			var parts: Array[String] = []
			var delta_damage: int = curr_damage - prev_damage
			var delta_radius: float = curr_radius - prev_radius
			if delta_damage != 0:
				parts.append("%+d pulse dmg" % delta_damage)
			if absf(delta_radius) > 0.05:
				parts.append("%+.0f range" % delta_radius)
			if parts.is_empty():
				return "Gain: no direct numeric change"
			return "Gain: %s" % " | ".join(parts)
		"razor_halo":
			var curr_blades: int = _get_spike_count_for_level(clamped_level)
			var prev_blades: int = _get_spike_count_for_level(previous_level)
			var curr_damage: int = maxi(1, int(round(8.0 * module_damage_multiplier)))
			var prev_damage: int = 0
			if previous_level > 0:
				prev_damage = maxi(1, int(round(8.0 * module_damage_multiplier)))
			var curr_heal: int = _get_razor_halo_heal_per_hit_for_level(clamped_level)
			var prev_heal: int = _get_razor_halo_heal_per_hit_for_level(previous_level)
			var parts: Array[String] = []
			if curr_blades != prev_blades:
				parts.append("%+d blades" % (curr_blades - prev_blades))
			if curr_damage != prev_damage:
				parts.append("%+d contact dmg every 0.20s" % (curr_damage - prev_damage))
			if curr_heal != prev_heal:
				parts.append("heal %+d per damage tick on hit" % (curr_heal - prev_heal))
			if parts.is_empty():
				return "Gain: no direct numeric change"
			return "Gain: %s" % " | ".join(parts)
		"puncture_lance":
			var curr_hits: int = clampi(clamped_level, 1, 5)
			var prev_hits: int = clampi(previous_level, 0, 5)
			var curr_damage_base: float = 12.0
			match clamped_level:
				2:
					curr_damage_base *= 1.20
				3:
					curr_damage_base *= 1.38
				4:
					curr_damage_base *= 1.58
				5:
					curr_damage_base *= 1.80
			var prev_damage_base: float = 0.0
			match previous_level:
				1:
					prev_damage_base = 12.0
				2:
					prev_damage_base = 12.0 * 1.20
				3:
					prev_damage_base = 12.0 * 1.38
				4:
					prev_damage_base = 12.0 * 1.58
				5:
					prev_damage_base = 12.0 * 1.80
			var curr_damage: int = maxi(1, int(round(curr_damage_base * module_damage_multiplier)))
			var prev_damage: int = 0
			if previous_level > 0:
				prev_damage = maxi(1, int(round(prev_damage_base * module_damage_multiplier)))
			var parts: Array[String] = []
			if curr_hits != prev_hits:
				parts.append("%+d lances/volley" % (curr_hits - prev_hits))
			if curr_damage != prev_damage:
				parts.append("%+d pierce dmg" % (curr_damage - prev_damage))
			if parts.is_empty():
				return "Gain: no direct numeric change"
			return "Gain: %s" % " | ".join(parts)
		"lytic_burst":
			var curr_damage: int = maxi(1, int(round(float(_get_pulse_damage_for_level(clamped_level)) * 1.25 * module_damage_multiplier)))
			var prev_damage: int = 0
			if previous_level > 0:
				prev_damage = maxi(1, int(round(float(_get_pulse_damage_for_level(previous_level)) * 1.25 * module_damage_multiplier)))
			var curr_radius: float = (_get_pulse_radius_for_level(clamped_level) + 20.0) * _get_preview_pulse_radius_multiplier()
			var prev_radius: float = 0.0
			if previous_level > 0:
				prev_radius = (_get_pulse_radius_for_level(previous_level) + 20.0) * _get_preview_pulse_radius_multiplier()
			var curr_block_pct: int = int(round(_get_lytic_guard_block_chance_for_level(clamped_level) * 100.0))
			var prev_block_pct: int = 0
			if previous_level > 0:
				prev_block_pct = int(round(_get_lytic_guard_block_chance_for_level(previous_level) * 100.0))
			var parts: Array[String] = []
			var delta_damage: int = curr_damage - prev_damage
			var delta_radius: float = curr_radius - prev_radius
			var delta_block_pct: int = curr_block_pct - prev_block_pct
			if delta_damage != 0:
				parts.append("%+d burst dmg" % delta_damage)
			if absf(delta_radius) > 0.05:
				parts.append("%+.0f burst radius" % delta_radius)
			if delta_block_pct != 0:
				parts.append("%+d%% block chance" % delta_block_pct)
			if parts.is_empty():
				return "Gain: no direct numeric change"
			return "Gain: %s" % " | ".join(parts)
		"infective_secretion":
			var curr_damage: int = maxi(1, int(round(float(_get_acid_damage_for_level(clamped_level)) * module_damage_multiplier)))
			var prev_damage: int = 0
			if previous_level > 0:
				prev_damage = maxi(1, int(round(float(_get_acid_damage_for_level(previous_level)) * module_damage_multiplier)))
			var curr_lifetime: float = _get_acid_lifetime_for_level(clamped_level) * _get_preview_acid_lifetime_multiplier()
			var prev_lifetime: float = 0.0
			if previous_level > 0:
				prev_lifetime = _get_acid_lifetime_for_level(previous_level) * _get_preview_acid_lifetime_multiplier()
			var parts: Array[String] = []
			if curr_damage != prev_damage:
				parts.append("%+d infection DOT" % (curr_damage - prev_damage))
			var delta_lifetime: float = curr_lifetime - prev_lifetime
			if absf(delta_lifetime) > 0.005:
				parts.append("%+.2fs trail uptime" % delta_lifetime)
			if parts.is_empty():
				return "Gain: no direct numeric change"
			return "Gain: %s" % " | ".join(parts)
		"virion_orbit":
			var curr_count: int = _get_orbiter_count_for_level(clamped_level)
			var prev_count: int = _get_orbiter_count_for_level(previous_level)
			var curr_damage: int = maxi(1, int(round(6.0 * module_damage_multiplier)))
			var prev_damage: int = 0
			if previous_level > 0:
				prev_damage = maxi(1, int(round(6.0 * module_damage_multiplier)))
			var curr_speed_mult: float = 1.0
			if clamped_level >= 5:
				curr_speed_mult = 2.1
			elif clamped_level >= 4:
				curr_speed_mult = 1.8
			elif clamped_level >= 3:
				curr_speed_mult = 1.5
			var prev_speed_mult: float = 0.0
			if previous_level > 0:
				prev_speed_mult = 1.0
				if previous_level >= 5:
					prev_speed_mult = 2.1
				elif previous_level >= 4:
					prev_speed_mult = 1.8
				elif previous_level >= 3:
					prev_speed_mult = 1.5
			var parts: Array[String] = []
			if curr_count != prev_count:
				parts.append("%+d virions" % (curr_count - prev_count))
			if curr_damage != prev_damage:
				parts.append("%+d contact dmg + infection" % (curr_damage - prev_damage))
			var delta_speed_pct: int = int(round((curr_speed_mult - prev_speed_mult) * 100.0))
			if delta_speed_pct != 0:
				parts.append("%+d%% orbit speed" % delta_speed_pct)
			if parts.is_empty():
				return "Gain: no direct numeric change"
			return "Gain: %s" % " | ".join(parts)
		"chain_bloom":
			var curr_damage_base: float = 9.0
			match clamped_level:
				2:
					curr_damage_base *= 1.25
				3:
					curr_damage_base *= 1.55
				4:
					curr_damage_base *= 1.85
				5:
					curr_damage_base *= 2.20
			var prev_damage_base: float = 0.0
			match previous_level:
				1:
					prev_damage_base = 9.0
				2:
					prev_damage_base = 9.0 * 1.25
				3:
					prev_damage_base = 9.0 * 1.55
				4:
					prev_damage_base = 9.0 * 1.85
				5:
					prev_damage_base = 9.0 * 2.20
			var curr_damage: int = maxi(1, int(round(curr_damage_base * module_damage_multiplier)))
			var prev_damage: int = 0
			if previous_level > 0:
				prev_damage = maxi(1, int(round(prev_damage_base * module_damage_multiplier)))

			var curr_radius: float = 90.0
			match clamped_level:
				2:
					curr_radius += 26.0
				3:
					curr_radius += 52.0
				4:
					curr_radius += 80.0
				5:
					curr_radius += 110.0
			var prev_radius: float = 0.0
			if previous_level > 0:
				prev_radius = 90.0
				match previous_level:
					2:
						prev_radius += 26.0
					3:
						prev_radius += 52.0
					4:
						prev_radius += 80.0
					5:
						prev_radius += 110.0

			var parts: Array[String] = []
			if previous_level <= 0:
				parts.append("+infected death bloom")
			var delta_damage: int = curr_damage - prev_damage
			var delta_radius: float = curr_radius - prev_radius
			if delta_damage != 0:
				parts.append("%+d bloom dmg" % delta_damage)
			if absf(delta_radius) > 0.05:
				parts.append("%+.0f bloom radius" % delta_radius)
			if parts.is_empty():
				return "Gain: no direct numeric change"
			return "Gain: %s" % " | ".join(parts)
		"leech_tendril":
			var curr_damage_base: float = 4.0
			match clamped_level:
				2:
					curr_damage_base *= 1.25
				3:
					curr_damage_base *= 1.48
				4:
					curr_damage_base *= 1.75
				5:
					curr_damage_base *= 2.05
			var prev_damage_base: float = 0.0
			match previous_level:
				1:
					prev_damage_base = 4.0
				2:
					prev_damage_base = 4.0 * 1.25
				3:
					prev_damage_base = 4.0 * 1.48
				4:
					prev_damage_base = 4.0 * 1.75
				5:
					prev_damage_base = 4.0 * 2.05
			var curr_damage: int = maxi(1, int(round(curr_damage_base * module_damage_multiplier)))
			var prev_damage: int = 0
			if previous_level > 0:
				prev_damage = maxi(1, int(round(prev_damage_base * module_damage_multiplier)))

			var curr_heal: int = 1
			match clamped_level:
				2:
					curr_heal = 2
				3:
					curr_heal = 3
				4:
					curr_heal = 4
				5:
					curr_heal = 5
			var prev_heal: int = 0
			if previous_level > 0:
				prev_heal = 1
				match previous_level:
					2:
						prev_heal = 2
					3:
						prev_heal = 3
					4:
						prev_heal = 4
					5:
						prev_heal = 5
			var parts: Array[String] = []
			if curr_damage != prev_damage:
				parts.append("%+d drain dmg tick" % (curr_damage - prev_damage))
			if curr_heal != prev_heal:
				parts.append("heal %+d per tether tick" % (curr_heal - prev_heal))
			if parts.is_empty():
				return "Gain: no direct numeric change"
			return "Gain: %s" % " | ".join(parts)
		"protein_shell":
			var curr_reduction: float = _get_membrane_reduction_for_level(clamped_level)
			var prev_reduction: float = _get_membrane_reduction_for_level(previous_level)
			var curr_reflect: float = _get_membrane_reflect_percent_for_level(clamped_level)
			var prev_reflect: float = _get_membrane_reflect_percent_for_level(previous_level)
			var parts: Array[String] = []
			var delta_reduction: float = curr_reduction - prev_reduction
			var delta_reflect: float = curr_reflect - prev_reflect
			if absf(delta_reduction) > 0.05:
				parts.append("%+.0f%% incoming dmg reduction" % delta_reduction)
			if absf(delta_reflect) > 0.05:
				parts.append("%+.0f%% dmg reflect" % delta_reflect)
			if parts.is_empty():
				return "Gain: no direct numeric change"
			return "Gain: %s" % " | ".join(parts)
		"host_override":
			var curr_threshold_pct: int = 25
			match clamped_level:
				2:
					curr_threshold_pct = 40
				3:
					curr_threshold_pct = 55
				4:
					curr_threshold_pct = 65
				5:
					curr_threshold_pct = 75
			var prev_threshold_pct: int = 0
			match previous_level:
				1:
					prev_threshold_pct = 25
				2:
					prev_threshold_pct = 40
				3:
					prev_threshold_pct = 55
				4:
					prev_threshold_pct = 65
				5:
					prev_threshold_pct = 75

			var curr_hosts_cap: int = 1
			match clamped_level:
				2:
					curr_hosts_cap = 2
				3:
					curr_hosts_cap = 3
				4:
					curr_hosts_cap = 4
				5:
					curr_hosts_cap = 5
			var prev_hosts_cap: int = 0
			match previous_level:
				1:
					prev_hosts_cap = 1
				2:
					prev_hosts_cap = 2
				3:
					prev_hosts_cap = 3
				4:
					prev_hosts_cap = 4
				5:
					prev_hosts_cap = 5
			var parts: Array[String] = []
			var delta_threshold_pct: int = curr_threshold_pct - prev_threshold_pct
			var delta_hosts_cap: int = curr_hosts_cap - prev_hosts_cap
			if delta_threshold_pct != 0:
				parts.append("%+d%% conversion threshold" % delta_threshold_pct)
			if delta_hosts_cap != 0:
				parts.append("%+d max hosts" % delta_hosts_cap)
			if parts.is_empty():
				return "Gain: no direct numeric change"
			return "Gain: %s" % " | ".join(parts)
		"offense_boost":
			var curr_pct: int = 10
			match clamped_level:
				2:
					curr_pct = 22
				3:
					curr_pct = 36
			var prev_pct: int = 0
			match previous_level:
				1:
					prev_pct = 10
				2:
					prev_pct = 22
				3:
					prev_pct = 36
			return "Gain: +%d%% ability damage" % (curr_pct - prev_pct)
		"defense_boost":
			var curr_reduction: int = 10
			match clamped_level:
				2:
					curr_reduction = 22
				3:
					curr_reduction = 34
			var prev_reduction: int = 0
			match previous_level:
				1:
					prev_reduction = 10
				2:
					prev_reduction = 22
				3:
					prev_reduction = 34
			return "Gain: +%d%% incoming damage reduction" % (curr_reduction - prev_reduction)
		"pickup_radius_boost":
			var curr_radius_bonus: int = 100
			match clamped_level:
				2:
					curr_radius_bonus = 220
				3:
					curr_radius_bonus = 360
			var prev_radius_bonus: int = 0
			match previous_level:
				1:
					prev_radius_bonus = 100
				2:
					prev_radius_bonus = 220
				3:
					prev_radius_bonus = 360
			return "Gain: %+d pickup radius" % (curr_radius_bonus - prev_radius_bonus)
		"move_speed_boost":
			var curr_speed_pct: int = 9
			match clamped_level:
				2:
					curr_speed_pct = 19
				3:
					curr_speed_pct = 30
			var prev_speed_pct: int = 0
			match previous_level:
				1:
					prev_speed_pct = 9
				2:
					prev_speed_pct = 19
				3:
					prev_speed_pct = 30
			return "Gain: +%d%% movement speed" % (curr_speed_pct - prev_speed_pct)
		"cooldown_boost":
			var curr_cooldown_reduction: int = 8
			match clamped_level:
				2:
					curr_cooldown_reduction = 18
				3:
					curr_cooldown_reduction = 28
			var prev_cooldown_reduction: int = 0
			match previous_level:
				1:
					prev_cooldown_reduction = 8
				2:
					prev_cooldown_reduction = 18
				3:
					prev_cooldown_reduction = 28
			return "Gain: +%d%% cooldown reduction" % (curr_cooldown_reduction - prev_cooldown_reduction)
		"vitality_boost":
			var curr_hp_bonus: int = 35
			match clamped_level:
				2:
					curr_hp_bonus = 80
				3:
					curr_hp_bonus = 140
			var prev_hp_bonus: int = 0
			match previous_level:
				1:
					prev_hp_bonus = 35
				2:
					prev_hp_bonus = 80
				3:
					prev_hp_bonus = 140
			var hp_delta: int = curr_hp_bonus - prev_hp_bonus
			return "Gain: +%d max HP and +%d instant heal" % [hp_delta, hp_delta]
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
	var getter_name: String = ""
	if mutation_system.has_method("get_current_variant_id"):
		getter_name = "get_current_variant_id"
	elif mutation_system.has_method("get_current_lineage_id"):
		getter_name = "get_current_lineage_id"
	if getter_name.is_empty():
		return false

	var lineage_id_variant: Variant = mutation_system.call(getter_name)
	var current_lineage_id: String = String(lineage_id_variant)
	return current_lineage_id.is_empty()

func _set_lineage_choice_button_texts() -> void:
	_set_levelup_mode(true)
	_refresh_choice_panel_labels()
	_set_lineage_choice_icon(lineage_choice_1_icon, VARIANT_ICON_LYTIC)
	_set_lineage_choice_icon(lineage_choice_2_icon, VARIANT_ICON_PANDEMIC)
	_set_lineage_choice_icon(lineage_choice_3_icon, VARIANT_ICON_PARASITIC)
	_set_lineage_choice_text(
		lineage_choice_1,
		lineage_choice_1_text,
		"Lytic Variant",
		"Close-range execution variant that deletes priority targets in melee windows.",
		_build_lineage_starter_text("lytic"),
		_build_lineage_active_text("lytic"),
		"Favored rolls: Razor Halo, Puncture Lance, Lytic Burst"
	)
	_set_lineage_choice_text(
		lineage_choice_2,
		lineage_choice_2_text,
		"Pandemic Variant",
		"Contagion spread variant that infects packs and wins through chain pressure.",
		_build_lineage_starter_text("pandemic"),
		_build_lineage_active_text("pandemic"),
		"Favored rolls: Infective Secretion, Virion Orbit, Chain Bloom"
	)
	_set_lineage_choice_text(
		lineage_choice_3,
		lineage_choice_3_text,
		"Parasitic Variant",
		"Drain-control variant built around sustain, tether pressure, and host conversion.",
		_build_lineage_starter_text("parasitic"),
		_build_lineage_active_text("parasitic"),
		"Favored rolls: Leech Tendril, Protein Shell, Host Override"
	)

func _build_lineage_starter_text(lineage_id: String) -> String:
	match lineage_id:
		"lytic":
			return "Razor Halo L1: %s" % _build_mutation_gain_summary_for_level("razor_halo", 1)
		"pandemic":
			return "Infective Secretion L1: %s" % _build_mutation_gain_summary_for_level("infective_secretion", 1)
		"parasitic":
			return "Leech Tendril L1: %s" % _build_mutation_gain_summary_for_level("leech_tendril", 1)
		_:
			return "None"

func _build_lineage_active_text(lineage_id: String) -> String:
	match lineage_id:
		"lytic":
			return "Predator Dash: burst forward and ignore damage during the dash."
		"pandemic":
			return "Viral Camouflage: become untargetable briefly and move faster while hidden."
		"parasitic":
			return "Siphon Pulse: channel in place, drain nearby hosts in a burst field, and heal per tick."
		_:
			return "None"

func _set_lineage_choice_text(
	button: Button,
	rich_text: RichTextLabel,
	title_text: String,
	description_text: String,
	starter_text: String,
	active_text: String,
	favored_text: String
) -> void:
	if button == null:
		return
	if rich_text == null:
		button.text = "%s\n%s\n%s\n%s\n%s" % [title_text, description_text, starter_text, active_text, favored_text]
		return
	button.text = ""
	rich_text.text = _format_lineage_choice_bbcode(title_text, description_text, starter_text, active_text, favored_text)

func _set_lineage_choice_icon(icon_rect: TextureRect, icon_texture: Texture2D) -> void:
	if icon_rect == null:
		return
	_apply_icon_template(icon_rect, icon_texture, "lineage", ICON_TEMPLATE_LINEAGE_ICON_INSET)

func _format_lineage_choice_bbcode(
	title_text: String,
	description_text: String,
	starter_text: String,
	active_text: String,
	favored_text: String
) -> String:
	return "[center][font_size=23][b]%s[/b][/font_size]\n[font_size=16][color=#c8deea]%s[/color][/font_size]\n\n[font_size=15][color=#9ec4d6][b]Starter Spell[/b][/color][/font_size]\n[font_size=14][color=#b7d3e2]%s[/color][/font_size]\n\n[font_size=15][color=#9ec4d6][b]Variant Cast (Q)[/b][/color][/font_size]\n[font_size=14][color=#b7d3e2]%s[/color][/font_size]\n\n[font_size=13][color=#7fa4b6][i]%s[/i][/color][/font_size][/center]" % [
		title_text,
		description_text,
		starter_text,
		active_text,
		favored_text
	]

func _apply_lineage_choice(choice_index: int) -> bool:
	if mutation_system == null:
		return false
	var chooser_name: String = ""
	if mutation_system.has_method("choose_variant"):
		chooser_name = "choose_variant"
	elif mutation_system.has_method("choose_lineage"):
		chooser_name = "choose_lineage"
	if chooser_name.is_empty():
		return false
	if choice_index < 0 or choice_index >= LINEAGE_CHOICES.size():
		return false

	var lineage_id: String = LINEAGE_CHOICES[choice_index]
	var applied: bool = bool(mutation_system.call(chooser_name, lineage_id))
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
	if mutation_system != null:
		if mutation_system.has_method("get_current_variant_name"):
			var variant_name_variant: Variant = mutation_system.call("get_current_variant_name")
			return String(variant_name_variant)
		if mutation_system.has_method("get_current_lineage_name"):
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

	var granted_xp: int = debug_grant_xp_amount
	var current_xp_variant: Variant = xp_system.get("current_xp")
	var xp_to_next_variant: Variant = xp_system.get("xp_to_next_level")
	if current_xp_variant != null and xp_to_next_variant != null:
		var current_xp_value: int = int(current_xp_variant)
		var xp_to_next_value: int = int(xp_to_next_variant)
		if xp_to_next_value > 0:
			granted_xp = maxi(1, xp_to_next_value - current_xp_value)

	xp_system.call("add_xp", granted_xp)
	print("Debug XP granted: +", granted_xp)

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
	_recalculate_run_score()
	_update_timer_label()
	_tick_crisis_director(seconds_to_skip)
	_tick_biohazard_leak_spawner(seconds_to_skip)
	_tick_genome_cache_spawner(seconds_to_skip)

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
		print("Debug event jump: moved to next active event")

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
	_recalculate_run_score()
	_update_timer_label()

	var reached_final: bool = false
	if crisis_director.has_method("get_phase") and crisis_director.has_method("get_active_crisis_id"):
		var phase_name: String = String(crisis_director.call("get_phase"))
		var crisis_id: String = String(crisis_director.call("get_active_crisis_id"))
		reached_final = (phase_name == "final" and crisis_id == "protocol_omega_core")

	if not reached_final and crisis_director.has_method("debug_force_next_active_crisis"):
		var safety_steps: int = 24
		while safety_steps > 0 and not reached_final:
			safety_steps -= 1
			var jumped: bool = bool(crisis_director.call("debug_force_next_active_crisis", elapsed_seconds))
			if not jumped:
				break
			if crisis_director.has_method("get_phase") and crisis_director.has_method("get_active_crisis_id"):
				var phase_name: String = String(crisis_director.call("get_phase"))
				var crisis_id: String = String(crisis_director.call("get_active_crisis_id"))
				reached_final = (phase_name == "final" and crisis_id == "protocol_omega_core")

	_tick_crisis_director(0.1)
	_tick_biohazard_leak_spawner(0.1)
	_tick_genome_cache_spawner(0.1)
	_update_crisis_debug_banner()
	if reached_final:
		print("Debug jump: moved directly to final event at %.1fs" % elapsed_seconds)
	else:
		print("Debug jump: moved to final-event threshold at %.1fs" % elapsed_seconds)

func _can_use_debug_xp_cheat() -> bool:
	if not debug_allow_grant_xp:
		return false
	if OS.has_feature("editor"):
		return true
	return OS.has_feature("dev_cheats")

func _play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void:
	if _sfx_reentry_guard:
		return
	if audio_manager == null:
		return
	if audio_manager == self:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	_sfx_reentry_guard = true
	audio_manager.call("play_sfx", event_id, volume_db_offset, pitch_scale)
	_sfx_reentry_guard = false

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

	if pause_fps_option_button != null:
		var pause_fps_limit_callable := Callable(self, "_on_pause_fps_limit_selected")
		if not pause_fps_option_button.item_selected.is_connected(pause_fps_limit_callable):
			pause_fps_option_button.item_selected.connect(pause_fps_limit_callable)

	if variant_cast_panel != null:
		variant_cast_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		var variant_panel_enter_callable := Callable(self, "_on_variant_cast_panel_mouse_entered")
		if not variant_cast_panel.mouse_entered.is_connected(variant_panel_enter_callable):
			variant_cast_panel.mouse_entered.connect(variant_panel_enter_callable)
		var variant_panel_exit_callable := Callable(self, "_on_variant_cast_panel_mouse_exited")
		if not variant_cast_panel.mouse_exited.is_connected(variant_panel_exit_callable):
			variant_cast_panel.mouse_exited.connect(variant_panel_exit_callable)

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
	_refresh_pause_fps_limit_control()
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

func _refresh_pause_fps_limit_control() -> void:
	if pause_fps_option_button == null:
		return

	var fps_limit_ids: Array[String] = GAMEPLAY_SETTINGS.get_ordered_fps_limit_ids()
	if fps_limit_ids.is_empty():
		return

	var saved_fps_limit_id: String = GAMEPLAY_SETTINGS.load_fps_limit_id()
	pause_fps_option_button.clear()
	var selected_index: int = 0
	for index in range(fps_limit_ids.size()):
		var fps_limit_id: String = String(fps_limit_ids[index])
		pause_fps_option_button.add_item(GAMEPLAY_SETTINGS.get_fps_limit_display_name(fps_limit_id))
		if fps_limit_id == saved_fps_limit_id:
			selected_index = index
	pause_fps_option_button.select(selected_index)

func _on_pause_fps_limit_selected(index: int) -> void:
	if _syncing_audio_controls:
		return
	if pause_fps_option_button == null:
		return

	var fps_limit_ids: Array[String] = GAMEPLAY_SETTINGS.get_ordered_fps_limit_ids()
	if fps_limit_ids.is_empty():
		return

	var clamped_index: int = clampi(index, 0, fps_limit_ids.size() - 1)
	var fps_limit_id: String = GAMEPLAY_SETTINGS.sanitize_fps_limit_id(String(fps_limit_ids[clamped_index]))
	GAMEPLAY_SETTINGS.save_fps_limit_id(fps_limit_id)
	GAMEPLAY_SETTINGS.apply_fps_limit_id(fps_limit_id)

	_syncing_audio_controls = true
	pause_fps_option_button.select(clamped_index)
	_syncing_audio_controls = false

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
	_play_sfx("sfx_levelup")
	return true

func _build_crisis_reward_options(crisis_id: String) -> Array:
	var configured_options: Array = []
	match crisis_id:
		"uv_sweep_grid", "quarantine_lattice":
			configured_options = [
				_build_crisis_reward_option(
					"focused_instability",
					"Focused Instability",
					"+16% ability damage.",
					"offense_boost"
				),
				_build_crisis_reward_option(
					"kinetic_reframing",
					"Kinetic Reframing",
					"+14% movement speed.",
					"move_speed_boost"
				),
				_build_crisis_reward_option(
					"adaptive_shelling",
					"Adaptive Shelling",
					"-14% incoming damage, -2% movement speed.",
					"defense_boost"
				),
				_build_crisis_reward_option(
					"metabolic_surge",
					"Metabolic Surge",
					"+18% orbiter speed and +18% trail lifetime.",
					"cooldown_boost",
					"pandemic",
					[],
					["infective_secretion", "virion_orbit"]
				),
				_build_crisis_reward_option(
					"containment_breach",
					"Containment Breach",
					"+14% ability damage and +8% movement speed.",
					"proto_pulse"
				)
			]
		"hunter_deployment", "containment_warden":
			configured_options = [
				_build_crisis_reward_option(
					"lance_overclock",
					"Lance Overclock",
					"+18% ability damage and +14% pulse radius.",
					"puncture_lance",
					"lytic",
					[],
					["razor_halo", "puncture_lance"]
				),
				_build_crisis_reward_option(
					"metabolic_surge",
					"Metabolic Surge",
					"+18% orbiter speed and +18% trail lifetime.",
					"cooldown_boost",
					"pandemic",
					[],
					["infective_secretion", "virion_orbit"]
				),
				_build_crisis_reward_option(
					"containment_breach",
					"Containment Breach",
					"+14% ability damage and +8% movement speed.",
					"proto_pulse"
				),
				_build_crisis_reward_option(
					"epidemic_catalyst",
					"Epidemic Catalyst",
					"+24% trail lifetime and +15% ability damage.",
					"chain_bloom",
					"pandemic",
					[],
					["infective_secretion", "virion_orbit", "chain_bloom"]
				),
				_build_crisis_reward_option(
					"viral_density",
					"Viral Density",
					"+20% orbiter speed and +16% trail lifetime.",
					"infective_secretion",
					"pandemic",
					[],
					["infective_secretion", "chain_bloom"]
				),
				_build_crisis_reward_option(
					"hemotrophic_loop",
					"Hemotrophic Loop",
					"+1.2 HP regen/s and +20 max HP.",
					"leech_tendril",
					"parasitic",
					[],
					["leech_tendril", "protein_shell", "host_override"]
				),
				_build_crisis_reward_option(
					"focused_instability",
					"Focused Instability",
					"+16% ability damage.",
					"offense_boost"
				)
			]
		"decon_flood", "antiviral_drone_burst", "containment_seal":
			configured_options = [
				_build_crisis_reward_option(
					"epidemic_catalyst",
					"Epidemic Catalyst",
					"+24% trail lifetime and +15% ability damage.",
					"chain_bloom",
					"pandemic",
					[],
					["infective_secretion", "virion_orbit", "chain_bloom"]
				),
				_build_crisis_reward_option(
					"viral_density",
					"Viral Density",
					"+20% orbiter speed and +16% trail lifetime.",
					"infective_secretion",
					"pandemic",
					[],
					["infective_secretion", "chain_bloom"]
				),
				_build_crisis_reward_option(
					"hemotrophic_loop",
					"Hemotrophic Loop",
					"+1.2 HP regen/s and +20 max HP.",
					"leech_tendril",
					"parasitic",
					[],
					["leech_tendril", "protein_shell", "host_override"]
				),
				_build_crisis_reward_option(
					"lance_overclock",
					"Lance Overclock",
					"+18% ability damage and +14% pulse radius.",
					"puncture_lance",
					"lytic",
					[],
					["razor_halo", "puncture_lance"]
				),
				_build_crisis_reward_option(
					"adaptive_shelling",
					"Adaptive Shelling",
					"-14% incoming damage, -2% movement speed.",
					"defense_boost"
				),
				_build_crisis_reward_option(
					"kinetic_reframing",
					"Kinetic Reframing",
					"+14% movement speed.",
					"move_speed_boost"
				)
			]
		_:
			configured_options = [
				_build_crisis_reward_option(
					"fallback_hardened_membrane",
					"Hardened Membrane",
					"+20 max HP for this run.",
					"protein_shell"
				),
				_build_crisis_reward_option(
					"fallback_spike_density",
					"Spike Density",
					"+16% ability damage for this run.",
					"razor_halo"
				),
				_build_crisis_reward_option(
					"fallback_metabolic_burst",
					"Metabolic Burst",
					"+14% movement speed for this run.",
					"leech_tendril"
				)
			]
	return _select_crisis_reward_options_for_current_build(configured_options, 3)

func _build_crisis_reward_option(
	option_id: String,
	option_name: String,
	option_description: String,
	icon_id: String,
	variant_id: String = "",
	required_mutations_all: Array = [],
	required_mutations_any: Array = []
) -> Dictionary:
	return {
		"id": option_id,
		"name": option_name,
		"description": option_description,
		"short": option_description,
		"icon_id": icon_id,
		"variant_id": variant_id.strip_edges().to_lower(),
		"required_mutations_all": required_mutations_all.duplicate(),
		"required_mutations_any": required_mutations_any.duplicate(),
		"is_crisis_reward": true
	}

func _select_crisis_reward_options_for_current_build(configured_options: Array, target_count: int = 3) -> Array:
	var safe_target_count: int = maxi(1, target_count)
	var eligible_options: Array = []
	for option_variant in configured_options:
		if not (option_variant is Dictionary):
			continue
		var option: Dictionary = option_variant
		if not _is_crisis_reward_option_eligible(option):
			continue
		eligible_options.append(option)

	var selected_options: Array = []
	var used_ids: Dictionary = {}
	var current_variant_id: String = _get_current_variant_id_for_rewards()
	var universal_options: Array = []
	var variant_aligned_options: Array = []
	for option_variant in eligible_options:
		if not (option_variant is Dictionary):
			continue
		var option: Dictionary = option_variant
		var option_variant_id: String = String(option.get("variant_id", "")).strip_edges().to_lower()
		if option_variant_id.is_empty():
			universal_options.append(option)
		elif not current_variant_id.is_empty() and option_variant_id == current_variant_id:
			variant_aligned_options.append(option)

	var first_pick: Dictionary = _pick_random_unique_reward_option(universal_options, used_ids)
	if not first_pick.is_empty():
		selected_options.append(first_pick)
	var second_pick: Dictionary = _pick_random_unique_reward_option(variant_aligned_options, used_ids)
	if not second_pick.is_empty():
		selected_options.append(second_pick)

	while selected_options.size() < safe_target_count:
		var next_option: Dictionary = _pick_random_unique_reward_option(eligible_options, used_ids)
		if next_option.is_empty():
			break
		selected_options.append(next_option)

	if selected_options.size() >= safe_target_count:
		return selected_options

	var fallback_options: Array = [
		_build_crisis_reward_option("fallback_hardened_membrane", "Hardened Membrane", "+20 max HP for this run.", "protein_shell"),
		_build_crisis_reward_option("fallback_spike_density", "Spike Density", "+16% ability damage for this run.", "razor_halo"),
		_build_crisis_reward_option("fallback_metabolic_burst", "Metabolic Burst", "+14% movement speed for this run.", "leech_tendril")
	]
	while selected_options.size() < safe_target_count:
		var fallback_option: Dictionary = _pick_random_unique_reward_option(fallback_options, used_ids)
		if fallback_option.is_empty():
			break
		selected_options.append(fallback_option)

	return selected_options

func _pick_random_unique_reward_option(options: Array, used_ids: Dictionary) -> Dictionary:
	var candidates: Array = []
	for option_variant in options:
		if not (option_variant is Dictionary):
			continue
		var option: Dictionary = option_variant
		var option_id: String = String(option.get("id", "")).strip_edges().to_lower()
		if option_id.is_empty():
			continue
		if used_ids.has(option_id):
			continue
		candidates.append(option)

	if candidates.is_empty():
		return {}

	var selected_index: int = randi_range(0, candidates.size() - 1)
	var selected_option: Dictionary = candidates[selected_index]
	var selected_id: String = String(selected_option.get("id", "")).strip_edges().to_lower()
	if not selected_id.is_empty():
		used_ids[selected_id] = true
	return selected_option

func _is_crisis_reward_option_eligible(option: Dictionary) -> bool:
	var required_variant_id: String = String(option.get("variant_id", "")).strip_edges().to_lower()
	var current_variant_id: String = _get_current_variant_id_for_rewards()
	if not required_variant_id.is_empty():
		if current_variant_id.is_empty():
			return false
		if required_variant_id != current_variant_id:
			return false
	if not _are_required_mutations_owned(option.get("required_mutations_all", []), false):
		return false
	if not _are_required_mutations_owned(option.get("required_mutations_any", []), true):
		return false
	return true

func _are_required_mutations_owned(required_mutations_variant: Variant, require_any: bool) -> bool:
	if not (required_mutations_variant is Array):
		return true
	var required_mutations: Array = required_mutations_variant
	if required_mutations.is_empty():
		return true
	if require_any:
		for raw_mutation_id in required_mutations:
			if _is_mutation_owned_for_rewards(String(raw_mutation_id)):
				return true
		return false
	for raw_mutation_id in required_mutations:
		if not _is_mutation_owned_for_rewards(String(raw_mutation_id)):
			return false
	return true

func _is_mutation_owned_for_rewards(mutation_id: String) -> bool:
	var normalized_mutation_id: String = mutation_id.strip_edges().to_lower()
	if normalized_mutation_id.is_empty():
		return false
	if mutation_system != null and mutation_system.has_method("get_mutation_level"):
		return int(mutation_system.call("get_mutation_level", normalized_mutation_id)) > 0
	return int(_run_mutation_inventory_levels.get(normalized_mutation_id, 0)) > 0

func _get_current_variant_id_for_rewards() -> String:
	if mutation_system == null:
		return ""
	if mutation_system.has_method("get_current_variant_id"):
		return String(mutation_system.call("get_current_variant_id")).strip_edges().to_lower()
	if mutation_system.has_method("get_current_lineage_id"):
		return String(mutation_system.call("get_current_lineage_id")).strip_edges().to_lower()
	return ""

func _apply_crisis_reward_choice(choice_index: int) -> bool:
	if choice_index < 0 or choice_index >= crisis_reward_options.size():
		return false
	if not (crisis_reward_options[choice_index] is Dictionary):
		return false

	var reward_option: Dictionary = crisis_reward_options[choice_index]
	var reward_id: String = String(reward_option.get("id", ""))
	var reward_name: String = String(reward_option.get("name", "Event Reward"))
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
		print("[GameManager] Event reward selected: %s (%s)" % [reward_name, reward_id])
	return true

func _apply_crisis_reward_effect(reward_id: String) -> bool:
	match reward_id:
		"focused_instability":
			_reward_module_damage_multiplier = _multiply_reward_stat_with_cap(_reward_module_damage_multiplier, 1.16, 1.0, 2.20)
		"kinetic_reframing":
			_reward_move_speed_multiplier = _multiply_reward_stat_with_cap(_reward_move_speed_multiplier, 1.14, 1.0, 1.65)
		"adaptive_shelling":
			_reward_external_damage_multiplier = _multiply_reward_stat_with_cap(_reward_external_damage_multiplier, 0.86, 0.62, 1.0)
			_reward_move_speed_multiplier = _multiply_reward_stat_with_cap(_reward_move_speed_multiplier, 0.98, 1.0, 1.65)
		"lance_overclock":
			_reward_module_damage_multiplier = _multiply_reward_stat_with_cap(_reward_module_damage_multiplier, 1.18, 1.0, 2.20)
			_reward_pulse_radius_multiplier = _multiply_reward_stat_with_cap(_reward_pulse_radius_multiplier, 1.14, 1.0, 1.70)
		"metabolic_surge":
			_reward_orbiter_speed_multiplier = _multiply_reward_stat_with_cap(_reward_orbiter_speed_multiplier, 1.18, 1.0, 1.95)
			_reward_acid_lifetime_multiplier = _multiply_reward_stat_with_cap(_reward_acid_lifetime_multiplier, 1.18, 1.0, 2.10)
		"containment_breach":
			_reward_module_damage_multiplier = _multiply_reward_stat_with_cap(_reward_module_damage_multiplier, 1.14, 1.0, 2.20)
			_reward_move_speed_multiplier = _multiply_reward_stat_with_cap(_reward_move_speed_multiplier, 1.08, 1.0, 1.65)
		"epidemic_catalyst":
			_reward_acid_lifetime_multiplier = _multiply_reward_stat_with_cap(_reward_acid_lifetime_multiplier, 1.24, 1.0, 2.10)
			_reward_module_damage_multiplier = _multiply_reward_stat_with_cap(_reward_module_damage_multiplier, 1.15, 1.0, 2.20)
		"viral_density":
			_reward_orbiter_speed_multiplier = _multiply_reward_stat_with_cap(_reward_orbiter_speed_multiplier, 1.20, 1.0, 1.95)
			_reward_acid_lifetime_multiplier = _multiply_reward_stat_with_cap(_reward_acid_lifetime_multiplier, 1.16, 1.0, 2.10)
		"hemotrophic_loop":
			_reward_passive_regen_per_second = minf(5.2, _reward_passive_regen_per_second + 1.2)
			_reward_bonus_max_hp_flat = mini(120, _reward_bonus_max_hp_flat + 20)
		"fallback_hardened_membrane":
			_reward_bonus_max_hp_flat = mini(120, _reward_bonus_max_hp_flat + 20)
		"fallback_spike_density":
			_reward_module_damage_multiplier = _multiply_reward_stat_with_cap(_reward_module_damage_multiplier, 1.16, 1.0, 2.20)
		"fallback_metabolic_burst":
			_reward_move_speed_multiplier = _multiply_reward_stat_with_cap(_reward_move_speed_multiplier, 1.14, 1.0, 1.65)
		_:
			return false
	return true

func _multiply_reward_stat_with_cap(current_value: float, factor: float, min_value: float, max_value: float) -> float:
	var safe_factor: float = maxf(0.0, factor)
	var multiplied_value: float = current_value * safe_factor
	return clampf(multiplied_value, min_value, max_value)

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

func _grant_biomass_bonus_for_reward_crisis(crisis_id: String) -> void:
	if not _is_biomass_bonus_crisis(crisis_id):
		return

	var player_node := player as Node
	if player_node == null or not is_instance_valid(player_node):
		player_node = get_tree().get_first_node_in_group("player")
	if player_node == null:
		return

	var biomass_nodes: Array = get_tree().get_nodes_in_group("biomass_pickups")
	if biomass_nodes.is_empty():
		return

	var collected_pickups: int = 0
	var total_bonus_xp: int = 0
	_mass_biomass_collect_active = true
	for biomass_variant in biomass_nodes:
		var biomass_node := biomass_variant as Node
		if biomass_node == null or not is_instance_valid(biomass_node):
			continue
		if not biomass_node.is_inside_tree():
			continue
		if not biomass_node.has_method("_on_body_entered") and not biomass_node.has_method("collect_immediately"):
			continue

		var xp_variant: Variant = biomass_node.get("xp_value")
		if xp_variant != null:
			total_bonus_xp += maxi(0, int(xp_variant))

		if biomass_node.has_method("collect_immediately"):
			biomass_node.call("collect_immediately")
		else:
			biomass_node.call("_on_body_entered", player_node)
		collected_pickups += 1

	_mass_biomass_collect_active = false

	if collected_pickups <= 0:
		return

	_play_sfx("sfx_pickup_biomass", -3.0, 1.08)
	_queue_runtime_popup(
		"Containment Bonus",
		"Absorbed all map biomass (+%d XP)." % total_bonus_xp,
		false,
		2.4,
		false,
		runtime_popup_top_offset + 30.0
	)
	if debug_log_crisis_timeline:
		print("[GameManager] Biomass bonus applied after %s: %d pickups (+%d XP)" % [crisis_id, collected_pickups, total_bonus_xp])

func _finish_crisis_reward_prompt() -> void:
	var completed_reward_crisis_id: String = active_crisis_reward_id
	crisis_reward_selection_active = false
	active_crisis_reward_id = ""
	crisis_reward_options.clear()
	_complete_reward_phase_if_active()
	_grant_biomass_bonus_for_reward_crisis(completed_reward_crisis_id)

	if pending_genome_cache_prompt_count > 0:
		pending_genome_cache_prompt_count -= 1
		var did_open_cache_prompt: bool = _open_genome_cache_prompt(false, true)
		if did_open_cache_prompt:
			return
		pending_genome_cache_prompt_count = 0

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
		print("[GameManager] Event reward phase completed early via selection")

func _finish_genome_cache_prompt() -> void:
	genome_cache_selection_active = false

	if pending_genome_cache_prompt_count > 0:
		pending_genome_cache_prompt_count -= 1
		var did_open_cache_prompt: bool = _open_genome_cache_prompt(false, true)
		if did_open_cache_prompt:
			return
		pending_genome_cache_prompt_count = 0

	if pending_levelup_count > 0:
		pending_levelup_count -= 1
		var did_open_levelup_prompt: bool = _open_levelup_prompt(false)
		if did_open_levelup_prompt:
			return
		pending_levelup_count = 0

	_close_levelup_prompt()

func _open_genome_cache_prompt(play_sound: bool = true, allow_when_levelup_paused: bool = false) -> bool:
	if run_ended:
		return false
	if run_paused_for_menu:
		pending_genome_cache_prompt_count += 1
		return false
	if run_paused_for_levelup and not allow_when_levelup_paused:
		pending_genome_cache_prompt_count += 1
		return false
	if crisis_reward_selection_active or lineage_selection_active:
		pending_genome_cache_prompt_count += 1
		return false

	var options: Array = []
	if mutation_system != null and mutation_system.has_method("get_stat_only_options"):
		var options_variant: Variant = mutation_system.call("get_stat_only_options", 3)
		if options_variant is Array:
			options = options_variant
	if options.is_empty():
		return false

	levelup_options = options
	genome_cache_selection_active = true
	crisis_reward_selection_active = false
	lineage_selection_active = false
	active_crisis_reward_id = ""
	crisis_reward_options.clear()
	_set_levelup_mode(false)
	_set_choice_button_text(levelup_choice_1, levelup_choice_1_icon, levelup_choice_1_text, levelup_options, 0)
	_set_choice_button_text(levelup_choice_2, levelup_choice_2_icon, levelup_choice_2_text, levelup_options, 1)
	_set_choice_button_text(levelup_choice_3, levelup_choice_3_icon, levelup_choice_3_text, levelup_options, 2)
	_refresh_choice_panel_labels()

	run_paused_for_levelup = true
	_set_gameplay_active(false)
	if levelup_ui != null:
		levelup_ui.visible = true
	if play_sound:
		_play_sfx("sfx_levelup")
	return true

func _open_levelup_prompt(play_sound: bool = true) -> bool:
	if run_ended:
		return false
	if run_paused_for_menu:
		_queue_pending_levelup("pause_menu_active")
		return false
	if crisis_reward_selection_active:
		_queue_pending_levelup("crisis_reward_active")
		return false
	if genome_cache_selection_active:
		_queue_pending_levelup("genome_cache_active")
		return false

	crisis_reward_selection_active = false
	genome_cache_selection_active = false
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
		_play_sfx("sfx_levelup")
	_set_gameplay_active(false)
	if levelup_ui != null:
		levelup_ui.visible = true
	return true

func _close_levelup_prompt() -> void:
	if levelup_ui != null:
		levelup_ui.visible = false
	run_paused_for_levelup = false
	crisis_reward_selection_active = false
	genome_cache_selection_active = false
	active_crisis_reward_id = ""
	crisis_reward_options.clear()
	_refresh_lineage_labels()
	_set_gameplay_active(true)
