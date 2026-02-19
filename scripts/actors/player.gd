extends CharacterBody2D

signal hp_changed(current_hp: int, max_hp: int)
signal died

@export var move_speed: float = 260.0
@export var max_hp: int = 100
@export var invulnerability_seconds: float = 0.5
@export var visual_radius: float = 12.0
@export var lineage_accent_color: Color = Color(1, 1, 1, 0)
@export var lineage_accent_width: float = 2.0
@export var idle_animation_name: StringName = &"idle"
@export var move_animation_name: StringName = &"move"
@export var hit_animation_name: StringName = &"hit"
@export var visual_offset: Vector2 = Vector2.ZERO
@export var sprite_scale: Vector2 = Vector2.ONE
@export var sprite_modulate: Color = Color(1, 1, 1, 1)
@export var hit_animation_timeout_seconds: float = 0.24
@export var debug_log_damage: bool = false
@export var clamp_to_viewport_bounds: bool = true
@export var movement_bounds_extra_margin: float = 0.0
@export var world_health_ui_offset: Vector2 = Vector2(0, 44)
@export var world_health_ui_size: Vector2 = Vector2(132, 18)
@export var world_health_ui_z_index: int = 500
@export var world_health_text_vertical_nudge: float = -2.0

var current_hp: int
var _invulnerable_until_ms: int = 0
var incoming_damage_multiplier: float = 1.0
var _is_playing_hit_animation: bool = false
var _base_move_speed: float = 0.0
var _base_max_hp: int = 0
var _bonus_move_speed_multiplier: float = 1.0
var _bonus_max_hp_flat: int = 0
var _module_incoming_damage_multiplier: float = 1.0
var _external_incoming_damage_multiplier: float = 1.0
var _stat_move_speed_multiplier: float = 1.0
var _stat_max_hp_flat: int = 0
var _stat_incoming_damage_multiplier: float = 1.0
var _block_chance: float = 0.0
var _pickup_radius_multiplier: float = 1.0
var _hit_animation_timeout_left: float = 0.0
var _world_health_ui_root: Node2D
var _world_health_bar: ProgressBar
var _world_health_text: Label
var _world_health_fill_normal: StyleBoxFlat
var _world_health_fill_warning: StyleBoxFlat
var _world_health_fill_critical: StyleBoxFlat
var _world_movement_bounds: Rect2 = Rect2()
var _use_world_movement_bounds: bool = false

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var follow_camera: Camera2D = get_node_or_null("Camera2D")

func _ready() -> void:
	_base_move_speed = move_speed
	_base_max_hp = max_hp
	current_hp = max_hp
	_refresh_runtime_stats()
	_refresh_incoming_damage_multiplier()
	add_to_group("player")
	_setup_animated_sprite()
	_ensure_world_health_ui()
	if not hp_changed.is_connected(Callable(self, "_on_hp_changed_local")):
		hp_changed.connect(Callable(self, "_on_hp_changed_local"))
	hp_changed.emit(current_hp, max_hp)
	queue_redraw()

func _draw() -> void:
	if lineage_accent_color.a > 0.01:
		draw_arc(Vector2.ZERO, visual_radius + 4.0, 0.0, TAU, 48, lineage_accent_color, lineage_accent_width, true)

func _physics_process(_delta: float) -> void:
	if _is_playing_hit_animation:
		_hit_animation_timeout_left = maxf(0.0, _hit_animation_timeout_left - _delta)
		if _hit_animation_timeout_left <= 0.0:
			_is_playing_hit_animation = false
			_play_base_animation(velocity.length() > 0.01)
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed
	move_and_slide()
	_apply_movement_bounds()
	_update_animation_state(input_vector.length() > 0.01)

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	if current_hp <= 0:
		return

	var now_ms := Time.get_ticks_msec()
	if now_ms < _invulnerable_until_ms:
		return

	var final_amount: int = max(1, int(round(float(amount) * incoming_damage_multiplier)))
	_invulnerable_until_ms = now_ms + int(invulnerability_seconds * 1000.0)
	_apply_damage_value(final_amount, amount, false)

func take_dot_damage(amount: int) -> void:
	if amount <= 0:
		return
	if current_hp <= 0:
		return

	var final_amount: int = max(1, int(round(float(amount) * incoming_damage_multiplier)))
	_apply_damage_value(final_amount, amount, true)

func force_die() -> void:
	if current_hp <= 0:
		return
	current_hp = 0
	hp_changed.emit(current_hp, max_hp)
	died.emit()

