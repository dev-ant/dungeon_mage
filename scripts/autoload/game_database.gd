extends Node

var spells: Dictionary = {}
var rooms: Array = []
var room_by_id: Dictionary = {}
var skill_catalog: Array = []
var skill_by_id: Dictionary = {}
var skill_alias_to_id: Dictionary = {}
var runtime_spell_to_skill_id: Dictionary = {}
var skill_to_runtime_spell_id: Dictionary = {}
var skill_to_runtime_spell_ids: Dictionary = {}
var skill_validation_errors: Array[String] = []
var skill_validation_warnings: Array[String] = []
var spell_validation_errors: Array[String] = []
var buff_combos: Array = []
var buff_combo_by_id: Dictionary = {}
var buff_combo_validation_errors: Array[String] = []
var buff_combo_validation_warnings: Array[String] = []
var equipment_catalog: Array = []
var equipment_by_id: Dictionary = {}
var consumable_catalog: Array = []
var consumable_by_id: Dictionary = {}
var other_item_catalog: Array = []
var other_item_by_id: Dictionary = {}
var enemy_catalog: Array = []
var enemy_by_id: Dictionary = {}
var enemy_validation_errors: Array[String] = []
var room_floor_segment_validation_errors: Array[String] = []
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
const VALID_FLOOR_SEGMENT_DECOR_OVERRIDE_VALUES := ["ground", "platform"]
const VALID_FLOOR_SEGMENT_COLLISION_OVERRIDE_VALUES := ["solid", "one_way_platform"]
const FLOOR_SEGMENT_THIN_THRESHOLD := 40.0
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
const VALID_SKILL_TYPES := ["active", "buff", "deploy", "toggle", "passive"]
const VALID_SKILL_SCHOOLS := ["elemental", "white", "black", "arcane"]
const VALID_SKILL_ELEMENTS := [
	"fire",
	"water",
	"ice",
	"lightning",
	"wind",
	"earth",
	"plant",
	"dark",
	"holy",
	"arcane",
	"none"
]
const VALID_RUNTIME_SPELL_SCHOOLS := [
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
const VALID_SKILL_UNLOCK_STATES := ["starter", "story", "boss", "record", "late_game"]
const VALID_SKILL_HIT_SHAPES := ["projectile", "line", "cone", "circle", "aura", "wall"]
const VALID_BUFF_CATEGORIES := ["defense", "offense", "tempo", "ritual", "utility"]
const VALID_STACK_RULE_IDS := [
	"default_diminishing_buff",
	"heavy_diminishing_buff",
	"ritual_single_focus"
]
const VALID_BUFF_COMBO_TYPES := ["sustain", "instant", "trigger", "ritual"]
const VALID_BUFF_COMBO_EFFECT_MODES := ["set", "add", "mul"]
const VALID_BUFF_COMBO_TRIGGER_EVENTS := [
	"on_barrier_break",
	"on_deploy_kill",
	"on_spell_hit",
	"on_combo_end"
]
const VALID_BUFF_COMBO_STACK_KEYS := ["ash"]
const VALID_BUFF_COMBO_APPLY_STATUS_TAGS := ["snare"]
const VALID_BUFF_COMBO_EFFECT_TAGS := [
	"aftercast_cut",
	"ash_stack",
	"cast_speed_up",
	"chain_clear",
	"chain_up",
	"cheap_first_casts",
	"dash_cast",
	"deploy_kill_burst",
	"ending_burst",
	"final_damage_up",
	"fire_dark_finisher",
	"poise_ignore",
	"shield",
	"shockwave",
	"snare"
]
const VALID_SKILL_ROLE_TAGS := [
	"aoe",
	"arcane",
	"aura",
	"auto_strike",
	"bind",
	"boss_burst",
	"burst",
	"burst_window",
	"cast_speed",
	"chain",
	"circle",
	"cleanse",
	"cone",
	"control",
	"curse",
	"dark",
	"defense",
	"deploy",
	"dot",
	"drain",
	"earth",
	"field_control",
	"finisher",
	"fire",
	"fire_dark",
	"fortress",
	"freeze",
	"global",
	"heal",
	"heavy",
	"ice",
	"lightning",
	"launch",
	"line",
	"main_deploy",
	"mastery",
	"melee",
	"mob_clear",
	"mobility",
	"offense",
	"pierce",
	"plant",
	"poke",
	"projectile",
	"pull",
	"push",
	"reflect",
	"resist",
	"ritual",
	"rule_break",
	"single_target",
	"slow",
	"soft_cc",
	"stability",
	"starter",
	"summon",
	"super_armor",
	"tempo",
	"universal",
	"utility",
	"wall",
	"water",
	"wind"
]
const VALID_SKILL_GROWTH_TRACKS := [
	"buff_power",
	"damage",
	"duration",
	"final_multiplier",
	"heal",
	"knockback",
	"milestone",
	"pierce",
	"projectiles",
	"range",
	"targets",
	"threshold_bonuses"
]
const VALID_BUFF_COMBO_TAGS := [
	"arcane",
	"ash",
	"compression",
	"dark",
	"deploy",
	"fire",
	"guard",
	"holy",
	"ice",
	"ignition",
	"lightning",
	"plant",
	"ritual",
	"tempo",
	"time",
	"veil",
	"ward",
	"wind"
]
const RUNTIME_SPELL_REQUIRED_NUMERIC_FIELDS := ["damage", "speed", "range", "cooldown", "size"]
const PROTOTYPE_FLOOR_ROOM_COUNTS := {4: 13, 5: 11, 6: 9, 7: 7, 8: 5, 9: 3, 10: 1}
const PROTOTYPE_FLOOR_ANCHOR_ROOM_IDS := {
	4: "entrance",
	6: "seal_sanctum",
	7: "gate_threshold",
	8: "royal_inner_hall",
	9: "throne_approach",
	10: "inverted_spire"
}
const PROTOTYPE_FLOOR_ANCHOR_SLOTS := {4: 1, 6: 1, 7: 7, 8: 1, 9: 3, 10: 1}
const PROTOTYPE_FLOOR_THEMES := {
	4: "outer_ruins",
	5: "transition_corridor",
	6: "sanctuary_hub",
	7: "gate_threshold",
	8: "inner_keep",
	9: "throne_approach",
	10: "inverted_spire"
}
const PROTOTYPE_FLOOR_BACKGROUNDS := {
	4: "#1b2230",
	5: "#1d1b29",
	6: "#16212a",
	7: "#1a1828",
	8: "#21192a",
	9: "#24151f",
	10: "#120915"
}
const PROTOTYPE_FLOOR_BASE_WIDTHS := {4: 2520, 5: 2760, 6: 2960, 7: 3080, 8: 3220, 9: 3360, 10: 3480}
const PROTOTYPE_FLOOR_ID_PREFIXES := {
	4: "outer",
	5: "transition",
	6: "sanctum",
	7: "gate",
	8: "keep",
	9: "throne",
	10: "spire"
}
const PROTOTYPE_FLOOR_GENERATED_TITLES := {
	4: [
		"외벽 잔해 거리",
		"무너진 주거 골목",
		"감시대 균열로",
		"낙하 신호 통로",
		"절벽 매달림길",
		"뒤집힌 순찰선",
		"무너진 외벽 음영로",
		"감시 계단 파편실",
		"붕괴 물자 보관로",
		"방풍 마당 폐허",
		"외성 잔향 포위로",
		"성터 이행문"
	],
	5: [
		"반파된 검문 회랑",
		"엇갈린 아치 통로",
		"상승 착시 계단홀",
		"구조 신호 편향로",
		"굽은 병참 연결로",
		"전환 감시실",
		"뒤틀린 경비 아치",
		"무너진 행정 통로",
		"낙하 유도 경사층",
		"반복 문간 회랑",
		"성터 전이대"
	],
	6: [
		"봉인 외곽 피난로",
		"결계 보수 회랑",
		"생존자 취사 흔적실",
		"잔존 경계선",
		"폐쇄 shelter 우회로",
		"회복 물자 보관실",
		"피난 인계 통로",
		"내성 접근 전실"
	],
	7: [
		"외성 검문 마당",
		"파손된 수문 회랑",
		"심사 대기열",
		"삼중 차단로",
		"경비 누대 연결부",
		"판결 전실"
	],
	8: [
		"초상 회랑 잔실",
		"버려진 생활동",
		"의식 보조실",
		"왕실 내전 후미"
	],
	9: [
		"알현 전 대기실",
		"왕권 집행 회랑"
	]
}


func _ready() -> void:
	room_by_id.clear()
	skill_by_id.clear()
	skill_alias_to_id.clear()
	runtime_spell_to_skill_id.clear()
	skill_to_runtime_spell_id.clear()
	skill_to_runtime_spell_ids.clear()
	skill_validation_errors.clear()
	skill_validation_warnings.clear()
	spell_validation_errors.clear()
	buff_combo_by_id.clear()
	buff_combo_validation_errors.clear()
	buff_combo_validation_warnings.clear()
	equipment_by_id.clear()
	consumable_by_id.clear()
	other_item_by_id.clear()
	enemy_by_id.clear()
	enemy_validation_errors.clear()
	room_floor_segment_validation_errors.clear()
	room_spawn_validation_errors.clear()
	spells = _load_json("res://data/spells.json")
	var room_blob: Dictionary = _load_json("res://data/rooms.json")
	var combo_blob: Dictionary = _load_json("res://data/skills/buff_combos.json")
	var equipment_blob: Dictionary = _load_json("res://data/items/equipment.json")
	var consumable_blob: Dictionary = _load_json("res://data/items/consumables.json")
	var other_item_blob: Dictionary = _load_json("res://data/items/other_items.json")
	var enemy_blob: Dictionary = _load_json("res://data/enemies/enemies.json")
	skill_catalog = _load_skill_catalog("res://data/skills/skills.json")
	rooms = _expand_prototype_rooms(room_blob.get("rooms", []))
	buff_combos = _extract_buff_combo_entries(combo_blob, "res://data/skills/buff_combos.json")
	equipment_catalog = equipment_blob.get("equipment", [])
	consumable_catalog = consumable_blob.get("consumables", [])
	other_item_catalog = other_item_blob.get("other_items", [])
	enemy_catalog = enemy_blob.get("enemies", [])
	for room in rooms:
		room_by_id[room["id"]] = room
	for skill in skill_catalog:
		var skill_id := str(skill.get("skill_id", ""))
		if skill_id.is_empty():
			continue
		skill_by_id[skill_id] = skill
		_register_skill_alias(str(skill.get("canonical_skill_id", "")), skill_id)
	_build_runtime_spell_skill_mappings()
	_validate_progression_data()
	for combo in buff_combos:
		buff_combo_by_id[combo["combo_id"]] = combo
	for item in equipment_catalog:
		equipment_by_id[item["item_id"]] = item
	for item in consumable_catalog:
		consumable_by_id[item["item_id"]] = item
	for item in other_item_catalog:
		other_item_by_id[item["item_id"]] = item
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
		_validate_room_floor_segments(room)
		_validate_room_spawn_entries(room)


func _expand_prototype_rooms(base_rooms: Array) -> Array:
	var base_room_by_id: Dictionary = {}
	var preserved_rooms: Array = []
	for raw_room in base_rooms:
		if typeof(raw_room) != TYPE_DICTIONARY:
			continue
		var room_data: Dictionary = Dictionary(raw_room).duplicate(true)
		var room_id := str(room_data.get("id", ""))
		if room_id.is_empty():
			continue
		base_room_by_id[room_id] = room_data
	var prototype_rooms := _build_expanded_prototype_rooms(base_room_by_id)
	var prototype_ids: Dictionary = {}
	for prototype_room in prototype_rooms:
		prototype_ids[str(prototype_room.get("id", ""))] = true
	for raw_room in base_rooms:
		if typeof(raw_room) != TYPE_DICTIONARY:
			continue
		var room_data: Dictionary = Dictionary(raw_room).duplicate(true)
		var room_id := str(room_data.get("id", ""))
		if prototype_ids.has(room_id):
			continue
		preserved_rooms.append(room_data)
	var expanded_rooms: Array = []
	expanded_rooms.append_array(prototype_rooms)
	expanded_rooms.append_array(preserved_rooms)
	return expanded_rooms


func _build_expanded_prototype_rooms(base_room_by_id: Dictionary) -> Array:
	var expanded_rooms: Array = []
	var prototype_index := 0
	for floor in [4, 5, 6, 7, 8, 9, 10]:
		var room_count := int(PROTOTYPE_FLOOR_ROOM_COUNTS.get(floor, 0))
		var anchor_room_id := str(PROTOTYPE_FLOOR_ANCHOR_ROOM_IDS.get(floor, ""))
		var anchor_slot := int(PROTOTYPE_FLOOR_ANCHOR_SLOTS.get(floor, -1))
		for slot in range(1, room_count + 1):
			prototype_index += 1
			if anchor_room_id != "" and slot == anchor_slot and base_room_by_id.has(anchor_room_id):
				var anchor_room: Dictionary = Dictionary(base_room_by_id.get(anchor_room_id, {})).duplicate(true)
				expanded_rooms.append(
					_decorate_prototype_anchor_room(anchor_room, floor, slot, room_count, prototype_index)
				)
				continue
			expanded_rooms.append(
				_build_generated_prototype_room(floor, slot, room_count, prototype_index)
			)
	return expanded_rooms


func _decorate_prototype_anchor_room(
	room_data: Dictionary, floor: int, slot: int, room_count: int, prototype_index: int
) -> Dictionary:
	var decorated_room := room_data.duplicate(true)
	decorated_room["prototype_enabled"] = true
	decorated_room["prototype_generated"] = false
	decorated_room["prototype_anchor"] = true
	decorated_room["prototype_floor"] = floor
	decorated_room["prototype_floor_slot"] = slot
	decorated_room["prototype_room_count_on_floor"] = room_count
	decorated_room["prototype_index"] = prototype_index
	decorated_room["prototype_short_label"] = "%d층-%02d" % [floor, slot]
	decorated_room["prototype_role"] = "anchor"
	return decorated_room


func _build_generated_prototype_room(
	floor: int, slot: int, room_count: int, prototype_index: int
) -> Dictionary:
	var room_id := _build_generated_prototype_room_id(floor, slot)
	var title := _build_generated_prototype_title(floor, slot)
	var room_width := (
		int(PROTOTYPE_FLOOR_BASE_WIDTHS.get(floor, 2400))
		+ int(posmod(slot - 1, 3)) * 120
	)
	return {
		"id": room_id,
		"title": title,
		"width": room_width,
		"spawn": [180, 520],
		"background": str(PROTOTYPE_FLOOR_BACKGROUNDS.get(floor, "#1b2230")),
		"theme": str(PROTOTYPE_FLOOR_THEMES.get(floor, "outer_ruins")),
		"prototype_enabled": true,
		"prototype_generated": true,
		"prototype_anchor": false,
		"prototype_floor": floor,
		"prototype_floor_slot": slot,
		"prototype_room_count_on_floor": room_count,
		"prototype_index": prototype_index,
		"prototype_short_label": "%d층-%02d" % [floor, slot],
		"prototype_role": "route",
		"prototype_summary": _build_generated_prototype_summary(floor, title),
		"entry_text": _build_generated_prototype_entry_text(floor, title),
		"floor_segments": _build_generated_prototype_floor_segments(floor, room_width, slot),
		"objects": _build_generated_prototype_objects(floor, room_width, slot, title),
		"spawns": _build_generated_prototype_spawns(floor, room_width, slot)
	}


func _build_generated_prototype_room_id(floor: int, slot: int) -> String:
	return "f%d_%s_%02d" % [floor, str(PROTOTYPE_FLOOR_ID_PREFIXES.get(floor, "route")), slot]


func _build_generated_prototype_title(floor: int, slot: int) -> String:
	var titles: Array = PROTOTYPE_FLOOR_GENERATED_TITLES.get(floor, [])
	if titles.is_empty():
		return "%d층 추가 경로 %02d" % [floor, slot]
	var anchor_slot := int(PROTOTYPE_FLOOR_ANCHOR_SLOTS.get(floor, -1))
	var generated_index := slot - 1
	if anchor_slot > 0 and slot > anchor_slot:
		generated_index -= 1
	if generated_index < 0 or generated_index >= titles.size():
		return "%d층 추가 경로 %02d" % [floor, slot]
	return str(titles[generated_index])


func _build_generated_prototype_summary(floor: int, title: String) -> String:
	match floor:
		4:
			return "4층 외곽 폐허. %s와 가짜 상승 동선, 짧은 포켓 우회로 외성 탈출 감각을 더 깊은 방향으로 비트는 구간." % title
		5:
			return "5층 이행부. %s, 엇갈린 계단, 재합류 pocket으로 위를 약속하면서도 더 아래로 접히는 transition corridor." % title
		6:
			return "6층 refuge belt. %s, ward boundary, shelter-side pocket으로 허브 안도와 잔존 긴장을 함께 유지하는 route room." % title
		7:
			return "7층 gate belt. %s, checkpoint rise, holding pocket으로 심사 압박을 층 전체에 누적하는 threshold route." % title
		8:
			return "8층 inner keep. %s, household residue, side chamber pocket으로 사람이 살던 권력 공간이 비틀리는 route room." % title
		9:
			return "9층 judgment ascent. %s, waiting pocket, decree-facing stair로 옥좌 전 긴장을 길게 끌어올리는 corridor." % title
	return "%d층 확장 prototype room." % floor


func _build_generated_prototype_entry_text(floor: int, title: String) -> String:
	match floor:
		4:
			return "%s의 돌길은 바깥으로 이어지는 척하지만, 무너진 외벽과 짧은 우회 포켓이 다시 더 안쪽 폐허로 걸음을 되감는다." % title
		5:
			return "%s에서는 계단과 문간이 위를 약속하지만, 굽은 회랑은 결국 더 깊은 성터 쪽으로만 재합류한다." % title
		6:
			return "%s에는 잠깐 숨을 돌릴 여지가 있지만, 결계 바깥 공기는 여전히 이 refuge belt가 완전한 안전지대가 아님을 알려 준다." % title
		7:
			return "%s의 바닥선은 계속 심사를 예행연습하듯 좁아졌다 넓어지며, 안쪽으로 갈수록 통과 자격을 따지는 압박만 진해진다." % title
		8:
			return "%s에는 사람이 살던 흔적이 남아 있지만, 생활의 질서는 이미 의식과 복종의 배치로 다시 꺾여 있다." % title
		9:
			return "%s에서는 기다림 자체가 판결처럼 느껴진다. 잠깐 비켜선 pocket조차 결국 옥좌를 향한 긴장으로 다시 되돌아온다." % title
	return "%s이 prototype 확장 경로로 활성화됐다." % title


func _build_generated_prototype_floor_segments(floor: int, room_width: int, slot: int) -> Array:
	match floor:
		4:
			return _build_floor4_generated_segments(room_width, slot)
		5:
			return _build_floor5_generated_segments(room_width, slot)
		6:
			return _build_floor6_generated_segments(room_width, slot)
		7:
			return _build_floor7_generated_segments(room_width, slot)
		8:
			return _build_floor8_generated_segments(room_width, slot)
		9:
			return _build_floor9_generated_segments(room_width, slot)
	return [_make_floor_segment_entry(Vector2(room_width * 0.5, 664), Vector2(room_width, 112))]


func _build_floor4_generated_segments(room_width: int, slot: int) -> Array:
	return [
		_make_floor_segment_entry(Vector2(room_width * 0.5, 664), Vector2(room_width, 112)),
		_make_floor_segment_entry(Vector2(520, 560), Vector2(240, 24)),
		_make_floor_segment_entry(Vector2(980, 500 - int(posmod(slot, 2)) * 18), Vector2(260, 24)),
		_make_floor_segment_entry(Vector2(1480, 432 - int(posmod(slot, 3)) * 14), Vector2(280, 24)),
		_make_floor_segment_entry(
			Vector2(1960 + int(posmod(slot, 2)) * 80, 344),
			Vector2(300, 24)
		),
		_make_floor_segment_entry(Vector2(room_width - 260, 468), Vector2(200, 24)),
		_make_floor_segment_entry(Vector2(room_width - 340, 268), Vector2(180, 24))
	]


func _build_floor5_generated_segments(room_width: int, slot: int) -> Array:
	return [
		_make_floor_segment_entry(Vector2(room_width * 0.5, 664), Vector2(room_width, 112)),
		_make_floor_segment_entry(Vector2(460, 544), Vector2(240, 24)),
		_make_floor_segment_entry(Vector2(920, 476 - int(posmod(slot, 2)) * 18), Vector2(260, 24)),
		_make_floor_segment_entry(
			Vector2(1360, 402 - int(posmod(slot + 1, 2)) * 18),
			Vector2(260, 24)
		),
		_make_floor_segment_entry(Vector2(1800, 324), Vector2(240, 24)),
		_make_floor_segment_entry(Vector2(room_width - 620, 500), Vector2(220, 24)),
		_make_floor_segment_entry(Vector2(room_width - 260, 246), Vector2(200, 24))
	]


func _build_floor6_generated_segments(room_width: int, slot: int) -> Array:
	return [
		_make_floor_segment_entry(Vector2(room_width * 0.5, 664), Vector2(room_width, 112)),
		_make_floor_segment_entry(Vector2(420, 522), Vector2(220, 24)),
		_make_floor_segment_entry(Vector2(980, 454), Vector2(260, 24)),
		_make_floor_segment_entry(Vector2(room_width * 0.5, 584), Vector2(520, 28)),
		_make_floor_segment_entry(Vector2(room_width - 560, 520), Vector2(220, 24)),
		_make_floor_segment_entry(
			Vector2(room_width - 280, 438 - int(posmod(slot, 2)) * 18),
			Vector2(220, 24)
		)
	]


func _build_floor7_generated_segments(room_width: int, slot: int) -> Array:
	return [
		_make_floor_segment_entry(Vector2(room_width * 0.5, 664), Vector2(room_width, 112)),
		_make_floor_segment_entry(Vector2(520, 548), Vector2(240, 24)),
		_make_floor_segment_entry(Vector2(980, 488), Vector2(260, 24)),
		_make_floor_segment_entry(Vector2(1460, 430), Vector2(280, 24)),
		_make_floor_segment_entry(Vector2(1940, 374), Vector2(260, 24)),
		_make_floor_segment_entry(Vector2(room_width - 660, 504), Vector2(220, 24)),
		_make_floor_segment_entry(Vector2(room_width - 280, 312), Vector2(200, 24))
	]


func _build_floor8_generated_segments(room_width: int, slot: int) -> Array:
	return [
		_make_floor_segment_entry(Vector2(room_width * 0.5, 664), Vector2(room_width, 112)),
		_make_floor_segment_entry(Vector2(560, 526), Vector2(220, 24)),
		_make_floor_segment_entry(Vector2(room_width * 0.5, 452), Vector2(300, 24)),
		_make_floor_segment_entry(Vector2(room_width - 560, 520), Vector2(220, 24)),
		_make_floor_segment_entry(
			Vector2(room_width - 280, 372 - int(posmod(slot, 2)) * 18),
			Vector2(220, 24)
		),
		_make_floor_segment_entry(Vector2(300, 398), Vector2(180, 24))
	]


func _build_floor9_generated_segments(room_width: int, slot: int) -> Array:
	return [
		_make_floor_segment_entry(Vector2(room_width * 0.5, 664), Vector2(room_width, 112)),
		_make_floor_segment_entry(Vector2(700, 536), Vector2(240, 24)),
		_make_floor_segment_entry(Vector2(1140, 470), Vector2(260, 24)),
		_make_floor_segment_entry(Vector2(1600, 404), Vector2(260, 24)),
		_make_floor_segment_entry(Vector2(2080, 338), Vector2(240, 24)),
		_make_floor_segment_entry(Vector2(room_width - 620, 502), Vector2(220, 24)),
		_make_floor_segment_entry(Vector2(room_width - 280, 250), Vector2(200, 24))
	]


func _make_floor_segment_entry(
	position_value: Vector2,
	size: Vector2,
	decor_kind: String = "",
	collision_mode: String = ""
) -> Dictionary:
	var segment := {
		"position": [int(position_value.x), int(position_value.y)],
		"size": [int(size.x), int(size.y)]
	}
	var normalized_decor_kind := decor_kind.strip_edges()
	if _should_emit_floor_segment_decor_override(size, normalized_decor_kind):
		segment["decor_kind"] = normalized_decor_kind
	var normalized_collision_mode := collision_mode.strip_edges()
	if _should_emit_floor_segment_collision_override(size, normalized_collision_mode):
		segment["collision_mode"] = normalized_collision_mode
	return segment


func normalize_floor_segment_to_canonical_dictionary(raw_segment) -> Dictionary:
	if typeof(raw_segment) != TYPE_DICTIONARY:
		return {}
	var segment_data: Dictionary = raw_segment
	var position_result := _read_floor_segment_vector2_for_normalization(segment_data, "position")
	var size_result := _read_floor_segment_vector2_for_normalization(segment_data, "size")
	if not bool(position_result.get("valid", false)) or not bool(size_result.get("valid", false)):
		return {}
	var position_value: Vector2 = position_result.get("value", Vector2.ZERO)
	var size_value: Vector2 = size_result.get("value", Vector2.ZERO)
	if size_value.x <= 0.0 or size_value.y <= 0.0:
		return {}
	return _make_floor_segment_entry(
		position_value,
		size_value,
		str(segment_data.get("decor_kind", "")),
		str(segment_data.get("collision_mode", ""))
	)


func normalize_floor_segments_to_canonical(floor_segments: Array) -> Array:
	var canonical_segments: Array = []
	for raw_segment in floor_segments:
		var segment_data := normalize_floor_segment_to_canonical_dictionary(raw_segment)
		if not segment_data.is_empty():
			canonical_segments.append(segment_data)
	return canonical_segments


func _read_floor_segment_vector2_for_normalization(
	segment_data: Dictionary, vector_key: String
) -> Dictionary:
	if not segment_data.has(vector_key):
		return {"valid": false}
	var vector_value = segment_data.get(vector_key, null)
	if typeof(vector_value) != TYPE_ARRAY:
		return {"valid": false}
	var coords: Array = vector_value
	if coords.size() < 2:
		return {"valid": false}
	if not _is_room_floor_segment_numeric(coords[0]) or not _is_room_floor_segment_numeric(coords[1]):
		return {"valid": false}
	return {"valid": true, "value": Vector2(float(coords[0]), float(coords[1]))}


func _should_emit_floor_segment_decor_override(size: Vector2, decor_kind: String) -> bool:
	return (
		not decor_kind.is_empty()
		and VALID_FLOOR_SEGMENT_DECOR_OVERRIDE_VALUES.has(decor_kind)
		and decor_kind != _infer_floor_segment_decor_kind(size)
	)


func _should_emit_floor_segment_collision_override(size: Vector2, collision_mode: String) -> bool:
	return (
		not collision_mode.is_empty()
		and VALID_FLOOR_SEGMENT_COLLISION_OVERRIDE_VALUES.has(collision_mode)
		and collision_mode != _infer_floor_segment_collision_mode(size)
	)


func _infer_floor_segment_decor_kind(size: Vector2) -> String:
	if size.y <= FLOOR_SEGMENT_THIN_THRESHOLD:
		return "platform"
	return "ground"


func _infer_floor_segment_collision_mode(size: Vector2) -> String:
	if size.y <= FLOOR_SEGMENT_THIN_THRESHOLD:
		return "one_way_platform"
	return "solid"


func _build_generated_prototype_objects(floor: int, room_width: int, slot: int, title: String) -> Array:
	var objects: Array = []
	match floor:
		4:
			objects.append(
				_build_generated_echo(
					[780, 520],
					"%s의 표식은 아직도 외벽 균열을 출구처럼 가리키지만, 무너진 바닥 결은 이미 더 안쪽 폐허로만 기울어져 있다." % title,
					"표식은 여전히 바깥을 약속하지만, 발밑의 결은 깊은 쪽으로만 이어진다.",
					"마지막 계약 이후 다시 보면, 이 외벽 유도 자체가 처음부터 안쪽을 향한 선별 장치처럼 읽힌다."
				)
			)
			objects.append(
				_build_generated_echo(
					[room_width - 280, 236],
					"포켓 끝자락의 신호 천 조각은 구조선처럼 보이지만, 접힌 돌길은 그 흔적조차 더 깊은 아래로 되돌려 놓는다.",
					"신호의 방향은 남았지만, 그 약속은 더는 바깥으로 이어지지 않는다.",
					"계약이 밝혀진 뒤에는 이 신호마저 성의 깊은 안쪽으로 사람을 몰아넣던 유도선으로 보인다."
				)
			)
			if posmod(slot, 2) == 0:
				objects.append({"type": "rope", "position": [520, 596], "height": 220.0})
		5:
			objects.append(
				_build_generated_echo(
					[720, 506],
					"%s의 검문 흔적은 윗방향을 가리키지만, 다음 문간은 늘 예상보다 더 아래에서 다시 열린다." % title,
					"검문 동선은 위를 약속하고, 결과만 더 깊은 층을 남긴다.",
					"이제 보면 검문 표식과 구조선 모두가 성의 중심 쪽으로 사람을 접어 넣는 설계였다."
				)
			)
			objects.append(
				_build_generated_echo(
					[int(room_width * 0.5), 386],
					"반복되는 아치의 간격이 미묘하게 어긋나 있다. 같은 회랑을 맴도는 듯하지만 매번 더 안쪽 기울기가 커진다.",
					"같은 아치가 반복될수록 방향 감각은 더 빨리 무너진다.",
					"계약 이후 돌아보면 이 반복 구조는 단순한 회랑이 아니라 의도적인 선택 압박처럼 보인다."
				)
			)
			objects.append(
				_build_generated_echo(
					[room_width - 260, 220],
					"짧은 pocket 끝에 남은 구조 신호는 탈출 지점처럼 보이지만, 벽면 금은 곧장 더 깊은 통로와만 이어진다.",
					"잠깐 비켜선 pocket도 결국 안쪽 흐름으로만 합류한다.",
					"가장 높은 pocket조차 성터 이행부 전체가 이미 아래를 향해 뒤집혀 있었음을 증언한다."
				)
			)
		6:
			objects.append(
				_build_generated_echo(
					[760, 520],
					"%s의 피난 흔적은 잠깐 숨을 돌리게 하지만, 결계 바깥 공기는 이 refuge belt가 끝내 싸움을 밀어 올릴 뿐임을 알려 준다." % title,
					"짧은 안도는 남아 있지만, 이 방도 완전한 안전지대는 아니다.",
					"계약 이후 다시 보면 이 피난 흔적은 누군가가 최후까지 왕의 정의를 거부했다는 작은 증거로 읽힌다."
				)
			)
			objects.append(
				_build_generated_echo(
					[room_width - 300, 418],
					"짧은 측면 pocket에는 물자 인계 흔적이 남아 있다. 살아남기 위한 동선이었지만, 여전히 더 안쪽 방어선으로만 이어졌다.",
					"우회 pocket도 결국 다음 경계선으로만 사람을 보냈다.",
					"결국 이 refuge belt 전체는 최종 계약을 끝까지 거부하며 버티던 마지막 생활선으로 보인다."
				)
			)
		7:
			objects.append(
				_build_generated_echo(
					[980, 468],
					"%s의 바닥선에는 대기열이 한번 끊겼다가 다시 이어진 흔적이 남아 있다. 통과는 이동이 아니라 선별처럼 진행됐다." % title,
					"대기선은 비어 있지만, 심사 압박은 아직도 방 전체에 남아 있다.",
					"최심층을 본 뒤 돌아오면 이 대기선은 계약을 위한 첫 판정선처럼 읽힌다."
				)
			)
			objects.append(
				_build_generated_echo(
					[room_width - 280, 282],
					"짧은 holding pocket에는 통과를 기다리던 발자국이 방향을 잃은 채 겹쳐 있다. 누구도 쉽게 문턱을 넘지 못했다.",
					"pocket에 쌓인 발자국은 아직도 멈춤 자체가 심사였음을 남긴다.",
					"문턱의 pocket까지 심판 구조의 일부였다는 사실이 이제는 더 선명해진다."
				)
			)
		8:
			objects.append(
				_build_generated_echo(
					[820, 498],
					"%s에는 생활 공간의 정리가 남아 있지만, 배치는 이미 사람보다 복종과 의식을 우선하는 쪽으로 틀어져 있다." % title,
					"생활의 질서는 남아 있어도, 그 중심은 더는 사람을 향하지 않는다.",
					"계약을 본 뒤에는 이 생활 흔적마저 지워질 이름을 준비하던 정리선처럼 보인다."
				)
			)
			objects.append(
				_build_generated_echo(
					[room_width - 300, 350],
					"측면 chamber pocket에는 보조 마법식이 끊긴 채 남아 있다. 돕기 위한 술식이었지만, 지금은 누군가를 억누르는 방식으로만 기억된다.",
					"보조 술식은 부서졌지만, 순종을 강요한 감각은 아직 남아 있다.",
					"이 pocket의 남은 결계선도 결국 최종 계약을 떠받치던 예행 구조였음이 드러난다."
				)
			)
		9:
			objects.append(
				_build_generated_echo(
					[940, 520],
					"%s의 대기 흔적은 알현 전 긴장을 남기고 있다. 잠깐 비켜난 자리조차 결국 판결을 기다리는 자세로만 되돌아온다." % title,
					"대기실의 정적은 휴식이 아니라 심판 전의 숨고르기에 가깝다.",
					"계약 이후 돌아보면 이 대기 구조는 옥좌보다 먼저 공포를 배우게 하던 장치로 읽힌다."
				)
			)
			objects.append(
				_build_generated_echo(
					[room_width - 280, 224],
					"짧은 pocket 위쪽에는 집행 문구가 절반만 남아 있다. 누구를 위한 명령이었는지 지워졌지만, 두려움만은 또렷하다.",
					"문구는 끊겼어도, 두려움만은 아직 형태를 유지한다.",
					"이 집행 흔적도 제단이 말하기 전부터 사람을 공포로 정렬하던 일부였다는 사실이 드러난다."
				)
			)
	return objects


func _build_generated_prototype_spawns(floor: int, room_width: int, slot: int) -> Array:
	match floor:
		4:
			return [
				{"type": "mushroom", "position": [680, 600]},
				{"type": "worm", "position": [1040, 600]},
				{"type": "bat", "position": [room_width - 420, 298]}
			]
		5:
			return [
				{"type": "brute", "position": [920, 600]},
				{"type": "ranged", "position": [int(room_width * 0.55), 376]},
				{"type": "bat", "position": [room_width - 420, 244]}
			]
		6:
			var hub_spawns := [
				{"type": "mushroom", "position": [760, 600]},
				{"type": "eyeball", "position": [room_width - 540, 352]}
			]
			if posmod(slot, 3) == 0:
				hub_spawns.append({"type": "brute", "position": [int(room_width * 0.5), 600]})
			return hub_spawns
		7:
			return [
				{"type": "sword", "position": [960, 600]},
				{"type": "ranged", "position": [int(room_width * 0.6), 412]},
				{"type": "brute", "position": [room_width - 520, 600]}
			]
		8:
			return [
				{"type": "eyeball", "position": [780, 338]},
				{"type": "ranged", "position": [int(room_width * 0.58), 600]},
				{"type": "sword", "position": [room_width - 480, 600]}
			]
		9:
			return [
				{"type": "ranged", "position": [980, 520]},
				{"type": "brute", "position": [int(room_width * 0.55), 600]},
				{"type": "bat", "position": [room_width - 420, 236]}
			]
	return []


func _build_generated_echo(
	position_value: Array, text: String, repeat_text: String, covenant_repeat_text: String
) -> Dictionary:
	var echo := {
		"type": "echo",
		"position": position_value.duplicate(),
		"text": text,
		"repeat_text": repeat_text
	}
	if covenant_repeat_text != "":
		echo["repeat_stage_messages"] = [
			{
				"required_flag": "inverted_spire_covenant",
				"text": covenant_repeat_text
			}
		]
	return echo


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


func get_skill_id_for_runtime_spell(spell_id: String) -> String:
	return str(runtime_spell_to_skill_id.get(spell_id, ""))


func get_runtime_spell_id_for_skill(skill_id: String) -> String:
	var resolved_skill_id := _resolve_runtime_mapping_skill_id(skill_id)
	if resolved_skill_id.is_empty():
		var skill_data: Dictionary = get_skill_data(skill_id)
		resolved_skill_id = str(skill_data.get("skill_id", ""))
	return str(skill_to_runtime_spell_id.get(resolved_skill_id, ""))


func get_runtime_spell_ids_for_skill(skill_id: String) -> Array[String]:
	var resolved_skill_id := _resolve_runtime_mapping_skill_id(skill_id)
	if resolved_skill_id.is_empty():
		var skill_data: Dictionary = get_skill_data(skill_id)
		resolved_skill_id = str(skill_data.get("skill_id", ""))
	var raw_spell_ids: Array = skill_to_runtime_spell_ids.get(resolved_skill_id, [])
	var resolved: Array[String] = []
	for raw_spell_id in raw_spell_ids:
		resolved.append(str(raw_spell_id))
	return resolved


func get_runtime_linked_spell_ids() -> Array[String]:
	var spell_ids: Array[String] = []
	for raw_spell_id in runtime_spell_to_skill_id.keys():
		spell_ids.append(str(raw_spell_id))
	spell_ids.sort()
	return spell_ids


func get_runtime_castable_skill_id(skill_id: String) -> String:
	var requested_id := skill_id.strip_edges()
	if requested_id.is_empty():
		return ""
	if spells.has(requested_id):
		return requested_id
	var skill_data: Dictionary = get_skill_data(requested_id)
	if skill_data.is_empty():
		return ""
	var resolved_skill_id := str(skill_data.get("skill_id", requested_id))
	var runtime_spell_id := get_runtime_spell_id_for_skill(resolved_skill_id)
	if runtime_spell_id != "":
		return runtime_spell_id
	var skill_type := str(skill_data.get("skill_type", ""))
	if skill_type in ["buff", "deploy", "toggle"]:
		return resolved_skill_id
	if spells.has(resolved_skill_id):
		return resolved_skill_id
	return ""


func get_runtime_castable_skill_catalog() -> Array[String]:
	var catalog: Array[String] = []
	var seen: Dictionary = {}
	for skill in skill_catalog:
		var skill_id := str(skill.get("skill_id", ""))
		if skill_id.is_empty():
			continue
		var runtime_castable_id := get_runtime_castable_skill_id(skill_id)
		if runtime_castable_id.is_empty() or seen.has(runtime_castable_id):
			continue
		seen[runtime_castable_id] = true
		catalog.append(runtime_castable_id)
	return catalog


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


func _build_runtime_spell_skill_mappings() -> void:
	for skill in skill_catalog:
		var skill_id := str(skill.get("skill_id", ""))
		if skill_id.is_empty():
			continue
		if spells.has(skill_id):
			_register_runtime_spell_skill_link(skill_id, skill_id)
	for raw_spell_id in spells.keys():
		var spell_id := str(raw_spell_id)
		var spell_data: Dictionary = spells.get(spell_id, {})
		var source_skill_id := str(spell_data.get("source_skill_id", ""))
		if source_skill_id.is_empty():
			continue
		_register_runtime_spell_skill_link(source_skill_id, spell_id)


func _register_runtime_spell_skill_link(skill_id: String, spell_id: String) -> void:
	var resolved_skill_id := _resolve_runtime_mapping_skill_id(skill_id)
	if resolved_skill_id.is_empty() or not spells.has(spell_id):
		return
	var existing_skill_id := str(runtime_spell_to_skill_id.get(spell_id, ""))
	if existing_skill_id != "" and existing_skill_id != resolved_skill_id:
		push_warning(
			"Runtime spell '%s' already maps to '%s'; ignoring duplicate target '%s'."
			% [spell_id, existing_skill_id, resolved_skill_id]
		)
		return
	runtime_spell_to_skill_id[spell_id] = resolved_skill_id
	var spell_ids: Array = skill_to_runtime_spell_ids.get(resolved_skill_id, [])
	if not spell_ids.has(spell_id):
		spell_ids.append(spell_id)
		skill_to_runtime_spell_ids[resolved_skill_id] = spell_ids
	if not skill_to_runtime_spell_id.has(resolved_skill_id):
		skill_to_runtime_spell_id[resolved_skill_id] = spell_id


func _resolve_runtime_mapping_skill_id(skill_id: String) -> String:
	var requested_id := skill_id.strip_edges()
	if requested_id.is_empty():
		return ""
	if skill_by_id.has(requested_id):
		return requested_id
	return str(skill_alias_to_id.get(requested_id, ""))


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


func get_consumable_item(item_id: String) -> Dictionary:
	return consumable_by_id.get(item_id, {}).duplicate(true)


func get_all_consumable_items() -> Array:
	return consumable_catalog.duplicate(true)


func get_other_item(item_id: String) -> Dictionary:
	return other_item_by_id.get(item_id, {}).duplicate(true)


func get_all_other_items() -> Array:
	return other_item_catalog.duplicate(true)


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


func get_room_reactive_surface_summary(room_id: String) -> Dictionary:
	var room: Dictionary = room_by_id.get(room_id, {})
	if room.is_empty():
		return {}
	return _build_room_reactive_surface_summary(room)


func get_room_reactive_surface_summaries() -> Array[Dictionary]:
	var summaries: Array[Dictionary] = []
	for room in rooms:
		summaries.append(_build_room_reactive_surface_summary(room))
	return summaries


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


func get_skill_validation_errors() -> Array[String]:
	return skill_validation_errors.duplicate()


func has_skill_validation_errors() -> bool:
	return not skill_validation_errors.is_empty()


func get_valid_buff_categories() -> Array[String]:
	var categories: Array[String] = []
	for buff_category in VALID_BUFF_CATEGORIES:
		categories.append(str(buff_category))
	return categories


func get_valid_stack_rule_ids() -> Array[String]:
	var ids: Array[String] = []
	for stack_rule_id in VALID_STACK_RULE_IDS:
		ids.append(str(stack_rule_id))
	return ids


func get_valid_buff_combo_stack_keys() -> Array[String]:
	var stack_keys: Array[String] = []
	for stack_key in VALID_BUFF_COMBO_STACK_KEYS:
		stack_keys.append(str(stack_key))
	return stack_keys


func get_valid_buff_combo_apply_status_tags() -> Array[String]:
	var status_tags: Array[String] = []
	for status_tag in VALID_BUFF_COMBO_APPLY_STATUS_TAGS:
		status_tags.append(str(status_tag))
	return status_tags


func get_skill_validation_warnings() -> Array[String]:
	return skill_validation_warnings.duplicate()


func has_skill_validation_warnings() -> bool:
	return not skill_validation_warnings.is_empty()


func get_buff_combo_validation_errors() -> Array[String]:
	return buff_combo_validation_errors.duplicate()


func has_buff_combo_validation_errors() -> bool:
	return not buff_combo_validation_errors.is_empty()


func get_buff_combo_validation_warnings() -> Array[String]:
	return buff_combo_validation_warnings.duplicate()


func has_buff_combo_validation_warnings() -> bool:
	return not buff_combo_validation_warnings.is_empty()


func get_spell_validation_errors() -> Array[String]:
	return spell_validation_errors.duplicate()


func has_spell_validation_errors() -> bool:
	return not spell_validation_errors.is_empty()


func get_room_spawn_validation_errors() -> Array[String]:
	return room_spawn_validation_errors.duplicate()


func has_room_spawn_validation_errors() -> bool:
	return not room_spawn_validation_errors.is_empty()


func get_room_floor_segment_validation_errors() -> Array[String]:
	return room_floor_segment_validation_errors.duplicate()


func has_room_floor_segment_validation_errors() -> bool:
	return not room_floor_segment_validation_errors.is_empty()


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


func _load_skill_catalog(path: String) -> Array:
	if not FileAccess.file_exists(path):
		_record_skill_validation_error("Missing skill data file: %s" % path)
		return []
	var raw := FileAccess.get_file_as_string(path)
	return _extract_skill_catalog_entries(JSON.parse_string(raw), path)


func _extract_skill_catalog_entries(parsed: Variant, path: String) -> Array:
	if typeof(parsed) != TYPE_DICTIONARY:
		_record_skill_validation_error(
			"Skill data file '%s' must be a dictionary with array field 'skills'" % path
		)
		return []
	var blob: Dictionary = parsed
	var raw_skills = blob.get("skills", null)
	if typeof(raw_skills) != TYPE_ARRAY:
		_record_skill_validation_error(
			"Skill data file '%s' is missing array field 'skills'" % path
		)
		return []
	return Array(raw_skills).duplicate(true)


func _extract_buff_combo_entries(parsed: Variant, path: String) -> Array:
	if typeof(parsed) != TYPE_DICTIONARY:
		_record_buff_combo_validation_error(
			"Buff combo data file '%s' must be a dictionary with array field 'combos'" % path
		)
		return []
	var blob: Dictionary = parsed
	var raw_combos = blob.get("combos", null)
	if typeof(raw_combos) != TYPE_ARRAY:
		_record_buff_combo_validation_error(
			"Buff combo data file '%s' is missing array field 'combos'" % path
		)
		return []
	return Array(raw_combos).duplicate(true)


func validate_skill_entry(skill_id: String, entry: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var entry_skill_id := str(entry.get("skill_id", ""))
	if entry_skill_id.is_empty():
		_append_validation_error(errors, "Skill data missing required skill_id for row '%s'" % skill_id)
	elif entry_skill_id != skill_id:
		_append_validation_error(
			errors,
			"Skill data row '%s' has mismatched skill_id '%s'" % [skill_id, entry_skill_id]
		)
	var canonical_skill_id = entry.get("canonical_skill_id", null)
	if typeof(canonical_skill_id) != TYPE_STRING or str(canonical_skill_id).strip_edges().is_empty():
		_append_validation_error(
			errors, "Skill data row '%s' has invalid canonical_skill_id" % skill_id
		)
	var display_name = entry.get("display_name", null)
	if typeof(display_name) != TYPE_STRING or str(display_name).strip_edges().is_empty():
		_append_validation_error(errors, "Skill data row '%s' has invalid display_name" % skill_id)
	_validate_required_enum_string_field(
		errors, skill_id, entry, "school", VALID_SKILL_SCHOOLS
	)
	_validate_required_enum_string_field(
		errors, skill_id, entry, "element", VALID_SKILL_ELEMENTS
	)
	var normalized_skill_type := _validate_required_enum_string_field(
		errors, skill_id, entry, "skill_type", VALID_SKILL_TYPES
	)
	_validate_required_string_array_field(errors, skill_id, entry, "role_tags")
	_validate_required_string_array_field(errors, skill_id, entry, "growth_tracks")
	_validate_required_enum_string_field(
		errors, skill_id, entry, "unlock_state", VALID_SKILL_UNLOCK_STATES
	)
	if not _is_numeric_variant(entry.get("max_level", null)):
		_append_validation_error(errors, "Skill data row '%s' is missing numeric max_level" % skill_id)
	if normalized_skill_type == "passive":
		var passive_family = entry.get("passive_family", null)
		if typeof(passive_family) != TYPE_STRING or str(passive_family).strip_edges().is_empty():
			_append_validation_error(
				errors, "Skill data row '%s' is missing passive_family" % skill_id
			)
		if str(passive_family) == "mastery":
			if not _is_numeric_variant(entry.get("final_multiplier_per_level", null)):
				_append_validation_error(
					errors,
					"Skill mastery row '%s' is missing numeric final_multiplier_per_level" % skill_id
				)
			if typeof(entry.get("threshold_bonuses", null)) != TYPE_ARRAY:
				_append_validation_error(
					errors, "Skill mastery row '%s' is missing array threshold_bonuses" % skill_id
				)
	elif normalized_skill_type in ["active", "buff", "deploy", "toggle"]:
		if not _is_numeric_variant(entry.get("mana_cost_base", null)):
			_append_validation_error(
				errors, "Skill runtime row '%s' is missing numeric mana_cost_base" % skill_id
			)
		if not _is_numeric_variant(entry.get("cooldown_base", null)):
			_append_validation_error(
				errors, "Skill runtime row '%s' is missing numeric cooldown_base" % skill_id
			)
		if normalized_skill_type in ["active", "deploy", "toggle"]:
			_validate_required_enum_string_field(
				errors, skill_id, entry, "hit_shape", VALID_SKILL_HIT_SHAPES
			)
		if entry.has("damage_cadence_reference_interval") and not _is_numeric_variant(
			entry.get("damage_cadence_reference_interval", null)
		):
			_append_validation_error(
				errors,
				"Skill runtime row '%s' has non-numeric damage_cadence_reference_interval" % skill_id
			)
		if normalized_skill_type == "buff":
			var normalized_buff_category := _validate_required_enum_string_field(
				errors, skill_id, entry, "buff_category", VALID_BUFF_CATEGORIES
			)
			_validate_required_enum_string_field(
				errors, skill_id, entry, "stack_rule_id", VALID_STACK_RULE_IDS
			)
			_validate_required_string_array_field(errors, skill_id, entry, "combo_tags")
			_validate_buff_secondary_payload_fields(errors, skill_id, entry)
			if not normalized_buff_category.is_empty():
				_validate_required_role_tag_membership(
					errors, skill_id, entry, normalized_buff_category, "buff_category"
				)
		if normalized_skill_type == "active" and typeof(entry.get("damage_formula", null)) != TYPE_DICTIONARY:
			_append_validation_error(
				errors, "Skill active row '%s' is missing dictionary damage_formula" % skill_id
			)
	return errors


func collect_skill_entry_warnings(skill_id: String, entry: Dictionary) -> Array[String]:
	var warnings: Array[String] = []
	_collect_unknown_string_array_member_warnings(
		warnings, skill_id, entry, "role_tags", VALID_SKILL_ROLE_TAGS
	)
	_collect_unknown_string_array_member_warnings(
		warnings, skill_id, entry, "growth_tracks", VALID_SKILL_GROWTH_TRACKS
	)
	if str(entry.get("skill_type", "")) == "buff":
		_collect_unknown_string_array_member_warnings(
			warnings, skill_id, entry, "combo_tags", VALID_BUFF_COMBO_TAGS
		)
	return warnings


func validate_buff_combo_entry(combo_id: String, entry: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var entry_combo_id := str(entry.get("combo_id", ""))
	if entry_combo_id.is_empty():
		_append_validation_error(errors, "Buff combo data missing required combo_id for row '%s'" % combo_id)
	elif entry_combo_id != combo_id:
		_append_validation_error(
			errors, "Buff combo row '%s' has mismatched combo_id '%s'" % [combo_id, entry_combo_id]
		)
	var display_name = entry.get("display_name", null)
	if typeof(display_name) != TYPE_STRING or str(display_name).strip_edges().is_empty():
		_append_validation_error(errors, "Buff combo row '%s' has invalid display_name" % combo_id)
	_validate_required_combo_string_array_field(errors, combo_id, entry, "required_buffs")
	_validate_required_combo_enum_string_field(
		errors, combo_id, entry, "combo_type", VALID_BUFF_COMBO_TYPES
	)
	_validate_required_combo_string_array_field(errors, combo_id, entry, "effect_tags")
	for field_name in ["priority", "internal_cooldown", "active_window"]:
		if not _is_numeric_variant(entry.get(field_name, null)):
			_append_validation_error(
				errors, "Buff combo row '%s' is missing numeric %s" % [combo_id, field_name]
			)
	for field_name in ["applied_effects", "trigger_rules", "penalties"]:
		if typeof(entry.get(field_name, null)) != TYPE_ARRAY:
			_append_validation_error(
				errors, "Buff combo row '%s' has invalid %s; expected array" % [combo_id, field_name]
			)
	_validate_buff_combo_effect_rows(errors, combo_id, entry.get("applied_effects", []))
	_validate_buff_combo_trigger_rule_rows(errors, combo_id, entry.get("trigger_rules", []))
	_validate_buff_combo_trigger_rule_links(errors, combo_id, entry.get("trigger_rules", []))
	_validate_buff_combo_penalty_rows(errors, combo_id, entry.get("penalties", []))
	_validate_required_buff_combo_runtime_payload_fields(errors, combo_id, entry)
	var visual_profile = entry.get("visual_profile", null)
	if typeof(visual_profile) != TYPE_STRING or str(visual_profile).strip_edges().is_empty():
		_append_validation_error(errors, "Buff combo row '%s' has invalid visual_profile" % combo_id)
	var notes = entry.get("notes", null)
	if typeof(notes) != TYPE_STRING or str(notes).strip_edges().is_empty():
		_append_validation_error(errors, "Buff combo row '%s' has invalid notes" % combo_id)
	return errors


func validate_buff_combo_links(combo_id: String, entry: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var raw_required_buffs = entry.get("required_buffs", null)
	if typeof(raw_required_buffs) != TYPE_ARRAY:
		return errors
	var required_buffs: Array = raw_required_buffs
	if required_buffs.is_empty():
		_append_validation_error(errors, "Buff combo row '%s' must include at least one required_buffs entry" % combo_id)
		return errors
	for required_buff_id in required_buffs:
		var buff_id := str(required_buff_id).strip_edges()
		if buff_id.is_empty():
			continue
		if not skill_by_id.has(buff_id):
			_append_validation_error(
				errors, "Buff combo row '%s' references unknown required buff '%s'" % [combo_id, buff_id]
			)
			continue
		var skill_entry: Dictionary = skill_by_id.get(buff_id, {})
		if str(skill_entry.get("skill_type", "")) != "buff":
			_append_validation_error(
				errors, "Buff combo row '%s' required buff '%s' must point to buff skill row" % [combo_id, buff_id]
			)
	return errors


func collect_buff_combo_entry_warnings(combo_id: String, entry: Dictionary) -> Array[String]:
	var warnings: Array[String] = []
	_collect_unknown_buff_combo_string_array_member_warnings(
		warnings, combo_id, entry, "effect_tags", VALID_BUFF_COMBO_EFFECT_TAGS
	)
	_collect_buff_combo_effect_tag_runtime_candidate_warnings(warnings, combo_id, entry)
	_collect_unknown_buff_combo_trigger_rule_string_warnings(
		warnings, combo_id, entry, "apply_status", VALID_BUFF_COMBO_APPLY_STATUS_TAGS
	)
	return warnings


func validate_spell_entry(spell_id: String, entry: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var entry_spell_id := str(entry.get("id", ""))
	if entry_spell_id.is_empty():
		_append_validation_error(errors, "Spell data missing required id for row '%s'" % spell_id)
	elif entry_spell_id != spell_id:
		_append_validation_error(
			errors, "Spell data row '%s' has mismatched id '%s'" % [spell_id, entry_spell_id]
		)
	var name = entry.get("name", null)
	if typeof(name) != TYPE_STRING or str(name).strip_edges().is_empty():
		_append_validation_error(errors, "Spell data row '%s' has invalid name" % spell_id)
	var school = entry.get("school", null)
	if typeof(school) != TYPE_STRING or not VALID_RUNTIME_SPELL_SCHOOLS.has(str(school)):
		_append_validation_error(
			errors, "Spell data row '%s' has invalid school '%s'" % [spell_id, str(school)]
		)
	var color = entry.get("color", null)
	if typeof(color) != TYPE_STRING or str(color).strip_edges().is_empty():
		_append_validation_error(errors, "Spell data row '%s' has invalid color" % spell_id)
	for field_name in RUNTIME_SPELL_REQUIRED_NUMERIC_FIELDS:
		if not _is_numeric_variant(entry.get(field_name, null)):
			_append_validation_error(
				errors,
				"Spell data row '%s' is missing numeric %s" % [spell_id, field_name]
			)
	var source_skill_id = entry.get("source_skill_id", null)
	if source_skill_id != null and (
		typeof(source_skill_id) != TYPE_STRING or str(source_skill_id).strip_edges().is_empty()
	):
		_append_validation_error(
			errors, "Spell data row '%s' has invalid source_skill_id" % spell_id
		)
	if entry.has("damage_type") and not VALID_ATTACK_DAMAGE_TYPES.has(str(entry.get("damage_type", ""))):
		_append_validation_error(
			errors,
			"Spell data row '%s' has invalid damage_type '%s'"
			% [spell_id, str(entry.get("damage_type", ""))]
		)
	if entry.has("multi_hit_count") and not _is_numeric_variant(entry.get("multi_hit_count", null)):
		_append_validation_error(
			errors, "Spell data row '%s' has non-numeric multi_hit_count" % spell_id
		)
	elif int(entry.get("multi_hit_count", 1)) < 1:
		_append_validation_error(
			errors, "Spell data row '%s' must keep multi_hit_count >= 1" % spell_id
		)
	if entry.has("hit_interval") and not _is_numeric_variant(entry.get("hit_interval", null)):
		_append_validation_error(
			errors, "Spell data row '%s' has non-numeric hit_interval" % spell_id
		)
	if entry.has("mana_cost") and not _is_numeric_variant(entry.get("mana_cost", null)):
		_append_validation_error(errors, "Spell data row '%s' has non-numeric mana_cost" % spell_id)
	return errors


func validate_skill_spell_link(
	skill_id: String, entry: Dictionary, spell_lookup: Dictionary = {}
) -> Array[String]:
	var errors: Array[String] = []
	var normalized_spell_lookup := spell_lookup if not spell_lookup.is_empty() else spells
	var skill_type := str(entry.get("skill_type", ""))
	if skill_type == "active":
		var canonical_skill_id := str(entry.get("canonical_skill_id", ""))
		var expects_runtime_spell_link := (
			normalized_spell_lookup.has(skill_id)
			or (
				not canonical_skill_id.is_empty()
				and canonical_skill_id != skill_id
			)
		)
		if not expects_runtime_spell_link:
			return errors
		var runtime_spell_id := _find_runtime_spell_id_for_skill_in_lookup(
			skill_id, entry, normalized_spell_lookup
		)
		if runtime_spell_id.is_empty():
			_append_validation_error(
				errors, "Active skill row '%s' is missing runtime spell link" % skill_id
			)
			return errors
		var spell_entry: Dictionary = normalized_spell_lookup.get(runtime_spell_id, {})
		var spell_school := str(spell_entry.get("school", ""))
		var skill_element := str(entry.get("element", ""))
		if not skill_element.is_empty() and not spell_school.is_empty() and skill_element != spell_school:
			_append_validation_error(
				errors,
				(
					"Active skill row '%s' element '%s' does not match runtime spell '%s' school '%s'"
					% [skill_id, skill_element, runtime_spell_id, spell_school]
				)
			)
		var skill_cooldown := float(entry.get("cooldown_base", 0.0))
		var spell_cooldown := float(spell_entry.get("cooldown", 0.0))
		if not is_equal_approx(skill_cooldown, spell_cooldown):
			_append_validation_error(
				errors,
				(
					"Active skill row '%s' cooldown_base '%s' must mirror primary runtime spell '%s' cooldown '%s'"
					% [skill_id, str(skill_cooldown), runtime_spell_id, str(spell_cooldown)]
				)
			)
	elif skill_type == "passive" and normalized_spell_lookup.has(skill_id):
		_append_validation_error(
			errors, "Passive skill row '%s' must not be treated as runtime spell" % skill_id
		)
	return errors


func validate_spell_skill_link(
	spell_id: String, entry: Dictionary, skill_lookup: Dictionary = {}
) -> Array[String]:
	var errors: Array[String] = []
	var normalized_skill_lookup := skill_lookup if not skill_lookup.is_empty() else skill_by_id
	var spell_school := str(entry.get("school", ""))
	var source_skill_id := str(entry.get("source_skill_id", ""))
	if not source_skill_id.is_empty():
		var linked_skill: Dictionary = get_skill_data(source_skill_id)
		if not normalized_skill_lookup.is_empty() and normalized_skill_lookup.has(source_skill_id):
			linked_skill = Dictionary(normalized_skill_lookup.get(source_skill_id, {})).duplicate(true)
		if linked_skill.is_empty():
			_append_validation_error(
				errors,
				"Spell row '%s' references unknown source_skill_id '%s'" % [spell_id, source_skill_id]
			)
			return errors
		var linked_skill_type := str(linked_skill.get("skill_type", ""))
		if linked_skill_type != "active":
			_append_validation_error(
				errors,
				(
					"Spell row '%s' source_skill_id '%s' must point to active skill row"
					% [spell_id, source_skill_id]
				)
			)
		var linked_element := str(linked_skill.get("element", ""))
		if not linked_element.is_empty() and not spell_school.is_empty() and linked_element != spell_school:
			_append_validation_error(
				errors,
				(
					"Spell row '%s' school '%s' does not match linked skill '%s' element '%s'"
					% [spell_id, spell_school, source_skill_id, linked_element]
				)
			)
	elif normalized_skill_lookup.has(spell_id):
		var direct_skill: Dictionary = normalized_skill_lookup.get(spell_id, {})
		if str(direct_skill.get("skill_type", "")) == "passive":
			_append_validation_error(
				errors, "Spell row '%s' must not resolve directly to passive skill row" % spell_id
			)
	return errors


func _validate_progression_data() -> void:
	for skill in skill_catalog:
		var skill_id := str(skill.get("skill_id", ""))
		if skill_id.is_empty():
			continue
		for message in validate_skill_entry(skill_id, skill):
			_record_skill_validation_error(message)
		for message in collect_skill_entry_warnings(skill_id, skill):
			_record_skill_validation_warning(message)
	for raw_spell_id in spells.keys():
		var spell_id := str(raw_spell_id)
		var spell_entry: Dictionary = spells.get(spell_id, {})
		for message in validate_spell_entry(spell_id, spell_entry):
			_record_spell_validation_error(message)
	for combo in buff_combos:
		var combo_id := str(combo.get("combo_id", ""))
		if combo_id.is_empty():
			continue
		for message in validate_buff_combo_entry(combo_id, combo):
			_record_buff_combo_validation_error(message)
		for message in collect_buff_combo_entry_warnings(combo_id, combo):
			_record_buff_combo_validation_warning(message)
	for skill in skill_catalog:
		var skill_id := str(skill.get("skill_id", ""))
		if skill_id.is_empty():
			continue
		for message in validate_skill_spell_link(skill_id, skill):
			_record_skill_validation_error(message)
	for raw_spell_id in spells.keys():
		var spell_id := str(raw_spell_id)
		var spell_entry: Dictionary = spells.get(spell_id, {})
		for message in validate_spell_skill_link(spell_id, spell_entry):
			_record_spell_validation_error(message)
	for combo in buff_combos:
		var combo_id := str(combo.get("combo_id", ""))
		if combo_id.is_empty():
			continue
		for message in validate_buff_combo_links(combo_id, combo):
			_record_buff_combo_validation_error(message)


func _find_runtime_spell_id_for_skill_in_lookup(
	skill_id: String, entry: Dictionary, spell_lookup: Dictionary
) -> String:
	if spell_lookup.has(skill_id):
		return skill_id
	var canonical_skill_id := str(entry.get("canonical_skill_id", ""))
	if not canonical_skill_id.is_empty() and spell_lookup.has(canonical_skill_id):
		return canonical_skill_id
	for raw_spell_id in spell_lookup.keys():
		var spell_id := str(raw_spell_id)
		var spell_entry: Dictionary = spell_lookup.get(spell_id, {})
		var source_skill_id := str(spell_entry.get("source_skill_id", ""))
		if source_skill_id == skill_id or (
			not canonical_skill_id.is_empty() and source_skill_id == canonical_skill_id
		):
			return spell_id
	return ""


func _record_skill_validation_error(message: String) -> void:
	skill_validation_errors.append(message)
	push_error(message)


func _record_skill_validation_warning(message: String) -> void:
	skill_validation_warnings.append(message)


func _record_buff_combo_validation_error(message: String) -> void:
	buff_combo_validation_errors.append(message)
	push_error(message)


func _record_buff_combo_validation_warning(message: String) -> void:
	buff_combo_validation_warnings.append(message)


func _record_spell_validation_error(message: String) -> void:
	spell_validation_errors.append(message)
	push_error(message)


func _append_validation_error(errors: Array[String], message: String) -> void:
	errors.append(message)


func _validate_required_enum_string_field(
	errors: Array[String],
	row_id: String,
	entry: Dictionary,
	field_name: String,
	valid_values: Array
) -> String:
	var raw_value = entry.get(field_name, null)
	var normalized_value := ""
	var display_value := ""
	if raw_value != null:
		display_value = str(raw_value)
	if typeof(raw_value) == TYPE_STRING:
		normalized_value = str(raw_value).strip_edges()
		display_value = normalized_value
	if normalized_value.is_empty() or not valid_values.has(normalized_value):
		_append_validation_error(
			errors,
			"Skill data row '%s' has invalid %s '%s'" % [row_id, field_name, display_value]
		)
		return ""
	return normalized_value


func _validate_required_string_array_field(
	errors: Array[String], row_id: String, entry: Dictionary, field_name: String
) -> void:
	var raw_value = entry.get(field_name, null)
	if typeof(raw_value) != TYPE_ARRAY:
		_append_validation_error(
			errors,
			"Skill data row '%s' has invalid %s; expected array[string]"
			% [row_id, field_name]
		)
		return
	var values: Array = raw_value
	for index in range(values.size()):
		if typeof(values[index]) != TYPE_STRING or str(values[index]).strip_edges().is_empty():
			_append_validation_error(
				errors,
				"Skill data row '%s' has invalid %s[%d]" % [row_id, field_name, index]
			)
			return


func _validate_required_role_tag_membership(
	errors: Array[String], row_id: String, entry: Dictionary, required_tag: String, source_field: String
) -> void:
	var raw_value = entry.get("role_tags", null)
	if typeof(raw_value) != TYPE_ARRAY:
		return
	var role_tags: Array = raw_value
	for role_tag in role_tags:
		if str(role_tag).strip_edges() == required_tag:
			return
	_append_validation_error(
		errors,
		"Skill data row '%s' must include role_tag '%s' matching %s'" % [row_id, required_tag, source_field]
	)


func _validate_buff_secondary_payload_fields(
	errors: Array[String], skill_id: String, entry: Dictionary
) -> void:
	var effect_lookup := _extract_skill_effect_lookup(errors, skill_id, entry, "buff_effects")
	if effect_lookup.is_empty():
		return
	_validate_required_secondary_payload_effect_bundle(
		errors,
		skill_id,
		effect_lookup,
		"extra_lightning_ping",
		"lightning_ping",
		"lightning_conductive_surge"
	)
	_validate_required_secondary_payload_effect_bundle(
		errors,
		skill_id,
		effect_lookup,
		"ice_reflect_wave",
		"ice_reflect_wave",
		"ice_frostblood_ward"
	)
	if skill_id == "dark_throne_of_ash":
		_validate_required_effect_numeric_value(
			errors,
			skill_id,
			effect_lookup,
			"dark_throne_of_ash",
			"ash_residue_burst"
		)
		_validate_required_effect_mode(
			errors,
			skill_id,
			effect_lookup,
			"dark_throne_of_ash",
			"ash_residue_burst",
			"add"
		)


func _extract_skill_effect_lookup(
	errors: Array[String], row_id: String, entry: Dictionary, field_name: String
) -> Dictionary:
	var raw_rows = entry.get(field_name, null)
	if typeof(raw_rows) != TYPE_ARRAY:
		_append_validation_error(
			errors,
			"Skill data row '%s' has invalid %s; expected array[object]" % [row_id, field_name]
		)
		return {}
	var effect_lookup := {}
	var rows: Array = raw_rows
	for index in range(rows.size()):
		if typeof(rows[index]) != TYPE_DICTIONARY:
			_append_validation_error(
				errors, "Skill data row '%s' has invalid %s[%d]" % [row_id, field_name, index]
			)
			continue
		var effect: Dictionary = rows[index]
		var stat_name := str(effect.get("stat", "")).strip_edges()
		if stat_name.is_empty():
			_append_validation_error(
				errors, "Skill data row '%s' has invalid %s[%d].stat" % [row_id, field_name, index]
			)
			continue
		effect_lookup[stat_name] = effect
	return effect_lookup


func _validate_required_secondary_payload_effect_bundle(
	errors: Array[String],
	skill_id: String,
	effect_lookup: Dictionary,
	trigger_stat: String,
	payload_prefix: String,
	required_skill_id: String
) -> void:
	if skill_id != required_skill_id or not effect_lookup.has(trigger_stat):
		return
	_validate_required_effect_string_value(
		errors, skill_id, effect_lookup, trigger_stat, "%s_effect_id" % payload_prefix
	)
	_validate_required_effect_mode(
		errors, skill_id, effect_lookup, trigger_stat, "%s_effect_id" % payload_prefix, "set"
	)
	_validate_required_effect_numeric_value(
		errors, skill_id, effect_lookup, trigger_stat, "%s_damage_ratio" % payload_prefix
	)
	_validate_required_effect_mode(
		errors, skill_id, effect_lookup, trigger_stat, "%s_damage_ratio" % payload_prefix, "set"
	)
	_validate_required_effect_numeric_value(
		errors, skill_id, effect_lookup, trigger_stat, "%s_radius" % payload_prefix
	)
	_validate_required_effect_mode(
		errors, skill_id, effect_lookup, trigger_stat, "%s_radius" % payload_prefix, "set"
	)
	_validate_required_effect_runtime_school_value(
		errors, skill_id, effect_lookup, trigger_stat, "%s_school" % payload_prefix
	)
	_validate_required_effect_mode(
		errors, skill_id, effect_lookup, trigger_stat, "%s_school" % payload_prefix, "set"
	)
	_validate_required_effect_string_value(
		errors, skill_id, effect_lookup, trigger_stat, "%s_color" % payload_prefix
	)
	_validate_required_effect_mode(
		errors, skill_id, effect_lookup, trigger_stat, "%s_color" % payload_prefix, "set"
	)


func _validate_required_effect_string_value(
	errors: Array[String],
	skill_id: String,
	effect_lookup: Dictionary,
	trigger_stat: String,
	stat_name: String
) -> void:
	var effect := _require_secondary_payload_effect(errors, skill_id, effect_lookup, trigger_stat, stat_name)
	if effect.is_empty():
		return
	var value = effect.get("value", null)
	if typeof(value) != TYPE_STRING or str(value).strip_edges().is_empty():
		_append_validation_error(
			errors, "Skill data row '%s' has invalid buff_effects stat '%s'" % [skill_id, stat_name]
		)


func _validate_required_effect_numeric_value(
	errors: Array[String],
	skill_id: String,
	effect_lookup: Dictionary,
	trigger_stat: String,
	stat_name: String
) -> void:
	var effect := _require_secondary_payload_effect(errors, skill_id, effect_lookup, trigger_stat, stat_name)
	if effect.is_empty():
		return
	if not _is_numeric_variant(effect.get("value", null)):
		_append_validation_error(
			errors, "Skill data row '%s' has invalid buff_effects stat '%s'" % [skill_id, stat_name]
		)


func _validate_required_effect_runtime_school_value(
	errors: Array[String],
	skill_id: String,
	effect_lookup: Dictionary,
	trigger_stat: String,
	stat_name: String
) -> void:
	var effect := _require_secondary_payload_effect(errors, skill_id, effect_lookup, trigger_stat, stat_name)
	if effect.is_empty():
		return
	var school_value = effect.get("value", null)
	if typeof(school_value) != TYPE_STRING or not VALID_RUNTIME_SPELL_SCHOOLS.has(str(school_value).strip_edges()):
		_append_validation_error(
			errors, "Skill data row '%s' has invalid buff_effects stat '%s'" % [skill_id, stat_name]
		)


func _validate_required_effect_mode(
	errors: Array[String],
	skill_id: String,
	effect_lookup: Dictionary,
	trigger_stat: String,
	stat_name: String,
	required_mode: String
) -> void:
	var effect := _require_secondary_payload_effect(errors, skill_id, effect_lookup, trigger_stat, stat_name)
	if effect.is_empty():
		return
	if str(effect.get("mode", "")).strip_edges() != required_mode:
		_append_validation_error(
			errors,
			(
				"Skill data row '%s' buff_effects stat '%s' must use mode '%s'"
				% [skill_id, stat_name, required_mode]
			)
		)


func _require_secondary_payload_effect(
	errors: Array[String],
	skill_id: String,
	effect_lookup: Dictionary,
	trigger_stat: String,
	stat_name: String
) -> Dictionary:
	if not effect_lookup.has(stat_name):
		_append_validation_error(
			errors,
			(
				"Skill data row '%s' is missing buff_effects stat '%s' required by '%s'"
				% [skill_id, stat_name, trigger_stat]
			)
		)
		return {}
	return effect_lookup.get(stat_name, {})


func _validate_required_combo_enum_string_field(
	errors: Array[String],
	row_id: String,
	entry: Dictionary,
	field_name: String,
	valid_values: Array
) -> String:
	var raw_value = entry.get(field_name, null)
	var normalized_value := ""
	var display_value := ""
	if raw_value != null:
		display_value = str(raw_value)
	if typeof(raw_value) == TYPE_STRING:
		normalized_value = str(raw_value).strip_edges()
		display_value = normalized_value
	if normalized_value.is_empty() or not valid_values.has(normalized_value):
		_append_validation_error(
			errors,
			"Buff combo row '%s' has invalid %s '%s'" % [row_id, field_name, display_value]
		)
		return ""
	return normalized_value


func _validate_required_combo_string_array_field(
	errors: Array[String], row_id: String, entry: Dictionary, field_name: String
) -> void:
	var raw_value = entry.get(field_name, null)
	if typeof(raw_value) != TYPE_ARRAY:
		_append_validation_error(
			errors,
			"Buff combo row '%s' has invalid %s; expected array[string]" % [row_id, field_name]
		)
		return
	var values: Array = raw_value
	for index in range(values.size()):
		if typeof(values[index]) != TYPE_STRING or str(values[index]).strip_edges().is_empty():
			_append_validation_error(
				errors,
				"Buff combo row '%s' has invalid %s[%d]" % [row_id, field_name, index]
			)
			return


func _validate_buff_combo_effect_rows(
	errors: Array[String], combo_id: String, raw_rows: Variant
) -> void:
	if typeof(raw_rows) != TYPE_ARRAY:
		return
	var rows: Array = raw_rows
	for index in range(rows.size()):
		var row = rows[index]
		if typeof(row) != TYPE_DICTIONARY:
			_append_validation_error(
				errors, "Buff combo row '%s' has invalid applied_effects[%d]" % [combo_id, index]
			)
			continue
		var effect: Dictionary = row
		var stat := str(effect.get("stat", "")).strip_edges()
		if stat.is_empty():
			_append_validation_error(
				errors, "Buff combo row '%s' has invalid applied_effects[%d].stat" % [combo_id, index]
			)
		var mode := str(effect.get("mode", "")).strip_edges()
		if mode.is_empty() or not VALID_BUFF_COMBO_EFFECT_MODES.has(mode):
			_append_validation_error(
				errors,
				"Buff combo row '%s' has invalid applied_effects[%d].mode '%s'"
				% [combo_id, index, mode]
			)
		if not effect.has("value"):
			_append_validation_error(
				errors, "Buff combo row '%s' is missing applied_effects[%d].value" % [combo_id, index]
			)
			continue
		var value = effect.get("value", null)
		if value == null or (typeof(value) == TYPE_STRING and str(value).strip_edges().is_empty()):
			_append_validation_error(
				errors, "Buff combo row '%s' has invalid applied_effects[%d].value" % [combo_id, index]
			)


func _validate_buff_combo_trigger_rule_rows(
	errors: Array[String], combo_id: String, raw_rows: Variant
) -> void:
	if typeof(raw_rows) != TYPE_ARRAY:
		return
	var rows: Array = raw_rows
	for index in range(rows.size()):
		var row = rows[index]
		if typeof(row) != TYPE_DICTIONARY:
			_append_validation_error(
				errors, "Buff combo row '%s' has invalid trigger_rules[%d]" % [combo_id, index]
			)
			continue
		var rule: Dictionary = row
		var event_name := str(rule.get("event", "")).strip_edges()
		if event_name.is_empty() or not VALID_BUFF_COMBO_TRIGGER_EVENTS.has(event_name):
			_append_validation_error(
				errors,
				"Buff combo row '%s' has invalid trigger_rules[%d].event '%s'"
				% [combo_id, index, event_name]
			)
		if not _is_numeric_variant(rule.get("cooldown", null)):
			_append_validation_error(
				errors, "Buff combo row '%s' is missing numeric trigger_rules[%d].cooldown" % [combo_id, index]
			)
		for string_field in [
			"spawn_effect", "damage_school", "apply_status", "stack_name", "scales_with_stack", "color"
		]:
			if not rule.has(string_field):
				continue
			if typeof(rule.get(string_field, null)) != TYPE_STRING or str(rule.get(string_field, "")).strip_edges().is_empty():
				_append_validation_error(
					errors, "Buff combo row '%s' has invalid trigger_rules[%d].%s" % [combo_id, index, string_field]
				)
		if rule.has("damage_school"):
			var damage_school := str(rule.get("damage_school", "")).strip_edges()
			if not damage_school.is_empty() and not VALID_RUNTIME_SPELL_SCHOOLS.has(damage_school):
				_append_validation_error(
					errors,
					"Buff combo row '%s' has invalid trigger_rules[%d].damage_school '%s'"
					% [combo_id, index, damage_school]
				)
		for numeric_field in ["radius", "max_stacks", "damage", "damage_per_stack", "radius_per_stack"]:
			if not rule.has(numeric_field):
				continue
			if not _is_numeric_variant(rule.get(numeric_field, null)):
				_append_validation_error(
					errors,
					"Buff combo row '%s' has invalid trigger_rules[%d].%s" % [combo_id, index, numeric_field]
				)


func _validate_buff_combo_trigger_rule_links(
	errors: Array[String], combo_id: String, raw_rows: Variant
) -> void:
	if typeof(raw_rows) != TYPE_ARRAY:
		return
	var rows: Array = raw_rows
	var declared_stack_keys: Array[String] = []
	for index in range(rows.size()):
		var row = rows[index]
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var rule: Dictionary = row
		if not rule.has("stack_name"):
			continue
		var stack_name := str(rule.get("stack_name", "")).strip_edges()
		if stack_name.is_empty():
			continue
		if not VALID_BUFF_COMBO_STACK_KEYS.has(stack_name):
			_append_validation_error(
				errors,
				"Buff combo row '%s' has invalid trigger_rules[%d].stack_name '%s'"
				% [combo_id, index, stack_name]
			)
			continue
		if not declared_stack_keys.has(stack_name):
			declared_stack_keys.append(stack_name)
	for index in range(rows.size()):
		var row = rows[index]
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var rule: Dictionary = row
		if not rule.has("scales_with_stack"):
			continue
		var stack_name := str(rule.get("scales_with_stack", "")).strip_edges()
		if stack_name.is_empty():
			continue
		if not VALID_BUFF_COMBO_STACK_KEYS.has(stack_name):
			_append_validation_error(
				errors,
				"Buff combo row '%s' has invalid trigger_rules[%d].scales_with_stack '%s'"
				% [combo_id, index, stack_name]
			)
			continue
		if not declared_stack_keys.has(stack_name):
			_append_validation_error(
				errors,
				(
					"Buff combo row '%s' trigger_rules[%d].scales_with_stack '%s' must reference a declared stack_name in the same combo"
					% [combo_id, index, stack_name]
				)
			)


func _validate_buff_combo_penalty_rows(
	errors: Array[String], combo_id: String, raw_rows: Variant
) -> void:
	if typeof(raw_rows) != TYPE_ARRAY:
		return
	var rows: Array = raw_rows
	for index in range(rows.size()):
		var row = rows[index]
		if typeof(row) != TYPE_DICTIONARY:
			_append_validation_error(
				errors, "Buff combo row '%s' has invalid penalties[%d]" % [combo_id, index]
			)
			continue
		var penalty: Dictionary = row
		var stat := str(penalty.get("stat", "")).strip_edges()
		if stat.is_empty():
			_append_validation_error(
				errors, "Buff combo row '%s' has invalid penalties[%d].stat" % [combo_id, index]
			)
		var mode := str(penalty.get("mode", "")).strip_edges()
		if mode.is_empty() or not VALID_BUFF_COMBO_EFFECT_MODES.has(mode):
			_append_validation_error(
				errors,
				"Buff combo row '%s' has invalid penalties[%d].mode '%s'" % [combo_id, index, mode]
			)
		if not penalty.has("value") or not _is_numeric_variant(penalty.get("value", null)):
			_append_validation_error(
				errors, "Buff combo row '%s' has invalid penalties[%d].value" % [combo_id, index]
			)
		if penalty.has("duration") and not _is_numeric_variant(penalty.get("duration", null)):
			_append_validation_error(
				errors, "Buff combo row '%s' has invalid penalties[%d].duration" % [combo_id, index]
			)


func _validate_required_buff_combo_runtime_payload_fields(
	errors: Array[String], combo_id: String, entry: Dictionary
) -> void:
	var applied_effect_lookup := _extract_combo_effect_lookup(errors, combo_id, entry, "applied_effects")
	var trigger_rule_lookup := _extract_combo_trigger_rule_lookup(errors, combo_id, entry)
	if combo_id == "combo_prismatic_guard":
		_validate_required_combo_effect_positive_value(
			errors, combo_id, applied_effect_lookup, "max_hp_barrier_ratio"
		)
		_validate_required_combo_effect_mode(
			errors, combo_id, applied_effect_lookup, "max_hp_barrier_ratio", "add"
		)
		_validate_required_combo_trigger_rule_string_value(
			errors, combo_id, trigger_rule_lookup, "on_barrier_break", "spawn_effect"
		)
		_validate_required_combo_trigger_rule_numeric_value(
			errors, combo_id, trigger_rule_lookup, "on_barrier_break", "radius"
		)
	elif combo_id == "combo_overclock_circuit":
		_validate_required_combo_effect_numeric_value(
			errors, combo_id, applied_effect_lookup, "lightning_aftercast_multiplier"
		)
		_validate_required_combo_effect_mode(
			errors, combo_id, applied_effect_lookup, "lightning_aftercast_multiplier", "mul"
		)
		_validate_required_combo_effect_positive_count(
			errors, combo_id, applied_effect_lookup, "lightning_chain_bonus"
		)
		_validate_required_combo_effect_mode(
			errors, combo_id, applied_effect_lookup, "lightning_chain_bonus", "add"
		)
		_validate_required_combo_effect_numeric_value(
			errors, combo_id, applied_effect_lookup, "dash_cast_speed_multiplier"
		)
		_validate_required_combo_effect_mode(
			errors, combo_id, applied_effect_lookup, "dash_cast_speed_multiplier", "mul"
		)
	elif combo_id == "combo_time_collapse":
		_validate_required_combo_effect_positive_count(
			errors, combo_id, applied_effect_lookup, "discounted_cast_charges"
		)
		_validate_required_combo_effect_mode(
			errors, combo_id, applied_effect_lookup, "discounted_cast_charges", "set"
		)
	elif combo_id == "combo_ashen_rite":
		_validate_required_combo_effect_string_value(
			errors, combo_id, applied_effect_lookup, "ash_residue_effect_id"
		)
		_validate_required_combo_effect_mode(
			errors, combo_id, applied_effect_lookup, "ash_residue_effect_id", "set"
		)
		_validate_required_combo_effect_numeric_value(
			errors, combo_id, applied_effect_lookup, "ash_residue_interval"
		)
		_validate_required_combo_effect_mode(
			errors, combo_id, applied_effect_lookup, "ash_residue_interval", "set"
		)
		_validate_required_combo_effect_numeric_value(
			errors, combo_id, applied_effect_lookup, "ash_residue_damage"
		)
		_validate_required_combo_effect_mode(
			errors, combo_id, applied_effect_lookup, "ash_residue_damage", "set"
		)
		_validate_required_combo_effect_numeric_value(
			errors, combo_id, applied_effect_lookup, "ash_residue_damage_per_stack"
		)
		_validate_required_combo_effect_mode(
			errors, combo_id, applied_effect_lookup, "ash_residue_damage_per_stack", "set"
		)
		_validate_required_combo_effect_numeric_value(
			errors, combo_id, applied_effect_lookup, "ash_residue_radius"
		)
		_validate_required_combo_effect_mode(
			errors, combo_id, applied_effect_lookup, "ash_residue_radius", "set"
		)
		_validate_required_combo_effect_runtime_school_value(
			errors, combo_id, applied_effect_lookup, "ash_residue_school"
		)
		_validate_required_combo_effect_mode(
			errors, combo_id, applied_effect_lookup, "ash_residue_school", "set"
		)
		_validate_required_combo_effect_string_value(
			errors, combo_id, applied_effect_lookup, "ash_residue_color"
		)
		_validate_required_combo_effect_mode(
			errors, combo_id, applied_effect_lookup, "ash_residue_color", "set"
		)
		_validate_required_combo_trigger_rule_string_value(
			errors, combo_id, trigger_rule_lookup, "on_combo_end", "spawn_effect"
		)
		_validate_required_combo_trigger_rule_runtime_school_value(
			errors, combo_id, trigger_rule_lookup, "on_combo_end", "damage_school"
		)
		_validate_required_combo_trigger_rule_string_value(
			errors, combo_id, trigger_rule_lookup, "on_combo_end", "color"
		)
		for numeric_field in ["damage", "damage_per_stack", "radius", "radius_per_stack"]:
			_validate_required_combo_trigger_rule_numeric_value(
				errors, combo_id, trigger_rule_lookup, "on_combo_end", numeric_field
			)
	elif combo_id == "combo_funeral_bloom":
		_validate_required_combo_trigger_rule_string_value(
			errors, combo_id, trigger_rule_lookup, "on_deploy_kill", "spawn_effect"
		)
		_validate_required_combo_trigger_rule_numeric_value(
			errors, combo_id, trigger_rule_lookup, "on_deploy_kill", "radius"
		)
		_validate_required_combo_trigger_rule_runtime_school_value(
			errors, combo_id, trigger_rule_lookup, "on_deploy_kill", "damage_school"
		)
		_validate_required_combo_trigger_rule_string_value(
			errors, combo_id, trigger_rule_lookup, "on_deploy_kill", "apply_status"
		)
		_validate_required_combo_trigger_rule_string_value(
			errors, combo_id, trigger_rule_lookup, "on_deploy_kill", "color"
		)


func _extract_combo_effect_lookup(
	_errors: Array[String], _combo_id: String, entry: Dictionary, field_name: String
) -> Dictionary:
	var raw_rows = entry.get(field_name, null)
	if typeof(raw_rows) != TYPE_ARRAY:
		return {}
	var effect_lookup := {}
	var rows: Array = raw_rows
	for index in range(rows.size()):
		if typeof(rows[index]) != TYPE_DICTIONARY:
			continue
		var effect: Dictionary = rows[index]
		var stat_name := str(effect.get("stat", "")).strip_edges()
		if stat_name.is_empty():
			continue
		effect_lookup[stat_name] = effect
	return effect_lookup


func _extract_combo_trigger_rule_lookup(_errors: Array[String], _combo_id: String, entry: Dictionary) -> Dictionary:
	var raw_rows = entry.get("trigger_rules", null)
	if typeof(raw_rows) != TYPE_ARRAY:
		return {}
	var trigger_rule_lookup := {}
	var rows: Array = raw_rows
	for index in range(rows.size()):
		if typeof(rows[index]) != TYPE_DICTIONARY:
			continue
		var rule: Dictionary = rows[index]
		var event_name := str(rule.get("event", "")).strip_edges()
		if event_name.is_empty():
			continue
		trigger_rule_lookup[event_name] = rule
	return trigger_rule_lookup


func _validate_required_combo_effect_string_value(
	errors: Array[String], combo_id: String, effect_lookup: Dictionary, stat_name: String
) -> void:
	var effect := _require_combo_effect(errors, combo_id, effect_lookup, stat_name)
	if effect.is_empty():
		return
	var value = effect.get("value", null)
	if typeof(value) != TYPE_STRING or str(value).strip_edges().is_empty():
		_append_validation_error(
			errors, "Buff combo row '%s' has invalid applied_effects stat '%s'" % [combo_id, stat_name]
		)


func _validate_required_combo_effect_numeric_value(
	errors: Array[String], combo_id: String, effect_lookup: Dictionary, stat_name: String
) -> void:
	var effect := _require_combo_effect(errors, combo_id, effect_lookup, stat_name)
	if effect.is_empty():
		return
	if not _is_numeric_variant(effect.get("value", null)):
		_append_validation_error(
			errors, "Buff combo row '%s' has invalid applied_effects stat '%s'" % [combo_id, stat_name]
		)


func _validate_required_combo_effect_positive_count(
	errors: Array[String], combo_id: String, effect_lookup: Dictionary, stat_name: String
) -> void:
	var effect := _require_combo_effect(errors, combo_id, effect_lookup, stat_name)
	if effect.is_empty():
		return
	if not _is_numeric_variant(effect.get("value", null)) or float(effect.get("value", 0.0)) < 1.0:
		_append_validation_error(
			errors, "Buff combo row '%s' has invalid applied_effects stat '%s'" % [combo_id, stat_name]
		)


func _validate_required_combo_effect_positive_value(
	errors: Array[String], combo_id: String, effect_lookup: Dictionary, stat_name: String
) -> void:
	var effect := _require_combo_effect(errors, combo_id, effect_lookup, stat_name)
	if effect.is_empty():
		return
	if not _is_numeric_variant(effect.get("value", null)) or float(effect.get("value", 0.0)) <= 0.0:
		_append_validation_error(
			errors, "Buff combo row '%s' has invalid applied_effects stat '%s'" % [combo_id, stat_name]
		)


func _validate_required_combo_effect_mode(
	errors: Array[String],
	combo_id: String,
	effect_lookup: Dictionary,
	stat_name: String,
	required_mode: String
) -> void:
	var effect := _require_combo_effect(errors, combo_id, effect_lookup, stat_name)
	if effect.is_empty():
		return
	if str(effect.get("mode", "")).strip_edges() != required_mode:
		_append_validation_error(
			errors,
			(
				"Buff combo row '%s' applied_effects stat '%s' must use mode '%s'"
				% [combo_id, stat_name, required_mode]
			)
		)


func _validate_required_combo_effect_runtime_school_value(
	errors: Array[String], combo_id: String, effect_lookup: Dictionary, stat_name: String
) -> void:
	var effect := _require_combo_effect(errors, combo_id, effect_lookup, stat_name)
	if effect.is_empty():
		return
	var school_value = effect.get("value", null)
	if typeof(school_value) != TYPE_STRING or not VALID_RUNTIME_SPELL_SCHOOLS.has(str(school_value).strip_edges()):
		_append_validation_error(
			errors, "Buff combo row '%s' has invalid applied_effects stat '%s'" % [combo_id, stat_name]
		)


func _require_combo_effect(
	errors: Array[String], combo_id: String, effect_lookup: Dictionary, stat_name: String
) -> Dictionary:
	if not effect_lookup.has(stat_name):
		_append_validation_error(
			errors, "Buff combo row '%s' is missing applied_effects stat '%s'" % [combo_id, stat_name]
		)
		return {}
	return effect_lookup.get(stat_name, {})


func _validate_required_combo_trigger_rule_string_value(
	errors: Array[String],
	combo_id: String,
	trigger_rule_lookup: Dictionary,
	event_name: String,
	field_name: String
) -> void:
	var rule := _require_combo_trigger_rule(errors, combo_id, trigger_rule_lookup, event_name)
	if rule.is_empty():
		return
	var value = rule.get(field_name, null)
	if typeof(value) != TYPE_STRING or str(value).strip_edges().is_empty():
		_append_validation_error(
			errors,
			"Buff combo row '%s' has invalid trigger_rules[%s].%s" % [combo_id, event_name, field_name]
		)


func _validate_required_combo_trigger_rule_numeric_value(
	errors: Array[String],
	combo_id: String,
	trigger_rule_lookup: Dictionary,
	event_name: String,
	field_name: String
) -> void:
	var rule := _require_combo_trigger_rule(errors, combo_id, trigger_rule_lookup, event_name)
	if rule.is_empty():
		return
	if not _is_numeric_variant(rule.get(field_name, null)):
		_append_validation_error(
			errors,
			"Buff combo row '%s' has invalid trigger_rules[%s].%s" % [combo_id, event_name, field_name]
		)


func _validate_required_combo_trigger_rule_runtime_school_value(
	errors: Array[String],
	combo_id: String,
	trigger_rule_lookup: Dictionary,
	event_name: String,
	field_name: String
) -> void:
	var rule := _require_combo_trigger_rule(errors, combo_id, trigger_rule_lookup, event_name)
	if rule.is_empty():
		return
	var school_value = rule.get(field_name, null)
	if typeof(school_value) != TYPE_STRING or not VALID_RUNTIME_SPELL_SCHOOLS.has(str(school_value).strip_edges()):
		_append_validation_error(
			errors,
			"Buff combo row '%s' has invalid trigger_rules[%s].%s" % [combo_id, event_name, field_name]
		)


func _require_combo_trigger_rule(
	errors: Array[String], combo_id: String, trigger_rule_lookup: Dictionary, event_name: String
) -> Dictionary:
	if not trigger_rule_lookup.has(event_name):
		_append_validation_error(
			errors, "Buff combo row '%s' is missing trigger_rules event '%s'" % [combo_id, event_name]
		)
		return {}
	var rule: Dictionary = trigger_rule_lookup.get(event_name, {})
	return rule


func _collect_unknown_string_array_member_warnings(
	warnings: Array[String],
	row_id: String,
	entry: Dictionary,
	field_name: String,
	valid_values: Array
) -> void:
	var raw_value = entry.get(field_name, null)
	if typeof(raw_value) != TYPE_ARRAY:
		return
	var values: Array = raw_value
	for index in range(values.size()):
		var tag_value := str(values[index]).strip_edges()
		if tag_value.is_empty() or valid_values.has(tag_value):
			continue
		warnings.append(
			(
				"Skill data row '%s' uses unknown %s '%s'; update the matching catalog if intentional"
				% [row_id, field_name.trim_suffix("s"), tag_value]
			)
		)


func _collect_unknown_buff_combo_string_array_member_warnings(
	warnings: Array[String],
	row_id: String,
	entry: Dictionary,
	field_name: String,
	valid_values: Array
) -> void:
	var raw_value = entry.get(field_name, null)
	if typeof(raw_value) != TYPE_ARRAY:
		return
	var values: Array = raw_value
	for index in range(values.size()):
		var tag_value := str(values[index]).strip_edges()
		if tag_value.is_empty() or valid_values.has(tag_value):
			continue
		warnings.append(
			(
				"Buff combo row '%s' uses unknown %s '%s'; update the matching catalog if intentional"
				% [row_id, field_name.trim_suffix("s"), tag_value]
			)
		)


func _collect_unknown_buff_combo_trigger_rule_string_warnings(
	warnings: Array[String],
	combo_id: String,
	entry: Dictionary,
	field_name: String,
	valid_values: Array
) -> void:
	var raw_rules = entry.get("trigger_rules", null)
	if typeof(raw_rules) != TYPE_ARRAY:
		return
	var rules: Array = raw_rules
	for index in range(rules.size()):
		var raw_rule = rules[index]
		if typeof(raw_rule) != TYPE_DICTIONARY:
			continue
		var rule: Dictionary = raw_rule
		if not rule.has(field_name):
			continue
		var field_value := str(rule.get(field_name, "")).strip_edges()
		if field_value.is_empty() or valid_values.has(field_value):
			continue
		warnings.append(
			(
				"Buff combo row '%s' uses unknown trigger_rules[%d].%s '%s'; update the matching catalog if intentional"
				% [combo_id, index, field_name, field_value]
			)
		)


func _collect_buff_combo_effect_tag_runtime_candidate_warnings(
	warnings: Array[String], combo_id: String, entry: Dictionary
) -> void:
	var effect_lookup := _extract_combo_effect_lookup([], combo_id, entry, "applied_effects")
	var trigger_rule_lookup := _extract_combo_trigger_rule_lookup([], combo_id, entry)
	if _buff_combo_has_effect_tag(entry, "poise_ignore"):
		if not _buff_combo_required_buffs_include(entry, "holy_crystal_aegis"):
			warnings.append(
				(
					"Buff combo row '%s' uses effect_tag 'poise_ignore' without required buff 'holy_crystal_aegis'; keep the runtime source aligned before promotion"
					% combo_id
				)
			)
		elif not _skill_row_has_numeric_buff_effect("holy_crystal_aegis", "super_armor_charges", "add", 1.0):
			warnings.append(
				(
					"Buff combo row '%s' uses effect_tag 'poise_ignore' but runtime source 'holy_crystal_aegis.buff_effects.super_armor_charges' is missing or invalid"
					% combo_id
				)
			)
	if _buff_combo_has_effect_tag(entry, "shield") and not _combo_effect_has_numeric_value(
		effect_lookup, "max_hp_barrier_ratio", "add", 0.0
	):
		warnings.append(
			(
				"Buff combo row '%s' uses effect_tag 'shield' but runtime source 'applied_effects.max_hp_barrier_ratio' is missing or invalid"
				% combo_id
			)
		)
	if _buff_combo_has_effect_tag(entry, "shockwave") and not _combo_trigger_rule_has_runtime_payload(
		trigger_rule_lookup, "on_barrier_break", "spawn_effect", "radius"
	):
		warnings.append(
			(
				"Buff combo row '%s' uses effect_tag 'shockwave' but runtime source 'trigger_rules[on_barrier_break].spawn_effect/radius' is missing or invalid"
				% combo_id
			)
		)


func _buff_combo_has_effect_tag(entry: Dictionary, effect_tag: String) -> bool:
	var raw_tags = entry.get("effect_tags", null)
	if typeof(raw_tags) != TYPE_ARRAY:
		return false
	var tags: Array = raw_tags
	for raw_tag in tags:
		if str(raw_tag).strip_edges() == effect_tag:
			return true
	return false


func _buff_combo_required_buffs_include(entry: Dictionary, required_buff_id: String) -> bool:
	var raw_required_buffs = entry.get("required_buffs", null)
	if typeof(raw_required_buffs) != TYPE_ARRAY:
		return false
	var required_buffs: Array = raw_required_buffs
	for raw_required_buff in required_buffs:
		if str(raw_required_buff).strip_edges() == required_buff_id:
			return true
	return false


func _skill_row_has_numeric_buff_effect(
	skill_id: String, stat_name: String, required_mode: String, minimum_value: float
) -> bool:
	if not skill_by_id.has(skill_id):
		return false
	var skill_entry: Dictionary = skill_by_id.get(skill_id, {})
	var raw_effects = skill_entry.get("buff_effects", null)
	if typeof(raw_effects) != TYPE_ARRAY:
		return false
	var effects: Array = raw_effects
	for raw_effect in effects:
		if typeof(raw_effect) != TYPE_DICTIONARY:
			continue
		var effect: Dictionary = raw_effect
		if str(effect.get("stat", "")).strip_edges() != stat_name:
			continue
		if str(effect.get("mode", "")).strip_edges() != required_mode:
			return false
		if not _is_numeric_variant(effect.get("value", null)):
			return false
		return float(effect.get("value", 0.0)) >= minimum_value
	return false


func _combo_effect_has_numeric_value(
	effect_lookup: Dictionary, stat_name: String, required_mode: String, minimum_value: float
) -> bool:
	if not effect_lookup.has(stat_name):
		return false
	var effect: Dictionary = effect_lookup.get(stat_name, {})
	if str(effect.get("mode", "")).strip_edges() != required_mode:
		return false
	if not _is_numeric_variant(effect.get("value", null)):
		return false
	return float(effect.get("value", 0.0)) > minimum_value


func _combo_trigger_rule_has_runtime_payload(
	trigger_rule_lookup: Dictionary, event_name: String, string_field_name: String, numeric_field_name: String
) -> bool:
	if not trigger_rule_lookup.has(event_name):
		return false
	var trigger_rule: Dictionary = trigger_rule_lookup.get(event_name, {})
	var string_value = trigger_rule.get(string_field_name, null)
	if typeof(string_value) != TYPE_STRING or str(string_value).strip_edges().is_empty():
		return false
	return _is_numeric_variant(trigger_rule.get(numeric_field_name, null))


func _is_numeric_variant(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT]


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


func _validate_room_floor_segments(room: Dictionary) -> void:
	var room_id := str(room.get("id", "<unknown>"))
	_validate_room_floor_segment_format_metadata(room_id, room)
	var floor_segments_value = room.get("floor_segments", [])
	if typeof(floor_segments_value) != TYPE_ARRAY:
		_record_room_floor_segment_validation_error(
			"Room '%s' has non-array floor_segments" % room_id
		)
		return
	var floor_segments: Array = floor_segments_value
	for segment_index in floor_segments.size():
		_validate_room_floor_segment_entry(
			room_id,
			floor_segments[segment_index],
			segment_index
		)


func _validate_room_floor_segment_format_metadata(room_id: String, room: Dictionary) -> void:
	if not room.has("floor_segment_format"):
		return
	var raw_format := str(room.get("floor_segment_format", "")).strip_edges()
	if raw_format.is_empty():
		_record_room_floor_segment_validation_error(
			"Room '%s' must not declare retired floor_segment_format metadata" % room_id
		)
		return
	_record_room_floor_segment_validation_error(
		"Room '%s' must not declare retired floor_segment_format metadata '%s'"
		% [room_id, raw_format]
	)


func _validate_room_floor_segment_entry(room_id: String, raw_segment, segment_index: int) -> void:
	if typeof(raw_segment) != TYPE_DICTIONARY:
		_record_room_floor_segment_validation_error(
			(
				"Room '%s' floor_segments[%d] must use canonical dictionary format "
				+ "(legacy floor segment array is retired)"
			)
			% [room_id, segment_index]
		)
		return
	var segment_data: Dictionary = raw_segment
	if _is_legacy_room_floor_segment_dictionary(segment_data):
		_record_room_floor_segment_validation_error(
			(
				"Room '%s' floor_segments[%d] must use canonical position/size arrays instead of "
				+ "x/y/width/height fallback (legacy floor segment dictionary is retired)"
			)
			% [room_id, segment_index]
		)
		return
	_validate_room_floor_segment_dictionary(room_id, segment_data, segment_index)


func _is_legacy_room_floor_segment_dictionary(segment_data: Dictionary) -> bool:
	if segment_data.has("position") or segment_data.has("size"):
		return false
	return (
		segment_data.has("x")
		or segment_data.has("y")
		or segment_data.has("width")
		or segment_data.has("height")
	)


func _validate_room_floor_segment_dictionary(
	room_id: String,
	segment_data: Dictionary,
	segment_index: int
) -> void:
	var size_result: Dictionary = _read_validated_room_floor_segment_vector2(
		room_id,
		segment_index,
		segment_data,
		"size"
	)
	_read_validated_room_floor_segment_vector2(
		room_id,
		segment_index,
		segment_data,
		"position"
	)
	if bool(size_result.get("valid", false)):
		var size_value: Vector2 = size_result.get("value", Vector2.ZERO)
		if size_value.x <= 0.0 or size_value.y <= 0.0:
			_record_room_floor_segment_validation_error(
				"Room '%s' floor_segments[%d] must have positive width and height"
				% [room_id, segment_index]
			)
	_validate_room_floor_segment_override_value(
		room_id,
		segment_index,
		segment_data,
		"decor_kind",
		VALID_FLOOR_SEGMENT_DECOR_OVERRIDE_VALUES
	)
	_validate_room_floor_segment_override_value(
		room_id,
		segment_index,
		segment_data,
		"collision_mode",
		VALID_FLOOR_SEGMENT_COLLISION_OVERRIDE_VALUES
	)


func _read_validated_room_floor_segment_vector2(
	room_id: String,
	segment_index: int,
	segment_data: Dictionary,
	vector_key: String
) -> Dictionary:
	if segment_data.has(vector_key):
		var vector_value = segment_data.get(vector_key, null)
		if typeof(vector_value) != TYPE_ARRAY:
			_record_room_floor_segment_validation_error(
				"Room '%s' floor_segments[%d] %s must use [x, y] array in canonical format"
				% [room_id, segment_index, vector_key]
			)
			return {"valid": false}
		var coords: Array = vector_value
		if coords.size() < 2:
			_record_room_floor_segment_validation_error(
				"Room '%s' floor_segments[%d] %s array must include at least two values"
				% [room_id, segment_index, vector_key]
			)
			return {"valid": false}
		if (
			not _is_room_floor_segment_numeric(coords[0])
			or not _is_room_floor_segment_numeric(coords[1])
		):
			_record_room_floor_segment_validation_error(
				"Room '%s' floor_segments[%d] %s array must use numeric coordinates"
				% [room_id, segment_index, vector_key]
			)
			return {"valid": false}
		return {"valid": true, "value": Vector2(float(coords[0]), float(coords[1]))}
	else:
		_record_room_floor_segment_validation_error(
			"Room '%s' floor_segments[%d] must define %s array in canonical format"
			% [room_id, segment_index, vector_key]
		)
		return {"valid": false}


func _validate_room_floor_segment_override_value(
	room_id: String,
	segment_index: int,
	segment_data: Dictionary,
	key_name: String,
	valid_values: Array
) -> void:
	if not segment_data.has(key_name):
		return
	var raw_value = segment_data.get(key_name, null)
	if typeof(raw_value) != TYPE_STRING:
		_record_room_floor_segment_validation_error(
			"Room '%s' floor_segments[%d] has non-string %s override"
			% [room_id, segment_index, key_name]
		)
		return
	var value := str(raw_value).strip_edges()
	if not valid_values.has(value):
		_record_room_floor_segment_validation_error(
			"Room '%s' floor_segments[%d] has invalid %s '%s'"
			% [room_id, segment_index, key_name, value]
		)


func _is_room_floor_segment_numeric(value) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


func _record_room_floor_segment_validation_error(message: String) -> void:
	room_floor_segment_validation_errors.append(message)
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


func _build_room_reactive_surface_summary(room: Dictionary) -> Dictionary:
	var board_count := 0
	var echo_count := 0
	var gate_count := 0
	var final_payoff_surface_count := 0
	for object_variant in room.get("objects", []):
		if typeof(object_variant) != TYPE_DICTIONARY:
			continue
		var object_data: Dictionary = object_variant
		var object_type := str(object_data.get("type", ""))
		if object_type == "refuge_notice":
			board_count += 1
			if _object_has_final_covenant_surface(object_data):
				final_payoff_surface_count += 1
		elif object_type == "echo":
			if str(object_data.get("repeat_text", "")) != "" or object_data.has("repeat_stage_messages"):
				echo_count += 1
			if _object_has_final_covenant_surface(object_data):
				final_payoff_surface_count += 1
	var room_id := str(room.get("id", ""))
	if room_id == "inverted_spire":
		gate_count = 1
		final_payoff_surface_count += 1
	var total_reactive_surfaces := board_count + echo_count + gate_count
	var payoff_density := "none"
	if total_reactive_surfaces >= 3:
		payoff_density = "dense"
	elif total_reactive_surfaces == 2:
		payoff_density = "medium"
	elif total_reactive_surfaces == 1:
		payoff_density = "light"
	return {
		"room_id": room_id,
		"title": str(room.get("title", "")),
		"board_count": board_count,
		"echo_count": echo_count,
		"gate_count": gate_count,
		"total_reactive_surfaces": total_reactive_surfaces,
		"payoff_density": payoff_density,
		"final_payoff_surface_count": final_payoff_surface_count
	}


func _object_has_final_covenant_surface(object_data: Dictionary) -> bool:
	for field_name in ["stage_messages", "repeat_stage_messages"]:
		for raw_stage in object_data.get(field_name, []):
			if typeof(raw_stage) != TYPE_DICTIONARY:
				continue
			var stage_data: Dictionary = raw_stage
			if str(stage_data.get("required_flag", "")) == "inverted_spire_covenant":
				return true
	return false
