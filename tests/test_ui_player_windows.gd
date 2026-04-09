extends "res://addons/gut/test.gd"

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")


func before_each() -> void:
	GameState.reset_progress_for_tests()
	UiState.reset_to_defaults_for_tests()
	GameState.current_room_id = "entrance"
	GameState.save_room_id = "entrance"
	GameState.save_spawn_position = Vector2(120, 480)


func _spawn_main_scene() -> Node2D:
	var main: Node2D = autofree(MAIN_SCENE.instantiate())
	add_child_autofree(main)
	await wait_process_frames(3)
	return main


func test_stat_window_reflects_core_runtime_stats() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("stat")
	await wait_process_frames(2)
	var stat_window = main.window_manager.get_window_node("stat")
	assert_string_contains(stat_window.get_primary_stats_text(), "최대 HP")
	assert_string_contains(stat_window.get_primary_stats_text(), "현재 서클")
	assert_string_contains(stat_window.get_resonance_text(), "공명")
	assert_string_contains(stat_window.get_resonance_text(), "화염")


func test_quest_window_builds_tabs_and_empty_state_shell() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("quest")
	await wait_process_frames(2)
	var quest_window = main.window_manager.get_window_node("quest")
	assert_eq(quest_window.get_tab_names(), ["진행 가능", "진행 중", "완료"])
	assert_string_contains(quest_window.get_empty_state_text("진행 중"), "future quest runtime hook")


func test_quest_window_tabs_use_custom_maple_like_skin() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("quest")
	await wait_process_frames(2)
	var quest_window = main.window_manager.get_window_node("quest")
	var accent := quest_window.get_node("Root/TitleAccent") as ColorRect
	assert_not_null(accent)
	assert_gt(accent.color.r, 0.8)
	var tabs := quest_window.get_node("Root/ContentRoot/QuestContent/QuestTabs") as TabContainer
	var selected_style := tabs.get_theme_stylebox("tab_selected") as StyleBoxFlat
	assert_not_null(selected_style)
	assert_gt(selected_style.bg_color.r, 0.8)


func test_skill_window_builds_school_categories_and_runtime_detail() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("skill")
	await wait_process_frames(2)
	var skill_window = main.window_manager.get_window_node("skill")
	assert_eq(skill_window.get_category_names().size(), 10)
	assert_ne(skill_window.get_selected_skill_id(), "")
	assert_string_contains(skill_window.get_detail_text(), "레벨")
	assert_string_contains(skill_window.get_bind_summary_text(), "현재 등록 키")


func test_skill_window_can_open_key_bindings_with_pending_skill() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("skill")
	await wait_process_frames(2)
	var skill_window = main.window_manager.get_window_node("skill")
	skill_window.debug_select_school("holy")
	skill_window.debug_select_skill("holy_mana_veil")
	skill_window.debug_request_bind_selected_skill()
	await wait_process_frames(2)
	assert_true(main.window_manager.is_window_open("key_bindings"))
	var key_bindings_window = main.window_manager.get_window_node("key_bindings")
	assert_string_contains(key_bindings_window.get_pending_skill_text(), "마나 베일")


func test_skill_window_drag_payload_can_bind_directly_into_key_bindings_slot() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("skill")
	main.window_manager.open_window("key_bindings")
	await wait_process_frames(2)
	var skill_window = main.window_manager.get_window_node("skill")
	var key_bindings_window = main.window_manager.get_window_node("key_bindings")
	skill_window.debug_select_school("holy")
	skill_window.debug_select_skill("holy_mana_veil")
	var payload: Dictionary = skill_window.debug_get_selected_skill_drag_payload()
	assert_eq(str(payload.get("type", "")), "skill_hotkey_bind")
	assert_eq(str(payload.get("skill_id", "")), "holy_mana_veil")
	assert_true(key_bindings_window.debug_drop_skill_payload_on_action(payload, "buff_pact"))
	assert_eq(str(GameState.get_action_hotkey_slot("buff_pact").get("skill_id", "")), "holy_mana_veil")
	assert_string_contains(str(key_bindings_window.get_slot_button("buff_pact").text), "마나 베일")
	assert_not_null(key_bindings_window.get_slot_button("buff_pact").icon)


func test_skill_window_buttons_expose_school_colored_pseudo_icons() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("skill")
	await wait_process_frames(2)
	var skill_window = main.window_manager.get_window_node("skill")
	skill_window.debug_select_school("holy")
	skill_window.debug_select_skill("holy_mana_veil")
	var skill_button: Button = skill_window._skill_buttons.get("holy_mana_veil", null)
	assert_not_null(skill_button)
	assert_not_null(skill_button.icon)


