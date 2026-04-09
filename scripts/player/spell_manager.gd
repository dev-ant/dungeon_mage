extends RefCounted

signal spell_cast(payload: Dictionary)

const SPLIT_EFFECT_PAYLOADS := {
	"arcane_force_pulse": {
		"attack": "arcane_force_pulse_attack",
		"hit": "arcane_force_pulse_hit"
	},
	"dark_void_bolt": {
		"attack": "dark_void_bolt_attack",
		"hit": "dark_void_bolt_hit"
	},
	"dark_shadow_bind": {
		"attack": "dark_shadow_bind_attack",
		"hit": "dark_shadow_bind_hit"
	},
	"earth_stone_spire": {
		"attack": "earth_stone_spire_attack",
		"hit": "earth_stone_spire_hit"
	},
	"earth_stone_rampart": {
		"attack": "earth_stone_rampart_attack",
		"hit": "earth_stone_rampart_hit"
	},
	"earth_tremor": {
		"attack": "earth_tremor_attack",
		"hit": "earth_tremor_hit"
	},
	"earth_gaia_break": {
		"attack": "earth_gaia_break_attack",
		"hit": "earth_gaia_break_hit"
	},
	"earth_continental_crush": {
		"attack": "earth_continental_crush_attack",
		"hit": "earth_continental_crush_hit"
	},
	"earth_world_end_break": {
		"attack": "earth_world_end_break_attack",
		"hit": "earth_world_end_break_hit"
	},
	"earth_stone_shot": {
		"attack": "earth_stone_shot_attack",
		"hit": "earth_stone_shot_hit"
	},
	"earth_rock_spear": {
		"attack": "earth_rock_spear_attack",
		"hit": "earth_rock_spear_hit"
	},
	"fire_bolt": {
		"attack": "fire_bolt_attack",
		"hit": "fire_bolt_hit"
	},
	"fire_flame_bullet": {
		"attack": "fire_flame_bullet_attack",
		"hit": "fire_flame_bullet_hit"
	},
	"fire_flame_storm": {
		"attack": "fire_flame_storm_attack",
		"hit": "fire_flame_storm_hit"
	},
	"fire_inferno_breath": {
		"attack": "fire_inferno_breath_attack",
		"hit": "fire_inferno_breath_hit"
	},
	"fire_inferno_buster": {
		"attack": "fire_inferno_buster_attack",
		"hit": "fire_inferno_buster_hit"
	},
	"fire_meteor_strike": {
		"attack": "fire_meteor_strike_attack",
		"hit": "fire_meteor_strike_hit"
	},
	"fire_apocalypse_flame": {
		"attack": "fire_apocalypse_flame_attack",
		"hit": "fire_apocalypse_flame_hit"
	},
	"fire_solar_cataclysm": {
		"attack": "fire_solar_cataclysm_attack",
		"hit": "fire_solar_cataclysm_hit"
	},
	"fire_hellfire_field": {
		"attack": "fire_hellfire_field_attack",
		"hit": "fire_hellfire_field_hit"
	},
	"fire_inferno_sigil": {
		"attack": "fire_inferno_sigil_attack",
		"hit": "fire_inferno_sigil_hit"
	},
	"holy_halo_touch": {
		"attack": "holy_halo_touch_attack",
		"hit": "holy_halo_touch_hit"
	},
	"holy_bless_field": {
		"attack": "holy_bless_field_attack",
		"hit": "holy_bless_field_hit"
	},
	"holy_radiant_burst": {
		"attack": "holy_radiant_burst_attack",
		"hit": "holy_radiant_burst_hit"
	},
	"holy_cure_ray": {
		"attack": "holy_cure_ray_attack",
		"hit": "holy_cure_ray_hit"
	},
	"holy_judgment_halo": {
		"attack": "holy_judgment_halo_attack",
		"hit": "holy_judgment_halo_hit"
	},
	"holy_sanctuary_of_reversal": {
		"attack": "holy_sanctuary_of_reversal_attack",
		"hit": "holy_sanctuary_of_reversal_hit"
	},
	"ice_storm": {
		"attack": "ice_storm_attack",
		"hit": "ice_storm_hit"
	},
	"ice_ice_wall": {
		"attack": "ice_ice_wall_attack",
		"hit": "ice_ice_wall_hit"
	},
	"ice_absolute_freeze": {
		"attack": "ice_absolute_freeze_attack",
		"hit": "ice_absolute_freeze_hit"
	},
	"ice_absolute_zero": {
		"attack": "ice_absolute_zero_attack",
		"hit": "ice_absolute_zero_hit"
	},
	"ice_frost_needle": {
		"attack": "ice_frost_needle_attack",
		"hit": "ice_frost_needle_hit"
	},
	"ice_spear": {
		"attack": "ice_spear_attack",
		"hit": "ice_spear_hit"
	},
	"lightning_thunder_arrow": {
		"attack": "lightning_thunder_arrow_attack",
		"hit": "lightning_thunder_arrow_hit"
	},
	"lightning_bolt": {
		"attack": "lightning_bolt_attack",
		"hit": "lightning_bolt_hit"
	},
	"plant_world_root": {
		"attack": "plant_world_root_attack",
		"hit": "plant_world_root_hit"
	},
	"plant_vine_snare": {
		"attack": "plant_vine_snare_attack",
		"hit": "plant_vine_snare_hit"
	},
	"plant_worldroot_bastion": {
		"attack": "plant_worldroot_bastion_attack",
		"hit": "plant_worldroot_bastion_hit"
	},
	"plant_genesis_arbor": {
		"attack": "plant_genesis_arbor_attack",
		"hit": "plant_genesis_arbor_hit"
	},
	"water_aqua_spear": {
		"attack": "water_aqua_spear_attack",
		"hit": "water_aqua_spear_hit"
	},
	"water_tidal_ring": {
		"attack": "water_tidal_ring_attack",
		"hit": "water_tidal_ring_hit"
	},
	"water_aqua_geyser": {
		"attack": "water_aqua_geyser_attack",
		"hit": "water_aqua_geyser_hit"
	},
	"water_wave": {
		"attack": "water_wave_attack",
		"hit": "water_wave_hit"
	},
	"water_tsunami": {
		"attack": "water_tsunami_attack",
		"hit": "water_tsunami_hit"
	},
	"water_ocean_collapse": {
		"attack": "water_ocean_collapse_attack",
		"hit": "water_ocean_collapse_hit"
	},
	"water_aqua_bullet": {
		"attack": "water_aqua_bullet_attack",
		"hit": "water_aqua_bullet_hit"
	},
	"wind_cyclone_prison": {
		"attack": "wind_cyclone_prison_attack",
		"hit": "wind_cyclone_prison_hit"
	},
	"wind_arrow": {
		"attack": "wind_arrow_attack",
		"hit": "wind_arrow_hit"
	},
	"wind_gust_bolt": {
		"attack": "wind_gust_bolt_attack",
		"hit": "wind_gust_bolt_hit"
	},
	"wind_gale_cutter": {
		"attack": "wind_gale_cutter_attack",
		"hit": "wind_gale_cutter_hit"
	},
	"wind_tempest_drive": {
		"attack": "wind_tempest_drive_attack",
		"hit": "wind_tempest_drive_hit"
	},
	"wind_storm": {
		"attack": "wind_storm_attack",
		"hit": "wind_storm_hit"
	},
	"wind_heavenly_storm": {
		"attack": "wind_heavenly_storm_attack",
		"hit": "wind_heavenly_storm_hit"
	},
	"volt_spear": {
		"attack": "volt_spear_attack",
		"hit": "volt_spear_hit"
	}
}
const EFFECT_PAYLOAD_OVERRIDES := {
	"fire_inferno_sigil": {
		"terminal_effect_id": "fire_inferno_sigil_end"
	},
	"fire_flame_storm": {
		"terminal_effect_id": "fire_flame_storm_end"
	},
	"fire_meteor_strike": {
		"terminal_effect_id": "fire_meteor_strike_end"
	},
	"fire_apocalypse_flame": {
		"terminal_effect_id": "fire_apocalypse_flame_end"
	},
	"fire_solar_cataclysm": {
		"terminal_effect_id": "fire_solar_cataclysm_end"
	},
	"earth_gaia_break": {
		"terminal_effect_id": "earth_gaia_break_end"
	},
	"earth_continental_crush": {
		"terminal_effect_id": "earth_continental_crush_end"
	},
	"earth_world_end_break": {
		"terminal_effect_id": "earth_world_end_break_end"
	},
	"fire_hellfire_field": {
		"terminal_effect_id": "fire_hellfire_field_end"
	},
	"holy_bless_field": {
		"terminal_effect_id": "holy_bless_field_end"
	},
	"holy_judgment_halo": {
		"terminal_effect_id": "holy_judgment_halo_end"
	},
	"dark_shadow_bind": {
		"terminal_effect_id": "dark_shadow_bind_end"
	},
	"holy_sanctuary_of_reversal": {
		"terminal_effect_id": "holy_sanctuary_of_reversal_end"
	},
	"ice_storm": {
		"terminal_effect_id": "ice_storm_end"
	},
	"ice_ice_wall": {
		"terminal_effect_id": "ice_ice_wall_end"
	},
	"earth_stone_rampart": {
		"terminal_effect_id": "earth_stone_rampart_end"
	},
	"ice_absolute_zero": {
		"terminal_effect_id": "ice_absolute_zero_end"
	},
	"plant_world_root": {
		"terminal_effect_id": "plant_world_root_end"
	},
	"plant_vine_snare": {
		"terminal_effect_id": "plant_vine_snare_end"
	},
	"plant_worldroot_bastion": {
		"terminal_effect_id": "plant_worldroot_bastion_end"
	},
	"plant_genesis_arbor": {
		"terminal_effect_id": "plant_genesis_arbor_end"
	},
	"water_tsunami": {
		"terminal_effect_id": "water_tsunami_end"
	},
	"water_ocean_collapse": {
		"terminal_effect_id": "water_ocean_collapse_end"
	},
	"water_aqua_geyser": {
		"terminal_effect_id": "water_aqua_geyser_end"
	},
	"wind_cyclone_prison": {
		"terminal_effect_id": "wind_cyclone_prison_end"
	}
}

