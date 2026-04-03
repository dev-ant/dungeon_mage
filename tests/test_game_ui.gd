extends "res://addons/gut/test.gd"

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const ENEMY_SCENE := preload("res://scenes/enemies/EnemyBase.tscn")


func before_each() -> void:
	GameState.reset_progress_for_tests()
	GameState.current_room_id = "entrance"
	GameState.save_room_id = "entrance"
	GameState.save_spawn_position = Vector2(120, 480)


func _spawn_main_scene() -> Node2D:
	var main: Node2D = autofree(MAIN_SCENE.instantiate())
	add_child_autofree(main)
	await _settle_frames(3)
	return main


func _settle_frames(frame_count: int = 1) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


func _mouse_button(button_index: int, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button_index
	event.pressed = pressed
	return event


func _clear_enemy_layer(main: Node2D) -> void:
	main._clear_layer(main.enemy_layer)
	await _settle_frames(2)


func _spawn_enemy(main: Node2D, enemy_type: String, world_position: Vector2) -> CharacterBody2D:
	var enemy: CharacterBody2D = ENEMY_SCENE.instantiate()
	enemy.configure({"type": enemy_type, "position": world_position}, main.player)
	main.enemy_layer.add_child(enemy)
	await _settle_frames(2)
	return enemy


func test_game_ui_hotbar_shell_uses_visible_ten_slot_row() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	assert_eq(
		ui._hotbar_button_nodes.size(),
		GameState.VISIBLE_HOTBAR_SLOT_COUNT,
		"Game UI should render only the visible ten-slot combat row"
	)
	assert_not_null(ui._resource_cluster_container, "resource cluster shell should be built")
	assert_not_null(ui._buff_chip_row, "active buff row should be built")


func test_game_ui_hover_builds_rich_tooltip_from_player_payload() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.set_hotbar_skill(0, "holy_mana_veil")
	ui.refresh("")
	ui._on_hud_hotbar_button_hovered(0)
	assert_true(ui._tooltip_panel.visible, "hovering a visible slot should show the tooltip panel")
	assert_string_contains(str(ui._tooltip_label.text), "마나 베일")
	assert_string_contains(str(ui._tooltip_label.text), "쿨타임")
	assert_string_contains(str(ui._tooltip_label.text), "마스터리")


func test_game_ui_right_click_clears_visible_slot() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.set_hotbar_skill(0, "holy_mana_veil")
	ui._on_hud_hotbar_button_gui_input(0, _mouse_button(MOUSE_BUTTON_RIGHT, false))
	assert_eq(str(GameState.get_hotbar_slot(0).get("skill_id", "")), "")


func test_game_ui_left_drag_swaps_visible_slots() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.set_hotbar_skill(0, "holy_mana_veil")
	GameState.set_hotbar_skill(1, "fire_bolt")
	ui._on_hud_hotbar_button_gui_input(0, _mouse_button(MOUSE_BUTTON_LEFT, true))
	ui._on_hud_hotbar_button_gui_input(1, _mouse_button(MOUSE_BUTTON_LEFT, false))
	assert_eq(str(GameState.get_hotbar_slot(0).get("skill_id", "")), "fire_bolt")
	assert_eq(str(GameState.get_hotbar_slot(1).get("skill_id", "")), "holy_mana_veil")


func test_game_ui_dims_unavailable_visible_slot() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.set_hotbar_skill(0, "fire_bolt")
	GameState.mana = 0.0
	ui.refresh("")
	var btn: Button = ui._hotbar_button_nodes[0]
	assert_lt(btn.modulate.r, 0.9, "unavailable visible slot should be dimmed instead of looking ready")


func test_game_ui_hide_primary_action_row_removes_mouse_hotbar_path() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.set_hotbar_skill(0, "holy_mana_veil")
	ui.set_show_primary_action_row(false)
	ui._on_hud_hotbar_button_hovered(0)
	ui._on_hud_hotbar_button_gui_input(0, _mouse_button(MOUSE_BUTTON_RIGHT, false))
	assert_false(ui._hotbar_container.visible, "primary action row should disappear when hidden")
	assert_false(ui._tooltip_panel.visible, "hidden primary action row should not expose hover tooltip")
	assert_eq(
		str(GameState.get_hotbar_slot(0).get("skill_id", "")),
		"holy_mana_veil",
		"hidden primary action row should no longer respond to mouse clear interactions"
	)


func test_game_ui_hide_active_buff_row_hides_buff_shell_without_breaking_refresh() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.active_buffs.append({"skill_id": "holy_mana_veil", "display_name": "마나 베일", "remaining": 5.0})
	ui.refresh("")
	assert_true(ui._buff_chip_panel.visible, "buff row should start visible")
	ui.set_show_active_buff_row(false)
	ui.refresh("")
	assert_false(ui._buff_chip_panel.visible, "active buff row should disappear when hidden")


func test_game_ui_target_panel_tracks_nearest_alive_enemy() -> void:
	var main: Node2D = await _spawn_main_scene()
	await _clear_enemy_layer(main)
	var far_enemy: CharacterBody2D = await _spawn_enemy(
		main, "rat", main.player.global_position + Vector2(260, 0)
	)
	var near_enemy: CharacterBody2D = await _spawn_enemy(
		main, "dummy", main.player.global_position + Vector2(80, 0)
	)
	var ui = main.get_node("CanvasLayer/GameUI")
	ui.refresh("")
	assert_true(ui._target_panel_container.visible, "target panel should appear when an enemy is available")
	assert_string_contains(str(ui._target_name_label.text), str(near_enemy.display_name))
	near_enemy.health = int(near_enemy.max_health / 2)
	ui.refresh("")
	assert_eq(
		str(ui._target_hp_value_label.text),
		"%d/%d" % [near_enemy.health, near_enemy.max_health],
		"target panel should mirror the nearest enemy health snapshot"
	)
	assert_string_contains(str(ui._target_meta_label.text), "Dummy")
	assert_false(str(far_enemy.display_name).is_empty())


func test_game_ui_target_panel_falls_back_and_hides_without_alive_enemies() -> void:
	var main: Node2D = await _spawn_main_scene()
	await _clear_enemy_layer(main)
	var far_enemy: CharacterBody2D = await _spawn_enemy(
		main, "rat", main.player.global_position + Vector2(220, 0)
	)
	var near_enemy: CharacterBody2D = await _spawn_enemy(
		main, "dummy", main.player.global_position + Vector2(60, 0)
	)
	var ui = main.get_node("CanvasLayer/GameUI")
	ui.refresh("")
	near_enemy.health = 0
	ui.refresh("")
	assert_string_contains(
		str(ui._target_name_label.text),
		str(far_enemy.display_name),
		"when the nearest enemy is no longer alive, the panel should fall back to the next living enemy"
	)
	far_enemy.health = 0
	ui.refresh("")
	assert_false(ui._target_panel_container.visible, "target panel should hide when there are no alive enemies")
