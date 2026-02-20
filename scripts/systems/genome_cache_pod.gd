extends StaticBody2D

signal destroyed(world_position: Vector2, cache_node: Node)

@export var max_hp: int = 26
@export var dot_damage_multiplier: float = 0.85
@export var collision_radius: float = 18.0
@export var idle_animation_name: StringName = &"idle"
@export var open_animation_name: StringName = &"open"
@export var open_animation_loop_fallback_seconds: float = 0.45
@export var hit_flash_color: Color = Color(1.0, 0.60, 0.52, 1.0)
@export var hit_flash_duration_seconds: float = 0.08
@export var debug_log_damage: bool = false

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var current_hp: int = 0
var _flash_time_left: float = 0.0
var _base_sprite_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
var _is_destroying: bool = false

func _ready() -> void:
	current_hp = maxi(1, max_hp)
	add_to_group("genome_cache_pods")
	add_to_group("enemies")
	add_to_group("crisis_runtime_nodes")
	_setup_collision()
	_setup_visuals()

func _process(delta: float) -> void:
	if _flash_time_left <= 0.0:
		return
	_flash_time_left = maxf(0.0, _flash_time_left - delta)
	if _flash_time_left <= 0.0 and animated_sprite != null:
		animated_sprite.modulate = _base_sprite_modulate

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	if _is_destroying:
		return
	if current_hp <= 0:
		return
	current_hp = maxi(0, current_hp - amount)
	_trigger_hit_flash()
	if debug_log_damage:
		print("[GenomeCachePod] took ", amount, ", hp ", current_hp, "/", max_hp)
	if current_hp > 0:
		return
	_begin_destroy_sequence()

func take_dot_damage(amount: int) -> void:
	if amount <= 0:
		return
	if _is_destroying:
		return
	var scaled_amount: int = maxi(1, int(round(float(amount) * clampf(dot_damage_multiplier, 0.1, 3.0))))
	take_damage(scaled_amount)

func get_current_hp() -> int:
	return current_hp

func get_max_hp() -> int:
	return maxi(1, max_hp)

func _setup_collision() -> void:
	if collision_shape == null:
		return
	var circle_shape := collision_shape.shape as CircleShape2D
	if circle_shape == null:
		circle_shape = CircleShape2D.new()
		collision_shape.shape = circle_shape
	circle_shape.radius = maxf(6.0, collision_radius)

func _setup_visuals() -> void:
	if animated_sprite == null:
		return
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_base_sprite_modulate = animated_sprite.modulate
	if animated_sprite.sprite_frames == null:
		return
	var resolved_animation: StringName = _resolve_idle_animation_name()
	if resolved_animation.is_empty():
		var animation_names: PackedStringArray = animated_sprite.sprite_frames.get_animation_names()
		if animation_names.is_empty():
			return
		resolved_animation = StringName(animation_names[0])
	animated_sprite.play(resolved_animation)

func _trigger_hit_flash() -> void:
	if animated_sprite == null:
		return
	_flash_time_left = maxf(0.01, hit_flash_duration_seconds)
	animated_sprite.modulate = hit_flash_color

func _begin_destroy_sequence() -> void:
	if _is_destroying:
		return
	_is_destroying = true
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)
	if is_in_group("enemies"):
		remove_from_group("enemies")
	if is_in_group("hostile_enemies"):
		remove_from_group("hostile_enemies")
	_play_open_animation_then_finalize()

func _play_open_animation_then_finalize() -> void:
	var did_play_open: bool = false
	if animated_sprite != null and _can_play_animation(open_animation_name):
		animated_sprite.modulate = _base_sprite_modulate
		animated_sprite.play(open_animation_name)
		did_play_open = true
		var is_looping: bool = false
		if animated_sprite.sprite_frames != null:
			is_looping = animated_sprite.sprite_frames.get_animation_loop(open_animation_name)
		if is_looping:
			await get_tree().create_timer(maxf(0.05, open_animation_loop_fallback_seconds)).timeout
		else:
			await animated_sprite.animation_finished
	if not did_play_open:
		# No open animation configured: keep responsive and resolve immediately.
		await get_tree().process_frame
	_finalize_destroy_sequence()

func _finalize_destroy_sequence() -> void:
	destroyed.emit(global_position, self)
	queue_free()

func _resolve_idle_animation_name() -> StringName:
	if _can_play_animation(idle_animation_name):
		return idle_animation_name
	if _can_play_animation(&"default"):
		return &"default"
	return StringName()

func _can_play_animation(animation_name: StringName) -> bool:
	if animation_name.is_empty():
		return false
	if animated_sprite == null:
		return false
	if animated_sprite.sprite_frames == null:
		return false
	return animated_sprite.sprite_frames.has_animation(animation_name)
