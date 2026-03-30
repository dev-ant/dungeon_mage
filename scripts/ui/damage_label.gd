extends Label

const SCHOOL_COLORS := {
	"fire": Color(1.0, 0.55, 0.15),
	"ice": Color(0.45, 0.85, 1.0),
	"lightning": Color(1.0, 0.95, 0.2),
	"dark": Color(0.75, 0.3, 1.0),
	"": Color(1.0, 1.0, 1.0),
}

func setup(amount: int, pos: Vector2, school: String = "") -> void:
	global_position = pos + Vector2(randf_range(-12.0, 12.0), -30.0)
	text = str(amount)
	add_theme_font_size_override("font_size", 20)
	modulate = SCHOOL_COLORS.get(school, Color(1.0, 1.0, 1.0))
	z_index = 10

func _physics_process(delta: float) -> void:
	global_position.y -= 60.0 * delta
	modulate.a -= 1.5 * delta
	if modulate.a <= 0.0:
		queue_free()
