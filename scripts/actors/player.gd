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
@export var visual_offset: Vector2 = Vector2(0.0, 1.0)
@export var sprite_scale: Vector2 = Vector2(0.3, 0.3)
@export var sprite_modulate: Color = Color(1, 1, 1, 1)
@export var debug_log_damage: bool = false
@export var clamp_to_viewport_bounds: bool = true
@export var movement_bounds_extra_margin: float = 0.0

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

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

func _ready() -> void:
	_base_move_speed = move_speed
	_base_max_hp = max_hp
	current_hp = max_hp
	_refresh_runtime_stats()
	_refresh_incoming_damage_multiplier()
	add_to_group("player")
	hp_changed.emit(current_hp, max_hp)
	_setup_animated_sprite()
	queue_redraw()

func _draw() -> void:
	if lineage_accent_color.a > 0.01:
		draw_arc(Vector2.ZERO, visual_radius + 4.0, 0.0, TAU, 48, lineage_accent_color, lineage_accent_width, true)

func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed
	move_and_slide()
	_apply_viewport_bounds()
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

func set_incoming_damage_multiplier(multiplier: float) -> void:
	_module_incoming_damage_multiplier = clampf(multiplier, 0.05, 1.0)
	_refresh_incoming_damage_multiplier()

func set_external_incoming_damage_multiplier(multiplier: float) -> void:
	_external_incoming_damage_multiplier = clampf(multiplier, 0.05, 1.0)
	_refresh_incoming_damage_multiplier()

func set_bonus_move_speed_multiplier(multiplier: float) -> void:
	_bonus_move_speed_multiplier = maxf(0.1, multiplier)
	_refresh_runtime_stats()

func set_bonus_max_hp_flat(amount: int) -> void:
	_bonus_max_hp_flat = maxi(0, amount)
	_refresh_runtime_stats()

func set_lineage_accent(color: Color) -> void:
	lineage_accent_color = color
	queue_redraw()

func _setup_animated_sprite() -> void:
	if animated_sprite == null:
		push_error("Player requires an AnimatedSprite2D child node named AnimatedSprite2D.")
		return
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	animated_sprite.position = visual_offset
	animated_sprite.scale = sprite_scale
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
	_play_base_animation(velocity.length() > 0.01)

func _apply_damage_value(final_amount: int, raw_amount: int, is_dot: bool) -> void:
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
		_module_incoming_damage_multiplier * _external_incoming_damage_multiplier,
		0.05,
		1.0
	)

func _refresh_runtime_stats() -> void:
	move_speed = _base_move_speed * _bonus_move_speed_multiplier

	var previous_max_hp: int = max_hp
	var target_max_hp: int = maxi(1, _base_max_hp + _bonus_max_hp_flat)
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
