extends "res://addons/gut/test.gd"

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")
const ENEMY_SCENE := preload("res://scenes/enemies/EnemyBase.tscn")


func before_each() -> void:
	GameState.reset_progress_for_tests()
	UiState.reset_to_defaults_for_tests()
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


func _get_progress_bar_fill_color(bar: ProgressBar) -> Color:
	var fill := bar.get_theme_stylebox("fill") as StyleBoxFlat
	if fill == null:
		return Color.BLACK
	return fill.bg_color


func _get_panel_border_color(panel: PanelContainer) -> Color:
	var style := panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style == null:
		return Color.BLACK
	return style.border_color


func _get_panel_border_width(panel: PanelContainer) -> int:
	var style := panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style == null:
		return 0
	return style.border_width_left


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
	assert_eq(
		ui._resource_cluster_info_label,
		null,
		"resource cluster should no longer build the old card header info line"
	)
	assert_not_null(ui._bottom_hud_row, "bottom HUD row should be built")
	assert_eq(
		int(ui._hp_bar.custom_minimum_size.y),
		8,
		"HP bar should use the slim no-card layout"
	)
	assert_eq(
		ui._hp_bar.get_parent(),
		ui._mp_bar.get_parent(),
		"HP and MP bars should live in the same stacked container"
	)
	assert_lt(
		ui._hp_bar.get_index(),
		ui._mp_bar.get_index(),
		"HP bar should appear above the MP bar"
	)
	assert_eq(
		ui._resource_cluster_container.get_parent(),
		ui._bottom_hud_row,
		"resource cluster should live in the shared bottom HUD row"
	)
	assert_not_null(ui._bottom_status_panel, "bottom-left status shell should be built")
	assert_not_null(ui._buff_chip_row, "active buff row should be built")
	assert_eq(
		ui.resonance_label.get_parent(),
		ui._bottom_status_column,
		"resonance summary should live in the bottom-left status shell"
	)
	assert_eq(
		int(ui._bottom_status_panel.custom_minimum_size.x),
		280,
		"bottom-left status shell should clamp to the narrower HUD width"
	)
	assert_eq(
		ui._bottom_hud_row.get_parent().get_child(ui._bottom_hud_row.get_parent().get_child_count() - 1),
		ui._bottom_hud_row,
		"bottom HUD row should stay at the very bottom of the HUD stack"
	)
	var hotbar_panel_style := ui._hotbar_container.get_theme_stylebox("panel") as StyleBoxTexture
	assert_not_null(hotbar_panel_style, "hotbar shell should use a texture-backed panel style")
	assert_true(hotbar_panel_style.texture is AtlasTexture, "hotbar shell should read from the action panel atlas")
	var first_slot_style := ui._hotbar_button_nodes[0].get_theme_stylebox("normal") as StyleBoxTexture
	assert_not_null(first_slot_style, "hotbar slot should use a texture-backed slot style")
	assert_true(first_slot_style.texture is AtlasTexture, "hotbar slot should read from the action panel atlas")


func test_game_ui_top_warning_hides_duplicate_resource_and_skill_lines_until_needed() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	ui.refresh("")
	assert_false(ui.hp_label.visible, "top warning row should stay hidden when there is no urgent warning")
	assert_false(ui.mastery_label.visible, "top mastery row should stay hidden after HUD simplification")

	GameState.last_damage_amount = 12
	GameState.last_damage_school = "fire"
	GameState.last_damage_display_timer = 4.0
	ui.refresh("")
	assert_true(ui.hp_label.visible, "top warning row should appear when recent damage exists")
	assert_string_contains(str(ui.hp_label.text), "최근 피해 12")