func heal(amount: int) -> void:
	if amount <= 0:
		return
	if current_hp <= 0:
		return

	var previous_hp: int = current_hp
	current_hp = mini(max_hp, current_hp + amount)
	if current_hp == previous_hp:
		return
	hp_changed.emit(current_hp, max_hp)

func restore_full_health() -> void:
	if current_hp <= 0:
		return
	if current_hp >= max_hp:
		return
	current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)

func set_incoming_damage_multiplier(multiplier: float) -> void:
	_module_incoming_damage_multiplier = clampf(multiplier, 0.05, 1.0)
	_refresh_incoming_damage_multiplier()

func set_external_incoming_damage_multiplier(multiplier: float) -> void:
	_external_incoming_damage_multiplier = clampf(multiplier, 0.05, 1.0)
	_refresh_incoming_damage_multiplier()

func set_bonus_move_speed_multiplier(multiplier: float) -> void:
	_bonus_move_speed_multiplier = maxf(0.1, multiplier)
	_refresh_runtime_stats()

func set_stat_move_speed_multiplier(multiplier: float) -> void:
	_stat_move_speed_multiplier = maxf(0.1, multiplier)
	_refresh_runtime_stats()

func set_bonus_max_hp_flat(amount: int) -> void:
	_bonus_max_hp_flat = maxi(0, amount)
	_refresh_runtime_stats()

func set_stat_max_hp_flat(amount: int) -> void:
	_stat_max_hp_flat = maxi(0, amount)
	_refresh_runtime_stats()

func set_lineage_accent(color: Color) -> void:
	lineage_accent_color = color
	queue_redraw()

func set_stat_incoming_damage_multiplier(multiplier: float) -> void:
	_stat_incoming_damage_multiplier = clampf(multiplier, 0.05, 1.0)
	_refresh_incoming_damage_multiplier()

func set_pickup_radius_multiplier(multiplier: float) -> void:
	_pickup_radius_multiplier = maxf(0.5, multiplier)

func get_pickup_radius_multiplier() -> float:
	return _pickup_radius_multiplier

func set_block_chance(chance: float) -> void:
	_block_chance = clampf(chance, 0.0, 0.95)

func get_block_chance() -> float:
	return _block_chance

func _setup_animated_sprite() -> void:
	if animated_sprite == null:
		push_error("Player requires an AnimatedSprite2D child node named AnimatedSprite2D.")
		return
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	animated_sprite.position += visual_offset
	animated_sprite.scale = Vector2(animated_sprite.scale.x * sprite_scale.x, animated_sprite.scale.y * sprite_scale.y)
	animated_sprite.modulate = sprite_modulate
	if not animated_sprite.animation_finished.is_connected(Callable(self, "_on_animated_sprite_animation_finished")):
		animated_sprite.animation_finished.connect(Callable(self, "_on_animated_sprite_animation_finished"))
	_play_base_animation(false)

func _trigger_hit_animation() -> void:
	if animated_sprite == null:
		return
	if not _has_animation(hit_animation_name):
		return
	_is_playing_hit_animation = true
	_hit_animation_timeout_left = maxf(0.05, hit_animation_timeout_seconds)
	animated_sprite.play(hit_animation_name)

func _update_animation_state(is_moving: bool) -> void:
	if animated_sprite == null:
		return
	if _is_playing_hit_animation:
		return
	_play_base_animation(is_moving)

func _play_base_animation(is_moving: bool) -> void:
	if animated_sprite == null:
		return
	var target_animation: StringName = move_animation_name if is_moving else idle_animation_name
	if not _has_animation(target_animation):
		return
	if animated_sprite.animation == target_animation and animated_sprite.is_playing():
		return
	animated_sprite.play(target_animation)

func _has_animation(animation_name: StringName) -> bool:
	if animated_sprite == null:
		return false
	if animated_sprite.sprite_frames == null:
		return false
	return animated_sprite.sprite_frames.has_animation(animation_name)

func _on_animated_sprite_animation_finished() -> void:
	if animated_sprite == null:
		return
	if animated_sprite.animation != hit_animation_name:
		return
	_is_playing_hit_animation = false
	_hit_animation_timeout_left = 0.0
	_play_base_animation(velocity.length() > 0.01)

