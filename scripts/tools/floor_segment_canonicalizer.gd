extends SceneTree

const ROOMS_PATH := "res://data/rooms.json"
const USAGE_ERROR := (
	"Usage: godot --headless --path . -s res://scripts/tools/floor_segment_canonicalizer.gd -- "
	+ "<room_id> [room_id...]"
)


func _init() -> void:
	var room_ids := PackedStringArray(OS.get_cmdline_user_args())

	var source_text := FileAccess.get_file_as_string(ROOMS_PATH)
	var root_value = JSON.parse_string(source_text)
	if typeof(root_value) != TYPE_DICTIONARY:
		push_error("Failed to parse %s as room catalog JSON" % ROOMS_PATH)
		quit(1)
		return

	var root: Dictionary = root_value
	var rooms_value = root.get("rooms", [])
	if typeof(rooms_value) != TYPE_ARRAY:
		push_error("%s must contain an array 'rooms' field" % ROOMS_PATH)
		quit(1)
		return

	var rooms: Array = rooms_value
	var room_match_result := build_requested_room_match_result(room_ids, rooms)
	if not bool(room_match_result.get("ok", false)):
		push_error(str(room_match_result.get("error", "")))
		quit(1)
		return

	var matched_indices: Array = room_match_result.get("matched_indices", [])
	for room_index_value in matched_indices:
		var room_index := int(room_index_value)
		var room: Dictionary = rooms[room_index]
		var room_id := str(room.get("id", ""))
		var normalization_result := _normalize_floor_segments_to_canonical(
			room_id,
			Array(room.get("floor_segments", []))
		)
		if not bool(normalization_result.get("ok", false)):
			quit(1)
			return
		room["floor_segments"] = Array(normalization_result.get("segments", []))
		rooms[room_index] = room

	root["rooms"] = rooms
	var file := FileAccess.open(ROOMS_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open %s for writing" % ROOMS_PATH)
		quit(1)
		return
	file.store_string(JSON.stringify(root, "\t") + "\n")
	print("Canonicalized %d room(s): %s" % [matched_indices.size(), str(room_ids)])
	quit()


func _normalize_floor_segments_to_canonical(room_id: String, floor_segments: Array) -> Dictionary:
	var normalization_result := build_floor_segment_normalization_result(room_id, floor_segments)
	if bool(normalization_result.get("ok", false)):
		return normalization_result
	push_error(str(normalization_result.get("error", "")))
	return {"ok": false, "segments": []}


static func build_floor_segment_normalization_result(
	room_id: String, floor_segments: Array
) -> Dictionary:
	var canonical_segments: Array = []
	for segment_index in floor_segments.size():
		var raw_segment = floor_segments[segment_index]
		var segment_data := GameDatabase.normalize_floor_segment_to_canonical_dictionary(raw_segment)
		if not segment_data.is_empty():
			canonical_segments.append(segment_data)
			continue
		return {
			"ok": false,
			"segments": [],
			"error":
			(
				"Room '%s' floor_segments[%d] is not canonical dictionary shape; "
				+ "legacy floor-segment conversion is retired from this tool."
			)
			% [room_id, segment_index]
		}
	return {"ok": true, "segments": canonical_segments, "error": ""}


static func build_requested_room_match_result(
	requested_room_ids: PackedStringArray, rooms: Array
) -> Dictionary:
	if requested_room_ids.is_empty():
		return {"ok": false, "matched_indices": [], "error": USAGE_ERROR}

	var matched_indices: Array = []
	for room_index in rooms.size():
		if typeof(rooms[room_index]) != TYPE_DICTIONARY:
			continue
		var room: Dictionary = rooms[room_index]
		var room_id := str(room.get("id", ""))
		if requested_room_ids.has(room_id):
			matched_indices.append(room_index)
	if matched_indices.is_empty():
		return {
			"ok": false,
			"matched_indices": [],
			"error": "No rooms matched the requested ids: %s" % str(requested_room_ids)
		}
	return {"ok": true, "matched_indices": matched_indices, "error": ""}
