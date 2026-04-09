extends "res://addons/gut/test.gd"

const ROOM_BUILDER_SCRIPT := preload("res://scripts/world/room_builder.gd")


func _make_canonical_floor_segment(
	position_value: Vector2,
	size: Vector2,
	decor_kind: String = "",
	collision_mode: String = ""
) -> Dictionary:
	var segment := {
		"position": [int(position_value.x), int(position_value.y)],
		"size": [int(size.x), int(size.y)]
	}
	if not decor_kind.is_empty():
		segment["decor_kind"] = decor_kind
	if not collision_mode.is_empty():
		segment["collision_mode"] = collision_mode
	return segment


func _get_static_bodies(room_layer: Node2D) -> Array:
	var bodies: Array = []
	for child in room_layer.get_children():
		if child is StaticBody2D:
			bodies.append(child)
	return bodies


func _get_collision_shape(body: StaticBody2D) -> CollisionShape2D:
	for child in body.get_children():
		if child is CollisionShape2D:
			return child
	return null


func _count_static_bodies_with_kind(room_layer: Node2D, collision_kind: String) -> int:
	var count := 0
	for body in _get_static_bodies(room_layer):
		if str(body.get_meta("collision_kind", "")) == collision_kind:
			count += 1
	return count


func _find_static_body_at_position(room_layer: Node2D, position_value: Vector2) -> StaticBody2D:
	for body in _get_static_bodies(room_layer):
		if body.position == position_value:
			return body
	return null


func test_build_adds_background_and_segment_decor_layers() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "entrance",
		"width": 1600,
		"background": "#132033",
		"floor_segments": [
			_make_canonical_floor_segment(Vector2(800, 664), Vector2(1600, 112)),
			_make_canonical_floor_segment(Vector2(980, 520), Vector2(260, 24))
		]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	assert_true(room_layer.has_node("BackgroundLayer"))
	assert_true(room_layer.has_node("TerrainDecorLayer"))
	assert_true(room_layer.has_node("LandmarkLayer"))
	assert_gt(room_layer.get_node("BackgroundLayer").get_child_count(), 2)

	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), 2)
	assert_true(terrain_layer.get_child(0).has_node("GroundDecor"))
	assert_true(terrain_layer.get_child(1).has_node("PlatformDecor"))


func test_thin_floor_collision_profile_uses_one_way_top_strip() -> void:
	var builder = ROOM_BUILDER_SCRIPT.new()
	var profile: Dictionary = builder._build_floor_collision_profile(Vector2(260, 24))

	assert_eq(str(profile.get("collision_kind", "")), "one_way_platform")
	assert_true(bool(profile.get("one_way", false)))
	assert_eq(profile.get("shape_size", Vector2.ZERO), Vector2(260, 8))
	assert_eq(profile.get("shape_offset", Vector2.ZERO), Vector2(0, -8))
	assert_eq(float(profile.get("one_way_margin", 0.0)), 2.0)


func test_ground_floor_collision_profile_remains_full_solid() -> void:
	var builder = ROOM_BUILDER_SCRIPT.new()
	var size := Vector2(1600, 112)
	var profile: Dictionary = builder._build_floor_collision_profile(size)

	assert_eq(str(profile.get("collision_kind", "")), "solid_floor")
	assert_false(bool(profile.get("one_way", false)))
	assert_eq(profile.get("shape_size", Vector2.ZERO), size)
	assert_eq(profile.get("shape_offset", Vector2.ZERO), Vector2.ZERO)
	assert_eq(float(profile.get("one_way_margin", 1.0)), 0.0)


func test_normalize_floor_segment_supports_dictionary_schema_and_override_fields() -> void:
	var builder = ROOM_BUILDER_SCRIPT.new()
	var segment_spec: Dictionary = builder._normalize_floor_segment(
		{
			"position": [420, 508],
			"size": Vector2(220, 24),
			"decor_kind": "ground",
			"collision_mode": "solid"
		}
	)

	assert_true(bool(segment_spec.get("valid", false)))
	assert_eq(segment_spec.get("position", Vector2.ZERO), Vector2(420, 508))
	assert_eq(segment_spec.get("size", Vector2.ZERO), Vector2(220, 24))
	assert_eq(str(segment_spec.get("decor_kind", "")), "ground")
	assert_eq(str(segment_spec.get("collision_mode", "")), "solid")


