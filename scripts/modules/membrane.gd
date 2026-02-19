extends Node2D

@export var membrane_color: Color = Color(0.75, 0.95, 1.0, 0.8)
@export var visual_z_index: int = -5
@export var active_animation_name: StringName = &"default"
@export var membrane_pulse_speed: float = 2.2
@export var membrane_pulse_amplitude: float = 0.06
@export var rotate_visual: bool = false
@export var visual_rotation_speed: float = 0.15
@export var use_lineage_tint: bool = false
@export_range(0.0, 1.0, 0.01) var lineage_tint_strength: float = 0.18

var membrane_level: int = 0
var _visual_time: float = 0.0
var _lineage_color: Color = Color(1.0, 1.0, 1.0, 1.0)
var _base_visual_scale: Vector2 = Vector2.ONE
var _base_visual_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
var _base_visual_rotation: float = 0.0

@onready var visual_sprite: AnimatedSprite2D = get_node_or_null("VisualSprite")

func _ready() -> void:
	add_to_group("player_modules")
	if visual_sprite == null:
		push_error("Membrane requires an AnimatedSprite2D child node named VisualSprite.")
	else:
		visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		_base_visual_scale = visual_sprite.scale
		_base_visual_modulate = visual_sprite.modulate
		_base_visual_rotation = visual_sprite.rotation
		visual_sprite.z_index = visual_z_index
	set_level(0)

func _process(delta: float) -> void:
	if membrane_level > 0:
		_visual_time += delta
	_update_visual_sprite()

func set_level(new_level: int) -> void:
	membrane_level = clampi(new_level, 0, 5)
	_apply_to_player()
	_update_visual_sprite()

func set_lineage_color(color: Color) -> void:
	_lineage_color = color
	_update_visual_sprite()

func _apply_to_player() -> void:
	var owner_player := get_parent() as Node
	if owner_player == null:
		return
	if not owner_player.has_method("set_incoming_damage_multiplier"):
		return

	owner_player.call("set_incoming_damage_multiplier", _get_damage_multiplier_for_level(membrane_level))

func _get_damage_multiplier_for_level(level: int) -> float:
	match level:
		1:
			return 0.85
		2:
			return 0.70
		3:
			return 0.55
		4:
			return 0.45
		5:
			return 0.35
		_:
			return 1.0

func _draw() -> void:
	pass

func _update_visual_sprite() -> void:
	if visual_sprite == null:
		return

	visual_sprite.z_index = visual_z_index

	if membrane_level <= 0:
		visual_sprite.visible = false
		if visual_sprite.is_playing():
			visual_sprite.stop()
		return

	visual_sprite.visible = true
	_play_visual_animation_if_available()

	var pulse: float = (sin(_visual_time * membrane_pulse_speed) + 1.0) * 0.5
	var pulse_scale: float = 1.0 + (membrane_pulse_amplitude * pulse)
	visual_sprite.scale = _base_visual_scale * pulse_scale

	var tint_rgb: Color = Color(1.0, 1.0, 1.0, 1.0)
	if use_lineage_tint:
		tint_rgb = tint_rgb.lerp(_lineage_color, lineage_tint_strength)
	var level_alpha_multiplier: float = 0.85 + (0.05 * float(membrane_level))
	level_alpha_multiplier = clampf(level_alpha_multiplier, 0.0, 1.25)
	var modulate_now: Color = _base_visual_modulate
	modulate_now.r *= tint_rgb.r
	modulate_now.g *= tint_rgb.g
	modulate_now.b *= tint_rgb.b
	modulate_now.a *= level_alpha_multiplier
	visual_sprite.modulate = modulate_now

	if rotate_visual:
		visual_sprite.rotation = _base_visual_rotation + (_visual_time * visual_rotation_speed)
	else:
		visual_sprite.rotation = _base_visual_rotation

func _play_visual_animation_if_available() -> void:
	if visual_sprite == null:
		return
	var frames: SpriteFrames = visual_sprite.sprite_frames
	if frames == null:
		return
	var animation_to_play: StringName = active_animation_name
	if not frames.has_animation(animation_to_play):
		var animation_names: PackedStringArray = frames.get_animation_names()
		if animation_names.is_empty():
			return
		animation_to_play = StringName(animation_names[0])
	if not frames.has_animation(animation_to_play):
		return
	if visual_sprite.animation == animation_to_play and visual_sprite.is_playing():
		return
	visual_sprite.play(animation_to_play)
