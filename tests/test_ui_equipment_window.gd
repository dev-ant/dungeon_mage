extends "res://addons/gut/test.gd"

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")


func before_each() -> void:
	GameState.reset_progress_for_tests()
	GameState.current_room_id = "entrance"
	GameState.save_room_id = "entrance"
	GameState.save_spawn_position = Vector2(120, 480)
	get_tree().paused = false


func _spawn_main_scene() -> Node2D:
	var main: Node2D = autofree(MAIN_SCENE.instantiate())
	add_child_autofree(main)
	await wait_process_frames(3)
	return main


func test_equipment_window_renders_slot_shell_for_all_equipment_slots() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("equipment")
	await wait_process_frames(2)
	var equipment_window = main.window_manager.get_window_node("equipment")
	assert_not_null(equipment_window.get_slot_button("weapon"))
	assert_not_null(equipment_window.get_slot_button("offhand"))
	assert_not_null(equipment_window.get_slot_button("head"))
	assert_not_null(equipment_window.get_slot_button("body"))
	assert_not_null(equipment_window.get_slot_button("legs"))
	assert_not_null(equipment_window.get_slot_button("accessory_1"))
	assert_not_null(equipment_window.get_slot_button("accessory_2"))


func test_equipment_window_can_equip_and_unequip_selected_item() -> void:
	GameState.grant_equipment_item("weapon_ember_staff")
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("equipment")
	await wait_process_frames(2)
	var equipment_window = main.window_manager.get_window_node("equipment")
	equipment_window.debug_select_slot("weapon")
	equipment_window.debug_select_owned_item("weapon_ember_staff")
	assert_true(equipment_window.debug_equip_selected_item())
	assert_eq(str(GameState.get_equipped_items().get("weapon", "")), "weapon_ember_staff")
	assert_true(equipment_window.debug_unequip_selected_slot())
	assert_eq(str(GameState.get_equipped_items().get("weapon", "")), "")


func test_equipment_window_double_click_shortcuts_match_maple_like_equip_flow() -> void:
	GameState.grant_equipment_item("weapon_ember_staff")
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("equipment")
	await wait_process_frames(2)
	var equipment_window = main.window_manager.get_window_node("equipment")
	assert_true(equipment_window.debug_double_click_owned_item("weapon_ember_staff"))
	assert_eq(str(GameState.get_equipped_items().get("weapon", "")), "weapon_ember_staff")
	assert_true(equipment_window.debug_double_click_slot("weapon"))
	assert_eq(str(GameState.get_equipped_items().get("weapon", "")), "")


func test_equipment_window_can_drag_owned_item_to_matching_slot() -> void:
	GameState.grant_equipment_item("weapon_ember_staff")
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("equipment")
	await wait_process_frames(2)
	var equipment_window = main.window_manager.get_window_node("equipment")
	assert_true(equipment_window.debug_drag_owned_item_to_slot("weapon_ember_staff", "weapon"))
	assert_eq(str(GameState.get_equipped_items().get("weapon", "")), "weapon_ember_staff")


func test_equipment_window_can_drag_equipped_slot_back_to_owned_panel() -> void:
	assert_true(GameState.set_equipped_item("weapon", "weapon_ember_staff"))
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("equipment")
	await wait_process_frames(2)
	var equipment_window = main.window_manager.get_window_node("equipment")
	assert_true(equipment_window.debug_drag_equipped_slot_to_owned("weapon"))
	assert_eq(str(GameState.get_equipped_items().get("weapon", "")), "")
	assert_eq(GameState.find_equipment_inventory_slot_by_item("weapon_ember_staff"), 0)


func test_equipment_window_hovered_slot_surfaces_equipped_item_context() -> void:
	assert_true(GameState.set_equipped_item("weapon", "weapon_ember_staff"))
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("equipment")
	await wait_process_frames(2)
	var equipment_window = main.window_manager.get_window_node("equipment")
	equipment_window.debug_hover_slot("weapon")
	assert_string_contains(equipment_window.get_summary_text(), "무기 (hover)")
	assert_string_contains(equipment_window.get_compare_text(), "슬롯 hover 중")
	assert_string_contains(equipment_window.get_slot_tooltip_text("weapon"), "현재 장착: 엠버 스태프")
	equipment_window.debug_clear_hover_slot("weapon")
	assert_string_contains(equipment_window.get_compare_text(), "후보 장비를 선택하면")


func test_equipment_window_hovered_owned_item_updates_compare_context_and_tooltip() -> void:
	assert_true(GameState.set_equipped_item("weapon", "weapon_ember_staff"))
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("equipment")
	await wait_process_frames(2)
	var equipment_window = main.window_manager.get_window_node("equipment")
	equipment_window.debug_hover_owned_item("weapon_tempest_rod")
	assert_string_contains(equipment_window.get_summary_text(), "무기 (hover 비교)")
	assert_string_contains(equipment_window.get_compare_text(), "후보: 템페스트 로드")
	assert_string_contains(equipment_window.get_owned_item_tooltip_text("weapon_tempest_rod"), "현재 장착 비교 대상: 엠버 스태프")
	equipment_window.debug_clear_hover_owned_item("weapon_tempest_rod")
	assert_false(equipment_window.get_summary_text().contains("(hover 비교)"))
	assert_string_contains(equipment_window.get_compare_text(), "후보: 템페스트 로드")


func test_equipment_window_uses_textured_panel_and_slot_shells() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("equipment")
	await wait_process_frames(2)
	var equipment_window = main.window_manager.get_window_node("equipment")
	var paper_panel := equipment_window.get_node("Root/ContentRoot/EquipmentContent/PaperDollPanel") as PanelContainer
	assert_true(paper_panel.get_theme_stylebox("panel") is StyleBoxTexture)
	var slot_button := equipment_window.get_slot_button("weapon") as Button
	assert_true(slot_button.get_theme_stylebox("normal") is StyleBoxTexture)
