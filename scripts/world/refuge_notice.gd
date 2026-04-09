extends Area2D

var prompt_text := "E 키를 눌러 피난처 게시판을 읽으세요."
var default_text := ""
var stage_messages: Array[Dictionary] = []


func setup(config: Dictionary) -> void:
	position = config.get("position", Vector2.ZERO)
	default_text = str(config.get("text", ""))
	if config.has("prompt_text"):
		prompt_text = str(config.get("prompt_text", prompt_text))
	stage_messages = []
	for raw_stage in config.get("stage_messages", []):
		if typeof(raw_stage) != TYPE_DICTIONARY:
			continue
		stage_messages.append(raw_stage)
	_build()


func interact(_player: Node) -> void:
	var message := _resolve_message()
	if message != "":
		GameState.push_message(message, 3.0)


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


func _resolve_message() -> String:
	for stage in stage_messages:
		if _stage_matches(stage):
			return str(stage.get("text", default_text))
	return default_text


func _stage_matches(stage: Dictionary) -> bool:
	var has_requirement := false
	var required_flag := str(stage.get("required_flag", ""))
	if required_flag != "":
		has_requirement = true
		if not GameState.progression_flags.get(required_flag, false):
			return false
	var required_flags_all = stage.get("required_flags_all", [])
	if typeof(required_flags_all) == TYPE_ARRAY and not required_flags_all.is_empty():
		has_requirement = true
		for raw_flag in required_flags_all:
			var flag_id := str(raw_flag)
			if flag_id == "":
				continue
			if not GameState.progression_flags.get(flag_id, false):
				return false
	return has_requirement


func _build() -> void:
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(34, 48)
	add_child(shape)

	var post := Polygon2D.new()
	post.color = Color("#6e654f")
	post.polygon = PackedVector2Array(
		[
			Vector2(-4, -28),
			Vector2(4, -28),
			Vector2(4, 30),
			Vector2(-4, 30)
		]
	)
	add_child(post)

	var board := Polygon2D.new()
	board.color = Color("#d7c6a2")
	board.polygon = PackedVector2Array(
		[
			Vector2(-18, -26),
			Vector2(18, -26),
			Vector2(18, 4),
			Vector2(-18, 4)
		]
	)
	add_child(board)