func _apply_damage_value(final_amount: int, raw_amount: int, is_dot: bool) -> void:
	if not is_dot and _block_chance > 0.0 and randf() <= _block_chance:
		if debug_log_damage:
			print(
				"Player blocked incoming damage (",
				int(round(_block_chance * 100.0)),
				"% chance)."
			)
		return
	current_hp = max(0, current_hp - final_amount)
	_trigger_hit_animation()
	if debug_log_damage:
		var damage_type_label: String = "DOT" if is_dot else "HIT"
		print(
			"Player took ",
			final_amount,
			" damage [",
			damage_type_label,
			"] (raw ",
			raw_amount,
			", x",
			incoming_damage_multiplier,
			"). HP: ",
			current_hp,
			"/",
			max_hp
		)
	hp_changed.emit(current_hp, max_hp)

	if current_hp == 0:
		died.emit()

func _refresh_incoming_damage_multiplier() -> void:
	incoming_damage_multiplier = clampf(
		_module_incoming_damage_multiplier * _external_incoming_damage_multiplier * _stat_incoming_damage_multiplier,
		0.05,
		1.0
	)

func _refresh_runtime_stats() -> void:
	move_speed = _base_move_speed * _bonus_move_speed_multiplier * _stat_move_speed_multiplier

	var previous_max_hp: int = max_hp
	var target_max_hp: int = maxi(1, _base_max_hp + _bonus_max_hp_flat + _stat_max_hp_flat)
	if previous_max_hp == target_max_hp:
		return

	max_hp = target_max_hp
	if current_hp > 0:
		var bonus_delta: int = target_max_hp - previous_max_hp
		if bonus_delta > 0:
			current_hp = mini(max_hp, current_hp + bonus_delta)
		else:
			current_hp = mini(current_hp, max_hp)
	hp_changed.emit(current_hp, max_hp)

func set_world_movement_bounds(bounds: Rect2, enabled: bool = true) -> void:
	if enabled and bounds.size.x > 1.0 and bounds.size.y > 1.0:
		_world_movement_bounds = bounds
		_use_world_movement_bounds = true
	else:
		_use_world_movement_bounds = false

func configure_follow_camera(bounds: Rect2, enabled: bool = true) -> void:
	if follow_camera == null:
		return
	follow_camera.enabled = true
	if not enabled or bounds.size.x <= 1.0 or bounds.size.y <= 1.0:
		follow_camera.limit_left = -10000000
		follow_camera.limit_top = -10000000
		follow_camera.limit_right = 10000000
		follow_camera.limit_bottom = 10000000
		return
	follow_camera.limit_left = int(floor(bounds.position.x))
	follow_camera.limit_top = int(floor(bounds.position.y))
	follow_camera.limit_right = int(ceil(bounds.position.x + bounds.size.x))
	follow_camera.limit_bottom = int(ceil(bounds.position.y + bounds.size.y))

func _apply_movement_bounds() -> void:
	if _use_world_movement_bounds:
		_apply_world_bounds()
		return
	_apply_viewport_bounds()

func _apply_viewport_bounds() -> void:
	if not clamp_to_viewport_bounds:
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 1.0 or viewport_size.y <= 1.0:
		return

	var margin: float = maxf(0.0, visual_radius + movement_bounds_extra_margin)
	var min_x: float = margin
	var max_x: float = maxf(min_x, viewport_size.x - margin)
	var min_y: float = margin
	var max_y: float = maxf(min_y, viewport_size.y - margin)

	var clamped_position: Vector2 = global_position
	clamped_position.x = clampf(clamped_position.x, min_x, max_x)
	clamped_position.y = clampf(clamped_position.y, min_y, max_y)
	if clamped_position != global_position:
		global_position = clamped_position

func _apply_world_bounds() -> void:
	var margin: float = maxf(0.0, visual_radius)
	var min_x: float = _world_movement_bounds.position.x + margin
	var max_x: float = maxf(min_x, _world_movement_bounds.position.x + _world_movement_bounds.size.x - margin)
	var min_y: float = _world_movement_bounds.position.y + margin
	var max_y: float = maxf(min_y, _world_movement_bounds.position.y + _world_movement_bounds.size.y - margin)

	var clamped_position: Vector2 = global_position
	clamped_position.x = clampf(clamped_position.x, min_x, max_x)
	clamped_position.y = clampf(clamped_position.y, min_y, max_y)
	if clamped_position != global_position:
		global_position = clamped_position

