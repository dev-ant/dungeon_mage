extends RefCounted

var max_health: int
var health: int
var max_mana: float
var mana: float
var mana_regen_per_second: float
var buff_cooldowns: Dictionary = {}
var active_buffs: Array = []
var active_penalties: Array = []
var combo_barrier := 0.0
var combo_barrier_combo_id := ""
var time_collapse_charges := 0
var time_collapse_active := false
var overclock_circuit_active := false
var funeral_bloom_active := false
var funeral_bloom_icd_timer := 0.0
var ashen_rite_active := false
var ash_stacks := 0
var ash_residue_timer := 0.0
var soul_dominion_active := false
var soul_dominion_aftershock_timer := 0.0
var last_combo_effect: Dictionary = {}
var session_damage_dealt: int = 0
var session_hit_count: int = 0
var session_kills: int = 0
var session_drops: int = 0
var last_drop_display := ""
var last_damage_amount := 0
var last_damage_school := ""
var last_damage_display_timer := 0.0


func _init(
	base_max_health: int = 100,
	base_max_mana: float = 180.0,
	base_mana_regen_per_second: float = 14.0
) -> void:
	reset(base_max_health, base_max_mana, base_mana_regen_per_second)


func reset(base_max_health: int, base_max_mana: float, base_mana_regen_per_second: float) -> void:
	max_health = base_max_health
	health = base_max_health
	max_mana = base_max_mana
	mana = base_max_mana
	mana_regen_per_second = base_mana_regen_per_second
	buff_cooldowns.clear()
	active_buffs.clear()
	active_penalties.clear()
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
	session_damage_dealt = 0
	session_hit_count = 0
	session_kills = 0
	session_drops = 0
	last_drop_display = ""
	last_damage_amount = 0
	last_damage_school = ""
	last_damage_display_timer = 0.0


func build_resource_save_payload() -> Dictionary:
	return {"health": health, "mana": mana}


func load_resource_save_payload(parsed: Dictionary) -> void:
	health = int(parsed.get("health", health))
	mana = float(parsed.get("mana", mana))
