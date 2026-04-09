extends RefCounted

var current_room_id := "entrance"
var save_room_id := "entrance"
var save_spawn_position := Vector2(140, 480)
var core_activated := false
var boss_defeated := false
var seen_room_texts: Dictionary = {}
var seen_echoes: Dictionary = {}
var progression_flags: Dictionary = {}


func reset() -> void:
	current_room_id = "entrance"
	save_room_id = "entrance"
	save_spawn_position = Vector2(140, 480)
	core_activated = false
	boss_defeated = false
	seen_room_texts = {}
	seen_echoes = {}
	progression_flags = {}


func save_progress(room_id: String, spawn_position: Vector2) -> void:
	save_room_id = room_id
	save_spawn_position = spawn_position


func restore_current_room() -> void:
	current_room_id = save_room_id


func build_save_payload() -> Dictionary:
	return {
		"current_room_id": current_room_id,
		"save_room_id": save_room_id,
		"save_spawn_x": save_spawn_position.x,
		"save_spawn_y": save_spawn_position.y,
		"core_activated": core_activated,
		"boss_defeated": boss_defeated,
		"progression_flags": progression_flags,
		"seen_room_texts": seen_room_texts,
		"seen_echoes": seen_echoes
	}


func load_save_payload(parsed: Dictionary) -> void:
	current_room_id = str(parsed.get("current_room_id", current_room_id))
	save_room_id = str(parsed.get("save_room_id", save_room_id))
	save_spawn_position = Vector2(
		float(parsed.get("save_spawn_x", save_spawn_position.x)),
		float(parsed.get("save_spawn_y", save_spawn_position.y))
	)
	core_activated = bool(parsed.get("core_activated", core_activated))
	boss_defeated = bool(parsed.get("boss_defeated", boss_defeated))
	progression_flags = parsed.get("progression_flags", progression_flags)
	seen_room_texts = parsed.get("seen_room_texts", seen_room_texts)
	seen_echoes = parsed.get("seen_echoes", seen_echoes)
