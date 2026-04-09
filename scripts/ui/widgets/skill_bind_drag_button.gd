extends Button

class_name SkillBindDragButton

const SKILL_VISUAL_HELPER := preload("res://scripts/ui/widgets/skill_visual_helper.gd")

var skill_id := ""


func _get_drag_data(_at_position: Vector2) -> Variant:
	var payload := get_drag_payload()
	if payload.is_empty():
		return null
	var preview := SKILL_VISUAL_HELPER.build_drag_preview(
		str(payload.get("skill_id", skill_id)),
		str(payload.get("display_name", skill_id))
	)
	set_drag_preview(preview)
	return payload


func get_drag_payload() -> Dictionary:
	if skill_id == "":
		return {}
	var resolved_skill_id := GameDatabase.get_runtime_castable_skill_id(skill_id)
	if resolved_skill_id == "":
		resolved_skill_id = skill_id
	var skill_data: Dictionary = GameDatabase.get_skill_data(resolved_skill_id)
	var display_name := str(skill_data.get("display_name", resolved_skill_id))
	return {
		"type": "skill_hotkey_bind",
		"skill_id": resolved_skill_id,
		"display_name": display_name
	}
