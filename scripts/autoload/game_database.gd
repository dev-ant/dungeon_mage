extends Node

var spells: Dictionary = {}
var rooms: Array = []
var room_by_id: Dictionary = {}
var skill_catalog: Array = []
var skill_by_id: Dictionary = {}
var buff_combos: Array = []
var buff_combo_by_id: Dictionary = {}
var equipment_catalog: Array = []
var equipment_by_id: Dictionary = {}
var enemy_catalog: Array = []
var enemy_by_id: Dictionary = {}

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
	buff_combo_by_id.clear()
	equipment_by_id.clear()
	enemy_by_id.clear()
	for room in rooms:
		room_by_id[room["id"]] = room
	for skill in skill_catalog:
		skill_by_id[skill["skill_id"]] = skill
	for combo in buff_combos:
		buff_combo_by_id[combo["combo_id"]] = combo
	for item in equipment_catalog:
		equipment_by_id[item["item_id"]] = item
	for enemy in enemy_catalog:
		enemy_by_id[enemy["enemy_id"]] = enemy

func get_spell(spell_id: String) -> Dictionary:
	return spells.get(spell_id, {}).duplicate(true)

func get_room(room_id: String) -> Dictionary:
	return room_by_id.get(room_id, {}).duplicate(true)

func get_skill_data(skill_id: String) -> Dictionary:
	return skill_by_id.get(skill_id, {}).duplicate(true)

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

func get_all_enemies() -> Array:
	return enemy_catalog.duplicate(true)

# Drop profile rules:
# "none"   → never drops
# "common" → 20% chance, pool = "uncommon" rarity items only
# "elite"  → 35% chance, pool = "uncommon" + "rare" items
# "rare"   → 50% chance, pool = all items
const DROP_CHANCE := {"common": 0.20, "elite": 0.35, "rare": 0.50}
const DROP_RARITY_FILTER := {"common": ["common", "uncommon"], "elite": ["common", "uncommon", "rare"], "rare": ["common", "uncommon", "rare", "epic", "legendary"]}

func get_drop_pool_for_profile(profile: String) -> Array[String]:
	var allowed: Array = DROP_RARITY_FILTER.get(profile, [])
	var pool: Array[String] = []
	for item in equipment_catalog:
		if allowed.has(str(item.get("rarity", ""))):
			pool.append(str(item.get("item_id", "")))
	return pool

func get_drop_for_profile(profile: String) -> String:
	if profile == "none" or profile == "":
		return ""
	var chance: float = float(DROP_CHANCE.get(profile, 0.0))
	if randf() > chance:
		return ""
	var pool := get_drop_pool_for_profile(profile)
	if pool.is_empty():
		return ""
	return pool[randi() % pool.size()]

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
