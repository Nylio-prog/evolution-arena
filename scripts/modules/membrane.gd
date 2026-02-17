extends Node2D

const MEMBRANE_SPRITE_TEXTURE: Texture2D = preload("res://art/sprites/mutations/mutation_membrane.png")

@export var membrane_color: Color = Color(0.75, 0.95, 1.0, 0.8)
@export var base_radius: float = 20.0
@export var radius_per_level: float = 4.0
@export var base_thickness: float = 2.0
@export var membrane_sprite_texture: Texture2D = MEMBRANE_SPRITE_TEXTURE
@export var membrane_sprite_scale_multiplier: float = 1.20
@export var membrane_pulse_speed: float = 2.2
@export var membrane_pulse_amplitude: float = 0.06
@export var use_lineage_tint: bool = false
@export_range(0.0, 1.0, 0.01) var lineage_tint_strength: float = 0.18

var membrane_level: int = 0
var _visual_time: float = 0.0
var _lineage_color: Color = Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	add_to_group("player_modules")
	_ensure_visual_sprite()
	set_level(0)

func _process(delta: float) -> void:
	if membrane_level <= 0:
		return
	_visual_time += delta
	_update_visual_sprite()

func set_level(new_level: int) -> void:
	membrane_level = clampi(new_level, 0, 3)
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
		_:
			return 1.0

func _draw() -> void:
	pass

func _ensure_visual_sprite() -> void:
	if get_node_or_null("VisualSprite") != null:
		return

	var visual_sprite := Sprite2D.new()
	visual_sprite.name = "VisualSprite"
	visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	add_child(visual_sprite)

func _update_visual_sprite() -> void:
	var visual_sprite := get_node_or_null("VisualSprite") as Sprite2D
	if visual_sprite == null:
		return

	if membrane_level <= 0:
		visual_sprite.visible = false
		return

	visual_sprite.visible = true
	visual_sprite.texture = membrane_sprite_texture
	var pulse: float = (sin(_visual_time * membrane_pulse_speed) + 1.0) * 0.5
	var pulse_scale: float = 1.0 + (membrane_pulse_amplitude * pulse)
	visual_sprite.scale = _compute_membrane_sprite_scale() * pulse_scale
	var tint_rgb: Color = Color(1.0, 1.0, 1.0, 1.0)
	if use_lineage_tint:
		tint_rgb = tint_rgb.lerp(_lineage_color, lineage_tint_strength)
	var color_now: Color = Color(tint_rgb.r, tint_rgb.g, tint_rgb.b, 1.0)
	color_now.a = 0.07 + (0.04 * float(membrane_level)) + (0.05 * pulse)
	visual_sprite.modulate = color_now
	visual_sprite.rotation = _visual_time * 0.15

func _compute_membrane_sprite_scale() -> Vector2:
	if membrane_sprite_texture == null:
		return Vector2.ONE
	var texture_width: float = maxf(1.0, membrane_sprite_texture.get_size().x)
	var ring_radius: float = base_radius + (radius_per_level * float(membrane_level))
	var desired_diameter: float = ring_radius * 2.0 * membrane_sprite_scale_multiplier
	var uniform_scale: float = desired_diameter / texture_width
	return Vector2(uniform_scale, uniform_scale)
