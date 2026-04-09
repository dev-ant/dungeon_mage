extends Node

const SAVE_PATH := "user://savegame.json"
const SCHOOL_ORDER := [
	"fire", "ice", "lightning", "wind", "water", "plant", "earth", "holy", "dark", "arcane"
]
const RESONANCE_MILESTONES := {
	5: "%s 공명이 선명해집니다. 패턴이 서서히 자리를 잡기 시작합니다.",
	15: "깊은 %s 공명. 마법식에 결정 같은 예리함이 깃듭니다.",
	30: "정점의 %s 공명. 미궁이 당신의 시전 패턴에 맞춰 뒤틀립니다."
}
const BASE_MAX_HEALTH := 100
const BASE_MAX_MANA := 180.0
const BASE_MANA_REGEN_PER_SECOND := 14.0
const VISIBLE_HOTBAR_SLOT_COUNT := 10
const LEGACY_HOTBAR_TAIL_SAVE_KEY := "legacy_spell_hotbar_tail"
const VISIBLE_HOTBAR_SHORTCUT_SAVE_KEY := "visible_hotbar_shortcuts"
const ACTION_HOTKEY_REGISTRY_SAVE_KEY := "action_hotkey_registry"
const DEFAULT_VISIBLE_HOTBAR_KEYCODES := {
	"spell_fire": KEY_1,
	"spell_ice": KEY_2,
	"spell_lightning": KEY_3,
	"spell_water": KEY_4,
	"spell_wind": KEY_5,
	"spell_plant": KEY_6,
	"spell_earth": KEY_7,
	"spell_holy": KEY_8,
	"spell_dark": KEY_9,
	"spell_arcane": KEY_0
}
const DEFAULT_ACTION_HOTKEY_REGISTRY := [
	{"action": "buff_aegis", "skill_id": "holy_crystal_aegis", "label": "V", "keycode": KEY_V},
	{"action": "buff_tempo", "skill_id": "wind_tempest_drive", "label": "A", "keycode": KEY_A},
	{
		"action": "buff_surge",
		"skill_id": "lightning_conductive_surge",
		"label": "S",
		"keycode": KEY_S
	},
	{
		"action": "buff_compression",
		"skill_id": "arcane_astral_compression",
		"label": "D",
		"keycode": KEY_D
	},
	{
		"action": "buff_hourglass",
		"skill_id": "arcane_world_hourglass",
		"label": "F",
		"keycode": KEY_F
	},
	{"action": "buff_pact", "skill_id": "dark_grave_pact", "label": "SHIFT", "keycode": KEY_SHIFT},
	{"action": "buff_throne", "skill_id": "dark_throne_of_ash", "label": "CTRL", "keycode": KEY_CTRL},
	{
		"action": "buff_overflow",
		"skill_id": "plant_verdant_overflow",
		"label": "ALT",
		"keycode": KEY_ALT
	}
]
const SOUL_DOMINION_DAMAGE_TAKEN_MULT := 1.35
const SOUL_DOMINION_AFTERSHOCK_DURATION := 5.0
const SOUL_DOMINION_AFTERSHOCK_DAMAGE_MULT := 1.2
const OVERCLOCK_CIRCUIT_WINDOW_DURATION := 1.0
const OVERCLOCK_CIRCUIT_AFTERCAST_MULT := 0.88
const OVERCLOCK_CIRCUIT_CHAIN_BONUS := 1
const OVERCLOCK_CIRCUIT_SPEED_MULT := 1.18
const DEFAULT_SPELL_HOTBAR := [
	{"action": "spell_fire", "skill_id": "fire_bolt", "label": "1"},
	{"action": "spell_ice", "skill_id": "ice_frost_needle", "label": "2"},
	{"action": "spell_lightning", "skill_id": "volt_spear", "label": "3"},
	{"action": "spell_water", "skill_id": "water_aqua_bullet", "label": "4"},
	{"action": "spell_wind", "skill_id": "wind_gale_cutter", "label": "5"},
	{"action": "spell_plant", "skill_id": "plant_vine_snare", "label": "6"},
	{"action": "spell_earth", "skill_id": "earth_tremor", "label": "7"},
	{"action": "spell_holy", "skill_id": "holy_radiant_burst", "label": "8"},
	{"action": "spell_dark", "skill_id": "dark_void_bolt", "label": "9"},
	{"action": "spell_arcane", "skill_id": "arcane_force_pulse", "label": "0"},
	{"action": "buff_guard", "skill_id": "holy_mana_veil", "label": "Z"},
	{"action": "buff_power", "skill_id": "fire_pyre_heart", "label": "X"},
	{"action": "buff_ward", "skill_id": "ice_frostblood_ward", "label": "C"}
]
const HOTBAR_PRESET_IDS := [
	"default", "ritual", "overclock", "deploy_lab", "ashen_rite", "apex_toggles", "funeral_bloom"
]
const EQUIPMENT_INVENTORY_SLOT_COUNT := 20
const STACKABLE_INVENTORY_SLOT_COUNT := 20
const EQUIPMENT_SLOT_SORT_ORDER := {
	"weapon": 0,
	"offhand": 1,
	"head": 2,
	"body": 3,
	"legs": 4,
	"accessory_1": 5,
	"accessory_2": 6
}
const EQUIPMENT_RARITY_SORT_ORDER := {"common": 0, "uncommon": 1, "rare": 2, "epic": 3, "legendary": 4}
const HOTBAR_PRESET_DEFINITIONS := {
	"default": {
		"label": "기본",
		"slots": [
			"fire_bolt",
			"frost_nova",
			"volt_spear",
			"holy_mana_veil",
			"fire_pyre_heart",
			"ice_frostblood_ward"
		]
	},
	"ritual": {
		"label": "의식",
		"slots": [
			"earth_stone_spire",
			"dark_grave_echo",
			"volt_spear",
			"holy_mana_veil",
			"holy_crystal_aegis",
			"arcane_world_hourglass"
		]
	},
	"overclock": {
		"label": "오버클럭",
		"slots": [
			"volt_spear",
			"earth_stone_spire",
			"dark_grave_echo",
			"wind_tempest_drive",
			"lightning_conductive_surge",
			"fire_pyre_heart"
		]
	},
	"deploy_lab": {
		"label": "설치술",
		"slots": [
			"earth_stone_spire",
			"dark_grave_echo",
			"fire_inferno_sigil",
			"holy_mana_veil",
			"wind_tempest_drive",
			"arcane_world_hourglass"
		]
	},
	"ashen_rite": {
		"label": "재의 의식",
		"slots": [
			"fire_bolt",
			"volt_spear",
			"dark_grave_echo",
			"dark_grave_pact",
			"arcane_world_hourglass",
			"dark_throne_of_ash"
		]
	},
	"apex_toggles": {
		"label": "극점 토글",
		"slots": [
			"ice_glacial_dominion",
			"lightning_tempest_crown",
			"dark_soul_dominion",
			"holy_crystal_aegis",
			"arcane_astral_compression",
			"arcane_world_hourglass"
		]
	},
	"funeral_bloom": {
		"label": "장송 개화",
		"slots": [
			"earth_stone_spire",
			"dark_grave_echo",
			"fire_bolt",
			"dark_grave_pact",
			"plant_verdant_overflow",
			"holy_mana_veil"
		]
	}
}
const DEFAULT_EQUIPMENT_PRESET := {
	"weapon": "",
	"offhand": "",
	"head": "",
	"body": "",
	"legs": "",
	"accessory_1": "",
	"accessory_2": ""
}
const EQUIPMENT_PRESET_IDS := [
	"fire_burst",
	"ritual_control",
	"storm_tempo",
	"earth_deploy",
	"wind_tempo",
	"holy_guard",
	"sanctum_sustain",
	"dark_shadow",
	"arcane_pulse"
]
const ADMIN_EQUIPMENT_PRESET_IDS := ["fire_burst", "ritual_control", "storm_tempo"]
const EQUIPMENT_PRESET_LABELS := {
	"fire_burst": "화염 폭딜",
	"ritual_control": "의식 제어",
	"storm_tempo": "폭풍 템포",
	"earth_deploy": "대지 설치",
	"wind_tempo": "바람 템포",
	"holy_guard": "성역 수호",
	"sanctum_sustain": "성소 유지",
	"dark_shadow": "암흑 그림자",
	"arcane_pulse": "아케인 파동"
}
const EQUIPMENT_PRESETS := {
	"fire_burst":
	{
		"weapon": "weapon_ember_staff",
		"offhand": "focus_storm_orb",
		"head": "helm_ritual_circlet",
		"body": "armor_mage_coat",
		"legs": "greaves_strider_boots",
		"accessory_1": "ring_earth_seed",
		"accessory_2": "ring_grave_whisper"
	},
	"ritual_control":
	{
		"weapon": "weapon_ember_staff",
		"offhand": "focus_storm_orb",
		"head": "helm_ritual_circlet",
		"body": "armor_mage_coat",
		"legs": "greaves_strider_boots",
		"accessory_1": "ring_grave_whisper",
		"accessory_2": "ring_earth_seed"
	},
	"storm_tempo":
	{
		"weapon": "weapon_ember_staff",
		"offhand": "focus_storm_orb",
		"head": "helm_ritual_circlet",
		"body": "armor_mage_coat",
		"legs": "greaves_strider_boots",
		"accessory_1": "ring_earth_seed",
		"accessory_2": "ring_grave_whisper"
	},
	"earth_deploy":
	{
		"weapon": "weapon_ember_staff",
		"offhand": "focus_storm_orb",
		"head": "helm_ritual_circlet",
		"body": "armor_mage_coat",
		"legs": "greaves_earthen_stride",
		"accessory_1": "ring_earth_seed",
		"accessory_2": "ring_verdant_coil"
	},
	"wind_tempo":
	{
		"weapon": "weapon_worn_focus",
		"offhand": "focus_gale_shard",
		"head": "helm_ritual_circlet",
		"body": "armor_mage_coat",
		"legs": "greaves_strider_boots",
		"accessory_1": "ring_flux_band",
		"accessory_2": "accessory_split_lens"
	},
	"holy_guard":
	{
		"weapon": "weapon_ember_staff",
		"offhand": "focus_swift_prism",
		"head": "helm_holy_halo",
		"body": "armor_guardian_coat",
		"legs": "greaves_strider_boots",
		"accessory_1": "ring_flux_band",
		"accessory_2": "ring_sanctum_loop"
	},
	"sanctum_sustain":
	{
		"weapon": "weapon_worn_focus",
		"offhand": "focus_storm_orb",
		"head": "helm_holy_halo",
		"body": "armor_soul_weave",
		"legs": "greaves_strider_boots",
		"accessory_1": "ring_copper_band",
		"accessory_2": "ring_sanctum_loop"
	},
	"dark_shadow":
	{
		"weapon": "weapon_ember_staff",
		"offhand": "focus_void_lens",
		"head": "helm_ritual_circlet",
		"body": "armor_mage_coat",
		"legs": "greaves_strider_boots",
		"accessory_1": "ring_abyss_signet",
		"accessory_2": "ring_grave_whisper"
	},
	"arcane_pulse":
	{
		"weapon": "weapon_ember_staff",
		"offhand": "focus_arcane_prism",
		"head": "helm_ritual_circlet",
		"body": "armor_mage_coat",
		"legs": "greaves_strider_boots",
		"accessory_1": "ring_chain_arc",
		"accessory_2": "ring_arcane_coil"
	}
}
const SCHOOL_TO_MASTERY := {
	"fire": "fire_mastery",
	"ice": "ice_mastery",
	"lightning": "lightning_mastery",
	"water": "water_mastery",
	"wind": "wind_mastery",
	"earth": "earth_mastery",
	"plant": "plant_mastery",
	"dark": "dark_magic_mastery",
	"arcane": "arcane_magic_mastery"
}

const CombatRuntimeStateScript := preload("res://scripts/autoload/combat_runtime_state.gd")
const ProgressionSaveStateScript := preload("res://scripts/autoload/progression_save_state.gd")

signal room_changed(room_id: String)
signal ui_message_changed(text: String, duration: float)
signal stats_changed
signal player_died
signal combo_effect_requested(payload: Dictionary)
signal progression_event_granted(event_id: String)

var _combat_state = CombatRuntimeStateScript.new(
	BASE_MAX_HEALTH, BASE_MAX_MANA, BASE_MANA_REGEN_PER_SECOND
)
var _progress_state = ProgressionSaveStateScript.new()

var max_health: int:
	get:
		return _combat_state.max_health
	set(value):
		_combat_state.max_health = value

var health: int:
	get:
		return _combat_state.health
	set(value):
		_combat_state.health = value

var max_mana: float:
	get:
		return _combat_state.max_mana
	set(value):
		_combat_state.max_mana = value

var mana: float:
	get:
		return _combat_state.mana
	set(value):
		_combat_state.mana = value

var mana_regen_per_second: float:
	get:
		return _combat_state.mana_regen_per_second
	set(value):
		_combat_state.mana_regen_per_second = value

var admin_infinite_health := false
var admin_infinite_mana := false
var admin_ignore_cooldowns := false
var admin_ignore_buff_slot_limit := false
var admin_freeze_ai := false
var session_damage_dealt: int:
	get:
		return _combat_state.session_damage_dealt
	set(value):
		_combat_state.session_damage_dealt = value

var session_hit_count: int:
	get:
		return _combat_state.session_hit_count
	set(value):
		_combat_state.session_hit_count = value

var session_kills: int:
	get:
		return _combat_state.session_kills
	set(value):
		_combat_state.session_kills = value

var session_drops: int:
	get:
		return _combat_state.session_drops
	set(value):
		_combat_state.session_drops = value

var last_drop_display: String:
	get:
		return _combat_state.last_drop_display
	set(value):
		_combat_state.last_drop_display = value

var current_room_id: String:
	get:
		return _progress_state.current_room_id
	set(value):
		_progress_state.current_room_id = value

var save_room_id: String:
	get:
		return _progress_state.save_room_id
	set(value):
		_progress_state.save_room_id = value

var save_spawn_position: Vector2:
	get:
		return _progress_state.save_spawn_position
	set(value):
		_progress_state.save_spawn_position = value

var core_activated: bool:
	get:
		return _progress_state.core_activated
	set(value):
		_progress_state.core_activated = value

var boss_defeated: bool:
	get:
		return _progress_state.boss_defeated
	set(value):
		_progress_state.boss_defeated = value

var seen_room_texts: Dictionary:
	get:
		return _progress_state.seen_room_texts
	set(value):
		_progress_state.seen_room_texts = value

var seen_echoes: Dictionary:
	get:
		return _progress_state.seen_echoes
	set(value):
		_progress_state.seen_echoes = value

var progression_flags: Dictionary:
	get:
		return _progress_state.progression_flags
	set(value):
		_progress_state.progression_flags = value

var ui_message := ""
var ui_message_time := 0.0
var spell_mastery: Dictionary = {}
var spell_level: Dictionary = {}
var skill_experience: Dictionary = {}
var skill_level_data: Dictionary = {}
var buff_cooldowns: Dictionary:
	get:
		return _combat_state.buff_cooldowns
	set(value):
		_combat_state.buff_cooldowns = value

var active_buffs: Array:
	get:
		return _combat_state.active_buffs
	set(value):
		_combat_state.active_buffs = value

var active_field_effects: Array:
	get:
		return _combat_state.active_field_effects
	set(value):
		_combat_state.active_field_effects = value

var active_penalties: Array:
	get:
		return _combat_state.active_penalties
	set(value):
		_combat_state.active_penalties = value

var combo_barrier: float:
	get:
		return _combat_state.combo_barrier
	set(value):
		_combat_state.combo_barrier = value

var combo_barrier_combo_id: String:
	get:
		return _combat_state.combo_barrier_combo_id
	set(value):
		_combat_state.combo_barrier_combo_id = value

var time_collapse_charges: int:
	get:
		return _combat_state.time_collapse_charges
	set(value):
		_combat_state.time_collapse_charges = value

var time_collapse_active: bool:
	get:
		return _combat_state.time_collapse_active
	set(value):
		_combat_state.time_collapse_active = value

var overclock_circuit_active: bool:
	get:
		return _combat_state.overclock_circuit_active
	set(value):
		_combat_state.overclock_circuit_active = value

var overclock_circuit_timer: float:
	get:
		return _combat_state.overclock_circuit_timer
	set(value):
		_combat_state.overclock_circuit_timer = value

var funeral_bloom_active: bool:
	get:
		return _combat_state.funeral_bloom_active
	set(value):
		_combat_state.funeral_bloom_active = value

var funeral_bloom_icd_timer: float:
	get:
		return _combat_state.funeral_bloom_icd_timer
	set(value):
		_combat_state.funeral_bloom_icd_timer = value

var ashen_rite_active: bool:
	get:
		return _combat_state.ashen_rite_active
	set(value):
		_combat_state.ashen_rite_active = value

var ash_stacks: int:
	get:
		return _combat_state.ash_stacks
	set(value):
		_combat_state.ash_stacks = value

var ash_residue_timer: float:
	get:
		return _combat_state.ash_residue_timer
	set(value):
		_combat_state.ash_residue_timer = value

var soul_dominion_active: bool:
	get:
		return _combat_state.soul_dominion_active
	set(value):
		_combat_state.soul_dominion_active = value

var soul_dominion_aftershock_timer: float:
	get:
		return _combat_state.soul_dominion_aftershock_timer
	set(value):
		_combat_state.soul_dominion_aftershock_timer = value

var last_combo_effect: Dictionary:
	get:
		return _combat_state.last_combo_effect
	set(value):
		_combat_state.last_combo_effect = value

var current_circle := 4
var circle_progress_score := 1.0
var spell_hotbar: Array = []
var visible_hotbar_shortcuts: Array = []
var action_hotkey_registry: Array = []
var equipped_items: Dictionary = {}
var equipment_inventory: Array = []
var consumable_inventory: Array = []
var other_inventory: Array = []
var current_equipment_preset := "default"
var resonance := {
	"fire": 0,
	"ice": 0,
	"lightning": 0,
	"wind": 0,
	"water": 0,
	"plant": 0,
	"earth": 0,
	"holy": 0,
	"dark": 0,
	"arcane": 0
}
var last_spell_school := "fire"
var last_damage_amount: int:
	get:
		return _combat_state.last_damage_amount
	set(value):
		_combat_state.last_damage_amount = value

var last_damage_school: String:
	get:
		return _combat_state.last_damage_school
	set(value):
		_combat_state.last_damage_school = value

var last_damage_display_timer: float:
	get:
		return _combat_state.last_damage_display_timer
	set(value):
		_combat_state.last_damage_display_timer = value

var resonance_bonus_school := ""
var resonance_bonus_timer := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_save()
	_initialize_skill_progress()
	_initialize_buff_runtime()
	_initialize_spell_hotbar()
	_initialize_action_hotkey_registry()
	_initialize_equipment_state()
	_recalculate_derived_stats(false)
	recalculate_circle_progression(false)
	stats_changed.emit()


func _process(delta: float) -> void:
	_tick_buff_runtime(delta)
	_tick_mana_regeneration(delta)
	if ui_message_time > 0.0:
		ui_message_time = max(ui_message_time - delta, 0.0)
		if ui_message_time == 0.0 and ui_message != "":
			ui_message = ""
			ui_message_changed.emit("", 0.0)
	if last_damage_display_timer > 0.0:
		last_damage_display_timer = max(last_damage_display_timer - delta, 0.0)
	if resonance_bonus_timer > 0.0:
		resonance_bonus_timer = max(resonance_bonus_timer - delta, 0.0)
		if resonance_bonus_timer == 0.0:
			resonance_bonus_school = ""


func ensure_input_map() -> void:
	_add_action("move_left", [KEY_LEFT])
	_add_action("move_right", [KEY_RIGHT])
	_add_action("move_up", [KEY_UP])
	_add_action("move_down", [KEY_DOWN])
	_add_action("jump", [KEY_SPACE])
	_add_action("dash", [KEY_TAB])
	_add_action("spell_fire", [KEY_1])
	_add_action("spell_ice", [KEY_2])
	_add_action("spell_lightning", [KEY_3])
	_add_action("spell_water", [KEY_4])
	_add_action("spell_wind", [KEY_5])
	_add_action("spell_plant", [KEY_6])
	_add_action("spell_earth", [KEY_7])
	_add_action("spell_holy", [KEY_8])
	_add_action("spell_dark", [KEY_9])
	_add_action("spell_arcane", [KEY_0])
	_add_action("buff_guard", [KEY_Z])
	_add_action("buff_power", [KEY_X])
	_add_action("buff_ward", [KEY_C])
	_add_action("buff_aegis", [KEY_V])
	_add_action("buff_tempo", [KEY_A])
	_add_action("buff_surge", [KEY_S])
	_add_action("buff_compression", [KEY_D])
	_add_action("buff_hourglass", [KEY_F])
	_add_action("buff_pact", [KEY_SHIFT])
	_add_action("buff_throne", [KEY_CTRL])
	_add_action("buff_overflow", [KEY_ALT])
	_add_action("interact", [KEY_ENTER])
	_add_action("admin_menu", [KEY_F8])
	_add_action("ui_inventory", [KEY_I])
	_add_action("ui_skill", [KEY_K])
	_add_action("ui_equipment", [KEY_E])
	_add_action("ui_stats", [KEY_T])
	_add_action("ui_quest", [KEY_Q])
	_add_action("ui_settings", [KEY_ESCAPE])
	_set_action_primary_physical_keycode("move_left", KEY_LEFT)
	_set_action_primary_physical_keycode("move_right", KEY_RIGHT)
	_set_action_primary_physical_keycode("move_up", KEY_UP)
	_set_action_primary_physical_keycode("move_down", KEY_DOWN)
	_set_action_primary_physical_keycode("jump", KEY_SPACE)
	_set_action_primary_physical_keycode("dash", KEY_TAB)
	_set_action_primary_physical_keycode("buff_guard", KEY_Z)
	_set_action_primary_physical_keycode("buff_power", KEY_X)
	_set_action_primary_physical_keycode("buff_ward", KEY_C)
	_set_action_primary_physical_keycode("buff_aegis", KEY_V)
	_set_action_primary_physical_keycode("buff_tempo", KEY_A)
	_set_action_primary_physical_keycode("buff_surge", KEY_S)
	_set_action_primary_physical_keycode("buff_compression", KEY_D)
	_set_action_primary_physical_keycode("buff_hourglass", KEY_F)
	_set_action_primary_physical_keycode("buff_pact", KEY_SHIFT)
	_set_action_primary_physical_keycode("buff_throne", KEY_CTRL)
	_set_action_primary_physical_keycode("buff_overflow", KEY_ALT)
	_set_action_primary_physical_keycode("interact", KEY_ENTER)
	_set_action_primary_physical_keycode("admin_menu", KEY_F8)
	_set_action_primary_physical_keycode("ui_inventory", KEY_I)
	_set_action_primary_physical_keycode("ui_skill", KEY_K)
	_set_action_primary_physical_keycode("ui_equipment", KEY_E)
	_set_action_primary_physical_keycode("ui_stats", KEY_T)
	_set_action_primary_physical_keycode("ui_quest", KEY_Q)
	_set_action_primary_physical_keycode("ui_settings", KEY_ESCAPE)
	_apply_visible_hotbar_shortcuts_to_input_map()
	_apply_action_hotkey_registry_to_input_map()


func heal_full() -> void:
	health = max_health
	mana = max_mana
	_reset_transient_combat_runtime()
	stats_changed.emit()


func apply_direct_heal(amount: int, show_message: bool = false) -> int:
	if amount <= 0 or health >= max_health:
		return 0
	var healed := mini(amount, max_health - health)
	health += healed
	if healed > 0:
		if show_message:
			push_message("+%d HP 회복" % healed, 0.8)
		stats_changed.emit()
	return healed


func apply_direct_mana_restore(amount: float, show_message: bool = false) -> float:
	if amount <= 0.0 or mana >= max_mana:
		return 0.0
	var restored := minf(amount, max_mana - mana)
	mana += restored
	if restored > 0.0:
		if show_message:
			push_message("+%d MP 회복" % int(round(restored)), 0.8)
		stats_changed.emit()
	return restored


func _reset_transient_combat_runtime(
	clear_effects: bool = false, clear_hit_feedback: bool = false
) -> void:
	combo_barrier = 0.0
	combo_barrier_combo_id = ""
	time_collapse_charges = 0
	time_collapse_active = false
	overclock_circuit_active = false
	overclock_circuit_timer = 0.0
	funeral_bloom_active = false
	funeral_bloom_icd_timer = 0.0
	ashen_rite_active = false
	ash_stacks = 0
	ash_residue_timer = 0.0
	soul_dominion_active = false
	soul_dominion_aftershock_timer = 0.0
	last_combo_effect = {}
	if clear_effects:
		active_buffs.clear()
		active_field_effects.clear()
		active_penalties.clear()
		buff_cooldowns.clear()
	if clear_hit_feedback:
		last_damage_amount = 0
		last_damage_school = ""
		last_damage_display_timer = 0.0


func restore_mana_full() -> void:
	mana = max_mana
	stats_changed.emit()


func damage(amount: int, school: String = "") -> void:
	if admin_infinite_health:
		health = max_health
		stats_changed.emit()
		return
	var reduced_amount := int(max(round(float(amount) * get_damage_taken_multiplier()), 1.0))
	if combo_barrier > 0.0:
		var absorbed: float = min(combo_barrier, float(reduced_amount))
		combo_barrier -= absorbed
		reduced_amount -= int(round(absorbed))
		if absorbed > 0.0:
			push_message("프리즈매틱 장벽이 충격을 흡수했습니다.", 0.8)
		if combo_barrier <= 0.0 and combo_barrier_combo_id == "combo_prismatic_guard":
			push_message("프리즈매틱 가드가 날카로운 마나 파열과 함께 산산이 부서졌습니다.", 1.2)
			var barrier_break_payload := _build_prismatic_guard_break_payload()
			if not barrier_break_payload.is_empty():
				_emit_combo_effect(barrier_break_payload)
	if reduced_amount <= 0:
		stats_changed.emit()
		return
	last_damage_amount = reduced_amount
	last_damage_school = school
	last_damage_display_timer = 4.0
	health = max(health - reduced_amount, 0)
	stats_changed.emit()
	if health <= 0:
		push_message(
			"집중이 산산이 부서졌습니다. 미궁이 의식을 끝내기 전에 휴식 봉인이 당신을 끌어돌립니다.",
			3.0
		)
		player_died.emit()


func save_progress(room_id: String, spawn_position: Vector2) -> void:
	_progress_state.save_progress(room_id, spawn_position)
	heal_full()
	save_to_disk()
	push_message("마나가 안정되었습니다. 봉인이 당신의 경로를 기록합니다.", 2.4)


func restore_after_death() -> Dictionary:
	_progress_state.restore_current_room()
	health = max_health
	mana = max_mana
	_reset_transient_combat_runtime(true, true)
	stats_changed.emit()
	return {"room_id": save_room_id, "spawn_position": save_spawn_position}


func set_room(room_id: String) -> void:
	current_room_id = room_id
	room_changed.emit(room_id)
	save_to_disk()


func register_spell_use(spell_id: String, school: String = "") -> void:
	var resolved_school := resolve_runtime_school("", spell_id, school)
	last_spell_school = resolved_school
	spell_mastery[spell_id] = int(spell_mastery.get(spell_id, 0)) + 1
	if resolved_school != "":
		resonance[resolved_school] = int(resonance.get(resolved_school, 0)) + 1
		_check_resonance_milestone(resolved_school, int(resonance.get(resolved_school, 0)))
	_sync_runtime_spell_level(spell_id)
	if _should_open_overclock_circuit_from_spell(spell_id):
		_activate_overclock_circuit_window()
	stats_changed.emit()


func _check_resonance_milestone(school: String, new_value: int) -> void:
	if RESONANCE_MILESTONES.has(new_value):
		push_message(RESONANCE_MILESTONES[new_value] % get_school_display_name(school), 2.4)
	if new_value == 30:
		resonance_bonus_school = school
		resonance_bonus_timer = 15.0


func get_spell_runtime(spell_id: String) -> Dictionary:
	var data: Dictionary = GameDatabase.get_spell(spell_id)
	var level: int = get_spell_level(spell_id)
	var linked_skill: Dictionary = GameDatabase.get_skill_data(get_skill_id_for_spell(spell_id))
	if not data.is_empty():
		var runtime_options := build_active_spell_runtime_options(spell_id, linked_skill, data, level)
		var runtime_school := str(runtime_options.get("runtime_school", ""))
		data["skill_id"] = get_skill_id_for_spell(spell_id)
		data["school"] = runtime_school
		if not linked_skill.is_empty():
			data["linked_skill_name"] = linked_skill.get("display_name", data.get("name", spell_id))
			if not data.has("target_count") and linked_skill.has("target_count_base"):
				data["target_count"] = int(linked_skill.get("target_count_base", 0))
			if not data.has("projectile_count") and linked_skill.has("projectile_count_base"):
				data["projectile_count"] = int(linked_skill.get("projectile_count_base", 0))
			if not data.has("pierce") and linked_skill.has("pierce_count_base"):
				data["pierce"] = int(linked_skill.get("pierce_count_base", 0))
			if linked_skill.has("dash_speed_base"):
				data["dash_speed"] = float(linked_skill.get("dash_speed_base", 0.0))
			if linked_skill.has("dash_duration_base"):
				data["dash_duration"] = float(linked_skill.get("dash_duration_base", 0.0))
		data = build_common_runtime_stat_block(
			str(linked_skill.get("skill_id", get_skill_id_for_spell(spell_id))),
			data,
			linked_skill,
			runtime_options
		)
		data["utility_effects"] = _get_scaled_runtime_utility_effects(
			data.get("utility_effects", []),
			level
		)
		data["skill_level"] = level
		data = _apply_buff_runtime_modifiers(data)
	return data


