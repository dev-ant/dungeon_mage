extends "res://addons/gut/test.gd"

const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")
const ROPE_SCRIPT := preload("res://scripts/world/rope.gd")
const REST_POINT_SCRIPT := preload("res://scripts/world/rest_point.gd")
const SEAL_STATUE_SCRIPT := preload("res://scripts/world/seal_statue.gd")
const MEMORY_PLINTH_SCRIPT := preload("res://scripts/world/memory_plinth.gd")
const COVENANT_ALTAR_SCRIPT := preload("res://scripts/world/covenant_altar.gd")
const REFUGE_NOTICE_SCRIPT := preload("res://scripts/world/refuge_notice.gd")
const DEFAULT_ECHO_REPEAT_TEXT := "흔적은 희미해졌지만, 같은 불안감은 그대로 남아 있다."


class DummyInteractable:
	extends Node

	var interact_calls := 0
	var last_player: Node = null

	func interact(player: Node) -> void:
		interact_calls += 1
		last_player = player


func _make_floor_body(collision_kind: String) -> StaticBody2D:
	var body: StaticBody2D = autofree(StaticBody2D.new())
	body.set_meta("collision_kind", collision_kind)
	return body


func before_each() -> void:
	GameState.health = GameState.max_health
	GameState.reset_progress_for_tests()
	GameState.ensure_input_map()


func test_double_jump_allows_two_jumps_before_landing() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	assert_true(player.debug_try_jump(true))
	assert_eq(player.get_jump_count(), 1)
	assert_true(player.debug_try_jump(false))
	assert_eq(player.get_jump_count(), 2)
	assert_false(player.debug_try_jump(false))
	player._on_landed()
	assert_eq(player.get_jump_count(), 0)


func test_aerial_support_effects_raise_jump_limit_and_launch_height() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	GameState.refresh_field_support_effects(
		"wind_sky_dominion_test",
		[
			{"stat": "air_jump_bonus", "mode": "add", "value": 1},
			{"stat": "jump_velocity_multiplier", "mode": "mul", "value": 1.2}
		],
		1.2
	)
	assert_eq(player.get_max_jump_count(), 3)
	assert_true(player.debug_try_jump(true))
	var boosted_jump_velocity: float = player.debug_get_velocity().y
	assert_lt(boosted_jump_velocity, -700.0, "aerial support must launch the player harder than the default jump")
	assert_true(player.debug_try_jump(false))
	assert_true(player.debug_try_jump(false))
	assert_false(player.debug_try_jump(false))


func test_aerial_support_effects_reduce_applied_gravity() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_apply_air_gravity(0.2)
	var base_gravity_step: float = player.debug_get_velocity().y
	player.velocity = Vector2.ZERO
	GameState.refresh_field_support_effects(
		"wind_sky_dominion_test",
		[
			{"stat": "gravity_multiplier", "mode": "mul", "value": 0.7}
		],
		1.2
	)
	player.debug_apply_air_gravity(0.2)
	var reduced_gravity_step: float = player.debug_get_velocity().y
	assert_lt(reduced_gravity_step, base_gravity_step, "gravity reduction must keep the same air step lighter than the default fall")


func test_platform_drop_through_requires_grounded_down_input_and_one_way_floor() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var solid_floor := _make_floor_body("solid_floor")
	var one_way_floor := _make_floor_body("one_way_platform")

	player.debug_set_current_floor_platform(solid_floor)
	assert_false(player.debug_try_platform_drop_through(true, true))
	assert_false(player.debug_is_platform_drop_through_active())

	player.debug_set_current_floor_platform(one_way_floor)
	assert_false(player.debug_try_platform_drop_through(false, true))
	assert_false(player.debug_try_platform_drop_through(true, false))
	assert_true(player.debug_try_platform_drop_through(true, true))
	assert_true(player.debug_is_platform_drop_through_active())


func test_platform_drop_through_sets_fall_state_and_clears_after_timer() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var one_way_floor := _make_floor_body("one_way_platform")

	player.debug_set_current_floor_platform(one_way_floor)
	assert_true(player.debug_try_platform_drop_through(true, true))
	assert_eq(player.get_debug_state_name(), "Fall")
	assert_eq(player.velocity.y, 160.0)
	assert_true(player.debug_is_platform_drop_through_active())

	player.debug_advance_timers(0.18)
	assert_false(player.debug_is_platform_drop_through_active())


func test_reset_at_clears_platform_drop_through_state() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var one_way_floor := _make_floor_body("one_way_platform")

	player.debug_set_current_floor_platform(one_way_floor)
	assert_true(player.debug_try_platform_drop_through(true, true))
	player.reset_at(Vector2(32, 64))

	assert_false(player.debug_is_platform_drop_through_active())
	assert_eq(player.global_position, Vector2(32, 64))


func test_platform_drop_through_rejects_reentry_while_active_and_rearms_after_timeout() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var one_way_floor := _make_floor_body("one_way_platform")

	player.debug_set_current_floor_platform(one_way_floor)
	assert_true(player.debug_try_platform_drop_through(true, true))
	assert_false(
		player.debug_try_platform_drop_through(true, true),
		"drop-through should not re-enter while the previous exception window is active"
	)

	player.debug_advance_timers(0.18)
	player.debug_set_current_floor_platform(one_way_floor)
	assert_true(
		player.debug_try_platform_drop_through(true, true),
		"drop-through should rearm once the previous window expires"
	)


func test_platform_drop_through_rejects_when_dead_or_in_hit_stun() -> void:
	var dead_player = autofree(PLAYER_SCRIPT.new())
	var dead_floor := _make_floor_body("one_way_platform")
	dead_player.debug_set_current_floor_platform(dead_floor)
	dead_player.debug_mark_dead()
	assert_false(dead_player.debug_try_platform_drop_through(true, true))

	var hit_player = autofree(PLAYER_SCRIPT.new())
	var hit_floor := _make_floor_body("one_way_platform")
	hit_player.debug_set_current_floor_platform(hit_floor)
	hit_player.receive_hit(10, Vector2.ZERO, 120.0)
	assert_false(hit_player.debug_try_platform_drop_through(true, true))


