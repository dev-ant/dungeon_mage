extends "res://scripts/ui/widgets/ui_window_frame.gd"

const SCHOOL_ORDER := ["fire", "ice", "lightning", "wind", "water", "plant", "earth", "holy", "dark", "arcane"]
const SCHOOL_LABELS := {
	"fire": "화염",
	"ice": "빙결",
	"lightning": "번개",
	"wind": "바람",
	"water": "물",
	"plant": "식물",
	"earth": "대지",
	"holy": "성속",
	"dark": "암흑",
	"arcane": "비전"
}

var _primary_stats_label: Label = null
var _secondary_stats_label: Label = null
var _resonance_label: Label = null


func _enter_tree() -> void:
	window_id = "stat"
	window_title = "스텟"
	placeholder_text = ""
	default_size = Vector2(380.0, 420.0)
	default_position = Vector2(236.0, 126.0)


func _ready() -> void:
	super._ready()
	clear_content_root()
	_build_stat_content()
	_connect_runtime_signals()
	_refresh_stats()


func get_primary_stats_text() -> String:
	return "" if _primary_stats_label == null else _primary_stats_label.text


func get_resonance_text() -> String:
	return "" if _resonance_label == null else _resonance_label.text


func _build_stat_content() -> void:
	var content_root := get_content_root()
	if content_root == null:
		return

	var content := VBoxContainer.new()
	content.name = "StatContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	content_root.add_child(content)

	_primary_stats_label = Label.new()
	_primary_stats_label.name = "PrimaryStatsLabel"
	_primary_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_primary_stats_label)

	_secondary_stats_label = Label.new()
	_secondary_stats_label.name = "SecondaryStatsLabel"
	_secondary_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_secondary_stats_label)

	_resonance_label = Label.new()
	_resonance_label.name = "ResonanceLabel"
	_resonance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_resonance_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_resonance_label.modulate = Color(0.87, 0.93, 1.0, 0.96)
	content.add_child(_resonance_label)


func _connect_runtime_signals() -> void:
	if not GameState.stats_changed.is_connected(_refresh_stats):
		GameState.stats_changed.connect(_refresh_stats)


func _refresh_stats() -> void:
	if _primary_stats_label == null or _secondary_stats_label == null or _resonance_label == null:
		return

	var hp_text := "최대 HP: %d" % int(GameState.max_health)
	var mp_text := "최대 MP: %d" % int(round(GameState.max_mana))
	var mana_regen_text := "MP 재생: %.1f/s" % float(GameState.mana_regen_per_second)
	var circle_text := "현재 서클: %d (점수 %.1f)" % [int(GameState.get_current_circle()), float(GameState.get_circle_progress_score())]
	_primary_stats_label.text = "\n".join([hp_text, mp_text, mana_regen_text, circle_text])

	var magic_bonus_percent := int(round((GameState.get_equipment_damage_multiplier("arcane") - 1.0) * 100.0))
	var damage_reduction_percent := int(round((1.0 - GameState.get_equipment_damage_taken_multiplier()) * 100.0))
	var cooldown_recovery_percent := int(round((1.0 - GameState.get_equipment_cooldown_multiplier()) * 100.0))
	var cast_speed_percent := int(round(GameState.get_equipment_cast_speed_bonus() * 100.0))
	_secondary_stats_label.text = "\n".join(
		[
			"마공 보정: %d%%" % magic_bonus_percent,
			"피해 경감: %d%%" % damage_reduction_percent,
			"재사용 회복: %d%%" % cooldown_recovery_percent,
			"시전 속도: %d%%" % cast_speed_percent
		]
	)

	var resonance_lines: Array[String] = ["공명"]
	for school in SCHOOL_ORDER:
		var value := int(GameState.resonance.get(school, 0))
		resonance_lines.append("%s: %d" % [str(SCHOOL_LABELS.get(school, school)), value])
	_resonance_label.text = "\n".join(resonance_lines)
