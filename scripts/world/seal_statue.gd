extends Area2D

var message := ""
var progression_event_id := ""
var prompt_text := "E 키를 눌러 봉인 석상에서 경로를 고정하세요."


func setup(config: Dictionary) -> void:
	position = config.get("position", Vector2.ZERO)
	message = str(config.get("text", ""))
	progression_event_id = str(config.get("progression_event_id", ""))
	if config.has("prompt_text"):
		prompt_text = str(config.get("prompt_text", prompt_text))
	_build()


func interact(_player: Node) -> void:
	GameState.save_progress(GameState.current_room_id, global_position + Vector2(0, -72))
	GameState.heal_full()
	if progression_event_id != "":
		GameState.grant_progression_event(progression_event_id)
	if message != "":
		GameState.push_message(message, 3.2)


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
	shape.shape.size = Vector2(40, 68)
	add_child(shape)

	var base := Polygon2D.new()
	base.color = Color("#87b9aa")
	base.polygon = PackedVector2Array(
		[
			Vector2(-24, 30),
			Vector2(24, 30),
			Vector2(18, -12),
			Vector2(-18, -12)
		]
	)
	add_child(base)

	var pillar := Polygon2D.new()
	pillar.color = Color("#c8efe1")
	pillar.polygon = PackedVector2Array(
		[
			Vector2(-10, -12),
			Vector2(10, -12),
			Vector2(14, -44),
			Vector2(-14, -44)
		]
	)
	add_child(pillar)
