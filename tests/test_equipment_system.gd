extends "res://addons/gut/test.gd"

func before_each() -> void:
	GameState.health = GameState.max_health
	GameState.reset_progress_for_tests()

func test_equipment_preset_changes_runtime_damage_and_summary() -> void:
	var base_runtime: Dictionary = GameState.get_spell_runtime("fire_bolt")
	assert_true(GameState.apply_equipment_preset("fire_burst"))
	var boosted_runtime: Dictionary = GameState.get_spell_runtime("fire_bolt")
	assert_gt(int(boosted_runtime.get("damage", 0)), int(base_runtime.get("damage", 0)))
	assert_string_contains(GameState.get_equipment_summary(), "Preset:fire_burst")

func test_equipment_affects_deploy_runtime() -> void:
	assert_true(GameState.apply_equipment_preset("ritual_control"))
	var manager = preload("res://scripts/player/spell_manager.gd").new()
	var player = autofree(preload("res://scripts/player/player.gd").new())
	manager.setup(player)
	var runtime: Dictionary = manager._build_skill_runtime("earth_stone_spire", GameDatabase.get_skill_data("earth_stone_spire"))
	assert_gt(float(runtime.get("duration", 0.0)), 0.8)
	assert_gt(float(runtime.get("size", 0.0)), 80.0)

func test_can_change_individual_equipment_slot() -> void:
	assert_true(GameState.set_equipped_item("weapon", "weapon_tempest_rod"))
	var equipped: Dictionary = GameState.get_equipped_items()
	assert_eq(str(equipped.get("weapon", "")), "weapon_tempest_rod")
	assert_string_contains(GameState.get_equipment_summary(), "Tempest Rod")

func test_equipment_updates_max_mana_and_regen() -> void:
	var base_max_mana := GameState.max_mana
	var base_regen := GameState.mana_regen_per_second
	assert_true(GameState.apply_equipment_preset("fire_burst"))
	assert_gt(GameState.max_mana, base_max_mana)
	assert_gt(GameState.mana_regen_per_second, base_regen)

func test_equipment_damage_reduction_reduces_taken_damage() -> void:
	assert_true(GameState.apply_equipment_preset("fire_burst"))
	var starting_health := GameState.max_health
	GameState.damage(10)
	assert_eq(GameState.health, starting_health - 9)

func test_can_grant_equipment_into_inventory() -> void:
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	var inventory: Array = GameState.get_equipment_inventory()
	assert_eq(inventory.size(), 1)
	assert_eq(str(inventory[0]), "weapon_tempest_rod")
	assert_string_contains(GameState.get_equipment_inventory_summary(), "Tempest Rod")

func test_can_equip_item_from_inventory_and_swap_previous_item_back() -> void:
	assert_true(GameState.set_equipped_item("weapon", "weapon_ember_staff"))
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	assert_true(GameState.equip_inventory_item("weapon", "weapon_tempest_rod"))
	var equipped: Dictionary = GameState.get_equipped_items()
	var inventory: Array = GameState.get_equipment_inventory()
	assert_eq(str(equipped.get("weapon", "")), "weapon_tempest_rod")
	assert_true(inventory.has("weapon_ember_staff"))
	assert_false(inventory.has("weapon_tempest_rod"))

func test_can_unequip_item_to_inventory() -> void:
	assert_true(GameState.set_equipped_item("offhand", "focus_storm_orb"))
	assert_true(GameState.unequip_item_to_inventory("offhand"))
	var equipped: Dictionary = GameState.get_equipped_items()
	var inventory: Array = GameState.get_equipment_inventory()
	assert_eq(str(equipped.get("offhand", "")), "")
	assert_true(inventory.has("focus_storm_orb"))

func test_slot_inventory_summary_filters_by_slot() -> void:
	assert_true(GameState.grant_equipment_item("weapon_tempest_rod"))
	assert_true(GameState.grant_equipment_item("focus_storm_orb"))
	assert_string_contains(GameState.get_equipment_slot_inventory_summary("weapon"), "Tempest Rod")
	assert_false(GameState.get_equipment_slot_inventory_summary("weapon").contains("Storm Orb"))

func test_drop_pool_none_returns_empty() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("none")
	assert_eq(pool.size(), 0, "none profile must have empty drop pool")

func test_drop_pool_unknown_returns_empty() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("unknown_profile")
	assert_eq(pool.size(), 0, "unknown profile must have empty drop pool")

func test_drop_pool_common_only_contains_common_and_uncommon_items() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("common")
	assert_gt(pool.size(), 0, "common pool must not be empty")
	for item_id in pool:
		var item: Dictionary = GameDatabase.get_equipment(str(item_id))
		var rarity := str(item.get("rarity", ""))
		assert_true(rarity == "common" or rarity == "uncommon", "common pool must only contain common or uncommon items, got: " + rarity)

func test_drop_pool_common_contains_common_rarity_items() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("common")
	var has_common := false
	for item_id in pool:
		var item: Dictionary = GameDatabase.get_equipment(str(item_id))
		if str(item.get("rarity", "")) == "common":
			has_common = true
	assert_true(has_common, "common pool must include at least one common-rarity item")

func test_drop_pool_rare_contains_uncommon_and_rare_items() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("rare")
	var has_rare := false
	var has_uncommon := false
	for item_id in pool:
		var item: Dictionary = GameDatabase.get_equipment(str(item_id))
		var rarity := str(item.get("rarity", ""))
		if rarity == "rare":
			has_rare = true
		if rarity == "uncommon":
			has_uncommon = true
	assert_true(has_rare, "rare pool must contain at least one rare item")
	assert_true(has_uncommon, "rare pool must contain at least one uncommon item")

func test_drop_for_none_profile_always_returns_empty() -> void:
	for i in range(10):
		assert_eq(GameDatabase.get_drop_for_profile("none"), "", "none profile must never drop")

func test_drop_pool_elite_contains_both_rarities() -> void:
	var pool: Array = GameDatabase.get_drop_pool_for_profile("elite")
	assert_gt(pool.size(), 0, "elite pool must not be empty")
	var has_rare := false
	for item_id in pool:
		var item: Dictionary = GameDatabase.get_equipment(str(item_id))
		if str(item.get("rarity", "")) == "rare":
			has_rare = true
	assert_true(has_rare, "elite pool must include rare items")
