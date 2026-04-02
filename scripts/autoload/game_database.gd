extends Node

var spells: Dictionary = {}
var rooms: Array = []
var room_by_id: Dictionary = {}
var skill_catalog: Array = []
var skill_by_id: Dictionary = {}
var skill_alias_to_id: Dictionary = {}
var buff_combos: Array = []
var buff_combo_by_id: Dictionary = {}
var equipment_catalog: Array = []
var equipment_by_id: Dictionary = {}
var enemy_catalog: Array = []
var enemy_by_id: Dictionary = {}
var enemy_validation_errors: Array[String] = []
var room_spawn_validation_errors: Array[String] = []
const REQUIRED_ENEMY_FIELDS := [
	"enemy_id",
	"enemy_type",
	"display_name",
	"enemy_grade",
	"role",
	"max_hp",
	"attack_damage_type",
	"attack_element",
	"attack_period",
	"physical_defense",
	"magic_defense",
	"knockback_resistance",
	"super_armor_enabled",
	"vulnerability_damage_multiplier",
	"drop_profile"
]
const VALID_ENEMY_GRADES := ["normal", "elite", "boss"]
const VALID_DROP_PROFILES := ["none", "common", "elite", "rare", "boss"]
const VALID_ATTACK_DAMAGE_TYPES := ["physical", "magic"]
const VALID_ATTACK_ELEMENTS := [
	"none",
	"fire",
	"water",
	"ice",
	"lightning",
	"wind",
	"earth",
	"plant",
	"dark",
	"holy",
	"arcane"
]
const VALID_ENEMY_ROLES := [
	"agile_sword_fighter",
	"area_control",
	"boss_volley",
	"burst_check",
	"fast_melee_swarm",
	"flying_observer",
	"flying_ranged_harasser",
	"ground_charge_presser",
	"melee_chaser",
	"melee_stunner",
	"mobile_burst",
	"punish_stationary",
	"ranged_harasser",
	"slow_bite_chaser",
	"slow_ranged_denial",
	"telegraph_charger",
	"training_target",
	"trash_tank"
]
const REQUIRED_ELEMENT_RESIST_FIELDS := [
	"fire_resist",
	"water_resist",
	"ice_resist",
	"lightning_resist",
	"wind_resist",
	"earth_resist",
	"plant_resist",
	"dark_resist",
	"holy_resist",
	"arcane_resist"
]
const REQUIRED_STATUS_RESIST_FIELDS := [
	"slow_resist",
	"root_resist",
	"stun_resist",
	"freeze_resist",
	"shock_resist",
	"burn_resist",
	"poison_resist",
	"silence_resist"
]


func _ready() -> void:
	spells = _load_json("res://data/spells.json")
	var room_blob: Dictionary = _load_json("res://data/rooms.json")
	var skill_blob: Dictionary = _load_json("res://data/skills/skills.json")
	var combo_blob: Dictionary = _load_json("res://data/skills/buff_combos.json")
	var equipment_blob: Dictionary = _load_json("res://data/items/equipment.json")
	var enemy_blob: Dictionary = _load_json("res://data/enemies/enemies.json")
	rooms = room_blob.get("rooms", [])
	skill_catalog = skill_blob.get("skills", [])
	buff_combos = combo_blob.get("combos", [])
	equipment_catalog = equipment_blob.get("equipment", [])
	enemy_catalog = enemy_blob.get("enemies", [])
	room_by_id.clear()
	skill_by_id.clear()
	skill_alias_to_id.clear()
	buff_combo_by_id.clear()
	equipment_by_id.clear()
	enemy_by_id.clear()
	enemy_validation_errors.clear()
	room_spawn_validation_errors.clear()
	for room in rooms:
		room_by_id[room["id"]] = room
	for skill in skill_catalog:
		var skill_id := str(skill.get("skill_id", ""))
		if skill_id.is_empty():
			continue
		skill_by_id[skill_id] = skill
		_register_skill_alias(str(skill.get("canonical_skill_id", "")), skill_id)
	for combo in buff_combos:
		buff_combo_by_id[combo["combo_id"]] = combo
	for item in equipment_catalog:
		equipment_by_id[item["item_id"]] = item
	for enemy in enemy_catalog:
		var enemy_id := str(enemy.get("enemy_id", ""))
		_validate_enemy_entry(enemy)
		if enemy_id.is_empty():
			continue
		if enemy_by_id.has(enemy_id):
			_record_enemy_validation_error("Enemy data has duplicate enemy_id '%s'" % enemy_id)
			continue
		enemy_by_id[enemy_id] = enemy
	for room in rooms:
		_validate_room_spawn_entries(room)