func test_game_ui_soul_dominion_warning_row_and_mp_bar_shift_between_active_and_aftershock() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.soul_dominion_active = true
	GameState.soul_dominion_aftershock_timer = 0.0
	ui.refresh("")
	assert_true(ui.hp_label.visible, "soul dominion active state should force the top warning row visible")
	assert_string_contains(str(ui.hp_label.text), "소울 도미니언 활성")
	var active_warning_color: Color = ui.hp_label.modulate
	var active_mp_fill: Color = _get_progress_bar_fill_color(ui._mp_bar)
	assert_gt(active_mp_fill.r, active_mp_fill.b, "active soul dominion MP bar should abandon the default blue read")

	GameState.soul_dominion_active = false
	GameState.soul_dominion_aftershock_timer = GameState.SOUL_DOMINION_AFTERSHOCK_DURATION
	ui.refresh("")
	assert_true(ui.hp_label.visible, "aftershock state should keep the top warning row visible")
	assert_string_contains(str(ui.hp_label.text), "소울 도미니언 여진")
	var aftershock_warning_color: Color = ui.hp_label.modulate
	var aftershock_mp_fill: Color = _get_progress_bar_fill_color(ui._mp_bar)
	assert_gt(
		aftershock_warning_color.g,
		active_warning_color.g,
		"aftershock warning color should read warmer and lighter than the fully active dominion warning"
	)
	assert_gt(
		aftershock_mp_fill.g,
		active_mp_fill.g,
		"aftershock MP bar should shift toward a warmer amber read instead of reusing the active dominion red"
	)

func test_game_ui_aftershock_warning_and_mp_bar_pulse_over_time() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.soul_dominion_active = false
	GameState.soul_dominion_aftershock_timer = GameState.SOUL_DOMINION_AFTERSHOCK_DURATION
	ui.refresh("")
	var first_warning_color: Color = ui.hp_label.modulate
	var first_mp_fill: Color = _get_progress_bar_fill_color(ui._mp_bar)
	GameState.soul_dominion_aftershock_timer = maxf(
		GameState.SOUL_DOMINION_AFTERSHOCK_DURATION - 0.4,
		0.0
	)
	ui.refresh("")
	var second_warning_color: Color = ui.hp_label.modulate
	var second_mp_fill: Color = _get_progress_bar_fill_color(ui._mp_bar)
	assert_ne(
		second_warning_color,
		first_warning_color,
		"aftershock warning row should pulse over time instead of staying at a fixed amber tint"
	)
	assert_ne(
		second_mp_fill,
		first_mp_fill,
		"aftershock MP bar should pulse over time instead of staying at a flat warning color"
	)

func test_game_ui_soul_risk_overlay_shifts_between_active_and_aftershock() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.soul_dominion_active = true
	GameState.soul_dominion_aftershock_timer = 0.0
	ui.refresh("")
	assert_true(ui._soul_risk_overlay.visible, "soul dominion active state should enable the edge risk overlay")
	var active_border_color: Color = _get_panel_border_color(ui._soul_risk_overlay)
	var active_border_width := _get_panel_border_width(ui._soul_risk_overlay)

	GameState.soul_dominion_active = false
	GameState.soul_dominion_aftershock_timer = GameState.SOUL_DOMINION_AFTERSHOCK_DURATION
	ui.refresh("")
	assert_true(ui._soul_risk_overlay.visible, "aftershock state should keep the edge risk overlay visible")
	var aftershock_border_color: Color = _get_panel_border_color(ui._soul_risk_overlay)
	var aftershock_border_width := _get_panel_border_width(ui._soul_risk_overlay)
	assert_gt(
		aftershock_border_color.g,
		active_border_color.g,
		"aftershock edge overlay should shift from deep red to a warmer amber border"
	)
	assert_lt(
		aftershock_border_width,
		active_border_width,
		"aftershock edge overlay should start slightly narrower than the fully active dominion border"
	)

