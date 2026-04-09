extends Area2D

var echo_text := ""
var echo_id := ""
var repeat_text := "흔적은 희미해졌지만, 같은 불안감은 그대로 남아 있다."
var progression_event_override := ""
var stage_messages: Array[Dictionary] = []
var repeat_stage_messages: Array[Dictionary] = []


func setup(config: Dictionary, room_id: String, index: int) -> void:
	position = config.get("position", Vector2.ZERO)
	echo_text = str(config.get("text", ""))
	echo_id = "%s_echo_%d" % [room_id, index]
	repeat_text = str(config.get("repeat_text", repeat_text))
	progression_event_override = str(config.get("progression_event_id", ""))
	stage_messages = []
	for raw_stage in config.get("stage_messages", []):
		if typeof(raw_stage) != TYPE_DICTIONARY:
			continue
		stage_messages.append(raw_stage)
	repeat_stage_messages = []
	for raw_stage in config.get("repeat_stage_messages", []):
		if typeof(raw_stage) != TYPE_DICTIONARY:
			continue
		repeat_stage_messages.append(raw_stage)
	_build()


func interact(_player: Node) -> void:
	if GameState.has_seen_echo(echo_id):
		GameState.push_message(_resolve_repeat_text(), 2.0)
	else:
		GameState.mark_echo_seen(echo_id)
		var progression_event_id := _get_progression_event_id()
		if progression_event_id != "":
			GameState.grant_progression_event(progression_event_id)
		GameState.push_message(_resolve_echo_text(), 3.3)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.register_interactable(self)
		GameState.push_message("E 키를 눌러 남은 흔적을 조사하세요.", 1.2)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		body.unregister_interactable(self)


func _build() -> void:
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 18.0
	add_child(shape)
	var polygon := Polygon2D.new()
	polygon.color = Color("#ded6ff")
	polygon.polygon = PackedVector2Array(
		[Vector2(0, -22), Vector2(18, 0), Vector2(0, 22), Vector2(-18, 0)]
	)
	add_child(polygon)


func _get_progression_event_id() -> String:
	if progression_event_override != "":
		return progression_event_override
	match echo_id:
		"entrance_echo_1":
			return "echo_entrance_1"
		"entrance_echo_2":
			return "echo_entrance_2"
		"deep_gate_echo_0":
			return "echo_deep_0"
		"deep_gate_echo_1":
			return "echo_deep_1"
		_:
			return ""


func _resolve_echo_text() -> String:
	for stage in stage_messages:
		if _stage_matches(stage):
			return str(stage.get("text", echo_text))
	return echo_text


func _resolve_repeat_text() -> String:
	for stage in repeat_stage_messages:
		if _stage_matches(stage):
			return str(stage.get("text", repeat_text))
	return repeat_text


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