func get_spell(spell_id: String) -> Dictionary:
	return spells.get(spell_id, {}).duplicate(true)


func get_room(room_id: String) -> Dictionary:
	return room_by_id.get(room_id, {}).duplicate(true)


func get_skill_data(skill_id: String) -> Dictionary:
	var exact: Dictionary = skill_by_id.get(skill_id, {})
	if not exact.is_empty():
		return exact.duplicate(true)
	var mapped_skill_id := str(skill_alias_to_id.get(skill_id, ""))
	if mapped_skill_id.is_empty():
		return {}
	return skill_by_id.get(mapped_skill_id, {}).duplicate(true)


func _register_skill_alias(alias_id: String, target_skill_id: String) -> void:
	if alias_id.is_empty() or alias_id == target_skill_id:
		return
	if skill_alias_to_id.has(alias_id) and str(skill_alias_to_id[alias_id]) != target_skill_id:
		push_warning(
			"Skill alias '%s' already points to '%s'; ignoring duplicate target '%s'."
			% [alias_id, str(skill_alias_to_id[alias_id]), target_skill_id]
		)
		return
	skill_alias_to_id[alias_id] = target_skill_id


func get_all_skills() -> Array:
	return skill_catalog.duplicate(true)


func get_buff_combo(combo_id: String) -> Dictionary:
	return buff_combo_by_id.get(combo_id, {}).duplicate(true)


func get_all_buff_combos() -> Array:
	return buff_combos.duplicate(true)


func get_equipment(item_id: String) -> Dictionary:
	return equipment_by_id.get(item_id, {}).duplicate(true)


func get_all_equipment() -> Array:
	return equipment_catalog.duplicate(true)


func get_enemy_data(enemy_id: String) -> Dictionary:
	return enemy_by_id.get(enemy_id, {}).duplicate(true)


func get_all_rooms() -> Array:
	return rooms.duplicate(true)


func get_room_spawn_summary(room_id: String) -> Dictionary:
	var room: Dictionary = room_by_id.get(room_id, {})
	if room.is_empty():
		return {}
	return _build_room_spawn_summary(room)


func get_room_spawn_summaries() -> Array[Dictionary]:
	var summaries: Array[Dictionary] = []
	for room in rooms:
		summaries.append(_build_room_spawn_summary(room))
	return summaries


func get_room_spawn_enemy_summaries(room_id: String) -> Array[Dictionary]:
	var room: Dictionary = room_by_id.get(room_id, {})
	if room.is_empty():
		return []
	return _build_room_spawn_enemy_summaries(room)


func get_all_enemies() -> Array:
	return enemy_catalog.duplicate(true)


func get_enemy_spawn_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for enemy in enemy_catalog:
		var super_armor_tags: Array = enemy.get("super_armor_tags", [])
		var drop_profile := str(enemy.get("drop_profile", ""))
		var drop_preview: Dictionary = get_drop_profile_preview(drop_profile)
		entries.append(
			{
				"enemy_id": str(enemy.get("enemy_id", "")),
				"display_name": str(enemy.get("display_name", "")),
				"enemy_grade": str(enemy.get("enemy_grade", "")),
				"role": str(enemy.get("role", "")),
				"max_hp": int(enemy.get("max_hp", 0)),
				"drop_profile": drop_profile,
				"drop_chance": float(drop_preview.get("drop_chance", 0.0)),
				"drop_rarity_preview": drop_preview.get("rarity_preview", []).duplicate(),
				"has_super_armor_hint": bool(enemy.get("super_armor_enabled", false))
				or not super_armor_tags.is_empty()
			}
		)
	return entries