func test_key_bindings_window_can_assign_pending_skill_by_pressing_allowed_key() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("skill")
	main.window_manager.open_window("key_bindings")
	await wait_process_frames(2)
	var skill_window = main.window_manager.get_window_node("skill")
	var key_bindings_window = main.window_manager.get_window_node("key_bindings")
	skill_window.debug_select_school("holy")
	skill_window.debug_select_skill("holy_mana_veil")
	key_bindings_window.set_pending_skill_id("holy_mana_veil")
	assert_true(key_bindings_window.debug_handle_keycode(KEY_SHIFT))
	assert_eq(str(GameState.get_action_hotkey_slot("buff_pact").get("skill_id", "")), "holy_mana_veil")
	assert_eq(key_bindings_window.get_pending_skill_text(), "등록 대기 중인 스킬: 없음")


func test_key_bindings_window_allowed_key_press_without_pending_skill_selects_matching_slot() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("key_bindings")
	await wait_process_frames(2)
	var key_bindings_window = main.window_manager.get_window_node("key_bindings")
	assert_true(key_bindings_window.debug_handle_keycode(KEY_V))
	assert_eq(key_bindings_window.get_selected_action(), "buff_aegis")
	assert_true(key_bindings_window.get_slot_button("buff_aegis").button_pressed)


func test_key_bindings_window_hover_and_selected_slots_use_distinct_visual_borders() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("key_bindings")
	await wait_process_frames(2)
	var key_bindings_window = main.window_manager.get_window_node("key_bindings")
	key_bindings_window.debug_set_hovered_action("buff_aegis")
	var selected_border: Color = key_bindings_window.debug_get_slot_border_color("spell_fire", "pressed")
	var hovered_border: Color = key_bindings_window.debug_get_slot_border_color("buff_aegis", "hover")
	assert_ne(selected_border, hovered_border)


func test_skill_and_key_bindings_panels_use_textured_shells() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("skill")
	main.window_manager.open_window("key_bindings")
	await wait_process_frames(2)
	var skill_window = main.window_manager.get_window_node("skill")
	var category_panel := skill_window.get_node("Root/ContentRoot/SkillContent/CategoryPanel") as PanelContainer
	var category_style := category_panel.get_theme_stylebox("panel") as StyleBoxTexture
	assert_true(category_style is StyleBoxTexture)
	assert_true(category_style.texture is AtlasTexture)
	var list_panel := skill_window.get_node("Root/ContentRoot/SkillContent/SkillListPanel") as PanelContainer
	var list_style := list_panel.get_theme_stylebox("panel") as StyleBoxTexture
	assert_true(list_style is StyleBoxTexture)
	assert_true(list_style.texture is AtlasTexture)
	var detail_panel := skill_window.get_node("Root/ContentRoot/SkillContent/SkillDetailPanel") as PanelContainer
	var detail_style := detail_panel.get_theme_stylebox("panel") as StyleBoxTexture
	assert_true(detail_style is StyleBoxTexture)
	assert_true(detail_style.texture is AtlasTexture)
	var category_button := skill_window._category_buttons.get("fire", null) as Button
	assert_not_null(category_button)
	var category_button_style := category_button.get_theme_stylebox("normal") as StyleBoxTexture
	assert_not_null(category_button_style)
	assert_true(category_button_style.texture is AtlasTexture)
	var bind_button := skill_window.find_child("BindButton", true, false) as Button
	var bind_button_style := bind_button.get_theme_stylebox("normal") as StyleBoxTexture
	assert_not_null(bind_button_style)
	assert_true(bind_button_style.texture is AtlasTexture)
	var key_bindings_window = main.window_manager.get_window_node("key_bindings")
	var slot_panel := key_bindings_window.get_node("Root/ContentRoot/KeyBindingsContent/SlotPanel") as PanelContainer
	var slot_style := slot_panel.get_theme_stylebox("panel") as StyleBoxTexture
	assert_true(slot_style is StyleBoxTexture)
	assert_true(slot_style.texture is AtlasTexture)
	var assign_button := key_bindings_window.find_child("AssignButton", true, false) as Button
	var assign_button_style := assign_button.get_theme_stylebox("normal") as StyleBoxTexture
	assert_not_null(assign_button_style)
	assert_true(assign_button_style.texture is AtlasTexture)
