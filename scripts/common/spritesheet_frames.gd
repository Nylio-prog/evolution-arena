extends RefCounted

class_name SpritesheetFrames

static func build_animation_from_grid(
	texture: Texture2D,
	animation_name: StringName,
	columns: int = 3,
	rows: int = 3,
	frame_count: int = 9,
	fps: float = 12.0,
	loop: bool = true,
	margin: Vector2i = Vector2i.ZERO,
	spacing: Vector2i = Vector2i.ZERO
) -> SpriteFrames:
	var frames := SpriteFrames.new()
	append_animation_from_grid(frames, texture, animation_name, columns, rows, frame_count, fps, loop, margin, spacing)
	return frames

static func append_animation_from_grid(
	frames: SpriteFrames,
	texture: Texture2D,
	animation_name: StringName,
	columns: int = 3,
	rows: int = 3,
	frame_count: int = 9,
	fps: float = 12.0,
	loop: bool = true,
	margin: Vector2i = Vector2i.ZERO,
	spacing: Vector2i = Vector2i.ZERO
) -> void:
	if frames == null:
		return
	if texture == null:
		return
	var safe_columns: int = maxi(1, columns)
	var safe_rows: int = maxi(1, rows)
	var safe_frame_count: int = maxi(1, frame_count)
	var texture_size: Vector2 = texture.get_size()
	if texture_size.x <= 1.0 or texture_size.y <= 1.0:
		return

	var usable_width: float = texture_size.x - float(margin.x * 2) - float(spacing.x * (safe_columns - 1))
	var usable_height: float = texture_size.y - float(margin.y * 2) - float(spacing.y * (safe_rows - 1))
	if usable_width <= 0.0 or usable_height <= 0.0:
		return

	var cell_width: float = floor(usable_width / float(safe_columns))
	var cell_height: float = floor(usable_height / float(safe_rows))
	if cell_width <= 1.0 or cell_height <= 1.0:
		return

	if frames.has_animation(animation_name):
		frames.remove_animation(animation_name)
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, maxf(0.1, fps))
	frames.set_animation_loop(animation_name, loop)

	var max_cells: int = safe_columns * safe_rows
	var frame_total: int = mini(safe_frame_count, max_cells)
	for frame_index in range(frame_total):
		var cell_x: int = frame_index % safe_columns
		var cell_y: int = int(floor(float(frame_index) / float(safe_columns)))
		var region_position := Vector2(
			float(margin.x) + (float(cell_x) * (cell_width + float(spacing.x))),
			float(margin.y) + (float(cell_y) * (cell_height + float(spacing.y)))
		)
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(region_position, Vector2(cell_width, cell_height))
		frames.add_frame(animation_name, atlas)

static func build_first_frame_texture(
	texture: Texture2D,
	columns: int = 3,
	rows: int = 3,
	margin: Vector2i = Vector2i.ZERO,
	spacing: Vector2i = Vector2i.ZERO
) -> Texture2D:
	if texture == null:
		return null
	var safe_columns: int = maxi(1, columns)
	var safe_rows: int = maxi(1, rows)
	var texture_size: Vector2 = texture.get_size()
	var usable_width: float = texture_size.x - float(margin.x * 2) - float(spacing.x * (safe_columns - 1))
	var usable_height: float = texture_size.y - float(margin.y * 2) - float(spacing.y * (safe_rows - 1))
	if usable_width <= 0.0 or usable_height <= 0.0:
		return texture
	var cell_width: float = floor(usable_width / float(safe_columns))
	var cell_height: float = floor(usable_height / float(safe_rows))
	if cell_width <= 1.0 or cell_height <= 1.0:
		return texture

	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(Vector2(margin.x, margin.y), Vector2(cell_width, cell_height))
	return atlas