func test_normalize_floor_segment_rejects_legacy_array_entry() -> void:
	var builder = ROOM_BUILDER_SCRIPT.new()
	var segment_spec: Dictionary = builder._normalize_floor_segment([1130, 438, 320, 64])

	assert_false(bool(segment_spec.get("valid", false)))
	assert_push_warning(
		"legacy floor segment array; runtime room builder expects canonical dictionary floor_segments",
		"Room-builder runtime path must reject legacy array entries"
	)


func test_normalize_floor_segment_rejects_legacy_xy_fallback_dictionary() -> void:
	var builder = ROOM_BUILDER_SCRIPT.new()
	var segment_spec: Dictionary = builder._normalize_floor_segment(
		{"x": 1130, "y": 438, "width": 320, "height": 64}
	)

	assert_false(bool(segment_spec.get("valid", false)))
	assert_push_warning(
		"legacy floor segment dictionary; runtime room builder expects position/size arrays",
		"Room-builder runtime path must reject x/y/width/height fallback dictionaries"
	)


func test_build_ignores_legacy_entries_even_without_legacy_format_flag() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "schema_mix",
		"width": 1760,
		"background": "#1b2230",
		"floor_segments": [
			[880, 664, 1760, 112],
			_make_canonical_floor_segment(Vector2(420, 508), Vector2(220, 24), "ground", "solid"),
			{
				"x": 1130,
				"y": 438,
				"width": 320,
				"height": 64,
				"decor_kind": "platform",
				"collision_mode": "one_way_platform"
			}
		]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), 1)
	assert_true(terrain_layer.get_child(0).has_node("GroundDecor"))

	assert_eq(_count_static_bodies_with_kind(room_layer, "solid_floor"), 1)
	assert_eq(_count_static_bodies_with_kind(room_layer, "one_way_platform"), 0)
	assert_eq(_count_static_bodies_with_kind(room_layer, "boundary_wall"), 2)

	var forced_ground_body := _find_static_body_at_position(room_layer, Vector2(420, 508))
	assert_not_null(forced_ground_body)
	assert_null(_find_static_body_at_position(room_layer, Vector2(880, 664)))
	assert_null(_find_static_body_at_position(room_layer, Vector2(1130, 438)))
	assert_eq(forced_ground_body.get_meta("collision_kind", ""), "solid_floor")

	var forced_ground_shape := _get_collision_shape(forced_ground_body)
	assert_not_null(forced_ground_shape)
	assert_false(forced_ground_shape.one_way_collision)
	assert_eq(forced_ground_shape.position, Vector2.ZERO)
	assert_eq((forced_ground_shape.shape as RectangleShape2D).size, Vector2(220, 24))
	assert_push_warning(
		"legacy floor segment array; runtime room builder expects canonical dictionary floor_segments",
		"Runtime path must skip legacy array entries even without any format flag"
	)
	assert_push_warning(
		"legacy floor segment dictionary; runtime room builder expects position/size arrays",
		"Runtime path must skip x/y/width/height fallback entries even without any format flag"
	)


func test_build_default_canonical_path_skips_legacy_arrays() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "schema_default_canonical",
		"width": 1760,
		"background": "#1b2230",
		"floor_segments": [
			[880, 664, 1760, 112],
			_make_canonical_floor_segment(Vector2(420, 508), Vector2(220, 24))
		]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), 1)
	assert_eq(_count_static_bodies_with_kind(room_layer, "one_way_platform"), 1)
	assert_eq(_count_static_bodies_with_kind(room_layer, "boundary_wall"), 2)
	assert_push_warning(
		"legacy floor segment array; runtime room builder expects canonical dictionary floor_segments",
		"Default room-builder path must skip legacy array entries"
	)


func test_build_supports_generated_floor_5_room_with_canonical_floor_segments() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data: Dictionary = GameDatabase.get_room("f5_transition_01")
	var room_width := int(room_data.get("width", 0))

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var floor_segments: Array = room_data.get("floor_segments", [])
	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), floor_segments.size())
	for raw_segment in floor_segments:
		assert_eq(typeof(raw_segment), TYPE_DICTIONARY)

	var upper_platform_body := _find_static_body_at_position(room_layer, Vector2(room_width - 260, 246))
	assert_not_null(upper_platform_body)
	assert_eq(upper_platform_body.get_meta("collision_kind", ""), "one_way_platform")
	var upper_platform_shape := _get_collision_shape(upper_platform_body)
	assert_not_null(upper_platform_shape)
	assert_true(upper_platform_shape.one_way_collision)
	assert_eq(upper_platform_shape.position, Vector2(0, -8))
	assert_eq((upper_platform_shape.shape as RectangleShape2D).size, Vector2(200, 8))


