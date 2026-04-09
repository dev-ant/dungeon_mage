extends "res://addons/gut/test.gd"

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")


class EnemyDropStub:
	extends Node2D
	var enemy_type := "boss"


func before_each() -> void:
	GameState.reset_progress_for_tests()
	GameState.current_room_id = "entrance"
	GameState.save_room_id = "entrance"
	GameState.save_spawn_position = Vector2(120, 480)
	GameState.boss_defeated = false
	GameState.core_activated = false
	GameState.equipment_inventory.clear()


func _spawn_main_scene() -> Node2D:
	var main: Node2D = autofree(MAIN_SCENE.instantiate())
	add_child_autofree(main)
	await _settle_frames(3)
	return main


func _settle_frames(frame_count: int = 1) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


func _get_latest_damage_label(main: Node2D) -> Label:
	if main.damage_layer.get_child_count() == 0:
		return null
	return main.damage_layer.get_child(main.damage_layer.get_child_count() - 1) as Label


func _assert_string_contains_all(text: String, fragments: Array[String], context: String) -> void:
	for fragment in fragments:
		assert_string_contains(text, fragment, context)


func _find_first_catalog_room_for_floor(floor: int) -> String:
	for raw_entry in GameState.get_prototype_room_catalog():
		var entry: Dictionary = raw_entry
		if int(entry.get("floor", 0)) == floor:
			return str(entry.get("room_id", ""))
	return ""


func _find_last_catalog_room_for_floor(floor: int) -> String:
	var found_room_id := ""
	for raw_entry in GameState.get_prototype_room_catalog():
		var entry: Dictionary = raw_entry
		if int(entry.get("floor", 0)) != floor:
			continue
		found_room_id = str(entry.get("room_id", ""))
	return found_room_id


func test_main_ready_loads_room_and_room_spawns() -> void:
	var main: Node2D = await _spawn_main_scene()
	var expected_spawn_count: int = GameDatabase.get_room("entrance").get("spawns", []).size()
	assert_eq(
		str(main.current_room.get("id", "")),
		"entrance",
		"Main must load the current GameState room on ready"
	)
	assert_gt(main.room_layer.get_child_count(), 0, "Room layer must be populated after room load")
	assert_eq(
		main.enemy_layer.get_child_count(),
		expected_spawn_count,
		"Room load must spawn the configured entrance enemies"
	)


func test_admin_spawn_signal_adds_enemy_to_enemy_layer() -> void:
	var main: Node2D = await _spawn_main_scene()
	var before_count: int = main.enemy_layer.get_child_count()
	main.admin_menu.spawn_enemy_requested.emit("dummy")
	await _settle_frames(2)
	assert_eq(
		main.enemy_layer.get_child_count(),
		before_count + 1,
		"Admin spawn signal must add an enemy instance to Main"
	)


func test_player_death_restores_saved_room_and_spawn_position() -> void:
	var main: Node2D = await _spawn_main_scene()
	GameState.save_progress("vault_sector", Vector2(820, 360))
	GameState.health = 1
	GameState.damage(9999)
	await get_tree().create_timer(1.8).timeout
	await _settle_frames(2)
	assert_eq(
		str(main.current_room.get("id", "")),
		"vault_sector",
		"Death flow must reload the saved room"
	)
	assert_eq(
		GameState.current_room_id,
		"vault_sector",
		"restore_after_death must restore current_room_id through Main"
	)
	assert_eq(
		main.player.global_position.x, 820.0, "Death flow must restore the saved spawn X position"
	)
	assert_lt(
		absf(main.player.global_position.y - 360.0),
		48.0,
		"Death flow must respawn the player near the saved spawn Y position before gravity settles"
	)


func test_enemy_death_grants_drop_and_records_boss_progression() -> void:
	var main: Node2D = await _spawn_main_scene()
	var enemy: EnemyDropStub = autofree(EnemyDropStub.new())
	add_child_autofree(enemy)
	enemy.global_position = Vector2(640, 240)
	seed(1)
	main._on_enemy_died(enemy)
	assert_eq(
		GameState.session_drops,
		1,
		"Enemy death must record an awarded item drop when the drop roll succeeds"
	)
	assert_false(
		GameState.last_drop_display.is_empty(),
		"Enemy death must expose the last awarded drop to the UI/runtime"
	)
	assert_true(GameState.boss_defeated, "Boss death handling must update progression state")
	assert_eq(
		GameState.get_equipment_inventory().size(),
		1,
		"Drop grant must add the awarded equipment item to inventory"
	)