var player: CharacterBody2D = null
var slot_bindings: Array = []
var slot_cooldowns: Dictionary = {
	"fire_bolt": 0.0,
	"ice_frost_needle": 0.0,
	"frost_nova": 0.0,
	"holy_cure_ray": 0.0,
	"holy_judgment_halo": 0.0,
	"water_tidal_ring": 0.0,
	"volt_spear": 0.0,
	"holy_mana_veil": 0.0,
	"fire_pyre_heart": 0.0,
	"ice_frostblood_ward": 0.0
}
var active_toggles: Dictionary = {}
var last_failure_reason := ""
var last_feedback_text := "대기"

func setup(player_node: CharacterBody2D) -> void:
	player = player_node
	slot_bindings = GameState.get_spell_hotbar()
	_sync_buff_cooldowns()

func tick(delta: float) -> void:
	for spell_id in slot_cooldowns.keys():
		slot_cooldowns[spell_id] = max(float(slot_cooldowns[spell_id]) - delta, 0.0)
	_tick_toggles(delta)
	_sync_buff_cooldowns()

func handle_input() -> void:
	for slot in _get_combat_input_bindings():
		var action := str(slot.get("action", ""))
		if action != "" and Input.is_action_just_pressed(action):
			attempt_cast_by_action(action)

