extends RefCounted

const ROOM_HEIGHT := 720.0
const ROOM_FLOOR_THRESHOLD := 40.0
const FLOOR_TILE_SIZE := Vector2(96, 96)
const PLATFORM_TILE_SIZE := Vector2(96, 32)
const BG_SCALE := Vector2(4.0, 4.0)

const BG_TEXTURE_PATHS := [
	"res://assets/background/gandalf_hardcore/bg_dirt_1.png",
	"res://assets/background/gandalf_hardcore/bg_dirt_2.png"
]
const FLOOR_TEXTURE_PATHS := [
	"res://assets/background/gandalf_hardcore/floor_tiles_1.png",
	"res://assets/background/gandalf_hardcore/floor_tiles_2.png"
]
const OTHER_TEXTURE_PATHS := [
	"res://assets/background/gandalf_hardcore/other_tiles_1.png",
	"res://assets/background/gandalf_hardcore/other_tiles_2.png"
]

var _texture_cache: Dictionary = {}


func build(room_layer: Node2D, room_data: Dictionary, variant: Dictionary) -> void:
	for child in room_layer.get_children():
		child.queue_free()

	var room_width := float(room_data.get("width", 1600))
	var palette_index := _choose_palette_index(room_data)

	var background_layer := Node2D.new()
	background_layer.name = "BackgroundLayer"
	background_layer.z_index = -30
	room_layer.add_child(background_layer)
	_build_background(background_layer, room_width, room_data, variant)

	var terrain_decor_layer := Node2D.new()
	terrain_decor_layer.name = "TerrainDecorLayer"
	terrain_decor_layer.z_index = -8
	room_layer.add_child(terrain_decor_layer)

	for segment_index in room_data.get("floor_segments", []).size():
		var segment: Array = room_data.get("floor_segments", [])[segment_index]
		var position_value := Vector2(segment[0], segment[1])
		var size := Vector2(segment[2], segment[3])
		terrain_decor_layer.add_child(
			_make_segment_decor(position_value, size, palette_index, segment_index)
		)
		room_layer.add_child(
			_make_static_rect(position_value, size, _segment_color(segment_index, size, palette_index))
		)

	room_layer.add_child(_make_wall(Vector2(-24, ROOM_HEIGHT * 0.5), Vector2(48, ROOM_HEIGHT)))
	room_layer.add_child(
		_make_wall(
			Vector2(room_width + 24, ROOM_HEIGHT * 0.5), Vector2(48, ROOM_HEIGHT)
		)
	)


func _build_background(
	background_layer: Node2D, room_width: float, room_data: Dictionary, variant: Dictionary
) -> void:
	var background_textures := _get_background_textures()
	var base := Polygon2D.new()
	base.name = "BaseBackdrop"
	base.color = (
		Color(room_data.get("background", "#101820"))
		+ Color(variant.get("tint", Color("#ffffff"))) * 0.16
	)
	base.polygon = PackedVector2Array(
		[
			Vector2(0, 0),
			Vector2(room_width, 0),
			Vector2(room_width, ROOM_HEIGHT),
			Vector2(0, ROOM_HEIGHT)
		]
	)
	background_layer.add_child(base)

	var chunk_width: float = background_textures[0].get_width() * BG_SCALE.x
	var bottom_y: float = ROOM_HEIGHT - (background_textures[0].get_height() * BG_SCALE.y * 0.5) + 18.0
	var top_y := 250.0
	var idx := 0
	var x: float = -chunk_width * 0.5
	while x <= room_width + chunk_width:
		background_layer.add_child(
			_make_background_sprite(
				background_textures[idx % background_textures.size()], Vector2(x, bottom_y), 0.34
			)
		)
		background_layer.add_child(
			_make_background_sprite(
				background_textures[(idx + 1) % background_textures.size()],
				Vector2(x + chunk_width * 0.25, top_y),
				0.18
			)
		)
		idx += 1
		x += chunk_width * 0.9


func _make_background_sprite(texture: Texture2D, position_value: Vector2, alpha: float) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = position_value
	sprite.centered = true
	sprite.scale = BG_SCALE
	sprite.modulate = Color(1, 1, 1, alpha)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return sprite


func _make_segment_decor(
	position_value: Vector2, size: Vector2, palette_index: int, segment_index: int
) -> Node2D:
	var decor := Node2D.new()
	decor.name = "SegmentDecor_%d" % segment_index
	decor.position = position_value

	if size.y <= ROOM_FLOOR_THRESHOLD:
		_build_platform_decor(decor, size, palette_index, segment_index)
	else:
		_build_ground_decor(decor, size, palette_index)

	return decor


