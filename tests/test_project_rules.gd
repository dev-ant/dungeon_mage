extends "res://addons/gut/test.gd"

const SCAN_ROOTS := ["res://scenes", "res://scripts", "res://tests"]
const ASSET_SAMPLE_PREFIX := "res://asset" + "_sample/"


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
