extends Area2D

signal collected(amount: int)

@export var xp_value: int = 6
@export var pickup_sprite_texture: Texture2D
@export_file("*.png", "*.webp", "*.jpg", "*.jpeg", "*.svg") var default_sprite_path: String = "res://art/sprites/ui/biomass_pickup.png"
@export var sprite_scale: Vector2 = Vector2(0.15, 0.15)
@export var sprite_modulate: Color = Color(0.1497069, 0.60367393, 0.5370635, 1.0)
@export var spawn_pop_duration: float = 0.18
@export var spawn_pop_overshoot: float = 1.35
@export var collect_feedback_duration: float = 0.16
@export var collect_scale_multiplier: float = 1.55
@export var collect_rise_pixels: float = 18.0
@export var debug_log_collect: bool = false

@onready var visual_sprite: Sprite2D = get_node_or_null("Sprite2D")

var _is_collecting: bool = false
var _sprite_tween: Tween

func _ready() -> void:
	add_to_group("biomass_pickups")
	body_entered.connect(_on_body_entered)
	_refresh_visual_sprite()
	_play_spawn_feedback()

func _on_body_entered(body: Node) -> void:
	if body == null:
		return
	if not body.is_in_group("player"):
		return
	if _is_collecting:
		return

	if debug_log_collect:
		print("Biomass collected for ", xp_value, " XP")
	_is_collecting = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	collected.emit(xp_value)
	_play_collect_feedback()

func _refresh_visual_sprite() -> void:
	if visual_sprite == null:
		push_error("BiomassPickup requires a Sprite2D child node.")
		return

	var resolved_texture: Texture2D = pickup_sprite_texture
	if resolved_texture == null and ResourceLoader.exists(default_sprite_path, "Texture2D"):
		var loaded_resource: Resource = load(default_sprite_path)
		resolved_texture = loaded_resource as Texture2D

	visual_sprite.texture = resolved_texture
	visual_sprite.scale = sprite_scale
	visual_sprite.modulate = sprite_modulate
	visual_sprite.visible = true
	if resolved_texture == null:
		push_error("Biomass sprite missing. Assign pickup_sprite_texture or add file: %s" % default_sprite_path)

func _play_spawn_feedback() -> void:
	if visual_sprite == null:
		return

	var base_scale: Vector2 = sprite_scale
	var intro_scale: Vector2 = base_scale * 0.7
	var overshoot_scale: Vector2 = base_scale * maxf(1.0, spawn_pop_overshoot)
	visual_sprite.scale = intro_scale

	_stop_sprite_tween()
	_sprite_tween = create_tween()
	_sprite_tween.tween_property(visual_sprite, "scale", overshoot_scale, spawn_pop_duration * 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_sprite_tween.tween_property(visual_sprite, "scale", base_scale, spawn_pop_duration * 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _play_collect_feedback() -> void:
	if visual_sprite == null:
		queue_free()
		return

	var start_modulate: Color = visual_sprite.modulate
	var end_modulate: Color = start_modulate
	end_modulate.a = 0.0
	var target_scale: Vector2 = visual_sprite.scale * maxf(1.0, collect_scale_multiplier)
	var target_position: Vector2 = visual_sprite.position + Vector2(0.0, -collect_rise_pixels)

	_stop_sprite_tween()
	_sprite_tween = create_tween()
	_sprite_tween.set_parallel(true)
	_sprite_tween.tween_property(visual_sprite, "modulate", end_modulate, collect_feedback_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_sprite_tween.tween_property(visual_sprite, "scale", target_scale, collect_feedback_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_sprite_tween.tween_property(visual_sprite, "position", target_position, collect_feedback_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_sprite_tween.finished.connect(_on_collect_feedback_finished)

func _on_collect_feedback_finished() -> void:
	queue_free()

func _stop_sprite_tween() -> void:
	if is_instance_valid(_sprite_tween):
		_sprite_tween.kill()
