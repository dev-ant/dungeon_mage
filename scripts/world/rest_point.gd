extends Area2D

var message := ""


func setup(config: Dictionary) -> void:
	position = config.get("position", Vector2.ZERO)
	message = str(config.get("text", ""))
	_build(Color("#8bffcf"), Vector2(20, 46))


func interact(_player: Node) -> void:
	GameState.save_progress(GameState.current_room_id, global_position + Vector2(0, -60))
	if GameState.current_room_id == "entrance":
		GameState.grant_progression_event("rest_entrance")
	if message != "":
		GameState.push_message(message, 2.8)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.register_interactable(self)
		GameState.push_message("E 키를 눌러 휴식하고 경로를 기록하세요.", 1.3)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		body.unregister_interactable(self)


func _build(color: Color, size: Vector2) -> void:
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = size
	add_child(shape)
	var polygon := Polygon2D.new()
	polygon.color = color
	polygon.polygon = PackedVector2Array(
		[Vector2(-14, -30), Vector2(14, -30), Vector2(18, 30), Vector2(-18, 30)]
	)
	add_child(polygon)