func build_runtime_scaling_options(
	level: int, runtime_school: String, overrides: Dictionary = {}
) -> Dictionary:
	var options := {
		"level": level,
		"runtime_school": runtime_school
	}
	for key in overrides.keys():
		options[key] = overrides[key]
	return options


func build_active_spell_runtime_options(
	spell_id: String,
	linked_skill_data: Dictionary = {},
	spell_data: Dictionary = {},
	level_override: int = -1
) -> Dictionary:
	var resolved_linked_skill_data: Dictionary = _resolve_runtime_skill_data(
		get_skill_id_for_spell(spell_id),
		linked_skill_data
	)
	var resolved_skill_id: String = _resolve_runtime_skill_id(
		get_skill_id_for_spell(spell_id),
		resolved_linked_skill_data
	)
	var resolved_spell_data: Dictionary = spell_data
	if resolved_spell_data.is_empty():
		resolved_spell_data = GameDatabase.get_spell(spell_id)
	var runtime_school := resolve_runtime_school(
		resolved_skill_id,
		spell_id,
		str(resolved_spell_data.get("school", ""))
	)
	var level := level_override
	if level < 0:
		level = get_spell_level(spell_id)
	return build_runtime_scaling_options(
		level,
		runtime_school,
		{
			"runtime_spell_id": spell_id,
			"damage_per_level": 0.04,
			"cooldown_reduction_per_level": 0.045,
			"cooldown_min_multiplier": 0.55,
			"duration_scale_per_level": 0.01,
			"range_scale_per_level": 0.008,
			"size_scale_per_level": 0.006,
			"knockback_scale_per_level": float(
				resolved_linked_skill_data.get("knockback_scale_per_level", 0.0)
			),
			"dash_speed_scale_per_level": float(
				resolved_linked_skill_data.get("dash_speed_scale_per_level", 0.0)
			),
			"dash_duration_scale_per_level": float(
				resolved_linked_skill_data.get("dash_duration_scale_per_level", 0.0)
			),
			"self_heal_per_level": float(
				resolved_linked_skill_data.get("self_heal_scale_per_level", 0.0)
			),
			"apply_equipment_damage": true,
			"apply_equipment_cooldown": true,
			"apply_equipment_aoe": true,
			"aoe_fields": ["size"],
			"apply_discrete_milestone_bonuses": true
		}
	)


func build_data_driven_skill_runtime_options(
	skill_id: String, skill_data: Dictionary = {}, level_override: int = -1
) -> Dictionary:
	var resolved_skill_data: Dictionary = _resolve_runtime_skill_data(skill_id, skill_data)
	var resolved_skill_id: String = _resolve_runtime_skill_id(skill_id, resolved_skill_data)
	var runtime_school := resolve_runtime_school(
		resolved_skill_id,
		"",
		str(resolved_skill_data.get("element", "arcane"))
	)
	var level := level_override
	if level < 0:
		level = get_skill_level(resolved_skill_id)
	return build_runtime_scaling_options(
		level,
		runtime_school,
		{
			"cooldown_reduction_per_level": float(
				resolved_skill_data.get("cooldown_reduction_per_level", 0.0)
			),
			"cooldown_min_multiplier": 0.45,
			"duration_scale_per_level": float(
				resolved_skill_data.get("duration_scale_per_level", 0.0)
			),
			"size_scale_per_level": float(resolved_skill_data.get("range_scale_per_level", 0.0)),
			"pull_strength_scale_per_level": float(
				resolved_skill_data.get("pull_strength_scale_per_level", 0.0)
			),
			"self_heal_per_level": float(resolved_skill_data.get("self_heal_scale_per_level", 0.0)),
			"apply_equipment_damage": true,
			"apply_equipment_cooldown": true,
			"apply_equipment_aoe": true,
			"aoe_fields": ["size"],
			"duration_equipment_mode": "install"
		}
	)


func build_data_driven_skill_base_runtime(
	skill_id: String, skill_data: Dictionary = {}, level_override: int = -1
) -> Dictionary:
	var resolved_skill_data: Dictionary = _resolve_runtime_skill_data(skill_id, skill_data)
	var resolved_skill_id: String = _resolve_runtime_skill_id(skill_id, resolved_skill_data)
	var level := level_override
	if level < 0:
		level = get_skill_level(resolved_skill_id)
	var level_delta: int = max(level - 1, 0)
	var damage_formula: Dictionary = resolved_skill_data.get("damage_formula", {})
	var coefficient: float = float(damage_formula.get("coefficient_base", 1.0)) + float(
		damage_formula.get("coefficient_per_level", 0.0)
	) * float(level_delta)
	var flat_damage: float = float(damage_formula.get("flat_base", 0.0)) + float(
		damage_formula.get("flat_per_level", 0.0)
	) * float(level_delta)
	var formula_type := str(damage_formula.get("formula_type", "hit"))
	var tick_interval := float(resolved_skill_data.get("tick_interval", 1.0))
	var damage_value := int(round(coefficient * 10.0 + flat_damage))
	var damage_cadence_reference_interval := float(
		resolved_skill_data.get("damage_cadence_reference_interval", 0.0)
	)
	if tick_interval > 0.0 and damage_cadence_reference_interval > 0.0:
		var cadence_window := float(resolved_skill_data.get("duration_base", 0.0))
		if cadence_window <= 0.0:
			cadence_window = 3.0
		else:
			cadence_window = minf(cadence_window, 3.0)
		var reference_hits := _count_tick_hits_in_window(
			damage_cadence_reference_interval,
			cadence_window
		)
		var runtime_hits := _count_tick_hits_in_window(tick_interval, cadence_window)
		if damage_value > 0 and reference_hits > 0 and runtime_hits > 0:
			damage_value = maxi(
				1,
				int(round(float(damage_value) * float(reference_hits) / float(runtime_hits)))
			)
	var runtime := {
		"cooldown": float(resolved_skill_data.get("cooldown_base", 1.0)),
		"duration": float(resolved_skill_data.get("duration_base", 0.0)),
		"size": float(resolved_skill_data.get("range_base", 40.0)),
		"tick_interval": tick_interval,
		"knockback": float(resolved_skill_data.get("knockback_base", 180.0)),
		"pull_strength": float(resolved_skill_data.get("pull_strength_base", 0.0)),
		"target_count": int(resolved_skill_data.get("target_count_base", 0))
		+ get_skill_milestone_runtime_bonus(resolved_skill_data, "target_count", level),
		"pierce": int(resolved_skill_data.get("pierce_count_base", 0))
		+ get_skill_milestone_runtime_bonus(resolved_skill_data, "pierce_count", level),
		"utility_effects": _get_scaled_runtime_utility_effects(
			resolved_skill_data.get("utility_effects", []),
			level
		)
	}
	if formula_type == "heal" and str(resolved_skill_data.get("skill_type", "")) == "deploy":
		runtime["damage"] = 0
		runtime["self_heal"] = damage_value
	else:
		runtime["damage"] = damage_value
	var authored_self_heal := int(resolved_skill_data.get("self_heal_base", 0))
	if authored_self_heal > 0:
		runtime["self_heal"] = authored_self_heal
	return runtime


func _get_scaled_runtime_utility_effects(raw_effects: Array, level: int) -> Array:
	var level_delta: int = max(level - 1, 0)
	var scaled_effects: Array = raw_effects.duplicate(true)
	for effect_index in range(scaled_effects.size()):
		if typeof(scaled_effects[effect_index]) != TYPE_DICTIONARY:
			continue
		var effect: Dictionary = (scaled_effects[effect_index] as Dictionary).duplicate(true)
		if effect.has("chance_per_level"):
			effect["chance"] = clampf(
				float(effect.get("chance", 0.0))
				+ float(effect.get("chance_per_level", 0.0)) * float(level_delta),
				0.0,
				1.0
			)
			effect.erase("chance_per_level")
		if effect.has("value_per_level"):
			effect["value"] = float(effect.get("value", 0.0)) + float(
				effect.get("value_per_level", 0.0)
			) * float(level_delta)
			effect.erase("value_per_level")
		if effect.has("duration_per_level"):
			effect["duration"] = maxf(
				0.0,
				float(effect.get("duration", 0.0))
				+ float(effect.get("duration_per_level", 0.0)) * float(level_delta)
			)
			effect.erase("duration_per_level")
		if effect.has("duration_scale_per_level"):
			effect["duration"] = maxf(
				0.0,
				float(effect.get("duration", 0.0))
				* (1.0 + float(effect.get("duration_scale_per_level", 0.0)) * float(level_delta))
			)
			effect.erase("duration_scale_per_level")
		scaled_effects[effect_index] = effect
	return scaled_effects


func get_data_driven_skill_runtime(
	skill_id: String, skill_data: Dictionary = {}, level_override: int = -1
) -> Dictionary:
	var resolved_skill_data: Dictionary = _resolve_runtime_skill_data(skill_id, skill_data)
	var resolved_skill_id: String = _resolve_runtime_skill_id(skill_id, resolved_skill_data)
	var level := level_override
	if level < 0:
		level = get_skill_level(resolved_skill_id)
	var base_runtime := build_data_driven_skill_base_runtime(
		resolved_skill_id,
		resolved_skill_data,
		level
	)
	var runtime_options := build_data_driven_skill_runtime_options(
		resolved_skill_id,
		resolved_skill_data,
		level
	)
	var runtime := build_common_runtime_stat_block(
		resolved_skill_id,
		base_runtime,
		resolved_skill_data,
		runtime_options
	)
	runtime["tick_interval"] = float(runtime.get("tick_interval", 1.0)) * maxf(
		0.6,
		1.0 - get_equipment_cast_speed_bonus()
	)
	runtime["mana_drain_per_tick"] = get_data_driven_skill_mana_drain_per_tick(
		resolved_skill_id,
		resolved_skill_data,
		runtime_options
	)
	var support_effects: Array = resolved_skill_data.get("support_effects", [])
	if not support_effects.is_empty():
		runtime["support_effects"] = _get_scaled_authored_effects(
			resolved_skill_id,
			support_effects,
			resolved_skill_data,
			level
		)
		var support_effect_duration := float(
			resolved_skill_data.get("support_effect_duration_base", 0.0)
		)
		if support_effect_duration <= 0.0:
			support_effect_duration = maxf(float(runtime.get("tick_interval", 0.0)) + 0.15, 0.2)
		runtime["support_effect_duration"] = support_effect_duration
	return runtime


func get_data_driven_skill_mana_drain_per_tick(
	skill_id: String, skill_data: Dictionary = {}, runtime_options: Dictionary = {}
) -> float:
	var resolved_skill_data: Dictionary = _resolve_runtime_skill_data(skill_id, skill_data)
	var resolved_skill_id: String = _resolve_runtime_skill_id(skill_id, resolved_skill_data)
	var base_value: float = float(resolved_skill_data.get("sustain_mana_cost_base", -1.0))
	if base_value < 0.0:
		var mana_cost: float = get_skill_mana_cost(resolved_skill_id)
		return maxf(1.0, mana_cost * 0.35)
	var resolved_options := runtime_options
	if resolved_options.is_empty():
		resolved_options = build_data_driven_skill_runtime_options(
			resolved_skill_id,
			resolved_skill_data
		)
	return maxf(
		1.0,
		get_common_scaled_mana_value(
			resolved_skill_id,
			base_value,
			float(resolved_skill_data.get("sustain_mana_reduction_per_level", 0.0)),
			float(resolved_skill_data.get("sustain_mana_min_ratio", 0.65)),
			resolved_skill_data,
			str(resolved_options.get("runtime_school", ""))
		)
	)


func build_data_driven_combat_payload(
	skill_id: String, runtime_source: Dictionary = {}, overrides: Dictionary = {}
) -> Dictionary:
	var payload := {
		"spell_id": skill_id,
		"velocity": Vector2.ZERO,
		"range": 1.0,
		"team": "player",
		"damage": int(runtime_source.get("damage", 0)),
		"knockback": float(runtime_source.get("knockback", 180.0)),
		"school": str(runtime_source.get("school", resolve_runtime_school(skill_id))),
		"size": float(runtime_source.get("size", 40.0)),
		"duration": float(runtime_source.get("duration", 0.12)),
		"utility_effects": runtime_source.get("utility_effects", []).duplicate(true)
	}
	var passthrough_fields := [
		"tick_interval",
		"pierce",
		"target_count",
		"color",
		"owner",
		"pull_strength",
		"self_heal",
		"support_effects",
		"support_effect_duration"
	]
	for field_name in passthrough_fields:
		if runtime_source.has(field_name):
			payload[field_name] = runtime_source.get(field_name)
	for key in overrides.keys():
		payload[key] = overrides[key]
	return payload


func get_skill_milestone_runtime_bonus(
	skill_data: Dictionary, stat_name: String, level: int
) -> int:
	var total_bonus := 0
	for bonus in skill_data.get("milestone_bonuses", []):
		if str(bonus.get("stat", "")) != stat_name:
			continue
		if level >= int(bonus.get("level", 99)):
			total_bonus += int(bonus.get("value", 0))
	return total_bonus


func build_common_runtime_stat_block(
	target_skill_id: String,
	base_runtime: Dictionary,
	target_skill_data: Dictionary = {},
	options: Dictionary = {}
) -> Dictionary:
	var runtime: Dictionary = base_runtime.duplicate(true)
	var resolved_skill_data: Dictionary = _resolve_runtime_skill_data(target_skill_id, target_skill_data)
	var resolved_skill_id: String = _resolve_runtime_skill_id(target_skill_id, resolved_skill_data)
	var runtime_school := resolve_runtime_school(
		resolved_skill_id,
		str(options.get("runtime_spell_id", "")),
		str(options.get("runtime_school", runtime.get("school", "")))
	)
	if runtime_school != "":
		runtime["school"] = runtime_school
	var level: int = int(options.get("level", get_skill_level(resolved_skill_id)))
	var level_delta: int = max(level - 1, 0)
	var damage_per_level := float(options.get("damage_per_level", 0.0))
	var cooldown_reduction_per_level := float(options.get("cooldown_reduction_per_level", 0.0))
	var cooldown_min_multiplier := float(options.get("cooldown_min_multiplier", 1.0))
	var duration_scale_per_level := float(options.get("duration_scale_per_level", 0.0))
	var range_scale_per_level := float(options.get("range_scale_per_level", 0.0))
	var size_scale_per_level := float(options.get("size_scale_per_level", 0.0))
	var knockback_scale_per_level := float(options.get("knockback_scale_per_level", 0.0))
	var pull_strength_scale_per_level := float(options.get("pull_strength_scale_per_level", 0.0))
	var dash_speed_scale_per_level := float(options.get("dash_speed_scale_per_level", 0.0))
	var dash_duration_scale_per_level := float(options.get("dash_duration_scale_per_level", 0.0))
	var self_heal_per_level := float(options.get("self_heal_per_level", 0.0))
	if runtime.has("damage"):
		runtime["damage"] = int(
			round(float(runtime.get("damage", 0.0)) * (1.0 + damage_per_level * float(level_delta)))
		)
	if runtime.has("self_heal"):
		runtime["self_heal"] = int(
			round(
				float(runtime.get("self_heal", 0.0))
				* (1.0 + self_heal_per_level * float(level_delta))
			)
		)
	if runtime.has("cooldown"):
		runtime["cooldown"] = float(runtime.get("cooldown", 0.0)) * maxf(
			cooldown_min_multiplier,
			1.0 - cooldown_reduction_per_level * float(level_delta)
		)
	if runtime.has("duration"):
		runtime["duration"] = float(runtime.get("duration", 0.0)) * (
			1.0 + duration_scale_per_level * float(level_delta)
		)
	if runtime.has("range"):
		runtime["range"] = float(runtime.get("range", 0.0)) * (
			1.0 + range_scale_per_level * float(level_delta)
		)
	if runtime.has("size"):
		runtime["size"] = float(runtime.get("size", 0.0)) * (
			1.0 + size_scale_per_level * float(level_delta)
		)
	if runtime.has("knockback"):
		runtime["knockback"] = float(runtime.get("knockback", 0.0)) * (
			1.0 + knockback_scale_per_level * float(level_delta)
		)
	if runtime.has("pull_strength"):
		runtime["pull_strength"] = float(runtime.get("pull_strength", 0.0)) * (
			1.0 + pull_strength_scale_per_level * float(level_delta)
		)
	if runtime.has("dash_speed"):
		runtime["dash_speed"] = float(runtime.get("dash_speed", 0.0)) * (
			1.0 + dash_speed_scale_per_level * float(level_delta)
		)
	if runtime.has("dash_duration"):
		runtime["dash_duration"] = float(runtime.get("dash_duration", 0.0)) * (
			1.0 + dash_duration_scale_per_level * float(level_delta)
		)
	if not runtime.has("target_count") and resolved_skill_data.has("target_count_base"):
		runtime["target_count"] = int(resolved_skill_data.get("target_count_base", 0))
	if not runtime.has("projectile_count") and resolved_skill_data.has("projectile_count_base"):
		runtime["projectile_count"] = int(resolved_skill_data.get("projectile_count_base", 0))
	if not runtime.has("pierce") and resolved_skill_data.has("pierce_count_base"):
		runtime["pierce"] = int(resolved_skill_data.get("pierce_count_base", 0))
	if bool(options.get("apply_discrete_milestone_bonuses", false)):
		var discrete_milestone_runtime_fields := {
			"pierce": "pierce_count",
			"target_count": "target_count",
			"projectile_count": "projectile_count"
		}
		for runtime_field in discrete_milestone_runtime_fields.keys():
			if not runtime.has(runtime_field):
				continue
			var milestone_stat := str(discrete_milestone_runtime_fields.get(runtime_field, ""))
			if milestone_stat.is_empty():
				continue
			runtime[runtime_field] = int(runtime.get(runtime_field, 0)) + get_skill_milestone_runtime_bonus(
				resolved_skill_data,
				milestone_stat,
				level
			)
	var mastery_modifiers := get_mastery_runtime_modifiers_for_skill(
		resolved_skill_id,
		resolved_skill_data,
		runtime_school
	)
	if runtime.has("damage"):
		runtime["damage"] = int(
			round(
				float(runtime.get("damage", 0.0))
				* float(mastery_modifiers.get("damage_multiplier", 1.0))
			)
		)
	if runtime.has("cooldown"):
		runtime["cooldown"] = (
			float(runtime.get("cooldown", 0.0))
			* float(mastery_modifiers.get("cooldown_multiplier", 1.0))
		)
	if bool(options.get("apply_equipment_damage", false)) and runtime.has("damage"):
		runtime["damage"] = int(
			round(float(runtime.get("damage", 0.0)) * get_equipment_damage_multiplier(runtime_school))
		)
	if bool(options.get("apply_equipment_cooldown", false)) and runtime.has("cooldown"):
		runtime["cooldown"] = float(runtime.get("cooldown", 0.0)) * get_equipment_cooldown_multiplier()
	if bool(options.get("apply_equipment_aoe", false)):
		var aoe_fields: Array = options.get("aoe_fields", ["size"])
		for raw_field in aoe_fields:
			var field_name := str(raw_field)
			if runtime.has(field_name):
				runtime[field_name] = (
					float(runtime.get(field_name, 0.0)) * get_equipment_aoe_multiplier()
				)
	if str(options.get("duration_equipment_mode", "")) == "install" and runtime.has("duration"):
		runtime["duration"] = (
			float(runtime.get("duration", 0.0)) * get_equipment_install_duration_multiplier()
		)
	runtime = _apply_high_circle_range_feel_bonus(runtime, resolved_skill_data)
	return runtime


func _count_tick_hits_in_window(interval: float, window: float) -> int:
	var safe_interval := maxf(interval, 0.001)
	var safe_window := maxf(window, safe_interval)
	return 1 + int(floor(maxf(safe_window - 0.0001, 0.0) / safe_interval))


func _apply_high_circle_range_feel_bonus(
	runtime: Dictionary, skill_data: Dictionary = {}
) -> Dictionary:
	var circle := int(skill_data.get("circle", 0))
	if circle < 4:
		return runtime
	var adjusted := runtime.duplicate(true)
	var hit_shape := str(skill_data.get("hit_shape", "projectile"))
	var skill_type := str(skill_data.get("skill_type", "active"))
	var circle_delta := float(circle - 4)
	var size_multiplier := 1.0
	var range_multiplier := 1.0
	var duration_multiplier := 1.0
	var stationary_burst := (
		hit_shape == "circle"
		or hit_shape == "aura"
		or hit_shape == "wall"
		or skill_type == "deploy"
		or float(runtime.get("speed", 0.0)) <= 0.0
	)
	if stationary_burst:
		size_multiplier = minf(2.55, 1.42 + circle_delta * 0.19)
		range_multiplier = minf(2.40, 1.36 + circle_delta * 0.17)
		if adjusted.has("duration") and float(adjusted.get("duration", 0.0)) > 0.0:
			duration_multiplier = minf(1.40, 1.08 + circle_delta * 0.035)
	elif hit_shape == "line" or hit_shape == "cone":
		size_multiplier = minf(1.45, 1.08 + circle_delta * 0.05)
		range_multiplier = minf(1.70, 1.14 + circle_delta * 0.07)
		if adjusted.has("duration") and float(adjusted.get("duration", 0.0)) > 0.0:
			duration_multiplier = minf(1.18, 1.03 + circle_delta * 0.02)
	else:
		size_multiplier = minf(1.30, 1.04 + circle_delta * 0.03)
		range_multiplier = minf(1.45, 1.08 + circle_delta * 0.05)
		if adjusted.has("duration") and float(adjusted.get("duration", 0.0)) > 0.0:
			duration_multiplier = minf(1.14, 1.02 + circle_delta * 0.015)
	if adjusted.has("size"):
		adjusted["size"] = float(adjusted.get("size", 0.0)) * size_multiplier
	if adjusted.has("range"):
		adjusted["range"] = float(adjusted.get("range", 0.0)) * range_multiplier
	if adjusted.has("duration"):
		adjusted["duration"] = float(adjusted.get("duration", 0.0)) * duration_multiplier
	return adjusted


func get_common_scaled_mana_value(
	target_skill_id: String,
	base_value: float,
	reduction_per_level: float,
	min_ratio: float = 0.4,
	target_skill_data: Dictionary = {},
	school_override: String = ""
) -> float:
	var resolved_skill_data: Dictionary = _resolve_runtime_skill_data(target_skill_id, target_skill_data)
	var resolved_skill_id: String = _resolve_runtime_skill_id(target_skill_id, resolved_skill_data)
	var runtime_school := resolve_runtime_school(resolved_skill_id, "", school_override)
	var level: int = get_skill_level(resolved_skill_id)
	var level_delta: int = max(level - 1, 0)
	var scaled_value := maxf(
		0.0, base_value * maxf(min_ratio, 1.0 - reduction_per_level * float(level_delta))
	)
	var mastery_modifiers := get_mastery_runtime_modifiers_for_skill(
		resolved_skill_id,
		resolved_skill_data,
		runtime_school
	)
	return maxf(0.0, scaled_value * float(mastery_modifiers.get("mana_cost_multiplier", 1.0)))


func get_mastery_runtime_modifiers_for_skill(
	target_skill_id: String, target_skill_data: Dictionary = {}, school_override: String = ""
) -> Dictionary:
	var modifiers := {
		"mastery_id": "",
		"global_mastery_id": "",
		"damage_multiplier": 1.0,
		"cooldown_multiplier": 1.0,
		"mana_cost_multiplier": 1.0
	}
	var resolved_skill_data: Dictionary = _resolve_runtime_skill_data(target_skill_id, target_skill_data)
	if resolved_skill_data.is_empty():
		return modifiers
	var skill_type := str(resolved_skill_data.get("skill_type", ""))
	if skill_type not in ["active", "deploy", "toggle"]:
		return modifiers
	var runtime_school := resolve_runtime_school(target_skill_id, "", school_override)
	var mastery_id: String = str(SCHOOL_TO_MASTERY.get(runtime_school, ""))
	if mastery_id != "":
		var mastery_data: Dictionary = GameDatabase.get_skill_data(mastery_id)
		if (
			not mastery_data.is_empty()
			and str(mastery_data.get("passive_family", "")) == "mastery"
			and not _is_global_mastery_runtime_modifier(mastery_data)
			and _mastery_applies_to_skill(mastery_data, resolved_skill_data, runtime_school)
		):
			modifiers = _apply_single_mastery_runtime_modifier(
				modifiers,
				mastery_id,
				mastery_data,
				get_skill_level(mastery_id),
				false
			)
	var global_mastery_id := "arcane_magic_mastery"
	var global_mastery_data: Dictionary = GameDatabase.get_skill_data(global_mastery_id)
	if (
		not global_mastery_data.is_empty()
		and str(global_mastery_data.get("passive_family", "")) == "mastery"
		and _is_global_mastery_runtime_modifier(global_mastery_data)
		and _mastery_applies_to_skill(global_mastery_data, resolved_skill_data, runtime_school)
	):
		modifiers = _apply_single_mastery_runtime_modifier(
			modifiers,
			global_mastery_id,
			global_mastery_data,
			get_skill_level(global_mastery_id),
			true
		)
	return modifiers


func _apply_single_mastery_runtime_modifier(
	modifiers: Dictionary,
	mastery_id: String,
	mastery_data: Dictionary,
	mastery_level: int,
	is_global: bool
) -> Dictionary:
	var level_delta: int = max(mastery_level - 1, 0)
	var damage_bonus := 0.0
	var mana_reduction := 0.0
	var cooldown_reduction := 0.0
	for raw_bonus in mastery_data.get("threshold_bonuses", []):
		var bonus: Dictionary = raw_bonus
		if mastery_level < int(bonus.get("level", 99)):
			continue
		var effect := str(bonus.get("effect", ""))
		var value := float(bonus.get("value", 0.0))
		match effect:
			"damage":
				damage_bonus += value
			"mana_cost_reduction":
				mana_reduction += value
			"cooldown_reduction":
				cooldown_reduction += value
			_:
				pass
	var damage_multiplier := maxf(
		0.0,
		(1.0 + float(mastery_data.get("final_multiplier_per_level", 0.0)) * float(level_delta))
		* (1.0 + damage_bonus)
	)
	var mana_cost_multiplier := maxf(0.0, 1.0 - mana_reduction)
	var cooldown_multiplier := maxf(0.0, 1.0 - cooldown_reduction)
	if is_global:
		modifiers["global_mastery_id"] = mastery_id
	elif str(modifiers.get("mastery_id", "")) == "":
		modifiers["mastery_id"] = mastery_id
	modifiers["damage_multiplier"] = float(modifiers.get("damage_multiplier", 1.0)) * damage_multiplier
	modifiers["mana_cost_multiplier"] = float(modifiers.get("mana_cost_multiplier", 1.0)) * mana_cost_multiplier
	modifiers["cooldown_multiplier"] = float(modifiers.get("cooldown_multiplier", 1.0)) * cooldown_multiplier
	return modifiers


func _resolve_runtime_skill_data(
	target_skill_id: String, target_skill_data: Dictionary = {}
) -> Dictionary:
	var resolved_skill_data: Dictionary = target_skill_data.duplicate(true)
	if resolved_skill_data.is_empty():
		resolved_skill_data = GameDatabase.get_skill_data(target_skill_id)
	if resolved_skill_data.is_empty():
		var mapped_skill_id := get_skill_id_for_spell(target_skill_id)
		if mapped_skill_id != "" and mapped_skill_id != target_skill_id:
			resolved_skill_data = GameDatabase.get_skill_data(mapped_skill_id)
	return resolved_skill_data


func _resolve_runtime_skill_id(target_skill_id: String, resolved_skill_data: Dictionary) -> String:
	var resolved_skill_id := str(resolved_skill_data.get("skill_id", ""))
	if resolved_skill_id != "":
		return resolved_skill_id
	var mapped_skill_id := get_skill_id_for_spell(target_skill_id)
	if mapped_skill_id != "":
		return mapped_skill_id
	return target_skill_id


