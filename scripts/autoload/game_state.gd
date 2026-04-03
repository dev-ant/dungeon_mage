extends Node

const SAVE_PATH := "user://savegame.json"
const SCHOOL_ORDER := [
	"fire", "ice", "lightning", "wind", "water", "plant", "earth", "holy", "dark", "arcane"
]
const RESONANCE_MILESTONES := {
	5: "%s resonance sharpens. The pattern is beginning to take hold.",
	15: "Deep %s resonance. Your spells carry a crystallized edge.",
	30: "Peak %s resonance. The maze reshapes around your casting pattern."
}
const BASE_MAX_HEALTH := 100
const BASE_MAX_MANA := 180.0
const BASE_MANA_REGEN_PER_SECOND := 14.0
const VISIBLE_HOTBAR_SLOT_COUNT := 10
const LEGACY_HOTBAR_TAIL_SAVE_KEY := "legacy_spell_hotbar_tail"
const VISIBLE_HOTBAR_SHORTCUT_SAVE_KEY := "visible_hotbar_shortcuts"
const DEFAULT_VISIBLE_HOTBAR_KEYCODES := {
	"spell_fire": KEY_Z,
	"spell_ice": KEY_C,
	"spell_lightning": KEY_V,
	"spell_water": KEY_U,
	"spell_wind": KEY_I,
	"spell_plant": KEY_P,
	"spell_earth": KEY_O,
	"spell_holy": KEY_K,
	"spell_dark": KEY_L,
	"spell_arcane": KEY_M
}
const SOUL_DOMINION_DAMAGE_TAKEN_MULT := 1.35
const SOUL_DOMINION_AFTERSHOCK_DURATION := 5.0
const SOUL_DOMINION_AFTERSHOCK_DAMAGE_MULT := 1.2
const DEFAULT_SPELL_HOTBAR := [
	{"action": "spell_fire", "skill_id": "fire_bolt", "label": "Z"},
	{"action": "spell_ice", "skill_id": "frost_nova", "label": "C"},
	{"action": "spell_lightning", "skill_id": "volt_spear", "label": "V"},
	{"action": "spell_water", "skill_id": "water_aqua_bullet", "label": "U"},
	{"action": "spell_wind", "skill_id": "wind_gale_cutter", "label": "I"},
	{"action": "spell_plant", "skill_id": "plant_vine_snare", "label": "P"},
	{"action": "spell_earth", "skill_id": "earth_tremor", "label": "O"},
	{"action": "spell_holy", "skill_id": "holy_radiant_burst", "label": "K"},
	{"action": "spell_dark", "skill_id": "dark_void_bolt", "label": "L"},
	{"action": "spell_arcane", "skill_id": "arcane_force_pulse", "label": "M"},
	{"action": "buff_guard", "skill_id": "holy_mana_veil", "label": "Q"},
	{"action": "buff_power", "skill_id": "fire_pyre_heart", "label": "R"},
	{"action": "buff_ward", "skill_id": "ice_frostblood_ward", "label": "F"}
]
const DEFAULT_EQUIPMENT_PRESET := {
	"weapon": "",
	"offhand": "",
	"head": "",
	"body": "",
	"legs": "",
	"accessory_1": "",
	"accessory_2": ""
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
const BUFF_KEY_LOADOUT := [
	"holy_mana_veil",
	"fire_pyre_heart",
	"ice_frostblood_ward",
	"holy_crystal_aegis",
	"wind_tempest_drive",
	"lightning_conductive_surge",
	"arcane_astral_compression",
	"arcane_world_hourglass",
	"dark_grave_pact",
	"dark_throne_of_ash",
	"plant_verdant_overflow"
]
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
var equipped_items: Dictionary = {}
var equipment_inventory: Array = []
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
	_add_action("move_left", [KEY_LEFT, KEY_A])
	_add_action("move_right", [KEY_RIGHT, KEY_D])
	_add_action("move_up", [KEY_UP])
	_add_action("move_down", [KEY_DOWN])
	_add_action("jump", [KEY_SPACE, KEY_ALT])
	_add_action("dash", [KEY_SHIFT, KEY_X])
	_add_action("spell_fire", [KEY_Z])
	_add_action("spell_ice", [KEY_C])
	_add_action("spell_lightning", [KEY_V])
	_add_action("spell_water", [KEY_U])
	_add_action("spell_wind", [KEY_I])
	_add_action("spell_plant", [KEY_P])
	_add_action("spell_earth", [KEY_O])
	_add_action("spell_holy", [KEY_K])
	_add_action("spell_dark", [KEY_L])
	_add_action("spell_arcane", [KEY_M])
	_add_action("buff_guard", [KEY_Q])
	_add_action("buff_power", [KEY_R])
	_add_action("buff_ward", [KEY_F])
	_add_action("buff_aegis", [KEY_T])
	_add_action("buff_tempo", [KEY_G])
	_add_action("buff_surge", [KEY_B])
	_add_action("buff_compression", [KEY_Y])
	_add_action("buff_hourglass", [KEY_H])
	_add_action("buff_pact", [KEY_J])
	_add_action("buff_throne", [KEY_N])
	_add_action("interact", [KEY_E, KEY_ENTER])
	_add_action("admin_menu", [KEY_ESCAPE])
	_apply_visible_hotbar_shortcuts_to_input_map()


func heal_full() -> void:
	health = max_health
	mana = max_mana
	_reset_transient_combat_runtime()
	stats_changed.emit()


func _reset_transient_combat_runtime(
	clear_effects: bool = false, clear_hit_feedback: bool = false
) -> void:
	combo_barrier = 0.0
	combo_barrier_combo_id = ""
	time_collapse_charges = 0
	time_collapse_active = false
	overclock_circuit_active = false
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
			push_message("Prismatic barrier absorbs the impact.", 0.8)
		if combo_barrier <= 0.0 and combo_barrier_combo_id == "combo_prismatic_guard":
			push_message("Prismatic Guard shatters in a sharp mana burst.", 1.2)
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
			"Your focus shatters. The rest seal drags you back before the maze can finish the ritual.",
			3.0
		)
		player_died.emit()