func _ensure_world_health_ui() -> void:
	if _world_health_ui_root == null:
		_world_health_ui_root = Node2D.new()
		_world_health_ui_root.name = "WorldHealthUI"
		add_child(_world_health_ui_root)

	_world_health_ui_root.position = world_health_ui_offset
	_world_health_ui_root.z_as_relative = false
	_world_health_ui_root.z_index = world_health_ui_z_index

	if _world_health_bar == null:
		_world_health_bar = ProgressBar.new()
		_world_health_bar.name = "HealthBar"
		_world_health_ui_root.add_child(_world_health_bar)

	_world_health_bar.min_value = 0.0
	_world_health_bar.show_percentage = false
	_world_health_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world_health_bar.custom_minimum_size = world_health_ui_size
	_world_health_bar.size = world_health_ui_size
	_world_health_bar.position = Vector2(-world_health_ui_size.x * 0.5, 0.0)

	var background_style: StyleBoxFlat = StyleBoxFlat.new()
	background_style.bg_color = Color(0.02, 0.06, 0.09, 0.90)
	background_style.border_width_left = 1
	background_style.border_width_top = 1
	background_style.border_width_right = 1
	background_style.border_width_bottom = 1
	background_style.border_color = Color(0.22, 0.45, 0.58, 0.95)
	background_style.corner_radius_top_left = 8
	background_style.corner_radius_top_right = 8
	background_style.corner_radius_bottom_left = 8
	background_style.corner_radius_bottom_right = 8

	_world_health_fill_normal = StyleBoxFlat.new()
	_world_health_fill_normal.bg_color = Color(0.94, 0.26, 0.34, 0.96)
	_world_health_fill_normal.corner_radius_top_left = 8
	_world_health_fill_normal.corner_radius_top_right = 8
	_world_health_fill_normal.corner_radius_bottom_left = 8
	_world_health_fill_normal.corner_radius_bottom_right = 8

	_world_health_fill_warning = StyleBoxFlat.new()
	_world_health_fill_warning.bg_color = Color(0.98, 0.52, 0.18, 0.96)
	_world_health_fill_warning.corner_radius_top_left = 8
	_world_health_fill_warning.corner_radius_top_right = 8
	_world_health_fill_warning.corner_radius_bottom_left = 8
	_world_health_fill_warning.corner_radius_bottom_right = 8

	_world_health_fill_critical = StyleBoxFlat.new()
	_world_health_fill_critical.bg_color = Color(0.84, 0.10, 0.12, 0.98)
	_world_health_fill_critical.corner_radius_top_left = 8
	_world_health_fill_critical.corner_radius_top_right = 8
	_world_health_fill_critical.corner_radius_bottom_left = 8
	_world_health_fill_critical.corner_radius_bottom_right = 8

	_world_health_bar.add_theme_stylebox_override("background", background_style)
	_world_health_bar.add_theme_stylebox_override("fill", _world_health_fill_normal)

	if _world_health_text == null:
		_world_health_text = Label.new()
		_world_health_text.name = "HealthText"
		_world_health_ui_root.add_child(_world_health_text)

	_world_health_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world_health_text.position = Vector2(-world_health_ui_size.x * 0.5, world_health_text_vertical_nudge)
	_world_health_text.custom_minimum_size = world_health_ui_size
	_world_health_text.size = world_health_ui_size
	_world_health_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_world_health_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_world_health_text.add_theme_font_size_override("font_size", 13)
	_world_health_text.add_theme_color_override("font_color", Color(1, 1, 1, 0.98))
	_world_health_text.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_world_health_text.add_theme_constant_override("outline_size", 2)

func _on_hp_changed_local(current_hp_value: int, max_hp_value: int) -> void:
	_refresh_world_health_ui(current_hp_value, max_hp_value)

func _refresh_world_health_ui(current_hp_value: int, max_hp_value: int) -> void:
	if _world_health_ui_root == null or _world_health_bar == null or _world_health_text == null:
		return

	var clamped_max_hp: int = maxi(1, max_hp_value)
	var clamped_current_hp: int = clampi(current_hp_value, 0, clamped_max_hp)
	_world_health_ui_root.visible = clamped_current_hp > 0

	_world_health_bar.max_value = float(clamped_max_hp)
	_world_health_bar.value = float(clamped_current_hp)
	_world_health_text.text = "%d/%d" % [clamped_current_hp, clamped_max_hp]

	var hp_ratio: float = float(clamped_current_hp) / float(clamped_max_hp)
	var fill_style: StyleBoxFlat = _world_health_fill_normal
	var text_color: Color = Color(1, 1, 1, 0.98)
	if hp_ratio <= 0.30:
		fill_style = _world_health_fill_critical
		text_color = Color(1.0, 0.90, 0.90, 1.0)
	elif hp_ratio <= 0.60:
		fill_style = _world_health_fill_warning
		text_color = Color(1.0, 0.95, 0.87, 1.0)
	_world_health_bar.add_theme_stylebox_override("fill", fill_style)
	_world_health_text.add_theme_color_override("font_color", text_color)