func resolve_runtime_school(
	target_skill_id: String = "", runtime_spell_id: String = "", school_hint: String = ""
) -> String:
	var resolved_spell_id := runtime_spell_id.strip_edges()
	var resolved_skill_id := target_skill_id.strip_edges()
	if resolved_spell_id == "" and resolved_skill_id != "":
		var direct_spell_data: Dictionary = GameDatabase.get_spell(resolved_skill_id)
		if not direct_spell_data.is_empty():
			resolved_spell_id = resolved_skill_id
	if resolved_spell_id != "":
		var spell_data: Dictionary = GameDatabase.get_spell(resolved_spell_id)
		var spell_school := str(spell_data.get("school", "")).strip_edges()
		if spell_school != "":
			return spell_school
		if resolved_skill_id == "":
			resolved_skill_id = get_skill_id_for_spell(resolved_spell_id)
	if resolved_skill_id != "":
		var skill_data: Dictionary = GameDatabase.get_skill_data(resolved_skill_id)
		var skill_element := str(skill_data.get("element", "")).strip_edges()
		if skill_element != "" and skill_element != "none":
			return skill_element
		var skill_school := str(skill_data.get("school", "")).strip_edges()
		if skill_school != "":
			return skill_school
	return school_hint.strip_edges()


func _mastery_applies_to_skill(
	mastery_data: Dictionary, target_skill_data: Dictionary, runtime_school: String
) -> bool:
	var target_skill_type := str(target_skill_data.get("skill_type", ""))
	if target_skill_type not in ["active", "deploy", "toggle"]:
		return false
	var applies_to_school := str(mastery_data.get("applies_to_school", ""))
	if applies_to_school != "" and applies_to_school != "all":
		var target_school := str(target_skill_data.get("school", ""))
		if target_school != applies_to_school:
			return false
	var applies_to_element := str(mastery_data.get("applies_to_element", ""))
	if applies_to_element != "" and applies_to_element != "all":
		var target_element := str(target_skill_data.get("element", runtime_school))
		if target_element != applies_to_element:
			return false
	return true


func _is_global_mastery_runtime_modifier(mastery_data: Dictionary) -> bool:
	var applies_to_school := str(mastery_data.get("applies_to_school", ""))
	var applies_to_element := str(mastery_data.get("applies_to_element", ""))
	return applies_to_school == "all" and applies_to_element == "all"


func consume_spell_cast(spell_id: String) -> void:
	if time_collapse_active and time_collapse_charges > 0:
		time_collapse_charges = max(time_collapse_charges - 1, 0)
		if time_collapse_charges == 0:
			push_message("타임 콜랩스의 무상 시전 창이 소진되었습니다.", 1.0)
	if _is_overclock_circuit_consumer_spell(spell_id):
		overclock_circuit_active = false
		overclock_circuit_timer = 0.0
	stats_changed.emit()


func register_skill_damage(spell_id: String, amount: float) -> void:
	var linked_skill_id: String = get_skill_id_for_spell(spell_id)
	var dealt: float = max(amount, 0.0)
	if dealt <= 0.0:
		return
	if linked_skill_id != "":
		_add_skill_experience(linked_skill_id, dealt)
	_add_skill_experience("arcane_magic_mastery", dealt)
	var school := resolve_runtime_school(linked_skill_id, spell_id)
	var mastery_id: String = str(SCHOOL_TO_MASTERY.get(school, ""))
	if mastery_id != "" and mastery_id != "arcane_magic_mastery":
		_add_skill_experience(mastery_id, dealt)
	if ashen_rite_active:
		ash_stacks = min(ash_stacks + 1, _get_ashen_rite_stack_cap())
	if linked_skill_id != "":
		spell_mastery[spell_id] = int(round(float(skill_experience.get(linked_skill_id, 0.0))))
		_sync_runtime_spell_level(spell_id)
	stats_changed.emit()


func get_dominant_school() -> String:
	var best_school := SCHOOL_ORDER[0]
	var best_value := -1
	for school in SCHOOL_ORDER:
		var value := int(resonance.get(school, 0))
		if value > best_value:
			best_value = value
			best_school = school
	return best_school


func get_school_display_name(school: String) -> String:
	match school:
		"fire":
			return "화염"
		"ice":
			return "냉기"
		"lightning":
			return "전기"
		"wind":
			return "바람"
		"water":
			return "물"
		"plant":
			return "자연"
		"earth":
			return "대지"
		"holy":
			return "성광"
		"dark":
			return "암흑"
		"arcane":
			return "아케인"
		_:
			return school


func get_room_variant(room_id: String) -> Dictionary:
	var dominant := get_dominant_school()
	var variant := {"tint": Color("#ffffff"), "extra_spawns": [], "label": ""}
	match dominant:
		"fire":
			variant.tint = Color("#2b1710")
			variant.extra_spawns = [{"type": "ranged", "position": [1360, 300]}]
			variant.label = "화염 공명이 불안정한 감시자를 끌어당깁니다."
		"ice":
			variant.tint = Color("#0d2836")
			variant.extra_spawns = [{"type": "brute", "position": [1280, 600]}]
			variant.label = "냉기 공명이 방을 무겁고 둔한 저항으로 채웁니다."
		"lightning":
			variant.tint = Color("#2a2b10")
			variant.extra_spawns = [
				{"type": "ranged", "position": [900, 260]},
				{"type": "brute", "position": [1420, 600]}
			]
			variant.label = "전기 공명이 미궁 전체를 예민하게 흔듭니다."
	return variant


func mark_echo_seen(echo_id: String) -> void:
	seen_echoes[echo_id] = true
	save_to_disk()


func has_seen_echo(echo_id: String) -> bool:
	return seen_echoes.get(echo_id, false)


func mark_room_text_seen(room_id: String) -> void:
	seen_room_texts[room_id] = true
	save_to_disk()


func has_seen_room_text(room_id: String) -> bool:
	return seen_room_texts.get(room_id, false)


func push_message(text: String, duration: float = 2.0) -> void:
	ui_message = text
	ui_message_time = duration
	ui_message_changed.emit(text, duration)


func save_to_disk() -> void:
	var payload := _build_save_payload()
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(payload))


func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var raw := FileAccess.get_file_as_string(SAVE_PATH)
	var parsed = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	_load_save_payload(parsed)


func _build_save_payload() -> Dictionary:
	_initialize_spell_hotbar()
	var hotbar_snapshot: Array = spell_hotbar.duplicate(true)
	ensure_input_map()
	var visible_shortcut_snapshot: Array = _build_visible_hotbar_shortcut_payload()
	spell_hotbar = hotbar_snapshot.duplicate(true)
	var payload := _combat_state.build_resource_save_payload()
	payload["current_room_id"] = current_room_id
	payload["save_room_id"] = save_room_id
	payload["save_spawn_x"] = save_spawn_position.x
	payload["save_spawn_y"] = save_spawn_position.y
	payload["core_activated"] = core_activated
	payload["boss_defeated"] = boss_defeated
	payload["progression_flags"] = progression_flags
	payload["seen_room_texts"] = seen_room_texts
	payload["seen_echoes"] = seen_echoes
	payload.merge(
		{
			"spell_mastery": spell_mastery,
			"spell_level": spell_level,
			"skill_experience": skill_experience,
			"skill_level_data": skill_level_data,
			"spell_hotbar": _build_hotbar_save_slice_from_source(
				hotbar_snapshot,
				0,
				VISIBLE_HOTBAR_SLOT_COUNT
			),
			LEGACY_HOTBAR_TAIL_SAVE_KEY: _build_hotbar_save_slice_from_source(
				hotbar_snapshot,
				VISIBLE_HOTBAR_SLOT_COUNT,
				DEFAULT_SPELL_HOTBAR.size() - VISIBLE_HOTBAR_SLOT_COUNT
			),
			VISIBLE_HOTBAR_SHORTCUT_SAVE_KEY: visible_shortcut_snapshot,
			ACTION_HOTKEY_REGISTRY_SAVE_KEY: get_action_hotkey_registry_save_payload(),
			"equipped_items": equipped_items,
			"equipment_inventory": equipment_inventory,
			"consumable_inventory": consumable_inventory,
			"other_inventory": other_inventory,
			"current_equipment_preset": current_equipment_preset,
			"resonance": resonance,
			"last_spell_school": last_spell_school
		}
	)
	return payload


func _load_save_payload(parsed: Dictionary) -> void:
	_combat_state.load_resource_save_payload(parsed)
	_progress_state.load_save_payload(parsed)
	spell_mastery = parsed.get("spell_mastery", spell_mastery)
	spell_level = parsed.get("spell_level", spell_level)
	skill_experience = parsed.get("skill_experience", skill_experience)
	skill_level_data = parsed.get("skill_level_data", skill_level_data)
	visible_hotbar_shortcuts = _restore_visible_hotbar_shortcuts(
		parsed.get(VISIBLE_HOTBAR_SHORTCUT_SAVE_KEY, [])
	)
	spell_hotbar = _restore_saved_spell_hotbar(
		parsed.get("spell_hotbar", spell_hotbar),
		parsed.get(LEGACY_HOTBAR_TAIL_SAVE_KEY, [])
	)
	action_hotkey_registry = _restore_action_hotkey_registry(
		parsed.get(ACTION_HOTKEY_REGISTRY_SAVE_KEY, [])
	)
	equipped_items = parsed.get("equipped_items", equipped_items)
	equipment_inventory = parsed.get("equipment_inventory", equipment_inventory)
	consumable_inventory = parsed.get("consumable_inventory", consumable_inventory)
	other_inventory = parsed.get("other_inventory", other_inventory)
	current_equipment_preset = str(parsed.get("current_equipment_preset", current_equipment_preset))
	resonance = parsed.get("resonance", resonance)
	last_spell_school = str(parsed.get("last_spell_school", last_spell_school))
	_initialize_spell_hotbar()
	_initialize_action_hotkey_registry()
	if visible_hotbar_shortcuts.is_empty():
		visible_hotbar_shortcuts = _build_legacy_visible_hotbar_shortcut_payload()
	ensure_input_map()
	_initialize_equipment_state()
	_initialize_stackable_inventory_state()
	_recalculate_derived_stats(false)


func _build_hotbar_save_slice(start_index: int, slot_count: int) -> Array:
	_initialize_spell_hotbar()
	return _build_hotbar_save_slice_from_source(spell_hotbar, start_index, slot_count)


func _build_hotbar_save_slice_from_source(source_hotbar: Array, start_index: int, slot_count: int) -> Array:
	var saved_slice: Array = []
	var max_index: int = mini(start_index + slot_count, source_hotbar.size())
	for i in range(start_index, max_index):
		if typeof(source_hotbar[i]) != TYPE_DICTIONARY:
			continue
		saved_slice.append((source_hotbar[i] as Dictionary).duplicate(true))
	return saved_slice


func _restore_saved_spell_hotbar(saved_hotbar_value, saved_legacy_tail_value) -> Array:
	var restored_hotbar: Array = get_default_spell_hotbar_template()
	if typeof(saved_hotbar_value) == TYPE_ARRAY:
		var saved_hotbar: Array = saved_hotbar_value
		if saved_hotbar.size() > VISIBLE_HOTBAR_SLOT_COUNT:
			return saved_hotbar.duplicate(true)
		_apply_saved_hotbar_slice(restored_hotbar, saved_hotbar, 0)
	if typeof(saved_legacy_tail_value) == TYPE_ARRAY:
		_apply_saved_hotbar_slice(
			restored_hotbar,
			saved_legacy_tail_value,
			VISIBLE_HOTBAR_SLOT_COUNT
		)
	return restored_hotbar


func _apply_saved_hotbar_slice(restored_hotbar: Array, saved_slice: Array, start_index: int) -> void:
	var max_count: int = mini(saved_slice.size(), restored_hotbar.size() - start_index)
	for i in range(max_count):
		if typeof(saved_slice[i]) != TYPE_DICTIONARY:
			continue
		var target_index := start_index + i
		var restored_slot: Dictionary = restored_hotbar[target_index]
		var saved_slot: Dictionary = saved_slice[i]
		var saved_action := str(saved_slot.get("action", ""))
		var saved_label := str(saved_slot.get("label", ""))
		if saved_action != "":
			restored_slot["action"] = saved_action
		if saved_label != "":
			restored_slot["label"] = saved_label
		restored_slot["skill_id"] = str(saved_slot.get("skill_id", ""))
		restored_hotbar[target_index] = restored_slot


func _build_visible_hotbar_shortcut_payload() -> Array:
	_initialize_spell_hotbar()
	var payload: Array = []
	var visible_count: int = mini(VISIBLE_HOTBAR_SLOT_COUNT, spell_hotbar.size())
	for i in range(visible_count):
		var slot: Dictionary = spell_hotbar[i]
		var action := str(slot.get("action", ""))
		if action == "":
			continue
		payload.append(
			{
				"slot_index": i,
				"action": action,
				"keycode": _get_action_primary_physical_keycode(
					action,
					_get_default_visible_hotbar_keycode(action)
				)
			}
		)
	return payload


func _restore_visible_hotbar_shortcuts(saved_value) -> Array:
	if typeof(saved_value) != TYPE_ARRAY:
		return []
	var default_hotbar: Array = get_default_spell_hotbar_template()
	var restored: Array = []
	var saved_shortcuts: Array = saved_value
	for raw_value in saved_shortcuts:
		if typeof(raw_value) != TYPE_DICTIONARY:
			continue
		var shortcut: Dictionary = raw_value
		var slot_index: int = int(shortcut.get("slot_index", -1))
		if slot_index < 0 or slot_index >= VISIBLE_HOTBAR_SLOT_COUNT:
			continue
		var default_action := str(default_hotbar[slot_index].get("action", ""))
		var action := str(shortcut.get("action", default_action))
		var keycode: int = int(shortcut.get("keycode", 0))
		if action == "" or keycode <= 0:
			continue
		restored.append({"slot_index": slot_index, "action": action, "keycode": keycode})
	return restored


func _build_legacy_visible_hotbar_shortcut_payload() -> Array:
	_initialize_spell_hotbar()
	var restored: Array = []
	var visible_count: int = mini(VISIBLE_HOTBAR_SLOT_COUNT, spell_hotbar.size())
	for i in range(visible_count):
		var slot: Dictionary = spell_hotbar[i]
		var action := str(slot.get("action", ""))
		if action == "":
			continue
		var label := str(slot.get("label", ""))
		var keycode: int = _parse_hotbar_label_to_keycode(label)
		if keycode <= 0:
			keycode = _get_default_visible_hotbar_keycode(action)
		if keycode <= 0:
			continue
		restored.append({"slot_index": i, "action": action, "keycode": keycode})
	return restored


func _restore_action_hotkey_registry(saved_value) -> Array:
	var defaults: Array = get_default_action_hotkey_registry_template()
	if typeof(saved_value) != TYPE_ARRAY:
		return defaults
	var restored: Array = []
	var saved_entries: Dictionary = {}
	for raw_value in saved_value:
		if typeof(raw_value) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = raw_value
		var action := str(entry.get("action", ""))
		if action == "":
			continue
		saved_entries[action] = entry
	for default_value in defaults:
		var slot: Dictionary = (default_value as Dictionary).duplicate(true)
		var action := str(slot.get("action", ""))
		if saved_entries.has(action):
			var saved_slot: Dictionary = saved_entries[action]
			var normalized_skill_id := get_runtime_castable_hotbar_skill_id(str(saved_slot.get("skill_id", "")))
			if normalized_skill_id != "":
				slot["skill_id"] = normalized_skill_id
			elif str(saved_slot.get("skill_id", "")) == "":
				slot["skill_id"] = ""
		restored.append(slot)
	return restored


func _apply_action_hotkey_registry_to_input_map() -> void:
	_initialize_action_hotkey_registry()
	for entry_value in action_hotkey_registry:
		var entry: Dictionary = entry_value
		var action := str(entry.get("action", ""))
		var keycode: int = int(entry.get("keycode", 0))
		if action == "" or keycode <= 0:
			continue
		_set_action_primary_physical_keycode(action, keycode)


func _parse_hotbar_label_to_keycode(label: String) -> int:
	var normalized_label := label.strip_edges().to_upper()
	if normalized_label == "":
		return 0
	return int(OS.find_keycode_from_string(normalized_label))


func _apply_visible_hotbar_shortcuts_to_input_map() -> void:
	if visible_hotbar_shortcuts.is_empty():
		return
	_initialize_spell_hotbar()
	for shortcut_value in visible_hotbar_shortcuts:
		var shortcut: Dictionary = shortcut_value
		var slot_index: int = int(shortcut.get("slot_index", -1))
		if slot_index < 0 or slot_index >= mini(VISIBLE_HOTBAR_SLOT_COUNT, spell_hotbar.size()):
			continue
		var action := str(shortcut.get("action", ""))
		var keycode: int = int(shortcut.get("keycode", 0))
		if action == "" or keycode <= 0:
			continue
		_set_action_primary_physical_keycode(action, keycode)
		var slot: Dictionary = spell_hotbar[slot_index]
		slot["label"] = _format_hotbar_key_label(keycode)
		spell_hotbar[slot_index] = slot


func _reset_visible_hotbar_shortcuts_to_default(persist: bool) -> void:
	_initialize_spell_hotbar()
	ensure_input_map()
	var default_hotbar: Array = get_default_spell_hotbar_template()
	var visible_count: int = mini(VISIBLE_HOTBAR_SLOT_COUNT, spell_hotbar.size())
	for i in range(visible_count):
		var slot: Dictionary = spell_hotbar[i]
		var action := str(slot.get("action", ""))
		var default_keycode: int = _get_default_visible_hotbar_keycode(action)
		if action == "" or default_keycode <= 0:
			continue
		_set_action_primary_physical_keycode(action, default_keycode)
		slot["label"] = str(default_hotbar[i].get("label", _format_hotbar_key_label(default_keycode)))
		spell_hotbar[i] = slot
	visible_hotbar_shortcuts = _build_visible_hotbar_shortcut_payload()
	if persist:
		save_to_disk()
		stats_changed.emit()


func _get_default_visible_hotbar_keycode(action: String) -> int:
	return int(get_default_visible_hotbar_keycode_map().get(action, 0))


func _get_action_primary_physical_keycode(action: String, fallback_keycode: int = 0) -> int:
	if not InputMap.has_action(action):
		return fallback_keycode
	for event_value in InputMap.action_get_events(action):
		var key_event := event_value as InputEventKey
		if key_event == null:
			continue
		if key_event.physical_keycode != 0:
			return int(key_event.physical_keycode)
		if key_event.keycode != 0:
			return int(key_event.keycode)
	return fallback_keycode


func _set_action_primary_physical_keycode(action: String, keycode: int) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_erase_events(action)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)


func _find_visible_hotbar_slot_by_keycode(keycode: int, excluded_slot_index: int = -1) -> int:
	_initialize_spell_hotbar()
	var visible_count: int = mini(VISIBLE_HOTBAR_SLOT_COUNT, spell_hotbar.size())
	for i in range(visible_count):
		if i == excluded_slot_index:
			continue
		var slot: Dictionary = spell_hotbar[i]
		var action := str(slot.get("action", ""))
		if action == "":
			continue
		if _get_action_primary_physical_keycode(action, _get_default_visible_hotbar_keycode(action)) == keycode:
			return i
	return -1


func _format_hotbar_key_label(keycode: int) -> String:
	var key_name := OS.get_keycode_string(keycode)
	if key_name == "":
		return "?"
	return key_name.to_upper()


func _add_action(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	if InputMap.action_get_events(action).is_empty():
		for keycode in keys:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action, event)


func get_skill_id_for_spell(spell_id: String) -> String:
	var mapped: String = GameDatabase.get_skill_id_for_runtime_spell(spell_id)
	if mapped != "":
		return mapped
	var direct_skill: Dictionary = GameDatabase.get_skill_data(spell_id)
	if not direct_skill.is_empty():
		return str(direct_skill.get("skill_id", spell_id))
	return ""


func get_spell_level(spell_id: String) -> int:
	return int(spell_level.get(spell_id, 1))


func get_spell_hotbar() -> Array:
	_initialize_spell_hotbar()
	return spell_hotbar.duplicate(true)


func get_visible_spell_hotbar() -> Array:
	_initialize_spell_hotbar()
	var visible: Array = []
	var visible_count: int = mini(VISIBLE_HOTBAR_SLOT_COUNT, spell_hotbar.size())
	for i in range(visible_count):
		visible.append((spell_hotbar[i] as Dictionary).duplicate(true))
	return visible


func get_visible_hotbar_shortcuts() -> Array:
	ensure_input_map()
	return _build_visible_hotbar_shortcut_payload()


func get_hotbar_preset_ids() -> Array[String]:
	var preset_ids: Array[String] = []
	for raw_preset_id in HOTBAR_PRESET_IDS:
		preset_ids.append(str(raw_preset_id))
	return preset_ids


func get_hotbar_preset_catalog() -> Array[Dictionary]:
	var catalog: Array[Dictionary] = []
	for preset_id in get_hotbar_preset_ids():
		catalog.append(
			{
				"preset_id": preset_id,
				"label": get_hotbar_preset_label(preset_id),
				"slots": get_hotbar_preset_data(preset_id)
			}
		)
	return catalog


func get_next_hotbar_preset_id(current_preset_id: String) -> String:
	var preset_ids: Array[String] = get_hotbar_preset_ids()
	if preset_ids.is_empty():
		return ""
	var current_index := preset_ids.find(current_preset_id)
	if current_index == -1:
		return preset_ids[0]
	return preset_ids[posmod(current_index + 1, preset_ids.size())]


func resolve_current_hotbar_preset_id() -> String:
	_initialize_spell_hotbar()
	for preset_id in get_hotbar_preset_ids():
		var preset_slots: Array[String] = get_hotbar_preset_data(preset_id)
		if preset_slots.is_empty():
			continue
		var matches := true
		var slot_count := mini(preset_slots.size(), spell_hotbar.size())
		for i in range(slot_count):
			var current_skill_id := str((spell_hotbar[i] as Dictionary).get("skill_id", ""))
			if current_skill_id != str(preset_slots[i]):
				matches = false
				break
		if matches:
			return preset_id
	return ""


func get_hotbar_preset_state() -> Dictionary:
	var current_preset_id := resolve_current_hotbar_preset_id()
	var next_preset_id := get_next_hotbar_preset_id(current_preset_id)
	return {
		"catalog": get_hotbar_preset_catalog(),
		"current_preset_id": current_preset_id,
		"current_label": get_hotbar_preset_label(current_preset_id),
		"next_preset_id": next_preset_id,
		"next_label": get_hotbar_preset_label(next_preset_id)
	}


func get_hotbar_preset_label(preset_id: String) -> String:
	var preset_definition: Dictionary = HOTBAR_PRESET_DEFINITIONS.get(preset_id, {})
	return str(preset_definition.get("label", ""))


func get_hotbar_preset_data(preset_id: String) -> Array[String]:
	var preset_definition: Dictionary = HOTBAR_PRESET_DEFINITIONS.get(preset_id, {})
	var normalized_slots: Array[String] = []
	var raw_slots: Array = preset_definition.get("slots", [])
	for raw_skill_id in raw_slots:
		var skill_id := str(raw_skill_id)
		if skill_id == "":
			normalized_slots.append("")
			continue
		var runtime_castable_id := get_runtime_castable_hotbar_skill_id(skill_id)
		if runtime_castable_id == "":
			push_warning("Hotbar preset '%s' contains non-castable skill id '%s'." % [preset_id, skill_id])
			normalized_slots.append("")
			continue
		normalized_slots.append(runtime_castable_id)
	return normalized_slots


func apply_hotbar_preset(preset_id: String) -> bool:
	var preset_slots: Array[String] = get_hotbar_preset_data(preset_id)
	if preset_slots.is_empty():
		return false
	var slot_count: int = mini(preset_slots.size(), get_spell_hotbar().size())
	for i in range(slot_count):
		var preset_skill_id := preset_slots[i]
		if preset_skill_id == "":
			continue
		if not set_hotbar_skill(i, preset_skill_id):
			return false
	return true


func apply_next_hotbar_preset() -> String:
	var next_preset_id := str(get_hotbar_preset_state().get("next_preset_id", ""))
	if next_preset_id == "":
		return ""
	if not apply_hotbar_preset(next_preset_id):
		return ""
	return next_preset_id


func get_default_spell_hotbar_template() -> Array:
	return DEFAULT_SPELL_HOTBAR.duplicate(true)


func get_default_visible_hotbar_keycode_map() -> Dictionary:
	return DEFAULT_VISIBLE_HOTBAR_KEYCODES.duplicate(true)


func get_default_action_hotkey_registry_template() -> Array:
	return DEFAULT_ACTION_HOTKEY_REGISTRY.duplicate(true)


func get_action_hotkey_registry() -> Array:
	_initialize_spell_hotbar()
	_initialize_action_hotkey_registry()
	var registry: Array = []
	for slot_index in range(spell_hotbar.size()):
		var slot: Dictionary = (spell_hotbar[slot_index] as Dictionary).duplicate(true)
		slot["registry_index"] = slot_index
		slot["group"] = "hotbar"
		slot["keycode"] = _get_action_primary_physical_keycode(
			str(slot.get("action", "")),
			_parse_hotbar_label_to_keycode(str(slot.get("label", "")))
		)
		registry.append(slot)
	for registry_index in range(action_hotkey_registry.size()):
		var entry: Dictionary = (action_hotkey_registry[registry_index] as Dictionary).duplicate(true)
		entry["registry_index"] = spell_hotbar.size() + registry_index
		entry["group"] = "extended"
		registry.append(entry)
	return registry


func get_action_hotkey_registry_save_payload() -> Array:
	_initialize_action_hotkey_registry()
	var payload: Array = []
	for entry_value in action_hotkey_registry:
		var entry: Dictionary = entry_value
		payload.append(
			{
				"action": str(entry.get("action", "")),
				"skill_id": str(entry.get("skill_id", "")),
				"label": str(entry.get("label", "")),
				"keycode": int(entry.get("keycode", 0))
			}
		)
	return payload


func get_action_hotkey_labels_for_skill(skill_id: String) -> Array[String]:
	var normalized_skill_id := get_runtime_castable_hotbar_skill_id(skill_id)
	if normalized_skill_id == "":
		normalized_skill_id = skill_id
	var labels: Array[String] = []
	for entry_value in get_action_hotkey_registry():
		var entry: Dictionary = entry_value
		if str(entry.get("skill_id", "")) == normalized_skill_id:
			labels.append(str(entry.get("label", "")))
	return labels


func set_action_hotkey_skill(action: String, skill_id: String) -> bool:
	_initialize_spell_hotbar()
	_initialize_action_hotkey_registry()
	var normalized_skill_id := ""
	if skill_id != "":
		normalized_skill_id = get_runtime_castable_hotbar_skill_id(skill_id)
		if normalized_skill_id == "":
			return false
	var hotbar_slot_index := _find_hotbar_slot_index_by_action(action)
	if hotbar_slot_index != -1:
		return set_hotbar_skill(hotbar_slot_index, normalized_skill_id)
	for entry_index in range(action_hotkey_registry.size()):
		var entry: Dictionary = action_hotkey_registry[entry_index]
		if str(entry.get("action", "")) != action:
			continue
		entry["skill_id"] = normalized_skill_id
		action_hotkey_registry[entry_index] = entry
		save_to_disk()
		stats_changed.emit()
		return true
	return false


func clear_action_hotkey_skill(action: String) -> bool:
	return set_action_hotkey_skill(action, "")


func get_action_hotkey_slot(action: String) -> Dictionary:
	for entry_value in get_action_hotkey_registry():
		var entry: Dictionary = entry_value
		if str(entry.get("action", "")) == action:
			return entry
	return {}


func _find_hotbar_slot_index_by_action(action: String) -> int:
	_initialize_spell_hotbar()
	for slot_index in range(spell_hotbar.size()):
		var slot: Dictionary = spell_hotbar[slot_index]
		if str(slot.get("action", "")) == action:
			return slot_index
	return -1


func get_equipment_preset_ids() -> Array[String]:
	var preset_ids: Array[String] = []
	for raw_preset_id in EQUIPMENT_PRESET_IDS:
		preset_ids.append(str(raw_preset_id))
	return preset_ids


func get_equipment_preset_catalog() -> Array[Dictionary]:
	var catalog: Array[Dictionary] = []
	for preset_id in get_equipment_preset_ids():
		catalog.append(
			{
				"preset_id": preset_id,
				"label": get_equipment_preset_label(preset_id),
				"equipment": get_equipment_preset_data(preset_id)
			}
		)
	return catalog


func get_admin_equipment_preset_ids() -> Array[String]:
	var preset_ids: Array[String] = []
	for raw_preset_id in ADMIN_EQUIPMENT_PRESET_IDS:
		preset_ids.append(str(raw_preset_id))
	return preset_ids


func get_admin_equipment_preset_catalog() -> Array[Dictionary]:
	var catalog: Array[Dictionary] = []
	for preset_id in get_admin_equipment_preset_ids():
		catalog.append(
			{
				"preset_id": preset_id,
				"label": get_equipment_preset_label(preset_id),
				"equipment": get_equipment_preset_data(preset_id)
			}
		)
	return catalog