func test_platform_drop_through_is_blocked_while_on_rope() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var rope_mock := Node.new()
	autofree(rope_mock)
	rope_mock.set_meta("rope_top_y", 400.0)
	rope_mock.set_meta("rope_bottom_y", 600.0)
	player.register_rope(rope_mock)
	assert_true(player._try_grab_rope())

	var one_way_floor := _make_floor_body("one_way_platform")
	player.debug_set_current_floor_platform(one_way_floor)
	assert_false(player.debug_try_platform_drop_through(true, true))


func test_platform_drop_through_clears_when_target_platform_is_freed() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var one_way_floor := StaticBody2D.new()
	one_way_floor.set_meta("collision_kind", "one_way_platform")

	player.debug_set_current_floor_platform(one_way_floor)
	assert_true(player.debug_try_platform_drop_through(true, true))
	assert_true(player.debug_is_platform_drop_through_active())

	one_way_floor.free()
	player.debug_advance_timers(0.01)
	assert_false(player.debug_is_platform_drop_through_active())


func test_dash_enters_cooldown_and_unlocks_after_time() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	assert_true(player.debug_begin_dash())
	assert_eq(player.get_debug_state_name(), "Dash")
	assert_false(player.debug_begin_dash())
	player.debug_advance_timers(0.7)
	assert_true(player.debug_begin_dash())


func test_receive_hit_grants_iframes_and_prevents_second_hit() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var starting_health := GameState.health
	player.receive_hit(10, Vector2.ZERO, 120.0)
	assert_lt(GameState.health, starting_health)
	var after_first_hit := GameState.health
	player.receive_hit(10, Vector2.ZERO, 120.0)
	assert_eq(GameState.health, after_first_hit)
	assert_true(player.is_input_locked())


func test_dead_state_blocks_jump_and_dash() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_mark_dead()
	assert_eq(player.get_debug_state_name(), "Dead")
	assert_false(player.debug_try_jump(true))
	assert_false(player.debug_begin_dash())


func test_state_chart_is_built_via_debug_setup() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	assert_null(player.get_state_chart(), "state_chart is null before setup")
	player.debug_setup_state_chart()
	assert_not_null(
		player.get_state_chart(), "state_chart should be created after debug_setup_state_chart()"
	)


func test_state_chart_dead_transition_matches_state_name() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_state_chart()
	player.debug_mark_dead()
	assert_eq(player.get_debug_state_name(), "Dead")
	assert_not_null(player.get_state_chart())


func test_state_chart_jump_and_double_jump_transitions() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_state_chart()
	player.debug_try_jump(true)
	assert_eq(player.get_debug_state_name(), "Jump")
	player.debug_try_jump(false)
	assert_eq(player.get_debug_state_name(), "DoubleJump")


func test_state_chart_dash_transition_sets_state_name() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_state_chart()
	player.debug_begin_dash()
	assert_eq(player.get_debug_state_name(), "Dash")
	assert_not_null(player.get_state_chart())


func test_rope_grab_sets_on_rope_state() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var rope_mock := Node.new()
	autofree(rope_mock)
	rope_mock.set_meta("rope_top_y", 400.0)
	rope_mock.set_meta("rope_bottom_y", 600.0)
	player.register_rope(rope_mock)
	var grabbed: bool = player._try_grab_rope()
	assert_true(grabbed, "should grab rope when current_rope is set")
	assert_eq(player.get_debug_state_name(), "OnRope")


func test_rope_unregister_exits_on_rope_state() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var rope_mock := Node.new()
	autofree(rope_mock)
	rope_mock.set_meta("rope_top_y", 400.0)
	rope_mock.set_meta("rope_bottom_y", 600.0)
	player.register_rope(rope_mock)
	player._try_grab_rope()
	assert_eq(player.get_debug_state_name(), "OnRope")
	player.unregister_rope(rope_mock)
	assert_null(player.current_rope)


func test_dead_player_cannot_grab_rope() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_mark_dead()
	var rope_mock := Node.new()
	autofree(rope_mock)
	player.register_rope(rope_mock)
	assert_false(player._try_grab_rope(), "dead player cannot grab rope")


func test_rope_grab_snaps_player_to_rope_center_and_clamps_height() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var rope = autofree(ROPE_SCRIPT.new())
	rope.setup({"position": Vector2(512, 420), "height": 180.0})
	player.global_position = Vector2(610, 280)
	player.register_rope(rope)
	assert_true(player._try_grab_rope(), "player should grab a valid rope")
	assert_eq(
		player.global_position.x,
		rope.global_position.x,
		"rope grab must snap x to the rope centerline"
	)
	assert_eq(player.global_position.y, rope.rope_top_y, "rope grab must clamp y into rope bounds")


func test_rope_physics_keeps_player_centered_and_inside_bounds() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var rope = autofree(ROPE_SCRIPT.new())
	rope.setup({"position": Vector2(700, 460), "height": 220.0})
	player.global_position = Vector2(640, 620)
	player.register_rope(rope)
	player._try_grab_rope()
	player.global_position = Vector2(660, 900)
	player._handle_rope_physics()
	assert_eq(
		player.global_position.x,
		rope.global_position.x,
		"rope physics must keep the player centered on the rope"
	)
	assert_eq(
		player.global_position.y,
		rope.rope_bottom_y,
		"rope physics must clamp the player to the rope bottom"
	)


func test_rope_physics_uses_meta_bounds_for_mock_rope() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var rope_mock: Node = autofree(Node.new())
	rope_mock.set_meta("rope_top_y", 380.0)
	rope_mock.set_meta("rope_bottom_y", 540.0)
	player.global_position = Vector2(480, 500)
	player.register_rope(rope_mock)
	assert_true(
		player._try_grab_rope(), "player should grab a mock rope that exposes bounds via meta"
	)
	player.global_position = Vector2(480, 720)
	player._handle_rope_physics()
	assert_eq(
		player.global_position.y,
		540.0,
		"rope physics must reuse meta-based bounds for mock ropes too"
	)