func test_combo_effect_signal_spawns_projectile_and_focuses_event_camera() -> void:
	var main: Node2D = await _spawn_main_scene()
	var before_count: int = main.projectile_layer.get_child_count()
	GameState.combo_effect_requested.emit(
		{
			"effect_id": "ash_detonation",
			"damage": 42,
			"school": "dark",
			"radius": 72.0,
			"color": "#ff8844"
		}
	)
	await _settle_frames(2)
	assert_eq(
		main.projectile_layer.get_child_count(),
		before_count + 1,
		"Combo effect requests must spawn their projectile burst in Main"
	)
	var burst: Node = main.projectile_layer.get_child(0)
	assert_gte(
		float(burst.get("duration")),
		0.3,
		"Combo effect bursts must stay alive long enough for runtime focus and integration assertions"
	)
	assert_eq(
		main.event_camera.priority,
		40,
		"Ash detonation combo effects must temporarily raise the event camera priority"
	)


func test_soul_dominion_aftershock_clear_triggers_world_release_overlay_pulse() -> void:
	var main: Node2D = await _spawn_main_scene()
	var overlay := main.get_node("CanvasLayer/SoulRiskReleaseOverlay") as ColorRect
	assert_not_null(overlay, "Main must build the Soul Dominion release overlay on the canvas layer")
	GameState.soul_dominion_active = false
	GameState.soul_dominion_aftershock_timer = GameState.SOUL_DOMINION_AFTERSHOCK_DURATION
	await _settle_frames(3)
	assert_false(overlay.visible, "World release overlay must stay hidden while aftershock is still active")
	GameState.soul_dominion_aftershock_timer = 0.0
	await _settle_frames(2)
	assert_true(overlay.visible, "World release overlay must pulse once the Soul Dominion aftershock fully clears")
	var first_alpha := overlay.color.a
	assert_gt(first_alpha, 0.0, "Release overlay should render a visible alpha right after the risk state resolves")
	await _settle_frames(10)
	assert_lt(overlay.color.a, first_alpha, "Release overlay should immediately start fading instead of holding a flat full-screen wash")
	await _settle_frames(40)
	assert_false(overlay.visible, "World release overlay must clear itself after the brief release beat finishes")


func test_special_effects_toggle_suppresses_world_release_overlay_pulse() -> void:
	var main: Node2D = await _spawn_main_scene()
	var overlay := main.get_node("CanvasLayer/SoulRiskReleaseOverlay") as ColorRect
	UiState.set_special_effects_enabled(false, false)
	GameState.soul_dominion_active = false
	GameState.soul_dominion_aftershock_timer = GameState.SOUL_DOMINION_AFTERSHOCK_DURATION
	await _settle_frames(3)
	GameState.soul_dominion_aftershock_timer = 0.0
	await _settle_frames(3)
	assert_false(overlay.visible, "special effects toggle should suppress the world release overlay pulse")


