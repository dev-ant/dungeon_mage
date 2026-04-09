extends "res://addons/gut/test.gd"

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")


func before_each() -> void:
	GameState.reset_progress_for_tests()
	UiState.reset_to_defaults_for_tests()
	GameState.current_room_id = "entrance"
	GameState.save_room_id = "entrance"
	GameState.save_spawn_position = Vector2(120, 480)
	get_tree().paused = false


func _spawn_main_scene() -> Node2D:
	var main: Node2D = autofree(MAIN_SCENE.instantiate())
	add_child_autofree(main)
	await _settle_frames(3)
	return main


func _settle_frames(frame_count: int = 1) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


func _switch_inventory_tab(window: Control, tab_index: int) -> void:
	var tabs := window.get_node("Root/ContentRoot/InventoryContent/InventoryTabs") as TabContainer
	tabs.current_tab = tab_index


func test_inventory_window_builds_three_maple_tabs_with_twenty_slots_each() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("inventory")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("inventory")
	for tab_name in ["장비", "소비", "기타"]:
		var grid := window.call("get_tab_slot_grid", tab_name) as GridContainer
		assert_not_null(grid, "%s 탭은 5x4 슬롯 그리드를 가져야 합니다." % tab_name)
		assert_eq(grid.get_child_count(), 20, "%s 탭은 기본 20칸을 유지해야 합니다." % tab_name)


func test_inventory_window_applies_custom_tab_and_action_button_skin() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("inventory")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("inventory")
	var accent := window.get_node("Root/TitleAccent") as ColorRect
	assert_not_null(accent)
	assert_gt(accent.color.b, 0.8)
	var tabs := window.get_node("Root/ContentRoot/InventoryContent/InventoryTabs") as TabContainer
	var selected_style := tabs.get_theme_stylebox("tab_selected") as StyleBoxFlat
	assert_not_null(selected_style)
	assert_gt(selected_style.bg_color.a, 0.0)
	var count_badge := window.get_node("Root/ContentRoot/InventoryContent/HeaderRow/CountBadge") as PanelContainer
	var badge_style := count_badge.get_theme_stylebox("panel") as StyleBoxFlat
	assert_not_null(badge_style)
	assert_gt(badge_style.border_color.b, 0.8)
	var organize_button := window.get_node("Root/ContentRoot/InventoryContent/ActionRow/OrganizeButton") as Button
	var organize_style := organize_button.get_theme_stylebox("hover") as StyleBoxFlat
	assert_not_null(organize_style)
	assert_gt(organize_style.border_color.g, 0.5)
	var grid_panel := window.get_node("Root/ContentRoot/InventoryContent/InventoryTabs/장비/장비Panel") as PanelContainer
	var grid_style := grid_panel.get_theme_stylebox("panel") as StyleBoxTexture
	assert_true(grid_style is StyleBoxTexture)
	assert_true(grid_style.texture is AtlasTexture)
	var first_slot := window.get_slot_button("장비", 0) as Button
	var slot_style := first_slot.get_theme_stylebox("normal") as StyleBoxTexture
	assert_true(slot_style is StyleBoxTexture)
	assert_true(slot_style.texture is AtlasTexture)


func test_inventory_window_equipment_tab_tracks_current_equipment_inventory_count() -> void:
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	assert_true(GameState.grant_equipment_item("focus_storm_orb"))
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("inventory")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("inventory")
	var count_label := window.get_node("Root/ContentRoot/InventoryContent/HeaderRow/CountBadge/CountMargin/CountLabel") as Label
	assert_eq(count_label.text, "2 / 20", "장비 탭 카운트는 현재 장비 인벤토리 아이템 수를 반영해야 합니다.")


func test_inventory_window_binds_equipment_items_into_top_left_cells() -> void:
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	assert_true(GameState.grant_equipment_item("focus_storm_orb"))
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("inventory")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("inventory")
	assert_eq(window.get_slot_item_id("장비", 0), "weapon_tempest_rod")
	assert_eq(window.get_slot_item_id("장비", 1), "focus_storm_orb")
	var first_button := window.get_slot_button("장비", 0) as Button
	assert_string_contains(first_button.text, "템페스트")


func test_inventory_window_can_swap_equipment_cells() -> void:
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	assert_true(GameState.grant_equipment_item("focus_storm_orb"))
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("inventory")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("inventory")
	assert_true(window.debug_swap_equipment_slots(0, 1))
	assert_eq(window.get_slot_item_id("장비", 0), "focus_storm_orb")
	assert_eq(window.get_slot_item_id("장비", 1), "weapon_tempest_rod")