func test_build_supports_checked_in_entrance_room_with_canonical_floor_segments() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data: Dictionary = GameDatabase.get_room("entrance")

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var floor_segments: Array = room_data.get("floor_segments", [])
	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), floor_segments.size())
	for raw_segment in floor_segments:
		assert_eq(typeof(raw_segment), TYPE_DICTIONARY)

	var support_platform_body := _find_static_body_at_position(room_layer, Vector2(2250, 456))
	assert_not_null(support_platform_body)
	assert_eq(support_platform_body.get_meta("collision_kind", ""), "one_way_platform")
	var support_platform_shape := _get_collision_shape(support_platform_body)
	assert_not_null(support_platform_shape)
	assert_true(support_platform_shape.one_way_collision)
	assert_eq(support_platform_shape.position, Vector2(0, -8))
	assert_eq((support_platform_shape.shape as RectangleShape2D).size, Vector2(180, 8))


func test_build_supports_checked_in_seal_sanctum_room_with_canonical_floor_segments() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data: Dictionary = GameDatabase.get_room("seal_sanctum")

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var floor_segments: Array = room_data.get("floor_segments", [])
	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), floor_segments.size())
	for raw_segment in floor_segments:
		assert_eq(typeof(raw_segment), TYPE_DICTIONARY)

	var support_platform_body := _find_static_body_at_position(room_layer, Vector2(2540, 520))
	assert_not_null(support_platform_body)
	assert_eq(support_platform_body.get_meta("collision_kind", ""), "one_way_platform")
	var support_platform_shape := _get_collision_shape(support_platform_body)
	assert_not_null(support_platform_shape)
	assert_true(support_platform_shape.one_way_collision)
	assert_eq(support_platform_shape.position, Vector2(0, -8))
	assert_eq((support_platform_shape.shape as RectangleShape2D).size, Vector2(240, 8))


func test_build_supports_checked_in_gate_threshold_room_with_canonical_floor_segments() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data: Dictionary = GameDatabase.get_room("gate_threshold")

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var floor_segments: Array = room_data.get("floor_segments", [])
	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), floor_segments.size())
	for raw_segment in floor_segments:
		assert_eq(typeof(raw_segment), TYPE_DICTIONARY)

	var upper_checkpoint_body := _find_static_body_at_position(room_layer, Vector2(1760, 370))
	assert_not_null(upper_checkpoint_body)
	assert_eq(upper_checkpoint_body.get_meta("collision_kind", ""), "one_way_platform")
	var upper_checkpoint_shape := _get_collision_shape(upper_checkpoint_body)
	assert_not_null(upper_checkpoint_shape)
	assert_true(upper_checkpoint_shape.one_way_collision)
	assert_eq(upper_checkpoint_shape.position, Vector2(0, -8))
	assert_eq((upper_checkpoint_shape.shape as RectangleShape2D).size, Vector2(320, 8))


func test_build_supports_checked_in_royal_inner_hall_room_with_canonical_floor_segments() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data: Dictionary = GameDatabase.get_room("royal_inner_hall")

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var floor_segments: Array = room_data.get("floor_segments", [])
	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), floor_segments.size())
	for raw_segment in floor_segments:
		assert_eq(typeof(raw_segment), TYPE_DICTIONARY)

	var support_trace_body := _find_static_body_at_position(room_layer, Vector2(2000, 376))
	assert_not_null(support_trace_body)
	assert_eq(support_trace_body.get_meta("collision_kind", ""), "one_way_platform")
	var support_trace_shape := _get_collision_shape(support_trace_body)
	assert_not_null(support_trace_shape)
	assert_true(support_trace_shape.one_way_collision)
	assert_eq(support_trace_shape.position, Vector2(0, -8))
	assert_eq((support_trace_shape.shape as RectangleShape2D).size, Vector2(280, 8))


