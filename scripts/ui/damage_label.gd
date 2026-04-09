extends Label

const SCHOOL_COLORS := {
	"fire": Color(1.0, 0.55, 0.15),
	"ice": Color(0.45, 0.85, 1.0),
	"lightning": Color(1.0, 0.95, 0.2),
	"dark": Color(0.75, 0.3, 1.0),
	"": Color(1.0, 1.0, 1.0),
}
const SOUL_RISK_ACTIVE_TINT := Color(0.96, 0.74, 1.0)
const SOUL_RISK_AFTERSHOCK_TINT := Color(1.0, 0.86, 0.72)
const SOUL_RISK_ACTIVE_SCALE := 1.12
const SOUL_RISK_AFTERSHOCK_SCALE := 1.06


func setup(amount: int, pos: Vector2, school: String = "") -> void:
	global_position = pos + Vector2(randf_range(-12.0, 12.0), -30.0)
	text = str(amount)
	add_theme_font_size_override("font_size", 20)
	var base_color: Color = SCHOOL_COLORS.get(school, Color(1.0, 1.0, 1.0))
	modulate = _get_soul_risk_damage_label_color(base_color)
	scale = Vector2.ONE * _get_soul_risk_damage_label_scale()
	z_index = 10


func _physics_process(delta: float) -> void:
	global_position.y -= 60.0 * delta
	modulate.a -= 1.5 * delta
	if modulate.a <= 0.0:
		queue_free()


func _get_soul_risk_damage_label_color(base_color: Color) -> Color:
	if GameState.soul_dominion_active:
		return base_color.lerp(SOUL_RISK_ACTIVE_TINT, 0.30)
	if GameState.soul_dominion_aftershock_timer > 0.0:
		return base_color.lerp(SOUL_RISK_AFTERSHOCK_TINT, 0.26)
	return base_color


func _get_soul_risk_damage_label_scale() -> float:
	if GameState.soul_dominion_active:
		return SOUL_RISK_ACTIVE_SCALE
	if GameState.soul_dominion_aftershock_timer > 0.0:
		return SOUL_RISK_AFTERSHOCK_SCALE
	return 1.0