func test_unregister_rope_falls_back_to_previous_rope() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var first_rope: Node = autofree(Node.new())
	first_rope.set_meta("rope_top_y", 320.0)
	first_rope.set_meta("rope_bottom_y", 520.0)
	var second_rope: Node = autofree(Node.new())
	second_rope.set_meta("rope_top_y", 410.0)
	second_rope.set_meta("rope_bottom_y", 610.0)
	player.register_rope(first_rope)
	player.register_rope(second_rope)
	player.unregister_rope(second_rope)
	assert_eq(
		player.current_rope,
		first_rope,
		"rope focus should fall back to the previous rope when the latest one exits"
	)
	assert_true(player._try_grab_rope(), "player should still be able to grab the fallback rope")


func test_stale_current_rope_falls_back_to_previous_valid_rope() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var first_rope: Node = autofree(Node.new())
	first_rope.set_meta("rope_top_y", 300.0)
	first_rope.set_meta("rope_bottom_y", 500.0)
	var second_rope: Node = Node.new()
	second_rope.set_meta("rope_top_y", 420.0)
	second_rope.set_meta("rope_bottom_y", 620.0)
	player.register_rope(first_rope)
	player.register_rope(second_rope)
	second_rope.free()
	assert_eq(
		player._get_valid_rope(),
		first_rope,
		"stale current rope should be replaced with the previous valid rope"
	)
	assert_true(
		player._try_grab_rope(), "player should still grab a valid rope after stale rope cleanup"
	)


func test_cast_hotbar_slot_returns_false_when_dead() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_mark_dead()
	assert_false(player.cast_hotbar_slot(0), "dead player cannot cast hotbar slot")


func test_cast_hotbar_slot_returns_false_when_spell_manager_is_null() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	assert_false(
		player.cast_hotbar_slot(0),
		"cast_hotbar_slot should return false when spell_manager is null"
	)


func test_cast_hotbar_slot_returns_false_for_out_of_range_slot() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	assert_false(player.cast_hotbar_slot(-1), "negative slot index should return false")
	assert_false(player.cast_hotbar_slot(99), "out-of-range slot index should return false")


func test_cast_hotbar_slot_returns_false_for_empty_slot() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	GameState.set_hotbar_skill(0, "")
	assert_false(player.cast_hotbar_slot(0), "empty hotbar slot should return false on cast")


func test_cast_hotbar_slot_activates_buff_skill() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	GameState.set_hotbar_skill(0, "holy_mana_veil")
	GameState.mana = GameState.max_mana
	var result: bool = player.cast_hotbar_slot(0)
	assert_true(result, "cast_hotbar_slot should succeed for a valid buff skill")


func test_cast_hotbar_slot_frost_nova_triggers_area_burst_camera_shake() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	GameState.set_hotbar_skill(0, "frost_nova")
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	assert_eq(player._cam_shake_timer, 0.0, "cast shake timer should start idle")
	assert_true(player.cast_hotbar_slot(0), "frost_nova cast should succeed from hotbar")
	assert_gt(player._cam_shake_timer, 0.0, "area burst casts must trigger a short local camera shake")
	assert_gt(player._cam_shake_intensity, 0.0, "area burst casts must set camera shake intensity")


func test_screen_shake_setting_can_disable_area_burst_camera_feedback() -> void:
	UiState.set_screen_shake_enabled(false, false)
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	GameState.set_hotbar_skill(0, "frost_nova")
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	assert_true(player.cast_hotbar_slot(0), "frost_nova cast should still succeed when screen shake is disabled")
	assert_eq(player._cam_shake_timer, 0.0, "disabled screen shake should suppress burst camera shake timers")
	assert_eq(player._cam_shake_intensity, 0.0, "disabled screen shake should suppress burst camera shake intensity")


func test_player_visible_hotbar_bindings_expose_first_ten_slots() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	var visible_bindings: Array = player.get_visible_hotbar_bindings()
	assert_eq(
		visible_bindings.size(),
		GameState.VISIBLE_HOTBAR_SLOT_COUNT,
		"player wrapper should expose the first ten visible hotbar slots"
	)
	assert_eq(str(visible_bindings[0].get("label", "")), "1")
	assert_eq(str(visible_bindings[9].get("label", "")), "0")


func test_player_visible_hotbar_shortcuts_wrap_game_state_profile() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	var shortcuts: Array = player.get_visible_hotbar_shortcuts()
	assert_eq(shortcuts.size(), GameState.VISIBLE_HOTBAR_SLOT_COUNT)
	assert_eq(str(shortcuts[0].get("action", "")), "spell_fire")
	assert_eq(int(shortcuts[0].get("keycode", 0)), KEY_1)


func test_player_can_rebind_visible_hotbar_shortcut_through_wrapper() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	assert_true(player.rebind_visible_hotbar_shortcut(0, KEY_1))
	assert_eq(str(GameState.get_hotbar_slot(0).get("label", "")), "1")
	assert_eq((InputMap.action_get_events("spell_fire")[0] as InputEventKey).physical_keycode, KEY_1)
	player.reset_visible_hotbar_shortcuts_to_default()
	assert_eq(str(GameState.get_hotbar_slot(0).get("label", "")), "1")


func test_player_hotbar_slot_tooltip_data_wraps_spell_manager_payload() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	GameState.set_hotbar_skill(0, "holy_mana_veil")
	var tooltip: Dictionary = player.get_hotbar_slot_tooltip_data(0)
	assert_eq(str(tooltip.get("skill_id", "")), "holy_mana_veil")
	assert_eq(str(tooltip.get("label", "")), "1")
	assert_string_contains(str(tooltip.get("name", "")), "마나 베일")
	assert_true(tooltip.has("description"), "player tooltip wrapper should preserve description field")


func test_player_can_clear_and_swap_hotbar_slots_through_wrappers() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	var initial_slot_zero: Dictionary = GameState.get_hotbar_slot(0)
	var initial_slot_one: Dictionary = GameState.get_hotbar_slot(1)
	assert_true(player.swap_hotbar_slots(0, 1))
	assert_eq(
		str(GameState.get_hotbar_slot(0).get("skill_id", "")),
		str(initial_slot_one.get("skill_id", "")),
		"player swap wrapper should delegate to GameState hotbar swap"
	)
	assert_true(player.clear_hotbar_slot(1))
	assert_eq(str(GameState.get_hotbar_slot(1).get("skill_id", "")), "")
	assert_eq(
		str(GameState.get_hotbar_slot(1).get("label", "")),
		str(initial_slot_one.get("label", "")),
		"player clear wrapper should preserve slot metadata"
	)
	assert_eq(
		str(GameState.get_hotbar_slot(0).get("label", "")),
		str(initial_slot_zero.get("label", "")),
		"player swap wrapper should preserve destination slot label"
	)


