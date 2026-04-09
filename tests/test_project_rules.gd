extends "res://addons/gut/test.gd"

const SCAN_ROOTS := ["res://scenes", "res://scripts", "res://tests"]
const ASSET_SAMPLE_PREFIX := "res://asset" + "_sample/"
const FLOOR_SEGMENT_CANONICALIZER_PATH := "res://scripts/tools/floor_segment_canonicalizer.gd"
const GAME_DATABASE_PATH := "res://scripts/autoload/game_database.gd"
const ROOM_BUILDER_PATH := "res://scripts/world/room_builder.gd"
const GAME_STATE_TEST_PATH := "res://tests/test_game_state.gd"


func test_runtime_sources_do_not_reference_asset_sample_paths() -> void:
	var offending_paths: Array[String] = []
	for root in SCAN_ROOTS:
		_collect_asset_sample_references(root, offending_paths)
	assert_true(
		offending_paths.is_empty(),
		(
			"Runtime source files must not reference %s:\n%s"
			% [ASSET_SAMPLE_PREFIX, "\n".join(offending_paths)]
		)
	)


func test_floor_segment_canonicalizer_does_not_reintroduce_retired_format_metadata_write() -> void:
	var source := FileAccess.get_file_as_string(FLOOR_SEGMENT_CANONICALIZER_PATH)
	assert_false(
		source.contains("room[\"floor_segment_format\"]"),
		"Offline floor-segment canonicalizer must not write retired floor_segment_format metadata"
	)


func test_floor_segment_canonicalizer_keeps_legacy_fallback_helper_removed() -> void:
	var source := FileAccess.get_file_as_string(FLOOR_SEGMENT_CANONICALIZER_PATH)
	assert_false(
		source.contains("_is_legacy_floor_segment_fallback_dictionary"),
		"Offline floor-segment canonicalizer should stay canonical-only without a legacy fallback helper"
	)


func test_floor_segment_canonicalizer_delegates_to_game_database_canonical_helper() -> void:
	var source := FileAccess.get_file_as_string(FLOOR_SEGMENT_CANONICALIZER_PATH)
	assert_true(
		source.contains("GameDatabase.normalize_floor_segment_to_canonical_dictionary"),
		"Offline floor-segment canonicalizer should share canonical parsing with GameDatabase helper"
	)
	assert_true(
		source.contains("static func build_floor_segment_normalization_result("),
		"Offline floor-segment canonicalizer should keep a static normalization seam for deterministic tests"
	)
	assert_true(
		source.contains("static func build_requested_room_match_result("),
		"Offline floor-segment canonicalizer should keep a static room-id match seam for CLI contract tests"
	)
	for token in [
		"func _normalize_floor_segment_to_canonical(raw_segment)",
		"func _read_floor_segment_vector2(segment_data: Dictionary, vector_key: String)",
		"func _make_floor_segment_entry("
	]:
		assert_false(
			source.contains(token),
			"Offline floor-segment canonicalizer should not reintroduce duplicate helper '%s'" % token
		)


func test_room_builder_does_not_depend_on_retired_floor_segment_format_key() -> void:
	var source := FileAccess.get_file_as_string(ROOM_BUILDER_PATH)
	assert_false(
		source.contains("floor_segment_format"),
		"Runtime room builder must infer floor collision behavior from floor_segments shape/overrides only"
	)


func test_room_floor_segment_validator_does_not_keep_xy_fallback_parse_branch() -> void:
	var source := FileAccess.get_file_as_string(GAME_DATABASE_PATH)
	for token in [
		"must define %s/%s when %s is omitted",
		"must use numeric %s/%s values",
		"x_key: String",
		"y_key: String"
	]:
		assert_false(
			source.contains(token),
			"Room floor-segment validator should stay canonical-only without x/y fallback parse token '%s'"
			% token
		)


func test_runtime_and_validator_share_legacy_floor_segment_error_tokens() -> void:
	var builder_source := FileAccess.get_file_as_string(ROOM_BUILDER_PATH)
	var database_source := FileAccess.get_file_as_string(GAME_DATABASE_PATH)
	for token in ["legacy floor segment array", "legacy floor segment dictionary"]:
		assert_true(
			builder_source.contains(token),
			"room_builder source must keep legacy floor-segment token '%s' for warning contract" % token
		)
		assert_true(
			database_source.contains(token),
			"game_database source must keep legacy floor-segment token '%s' for validation contract" % token
		)


func test_floor_segment_test_helpers_do_not_restore_legacy_parse_tokens() -> void:
	var source := FileAccess.get_file_as_string(GAME_STATE_TEST_PATH)
	for token in [
		"segment_data.get(\"x\", 0.0)",
		"segment_data.get(\"y\", 0.0)",
		"segment_data.get(\"width\", 0.0)",
		"segment_data.get(\"height\", 0.0)"
	]:
		assert_false(
			source.contains(token),
			"Floor-segment test helpers must stay canonical-only without legacy parse token '%s'"
			% token
		)


func test_floor_segment_test_file_keeps_named_legacy_fixture_helpers() -> void:
	var source := FileAccess.get_file_as_string(GAME_STATE_TEST_PATH)
	for token in [
		"func _make_legacy_floor_segment_array_fixture() -> Array:",
		"func _make_legacy_floor_segment_xy_fallback_fixture() -> Dictionary:",
		"func _make_floor_segment_missing_size_array_fixture() -> Dictionary:"
	]:
		assert_true(
			source.contains(token),
			"Floor-segment tests should keep central legacy fixture helper '%s'" % token
		)


func _collect_asset_sample_references(path: String, offending_paths: Array[String]) -> void:
	if path.ends_with(".gd") or path.ends_with(".tscn"):
		var source := FileAccess.get_file_as_string(path)
		if source.contains(ASSET_SAMPLE_PREFIX):
			offending_paths.append(path)
		return
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var entry := dir.get_next()
		if entry == "":
			break
		if entry.begins_with("."):
			continue
		var child_path := path.path_join(entry)
		if dir.current_is_dir():
			_collect_asset_sample_references(child_path, offending_paths)
		elif child_path.ends_with(".gd") or child_path.ends_with(".tscn"):
			_collect_asset_sample_references(child_path, offending_paths)
	dir.list_dir_end()
