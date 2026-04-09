extends RefCounted

class_name SkillVisualHelper

const ICON_BORDER := Color(0.08, 0.10, 0.16, 0.95)
const ICON_HIGHLIGHT_ALPHA := 0.22
const ICON_INNER_DARKEN := 0.16

static var _icon_cache: Dictionary = {}
static var _school_colors := {
	"fire": Color(0.95, 0.38, 0.12, 1.0),
	"ice": Color(0.30, 0.72, 0.95, 1.0),
	"lightning": Color(0.95, 0.88, 0.15, 1.0),
	"dark": Color(0.62, 0.22, 0.90, 1.0),
	"plant": Color(0.28, 0.82, 0.30, 1.0),
	"holy": Color(0.95, 0.93, 0.68, 1.0),
	"arcane": Color(0.72, 0.58, 1.0, 1.0),
	"earth": Color(0.72, 0.54, 0.32, 1.0),
	"water": Color(0.26, 0.70, 0.98, 1.0),
	"wind": Color(0.58, 0.92, 0.82, 1.0),
	"": Color(0.72, 0.75, 0.82, 1.0)
}


static func apply_skill_icon(button: Button, skill_id: String, icon_size: int = 20) -> void:
	if button == null:
		return
	if skill_id == "":
		button.icon = null
		return
	button.icon = get_skill_icon(skill_id, icon_size)
	button.expand_icon = false
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER


static func build_drag_preview(skill_id: String, display_name: String) -> Control:
	var preview := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.19, 0.28, 0.96)
	style.border_color = Color(0.43, 0.68, 0.96, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 10
	style.content_margin_top = 7
	style.content_margin_right = 10
	style.content_margin_bottom = 7
	preview.add_theme_stylebox_override("panel", style)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	preview.add_child(row)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(22.0, 22.0)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = get_skill_icon(skill_id, 22)
	row.add_child(icon)

	var label := Label.new()
	label.text = display_name
	label.modulate = Color(0.96, 0.98, 1.0, 0.96)
	row.add_child(label)
	return preview


static func get_skill_icon(skill_id: String, icon_size: int = 20) -> Texture2D:
	var resolved_skill_id := GameDatabase.get_runtime_castable_skill_id(skill_id)
	if resolved_skill_id == "":
		resolved_skill_id = skill_id
	var school := _resolve_skill_school(resolved_skill_id)
	var cache_key := "%s:%d" % [school, icon_size]
	if _icon_cache.has(cache_key):
		return _icon_cache[cache_key]
	var texture := _build_school_icon_texture(school, icon_size)
	_icon_cache[cache_key] = texture
	return texture


static func _resolve_skill_school(skill_id: String) -> String:
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	var runtime_data: Dictionary = GameDatabase.get_spell(skill_id)
	var school := str(skill_data.get("element", skill_data.get("school", "")))
	if school == "":
		school = str(runtime_data.get("school", ""))
	if school == "":
		school = GameState.resolve_runtime_school(skill_id, skill_id)
	return school


static func _build_school_icon_texture(school: String, icon_size: int) -> Texture2D:
	var size := maxi(icon_size, 12)
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var base_color: Color = _school_colors.get(school, _school_colors[""])
	var inner_color := base_color.darkened(ICON_INNER_DARKEN)
	var highlight := base_color.lightened(0.30)
	for y in range(size):
		for x in range(size):
			var pixel := inner_color
			if x == 0 or y == 0 or x == size - 1 or y == size - 1:
				pixel = ICON_BORDER
			elif x == 1 or y == 1 or x == size - 2 or y == size - 2:
				pixel = base_color.darkened(0.28)
			elif x + y < size / 2:
				pixel = inner_color.lerp(highlight, ICON_HIGHLIGHT_ALPHA)
			elif abs(x - y) <= 1:
				pixel = inner_color.lerp(highlight, 0.12)
			image.set_pixel(x, y, pixel)
	var texture := ImageTexture.create_from_image(image)
	return texture