func test_game_ui_aftershock_edge_overlay_pulses_over_time_then_fades_after_risk_clears() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.soul_dominion_active = false
	GameState.soul_dominion_aftershock_timer = GameState.SOUL_DOMINION_AFTERSHOCK_DURATION
	ui.refresh("")
	var first_border_color: Color = _get_panel_border_color(ui._soul_risk_overlay)
	var first_border_width := _get_panel_border_width(ui._soul_risk_overlay)
	GameState.soul_dominion_aftershock_timer = maxf(
		GameState.SOUL_DOMINION_AFTERSHOCK_DURATION - 0.4,
		0.0
	)
	ui.refresh("")
	var second_border_color: Color = _get_panel_border_color(ui._soul_risk_overlay)
	var second_border_width := _get_panel_border_width(ui._soul_risk_overlay)
	assert_true(
		second_border_color != first_border_color or second_border_width != first_border_width,
		"aftershock edge overlay should pulse over time instead of staying at a fixed border state"
	)
	GameState.soul_dominion_aftershock_timer = 0.0
	ui.refresh("")
	assert_true(ui._soul_risk_overlay.visible, "edge risk overlay should linger for a brief clear beat instead of snapping off immediately")
	var clear_border_color: Color = _get_panel_border_color(ui._soul_risk_overlay)
	assert_gt(clear_border_color.a, 0.0, "clear beat overlay should still render a visible border right after risk clears")
	await _settle_frames(60)
	ui.refresh("")
	assert_false(ui._soul_risk_overlay.visible, "edge risk overlay should hide after the brief clear beat finishes")


func test_game_ui_special_effects_toggle_hides_soul_risk_overlay() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.soul_dominion_active = true
	ui.refresh("")
	assert_true(ui._soul_risk_overlay.visible, "soul risk overlay should show while the special effects master toggle is enabled")
	UiState.set_special_effects_enabled(false, false)
	await _settle_frames(1)
	assert_false(ui._soul_risk_overlay.visible, "special effects toggle should hide the full-screen soul risk overlay immediately")


func test_game_ui_soul_risk_clear_beat_fades_mp_bar_back_to_safe_blue() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.soul_dominion_active = false
	GameState.soul_dominion_aftershock_timer = GameState.SOUL_DOMINION_AFTERSHOCK_DURATION
	ui.refresh("")
	GameState.soul_dominion_aftershock_timer = 0.0
	ui.refresh("")
	var clear_mp_fill: Color = _get_progress_bar_fill_color(ui._mp_bar)
	assert_ne(
		clear_mp_fill,
		Color(0.18, 0.45, 0.88),
		"MP bar should not snap directly to the default blue the instant aftershock clears"
	)
	assert_gt(clear_mp_fill.r, clear_mp_fill.b, "clear beat should still read as a warm residual warning")
	await _settle_frames(60)
	ui.refresh("")
	var safe_mp_fill: Color = _get_progress_bar_fill_color(ui._mp_bar)
	assert_eq(
		safe_mp_fill,
		Color(0.18, 0.45, 0.88),
		"MP bar should settle back to the default blue after the clear beat completes"
	)


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


func test_game_ui_hotbar_tooltip_flips_left_near_right_edge() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.set_hotbar_skill(9, "dark_void_bolt")
	ui.refresh("")
	ui._on_hud_hotbar_button_hovered(9)
	assert_true(ui._tooltip_panel.visible, "hovering the far-right slot should still show the tooltip")
	assert_eq(ui.debug_get_tooltip_horizontal_side(), "left")


func test_game_ui_tooltip_flips_below_when_anchor_is_near_top_edge() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	ui.debug_show_tooltip_for_anchor_rect(Rect2(120.0, 4.0, 56.0, 56.0), "top edge")
	assert_true(ui._tooltip_panel.visible, "debug tooltip anchor should make the tooltip visible")
	assert_eq(ui.debug_get_tooltip_vertical_side(), "below")


func test_game_ui_filled_hotbar_slot_shows_idle_overlay_and_hover_upgrades_it() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.set_hotbar_skill(0, "holy_mana_veil")
	ui.refresh("")
	assert_true(ui.debug_is_hotbar_overlay_visible(0), "filled slot should expose the subtle ready overlay")
	var idle_border: Color = ui.debug_get_hotbar_overlay_border_color(0)
	ui._on_hud_hotbar_button_hovered(0)
	var hovered_border: Color = ui.debug_get_hotbar_overlay_border_color(0)
	assert_ne(idle_border, hovered_border)


