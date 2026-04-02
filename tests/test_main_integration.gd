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
	GameState.equipment_inventory.clear()


func _spawn_main_scene() -> Node2D:
	var main: Node2D = autofree(MAIN_SCENE.instantiate())
	add_child_autofree(main)
	await _settle_frames(3)
	return main


func _settle_frames(frame_count: int = 1) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


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
		GameState.equipment_inventory.size(),
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
	assert_eq(
		main.event_camera.priority,
		40,
		"Ash detonation combo effects must temporarily raise the event camera priority"
	)