func attempt_cast_by_action(action: String) -> bool:
	for slot in _get_combat_input_bindings():
		if str(slot.get("action", "")) == action:
			return attempt_cast(str(slot.get("skill_id", "")))
	last_failure_reason = "empty_slot"
	last_feedback_text = "빈 슬롯"
	_announce_failure()
	return false

func attempt_cast(skill_id: String) -> bool:
	last_failure_reason = ""
	if skill_id == "":
		last_failure_reason = "empty_slot"
		last_feedback_text = "빈 슬롯"
		_announce_failure()
		return false
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	if not skill_data.is_empty() and str(skill_data.get("skill_type", "")) == "toggle" and active_toggles.has(skill_id):
		return _cast_toggle(skill_id, skill_data)
	if not can_cast(skill_id):
		_announce_failure()
		return false
	if not skill_data.is_empty():
		var skill_type := str(skill_data.get("skill_type", ""))
		if skill_type == "buff":
			var activated := GameState.try_activate_buff(skill_id)
			_sync_buff_cooldowns()
			if not activated:
				last_failure_reason = "buff_rejected"
				last_feedback_text = "버프 사용 실패"
			else:
				if player != null and player.has_method("on_buff_activated"):
					player.call("on_buff_activated", skill_id)
				_emit_buff_activation_payload(skill_id, skill_data)
				last_feedback_text = "%s 활성화" % _get_skill_display_name(skill_id)
			return activated
		if skill_type == "deploy":
			return _cast_deploy(skill_id, skill_data)
		if skill_type == "toggle":
			return _cast_toggle(skill_id, skill_data)
	if not GameState.consume_skill_mana(skill_id):
		last_failure_reason = "mana"
		last_feedback_text = "MP 부족"
		_announce_failure()
		return false
	var runtime: Dictionary = GameState.get_spell_runtime(skill_id)
	slot_cooldowns[skill_id] = float(runtime.get("cooldown", 0.3))
	GameState.register_spell_use(skill_id, str(runtime.get("school", "")))
	var self_heal := int(runtime.get("self_heal", 0))
	if self_heal > 0:
		GameState.apply_direct_heal(self_heal)
	var speed_mult := GameState.get_equipment_projectile_speed_multiplier()
	var velocity_value := Vector2(float(runtime.get("speed", 0.0)) * player.facing * speed_mult, 0.0)
	var spawn_pos := player.global_position + Vector2(34 * player.facing, -18)
	if skill_id == "water_aqua_geyser":
		velocity_value = Vector2.ZERO
		spawn_pos = player.global_position + Vector2(96 * player.facing, -6)
	elif (
		skill_id == "frost_nova"
		or skill_id == "water_tidal_ring"
		or skill_id == "holy_judgment_halo"
	):
		velocity_value = Vector2.ZERO
		spawn_pos = player.global_position + Vector2(0, -6)
	var payload := runtime.duplicate(true)
	payload["spell_id"] = skill_id
	payload["position"] = spawn_pos
	payload["velocity"] = velocity_value
	payload["team"] = "player"
	payload["owner"] = player
	payload["total_damage"] = int(payload.get("damage", 0))
	payload["multi_hit_total"] = maxi(1, int(payload.get("multi_hit_count", 1)))
	_apply_hitstop_policy(payload, "active")
	_apply_skill_effect_payload(skill_id, payload)
	GameState.consume_spell_cast(skill_id)
	if player != null and player.has_method("on_active_skill_cast_started"):
		player.call("on_active_skill_cast_started", skill_id, runtime)
	_emit_active_payload_wave(payload)
	last_feedback_text = "%s 시전" % _get_skill_display_name(skill_id)
	return true