func test_build_supports_checked_in_throne_approach_room_with_canonical_floor_segments() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data: Dictionary = GameDatabase.get_room("throne_approach")

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var floor_segments: Array = room_data.get("floor_segments", [])
	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), floor_segments.size())
	for raw_segment in floor_segments:
		assert_eq(typeof(raw_segment), TYPE_DICTIONARY)

	var decree_stair_body := _find_static_body_at_position(room_layer, Vector2(2440, 290))
	assert_not_null(decree_stair_body)
	assert_eq(decree_stair_body.get_meta("collision_kind", ""), "one_way_platform")
	var decree_stair_shape := _get_collision_shape(decree_stair_body)
	assert_not_null(decree_stair_shape)
	assert_true(decree_stair_shape.one_way_collision)
	assert_eq(decree_stair_shape.position, Vector2(0, -8))
	assert_eq((decree_stair_shape.shape as RectangleShape2D).size, Vector2(260, 8))


func test_build_supports_checked_in_inverted_spire_room_with_canonical_floor_segments() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data: Dictionary = GameDatabase.get_room("inverted_spire")

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var floor_segments: Array = room_data.get("floor_segments", [])
	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), floor_segments.size())
	for raw_segment in floor_segments:
		assert_eq(typeof(raw_segment), TYPE_DICTIONARY)

	var flank_pocket_body := _find_static_body_at_position(room_layer, Vector2(3180, 332))
	assert_not_null(flank_pocket_body)
	assert_eq(flank_pocket_body.get_meta("collision_kind", ""), "one_way_platform")
	var flank_pocket_shape := _get_collision_shape(flank_pocket_body)
	assert_not_null(flank_pocket_shape)
	assert_true(flank_pocket_shape.one_way_collision)
	assert_eq(flank_pocket_shape.position, Vector2(0, -8))
	assert_eq((flank_pocket_shape.shape as RectangleShape2D).size, Vector2(180, 8))


func test_build_supports_checked_in_arcane_core_room_with_canonical_floor_segments() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data: Dictionary = GameDatabase.get_room("arcane_core")

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var floor_segments: Array = room_data.get("floor_segments", [])
	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), floor_segments.size())
	for raw_segment in floor_segments:
		assert_eq(typeof(raw_segment), TYPE_DICTIONARY)

	var top_perch_body := _find_static_body_at_position(room_layer, Vector2(1980, 180))
	assert_not_null(top_perch_body)
	assert_eq(top_perch_body.get_meta("collision_kind", ""), "one_way_platform")
	var top_perch_shape := _get_collision_shape(top_perch_body)
	assert_not_null(top_perch_shape)
	assert_true(top_perch_shape.one_way_collision)
	assert_eq(top_perch_shape.position, Vector2(0, -8))
	assert_eq((top_perch_shape.shape as RectangleShape2D).size, Vector2(180, 8))


func test_build_supports_checked_in_void_rift_room_with_canonical_floor_segments() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data: Dictionary = GameDatabase.get_room("void_rift")

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var floor_segments: Array = room_data.get("floor_segments", [])
	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), floor_segments.size())
	for raw_segment in floor_segments:
		assert_eq(typeof(raw_segment), TYPE_DICTIONARY)

	var top_rift_perch_body := _find_static_body_at_position(room_layer, Vector2(1640, 160))
	assert_not_null(top_rift_perch_body)
	assert_eq(top_rift_perch_body.get_meta("collision_kind", ""), "one_way_platform")
	var top_rift_perch_shape := _get_collision_shape(top_rift_perch_body)
	assert_not_null(top_rift_perch_shape)
	assert_true(top_rift_perch_shape.one_way_collision)
	assert_eq(top_rift_perch_shape.position, Vector2(0, -8))
	assert_eq((top_rift_perch_shape.shape as RectangleShape2D).size, Vector2(160, 8))