func test_receive_hit_with_slow_effect_sets_slow_state() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	assert_eq(player.player_slow_timer, 0.0, "slow_timer starts at zero")
	assert_eq(player.player_slow_multiplier, 1.0, "slow_multiplier starts at 1.0")
	player.receive_hit(
		5, Vector2.ZERO, 100.0, "", [{"type": "slow", "value": 0.3, "duration": 1.5}]
	)
	assert_almost_eq(
		player.player_slow_multiplier, 0.7, 0.001, "slow_multiplier should be 0.7 after 30% slow"
	)
	assert_almost_eq(
		player.player_slow_timer, 1.5, 0.001, "slow_timer should be 1.5 after slow applied"
	)


func test_slow_timer_expires_and_resets_multiplier() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.receive_hit(
		5, Vector2.ZERO, 100.0, "", [{"type": "slow", "value": 0.3, "duration": 0.5}]
	)
	assert_almost_eq(player.player_slow_multiplier, 0.7, 0.001, "slow active after hit")
	player.debug_advance_timers(0.6)
	assert_eq(player.player_slow_timer, 0.0, "slow_timer at zero after expiry")
	assert_eq(player.player_slow_multiplier, 1.0, "slow_multiplier restored to 1.0 after expiry")


func test_receive_hit_no_utility_effects_leaves_slow_unchanged() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.receive_hit(5, Vector2.ZERO, 100.0)
	assert_eq(player.player_slow_multiplier, 1.0, "no slow effect — multiplier stays 1.0")


func test_reset_at_clears_slow_state() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.player_slow_timer = 2.0
	player.player_slow_multiplier = 0.5
	player.reset_at(Vector2.ZERO)
	assert_eq(player.player_slow_timer, 0.0, "reset_at clears slow_timer")
	assert_eq(player.player_slow_multiplier, 1.0, "reset_at restores slow_multiplier")


func test_respawn_from_saved_route_restores_position_and_clears_dead_state() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	GameState.save_progress("vault_sector", Vector2(920, 410))
	player.global_position = Vector2(1500, 200)
	player.player_slow_timer = 1.2
	player.player_slow_multiplier = 0.4
	player.invuln_timer = 0.5
	player._cam_shake_timer = 0.2
	GameState.mana = 7.0
	GameState.active_buffs.append({"skill_id": "holy_mana_veil", "remaining": 4.0, "effects": []})
	GameState.active_penalties.append(
		{"stat": "defense_multiplier", "mode": "mul", "value": 0.75, "remaining": 8.0}
	)
	player.debug_mark_dead()
	var restore_data: Dictionary = player.respawn_from_saved_route()
	assert_eq(
		str(restore_data.get("room_id", "")),
		"vault_sector",
		"respawn must expose the saved room id for sandbox wiring"
	)
	assert_eq(
		restore_data.get("spawn_position", Vector2.ZERO),
		Vector2(920, 410),
		"respawn must use the saved spawn position"
	)
	assert_eq(
		player.global_position, Vector2(920, 410), "player must return to the saved spawn position"
	)
	assert_eq(player.get_debug_state_name(), "Idle", "respawn must clear the Dead state")
	assert_false(player.is_dead, "respawn must clear is_dead")
	assert_eq(player.player_slow_timer, 0.0, "respawn must clear slow timer")
	assert_eq(player.player_slow_multiplier, 1.0, "respawn must restore slow multiplier")
	assert_eq(player.invuln_timer, 0.0, "respawn must clear leftover invulnerability")
	assert_eq(player._cam_shake_timer, 0.0, "respawn must clear leftover camera shake")
	assert_eq(
		GameState.mana,
		GameState.max_mana,
		"respawn must restore mana via GameState.restore_after_death"
	)
	assert_true(GameState.active_buffs.is_empty(), "respawn must clear active buffs")
	assert_true(GameState.active_penalties.is_empty(), "respawn must clear active penalties")


func test_rest_point_saves_global_spawn_position_not_local_position() -> void:
	var parent = autofree(Node2D.new())
	parent.position = Vector2(300, 120)
	var rest_point = autofree(REST_POINT_SCRIPT.new())
	var dummy_player = autofree(Node.new())
	parent.add_child(rest_point)
	rest_point.setup({"position": Vector2(80, 500), "text": "Route sealed."})
	GameState.current_room_id = "vault_sector"
	rest_point.interact(dummy_player)
	assert_eq(GameState.save_room_id, "vault_sector", "rest point must save the current room id")
	assert_eq(
		GameState.save_spawn_position,
		Vector2(380, 560),
		"rest point must save a global spawn anchor even under a translated parent"
	)


func test_rest_point_interact_grants_entrance_progression_event() -> void:
	var rest_point = autofree(REST_POINT_SCRIPT.new())
	var dummy_player = autofree(Node.new())
	rest_point.setup({"position": Vector2(140, 540)})
	GameState.current_room_id = "entrance"
	rest_point.interact(dummy_player)
	assert_true(
		GameState.progression_flags.has("rest_entrance"),
		"entrance rest point must grant the rest_entrance progression event"
	)


func test_seal_statue_interact_saves_heals_and_grants_hub_progression() -> void:
	var statue = autofree(SEAL_STATUE_SCRIPT.new())
	var dummy_player = autofree(Node.new())
	GameState.current_room_id = "seal_sanctum"
	GameState.health = 12
	GameState.mana = 24.0
	statue.setup(
		{
			"position": Vector2(300, 540),
			"progression_event_id": "seal_sanctum_anchor",
			"text": "The refuge accepts your route."
		}
	)
	statue.interact(dummy_player)
	assert_eq(GameState.save_room_id, "seal_sanctum")
	assert_eq(GameState.save_spawn_position, Vector2(300, 468))
	assert_eq(GameState.health, GameState.max_health)
	assert_eq(GameState.mana, GameState.max_mana)
	assert_true(
		GameState.progression_flags.has("seal_sanctum_anchor"),
		"seal statue must grant the hub anchor progression flag on first interaction"
	)


