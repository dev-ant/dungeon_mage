extends Area2D

var message := ""
var repeat_message := "오래된 권위의 압력만이 아직 남아 있다."
var progression_event_id := ""
var prompt_text := "E 키를 눌러 궁정의 흔적을 조사하세요."
var save_route := false


func setup(config: Dictionary) -> void:
	position = config.get("position", Vector2.ZERO)
	message = str(config.get("text", ""))
	repeat_message = str(config.get("repeat_text", repeat_message))
	progression_event_id = str(config.get("progression_event_id", ""))
	if config.has("prompt_text"):
		prompt_text = str(config.get("prompt_text", prompt_text))
	save_route = bool(config.get("save_progress", false))
	_build()


func interact(_player: Node) -> void:
	if save_route:
		GameState.save_progress(GameState.current_room_id, global_position + Vector2(0, -60))
	var granted := false
	if progression_event_id != "":
		granted = GameState.grant_progression_event(progression_event_id)
	if granted or progression_event_id == "":
		if message != "":
			GameState.push_message(message, 3.0)
	elif repeat_message != "":
		GameState.push_message(repeat_message, 2.0)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.register_interactable(self)
		GameState.push_message(prompt_text, 1.3)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		body.unregister_interactable(self)


func _build() -> void:
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(34, 42)
	add_child(shape)

	var base := Polygon2D.new()
	base.color = Color("#8f7d69")
	base.polygon = PackedVector2Array(
		[
			Vector2(-18, 20),
			Vector2(18, 20),
			Vector2(16, 32),
			Vector2(-16, 32)
		]
	)
	add_child(base)

	var pillar := Polygon2D.new()
	pillar.color = Color("#c9b394")
	pillar.polygon = PackedVector2Array(
		[
			Vector2(-10, -18),
			Vector2(10, -18),
			Vector2(12, 20),
			Vector2(-12, 20)
		]
	)
	add_child(pillar)

	var crown := Polygon2D.new()
	crown.color = Color("#eadfc7")
	crown.polygon = PackedVector2Array(
		[
			Vector2(-12, -18),
			Vector2(0, -34),
			Vector2(12, -18)
		]
	)
	add_child(crown)