func test_game_ui_drag_source_slot_uses_distinct_overlay_from_hover() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	GameState.set_hotbar_skill(0, "holy_mana_veil")
	ui.refresh("")
	ui._on_hud_hotbar_button_hovered(0)
	var hovered_border: Color = ui.debug_get_hotbar_overlay_border_color(0)
	ui._on_hud_hotbar_button_gui_input(0, _mouse_button(MOUSE_BUTTON_LEFT, true))
	var drag_border: Color = ui.debug_get_hotbar_overlay_border_color(0)
	assert_ne(hovered_border, drag_border)


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


func test_game_ui_skill_window_payload_can_bind_directly_to_visible_hotbar_slot() -> void:
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	main.window_manager.open_window("skill")
	await _settle_frames(2)
	var skill_window = main.window_manager.get_window_node("skill")
	skill_window.debug_select_school("holy")
	skill_window.debug_select_skill("holy_mana_veil")
	var payload: Dictionary = skill_window.debug_get_selected_skill_drag_payload()
	assert_true(ui.debug_drop_skill_payload_on_hotbar_slot(payload, 0))
	assert_eq(str(GameState.get_hotbar_slot(0).get("skill_id", "")), "holy_mana_veil")
	assert_string_contains(str(ui._hotbar_button_nodes[0].text), "마나")
	assert_not_null(ui._hotbar_button_nodes[0].icon)


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


func test_game_ui_reads_hud_visibility_defaults_from_ui_state() -> void:
	UiState.set_show_primary_action_row(false, false)
	UiState.set_show_active_buff_row(false, false)
	var main: Node2D = await _spawn_main_scene()
	var ui = main.get_node("CanvasLayer/GameUI")
	assert_false(ui.is_primary_action_row_visible())
	assert_false(ui.is_active_buff_row_visible())


func test_game_ui_target_panel_tracks_nearest_alive_boss_only() -> void:
	var main: Node2D = await _spawn_main_scene()
	await _clear_enemy_layer(main)
	var far_boss: CharacterBody2D = await _spawn_enemy(
		main, "boss", main.player.global_position + Vector2(260, 0)
	)
	var near_enemy: CharacterBody2D = await _spawn_enemy(
		main, "dummy", main.player.global_position + Vector2(80, 0)
	)
	var ui = main.get_node("CanvasLayer/GameUI")
	ui.refresh("")
	assert_true(ui._target_panel_container.visible, "target panel should appear when a boss enemy is available")
	assert_string_contains(str(ui._target_name_label.text), str(far_boss.display_name))
	far_boss.health = int(far_boss.max_health / 2)
	ui.refresh("")
	assert_eq(
		str(ui._target_hp_value_label.text),
		"%d/%d" % [far_boss.health, far_boss.max_health],
		"target panel should mirror the tracked boss health snapshot"
	)
	assert_string_contains(str(ui._target_meta_label.text), "보스")
	assert_false(str(near_enemy.display_name).is_empty())


func test_game_ui_target_panel_hides_when_only_normal_enemies_remain() -> void:
	var main: Node2D = await _spawn_main_scene()
	await _clear_enemy_layer(main)
	var boss_enemy: CharacterBody2D = await _spawn_enemy(
		main, "boss", main.player.global_position + Vector2(220, 0)
	)
	var near_enemy: CharacterBody2D = await _spawn_enemy(
		main, "dummy", main.player.global_position + Vector2(60, 0)
	)
	var ui = main.get_node("CanvasLayer/GameUI")
	ui.refresh("")
	boss_enemy.health = 0
	ui.refresh("")
	assert_false(
		ui._target_panel_container.visible,
		"target panel should hide when no alive boss remains even if normal enemies are still alive"
	)
	assert_gt(near_enemy.health, 0, "normal enemy should still be alive for the hide check")