func test_memory_plinth_interact_saves_progress_and_grants_castle_progression() -> void:
	var plinth = autofree(MEMORY_PLINTH_SCRIPT.new())
	var dummy_player = autofree(Node.new())
	GameState.current_room_id = "royal_inner_hall"
	plinth.setup(
		{
			"position": Vector2(420, 500),
			"progression_event_id": "royal_inner_hall_archive",
			"save_progress": true,
			"text": "The archive still resists oblivion."
		}
	)
	plinth.interact(dummy_player)
	assert_eq(GameState.save_room_id, "royal_inner_hall")
	assert_eq(GameState.save_spawn_position, Vector2(420, 440))
	assert_true(
		GameState.progression_flags.has("royal_inner_hall_archive"),
		"memory plinth must grant the inner hall archive progression flag on first interaction"
	)


func test_memory_plinth_repeat_interact_uses_repeat_message_without_duplicate_progression() -> void:
	var plinth = autofree(MEMORY_PLINTH_SCRIPT.new())
	var dummy_player = autofree(Node.new())
	GameState.current_room_id = "throne_approach"
	plinth.setup(
		{
			"position": Vector2(520, 480),
			"progression_event_id": "throne_approach_decree",
			"repeat_text": "The broken decree cannot tighten its hold any further."
		}
	)
	plinth.interact(dummy_player)
	assert_true(GameState.progression_flags.has("throne_approach_decree"))
	plinth.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"The broken decree cannot tighten its hold any further."
	)


func test_covenant_altar_interact_saves_progress_and_grants_final_progression() -> void:
	var altar = autofree(COVENANT_ALTAR_SCRIPT.new())
	var dummy_player = autofree(Node.new())
	GameState.current_room_id = "inverted_spire"
	altar.setup(
		{
			"position": Vector2(640, 540),
			"progression_event_id": "inverted_spire_covenant",
			"text": "The covenant remains legible."
		}
	)
	altar.interact(dummy_player)
	assert_eq(GameState.save_room_id, "inverted_spire")
	assert_eq(GameState.save_spawn_position, Vector2(640, 468))
	assert_true(
		GameState.progression_flags.has("inverted_spire_covenant"),
		"covenant altar must grant the final covenant progression flag on first interaction"
	)


func test_covenant_altar_repeat_interact_uses_repeat_message() -> void:
	var altar = autofree(COVENANT_ALTAR_SCRIPT.new())
	var dummy_player = autofree(Node.new())
	GameState.current_room_id = "inverted_spire"
	altar.setup(
		{
			"position": Vector2(760, 540),
			"progression_event_id": "inverted_spire_covenant",
			"repeat_text": "The chamber already knows what the bargain cost."
		}
	)
	altar.interact(dummy_player)
	altar.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The chamber already knows what the bargain cost.")


func test_refuge_notice_uses_default_message_without_progression_flags() -> void:
	var notice = autofree(REFUGE_NOTICE_SCRIPT.new())
	var dummy_player = autofree(Node.new())
	notice.setup(
		{
			"position": Vector2(300, 500),
			"text": "Keep the sanctuary wards lit."
		}
	)
	notice.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "Keep the sanctuary wards lit.")


func test_refuge_notice_reacts_to_latest_castle_progression_flag() -> void:
	var notice = autofree(REFUGE_NOTICE_SCRIPT.new())
	var dummy_player = autofree(Node.new())
	notice.setup(
		{
			"position": Vector2(340, 500),
			"text": "Default notice.",
			"stage_messages": [
				{
					"required_flag": "inverted_spire_covenant",
					"text": "Final covenant warning."
				},
				{
					"required_flag": "throne_approach_decree",
					"text": "Throne corridor warning."
				},
				{
					"required_flag": "royal_inner_hall_archive",
					"text": "Inner hall archive update."
				}
			]
		}
	)
	GameState.progression_flags["royal_inner_hall_archive"] = true
	notice.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "Inner hall archive update.")
	GameState.progression_flags["throne_approach_decree"] = true
	notice.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "Throne corridor warning.")
	GameState.progression_flags["inverted_spire_covenant"] = true
	notice.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "Final covenant warning.")


func test_refuge_notice_reacts_to_gate_threshold_flags_before_deeper_castle_states() -> void:
	var notice = autofree(REFUGE_NOTICE_SCRIPT.new())
	var dummy_player = autofree(Node.new())
	notice.setup(
		{
			"position": Vector2(360, 500),
			"text": "Default notice.",
			"stage_messages": [
				{
					"required_flag": "inverted_spire_covenant",
					"text": "Final covenant warning."
				},
				{
					"required_flags_all": [
						"gate_threshold_survivor_trace",
						"gate_threshold_bloodline_hint"
					],
					"text": "Combined threshold warning."
				},
				{
					"required_flag": "gate_threshold_bloodline_hint",
					"text": "Bloodline warning."
				},
				{
					"required_flag": "gate_threshold_survivor_trace",
					"text": "Survivor warning."
				}
			]
		}
	)
	GameState.progression_flags["gate_threshold_survivor_trace"] = true
	notice.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "Survivor warning.")
	GameState.progression_flags["gate_threshold_bloodline_hint"] = true
	notice.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "Combined threshold warning.")
	GameState.progression_flags["inverted_spire_covenant"] = true
	notice.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "Final covenant warning.")


func test_refuge_notice_supports_combined_companion_stage_before_final_covenant() -> void:
	var notice = autofree(REFUGE_NOTICE_SCRIPT.new())
	var dummy_player = autofree(Node.new())
	notice.setup(
		{
			"position": Vector2(380, 500),
			"text": "Default notice.",
			"stage_messages": [
				{
					"required_flag": "inverted_spire_covenant",
					"text": "Final covenant warning."
				},
				{
					"required_flags_all": [
						"royal_inner_hall_companion_trace",
						"royal_inner_hall_archive",
						"throne_approach_companion_trace",
						"throne_approach_decree"
					],
					"text": "Combined companion warning."
				},
				{
					"required_flag": "throne_approach_decree",
					"text": "Throne corridor warning."
				}
			]
		}
	)
	GameState.progression_flags["royal_inner_hall_companion_trace"] = true
	GameState.progression_flags["royal_inner_hall_archive"] = true
	GameState.progression_flags["throne_approach_companion_trace"] = true
	notice.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "Default notice.")
	GameState.progression_flags["throne_approach_decree"] = true
	notice.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "Combined companion warning.")


