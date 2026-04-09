extends Area2D

signal activated


func setup(position_value: Vector2) -> void:
	position = position_value
	_build()


func interact(_player: Node) -> void:
	if not GameState.boss_defeated:
		GameState.push_message(
			"압력 봉인이 코어를 막고 있다. 이 방 어딘가에 아직 수호자가 남아 있다.", 2.2
		)
		return
	if GameState.core_activated:
		GameState.push_message("코어는 이미 회전했다. 미궁이 당신의 흔적을 기억하고 있다.", 2.0)
		return
	GameState.core_activated = true
	GameState.grant_progression_event("core_conduit")
	GameState.save_to_disk()
	GameState.push_message("상부 채널 복구 승인... 심층 정렬을 시작합니다.", 3.5)
	activated.emit()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.register_interactable(self)
		GameState.push_message("E 키를 눌러 바닥 코어를 활성화하세요.", 1.2)


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