func get_enemy_validation_errors() -> Array[String]:
	return enemy_validation_errors.duplicate()


func has_enemy_validation_errors() -> bool:
	return not enemy_validation_errors.is_empty()


func get_room_spawn_validation_errors() -> Array[String]:
	return room_spawn_validation_errors.duplicate()


func has_room_spawn_validation_errors() -> bool:
	return not room_spawn_validation_errors.is_empty()


# Drop profile rules:
# "none"   → never drops
# "common" → 20% chance, pool = "common" + "uncommon" rarity items
# "elite"  → 35% chance, pool = "common" + "uncommon" + "rare" items
# "rare"   → 50% chance, pool = all items
# "boss"   → 70% chance, pool = "epic" + "legendary" items only
const DROP_CHANCE := {"common": 0.20, "elite": 0.35, "rare": 0.50, "boss": 0.70}
const DROP_RARITY_FILTER := {
	"common": ["common", "uncommon"],
	"elite": ["common", "uncommon", "rare"],
	"rare": ["common", "uncommon", "rare", "epic", "legendary"],
	"boss": ["epic", "legendary"]
}
# Higher weight = more likely to be selected from within the pool.
const DROP_RARITY_WEIGHT := {"common": 10, "uncommon": 6, "rare": 3, "epic": 1, "legendary": 1}


func get_drop_pool_for_profile(profile: String) -> Array[String]:
	var allowed: Array = DROP_RARITY_FILTER.get(profile, [])
	var pool: Array[String] = []
	for item in equipment_catalog:
		if allowed.has(str(item.get("rarity", ""))):
			pool.append(str(item.get("item_id", "")))
	return pool


func get_drop_for_profile(profile: String) -> String:
	return resolve_drop_for_profile(profile, randf(), randi())


func resolve_drop_for_profile(profile: String, chance_roll: float, weighted_roll: int = 0) -> String:
	if profile == "none" or profile == "":
		return ""
	var chance: float = float(DROP_CHANCE.get(profile, 0.0))
	if chance_roll > chance:
		return ""
	return get_weighted_drop_for_profile(profile, weighted_roll)


func get_drop_profile_summary(profile: String) -> Dictionary:
	return _build_drop_profile_summary(profile)


func get_drop_profile_summaries() -> Array[Dictionary]:
	var summaries: Array[Dictionary] = []
	for profile in VALID_DROP_PROFILES:
		summaries.append(_build_drop_profile_summary(profile))
	return summaries


func get_drop_profile_preview(profile: String) -> Dictionary:
	var normalized_profile := profile
	if normalized_profile.is_empty():
		normalized_profile = "none"
	return {
		"profile": normalized_profile,
		"drop_chance": float(DROP_CHANCE.get(normalized_profile, 0.0)),
		"rarity_preview": Array(DROP_RARITY_FILTER.get(normalized_profile, [])).duplicate()
	}


func get_weighted_drop_for_profile(profile: String, weighted_roll: int = -1) -> String:
	var allowed: Array = DROP_RARITY_FILTER.get(profile, [])
	if allowed.is_empty():
		return ""
	# Build weighted list
	var weighted_ids: Array[String] = []
	for item in equipment_catalog:
		var rarity := str(item.get("rarity", ""))
		if not allowed.has(rarity):
			continue
		var weight: int = int(DROP_RARITY_WEIGHT.get(rarity, 1))
		var item_id := str(item.get("item_id", ""))
		for _i in range(weight):
			weighted_ids.append(item_id)
	if weighted_ids.is_empty():
		return ""
	var resolved_roll: int = weighted_roll
	if resolved_roll < 0:
		resolved_roll = randi()
	return weighted_ids[posmod(resolved_roll, weighted_ids.size())]


