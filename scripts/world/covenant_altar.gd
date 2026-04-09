extends Area2D

var message := ""
var repeat_message := "제단은 더 이상 설득할 필요가 없다. 이 방 자체가 이미 계약을 품고 있다."
var progression_event_id := ""
var prompt_text := "E 키를 눌러 계약의 제단을 조사하세요."


func setup(config: Dictionary) -> void:
	position = config.get("position", Vector2.ZERO)
	message = str(config.get("text", ""))
	repeat_message = str(config.get("repeat_text", repeat_message))
	progression_event_id = str(config.get("progression_event_id", ""))
	if config.has("prompt_text"):
		prompt_text = str(config.get("prompt_text", prompt_text))
	_build()


func interact(_player: Node) -> void:
	GameState.save_progress(GameState.current_room_id, global_position + Vector2(0, -72))
	var granted := false
	if progression_event_id != "":
		granted = GameState.grant_progression_event(progression_event_id)
	if granted or progression_event_id == "":
		if message != "":
			GameState.push_message(message, 3.2)
	elif repeat_message != "":
		GameState.push_message(repeat_message, 2.2)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.register_interactable(self)
		GameState.push_message(prompt_text, 1.4)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		body.unregister_interactable(self)


func _build() -> void:
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(54, 34)
	add_child(shape)

	var dais := Polygon2D.new()
	dais.color = Color("#6f546e")
	dais.polygon = PackedVector2Array(
		[
			Vector2(-28, 18),
			Vector2(28, 18),
			Vector2(38, 34),
			Vector2(-38, 34)
		]
	)
	add_child(dais)

	var slab := Polygon2D.new()
	slab.color = Color("#c59ac4")
	slab.polygon = PackedVector2Array(
		[
			Vector2(-18, -10),
			Vector2(18, -10),
			Vector2(26, 18),
			Vector2(-26, 18)
		]
	)
	add_child(slab)

	var spike := Polygon2D.new()
	spike.color = Color("#f0c9de")
	spike.polygon = PackedVector2Array(
		[
			Vector2(-10, -10),
			Vector2(0, -34),
			Vector2(10, -10)
		]
	)
	add_child(spike)
