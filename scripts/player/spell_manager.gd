extends RefCounted

signal spell_cast(payload: Dictionary)

const SPLIT_EFFECT_PAYLOADS := {
	"dark_void_bolt": {
		"attack": "dark_void_bolt_attack",
		"hit": "dark_void_bolt_hit"
	},
	"earth_tremor": {
		"attack": "earth_tremor_attack",
		"hit": "earth_tremor_hit"
	},
	"fire_bolt": {
		"attack": "fire_bolt_attack",
		"hit": "fire_bolt_hit"
	},
	"holy_radiant_burst": {
		"attack": "holy_radiant_burst_attack",
		"hit": "holy_radiant_burst_hit"
	},
	"water_aqua_bullet": {
		"attack": "water_aqua_bullet_attack",
		"hit": "water_aqua_bullet_hit"
	},
	"wind_gale_cutter": {
		"attack": "wind_gale_cutter_attack",
		"hit": "wind_gale_cutter_hit"
	},
	"volt_spear": {
		"attack": "volt_spear_attack",
		"hit": "volt_spear_hit"
	}
}

var player: CharacterBody2D = null
var slot_bindings: Array = []
var slot_cooldowns: Dictionary = {
	"fire_bolt": 0.0,
	"frost_nova": 0.0,
	"volt_spear": 0.0,
	"holy_mana_veil": 0.0,
	"fire_pyre_heart": 0.0,
	"ice_frostblood_ward": 0.0
}
var active_toggles: Dictionary = {}
var last_failure_reason := ""
var last_feedback_text := "Ready"

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
	last_feedback_text = "Empty slot"
	_announce_failure()
	return false

func attempt_cast(skill_id: String) -> bool:
	last_failure_reason = ""
	if skill_id == "":
		last_failure_reason = "empty_slot"
		last_feedback_text = "Empty slot"
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
				last_feedback_text = "Buff rejected"
			else:
				last_feedback_text = "%s activated" % _get_skill_display_name(skill_id)
			return activated
		if skill_type == "deploy":
			return _cast_deploy(skill_id, skill_data)
		if skill_type == "toggle":
			return _cast_toggle(skill_id, skill_data)
	if not GameState.consume_skill_mana(skill_id):
		last_failure_reason = "mana"
		last_feedback_text = "Need more mana"
		_announce_failure()
		return false
	var runtime: Dictionary = GameState.get_spell_runtime(skill_id)
	slot_cooldowns[skill_id] = float(runtime.get("cooldown", 0.3))
	GameState.register_spell_use(skill_id, str(runtime.get("school", "")))
	var speed_mult := GameState.get_equipment_projectile_speed_multiplier()
	var velocity_value := Vector2(float(runtime.get("speed", 0.0)) * player.facing * speed_mult, 0.0)
	var spawn_pos := player.global_position + Vector2(34 * player.facing, -18)
	if skill_id == "frost_nova":
		velocity_value = Vector2.ZERO
		spawn_pos = player.global_position + Vector2(0, -6)
	var payload := runtime.duplicate(true)
	payload["spell_id"] = skill_id
	payload["position"] = spawn_pos
	payload["velocity"] = velocity_value
	payload["team"] = "player"
	payload["owner"] = player
	_apply_hitstop_policy(payload, "active")
	_apply_skill_effect_payload(skill_id, payload)
	GameState.consume_spell_cast(skill_id)
	spell_cast.emit(payload)
	var count_bonus := GameState.get_equipment_projectile_count_bonus()
	if count_bonus > 0 and velocity_value != Vector2.ZERO:
		for i in range(count_bonus):
			var angle_sign := 1.0 if i % 2 == 0 else -1.0
			var angle_deg := angle_sign * (15.0 * (int(i / 2) + 1))
			var extra := payload.duplicate(true)
			extra["velocity"] = velocity_value.rotated(deg_to_rad(angle_deg))
			spell_cast.emit(extra)
	last_feedback_text = "%s cast" % _get_skill_display_name(skill_id)
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
		last_feedback_text = "Need more mana"
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
	return GameState.get_visible_spell_hotbar()

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
			parts.append("%s [empty]" % label)
			continue
		var cooldown := get_cooldown(skill_id)
		var display_name := _get_skill_display_name(skill_id)
		if active_toggles.has(skill_id):
			display_name = "%s ON" % display_name
		var cooldown_text := "---" if cooldown <= 0.0 else "cd:%.1f" % cooldown
		parts.append("%s %s %s" % [label, display_name, cooldown_text])
	return "Hotbar  %s" % " | ".join(parts)

func get_hotbar_mastery_summary() -> String:
	var parts: Array[String] = []
	for slot in slot_bindings:
		var skill_id := str(slot.get("skill_id", ""))
		var label := str(slot.get("label", "?"))
		if skill_id == "":
			parts.append("%s [empty]" % label)
			continue
		var display_name := _get_skill_display_name(skill_id)
		var short_name: String = display_name.split(" ")[0]
		var level := GameState.get_spell_level(skill_id)
		var xp: int = int(GameState.spell_mastery.get(skill_id, 0))
		parts.append("%s %s Lv.%d (%d)" % [label, short_name, level, xp])
	return "Skills  %s" % "   ".join(parts)

func get_last_failure_reason() -> String:
	return last_failure_reason

func get_feedback_summary() -> String:
	return "Cast  %s" % last_feedback_text