func can_cast(skill_id: String) -> bool:
	if player == null:
		last_failure_reason = "missing_player"
		return false
	if not player.can_cast_spell():
		last_failure_reason = "player_locked"
		return false
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	if not GameState.has_enough_mana(skill_id):
		last_failure_reason = "mana"
		last_feedback_text = "MP 부족"
		return false
	if not skill_data.is_empty() and str(skill_data.get("skill_type", "")) == "buff":
		if float(GameState.buff_cooldowns.get(skill_id, 0.0)) > 0.0 and not GameState.admin_ignore_cooldowns:
			last_failure_reason = "cooldown"
			return false
		if GameState.active_buffs.size() >= GameState.get_buff_slot_limit() and not GameState.admin_ignore_buff_slot_limit:
			last_failure_reason = "buff_slots_full"
			return false
		return true
	if float(slot_cooldowns.get(skill_id, 0.0)) > 0.0 and not GameState.admin_ignore_cooldowns:
		last_failure_reason = "cooldown"
		return false
	return true

func get_cooldown(skill_id: String) -> float:
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	if not skill_data.is_empty() and str(skill_data.get("skill_type", "")) == "buff":
		return float(GameState.buff_cooldowns.get(skill_id, 0.0))
	return float(slot_cooldowns.get(skill_id, 0.0))

func get_slot_bindings() -> Array:
	slot_bindings = GameState.get_spell_hotbar()
	return slot_bindings.duplicate(true)

func get_visible_slot_bindings() -> Array:
	return GameState.get_visible_spell_hotbar()


func _get_combat_input_bindings() -> Array:
	return GameState.get_action_hotkey_registry()

func assign_skill_to_slot(slot_index: int, skill_id: String) -> bool:
	var changed := GameState.set_hotbar_skill(slot_index, skill_id)
	if changed:
		slot_bindings = GameState.get_spell_hotbar()
	return changed

func clear_slot(slot_index: int) -> bool:
	var changed := GameState.clear_hotbar_skill(slot_index)
	if changed:
		slot_bindings = GameState.get_spell_hotbar()
	return changed

func swap_slots(first_index: int, second_index: int) -> bool:
	var changed := GameState.swap_hotbar_skills(first_index, second_index)
	if changed:
		slot_bindings = GameState.get_spell_hotbar()
	return changed


func assign_skill_to_action_hotkey(action: String, skill_id: String) -> bool:
	return GameState.set_action_hotkey_skill(action, skill_id)


func clear_action_hotkey(action: String) -> bool:
	return GameState.clear_action_hotkey_skill(action)

func get_hotbar_slot_tooltip_data(slot_index: int) -> Dictionary:
	var slot: Dictionary = GameState.get_hotbar_slot(slot_index)
	var skill_id := str(slot.get("skill_id", ""))
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	var runtime_data: Dictionary = GameDatabase.get_spell(skill_id)
	var cast_state := _get_slot_cast_state(skill_id)
	var resolved_school := GameState.resolve_runtime_school(
		str(skill_data.get("skill_id", skill_id)),
		skill_id,
		str(runtime_data.get("school", ""))
	)
	return {
		"slot_index": slot_index,
		"label": str(slot.get("label", "")),
		"action": str(slot.get("action", "")),
		"skill_id": skill_id,
		"name": "" if skill_id == "" else _get_skill_display_name(skill_id),
		"cooldown": 0.0 if skill_id == "" else get_cooldown(skill_id),
		"cost": 0.0 if skill_id == "" else GameState.get_skill_mana_cost(skill_id),
		"description": str(skill_data.get("description", runtime_data.get("description", ""))),
		"school": resolved_school,
		"current_state": str(cast_state.get("current_state", "empty")),
		"level": 0 if skill_id == "" else GameState.get_skill_level(skill_id),
		"mastery": 0 if skill_id == "" else int(GameState.spell_mastery.get(skill_id, 0)),
		"can_use": bool(cast_state.get("can_use", false)),
		"failure_reason": str(cast_state.get("failure_reason", ""))
	}