func test_soul_dominion_camera_feedback_separates_active_aftershock_and_clear_states() -> void:
	var main: Node2D = await _spawn_main_scene()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var manager = main.player.spell_manager
	assert_not_null(manager, "Main integration camera feedback test needs the live player spell manager")
	var default_zoom: Vector2 = main.camera.zoom
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	await _settle_frames(2)
	main._refresh_soul_risk_camera_feedback()
	var active_zoom: Vector2 = main.camera.zoom
	assert_lt(active_zoom.x, default_zoom.x, "Soul Dominion active should pull the player camera slightly inward")

	assert_true(manager.attempt_cast("dark_soul_dominion"))
	await _settle_frames(2)
	main._refresh_soul_risk_camera_feedback()
	var first_aftershock_zoom: Vector2 = main.camera.zoom
	assert_gt(
		first_aftershock_zoom.x,
		active_zoom.x,
		"Aftershock camera read should relax back toward the default zoom instead of staying as tight as the active risk state"
	)
	assert_lt(
		first_aftershock_zoom.x,
		default_zoom.x,
		"Aftershock camera read should still stay slightly inside the default zoom until the risk fully clears"
	)
	GameState.soul_dominion_aftershock_timer = maxf(
		GameState.SOUL_DOMINION_AFTERSHOCK_DURATION - 1.4,
		0.0
	)
	await _settle_frames(2)
	main._refresh_soul_risk_camera_feedback()
	var second_aftershock_zoom: Vector2 = main.camera.zoom
	assert_gt(
		second_aftershock_zoom.x,
		first_aftershock_zoom.x,
		"Aftershock camera read should ease back toward the default zoom over time instead of staying fixed"
	)

	GameState.soul_dominion_aftershock_timer = 0.0
	await _settle_frames(6)
	main._refresh_soul_risk_camera_feedback()
	var clear_zoom: Vector2 = main.camera.zoom
	assert_gt(
		clear_zoom.x,
		default_zoom.x,
		"Clear beat should briefly overshoot outward so the release reads differently from both active and aftershock states"
	)
	await _settle_frames(40)
	main._refresh_soul_risk_camera_feedback()
	assert_eq(
		main.camera.zoom,
		default_zoom,
		"Camera zoom should settle back to the baseline once the release beat finishes"
	)


func test_soul_dominion_risk_tints_world_damage_labels_differently_from_safe_state() -> void:
	var main: Node2D = await _spawn_main_scene()
	main._spawn_damage_label(42, Vector2(240, 240), "fire")
	await _settle_frames(1)
	var safe_label := _get_latest_damage_label(main)
	assert_not_null(safe_label, "Main should spawn a world damage label on the damage layer")
	var safe_color: Color = safe_label.modulate
	var safe_scale: Vector2 = safe_label.scale
	main._clear_layer(main.damage_layer)
	await _settle_frames(1)

	GameState.soul_dominion_active = true
	GameState.soul_dominion_aftershock_timer = 0.0
	main._spawn_damage_label(42, Vector2(240, 240), "fire")
	await _settle_frames(1)
	var active_label := _get_latest_damage_label(main)
	assert_not_null(active_label, "Active Soul Dominion should still allow world damage labels to spawn")
	var active_scale: Vector2 = active_label.scale
	var active_color: Color = active_label.modulate
	assert_gt(
		active_scale.x,
		safe_scale.x,
		"Active Soul Dominion should make world damage labels read slightly larger than the neutral baseline"
	)
	assert_gt(
		active_color.b,
		safe_color.b,
		"Active Soul Dominion should push damage labels toward a cooler violet highlight instead of leaving them at the base school tint"
	)
	main._clear_layer(main.damage_layer)
	await _settle_frames(1)

	GameState.soul_dominion_active = false
	GameState.soul_dominion_aftershock_timer = GameState.SOUL_DOMINION_AFTERSHOCK_DURATION
	main._spawn_damage_label(42, Vector2(240, 240), "fire")
	await _settle_frames(1)
	var aftershock_label := _get_latest_damage_label(main)
	assert_not_null(aftershock_label, "Aftershock should keep world damage labels visible with the softer risk tint")
	assert_gt(
		aftershock_label.scale.x,
		safe_scale.x,
		"Aftershock damage labels should remain slightly enlarged so the lingering risk still reads in the world"
	)
	assert_lt(
		aftershock_label.scale.x,
		active_scale.x,
		"Aftershock damage labels should relax below the fully active Soul Dominion emphasis"
	)
	assert_gt(
		aftershock_label.modulate.g,
		active_color.g,
		"Aftershock damage labels should shift warmer than the active violet highlight to match the softer risk phase"
	)


func test_entrance_shifts_into_next_expanded_prototype_room_even_with_enemies_alive() -> void:
	var main: Node2D = await _spawn_main_scene()
	var expected_room_id := str(GameState.get_prototype_room_order()[1])
	main._attempt_room_shift(1)
	await get_tree().create_timer(0.5).timeout
	await _settle_frames(2)
	assert_eq(
		str(main.current_room.get("id", "")),
		expected_room_id,
		"Entrance must advance into the next room even when enemies are still alive"
	)


