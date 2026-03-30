extends RefCounted

func build(room_layer: Node2D, room_data: Dictionary, variant: Dictionary) -> void:
	for child in room_layer.get_children():
		child.queue_free()
	var background := Polygon2D.new()
	background.color = Color(room_data.get("background", "#101820")) + Color(variant.get("tint", Color("#ffffff"))) * 0.18
	background.z_index = -20
	background.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(room_data.get("width", 1600), 0),
		Vector2(room_data.get("width", 1600), 720),
		Vector2(0, 720)
	])
	room_layer.add_child(background)
	for segment in room_data.get("floor_segments", []):
		room_layer.add_child(_make_static_rect(Vector2(segment[0], segment[1]), Vector2(segment[2], segment[3])))
	room_layer.add_child(_make_wall(Vector2(-24, 360), Vector2(48, 720)))
	room_layer.add_child(_make_wall(Vector2(room_data.get("width", 1600) + 24, 360), Vector2(48, 720)))

func _make_static_rect(position_value: Vector2, size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = position_value
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = size
	body.add_child(shape)
	var polygon := Polygon2D.new()
	polygon.color = Color("#31445f")
	polygon.polygon = PackedVector2Array([
		Vector2(-size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.5),
		Vector2(-size.x * 0.5, size.y * 0.5)
	])
	body.add_child(polygon)
	return body

func _make_wall(position_value: Vector2, size: Vector2) -> StaticBody2D:
	var wall := _make_static_rect(position_value, size)
	for child in wall.get_children():
		if child is Polygon2D:
			child.color = Color("#1d2b3e")
	return wall