func get_hotbar_summary() -> String:
	var parts: Array[String] = []
	for slot in slot_bindings:
		var skill_id := str(slot.get("skill_id", ""))
		var label := str(slot.get("label", "?"))
		if skill_id == "":
			parts.append("%s [빈 슬롯]" % label)
			continue
		var cooldown := get_cooldown(skill_id)
		var display_name := _get_skill_display_name(skill_id)
		if active_toggles.has(skill_id):
			display_name = "%s 사용 중" % display_name
		var cooldown_text := "---" if cooldown <= 0.0 else "재사용:%.1f" % cooldown
		parts.append("%s %s %s" % [label, display_name, cooldown_text])
	return "핫바  %s" % " | ".join(parts)

func get_hotbar_mastery_summary() -> String:
	var parts: Array[String] = []
	for slot in slot_bindings:
		var skill_id := str(slot.get("skill_id", ""))
		var label := str(slot.get("label", "?"))
		if skill_id == "":
			parts.append("%s [빈 슬롯]" % label)
			continue
		var display_name := _get_skill_display_name(skill_id)
		var short_name: String = display_name.split(" ")[0]
		var level := GameState.get_spell_level(skill_id)
		var xp: int = int(GameState.spell_mastery.get(skill_id, 0))
		parts.append("%s %s Lv.%d (%d)" % [label, short_name, level, xp])
	return "스킬  %s" % "   ".join(parts)

func get_last_failure_reason() -> String:
	return last_failure_reason

func get_feedback_summary() -> String:
	return "시전  %s" % last_feedback_text

func get_toggle_summary() -> String:
	if active_toggles.is_empty():
		return "토글  없음"
	var parts: Array[String] = []
	for skill_id in active_toggles.keys():
		var toggle_data: Dictionary = active_toggles[skill_id]
		var tag_text := ""
		var tags: Array = toggle_data.get("tags", [])
		if not tags.is_empty():
			tag_text = " [%s]" % "/".join(tags)
		var extra_detail := ""
		if skill_id == "dark_soul_dominion":
			var dmg_pct := int(round((GameState.SOUL_DOMINION_DAMAGE_TAKEN_MULT - 1.0) * 100.0))
			extra_detail = " [MP 봉인 피격 +%d%%]" % dmg_pct
		elif skill_id == "ice_glacial_dominion":
			var utility_effects: Array = toggle_data.get("utility_effects", [])
			for eff in utility_effects:
				if str(eff.get("type", "")) == "slow":
					var slow_pct := int(round(float(eff.get("value", 0.0)) * 100.0))
					extra_detail = " [둔화 %d%%]" % slow_pct
					break
		elif skill_id == "lightning_tempest_crown":
			var pierce_count: int = int(toggle_data.get("pierce", 0))
			if pierce_count > 0:
				extra_detail = " [관통 x%d]" % pierce_count
		elif skill_id == "earth_fortress":
			var support_effects: Array = toggle_data.get("support_effects", [])
			for eff in support_effects:
				if str(eff.get("stat", "")) == "defense_multiplier":
					extra_detail = " [방어 x%.2f]" % float(eff.get("value", 1.0))
					break
		elif skill_id == "wind_sky_dominion":
			var support_effects: Array = toggle_data.get("support_effects", [])
			var air_jump_bonus := 0
			for eff in support_effects:
				if str(eff.get("stat", "")) == "air_jump_bonus":
					air_jump_bonus = int(round(float(eff.get("value", 0.0))))
					break
			extra_detail = " [체공 +%d단]" % air_jump_bonus
		parts.append("%s%s%s 틱 %.1f 소모 %.1f" % [
			_get_skill_display_name(skill_id),
			tag_text,
			extra_detail,
			float(toggle_data.get("tick_remaining", 0.0)),
			float(toggle_data.get("mana_drain_per_tick", 0.0))
		])
	return "토글  %s" % " | ".join(parts)

func reset_all_cooldowns() -> void:
	for skill_id in slot_cooldowns.keys():
		slot_cooldowns[skill_id] = 0.0
	for skill_id in GameState.buff_cooldowns.keys():
		GameState.buff_cooldowns[skill_id] = 0.0

func _sync_buff_cooldowns() -> void:
	for skill_id in GameState.buff_cooldowns.keys():
		slot_cooldowns[skill_id] = float(GameState.buff_cooldowns.get(skill_id, 0.0))

func _get_skill_display_name(skill_id: String) -> String:
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	if not skill_data.is_empty():
		return str(skill_data.get("display_name", skill_id))
	var runtime_data: Dictionary = GameDatabase.get_spell(skill_id)
	if not runtime_data.is_empty():
		return str(runtime_data.get("name", skill_id))
	return skill_id