func save_progress(room_id: String, spawn_position: Vector2) -> void:
	_progress_state.save_progress(room_id, spawn_position)
	heal_full()
	save_to_disk()
	push_message("Mana stabilized. The seal records your route.", 2.4)


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
	stats_changed.emit()


func _check_resonance_milestone(school: String, new_value: int) -> void:
	if RESONANCE_MILESTONES.has(new_value):
		push_message(RESONANCE_MILESTONES[new_value] % school.capitalize(), 2.4)
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
		data = build_common_runtime_stat_block(
			str(linked_skill.get("skill_id", get_skill_id_for_spell(spell_id))),
			data,
			linked_skill,
			runtime_options
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
			"apply_equipment_damage": true,
			"apply_equipment_cooldown": true,
			"apply_equipment_aoe": true,
			"aoe_fields": ["size"]
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
	return {
		"damage": int(round(coefficient * 10.0 + flat_damage)),
		"cooldown": float(resolved_skill_data.get("cooldown_base", 1.0)),
		"duration": float(resolved_skill_data.get("duration_base", 0.0)),
		"size": float(resolved_skill_data.get("range_base", 40.0)),
		"tick_interval": float(resolved_skill_data.get("tick_interval", 1.0)),
		"knockback": float(resolved_skill_data.get("knockback_base", 180.0)),
		"pierce": int(resolved_skill_data.get("pierce_count_base", 0))
		+ get_skill_milestone_runtime_bonus(resolved_skill_data, "pierce_count", level),
		"utility_effects": resolved_skill_data.get("utility_effects", []).duplicate(true)
	}


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
	var passthrough_fields := ["tick_interval", "pierce", "target_count", "color", "owner"]
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
	if runtime.has("damage"):
		runtime["damage"] = int(
			round(float(runtime.get("damage", 0.0)) * (1.0 + damage_per_level * float(level_delta)))
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
	return runtime


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
	if mastery_id == "":
		return modifiers
	var mastery_data: Dictionary = GameDatabase.get_skill_data(mastery_id)
	if mastery_data.is_empty() or str(mastery_data.get("passive_family", "")) != "mastery":
		return modifiers
	if _is_global_mastery_runtime_modifier(mastery_data):
		return modifiers
	if not _mastery_applies_to_skill(mastery_data, resolved_skill_data, runtime_school):
		return modifiers
	var mastery_level: int = get_skill_level(mastery_id)
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
	modifiers["mastery_id"] = mastery_id
	modifiers["damage_multiplier"] = maxf(
		0.0,
		(1.0 + float(mastery_data.get("final_multiplier_per_level", 0.0)) * float(level_delta))
		* (1.0 + damage_bonus)
	)
	modifiers["mana_cost_multiplier"] = maxf(0.0, 1.0 - mana_reduction)
	modifiers["cooldown_multiplier"] = maxf(0.0, 1.0 - cooldown_reduction)
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
			push_message("Time Collapse exhausts its free casting window.", 1.0)
	stats_changed.emit()


func register_skill_damage(spell_id: String, amount: float) -> void:
	var linked_skill_id: String = get_skill_id_for_spell(spell_id)
	if linked_skill_id == "":
		return
	var dealt: float = max(amount, 0.0)
	if dealt <= 0.0:
		return
	_add_skill_experience(linked_skill_id, dealt)
	_add_skill_experience("arcane_magic_mastery", dealt)
	var school := resolve_runtime_school(linked_skill_id, spell_id)
	var mastery_id: String = str(SCHOOL_TO_MASTERY.get(school, ""))
	if mastery_id != "":
		_add_skill_experience(mastery_id, dealt)
	if ashen_rite_active:
		ash_stacks = min(ash_stacks + 1, 20)
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


func get_room_variant(room_id: String) -> Dictionary:
	var dominant := get_dominant_school()
	var variant := {"tint": Color("#ffffff"), "extra_spawns": [], "label": ""}
	match dominant:
		"fire":
			variant.tint = Color("#2b1710")
			variant.extra_spawns = [{"type": "ranged", "position": [1360, 300]}]
			variant.label = "Fire resonance draws volatile sentries."
		"ice":
			variant.tint = Color("#0d2836")
			variant.extra_spawns = [{"type": "brute", "position": [1280, 600]}]
			variant.label = "Ice resonance thickens the chamber into slower, heavier resistance."
		"lightning":
			variant.tint = Color("#2a2b10")
			variant.extra_spawns = [
				{"type": "ranged", "position": [900, 260]},
				{"type": "brute", "position": [1420, 600]}
			]
			variant.label = "Lightning resonance makes the maze feel alert and over-responsive."
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
			"equipped_items": equipped_items,
			"equipment_inventory": equipment_inventory,
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
	equipped_items = parsed.get("equipped_items", equipped_items)
	equipment_inventory = parsed.get("equipment_inventory", equipment_inventory)
	current_equipment_preset = str(parsed.get("current_equipment_preset", current_equipment_preset))
	resonance = parsed.get("resonance", resonance)
	last_spell_school = str(parsed.get("last_spell_school", last_spell_school))
	_initialize_spell_hotbar()
	if visible_hotbar_shortcuts.is_empty():
		visible_hotbar_shortcuts = _build_legacy_visible_hotbar_shortcut_payload()
	ensure_input_map()
	_initialize_equipment_state()
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
	var restored_hotbar: Array = DEFAULT_SPELL_HOTBAR.duplicate(true)
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
	var restored: Array = []
	var saved_shortcuts: Array = saved_value
	for raw_value in saved_shortcuts:
		if typeof(raw_value) != TYPE_DICTIONARY:
			continue
		var shortcut: Dictionary = raw_value
		var slot_index: int = int(shortcut.get("slot_index", -1))
		if slot_index < 0 or slot_index >= VISIBLE_HOTBAR_SLOT_COUNT:
			continue
		var default_action := str(DEFAULT_SPELL_HOTBAR[slot_index].get("action", ""))
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
	var visible_count: int = mini(VISIBLE_HOTBAR_SLOT_COUNT, spell_hotbar.size())
	for i in range(visible_count):
		var slot: Dictionary = spell_hotbar[i]
		var action := str(slot.get("action", ""))
		var default_keycode: int = _get_default_visible_hotbar_keycode(action)
		if action == "" or default_keycode <= 0:
			continue
		_set_action_primary_physical_keycode(action, default_keycode)
		slot["label"] = str(
			DEFAULT_SPELL_HOTBAR[i].get("label", _format_hotbar_key_label(default_keycode))
		)
		spell_hotbar[i] = slot
	visible_hotbar_shortcuts = _build_visible_hotbar_shortcut_payload()
	if persist:
		save_to_disk()
		stats_changed.emit()


func _get_default_visible_hotbar_keycode(action: String) -> int:
	return int(DEFAULT_VISIBLE_HOTBAR_KEYCODES.get(action, 0))


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
	return equipment_inventory.duplicate()


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
	return equipment_inventory.has(item_id)


func grant_equipment_item(item_id: String) -> bool:
	if item_id == "":
		return false
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return false
	equipment_inventory.append(item_id)
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
	if not has_equipment_in_inventory(item_id):
		return false
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return false
	if str(item.get("slot_type", "")) != slot_name:
		return false
	var current_item_id := str(equipped_items.get(slot_name, ""))
	equipment_inventory.erase(item_id)
	if current_item_id != "":
		equipment_inventory.append(current_item_id)
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
	equipment_inventory.append(current_item_id)
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
	return "Gear  %s / %s  Preset:%s" % [weapon_name, offhand_name, current_equipment_preset]


func get_equipment_inventory_summary() -> String:
	if equipment_inventory.is_empty():
		return "Inventory  empty"
	var preview_parts: Array[String] = []
	var preview_count := mini(equipment_inventory.size(), 4)
	for i in range(preview_count):
		var item_id := str(equipment_inventory[i])
		preview_parts.append(_get_equipment_display_name(item_id))
	var remainder := equipment_inventory.size() - preview_count
	var preview_text := ", ".join(preview_parts)
	if remainder > 0:
		preview_text += " +%d" % remainder
	return "Inventory  %s" % preview_text


func get_equipment_slot_inventory_summary(slot_name: String) -> String:
	var slot_inventory: Array = get_equipment_inventory_for_slot(slot_name)
	if slot_inventory.is_empty():
		return "Owned  none"
	var preview_parts: Array[String] = []
	var preview_count := mini(slot_inventory.size(), 3)
	for i in range(preview_count):
		var item_id := str(slot_inventory[i])
		preview_parts.append(_get_equipment_display_name(item_id))
	var remainder := slot_inventory.size() - preview_count
	var preview_text := ", ".join(preview_parts)
	if remainder > 0:
		preview_text += " +%d" % remainder
	return "Owned  %s" % preview_text


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
	spell_hotbar = DEFAULT_SPELL_HOTBAR.duplicate(true)
	_initialize_skill_progress()
	_initialize_buff_runtime()
	_initialize_spell_hotbar()
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
		combat_parts.append("InfiniteHP")
	if admin_infinite_mana:
		resource_parts.append("InfiniteMP")
	if admin_ignore_cooldowns:
		combat_parts.append("NoCooldown")
	if admin_ignore_buff_slot_limit:
		combat_parts.append("FreeBuffSlots")
	var resource_text := "-" if resource_parts.is_empty() else "/".join(resource_parts)
	var combat_text := "-" if combat_parts.is_empty() else "/".join(combat_parts)
	return (
		"Admin  Resources[%s] Combat[%s] Gear[%s]"
		% [resource_text, combat_text, current_equipment_preset]
	)


func get_resource_summary() -> String:
	return "MP %.0f/%.0f" % [mana, max_mana]


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
	for skill_id in BUFF_KEY_LOADOUT:
		if not buff_cooldowns.has(skill_id):
			buff_cooldowns[skill_id] = 0.0


func _initialize_spell_hotbar() -> void:
	if spell_hotbar.is_empty():
		spell_hotbar = DEFAULT_SPELL_HOTBAR.duplicate(true)
		return
	var normalized: Array = []
	for i in range(DEFAULT_SPELL_HOTBAR.size()):
		var fallback: Dictionary = DEFAULT_SPELL_HOTBAR[i]
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
		if GameDatabase.get_equipment(item_id).is_empty():
			continue
		normalized_inventory.append(item_id)
	equipment_inventory = normalized_inventory


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
		return "(none)"
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
				"%s reaches Lv.%d. The spell form sharpens."
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
	var current_cooldown: float = float(buff_cooldowns.get(skill_id, 0.0))
	if current_cooldown > 0.0 and not admin_ignore_cooldowns:
		push_message("%s is still reforming." % skill_data.get("display_name", skill_id), 1.2)
		return false
	if not admin_ignore_cooldowns:
		for penalty in active_penalties:
			if str(penalty.get("stat", "")) == "ritual_recast_lock":
				push_message(
					(
						"The ritual's aftermath seals your casting patterns for %.1fs."
						% float(penalty.get("remaining", 0.0))
					),
					1.6
				)
				return false
	if active_buffs.size() >= get_buff_slot_limit() and not admin_ignore_buff_slot_limit:
		push_message(
			(
				"Your current circle can only stabilize %d buff patterns at once."
				% get_buff_slot_limit()
			),
			1.6
		)
		return false
	if not consume_skill_mana(skill_id):
		push_message(
			(
				"You do not have enough mana to stabilize %s."
				% skill_data.get("display_name", skill_id)
			),
			1.2
		)
		return false
	active_buffs.append(
		{
			"skill_id": skill_id,
			"display_name": skill_data.get("display_name", skill_id),
			"remaining":
			_get_scaled_buff_duration(skill_id, float(skill_data.get("duration_base", 0.0))),
			"effects": skill_data.get("buff_effects", [])
		}
	)
	buff_cooldowns[skill_id] = _get_scaled_buff_cooldown(
		skill_id, float(skill_data.get("cooldown_base", 0.0))
	)
	for effect in skill_data.get("downside_effects", []):
		if (
			str(effect.get("stat", "")) == "mana_percent"
			and str(effect.get("mode", "")) == "set"
			and float(effect.get("duration", 0.0)) == 0.0
		):
			mana = clampf(max_mana * float(effect.get("value", 1.0)), 0.0, max_mana)
	_refresh_combo_runtime()
	push_message("%s flares to life." % skill_data.get("display_name", skill_id), 1.4)
	stats_changed.emit()
	return true


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
				"Your spell lattice stabilizes at %d-circle. More simultaneous buffs become possible."
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
				"The maintenance seal stabilizes your spell lattice. Your core techniques sharpen together.",
				2.8
			)
		"echo_entrance_1":
			_grant_skill_level_bonus("fire_ember_dart", 2)
			push_message("Mira's trace leaves behind a hotter casting rhythm.", 2.4)
		"echo_entrance_2":
			_grant_skill_level_bonus("ice_frost_needle", 2)
			push_message("The looping residue teaches you how to hold colder shapes in place.", 2.4)
		"boss_conduit":
			_grant_all_skill_levels(3)
			push_message(
				"The fallen guardian's core releases a surge of forced understanding through every spell you know.",
				3.0
			)
		"core_conduit":
			_grant_all_skill_levels(2)
			push_message(
				"The floor core drags your spell lattice deeper, refining every practiced pattern at once.",
				3.0
			)
		"echo_deep_0":
			_grant_skill_level_bonus("lightning_thunder_lance", 2)
			push_message(
				"The delayed footsteps teach you to release lightning a breath earlier than instinct.",
				2.4
			)
		"echo_deep_1":
			_grant_skill_level_bonus("arcane_magic_mastery", 2)
			push_message(
				"The scratched spiral settles into your focus. Even your foundational control grows denser.",
				2.4
			)
		_:
			return false
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
		return "Buffs  none"
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
	var limit_text := "INF" if admin_ignore_buff_slot_limit else str(get_buff_slot_limit())
	return "Buffs  %s / %s  %s" % [active_buffs.size(), limit_text, " | ".join(parts)]


func get_buff_cooldown_summary() -> String:
	var parts: Array[String] = []
	for skill_id in BUFF_KEY_LOADOUT:
		var cd := float(buff_cooldowns.get(skill_id, 0.0))
		if cd <= 0.0:
			continue
		var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
		var name_text := str(skill_data.get("display_name", skill_id))
		parts.append("%s cd:%.1fs" % [name_text, cd])
	if parts.is_empty():
		return "Cooldowns  all ready"
	return "Cooldowns  %s" % " | ".join(parts)


func get_active_combo_names() -> Array[String]:
	var names: Array[String] = []
	for combo in _get_active_combos():
		names.append(str(combo.get("display_name", combo.get("combo_id", "?"))))
	return names


func get_combo_summary() -> String:
	var names := get_active_combo_names()
	var ritual_text := _get_ashen_rite_aftermath_summary()
	if names.is_empty() and ritual_text.is_empty():
		return "Combos  none"
	# [BURST] prefix makes the burst window immediately visible during sandbox play
	var burst_prefix := "[BURST] " if (time_collapse_active or ashen_rite_active) else ""
	var barrier_text := ""
	if combo_barrier > 0.0:
		barrier_text = "  Barrier %.0f" % combo_barrier
	var time_text := ""
	if time_collapse_active:
		var min_remaining := 0.0
		for buff in active_buffs:
			var sid := str(buff.get("skill_id", ""))
			if sid in ["arcane_astral_compression", "arcane_world_hourglass"]:
				var r := float(buff.get("remaining", 0.0))
				if min_remaining == 0.0 or r < min_remaining:
					min_remaining = r
		time_text = "  TimeCharges %d" % time_collapse_charges
		if min_remaining > 0.0:
			time_text += "  Closes %.1fs" % min_remaining
	var ash_text := ""
	if ashen_rite_active:
		ash_text = "  Ash %d" % ash_stacks
	var funeral_text := ""
	if funeral_bloom_active:
		funeral_text = (
			"  Bloom"
			+ (
				"  ICD %.1fs" % funeral_bloom_icd_timer
				if funeral_bloom_icd_timer > 0.0
				else "  ready"
			)
		)
	return (
		"%sCombos  %s%s%s%s%s%s"
		% [
			burst_prefix,
			", ".join(names) if not names.is_empty() else "none",
			barrier_text,
			time_text,
			ash_text,
			funeral_text,
			ritual_text
		]
	)


func get_resource_status_line() -> String:
	var dmg_suffix := ""
	if last_damage_display_timer > 0.0 and last_damage_amount > 0:
		if last_damage_school != "":
			dmg_suffix = " [←%d %s]" % [last_damage_amount, last_damage_school]
		else:
			dmg_suffix = " [←%d]" % last_damage_amount
	var soul_suffix := ""
	if soul_dominion_active:
		soul_suffix = (
			"  [!MP-LOCK +%d%% DMG]" % int(round((SOUL_DOMINION_DAMAGE_TAKEN_MULT - 1.0) * 100.0))
		)
	elif soul_dominion_aftershock_timer > 0.0:
		soul_suffix = (
			"  [!SHOCK %.1fs +%d%% DMG]"
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
			"Soul Dominion ACTIVE  [MP Regen LOCKED | DMG x%.2f]" % SOUL_DOMINION_DAMAGE_TAKEN_MULT
		)
	if soul_dominion_aftershock_timer > 0.0:
		return (
			"Soul Dominion AFTERSHOCK  %.1fs  [MP Regen LOCKED | DMG x%.2f]"
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
	for penalty in active_penalties:
		penalty["remaining"] = max(float(penalty.get("remaining", 0.0)) - delta, 0.0)
	active_penalties = active_penalties.filter(
		func(entry: Dictionary) -> bool: return float(entry.get("remaining", 0.0)) > 0.0
	)
	if soul_dominion_aftershock_timer > 0.0:
		soul_dominion_aftershock_timer = maxf(soul_dominion_aftershock_timer - delta, 0.0)
	if funeral_bloom_icd_timer > 0.0:
		funeral_bloom_icd_timer = maxf(funeral_bloom_icd_timer - delta, 0.0)
	var has_ash_burst := ashen_rite_active
	if not has_ash_burst:
		for _effect in _collect_active_effects():
			if (
				str(_effect.get("stat", "")) == "ash_residue_burst"
				and int(_effect.get("value", 0)) > 0
			):
				has_ash_burst = true
				break
	if has_ash_burst:
		ash_residue_timer = max(ash_residue_timer - delta, 0.0)
		if ash_residue_timer <= 0.0:
			ash_residue_timer = 1.25
			_emit_combo_effect(
				{
					"effect_id": "ash_residue_burst",
					"damage": 16 + ash_stacks * 2,
					"radius": 54.0,
					"school": "fire",
					"color": "#ff9a54"
				}
			)
	_tick_active_buff_drains(delta)
	_refresh_combo_runtime()
	if not expired.is_empty():
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
	return "Hits: %d  DMG: %d" % [session_hit_count, session_damage_dealt]


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


func _collect_active_effects() -> Array:
	var effects: Array = []
	for buff in active_buffs:
		for effect in buff.get("effects", []):
			effects.append(effect)
	for combo in _get_active_combos():
		for effect in combo.get("applied_effects", []):
			effects.append(effect)
	for penalty in active_penalties:
		effects.append(penalty)
	return effects


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
	var parts: Array[String] = ["  Aftermath"]
	if guard_break_remaining > 0.0:
		parts.append("GuardBreak %.1fs" % guard_break_remaining)
	if recast_lock_remaining > 0.0:
		parts.append("Lock %.1fs" % recast_lock_remaining)
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
			push_message("Prismatic Guard condenses into a visible mana barrier.", 1.2)
	var time_combo_found := false
	for combo in _get_active_combos():
		if str(combo.get("combo_id", "")) == "combo_time_collapse":
			time_combo_found = true
			break
	if time_combo_found and not time_collapse_active:
		time_collapse_active = true
		time_collapse_charges = 3
		push_message("Time Collapse opens a brief overclocked casting window.", 1.2)
	elif not time_combo_found:
		time_collapse_active = false
		time_collapse_charges = 0
	var overclock_found := false
	for combo in _get_active_combos():
		if str(combo.get("combo_id", "")) == "combo_overclock_circuit":
			overclock_found = true
			break
	if overclock_found and not overclock_circuit_active:
		overclock_circuit_active = true
		push_message("Overclock Circuit engaged. Lightning chains accelerate.", 1.2)
	elif not overclock_found:
		overclock_circuit_active = false
	var funeral_found := false
	for combo in _get_active_combos():
		if str(combo.get("combo_id", "")) == "combo_funeral_bloom":
			funeral_found = true
			break
	if funeral_found and not funeral_bloom_active:
		funeral_bloom_active = true
		push_message("Funeral Bloom awakens. Deploy kills will detonate.", 1.2)
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
		ash_residue_timer = 1.25
		push_message("Ashen Rite begins. Spell impacts now feed the ritual.", 1.2)
	elif not ashen_found and ashen_rite_active:
		if ash_stacks > 0:
			_emit_combo_effect(
				{
					"effect_id": "ash_detonation",
					"damage": 24 + ash_stacks * 7,
					"radius": 68.0 + ash_stacks * 3.0,
					"school": "fire",
					"color": "#ff7446",
					"stacks": ash_stacks
				}
			)
		mana = 0.0
		active_penalties.append(
			{"stat": "defense_multiplier", "mode": "mul", "value": 0.75, "remaining": 10.0}
		)
		active_penalties.append(
			{"stat": "ritual_recast_lock", "mode": "set", "value": 1, "remaining": 6.0}
		)
		push_message(
			"The Ashen Rite consumes your reserves. Defense broken for 10s, recasting locked for 6s.",
			2.0
		)
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
	return data


func _get_scaled_buff_duration(skill_id: String, base_value: float) -> float:
	var level_delta: int = max(get_skill_level(skill_id) - 1, 0)
	return base_value * (1.0 + 0.01 * level_delta) * get_equipment_buff_duration_multiplier()


func _get_scaled_buff_cooldown(skill_id: String, base_value: float) -> float:
	var level_delta: int = max(get_skill_level(skill_id) - 1, 0)
	return base_value * max(0.55, 1.0 - 0.045 * level_delta)


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
			push_message("+%d HP (kill drain)" % heal_amount, 0.8)
		stats_changed.emit()


func notify_deploy_kill() -> void:
	if not funeral_bloom_active:
		return
	if funeral_bloom_icd_timer > 0.0:
		return
	funeral_bloom_icd_timer = 1.5
	_emit_combo_effect(
		{
			"effect_id": "corruption_burst",
			"radius": 96.0,
			"damage_school": "dark",
			"apply_status": "snare",
			"color": "#6a1d8a"
		}
	)


func _emit_combo_effect(payload: Dictionary) -> void:
	last_combo_effect = payload.duplicate(true)
	combo_effect_requested.emit(last_combo_effect)


func apply_spell_modifiers(data: Dictionary) -> Dictionary:
	data = _apply_buff_runtime_modifiers(data)
	if str(data.get("school", "")) == "lightning":
		for effect in _collect_active_effects():
			if (
				str(effect.get("stat", "")) == "extra_lightning_ping"
				and int(effect.get("value", 0)) > 0
			):
				_emit_combo_effect(
					{
						"effect_id": "lightning_ping",
						"school": "lightning",
						"damage": int(round(float(data.get("damage", 10)) * 0.45)),
						"radius": 52.0,
						"color": "#a8c8ff"
					}
				)
				break
	if str(data.get("school", "")) == "ice":
		for effect in _collect_active_effects():
			if (
				str(effect.get("stat", "")) == "ice_reflect_wave"
				and int(effect.get("value", 0)) > 0
			):
				_emit_combo_effect(
					{
						"effect_id": "ice_reflect_wave",
						"school": "ice",
						"damage": int(round(float(data.get("damage", 10)) * 0.35)),
						"radius": 60.0,
						"color": "#b8e8ff"
					}
				)
				break
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
