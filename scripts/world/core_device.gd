extends Area2D

signal activated


func setup(position_value: Vector2) -> void:
	position = position_value
	_build()


func interact(_player: Node) -> void:
	if not GameState.boss_defeated:
		GameState.push_message(
			"A pressure lock bars the core. Something in this chamber still guards it.", 2.2
		)
		return
	if GameState.core_activated:
		GameState.push_message("The core already turned. The maze remembers your signature.", 2.0)
		return
	GameState.core_activated = true
	GameState.grant_progression_event("core_conduit")
	GameState.save_to_disk()
	GameState.push_message("Upper channel restoration accepted... Deep alignment commencing.", 3.5)
	activated.emit()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.register_interactable(self)
		GameState.push_message("Press E to activate the floor core.", 1.2)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		body.unregister_interactable(self)


func _build() -> void:
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(24, 56)
	add_child(shape)
	var polygon := Polygon2D.new()
	polygon.color = Color("#f7db8b")
	polygon.polygon = PackedVector2Array(
		[Vector2(-20, -34), Vector2(20, -34), Vector2(16, 34), Vector2(-16, 34)]
	)
	add_child(polygon)