func test_player_right_edge_shifts_into_next_room_using_current_room_width() -> void:
	var main: Node2D = await _spawn_main_scene()
	var expected_room_id := str(GameState.get_prototype_room_order()[1])
	var room_width := float(GameDatabase.get_room("entrance").get("width", 1600))
	main.player.global_position = Vector2(room_width - 55.0, 480)
	main.player._check_room_edges()
	await get_tree().create_timer(0.5).timeout
	await _settle_frames(2)
	assert_eq(
		str(main.current_room.get("id", "")),
		expected_room_id,
		"Walking to the right edge derived from the current room width must shift into the next room"
	)


func test_last_4f_room_advances_into_first_5f_room() -> void:
	var last_4f_room_id := _find_last_catalog_room_for_floor(4)
	var first_5f_room_id := _find_first_catalog_room_for_floor(5)
	GameState.current_room_id = last_4f_room_id
	GameState.save_room_id = last_4f_room_id
	GameState.save_spawn_position = Vector2(240, 520)
	var main: Node2D = await _spawn_main_scene()
	main._attempt_room_shift(1)
	await get_tree().create_timer(0.5).timeout
	await _settle_frames(2)
	assert_eq(
		str(main.current_room.get("id", "")),
		first_5f_room_id,
		"The expanded prototype flow must hand off from the last 4F room into the first 5F room"
	)


func test_first_6f_room_can_shift_back_to_last_5f_room() -> void:
	var first_6f_room_id := _find_first_catalog_room_for_floor(6)
	var last_5f_room_id := _find_last_catalog_room_for_floor(5)
	GameState.current_room_id = first_6f_room_id
	GameState.save_room_id = first_6f_room_id
	GameState.save_spawn_position = Vector2(240, 520)
	var main: Node2D = await _spawn_main_scene()
	main._attempt_room_shift(-1)
	await get_tree().create_timer(0.5).timeout
	await _settle_frames(2)
	assert_eq(
		str(main.current_room.get("id", "")),
		last_5f_room_id,
		"The first 6F refuge room must support shifting back into the last 5F transition room"
	)


func test_conduit_direct_load_keeps_legacy_transition_rule_without_core_activation() -> void:
	GameState.current_room_id = "conduit"
	GameState.save_room_id = "conduit"
	GameState.save_spawn_position = Vector2(120, 480)
	var main: Node2D = await _spawn_main_scene()
	main._attempt_room_shift(1)
	await get_tree().create_timer(0.5).timeout
	await _settle_frames(2)
	assert_eq(
		str(main.current_room.get("id", "")),
		"deep_gate",
		"Directly loaded legacy conduit room must keep its original forward transition without requiring core activation"
	)


func test_gate_threshold_advances_into_royal_inner_hall_in_prototype_flow() -> void:
	GameState.current_room_id = "gate_threshold"
	GameState.save_room_id = "gate_threshold"
	GameState.save_spawn_position = Vector2(180, 520)
	var main: Node2D = await _spawn_main_scene()
	main._attempt_room_shift(1)
	await get_tree().create_timer(0.5).timeout
	await _settle_frames(2)
	assert_eq(
		str(main.current_room.get("id", "")),
		"royal_inner_hall",
		"Gate threshold must advance into the 8F inner hall prototype room"
	)


func test_throne_approach_advances_into_inverted_spire_in_prototype_flow() -> void:
	GameState.current_room_id = "throne_approach"
	GameState.save_room_id = "throne_approach"
	GameState.save_spawn_position = Vector2(220, 520)
	var main: Node2D = await _spawn_main_scene()
	main._attempt_room_shift(1)
	await get_tree().create_timer(0.5).timeout
	await _settle_frames(2)
	assert_eq(
		str(main.current_room.get("id", "")),
		"inverted_spire",
		"Throne approach must advance into the final 10F prototype room"
	)


