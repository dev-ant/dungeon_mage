extends "res://addons/gut/test.gd"

const ROOM_BUILDER_SCRIPT := preload("res://scripts/world/room_builder.gd")


func test_build_adds_background_and_segment_decor_layers() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "entrance",
		"width": 1600,
		"background": "#132033",
		"floor_segments": [[800, 664, 1600, 112], [980, 520, 260, 24]]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	assert_true(room_layer.has_node("BackgroundLayer"))
	assert_true(room_layer.has_node("TerrainDecorLayer"))
	assert_gt(room_layer.get_node("BackgroundLayer").get_child_count(), 2)

	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), 2)
	assert_true(terrain_layer.get_child(0).has_node("GroundDecor"))
	assert_true(terrain_layer.get_child(1).has_node("PlatformDecor"))


func test_build_preserves_collision_segments_and_walls() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "conduit",
		"width": 1920,
		"background": "#24193b",
		"floor_segments": [[960, 664, 1920, 112], [520, 510, 250, 24], [980, 430, 240, 24]]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var static_body_count := 0
	for child in room_layer.get_children():
		if child is StaticBody2D:
			static_body_count += 1

	assert_eq(static_body_count, 5, "three floor segments plus two boundary walls should remain")
