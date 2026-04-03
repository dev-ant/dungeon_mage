extends "res://addons/gut/test.gd"

const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")
const ROPE_SCRIPT := preload("res://scripts/world/rope.gd")
const REST_POINT_SCRIPT := preload("res://scripts/world/rest_point.gd")


class DummyInteractable:
	extends Node

	var interact_calls := 0
	var last_player: Node = null

	func interact(player: Node) -> void:
		interact_calls += 1
		last_player = player


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


func test_player_visible_hotbar_bindings_expose_first_ten_slots() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	var visible_bindings: Array = player.get_visible_hotbar_bindings()
	assert_eq(
		visible_bindings.size(),
		GameState.VISIBLE_HOTBAR_SLOT_COUNT,
		"player wrapper should expose the first ten visible hotbar slots"
	)
	assert_eq(str(visible_bindings[0].get("label", "")), "Z")
	assert_eq(str(visible_bindings[9].get("label", "")), "M")


func test_player_visible_hotbar_shortcuts_wrap_game_state_profile() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	var shortcuts: Array = player.get_visible_hotbar_shortcuts()
	assert_eq(shortcuts.size(), GameState.VISIBLE_HOTBAR_SLOT_COUNT)
	assert_eq(str(shortcuts[0].get("action", "")), "spell_fire")
	assert_eq(int(shortcuts[0].get("keycode", 0)), KEY_Z)


func test_player_can_rebind_visible_hotbar_shortcut_through_wrapper() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	assert_true(player.rebind_visible_hotbar_shortcut(0, KEY_1))
	assert_eq(str(GameState.get_hotbar_slot(0).get("label", "")), "1")
	assert_eq((InputMap.action_get_events("spell_fire")[0] as InputEventKey).physical_keycode, KEY_1)
	player.reset_visible_hotbar_shortcuts_to_default()
	assert_eq(str(GameState.get_hotbar_slot(0).get("label", "")), "Z")


func test_player_hotbar_slot_tooltip_data_wraps_spell_manager_payload() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_setup_spell_manager()
	GameState.set_hotbar_skill(0, "holy_mana_veil")
	var tooltip: Dictionary = player.get_hotbar_slot_tooltip_data(0)
	assert_eq(str(tooltip.get("skill_id", "")), "holy_mana_veil")
	assert_eq(str(tooltip.get("label", "")), "Z")
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
	player.request_room_shift.connect(func(direction: int) -> void: emitted.append(direction))
	player.global_position = Vector2(1605, 480)
	player._check_room_edges()
	player._check_room_edges()
	assert_eq(
		emitted, [1], "room shift should emit once while the player remains beyond the same edge"
	)
	player.global_position = Vector2(900, 480)
	player._check_room_edges()
	player.global_position = Vector2(1605, 480)
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