func _get_slot_cast_state(skill_id: String) -> Dictionary:
	if skill_id == "":
		return {"current_state": "empty", "can_use": false, "failure_reason": "empty_slot"}
	if active_toggles.has(skill_id):
		return {"current_state": "active_toggle", "can_use": true, "failure_reason": ""}
	if player == null:
		return {"current_state": "missing_player", "can_use": false, "failure_reason": "missing_player"}
	if not player.can_cast_spell():
		return {"current_state": "locked", "can_use": false, "failure_reason": "player_locked"}
	if not GameState.has_enough_mana(skill_id):
		return {
			"current_state": "insufficient_mana",
			"can_use": false,
			"failure_reason": "mana"
		}
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	if not skill_data.is_empty() and str(skill_data.get("skill_type", "")) == "buff":
		if float(GameState.buff_cooldowns.get(skill_id, 0.0)) > 0.0 and not GameState.admin_ignore_cooldowns:
			return {"current_state": "cooldown", "can_use": false, "failure_reason": "cooldown"}
		if GameState.active_buffs.size() >= GameState.get_buff_slot_limit() and not GameState.admin_ignore_buff_slot_limit:
			return {
				"current_state": "buff_slots_full",
				"can_use": false,
				"failure_reason": "buff_slots_full"
			}
		return {"current_state": "ready", "can_use": true, "failure_reason": ""}
	if float(slot_cooldowns.get(skill_id, 0.0)) > 0.0 and not GameState.admin_ignore_cooldowns:
		return {"current_state": "cooldown", "can_use": false, "failure_reason": "cooldown"}
	return {"current_state": "ready", "can_use": true, "failure_reason": ""}

func get_split_effect_skill_ids() -> Array[String]:
	var skill_ids: Array[String] = []
	for skill_id in SPLIT_EFFECT_PAYLOADS.keys():
		skill_ids.append(str(skill_id))
	skill_ids.sort()
	return skill_ids

func get_split_effect_payload(skill_id: String) -> Dictionary:
	return SPLIT_EFFECT_PAYLOADS.get(skill_id, {}).duplicate(true)

func _apply_skill_effect_payload(skill_id: String, payload: Dictionary) -> void:
	var effect_ids: Dictionary = get_split_effect_payload(skill_id)
	if not effect_ids.is_empty():
		payload["attack_effect_id"] = str(effect_ids.get("attack", ""))
		payload["hit_effect_id"] = str(effect_ids.get("hit", ""))
	var payload_overrides: Dictionary = EFFECT_PAYLOAD_OVERRIDES.get(skill_id, {})
	for key in payload_overrides.keys():
		payload[key] = payload_overrides[key]

func _announce_failure() -> void:
	match last_failure_reason:
		"empty_slot":
			GameState.push_message("해당 핫바 슬롯은 비어 있습니다.", 1.0)
		"player_locked":
			GameState.push_message("경직되었거나 쓰러진 상태에서는 시전할 수 없습니다.", 1.0)
		"cooldown":
			GameState.push_message("그 마법식은 아직 재정비되지 않았습니다.", 1.0)
		"mana":
			GameState.push_message("마나가 부족해 그 시전을 유지할 수 없습니다.", 1.0)
		"buff_slots_full":
			GameState.push_message("현재 서클에서는 활성 버프를 더 유지할 수 없습니다.", 1.2)

func _emit_buff_activation_payload(skill_id: String, skill_data: Dictionary) -> void:
	if player == null:
		return
	var runtime := _build_buff_activation_runtime(skill_id, skill_data)
	if runtime.is_empty():
		return
	var offset_x := float(skill_data.get("activation_burst_offset_x", 0.0))
	var offset_y := float(skill_data.get("activation_burst_offset_y", -10.0))
	var payload := GameState.build_data_driven_combat_payload(
		skill_id,
		runtime,
			{
				"position": player.global_position + Vector2(offset_x * player.facing, offset_y),
				"duration": float(runtime.get("duration", 0.0)),
				"owner": player,
				"color": _get_skill_color(skill_data)
			}
		)
	_apply_hitstop_policy(payload, "active")
	_apply_skill_effect_payload(skill_id, payload)
	GameState.register_spell_use(skill_id, str(runtime.get("school", "")))
	spell_cast.emit(payload)