func test_player_left_edge_shifts_back_to_previous_room() -> void:
	var first_6f_room_id := _find_first_catalog_room_for_floor(6)
	var last_5f_room_id := _find_last_catalog_room_for_floor(5)
	GameState.current_room_id = first_6f_room_id
	GameState.save_room_id = first_6f_room_id
	GameState.save_spawn_position = Vector2(240, 520)
	var main: Node2D = await _spawn_main_scene()
	main.player.global_position = Vector2(5, 480)
	main.player._check_room_edges()
	await get_tree().create_timer(0.5).timeout
	await _settle_frames(2)
	assert_eq(
		str(main.current_room.get("id", "")),
		last_5f_room_id,
		"Walking to the left edge must shift the player into the previous room"
	)


func test_admin_room_jump_signal_loads_selected_prototype_room() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.admin_menu.room_jump_requested.emit("royal_inner_hall")
	await _settle_frames(2)
	assert_eq(
		str(main.current_room.get("id", "")),
		"royal_inner_hall",
		"Admin room jump signal must load the requested prototype room immediately"
	)


func test_inverted_spire_covenant_event_triggers_warning_focus_and_message() -> void:
	GameState.current_room_id = "inverted_spire"
	GameState.save_room_id = "inverted_spire"
	GameState.save_spawn_position = Vector2(240, 520)
	var main: Node2D = await _spawn_main_scene()
	assert_false(GameState.progression_flags.get("inverted_spire_covenant", false))
	_assert_string_contains_all(
		main._get_room_clear_blocked_message("inverted_spire"),
		["계약의 바닥은 여전히 팽팽하다", "제단은 아직 응답을 끝내지 않았다"],
		"Pre-covenant warning must match the current Korean runtime contract"
	)
	assert_true(GameState.grant_progression_event("inverted_spire_covenant"))
	await _settle_frames(1)
	_assert_string_contains_all(
		str(GameState.ui_message),
		["제단이 응답한다", "오래 기다린 시선이 당신을 향한다"],
		"Covenant grant message must match the current Korean runtime contract"
	)
	assert_eq(main.event_camera.priority, 40)
	_assert_string_contains_all(
		main._get_room_clear_blocked_message("inverted_spire"),
		["계약의 바닥은 방이 고요해질 때만 응답한다"],
		"Post-covenant warning must match the current Korean runtime contract"
	)


func test_inverted_spire_warning_line_reflects_threshold_and_companion_phase_knowledge() -> void:
	GameState.current_room_id = "inverted_spire"
	GameState.save_room_id = "inverted_spire"
	GameState.save_spawn_position = Vector2(240, 520)
	var main: Node2D = await _spawn_main_scene()
	GameState.progression_flags["gate_threshold_survivor_trace"] = true
	GameState.progression_flags["gate_threshold_bloodline_hint"] = true
	_assert_string_contains_all(
		main._get_room_clear_blocked_message("inverted_spire"),
		[
			"계약의 바닥은 여전히 팽팽하다",
			"관문에서 혈통을 골랐던 그 심판",
			"이 방을 닫아 두고 있다"
		],
		"Threshold-aware warning must use the current Korean runtime phrasing"
	)
	GameState.progression_flags["royal_inner_hall_companion_trace"] = true
	GameState.progression_flags["royal_inner_hall_archive"] = true
	GameState.progression_flags["throne_approach_companion_trace"] = true
	GameState.progression_flags["throne_approach_decree"] = true
	_assert_string_contains_all(
		main._get_room_clear_blocked_message("inverted_spire"),
		[
			"계약의 바닥은 여전히 팽팽하다",
			"관문과 내전, 그리고 옥좌 회랑",
			"이 방이 당신에게 무엇을 요구하는지 알고 있다"
		],
		"Companion-aware warning must use the current Korean runtime phrasing"
	)
	GameState.progression_flags["inverted_spire_covenant"] = true
	_assert_string_contains_all(
		main._get_room_clear_blocked_message("inverted_spire"),
		[
			"계약의 바닥은 방이 고요해질 때만 응답한다",
			"관문은 혈통을 골랐고",
			"복도는 이름을 지웠으며",
			"옥좌는 제단이 말하기 전부터 공포를 가르쳤다"
		],
		"Final warning must use the current Korean runtime phrasing"
	)