func get_next_admin_equipment_preset_id(current_preset_id: String) -> String:
	var preset_ids: Array[String] = get_admin_equipment_preset_ids()
	if preset_ids.is_empty():
		return ""
	var current_index := preset_ids.find(current_preset_id)
	if current_index == -1:
		return preset_ids[0]
	return preset_ids[posmod(current_index + 1, preset_ids.size())]


func resolve_current_admin_equipment_preset_id() -> String:
	var equipped_items: Dictionary = get_equipped_items()
	for preset_id in get_admin_equipment_preset_ids():
		var preset_data: Dictionary = get_equipment_preset_data(preset_id)
		if preset_data.is_empty():
			continue
		var matches := true
		for slot_name in preset_data.keys():
			if str(equipped_items.get(str(slot_name), "")) != str(preset_data.get(slot_name, "")):
				matches = false
				break
		if matches:
			return preset_id
	return ""


func get_admin_equipment_preset_state() -> Dictionary:
	var current_preset_id := resolve_current_admin_equipment_preset_id()
	var next_preset_id := get_next_admin_equipment_preset_id(current_preset_id)
	return {
		"catalog": get_admin_equipment_preset_catalog(),
		"current_preset_id": current_preset_id,
		"current_label": get_equipment_preset_label(current_preset_id),
		"next_preset_id": next_preset_id,
		"next_label": get_equipment_preset_label(next_preset_id)
	}


func apply_next_admin_equipment_preset() -> String:
	var next_preset_id := str(get_admin_equipment_preset_state().get("next_preset_id", ""))
	if next_preset_id == "":
		return ""
	apply_equipment_preset(next_preset_id)
	return next_preset_id


func get_equipment_preset_label(preset_id: String) -> String:
	return str(EQUIPMENT_PRESET_LABELS.get(preset_id, ""))


func get_equipment_preset_data(preset_id: String) -> Dictionary:
	if not EQUIPMENT_PRESETS.has(preset_id):
		return {}
	return (EQUIPMENT_PRESETS[preset_id] as Dictionary).duplicate(true)


func get_registered_buff_skill_ids() -> Array[String]:
	var buff_skill_ids: Array[String] = []
	for skill in GameDatabase.get_all_skills():
		var skill_type := str(skill.get("skill_type", ""))
		if skill_type != "buff":
			continue
		var skill_id := str(skill.get("skill_id", ""))
		if skill_id == "":
			continue
		buff_skill_ids.append(skill_id)
	return buff_skill_ids


func set_visible_hotbar_shortcut(slot_index: int, keycode: int) -> bool:
	_initialize_spell_hotbar()
	ensure_input_map()
	if slot_index < 0 or slot_index >= mini(VISIBLE_HOTBAR_SLOT_COUNT, spell_hotbar.size()):
		return false
	if keycode <= 0:
		return false
	var slot: Dictionary = spell_hotbar[slot_index]
	var action := str(slot.get("action", ""))
	if action == "":
		return false
	var current_keycode: int = _get_action_primary_physical_keycode(
		action,
		_get_default_visible_hotbar_keycode(action)
	)
	var conflicting_slot_index := _find_visible_hotbar_slot_by_keycode(keycode, slot_index)
	if conflicting_slot_index != -1:
		var conflicting_slot: Dictionary = spell_hotbar[conflicting_slot_index]
		var conflicting_action := str(conflicting_slot.get("action", ""))
		if conflicting_action != "":
			_set_action_primary_physical_keycode(conflicting_action, current_keycode)
			conflicting_slot["label"] = _format_hotbar_key_label(current_keycode)
			spell_hotbar[conflicting_slot_index] = conflicting_slot
	_set_action_primary_physical_keycode(action, keycode)
	slot["label"] = _format_hotbar_key_label(keycode)
	spell_hotbar[slot_index] = slot
	visible_hotbar_shortcuts = _build_visible_hotbar_shortcut_payload()
	save_to_disk()
	stats_changed.emit()
	return true


func reset_visible_hotbar_shortcuts_to_default() -> void:
	_reset_visible_hotbar_shortcuts_to_default(true)


func get_hotbar_slot(slot_index: int) -> Dictionary:
	_initialize_spell_hotbar()
	if slot_index < 0 or slot_index >= spell_hotbar.size():
		return {}
	return (spell_hotbar[slot_index] as Dictionary).duplicate(true)


func get_runtime_castable_hotbar_skill_id(skill_id: String) -> String:
	return GameDatabase.get_runtime_castable_skill_id(skill_id)


func set_hotbar_skill(slot_index: int, skill_id: String) -> bool:
	_initialize_spell_hotbar()
	if slot_index < 0 or slot_index >= spell_hotbar.size():
		return false
	var normalized_skill_id := ""
	if skill_id != "":
		normalized_skill_id = get_runtime_castable_hotbar_skill_id(skill_id)
		if normalized_skill_id == "":
			return false
	var slot: Dictionary = spell_hotbar[slot_index]
	slot["skill_id"] = normalized_skill_id
	spell_hotbar[slot_index] = slot
	save_to_disk()
	stats_changed.emit()
	return true


func clear_hotbar_skill(slot_index: int) -> bool:
	return set_hotbar_skill(slot_index, "")


func swap_hotbar_skills(first_index: int, second_index: int) -> bool:
	_initialize_spell_hotbar()
	if first_index < 0 or first_index >= spell_hotbar.size():
		return false
	if second_index < 0 or second_index >= spell_hotbar.size():
		return false
	if first_index == second_index:
		return true
	var first_slot: Dictionary = spell_hotbar[first_index]
	var second_slot: Dictionary = spell_hotbar[second_index]
	var first_skill_id := str(first_slot.get("skill_id", ""))
	var second_skill_id := str(second_slot.get("skill_id", ""))
	if first_skill_id == second_skill_id:
		return true
	first_slot["skill_id"] = second_skill_id
	second_slot["skill_id"] = first_skill_id
	spell_hotbar[first_index] = first_slot
	spell_hotbar[second_index] = second_slot
	save_to_disk()
	stats_changed.emit()
	return true


func apply_equipment_preset(preset_id: String) -> bool:
	if not EQUIPMENT_PRESETS.has(preset_id):
		return false
	equipped_items = EQUIPMENT_PRESETS[preset_id].duplicate(true)
	current_equipment_preset = preset_id
	_recalculate_derived_stats()
	save_to_disk()
	stats_changed.emit()
	return true


func get_equipped_items() -> Dictionary:
	_initialize_equipment_state()
	return equipped_items.duplicate(true)


func get_equipment_inventory() -> Array:
	_initialize_equipment_state()
	var occupied_items: Array = []
	for item_value in equipment_inventory:
		var item_id := str(item_value)
		if item_id == "":
			continue
		occupied_items.append(item_id)
	return occupied_items


func get_equipment_inventory_capacity() -> int:
	return EQUIPMENT_INVENTORY_SLOT_COUNT


func get_equipment_inventory_occupied_count() -> int:
	_initialize_equipment_state()
	var total := 0
	for item_value in equipment_inventory:
		if str(item_value) != "":
			total += 1
	return total


func get_equipment_inventory_item_at(slot_index: int) -> String:
	_initialize_equipment_state()
	if slot_index < 0 or slot_index >= EQUIPMENT_INVENTORY_SLOT_COUNT:
		return ""
	return str(equipment_inventory[slot_index])


func get_equipment_inventory_for_slot(slot_name: String) -> Array:
	var filtered_inventory: Array = []
	for item_value in equipment_inventory:
		var item_id := str(item_value)
		var item: Dictionary = GameDatabase.get_equipment(item_id)
		if item.is_empty():
			continue
		if str(item.get("slot_type", "")) == slot_name:
			filtered_inventory.append(item_id)
	return filtered_inventory


func has_equipment_in_inventory(item_id: String) -> bool:
	return find_equipment_inventory_slot_by_item(item_id) != -1


func find_equipment_inventory_slot_by_item(item_id: String) -> int:
	_initialize_equipment_state()
	if item_id == "":
		return -1
	for slot_index in range(equipment_inventory.size()):
		if str(equipment_inventory[slot_index]) == item_id:
			return slot_index
	return -1


func grant_equipment_item(item_id: String) -> bool:
	_initialize_equipment_state()
	if item_id == "":
		return false
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return false
	var empty_slot_index := _find_first_empty_equipment_inventory_slot()
	if empty_slot_index == -1:
		return false
	equipment_inventory[empty_slot_index] = item_id
	save_to_disk()
	stats_changed.emit()
	return true


func swap_equipment_inventory_items(first_index: int, second_index: int) -> bool:
	_initialize_equipment_state()
	if first_index < 0 or first_index >= EQUIPMENT_INVENTORY_SLOT_COUNT:
		return false
	if second_index < 0 or second_index >= EQUIPMENT_INVENTORY_SLOT_COUNT:
		return false
	if first_index == second_index:
		return true
	var first_item_id := str(equipment_inventory[first_index])
	var second_item_id := str(equipment_inventory[second_index])
	equipment_inventory[first_index] = second_item_id
	equipment_inventory[second_index] = first_item_id
	save_to_disk()
	stats_changed.emit()
	return true


func move_equipment_inventory_item(source_index: int, target_index: int) -> bool:
	_initialize_equipment_state()
	if source_index < 0 or source_index >= EQUIPMENT_INVENTORY_SLOT_COUNT:
		return false
	if target_index < 0 or target_index >= EQUIPMENT_INVENTORY_SLOT_COUNT:
		return false
	if source_index == target_index:
		return true
	var moved_item_id := str(equipment_inventory[source_index])
	if moved_item_id == "":
		return false
	if str(equipment_inventory[target_index]) != "":
		return false
	equipment_inventory[target_index] = moved_item_id
	equipment_inventory[source_index] = ""
	save_to_disk()
	stats_changed.emit()
	return true


func organize_equipment_inventory() -> bool:
	_initialize_equipment_state()
	var before: Array = equipment_inventory.duplicate()
	var occupied_items := get_equipment_inventory()
	occupied_items.sort_custom(
		func(a: Variant, b: Variant) -> bool:
			var item_a: Dictionary = GameDatabase.get_equipment(str(a))
			var item_b: Dictionary = GameDatabase.get_equipment(str(b))
			var slot_order_a := int(
				EQUIPMENT_SLOT_SORT_ORDER.get(str(item_a.get("slot_type", "")), 999)
			)
			var slot_order_b := int(
				EQUIPMENT_SLOT_SORT_ORDER.get(str(item_b.get("slot_type", "")), 999)
			)
			if slot_order_a != slot_order_b:
				return slot_order_a < slot_order_b
			var rarity_a := int(
				EQUIPMENT_RARITY_SORT_ORDER.get(str(item_a.get("rarity", "common")), 0)
			)
			var rarity_b := int(
				EQUIPMENT_RARITY_SORT_ORDER.get(str(item_b.get("rarity", "common")), 0)
			)
			if rarity_a != rarity_b:
				return rarity_a > rarity_b
			return _get_equipment_display_name(str(a)).naturalnocasecmp_to(
				_get_equipment_display_name(str(b))
			) < 0
	)
	equipment_inventory = occupied_items
	while equipment_inventory.size() < EQUIPMENT_INVENTORY_SLOT_COUNT:
		equipment_inventory.append("")
	if equipment_inventory == before:
		return false
	save_to_disk()
	stats_changed.emit()
	return true


func set_equipped_item(slot_name: String, item_id: String) -> bool:
	_initialize_equipment_state()
	if not equipped_items.has(slot_name):
		return false
	if item_id != "":
		var item: Dictionary = GameDatabase.get_equipment(item_id)
		if item.is_empty():
			return false
		if str(item.get("slot_type", "")) != slot_name:
			return false
	equipped_items[slot_name] = item_id
	current_equipment_preset = "custom"
	_recalculate_derived_stats()
	save_to_disk()
	stats_changed.emit()
	return true


func equip_inventory_item(slot_name: String, item_id: String) -> bool:
	_initialize_equipment_state()
	if not equipped_items.has(slot_name):
		return false
	var inventory_slot_index := find_equipment_inventory_slot_by_item(item_id)
	if inventory_slot_index == -1:
		return false
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return false
	if str(item.get("slot_type", "")) != slot_name:
		return false
	var current_item_id := str(equipped_items.get(slot_name, ""))
	equipment_inventory[inventory_slot_index] = current_item_id
	equipped_items[slot_name] = item_id
	current_equipment_preset = "custom"
	_recalculate_derived_stats()
	save_to_disk()
	stats_changed.emit()
	return true


func unequip_item_to_inventory(slot_name: String) -> bool:
	_initialize_equipment_state()
	if not equipped_items.has(slot_name):
		return false
	var current_item_id := str(equipped_items.get(slot_name, ""))
	if current_item_id == "":
		return false
	var empty_slot_index := _find_first_empty_equipment_inventory_slot()
	if empty_slot_index == -1:
		return false
	equipment_inventory[empty_slot_index] = current_item_id
	equipped_items[slot_name] = ""
	current_equipment_preset = "custom"
	_recalculate_derived_stats()
	save_to_disk()
	stats_changed.emit()
	return true


func get_equipment_summary() -> String:
	_initialize_equipment_state()
	var weapon_name := _get_equipment_display_name(str(equipped_items.get("weapon", "")))
	var offhand_name := _get_equipment_display_name(str(equipped_items.get("offhand", "")))
	var preset_label := str(EQUIPMENT_PRESET_LABELS.get(current_equipment_preset, current_equipment_preset))
	return "장비  %s / %s  프리셋:%s" % [weapon_name, offhand_name, preset_label]


func get_equipment_inventory_summary() -> String:
	var inventory_items := get_equipment_inventory()
	if inventory_items.is_empty():
		return "인벤토리  비어 있음"
	var preview_parts: Array[String] = []
	var preview_count := mini(inventory_items.size(), 4)
	for i in range(preview_count):
		var item_id := str(inventory_items[i])
		preview_parts.append(_get_equipment_display_name(item_id))
	var remainder := inventory_items.size() - preview_count
	var preview_text := ", ".join(preview_parts)
	if remainder > 0:
		preview_text += " +%d" % remainder
	return "인벤토리  %s" % preview_text


func get_equipment_slot_inventory_summary(slot_name: String) -> String:
	var slot_inventory: Array = get_equipment_inventory_for_slot(slot_name)
	if slot_inventory.is_empty():
		return "보유 장비  없음"
	var preview_parts: Array[String] = []
	var preview_count := mini(slot_inventory.size(), 3)
	for i in range(preview_count):
		var item_id := str(slot_inventory[i])
		preview_parts.append(_get_equipment_display_name(item_id))
	var remainder := slot_inventory.size() - preview_count
	var preview_text := ", ".join(preview_parts)
	if remainder > 0:
		preview_text += " +%d" % remainder
	return "보유 장비  %s" % preview_text


func get_consumable_inventory_occupied_count() -> int:
	return _get_stackable_inventory_occupied_count("consumable")


func get_other_inventory_occupied_count() -> int:
	return _get_stackable_inventory_occupied_count("other")


func get_consumable_inventory_item_at(slot_index: int) -> Dictionary:
	return _get_stackable_inventory_slot("consumable", slot_index)


func get_other_inventory_item_at(slot_index: int) -> Dictionary:
	return _get_stackable_inventory_slot("other", slot_index)


func grant_consumable_item(item_id: String, quantity: int = 1) -> bool:
	return _grant_stackable_inventory_item("consumable", item_id, quantity)


func grant_other_item(item_id: String, quantity: int = 1) -> bool:
	return _grant_stackable_inventory_item("other", item_id, quantity)


func apply_stackable_inventory_drag_drop(kind: String, source_index: int, target_index: int) -> bool:
	_initialize_stackable_inventory_state()
	if source_index < 0 or source_index >= STACKABLE_INVENTORY_SLOT_COUNT:
		return false
	if target_index < 0 or target_index >= STACKABLE_INVENTORY_SLOT_COUNT:
		return false
	if source_index == target_index:
		return true
	var inventory := _get_stackable_inventory_snapshot(kind)
	var source_slot := _normalize_stackable_slot_entry(inventory[source_index], kind)
	var target_slot := _normalize_stackable_slot_entry(inventory[target_index], kind)
	if _is_stackable_slot_empty(source_slot):
		return false
	var changed := false
	if _is_stackable_slot_empty(target_slot):
		inventory[target_index] = source_slot
		inventory[source_index] = _build_empty_stackable_slot()
		changed = true
	elif str(source_slot.get("item_id", "")) == str(target_slot.get("item_id", "")):
		var max_stack := _get_stackable_item_max_stack(kind, str(source_slot.get("item_id", "")))
		var target_count := int(target_slot.get("count", 0))
		var source_count := int(source_slot.get("count", 0))
		var transfer_count := mini(max_stack - target_count, source_count)
		if transfer_count <= 0:
			return false
		target_slot["count"] = target_count + transfer_count
		source_slot["count"] = source_count - transfer_count
		inventory[target_index] = target_slot
		inventory[source_index] = (
			_build_empty_stackable_slot() if int(source_slot.get("count", 0)) <= 0 else source_slot
		)
		changed = true
	else:
		inventory[source_index] = target_slot
		inventory[target_index] = source_slot
		changed = true
	if not changed:
		return false
	_set_stackable_inventory(kind, inventory)
	save_to_disk()
	stats_changed.emit()
	return true


func organize_stackable_inventory(kind: String) -> bool:
	_initialize_stackable_inventory_state()
	var before := _get_stackable_inventory_snapshot(kind)
	var occupied_slots: Array[Dictionary] = []
	for slot_value in before:
		var slot_entry := _normalize_stackable_slot_entry(slot_value, kind)
		if _is_stackable_slot_empty(slot_entry):
			continue
		occupied_slots.append(slot_entry)
	occupied_slots.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			var name_a := _get_stackable_item_display_name(kind, str(a.get("item_id", "")))
			var name_b := _get_stackable_item_display_name(kind, str(b.get("item_id", "")))
			var compare_result := name_a.naturalnocasecmp_to(name_b)
			if compare_result != 0:
				return compare_result < 0
			return int(a.get("count", 0)) > int(b.get("count", 0))
	)
	var normalized: Array = occupied_slots.duplicate(true)
	while normalized.size() < STACKABLE_INVENTORY_SLOT_COUNT:
		normalized.append(_build_empty_stackable_slot())
	if normalized == before:
		return false
	_set_stackable_inventory(kind, normalized)
	save_to_disk()
	stats_changed.emit()
	return true


func use_consumable_inventory_item(slot_index: int) -> bool:
	_initialize_stackable_inventory_state()
	if slot_index < 0 or slot_index >= STACKABLE_INVENTORY_SLOT_COUNT:
		return false
	var inventory := _get_stackable_inventory_snapshot("consumable")
	var slot_entry := _normalize_stackable_slot_entry(inventory[slot_index], "consumable")
	if _is_stackable_slot_empty(slot_entry):
		return false
	var item_id := str(slot_entry.get("item_id", ""))
	var item: Dictionary = GameDatabase.get_consumable_item(item_id)
	if item.is_empty():
		return false
	var effect: Dictionary = item.get("effect", {})
	var effect_type := str(effect.get("effect_type", ""))
	var consumed := false
	match effect_type:
		"restore_hp":
			consumed = apply_direct_heal(int(effect.get("amount", 0)), true) > 0
		"restore_mp":
			consumed = apply_direct_mana_restore(float(effect.get("amount", 0.0)), true) > 0.0
		"restore_hp_mp":
			var healed := apply_direct_heal(int(effect.get("hp_amount", 0)), true)
			var restored := apply_direct_mana_restore(float(effect.get("mp_amount", 0.0)), true)
			consumed = healed > 0 or restored > 0.0
		_:
			return false
	if not consumed:
		push_message("지금은 사용할 수 없습니다.", 0.8)
		return false
	var remaining := int(slot_entry.get("count", 0)) - 1
	if remaining <= 0:
		inventory[slot_index] = _build_empty_stackable_slot()
	else:
		slot_entry["count"] = remaining
		inventory[slot_index] = slot_entry
	_set_stackable_inventory("consumable", inventory)
	save_to_disk()
	stats_changed.emit()
	return true


func get_stackable_inventory_summary(kind: String) -> String:
	_initialize_stackable_inventory_state()
	var inventory := _get_stackable_inventory_snapshot(kind)
	var preview_parts: Array[String] = []
	var occupied_count := 0
	for slot_value in inventory:
		var slot_entry := _normalize_stackable_slot_entry(slot_value, kind)
		if _is_stackable_slot_empty(slot_entry):
			continue
		occupied_count += 1
		if preview_parts.size() >= 4:
			continue
		preview_parts.append(
			"%s x%d" % [
				_get_stackable_item_display_name(kind, str(slot_entry.get("item_id", ""))),
				int(slot_entry.get("count", 0))
			]
		)
	if preview_parts.is_empty():
		return "%s  비어 있음" % ("소비" if kind == "consumable" else "기타")
	var preview_text := ", ".join(preview_parts)
	var remainder := occupied_count - preview_parts.size()
	if remainder > 0:
		preview_text += " +%d" % remainder
	return "%s  %s" % [("소비" if kind == "consumable" else "기타"), preview_text]


func get_equipment_damage_multiplier(school: String) -> float:
	var total := 1.0 + _get_equipment_stat_total("magic_attack") * 0.03
	match school:
		"fire":
			total *= _get_equipment_stat_product("fire_damage_multiplier")
		"ice":
			total *= _get_equipment_stat_product("ice_damage_multiplier")
		"lightning":
			total *= _get_equipment_stat_product("lightning_damage_multiplier")
		"earth":
			total *= _get_equipment_stat_product("earth_damage_multiplier")
		"dark":
			total *= _get_equipment_stat_product("dark_damage_multiplier")
		"holy":
			total *= _get_equipment_stat_product("holy_damage_multiplier")
		"wind":
			total *= _get_equipment_stat_product("wind_damage_multiplier")
		"water":
			total *= _get_equipment_stat_product("water_damage_multiplier")
		"plant":
			total *= _get_equipment_stat_product("plant_damage_multiplier")
		"arcane":
			total *= _get_equipment_stat_product("arcane_damage_multiplier")
	if resonance_bonus_timer > 0.0 and resonance_bonus_school == school:
		total *= 1.10
	return total


func get_equipment_cooldown_multiplier() -> float:
	return maxf(0.65, 1.0 - _get_equipment_stat_total("cooldown_recovery"))


func get_equipment_damage_taken_multiplier() -> float:
	return maxf(0.6, _get_equipment_stat_product("damage_taken_multiplier"))


func get_equipment_bonus_max_health() -> int:
	return int(round(_get_equipment_stat_total("max_hp")))


func get_equipment_bonus_max_mana() -> float:
	return _get_equipment_stat_total("max_mp")


func get_equipment_bonus_mana_regen() -> float:
	return _get_equipment_stat_total("mp_regen")


func get_equipment_buff_duration_multiplier() -> float:
	return maxf(1.0, _get_equipment_stat_product("buff_duration_multiplier"))


func get_equipment_install_duration_multiplier() -> float:
	return maxf(1.0, _get_equipment_stat_product("installation_duration_multiplier"))


func get_equipment_aoe_multiplier() -> float:
	return maxf(1.0, _get_equipment_stat_product("aoe_radius_multiplier"))


func get_equipment_barrier_power_multiplier() -> float:
	return maxf(1.0, _get_equipment_stat_product("barrier_power_multiplier"))


func get_equipment_cast_speed_bonus() -> float:
	return _get_equipment_stat_total("cast_speed")


func get_equipment_projectile_speed_multiplier() -> float:
	return maxf(1.0, _get_equipment_stat_product("projectile_speed_multiplier"))


func get_equipment_projectile_count_bonus() -> int:
	return int(round(_get_equipment_stat_total("projectile_count_bonus")))


func get_skill_level(skill_id: String) -> int:
	var mapped_skill_id: String = get_skill_id_for_spell(skill_id)
	if mapped_skill_id != "":
		skill_id = mapped_skill_id
	return int(skill_level_data.get(skill_id, 1))


func set_skill_level(skill_id: String, level: int) -> bool:
	if skill_id == "":
		return false
	var mapped_skill_id: String = get_skill_id_for_spell(skill_id)
	if mapped_skill_id != "":
		skill_id = mapped_skill_id
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	if skill_data.is_empty():
		return false
	var clamped_level: int = clampi(level, 1, 30)
	skill_level_data[skill_id] = clamped_level
	skill_experience[skill_id] = _required_experience_for_level(clamped_level)
	for runtime_spell_id in GameDatabase.get_runtime_spell_ids_for_skill(skill_id):
		_sync_runtime_spell_level(runtime_spell_id)
	recalculate_circle_progression(false)
	save_to_disk()
	stats_changed.emit()
	return true


func get_skill_experience(skill_id: String) -> float:
	var mapped_skill_id: String = get_skill_id_for_spell(skill_id)
	if mapped_skill_id != "":
		skill_id = mapped_skill_id
	return float(skill_experience.get(skill_id, 0.0))


func reset_progress_for_tests() -> void:
	if UiState != null and UiState.has_method("reset_to_defaults_for_tests"):
		UiState.reset_to_defaults_for_tests()
	_combat_state.reset(BASE_MAX_HEALTH, BASE_MAX_MANA, BASE_MANA_REGEN_PER_SECOND)
	_progress_state.reset()
	ui_message = ""
	ui_message_time = 0.0
	spell_mastery.clear()
	spell_level.clear()
	skill_experience.clear()
	skill_level_data.clear()
	admin_infinite_health = false
	admin_infinite_mana = false
	admin_ignore_cooldowns = false
	admin_ignore_buff_slot_limit = false
	admin_freeze_ai = false
	equipped_items.clear()
	equipment_inventory.clear()
	consumable_inventory.clear()
	other_inventory.clear()
	current_equipment_preset = "default"
	resonance = {
		"fire": 0,
		"ice": 0,
		"lightning": 0,
		"wind": 0,
		"water": 0,
		"plant": 0,
		"earth": 0,
		"holy": 0,
		"dark": 0,
		"arcane": 0
	}
	last_spell_school = "fire"
	resonance_bonus_school = ""
	resonance_bonus_timer = 0.0
	visible_hotbar_shortcuts.clear()
	action_hotkey_registry.clear()
	spell_hotbar = get_default_spell_hotbar_template()
	_initialize_skill_progress()
	_initialize_buff_runtime()
	_initialize_spell_hotbar()
	_initialize_action_hotkey_registry()
	_reset_visible_hotbar_shortcuts_to_default(false)
	_initialize_equipment_state()
	_recalculate_derived_stats(false)
	recalculate_circle_progression(false)


func set_admin_infinite_health(enabled: bool) -> void:
	admin_infinite_health = enabled
	if admin_infinite_health:
		health = max_health
	stats_changed.emit()


func set_admin_infinite_mana(enabled: bool) -> void:
	admin_infinite_mana = enabled
	if admin_infinite_mana:
		mana = max_mana
	stats_changed.emit()


func set_admin_ignore_cooldowns(enabled: bool) -> void:
	admin_ignore_cooldowns = enabled
	stats_changed.emit()


func set_admin_ignore_buff_slot_limit(enabled: bool) -> void:
	admin_ignore_buff_slot_limit = enabled
	stats_changed.emit()


func get_admin_status_summary() -> String:
	var resource_parts: Array[String] = []
	var combat_parts: Array[String] = []
	if admin_infinite_health:
		combat_parts.append("무한 HP")
	if admin_infinite_mana:
		resource_parts.append("무한 MP")
	if admin_ignore_cooldowns:
		combat_parts.append("쿨타임 없음")
	if admin_ignore_buff_slot_limit:
		combat_parts.append("버프 슬롯 무제한")
	var resource_text := "-" if resource_parts.is_empty() else "/".join(resource_parts)
	var combat_text := "-" if combat_parts.is_empty() else "/".join(combat_parts)
	var preset_label := str(EQUIPMENT_PRESET_LABELS.get(current_equipment_preset, current_equipment_preset))
	return (
		"관리  자원[%s] 전투[%s] 장비[%s]"
		% [resource_text, combat_text, preset_label]
	)


func get_resource_summary() -> String:
	return "MP %.0f/%.0f" % [mana, max_mana]


func _get_prototype_room_metadata(room_id: String) -> Dictionary:
	var room_data: Dictionary = GameDatabase.get_room(room_id)
	if room_data.is_empty():
		return {}
	if not bool(room_data.get("prototype_enabled", false)):
		return {}
	return room_data