func _build_ground_decor(decor: Node2D, size: Vector2, palette_index: int) -> void:
	var texture: Texture2D = _get_floor_textures()[palette_index]
	var fill := Polygon2D.new()
	fill.name = "GroundFill"
	fill.z_index = -1
	fill.color = _segment_color(0, size, palette_index).darkened(0.08)
	fill.polygon = PackedVector2Array(
		[
			Vector2(-size.x * 0.5, -size.y * 0.5 + 24.0),
			Vector2(size.x * 0.5, -size.y * 0.5 + 24.0),
			Vector2(size.x * 0.5, size.y * 0.5),
			Vector2(-size.x * 0.5, size.y * 0.5)
		]
	)
	decor.add_child(fill)

	var top_row := Node2D.new()
	top_row.name = "GroundDecor"
	decor.add_child(top_row)

	var columns := int(ceil(size.x / FLOOR_TILE_SIZE.x))
	for column in columns:
		var region := Rect2(0, 0, FLOOR_TILE_SIZE.x, FLOOR_TILE_SIZE.y)
		if column == columns - 1 and column > 0:
			region.position.x = FLOOR_TILE_SIZE.x * 2.0
		var sprite := _make_region_sprite(
			texture,
			region,
			Vector2(
				-size.x * 0.5 + FLOOR_TILE_SIZE.x * 0.5 + column * FLOOR_TILE_SIZE.x,
				-size.y * 0.5 + FLOOR_TILE_SIZE.y * 0.5
			)
		)
		top_row.add_child(sprite)


func _build_platform_decor(
	decor: Node2D, size: Vector2, palette_index: int, segment_index: int
) -> void:
	var texture: Texture2D = _get_other_textures()[palette_index]
	var underside := Polygon2D.new()
	underside.name = "PlatformUnderside"
	underside.z_index = -1
	underside.color = _segment_color(segment_index, size, palette_index).darkened(0.15)
	underside.polygon = PackedVector2Array(
		[
			Vector2(-size.x * 0.5, -size.y * 0.5 + 8.0),
			Vector2(size.x * 0.5, -size.y * 0.5 + 8.0),
			Vector2(size.x * 0.5, size.y * 0.5),
			Vector2(-size.x * 0.5, size.y * 0.5)
		]
	)
	decor.add_child(underside)

	var platform_row := Node2D.new()
	platform_row.name = "PlatformDecor"
	decor.add_child(platform_row)

	var columns := int(ceil(size.x / FLOOR_TILE_SIZE.x))
	for column in columns:
		var region_x := 0.0
		if column == columns - 1 and column > 0:
			region_x = PLATFORM_TILE_SIZE.x
		var sprite := _make_region_sprite(
			texture,
			Rect2(region_x, 96, PLATFORM_TILE_SIZE.x, PLATFORM_TILE_SIZE.y),
			Vector2(
				-size.x * 0.5 + FLOOR_TILE_SIZE.x * 0.5 + column * FLOOR_TILE_SIZE.x,
				-size.y * 0.5 + PLATFORM_TILE_SIZE.y * 0.5
			)
		)
		platform_row.add_child(sprite)


func _make_region_sprite(texture: Texture2D, region: Rect2, position_value: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = position_value
	sprite.centered = true
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return sprite


func _make_static_rect(position_value: Vector2, size: Vector2, color: Color) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = position_value

	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = size
	body.add_child(shape)

	var polygon := Polygon2D.new()
	var overlay_color := color
	overlay_color.a = 0.22
	polygon.color = overlay_color
	polygon.z_index = -6
	polygon.polygon = PackedVector2Array(
		[
			Vector2(-size.x * 0.5, -size.y * 0.5),
			Vector2(size.x * 0.5, -size.y * 0.5),
			Vector2(size.x * 0.5, size.y * 0.5),
			Vector2(-size.x * 0.5, size.y * 0.5)
		]
	)
	body.add_child(polygon)
	return body


func _make_wall(position_value: Vector2, size: Vector2) -> StaticBody2D:
	return _make_static_rect(position_value, size, Color("#1d2b3e"))


func _choose_palette_index(room_data: Dictionary) -> int:
	var room_id := str(room_data.get("id", ""))
	if room_id in ["conduit", "vault_sector", "arcane_core"]:
		return 1
	return 0


func _get_background_textures() -> Array[Texture2D]:
	return _load_texture_group(BG_TEXTURE_PATHS)


func _get_floor_textures() -> Array[Texture2D]:
	return _load_texture_group(FLOOR_TEXTURE_PATHS)


func _get_other_textures() -> Array[Texture2D]:
	return _load_texture_group(OTHER_TEXTURE_PATHS)


func _load_texture_group(paths: Array) -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	for path in paths:
		textures.append(_load_runtime_texture(str(path)))
	return textures


func _load_runtime_texture(path: String) -> Texture2D:
	if _texture_cache.has(path):
		return _texture_cache[path]

	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty():
		image = Image.create(int(FLOOR_TILE_SIZE.x), int(FLOOR_TILE_SIZE.y), false, Image.FORMAT_RGBA8)
		image.fill(Color(1, 0, 1, 1))

	var texture := ImageTexture.create_from_image(image)
	_texture_cache[path] = texture
	return texture


func _segment_color(segment_index: int, size: Vector2, palette_index: int) -> Color:
	if size.y <= ROOM_FLOOR_THRESHOLD:
		return Color("#5b4633") if palette_index == 0 else Color("#6c5134")
	return Color("#403427") if palette_index == 0 else Color("#4a3425")
