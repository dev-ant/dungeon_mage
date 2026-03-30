extends "res://addons/gut/test.gd"

const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")

func before_each() -> void:
	GameState.health = GameState.max_health
	GameState.reset_progress_for_tests()

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
	assert_not_null(player.get_state_chart(), "state_chart should be created after debug_setup_state_chart()")

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

func test_cast_hotbar_slot_returns_false_when_dead() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	player.debug_mark_dead()
	assert_false(player.cast_hotbar_slot(0), "dead player cannot cast hotbar slot")

func test_cast_hotbar_slot_returns_false_when_spell_manager_is_null() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	assert_false(player.cast_hotbar_slot(0), "cast_hotbar_slot should return false when spell_manager is null")

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