func _get_generated_prototype_profile(room_id: String) -> Dictionary:
	var room_data: Dictionary = _get_prototype_room_metadata(room_id)
	if room_data.is_empty() or not bool(room_data.get("prototype_generated", false)):
		return {}
	var floor := int(room_data.get("prototype_floor", 0))
	match floor:
		4:
			return {
				"weakest_message": "Low risk: 4F route rooms are stable; revisit only if false-exit onboarding or detour pressure changes.",
				"next_focus": "outer_breach_route_polish",
				"verification_status": "outer breach route locked",
				"verification_lock_level": "locked",
				"priority": "Low: keep 4F route rooms stable and only polish pocket readability or combat spacing.",
				"priority_level": "low",
				"action": "Keep the room stable and only add non-story outer-breach payoff if a detour pocket feels thin.",
				"room_note": "4F role: route room that repeats the maze's false-exit lesson across the widened outer breach.",
				"internal_path_note": "Keeps 4F outer-breach pressure building before the maze fully bends into 5F.",
				"handoff_path_note": "Hands off into 5F's bent transition corridors, where upward-looking routes start folding deeper.",
				"clues": [
					"Outer breach direction drift  implicit scene clue",
					"Pocket signal residue  detour pocket clue"
				]
			}
		5:
			return {
				"weakest_message": "5F route readability is the main watchpoint; the floor must feel maze-like without hiding the forward handoff.",
				"next_focus": "transition_route_readability",
				"verification_status": "transition corridor identity locked",
				"verification_lock_level": "locked",
				"priority": "Medium: keep 5F route rooms legible while preserving bent-corridor pressure and loop-back pacing.",
				"priority_level": "medium",
				"action": "Polish only non-story echo or spawn pressure if a 5F detour stops feeling like a deliberate misleading route.",
				"room_note": "5F role: transition route where checkpoint logic and stair rhythm deliberately break direction sense.",
				"internal_path_note": "Keeps 5F folding back into itself until the refuge floor can feel earned.",
				"handoff_path_note": "Releases into 6F refuge space only after the transition architecture has fully broken the player's sense of upward escape.",
				"clues": [
					"Bent checkpoint routing  implicit scene clue",
					"False-ascent pocket return  detour pocket clue"
				]
			}
		6:
			return {
				"weakest_message": "Low risk: 6F route rooms are stable; revisit only if refuge spacing or side-pressure around the hub changes.",
				"next_focus": "refuge_belt_spacing",
				"verification_status": "refuge belt route locked",
				"verification_lock_level": "locked",
				"priority": "Low: keep 6F side routes stable and only polish shelter-side pressure around the hub belt.",
				"priority_level": "low",
				"action": "Add only non-story refuge residue or light combat spacing polish if a 6F side route feels empty.",
				"room_note": "6F role: refuge belt room that cushions hub safety with lingering ward-edge pressure.",
				"internal_path_note": "Lets the 6F refuge belt breathe sideways before pressure climbs back into the gate floor.",
				"handoff_path_note": "Sends the player from refuge space toward 7F's judgment belt with clearer ward-backed warning context.",
				"clues": [
					"Ward-bound refuge spillover  implicit scene clue",
					"Shelter-side residue  detour pocket clue"
				]
			}
		7:
			return {
				"weakest_message": "Low risk: 7F route rooms are stable; revisit only if checkpoint pressure or pre-gate pacing needs tuning.",
				"next_focus": "gate_pressure_cadence",
				"verification_status": "gate belt route locked",
				"verification_lock_level": "locked",
				"priority": "Medium: keep 7F route rooms stable and only tune holding-pocket pressure or queue readability before the anchor gate.",
				"priority_level": "medium",
				"action": "Polish only non-story queue-line echoes or enemy spacing if a pre-gate route room stops feeling like deliberate screening space.",
				"room_note": "7F role: gate-belt room that extends inspection, holding, and selection pressure before the main threshold.",
				"internal_path_note": "Tightens checkpoint pressure one room at a time before the final threshold anchor.",
				"handoff_path_note": "Hands off into 8F inner rooms after the gate belt has fully narrowed the route into judgment space.",
				"clues": [
					"Checkpoint pressure rhythm  implicit scene clue",
					"Holding pocket queue trace  detour pocket clue"
				]
			}
		8:
			return {
				"weakest_message": "Low risk: 8F route rooms are stable; revisit only if inner-keep household residue or side-chamber pacing feels thin.",
				"next_focus": "inner_keep_route_presentation",
				"verification_status": "inner keep route locked",
				"verification_lock_level": "locked",
				"priority": "Medium: keep 8F route rooms stable and only deepen non-story household or support-ward residue where needed.",
				"priority_level": "medium",
				"action": "Add only non-story inner-keep residue if a side chamber stops reading like a lived-in power space turned wrong.",
				"room_note": "8F role: inner-keep route room that spreads erased domestic order and warped support magic beyond the anchor hall.",
				"internal_path_note": "Turns domestic ruin and support distortion into a broader inner-court route before 9F opens up.",
				"handoff_path_note": "Feeds 9F by turning inner-court residue into open judgment space and longer throne pressure.",
				"clues": [
					"Household residue in power space  implicit scene clue",
					"Support-ward distortion pocket  detour pocket clue"
				]
			}
		9:
			return {
				"weakest_message": "Low risk: 9F route rooms are stable; revisit only if judgment-ascent pacing or waiting-pocket tension feels thin.",
				"next_focus": "judgment_ascent_pacing",
				"verification_status": "judgment ascent route locked",
				"verification_lock_level": "locked",
				"priority": "Medium: keep 9F route rooms stable and only polish waiting-pocket pressure or decree-facing ascent cadence.",
				"priority_level": "medium",
				"action": "Add only non-story judgment residue if a 9F waiting room stops feeling like pre-throne pressure.",
				"room_note": "9F role: judgment-ascent room that stretches waiting, decree, and audience pressure before the throne anchor.",
				"internal_path_note": "Raises throne pressure one corridor at a time before the final 9F anchor room closes the floor.",
				"handoff_path_note": "Prepares the final throne anchor by keeping audience pressure active until the covenant handoff becomes immediate.",
				"clues": [
					"Audience waiting pressure  implicit scene clue",
					"Decree-facing ascent pocket  detour pocket clue"
				]
			}
		_:
			return {}


func _get_prototype_adjacent_room_context(room_id: String) -> Dictionary:
	var room_order: Array[String] = get_prototype_room_order()
	var room_index := room_order.find(room_id)
	if room_index == -1:
		return {}
	var previous_room_id := ""
	var next_room_id := ""
	if room_index > 0:
		previous_room_id = str(room_order[room_index - 1])
	if room_index + 1 < room_order.size():
		next_room_id = str(room_order[room_index + 1])
	var previous_room: Dictionary = GameDatabase.get_room(previous_room_id)
	var next_room: Dictionary = GameDatabase.get_room(next_room_id)
	return {
		"previous_room_id": previous_room_id,
		"next_room_id": next_room_id,
		"previous_floor": int(previous_room.get("prototype_floor", 0)),
		"next_floor": int(next_room.get("prototype_floor", 0))
	}


func _build_generated_room_weakest_link_summary(room_id: String) -> Dictionary:
	var profile := _get_generated_prototype_profile(room_id)
	if profile.is_empty():
		return {}
	return {
		"room_id": room_id,
		"message": str(profile.get("weakest_message", "")),
		"is_locked": true,
		"next_focus": str(profile.get("next_focus", "route_polish")),
		"blocking_flags": []
	}


func _build_generated_room_verification_status_summary(room_id: String) -> Dictionary:
	var profile := _get_generated_prototype_profile(room_id)
	if profile.is_empty():
		return {}
	return {
		"room_id": room_id,
		"status": str(profile.get("verification_status", "")),
		"lock_level": str(profile.get("verification_lock_level", "locked"))
	}


func _build_generated_room_next_priority_summary(room_id: String) -> Dictionary:
	var profile := _get_generated_prototype_profile(room_id)
	if profile.is_empty():
		return {}
	return {
		"room_id": room_id,
		"priority": str(profile.get("priority", "")),
		"priority_level": str(profile.get("priority_level", "low"))
	}


func _build_generated_room_action_candidate_summary(room_id: String) -> Dictionary:
	var profile := _get_generated_prototype_profile(room_id)
	if profile.is_empty():
		return {}
	return {
		"room_id": room_id,
		"actions": [str(profile.get("action", ""))],
		"count": 1
	}


func _build_generated_room_note_summary(room_id: String) -> Dictionary:
	var profile := _get_generated_prototype_profile(room_id)
	if profile.is_empty():
		return {}
	return {
		"room_id": room_id,
		"note": str(profile.get("room_note", ""))
	}


func _build_generated_room_path_note_summary(room_id: String) -> Dictionary:
	var profile := _get_generated_prototype_profile(room_id)
	if profile.is_empty():
		return {}
	var room_data: Dictionary = _get_prototype_room_metadata(room_id)
	var floor := int(room_data.get("prototype_floor", 0))
	var adjacent := _get_prototype_adjacent_room_context(room_id)
	var next_floor := int(adjacent.get("next_floor", floor))
	var note := str(profile.get("internal_path_note", ""))
	if next_floor > floor:
		note = str(profile.get("handoff_path_note", note))
	return {
		"room_id": room_id,
		"note": note
	}


func _build_generated_room_clue_check_summary(room_id: String) -> Dictionary:
	var profile := _get_generated_prototype_profile(room_id)
	if profile.is_empty():
		return {}
	return {
		"room_id": room_id,
		"clues": Array(profile.get("clues", [])).duplicate(),
		"count": Array(profile.get("clues", [])).size()
	}


func get_room_weakest_link_summary(room_id: String) -> Dictionary:
	match room_id:
		"entrance":
			return {
				"room_id": room_id,
				"message": "Low risk: 4F is stable; only revisit if onboarding or first-depth messaging changes.",
				"is_locked": true,
				"next_focus": "onboarding_polish",
				"blocking_flags": []
			}
		"seal_sanctum":
			if not bool(progression_flags.get("seal_sanctum_anchor", false)):
				return {
					"room_id": room_id,
					"message": "Hub anchor confirmation is still the weakest link before more refuge layering.",
					"is_locked": false,
					"next_focus": "hub_anchor_confirmation",
					"blocking_flags": ["seal_sanctum_anchor"]
				}
			return {
				"room_id": room_id,
				"message": "Hub reactions are stable; the next weakest link is broader board/echo coverage.",
				"is_locked": true,
				"next_focus": "broader_reactive_coverage",
				"blocking_flags": []
			}
		"gate_threshold":
			var survivor_done := bool(progression_flags.get("gate_threshold_survivor_trace", false))
			var bloodline_done := bool(progression_flags.get("gate_threshold_bloodline_hint", false))
			if not survivor_done and not bloodline_done:
				return {
					"room_id": room_id,
					"message": "7F still lacks both threshold proofs; survivor warning and bloodline hint must both be confirmed.",
					"is_locked": false,
					"next_focus": "threshold_dual_proofs",
					"blocking_flags": ["gate_threshold_survivor_trace", "gate_threshold_bloodline_hint"]
				}
			if not survivor_done:
				return {
					"room_id": room_id,
					"message": "7F bloodline logic is present, but the survivor warning half is still the weakest link.",
					"is_locked": false,
					"next_focus": "survivor_warning",
					"blocking_flags": ["gate_threshold_survivor_trace"]
				}
			if not bloodline_done:
				return {
					"room_id": room_id,
					"message": "7F survivor warning is present, but the bloodline selector half is still the weakest link.",
					"is_locked": false,
					"next_focus": "bloodline_selector",
					"blocking_flags": ["gate_threshold_bloodline_hint"]
				}
			return {
				"room_id": room_id,
				"message": "7F lore is locked; the weakest link has moved downstream into reaction polish.",
				"is_locked": true,
				"next_focus": "reaction_polish",
				"blocking_flags": []
			}
		"royal_inner_hall":
			var trace_done := bool(progression_flags.get("royal_inner_hall_companion_trace", false))
			var archive_done := bool(progression_flags.get("royal_inner_hall_archive", false))
			if not trace_done and not archive_done:
				return {
					"room_id": room_id,
					"message": "8F still lacks both halves of its court pattern: archive erasure and companion distortion.",
					"is_locked": false,
					"next_focus": "court_pattern_dual_proofs",
					"blocking_flags": ["royal_inner_hall_companion_trace", "royal_inner_hall_archive"]
				}
			if not trace_done:
				return {
					"room_id": room_id,
					"message": "8F archive is present, but the companion-distortion half is still the weakest link.",
					"is_locked": false,
					"next_focus": "companion_distortion",
					"blocking_flags": ["royal_inner_hall_companion_trace"]
				}
			if not archive_done:
				return {
					"room_id": room_id,
					"message": "8F companion distortion is present, but the erased-household archive is still the weakest link.",
					"is_locked": false,
					"next_focus": "erased_household_archive",
					"blocking_flags": ["royal_inner_hall_archive"]
				}
			return {
				"room_id": room_id,
				"message": "8F clues are locked; the weakest link is now how strongly they hand off into 9F.",
				"is_locked": true,
				"next_focus": "handoff_into_9f",
				"blocking_flags": []
			}
		"throne_approach":
			var throne_trace_done := bool(progression_flags.get("throne_approach_companion_trace", false))
			var decree_done := bool(progression_flags.get("throne_approach_decree", false))
			if not throne_trace_done and not decree_done:
				return {
					"room_id": room_id,
					"message": "9F still lacks both coercion proofs: companion trace and fear decree.",
					"is_locked": false,
					"next_focus": "coercion_dual_proofs",
					"blocking_flags": ["throne_approach_companion_trace", "throne_approach_decree"]
				}
			if not throne_trace_done:
				return {
					"room_id": room_id,
					"message": "9F decree is present, but the companion-trace half is still the weakest link.",
					"is_locked": false,
					"next_focus": "companion_trace",
					"blocking_flags": ["throne_approach_companion_trace"]
				}
			if not decree_done:
				return {
					"room_id": room_id,
					"message": "9F companion trace is present, but the fear-decree half is still the weakest link.",
					"is_locked": false,
					"next_focus": "fear_decree",
					"blocking_flags": ["throne_approach_decree"]
				}
			return {
				"room_id": room_id,
				"message": "9F clues are locked; the weakest link is now final-room payoff presentation.",
				"is_locked": true,
				"next_focus": "final_room_payoff_presentation",
				"blocking_flags": []
			}
		"inverted_spire":
			if not bool(progression_flags.get("inverted_spire_covenant", false)):
				return {
					"room_id": room_id,
					"message": "10F still depends on confirming the covenant altar before aftermath logic can be trusted.",
					"is_locked": false,
					"next_focus": "covenant_confirmation",
					"blocking_flags": ["inverted_spire_covenant"]
				}
			return {
				"room_id": room_id,
				"message": "10F truth is locked; the weakest link is optional non-cutscene payoff polish.",
				"is_locked": true,
				"next_focus": "optional_payoff_polish",
				"blocking_flags": []
			}
		_:
			return _build_generated_room_weakest_link_summary(room_id)


func get_room_weakest_link_summaries() -> Array[Dictionary]:
	var room_ids: Array[String] = get_prototype_room_order()
	var summaries: Array[Dictionary] = []
	for room_id in room_ids:
		var summary := get_room_weakest_link_summary(room_id)
		if summary.is_empty():
			continue
		summaries.append(summary.duplicate(true))
	return summaries


func get_progression_chain_summary() -> Dictionary:
	var checks: Array[Dictionary] = [
		{
			"label": "7F Survivor",
			"flag": "gate_threshold_survivor_trace"
		},
		{
			"label": "7F Bloodline",
			"flag": "gate_threshold_bloodline_hint"
		},
		{
			"label": "8F Trace",
			"flag": "royal_inner_hall_companion_trace"
		},
		{
			"label": "8F Archive",
			"flag": "royal_inner_hall_archive"
		},
		{
			"label": "9F Trace",
			"flag": "throne_approach_companion_trace"
		},
		{
			"label": "9F Decree",
			"flag": "throne_approach_decree"
		},
		{
			"label": "6F Notice",
			"flag": "seal_sanctum_anchor"
		},
		{
			"label": "10F Covenant",
			"flag": "inverted_spire_covenant"
		}
	]
	var parts: Array[String] = []
	for check in checks:
		var flag_id := str(check.get("flag", ""))
		var done := bool(progression_flags.get(flag_id, false))
		parts.append("%s[%s]" % [str(check.get("label", flag_id)), "Y" if done else "-"])
	return {
		"parts": parts.duplicate(),
		"line": "Progression Chain: %s" % "  ".join(parts)
	}


func get_progression_phase_summary() -> Dictionary:
	var threshold_done := (
		bool(progression_flags.get("gate_threshold_survivor_trace", false))
		and bool(progression_flags.get("gate_threshold_bloodline_hint", false))
	)
	var companion_done := (
		bool(progression_flags.get("royal_inner_hall_companion_trace", false))
		and bool(progression_flags.get("royal_inner_hall_archive", false))
		and bool(progression_flags.get("throne_approach_companion_trace", false))
		and bool(progression_flags.get("throne_approach_decree", false))
	)
	var final_done := bool(progression_flags.get("inverted_spire_covenant", false))
	return {
		"threshold_done": threshold_done,
		"companion_done": companion_done,
		"final_done": final_done,
		"line": (
			"Phase Summary: Threshold[%s]  Companion[%s]  Final[%s]"
			% [
				"Y" if threshold_done else "-",
				"Y" if companion_done else "-",
				"Y" if final_done else "-"
			]
		)
	}


func get_lore_handoff_summary() -> Dictionary:
	var phase_summary := get_progression_phase_summary()
	var threshold_done := bool(phase_summary.get("threshold_done", false))
	var companion_done := bool(phase_summary.get("companion_done", false))
	var final_done := bool(phase_summary.get("final_done", false))
	var threshold_text := (
		"The 7F gate is confirmed as a blood-selecting judgment point."
		if threshold_done
		else "The 7F gate has not yet been fully confirmed as a blood-selecting threshold."
	)
	var companion_text := (
		"The 8F-9F support traces and court records now read as one coerced pattern."
		if companion_done
		else "The 8F-9F companion traces are not yet locked into one court pattern."
	)
	var final_text := (
		"The 10F covenant now confirms how gate, hall, throne, and altar belonged to one design."
		if final_done
		else "The 10F covenant has not yet confirmed the full design behind the maze."
	)
	return {
		"threshold": threshold_text,
		"companion": companion_text,
		"final": final_text,
		"lines": [
			" Lore Handoff:",
			"- Threshold  %s" % threshold_text,
			"- Companion  %s" % companion_text,
			"- Final  %s" % final_text
		]
	}


func get_room_verification_status_summary(room_id: String) -> Dictionary:
	match room_id:
		"entrance":
			return {
				"room_id": room_id,
				"status": "implicit environment role locked",
				"lock_level": "locked"
			}
		"seal_sanctum":
			if bool(progression_flags.get("seal_sanctum_anchor", false)):
				return {
					"room_id": room_id,
					"status": "hub anchor locked",
					"lock_level": "locked"
				}
			return {
				"room_id": room_id,
				"status": "hub clue scaffold locked, anchor not yet confirmed",
				"lock_level": "scaffold"
			}
		"gate_threshold":
			var gate_count := 0
			if bool(progression_flags.get("gate_threshold_survivor_trace", false)):
				gate_count += 1
			if bool(progression_flags.get("gate_threshold_bloodline_hint", false)):
				gate_count += 1
			if gate_count >= 2:
				return {
					"room_id": room_id,
					"status": "threshold lore fully locked",
					"lock_level": "locked"
				}
			if gate_count == 1:
				return {
					"room_id": room_id,
					"status": "threshold lore partially locked",
					"lock_level": "partial"
				}
			return {
				"room_id": room_id,
				"status": "threshold lore scaffold only",
				"lock_level": "scaffold"
			}
		"royal_inner_hall":
			var hall_count := 0
			if bool(progression_flags.get("royal_inner_hall_companion_trace", false)):
				hall_count += 1
			if bool(progression_flags.get("royal_inner_hall_archive", false)):
				hall_count += 1
			if hall_count >= 2:
				return {
					"room_id": room_id,
					"status": "inner hall clues fully locked",
					"lock_level": "locked"
				}
			if hall_count == 1:
				return {
					"room_id": room_id,
					"status": "inner hall clues partially locked",
					"lock_level": "partial"
				}
			return {
				"room_id": room_id,
				"status": "inner hall clue scaffold only",
				"lock_level": "scaffold"
			}
		"throne_approach":
			var throne_count := 0
			if bool(progression_flags.get("throne_approach_companion_trace", false)):
				throne_count += 1
			if bool(progression_flags.get("throne_approach_decree", false)):
				throne_count += 1
			if throne_count >= 2:
				return {
					"room_id": room_id,
					"status": "throne corridor clues fully locked",
					"lock_level": "locked"
				}
			if throne_count == 1:
				return {
					"room_id": room_id,
					"status": "throne corridor clues partially locked",
					"lock_level": "partial"
				}
			return {
				"room_id": room_id,
				"status": "throne corridor clue scaffold only",
				"lock_level": "scaffold"
			}
		"inverted_spire":
			if bool(progression_flags.get("inverted_spire_covenant", false)):
				return {
					"room_id": room_id,
					"status": "final covenant locked",
					"lock_level": "locked"
				}
			return {
				"room_id": room_id,
				"status": "final covenant scaffold only",
				"lock_level": "scaffold"
			}
		_:
			return _build_generated_room_verification_status_summary(room_id)


func get_room_next_priority_summary(room_id: String) -> Dictionary:
	match room_id:
		"entrance":
			return {
				"room_id": room_id,
				"priority": "Low: maintain as visual entry anchor unless 4F onboarding changes.",
				"priority_level": "low"
			}
		"seal_sanctum":
			if bool(progression_flags.get("seal_sanctum_anchor", false)):
				return {
					"room_id": room_id,
					"priority": "Medium: anchor is locked, so next safe work is richer hub response or support-state feedback.",
					"priority_level": "medium"
				}
			return {
				"room_id": room_id,
				"priority": "High: confirm the hub anchor interaction before layering more refuge reactions.",
				"priority_level": "high"
			}
		"gate_threshold":
			var gate_count := 0
			if bool(progression_flags.get("gate_threshold_survivor_trace", false)):
				gate_count += 1
			if bool(progression_flags.get("gate_threshold_bloodline_hint", false)):
				gate_count += 1
			if gate_count >= 2:
				return {
					"room_id": room_id,
					"priority": "Low: gate lore is locked, so next safe work is downstream reaction polish.",
					"priority_level": "low"
				}
			if gate_count == 1:
				return {
					"room_id": room_id,
					"priority": "High: finish the missing gate clue to lock the threshold reading.",
					"priority_level": "high"
				}
			return {
				"room_id": room_id,
				"priority": "High: implement both gate clues before deepening 8F-10F handoff.",
				"priority_level": "high"
			}
		"royal_inner_hall":
			var hall_count := 0
			if bool(progression_flags.get("royal_inner_hall_companion_trace", false)):
				hall_count += 1
			if bool(progression_flags.get("royal_inner_hall_archive", false)):
				hall_count += 1
			if hall_count >= 2:
				return {
					"room_id": room_id,
					"priority": "Medium: hall clues are locked, so next safe work is stronger 8F-to-9F presentation.",
					"priority_level": "medium"
				}
			if hall_count == 1:
				return {
					"room_id": room_id,
					"priority": "High: finish the second 8F clue so the court pattern can form cleanly.",
					"priority_level": "high"
				}
			return {
				"room_id": room_id,
				"priority": "High: implement both 8F clues before relying on companion-phase summaries.",
				"priority_level": "high"
			}
		"throne_approach":
			var throne_count := 0
			if bool(progression_flags.get("throne_approach_companion_trace", false)):
				throne_count += 1
			if bool(progression_flags.get("throne_approach_decree", false)):
				throne_count += 1
			if throne_count >= 2:
				return {
					"room_id": room_id,
					"priority": "Medium: throne clues are locked, so next safe work is final-room payoff polish.",
					"priority_level": "medium"
				}
			if throne_count == 1:
				return {
					"room_id": room_id,
					"priority": "High: finish the second 9F clue before treating the coercion pattern as settled.",
					"priority_level": "high"
				}
			return {
				"room_id": room_id,
				"priority": "High: implement both 9F clues before pushing more 10F payoff.",
				"priority_level": "high"
			}
		"inverted_spire":
			if bool(progression_flags.get("inverted_spire_covenant", false)):
				return {
					"room_id": room_id,
					"priority": "Medium: covenant is locked, so next safe work is admin/world payoff polish short of cutscenes.",
					"priority_level": "medium"
				}
			return {
				"room_id": room_id,
				"priority": "High: confirm the covenant altar record before expanding any final-room aftermath.",
				"priority_level": "high"
			}
		_:
			return _build_generated_room_next_priority_summary(room_id)


func get_room_action_candidate_summary(room_id: String) -> Dictionary:
	var actions: Array[String] = []
	match room_id:
		"entrance":
			actions.append("Keep current 4F layout stable and only revisit if onboarding beats change.")
		"seal_sanctum":
			if bool(progression_flags.get("seal_sanctum_anchor", false)):
				actions.append("Add one more hub reaction tied to already-locked phase flags.")
			else:
				actions.append("Reconfirm the seal statue anchor flow before expanding any hub side feedback.")
		"gate_threshold":
			if not bool(progression_flags.get("gate_threshold_survivor_trace", false)):
				actions.append("Implement or validate the survivor-warning trace in 7F gate space.")
			if not bool(progression_flags.get("gate_threshold_bloodline_hint", false)):
				actions.append("Implement or validate the bloodline-hint trace in 7F gate space.")
			if actions.is_empty():
				actions.append("Keep 7F stable and focus on downstream hub/final reactions.")
		"royal_inner_hall":
			if not bool(progression_flags.get("royal_inner_hall_companion_trace", false)):
				actions.append("Implement or validate the 8F companion-trace echo.")
			if not bool(progression_flags.get("royal_inner_hall_archive", false)):
				actions.append("Implement or validate the 8F erased-household archive interaction.")
			if actions.is_empty():
				actions.append("Keep 8F stable and focus on stronger presentation into 9F.")
		"throne_approach":
			if not bool(progression_flags.get("throne_approach_companion_trace", false)):
				actions.append("Implement or validate the 9F companion-trace clue.")
			if not bool(progression_flags.get("throne_approach_decree", false)):
				actions.append("Implement or validate the 9F fear-decree clue.")
			if actions.is_empty():
				actions.append("Keep 9F stable and focus on 10F payoff polish short of cutscenes.")
		"inverted_spire":
			if not bool(progression_flags.get("inverted_spire_covenant", false)):
				actions.append("Reconfirm the covenant altar record and final warning linkage.")
			else:
				actions.append("Add one more non-cutscene payoff reaction using already-locked covenant truth.")
		_:
			return _build_generated_room_action_candidate_summary(room_id)
	return {
		"room_id": room_id,
		"actions": actions.duplicate(),
		"count": actions.size()
	}


func get_room_note_summary(room_id: String) -> Dictionary:
	match room_id:
		"entrance":
			return {
				"room_id": room_id,
				"note": "4F role: false-exit outer breach that teaches the maze points deeper, not upward."
			}
		"seal_sanctum":
			return {
				"room_id": room_id,
				"note": "6F role: refuge hub that rewrites discovered truths into survivable warning."
			}
		"gate_threshold":
			return {
				"room_id": room_id,
				"note": "7F role: judgment gate where bloodline selection becomes legible."
			}
		"royal_inner_hall":
			return {
				"room_id": room_id,
				"note": "8F role: inner court where erased records and distorted support traces first overlap."
			}
		"throne_approach":
			return {
				"room_id": room_id,
				"note": "9F role: throne corridor where decree and support traces are not yet fully locked together."
			}
		"inverted_spire":
			if bool(progression_flags.get("inverted_spire_covenant", false)):
				return {
					"room_id": room_id,
					"note": "10F role: covenant core that confirms gate, hall, throne, and altar as one design."
				}
			return {
				"room_id": room_id,
				"note": "10F role: covenant core awaiting final confirmation"
			}
		_:
			return _build_generated_room_note_summary(room_id)


func get_room_path_note_summary(room_id: String) -> Dictionary:
	var threshold_done := (
		bool(progression_flags.get("gate_threshold_survivor_trace", false))
		and bool(progression_flags.get("gate_threshold_bloodline_hint", false))
	)
	var companion_done := (
		bool(progression_flags.get("royal_inner_hall_companion_trace", false))
		and bool(progression_flags.get("royal_inner_hall_archive", false))
		and bool(progression_flags.get("throne_approach_companion_trace", false))
		and bool(progression_flags.get("throne_approach_decree", false))
	)
	var final_done := bool(progression_flags.get("inverted_spire_covenant", false))
	match room_id:
		"entrance":
			return {
				"room_id": room_id,
				"note": "Leads into the 6F refuge, where the fall is first reinterpreted as a survivable route."
			}
		"seal_sanctum":
			return {
				"room_id": room_id,
				"note": "Sends the player back upward into the 7F judgment gate with clearer warning context."
			}
		"gate_threshold":
			if threshold_done:
				return {
					"room_id": room_id,
					"note": "Hands off into 8F with the gate's blood judgment already established."
				}
			return {
				"room_id": room_id,
				"note": "Hands off into 8F before the gate's blood judgment is fully proven."
			}
		"royal_inner_hall":
			return {
				"room_id": room_id,
				"note": "Feeds into 9F by turning erased household record and support traces into one suspicion."
			}
		"throne_approach":
			if companion_done:
				return {
					"room_id": room_id,
					"note": "Hands the full coercion pattern into 10F, where the covenant can confirm it."
				}
			return {
				"room_id": room_id,
				"note": "Approaches 10F before decree and support traces have fully resolved into one pattern."
			}
		"inverted_spire":
			if final_done:
				return {
					"room_id": room_id,
					"note": "Returns meaning back to the hub: the covenant now explains what the gate, hall, and throne were preparing."
				}
			return {
				"room_id": room_id,
				"note": "Waits on the altar record before the full chain can be sent back to the hub as truth."
			}
		_:
			return _build_generated_room_path_note_summary(room_id)


