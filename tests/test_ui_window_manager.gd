extends "res://addons/gut/test.gd"

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")


func before_each() -> void:
	GameState.reset_progress_for_tests()
	GameState.current_room_id = "entrance"
	GameState.save_room_id = "entrance"
	GameState.save_spawn_position = Vector2(120, 480)
	get_tree().paused = false


func after_each() -> void:
	get_tree().paused = false


func _spawn_main_scene() -> Node2D:
	var main: Node2D = autofree(MAIN_SCENE.instantiate())
	add_child_autofree(main)
	await _settle_frames(3)
	return main


func _settle_frames(frame_count: int = 1) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


func _press_action(action: String) -> void:
	var pressed := InputEventAction.new()
	pressed.action = action
	pressed.pressed = true
	Input.parse_input_event(pressed)
	var released := InputEventAction.new()
	released.action = action
	released.pressed = false
	Input.parse_input_event(released)


func test_window_manager_builds_window_layers_under_canvas_layer() -> void:
	var main: Node2D = await _spawn_main_scene()
	assert_not_null(main.get_node("CanvasLayer/WindowLayer"))
	assert_not_null(main.get_node("CanvasLayer/ModalLayer"))
	assert_not_null(main.get_node("CanvasLayer/TooltipLayer"))
	assert_not_null(main.window_manager, "main scene should expose the new window manager")


func test_inventory_action_toggles_inventory_window_shell() -> void:
	var main: Node2D = await _spawn_main_scene()
	_press_action("ui_inventory")
	await _settle_frames(2)
	assert_true(main.window_manager.is_window_open("inventory"))
	_press_action("ui_inventory")
	await _settle_frames(2)
	assert_false(main.window_manager.is_window_open("inventory"))


func test_skill_then_inventory_esc_closes_topmost_first() -> void:
	var main: Node2D = await _spawn_main_scene()
	_press_action("ui_skill")
	await _settle_frames(2)
	_press_action("ui_inventory")
	await _settle_frames(2)
	assert_eq(main.window_manager.get_topmost_window_id(), "inventory")
	_press_action("ui_settings")
	await _settle_frames(2)
	assert_false(main.window_manager.is_window_open("inventory"))
	assert_true(main.window_manager.is_window_open("skill"))
	assert_eq(main.window_manager.get_topmost_window_id(), "skill")


func test_esc_opens_settings_and_pauses_until_closed() -> void:
	var main: Node2D = await _spawn_main_scene()
	_press_action("ui_settings")
	await _settle_frames(2)
	assert_true(main.window_manager.is_window_open("settings"))
	assert_true(get_tree().paused, "settings window should pause the game tree")
	_press_action("ui_settings")
	await _settle_frames(2)
	assert_false(main.window_manager.is_window_open("settings"))
	assert_false(get_tree().paused, "closing settings via ESC should resume the tree")


func test_admin_menu_action_moves_to_f8_and_escape_is_reserved_for_settings() -> void:
	GameState.ensure_input_map()
	assert_eq((InputMap.action_get_events("move_left")[0] as InputEventKey).physical_keycode, KEY_LEFT)
	assert_eq((InputMap.action_get_events("move_right")[0] as InputEventKey).physical_keycode, KEY_RIGHT)
	assert_eq((InputMap.action_get_events("jump")[0] as InputEventKey).physical_keycode, KEY_SPACE)
	assert_eq((InputMap.action_get_events("dash")[0] as InputEventKey).physical_keycode, KEY_TAB)
	assert_eq((InputMap.action_get_events("admin_menu")[0] as InputEventKey).physical_keycode, KEY_F8)
	assert_eq((InputMap.action_get_events("ui_settings")[0] as InputEventKey).physical_keycode, KEY_ESCAPE)
	assert_eq((InputMap.action_get_events("ui_equipment")[0] as InputEventKey).physical_keycode, KEY_E)
	assert_eq((InputMap.action_get_events("ui_stats")[0] as InputEventKey).physical_keycode, KEY_T)
	assert_eq((InputMap.action_get_events("ui_quest")[0] as InputEventKey).physical_keycode, KEY_Q)
	assert_eq((InputMap.action_get_events("buff_guard")[0] as InputEventKey).physical_keycode, KEY_Z)
	assert_eq((InputMap.action_get_events("buff_aegis")[0] as InputEventKey).physical_keycode, KEY_V)
	assert_eq((InputMap.action_get_events("buff_tempo")[0] as InputEventKey).physical_keycode, KEY_A)
	assert_eq((InputMap.action_get_events("buff_surge")[0] as InputEventKey).physical_keycode, KEY_S)
	assert_eq((InputMap.action_get_events("buff_compression")[0] as InputEventKey).physical_keycode, KEY_D)
	assert_eq((InputMap.action_get_events("buff_hourglass")[0] as InputEventKey).physical_keycode, KEY_F)
	assert_eq((InputMap.action_get_events("buff_pact")[0] as InputEventKey).physical_keycode, KEY_SHIFT)
	assert_eq((InputMap.action_get_events("buff_throne")[0] as InputEventKey).physical_keycode, KEY_CTRL)
	assert_eq((InputMap.action_get_events("buff_overflow")[0] as InputEventKey).physical_keycode, KEY_ALT)


func test_equipment_stat_and_quest_actions_toggle_their_windows() -> void:
	var main: Node2D = await _spawn_main_scene()
	_press_action("ui_equipment")
	await _settle_frames(2)
	assert_true(main.window_manager.is_window_open("equipment"))
	_press_action("ui_stats")
	await _settle_frames(2)
	assert_true(main.window_manager.is_window_open("stat"))
	_press_action("ui_quest")
	await _settle_frames(2)
	assert_true(main.window_manager.is_window_open("quest"))
	assert_eq(main.window_manager.get_topmost_window_id(), "quest")
