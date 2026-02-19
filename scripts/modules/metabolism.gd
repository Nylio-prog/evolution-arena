extends Node2D

const METABOLISM_SPRITE_TEXTURE: Texture2D = preload("res://art/sprites/mutations/mutation_metabolism.png")

@export var base_regen_per_second: float = 1.8
@export var regen_tick_cap_per_frame: int = 8
@export var aura_color: Color = Color(0.75, 1.0, 0.78, 0.9)
@export var aura_radius: float = 20.0
@export var aura_width: float = 1.8
@export var metabolism_sprite_texture: Texture2D = METABOLISM_SPRITE_TEXTURE
@export var metabolism_sprite_scale_multiplier: float = 1.55
@export var metabolism_pulse_speed: float = 4.4
@export var metabolism_pulse_amplitude: float = 0.12

var metabolism_level: int = 0
var _regen_per_second: float = 0.0
var _regen_progress: float = 0.0
var _visual_time: float = 0.0
var _visual_sprite: Sprite2D = null

func _ready() -> void:
	add_to_group("player_modules")
	_ensure_visual_sprite()
	set_level(0)

func _physics_process(delta: float) -> void:
	if metabolism_level <= 0:
		return

	var owner_player: Node = get_parent()
	if owner_player == null:
		return
	if not owner_player.has_method("heal"):
		return

	_regen_progress += _regen_per_second * delta
	if _regen_progress < 1.0:
		return

	var heal_amount: int = int(floor(_regen_progress))
	heal_amount = mini(heal_amount, maxi(1, regen_tick_cap_per_frame))
	_regen_progress -= float(heal_amount)
	owner_player.call("heal", heal_amount)

func _process(delta: float) -> void:
	if metabolism_level <= 0:
		if _visual_sprite != null and is_instance_valid(_visual_sprite):
			_visual_sprite.visible = false
		return
	_visual_time += delta
	_update_visual_sprite()

func set_level(new_level: int) -> void:
	metabolism_level = clampi(new_level, 0, 5)
	_configure_regen()
	_update_visual_sprite()

func set_lineage_color(color: Color) -> void:
	aura_color = color
	_update_visual_sprite()

func get_regen_per_second() -> float:
	return _regen_per_second

func _configure_regen() -> void:
	match metabolism_level:
		1:
			_regen_per_second = base_regen_per_second
		2:
			_regen_per_second = base_regen_per_second * 2.0
		3:
			_regen_per_second = base_regen_per_second * 3.2
		4:
			_regen_per_second = base_regen_per_second * 4.5
		5:
			_regen_per_second = base_regen_per_second * 6.0
		_:
			_regen_per_second = 0.0

func _draw() -> void:
	pass

func _ensure_visual_sprite() -> void:
	if _visual_sprite != null and is_instance_valid(_visual_sprite):
		return

	_visual_sprite = Sprite2D.new()
	_visual_sprite.name = "MetabolismVisual"
	_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var add_material := CanvasItemMaterial.new()
	add_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_visual_sprite.material = add_material
	add_child(_visual_sprite)

func _update_visual_sprite() -> void:
	if _visual_sprite == null or not is_instance_valid(_visual_sprite):
		return
	if metabolism_level <= 0 or metabolism_sprite_texture == null:
		_visual_sprite.visible = false
		return

	_visual_sprite.visible = true
	_visual_sprite.texture = metabolism_sprite_texture

	var pulse: float = (sin(_visual_time * metabolism_pulse_speed) + 1.0) * 0.5
	var base_scale: float = _compute_metabolism_base_scale()
	var scale_now: float = base_scale * (1.0 + (metabolism_pulse_amplitude * pulse))
	_visual_sprite.scale = Vector2(scale_now, scale_now)
	_visual_sprite.rotation = _visual_time * 0.35

	var color_now: Color = aura_color
	color_now.a = 0.36 + (0.18 * pulse)
	_visual_sprite.modulate = color_now

func _compute_metabolism_base_scale() -> float:
	if metabolism_sprite_texture == null:
		return 1.0
	var texture_width: float = maxf(1.0, metabolism_sprite_texture.get_size().x)
	var desired_diameter: float = (aura_radius + float(metabolism_level * 3)) * 2.0 * metabolism_sprite_scale_multiplier
	return desired_diameter / texture_width