func test_build_supports_checked_in_deep_gate_room_with_canonical_floor_segments() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data: Dictionary = GameDatabase.get_room("deep_gate")

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var floor_segments: Array = room_data.get("floor_segments", [])
	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), floor_segments.size())
	for raw_segment in floor_segments:
		assert_eq(typeof(raw_segment), TYPE_DICTIONARY)

	var top_gate_body := _find_static_body_at_position(room_layer, Vector2(1470, 320))
	assert_not_null(top_gate_body)
	assert_eq(top_gate_body.get_meta("collision_kind", ""), "one_way_platform")
	var top_gate_shape := _get_collision_shape(top_gate_body)
	assert_not_null(top_gate_shape)
	assert_true(top_gate_shape.one_way_collision)
	assert_eq(top_gate_shape.position, Vector2(0, -8))
	assert_eq((top_gate_shape.shape as RectangleShape2D).size, Vector2(220, 8))


func test_build_supports_checked_in_conduit_room_with_canonical_floor_segments() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data: Dictionary = GameDatabase.get_room("conduit")

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var floor_segments: Array = room_data.get("floor_segments", [])
	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), floor_segments.size())
	for raw_segment in floor_segments:
		assert_eq(typeof(raw_segment), TYPE_DICTIONARY)

	var top_conduit_body := _find_static_body_at_position(room_layer, Vector2(1450, 350))
	assert_not_null(top_conduit_body)
	assert_eq(top_conduit_body.get_meta("collision_kind", ""), "one_way_platform")
	var top_conduit_shape := _get_collision_shape(top_conduit_body)
	assert_not_null(top_conduit_shape)
	assert_true(top_conduit_shape.one_way_collision)
	assert_eq(top_conduit_shape.position, Vector2(0, -8))
	assert_eq((top_conduit_shape.shape as RectangleShape2D).size, Vector2(240, 8))


func test_build_supports_checked_in_vault_sector_room_with_canonical_floor_segments() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data: Dictionary = GameDatabase.get_room("vault_sector")

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var floor_segments: Array = room_data.get("floor_segments", [])
	var terrain_layer: Node = room_layer.get_node("TerrainDecorLayer")
	assert_eq(terrain_layer.get_child_count(), floor_segments.size())
	for raw_segment in floor_segments:
		assert_eq(typeof(raw_segment), TYPE_DICTIONARY)

	var top_vault_body := _find_static_body_at_position(room_layer, Vector2(1720, 270))
	assert_not_null(top_vault_body)
	assert_eq(top_vault_body.get_meta("collision_kind", ""), "one_way_platform")
	var top_vault_shape := _get_collision_shape(top_vault_body)
	assert_not_null(top_vault_shape)
	assert_true(top_vault_shape.one_way_collision)
	assert_eq(top_vault_shape.position, Vector2(0, -8))
	assert_eq((top_vault_shape.shape as RectangleShape2D).size, Vector2(200, 8))


func test_build_preserves_collision_segments_and_walls() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "conduit",
		"width": 1920,
		"background": "#24193b",
		"floor_segments": [
			_make_canonical_floor_segment(Vector2(960, 664), Vector2(1920, 112)),
			_make_canonical_floor_segment(Vector2(520, 510), Vector2(250, 24)),
			_make_canonical_floor_segment(Vector2(980, 430), Vector2(240, 24))
		]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var static_bodies := _get_static_bodies(room_layer)
	var solid_floor_count := _count_static_bodies_with_kind(room_layer, "solid_floor")
	var one_way_platform_count := _count_static_bodies_with_kind(room_layer, "one_way_platform")
	var boundary_wall_count := _count_static_bodies_with_kind(room_layer, "boundary_wall")

	assert_eq(static_bodies.size(), 5, "three floor segments plus two boundary walls should remain")
	assert_eq(solid_floor_count + one_way_platform_count, 3, "all floor segments should remain present")
	assert_eq(boundary_wall_count, 2, "both boundary walls should remain present")


func test_build_marks_thin_platform_collisions_as_one_way_and_ground_as_solid() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "entrance",
		"width": 1600,
		"background": "#132033",
		"floor_segments": [
			_make_canonical_floor_segment(Vector2(800, 664), Vector2(1600, 112)),
			_make_canonical_floor_segment(Vector2(980, 520), Vector2(260, 24))
		]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var thin_platform: StaticBody2D = null
	var ground_segment: StaticBody2D = null
	for body in _get_static_bodies(room_layer):
		match str(body.get_meta("collision_kind", "")):
			"one_way_platform":
				thin_platform = body
			"solid_floor":
				ground_segment = body

	assert_not_null(thin_platform)
	assert_not_null(ground_segment)

	var platform_shape := _get_collision_shape(thin_platform)
	var ground_shape := _get_collision_shape(ground_segment)
	assert_not_null(platform_shape)
	assert_not_null(ground_shape)
	assert_true(platform_shape.one_way_collision)
	assert_eq(platform_shape.position, Vector2(0, -8))
	assert_eq((platform_shape.shape as RectangleShape2D).size, Vector2(260, 8))
	assert_eq(platform_shape.get_meta("collision_kind", ""), "one_way_platform")
	assert_false(ground_shape.one_way_collision)
	assert_eq(ground_shape.position, Vector2.ZERO)
	assert_eq((ground_shape.shape as RectangleShape2D).size, Vector2(1600, 112))
	assert_eq(ground_shape.get_meta("collision_kind", ""), "solid_floor")


