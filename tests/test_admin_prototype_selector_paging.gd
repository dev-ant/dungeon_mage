extends "res://addons/gut/test.gd"

const ADMIN_MENU_SCRIPT := preload("res://scripts/admin/admin_menu.gd")


func before_each() -> void:
	GameState.reset_progress_for_tests()


func _get_enabled_room_button_texts(menu: Control) -> Array[String]:
	var texts: Array[String] = []
	for button in menu._resource_room_button_nodes:
		if button.disabled:
			continue
		texts.append(button.text)
	return texts


func _get_selected_room_button_text(menu: Control) -> String:
	for button in menu._resource_room_button_nodes:
		if button.disabled:
			continue
		if not button.flat:
			return button.text
	return ""


func test_admin_resource_selector_uses_paged_room_window() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("resources")
	var catalog: Array[Dictionary] = GameState.get_prototype_room_catalog()
	assert_eq(catalog.size(), 49)
	assert_eq(menu._resource_room_button_nodes.size(), menu.PROTOTYPE_ROOM_PAGE_SIZE)
	assert_eq(menu._resource_room_button_nodes[0].text, str(catalog[0].get("short_label", "")))
	assert_eq(
		menu._resource_room_button_nodes[menu.PROTOTYPE_ROOM_PAGE_SIZE - 1].text,
		str(catalog[menu.PROTOTYPE_ROOM_PAGE_SIZE - 1].get("short_label", ""))
	)
	assert_eq(_get_selected_room_button_text(menu), str(catalog[0].get("short_label", "")))
	assert_true(menu._resource_prev_page_button.disabled)
	assert_false(menu._resource_next_page_button.disabled)
	assert_string_contains(menu._resource_room_page_label.text, "1/5")
	assert_string_contains(menu.body_label.text, "프로토타입 페이지: 1/5")


func test_admin_resource_selector_syncs_page_to_direct_room_selection() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("resources")
	menu.debug_select_prototype_room("inverted_spire")
	assert_string_contains(menu.body_label.text, "프로토타입 대상: inverted_spire")
	assert_string_contains(menu._resource_room_page_label.text, "5/5")
	assert_false(menu._resource_prev_page_button.disabled)
	assert_true(menu._resource_next_page_button.disabled)
	assert_true(_get_enabled_room_button_texts(menu).has("10층-01"))
	assert_eq(_get_selected_room_button_text(menu), "10층-01")


func test_admin_resource_selector_page_navigation_keeps_selection_jumpable() -> void:
	var menu = autofree(ADMIN_MENU_SCRIPT.new())
	add_child_autofree(menu)
	menu.pause_on_open = false
	await get_tree().process_frame
	menu.debug_click_tab("resources")
	var catalog: Array[Dictionary] = GameState.get_prototype_room_catalog()
	menu.debug_cycle_prototype_room_page(1)
	assert_string_contains(menu._resource_room_page_label.text, "2/5")
	assert_eq(menu._get_selected_prototype_room_id(), str(catalog[menu.PROTOTYPE_ROOM_PAGE_SIZE].get("room_id", "")))
	assert_eq(
		_get_selected_room_button_text(menu),
		str(catalog[menu.PROTOTYPE_ROOM_PAGE_SIZE].get("short_label", ""))
	)
