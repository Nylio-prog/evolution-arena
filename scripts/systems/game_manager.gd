extends Node2D

const BIOMASS_PICKUP_SCENE: PackedScene = preload("res://scenes/systems/biomass_pickup.tscn")
const CONTAINMENT_SWEEP_SCENE: PackedScene = preload("res://scenes/systems/containment_sweep_hazard.tscn")
const BIOHAZARD_LEAK_ZONE_SCENE: PackedScene = preload("res://scenes/systems/biohazard_leak_zone.tscn")
const STRAIN_BLOOM_ELITE_SCENE: PackedScene = preload("res://scenes/actors/enemy_dasher.tscn")
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
@onready var audio_button: Button = get_node_or_null("UiHud/AudioButton")
@onready var audio_panel: Control = get_node_or_null("UiHud/AudioPanel")
@onready var sfx_slider: HSlider = get_node_or_null("UiHud/AudioPanel/Padding/Rows/SfxSlider")
@onready var sfx_mute_toggle: CheckButton = get_node_or_null("UiHud/AudioPanel/Padding/Rows/SfxMuteToggle")
@onready var music_slider: HSlider = get_node_or_null("UiHud/AudioPanel/Padding/Rows/MusicSlider")
@onready var music_mute_toggle: CheckButton = get_node_or_null("UiHud/AudioPanel/Padding/Rows/MusicMuteToggle")
@onready var levelup_ui: CanvasLayer = get_node_or_null("UiLevelup")
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
@onready var game_over_main_menu_button: Button = get_node_or_null("GameOver/Root/MainMenuButton")
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
var game_over_main_menu_requested: bool = false
var _last_player_hp: int = -1
var _syncing_audio_controls: bool = false
var _active_containment_sweeps: Array[Node2D] = []
var _active_biohazard_leaks: Array[Node2D] = []
var _biohazard_leak_spawner_active: bool = false
var _biohazard_leak_spawn_accumulator: float = 0.0
var _biohazard_leak_position_sample_accumulator: float = 0.0
var _biohazard_leak_elapsed_seconds: float = 0.0
var _biohazard_recent_player_positions: Array = []
var _strain_bloom_elite_target: Node2D
var _strain_bloom_active: bool = false
var _strain_bloom_elite_killed: bool = false
@export var debug_allow_grant_xp: bool = false
@export var debug_grant_xp_amount: int = 20
@export var debug_fast_forward_seconds: float = 10.0
@export var debug_log_crisis_timeline: bool = true
@export var debug_show_crisis_banner: bool = true
@export var crisis_spawn_wait_multiplier_active: float = 1.6
@export var containment_sweep_concurrent_count: int = 2
@export var containment_sweep_spacing: float = 220.0
@export var biohazard_leak_initial_spawn_count: int = 0
@export var biohazard_leak_spawn_interval_seconds: float = 1.0
@export var biohazard_leak_player_position_sample_interval_seconds: float = 0.20
@export var biohazard_leak_player_position_history_seconds: float = 10.0
@export var biohazard_leak_player_position_min_age_seconds: float = 1.2
@export var biohazard_leak_max_active_zones: int = 32
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

const LINEAGE_CHOICES: Array[String] = ["predator", "swarm", "bulwark"]

func _ready() -> void:
	_reset_runtime_state()

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

	for node in get_tree().get_nodes_in_group("biomass_pickups"):
		_connect_biomass_pickup(node as Node)
	for node in get_tree().get_nodes_in_group("enemies"):
		_connect_enemy_death(node as Node)
	get_tree().connect("node_added", Callable(self, "_on_tree_node_added"))

	if game_over_ui != null:
		game_over_ui.visible = false

	if game_over_main_menu_button != null:
		game_over_main_menu_button.disabled = false
		var game_over_main_menu_callable := Callable(self, "_on_game_over_main_menu_pressed")
		if not game_over_main_menu_button.pressed.is_connected(game_over_main_menu_callable):
			game_over_main_menu_button.pressed.connect(game_over_main_menu_callable)

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
	game_over_main_menu_requested = false
	_last_player_hp = -1
	_clear_containment_sweep()
	_clear_biohazard_leaks()
	_clear_strain_bloom_state()
	if crisis_director != null and crisis_director.has_method("reset_runtime_state"):
		crisis_director.call("reset_runtime_state")

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
	_set_crisis_spawn_throttle(crisis_active)
	if new_phase == "reward" and crisis_id == "strain_bloom":
		_handle_strain_bloom_timeout()
	if _strain_bloom_active and crisis_id != "strain_bloom":
		_clear_strain_bloom_state()
	if new_phase != "active" or crisis_id != "containment_sweep":
		_clear_containment_sweep()
	if new_phase != "active" or crisis_id != "biohazard_leak":
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

