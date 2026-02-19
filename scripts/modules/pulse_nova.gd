extends Node2D

const PULSE_NOVA_SPRITE_TEXTURE: Texture2D = preload("res://art/sprites/mutations/mutation_pulse_nova.png")

@export var base_pulse_damage: int = 8
@export var base_pulse_radius: float = 80.0
@export var base_pulse_interval_seconds: float = 1.85
@export var pulse_visual_duration_seconds: float = 0.22
@export var pulse_color: Color = Color(0.75, 0.95, 1.0, 0.95)
@export var pulse_outline_color: Color = Color(0.12, 0.2, 0.26, 1.0)
@export var pulse_sprite_texture: Texture2D = PULSE_NOVA_SPRITE_TEXTURE
@export var pulse_sprite_scale_multiplier: float = 1.15
@export_range(0.0, 1.0, 0.01) var block_chance_level_1: float = 0.06
@export_range(0.0, 1.0, 0.01) var block_chance_level_2: float = 0.10
@export_range(0.0, 1.0, 0.01) var block_chance_level_3: float = 0.14
@export_range(0.0, 1.0, 0.01) var block_chance_level_4: float = 0.18
@export_range(0.0, 1.0, 0.01) var block_chance_level_5: float = 0.22
@export var debug_log_hits: bool = false

@onready var audio_manager: Node = get_node_or_null("/root/AudioManager")

var pulse_level: int = 0
var _pulse_damage: int = 0
var _pulse_radius: float = 0.0
var _pulse_interval_seconds: float = 999.0
var _time_until_next_pulse: float = 0.0
var _pulse_visual_time_left: float = 0.0
var _pulse_visual_sprite: Sprite2D = null

func _ready() -> void:
	add_to_group("player_modules")
	_ensure_pulse_visual_sprite()
	set_level(0)

func _exit_tree() -> void:
	_apply_guard_block_chance_to_player(0)

func _physics_process(delta: float) -> void:
	if pulse_level <= 0:
		return

	_time_until_next_pulse = maxf(0.0, _time_until_next_pulse - delta)
	if _time_until_next_pulse <= 0.0:
		_emit_pulse()
		_time_until_next_pulse = _pulse_interval_seconds

	if _pulse_visual_time_left > 0.0:
		_pulse_visual_time_left = maxf(0.0, _pulse_visual_time_left - delta)
		_update_pulse_visual()

func set_level(new_level: int) -> void:
	pulse_level = clampi(new_level, 0, 5)
	_configure_level_stats()
	_apply_guard_block_chance_to_player(_get_guard_block_chance_for_level(pulse_level))
	_time_until_next_pulse = minf(_time_until_next_pulse, _pulse_interval_seconds)
	_update_pulse_visual()

func set_lineage_color(color: Color) -> void:
	pulse_color = color
	pulse_outline_color = color.darkened(0.75)
	_update_pulse_visual()

func _configure_level_stats() -> void:
	match pulse_level:
		1:
			_pulse_damage = base_pulse_damage
			_pulse_radius = base_pulse_radius
			_pulse_interval_seconds = base_pulse_interval_seconds
		2:
			_pulse_damage = int(round(float(base_pulse_damage) * 1.35))
			_pulse_radius = base_pulse_radius + 16.0
			_pulse_interval_seconds = maxf(0.40, base_pulse_interval_seconds * 0.86)
		3:
			_pulse_damage = int(round(float(base_pulse_damage) * 1.75))
			_pulse_radius = base_pulse_radius + 30.0
			_pulse_interval_seconds = maxf(0.34, base_pulse_interval_seconds * 0.74)
		4:
			_pulse_damage = int(round(float(base_pulse_damage) * 2.10))
			_pulse_radius = base_pulse_radius + 44.0
			_pulse_interval_seconds = maxf(0.30, base_pulse_interval_seconds * 0.66)
		5:
			_pulse_damage = int(round(float(base_pulse_damage) * 2.45))
			_pulse_radius = base_pulse_radius + 58.0
			_pulse_interval_seconds = maxf(0.26, base_pulse_interval_seconds * 0.58)
		_:
			_pulse_damage = 0
			_pulse_radius = 0.0
			_pulse_interval_seconds = 999.0