func get_room_clue_check_summary(room_id: String) -> Dictionary:
	var clues: Array[String] = []
	match room_id:
		"entrance":
			clues.append("Outer breach orientation  implicit scene clue")
			clues.append("Exit-like descent illusion  implicit scene clue")
		"seal_sanctum":
			clues.append(
				"Seal statue anchor  [%s]"
				% ("Y" if bool(progression_flags.get("seal_sanctum_anchor", false)) else "-")
			)
			clues.append("Refuge notice phase summary  preview-backed clue")
		"gate_threshold":
			clues.append(
				"Survivor warning  [%s]"
				% (
					"Y"
					if bool(progression_flags.get("gate_threshold_survivor_trace", false))
					else "-"
				)
			)
			clues.append(
				"Bloodline hint  [%s]"
				% (
					"Y"
					if bool(progression_flags.get("gate_threshold_bloodline_hint", false))
					else "-"
				)
			)
		"royal_inner_hall":
			clues.append(
				"Companion trace  [%s]"
				% (
					"Y"
					if bool(progression_flags.get("royal_inner_hall_companion_trace", false))
					else "-"
				)
			)
			clues.append(
				"Erased household archive  [%s]"
				% (
					"Y"
					if bool(progression_flags.get("royal_inner_hall_archive", false))
					else "-"
				)
			)
		"throne_approach":
			clues.append(
				"Companion trace  [%s]"
				% (
					"Y"
					if bool(progression_flags.get("throne_approach_companion_trace", false))
					else "-"
				)
			)
			clues.append(
				"Fear decree  [%s]"
				% (
					"Y"
					if bool(progression_flags.get("throne_approach_decree", false))
					else "-"
				)
			)
		"inverted_spire":
			clues.append(
				"Covenant altar record  [%s]"
				% (
					"Y"
					if bool(progression_flags.get("inverted_spire_covenant", false))
					else "-"
				)
			)
			clues.append("Final warning phase link  preview-backed clue")
		_:
			return _build_generated_room_clue_check_summary(room_id)
	return {
		"room_id": room_id,
		"clues": clues.duplicate(),
		"count": clues.size()
	}


func get_final_warning_preview_summary() -> Dictionary:
	var phase_summary := get_progression_phase_summary()
	var threshold_done := bool(phase_summary.get("threshold_done", false))
	var companion_done := bool(phase_summary.get("companion_done", false))
	var covenant_seen := bool(progression_flags.get("inverted_spire_covenant", false))
	var state_label := "제단 미확인"
	if covenant_seen:
		state_label = "경고 준비됨"
	elif companion_done:
		state_label = "동행자 흔적 확보"
	elif threshold_done:
		state_label = "관문 단서 확보"
	var gate_line := "계약의 바닥은 여전히 팽팽하다. 제단은 아직 응답을 끝내지 않았다."
	if covenant_seen:
		if companion_done:
			gate_line = "계약의 바닥은 방이 고요해질 때만 응답한다. 관문은 혈통을 골랐고, 복도는 이름을 지웠으며, 옥좌는 제단이 말하기 전부터 공포를 가르쳤다."
		elif threshold_done:
			gate_line = "계약의 바닥은 방이 고요해질 때만 응답한다. 관문에서 당신의 혈통을 판별한 무언가는 아직도 제단 아래에서 기다리고 있다."
		else:
			gate_line = "계약의 바닥은 방이 고요해질 때만 응답한다."
	elif companion_done:
		gate_line = "계약의 바닥은 여전히 팽팽하다. 제단은 아직 응답을 끝내지 않았지만, 관문과 내전, 그리고 옥좌 회랑은 이미 이 방이 당신에게 무엇을 요구하는지 알고 있다."
	elif threshold_done:
		gate_line = "계약의 바닥은 여전히 팽팽하다. 제단은 아직 응답을 끝내지 않았고, 관문에서 혈통을 골랐던 그 심판이 아직도 이 방을 닫아 두고 있다."
	return {
		"state_label": state_label,
		"gate_line": gate_line,
		"lines": [
			"최종 경고 미리보기:",
			"- State  %s" % state_label,
			"- Gate Line  %s" % gate_line.left(96)
		]
	}


func get_phase_cross_check_summary() -> Dictionary:
	var hub_room: Dictionary = GameDatabase.get_room("seal_sanctum")
	var hub_notice := ""
	for raw_object in hub_room.get("objects", []):
		if typeof(raw_object) != TYPE_DICTIONARY:
			continue
		var object_data: Dictionary = raw_object
		if str(object_data.get("type", "")) != "refuge_notice":
			continue
		hub_notice = _resolve_reactive_object_message_preview(object_data).left(72)
		break
	var final_warning_summary := get_final_warning_preview_summary()
	var final_state := str(final_warning_summary.get("state_label", "altar unread"))
	var final_gate := str(final_warning_summary.get("gate_line", "")).left(72)
	return {
		"hub_notice": hub_notice,
		"final_state": final_state,
		"final_gate": final_gate,
		"lines": [
			"Phase Cross-Check:",
			"- Hub Notice  %s" % hub_notice,
			"- Final State  %s" % final_state,
			"- Final Gate  %s" % final_gate
		]
	}


func get_room_reactive_notice_preview(room_id: String) -> Dictionary:
	var room_data: Dictionary = GameDatabase.get_room(room_id)
	if room_data.is_empty():
		return {}
	for raw_object in room_data.get("objects", []):
		if typeof(raw_object) != TYPE_DICTIONARY:
			continue
		var object_data: Dictionary = raw_object
		if str(object_data.get("type", "")) != "refuge_notice":
			continue
		return {
			"room_id": room_id,
			"text": _resolve_reactive_object_message_preview(object_data)
		}
	return {}


func get_room_interaction_preview_summary(room_id: String) -> Dictionary:
	var room_data: Dictionary = GameDatabase.get_room(room_id)
	if room_data.is_empty():
		return {}
	var entries: Array[Dictionary] = []
	for raw_object in room_data.get("objects", []):
		if typeof(raw_object) != TYPE_DICTIONARY:
			continue
		var object_data: Dictionary = raw_object
		var object_type := str(object_data.get("type", ""))
		match object_type:
			"seal_statue":
				entries.append({"label": "Seal Statue", "summary": "Hub anchor, full recovery"})
			"memory_plinth":
				entries.append({"label": "Memory Plinth", "summary": "Story trace, route anchor"})
			"covenant_altar":
				entries.append({"label": "Covenant Altar", "summary": "Final truth, boss anchor"})
			"refuge_notice":
				entries.append({"label": "Refuge Notice", "summary": "Reactive hub summary"})
			"rest":
				entries.append({"label": "휴식 지점", "summary": "경로 저장"})
			"echo":
				entries.append({"label": "메아리 흔적", "summary": "기록 열람"})
	if entries.is_empty():
		return {"room_id": room_id, "entries": [], "lines": ["- 없음"]}
	var lines: Array[String] = []
	for entry in entries:
		lines.append("- %s  %s" % [str(entry.get("label", "")), str(entry.get("summary", ""))])
	return {
		"room_id": room_id,
		"entries": entries.duplicate(true),
		"lines": lines
	}


func get_prototype_room_overview_summary(room_id: String) -> Dictionary:
	var room_data: Dictionary = GameDatabase.get_room(room_id)
	if room_data.is_empty():
		return {}
	return {
		"room_id": room_id,
		"title": str(room_data.get("title", room_id)),
		"summary": str(room_data.get("prototype_summary", room_data.get("entry_text", "")))
	}


func get_prototype_room_catalog() -> Array[Dictionary]:
	var prototype_rooms: Array[Dictionary] = []
	for raw_room in GameDatabase.get_all_rooms():
		if typeof(raw_room) != TYPE_DICTIONARY:
			continue
		var room_data: Dictionary = Dictionary(raw_room)
		if not bool(room_data.get("prototype_enabled", false)):
			continue
		prototype_rooms.append(room_data.duplicate(true))
	prototype_rooms.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return int(a.get("prototype_index", 9999)) < int(b.get("prototype_index", 9999))
	)
	var catalog: Array[Dictionary] = []
	for room_data in prototype_rooms:
		var room_id := str(room_data.get("id", ""))
		var overview := get_prototype_room_overview_summary(room_id)
		if overview.is_empty():
			continue
		catalog.append(
			{
				"room_id": room_id,
				"short_label": str(room_data.get("prototype_short_label", room_id)),
				"title": str(overview.get("title", room_id)),
				"summary": str(overview.get("summary", "")),
				"jump_label": "이동 %s" % str(overview.get("title", room_id)).left(12),
				"floor": int(room_data.get("prototype_floor", 0)),
				"slot_on_floor": int(room_data.get("prototype_floor_slot", 0)),
				"is_anchor": bool(room_data.get("prototype_anchor", false)),
				"is_generated": bool(room_data.get("prototype_generated", false)),
				"prototype_index": int(room_data.get("prototype_index", 0))
			}
		)
	return catalog


func get_prototype_room_order() -> Array[String]:
	var room_ids: Array[String] = []
	for entry in get_prototype_room_catalog():
		room_ids.append(str(entry.get("room_id", "")))
	return room_ids


func get_prototype_flow_preview_summary(selected_room_id: String) -> Dictionary:
	var entries: Array[Dictionary] = []
	var lines: Array[String] = ["프로토타입 흐름:"]
	for catalog_entry in get_prototype_room_catalog():
		var room_id := str(catalog_entry.get("room_id", ""))
		var marker := ">" if room_id == selected_room_id else "-"
		var short_label := str(catalog_entry.get("short_label", room_id))
		var caption := "%s (%s)" % [
			str(catalog_entry.get("title", room_id)),
			str(catalog_entry.get("summary", "")).left(32)
		]
		entries.append(
			{
				"room_id": room_id,
				"marker": marker,
				"short_label": short_label,
				"caption": caption,
				"is_selected": room_id == selected_room_id
			}
		)
		lines.append("%s %s  %s" % [marker, short_label, caption])
	return {
		"selected_room_id": selected_room_id,
		"entries": entries.duplicate(true),
		"lines": lines
	}


func get_room_reactive_preview_summary(room_id: String) -> Dictionary:
	var room_data: Dictionary = GameDatabase.get_room(room_id)
	if room_data.is_empty():
		return {}
	var lines: Array[String] = []
	var entries: Array[Dictionary] = []
	var notice_summary := get_room_reactive_notice_preview(room_id)
	if not notice_summary.is_empty():
		var notice_text := str(notice_summary.get("text", ""))
		lines.append("Reactive Preview:")
		lines.append("- Refuge Notice  %s" % notice_text.left(96))
		entries.append({"surface": "Refuge Notice", "text": notice_text})
	if room_id == "inverted_spire":
		var warning_summary := get_final_warning_preview_summary()
		for raw_line in warning_summary.get("lines", []):
			lines.append(str(raw_line))
		entries.append(
			{
				"surface": "Final Warning",
				"state_label": str(warning_summary.get("state_label", "")),
				"text": str(warning_summary.get("gate_line", ""))
			}
		)
	if lines.is_empty():
		return {}
	return {
		"room_id": room_id,
		"entries": entries.duplicate(true),
		"lines": lines
	}


func get_room_reactive_residue_summary(room_id: String) -> Dictionary:
	var room_data: Dictionary = GameDatabase.get_room(room_id)
	if room_data.is_empty():
		return {}
	var entries: Array[Dictionary] = []
	for raw_object in room_data.get("objects", []):
		if typeof(raw_object) != TYPE_DICTIONARY:
			continue
		var object_data: Dictionary = raw_object
		var object_type := str(object_data.get("type", ""))
		if object_type == "refuge_notice":
			entries.append(
				{
					"surface": "Board",
					"text": _resolve_reactive_object_message_preview(object_data).left(84)
				}
			)
		elif object_type == "echo":
			var repeat_preview := _resolve_echo_repeat_preview(object_data)
			if repeat_preview == "":
				continue
			entries.append({"surface": "Echo", "text": repeat_preview.left(84)})
	if room_id == "inverted_spire":
		var final_warning_summary := get_final_warning_preview_summary()
		entries.append(
			{
				"surface": "Gate",
				"text": str(final_warning_summary.get("gate_line", "")).left(84)
			}
		)
	if entries.is_empty():
		return {}
	var lines: Array[String] = [" Reactive Residue:"]
	for entry in entries:
		lines.append("- %s  %s" % [str(entry.get("surface", "")), str(entry.get("text", ""))])
	return {
		"room_id": room_id,
		"entries": entries.duplicate(true),
		"count": entries.size(),
		"lines": lines
	}


func _resolve_reactive_object_message_preview(object_data: Dictionary) -> String:
	for raw_stage in object_data.get("stage_messages", []):
		if typeof(raw_stage) != TYPE_DICTIONARY:
			continue
		var stage_data: Dictionary = raw_stage
		if _reactive_stage_matches(stage_data):
			return str(stage_data.get("text", object_data.get("text", "")))
	return str(object_data.get("text", ""))


func _resolve_echo_repeat_preview(object_data: Dictionary) -> String:
	for raw_stage in object_data.get("repeat_stage_messages", []):
		if typeof(raw_stage) != TYPE_DICTIONARY:
			continue
		var stage_data: Dictionary = raw_stage
		if _reactive_stage_matches(stage_data):
			return str(stage_data.get("text", object_data.get("repeat_text", "")))
	return str(object_data.get("repeat_text", ""))


func _reactive_stage_matches(stage_data: Dictionary) -> bool:
	var has_requirement := false
	var required_flag := str(stage_data.get("required_flag", ""))
	if required_flag != "":
		has_requirement = true
		if not progression_flags.get(required_flag, false):
			return false
	var required_flags_all = stage_data.get("required_flags_all", [])
	if typeof(required_flags_all) == TYPE_ARRAY and not required_flags_all.is_empty():
		has_requirement = true
		for raw_flag in required_flags_all:
			var flag_id := str(raw_flag)
			if flag_id == "":
				continue
			if not progression_flags.get(flag_id, false):
				return false
	return has_requirement


func _initialize_skill_progress() -> void:
	for skill in GameDatabase.get_all_skills():
		var skill_id := str(skill.get("skill_id", ""))
		if skill_id == "":
			continue
		if not skill_experience.has(skill_id):
			skill_experience[skill_id] = 0.0
		if not skill_level_data.has(skill_id):
			skill_level_data[skill_id] = 1
	for runtime_spell_id in GameDatabase.get_runtime_linked_spell_ids():
		if not spell_mastery.has(runtime_spell_id):
			spell_mastery[runtime_spell_id] = 0
		if not spell_level.has(runtime_spell_id):
			spell_level[runtime_spell_id] = 1
		_sync_runtime_spell_level(runtime_spell_id)
	recalculate_circle_progression(false)


func _initialize_buff_runtime() -> void:
	for skill_id in get_registered_buff_skill_ids():
		if not buff_cooldowns.has(skill_id):
			buff_cooldowns[skill_id] = 0.0


func _initialize_spell_hotbar() -> void:
	if spell_hotbar.is_empty():
		spell_hotbar = get_default_spell_hotbar_template()
		return
	var default_hotbar: Array = get_default_spell_hotbar_template()
	var normalized: Array = []
	for i in range(default_hotbar.size()):
		var fallback: Dictionary = default_hotbar[i]
		var slot: Dictionary = fallback.duplicate(true)
		if i < spell_hotbar.size() and typeof(spell_hotbar[i]) == TYPE_DICTIONARY:
			var existing: Dictionary = spell_hotbar[i]
			var existing_action := str(existing.get("action", ""))
			var existing_label := str(existing.get("label", ""))
			if existing_action != "":
				slot["action"] = existing_action
			if existing_label != "":
				slot["label"] = existing_label
			var raw_skill_id := str(existing.get("skill_id", ""))
			if raw_skill_id == "":
				slot["skill_id"] = ""
			else:
				var normalized_skill_id := get_runtime_castable_hotbar_skill_id(raw_skill_id)
				if normalized_skill_id != "":
					slot["skill_id"] = normalized_skill_id
		normalized.append(slot)
	spell_hotbar = normalized


func _initialize_action_hotkey_registry() -> void:
	var defaults: Array = get_default_action_hotkey_registry_template()
	if action_hotkey_registry.is_empty():
		action_hotkey_registry = defaults
		return
	var saved_entries: Dictionary = {}
	for raw_entry in action_hotkey_registry:
		if typeof(raw_entry) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = raw_entry
		var action := str(entry.get("action", ""))
		if action == "":
			continue
		saved_entries[action] = entry
	var normalized: Array = []
	for default_value in defaults:
		var slot: Dictionary = (default_value as Dictionary).duplicate(true)
		var action := str(slot.get("action", ""))
		if saved_entries.has(action):
			var saved_slot: Dictionary = saved_entries[action]
			var normalized_skill_id := get_runtime_castable_hotbar_skill_id(str(saved_slot.get("skill_id", "")))
			if normalized_skill_id != "":
				slot["skill_id"] = normalized_skill_id
			elif str(saved_slot.get("skill_id", "")) == "":
				slot["skill_id"] = ""
		normalized.append(slot)
	action_hotkey_registry = normalized


func _initialize_equipment_state() -> void:
	if equipped_items.is_empty():
		equipped_items = DEFAULT_EQUIPMENT_PRESET.duplicate(true)
	else:
		var normalized: Dictionary = DEFAULT_EQUIPMENT_PRESET.duplicate(true)
		for slot_name in normalized.keys():
			normalized[slot_name] = str(equipped_items.get(slot_name, normalized[slot_name]))
		equipped_items = normalized
	var normalized_inventory: Array = []
	for item_value in equipment_inventory:
		var item_id := str(item_value)
		if item_id == "":
			normalized_inventory.append("")
			continue
		if GameDatabase.get_equipment(item_id).is_empty():
			continue
		normalized_inventory.append(item_id)
	if normalized_inventory.size() > EQUIPMENT_INVENTORY_SLOT_COUNT:
		normalized_inventory = normalized_inventory.slice(0, EQUIPMENT_INVENTORY_SLOT_COUNT)
	while normalized_inventory.size() < EQUIPMENT_INVENTORY_SLOT_COUNT:
		normalized_inventory.append("")
	equipment_inventory = normalized_inventory


func _initialize_stackable_inventory_state() -> void:
	consumable_inventory = _normalize_stackable_inventory_array(consumable_inventory, "consumable")
	other_inventory = _normalize_stackable_inventory_array(other_inventory, "other")


func _normalize_stackable_inventory_array(raw_inventory: Array, kind: String) -> Array:
	var normalized_inventory: Array = []
	for slot_value in raw_inventory:
		normalized_inventory.append(_normalize_stackable_slot_entry(slot_value, kind))
	if normalized_inventory.size() > STACKABLE_INVENTORY_SLOT_COUNT:
		normalized_inventory = normalized_inventory.slice(0, STACKABLE_INVENTORY_SLOT_COUNT)
	while normalized_inventory.size() < STACKABLE_INVENTORY_SLOT_COUNT:
		normalized_inventory.append(_build_empty_stackable_slot())
	return normalized_inventory


func _normalize_stackable_slot_entry(slot_value: Variant, kind: String) -> Dictionary:
	if typeof(slot_value) != TYPE_DICTIONARY:
		return _build_empty_stackable_slot()
	var slot_dict := Dictionary(slot_value)
	var item_id := str(slot_dict.get("item_id", ""))
	var count := int(slot_dict.get("count", 0))
	if item_id == "" or count <= 0:
		return _build_empty_stackable_slot()
	if _get_stackable_item_data(kind, item_id).is_empty():
		return _build_empty_stackable_slot()
	count = clampi(count, 1, _get_stackable_item_max_stack(kind, item_id))
	return {"item_id": item_id, "count": count}


func _build_empty_stackable_slot() -> Dictionary:
	return {"item_id": "", "count": 0}


func _is_stackable_slot_empty(slot_entry: Dictionary) -> bool:
	return str(slot_entry.get("item_id", "")) == "" or int(slot_entry.get("count", 0)) <= 0


func _get_stackable_inventory_snapshot(kind: String) -> Array:
	match kind:
		"consumable":
			return consumable_inventory.duplicate(true)
		"other":
			return other_inventory.duplicate(true)
		_:
			return []


func _set_stackable_inventory(kind: String, inventory: Array) -> void:
	match kind:
		"consumable":
			consumable_inventory = inventory.duplicate(true)
		"other":
			other_inventory = inventory.duplicate(true)


func _get_stackable_item_data(kind: String, item_id: String) -> Dictionary:
	match kind:
		"consumable":
			return GameDatabase.get_consumable_item(item_id)
		"other":
			return GameDatabase.get_other_item(item_id)
		_:
			return {}


func _get_stackable_item_display_name(kind: String, item_id: String) -> String:
	var item := _get_stackable_item_data(kind, item_id)
	if item.is_empty():
		return "(비어 있음)"
	return str(item.get("display_name", item_id))


func _get_stackable_item_max_stack(kind: String, item_id: String) -> int:
	var item := _get_stackable_item_data(kind, item_id)
	if item.is_empty():
		return 9999
	return maxi(int(item.get("max_stack", 9999)), 1)


func _get_stackable_inventory_slot(kind: String, slot_index: int) -> Dictionary:
	_initialize_stackable_inventory_state()
	if slot_index < 0 or slot_index >= STACKABLE_INVENTORY_SLOT_COUNT:
		return _build_empty_stackable_slot()
	var inventory := _get_stackable_inventory_snapshot(kind)
	return _normalize_stackable_slot_entry(inventory[slot_index], kind)


func _get_stackable_inventory_occupied_count(kind: String) -> int:
	_initialize_stackable_inventory_state()
	var total := 0
	for slot_value in _get_stackable_inventory_snapshot(kind):
		if not _is_stackable_slot_empty(_normalize_stackable_slot_entry(slot_value, kind)):
			total += 1
	return total


func _grant_stackable_inventory_item(kind: String, item_id: String, quantity: int) -> bool:
	_initialize_stackable_inventory_state()
	if item_id == "" or quantity <= 0:
		return false
	if _get_stackable_item_data(kind, item_id).is_empty():
		return false
	var inventory := _get_stackable_inventory_snapshot(kind)
	var remaining := quantity
	var max_stack := _get_stackable_item_max_stack(kind, item_id)
	for slot_index in range(inventory.size()):
		var slot_entry := _normalize_stackable_slot_entry(inventory[slot_index], kind)
		if str(slot_entry.get("item_id", "")) != item_id:
			continue
		var count := int(slot_entry.get("count", 0))
		if count >= max_stack:
			continue
		var added := mini(max_stack - count, remaining)
		slot_entry["count"] = count + added
		inventory[slot_index] = slot_entry
		remaining -= added
		if remaining <= 0:
			break
	for slot_index in range(inventory.size()):
		if remaining <= 0:
			break
		var slot_entry := _normalize_stackable_slot_entry(inventory[slot_index], kind)
		if not _is_stackable_slot_empty(slot_entry):
			continue
		var added := mini(max_stack, remaining)
		inventory[slot_index] = {"item_id": item_id, "count": added}
		remaining -= added
	if remaining > 0:
		return false
	_set_stackable_inventory(kind, inventory)
	save_to_disk()
	stats_changed.emit()
	return true


func _find_first_empty_equipment_inventory_slot() -> int:
	_initialize_equipment_state()
	for slot_index in range(equipment_inventory.size()):
		if str(equipment_inventory[slot_index]) == "":
			return slot_index
	return -1


func _get_equipment_stat_total(stat_name: String) -> float:
	_initialize_equipment_state()
	var total := 0.0
	for item_id in equipped_items.values():
		var item: Dictionary = GameDatabase.get_equipment(str(item_id))
		var stats: Dictionary = item.get("stat_modifiers", {})
		total += float(stats.get(stat_name, 0.0))
	return total


func _get_equipment_stat_product(stat_name: String) -> float:
	_initialize_equipment_state()
	var total := 1.0
	for item_id in equipped_items.values():
		var item: Dictionary = GameDatabase.get_equipment(str(item_id))
		var stats: Dictionary = item.get("stat_modifiers", {})
		if stats.has(stat_name):
			total *= float(stats.get(stat_name, 1.0))
	return total


func _get_equipment_display_name(item_id: String) -> String:
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return "(없음)"
	return str(item.get("display_name", item_id))


func _add_skill_experience(skill_id: String, amount: float) -> void:
	if not skill_level_data.has(skill_id):
		skill_level_data[skill_id] = 1
	if not skill_experience.has(skill_id):
		skill_experience[skill_id] = 0.0
	skill_experience[skill_id] = float(skill_experience[skill_id]) + amount
	var leveled_up := false
	while (
		int(skill_level_data[skill_id]) < 30
		and (
			float(skill_experience[skill_id])
			>= _required_experience_for_next_level(int(skill_level_data[skill_id]))
		)
	):
		skill_level_data[skill_id] = int(skill_level_data[skill_id]) + 1
		leveled_up = true
	if leveled_up:
		var skill_data := GameDatabase.get_skill_data(skill_id)
		push_message(
			(
				"%s 레벨이 %d에 도달했습니다. 마법식이 한층 선명해집니다."
				% [skill_data.get("display_name", skill_id), int(skill_level_data[skill_id])]
			),
			2.4
		)
		recalculate_circle_progression()


func _required_experience_for_next_level(current_level: int) -> float:
	return 120.0 + float(max(current_level - 1, 0) * 55)


func _required_experience_for_level(target_level: int) -> float:
	var total := 0.0
	for current_level in range(1, max(target_level, 1)):
		total += _required_experience_for_next_level(current_level)
	return total


func _sync_runtime_spell_level(spell_id: String) -> void:
	var linked_skill_id := get_skill_id_for_spell(spell_id)
	if linked_skill_id == "":
		return
	spell_level[spell_id] = get_skill_level(linked_skill_id)


func try_activate_buff(skill_id: String) -> bool:
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	if skill_data.is_empty() or str(skill_data.get("skill_type", "")) != "buff":
		return false
	var runtime := get_buff_runtime(skill_id, skill_data)
	if runtime.is_empty():
		return false
	var current_cooldown: float = float(buff_cooldowns.get(skill_id, 0.0))
	if current_cooldown > 0.0 and not admin_ignore_cooldowns:
		push_message("%s은(는) 아직 재정비 중입니다." % skill_data.get("display_name", skill_id), 1.2)
		return false
	if not admin_ignore_cooldowns:
		for penalty in active_penalties:
			if str(penalty.get("stat", "")) == "ritual_recast_lock":
				push_message(
					(
						"의식의 여파가 %.1fs 동안 당신의 시전 패턴을 봉합니다."
						% float(penalty.get("remaining", 0.0))
					),
					1.6
				)
				return false
	if active_buffs.size() >= get_buff_slot_limit() and not admin_ignore_buff_slot_limit:
		push_message(
			(
				"현재 서클에서는 동시에 %d개의 버프 패턴만 안정화할 수 있습니다."
				% get_buff_slot_limit()
			),
			1.6
		)
		return false
	if not consume_skill_mana(skill_id):
		push_message(
			(
				"%s을(를) 안정화할 만큼 마나가 충분하지 않습니다."
				% skill_data.get("display_name", skill_id)
			),
			1.2
		)
		return false
	active_buffs.append(
		{
			"skill_id": skill_id,
			"display_name": skill_data.get("display_name", skill_id),
			"remaining": float(runtime.get("duration", 0.0)),
			"effects": runtime.get("effects", []).duplicate(true)
		}
	)
	buff_cooldowns[skill_id] = float(runtime.get("cooldown", 0.0))
	for effect in skill_data.get("downside_effects", []):
		if (
			str(effect.get("stat", "")) == "mana_percent"
			and str(effect.get("mode", "")) == "set"
			and float(effect.get("duration", 0.0)) == 0.0
		):
			mana = clampf(max_mana * float(effect.get("value", 1.0)), 0.0, max_mana)
	_refresh_combo_runtime()
	push_message("%s 효과가 타오르듯 깨어납니다." % skill_data.get("display_name", skill_id), 1.4)
	stats_changed.emit()
	return true