func test_build_adds_outer_ruins_landmarks_for_entrance_theme() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "entrance",
		"theme": "outer_ruins",
		"width": 1600,
		"background": "#1b2230",
		"floor_segments": [
			_make_canonical_floor_segment(Vector2(800, 664), Vector2(1600, 112)),
			_make_canonical_floor_segment(Vector2(520, 556), Vector2(220, 24)),
			_make_canonical_floor_segment(Vector2(930, 492), Vector2(260, 24))
		]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var landmark_layer: Node = room_layer.get_node("LandmarkLayer")
	assert_gt(landmark_layer.get_child_count(), 0)
	assert_true(landmark_layer.has_node("CollapsedButtress"))
	assert_true(landmark_layer.has_node("BrokenWatchtower"))
	assert_true(landmark_layer.has_node("OuterWallSilhouette"))
	assert_true(landmark_layer.has_node("SignalMast"))
	assert_true(landmark_layer.has_node("FallenGateSpan"))


func test_build_adds_transition_landmarks_for_floor_5_theme() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "f5_transition_01",
		"theme": "transition_corridor",
		"width": 2760,
		"background": "#1d1b29",
		"floor_segments": [
			_make_canonical_floor_segment(Vector2(1380, 664), Vector2(2760, 112)),
			_make_canonical_floor_segment(Vector2(460, 544), Vector2(240, 24)),
			_make_canonical_floor_segment(Vector2(920, 476), Vector2(260, 24))
		]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var landmark_layer: Node = room_layer.get_node("LandmarkLayer")
	assert_gt(landmark_layer.get_child_count(), 0)
	assert_true(landmark_layer.has_node("TransitionWall"))
	assert_true(landmark_layer.has_node("BentCheckpoint"))
	assert_true(landmark_layer.has_node("ArchLeft"))
	assert_true(landmark_layer.has_node("ArchRight"))
	assert_true(landmark_layer.has_node("BrokenStair"))
	assert_true(landmark_layer.has_node("SignalChannel"))
	assert_true(landmark_layer.has_node("LoopbackBanner"))


func test_build_adds_sanctuary_landmarks_for_hub_theme() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "seal_sanctum",
		"theme": "sanctuary_hub",
		"width": 1960,
		"background": "#16212a",
		"floor_segments": [
			_make_canonical_floor_segment(Vector2(980, 664), Vector2(1960, 112)),
			_make_canonical_floor_segment(Vector2(420, 520), Vector2(220, 24)),
			_make_canonical_floor_segment(Vector2(1520, 520), Vector2(220, 24))
		]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var landmark_layer: Node = room_layer.get_node("LandmarkLayer")
	assert_gt(landmark_layer.get_child_count(), 0)
	assert_true(landmark_layer.has_node("SealStatue"))
	assert_true(landmark_layer.has_node("WardRing"))
	assert_true(landmark_layer.has_node("LeftShelter"))
	assert_true(landmark_layer.has_node("RightShelter"))
	assert_true(landmark_layer.has_node("WardBoundaryLeft"))
	assert_true(landmark_layer.has_node("WardBoundaryRight"))


