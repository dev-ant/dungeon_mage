extends Area2D

var echo_text := ""
var echo_id := ""

func setup(config: Dictionary, room_id: String, index: int) -> void:
	position = config.get("position", Vector2.ZERO)
	echo_text = str(config.get("text", ""))
	echo_id = "%s_echo_%d" % [room_id, index]
	_build()

func interact(_player: Node) -> void:
	if GameState.has_seen_echo(echo_id):
		GameState.push_message("The trace is faint now, but the same unease remains.", 2.0)
	else:
		GameState.mark_echo_seen(echo_id)
		var progression_event_id := _get_progression_event_id()
		if progression_event_id != "":
			GameState.grant_progression_event(progression_event_id)
		GameState.push_message(echo_text, 3.3)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.register_interactable(self)
		GameState.push_message("Press E to examine the lingering trace.", 1.2)

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
	polygon.polygon = PackedVector2Array([
		Vector2(0, -22),
		Vector2(18, 0),
		Vector2(0, 22),
		Vector2(-18, 0)
	])
	add_child(polygon)

func _get_progression_event_id() -> String:
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
