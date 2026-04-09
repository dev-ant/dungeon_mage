extends Button

class_name SkillHotbarDropButton

signal skill_payload_dropped(slot_index: int, skill_id: String)

var slot_index := -1


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return _extract_skill_id(data) != ""


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var skill_id := _extract_skill_id(data)
	if skill_id == "":
		return
	skill_payload_dropped.emit(slot_index, skill_id)


func _extract_skill_id(data: Variant) -> String:
	if typeof(data) != TYPE_DICTIONARY:
		return ""
	var payload: Dictionary = data
	if str(payload.get("type", "")) != "skill_hotkey_bind":
		return ""
	return str(payload.get("skill_id", ""))