func _get_guard_block_chance_for_level(level: int) -> float:
	match level:
		1:
			return block_chance_level_1
		2:
			return block_chance_level_2
		3:
			return block_chance_level_3
		4:
			return block_chance_level_4
		5:
			return block_chance_level_5
		_:
			return 0.0

func _apply_guard_block_chance_to_player(block_chance: float) -> void:
	var owner_player := get_parent() as Node
	if owner_player == null:
		return
	if owner_player.has_method("set_block_chance"):
		owner_player.call("set_block_chance", clampf(block_chance, 0.0, 0.95))

func _emit_pulse() -> void:
	if pulse_level <= 0:
		return

	var owner_player := get_parent() as Node2D
	if owner_player == null:
		return

	var hit_count: int = 0
	var pulse_origin: Vector2 = owner_player.global_position
	for enemy_variant in get_tree().get_nodes_in_group("enemies"):
		var enemy_node := enemy_variant as Node2D
		if enemy_node == null:
			continue
		if not enemy_node.has_method("take_damage"):
			continue

		var distance_to_enemy: float = pulse_origin.distance_to(enemy_node.global_position)
		if distance_to_enemy > _pulse_radius:
			continue

		enemy_node.call("take_damage", _pulse_damage)
		hit_count += 1

	if debug_log_hits:
		print("Pulse Nova hit ", hit_count, " enemy(s) for ", _pulse_damage)
	_play_sfx("sfx_lytic_burst", -4.0, randf_range(0.96, 1.04))

	_pulse_visual_time_left = pulse_visual_duration_seconds
	_update_pulse_visual()

func _draw() -> void:
	pass

func _ensure_pulse_visual_sprite() -> void:
	if _pulse_visual_sprite != null and is_instance_valid(_pulse_visual_sprite):
		return

	_pulse_visual_sprite = Sprite2D.new()
	_pulse_visual_sprite.name = "PulseVisual"
	_pulse_visual_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_pulse_visual_sprite.texture = pulse_sprite_texture
	_pulse_visual_sprite.visible = false
	var add_material := CanvasItemMaterial.new()
	add_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_pulse_visual_sprite.material = add_material
	add_child(_pulse_visual_sprite)

func _update_pulse_visual() -> void:
	if _pulse_visual_sprite == null or not is_instance_valid(_pulse_visual_sprite):
		return

	if pulse_level <= 0 or _pulse_visual_time_left <= 0.0:
		_pulse_visual_sprite.visible = false
		return

	_pulse_visual_sprite.visible = true
	if pulse_sprite_texture == null:
		_pulse_visual_sprite.visible = false
		return
	_pulse_visual_sprite.texture = pulse_sprite_texture

	var normalized: float = 1.0 - (_pulse_visual_time_left / maxf(0.01, pulse_visual_duration_seconds))
	var radius_now: float = lerpf(4.0, _pulse_radius, normalized)
	var alpha_factor: float = 1.0 - normalized
	var texture_width: float = maxf(1.0, pulse_sprite_texture.get_size().x)
	var desired_diameter: float = radius_now * 2.0 * pulse_sprite_scale_multiplier
	var uniform_scale: float = desired_diameter / texture_width
	_pulse_visual_sprite.scale = Vector2(uniform_scale, uniform_scale)

	var visual_color: Color = pulse_color
	visual_color.a = clampf(0.95 * pow(alpha_factor, 0.6), 0.0, 1.0)
	_pulse_visual_sprite.modulate = visual_color
	_pulse_visual_sprite.rotation = normalized * 0.35 * TAU

func _play_sfx(event_id: String, volume_db_offset: float = 0.0, pitch_scale: float = 1.0) -> void:
	if audio_manager == null:
		return
	if not audio_manager.has_method("play_sfx"):
		return
	audio_manager.call("play_sfx", event_id, volume_db_offset, pitch_scale)