func _build_drop_profile_summary(profile: String) -> Dictionary:
	var normalized_profile := profile
	if normalized_profile.is_empty():
		normalized_profile = "none"
	var allowed: Array = DROP_RARITY_FILTER.get(normalized_profile, [])
	var rarity_counts: Dictionary = {}
	var weighted_rarity_counts: Dictionary = {}
	var pool_size := 0
	var weighted_pool_size := 0
	for item in equipment_catalog:
		var rarity := str(item.get("rarity", ""))
		if not allowed.has(rarity):
			continue
		pool_size += 1
		rarity_counts[rarity] = int(rarity_counts.get(rarity, 0)) + 1
		var weight: int = int(DROP_RARITY_WEIGHT.get(rarity, 1))
		weighted_rarity_counts[rarity] = int(weighted_rarity_counts.get(rarity, 0)) + weight
		weighted_pool_size += weight
	return {
		"profile": normalized_profile,
		"drop_chance": float(DROP_CHANCE.get(normalized_profile, 0.0)),
		"rarity_preview": Array(allowed).duplicate(),
		"pool_size": pool_size,
		"weighted_pool_size": weighted_pool_size,
		"rarity_counts": rarity_counts.duplicate(true),
		"weighted_rarity_counts": weighted_rarity_counts.duplicate(true)
	}


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Missing data file: %s" % path)
		return {}
	var raw := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON dictionary: %s" % path)
		return {}
	return parsed


func _validate_enemy_entry(enemy: Dictionary) -> void:
	var enemy_id := str(enemy.get("enemy_id", "<unknown>"))
	for field_name in REQUIRED_ENEMY_FIELDS:
		if not enemy.has(field_name):
			_record_enemy_validation_error(
				"Enemy data missing required field '%s' for enemy '%s'"
				% [field_name, enemy_id]
			)
	var enemy_grade := str(enemy.get("enemy_grade", ""))
	if not enemy_grade.is_empty() and not VALID_ENEMY_GRADES.has(enemy_grade):
		_record_enemy_validation_error(
			"Enemy data has invalid enemy_grade '%s' for enemy '%s'" % [enemy_grade, enemy_id]
		)
	var role := str(enemy.get("role", ""))
	if not role.is_empty() and not VALID_ENEMY_ROLES.has(role):
		_record_enemy_validation_error(
			"Enemy data has invalid role '%s' for enemy '%s'" % [role, enemy_id]
		)
	var attack_damage_type := str(enemy.get("attack_damage_type", ""))
	if (
		not attack_damage_type.is_empty()
		and not VALID_ATTACK_DAMAGE_TYPES.has(attack_damage_type)
	):
		_record_enemy_validation_error(
			"Enemy data has invalid attack_damage_type '%s' for enemy '%s'"
			% [attack_damage_type, enemy_id]
		)
	var attack_element := str(enemy.get("attack_element", ""))
	if not attack_element.is_empty() and not VALID_ATTACK_ELEMENTS.has(attack_element):
		_record_enemy_validation_error(
			"Enemy data has invalid attack_element '%s' for enemy '%s'"
			% [attack_element, enemy_id]
		)
	var drop_profile := str(enemy.get("drop_profile", ""))
	if not drop_profile.is_empty() and not VALID_DROP_PROFILES.has(drop_profile):
		_record_enemy_validation_error(
			"Enemy data has invalid drop_profile '%s' for enemy '%s'" % [drop_profile, enemy_id]
		)
	if enemy.has("super_armor_tags"):
		var super_armor_tags = enemy.get("super_armor_tags", [])
		if typeof(super_armor_tags) != TYPE_ARRAY:
			_record_enemy_validation_error(
				"Enemy data has non-array super_armor_tags for enemy '%s'" % enemy_id
			)
		else:
			for tag in super_armor_tags:
				if typeof(tag) != TYPE_STRING:
						_record_enemy_validation_error(
							"Enemy data has non-string super_armor_tag for enemy '%s'" % enemy_id
						)
						break
	for field_name in REQUIRED_ELEMENT_RESIST_FIELDS:
		if not enemy.has(field_name):
			_record_enemy_validation_error(
				"Enemy data missing required element_resist field '%s' for enemy '%s'"
				% [field_name, enemy_id]
			)
	for field_name in REQUIRED_STATUS_RESIST_FIELDS:
		if not enemy.has(field_name):
			_record_enemy_validation_error(
				"Enemy data missing required status_resist field '%s' for enemy '%s'"
				% [field_name, enemy_id]
			)