func get_buff_runtime(skill_id: String, skill_data: Dictionary = {}, level_override: int = -1) -> Dictionary:
	var resolved_skill_data: Dictionary = _resolve_runtime_skill_data(skill_id, skill_data)
	var resolved_skill_id: String = _resolve_runtime_skill_id(skill_id, resolved_skill_data)
	if resolved_skill_data.is_empty() or str(resolved_skill_data.get("skill_type", "")) != "buff":
		return {}
	return {
		"skill_id": resolved_skill_id,
		"display_name": str(resolved_skill_data.get("display_name", resolved_skill_id)),
		"school": resolve_runtime_school(
			resolved_skill_id,
			"",
			str(resolved_skill_data.get("element", "arcane"))
		),
		"duration": _get_scaled_buff_duration(
			resolved_skill_id,
			float(resolved_skill_data.get("duration_base", 0.0)),
			level_override
		),
		"cooldown": _get_scaled_buff_cooldown(
			resolved_skill_id,
			float(resolved_skill_data.get("cooldown_base", 0.0)),
			level_override
		),
		"effects": _get_scaled_buff_effects(
			resolved_skill_id,
			resolved_skill_data,
			level_override
		)
	}


func get_buff_slot_limit() -> int:
	if current_circle >= 10:
		return 5
	if current_circle >= 8:
		return 4
	if current_circle >= 6:
		return 3
	return 2


func get_current_circle() -> int:
	return current_circle


func get_circle_progress_score() -> float:
	return circle_progress_score


func recalculate_circle_progression(announce: bool = true) -> void:
	var previous_circle: int = current_circle
	var total_levels := 0
	var skill_count := 0
	var level20_count := 0
	var level25_count := 0
	var level30_count := 0
	var level10_count := 0
	var level12_count := 0
	var level15_count := 0
	var level18_count := 0
	var level22_count := 0
	var level26_count := 0
	for skill in GameDatabase.get_all_skills():
		var skill_id: String = str(skill.get("skill_id", ""))
		if skill_id == "":
			continue
		var level: int = get_skill_level(skill_id)
		total_levels += level
		skill_count += 1
		if level >= 20:
			level20_count += 1
		if level >= 25:
			level25_count += 1
		if level >= 30:
			level30_count += 1
		if level >= 10:
			level10_count += 1
		if level >= 12:
			level12_count += 1
		if level >= 15:
			level15_count += 1
		if level >= 18:
			level18_count += 1
		if level >= 22:
			level22_count += 1
		if level >= 26:
			level26_count += 1
	var average_level: float = 1.0
	if skill_count > 0:
		average_level = round(float(total_levels) / float(skill_count))
	var bonus_score: float = (
		float(level20_count) * 0.2 + float(level25_count) * 0.2 + float(level30_count) * 0.3
	)
	circle_progress_score = average_level + bonus_score
	current_circle = 4
	if circle_progress_score >= 19.0 and level26_count >= 8:
		current_circle = 10
	elif circle_progress_score >= 15.0 and level22_count >= 7:
		current_circle = 9
	elif circle_progress_score >= 12.0 and level18_count >= 6:
		current_circle = 8
	elif circle_progress_score >= 9.0 and level15_count >= 5:
		current_circle = 7
	elif circle_progress_score >= 6.0 and level12_count >= 4:
		current_circle = 6
	elif circle_progress_score >= 3.0 and level10_count >= 3:
		current_circle = 5
	current_circle = max(current_circle, 4)
	if announce and current_circle > previous_circle:
		push_message(
			(
				"당신의 마법 격자가 %d서클로 안정화되었습니다. 동시에 유지할 수 있는 버프가 늘어납니다."
				% current_circle
			),
			2.6
		)
	stats_changed.emit()


func grant_progression_event(event_id: String) -> bool:
	if progression_flags.get(event_id, false):
		return false
	progression_flags[event_id] = true
	match event_id:
		"rest_entrance":
			_grant_skill_level_bonus("fire_ember_dart", 4)
			_grant_skill_level_bonus("ice_frost_needle", 4)
			_grant_skill_level_bonus("lightning_thunder_lance", 4)
			_grant_skill_level_bonus("arcane_magic_mastery", 4)
			push_message(
				"유지 봉인이 당신의 마법 격자를 안정화합니다. 핵심 기술들이 함께 날카로워집니다.",
				2.8
			)
		"echo_entrance_1":
			_grant_skill_level_bonus("fire_ember_dart", 2)
			push_message("미라의 흔적이 더 뜨거운 시전 리듬을 남깁니다.", 2.4)
		"echo_entrance_2":
			_grant_skill_level_bonus("ice_frost_needle", 2)
			push_message("반복된 잔향이 더 차가운 형상을 붙잡는 법을 가르쳐 줍니다.", 2.4)
		"boss_conduit":
			_grant_all_skill_levels(3)
			push_message(
				"쓰러진 수호자의 코어가 당신이 아는 모든 마법에 강제된 이해의 파동을 흘려보냅니다.",
				3.0
			)
		"core_conduit":
			_grant_all_skill_levels(2)
			push_message(
				"바닥 코어가 당신의 마법 격자를 더 깊은 곳으로 끌어내려, 익힌 패턴 전부를 한꺼번에 다듬습니다.",
				3.0
			)
		"echo_deep_0":
			_grant_skill_level_bonus("lightning_thunder_lance", 2)
			push_message(
				"늦게 울리는 발소리가 본능보다 한 박자 먼저 번개를 놓는 법을 가르칩니다.",
				2.4
			)
		"seal_sanctum_anchor":
			push_message(
				"피난처 봉인이 당신의 흔적을 받아들였습니다. 지금만큼은 미궁도 이 방을 피신처로 남겨둘 수밖에 없습니다.",
				3.0
			)
		"royal_inner_hall_archive":
			push_message(
				"무너진 가계 장부가 이 층이 도시가 뒤집히기 전 궁정의 생활 중심지였음을 증명합니다.",
				3.0
			)
		"throne_approach_decree":
			push_message(
				"남아 있는 칙령은 여전히 복종을 요구합니다. 지금도 옥좌 회랑은 굴복이 필연처럼 느껴지도록 강요합니다.",
				3.0
			)
		"royal_inner_hall_companion_trace":
			push_message(
				"지원 마법의 잔재가 복도에 달라붙어 있습니다. 당신과 가까운 누군가가 먼저 내전에 닿았고, 무사히 돌아오지 못했습니다.",
				3.0
			)
		"throne_approach_companion_trace":
			push_message(
				"옥좌 회랑에는 익숙한 지원의 리듬이 아직 남아 있지만, 강압적인 형태로 늘어나 있습니다. 동료 B는 이 방이 허용해서는 안 될 만큼 가까이에 있습니다.",
				3.0
			)
		"inverted_spire_covenant":
			push_message(
				"계약의 제단은 왕의 마지막 실수를 완벽한 형태로 보존하고 있습니다. 구원이 소거와 맞바뀐 곳이 바로 여기입니다.",
				3.2
			)
		"echo_deep_1":
			_grant_skill_level_bonus("arcane_magic_mastery", 2)
			push_message(
				"긁힌 나선이 당신의 집중 속에 가라앉습니다. 기초 제어력마저 더 조밀해집니다.",
				2.4
			)
		_:
			return false
	progression_event_granted.emit(event_id)
	recalculate_circle_progression()
	save_to_disk()
	return true


func _grant_all_skill_levels(amount: int) -> void:
	for skill in GameDatabase.get_all_skills():
		var skill_id: String = str(skill.get("skill_id", ""))
		if skill_id == "":
			continue
		_grant_skill_level_bonus(skill_id, amount)


func _grant_skill_level_bonus(skill_id: String, amount: int) -> void:
	if not skill_level_data.has(skill_id):
		skill_level_data[skill_id] = 1
	skill_level_data[skill_id] = min(int(skill_level_data[skill_id]) + amount, 30)
	for runtime_spell_id in GameDatabase.get_runtime_spell_ids_for_skill(skill_id):
		_sync_runtime_spell_level(runtime_spell_id)


func get_player_move_multiplier() -> float:
	var total := 1.0
	for effect in _collect_active_effects():
		if str(effect.get("stat", "")) == "move_speed_multiplier":
			total = _apply_multiplier_effect(total, effect)
	return total


func get_player_jump_velocity_multiplier() -> float:
	var total := 1.0
	for effect in _collect_active_effects():
		if str(effect.get("stat", "")) == "jump_velocity_multiplier":
			total = _apply_multiplier_effect(total, effect)
	return total


func get_player_gravity_multiplier() -> float:
	var total := 1.0
	for effect in _collect_active_effects():
		if str(effect.get("stat", "")) == "gravity_multiplier":
			total = _apply_multiplier_effect(total, effect)
	return clampf(total, 0.2, 2.5)


func get_player_air_jump_bonus() -> int:
	var total := 0
	for effect in _collect_active_effects():
		if str(effect.get("stat", "")) == "air_jump_bonus":
			total += int(round(float(effect.get("value", 0.0))))
	return maxi(total, 0)


func get_damage_taken_multiplier() -> float:
	var total := get_equipment_damage_taken_multiplier()
	for effect in _collect_active_effects():
		var stat := str(effect.get("stat", ""))
		if stat == "damage_taken_multiplier":
			total = _apply_multiplier_effect(total, effect)
		elif stat == "defense_multiplier":
			var def_val := float(effect.get("value", 1.0))
			if def_val > 0.0:
				total /= def_val
	if soul_dominion_active:
		total *= SOUL_DOMINION_DAMAGE_TAKEN_MULT
	elif soul_dominion_aftershock_timer > 0.0:
		total *= SOUL_DOMINION_AFTERSHOCK_DAMAGE_MULT
	return total


func get_active_buff_summary() -> String:
	if active_buffs.is_empty():
		return "버프  없음"
	# Group by skill_id to show stack count when the same buff is cast multiple times
	var skill_order: Array[String] = []
	var stacks_by_id: Dictionary = {}
	var first_buff_by_id: Dictionary = {}
	for buff in active_buffs:
		var sid := str(buff.get("skill_id", "?"))
		if not stacks_by_id.has(sid):
			stacks_by_id[sid] = 0
			first_buff_by_id[sid] = buff
			skill_order.append(sid)
		stacks_by_id[sid] += 1
	var parts: Array[String] = []
	for sid in skill_order:
		var buff: Dictionary = first_buff_by_id[sid]
		var display_name := str(buff.get("display_name", "?"))
		var stacks := int(stacks_by_id.get(sid, 1))
		var remaining := float(buff.get("remaining", 0.0))
		var stack_text := " x%d" % stacks if stacks > 1 else ""
		var expiry_marker := " !" if remaining < 2.0 else ""
		parts.append("%s%s %.1fs%s" % [display_name, stack_text, remaining, expiry_marker])
	var limit_text := "무제한" if admin_ignore_buff_slot_limit else str(get_buff_slot_limit())
	return "버프  %s / %s  %s" % [active_buffs.size(), limit_text, " | ".join(parts)]


func get_buff_cooldown_summary() -> String:
	var parts: Array[String] = []
	for skill_id in get_registered_buff_skill_ids():
		var cd := float(buff_cooldowns.get(skill_id, 0.0))
		if cd <= 0.0:
			continue
		var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
		var name_text := str(skill_data.get("display_name", skill_id))
		parts.append("%s 재사용:%.1fs" % [name_text, cd])
	if parts.is_empty():
		return "재사용 대기  모두 준비 완료"
	return "재사용 대기  %s" % " | ".join(parts)


func get_active_combo_names() -> Array[String]:
	var names: Array[String] = []
	for combo in _get_active_combos():
		names.append(str(combo.get("display_name", combo.get("combo_id", "?"))))
	if _is_overclock_circuit_runtime_active():
		names.append("오버클럭 회로")
	return names


func get_combo_summary() -> String:
	var names := get_active_combo_names()
	var ritual_text := _get_ashen_rite_aftermath_summary()
	if names.is_empty() and ritual_text.is_empty():
		return "콤보  없음"
	# [BURST] prefix makes the burst window immediately visible during sandbox play
	var burst_prefix := "[폭주] " if (time_collapse_active or ashen_rite_active or _is_overclock_circuit_runtime_active()) else ""
	var barrier_text := ""
	if combo_barrier > 0.0:
		barrier_text = "  장벽 %.0f" % combo_barrier
	var time_text := ""
	if time_collapse_active:
		var min_remaining := 0.0
		for buff in active_buffs:
			var sid := str(buff.get("skill_id", ""))
			if sid in ["arcane_astral_compression", "arcane_world_hourglass"]:
				var r := float(buff.get("remaining", 0.0))
				if min_remaining == 0.0 or r < min_remaining:
					min_remaining = r
		time_text = "  시간 충전 %d" % time_collapse_charges
		if min_remaining > 0.0:
			time_text += "  종료 %.1fs" % min_remaining
	var ash_text := ""
	if ashen_rite_active:
		ash_text = "  재 스택 %d" % ash_stacks
	var overclock_text := ""
	if _is_overclock_circuit_runtime_active():
		overclock_text = "  오버클럭 %.1fs" % overclock_circuit_timer
	var funeral_text := ""
	if funeral_bloom_active:
		funeral_text = (
			"  개화"
			+ (
				"  내부 대기 %.1fs" % funeral_bloom_icd_timer
				if funeral_bloom_icd_timer > 0.0
				else "  준비 완료"
			)
		)
	return (
		"%s콤보  %s%s%s%s%s%s%s"
		% [
			burst_prefix,
			", ".join(names) if not names.is_empty() else "없음",
			barrier_text,
			time_text,
			ash_text,
			overclock_text,
			funeral_text,
			ritual_text
		]
	)


func get_resource_status_line() -> String:
	var dmg_suffix := ""
	if last_damage_display_timer > 0.0 and last_damage_amount > 0:
		if last_damage_school != "":
			dmg_suffix = " [←%d %s]" % [last_damage_amount, get_school_display_name(last_damage_school)]
		else:
			dmg_suffix = " [←%d]" % last_damage_amount
	var soul_suffix := ""
	if soul_dominion_active:
		soul_suffix = (
			"  [!MP 봉인 피격 +%d%%]" % int(round((SOUL_DOMINION_DAMAGE_TAKEN_MULT - 1.0) * 100.0))
		)
	elif soul_dominion_aftershock_timer > 0.0:
		soul_suffix = (
			"  [!여진 %.1fs 피격 +%d%%]"
			% [
				soul_dominion_aftershock_timer,
				int(round((SOUL_DOMINION_AFTERSHOCK_DAMAGE_MULT - 1.0) * 100.0))
			]
		)
	return (
		"HP %d/%d%s   MP %.0f/%.0f%s"
		% [health, max_health, dmg_suffix, mana, max_mana, soul_suffix]
	)


func get_soul_dominion_risk_summary() -> String:
	if soul_dominion_active:
		return (
			"소울 도미니언 활성  [MP 회복 봉인 | 피격 x%.2f]" % SOUL_DOMINION_DAMAGE_TAKEN_MULT
		)
	if soul_dominion_aftershock_timer > 0.0:
		return (
			"소울 도미니언 여진  %.1fs  [MP 회복 봉인 | 피격 x%.2f]"
			% [soul_dominion_aftershock_timer, SOUL_DOMINION_AFTERSHOCK_DAMAGE_MULT]
		)
	return ""


func _tick_buff_runtime(delta: float) -> void:
	for skill_id in buff_cooldowns.keys():
		buff_cooldowns[skill_id] = max(float(buff_cooldowns[skill_id]) - delta, 0.0)
	var expired: Array = []
	for buff in active_buffs:
		buff["remaining"] = max(float(buff.get("remaining", 0.0)) - delta, 0.0)
		if float(buff["remaining"]) <= 0.0:
			expired.append(buff)
	for buff in expired:
		_expire_buff(buff)
		active_buffs.erase(buff)
	var expired_field_effects: Array = []
	for field_effect in active_field_effects:
		field_effect["remaining"] = max(float(field_effect.get("remaining", 0.0)) - delta, 0.0)
		if float(field_effect.get("remaining", 0.0)) <= 0.0:
			expired_field_effects.append(field_effect)
	active_field_effects = active_field_effects.filter(
		func(entry: Dictionary) -> bool: return float(entry.get("remaining", 0.0)) > 0.0
	)
	for penalty in active_penalties:
		penalty["remaining"] = max(float(penalty.get("remaining", 0.0)) - delta, 0.0)
	active_penalties = active_penalties.filter(
		func(entry: Dictionary) -> bool: return float(entry.get("remaining", 0.0)) > 0.0
	)
	if soul_dominion_aftershock_timer > 0.0:
		soul_dominion_aftershock_timer = maxf(soul_dominion_aftershock_timer - delta, 0.0)
	if overclock_circuit_timer > 0.0:
		overclock_circuit_timer = maxf(overclock_circuit_timer - delta, 0.0)
	if overclock_circuit_timer <= 0.0:
		overclock_circuit_active = false
	if funeral_bloom_icd_timer > 0.0:
		funeral_bloom_icd_timer = maxf(funeral_bloom_icd_timer - delta, 0.0)
	var has_ash_burst := ashen_rite_active or _has_active_buff_effect_enabled(
		"dark_throne_of_ash", "ash_residue_burst"
	)
	if has_ash_burst:
		ash_residue_timer = max(ash_residue_timer - delta, 0.0)
		if ash_residue_timer <= 0.0:
			ash_residue_timer = _get_ash_residue_interval()
			var ash_residue_payload := _build_ash_residue_payload()
			if not ash_residue_payload.is_empty():
				_emit_combo_effect(ash_residue_payload)
	_tick_active_buff_drains(delta)
	_refresh_combo_runtime()
	if not expired.is_empty() or not expired_field_effects.is_empty():
		stats_changed.emit()


func _tick_active_buff_drains(delta: float) -> void:
	if admin_infinite_health:
		return
	for buff in active_buffs:
		var skill_data: Dictionary = GameDatabase.get_skill_data(str(buff.get("skill_id", "")))
		for effect in skill_data.get("downside_effects", []):
			if (
				str(effect.get("stat", "")) == "hp_drain_percent_per_second"
				and float(effect.get("duration", 0.0)) == 0.0
			):
				var drain: int = int(
					round(float(max_health) * float(effect.get("value", 0.0)) * delta)
				)
				if drain > 0 and health > 1:
					health = max(health - drain, 1)
					stats_changed.emit()
	for penalty in active_penalties:
		if str(penalty.get("stat", "")) == "self_burn":
			var burn_damage: int = int(
				round(float(max_health) * float(penalty.get("value", 0)) * 0.01 * delta)
			)
			if burn_damage > 0 and health > 1:
				health = max(health - burn_damage, 1)
				stats_changed.emit()


func get_poise_bonus() -> float:
	var total: float = 0.0
	for effect in _collect_active_effects():
		if str(effect.get("stat", "")) == "poise_bonus":
			total += float(effect.get("value", 0.0))
	return total


func get_super_armor_charges() -> int:
	var total: int = 0
	for effect in _collect_active_effects():
		if str(effect.get("stat", "")) == "super_armor_charges":
			total += int(effect.get("value", 0))
	return total


func get_status_resistance() -> float:
	var total: float = 0.0
	for effect in _collect_active_effects():
		if str(effect.get("stat", "")) == "status_resistance":
			total += float(effect.get("value", 0.0))
	return total


func get_stagger_taken_multiplier() -> float:
	var total: float = 1.0
	for effect in _collect_active_effects():
		if str(effect.get("stat", "")) == "stagger_taken_multiplier":
			total *= float(effect.get("value", 1.0))
	return total


func record_enemy_hit(amount: int, school: String) -> void:
	session_damage_dealt += amount
	session_hit_count += 1
	if not school.is_empty():
		var key := "school_hits_" + school
		progression_flags[key] = int(progression_flags.get(key, 0)) + 1


func get_combat_stats_summary() -> String:
	return "타격: %d  피해: %d" % [session_hit_count, session_damage_dealt]


func _tick_mana_regeneration(delta: float) -> void:
	if admin_infinite_mana:
		if mana != max_mana:
			mana = max_mana
			stats_changed.emit()
		return
	if soul_dominion_active or soul_dominion_aftershock_timer > 0.0:
		return
	if mana >= max_mana:
		return
	var regen_multiplier: float = 1.0
	for effect in _collect_active_effects():
		if str(effect.get("stat", "")) == "mana_regen_multiplier":
			regen_multiplier *= float(effect.get("value", 1.0))
	if regen_multiplier <= 0.0:
		return
	var previous_mana: float = mana
	mana = min(mana + mana_regen_per_second * regen_multiplier * delta, max_mana)
	if absf(mana - previous_mana) > 0.001:
		stats_changed.emit()


func _recalculate_derived_stats(keep_ratios: bool = true) -> void:
	_initialize_equipment_state()
	var previous_health_ratio := 1.0
	var previous_mana_ratio := 1.0
	if keep_ratios and max_health > 0:
		previous_health_ratio = clampf(float(health) / float(max_health), 0.0, 1.0)
	if keep_ratios and max_mana > 0.0:
		previous_mana_ratio = clampf(mana / max_mana, 0.0, 1.0)
	max_health = BASE_MAX_HEALTH + get_equipment_bonus_max_health()
	max_mana = BASE_MAX_MANA + get_equipment_bonus_max_mana()
	mana_regen_per_second = BASE_MANA_REGEN_PER_SECOND + get_equipment_bonus_mana_regen()
	if keep_ratios:
		health = int(round(previous_health_ratio * float(max_health)))
		mana = previous_mana_ratio * max_mana
	else:
		health = min(health, max_health)
		mana = min(mana, max_mana)
	if admin_infinite_health:
		health = max_health
	if admin_infinite_mana:
		mana = max_mana


func _expire_buff(buff: Dictionary) -> void:
	var skill_id := str(buff.get("skill_id", ""))
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	for effect in skill_data.get("downside_effects", []):
		var penalty: Dictionary = effect.duplicate(true)
		penalty["remaining"] = float(effect.get("duration", 0.0))
		active_penalties.append(penalty)


func _apply_combo_penalties(raw_penalties: Variant) -> void:
	if typeof(raw_penalties) != TYPE_ARRAY:
		return
	var penalties: Array = raw_penalties
	for raw_penalty in penalties:
		if typeof(raw_penalty) != TYPE_DICTIONARY:
			continue
		var penalty: Dictionary = raw_penalty.duplicate(true)
		var stat_name := str(penalty.get("stat", ""))
		var duration := float(penalty.get("duration", 0.0))
		if (
			stat_name == "mana_percent"
			and str(penalty.get("mode", "")) == "set"
			and duration <= 0.0
		):
			mana = clampf(max_mana * float(penalty.get("value", 1.0)), 0.0, max_mana)
			continue
		if duration > 0.0:
			penalty["remaining"] = duration
			active_penalties.append(penalty)


func _build_ashen_rite_aftermath_message(raw_penalties: Variant) -> String:
	var guard_break_duration := 0.0
	var recast_lock_duration := 0.0
	if typeof(raw_penalties) == TYPE_ARRAY:
		for raw_penalty in raw_penalties:
			if typeof(raw_penalty) != TYPE_DICTIONARY:
				continue
			var penalty: Dictionary = raw_penalty
			var stat_name := str(penalty.get("stat", ""))
			var duration := float(penalty.get("duration", 0.0))
			if stat_name == "defense_multiplier":
				guard_break_duration = max(guard_break_duration, duration)
			elif stat_name == "ritual_recast_lock":
				recast_lock_duration = max(recast_lock_duration, duration)
	var parts: Array[String] = ["애셴 라이트가 당신의 자원을 삼켜 버립니다."]
	if guard_break_duration > 0.0:
		parts.append("방어 약화 %.0fs." % guard_break_duration)
	if recast_lock_duration > 0.0:
		parts.append("재시전 봉인 %.0fs." % recast_lock_duration)
	return " ".join(parts)


func _collect_active_effects() -> Array:
	var effects: Array = []
	for buff in active_buffs:
		for effect in buff.get("effects", []):
			effects.append(effect)
	for field_effect in active_field_effects:
		for effect in field_effect.get("effects", []):
			effects.append(effect)
	for combo in _get_active_combos():
		for effect in combo.get("applied_effects", []):
			effects.append(effect)
	for penalty in active_penalties:
		effects.append(penalty)
	return effects


func _find_active_buff_effect(skill_id: String, stat_name: String) -> Dictionary:
	for raw_buff in active_buffs:
		if typeof(raw_buff) != TYPE_DICTIONARY:
			continue
		var buff: Dictionary = raw_buff
		if str(buff.get("skill_id", "")) != skill_id:
			continue
		for raw_effect in buff.get("effects", []):
			if typeof(raw_effect) != TYPE_DICTIONARY:
				continue
			var effect: Dictionary = raw_effect
			if str(effect.get("stat", "")).strip_edges() == stat_name:
				return effect.duplicate(true)
	return {}


func _get_active_buff_effect_value(skill_id: String, stat_name: String) -> Variant:
	var effect := _find_active_buff_effect(skill_id, stat_name)
	if effect.is_empty():
		return null
	return effect.get("value", null)


func _has_active_buff_effect_enabled(skill_id: String, stat_name: String) -> bool:
	var effect := _find_active_buff_effect(skill_id, stat_name)
	if effect.is_empty():
		return false
	return int(effect.get("value", 0)) > 0


func _build_active_buff_secondary_effect_payload(
	skill_id: String, payload_prefix: String, base_damage: float
) -> Dictionary:
	var effect_id_value: Variant = _get_active_buff_effect_value(
		skill_id, "%s_effect_id" % payload_prefix
	)
	var school_value: Variant = _get_active_buff_effect_value(skill_id, "%s_school" % payload_prefix)
	var damage_ratio_value: Variant = _get_active_buff_effect_value(
		skill_id, "%s_damage_ratio" % payload_prefix
	)
	var radius_value: Variant = _get_active_buff_effect_value(skill_id, "%s_radius" % payload_prefix)
	var color_value: Variant = _get_active_buff_effect_value(skill_id, "%s_color" % payload_prefix)
	if (
		typeof(effect_id_value) != TYPE_STRING
		or str(effect_id_value).strip_edges().is_empty()
		or typeof(school_value) != TYPE_STRING
		or str(school_value).strip_edges().is_empty()
		or typeof(color_value) != TYPE_STRING
		or str(color_value).strip_edges().is_empty()
	):
		return {}
	if typeof(damage_ratio_value) != TYPE_INT and typeof(damage_ratio_value) != TYPE_FLOAT:
		return {}
	if typeof(radius_value) != TYPE_INT and typeof(radius_value) != TYPE_FLOAT:
		return {}
	var school := str(school_value).strip_edges()
	return {
		"effect_id": str(effect_id_value).strip_edges(),
		"school": school,
		"damage_school": school,
		"damage": int(round(base_damage * float(damage_ratio_value))),
		"radius": float(radius_value),
		"color": str(color_value).strip_edges()
	}


func _get_penalty_remaining(stat_name: String) -> float:
	var remaining := 0.0
	for penalty in active_penalties:
		if str(penalty.get("stat", "")) == stat_name:
			remaining = max(remaining, float(penalty.get("remaining", 0.0)))
	return remaining


func _get_ashen_rite_aftermath_summary() -> String:
	var guard_break_remaining := _get_penalty_remaining("defense_multiplier")
	var recast_lock_remaining := _get_penalty_remaining("ritual_recast_lock")
	if guard_break_remaining <= 0.0 and recast_lock_remaining <= 0.0:
		return ""
	var parts: Array[String] = ["  후유증"]
	if guard_break_remaining > 0.0:
		parts.append("방어 붕괴 %.1fs" % guard_break_remaining)
	if recast_lock_remaining > 0.0:
		parts.append("재시전 봉인 %.1fs" % recast_lock_remaining)
	return "  ".join(parts)


func _get_active_combos() -> Array:
	var active_ids: Array[String] = []
	for buff in active_buffs:
		active_ids.append(str(buff.get("skill_id", "")))
	var combos: Array = []
	for combo in GameDatabase.get_all_buff_combos():
		var required: Array = combo.get("required_buffs", [])
		var valid := true
		for required_id in required:
			if not active_ids.has(str(required_id)):
				valid = false
				break
		if valid:
			combos.append(combo)
	combos.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return int(a.get("priority", 0)) > int(b.get("priority", 0))
	)
	return combos