func _build_buff_activation_runtime(skill_id: String, skill_data: Dictionary) -> Dictionary:
	var authored_spell: Dictionary = GameDatabase.get_spell(skill_id)
	if not authored_spell.is_empty():
		return GameState.get_spell_runtime(skill_id)
	var burst_duration := float(skill_data.get("activation_burst_duration", 0.0))
	var burst_size := float(skill_data.get("activation_burst_size", 0.0))
	var burst_formula: Dictionary = skill_data.get("activation_burst_damage_formula", {})
	if burst_duration <= 0.0 or burst_size <= 0.0 or burst_formula.is_empty():
		return {}
	var runtime_skill_data := skill_data.duplicate(true)
	runtime_skill_data["duration_base"] = burst_duration
	runtime_skill_data["range_base"] = burst_size
	runtime_skill_data["knockback_base"] = float(
		skill_data.get("activation_burst_knockback", skill_data.get("knockback_base", 180.0))
	)
	runtime_skill_data["damage_formula"] = burst_formula.duplicate(true)
	runtime_skill_data["utility_effects"] = skill_data.get(
		"activation_burst_utility_effects",
		[]
	).duplicate(true)
	return GameState.get_data_driven_skill_runtime(skill_id, runtime_skill_data)

func _cast_deploy(skill_id: String, skill_data: Dictionary) -> bool:
	for penalty in GameState.active_penalties:
		if str(penalty.get("stat", "")) == "deploy_recast_delay":
			last_failure_reason = "blocked"
			last_feedback_text = "설치식 재조정 중"
			_announce_failure()
			return false
	var runtime := _build_skill_runtime(skill_id, skill_data)
	runtime = GameState.apply_deploy_buff_modifiers(runtime)
	if not GameState.consume_skill_mana(skill_id):
		last_failure_reason = "mana"
		last_feedback_text = "MP 부족"
		_announce_failure()
		return false
	slot_cooldowns[skill_id] = float(runtime.get("cooldown", 0.8))
	GameState.register_spell_use(skill_id, str(runtime.get("school", "")))
	var payload := GameState.build_data_driven_combat_payload(
		skill_id,
		runtime,
		{
			"position": player.global_position + Vector2(48 * player.facing, -4),
			"target_count": int(runtime.get("target_count", 0)),
			"color": _get_skill_color(skill_data),
			"owner": player
		}
	)
	_apply_hitstop_policy(payload, "deploy")
	_apply_skill_effect_payload(skill_id, payload)
	GameState.consume_spell_cast(skill_id)
	spell_cast.emit(payload)
	last_feedback_text = "%s 설치" % _get_skill_display_name(skill_id)
	return true

func _cast_toggle(skill_id: String, skill_data: Dictionary) -> bool:
	if active_toggles.has(skill_id):
		active_toggles.erase(skill_id)
		if player != null and player.has_method("on_toggle_deactivated"):
			player.call("on_toggle_deactivated", skill_id)
		if skill_id == "dark_soul_dominion":
			GameState.soul_dominion_active = false
			GameState.soul_dominion_aftershock_timer = GameState.SOUL_DOMINION_AFTERSHOCK_DURATION
			GameState.push_message("소울 도미니언이 가라앉고, 여진만 남는다.", 1.5)
		else:
			GameState.push_message("%s 효과가 사라졌습니다." % _get_skill_display_name(skill_id), 1.0)
		last_feedback_text = "%s 비활성화" % _get_skill_display_name(skill_id)
		return true
	if not GameState.consume_skill_mana(skill_id):
		last_failure_reason = "mana"
		last_feedback_text = "MP 부족"
		_announce_failure()
		return false
	var runtime := _build_skill_runtime(skill_id, skill_data)
	slot_cooldowns[skill_id] = float(runtime.get("cooldown", 1.0))
	active_toggles[skill_id] = {
		"tick_interval": float(runtime.get("tick_interval", 1.0)),
		"tick_remaining": 0.01,
		"damage": int(runtime.get("damage", 12)),
		"size": float(runtime.get("size", 60.0)),
		"pull_strength": float(runtime.get("pull_strength", 0.0)),
		"self_heal": int(runtime.get("self_heal", 0)),
		"support_effects": runtime.get("support_effects", []).duplicate(true),
		"support_effect_duration": float(runtime.get("support_effect_duration", 0.0)),
		"mana_drain_per_tick": float(runtime.get("mana_drain_per_tick", 0.0)),
		"pierce": int(runtime.get("pierce", 0)),
		"tags": _get_toggle_runtime_tags(skill_data, runtime),
		"utility_effects": runtime.get("utility_effects", []).duplicate(true),
		"school": str(runtime.get("school", GameState.resolve_runtime_school(skill_id))),
		"color": _get_skill_color(skill_data)
	}
	if skill_id == "dark_soul_dominion":
		GameState.soul_dominion_active = true
		GameState.soul_dominion_aftershock_timer = 0.0
	if player != null and player.has_method("on_toggle_activated"):
		player.call("on_toggle_activated", skill_id)
	GameState.register_spell_use(skill_id, str(runtime.get("school", "")))
	GameState.push_message("%s 효과가 활성 오라로 전개됩니다." % _get_skill_display_name(skill_id), 1.2)
	last_feedback_text = "%s 활성화" % _get_skill_display_name(skill_id)
	return true