func test_echo_marker_can_grant_custom_progression_event_from_room_config() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(320, 520),
			"text": "A familiar support rhythm sours at the edge.",
			"repeat_text": "The rhythm still twists the same way.",
			"progression_event_id": "royal_inner_hall_companion_trace"
		},
		"royal_inner_hall",
		1
	)
	echo.interact(dummy_player)
	assert_true(GameState.progression_flags.has("royal_inner_hall_companion_trace"))
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The rhythm still twists the same way.")


func test_echo_marker_repeat_text_can_react_to_progression_flags() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(360, 520),
			"text": "The circle waits in silence.",
			"repeat_text": "The circle still waits.",
			"repeat_stage_messages": [
				{
					"required_flag": "inverted_spire_covenant",
					"text": "The circle now reads like a completed law."
				}
			]
		},
		"inverted_spire",
		0
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The circle waits in silence.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The circle still waits.")
	GameState.progression_flags["inverted_spire_covenant"] = true
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The circle now reads like a completed law.")


func test_echo_marker_repeat_text_can_react_to_inverted_spire_furnishing_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(380, 520),
			"text": "The overturned furniture still looks like wreckage.",
			"repeat_text": "The chamber still keeps the furniture upside down.",
			"repeat_stage_messages": [
				{
					"required_flag": "inverted_spire_covenant",
					"text": "The overturned furniture now reads like royal life forced into the covenant's ritual frame."
				}
			]
		},
		"inverted_spire",
		1
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The overturned furniture still looks like wreckage.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The chamber still keeps the furniture upside down.")
	GameState.progression_flags["inverted_spire_covenant"] = true
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"The overturned furniture now reads like royal life forced into the covenant's ritual frame."
	)


func test_echo_marker_repeat_text_can_react_to_inverted_spire_alcove_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(420, 520),
			"text": "The alcove window has been turned sideways.",
			"repeat_stage_messages": [
				{
					"required_flag": "inverted_spire_covenant",
					"text": "The buried alcove now reads like one more converted living space serving the ritual's law."
				}
			]
		},
		"inverted_spire",
		2
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The alcove window has been turned sideways.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), DEFAULT_ECHO_REPEAT_TEXT)
	GameState.progression_flags["inverted_spire_covenant"] = true
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"The buried alcove now reads like one more converted living space serving the ritual's law."
	)


func test_echo_marker_repeat_text_can_react_to_combined_throne_flags() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(400, 520),
			"text": "The corridor still points toward the throne.",
			"repeat_text": "The corridor still compels the same way.",
			"repeat_stage_messages": [
				{
					"required_flags_all": [
						"throne_approach_companion_trace",
						"throne_approach_decree"
					],
					"text": "The corridor now reads like a machine for teaching obedience."
				}
			]
		},
		"throne_approach",
		0
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The corridor still points toward the throne.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The corridor still compels the same way.")
	GameState.progression_flags["throne_approach_companion_trace"] = true
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The corridor still compels the same way.")
	GameState.progression_flags["throne_approach_decree"] = true
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The corridor now reads like a machine for teaching obedience.")


func test_echo_marker_repeat_text_can_react_to_throne_final_covenant_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(420, 520),
			"text": "The corridor still points toward the throne.",
			"repeat_text": "The corridor still compels the same way.",
			"repeat_stage_messages": [
				{
					"required_flag": "inverted_spire_covenant",
					"text": "The corridor now reads like rehearsal: the throne taught obedience here so the bargain could later pass for law."
				}
			]
		},
		"throne_approach",
		0
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The corridor still points toward the throne.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The corridor still compels the same way.")
	GameState.progression_flags["inverted_spire_covenant"] = true
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"The corridor now reads like rehearsal: the throne taught obedience here so the bargain could later pass for law."
	)


func test_echo_marker_repeat_text_can_react_to_combined_gate_flags() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(440, 520),
			"text": "The refuge note ends in warning.",
			"repeat_text": "The refuge note still trails off.",
			"repeat_stage_messages": [
				{
					"required_flags_all": [
						"gate_threshold_survivor_trace",
						"gate_threshold_bloodline_hint"
					],
					"text": "The refuge note now sounds like a rule for resisting selection."
				}
			]
		},
		"seal_sanctum",
		0
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The refuge note ends in warning.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The refuge note still trails off.")
	GameState.progression_flags["gate_threshold_survivor_trace"] = true
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The refuge note still trails off.")
	GameState.progression_flags["gate_threshold_bloodline_hint"] = true
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The refuge note now sounds like a rule for resisting selection.")


func test_echo_marker_repeat_text_can_react_to_combined_companion_flags() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(480, 520),
			"text": "The refuge crest is still covered over.",
			"repeat_text": "The ward script still hides the crest.",
			"repeat_stage_messages": [
				{
					"required_flags_all": [
						"royal_inner_hall_companion_trace",
						"royal_inner_hall_archive",
						"throne_approach_companion_trace",
						"throne_approach_decree"
					],
					"text": "The overwritten crest now looks like a rejection of the court's false authority."
				}
			]
		},
		"seal_sanctum",
		1
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The refuge crest is still covered over.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The ward script still hides the crest.")
	GameState.progression_flags["royal_inner_hall_companion_trace"] = true
	GameState.progression_flags["royal_inner_hall_archive"] = true
	GameState.progression_flags["throne_approach_companion_trace"] = true
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The ward script still hides the crest.")
	GameState.progression_flags["throne_approach_decree"] = true
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"The overwritten crest now looks like a rejection of the court's false authority."
	)


func test_echo_marker_repeat_text_can_react_to_hub_crest_final_covenant_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(500, 520),
			"text": "The refuge crest is still covered over.",
			"repeat_text": "The ward script still hides the crest.",
			"repeat_stage_messages": [
				{
					"required_flag": "inverted_spire_covenant",
					"text": "The covered crest now reads like the refuge refusing the king's last definition of the kingdom."
				}
			]
		},
		"seal_sanctum",
		1
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The refuge crest is still covered over.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The ward script still hides the crest.")
	GameState.progression_flags["inverted_spire_covenant"] = true
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"The covered crest now reads like the refuge refusing the king's last definition of the kingdom."
	)


