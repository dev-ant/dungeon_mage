extends "res://addons/gut/test.gd"

const FLOOR_SEGMENT_CANONICALIZER_SCRIPT := preload("res://scripts/tools/floor_segment_canonicalizer.gd")


func test_canonicalizer_room_match_result_requires_room_ids() -> void:
	var result: Dictionary = FLOOR_SEGMENT_CANONICALIZER_SCRIPT.build_requested_room_match_result(
		PackedStringArray(),
		[{"id": "entrance"}]
	)

	assert_false(bool(result.get("ok", true)))
	assert_eq(Array(result.get("matched_indices", [])).size(), 0)
	assert_eq(str(result.get("error", "")), str(FLOOR_SEGMENT_CANONICALIZER_SCRIPT.USAGE_ERROR))


func test_canonicalizer_room_match_result_reports_no_matching_room_ids() -> void:
	var result: Dictionary = FLOOR_SEGMENT_CANONICALIZER_SCRIPT.build_requested_room_match_result(
		PackedStringArray(["missing_room"]),
		[{"id": "entrance"}, {"id": "seal_sanctum"}]
	)

	assert_false(bool(result.get("ok", true)))
	assert_eq(Array(result.get("matched_indices", [])).size(), 0)
	var error_message := str(result.get("error", ""))
	assert_string_contains(error_message, "No rooms matched the requested ids:")
	assert_string_contains(error_message, "missing_room")


func test_canonicalizer_room_match_result_returns_catalog_order_indices_for_matches() -> void:
	var result: Dictionary = FLOOR_SEGMENT_CANONICALIZER_SCRIPT.build_requested_room_match_result(
		PackedStringArray(["inverted_spire", "entrance"]),
		[{"id": "entrance"}, {"id": "seal_sanctum"}, {"id": "inverted_spire"}]
	)

	assert_true(bool(result.get("ok", false)))
	assert_eq(str(result.get("error", "")), "")
	assert_eq(result.get("matched_indices", []), [0, 2])


func test_canonicalizer_normalization_result_accepts_canonical_dictionary_segments() -> void:
	var result: Dictionary = FLOOR_SEGMENT_CANONICALIZER_SCRIPT.build_floor_segment_normalization_result(
		"canonical_room",
		[
			{"position": [820, 664], "size": [1640, 112]},
			{
				"position": [980, 520],
				"size": [260, 24],
				"decor_kind": "platform",
				"collision_mode": "one_way_platform"
			}
		]
	)

	assert_true(bool(result.get("ok", false)))
	assert_eq(str(result.get("error", "")), "")
	var segments: Array = result.get("segments", [])
	assert_eq(segments.size(), 2)
	assert_eq(segments[0], {"position": [820, 664], "size": [1640, 112]})
	assert_eq(segments[1], {"position": [980, 520], "size": [260, 24]})


func test_canonicalizer_normalization_result_rejects_legacy_array_and_reports_index() -> void:
	var result: Dictionary = FLOOR_SEGMENT_CANONICALIZER_SCRIPT.build_floor_segment_normalization_result(
		"legacy_room", [[820, 664, 1640, 112]]
	)

	assert_false(bool(result.get("ok", true)))
	assert_eq(Array(result.get("segments", [])).size(), 0)
	var error_message := str(result.get("error", ""))
	assert_string_contains(error_message, "legacy floor-segment conversion is retired from this tool.")
	assert_string_contains(error_message, "Room 'legacy_room' floor_segments[0]")


func test_canonicalizer_normalization_result_reports_first_invalid_segment_index() -> void:
	var result: Dictionary = FLOOR_SEGMENT_CANONICALIZER_SCRIPT.build_floor_segment_normalization_result(
		"mixed_room",
		[
			{"position": [820, 664], "size": [1640, 112]},
			{"x": 980, "y": 520, "width": 260, "height": 24}
		]
	)

	assert_false(bool(result.get("ok", true)))
	assert_eq(Array(result.get("segments", [])).size(), 0)
	var error_message := str(result.get("error", ""))
	assert_string_contains(error_message, "Room 'mixed_room' floor_segments[1]")
	assert_string_contains(error_message, "legacy floor-segment conversion is retired from this tool.")