func _record_enemy_validation_error(message: String) -> void:
	enemy_validation_errors.append(message)
	push_error(message)


func _validate_room_spawn_entries(room: Dictionary) -> void:
	var room_id := str(room.get("id", "<unknown>"))
	for spawn_variant in room.get("spawns", []):
		if typeof(spawn_variant) != TYPE_DICTIONARY:
			_record_room_spawn_validation_error(
				"Room '%s' has a non-dictionary spawn entry" % room_id
			)
			continue
		var spawn: Dictionary = spawn_variant
		var spawn_type := str(spawn.get("type", ""))
		if spawn_type.is_empty():
			_record_room_spawn_validation_error(
				"Room '%s' has a spawn entry without type" % room_id
			)
			continue
		if not enemy_by_id.has(spawn_type):
			_record_room_spawn_validation_error(
				"Room '%s' references unknown enemy spawn type '%s'" % [room_id, spawn_type]
			)


func _record_room_spawn_validation_error(message: String) -> void:
	room_spawn_validation_errors.append(message)
	push_error(message)


func _build_room_spawn_summary(room: Dictionary) -> Dictionary:
	var spawn_type_counts: Dictionary = {}
	for spawn_variant in room.get("spawns", []):
		if typeof(spawn_variant) != TYPE_DICTIONARY:
			continue
		var spawn: Dictionary = spawn_variant
		var spawn_type := str(spawn.get("type", ""))
		if spawn_type.is_empty():
			continue
		spawn_type_counts[spawn_type] = int(spawn_type_counts.get(spawn_type, 0)) + 1
	var has_rest_point := false
	var has_rope := false
	for object_variant in room.get("objects", []):
		if typeof(object_variant) != TYPE_DICTIONARY:
			continue
		var object_data: Dictionary = object_variant
		var object_type := str(object_data.get("type", ""))
		if object_type == "rest":
			has_rest_point = true
		elif object_type == "rope":
			has_rope = true
	return {
		"room_id": str(room.get("id", "")),
		"title": str(room.get("title", "")),
		"width": int(room.get("width", 0)),
		"spawn_count": int(room.get("spawns", []).size()),
		"spawn_type_counts": spawn_type_counts.duplicate(true),
		"has_rest_point": has_rest_point,
		"has_rope": has_rope,
		"has_core": room.has("core_position")
	}


func _build_room_spawn_enemy_summaries(room: Dictionary) -> Array[Dictionary]:
	var spawn_type_counts: Dictionary = {}
	var ordered_spawn_types: Array[String] = []
	for spawn_variant in room.get("spawns", []):
		if typeof(spawn_variant) != TYPE_DICTIONARY:
			continue
		var spawn: Dictionary = spawn_variant
		var spawn_type := str(spawn.get("type", ""))
		if spawn_type.is_empty():
			continue
		if not spawn_type_counts.has(spawn_type):
			ordered_spawn_types.append(spawn_type)
		spawn_type_counts[spawn_type] = int(spawn_type_counts.get(spawn_type, 0)) + 1
	var summaries: Array[Dictionary] = []
	for spawn_type in ordered_spawn_types:
		var enemy: Dictionary = enemy_by_id.get(spawn_type, {})
		if enemy.is_empty():
			continue
		var super_armor_tags: Array = enemy.get("super_armor_tags", [])
		var drop_profile := str(enemy.get("drop_profile", ""))
		var drop_preview: Dictionary = get_drop_profile_preview(drop_profile)
		summaries.append(
			{
				"enemy_id": spawn_type,
				"display_name": str(enemy.get("display_name", "")),
				"enemy_grade": str(enemy.get("enemy_grade", "")),
				"role": str(enemy.get("role", "")),
				"count": int(spawn_type_counts.get(spawn_type, 0)),
				"max_hp": int(enemy.get("max_hp", 0)),
				"drop_profile": drop_profile,
				"drop_chance": float(drop_preview.get("drop_chance", 0.0)),
				"drop_rarity_preview": drop_preview.get("rarity_preview", []).duplicate(),
				"has_super_armor_hint": bool(enemy.get("super_armor_enabled", false))
				or not super_armor_tags.is_empty()
			}
		)
	return summaries