func test_echo_marker_repeat_text_can_react_to_hub_ward_anchor_companion_flags() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(520, 520),
			"text": "The ward anchor has been reset too many times to count.",
			"repeat_stage_messages": [
				{
					"required_flags_all": [
						"royal_inner_hall_companion_trace",
						"royal_inner_hall_archive",
						"throne_approach_companion_trace",
						"throne_approach_decree"
					],
					"text": "The ward anchor now reads like repeated refusal: shelter kept being renewed against the palace's idea of obedience."
				}
			]
		},
		"seal_sanctum",
		2
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The ward anchor has been reset too many times to count.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), DEFAULT_ECHO_REPEAT_TEXT)
	GameState.progression_flags["royal_inner_hall_companion_trace"] = true
	GameState.progression_flags["royal_inner_hall_archive"] = true
	GameState.progression_flags["throne_approach_companion_trace"] = true
	GameState.progression_flags["throne_approach_decree"] = true
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"The ward anchor now reads like repeated refusal: shelter kept being renewed against the palace's idea of obedience."
	)


func test_echo_marker_repeat_text_can_react_to_inner_hall_archive_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(520, 520),
			"text": "The portraits were removed first.",
			"repeat_text": "The empty frames still hang above the hall.",
			"repeat_stage_messages": [
				{
					"required_flag": "royal_inner_hall_archive",
					"text": "The empty frames now read like an official erasure of the royal line."
				}
			]
		},
		"royal_inner_hall",
		0
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The portraits were removed first.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The empty frames still hang above the hall.")
	GameState.progression_flags["royal_inner_hall_archive"] = true
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"The empty frames now read like an official erasure of the royal line."
	)


func test_echo_marker_repeat_text_can_react_to_inner_hall_final_covenant_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(540, 520),
			"text": "The portraits were removed first.",
			"repeat_text": "The empty frames still hang above the hall.",
			"repeat_stage_messages": [
				{
					"required_flag": "inverted_spire_covenant",
					"text": "The empty frames now read like preparation for a kingdom meant to survive without anything human left to inherit it."
				}
			]
		},
		"royal_inner_hall",
		0
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The portraits were removed first.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The empty frames still hang above the hall.")
	GameState.progression_flags["inverted_spire_covenant"] = true
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"The empty frames now read like preparation for a kingdom meant to survive without anything human left to inherit it."
	)


func test_echo_marker_repeat_text_can_react_to_inner_hall_companion_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(560, 520),
			"text": "The support spell still sounds hopeful.",
			"repeat_text": "The formula still carries a familiar rhythm.",
			"repeat_stage_messages": [
				{
					"required_flag": "royal_inner_hall_companion_trace",
					"text": "The formula now reads like support magic bent into palace obedience."
				}
			]
		},
		"royal_inner_hall",
		1
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The support spell still sounds hopeful.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The formula still carries a familiar rhythm.")
	GameState.progression_flags["royal_inner_hall_companion_trace"] = true
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"The formula now reads like support magic bent into palace obedience."
	)


func test_echo_marker_repeat_text_can_react_to_gate_survivor_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(600, 520),
			"text": "The gate kept its inspection marks.",
			"repeat_text": "The same judgment marks remain.",
			"repeat_stage_messages": [
				{
					"required_flag": "gate_threshold_survivor_trace",
					"text": "The marks now read like survivors rehearsing the same warning."
				}
			],
			"progression_event_id": "gate_threshold_survivor_trace"
		},
		"gate_threshold",
		0
	)
	echo.interact(dummy_player)
	assert_true(GameState.progression_flags.has("gate_threshold_survivor_trace"))
	assert_eq(str(GameState.ui_message), "The gate kept its inspection marks.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The marks now read like survivors rehearsing the same warning.")


func test_echo_marker_repeat_text_can_react_to_gate_bloodline_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(640, 520),
			"text": "The arch still claims to lead upward.",
			"repeat_text": "The false ascent still hangs over the gate.",
			"repeat_stage_messages": [
				{
					"required_flag": "gate_threshold_bloodline_hint",
					"text": "The false ascent now reads like a selector deciding who belongs below."
				}
			],
			"progression_event_id": "gate_threshold_bloodline_hint"
		},
		"gate_threshold",
		1
	)
	echo.interact(dummy_player)
	assert_true(GameState.progression_flags.has("gate_threshold_bloodline_hint"))
	assert_eq(str(GameState.ui_message), "The arch still claims to lead upward.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The false ascent now reads like a selector deciding who belongs below.")


func test_echo_marker_repeat_text_can_react_to_gate_final_covenant_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(660, 520),
			"text": "The arch still claims to lead upward.",
			"repeat_text": "The false ascent still hangs over the gate.",
			"repeat_stage_messages": [
				{
					"required_flag": "inverted_spire_covenant",
					"text": "The false ascent now reads like the first promise in the bargain: show the castle above, then feed the chosen bloodline below."
				}
			]
		},
		"gate_threshold",
		1
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The arch still claims to lead upward.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The false ascent still hangs over the gate.")
	GameState.progression_flags["inverted_spire_covenant"] = true
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"The false ascent now reads like the first promise in the bargain: show the castle above, then feed the chosen bloodline below."
	)


func test_echo_marker_repeat_text_can_react_to_gate_secondary_survivor_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(680, 520),
			"text": "The queue line still divides the floor.",
			"repeat_text": "The queue line still divides the floor before anyone speaks.",
			"repeat_stage_messages": [
				{
					"required_flag": "gate_threshold_survivor_trace",
					"text": "Now that the survivor warning is known, the queue line reads like the floor memorizing the same inspection order the living kept repeating."
				}
			]
		},
		"gate_threshold",
		2
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The queue line still divides the floor.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The queue line still divides the floor before anyone speaks.")
	GameState.progression_flags["gate_threshold_survivor_trace"] = true
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"Now that the survivor warning is known, the queue line reads like the floor memorizing the same inspection order the living kept repeating."
	)