func _spawn_containment_sweep(active_duration_seconds: float) -> void:
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
	var concurrent_count: int = maxi(1, containment_sweep_concurrent_count)
	var spacing: float = maxf(40.0, containment_sweep_spacing)
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
	if _active_biohazard_leaks.size() >= max_active_zones:
		return

	_biohazard_leak_spawn_accumulator += delta
	var spawn_interval: float = maxf(0.05, biohazard_leak_spawn_interval_seconds)
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

func _record_biohazard_player_position(position: Vector2) -> void:
	_biohazard_recent_player_positions.append({
		"position": position,
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
	_fail_run_immediately("Containment sweep contact")

func _fail_run_immediately(reason_text: String = "") -> void:
	if run_ended:
		return
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

	var phase_name: String = String(crisis_director.call("get_phase"))
	var crisis_id: String = ""
	var phase_seconds_remaining: float = 0.0
	var next_crisis_seconds: float = 0.0

	if crisis_director.has_method("get_active_crisis_id"):
		crisis_id = String(crisis_director.call("get_active_crisis_id"))
	if crisis_director.has_method("get_phase_time_remaining"):
		phase_seconds_remaining = float(crisis_director.call("get_phase_time_remaining"))
	if crisis_director.has_method("get_time_until_next_crisis"):
		next_crisis_seconds = float(crisis_director.call("get_time_until_next_crisis", elapsed_seconds))

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
					return "Evade containment sweep"
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
			return "Survive purge protocol"
		"victory":
			return "Run clear - outbreak ascendant"
		_:
			return "--"

func _on_crisis_started(crisis_id: String, is_final: bool, duration_seconds: float) -> void:
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
	if not debug_log_crisis_timeline:
		return
	print("[GameManager] Crisis reward started: %s (%.1fs)" % [crisis_id, duration_seconds])

func _on_final_crisis_completed() -> void:
	_clear_containment_sweep()
	_clear_biohazard_leaks()
	_clear_strain_bloom_state()
	if not debug_log_crisis_timeline:
		return
	print("[GameManager] Final crisis completed at %.1fs" % elapsed_seconds)

func _get_crisis_phase_time_remaining() -> float:
	if crisis_director == null:
		return 0.0
	if not crisis_director.has_method("get_phase_time_remaining"):
		return 0.0
	return float(crisis_director.call("get_phase_time_remaining"))

func _process(delta: float) -> void:
	if run_ended:
		return
	if run_paused_for_menu:
		return
	if run_paused_for_levelup:
		return
	elapsed_seconds += delta
	_update_timer_label()
	_tick_crisis_director(delta)
	_tick_biohazard_leak_spawner(delta)
	_update_crisis_debug_banner()

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
	_refresh_metabolism_hud()

func _refresh_lineage_labels() -> void:
	var current_lineage_name: String = _get_current_lineage_name()

	if lineage_label != null:
		lineage_label.text = "Lineage: %s" % current_lineage_name

	if levelup_lineage_prompt_label != null:
		if lineage_selection_active:
			levelup_lineage_prompt_label.text = "Choose your lineage"
		else:
			levelup_lineage_prompt_label.text = "Choose your mutation"

	if levelup_help_label != null:
		if lineage_selection_active:
			levelup_help_label.text = "Choose once. It grants a core mutation and biases future options."
		else:
			levelup_help_label.text = "Tip: * marks options favored by your lineage."

func _refresh_metabolism_hud() -> void:
	if metabolism_label == null:
		return
	if mutation_system == null:
		metabolism_label.visible = false
		return
	if not mutation_system.has_method("get_mutation_level"):
		metabolism_label.visible = false
		return

	var metabolism_level: int = int(mutation_system.call("get_mutation_level", "metabolism"))
	if metabolism_level <= 0:
		metabolism_label.visible = false
		return

	var regen_per_second: float = 0.0
	if mutation_system.has_method("get_metabolism_regen_per_second"):
		regen_per_second = float(mutation_system.call("get_metabolism_regen_per_second"))

	metabolism_label.visible = true
	metabolism_label.text = "Regen: +%.1f/s (L%d)" % [regen_per_second, metabolism_level]

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

	pending_levelup_count = 0
	run_paused_for_levelup = false
	run_paused_for_menu = false
	if levelup_ui != null:
		levelup_ui.visible = false
	if pause_menu_ui != null:
		pause_menu_ui.visible = false
	if crisis_debug_label != null:
		crisis_debug_label.visible = false
	_clear_containment_sweep()
	_clear_biohazard_leaks()
	_clear_strain_bloom_state()
	run_ended = true
	_play_sfx("player_death")
	_stop_music()
	_set_gameplay_active(false)
	_show_game_over()

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

	if game_over_ui != null:
		game_over_ui.visible = true

func _update_timer_label() -> void:
	if timer_label == null:
		return
	timer_label.text = "Time: %ds" % int(elapsed_seconds)

func _on_player_leveled_up(_new_level: int) -> void:
	if run_ended:
		return
	if run_paused_for_menu:
		pending_levelup_count += 1
		return
	if run_paused_for_levelup:
		pending_levelup_count += 1
		return

	_open_levelup_prompt()

func _on_levelup_choice_pressed(choice_index: int) -> void:
	if run_ended:
		return
	_play_sfx("ui_click")

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
	if mutation_id.is_empty() or not MUTATION_ICON_BY_ID.has(mutation_id):
		icon.texture = null
		icon.visible = false
		return

	var icon_texture_variant: Variant = MUTATION_ICON_BY_ID.get(mutation_id, null)
	var icon_texture: Texture2D = icon_texture_variant as Texture2D
	icon.texture = icon_texture
	icon.visible = icon_texture != null

func _format_mutation_option_text(option: Dictionary) -> String:
	var mutation_name: String = String(option.get("name", "Mutation"))
	var next_level: int = int(option.get("next_level", 1))
	var summary_text: String = String(option.get("short", ""))
	var favored: bool = bool(option.get("is_favored", false))
	if favored:
		mutation_name = "* " + mutation_name
	if summary_text.is_empty():
		summary_text = String(option.get("description", ""))

	if summary_text.is_empty():
		return "%s L%d" % [mutation_name, next_level]
	return "%s L%d\n%s" % [mutation_name, next_level, summary_text]

func _format_mutation_option_bbcode(option: Dictionary) -> String:
	var mutation_name: String = String(option.get("name", "Mutation"))
	var next_level: int = int(option.get("next_level", 1))
	var summary_text: String = String(option.get("short", ""))
	var favored: bool = bool(option.get("is_favored", false))
	var title_text: String = "%s L%d" % [mutation_name, next_level]
	if favored:
		title_text = "* " + title_text
	if summary_text.is_empty():
		summary_text = String(option.get("description", ""))

	if summary_text.is_empty():
		if favored:
			return "[center][b][color=#ffd966]%s[/color][/b][/center]" % [title_text]
		return "[center][b]%s[/b][/center]" % [title_text]

	if favored:
		return "[center][b][color=#ffd966]%s[/color][/b]\n%s[/center]" % [title_text, summary_text]
	return "[center][b]%s[/b]\n%s[/center]" % [title_text, summary_text]

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
	if levelup_lineage_prompt_label != null:
		levelup_lineage_prompt_label.text = "Choose your lineage"
	_set_lineage_choice_text(
		lineage_choice_1,
		lineage_choice_1_text,
		"Predator",
		"Aggressive close-range pressure",
		"Starter: Pulse Nova L1"
	)
	_set_lineage_choice_text(
		lineage_choice_2,
		lineage_choice_2_text,
		"Swarm",
		"Orbit and area control growth",
		"Starter: Orbiters L1"
	)
	_set_lineage_choice_text(
		lineage_choice_3,
		lineage_choice_3_text,
		"Bulwark",
		"Defensive sustain and spacing",
		"Starter: Membrane L1"
	)

func _set_lineage_choice_text(
	button: Button,
	rich_text: RichTextLabel,
	title_text: String,
	description_text: String,
	starter_text: String
) -> void:
	if button == null:
		return
	if rich_text == null:
		button.text = "%s\n%s\n%s" % [title_text, description_text, starter_text]
		return
	button.text = ""
	rich_text.text = _format_lineage_choice_bbcode(title_text, description_text, starter_text)

func _format_lineage_choice_bbcode(title_text: String, description_text: String, starter_text: String) -> String:
	return "[center][b]%s[/b]\n%s\n[color=#9ec4d6]%s[/color][/center]" % [
		title_text,
		description_text,
		starter_text
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

func _can_use_debug_xp_cheat() -> bool:
	if not debug_allow_grant_xp:
		return false
	if OS.has_feature("editor"):
		return true
	return OS.has_feature("dev_cheats")

func _play_sfx(event_id: String) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id)

func _setup_audio_controls() -> void:
	if audio_panel != null:
		audio_panel.visible = false
	if pause_options_panel != null:
		pause_options_panel.visible = false

	if audio_button != null:
		var audio_button_callable := Callable(self, "_on_audio_button_pressed")
		if not audio_button.pressed.is_connected(audio_button_callable):
			audio_button.pressed.connect(audio_button_callable)

	if sfx_slider != null:
		var sfx_slider_callable := Callable(self, "_on_sfx_slider_value_changed")
		if not sfx_slider.value_changed.is_connected(sfx_slider_callable):
			sfx_slider.value_changed.connect(sfx_slider_callable)
	if pause_sfx_slider != null:
		var pause_sfx_slider_callable := Callable(self, "_on_sfx_slider_value_changed")
		if not pause_sfx_slider.value_changed.is_connected(pause_sfx_slider_callable):
			pause_sfx_slider.value_changed.connect(pause_sfx_slider_callable)

	if sfx_mute_toggle != null:
		var sfx_mute_callable := Callable(self, "_on_sfx_mute_toggled")
		if not sfx_mute_toggle.toggled.is_connected(sfx_mute_callable):
			sfx_mute_toggle.toggled.connect(sfx_mute_callable)
	if pause_sfx_mute_toggle != null:
		var pause_sfx_mute_callable := Callable(self, "_on_sfx_mute_toggled")
		if not pause_sfx_mute_toggle.toggled.is_connected(pause_sfx_mute_callable):
			pause_sfx_mute_toggle.toggled.connect(pause_sfx_mute_callable)

	if music_slider != null:
		var music_slider_callable := Callable(self, "_on_music_slider_value_changed")
		if not music_slider.value_changed.is_connected(music_slider_callable):
			music_slider.value_changed.connect(music_slider_callable)
	if pause_music_slider != null:
		var pause_music_slider_callable := Callable(self, "_on_music_slider_value_changed")
		if not pause_music_slider.value_changed.is_connected(pause_music_slider_callable):
			pause_music_slider.value_changed.connect(pause_music_slider_callable)

	if music_mute_toggle != null:
		var music_mute_callable := Callable(self, "_on_music_mute_toggled")
		if not music_mute_toggle.toggled.is_connected(music_mute_callable):
			music_mute_toggle.toggled.connect(music_mute_callable)
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
	if sfx_slider != null:
		sfx_slider.value = value
	if pause_sfx_slider != null:
		pause_sfx_slider.value = value

func _set_music_slider_values(value: float) -> void:
	if music_slider != null:
		music_slider.value = value
	if pause_music_slider != null:
		pause_music_slider.value = value

func _set_sfx_mute_values(value: bool) -> void:
	if sfx_mute_toggle != null:
		sfx_mute_toggle.button_pressed = value
	if pause_sfx_mute_toggle != null:
		pause_sfx_mute_toggle.button_pressed = value

func _set_music_mute_values(value: bool) -> void:
	if music_mute_toggle != null:
		music_mute_toggle.button_pressed = value
	if pause_music_mute_toggle != null:
		pause_music_mute_toggle.button_pressed = value

func _on_audio_button_pressed() -> void:
	if audio_panel != null:
		audio_panel.visible = not audio_panel.visible
	_play_sfx("ui_click")

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

func _open_levelup_prompt(play_sound: bool = true) -> bool:
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
	_set_gameplay_active(true)