func test_inventory_window_can_move_equipment_into_explicit_empty_slot() -> void:
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	assert_true(GameState.grant_equipment_item("focus_storm_orb"))
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("inventory")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("inventory")
	assert_true(window.debug_drag_equipment_slot(0, 5))
	assert_eq(window.get_slot_item_id("장비", 0), "")
	assert_eq(window.get_slot_item_id("장비", 1), "focus_storm_orb")
	assert_eq(window.get_slot_item_id("장비", 5), "weapon_tempest_rod")


func test_inventory_window_organize_sorts_equipment_by_slot_then_rarity() -> void:
	assert_true(GameState.grant_equipment_item("focus_storm_orb"))
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("inventory")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("inventory")
	assert_true(window.debug_organize_equipment_tab())
	assert_eq(window.get_slot_item_id("장비", 0), "weapon_tempest_rod")
	assert_eq(window.get_slot_item_id("장비", 1), "focus_storm_orb")


func test_inventory_window_can_equip_selected_item_from_equipment_tab() -> void:
	assert_true(GameState.grant_equipment_item("weapon_ember_staff"))
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("inventory")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("inventory")
	window.debug_select_slot("장비", 0)
	assert_true(window.debug_equip_selected_item())
	assert_eq(str(GameState.get_equipped_items().get("weapon", "")), "weapon_ember_staff")
	assert_eq(window.get_slot_item_id("장비", 0), "")


func test_inventory_window_consumable_tab_binds_runtime_stack_items() -> void:
	assert_true(GameState.grant_consumable_item("consumable_minor_hp_potion", 3))
	assert_true(GameState.grant_consumable_item("consumable_minor_mp_potion", 2))
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("inventory")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("inventory")
	_switch_inventory_tab(window, 1)
	await _settle_frames(1)
	var count_label := window.get_node("Root/ContentRoot/InventoryContent/HeaderRow/CountBadge/CountMargin/CountLabel") as Label
	assert_eq(count_label.text, "2 / 20")
	assert_eq(window.get_slot_item_id("소비", 0), "consumable_minor_hp_potion")
	assert_eq(window.get_slot_stack_count("소비", 0), 3)
	assert_eq(window.get_slot_item_id("소비", 1), "consumable_minor_mp_potion")
	assert_eq(window.get_slot_stack_count("소비", 1), 2)
	window.debug_select_slot("소비", 0)
	assert_string_contains(window.get_detail_text(), "수량: x3")
	assert_string_contains(window.get_detail_text(), "HP를 35 회복")


func test_inventory_window_consumable_tab_can_use_selected_stack_item() -> void:
	assert_true(GameState.grant_consumable_item("consumable_minor_hp_potion", 2))
	GameState.health = 40
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("inventory")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("inventory")
	_switch_inventory_tab(window, 1)
	await _settle_frames(1)
	window.debug_select_slot("소비", 0)
	assert_true(window.debug_activate_selected_item())
	assert_gt(GameState.health, 40)
	assert_eq(window.get_slot_stack_count("소비", 0), 1)


func test_inventory_window_consumable_drag_can_merge_same_item_stack() -> void:
	assert_true(GameState.grant_consumable_item("consumable_focus_elixir", 12))
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("inventory")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("inventory")
	_switch_inventory_tab(window, 1)
	await _settle_frames(1)
	assert_eq(window.get_slot_stack_count("소비", 0), 10)
	assert_eq(window.get_slot_stack_count("소비", 1), 2)
	assert_true(window.debug_drag_tab_slot("소비", 0, 1))
	assert_eq(window.get_slot_stack_count("소비", 0), 2)
	assert_eq(window.get_slot_stack_count("소비", 1), 10)


func test_inventory_window_other_tab_binds_and_organizes_runtime_items() -> void:
	assert_true(GameState.grant_other_item("etc_broken_core_fragment", 4))
	assert_true(GameState.grant_other_item("etc_sealed_archive_page", 2))
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("inventory")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("inventory")
	_switch_inventory_tab(window, 2)
	await _settle_frames(1)
	assert_eq(window.get_slot_item_id("기타", 0), "etc_broken_core_fragment")
	assert_eq(window.get_slot_item_id("기타", 1), "etc_sealed_archive_page")
	assert_true(window.call("_organize_current_tab"))
	assert_eq(window.get_slot_item_id("기타", 0), "etc_sealed_archive_page")
	assert_eq(window.get_slot_item_id("기타", 1), "etc_broken_core_fragment")
	window.debug_select_slot("기타", 0)
	assert_string_contains(window.get_detail_text(), "봉인된 기록 조각")