func test_echo_marker_repeat_text_can_react_to_entrance_first_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(680, 520),
			"text": "The survey stakes still point toward the breach.",
			"repeat_text": "The survey stakes still lean the same way.",
			"repeat_stage_messages": [
				{
					"required_flag": "echo_entrance_1",
					"text": "The survey stakes now read like proof that escape already meant going deeper."
				}
			]
		},
		"entrance",
		1
	)
	echo.interact(dummy_player)
	assert_true(GameState.progression_flags.has("echo_entrance_1"))
	assert_eq(str(GameState.ui_message), "The survey stakes still point toward the breach.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The survey stakes now read like proof that escape already meant going deeper.")


func test_echo_marker_repeat_text_can_react_to_entrance_second_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(720, 520),
			"text": "The wall still points toward the castle.",
			"repeat_text": "The ruined wall still points the same way.",
			"repeat_stage_messages": [
				{
					"required_flag": "echo_entrance_2",
					"text": "The ruined wall now feels like it is still obeying the deeper city."
				}
			]
		},
		"entrance",
		2
	)
	echo.interact(dummy_player)
	assert_true(GameState.progression_flags.has("echo_entrance_2"))
	assert_eq(str(GameState.ui_message), "The wall still points toward the castle.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The ruined wall now feels like it is still obeying the deeper city.")


func test_echo_marker_repeat_text_can_react_to_entrance_final_covenant_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(740, 520),
			"text": "The wall still points toward the castle.",
			"repeat_text": "The ruined wall still points the same way.",
			"repeat_stage_messages": [
				{
					"required_flag": "inverted_spire_covenant",
					"text": "The ruined wall now reads like the maze's earliest confession: even the outer stones were already pointing the kingdom downward."
				}
			]
		},
		"entrance",
		2
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The wall still points toward the castle.")
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The ruined wall still points the same way.")
	GameState.progression_flags["inverted_spire_covenant"] = true
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"The ruined wall now reads like the maze's earliest confession: even the outer stones were already pointing the kingdom downward."
	)


func test_echo_marker_repeat_text_can_react_to_entrance_secondary_escape_flag() -> void:
	var echo = autofree(preload("res://scripts/world/echo_marker.gd").new())
	var dummy_player = autofree(Node.new())
	echo.setup(
		{
			"position": Vector2(760, 520),
			"text": "The guidepost still points upward.",
			"repeat_text": "The broken guidepost still promises up while the ground keeps teaching down.",
			"repeat_stage_messages": [
				{
					"required_flag": "echo_entrance_1",
					"text": "Once the survey trace is known, the guidepost stops looking mistaken and starts reading like the same false escape route repeated in wood and paint."
				}
			]
		},
		"entrance",
		3
	)
	echo.interact(dummy_player)
	assert_eq(str(GameState.ui_message), "The guidepost still points upward.")
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"The broken guidepost still promises up while the ground keeps teaching down."
	)
	GameState.progression_flags["echo_entrance_1"] = true
	echo.interact(dummy_player)
	assert_eq(
		str(GameState.ui_message),
		"Once the survey trace is known, the guidepost stops looking mistaken and starts reading like the same false escape route repeated in wood and paint."
	)


func test_try_interact_calls_registered_interactable() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var interactable = autofree(DummyInteractable.new())
	player.register_interactable(interactable)
	assert_true(
		player._try_interact(), "player should interact when a valid interactable is registered"
	)
	assert_eq(interactable.interact_calls, 1, "interactable should receive one interact call")
	assert_eq(interactable.last_player, player, "interactable should receive the player reference")


func test_try_interact_clears_stale_interactable_reference() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var interactable = DummyInteractable.new()
	player.register_interactable(interactable)
	interactable.free()
	assert_false(player._try_interact(), "stale interactable reference should be ignored safely")
	assert_null(
		player.current_interactable,
		"stale interactable reference should be cleared after detection"
	)


func test_unregister_interactable_falls_back_to_previous_target() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var first = autofree(DummyInteractable.new())
	var second = autofree(DummyInteractable.new())
	player.register_interactable(first)
	player.register_interactable(second)
	player.unregister_interactable(second)
	assert_true(
		player._try_interact(), "player should keep an older interactable when the latest one exits"
	)
	assert_eq(first.interact_calls, 1, "fallback interactable should receive the interaction")
	assert_eq(second.interact_calls, 0, "removed interactable should not be called again")
	assert_eq(
		player.current_interactable, first, "focus should fall back to the previous interactable"
	)


func test_stale_current_interactable_falls_back_to_previous_valid_target() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var first = autofree(DummyInteractable.new())
	var second = DummyInteractable.new()
	player.register_interactable(first)
	player.register_interactable(second)
	second.free()
	assert_true(
		player._try_interact(),
		"player should recover to the previous valid interactable when the current one is freed"
	)
	assert_eq(
		first.interact_calls, 1, "previous interactable should receive the recovered interaction"
	)
	assert_eq(
		player.current_interactable,
		first,
		"stale current interactable should be replaced with the previous valid one"
	)


func test_room_shift_edge_only_emits_once_until_player_reenters_safe_zone() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var emitted: Array[int] = []
	var room_width := float(GameDatabase.get_room("entrance").get("width", 1600))
	player.request_room_shift.connect(func(direction: int) -> void: emitted.append(direction))
	player.global_position = Vector2(room_width - 55.0, 480)
	player._check_room_edges()
	player._check_room_edges()
	assert_eq(
		emitted, [1], "room shift should emit once while the player remains beyond the same edge"
	)
	player.global_position = Vector2(room_width * 0.5, 480)
	player._check_room_edges()
	player.global_position = Vector2(room_width - 55.0, 480)
	player._check_room_edges()
	assert_eq(emitted, [1, 1], "room shift should re-arm after the player returns to the safe zone")


func test_room_shift_edge_lock_clears_on_reset_at() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var emitted: Array[int] = []
	player.request_room_shift.connect(func(direction: int) -> void: emitted.append(direction))
	player.global_position = Vector2(5, 480)
	player._check_room_edges()
	player.reset_at(Vector2(600, 480))
	player.global_position = Vector2(5, 480)
	player._check_room_edges()
	assert_eq(
		emitted,
		[-1, -1],
		"reset_at should clear the edge lock so the next room edge can emit again"
	)
