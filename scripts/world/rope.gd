extends Area2D

const ROPE_WIDTH := 6.0

var rope_top_y: float = 0.0
var rope_bottom_y: float = 0.0

func setup(config: Dictionary) -> void:
	position = config.get("position", Vector2.ZERO)
	var height: float = float(config.get("height", 200.0))
	rope_top_y = position.y - height * 0.5
	rope_bottom_y = position.y + height * 0.5

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(ROPE_WIDTH * 2.0, height)
	shape.shape = rect
	add_child(shape)

	var poly := Polygon2D.new()
	poly.color = Color("#8b6d3f")
	poly.polygon = PackedVector2Array([
		Vector2(-ROPE_WIDTH * 0.5, -height * 0.5),
		Vector2(ROPE_WIDTH * 0.5, -height * 0.5),
		Vector2(ROPE_WIDTH * 0.5, height * 0.5),
		Vector2(-ROPE_WIDTH * 0.5, height * 0.5)
	])
	add_child(poly)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("rope")

func _on_body_entered(body: Node) -> void:
	if body.has_method("register_rope"):
		body.register_rope(self)

func _on_body_exited(body: Node) -> void:
	if body.has_method("unregister_rope"):
		body.unregister_rope(self)