func _tick_toggles(delta: float) -> void:
	for skill_id in active_toggles.keys():
		var toggle_data: Dictionary = active_toggles[skill_id]
		toggle_data["tick_remaining"] = max(float(toggle_data.get("tick_remaining", 0.0)) - delta, 0.0)
		if float(toggle_data.get("tick_remaining", 0.0)) <= 0.0:
			var mana_drain_per_tick: float = float(toggle_data.get("mana_drain_per_tick", 0.0))
			if not GameState.consume_mana_amount(mana_drain_per_tick):
				active_toggles.erase(skill_id)
				if player != null and player.has_method("on_toggle_deactivated"):
					player.call("on_toggle_deactivated", skill_id)
				if skill_id == "dark_soul_dominion":
					GameState.soul_dominion_active = false
					GameState.soul_dominion_aftershock_timer = GameState.SOUL_DOMINION_AFTERSHOCK_DURATION
					GameState.push_message("소울 도미니언이 붕괴하고, 여진이 이어집니다.", 1.5)
				else:
					GameState.push_message("%s 효과가 마나 고갈로 붕괴했습니다." % _get_skill_display_name(skill_id), 1.2)
				last_feedback_text = "%s 비활성화(MP)" % _get_skill_display_name(skill_id)
				continue
			toggle_data["tick_remaining"] = float(toggle_data.get("tick_interval", 1.0))
			var payload := GameState.build_data_driven_combat_payload(
				skill_id,
				toggle_data,
				{
					"position": player.global_position + Vector2(0, -10),
					"knockback": 70.0,
					"duration": 0.12,
					"color": str(toggle_data.get("color", "#8f77d8")),
					"owner": player
				}
			)
			_apply_hitstop_policy(payload, "toggle")
			_apply_skill_effect_payload(skill_id, payload)
			payload = GameState.apply_spell_modifiers(payload)
			spell_cast.emit(payload)
		active_toggles[skill_id] = toggle_data

func _build_skill_runtime(skill_id: String, skill_data: Dictionary) -> Dictionary:
	return GameState.get_data_driven_skill_runtime(skill_id, skill_data)

func _get_toggle_mana_drain_per_tick(
	skill_id: String, skill_data: Dictionary, runtime_options: Dictionary = {}
) -> float:
	return GameState.get_data_driven_skill_mana_drain_per_tick(skill_id, skill_data, runtime_options)

func _get_toggle_runtime_tags(skill_data: Dictionary, runtime: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	for effect in runtime.get("utility_effects", []):
		var effect_type := str(effect.get("type", ""))
		if effect_type != "" and not tags.has(effect_type):
			tags.append(effect_type)
	if (
		int(runtime.get("self_heal", 0)) > 0
		or not (runtime.get("support_effects", []) as Array).is_empty()
	) and not tags.has("support"):
		tags.append("support")
	if float(runtime.get("pull_strength", 0.0)) > 0.0 and not tags.has("pull"):
		tags.append("pull")
	if int(runtime.get("pierce", 0)) > 0 and not tags.has("pierce"):
		tags.append("pierce")
	var role_tags: Array = skill_data.get("role_tags", [])
	if role_tags.has("finisher") or role_tags.has("rule_break"):
		if not tags.has("risk"):
			tags.append("risk")
	return tags

func _get_skill_color(skill_data: Dictionary) -> String:
	var element := str(skill_data.get("element", "arcane"))
	match element:
		"earth":
			return "#c8a56a"
		"dark":
			return "#8e6bd1"
		"fire":
			return "#ff8f45"
		"ice":
			return "#8cecff"
		"lightning":
			return "#f7ef6a"
	return "#ffffff"


func _emit_active_payload_wave(payload: Dictionary) -> void:
	spell_cast.emit(payload)
	var velocity_value: Vector2 = payload.get("velocity", Vector2.ZERO)
	var count_bonus: int = GameState.get_equipment_projectile_count_bonus()
	if count_bonus <= 0 or velocity_value == Vector2.ZERO:
		return
	for i in range(count_bonus):
		var angle_sign := 1.0 if i % 2 == 0 else -1.0
		var angle_deg := angle_sign * (15.0 * (int(i / 2) + 1))
		var extra := payload.duplicate(true)
		extra["velocity"] = velocity_value.rotated(deg_to_rad(angle_deg))
		extra["suppress_cast_lock"] = true
		spell_cast.emit(extra)


func _apply_hitstop_policy(payload: Dictionary, cast_type: String) -> void:
	if cast_type == "deploy" or cast_type == "toggle":
		payload["hitstop_mode"] = "none"
		return
	var speed := float(payload.get("speed", 0.0))
	var duration := float(payload.get("duration", 0.0))
	var size := float(payload.get("size", 0.0))
	if speed <= 0.0 and duration > 0.0 and size >= 48.0:
		payload["hitstop_mode"] = "area_burst"
		return
	payload["hitstop_mode"] = "default"