func test_build_adds_gate_landmarks_for_gate_threshold_theme() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "gate_threshold",
		"theme": "gate_threshold",
		"width": 2040,
		"background": "#1a1828",
		"floor_segments": [
			_make_canonical_floor_segment(Vector2(1020, 664), Vector2(2040, 112)),
			_make_canonical_floor_segment(Vector2(520, 520), Vector2(220, 24)),
			_make_canonical_floor_segment(Vector2(980, 442), Vector2(260, 24))
		]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var landmark_layer: Node = room_layer.get_node("LandmarkLayer")
	assert_gt(landmark_layer.get_child_count(), 0)
	assert_true(landmark_layer.has_node("GateArch"))
	assert_true(landmark_layer.has_node("GateVoid"))
	assert_true(landmark_layer.has_node("LeftGuardian"))
	assert_true(landmark_layer.has_node("RightGuardian"))
	assert_true(landmark_layer.has_node("InspectionDais"))
	assert_true(landmark_layer.has_node("ChainArray"))
	assert_true(landmark_layer.has_node("JudgementBeam"))


func test_build_adds_inner_keep_landmarks_for_royal_hall_theme() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "royal_inner_hall",
		"theme": "inner_keep",
		"width": 2120,
		"background": "#21192a",
		"floor_segments": [
			_make_canonical_floor_segment(Vector2(1060, 664), Vector2(2120, 112)),
			_make_canonical_floor_segment(Vector2(560, 520), Vector2(220, 24)),
			_make_canonical_floor_segment(Vector2(1060, 430), Vector2(260, 24))
		]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var landmark_layer: Node = room_layer.get_node("LandmarkLayer")
	assert_true(landmark_layer.has_node("GrandHallBackdrop"))
	assert_true(landmark_layer.has_node("PortraitRowLeft"))
	assert_true(landmark_layer.has_node("PortraitRowRight"))
	assert_true(landmark_layer.has_node("CentralChandelier"))
	assert_true(landmark_layer.has_node("ArchiveCabinetLeft"))
	assert_true(landmark_layer.has_node("ArchiveCabinetRight"))
	assert_true(landmark_layer.has_node("WardTetherLeft"))
	assert_true(landmark_layer.has_node("WardTetherRight"))


func test_build_adds_throne_landmarks_for_throne_approach_theme() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "throne_approach",
		"theme": "throne_approach",
		"width": 2180,
		"background": "#24151f",
		"floor_segments": [
			_make_canonical_floor_segment(Vector2(1090, 664), Vector2(2180, 112)),
			_make_canonical_floor_segment(Vector2(700, 500), Vector2(240, 24)),
			_make_canonical_floor_segment(Vector2(1090, 418), Vector2(260, 24))
		]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var landmark_layer: Node = room_layer.get_node("LandmarkLayer")
	assert_true(landmark_layer.has_node("ApproachWall"))
	assert_true(landmark_layer.has_node("ThroneDais"))
	assert_true(landmark_layer.has_node("ThroneBack"))
	assert_true(landmark_layer.has_node("ThroneBannerLeft"))
	assert_true(landmark_layer.has_node("ThroneBannerRight"))
	assert_true(landmark_layer.has_node("DecreePillarLeft"))
	assert_true(landmark_layer.has_node("DecreePillarRight"))
	assert_true(landmark_layer.has_node("ProcessionRunes"))


func test_build_adds_inverted_spire_landmarks_for_final_core_theme() -> void:
	var room_layer: Node2D = autofree(Node2D.new())
	var builder = ROOM_BUILDER_SCRIPT.new()
	var room_data := {
		"id": "inverted_spire",
		"theme": "inverted_spire",
		"width": 2240,
		"background": "#120915",
		"floor_segments": [
			_make_canonical_floor_segment(Vector2(1120, 664), Vector2(2240, 112)),
			_make_canonical_floor_segment(Vector2(1120, 552), Vector2(520, 28)),
			_make_canonical_floor_segment(Vector2(560, 420), Vector2(220, 24))
		]
	}

	builder.build(room_layer, room_data, {"tint": Color("#ffffff")})

	var landmark_layer: Node = room_layer.get_node("LandmarkLayer")
	assert_gt(landmark_layer.get_child_count(), 0)
	assert_true(landmark_layer.has_node("TowerMass"))
	assert_true(landmark_layer.has_node("InvertedSpire"))
	assert_true(landmark_layer.has_node("CovenantDais"))
	assert_true(landmark_layer.has_node("CovenantRing"))
	assert_true(landmark_layer.has_node("RoyalCanopyRemnant"))
	assert_true(landmark_layer.has_node("SpireTalonLeft"))
	assert_true(landmark_layer.has_node("SpireTalonRight"))