func _refresh_combo_runtime() -> void:
	var prismatic_combo: Dictionary = {}
	for combo in _get_active_combos():
		if str(combo.get("combo_id", "")) == "combo_prismatic_guard":
			prismatic_combo = combo
			break
	if prismatic_combo.is_empty():
		combo_barrier = 0.0
		combo_barrier_combo_id = ""
	else:
		var barrier_ratio := 0.0
		for effect in prismatic_combo.get("applied_effects", []):
			if str(effect.get("stat", "")) == "max_hp_barrier_ratio":
				barrier_ratio = float(effect.get("value", 0.0))
				break
		if combo_barrier_combo_id != "combo_prismatic_guard":
			combo_barrier = max_health * barrier_ratio * get_equipment_barrier_power_multiplier()
			combo_barrier_combo_id = "combo_prismatic_guard"
			push_message("프리즈매틱 가드가 가시적인 마나 장벽으로 응축됩니다.", 1.2)
	var time_combo_found := false
	for combo in _get_active_combos():
		if str(combo.get("combo_id", "")) == "combo_time_collapse":
			time_combo_found = true
			break
	if time_combo_found and not time_collapse_active:
		var opening_charges := _get_time_collapse_charge_count()
		if opening_charges > 0:
			time_collapse_active = true
			time_collapse_charges = opening_charges
			push_message("타임 콜랩스가 짧은 과부하 시전 창을 엽니다.", 1.2)
	elif not time_combo_found:
		time_collapse_active = false
		time_collapse_charges = 0
	if overclock_circuit_active and not _has_active_buff("lightning_conductive_surge"):
		overclock_circuit_active = false
		overclock_circuit_timer = 0.0
	var funeral_found := false
	for combo in _get_active_combos():
		if str(combo.get("combo_id", "")) == "combo_funeral_bloom":
			funeral_found = true
			break
	if funeral_found and not funeral_bloom_active:
		funeral_bloom_active = true
		push_message("퓨너럴 블룸이 깨어납니다. 설치 처치가 폭발로 이어집니다.", 1.2)
	elif not funeral_found and funeral_bloom_active:
		funeral_bloom_active = false
		funeral_bloom_icd_timer = 0.0
	var ashen_found := false
	for combo in _get_active_combos():
		if str(combo.get("combo_id", "")) == "combo_ashen_rite":
			ashen_found = true
			break
	if ashen_found and not ashen_rite_active:
		ashen_rite_active = true
		ash_stacks = 0
		ash_residue_timer = _get_ash_residue_interval()
		push_message("애셴 라이트가 시작됩니다. 이제 마법 충격이 의식을 먹여 살립니다.", 1.2)
	elif not ashen_found and ashen_rite_active:
		if ash_stacks > 0:
			var end_payload := _build_ashen_rite_end_payload()
			if not end_payload.is_empty():
				_emit_combo_effect(end_payload)
		var ashen_combo := GameDatabase.get_buff_combo("combo_ashen_rite")
		var penalties: Variant = ashen_combo.get("penalties", [])
		_apply_combo_penalties(penalties)
		push_message(_build_ashen_rite_aftermath_message(penalties), 2.0)
		ashen_rite_active = false
		ash_stacks = 0
		ash_residue_timer = 0.0


func _apply_buff_runtime_modifiers(data: Dictionary) -> Dictionary:
	var school: String = str(data.get("school", ""))
	for effect in _collect_active_effects():
		var stat := str(effect.get("stat", ""))
		match stat:
			"fire_final_damage_multiplier":
				if school == "fire":
					data["damage"] = int(
						round(float(data.get("damage", 0.0)) * float(effect.get("value", 1.0)))
					)
			"lightning_final_damage_multiplier":
				if school == "lightning":
					data["damage"] = int(
						round(float(data.get("damage", 0.0)) * float(effect.get("value", 1.0)))
					)
			"lightning_aftercast_multiplier":
				if school == "lightning":
					data["cooldown"] = (
						float(data.get("cooldown", 0.0)) * float(effect.get("value", 1.0))
					)
			"ice_status_duration_multiplier":
				if school == "ice" and data.has("duration"):
					data["duration"] = (
						float(data.get("duration", 0.0)) * float(effect.get("value", 1.0))
					)
			"final_damage_multiplier":
				data["damage"] = int(
					round(float(data.get("damage", 0.0)) * float(effect.get("value", 1.0)))
				)
			"discounted_cooldown_spend_multiplier":
				if time_collapse_active and time_collapse_charges > 0:
					data["cooldown"] = (
						float(data.get("cooldown", 0.0)) * float(effect.get("value", 1.0))
					)
			"lightning_chain_bonus":
				if school == "lightning":
					data["pierce"] = int(data.get("pierce", 0)) + int(effect.get("value", 0))
			"chain_bonus":
				if school == "lightning":
					data["pierce"] = int(data.get("pierce", 0)) + int(effect.get("value", 0))
			"dash_cast_speed_multiplier":
				if school == "lightning" and data.has("speed"):
					data["speed"] = float(data.get("speed", 0.0)) * float(effect.get("value", 1.0))
			"dark_final_damage_multiplier":
				if school == "dark":
					data["damage"] = int(
						round(float(data.get("damage", 0.0)) * float(effect.get("value", 1.0)))
					)
			"aftercast_multiplier":
				data["cooldown"] = (
					float(data.get("cooldown", 0.0)) * float(effect.get("value", 1.0))
				)
			"cast_speed_multiplier":
				var spd := float(effect.get("value", 1.0))
				if spd > 0.0:
					data["cooldown"] = float(data.get("cooldown", 0.0)) / spd
			"cooldown_flow_multiplier":
				data["cooldown"] = (
					float(data.get("cooldown", 0.0)) * float(effect.get("value", 1.0))
				)
			_:
				pass
	if _should_apply_overclock_circuit_to_runtime(data):
		if data.has("cooldown"):
			data["cooldown"] = float(data.get("cooldown", 0.0)) * OVERCLOCK_CIRCUIT_AFTERCAST_MULT
		data["pierce"] = int(data.get("pierce", 0)) + OVERCLOCK_CIRCUIT_CHAIN_BONUS
		if data.has("speed"):
			data["speed"] = float(data.get("speed", 0.0)) * OVERCLOCK_CIRCUIT_SPEED_MULT
	return data


func _has_active_buff(skill_id: String) -> bool:
	for raw_buff in active_buffs:
		if typeof(raw_buff) != TYPE_DICTIONARY:
			continue
		if str(raw_buff.get("skill_id", "")) == skill_id:
			return true
	return false


func _resolve_skill_type_for_runtime_id(runtime_id: String) -> String:
	if runtime_id.is_empty():
		return ""
	var skill_id := get_skill_id_for_spell(runtime_id)
	if skill_id == "":
		skill_id = runtime_id
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	return str(skill_data.get("skill_type", ""))


func _should_open_overclock_circuit_from_spell(spell_id: String) -> bool:
	var linked_skill_id := get_skill_id_for_spell(spell_id)
	if linked_skill_id == "":
		linked_skill_id = spell_id
	return linked_skill_id == "wind_tempest_drive" and _has_active_buff("lightning_conductive_surge")


func _activate_overclock_circuit_window() -> void:
	var was_active := _is_overclock_circuit_runtime_active()
	overclock_circuit_active = true
	overclock_circuit_timer = OVERCLOCK_CIRCUIT_WINDOW_DURATION
	if not was_active:
		push_message("오버클럭 회로가 열립니다. 다음 전기 시전이 한층 더 치고 나갑니다.", 1.2)


func _is_overclock_circuit_runtime_active() -> bool:
	return (
		overclock_circuit_active
		and overclock_circuit_timer > 0.0
		and _has_active_buff("lightning_conductive_surge")
	)


func _is_overclock_circuit_consumer_spell(spell_id: String) -> bool:
	if not _is_overclock_circuit_runtime_active():
		return false
	var school := resolve_runtime_school("", spell_id)
	if school != "lightning":
		return false
	return _resolve_skill_type_for_runtime_id(spell_id) == "active"


func _should_apply_overclock_circuit_to_runtime(data: Dictionary) -> bool:
	if not _is_overclock_circuit_runtime_active():
		return false
	if str(data.get("school", "")) != "lightning":
		return false
	var skill_type := _resolve_skill_type_for_runtime_id(str(data.get("spell_id", data.get("skill_id", ""))))
	return skill_type == "active"


func _get_scaled_buff_duration(skill_id: String, base_value: float, level_override: int = -1) -> float:
	var level: int = level_override if level_override >= 0 else get_skill_level(skill_id)
	var level_delta: int = max(level - 1, 0)
	return base_value * (1.0 + 0.01 * level_delta) * get_equipment_buff_duration_multiplier()


func _get_scaled_buff_cooldown(skill_id: String, base_value: float, level_override: int = -1) -> float:
	var level: int = level_override if level_override >= 0 else get_skill_level(skill_id)
	var level_delta: int = max(level - 1, 0)
	return base_value * max(0.55, 1.0 - 0.045 * level_delta)


func _get_scaled_buff_effects(
	skill_id: String, skill_data: Dictionary = {}, level_override: int = -1
) -> Array:
	var resolved_skill_data: Dictionary = _resolve_runtime_skill_data(skill_id, skill_data)
	return _get_scaled_authored_effects(
		_resolve_runtime_skill_id(skill_id, resolved_skill_data),
		resolved_skill_data.get("buff_effects", []),
		resolved_skill_data,
		level_override
	)


func _get_scaled_authored_effects(
	skill_id: String, raw_effects: Array, skill_data: Dictionary = {}, level_override: int = -1
) -> Array:
	var resolved_skill_data: Dictionary = _resolve_runtime_skill_data(skill_id, skill_data)
	var resolved_skill_id: String = _resolve_runtime_skill_id(skill_id, resolved_skill_data)
	var level: int = level_override if level_override >= 0 else get_skill_level(resolved_skill_id)
	var level_delta: int = max(level - 1, 0)
	var damage_taken_reduction_per_level := float(
		resolved_skill_data.get("damage_taken_reduction_per_level", 0.0)
	)
	var final_damage_multiplier_per_level := float(
		resolved_skill_data.get("final_damage_multiplier_per_level", 0.0)
	)
	var fire_final_damage_multiplier_per_level := float(
		resolved_skill_data.get("fire_final_damage_multiplier_per_level", 0.0)
	)
	var ice_status_duration_multiplier_per_level := float(
		resolved_skill_data.get("ice_status_duration_multiplier_per_level", 0.0)
	)
	var lightning_final_damage_multiplier_per_level := float(
		resolved_skill_data.get("lightning_final_damage_multiplier_per_level", 0.0)
	)
	var dark_final_damage_multiplier_per_level := float(
		resolved_skill_data.get("dark_final_damage_multiplier_per_level", 0.0)
	)
	var defense_multiplier_per_level := float(
		resolved_skill_data.get("defense_multiplier_per_level", 0.0)
	)
	var poise_bonus_per_level := float(resolved_skill_data.get("poise_bonus_per_level", 0.0))
	var status_resistance_per_level := float(
		resolved_skill_data.get("status_resistance_per_level", 0.0)
	)
	var move_speed_multiplier_per_level := float(
		resolved_skill_data.get("move_speed_multiplier_per_level", 0.0)
	)
	var cast_speed_multiplier_per_level := float(
		resolved_skill_data.get("cast_speed_multiplier_per_level", 0.0)
	)
	var cooldown_flow_multiplier_reduction_per_level := float(
		resolved_skill_data.get("cooldown_flow_multiplier_reduction_per_level", 0.0)
	)
	var deploy_range_multiplier_per_level := float(
		resolved_skill_data.get("deploy_range_multiplier_per_level", 0.0)
	)
	var deploy_duration_multiplier_per_level := float(
		resolved_skill_data.get("deploy_duration_multiplier_per_level", 0.0)
	)
	var jump_velocity_multiplier_per_level := float(
		resolved_skill_data.get("jump_velocity_multiplier_per_level", 0.0)
	)
	var gravity_multiplier_reduction_per_level := float(
		resolved_skill_data.get("gravity_multiplier_reduction_per_level", 0.0)
	)
	var air_jump_bonus_per_level := float(resolved_skill_data.get("air_jump_bonus_per_level", 0.0))
	var scaled_effects: Array = raw_effects.duplicate(true)
	for effect_index in range(scaled_effects.size()):
		if typeof(scaled_effects[effect_index]) != TYPE_DICTIONARY:
			continue
		var effect: Dictionary = (scaled_effects[effect_index] as Dictionary).duplicate(true)
		var stat := str(effect.get("stat", ""))
		if (
			stat == "damage_taken_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and damage_taken_reduction_per_level > 0.0
		):
			effect["value"] = maxf(
				0.1,
				float(effect.get("value", 1.0))
				- damage_taken_reduction_per_level * float(level_delta)
			)
		elif (
			stat == "final_damage_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and final_damage_multiplier_per_level > 0.0
		):
			effect["value"] = minf(
				3.0,
				float(effect.get("value", 1.0))
				+ final_damage_multiplier_per_level * float(level_delta)
			)
		elif (
			stat == "fire_final_damage_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and fire_final_damage_multiplier_per_level > 0.0
		):
			effect["value"] = minf(
				3.0,
				float(effect.get("value", 1.0))
				+ fire_final_damage_multiplier_per_level * float(level_delta)
			)
		elif (
			stat == "ice_status_duration_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and ice_status_duration_multiplier_per_level > 0.0
		):
			effect["value"] = minf(
				3.0,
				float(effect.get("value", 1.0))
				+ ice_status_duration_multiplier_per_level * float(level_delta)
			)
		elif (
			stat == "lightning_final_damage_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and lightning_final_damage_multiplier_per_level > 0.0
		):
			effect["value"] = minf(
				3.0,
				float(effect.get("value", 1.0))
				+ lightning_final_damage_multiplier_per_level * float(level_delta)
			)
		elif (
			stat == "dark_final_damage_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and dark_final_damage_multiplier_per_level > 0.0
		):
			effect["value"] = minf(
				3.0,
				float(effect.get("value", 1.0))
				+ dark_final_damage_multiplier_per_level * float(level_delta)
			)
		elif (
			stat == "defense_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and defense_multiplier_per_level > 0.0
		):
			effect["value"] = minf(
				5.0,
				float(effect.get("value", 1.0))
				+ defense_multiplier_per_level * float(level_delta)
			)
		elif stat == "status_resistance" and status_resistance_per_level > 0.0:
			effect["value"] = minf(
				0.95,
				float(effect.get("value", 0.0))
				+ status_resistance_per_level * float(level_delta)
			)
		elif stat == "poise_bonus" and poise_bonus_per_level > 0.0:
			effect["value"] = float(effect.get("value", 0.0)) + poise_bonus_per_level * float(
				level_delta
			)
		elif (
			stat == "move_speed_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and move_speed_multiplier_per_level > 0.0
		):
			effect["value"] = minf(
				3.0,
				float(effect.get("value", 1.0))
				+ move_speed_multiplier_per_level * float(level_delta)
			)
		elif (
			stat == "cast_speed_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and cast_speed_multiplier_per_level > 0.0
		):
			effect["value"] = minf(
				3.0,
				float(effect.get("value", 1.0))
				+ cast_speed_multiplier_per_level * float(level_delta)
			)
		elif (
			stat == "cooldown_flow_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and cooldown_flow_multiplier_reduction_per_level > 0.0
		):
			effect["value"] = maxf(
				0.2,
				float(effect.get("value", 1.0))
				- cooldown_flow_multiplier_reduction_per_level * float(level_delta)
			)
		elif (
			stat == "deploy_range_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and deploy_range_multiplier_per_level > 0.0
		):
			effect["value"] = minf(
				3.0,
				float(effect.get("value", 1.0))
				+ deploy_range_multiplier_per_level * float(level_delta)
			)
		elif (
			stat == "deploy_duration_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and deploy_duration_multiplier_per_level > 0.0
		):
			effect["value"] = minf(
				3.0,
				float(effect.get("value", 1.0))
				+ deploy_duration_multiplier_per_level * float(level_delta)
			)
		elif (
			stat == "jump_velocity_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and jump_velocity_multiplier_per_level > 0.0
		):
			effect["value"] = minf(
				2.5,
				float(effect.get("value", 1.0))
				+ jump_velocity_multiplier_per_level * float(level_delta)
			)
		elif (
			stat == "gravity_multiplier"
			and str(effect.get("mode", "")) == "mul"
			and gravity_multiplier_reduction_per_level > 0.0
		):
			effect["value"] = maxf(
				0.2,
				float(effect.get("value", 1.0))
				- gravity_multiplier_reduction_per_level * float(level_delta)
			)
		elif stat == "air_jump_bonus" and air_jump_bonus_per_level > 0.0:
			effect["value"] = float(effect.get("value", 0.0)) + air_jump_bonus_per_level * float(
				level_delta
			)
		scaled_effects[effect_index] = effect
	return scaled_effects


func refresh_field_support_effects(skill_id: String, effects: Array, duration_value: float) -> void:
	if skill_id.is_empty() or effects.is_empty() or duration_value <= 0.0:
		return
	for index in range(active_field_effects.size()):
		if typeof(active_field_effects[index]) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = active_field_effects[index]
		if str(entry.get("skill_id", "")) != skill_id:
			continue
		entry["remaining"] = maxf(float(entry.get("remaining", 0.0)), duration_value)
		entry["effects"] = effects.duplicate(true)
		active_field_effects[index] = entry
		stats_changed.emit()
		return
	active_field_effects.append(
		{
			"skill_id": skill_id,
			"remaining": duration_value,
			"effects": effects.duplicate(true)
		}
	)
	stats_changed.emit()


func _apply_multiplier_effect(current_value: float, effect: Dictionary) -> float:
	var mode := str(effect.get("mode", "mul"))
	var value := float(effect.get("value", 1.0))
	if mode == "mul":
		return current_value * value
	if mode == "add":
		return current_value + value
	return current_value


func record_item_drop(item_id: String) -> void:
	session_drops += 1
	var item_data: Dictionary = {}
	var main_loop = Engine.get_main_loop()
	if main_loop and main_loop.root:
		var db = main_loop.root.get_node_or_null("GameDatabase")
		if db:
			item_data = db.get_equipment(item_id)
	last_drop_display = str(item_data.get("display_name", item_id))


func notify_enemy_killed() -> void:
	session_kills += 1
	var leech_total: float = 0.0
	for effect in _collect_active_effects():
		if str(effect.get("stat", "")) == "kill_leech":
			leech_total += float(effect.get("value", 0.0))
	if leech_total > 0.0:
		var heal_amount: int = int(round(float(max_health) * leech_total * 0.01))
		health = mini(health + heal_amount, max_health)
		if heal_amount > 0:
			push_message("+%d HP (처치 흡수)" % heal_amount, 0.8)
		stats_changed.emit()


func _find_combo_trigger_rule(combo_id: String, event_name: String) -> Dictionary:
	var combo := GameDatabase.get_buff_combo(combo_id)
	if combo.is_empty():
		return {}
	for raw_rule in combo.get("trigger_rules", []):
		if typeof(raw_rule) != TYPE_DICTIONARY:
			continue
		var rule: Dictionary = raw_rule
		if str(rule.get("event", "")).strip_edges() == event_name:
			return rule.duplicate(true)
	return {}


func _find_combo_applied_effect(combo_id: String, stat_name: String) -> Dictionary:
	var combo := GameDatabase.get_buff_combo(combo_id)
	if combo.is_empty():
		return {}
	for raw_effect in combo.get("applied_effects", []):
		if typeof(raw_effect) != TYPE_DICTIONARY:
			continue
		var effect: Dictionary = raw_effect
		if str(effect.get("stat", "")).strip_edges() == stat_name:
			return effect.duplicate(true)
	return {}


func _get_combo_applied_effect_value(combo_id: String, stat_name: String, fallback: Variant) -> Variant:
	var combo_effect := _find_combo_applied_effect(combo_id, stat_name)
	if combo_effect.is_empty():
		return fallback
	return combo_effect.get("value", fallback)


func _get_time_collapse_charge_count() -> int:
	var charge_value: Variant = _get_combo_applied_effect_value(
		"combo_time_collapse", "discounted_cast_charges", 0
	)
	if typeof(charge_value) != TYPE_INT and typeof(charge_value) != TYPE_FLOAT:
		return 0
	return maxi(int(round(float(charge_value))), 1)


func _get_ashen_rite_stack_cap() -> int:
	var trigger_rule := _find_combo_trigger_rule("combo_ashen_rite", "on_spell_hit")
	if trigger_rule.is_empty():
		return 20
	return max(int(trigger_rule.get("max_stacks", 20)), 1)


func _get_ash_residue_interval() -> float:
	for effect in _collect_active_effects():
		if str(effect.get("stat", "")) == "ash_residue_interval":
			return max(float(effect.get("value", 1.25)), 0.05)
	var combo_effect := _find_combo_applied_effect("combo_ashen_rite", "ash_residue_interval")
	if combo_effect.is_empty():
		return 1.25
	return max(float(combo_effect.get("value", 1.25)), 0.05)


func _get_ash_residue_effect_value(stat_name: String, fallback: Variant) -> Variant:
	return _get_combo_applied_effect_value("combo_ashen_rite", stat_name, fallback)


func _build_ash_residue_payload() -> Dictionary:
	var effect_id_value: Variant = _get_ash_residue_effect_value("ash_residue_effect_id", null)
	var school_value: Variant = _get_ash_residue_effect_value("ash_residue_school", null)
	var damage_value: Variant = _get_ash_residue_effect_value("ash_residue_damage", null)
	var damage_per_stack_value: Variant = _get_ash_residue_effect_value("ash_residue_damage_per_stack", null)
	var radius_value: Variant = _get_ash_residue_effect_value("ash_residue_radius", null)
	var color_value: Variant = _get_ash_residue_effect_value("ash_residue_color", null)
	if (
		typeof(effect_id_value) != TYPE_STRING
		or str(effect_id_value).strip_edges().is_empty()
		or typeof(school_value) != TYPE_STRING
		or str(school_value).strip_edges().is_empty()
		or typeof(color_value) != TYPE_STRING
		or str(color_value).strip_edges().is_empty()
	):
		return {}
	if (
		(typeof(damage_value) != TYPE_INT and typeof(damage_value) != TYPE_FLOAT)
		or (typeof(damage_per_stack_value) != TYPE_INT and typeof(damage_per_stack_value) != TYPE_FLOAT)
		or (typeof(radius_value) != TYPE_INT and typeof(radius_value) != TYPE_FLOAT)
	):
		return {}
	var effect_id := str(effect_id_value).strip_edges()
	var school := str(school_value).strip_edges()
	var damage := float(damage_value)
	var damage_per_stack := float(damage_per_stack_value)
	return {
		"effect_id": effect_id,
		"damage": damage + ash_stacks * damage_per_stack,
		"radius": float(radius_value),
		"school": school,
		"damage_school": school,
		"color": str(color_value).strip_edges()
	}


func _build_ashen_rite_end_payload() -> Dictionary:
	var end_trigger_rule := _find_combo_trigger_rule("combo_ashen_rite", "on_combo_end")
	if end_trigger_rule.is_empty():
		return {}
	var effect_id := str(end_trigger_rule.get("spawn_effect", "")).strip_edges()
	var school := str(end_trigger_rule.get("damage_school", "")).strip_edges()
	var color := str(end_trigger_rule.get("color", "")).strip_edges()
	if effect_id.is_empty() or school.is_empty() or color.is_empty():
		return {}
	for field_name in ["damage", "damage_per_stack", "radius", "radius_per_stack"]:
		var field_value: Variant = end_trigger_rule.get(field_name, null)
		if typeof(field_value) != TYPE_INT and typeof(field_value) != TYPE_FLOAT:
			return {}
	return {
		"effect_id": effect_id,
		"damage": float(end_trigger_rule.get("damage", 0.0))
			+ ash_stacks * float(end_trigger_rule.get("damage_per_stack", 0.0)),
		"radius": float(end_trigger_rule.get("radius", 0.0))
			+ ash_stacks * float(end_trigger_rule.get("radius_per_stack", 0.0)),
		"school": school,
		"damage_school": school,
		"color": color,
		"stacks": ash_stacks
	}


func _build_prismatic_guard_break_payload() -> Dictionary:
	var trigger_rule := _find_combo_trigger_rule("combo_prismatic_guard", "on_barrier_break")
	if trigger_rule.is_empty():
		return {}
	var effect_id := str(trigger_rule.get("spawn_effect", "")).strip_edges()
	var radius_value: Variant = trigger_rule.get("radius", null)
	if effect_id.is_empty():
		return {}
	if typeof(radius_value) != TYPE_INT and typeof(radius_value) != TYPE_FLOAT:
		return {}
	return {
		"effect_id": effect_id,
		"radius": float(radius_value)
	}


func notify_deploy_kill() -> void:
	if not funeral_bloom_active:
		return
	if funeral_bloom_icd_timer > 0.0:
		return
	var combo := GameDatabase.get_buff_combo("combo_funeral_bloom")
	var trigger_rule := _find_combo_trigger_rule("combo_funeral_bloom", "on_deploy_kill")
	if combo.is_empty() or trigger_rule.is_empty():
		return
	var effect_id := str(trigger_rule.get("spawn_effect", "")).strip_edges()
	var damage_school := str(trigger_rule.get("damage_school", "")).strip_edges()
	var apply_status := str(trigger_rule.get("apply_status", "")).strip_edges()
	var color := str(trigger_rule.get("color", "")).strip_edges()
	var radius_value: Variant = trigger_rule.get("radius", null)
	if (
		effect_id.is_empty()
		or damage_school.is_empty()
		or apply_status.is_empty()
		or color.is_empty()
		or (typeof(radius_value) != TYPE_INT and typeof(radius_value) != TYPE_FLOAT)
	):
		return
	funeral_bloom_icd_timer = float(combo.get("internal_cooldown", 0.0))
	_emit_combo_effect(
		{
			"effect_id": effect_id,
			"radius": float(radius_value),
			"school": damage_school,
			"damage_school": damage_school,
			"apply_status": apply_status,
			"color": color
		}
	)


func _emit_combo_effect(payload: Dictionary) -> void:
	last_combo_effect = payload.duplicate(true)
	combo_effect_requested.emit(last_combo_effect)


func apply_spell_modifiers(data: Dictionary) -> Dictionary:
	data = _apply_buff_runtime_modifiers(data)
	if str(data.get("school", "")) == "lightning":
		var lightning_ping_trigger := _find_active_buff_effect(
			"lightning_conductive_surge", "extra_lightning_ping"
		)
		if int(lightning_ping_trigger.get("value", 0)) > 0:
			var lightning_ping_payload := _build_active_buff_secondary_effect_payload(
				"lightning_conductive_surge",
				"lightning_ping",
				float(data.get("damage", 0.0))
			)
			if not lightning_ping_payload.is_empty():
				_emit_combo_effect(lightning_ping_payload)
	if str(data.get("school", "")) == "ice":
		var ice_reflect_trigger := _find_active_buff_effect("ice_frostblood_ward", "ice_reflect_wave")
		if int(ice_reflect_trigger.get("value", 0)) > 0:
			var ice_reflect_payload := _build_active_buff_secondary_effect_payload(
				"ice_frostblood_ward",
				"ice_reflect_wave",
				float(data.get("damage", 0.0))
			)
			if not ice_reflect_payload.is_empty():
				_emit_combo_effect(ice_reflect_payload)
	return data


func apply_deploy_buff_modifiers(data: Dictionary) -> Dictionary:
	for effect in _collect_active_effects():
		var stat := str(effect.get("stat", ""))
		match stat:
			"deploy_range_multiplier":
				data["size"] = float(data.get("size", 1.0)) * float(effect.get("value", 1.0))
			"deploy_duration_multiplier":
				data["duration"] = (
					float(data.get("duration", 1.0)) * float(effect.get("value", 1.0))
				)
			"deploy_target_bonus":
				data["target_count"] = (
					int(data.get("target_count", 0)) + int(effect.get("value", 0))
				)
	return data


func get_skill_mana_cost(skill_id: String) -> float:
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	if skill_data.is_empty():
		var linked_skill_id: String = get_skill_id_for_spell(skill_id)
		if linked_skill_id != "" and linked_skill_id != skill_id:
			skill_data = GameDatabase.get_skill_data(linked_skill_id)
	if skill_data.is_empty():
		return 0.0
	var cost: float = get_common_scaled_mana_value(
		str(skill_data.get("skill_id", skill_id)),
		float(skill_data.get("mana_cost_base", 0.0)),
		float(skill_data.get("mana_reduction_per_level", 0.0)),
		0.4,
		skill_data,
		str(skill_data.get("element", ""))
	)
	for effect in _collect_active_effects():
		if str(effect.get("stat", "")) == "mana_efficiency_multiplier":
			cost = cost * float(effect.get("value", 1.0))
	return maxf(0.0, cost)


func has_enough_mana(skill_id: String) -> bool:
	if admin_infinite_mana:
		return true
	return mana >= get_skill_mana_cost(skill_id)


func consume_skill_mana(skill_id: String) -> bool:
	var mana_cost: float = get_skill_mana_cost(skill_id)
	if admin_infinite_mana or mana_cost <= 0.0:
		if admin_infinite_mana and mana != max_mana:
			mana = max_mana
			stats_changed.emit()
		return true
	if mana < mana_cost:
		return false
	mana = maxf(mana - mana_cost, 0.0)
	stats_changed.emit()
	return true


func consume_mana_amount(amount: float) -> bool:
	if admin_infinite_mana or amount <= 0.0:
		if admin_infinite_mana and mana != max_mana:
			mana = max_mana
			stats_changed.emit()
		return true
	if mana < amount:
		return false
	mana = maxf(mana - amount, 0.0)
	stats_changed.emit()
	return true