func get_toggle_summary() -> String:
	if active_toggles.is_empty():
		return "Toggles  none"
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
			extra_detail = " [MP-LOCK DMG+%d%%]" % dmg_pct
		elif skill_id == "ice_glacial_dominion":
			var utility_effects: Array = toggle_data.get("utility_effects", [])
			for eff in utility_effects:
				if str(eff.get("type", "")) == "slow":
					var slow_pct := int(round(float(eff.get("value", 0.0)) * 100.0))
					extra_detail = " [slow %d%%]" % slow_pct
					break
		elif skill_id == "lightning_tempest_crown":
			var pierce_count: int = int(toggle_data.get("pierce", 0))
			if pierce_count > 0:
				extra_detail = " [pierce x%d]" % pierce_count
		parts.append("%s%s%s tick %.1f drain %.1f" % [
			_get_skill_display_name(skill_id),
			tag_text,
			extra_detail,
			float(toggle_data.get("tick_remaining", 0.0)),
			float(toggle_data.get("mana_drain_per_tick", 0.0))
		])
	return "Toggles  %s" % " | ".join(parts)

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
	if effect_ids.is_empty():
		return
	payload["attack_effect_id"] = str(effect_ids.get("attack", ""))
	payload["hit_effect_id"] = str(effect_ids.get("hit", ""))

func _announce_failure() -> void:
	match last_failure_reason:
		"empty_slot":
			GameState.push_message("That hotbar slot is empty.", 1.0)
		"player_locked":
			GameState.push_message("You cannot cast while staggered or collapsed.", 1.0)
		"cooldown":
			GameState.push_message("That spell pattern has not recovered yet.", 1.0)
		"mana":
			GameState.push_message("Your mana lattice is too dry for that cast.", 1.0)
		"buff_slots_full":
			GameState.push_message("Your current circle cannot hold another active buff.", 1.2)

func _cast_deploy(skill_id: String, skill_data: Dictionary) -> bool:
	for penalty in GameState.active_penalties:
		if str(penalty.get("stat", "")) == "deploy_recast_delay":
			last_failure_reason = "blocked"
			last_feedback_text = "Deploy patterns still recalibrating"
			_announce_failure()
			return false
	var runtime := _build_skill_runtime(skill_id, skill_data)
	runtime = GameState.apply_deploy_buff_modifiers(runtime)
	if not GameState.consume_skill_mana(skill_id):
		last_failure_reason = "mana"
		last_feedback_text = "Need more mana"
		_announce_failure()
		return false
	slot_cooldowns[skill_id] = float(runtime.get("cooldown", 0.8))
	GameState.register_spell_use(skill_id, str(runtime.get("school", "")))
	var payload := GameState.build_data_driven_combat_payload(
		skill_id,
		runtime,
		{
			"position": player.global_position + Vector2(48 * player.facing, -4),
			"target_count": int(skill_data.get("target_count_base", 0))
			+ GameState.get_skill_milestone_runtime_bonus(
				skill_data,
				"target_count",
				GameState.get_skill_level(skill_id)
			),
			"color": _get_skill_color(skill_data),
			"owner": player
		}
	)
	_apply_hitstop_policy(payload, "deploy")
	GameState.consume_spell_cast(skill_id)
	spell_cast.emit(payload)
	last_feedback_text = "%s deployed" % _get_skill_display_name(skill_id)
	return true

func _cast_toggle(skill_id: String, skill_data: Dictionary) -> bool:
	if active_toggles.has(skill_id):
		active_toggles.erase(skill_id)
		if skill_id == "dark_soul_dominion":
			GameState.soul_dominion_active = false
			GameState.soul_dominion_aftershock_timer = GameState.SOUL_DOMINION_AFTERSHOCK_DURATION
			GameState.push_message("Soul Dominion recedes. Aftershock lingers.", 1.5)
		else:
			GameState.push_message("%s fades." % _get_skill_display_name(skill_id), 1.0)
		last_feedback_text = "%s off" % _get_skill_display_name(skill_id)
		return true
	if not GameState.consume_skill_mana(skill_id):
		last_failure_reason = "mana"
		last_feedback_text = "Need more mana"
		_announce_failure()
		return false
	var runtime := _build_skill_runtime(skill_id, skill_data)
	slot_cooldowns[skill_id] = float(runtime.get("cooldown", 1.0))
	active_toggles[skill_id] = {
		"tick_interval": float(runtime.get("tick_interval", 1.0)),
		"tick_remaining": 0.01,
		"damage": int(runtime.get("damage", 12)),
		"size": float(runtime.get("size", 60.0)),
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
	GameState.register_spell_use(skill_id, str(runtime.get("school", "")))
	GameState.push_message("%s hums into an active aura." % _get_skill_display_name(skill_id), 1.2)
	last_feedback_text = "%s on" % _get_skill_display_name(skill_id)
	return true

func _tick_toggles(delta: float) -> void:
	for skill_id in active_toggles.keys():
		var toggle_data: Dictionary = active_toggles[skill_id]
		toggle_data["tick_remaining"] = max(float(toggle_data.get("tick_remaining", 0.0)) - delta, 0.0)
		if float(toggle_data.get("tick_remaining", 0.0)) <= 0.0:
			var mana_drain_per_tick: float = float(toggle_data.get("mana_drain_per_tick", 0.0))
			if not GameState.consume_mana_amount(mana_drain_per_tick):
				active_toggles.erase(skill_id)
				if skill_id == "dark_soul_dominion":
					GameState.soul_dominion_active = false
					GameState.soul_dominion_aftershock_timer = GameState.SOUL_DOMINION_AFTERSHOCK_DURATION
					GameState.push_message("Soul Dominion collapses — aftershock persists.", 1.5)
				else:
					GameState.push_message("%s collapses as your mana runs dry." % _get_skill_display_name(skill_id), 1.2)
				last_feedback_text = "%s off (mana)" % _get_skill_display_name(skill_id)
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
