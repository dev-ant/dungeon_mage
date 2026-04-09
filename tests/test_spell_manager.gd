extends "res://addons/gut/test.gd"

const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")
const SPELL_MANAGER_SCRIPT := preload("res://scripts/player/spell_manager.gd")
const SPELL_PROJECTILE_SCRIPT := preload("res://scripts/player/spell_projectile.gd")
const ENEMY_SCRIPT := preload("res://scripts/enemies/enemy_base.gd")
const SPLIT_EFFECT_CASES := [
	{"spell_id": "arcane_force_pulse", "attack": "arcane_force_pulse_attack", "attack_frames": 6, "hit": "arcane_force_pulse_hit", "hit_frames": 8},
	{"spell_id": "volt_spear", "attack": "volt_spear_attack", "attack_frames": 8, "hit": "volt_spear_hit", "hit_frames": 8},
	{"spell_id": "wind_arrow", "attack": "wind_arrow_attack", "attack_frames": 6, "hit": "wind_arrow_hit", "hit_frames": 8},
	{"spell_id": "wind_gust_bolt", "attack": "wind_gust_bolt_attack", "attack_frames": 6, "hit": "wind_gust_bolt_hit", "hit_frames": 8},
	{"spell_id": "wind_tempest_drive", "attack": "wind_tempest_drive_attack", "attack_frames": 6, "hit": "wind_tempest_drive_hit", "hit_frames": 8},
	{"spell_id": "earth_stone_shot", "attack": "earth_stone_shot_attack", "attack_frames": 6, "hit": "earth_stone_shot_hit", "hit_frames": 6},
	{"spell_id": "earth_rock_spear", "attack": "earth_rock_spear_attack", "attack_frames": 6, "hit": "earth_rock_spear_hit", "hit_frames": 6},
	{"spell_id": "fire_bolt", "attack": "fire_bolt_attack", "attack_frames": 8, "hit": "fire_bolt_hit", "hit_frames": 8},
	{"spell_id": "fire_flame_bullet", "attack": "fire_flame_bullet_attack", "attack_frames": 6, "hit": "fire_flame_bullet_hit", "hit_frames": 8},
	{"spell_id": "fire_flame_storm", "attack": "fire_flame_storm_attack", "attack_frames": 4, "hit": "fire_flame_storm_hit", "hit_frames": 4},
	{"spell_id": "fire_inferno_breath", "attack": "fire_inferno_breath_attack", "attack_frames": 8, "hit": "fire_inferno_breath_hit", "hit_frames": 5},
	{"spell_id": "fire_inferno_buster", "attack": "fire_inferno_buster_attack", "attack_frames": 4, "hit": "fire_inferno_buster_hit", "hit_frames": 4},
	{"spell_id": "fire_meteor_strike", "attack": "fire_meteor_strike_attack", "attack_frames": 4, "hit": "fire_meteor_strike_hit", "hit_frames": 4},
	{"spell_id": "fire_apocalypse_flame", "attack": "fire_apocalypse_flame_attack", "attack_frames": 4, "hit": "fire_apocalypse_flame_hit", "hit_frames": 4},
	{"spell_id": "fire_solar_cataclysm", "attack": "fire_solar_cataclysm_attack", "attack_frames": 4, "hit": "fire_solar_cataclysm_hit", "hit_frames": 4},
	{"spell_id": "ice_absolute_zero", "attack": "ice_absolute_zero_attack", "attack_frames": 4, "hit": "ice_absolute_zero_hit", "hit_frames": 4},
	{"spell_id": "fire_hellfire_field", "attack": "fire_hellfire_field_attack", "attack_frames": 4, "hit": "fire_hellfire_field_hit", "hit_frames": 4},
	{"spell_id": "holy_halo_touch", "attack": "holy_halo_touch_attack", "attack_frames": 6, "hit": "holy_halo_touch_hit", "hit_frames": 8},
	{"spell_id": "holy_bless_field", "attack": "holy_bless_field_attack", "attack_frames": 4, "hit": "holy_bless_field_hit", "hit_frames": 4},
	{"spell_id": "fire_inferno_sigil", "attack": "fire_inferno_sigil_attack", "attack_frames": 17, "hit": "fire_inferno_sigil_hit", "hit_frames": 13},
	{"spell_id": "holy_cure_ray", "attack": "holy_cure_ray_attack", "attack_frames": 12, "hit": "holy_cure_ray_hit", "hit_frames": 7},
	{"spell_id": "holy_judgment_halo", "attack": "holy_judgment_halo_attack", "attack_frames": 11, "hit": "holy_judgment_halo_hit", "hit_frames": 11},
	{"spell_id": "holy_sanctuary_of_reversal", "attack": "holy_sanctuary_of_reversal_attack", "attack_frames": 4, "hit": "holy_sanctuary_of_reversal_hit", "hit_frames": 4},
	{"spell_id": "ice_storm", "attack": "ice_storm_attack", "attack_frames": 4, "hit": "ice_storm_hit", "hit_frames": 4},
	{"spell_id": "ice_ice_wall", "attack": "ice_ice_wall_attack", "attack_frames": 12, "hit": "ice_ice_wall_hit", "hit_frames": 7},
	{"spell_id": "ice_absolute_freeze", "attack": "ice_absolute_freeze_attack", "attack_frames": 4, "hit": "ice_absolute_freeze_hit", "hit_frames": 4},
	{"spell_id": "holy_radiant_burst", "attack": "holy_radiant_burst_attack", "attack_frames": 8, "hit": "holy_radiant_burst_hit", "hit_frames": 8},
	{"spell_id": "ice_frost_needle", "attack": "ice_frost_needle_attack", "attack_frames": 3, "hit": "ice_frost_needle_hit", "hit_frames": 8},
	{"spell_id": "ice_spear", "attack": "ice_spear_attack", "attack_frames": 6, "hit": "ice_spear_hit", "hit_frames": 8},
	{"spell_id": "lightning_thunder_arrow", "attack": "lightning_thunder_arrow_attack", "attack_frames": 6, "hit": "lightning_thunder_arrow_hit", "hit_frames": 8},
	{"spell_id": "lightning_bolt", "attack": "lightning_bolt_attack", "attack_frames": 6, "hit": "lightning_bolt_hit", "hit_frames": 8},
	{"spell_id": "plant_vine_snare", "attack": "plant_vine_snare_attack", "attack_frames": 4, "hit": "plant_vine_snare_hit", "hit_frames": 4},
	{"spell_id": "plant_world_root", "attack": "plant_world_root_attack", "attack_frames": 4, "hit": "plant_world_root_hit", "hit_frames": 4},
	{"spell_id": "plant_worldroot_bastion", "attack": "plant_worldroot_bastion_attack", "attack_frames": 4, "hit": "plant_worldroot_bastion_hit", "hit_frames": 4},
	{"spell_id": "plant_genesis_arbor", "attack": "plant_genesis_arbor_attack", "attack_frames": 4, "hit": "plant_genesis_arbor_hit", "hit_frames": 4},
	{"spell_id": "water_aqua_bullet", "attack": "water_aqua_bullet_attack", "attack_frames": 8, "hit": "water_aqua_bullet_hit", "hit_frames": 15},
	{"spell_id": "water_aqua_spear", "attack": "water_aqua_spear_attack", "attack_frames": 6, "hit": "water_aqua_spear_hit", "hit_frames": 6},
	{"spell_id": "water_aqua_geyser", "attack": "water_aqua_geyser_attack", "attack_frames": 4, "hit": "water_aqua_geyser_hit", "hit_frames": 20},
	{"spell_id": "water_wave", "attack": "water_wave_attack", "attack_frames": 6, "hit": "water_wave_hit", "hit_frames": 6},
	{"spell_id": "water_tsunami", "attack": "water_tsunami_attack", "attack_frames": 6, "hit": "water_tsunami_hit", "hit_frames": 6},
	{"spell_id": "water_ocean_collapse", "attack": "water_ocean_collapse_attack", "attack_frames": 6, "hit": "water_ocean_collapse_hit", "hit_frames": 6},
	{"spell_id": "water_tidal_ring", "attack": "water_tidal_ring_attack", "attack_frames": 11, "hit": "water_tidal_ring_hit", "hit_frames": 19},
	{"spell_id": "wind_gale_cutter", "attack": "wind_gale_cutter_attack", "attack_frames": 2, "hit": "wind_gale_cutter_hit", "hit_frames": 2},
	{"spell_id": "wind_storm", "attack": "wind_storm_attack", "attack_frames": 6, "hit": "wind_storm_hit", "hit_frames": 8},
	{"spell_id": "wind_heavenly_storm", "attack": "wind_heavenly_storm_attack", "attack_frames": 6, "hit": "wind_heavenly_storm_hit", "hit_frames": 8},
	{"spell_id": "wind_cyclone_prison", "attack": "wind_cyclone_prison_attack", "attack_frames": 12, "hit": "wind_cyclone_prison_hit", "hit_frames": 9},
	{"spell_id": "dark_shadow_bind", "attack": "dark_shadow_bind_attack", "attack_frames": 4, "hit": "dark_shadow_bind_hit", "hit_frames": 4},
	{"spell_id": "earth_stone_spire", "attack": "earth_stone_spire_attack", "attack_frames": 7, "hit": "earth_stone_spire_hit", "hit_frames": 6},
	{"spell_id": "earth_stone_rampart", "attack": "earth_stone_rampart_attack", "attack_frames": 9, "hit": "earth_stone_rampart_hit", "hit_frames": 9},
	{"spell_id": "earth_tremor", "attack": "earth_tremor_attack", "attack_frames": 12, "hit": "earth_tremor_hit", "hit_frames": 7},
	{"spell_id": "earth_gaia_break", "attack": "earth_gaia_break_attack", "attack_frames": 6, "hit": "earth_gaia_break_hit", "hit_frames": 6},
	{"spell_id": "earth_continental_crush", "attack": "earth_continental_crush_attack", "attack_frames": 6, "hit": "earth_continental_crush_hit", "hit_frames": 6},
	{"spell_id": "earth_world_end_break", "attack": "earth_world_end_break_attack", "attack_frames": 6, "hit": "earth_world_end_break_hit", "hit_frames": 6},
	{"spell_id": "dark_void_bolt", "attack": "dark_void_bolt_attack", "attack_frames": 8, "hit": "dark_void_bolt_hit", "hit_frames": 8}
]
const ENEMY_ARCHETYPE_CASES := [
	{"type": "brute", "label": "melee"},
	{"type": "bomber", "label": "ranged"},
	{"type": "leaper", "label": "pressure"},
	{"type": "elite", "label": "elite"}
]
const FALLBACK_PROJECTILE_RUNTIME_CASES := [
	{"spell_id": "wind_arrow", "school": "wind", "attack": "wind_arrow_attack", "hit": "wind_arrow_hit", "visual_frames": 4},
	{"spell_id": "wind_gust_bolt", "school": "wind", "attack": "wind_gust_bolt_attack", "hit": "wind_gust_bolt_hit", "visual_frames": 4},
	{"spell_id": "earth_stone_shot", "school": "earth", "attack": "earth_stone_shot_attack", "hit": "earth_stone_shot_hit", "visual_frames": 6},
	{"spell_id": "earth_rock_spear", "school": "earth", "attack": "earth_rock_spear_attack", "hit": "earth_rock_spear_hit", "visual_frames": 6},
	{"spell_id": "fire_flame_bullet", "school": "fire", "attack": "fire_flame_bullet_attack", "hit": "fire_flame_bullet_hit", "visual_frames": 10},
	{"spell_id": "holy_halo_touch", "school": "holy", "attack": "holy_halo_touch_attack", "hit": "holy_halo_touch_hit", "visual_frames": 8},
	{"spell_id": "water_aqua_spear", "school": "water", "attack": "water_aqua_spear_attack", "hit": "water_aqua_spear_hit", "visual_frames": 8},
	{"spell_id": "ice_spear", "school": "ice", "attack": "ice_spear_attack", "hit": "ice_spear_hit", "visual_frames": 6},
	{"spell_id": "lightning_thunder_arrow", "school": "lightning", "attack": "lightning_thunder_arrow_attack", "hit": "lightning_thunder_arrow_hit", "visual_frames": 6}
]
const ZERO_COOLDOWN_ACTIVE_RUNTIME_SPELLS := [
	"arcane_force_pulse",
	"fire_bolt",
	"water_aqua_bullet",
	"wind_arrow",
	"earth_stone_shot",
	"holy_halo_touch",
	"fire_flame_bullet",
	"water_aqua_spear",
	"wind_gust_bolt",
	"earth_rock_spear",
	"ice_frost_needle",
	"wind_gale_cutter",
	"fire_flame_arc",
	"water_tidal_ring",
	"water_wave",
	"holy_cure_ray",
	"holy_radiant_burst",
	"volt_spear",
	"lightning_bolt",
	"ice_spear",
	"lightning_thunder_arrow"
]
const MID_CIRCLE_ACTIVE_MULTI_HIT_RUNTIME_SPELLS := [
	"lightning_bolt",
	"ice_spear",
	"lightning_thunder_arrow",
	"fire_inferno_breath",
	"wind_storm",
	"wind_tempest_drive",
	"ice_absolute_freeze",
	"fire_inferno_buster"
]
const HIGH_CIRCLE_ACTIVE_MULTI_HIT_RUNTIME_SPELLS := [
	"fire_meteor_strike",
	"water_tsunami",
	"earth_gaia_break",
	"dark_void_bolt",
	"water_ocean_collapse",
	"wind_heavenly_storm",
	"earth_tremor",
	"earth_continental_crush",
	"earth_world_end_break",
	"fire_apocalypse_flame",
	"fire_solar_cataclysm",
	"ice_absolute_zero",
	"holy_judgment_halo"
]
const MID_CIRCLE_PERSISTENT_MULTI_HIT_SKILLS := [
	"dark_grave_echo",
	"fire_flame_storm",
	"ice_storm",
	"earth_fortress",
	"plant_worldroot_bastion"
]
const HIGH_CIRCLE_PERSISTENT_MULTI_HIT_SKILLS := [
	"fire_inferno_sigil",
	"wind_cyclone_prison",
	"fire_hellfire_field",
	"wind_storm_zone",
	"plant_world_root",
	"ice_glacial_dominion",
	"lightning_tempest_crown",
	"wind_sky_dominion",
	"plant_genesis_arbor",
	"dark_soul_dominion"
]
const CANONICAL_RUNTIME_PROXY_CASES := [
	{"canonical": "holy_healing_pulse", "runtime": "holy_radiant_burst"},
	{"canonical": "earth_quake_break", "runtime": "earth_tremor"},
	{"canonical": "dark_abyss_gate", "runtime": "dark_void_bolt"},
	{"canonical": "lightning_thunder_lance", "runtime": "volt_spear"},
	{"canonical": "wind_cutter", "runtime": "wind_gale_cutter"},
	{"canonical": "plant_root_bind", "runtime": "plant_vine_snare"}
]

class DummyProjectileTarget extends Node2D:
	var received_hits: Array = []

	func receive_hit(p_damage: int, hit_position: Vector2, p_knockback: float, p_school: String, p_utility_effects: Array = []) -> void:
		received_hits.append({
			"damage": p_damage,
			"position": hit_position,
			"knockback": p_knockback,
			"school": p_school,
			"utility_effects": p_utility_effects.duplicate(true)
		})

func before_each() -> void:
	GameState.health = GameState.max_health
	GameState.reset_progress_for_tests()


func after_each() -> void:
	Engine.time_scale = 1.0


func test_world_effect_visual_respects_ui_effect_opacity_setting() -> void:
	UiState.set_effect_opacity(0.35, false)
	var projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var sprite := projectile._create_world_effect_visual("fire_bolt_attack") as AnimatedSprite2D
	assert_not_null(sprite, "world effect visual should still build while effect opacity is reduced")
	assert_almost_eq(
		sprite.modulate.a,
		0.35,
		0.001,
		"world effect visuals must inherit the current effect opacity multiplier"
	)
	sprite.free()

func _assert_split_effect_visual_uses_cropped_single_tile(
	projectile: Area2D, effect_id: String, expected_frame_count: int = 8
) -> void:
	var sprite := projectile._create_world_effect_visual(effect_id) as AnimatedSprite2D
	assert_true(sprite != null, "%s visual must resolve from the shared world-effect registry" % effect_id)
	assert_eq(
		sprite.sprite_frames.get_frame_count("fly"),
		expected_frame_count,
		"%s must keep its authored split-effect frame count" % effect_id
	)
	var first_frame := sprite.sprite_frames.get_frame_texture("fly", 0)
	assert_eq(first_frame.get_width(), 64, "%s frame width must stay on the cropped 64px tile, not the full preview sheet" % effect_id)
	assert_eq(first_frame.get_height(), 64, "%s frame height must stay on the cropped 64px tile, not the full preview sheet" % effect_id)
	sprite.free()

func _spawn_enemy_for_spell_coverage(root: Node2D, enemy_type: String) -> CharacterBody2D:
	var player_target := Node2D.new()
	root.add_child(player_target)
	player_target.global_position = Vector2(420.0, 0.0)
	var enemy := ENEMY_SCRIPT.new()
	enemy.configure({"type": enemy_type, "position": Vector2.ZERO}, player_target)
	root.add_child(enemy)
	return enemy

func _spawn_projectile_for_spell_coverage(root: Node2D, config: Dictionary) -> Area2D:
	var projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup(config)
	root.add_child(projectile)
	return projectile

func _advance_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame

func _advance_physics_frames(frame_count: int) -> void:
	for _i in range(frame_count):
		await get_tree().physics_frame

func _force_status_effect_rolls(payload: Dictionary, forced_roll: float = 0.0) -> Dictionary:
	var adjusted: Dictionary = payload.duplicate(true)
	var adjusted_effects: Array = []
	for effect in adjusted.get("utility_effects", []):
		var effect_data: Dictionary = effect.duplicate(true)
		effect_data["debug_roll"] = forced_roll
		adjusted_effects.append(effect_data)
	adjusted["utility_effects"] = adjusted_effects
	return adjusted

func _find_effect_sprite(root: Node2D, effect_id: String, effect_stage: String) -> AnimatedSprite2D:
	for child in root.get_children():
		var sprite := child as AnimatedSprite2D
		if sprite == null:
			continue
		if str(sprite.get_meta("effect_id", "")) == effect_id and str(sprite.get_meta("effect_stage", "")) == effect_stage:
			return sprite
	return null


func _count_effect_sprites(root: Node2D, effect_id: String, effect_stage: String) -> int:
	var count := 0
	for child in root.get_children():
		var sprite := child as AnimatedSprite2D
		if sprite == null:
			continue
		if str(sprite.get_meta("effect_id", "")) == effect_id and str(sprite.get_meta("effect_stage", "")) == effect_stage:
			count += 1
	return count


func _get_ground_telegraph(projectile: Area2D) -> Node2D:
	return projectile.get_node_or_null("GroundTelegraph") as Node2D


func _get_ground_telegraph_startup_ring(projectile: Area2D) -> Line2D:
	var telegraph := _get_ground_telegraph(projectile)
	if telegraph == null:
		return null
	return telegraph.get_node_or_null("StartupRing") as Line2D


func _get_terminal_flash(projectile: Area2D) -> Node2D:
	return projectile.get_node_or_null("TerminalFlash") as Node2D


func _get_terminal_flash_outline(projectile: Area2D) -> Line2D:
	var flash := _get_terminal_flash(projectile)
	if flash == null:
		return null
	return flash.get_node_or_null("Outline") as Line2D


func _get_player_buff_overlay_sprite(player: CharacterBody2D) -> AnimatedSprite2D:
	var layer := player.get_node_or_null("BuffVisualLayer") as Node2D
	if layer == null:
		return null
	return layer.get_node_or_null("BuffOverlaySprite") as AnimatedSprite2D

func _get_player_toggle_overlay_sprite(player: CharacterBody2D) -> AnimatedSprite2D:
	var layer := player.get_node_or_null("ToggleVisualLayer") as Node2D
	if layer == null:
		return null
	return layer.get_node_or_null("ToggleOverlaySprite") as AnimatedSprite2D

func _get_slot_action(manager, slot_index: int) -> String:
	var bindings: Array = manager.get_slot_bindings()
	if slot_index < 0 or slot_index >= bindings.size():
		return ""
	return str(bindings[slot_index].get("action", ""))

func _assert_numeric_payload_field_matches(payload: Dictionary, expected: Dictionary, field: String, message: String) -> void:
	assert_almost_eq(
		float(payload.get(field, 0.0)),
		float(expected.get(field, 0.0)),
		0.0001,
		message
	)

func _split_total_damage_for_test(total_damage: int, hit_count: int) -> Array[int]:
	var safe_hit_count: int = maxi(hit_count, 1)
	var split: Array[int] = []
	var base_damage := int(total_damage / safe_hit_count)
	var remainder := int(total_damage % safe_hit_count)
	for hit_index in range(safe_hit_count):
		split.append(base_damage + (1 if hit_index < remainder else 0))
	return split

func _wait_for_multi_hit_sequence_for_test(runtime: Dictionary, extra_buffer: float = 0.08) -> void:
	var hit_count := maxi(1, int(runtime.get("multi_hit_count", 1)))
	var wait_time := maxf(float(runtime.get("hit_interval", 0.0)), 0.0) * float(hit_count - 1) + extra_buffer
	await get_tree().create_timer(wait_time).timeout

func _count_tick_hits_for_test(interval: float, window: float = 3.0) -> int:
	var safe_interval: float = maxf(interval, 0.001)
	var safe_window: float = maxf(window, safe_interval)
	return 1 + int(floor(maxf(safe_window - 0.0001, 0.0) / safe_interval))

func _assert_active_lead_payload_matches_runtime(payload: Dictionary, runtime: Dictionary, label: String) -> void:
	var hit_count: int = maxi(1, int(runtime.get("multi_hit_count", 1)))
	assert_eq(
		int(payload.get("damage", 0)),
		int(runtime.get("damage", 0)),
		"%s payload must keep authored total damage before on-hit split resolution" % label
	)
	assert_eq(
		int(payload.get("total_damage", 0)),
		int(runtime.get("damage", 0)),
		"%s payload must preserve runtime total damage metadata" % label
	)
	assert_eq(
		int(payload.get("multi_hit_total", 0)),
		hit_count,
		"%s payload must expose the runtime multi-hit count" % label
	)

func test_spell_manager_starts_cooldown_after_cast() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("wind_storm"))
	assert_gt(manager.get_cooldown("wind_storm"), 0.0)
	assert_false(manager.attempt_cast("wind_storm"))
	manager.tick(5.0)
	assert_true(manager.attempt_cast("wind_storm"))

func test_spell_manager_respects_dead_player_lock() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	player.debug_mark_dead()
	assert_false(manager.attempt_cast("volt_spear"))

func test_spell_manager_can_activate_buff_slot_and_report_it() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("holy_mana_veil"))
	assert_eq(GameState.active_buffs.size(), 1)
	assert_string_contains(manager.get_hotbar_summary(), "Z 마나 베일")


func test_holy_mana_veil_activation_spawns_guard_activation_and_overlay_visuals() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("holy_mana_veil"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "holy_guard_activation", "buff_activation")
	assert_true(activation != null, "holy_mana_veil must spawn a one-shot holy guard activation visual")
	var overlay := _get_player_buff_overlay_sprite(player)
	assert_true(overlay != null, "holy_mana_veil must create a player-following guard overlay visual")
	assert_eq(str(overlay.get_meta("effect_id", "")), "holy_guard_overlay")
	assert_eq(str(overlay.get_meta("skill_id", "")), "holy_mana_veil")
	GameState.active_buffs.clear()
	player._update_visual()
	await _advance_frames(2)
	assert_true(
		_get_player_buff_overlay_sprite(player) == null,
		"guard overlay must be removed when the holy_mana_veil buff is no longer active"
	)


func test_holy_mana_veil_cast_syncs_base_guard_buff_runtime_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var runtime := GameState.get_buff_runtime("holy_mana_veil")
	assert_false(runtime.is_empty(), "holy_mana_veil buff runtime must build from the central helper")
	assert_true(manager.attempt_cast("holy_mana_veil"))
	assert_eq(GameState.active_buffs.size(), 1, "holy_mana_veil cast must append exactly one active guard buff")
	var active_buff: Dictionary = GameState.active_buffs[0]
	assert_eq(str(active_buff.get("skill_id", "")), "holy_mana_veil")
	assert_almost_eq(
		float(active_buff.get("remaining", 0.0)),
		float(runtime.get("duration", 0.0)),
		0.0001,
		"holy_mana_veil cast must use the central buff runtime duration contract"
	)
	assert_almost_eq(
		manager.get_cooldown("holy_mana_veil"),
		float(runtime.get("cooldown", 0.0)),
		0.0001,
		"holy_mana_veil cast must sync spell manager cooldown from the central buff runtime contract"
	)
	assert_gt(
		GameState.get_poise_bonus(),
		0.0,
		"holy_mana_veil cast must expose its authored poise bonus through the active buff runtime"
	)


func test_holy_crystal_aegis_uses_shared_guard_overlay_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("holy_crystal_aegis"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "holy_guard_activation", "buff_activation")
	assert_true(activation != null, "holy_crystal_aegis must reuse the holy guard activation visual family")
	var overlay := _get_player_buff_overlay_sprite(player)
	assert_true(overlay != null, "holy_crystal_aegis must create a persistent guard overlay")
	assert_eq(str(overlay.get_meta("effect_id", "")), "holy_guard_overlay")
	assert_eq(str(overlay.get_meta("skill_id", "")), "holy_crystal_aegis")


func test_holy_crystal_aegis_cast_syncs_guard_buff_runtime_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var runtime := GameState.get_buff_runtime("holy_crystal_aegis")
	assert_false(runtime.is_empty(), "holy_crystal_aegis buff runtime must build from the central helper")
	assert_true(manager.attempt_cast("holy_crystal_aegis"))
	assert_eq(GameState.active_buffs.size(), 1, "holy_crystal_aegis cast must append exactly one active guard buff")
	var active_buff: Dictionary = GameState.active_buffs[0]
	assert_eq(str(active_buff.get("skill_id", "")), "holy_crystal_aegis")
	assert_almost_eq(
		float(active_buff.get("remaining", 0.0)),
		float(runtime.get("duration", 0.0)),
		0.0001,
		"holy_crystal_aegis cast must use the central buff runtime duration contract"
	)
	assert_almost_eq(
		manager.get_cooldown("holy_crystal_aegis"),
		float(runtime.get("cooldown", 0.0)),
		0.0001,
		"holy_crystal_aegis cast must sync spell manager cooldown from the central buff runtime contract"
	)
	assert_eq(
		GameState.get_super_armor_charges(),
		1,
		"holy_crystal_aegis cast must expose its authored guard charge through the active buff runtime"
	)

func test_holy_dawn_oath_uses_dedicated_guard_visual_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("holy_dawn_oath"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "holy_dawn_oath_activation", "buff_activation")
	assert_true(activation != null, "holy_dawn_oath must spawn a dedicated final-guard activation visual when cast")
	var overlay := _get_player_buff_overlay_sprite(player)
	assert_true(overlay != null, "holy_dawn_oath must create a persistent dedicated final-guard overlay")
	assert_eq(str(overlay.get_meta("effect_id", "")), "holy_dawn_oath_overlay")
	assert_eq(str(overlay.get_meta("skill_id", "")), "holy_dawn_oath")


func test_holy_dawn_oath_cast_syncs_final_guard_runtime_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var runtime := GameState.get_buff_runtime("holy_dawn_oath")
	assert_false(runtime.is_empty(), "holy_dawn_oath buff runtime must build from the central helper")
	assert_true(manager.attempt_cast("holy_dawn_oath"))
	assert_eq(GameState.active_buffs.size(), 1, "holy_dawn_oath cast must append exactly one active final guard buff")
	var active_buff: Dictionary = GameState.active_buffs[0]
	assert_eq(str(active_buff.get("skill_id", "")), "holy_dawn_oath")
	assert_almost_eq(
		float(active_buff.get("remaining", 0.0)),
		float(runtime.get("duration", 0.0)),
		0.0001,
		"holy_dawn_oath cast must use the central buff runtime duration contract"
	)
	assert_almost_eq(
		manager.get_cooldown("holy_dawn_oath"),
		float(runtime.get("cooldown", 0.0)),
		0.0001,
		"holy_dawn_oath cast must sync spell manager cooldown from the central buff runtime contract"
	)
	assert_lt(
		GameState.get_damage_taken_multiplier(),
		0.6,
		"holy_dawn_oath cast must expose its damage-reduction-focused final guard runtime"
	)
	assert_gte(
		GameState.get_super_armor_charges(),
		2,
		"holy_dawn_oath cast must expose its authored super-armor charge floor through the active buff runtime"
	)

func test_holy_dawn_oath_overlay_priority_supersedes_crystal_aegis() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("holy_crystal_aegis"))
	await _advance_frames(2)
	var first_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(first_overlay != null, "holy_crystal_aegis must establish the initial guard overlay")
	assert_eq(str(first_overlay.get_meta("skill_id", "")), "holy_crystal_aegis")
	assert_true(manager.attempt_cast("holy_dawn_oath"))
	await _advance_frames(2)
	var promoted_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(promoted_overlay != null, "holy_dawn_oath must keep a promoted guard overlay active")
	assert_eq(str(promoted_overlay.get_meta("skill_id", "")), "holy_dawn_oath")
	GameState.active_buffs = GameState.active_buffs.filter(
		func(buff: Dictionary) -> bool:
			return str(buff.get("skill_id", "")) != "holy_dawn_oath"
	)
	player._update_visual()
	await _advance_frames(2)
	var fallback_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(fallback_overlay != null, "holy_crystal_aegis overlay must return when holy_dawn_oath expires first")
	assert_eq(str(fallback_overlay.get_meta("skill_id", "")), "holy_crystal_aegis")

func test_dark_throne_of_ash_uses_dedicated_ritual_overlay_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var activation_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("dark_throne_activation", {})
	var overlay_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("dark_throne_overlay", {})
	assert_eq(
		str(activation_spec.get("dir_path", "")),
		"res://assets/effects/dark_throne_activation/",
		"dark_throne_of_ash must read activation frames from a dedicated ritual family path"
	)
	assert_eq(
		str(overlay_spec.get("dir_path", "")),
		"res://assets/effects/dark_throne_overlay/",
		"dark_throne_of_ash must read overlay frames from a dedicated ritual family path"
	)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("dark_throne_of_ash"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "dark_throne_activation", "buff_activation")
	assert_true(activation != null, "dark_throne_of_ash must spawn a ritual activation visual when cast")
	var overlay := _get_player_buff_overlay_sprite(player)
	assert_true(overlay != null, "dark_throne_of_ash must create a persistent ritual overlay")
	assert_eq(str(overlay.get_meta("effect_id", "")), "dark_throne_overlay")
	assert_eq(str(overlay.get_meta("skill_id", "")), "dark_throne_of_ash")

func test_dark_throne_of_ash_overlay_priority_supersedes_holy_dawn_oath() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("holy_dawn_oath"))
	await _advance_frames(2)
	var first_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(first_overlay != null, "holy_dawn_oath must establish the initial guard overlay before ritual cast")
	assert_eq(str(first_overlay.get_meta("skill_id", "")), "holy_dawn_oath")
	assert_true(manager.attempt_cast("dark_throne_of_ash"))
	await _advance_frames(4)
	var promoted_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(promoted_overlay != null, "dark_throne_of_ash must promote its ritual overlay above holy guard overlays")
	assert_eq(str(promoted_overlay.get_meta("skill_id", "")), "dark_throne_of_ash")
	GameState.active_buffs = GameState.active_buffs.filter(
		func(buff: Dictionary) -> bool:
			return str(buff.get("skill_id", "")) != "dark_throne_of_ash"
	)
	player._update_visual()
	await _advance_frames(4)
	var fallback_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(fallback_overlay != null, "holy_dawn_oath overlay must return when dark_throne_of_ash expires first")
	assert_eq(str(fallback_overlay.get_meta("skill_id", "")), "holy_dawn_oath")

func test_lightning_conductive_surge_uses_dedicated_buff_overlay_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var activation_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("conductive_surge_activation", {})
	var overlay_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("conductive_surge_overlay", {})
	assert_eq(
		str(activation_spec.get("dir_path", "")),
		"res://assets/effects/conductive_surge_activation/",
		"lightning_conductive_surge must read activation frames from a dedicated buff family path"
	)
	assert_eq(
		str(overlay_spec.get("dir_path", "")),
		"res://assets/effects/conductive_surge_overlay/",
		"lightning_conductive_surge must read overlay frames from a dedicated buff family path"
	)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("lightning_conductive_surge"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "conductive_surge_activation", "buff_activation")
	assert_true(activation != null, "lightning_conductive_surge must spawn a lightning buff activation visual when cast")
	var overlay := _get_player_buff_overlay_sprite(player)
	assert_true(overlay != null, "lightning_conductive_surge must create a persistent buff overlay when active alone")
	assert_eq(str(overlay.get_meta("effect_id", "")), "conductive_surge_overlay")
	assert_eq(str(overlay.get_meta("skill_id", "")), "lightning_conductive_surge")

func test_lightning_conductive_surge_overlay_does_not_override_holy_guard_priority() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("lightning_conductive_surge"))
	await _advance_frames(2)
	var first_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(first_overlay != null, "lightning_conductive_surge must establish its overlay before a guard buff is cast")
	assert_eq(str(first_overlay.get_meta("skill_id", "")), "lightning_conductive_surge")
	assert_true(manager.attempt_cast("holy_dawn_oath"))
	await _advance_frames(4)
	var promoted_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(promoted_overlay != null, "holy_dawn_oath must still take overlay priority over conductive surge")
	assert_eq(str(promoted_overlay.get_meta("skill_id", "")), "holy_dawn_oath")

func test_fire_pyre_heart_uses_dedicated_buff_overlay_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var activation_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("pyre_heart_activation", {})
	var overlay_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("pyre_heart_overlay", {})
	assert_eq(
		str(activation_spec.get("dir_path", "")),
		"res://assets/effects/pyre_heart_activation/",
		"fire_pyre_heart must read activation frames from a dedicated pyre-heart family path"
	)
	assert_eq(
		str(overlay_spec.get("dir_path", "")),
		"res://assets/effects/pyre_heart_overlay/",
		"fire_pyre_heart must read overlay frames from a dedicated pyre-heart family path"
	)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("fire_pyre_heart"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "pyre_heart_activation", "buff_activation")
	assert_true(activation != null, "fire_pyre_heart must spawn a fire burst activation visual when cast")
	var overlay := _get_player_buff_overlay_sprite(player)
	assert_true(overlay != null, "fire_pyre_heart must create a persistent offensive overlay when active alone")
	assert_eq(str(overlay.get_meta("effect_id", "")), "pyre_heart_overlay")
	assert_eq(str(overlay.get_meta("skill_id", "")), "fire_pyre_heart")

func test_fire_pyre_heart_overlay_stays_below_lightning_priority() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.set_admin_ignore_buff_slot_limit(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("fire_pyre_heart"))
	await _advance_frames(2)
	var first_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(first_overlay != null, "fire_pyre_heart must establish its overlay before lightning surge is cast")
	assert_eq(str(first_overlay.get_meta("skill_id", "")), "fire_pyre_heart")
	assert_true(manager.attempt_cast("lightning_conductive_surge"))
	await _advance_frames(4)
	var promoted_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(promoted_overlay != null, "lightning_conductive_surge must override fire_pyre_heart overlay priority")
	assert_eq(str(promoted_overlay.get_meta("skill_id", "")), "lightning_conductive_surge")

func test_ice_frostblood_ward_uses_dedicated_buff_overlay_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var activation_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("frostblood_ward_activation", {})
	var overlay_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("frostblood_ward_overlay", {})
	assert_eq(
		str(activation_spec.get("dir_path", "")),
		"res://assets/effects/frostblood_ward_activation/",
		"ice_frostblood_ward must read activation frames from a dedicated frostblood family path"
	)
	assert_eq(
		str(overlay_spec.get("dir_path", "")),
		"res://assets/effects/frostblood_ward_overlay/",
		"ice_frostblood_ward must read overlay frames from a dedicated frostblood family path"
	)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("ice_frostblood_ward"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "frostblood_ward_activation", "buff_activation")
	assert_true(activation != null, "ice_frostblood_ward must spawn a frost ward activation visual when cast")
	var overlay := _get_player_buff_overlay_sprite(player)
	assert_true(overlay != null, "ice_frostblood_ward must create a persistent defensive overlay when active alone")
	assert_eq(str(overlay.get_meta("effect_id", "")), "frostblood_ward_overlay")
	assert_eq(str(overlay.get_meta("skill_id", "")), "ice_frostblood_ward")

func test_ice_frostblood_ward_overlay_stays_below_holy_guard_priority() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.set_admin_ignore_buff_slot_limit(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("ice_frostblood_ward"))
	await _advance_frames(2)
	var first_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(first_overlay != null, "ice_frostblood_ward must establish its overlay before holy guard is cast")
	assert_eq(str(first_overlay.get_meta("skill_id", "")), "ice_frostblood_ward")
	assert_true(manager.attempt_cast("holy_mana_veil"))
	await _advance_frames(4)
	var promoted_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(promoted_overlay != null, "holy_mana_veil must override ice_frostblood_ward overlay priority")
	assert_eq(str(promoted_overlay.get_meta("skill_id", "")), "holy_mana_veil")

func test_arcane_astral_compression_uses_dedicated_buff_overlay_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var activation_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("astral_compression_activation", {})
	var overlay_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("astral_compression_overlay", {})
	assert_eq(
		str(activation_spec.get("dir_path", "")),
		"res://assets/effects/astral_compression_activation/",
		"arcane_astral_compression must read activation frames from a dedicated astral family path"
	)
	assert_eq(
		str(overlay_spec.get("dir_path", "")),
		"res://assets/effects/astral_compression_overlay/",
		"arcane_astral_compression must read overlay frames from a dedicated astral family path"
	)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("arcane_astral_compression"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "astral_compression_activation", "buff_activation")
	assert_true(activation != null, "arcane_astral_compression must spawn an arcane compression activation visual when cast")
	var overlay := _get_player_buff_overlay_sprite(player)
	assert_true(overlay != null, "arcane_astral_compression must create a persistent arcane overlay when active alone")
	assert_eq(str(overlay.get_meta("effect_id", "")), "astral_compression_overlay")
	assert_eq(str(overlay.get_meta("skill_id", "")), "arcane_astral_compression")

func test_arcane_world_hourglass_overlay_supersedes_astral_compression_but_not_holy_guard() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.set_admin_ignore_buff_slot_limit(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var activation_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("world_hourglass_activation", {})
	var overlay_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("world_hourglass_overlay", {})
	assert_eq(
		str(activation_spec.get("dir_path", "")),
		"res://assets/effects/world_hourglass_activation/",
		"arcane_world_hourglass must read activation frames from a dedicated hourglass family path"
	)
	assert_eq(
		str(overlay_spec.get("dir_path", "")),
		"res://assets/effects/world_hourglass_overlay/",
		"arcane_world_hourglass must read overlay frames from a dedicated hourglass family path"
	)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("arcane_astral_compression"))
	await _advance_frames(2)
	var first_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(first_overlay != null, "arcane_astral_compression must establish its overlay before hourglass is cast")
	assert_eq(str(first_overlay.get_meta("skill_id", "")), "arcane_astral_compression")
	assert_true(manager.attempt_cast("arcane_world_hourglass"))
	await _advance_frames(4)
	var hourglass_activation := _find_effect_sprite(root, "world_hourglass_activation", "buff_activation")
	assert_true(hourglass_activation != null, "arcane_world_hourglass must spawn a world-hourglass activation visual when cast")
	var hourglass_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(hourglass_overlay != null, "arcane_world_hourglass must override astral compression overlay priority")
	assert_eq(str(hourglass_overlay.get_meta("effect_id", "")), "world_hourglass_overlay")
	assert_eq(str(hourglass_overlay.get_meta("skill_id", "")), "arcane_world_hourglass")
	assert_true(manager.attempt_cast("holy_dawn_oath"))
	await _advance_frames(4)
	var holy_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(holy_overlay != null, "holy_dawn_oath must still override arcane world_hourglass overlay priority")
	assert_eq(str(holy_overlay.get_meta("skill_id", "")), "holy_dawn_oath")

func test_dark_grave_pact_uses_dedicated_buff_overlay_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var activation_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("grave_pact_activation", {})
	var overlay_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("grave_pact_overlay", {})
	assert_eq(
		str(activation_spec.get("dir_path", "")),
		"res://assets/effects/grave_pact_activation/",
		"dark_grave_pact must read activation frames from a dedicated pact family path"
	)
	assert_eq(
		str(overlay_spec.get("dir_path", "")),
		"res://assets/effects/grave_pact_overlay/",
		"dark_grave_pact must read overlay frames from a dedicated pact family path"
	)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("dark_grave_pact"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "grave_pact_activation", "buff_activation")
	assert_true(activation != null, "dark_grave_pact must spawn a grave pact activation visual when cast")
	var overlay := _get_player_buff_overlay_sprite(player)
	assert_true(overlay != null, "dark_grave_pact must create a persistent pact overlay when active alone")
	assert_eq(str(overlay.get_meta("effect_id", "")), "grave_pact_overlay")
	assert_eq(str(overlay.get_meta("skill_id", "")), "dark_grave_pact")

func test_dark_grave_pact_overlay_sits_above_lightning_and_below_holy_guard() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.set_admin_ignore_buff_slot_limit(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("lightning_conductive_surge"))
	await _advance_frames(2)
	var lightning_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(lightning_overlay != null, "lightning_conductive_surge must establish its overlay before grave pact is cast")
	assert_eq(str(lightning_overlay.get_meta("skill_id", "")), "lightning_conductive_surge")
	assert_true(manager.attempt_cast("dark_grave_pact"))
	await _advance_frames(4)
	var pact_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(pact_overlay != null, "dark_grave_pact must override conductive surge overlay priority")
	assert_eq(str(pact_overlay.get_meta("skill_id", "")), "dark_grave_pact")
	assert_true(manager.attempt_cast("holy_dawn_oath"))
	await _advance_frames(4)
	var holy_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(holy_overlay != null, "holy_dawn_oath must still override dark_grave_pact overlay priority")
	assert_eq(str(holy_overlay.get_meta("skill_id", "")), "holy_dawn_oath")

func test_plant_verdant_overflow_uses_dedicated_buff_overlay_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var activation_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("verdant_overflow_activation", {})
	var overlay_spec: Dictionary = player.BUFF_VISUAL_SPECS.get("verdant_overflow_overlay", {})
	assert_eq(
		str(activation_spec.get("dir_path", "")),
		"res://assets/effects/verdant_overflow_activation/",
		"plant_verdant_overflow must read activation frames from a dedicated verdant family path"
	)
	assert_eq(
		str(overlay_spec.get("dir_path", "")),
		"res://assets/effects/verdant_overflow_overlay/",
		"plant_verdant_overflow must read overlay frames from a dedicated verdant family path"
	)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("plant_verdant_overflow"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "verdant_overflow_activation", "buff_activation")
	assert_true(activation != null, "plant_verdant_overflow must spawn a verdant buff activation visual when cast")
	var overlay := _get_player_buff_overlay_sprite(player)
	assert_true(overlay != null, "plant_verdant_overflow must create a persistent verdant overlay when active alone")
	assert_eq(str(overlay.get_meta("effect_id", "")), "verdant_overflow_overlay")
	assert_eq(str(overlay.get_meta("skill_id", "")), "plant_verdant_overflow")

func test_plant_verdant_overflow_overlay_stays_below_lightning_and_holy_priorities() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.set_admin_ignore_buff_slot_limit(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("plant_verdant_overflow"))
	await _advance_frames(2)
	var first_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(first_overlay != null, "plant_verdant_overflow must establish its overlay before a higher-priority buff is cast")
	assert_eq(str(first_overlay.get_meta("skill_id", "")), "plant_verdant_overflow")
	assert_true(manager.attempt_cast("lightning_conductive_surge"))
	await _advance_frames(4)
	var lightning_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(lightning_overlay != null, "lightning_conductive_surge must override verdant_overflow overlay priority")
	assert_eq(str(lightning_overlay.get_meta("skill_id", "")), "lightning_conductive_surge")
	assert_true(manager.attempt_cast("holy_dawn_oath"))
	await _advance_frames(4)
	var holy_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(holy_overlay != null, "holy_dawn_oath must still override verdant_overflow and lightning overlays")
	assert_eq(str(holy_overlay.get_meta("skill_id", "")), "holy_dawn_oath")

func test_wind_tempest_drive_uses_active_activation_family_without_overlay() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("wind_tempest_drive"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "tempest_drive_activation", "active_activation")
	assert_true(activation != null, "wind_tempest_drive must spawn its activation visual when cast as an active skill")
	var overlay := _get_player_buff_overlay_sprite(player)
	assert_true(overlay == null, "wind_tempest_drive must not create a persistent buff overlay once it is a pure active skill")

func test_wind_tempest_drive_cast_does_not_override_existing_lightning_overlay() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.set_admin_ignore_buff_slot_limit(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("lightning_conductive_surge"))
	await _advance_frames(2)
	var lightning_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(lightning_overlay != null, "lightning_conductive_surge must establish its overlay before tempest drive is cast")
	assert_eq(str(lightning_overlay.get_meta("skill_id", "")), "lightning_conductive_surge")
	assert_true(manager.attempt_cast("wind_tempest_drive"))
	await _advance_frames(4)
	var promoted_overlay := _get_player_buff_overlay_sprite(player)
	assert_true(promoted_overlay != null, "Existing buff overlay must remain active when tempest drive is cast as an active skill")
	assert_eq(str(promoted_overlay.get_meta("skill_id", "")), "lightning_conductive_surge")

func test_wind_tempest_drive_cast_opens_overclock_circuit_when_conductive_surge_is_active() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("lightning_conductive_surge"))
	await _advance_frames(2)
	assert_true(manager.attempt_cast("wind_tempest_drive"))
	assert_true(GameState.overclock_circuit_active, "Tempest Drive cast must open Overclock Circuit when Conductive Surge is active")
	assert_true(GameState.get_active_combo_names().has("오버클럭 회로"))

func test_wind_tempest_drive_cast_triggers_forward_mobility_burst() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	player.facing = 1
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var start_x: float = player.global_position.x
	assert_true(manager.attempt_cast("wind_tempest_drive"))
	await _advance_physics_frames(4)
	assert_eq(player.get_debug_state_name(), "Dash", "wind_tempest_drive must push the player into a dash-like movement state on cast")
	assert_gt(player.global_position.x, start_x + 20.0, "wind_tempest_drive must advance the player forward by a readable mid-range distance")
	assert_gt(player.velocity.x, 0.0, "wind_tempest_drive must apply positive forward velocity when facing right")

func test_wind_tempest_drive_cast_syncs_dash_runtime_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.facing = 1
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var runtime := GameState.get_spell_runtime("wind_tempest_drive")
	assert_false(runtime.is_empty(), "wind_tempest_drive runtime must build before cast")
	assert_true(manager.attempt_cast("wind_tempest_drive"))
	assert_eq(player.get_debug_state_name(), "Dash", "wind_tempest_drive must enter dash state from its active runtime contract")
	assert_almost_eq(
		player.buff_mobility_timer,
		float(runtime.get("dash_duration", 0.0)),
		0.0001,
		"wind_tempest_drive cast must use the central runtime dash duration contract"
	)
	assert_almost_eq(
		player.velocity.x,
		float(runtime.get("dash_speed", 0.0)),
		0.0001,
		"wind_tempest_drive cast must use the central runtime dash speed contract"
	)

func test_wind_tempest_drive_cast_emits_active_activation_burst_payload() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(16.0, 6.0)
	player.facing = 1
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("wind_tempest_drive"), "wind_tempest_drive cast must succeed")
	assert_eq(payloads.size(), 1, "wind_tempest_drive must emit a single active activation burst payload")
	assert_eq(str(payloads[0].get("spell_id", "")), "wind_tempest_drive")
	assert_eq(str(payloads[0].get("school", "")), "wind")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "wind_tempest_drive activation burst must use area_burst hitstop")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "wind_tempest_drive_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "wind_tempest_drive_hit")
	assert_eq(float(payloads[0].get("velocity", Vector2.ZERO).length()), 0.0, "wind_tempest_drive activation burst must stay centered on the dash lane")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.1, "wind_tempest_drive activation burst must keep brief but readable duration")
	assert_gt(float(payloads[0].get("size", 0.0)), 90.0, "wind_tempest_drive activation burst must keep a readable frontal control radius")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "slow", "wind_tempest_drive activation burst must carry wind control utility")
	GameState.reset_progress_for_tests()

func test_wind_tempest_drive_active_burst_keeps_dash_state_when_spell_cast_signal_is_live() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	player.facing = 1
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	manager.spell_cast.connect(func(p: Dictionary) -> void: player.call("_on_spell_cast", p))
	var start_x: float = player.global_position.x
	assert_true(manager.attempt_cast("wind_tempest_drive"))
	await _advance_physics_frames(4)
	assert_eq(player.get_debug_state_name(), "Dash", "wind_tempest_drive active burst must keep the player in dash state even when spell_cast is connected")
	assert_gt(player.global_position.x, start_x + 20.0, "wind_tempest_drive active burst must still move the player forward in live cast flow")
	assert_gt(player.cast_lock_timer, 0.0, "wind_tempest_drive active burst must still respect cast feedback timing in live cast flow")

func test_overclock_circuit_live_cast_boosts_next_lightning_active_and_consumes_window() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.set_admin_ignore_buff_slot_limit(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("lightning_conductive_surge"))
	var base_runtime := GameState.get_spell_runtime("volt_spear")
	assert_true(manager.attempt_cast("wind_tempest_drive"))
	assert_true(GameState.overclock_circuit_active, "Tempest Drive must open Overclock Circuit before the next lightning active is cast")
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("volt_spear"))
	assert_eq(payloads.size(), 1, "The boosted lightning consumer cast must still emit a single active payload")
	var payload: Dictionary = payloads[0]
	assert_eq(str(payload.get("spell_id", "")), "volt_spear")
	assert_almost_eq(
		manager.get_cooldown("volt_spear"),
		float(base_runtime.get("cooldown", 0.0)) * GameState.OVERCLOCK_CIRCUIT_AFTERCAST_MULT,
		0.0001,
		"Overclock Circuit must reduce the live lightning active cooldown when the boosted cast is committed"
	)
	assert_eq(
		int(payload.get("pierce", 0)),
		int(base_runtime.get("pierce", 0)) + GameState.OVERCLOCK_CIRCUIT_CHAIN_BONUS,
		"Overclock Circuit must add one more chain to the live lightning active payload"
	)
	assert_almost_eq(
		float(payload.get("speed", 0.0)),
		float(base_runtime.get("speed", 0.0)) * GameState.OVERCLOCK_CIRCUIT_SPEED_MULT,
		0.0001,
		"Overclock Circuit must accelerate the live lightning active runtime before payload emission"
	)
	assert_false(GameState.overclock_circuit_active, "The lightning consumer cast must consume Overclock Circuit immediately after firing")
	assert_eq(GameState.overclock_circuit_timer, 0.0, "Consumed Overclock Circuit must clear its remaining timer")

func test_wind_tempest_drive_active_burst_builds_registered_runtime_visual() -> void:
	var projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 1.0,
		"team": "player",
		"damage": 24,
		"knockback": 220.0,
		"school": "wind",
		"size": 118.0,
		"duration": 0.16,
		"spell_id": "wind_tempest_drive",
		"attack_effect_id": "wind_tempest_drive_attack",
		"hit_effect_id": "wind_tempest_drive_hit",
		"color": "#eaffdf"
	})
	assert_gt(projectile.get_child_count(), 0, "wind_tempest_drive active burst must build a registered runtime visual")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "wind_tempest_drive active burst must use AnimatedSprite2D visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "wind_tempest_drive active burst must keep the fallback wind projectile frame count")

func test_ice_glacial_dominion_uses_frozen_domain_toggle_visual_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "ice_frozen_domain_activation", "toggle_activation")
	assert_true(activation != null, "ice_glacial_dominion must spawn a frozen-domain activation visual when toggled on")
	var overlay := _get_player_toggle_overlay_sprite(player)
	assert_true(overlay != null, "ice_glacial_dominion must create a persistent frozen-domain overlay while active")
	assert_eq(str(overlay.get_meta("effect_id", "")), "ice_frozen_domain_loop")
	assert_eq(str(overlay.get_meta("skill_id", "")), "ice_glacial_dominion")
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	await _advance_frames(2)
	var end_effect := _find_effect_sprite(root, "ice_frozen_domain_end", "toggle_end")
	assert_true(end_effect != null, "ice_glacial_dominion must spawn a frozen-domain end visual when toggled off")
	assert_true(_get_player_toggle_overlay_sprite(player) == null, "frozen-domain overlay must clear once the toggle is off")

func test_lightning_tempest_crown_uses_dedicated_toggle_visual_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var activation_spec: Dictionary = player.TOGGLE_VISUAL_SPECS.get("tempest_crown_activation", {})
	var overlay_spec: Dictionary = player.TOGGLE_VISUAL_SPECS.get("tempest_crown_loop", {})
	var end_spec: Dictionary = player.TOGGLE_VISUAL_SPECS.get("tempest_crown_end", {})
	assert_eq(
		str(activation_spec.get("dir_path", "")),
		"res://assets/effects/tempest_crown_activation/",
		"lightning_tempest_crown must read activation frames from a dedicated chain-lightning family path"
	)
	assert_eq(
		str(overlay_spec.get("dir_path", "")),
		"res://assets/effects/tempest_crown_loop/",
		"lightning_tempest_crown must read overlay frames from a dedicated chain-lightning family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/tempest_crown_end/",
		"lightning_tempest_crown must read end frames from a dedicated chain-lightning family path"
	)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("lightning_tempest_crown"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "tempest_crown_activation", "toggle_activation")
	assert_true(activation != null, "lightning_tempest_crown must spawn a dedicated chain-lightning activation visual when toggled on")
	var overlay := _get_player_toggle_overlay_sprite(player)
	assert_true(overlay != null, "lightning_tempest_crown must create a persistent dedicated chain-lightning overlay while active")
	assert_eq(str(overlay.get_meta("effect_id", "")), "tempest_crown_loop")
	assert_eq(str(overlay.get_meta("skill_id", "")), "lightning_tempest_crown")
	assert_true(manager.attempt_cast("lightning_tempest_crown"))
	await _advance_frames(2)
	var end_effect := _find_effect_sprite(root, "tempest_crown_end", "toggle_end")
	assert_true(end_effect != null, "lightning_tempest_crown must spawn a dedicated chain-lightning end visual when toggled off")
	assert_true(_get_player_toggle_overlay_sprite(player) == null, "tempest_crown overlay must clear once the toggle is off")

func test_earth_fortress_uses_dedicated_toggle_visual_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("earth_fortress"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "earth_fortress_activation", "toggle_activation")
	assert_true(activation != null, "earth_fortress must spawn a dedicated fortress activation visual when toggled on")
	var overlay := _get_player_toggle_overlay_sprite(player)
	assert_true(overlay != null, "earth_fortress must create a persistent dedicated fortress overlay while active")
	assert_eq(str(overlay.get_meta("effect_id", "")), "earth_fortress_loop")
	assert_eq(str(overlay.get_meta("skill_id", "")), "earth_fortress")
	assert_true(manager.attempt_cast("earth_fortress"))
	await _advance_frames(2)
	var end_effect := _find_effect_sprite(root, "earth_fortress_end", "toggle_end")
	assert_true(end_effect != null, "earth_fortress must spawn a dedicated fortress end visual when toggled off")
	assert_true(_get_player_toggle_overlay_sprite(player) == null, "earth_fortress overlay must clear once the toggle is off")

func test_dark_soul_dominion_uses_dedicated_toggle_visual_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var activation_spec: Dictionary = player.TOGGLE_VISUAL_SPECS.get("soul_dominion_activation", {})
	var overlay_spec: Dictionary = player.TOGGLE_VISUAL_SPECS.get("soul_dominion_loop", {})
	var end_spec: Dictionary = player.TOGGLE_VISUAL_SPECS.get("soul_dominion_end", {})
	var aftershock_spec: Dictionary = player.TOGGLE_VISUAL_SPECS.get("soul_dominion_aftershock", {})
	var clear_spec: Dictionary = player.TOGGLE_VISUAL_SPECS.get("soul_dominion_clear", {})
	assert_eq(
		str(activation_spec.get("dir_path", "")),
		"res://assets/effects/soul_dominion_activation/",
		"dark_soul_dominion must read activation frames from a dedicated final-risk family path"
	)
	assert_eq(
		str(overlay_spec.get("dir_path", "")),
		"res://assets/effects/soul_dominion_loop/",
		"dark_soul_dominion must read overlay frames from a dedicated final-risk family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/soul_dominion_end/",
		"dark_soul_dominion must read end frames from a dedicated final-risk family path"
	)
	assert_eq(
		str(aftershock_spec.get("dir_path", "")),
		"res://assets/effects/soul_dominion_aftershock/",
		"dark_soul_dominion must read aftershock frames from a dedicated final-risk family path"
	)
	assert_eq(
		str(clear_spec.get("dir_path", "")),
		"res://assets/effects/soul_dominion_clear/",
		"dark_soul_dominion must read clear frames from a dedicated final-risk family path"
	)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "soul_dominion_activation", "toggle_activation")
	assert_true(activation != null, "dark_soul_dominion must spawn a dedicated final-risk activation visual when toggled on")
	var overlay := _get_player_toggle_overlay_sprite(player)
	assert_true(overlay != null, "dark_soul_dominion must create a persistent dedicated final-risk overlay while active")
	assert_eq(str(overlay.get_meta("effect_id", "")), "soul_dominion_loop")
	assert_eq(str(overlay.get_meta("skill_id", "")), "dark_soul_dominion")
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	await _advance_frames(2)
	var end_effect := _find_effect_sprite(root, "soul_dominion_end", "toggle_end")
	assert_true(end_effect != null, "dark_soul_dominion must spawn a dedicated final-risk end visual when toggled off")
	assert_true(_get_player_toggle_overlay_sprite(player) == null, "soul_dominion overlay must clear once the toggle is off")

func test_dark_grave_echo_uses_dedicated_toggle_visual_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var activation_spec: Dictionary = player.TOGGLE_VISUAL_SPECS.get("grave_echo_activation", {})
	var overlay_spec: Dictionary = player.TOGGLE_VISUAL_SPECS.get("grave_echo_loop", {})
	var end_spec: Dictionary = player.TOGGLE_VISUAL_SPECS.get("grave_echo_end", {})
	assert_eq(
		str(activation_spec.get("dir_path", "")),
		"res://assets/effects/grave_echo_activation/",
		"dark_grave_echo must read activation frames from a dedicated curse family path"
	)
	assert_eq(
		str(overlay_spec.get("dir_path", "")),
		"res://assets/effects/grave_echo_loop/",
		"dark_grave_echo must read overlay frames from a dedicated curse family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/grave_echo_end/",
		"dark_grave_echo must read end frames from a dedicated curse family path"
	)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("dark_grave_echo"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "grave_echo_activation", "toggle_activation")
	assert_true(activation != null, "dark_grave_echo must spawn a dedicated curse-aura activation visual when toggled on")
	var overlay := _get_player_toggle_overlay_sprite(player)
	assert_true(overlay != null, "dark_grave_echo must create a persistent curse aura overlay while active")
	assert_eq(str(overlay.get_meta("effect_id", "")), "grave_echo_loop")
	assert_eq(str(overlay.get_meta("skill_id", "")), "dark_grave_echo")
	assert_true(manager.attempt_cast("dark_grave_echo"))
	await _advance_frames(2)
	var end_effect := _find_effect_sprite(root, "grave_echo_end", "toggle_end")
	assert_true(end_effect != null, "dark_grave_echo must spawn a dedicated curse-aura end visual when toggled off")
	assert_true(_get_player_toggle_overlay_sprite(player) == null, "dark_grave_echo overlay must clear once the toggle is off")

func test_dark_soul_dominion_toggle_off_spawns_single_aftershock_pulse_visual() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	await _advance_frames(2)
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	await _advance_physics_frames(2)
	await _advance_frames(1)
	var aftershock := _find_effect_sprite(root, "soul_dominion_aftershock", "toggle_aftershock")
	assert_true(aftershock != null, "dark_soul_dominion must spawn a dedicated aftershock pulse visual once the toggle collapses")
	assert_eq(str(aftershock.get_meta("skill_id", "")), "dark_soul_dominion")
	assert_eq(str(aftershock.get_meta("visual_signature", "")), "dark_soul_dominion_aftershock")
	assert_eq(str(aftershock.get_meta("visual_stage", "")), "aftershock")
	var end_effect := _find_effect_sprite(root, "soul_dominion_end", "toggle_end")
	assert_true(end_effect != null, "dark_soul_dominion aftershock comparison also needs the normal end visual")
	assert_gt(
		aftershock.scale.x,
		end_effect.scale.x,
		"aftershock pulse should flare larger than the base end visual so the lingering risk window reads separately from the toggle-off beat"
	)
	var initial_count := _count_effect_sprites(root, "soul_dominion_aftershock", "toggle_aftershock")
	assert_eq(initial_count, 1, "dark_soul_dominion aftershock pulse should spawn only once when the aftershock window begins")
	await _advance_physics_frames(12)
	await _advance_frames(1)
	assert_eq(
		_count_effect_sprites(root, "soul_dominion_aftershock", "toggle_aftershock"),
		initial_count,
		"dark_soul_dominion must not keep respawning aftershock pulses every physics frame while the timer is active"
	)


func test_dark_soul_dominion_aftershock_clear_beat_spawns_once_when_risk_fully_ends() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	await _advance_frames(2)
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	await _advance_physics_frames(2)
	await _advance_frames(1)
	var aftershock := _find_effect_sprite(root, "soul_dominion_aftershock", "toggle_aftershock")
	assert_true(aftershock != null, "clear-beat comparison needs the aftershock pulse to exist first")
	GameState.soul_dominion_aftershock_timer = 0.0
	await _advance_physics_frames(2)
	await _advance_frames(1)
	var clear_effect := _find_effect_sprite(root, "soul_dominion_clear", "toggle_clear")
	assert_true(clear_effect != null, "dark_soul_dominion must spawn a dedicated clear beat visual once aftershock fully ends")
	assert_eq(str(clear_effect.get_meta("skill_id", "")), "dark_soul_dominion")
	assert_eq(str(clear_effect.get_meta("visual_signature", "")), "dark_soul_dominion_clear")
	assert_eq(str(clear_effect.get_meta("visual_stage", "")), "clear")
	assert_lt(
		clear_effect.scale.x,
		aftershock.scale.x,
		"clear beat should resolve smaller than the aftershock flare so danger release reads as a closing echo instead of a second threat spike"
	)
	assert_gt(
		clear_effect.modulate.b,
		clear_effect.modulate.r,
		"clear beat should shift toward a cooler release tint instead of reusing the warm aftershock warning color"
	)
	var initial_clear_count := _count_effect_sprites(root, "soul_dominion_clear", "toggle_clear")
	assert_eq(initial_clear_count, 1, "dark_soul_dominion clear beat should spawn only once when aftershock fully clears")
	await _advance_physics_frames(12)
	await _advance_frames(1)
	assert_eq(
		_count_effect_sprites(root, "soul_dominion_clear", "toggle_clear"),
		initial_clear_count,
		"dark_soul_dominion must not keep respawning clear beat visuals every physics frame while safe"
	)


func test_dark_soul_dominion_overlay_priority_supersedes_dark_grave_echo() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("dark_grave_echo"))
	await _advance_frames(2)
	var first_overlay := _get_player_toggle_overlay_sprite(player)
	assert_true(first_overlay != null, "dark_grave_echo must establish its overlay before dark_soul_dominion is cast")
	assert_eq(str(first_overlay.get_meta("skill_id", "")), "dark_grave_echo")
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	await _advance_frames(4)
	var promoted_overlay := _get_player_toggle_overlay_sprite(player)
	assert_true(promoted_overlay != null, "dark_soul_dominion must take toggle overlay priority over dark_grave_echo")
	assert_eq(str(promoted_overlay.get_meta("skill_id", "")), "dark_soul_dominion")
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	await _advance_frames(4)
	var fallback_overlay := _get_player_toggle_overlay_sprite(player)
	assert_true(fallback_overlay != null, "dark_grave_echo overlay must return when dark_soul_dominion ends first")
	assert_eq(str(fallback_overlay.get_meta("skill_id", "")), "dark_grave_echo")

func test_dark_toggle_signature_profiles_make_soul_dominion_heavier_than_grave_echo() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("dark_grave_echo"))
	await _advance_frames(2)
	var grave_activation := _find_effect_sprite(root, "grave_echo_activation", "toggle_activation")
	var grave_overlay := _get_player_toggle_overlay_sprite(player)
	assert_true(
		grave_activation != null and grave_overlay != null,
		"dark_grave_echo baseline comparison needs both activation and overlay visuals"
	)
	assert_eq(str(grave_activation.get_meta("visual_signature", "")), "dark_grave_echo")
	assert_eq(str(grave_overlay.get_meta("visual_signature", "")), "dark_grave_echo")
	assert_eq(str(grave_overlay.get_meta("visual_stage", "")), "overlay")
	var grave_activation_scale := grave_activation.scale.x
	var grave_overlay_scale := grave_overlay.scale.x
	var grave_overlay_color := str(grave_overlay.get_meta("visual_stage_color", ""))
	assert_true(manager.attempt_cast("dark_grave_echo"))
	await _advance_frames(2)
	var grave_end := _find_effect_sprite(root, "grave_echo_end", "toggle_end")
	assert_true(grave_end != null, "dark_grave_echo comparison needs its end visual to exist")
	assert_eq(str(grave_end.get_meta("visual_signature", "")), "dark_grave_echo")
	var grave_end_scale := grave_end.scale.x
	var grave_end_color := str(grave_end.get_meta("visual_stage_color", ""))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	await _advance_frames(2)
	var soul_activation := _find_effect_sprite(root, "soul_dominion_activation", "toggle_activation")
	var soul_overlay := _get_player_toggle_overlay_sprite(player)
	assert_true(
		soul_activation != null and soul_overlay != null,
		"dark_soul_dominion comparison needs both activation and overlay visuals"
	)
	assert_eq(str(soul_activation.get_meta("visual_signature", "")), "dark_soul_dominion")
	assert_eq(str(soul_overlay.get_meta("visual_signature", "")), "dark_soul_dominion")
	assert_eq(str(soul_overlay.get_meta("visual_stage", "")), "overlay")
	assert_lt(
		grave_activation_scale,
		soul_activation.scale.x,
		"soul_dominion activation should spawn larger than grave_echo so the final dark toggle opens with a heavier ritual read"
	)
	assert_lt(
		grave_overlay_scale,
		soul_overlay.scale.x,
		"soul_dominion overlay should sit larger than grave_echo so the late dark aura clearly outranks the mid-tier curse loop"
	)
	assert_true(
		grave_overlay_color != str(soul_overlay.get_meta("visual_stage_color", "")),
		"dark toggle overlays should keep different signature colors so grave_echo and soul_dominion do not collapse into the same violet read"
	)
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	await _advance_frames(2)
	var soul_end := _find_effect_sprite(root, "soul_dominion_end", "toggle_end")
	assert_true(soul_end != null, "dark_soul_dominion comparison needs its end visual to exist")
	assert_eq(str(soul_end.get_meta("visual_signature", "")), "dark_soul_dominion")
	assert_lt(
		grave_end_scale,
		soul_end.scale.x,
		"soul_dominion end should resolve larger than grave_echo so the final dark toggle leaves a heavier terminal collapse"
	)
	assert_true(
		grave_end_color != str(soul_end.get_meta("visual_stage_color", "")),
		"dark toggle end visuals should keep different signature colors so the final dominion collapse reads apart from the grave-echo fade"
	)

func test_wind_storm_zone_uses_dedicated_toggle_visual_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("wind_storm_zone"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "storm_zone_activation", "toggle_activation")
	assert_true(activation != null, "wind_storm_zone must spawn a dedicated storm-zone activation visual when toggled on")
	var overlay := _get_player_toggle_overlay_sprite(player)
	assert_true(overlay != null, "wind_storm_zone must create a persistent dedicated zone overlay while active")
	assert_eq(str(overlay.get_meta("effect_id", "")), "storm_zone_loop")
	assert_eq(str(overlay.get_meta("skill_id", "")), "wind_storm_zone")
	assert_true(manager.attempt_cast("wind_storm_zone"))
	await _advance_frames(2)
	var end_effect := _find_effect_sprite(root, "storm_zone_end", "toggle_end")
	assert_true(end_effect != null, "wind_storm_zone must spawn a dedicated storm-zone end visual when toggled off")
	assert_true(_get_player_toggle_overlay_sprite(player) == null, "storm_zone overlay must clear once the toggle is off")

func test_holy_seraph_chorus_uses_dedicated_toggle_visual_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("holy_seraph_chorus"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "seraph_chorus_activation", "toggle_activation")
	assert_true(activation != null, "holy_seraph_chorus must spawn a dedicated chorus activation visual when toggled on")
	var overlay := _get_player_toggle_overlay_sprite(player)
	assert_true(overlay != null, "holy_seraph_chorus must create a persistent dedicated chorus overlay while active")
	assert_eq(str(overlay.get_meta("effect_id", "")), "seraph_chorus_loop")
	assert_eq(str(overlay.get_meta("skill_id", "")), "holy_seraph_chorus")
	assert_true(manager.attempt_cast("holy_seraph_chorus"))
	await _advance_frames(2)
	var end_effect := _find_effect_sprite(root, "seraph_chorus_end", "toggle_end")
	assert_true(end_effect != null, "holy_seraph_chorus must spawn a dedicated chorus end visual when toggled off")
	assert_true(_get_player_toggle_overlay_sprite(player) == null, "seraph_chorus overlay must clear once the toggle is off")

func test_wind_sky_dominion_uses_dedicated_toggle_visual_family() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("wind_sky_dominion"))
	await _advance_frames(2)
	var activation := _find_effect_sprite(root, "sky_dominion_activation", "toggle_activation")
	assert_true(activation != null, "wind_sky_dominion must spawn a dedicated sky-dominion activation visual when toggled on")
	var overlay := _get_player_toggle_overlay_sprite(player)
	assert_true(overlay != null, "wind_sky_dominion must create a persistent dedicated sky-dominion overlay while active")
	assert_eq(str(overlay.get_meta("effect_id", "")), "sky_dominion_loop")
	assert_eq(str(overlay.get_meta("skill_id", "")), "wind_sky_dominion")
	assert_true(manager.attempt_cast("wind_sky_dominion"))
	await _advance_frames(2)
	var end_effect := _find_effect_sprite(root, "sky_dominion_end", "toggle_end")
	assert_true(end_effect != null, "wind_sky_dominion must spawn a dedicated sky-dominion end visual when toggled off")
	assert_true(_get_player_toggle_overlay_sprite(player) == null, "sky_dominion overlay must clear once the toggle is off")

func test_spell_manager_can_reassign_slot_and_persist_to_game_state() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, "volt_spear"))
	var bindings: Array = manager.get_slot_bindings()
	assert_eq(str(bindings[0].get("skill_id", "")), "volt_spear")
	var saved_bindings: Array = GameState.get_spell_hotbar()
	assert_eq(str(saved_bindings[0].get("skill_id", "")), "volt_spear")


func test_spell_manager_assignment_normalizes_canonical_active_rows_to_runtime_spell_ids() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, "holy_healing_pulse"))
	var bindings: Array = manager.get_slot_bindings()
	assert_eq(str(bindings[0].get("skill_id", "")), "holy_radiant_burst")
	var saved_bindings: Array = GameState.get_spell_hotbar()
	assert_eq(str(saved_bindings[0].get("skill_id", "")), "holy_radiant_burst")


func test_spell_manager_visible_slot_bindings_return_first_ten_slots_only() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var visible_bindings: Array = manager.get_visible_slot_bindings()
	assert_eq(
		visible_bindings.size(),
		GameState.VISIBLE_HOTBAR_SLOT_COUNT,
		"spell manager visible bindings should expose only the first ten slots"
	)
	assert_eq(str(visible_bindings[0].get("label", "")), "1")
	assert_eq(str(visible_bindings[9].get("label", "")), "0")


func test_spell_manager_attempt_cast_by_action_uses_full_action_hotkey_registry() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	GameState.mana = GameState.max_mana
	assert_true(
		manager.attempt_cast_by_action("buff_guard"),
		"Maple-style registry should allow the hidden Z/X/C row to cast through the same primary path"
	)
	assert_true(GameState.active_buffs.size() >= 1)
	assert_true(
		manager.attempt_cast_by_action("buff_aegis"),
		"extended registry actions should also cast through the same unified action path"
	)
	assert_true(manager.assign_skill_to_slot(0, "volt_spear"))
	assert_true(
		manager.attempt_cast_by_action("spell_fire"),
		"visible slot actions must still cast whatever skill is currently assigned to that visible slot"
	)


func test_spell_manager_tooltip_data_contains_required_fields_for_assigned_slot() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, "holy_mana_veil"))
	var tooltip: Dictionary = manager.get_hotbar_slot_tooltip_data(0)
	assert_eq(str(tooltip.get("label", "")), "1")
	assert_eq(str(tooltip.get("skill_id", "")), "holy_mana_veil")
	assert_string_contains(str(tooltip.get("name", "")), "마나 베일")
	assert_true(tooltip.has("cooldown"), "tooltip should expose cooldown")
	assert_true(tooltip.has("cost"), "tooltip should expose mana cost")
	assert_true(tooltip.has("description"), "tooltip should expose description")
	assert_eq(str(tooltip.get("current_state", "")), "ready")
	assert_eq(int(tooltip.get("level", 0)), GameState.get_skill_level("holy_mana_veil"))
	assert_eq(int(tooltip.get("mastery", -1)), int(GameState.spell_mastery.get("holy_mana_veil", 0)))
	assert_true(bool(tooltip.get("can_use", false)), "ready slot should be usable")


func test_spell_manager_tooltip_school_reuses_common_runtime_school_resolver() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var tooltip: Dictionary = manager.get_hotbar_slot_tooltip_data(8)
	assert_eq(str(tooltip.get("skill_id", "")), "dark_void_bolt")
	assert_eq(
		str(tooltip.get("school", "")),
		"dark",
		"tooltip school must use the shared runtime school resolver for proxy-active rows"
	)


func test_spell_manager_tooltip_data_marks_empty_slot_as_empty_state() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.clear_slot(0))
	var tooltip: Dictionary = manager.get_hotbar_slot_tooltip_data(0)
	assert_eq(str(tooltip.get("skill_id", "")), "")
	assert_eq(str(tooltip.get("current_state", "")), "empty")
	assert_false(bool(tooltip.get("can_use", true)), "empty slot should be unusable")
	assert_eq(str(tooltip.get("failure_reason", "")), "empty_slot")


func test_spell_manager_can_swap_slots_and_refresh_bindings() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var before_first: Dictionary = manager.get_slot_bindings()[0]
	var before_second: Dictionary = manager.get_slot_bindings()[1]
	assert_true(manager.swap_slots(0, 1))
	var bindings: Array = manager.get_slot_bindings()
	assert_eq(str(bindings[0].get("skill_id", "")), str(before_second.get("skill_id", "")))
	assert_eq(str(bindings[1].get("skill_id", "")), str(before_first.get("skill_id", "")))
	assert_eq(str(bindings[0].get("label", "")), str(before_first.get("label", "")))
	assert_eq(str(bindings[1].get("label", "")), str(before_second.get("label", "")))


func test_spell_manager_can_cast_deploy_skill_from_reassigned_slot() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.assign_skill_to_slot(1, "earth_stone_spire"))
	assert_true(manager.attempt_cast("earth_stone_spire"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "earth_stone_spire")
	assert_eq(str(payloads[0].get("school", "")), "earth")
	assert_eq(float(payloads[0].get("knockback", 180.0)), 0.0, "Stone Spire deploy payload should not eject targets out of its pulse zone")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "Persistent deploy hits must not freeze the whole combat loop")

func test_fire_bolt_hotbar_action_emits_active_payload_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	assert_true(GameState.set_skill_level("fire_mastery", 10))
	GameState.set_equipped_item("weapon", "weapon_ember_staff")
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(12, 6)
	player.facing = 1
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, "fire_bolt"))
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var runtime: Dictionary = GameState.get_spell_runtime("fire_bolt")
	var action := _get_slot_action(manager, 0)
	assert_true(manager.attempt_cast_by_action(action))
	assert_eq(payloads.size(), 1)
	var payload: Dictionary = payloads[0]
	assert_eq(str(payload.get("spell_id", "")), "fire_bolt")
	assert_eq(str(payload.get("school", "")), str(runtime.get("school", "")))
	_assert_active_lead_payload_matches_runtime(payload, runtime, "fire_bolt")
	_assert_numeric_payload_field_matches(
		payload,
		runtime,
		"cooldown",
		"fire_bolt active payload must keep runtime cooldown after mastery/equipment scaling"
	)
	_assert_numeric_payload_field_matches(
		payload,
		runtime,
		"speed",
		"fire_bolt active payload must keep runtime projectile speed"
	)
	assert_eq(
		payload.get("velocity", Vector2.ZERO),
		Vector2(float(runtime.get("speed", 0.0)) * GameState.get_equipment_projectile_speed_multiplier(), 0.0),
		"fire_bolt active payload must keep the final velocity contract from runtime speed and equipment speed multiplier"
	)
	assert_eq(str(payload.get("attack_effect_id", "")), "fire_bolt_attack")
	assert_eq(str(payload.get("hit_effect_id", "")), "fire_bolt_hit")


func test_water_tidal_ring_cast_syncs_active_runtime_push_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.skill_level_data["water_tidal_ring"] = 30
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(14, 4)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var runtime := GameState.get_spell_runtime("water_tidal_ring")
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("water_tidal_ring"))
	assert_eq(payloads.size(), 1)
	var payload: Dictionary = payloads[0]
	assert_eq(str(payload.get("spell_id", "")), "water_tidal_ring")
	assert_eq(str(payload.get("school", "")), str(runtime.get("school", "")))
	assert_eq(payload.get("velocity", Vector2.RIGHT), Vector2.ZERO)
	_assert_active_lead_payload_matches_runtime(payload, runtime, "water_tidal_ring")
	_assert_numeric_payload_field_matches(
		payload,
		runtime,
		"duration",
		"water_tidal_ring active payload must keep runtime burst duration"
	)
	_assert_numeric_payload_field_matches(
		payload,
		runtime,
		"size",
		"water_tidal_ring active payload must keep runtime burst size"
	)
	_assert_numeric_payload_field_matches(
		payload,
		runtime,
		"knockback",
		"water_tidal_ring active payload must keep runtime push control strength"
	)
	assert_eq(str(payload.get("hitstop_mode", "")), "area_burst")
	assert_eq(str(payload.get("attack_effect_id", "")), "water_tidal_ring_attack")
	assert_eq(str(payload.get("hit_effect_id", "")), "water_tidal_ring_hit")

func test_common_runtime_stat_block_matches_deploy_runtime_builder() -> void:
	GameState.reset_progress_for_tests()
	var manager = SPELL_MANAGER_SCRIPT.new()
	var skill_id := "earth_stone_spire"
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	var level: int = GameState.get_skill_level(skill_id)
	var expected := GameState.get_data_driven_skill_runtime(skill_id, skill_data, level)
	var actual := manager._build_skill_runtime(skill_id, skill_data)
	assert_eq(
		int(actual.get("damage", 0)),
		int(expected.get("damage", 0)),
		"deploy runtime damage must delegate to the shared data-driven runtime helper"
	)
	assert_eq(
		float(actual.get("cooldown", 0.0)),
		float(expected.get("cooldown", 0.0)),
		"deploy runtime cooldown must delegate to the shared data-driven runtime helper"
	)
	assert_eq(
		float(actual.get("duration", 0.0)),
		float(expected.get("duration", 0.0)),
		"deploy runtime duration must delegate to the shared data-driven runtime helper"
	)
	assert_eq(
		float(actual.get("size", 0.0)),
		float(expected.get("size", 0.0)),
		"deploy runtime size must delegate to the shared data-driven runtime helper"
	)
	assert_eq(int(actual.get("pierce", -1)), 0)
	assert_eq(str(actual.get("school", "")), "earth")


func test_deploy_cast_payload_reuses_shared_data_driven_payload_helper() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(16, 8)
	player.facing = 1
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var skill_id := "earth_stone_spire"
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	var runtime := GameState.apply_deploy_buff_modifiers(
		GameState.get_data_driven_skill_runtime(skill_id, skill_data)
	)
	var expected_payload := GameState.build_data_driven_combat_payload(
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
			"color": "#c8a56a",
			"owner": player
		}
	)
	assert_true(manager.attempt_cast(skill_id))
	assert_eq(payloads.size(), 1)
	assert_eq(payloads[0].get("position", Vector2.ZERO), expected_payload.get("position", Vector2.ZERO))
	assert_eq(int(payloads[0].get("damage", 0)), int(expected_payload.get("damage", 0)))
	assert_eq(float(payloads[0].get("size", 0.0)), float(expected_payload.get("size", 0.0)))
	assert_eq(float(payloads[0].get("duration", 0.0)), float(expected_payload.get("duration", 0.0)))
	assert_eq(int(payloads[0].get("target_count", 0)), int(expected_payload.get("target_count", 0)))
	assert_eq(str(payloads[0].get("school", "")), str(expected_payload.get("school", "")))
	assert_eq(str(payloads[0].get("color", "")), str(expected_payload.get("color", "")))


func test_wind_cyclone_prison_deploy_payload_syncs_runtime_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.skill_level_data["wind_cyclone_prison"] = 30
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(22, 12)
	player.facing = 1
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var skill_id := "wind_cyclone_prison"
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	var runtime := GameState.apply_deploy_buff_modifiers(
		GameState.get_data_driven_skill_runtime(skill_id, skill_data)
	)
	var expected_payload := GameState.build_data_driven_combat_payload(
		skill_id,
		runtime,
		{
			"position": player.global_position + Vector2(48 * player.facing, -4),
			"target_count": int(runtime.get("target_count", 0)),
			"color": "#d4ffe3",
			"owner": player
		}
	)
	assert_true(manager.attempt_cast(skill_id))
	assert_eq(payloads.size(), 1)
	var payload: Dictionary = payloads[0]
	assert_eq(str(payload.get("spell_id", "")), skill_id)
	_assert_numeric_payload_field_matches(
		payload,
		expected_payload,
		"duration",
		"wind_cyclone_prison deploy cast must keep runtime duration on the emitted payload"
	)
	_assert_numeric_payload_field_matches(
		payload,
		expected_payload,
		"size",
		"wind_cyclone_prison deploy cast must keep runtime size on the emitted payload"
	)
	_assert_numeric_payload_field_matches(
		payload,
		expected_payload,
		"pull_strength",
		"wind_cyclone_prison deploy cast must keep runtime pull strength on the emitted payload"
	)
	assert_eq(
		int(payload.get("target_count", 0)),
		int(expected_payload.get("target_count", 0)),
		"wind_cyclone_prison deploy cast must keep runtime target count on the emitted payload"
	)
	assert_eq(str(payload.get("terminal_effect_id", "")), "wind_cyclone_prison_end")
	assert_eq(str(payload.get("attack_effect_id", "")), "wind_cyclone_prison_attack")
	assert_eq(str(payload.get("hit_effect_id", "")), "wind_cyclone_prison_hit")


func test_water_tidal_ring_push_control_strength_scales_on_actual_hit() -> void:
	GameState.reset_progress_for_tests()
	var low_runtime := GameState.get_spell_runtime("water_tidal_ring")
	assert_true(GameState.set_skill_level("water_tidal_ring", 30))
	var high_runtime := GameState.get_spell_runtime("water_tidal_ring")
	var low_root := Node2D.new()
	add_child_autofree(low_root)
	var low_projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var low_payload := low_runtime.duplicate(true)
	low_payload["position"] = Vector2(0.0, -8.0)
	low_payload["velocity"] = Vector2.ZERO
	low_payload["team"] = "player"
	low_payload["spell_id"] = "water_tidal_ring"
	low_payload["attack_effect_id"] = "water_tidal_ring_attack"
	low_payload["hit_effect_id"] = "water_tidal_ring_hit"
	low_payload["color"] = "#7fd9ff"
	low_payload["multi_hit_count"] = 1
	low_payload["total_damage"] = int(low_payload.get("damage", 0))
	low_projectile.setup(low_payload)
	low_root.add_child(low_projectile)
	await get_tree().process_frame
	var low_target := DummyProjectileTarget.new()
	low_root.add_child(low_target)
	low_projectile._hit_enemy(low_target)
	await get_tree().process_frame
	var high_root := Node2D.new()
	add_child_autofree(high_root)
	var high_projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var high_payload := high_runtime.duplicate(true)
	high_payload["position"] = Vector2(0.0, -8.0)
	high_payload["velocity"] = Vector2.ZERO
	high_payload["team"] = "player"
	high_payload["spell_id"] = "water_tidal_ring"
	high_payload["attack_effect_id"] = "water_tidal_ring_attack"
	high_payload["hit_effect_id"] = "water_tidal_ring_hit"
	high_payload["color"] = "#7fd9ff"
	high_payload["multi_hit_count"] = 1
	high_payload["total_damage"] = int(high_payload.get("damage", 0))
	high_projectile.setup(high_payload)
	high_root.add_child(high_projectile)
	await get_tree().process_frame
	var high_target := DummyProjectileTarget.new()
	high_root.add_child(high_target)
	high_projectile._hit_enemy(high_target)
	await get_tree().process_frame
	assert_gt(low_target.received_hits.size(), 0)
	assert_gt(high_target.received_hits.size(), 0)
	assert_gt(
		float(high_target.received_hits[0].get("knockback", 0.0)),
		float(low_target.received_hits[0].get("knockback", 0.0)),
		"water_tidal_ring must push harder on actual hit resolution as its runtime level rises"
	)
	GameState.reset_progress_for_tests()

func test_plant_root_bind_canonical_hotbar_action_emits_runtime_deploy_payload_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.skill_level_data["plant_vine_snare"] = 30
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(18, 10)
	player.facing = 1
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, "plant_root_bind"))
	assert_eq(str(manager.get_slot_bindings()[0].get("skill_id", "")), "plant_vine_snare")
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var skill_id := "plant_vine_snare"
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	var runtime := GameState.apply_deploy_buff_modifiers(
		GameState.get_data_driven_skill_runtime(skill_id, skill_data)
	)
	var expected_payload := GameState.build_data_driven_combat_payload(
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
			"color": "#3fa34d",
			"owner": player
		}
	)
	var action := _get_slot_action(manager, 0)
	assert_true(manager.attempt_cast_by_action(action))
	assert_eq(payloads.size(), 1)
	var payload: Dictionary = payloads[0]
	assert_eq(str(payload.get("spell_id", "")), "plant_vine_snare")
	assert_eq(str(payload.get("school", "")), "plant")
	assert_eq(int(payload.get("damage", 0)), int(expected_payload.get("damage", 0)))
	_assert_numeric_payload_field_matches(
		payload,
		expected_payload,
		"duration",
		"plant_root_bind canonical deploy cast must keep runtime duration on the runtime payload"
	)
	_assert_numeric_payload_field_matches(
		payload,
		expected_payload,
		"size",
		"plant_root_bind canonical deploy cast must keep runtime size on the runtime payload"
	)
	assert_eq(int(payload.get("target_count", 0)), int(expected_payload.get("target_count", 0)))
	var utility_effects: Array = payload.get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "root")


func test_plant_mastery_level_30_applies_deploy_damage_cooldown_and_mana_through_shared_runtime_builder() -> void:
	GameState.reset_progress_for_tests()
	var manager = SPELL_MANAGER_SCRIPT.new()
	var skill_data: Dictionary = GameDatabase.get_skill_data("plant_vine_snare")
	var baseline_runtime := manager._build_skill_runtime("plant_vine_snare", skill_data)
	assert_true(GameState.set_skill_level("plant_mastery", 30))
	var runtime := manager._build_skill_runtime("plant_vine_snare", skill_data)
	var mastery_modifiers := GameState.get_mastery_runtime_modifiers_for_skill(
		"plant_vine_snare",
		skill_data,
		str(runtime.get("school", ""))
	)
	assert_eq(
		int(runtime.get("damage", 0)),
		int(round(float(baseline_runtime.get("damage", 0.0)) * float(mastery_modifiers.get("damage_multiplier", 1.0)))),
		"plant deploy runtime damage must read cadence-normalized base damage before mastery amplification"
	)
	assert_almost_eq(
		float(runtime.get("cooldown", 0.0)),
		3.825,
		0.0001,
		"plant deploy runtime cooldown must read plant_mastery through the shared runtime helper"
	)
	assert_almost_eq(
		GameState.get_skill_mana_cost("plant_vine_snare"),
		13.2,
		0.0001,
		"plant deploy mana cost must read plant_mastery through the shared mana helper"
	)

func test_spell_manager_toggle_skill_emits_periodic_aura_and_can_turn_off() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.assign_skill_to_slot(2, "dark_grave_echo"))
	assert_true(manager.attempt_cast("dark_grave_echo"))
	manager.tick(0.2)
	assert_true(payloads.size() >= 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "dark_grave_echo")
	assert_string_contains(manager.get_hotbar_summary(), "그레이브 에코 사용 중")
	assert_true(manager.attempt_cast("dark_grave_echo"))
	assert_false(manager.get_hotbar_summary().contains("그레이브 에코 사용 중"))

func test_spell_manager_blocks_cast_when_mana_is_empty() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	GameState.mana = 0.0
	assert_false(manager.attempt_cast("fire_bolt"))
	assert_eq(manager.get_last_failure_reason(), "mana")
	assert_eq(manager.get_feedback_summary(), "시전  MP 부족")

func test_spell_manager_ignores_cooldown_when_admin_flag_is_enabled() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("wind_storm"))
	assert_false(manager.attempt_cast("wind_storm"))
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(manager.attempt_cast("wind_storm"))

func test_low_circle_zero_cooldown_active_still_relies_on_cast_lock_when_spell_cast_feedback_is_live() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	manager.spell_cast.connect(func(payload: Dictionary) -> void: player.call("_on_spell_cast", payload))
	assert_true(manager.attempt_cast("fire_bolt"))
	assert_eq(manager.get_cooldown("fire_bolt"), 0.0, "fire_bolt must be runtime-zero-cooldown after the low-circle rework")
	assert_false(manager.attempt_cast("fire_bolt"), "cast lock must still pace zero-cooldown actives while live spell feedback is connected")
	await get_tree().create_timer(0.10).timeout
	assert_true(manager.attempt_cast("fire_bolt"), "fire_bolt must become recastable again once the cast-lock cadence expires")

func test_low_circle_attack_runtime_defaults_to_zero_cooldown() -> void:
	GameState.reset_progress_for_tests()
	for spell_id in ZERO_COOLDOWN_ACTIVE_RUNTIME_SPELLS:
		var runtime := GameState.get_spell_runtime(spell_id)
		assert_eq(
			float(runtime.get("cooldown", -1.0)),
			0.0,
			"%s must keep zero cooldown in the runtime source of truth" % spell_id
		)

func test_active_multi_hit_runtime_tiers_match_documented_thresholds() -> void:
	GameState.reset_progress_for_tests()
	for spell_id in MID_CIRCLE_ACTIVE_MULTI_HIT_RUNTIME_SPELLS:
		var runtime := GameState.get_spell_runtime(spell_id)
		assert_gte(
			int(runtime.get("multi_hit_count", 1)),
			2,
			"%s must keep at least 2 hits in the 4-6 circle runtime band" % spell_id
		)
		assert_lte(
			int(runtime.get("multi_hit_count", 1)),
			6,
			"%s must stay inside the documented 4-6 circle multi-hit ceiling" % spell_id
		)
	for spell_id in HIGH_CIRCLE_ACTIVE_MULTI_HIT_RUNTIME_SPELLS:
		var runtime := GameState.get_spell_runtime(spell_id)
		assert_gte(
			int(runtime.get("multi_hit_count", 1)),
			6,
			"%s must keep at least 6 hits in the 7+ circle runtime band" % spell_id
		)

func test_persistent_attack_runtime_cadence_matches_documented_hit_thresholds() -> void:
	GameState.reset_progress_for_tests()
	for skill_id in MID_CIRCLE_PERSISTENT_MULTI_HIT_SKILLS:
		var runtime := GameState.get_data_driven_skill_runtime(skill_id, GameDatabase.get_skill_data(skill_id))
		var hit_count := _count_tick_hits_for_test(float(runtime.get("tick_interval", 0.0)))
		assert_gte(hit_count, 2, "%s must land at least 2 hits inside the 3-second sustain window" % skill_id)
		assert_lte(hit_count, 6, "%s must stay within the documented 4-6 circle sustain hit ceiling" % skill_id)
	for skill_id in HIGH_CIRCLE_PERSISTENT_MULTI_HIT_SKILLS:
		var runtime := GameState.get_data_driven_skill_runtime(skill_id, GameDatabase.get_skill_data(skill_id))
		var hit_count := _count_tick_hits_for_test(float(runtime.get("tick_interval", 0.0)))
		assert_gte(hit_count, 6, "%s must land at least 6 hits inside the 3-second sustain window" % skill_id)

func test_active_multi_hit_payloads_emit_once_and_resolve_hits_on_contact() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var cases := [
		{"spell_id": "fire_bolt"},
		{"spell_id": "fire_meteor_strike"},
		{"spell_id": "earth_world_end_break"}
	]
	for case in cases:
		var spell_id := str(case.get("spell_id", ""))
		var runtime := GameState.get_spell_runtime(spell_id)
		var manager = SPELL_MANAGER_SCRIPT.new()
		manager.setup(player)
		var payloads: Array = []
		manager.spell_cast.connect(func(payload: Dictionary) -> void:
			if str(payload.get("spell_id", "")) == spell_id:
				payloads.append(payload.duplicate(true))
		)
		assert_true(manager.attempt_cast(spell_id), "%s cast must succeed for on-hit multi-hit validation" % spell_id)
		assert_eq(payloads.size(), 1, "%s must emit exactly one cast payload regardless of authored hit count" % spell_id)
		var payload: Dictionary = payloads[0]
		assert_eq(int(payload.get("damage", 0)), int(runtime.get("damage", 0)), "%s cast payload damage must stay on total runtime damage" % spell_id)
		assert_eq(int(payload.get("total_damage", 0)), int(runtime.get("damage", 0)), "%s cast payload total_damage metadata must preserve authored total damage" % spell_id)
		assert_eq(int(payload.get("multi_hit_total", 0)), int(runtime.get("multi_hit_count", 1)), "%s cast payload must expose the authored hit count" % spell_id)
		assert_false(bool(payload.get("follow_up_hit", false)), "%s cast payload must no longer use follow-up payload semantics" % spell_id)
		var projectile := _spawn_projectile_for_spell_coverage(root, payload)
		await _advance_frames(1)
		var target := DummyProjectileTarget.new()
		root.add_child(target)
		projectile._hit_enemy(target)
		await _wait_for_multi_hit_sequence_for_test(runtime)
		var split_damage := _split_total_damage_for_test(int(runtime.get("damage", 0)), int(runtime.get("multi_hit_count", 1)))
		assert_eq(target.received_hits.size(), int(runtime.get("multi_hit_count", 1)), "%s must resolve authored hit count on a single target after contact" % spell_id)
		for hit_index in range(target.received_hits.size()):
			assert_eq(int(target.received_hits[hit_index].get("damage", 0)), split_damage[hit_index], "%s hit %d must use split total-damage distribution" % [spell_id, hit_index])

func test_projectile_count_bonus_stays_separate_from_multi_hit_count() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2.ZERO
	player.facing = 1
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void:
		if str(payload.get("spell_id", "")) == "wind_gale_cutter":
			payloads.append(payload.duplicate(true))
	)
	var base_runtime := GameState.get_spell_runtime("wind_gale_cutter")
	assert_true(manager.attempt_cast("wind_gale_cutter"))
	assert_eq(payloads.size(), 1, "without projectile bonus, Gale Cutter must still emit a single cast payload")
	assert_eq(int(payloads[0].get("multi_hit_total", 0)), int(base_runtime.get("multi_hit_count", 1)))
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	assert_true(GameState.apply_equipment_preset("wind_tempo"))
	payloads.clear()
	var boosted_runtime := GameState.get_spell_runtime("wind_gale_cutter")
	assert_true(manager.attempt_cast("wind_gale_cutter"))
	assert_gt(payloads.size(), 1, "projectile count bonus must add projectile emits instead of inflating multi-hit count")
	for payload in payloads:
		assert_eq(int(payload.get("multi_hit_total", 0)), int(boosted_runtime.get("multi_hit_count", 1)), "every bonus projectile must keep the same authored on-hit multi-hit count")

func test_runtime_proxy_mappings_keep_canonical_input_and_runtime_spell_resolution_in_sync() -> void:
	GameState.reset_progress_for_tests()
	for proxy_case in CANONICAL_RUNTIME_PROXY_CASES:
		var canonical_skill_id := str(proxy_case.get("canonical", ""))
		var runtime_spell_id := str(proxy_case.get("runtime", ""))
		assert_eq(
			GameDatabase.get_runtime_spell_id_for_skill(canonical_skill_id),
			runtime_spell_id,
			"%s must resolve to the documented runtime spell id" % canonical_skill_id
		)
		assert_eq(
			GameState.get_runtime_castable_hotbar_skill_id(canonical_skill_id),
			runtime_spell_id,
			"%s hotbar input must keep the runtime cast id in sync with the central mapping" % canonical_skill_id
		)

func test_spell_manager_reports_toggle_feedback_in_summary() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_grave_echo"))
	assert_true(manager.attempt_cast("dark_grave_echo"))
	assert_eq(manager.get_feedback_summary(), "시전  그레이브 에코 활성화")
	assert_true(manager.attempt_cast("dark_grave_echo"))
	assert_eq(manager.get_feedback_summary(), "시전  그레이브 에코 비활성화")

func test_toggle_skill_consumes_mana_each_tick() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_grave_echo"))
	var before_mana := GameState.mana
	assert_true(manager.attempt_cast("dark_grave_echo"))
	manager.tick(0.2)
	assert_lt(GameState.mana, before_mana - 1.0)

func test_toggle_skill_turns_off_when_mana_runs_out() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_grave_echo"))
	GameState.mana = 8.0
	assert_true(manager.attempt_cast("dark_grave_echo"))
	manager.tick(0.2)
	manager.tick(1.1)
	assert_false(manager.get_hotbar_summary().contains("그레이브 에코 사용 중"))
	assert_eq(manager.get_feedback_summary(), "시전  그레이브 에코 비활성화(MP)")

func test_toggle_skill_uses_data_driven_sustain_cost() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	var before_mana := GameState.mana
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	manager.tick(0.2)
	var mana_spent := before_mana - GameState.mana
	assert_gt(mana_spent, 15.0)
	assert_lt(mana_spent, 17.5)

func test_toggle_sustain_cost_reuses_common_scaled_mana_helper() -> void:
	var manager = SPELL_MANAGER_SCRIPT.new()
	var skill_data: Dictionary = GameDatabase.get_skill_data("dark_grave_echo")
	var runtime_options := GameState.build_data_driven_skill_runtime_options(
		"dark_grave_echo",
		skill_data
	)
	var expected := GameState.get_data_driven_skill_mana_drain_per_tick(
		"dark_grave_echo",
		skill_data,
		runtime_options
	)
	assert_eq(
		manager._get_toggle_mana_drain_per_tick("dark_grave_echo", skill_data, runtime_options),
		expected,
		"toggle sustain mana must delegate to the shared data-driven mana helper"
	)


func test_dark_mastery_level_30_applies_toggle_damage_cooldown_and_sustain_mana_through_shared_runtime_builder() -> void:
	GameState.reset_progress_for_tests()
	var manager = SPELL_MANAGER_SCRIPT.new()
	var skill_data: Dictionary = GameDatabase.get_skill_data("dark_grave_echo")
	var baseline_runtime := manager._build_skill_runtime("dark_grave_echo", skill_data)
	assert_true(GameState.set_skill_level("dark_magic_mastery", 30))
	var runtime := manager._build_skill_runtime("dark_grave_echo", skill_data)
	var mastery_modifiers := GameState.get_mastery_runtime_modifiers_for_skill(
		"dark_grave_echo",
		skill_data,
		str(runtime.get("school", ""))
	)
	assert_eq(
		int(runtime.get("damage", 0)),
		int(round(float(baseline_runtime.get("damage", 0.0)) * float(mastery_modifiers.get("damage_multiplier", 1.0)))),
		"dark toggle runtime damage must read cadence-normalized base damage before mastery amplification"
	)
	assert_almost_eq(
		float(runtime.get("cooldown", 0.0)),
		0.85,
		0.0001,
		"dark toggle runtime cooldown must read dark mastery through the shared runtime helper"
	)
	assert_almost_eq(
		float(runtime.get("mana_drain_per_tick", 0.0)),
		2.64,
		0.0001,
		"dark toggle sustain mana must read dark mastery through the shared mana helper"
	)


func test_arcane_mastery_level_30_applies_global_deploy_damage_cooldown_and_mana() -> void:
	GameState.reset_progress_for_tests()
	var manager = SPELL_MANAGER_SCRIPT.new()
	var skill_data: Dictionary = GameDatabase.get_skill_data("plant_vine_snare")
	var baseline_runtime := manager._build_skill_runtime("plant_vine_snare", skill_data)
	var baseline_mana := GameState.get_skill_mana_cost("plant_vine_snare")
	assert_true(GameState.set_skill_level("arcane_magic_mastery", 30))
	var runtime := manager._build_skill_runtime("plant_vine_snare", skill_data)
	assert_eq(
		int(runtime.get("damage", 0)),
		int(round(float(baseline_runtime.get("damage", 0.0)) * 1.087)),
		"arcane global mastery must boost deploy damage through the shared runtime helper"
	)
	assert_almost_eq(
		float(runtime.get("cooldown", 0.0)),
		float(baseline_runtime.get("cooldown", 0.0)) * 0.85,
		0.0001,
		"arcane global mastery must reduce deploy cooldown through the shared runtime helper"
	)
	assert_almost_eq(
		GameState.get_skill_mana_cost("plant_vine_snare"),
		baseline_mana * 0.88,
		0.0001,
		"arcane global mastery must reduce deploy mana cost through the shared mana helper"
	)


func test_arcane_mastery_level_30_applies_global_toggle_damage_cooldown_and_sustain_mana() -> void:
	GameState.reset_progress_for_tests()
	var manager = SPELL_MANAGER_SCRIPT.new()
	var skill_data: Dictionary = GameDatabase.get_skill_data("dark_grave_echo")
	var baseline_runtime := manager._build_skill_runtime("dark_grave_echo", skill_data)
	assert_true(GameState.set_skill_level("arcane_magic_mastery", 30))
	var runtime := manager._build_skill_runtime("dark_grave_echo", skill_data)
	assert_eq(
		int(runtime.get("damage", 0)),
		int(round(float(baseline_runtime.get("damage", 0.0)) * 1.087)),
		"arcane global mastery must boost toggle damage through the shared runtime helper"
	)
	assert_almost_eq(
		float(runtime.get("cooldown", 0.0)),
		float(baseline_runtime.get("cooldown", 0.0)) * 0.85,
		0.0001,
		"arcane global mastery must reduce toggle cooldown through the shared runtime helper"
	)
	assert_almost_eq(
		float(runtime.get("mana_drain_per_tick", 0.0)),
		float(baseline_runtime.get("mana_drain_per_tick", 0.0)) * 0.88,
		0.0001,
		"arcane global mastery must reduce toggle sustain mana through the shared mana helper"
	)


func test_ice_mastery_level_30_applies_toggle_damage_cooldown_and_sustain_mana_through_shared_runtime_builder() -> void:
	GameState.reset_progress_for_tests()
	var manager = SPELL_MANAGER_SCRIPT.new()
	var skill_data: Dictionary = GameDatabase.get_skill_data("ice_glacial_dominion")
	var baseline_runtime := manager._build_skill_runtime("ice_glacial_dominion", skill_data)
	assert_true(GameState.set_skill_level("ice_mastery", 30))
	var runtime := manager._build_skill_runtime("ice_glacial_dominion", skill_data)
	assert_eq(
		int(runtime.get("damage", 0)),
		int(round(float(baseline_runtime.get("damage", 0.0)) * 1.116)),
		"ice toggle runtime damage must read ice_mastery through the shared runtime helper"
	)
	assert_almost_eq(
		float(runtime.get("cooldown", 0.0)),
		float(baseline_runtime.get("cooldown", 0.0)) * 0.85,
		0.0001,
		"ice toggle runtime cooldown must read ice_mastery through the shared runtime helper"
	)
	assert_almost_eq(
		float(runtime.get("mana_drain_per_tick", 0.0)),
		float(baseline_runtime.get("mana_drain_per_tick", 0.0)) * 0.88,
		0.0001,
		"ice toggle sustain mana must read ice_mastery through the shared mana helper"
	)


func test_lightning_mastery_level_30_applies_toggle_damage_cooldown_and_sustain_mana_through_shared_runtime_builder() -> void:
	GameState.reset_progress_for_tests()
	var manager = SPELL_MANAGER_SCRIPT.new()
	var skill_data: Dictionary = GameDatabase.get_skill_data("lightning_tempest_crown")
	var baseline_runtime := manager._build_skill_runtime("lightning_tempest_crown", skill_data)
	assert_true(GameState.set_skill_level("lightning_mastery", 30))
	var runtime := manager._build_skill_runtime("lightning_tempest_crown", skill_data)
	assert_eq(
		int(runtime.get("damage", 0)),
		int(round(float(baseline_runtime.get("damage", 0.0)) * 1.116)),
		"lightning toggle runtime damage must read lightning_mastery through the shared runtime helper"
	)
	assert_almost_eq(
		float(runtime.get("cooldown", 0.0)),
		float(baseline_runtime.get("cooldown", 0.0)) * 0.85,
		0.0001,
		"lightning toggle runtime cooldown must read lightning_mastery through the shared runtime helper"
	)
	assert_almost_eq(
		float(runtime.get("mana_drain_per_tick", 0.0)),
		float(baseline_runtime.get("mana_drain_per_tick", 0.0)) * 0.88,
		0.0001,
		"lightning toggle sustain mana must read lightning_mastery through the shared mana helper"
	)


func test_wind_mastery_level_30_applies_toggle_damage_cooldown_and_sustain_mana_through_shared_runtime_builder() -> void:
	GameState.reset_progress_for_tests()
	var manager = SPELL_MANAGER_SCRIPT.new()
	var skill_data: Dictionary = GameDatabase.get_skill_data("wind_storm_zone")
	var baseline_runtime := manager._build_skill_runtime("wind_storm_zone", skill_data)
	assert_true(GameState.set_skill_level("wind_mastery", 30))
	var runtime := manager._build_skill_runtime("wind_storm_zone", skill_data)
	assert_eq(
		int(runtime.get("damage", 0)),
		int(round(float(baseline_runtime.get("damage", 0.0)) * 1.116)),
		"wind toggle runtime damage must read wind_mastery through the shared runtime helper"
	)
	assert_almost_eq(
		float(runtime.get("cooldown", 0.0)),
		float(baseline_runtime.get("cooldown", 0.0)) * 0.85,
		0.0001,
		"wind toggle runtime cooldown must read wind_mastery through the shared runtime helper"
	)
	assert_almost_eq(
		float(runtime.get("mana_drain_per_tick", 0.0)),
		float(baseline_runtime.get("mana_drain_per_tick", 0.0)) * 0.88,
		0.0001,
		"wind toggle sustain mana must read wind_mastery through the shared mana helper"
	)


func test_earth_mastery_level_30_applies_toggle_damage_cooldown_and_sustain_mana_through_shared_runtime_builder() -> void:
	GameState.reset_progress_for_tests()
	var manager = SPELL_MANAGER_SCRIPT.new()
	var skill_data: Dictionary = GameDatabase.get_skill_data("earth_fortress")
	var baseline_runtime := manager._build_skill_runtime("earth_fortress", skill_data)
	assert_true(GameState.set_skill_level("earth_mastery", 30))
	var runtime := manager._build_skill_runtime("earth_fortress", skill_data)
	assert_eq(
		int(runtime.get("damage", 0)),
		int(round(float(baseline_runtime.get("damage", 0.0)) * 1.116)),
		"earth toggle runtime damage must read earth_mastery through the shared runtime helper"
	)
	assert_almost_eq(
		float(runtime.get("cooldown", 0.0)),
		float(baseline_runtime.get("cooldown", 0.0)) * 0.85,
		0.0001,
		"earth toggle runtime cooldown must read earth_mastery through the shared runtime helper"
	)
	assert_almost_eq(
		float(runtime.get("mana_drain_per_tick", 0.0)),
		float(baseline_runtime.get("mana_drain_per_tick", 0.0)) * 0.88,
		0.0001,
		"earth toggle sustain mana must read earth_mastery through the shared mana helper"
	)

func test_toggle_sustain_cost_scales_down_with_skill_level() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	GameState.skill_level_data["ice_glacial_dominion"] = 20
	var before_mana := GameState.mana
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	manager.tick(0.2)
	var mana_spent := before_mana - GameState.mana
	assert_gt(mana_spent, 14.0)
	assert_lt(mana_spent, 16.0)

func test_glacial_dominion_toggle_emits_slow_utility_payload() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	manager.tick(0.2)
	assert_true(payloads.size() >= 1)
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "slow")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "Toggle aura ticks must not trigger hitstop")


func test_toggle_tick_payload_reuses_shared_data_driven_payload_helper() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(24, 12)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var skill_id := "dark_grave_echo"
	assert_true(manager.attempt_cast(skill_id))
	var toggle_state: Dictionary = manager.active_toggles.get(skill_id, {}).duplicate(true)
	var expected_payload := GameState.build_data_driven_combat_payload(
		skill_id,
		toggle_state,
		{
			"position": player.global_position + Vector2(0, -10),
			"knockback": 70.0,
			"duration": 0.12,
			"color": str(toggle_state.get("color", "#8f77d8")),
			"owner": player
		}
	)
	manager.tick(0.2)
	assert_true(payloads.size() >= 1)
	assert_eq(payloads[0].get("position", Vector2.ZERO), expected_payload.get("position", Vector2.ZERO))
	assert_eq(int(payloads[0].get("damage", 0)), int(expected_payload.get("damage", 0)))
	assert_eq(int(payloads[0].get("pierce", 0)), int(expected_payload.get("pierce", 0)))
	assert_eq(float(payloads[0].get("size", 0.0)), float(expected_payload.get("size", 0.0)))
	assert_eq(str(payloads[0].get("school", "")), str(expected_payload.get("school", "")))
	assert_eq(str(payloads[0].get("color", "")), str(expected_payload.get("color", "")))

func test_lightning_tempest_crown_hotbar_action_emits_runtime_toggle_payload_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.skill_level_data["lightning_tempest_crown"] = 24
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(8, -2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "lightning_tempest_crown"))
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var action := _get_slot_action(manager, 2)
	assert_true(manager.attempt_cast_by_action(action))
	var toggle_state: Dictionary = manager.active_toggles.get("lightning_tempest_crown", {}).duplicate(true)
	var expected_payload := GameState.build_data_driven_combat_payload(
		"lightning_tempest_crown",
		toggle_state,
		{
			"position": player.global_position + Vector2(0, -10),
			"knockback": 70.0,
			"duration": 0.12,
			"color": str(toggle_state.get("color", "#f0d44f")),
			"owner": player
		}
	)
	manager.tick(0.2)
	assert_true(payloads.size() >= 1)
	var payload: Dictionary = payloads[0]
	assert_eq(str(payload.get("spell_id", "")), "lightning_tempest_crown")
	assert_eq(str(payload.get("school", "")), "lightning")
	assert_eq(int(payload.get("damage", 0)), int(expected_payload.get("damage", 0)))
	assert_eq(int(payload.get("pierce", 0)), int(expected_payload.get("pierce", 0)))
	_assert_numeric_payload_field_matches(
		payload,
		expected_payload,
		"size",
		"lightning_tempest_crown toggle payload must keep runtime size"
	)
	_assert_numeric_payload_field_matches(
		payload,
		expected_payload,
		"duration",
		"lightning_tempest_crown toggle payload must keep runtime tick duration override"
	)

func test_holy_healing_pulse_canonical_hotbar_action_emits_runtime_active_payload_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.health = GameState.max_health - 26
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(20, 4)
	player.facing = 1
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, "holy_healing_pulse"))
	assert_eq(str(manager.get_slot_bindings()[0].get("skill_id", "")), "holy_radiant_burst")
	var runtime: Dictionary = GameState.get_spell_runtime("holy_radiant_burst")
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var action := _get_slot_action(manager, 0)
	assert_true(manager.attempt_cast_by_action(action))
	assert_eq(payloads.size(), 1)
	var payload: Dictionary = payloads[0]
	assert_eq(str(payload.get("spell_id", "")), "holy_radiant_burst")
	assert_eq(str(payload.get("school", "")), str(runtime.get("school", "")))
	_assert_active_lead_payload_matches_runtime(payload, runtime, "holy_healing_pulse")
	_assert_numeric_payload_field_matches(
		payload,
		runtime,
		"cooldown",
		"holy_healing_pulse canonical input must keep runtime cooldown after proxy normalization"
	)
	_assert_numeric_payload_field_matches(
		payload,
		runtime,
		"speed",
		"holy_healing_pulse canonical input must keep runtime projectile speed after proxy normalization"
	)
	_assert_numeric_payload_field_matches(
		payload,
		runtime,
		"self_heal",
		"holy_healing_pulse canonical input must keep runtime self-heal after proxy normalization"
	)
	assert_gt(int(payload.get("self_heal", 0)), 0, "holy_healing_pulse must carry a self-heal rider in the current solo runtime")
	assert_gt(GameState.health, GameState.max_health - 26, "holy_healing_pulse canonical cast must restore some player health on cast")

func test_ice_frost_needle_canonical_hotbar_action_emits_runtime_active_payload_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(18, 6)
	player.facing = -1
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(1, "ice_frost_needle"))
	assert_eq(str(manager.get_slot_bindings()[1].get("skill_id", "")), "ice_frost_needle")
	var runtime: Dictionary = GameState.get_spell_runtime("ice_frost_needle")
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var action := _get_slot_action(manager, 1)
	assert_true(manager.attempt_cast_by_action(action))
	assert_eq(payloads.size(), 1)
	var payload: Dictionary = payloads[0]
	assert_eq(str(payload.get("spell_id", "")), "ice_frost_needle")
	assert_eq(str(payload.get("school", "")), str(runtime.get("school", "")))
	_assert_active_lead_payload_matches_runtime(payload, runtime, "ice_frost_needle")
	assert_lt(float(payload.get("velocity", Vector2.ZERO).x), 0.0, "Frost Needle must keep directional projectile velocity on canonical hotbar cast")
	var utility_effects: Array = payload.get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "slow")
	_assert_numeric_payload_field_matches(
		payload,
		runtime,
		"cooldown",
		"ice_frost_needle canonical input must keep runtime cooldown after normalization"
	)
	_assert_numeric_payload_field_matches(
		payload,
		runtime,
		"speed",
		"ice_frost_needle canonical input must keep projectile speed after normalization"
	)


func test_lightning_thunder_lance_canonical_hotbar_action_emits_runtime_active_payload_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(20, 4)
	player.facing = -1
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "lightning_thunder_lance"))
	assert_eq(str(manager.get_slot_bindings()[2].get("skill_id", "")), "volt_spear")
	var runtime: Dictionary = GameState.get_spell_runtime("volt_spear")
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var action := _get_slot_action(manager, 2)
	assert_true(manager.attempt_cast_by_action(action))
	assert_eq(payloads.size(), 1)
	var payload: Dictionary = payloads[0]
	assert_eq(str(payload.get("spell_id", "")), "volt_spear")
	assert_eq(str(payload.get("school", "")), str(runtime.get("school", "")))
	assert_eq(str(payload.get("attack_effect_id", "")), "volt_spear_attack")
	assert_eq(str(payload.get("hit_effect_id", "")), "volt_spear_hit")
	_assert_active_lead_payload_matches_runtime(payload, runtime, "lightning_thunder_lance")
	assert_lt(float(payload.get("velocity", Vector2.ZERO).x), 0.0, "Thunder Lance must keep directional lance velocity on canonical hotbar cast")
	_assert_numeric_payload_field_matches(
		payload,
		runtime,
		"pierce",
		"lightning_thunder_lance canonical input must keep runtime pierce after proxy normalization"
	)


func test_earth_quake_break_canonical_hotbar_action_emits_runtime_active_payload_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(14, 8)
	player.facing = 1
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "earth_quake_break"))
	assert_eq(str(manager.get_slot_bindings()[2].get("skill_id", "")), "earth_tremor")
	var runtime: Dictionary = GameState.get_spell_runtime("earth_tremor")
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var action := _get_slot_action(manager, 2)
	assert_true(manager.attempt_cast_by_action(action))
	assert_eq(payloads.size(), 1)
	var payload: Dictionary = payloads[0]
	assert_eq(str(payload.get("spell_id", "")), "earth_tremor")
	assert_eq(str(payload.get("school", "")), str(runtime.get("school", "")))
	assert_eq(str(payload.get("attack_effect_id", "")), "earth_tremor_attack")
	assert_eq(str(payload.get("hit_effect_id", "")), "earth_tremor_hit")
	_assert_active_lead_payload_matches_runtime(payload, runtime, "earth_quake_break")
	_assert_numeric_payload_field_matches(
		payload,
		runtime,
		"cooldown",
		"earth_quake_break canonical input must keep runtime cooldown after proxy normalization"
	)


func test_high_circle_stationary_magic_runtime_bonus_makes_area_growth_readable() -> void:
	GameState.reset_progress_for_tests()
	var base_spell := GameDatabase.get_spell("holy_judgment_halo")
	var runtime := GameState.get_spell_runtime("holy_judgment_halo")
	assert_gt(
		float(runtime.get("size", 0.0)),
		float(base_spell.get("size", 0.0)) * 2.4,
		"10-circle stationary halo burst must feel dramatically wider than its authored base radius"
	)
	assert_gt(
		float(runtime.get("range", 0.0)),
		float(base_spell.get("range", 0.0)) * 2.2,
		"10-circle stationary halo burst must gain a clearly wider attack footprint than its base range"
	)


func test_high_circle_line_magic_runtime_bonus_keeps_long_range_growth_without_tripling_it() -> void:
	GameState.reset_progress_for_tests()
	var base_spell := GameDatabase.get_spell("water_tsunami")
	var runtime := GameState.get_spell_runtime("water_tsunami")
	assert_gt(
		float(runtime.get("range", 0.0)),
		float(base_spell.get("range", 0.0)) * 1.3,
		"7-circle line magic must extend meaningfully beyond its authored travel distance"
	)
	assert_lt(
		float(runtime.get("range", 0.0)),
		float(base_spell.get("range", 0.0)) * 1.6,
		"7-circle line magic should grow strongly but not explode into full-screen travel"
	)


func test_high_circle_deploy_runtime_bonus_expands_size_and_duration_together() -> void:
	GameState.reset_progress_for_tests()
	var skill_id := "fire_hellfire_field"
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	var runtime := GameState.get_data_driven_skill_runtime(skill_id, skill_data)
	assert_gt(
		float(runtime.get("size", 0.0)),
		float(skill_data.get("range_base", 0.0)) * 2.0,
		"8-circle deploy fields must feel substantially broader than their catalog radius"
	)
	assert_gt(
		float(runtime.get("duration", 0.0)),
		float(skill_data.get("duration_base", 0.0)) * 1.15,
		"8-circle deploy fields should persist longer when their footprint expands"
	)


func test_large_stationary_burst_builds_ground_telegraph_matching_radius() -> void:
	var projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 160.0,
		"duration": 0.44,
		"team": "player",
		"damage": 78,
		"knockback": 360.0,
		"school": "holy",
		"size": 150.0,
		"spell_id": "holy_judgment_halo",
		"attack_effect_id": "holy_judgment_halo_attack",
		"hit_effect_id": "holy_judgment_halo_hit",
		"terminal_effect_id": "holy_judgment_halo_end",
		"color": "#fff8d2"
	})
	var telegraph := _get_ground_telegraph(projectile)
	assert_true(telegraph != null, "large stationary bursts must build a procedural ground telegraph that matches their footprint")
	assert_eq(str(telegraph.get_meta("visual_role", "")), "ground_telegraph")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "burst")
	assert_almost_eq(float(telegraph.get_meta("telegraph_radius", 0.0)), 150.0, 0.001)
	assert_almost_eq(float(telegraph.scale.y), 0.42, 0.001, "ground telegraph must stay as a flattened floor ellipse in side view")


func test_large_stationary_burst_ground_telegraph_plays_startup_ring_intro() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 168.0,
		"duration": 0.44,
		"team": "player",
		"damage": 78,
		"knockback": 360.0,
		"school": "holy",
		"size": 150.0,
		"spell_id": "holy_judgment_halo",
		"attack_effect_id": "holy_judgment_halo_attack",
		"hit_effect_id": "holy_judgment_halo_hit",
		"terminal_effect_id": "holy_judgment_halo_end",
		"color": "#fff8d2"
	})
	root.add_child(projectile)
	await _advance_frames(1)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(startup_ring != null, "large stationary bursts must expose a startup ring so the cast warning is distinct from the body visual")
	assert_lt(
		startup_ring.scale.x,
		float(startup_ring.get_meta("phase_expand_scale", 1.0)),
		"startup ring should begin below its authored expansion target before it spreads outward"
	)
	await _advance_frames(20)
	assert_true(
		_get_ground_telegraph_startup_ring(projectile) == null,
		"startup ring should clear after its short intro pulse so the steady telegraph can take over"
	)


func test_school_phase_profiles_make_fire_startup_ring_faster_and_thicker_than_ice() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var fire_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	fire_projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 196.0,
		"duration": 8.0,
		"team": "player",
		"damage": 22,
		"knockback": 0.0,
		"school": "fire",
		"size": 196.0,
		"spell_id": "fire_hellfire_field",
		"attack_effect_id": "fire_hellfire_field_attack",
		"hit_effect_id": "fire_hellfire_field_hit",
		"terminal_effect_id": "fire_hellfire_field_end",
		"tick_interval": 1.0,
		"color": "#ffcc8d"
	})
	var ice_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	ice_projectile.setup({
		"position": Vector2(260.0, 0.0),
		"velocity": Vector2.ZERO,
		"range": 176.0,
		"duration": 8.0,
		"team": "player",
		"damage": 22,
		"knockback": 0.0,
		"school": "ice",
		"size": 176.0,
		"spell_id": "ice_storm",
		"attack_effect_id": "ice_storm_attack",
		"hit_effect_id": "ice_storm_hit",
		"terminal_effect_id": "ice_storm_end",
		"tick_interval": 1.0,
		"color": "#d8f6ff"
	})
	root.add_child(fire_projectile)
	root.add_child(ice_projectile)
	await _advance_frames(1)
	var fire_ring := _get_ground_telegraph_startup_ring(fire_projectile)
	var ice_ring := _get_ground_telegraph_startup_ring(ice_projectile)
	assert_true(fire_ring != null and ice_ring != null, "fire and ice large telegraphs should both expose startup rings")
	assert_lt(
		float(fire_ring.get_meta("phase_duration", 0.0)),
		float(ice_ring.get_meta("phase_duration", 0.0)),
		"fire startup ring should resolve faster than ice so explosive bursts feel snappier"
	)
	assert_gt(
		fire_ring.width,
		ice_ring.width,
		"fire startup ring should read thicker than ice so explosive danger reads hotter and heavier"
	)


func test_persistent_field_builds_ground_telegraph_with_inner_ring() -> void:
	var projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 196.0,
		"duration": 8.0,
		"team": "player",
		"damage": 22,
		"knockback": 0.0,
		"school": "fire",
		"size": 196.0,
		"spell_id": "fire_hellfire_field",
		"attack_effect_id": "fire_hellfire_field_attack",
		"hit_effect_id": "fire_hellfire_field_hit",
		"terminal_effect_id": "fire_hellfire_field_end",
		"tick_interval": 1.0,
		"color": "#ffcc8d"
	})
	var telegraph := _get_ground_telegraph(projectile)
	assert_true(telegraph != null, "large persistent fields must keep a procedural ground telegraph under the loop visual")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "persistent")
	assert_true(
		telegraph.get_node_or_null("InnerOutline") != null,
		"persistent fields should add an inner contour so the live damage zone reads more clearly"
	)


func test_moving_projectile_does_not_build_ground_telegraph() -> void:
	var projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(220.0, 0.0),
		"range": 520.0,
		"team": "player",
		"damage": 40,
		"knockback": 340.0,
		"school": "water",
		"size": 56.0,
		"pierce": 5,
		"spell_id": "water_tsunami",
		"attack_effect_id": "water_tsunami_attack",
		"hit_effect_id": "water_tsunami_hit",
		"terminal_effect_id": "water_tsunami_end",
		"color": "#a2f2ff"
	})
	assert_true(
		_get_ground_telegraph(projectile) == null,
		"moving line projectiles should keep their travel-body read instead of drawing a stationary floor telegraph"
	)


func test_large_stationary_burst_finish_spawns_terminal_flash_alongside_terminal_sprite() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 168.0,
		"duration": 0.44,
		"team": "player",
		"damage": 78,
		"knockback": 360.0,
		"school": "holy",
		"size": 150.0,
		"spell_id": "holy_judgment_halo",
		"attack_effect_id": "holy_judgment_halo_attack",
		"hit_effect_id": "holy_judgment_halo_hit",
		"terminal_effect_id": "holy_judgment_halo_end",
		"color": "#fff8d2"
	})
	root.add_child(projectile)
	await _advance_frames(2)
	projectile._finish_projectile()
	await _advance_frames(1)
	assert_true(projectile.terminal_effect_played, "large stationary bursts should still swap into their authored terminal effect")
	var terminal_flash := _get_terminal_flash(projectile)
	assert_true(terminal_flash != null, "large stationary bursts should add a procedural terminal flash so the ending read separates from startup warning")
	assert_eq(str(terminal_flash.get_meta("visual_role", "")), "terminal_flash")
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "terminal flash must complement, not replace, the authored terminal sprite when one exists")


func test_moving_projectile_finish_does_not_spawn_terminal_flash_overlay() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(220.0, 0.0),
		"range": 520.0,
		"duration": 0.44,
		"team": "player",
		"damage": 40,
		"knockback": 340.0,
		"school": "water",
		"size": 56.0,
		"pierce": 5,
		"spell_id": "water_tsunami",
		"attack_effect_id": "water_tsunami_attack",
		"hit_effect_id": "water_tsunami_hit",
		"terminal_effect_id": "water_tsunami_end",
		"color": "#a2f2ff"
	})
	root.add_child(projectile)
	await _advance_frames(2)
	projectile._finish_projectile()
	await _advance_frames(1)
	assert_true(
		_get_terminal_flash(projectile) == null,
		"moving projectiles should keep their travel impact ending without adding a floor-anchored terminal flash"
	)


func test_school_phase_profiles_make_wind_terminal_flash_sharper_than_earth() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var wind_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	wind_projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 190.0,
		"duration": 0.44,
		"team": "player",
		"damage": 62,
		"knockback": 280.0,
		"school": "wind",
		"size": 170.0,
		"spell_id": "wind_storm",
		"attack_effect_id": "wind_storm_attack",
		"hit_effect_id": "wind_storm_hit",
		"color": "#e4ffe1"
	})
	var earth_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	earth_projectile.setup({
		"position": Vector2(260.0, 0.0),
		"velocity": Vector2.ZERO,
		"range": 210.0,
		"duration": 0.44,
		"team": "player",
		"damage": 88,
		"knockback": 360.0,
		"school": "earth",
		"size": 190.0,
		"spell_id": "earth_gaia_break",
		"attack_effect_id": "earth_gaia_break_attack",
		"hit_effect_id": "earth_gaia_break_hit",
		"terminal_effect_id": "earth_gaia_break_end",
		"color": "#ead3ad"
	})
	root.add_child(wind_projectile)
	root.add_child(earth_projectile)
	await _advance_frames(2)
	wind_projectile._finish_projectile()
	earth_projectile._finish_projectile()
	await _advance_frames(1)
	var wind_flash := _get_terminal_flash(wind_projectile)
	var earth_flash := _get_terminal_flash(earth_projectile)
	var wind_outline := _get_terminal_flash_outline(wind_projectile)
	var earth_outline := _get_terminal_flash_outline(earth_projectile)
	assert_true(wind_flash != null and earth_flash != null, "wind and earth stationary bursts should both build terminal flashes")
	assert_true(wind_outline != null and earth_outline != null, "terminal flash profile checks need the outline layer to exist")
	assert_lt(
		float(wind_flash.get_meta("phase_duration", 0.0)),
		float(earth_flash.get_meta("phase_duration", 0.0)),
		"wind terminal flash should resolve faster than earth so the finish reads like a slicing gust instead of a heavy collapse"
	)
	assert_gt(
		float(wind_flash.get_meta("phase_expand_scale", 0.0)),
		float(earth_flash.get_meta("phase_expand_scale", 0.0)),
		"wind terminal flash should spread farther than earth so the ending reads like a quick outward burst"
	)
	assert_lt(
		wind_outline.width,
		earth_outline.width,
		"wind terminal flash should stay thinner than earth so earth keeps the heaviest collapse silhouette"
	)


func test_fire_signature_profiles_make_solar_cataclysm_broader_and_slower_than_inferno_buster() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var inferno_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	inferno_projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 180.0,
		"duration": 0.44,
		"team": "player",
		"damage": 74,
		"knockback": 320.0,
		"school": "fire",
		"size": 168.0,
		"spell_id": "fire_inferno_buster",
		"attack_effect_id": "fire_inferno_buster_attack",
		"hit_effect_id": "fire_inferno_buster_hit",
		"color": "#ffd09c"
	})
	var solar_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	solar_projectile.setup({
		"position": Vector2(280.0, 0.0),
		"velocity": Vector2.ZERO,
		"range": 208.0,
		"duration": 0.44,
		"team": "player",
		"damage": 112,
		"knockback": 420.0,
		"school": "fire",
		"size": 220.0,
		"spell_id": "fire_solar_cataclysm",
		"attack_effect_id": "fire_solar_cataclysm_attack",
		"hit_effect_id": "fire_solar_cataclysm_hit",
		"terminal_effect_id": "fire_solar_cataclysm_end",
		"color": "#fff3d6"
	})
	root.add_child(inferno_projectile)
	root.add_child(solar_projectile)
	await _advance_frames(1)
	var inferno_ring := _get_ground_telegraph_startup_ring(inferno_projectile)
	var solar_ring := _get_ground_telegraph_startup_ring(solar_projectile)
	assert_true(inferno_ring != null and solar_ring != null, "fire signature comparison needs both startup rings to exist")
	assert_eq(str(inferno_ring.get_meta("phase_signature", "")), "fire_inferno_buster")
	assert_eq(str(solar_ring.get_meta("phase_signature", "")), "fire_solar_cataclysm")
	assert_lt(
		float(inferno_ring.get_meta("phase_duration", 0.0)),
		float(solar_ring.get_meta("phase_duration", 0.0)),
		"inferno_buster startup should resolve faster than solar_cataclysm so the mid-tier burst feels more compressed"
	)
	assert_lt(
		float(inferno_ring.get_meta("phase_expand_scale", 0.0)),
		float(solar_ring.get_meta("phase_expand_scale", 0.0)),
		"solar_cataclysm startup should end wider than inferno_buster so the final fire signature reads larger inside the same school"
	)
	inferno_projectile._finish_projectile()
	solar_projectile._finish_projectile()
	await _advance_frames(1)
	var inferno_flash := _get_terminal_flash(inferno_projectile)
	var solar_flash := _get_terminal_flash(solar_projectile)
	var inferno_outline := _get_terminal_flash_outline(inferno_projectile)
	var solar_outline := _get_terminal_flash_outline(solar_projectile)
	assert_true(inferno_flash != null and solar_flash != null, "fire signature comparison needs both terminal flashes to exist")
	assert_true(inferno_outline != null and solar_outline != null, "fire terminal signature comparison needs both outlines")
	assert_lt(
		float(inferno_flash.get_meta("phase_duration", 0.0)),
		float(solar_flash.get_meta("phase_duration", 0.0)),
		"solar_cataclysm terminal flash should linger longer than inferno_buster to sell the final collapse tier"
	)
	assert_gt(
		float(solar_flash.get_meta("phase_expand_scale", 0.0)),
		float(inferno_flash.get_meta("phase_expand_scale", 0.0)),
		"solar_cataclysm terminal flash should spread farther than inferno_buster within the fire family"
	)
	assert_gt(
		solar_outline.width,
		inferno_outline.width,
		"solar_cataclysm terminal outline should stay heavier than inferno_buster so the final fire burst keeps its own signature"
	)


func test_earth_signature_profiles_make_world_end_break_heavier_than_gaia_break() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var gaia_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	gaia_projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 188.0,
		"duration": 0.44,
		"team": "player",
		"damage": 84,
		"knockback": 380.0,
		"school": "earth",
		"size": 178.0,
		"spell_id": "earth_gaia_break",
		"attack_effect_id": "earth_gaia_break_attack",
		"hit_effect_id": "earth_gaia_break_hit",
		"terminal_effect_id": "earth_gaia_break_end",
		"color": "#ead3ad"
	})
	var world_end_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	world_end_projectile.setup({
		"position": Vector2(300.0, 0.0),
		"velocity": Vector2.ZERO,
		"range": 236.0,
		"duration": 0.44,
		"team": "player",
		"damage": 124,
		"knockback": 460.0,
		"school": "earth",
		"size": 228.0,
		"spell_id": "earth_world_end_break",
		"attack_effect_id": "earth_world_end_break_attack",
		"hit_effect_id": "earth_world_end_break_hit",
		"terminal_effect_id": "earth_world_end_break_end",
		"color": "#f3e1bf"
	})
	root.add_child(gaia_projectile)
	root.add_child(world_end_projectile)
	await _advance_frames(1)
	var gaia_ring := _get_ground_telegraph_startup_ring(gaia_projectile)
	var world_end_ring := _get_ground_telegraph_startup_ring(world_end_projectile)
	assert_true(gaia_ring != null and world_end_ring != null, "earth signature comparison needs both startup rings to exist")
	assert_eq(str(gaia_ring.get_meta("phase_signature", "")), "earth_gaia_break")
	assert_eq(str(world_end_ring.get_meta("phase_signature", "")), "earth_world_end_break")
	assert_lt(
		float(gaia_ring.get_meta("phase_duration", 0.0)),
		float(world_end_ring.get_meta("phase_duration", 0.0)),
		"world_end_break startup should resolve slower than gaia_break so the final earth cast feels weightier"
	)
	assert_lt(
		float(gaia_ring.get_meta("phase_width_scale", 0.0)),
		float(world_end_ring.get_meta("phase_width_scale", 0.0)),
		"world_end_break startup ring should be thicker than gaia_break so the collapse read escalates inside the earth family"
	)
	gaia_projectile._finish_projectile()
	world_end_projectile._finish_projectile()
	await _advance_frames(1)
	var gaia_flash := _get_terminal_flash(gaia_projectile)
	var world_end_flash := _get_terminal_flash(world_end_projectile)
	var gaia_outline := _get_terminal_flash_outline(gaia_projectile)
	var world_end_outline := _get_terminal_flash_outline(world_end_projectile)
	assert_true(gaia_flash != null and world_end_flash != null, "earth signature comparison needs both terminal flashes to exist")
	assert_true(gaia_outline != null and world_end_outline != null, "earth terminal signature comparison needs both outlines")
	assert_lt(
		float(gaia_flash.get_meta("phase_duration", 0.0)),
		float(world_end_flash.get_meta("phase_duration", 0.0)),
		"world_end_break terminal flash should last longer than gaia_break so the final collapse leaves a heavier after-read"
	)
	assert_lt(
		float(gaia_flash.get_meta("phase_expand_scale", 0.0)),
		float(world_end_flash.get_meta("phase_expand_scale", 0.0)),
		"world_end_break terminal flash should spread farther than gaia_break so the final earth signature reads more apocalyptic"
	)
	assert_lt(
		float(gaia_flash.get_meta("phase_outline_width_scale", 0.0)),
		float(world_end_flash.get_meta("phase_outline_width_scale", 0.0)),
		"world_end_break terminal outline should stay thicker than gaia_break to preserve the heaviest collapse silhouette"
	)


func test_holy_signature_profiles_make_judgment_halo_faster_and_cleaner_than_bless_field() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var bless_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	bless_projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 176.0,
		"duration": 8.0,
		"team": "player",
		"damage": 22,
		"knockback": 0.0,
		"school": "holy",
		"size": 172.0,
		"spell_id": "holy_bless_field",
		"attack_effect_id": "holy_bless_field_attack",
		"hit_effect_id": "holy_bless_field_hit",
		"terminal_effect_id": "holy_bless_field_end",
		"tick_interval": 1.0,
		"color": "#fff1c2"
	})
	var judgment_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	judgment_projectile.setup({
		"position": Vector2(280.0, 0.0),
		"velocity": Vector2.ZERO,
		"range": 168.0,
		"duration": 0.44,
		"team": "player",
		"damage": 84,
		"knockback": 360.0,
		"school": "holy",
		"size": 168.0,
		"spell_id": "holy_judgment_halo",
		"attack_effect_id": "holy_judgment_halo_attack",
		"hit_effect_id": "holy_judgment_halo_hit",
		"terminal_effect_id": "holy_judgment_halo_end",
		"color": "#fff8d2"
	})
	root.add_child(bless_projectile)
	root.add_child(judgment_projectile)
	await _advance_frames(1)
	var bless_ring := _get_ground_telegraph_startup_ring(bless_projectile)
	var judgment_ring := _get_ground_telegraph_startup_ring(judgment_projectile)
	assert_true(bless_ring != null and judgment_ring != null, "holy signature comparison needs both startup rings to exist")
	assert_eq(str(bless_ring.get_meta("phase_signature", "")), "holy_bless_field")
	assert_eq(str(judgment_ring.get_meta("phase_signature", "")), "holy_judgment_halo")
	assert_lt(
		float(judgment_ring.get_meta("phase_duration", 0.0)),
		float(bless_ring.get_meta("phase_duration", 0.0)),
		"judgment_halo startup should resolve faster than bless_field so the final holy burst feels more decisive than a sustain field"
	)
	assert_gt(
		float(judgment_ring.get_meta("phase_expand_scale", 0.0)),
		float(bless_ring.get_meta("phase_expand_scale", 0.0)),
		"judgment_halo startup should flare wider than bless_field so the holy finisher reads as a sharper verdict mark"
	)
	bless_projectile._finish_projectile()
	judgment_projectile._finish_projectile()
	await _advance_frames(1)
	var bless_flash := _get_terminal_flash(bless_projectile)
	var judgment_flash := _get_terminal_flash(judgment_projectile)
	assert_true(bless_flash != null and judgment_flash != null, "holy signature comparison needs both terminal flashes to exist")
	assert_lt(
		float(judgment_flash.get_meta("phase_duration", 0.0)),
		float(bless_flash.get_meta("phase_duration", 0.0)),
		"judgment_halo terminal flash should clear faster than bless_field so the burst ends cleanly instead of lingering like a sanctuary"
	)
	assert_gt(
		float(judgment_flash.get_meta("phase_expand_scale", 0.0)),
		float(bless_flash.get_meta("phase_expand_scale", 0.0)),
		"judgment_halo terminal flash should spread farther than bless_field so the final holy burst lands with a stronger closing read"
	)


func test_holy_bless_field_ground_telegraph_uses_dedicated_blessing_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(8.0, -4.0),
		"velocity": Vector2.ZERO,
		"range": 148.0,
		"duration": 6.0,
		"team": "player",
		"damage": 0,
		"school": "holy",
		"size": 148.0,
		"spell_id": "holy_bless_field",
		"attack_effect_id": "holy_bless_field_attack",
		"hit_effect_id": "holy_bless_field_hit",
		"terminal_effect_id": "holy_bless_field_end",
		"tick_interval": 1.0,
		"self_heal": 18,
		"support_effects": [{"stat": "poise_bonus", "mode": "add", "value": 12}],
		"support_effect_duration": 1.2,
		"color": "#ffefbd"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "holy_bless_field must expose a startup ground telegraph for blessing-field read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "persistent")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "holy_bless_field")
	assert_gt(
		float(startup_ring.get_meta("phase_width_scale", 0.0)),
		0.08,
		"holy_bless_field startup ring must stay broader than the generic holy lane so its support field read lands immediately"
	)
	projectile._finish_projectile()
	await _advance_frames(2)
	var terminal_flash := _get_terminal_flash(projectile)
	assert_true(terminal_flash != null, "holy_bless_field must keep a terminal flash when the blessing field closes")
	assert_eq(str(terminal_flash.get_meta("phase_signature", "")), "holy_bless_field")


func test_holy_sanctuary_of_reversal_ground_telegraph_uses_dedicated_reversal_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(12.0, -6.0),
		"velocity": Vector2.ZERO,
		"range": 156.0,
		"duration": 2.4,
		"team": "player",
		"damage": 0,
		"school": "holy",
		"size": 156.0,
		"spell_id": "holy_sanctuary_of_reversal",
		"attack_effect_id": "holy_sanctuary_of_reversal_attack",
		"hit_effect_id": "holy_sanctuary_of_reversal_hit",
		"terminal_effect_id": "holy_sanctuary_of_reversal_end",
		"tick_interval": 0.35,
		"self_heal": 35,
		"support_effects": [
			{"stat": "damage_taken_multiplier", "mode": "mul", "value": 0.62},
			{"stat": "poise_bonus", "mode": "add", "value": 20}
		],
		"support_effect_duration": 0.7,
		"color": "#fff7e8"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "holy_sanctuary_of_reversal must expose a startup ground telegraph for reversal-window read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "persistent")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "holy_sanctuary_of_reversal")
	assert_gt(
		float(startup_ring.get_meta("phase_width_scale", 0.0)),
		0.09,
		"holy_sanctuary_of_reversal startup ring must read denser than the generic holy field lane so the panic window lands immediately"
	)
	projectile._finish_projectile()
	await _advance_frames(2)
	var terminal_flash := _get_terminal_flash(projectile)
	assert_true(terminal_flash != null, "holy_sanctuary_of_reversal must keep a terminal flash when the survival window closes")
	assert_eq(str(terminal_flash.get_meta("phase_signature", "")), "holy_sanctuary_of_reversal")


func test_holy_judgment_halo_ground_telegraph_uses_dedicated_verdict_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -6.0),
		"velocity": Vector2.ZERO,
		"range": 160.0,
		"duration": 0.44,
		"team": "player",
		"damage": 78,
		"knockback": 360.0,
		"school": "holy",
		"size": 150.0,
		"spell_id": "holy_judgment_halo",
		"attack_effect_id": "holy_judgment_halo_attack",
		"hit_effect_id": "holy_judgment_halo_hit",
		"terminal_effect_id": "holy_judgment_halo_end",
		"color": "#fff8d2"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "holy_judgment_halo must expose a startup ground telegraph for final verdict read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "burst")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "holy_judgment_halo")
	assert_gt(
		float(startup_ring.get_meta("phase_expand_scale", 0.0)),
		1.1,
		"holy_judgment_halo startup ring must flare wider than the generic holy lane so the final verdict read lands immediately"
	)
	projectile._finish_projectile()
	await _advance_frames(2)
	var terminal_flash := _get_terminal_flash(projectile)
	assert_true(terminal_flash != null, "holy_judgment_halo must keep a terminal flash when the verdict burst closes")
	assert_eq(str(terminal_flash.get_meta("phase_signature", "")), "holy_judgment_halo")


func test_fire_meteor_strike_ground_telegraph_uses_dedicated_meteor_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -6.0),
		"velocity": Vector2.ZERO,
		"range": 184.0,
		"duration": 0.46,
		"team": "player",
		"damage": 54,
		"knockback": 300.0,
		"school": "fire",
		"size": 184.0,
		"spell_id": "fire_meteor_strike",
		"attack_effect_id": "fire_meteor_strike_attack",
		"hit_effect_id": "fire_meteor_strike_hit",
		"terminal_effect_id": "fire_meteor_strike_end",
		"color": "#ffd29a"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "fire_meteor_strike must expose a startup ground telegraph for delayed meteor read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "burst")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "fire_meteor_strike")
	assert_gt(
		float(startup_ring.get_meta("phase_expand_scale", 0.0)),
		1.24,
		"fire_meteor_strike startup ring must flare wider than the generic fire lane so the impact landing point reads immediately"
	)
	projectile._finish_projectile()
	await _advance_frames(2)
	var terminal_flash := _get_terminal_flash(projectile)
	assert_true(terminal_flash != null, "fire_meteor_strike must keep a terminal flash when the meteor burst resolves")
	assert_eq(str(terminal_flash.get_meta("phase_signature", "")), "fire_meteor_strike")


func test_fire_apocalypse_flame_ground_telegraph_uses_dedicated_apocalypse_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 204.0,
		"duration": 0.52,
		"team": "player",
		"damage": 68,
		"knockback": 340.0,
		"school": "fire",
		"size": 204.0,
		"spell_id": "fire_apocalypse_flame",
		"attack_effect_id": "fire_apocalypse_flame_attack",
		"hit_effect_id": "fire_apocalypse_flame_hit",
		"terminal_effect_id": "fire_apocalypse_flame_end",
		"color": "#ffe1b2"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "fire_apocalypse_flame must expose a startup ground telegraph for apocalypse read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "burst")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "fire_apocalypse_flame")
	assert_gt(
		float(startup_ring.get_meta("phase_expand_scale", 0.0)),
		1.28,
		"fire_apocalypse_flame startup ring must flare wider than meteor_strike so the larger collapse reads immediately"
	)
	projectile._finish_projectile()
	await _advance_frames(2)
	var terminal_flash := _get_terminal_flash(projectile)
	assert_true(terminal_flash != null, "fire_apocalypse_flame must keep a terminal flash when the apocalypse burst resolves")
	assert_eq(str(terminal_flash.get_meta("phase_signature", "")), "fire_apocalypse_flame")


func test_fire_solar_cataclysm_ground_telegraph_uses_dedicated_solar_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -10.0),
		"velocity": Vector2.ZERO,
		"range": 218.0,
		"duration": 0.56,
		"team": "player",
		"damage": 74,
		"knockback": 380.0,
		"school": "fire",
		"size": 218.0,
		"spell_id": "fire_solar_cataclysm",
		"attack_effect_id": "fire_solar_cataclysm_attack",
		"hit_effect_id": "fire_solar_cataclysm_hit",
		"terminal_effect_id": "fire_solar_cataclysm_end",
		"color": "#fff0c6"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "fire_solar_cataclysm must expose a startup ground telegraph for solar collapse read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "burst")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "fire_solar_cataclysm")
	assert_gt(
		float(startup_ring.get_meta("phase_expand_scale", 0.0)),
		1.30,
		"fire_solar_cataclysm startup ring must flare wider than apocalypse_flame so the final solar collapse reads immediately"
	)
	projectile._finish_projectile()
	await _advance_frames(2)
	var terminal_flash := _get_terminal_flash(projectile)
	assert_true(terminal_flash != null, "fire_solar_cataclysm must keep a terminal flash when the solar burst resolves")
	assert_eq(str(terminal_flash.get_meta("phase_signature", "")), "fire_solar_cataclysm")


func test_earth_continental_crush_ground_telegraph_uses_dedicated_collapse_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -9.0),
		"velocity": Vector2.ZERO,
		"range": 198.0,
		"duration": 0.48,
		"team": "player",
		"damage": 64,
		"knockback": 460.0,
		"school": "earth",
		"size": 198.0,
		"spell_id": "earth_continental_crush",
		"attack_effect_id": "earth_continental_crush_attack",
		"hit_effect_id": "earth_continental_crush_hit",
		"terminal_effect_id": "earth_continental_crush_end",
		"color": "#dfc295"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "earth_continental_crush must expose a startup ground telegraph for ultimate collapse read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "burst")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "earth_continental_crush")
	assert_gt(
		float(startup_ring.get_meta("phase_expand_scale", 0.0)),
		1.08,
		"earth_continental_crush startup ring must flare wider than gaia_break so the higher collapse tier reads immediately"
	)
	projectile._finish_projectile()
	await _advance_frames(2)
	var terminal_flash := _get_terminal_flash(projectile)
	assert_true(terminal_flash != null, "earth_continental_crush must keep a terminal flash when the continental collapse resolves")
	assert_eq(str(terminal_flash.get_meta("phase_signature", "")), "earth_continental_crush")


func test_wind_heavenly_storm_ground_telegraph_uses_dedicated_heavenly_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 188.0,
		"duration": 0.42,
		"team": "player",
		"damage": 60,
		"knockback": 300.0,
		"school": "wind",
		"size": 188.0,
		"spell_id": "wind_heavenly_storm",
		"attack_effect_id": "wind_heavenly_storm_attack",
		"hit_effect_id": "wind_heavenly_storm_hit",
		"color": "#e6ffe0"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "wind_heavenly_storm must expose a startup ground telegraph for heavenly burst read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "burst")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "wind_heavenly_storm")
	assert_gt(
		float(startup_ring.get_meta("phase_expand_scale", 0.0)),
		1.13,
		"wind_heavenly_storm startup ring must flare wider than wind_storm so the ultimate heavenly burst reads immediately"
	)


func test_wind_storm_ground_telegraph_uses_dedicated_storm_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 148.0,
		"duration": 0.36,
		"team": "player",
		"damage": 40,
		"knockback": 240.0,
		"school": "wind",
		"size": 148.0,
		"spell_id": "wind_storm",
		"attack_effect_id": "wind_storm_attack",
		"hit_effect_id": "wind_storm_hit",
		"color": "#d6ffd5"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "wind_storm must expose a startup ground telegraph for storm burst read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "burst")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "wind_storm")
	assert_gt(
		float(startup_ring.get_meta("phase_expand_scale", 0.0)),
		1.09,
		"wind_storm startup ring must flare beyond the generic wind baseline so the stationary burst reads immediately"
	)


func test_plant_signature_profiles_make_genesis_arbor_heavier_than_worldroot_bastion() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var bastion_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	bastion_projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 196.0,
		"duration": 8.0,
		"team": "player",
		"damage": 28,
		"knockback": 0.0,
		"school": "plant",
		"size": 196.0,
		"spell_id": "plant_worldroot_bastion",
		"attack_effect_id": "plant_worldroot_bastion_attack",
		"hit_effect_id": "plant_worldroot_bastion_hit",
		"terminal_effect_id": "plant_worldroot_bastion_end",
		"tick_interval": 1.0,
		"color": "#c0dfa0"
	})
	var genesis_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	genesis_projectile.setup({
		"position": Vector2(320.0, 0.0),
		"velocity": Vector2.ZERO,
		"range": 220.0,
		"duration": 8.0,
		"team": "player",
		"damage": 34,
		"knockback": 0.0,
		"school": "plant",
		"size": 220.0,
		"spell_id": "plant_genesis_arbor",
		"attack_effect_id": "plant_genesis_arbor_attack",
		"hit_effect_id": "plant_genesis_arbor_hit",
		"terminal_effect_id": "plant_genesis_arbor_end",
		"tick_interval": 1.0,
		"color": "#c7e7a2"
	})
	root.add_child(bastion_projectile)
	root.add_child(genesis_projectile)
	await _advance_frames(1)
	var bastion_ring := _get_ground_telegraph_startup_ring(bastion_projectile)
	var genesis_ring := _get_ground_telegraph_startup_ring(genesis_projectile)
	assert_true(bastion_ring != null and genesis_ring != null, "plant signature comparison needs both startup rings to exist")
	assert_eq(str(bastion_ring.get_meta("phase_signature", "")), "plant")
	assert_eq(str(genesis_ring.get_meta("phase_signature", "")), "plant_genesis_arbor")
	assert_lt(
		float(bastion_ring.get_meta("phase_duration", 0.0)),
		float(genesis_ring.get_meta("phase_duration", 0.0)),
		"genesis_arbor startup should resolve slower than worldroot_bastion so the final plant canopy feels more deliberate and heavy"
	)
	assert_lt(
		float(bastion_ring.get_meta("phase_width_scale", 0.0)),
		float(genesis_ring.get_meta("phase_width_scale", 0.0)),
		"genesis_arbor startup ring should be thicker than worldroot_bastion so the end-tier canopy read escalates within the plant school"
	)
	bastion_projectile._finish_projectile()
	genesis_projectile._finish_projectile()
	await _advance_frames(1)
	var bastion_flash := _get_terminal_flash(bastion_projectile)
	var genesis_flash := _get_terminal_flash(genesis_projectile)
	assert_true(bastion_flash != null and genesis_flash != null, "plant signature comparison needs both terminal flashes to exist")
	assert_lt(
		float(bastion_flash.get_meta("phase_duration", 0.0)),
		float(genesis_flash.get_meta("phase_duration", 0.0)),
		"genesis_arbor terminal flash should linger longer than worldroot_bastion so the final plant field leaves a fuller canopy after-read"
	)
	assert_lt(
		float(bastion_flash.get_meta("phase_expand_scale", 0.0)),
		float(genesis_flash.get_meta("phase_expand_scale", 0.0)),
		"genesis_arbor terminal flash should spread farther than worldroot_bastion so the final plant field reads as the broadest canopy"
	)


func test_ice_signature_profiles_make_absolute_zero_heavier_than_absolute_freeze() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var freeze_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	freeze_projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 156.0,
		"duration": 0.34,
		"team": "player",
		"damage": 42,
		"knockback": 220.0,
		"school": "ice",
		"size": 156.0,
		"spell_id": "ice_absolute_freeze",
		"attack_effect_id": "ice_absolute_freeze_attack",
		"hit_effect_id": "ice_absolute_freeze_hit",
		"color": "#d8fbff"
	})
	var zero_projectile: Area2D = autofree(SPELL_PROJECTILE_SCRIPT.new())
	zero_projectile.setup({
		"position": Vector2(300.0, 0.0),
		"velocity": Vector2.ZERO,
		"range": 216.0,
		"duration": 0.56,
		"team": "player",
		"damage": 70,
		"knockback": 260.0,
		"school": "ice",
		"size": 216.0,
		"spell_id": "ice_absolute_zero",
		"attack_effect_id": "ice_absolute_zero_attack",
		"hit_effect_id": "ice_absolute_zero_hit",
		"terminal_effect_id": "ice_absolute_zero_end",
		"color": "#f0feff"
	})
	root.add_child(freeze_projectile)
	root.add_child(zero_projectile)
	await _advance_frames(1)
	var freeze_ring := _get_ground_telegraph_startup_ring(freeze_projectile)
	var zero_ring := _get_ground_telegraph_startup_ring(zero_projectile)
	assert_true(freeze_ring != null and zero_ring != null, "ice signature comparison needs both startup rings to exist")
	assert_eq(str(freeze_ring.get_meta("phase_signature", "")), "ice_absolute_freeze")
	assert_eq(str(zero_ring.get_meta("phase_signature", "")), "ice_absolute_zero")
	assert_lt(
		float(freeze_ring.get_meta("phase_duration", 0.0)),
		float(zero_ring.get_meta("phase_duration", 0.0)),
		"absolute_zero startup should resolve slower than absolute_freeze so the final ice burst feels more oppressive"
	)
	assert_lt(
		float(freeze_ring.get_meta("phase_width_scale", 0.0)),
		float(zero_ring.get_meta("phase_width_scale", 0.0)),
		"absolute_zero startup ring should be thicker than absolute_freeze so the final freeze read deepens within the ice family"
	)
	freeze_projectile._finish_projectile()
	zero_projectile._finish_projectile()
	await _advance_frames(1)
	var freeze_flash := _get_terminal_flash(freeze_projectile)
	var zero_flash := _get_terminal_flash(zero_projectile)
	assert_true(freeze_flash != null and zero_flash != null, "ice signature comparison needs both terminal flashes to exist")
	assert_lt(
		float(freeze_flash.get_meta("phase_duration", 0.0)),
		float(zero_flash.get_meta("phase_duration", 0.0)),
		"absolute_zero terminal flash should linger longer than absolute_freeze so the final frost collapse leaves a deeper after-read"
	)
	assert_lt(
		float(freeze_flash.get_meta("phase_expand_scale", 0.0)),
		float(zero_flash.get_meta("phase_expand_scale", 0.0)),
		"absolute_zero terminal flash should spread farther than absolute_freeze so the final ice burst reads as the broadest cold collapse"
	)
	assert_lt(
		float(freeze_flash.get_meta("phase_outline_width_scale", 0.0)),
		float(zero_flash.get_meta("phase_outline_width_scale", 0.0)),
		"absolute_zero terminal outline should stay thicker than absolute_freeze to preserve the heaviest frost silhouette"
	)


func test_ice_ice_wall_ground_telegraph_uses_dedicated_wall_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(12.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 180.0,
		"duration": 2.0,
		"team": "player",
		"damage": 18,
		"knockback": 180.0,
		"school": "ice",
		"size": 180.0,
		"spell_id": "ice_ice_wall",
		"attack_effect_id": "ice_ice_wall_attack",
		"hit_effect_id": "ice_ice_wall_hit",
		"terminal_effect_id": "ice_ice_wall_end",
		"color": "#e8fdff"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "ice_ice_wall must expose a startup ground telegraph for wall read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "burst")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "ice_ice_wall")
	assert_gt(
		float(startup_ring.get_meta("phase_width_scale", 0.0)),
		0.13,
		"ice_ice_wall startup ring must use a thicker dedicated wall signature than the generic ice burst lane"
	)
	projectile._finish_projectile()
	await _advance_frames(2)
	var terminal_flash := _get_terminal_flash(projectile)
	assert_true(terminal_flash != null, "ice_ice_wall must keep a terminal flash when the wall shell collapses")
	assert_eq(str(terminal_flash.get_meta("phase_signature", "")), "ice_ice_wall")


func test_earth_stone_rampart_ground_telegraph_uses_dedicated_wall_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(16.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 168.0,
		"duration": 2.0,
		"team": "player",
		"damage": 14,
		"knockback": 180.0,
		"school": "earth",
		"size": 168.0,
		"spell_id": "earth_stone_rampart",
		"attack_effect_id": "earth_stone_rampart_attack",
		"hit_effect_id": "earth_stone_rampart_hit",
		"terminal_effect_id": "earth_stone_rampart_end",
		"color": "#e5c99c"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "earth_stone_rampart must expose a startup ground telegraph for wall read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "burst")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "earth_stone_rampart")
	assert_gt(
		float(startup_ring.get_meta("phase_width_scale", 0.0)),
		0.14,
		"earth_stone_rampart startup ring must stay thick enough to read as a heavy earth wall instead of a quake burst"
	)
	projectile._finish_projectile()
	await _advance_frames(2)
	var terminal_flash := _get_terminal_flash(projectile)
	assert_true(terminal_flash != null, "earth_stone_rampart must keep a terminal flash when the stone wall collapses")
	assert_eq(str(terminal_flash.get_meta("phase_signature", "")), "earth_stone_rampart")


func test_water_aqua_geyser_ground_telegraph_uses_dedicated_geyser_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(96.0, -6.0),
		"velocity": Vector2.ZERO,
		"range": 104.0,
		"duration": 0.36,
		"team": "player",
		"damage": 40,
		"knockback": 420.0,
		"school": "water",
		"size": 104.0,
		"spell_id": "water_aqua_geyser",
		"attack_effect_id": "water_aqua_geyser_attack",
		"hit_effect_id": "water_aqua_geyser_hit",
		"terminal_effect_id": "water_aqua_geyser_end",
		"color": "#8aeaff"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "water_aqua_geyser must expose a startup ground telegraph for fixed forward burst read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "burst")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "water_aqua_geyser")
	assert_gt(
		float(startup_ring.get_meta("phase_expand_scale", 0.0)),
		1.1,
		"water_aqua_geyser startup ring must flare wider than generic water so the forward burst landing point reads immediately"
	)
	projectile._finish_projectile()
	await _advance_frames(2)
	var terminal_flash := _get_terminal_flash(projectile)
	assert_true(terminal_flash != null, "water_aqua_geyser must keep a terminal flash when the geyser collapses")
	assert_eq(str(terminal_flash.get_meta("phase_signature", "")), "water_aqua_geyser")


func test_earth_quake_break_ground_telegraph_uses_dedicated_quake_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(6.0, -4.0),
		"velocity": Vector2.ZERO,
		"range": 88.0,
		"duration": 0.18,
		"team": "player",
		"damage": 20,
		"knockback": 380.0,
		"school": "earth",
		"size": 104.0,
		"spell_id": "earth_tremor",
		"attack_effect_id": "earth_tremor_attack",
		"hit_effect_id": "earth_tremor_hit",
		"color": "#d9c19b"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "earth_quake_break must expose a startup ground telegraph for quake read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "burst")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "earth_tremor")
	assert_gt(
		float(startup_ring.get_meta("phase_width_scale", 0.0)),
		0.09,
		"earth_quake_break startup ring must keep a dedicated quake thickness above the generic default"
	)
	projectile._finish_projectile()
	await _advance_frames(2)
	var terminal_flash := _get_terminal_flash(projectile)
	assert_true(terminal_flash != null, "earth_quake_break must keep a terminal flash so the quake collapse resolves cleanly")
	assert_eq(str(terminal_flash.get_meta("phase_signature", "")), "earth_tremor")


func test_earth_quake_break_signature_reads_lighter_than_gaia_break() -> void:
	var quake = autofree(SPELL_PROJECTILE_SCRIPT.new())
	quake.setup({
		"position": Vector2(-24.0, -6.0),
		"velocity": Vector2.ZERO,
		"range": 88.0,
		"duration": 0.18,
		"team": "player",
		"damage": 20,
		"knockback": 380.0,
		"school": "earth",
		"size": 104.0,
		"spell_id": "earth_tremor",
		"attack_effect_id": "earth_tremor_attack",
		"hit_effect_id": "earth_tremor_hit",
		"color": "#d9c19b"
	})
	var gaia = autofree(SPELL_PROJECTILE_SCRIPT.new())
	gaia.setup({
		"position": Vector2(24.0, -6.0),
		"velocity": Vector2.ZERO,
		"range": 190.0,
		"duration": 0.34,
		"team": "player",
		"damage": 36,
		"knockback": 420.0,
		"school": "earth",
		"size": 192.0,
		"spell_id": "earth_gaia_break",
		"attack_effect_id": "earth_gaia_break_attack",
		"hit_effect_id": "earth_gaia_break_hit",
		"terminal_effect_id": "earth_gaia_break_end",
		"color": "#ead4ae"
	})
	add_child_autofree(quake)
	add_child_autofree(gaia)
	await _advance_frames(1)
	var quake_ring := _get_ground_telegraph_startup_ring(quake)
	var gaia_ring := _get_ground_telegraph_startup_ring(gaia)
	assert_true(quake_ring != null and gaia_ring != null, "earth signature comparison needs both startup rings to exist")
	assert_eq(str(quake_ring.get_meta("phase_signature", "")), "earth_tremor")
	assert_eq(str(gaia_ring.get_meta("phase_signature", "")), "earth_gaia_break")
	assert_lt(
		float(quake_ring.get_meta("phase_duration", 0.0)),
		float(gaia_ring.get_meta("phase_duration", 0.0)),
		"earth_quake_break startup ring should resolve faster than gaia_break so the stronger collapse tier still reads heavier"
	)
	assert_lt(
		float(quake_ring.get_meta("phase_width_scale", 0.0)),
		float(gaia_ring.get_meta("phase_width_scale", 0.0)),
		"earth_quake_break startup ring should stay thinner than gaia_break to preserve the later earth-family escalation"
	)
	quake._finish_projectile()
	gaia._finish_projectile()
	await _advance_frames(2)
	var quake_flash := _get_terminal_flash(quake)
	var gaia_flash := _get_terminal_flash(gaia)
	assert_true(quake_flash != null and gaia_flash != null, "earth signature comparison needs both terminal flashes to exist")
	assert_lt(
		float(quake_flash.get_meta("phase_duration", 0.0)),
		float(gaia_flash.get_meta("phase_duration", 0.0)),
		"earth_quake_break terminal flash should clear faster than gaia_break so the heavier collapse tier owns the longer after-read"
	)
	assert_lt(
		float(quake_flash.get_meta("phase_outline_width_scale", 0.0)),
		float(gaia_flash.get_meta("phase_outline_width_scale", 0.0)),
		"earth_quake_break terminal outline should stay thinner than gaia_break to keep the family hierarchy readable"
	)


func test_plant_root_bind_ground_telegraph_uses_dedicated_vine_bind_phase_signature() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(10.0, -6.0),
		"velocity": Vector2.ZERO,
		"range": 96.0,
		"duration": 5.0,
		"team": "player",
		"damage": 12,
		"knockback": 0.0,
		"school": "plant",
		"size": 96.0,
		"spell_id": "plant_vine_snare",
		"attack_effect_id": "plant_vine_snare_attack",
		"hit_effect_id": "plant_vine_snare_hit",
		"terminal_effect_id": "plant_vine_snare_end",
		"color": "#9fcf78"
	})
	add_child_autofree(projectile)
	await _advance_frames(1)
	var telegraph := _get_ground_telegraph(projectile)
	var startup_ring := _get_ground_telegraph_startup_ring(projectile)
	assert_true(telegraph != null and startup_ring != null, "plant_root_bind must expose a startup ground telegraph for vine-bind read")
	assert_eq(str(telegraph.get_meta("telegraph_mode", "")), "burst")
	assert_eq(str(startup_ring.get_meta("phase_signature", "")), "plant_vine_snare")
	assert_gt(
		float(startup_ring.get_meta("phase_width_scale", 0.0)),
		0.09,
		"plant_root_bind startup ring must use a tighter dedicated vine-bind signature than the generic plant field default"
	)
	projectile._finish_projectile()
	await _advance_frames(2)
	var terminal_flash := _get_terminal_flash(projectile)
	assert_true(terminal_flash != null, "plant_root_bind must keep a terminal flash when the bind field collapses")
	assert_eq(str(terminal_flash.get_meta("phase_signature", "")), "plant_vine_snare")


func test_earth_tremor_active_payload_uses_area_burst_hitstop_policy() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("earth_tremor"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "Instant area bursts must use the reduced area hitstop policy")


func test_frost_nova_active_payload_uses_area_burst_hitstop_policy() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("frost_nova"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "frost_nova")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "Frost Nova must inherit the instant area burst hitstop policy")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "freeze", "Frost Nova must act as the representative freeze burst")

func test_glacial_dominion_toggle_applies_slow_to_core_enemy_archetypes() -> void:
	for archetype in ENEMY_ARCHETYPE_CASES:
		GameState.reset_progress_for_tests()
		GameState.set_admin_ignore_cooldowns(true)
		GameState.set_admin_infinite_mana(true)
		var root := Node2D.new()
		add_child_autofree(root)
		var player = autofree(PLAYER_SCRIPT.new())
		player.global_position = Vector2.ZERO
		var manager = SPELL_MANAGER_SCRIPT.new()
		manager.setup(player)
		var enemy_type := str(archetype.get("type", ""))
		var enemy := _spawn_enemy_for_spell_coverage(root, enemy_type)
		enemy.target = null
		enemy.global_position = Vector2(56.0, -4.0)
		await _advance_frames(2)
		var payloads: Array = []
		manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
		assert_true(manager.attempt_cast("ice_glacial_dominion"), "Glacial Dominion must activate for %s archetype" % enemy_type)
		manager.tick(1.1)
		assert_true(payloads.size() >= 1, "Glacial Dominion must emit at least one aura tick for %s" % enemy_type)
		var projectile := _spawn_projectile_for_spell_coverage(
			root,
			_force_status_effect_rolls(payloads[payloads.size() - 1], 0.0)
		)
		await _advance_frames(10)
		assert_true(is_instance_valid(enemy), "Glacial Dominion should slow %s without instantly deleting it" % enemy_type)
		assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "Glacial Dominion must apply slow to %s" % enemy_type)
		assert_lt(enemy.slow_multiplier, 1.0, "Glacial Dominion must reduce movement multiplier for %s" % enemy_type)
		assert_lt(enemy.get_behavior_tempo_multiplier(), 1.0, "Glacial Dominion must also lower behavior tempo for %s" % enemy_type)
		enemy.attack_cooldown = enemy.attack_period
		enemy._tick_runtime_timers(0.5)
		assert_gt(
			enemy.attack_cooldown,
			maxf(enemy.attack_period - 0.5, 0.0),
			"Glacial Dominion slow must reduce cooldown recovery tempo for %s" % enemy_type
		)
		assert_gt(GameState.session_hit_count, 0, "Glacial Dominion must register a hit against %s" % enemy_type)
		if is_instance_valid(projectile):
			projectile.queue_free()
		Engine.time_scale = 1.0
		GameState.reset_progress_for_tests()
		root.queue_free()

func test_tempest_crown_toggle_emits_runtime_pierce_bonus() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	GameState.skill_level_data["lightning_tempest_crown"] = 24
	assert_true(manager.assign_skill_to_slot(2, "lightning_tempest_crown"))
	assert_true(manager.attempt_cast("lightning_tempest_crown"))
	manager.tick(0.2)
	assert_true(payloads.size() >= 1)
	assert_eq(int(payloads[0].get("pierce", 0)), 4)

func test_tempest_crown_toggle_pierce_scales_with_skill_milestones() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)

	var player_low = autofree(PLAYER_SCRIPT.new())
	var manager_low = SPELL_MANAGER_SCRIPT.new()
	manager_low.setup(player_low)
	var low_payloads: Array = []
	manager_low.spell_cast.connect(func(payload: Dictionary) -> void: low_payloads.append(payload))
	GameState.skill_level_data["lightning_tempest_crown"] = 1
	assert_true(manager_low.attempt_cast("lightning_tempest_crown"))
	manager_low.tick(2.0)
	assert_true(low_payloads.size() >= 1)
	var low_pierce: int = int(low_payloads[0].get("pierce", 0))
	assert_eq(low_pierce, 2, "Tempest Crown base pierce must stay at 2 below milestone levels")
	assert_true(manager_low.attempt_cast("lightning_tempest_crown"))

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)

	var player_high = autofree(PLAYER_SCRIPT.new())
	var manager_high = SPELL_MANAGER_SCRIPT.new()
	manager_high.setup(player_high)
	var high_payloads: Array = []
	manager_high.spell_cast.connect(func(payload: Dictionary) -> void: high_payloads.append(payload))
	GameState.skill_level_data["lightning_tempest_crown"] = 24
	assert_true(manager_high.attempt_cast("lightning_tempest_crown"))
	manager_high.tick(2.0)
	assert_true(high_payloads.size() >= 1)
	var high_pierce: int = int(high_payloads[0].get("pierce", 0))
	assert_eq(high_pierce, 4, "Tempest Crown milestone pierce must reach 4 at level 24")
	assert_gt(high_pierce, low_pierce, "Tempest Crown pierce must scale upward after milestone levels")
	assert_true(manager_high.attempt_cast("lightning_tempest_crown"))
	GameState.reset_progress_for_tests()

func test_toggle_summary_reports_active_toggle_tick_and_drain() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	var summary := manager.get_toggle_summary()
	assert_string_contains(summary, "프로즌 도메인")
	assert_string_contains(summary, "소모")
	assert_string_contains(summary, "slow")

func test_toggle_summary_reports_pierce_and_risk_tags() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "lightning_tempest_crown"))
	assert_true(manager.attempt_cast("lightning_tempest_crown"))
	var crown_summary := manager.get_toggle_summary()
	assert_string_contains(crown_summary, "pierce")
	assert_true(manager.attempt_cast("lightning_tempest_crown"))
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	var soul_summary := manager.get_toggle_summary()
	assert_string_contains(soul_summary, "risk")

func test_soul_dominion_blocks_mp_regen_while_active() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	GameState.mana = 24.0
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_true(GameState.soul_dominion_active)
	var mana_before := GameState.mana
	GameState._tick_mana_regeneration(2.0)
	assert_eq(GameState.mana, mana_before, "MP regen must be blocked while Soul Dominion is active")

func test_soul_dominion_increases_damage_taken_while_active() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_true(GameState.soul_dominion_active)
	var multiplier := GameState.get_damage_taken_multiplier()
	assert_true(multiplier >= GameState.SOUL_DOMINION_DAMAGE_TAKEN_MULT - 0.01)

func test_soul_dominion_starts_aftershock_on_toggle_off() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_false(GameState.soul_dominion_active)
	assert_gt(GameState.soul_dominion_aftershock_timer, 0.0)
	var mana_before := GameState.mana
	GameState._tick_mana_regeneration(2.0)
	assert_eq(GameState.mana, mana_before, "MP regen must be blocked during aftershock")

func test_soul_dominion_aftershock_clears_after_duration() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_gt(GameState.soul_dominion_aftershock_timer, 0.0)
	GameState._tick_buff_runtime(GameState.SOUL_DOMINION_AFTERSHOCK_DURATION + 0.1)
	assert_eq(GameState.soul_dominion_aftershock_timer, 0.0)
	GameState.mana = 100.0
	GameState._tick_mana_regeneration(1.0)
	assert_gt(GameState.mana, 100.0, "MP regen resumes after aftershock expires")

func test_hotbar_summary_shows_ready_marker_when_cooldown_is_zero() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	manager.reset_all_cooldowns()
	var summary := manager.get_hotbar_summary()
	assert_string_contains(summary, "---", "Ready slot must show --- not 0.0")
	assert_false(summary.contains(" 0.0"), "0.0 should not appear in hotbar summary for ready slots")

func test_hotbar_summary_shows_cd_prefix_when_on_cooldown() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, "wind_storm"))
	assert_true(manager.attempt_cast("wind_storm"))
	var summary := manager.get_hotbar_summary()
	assert_string_contains(summary, "재사용:", "Cooling-down slot must show localized cooldown prefix")

func test_hotbar_summary_shows_empty_marker_for_unassigned_slot() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, ""))
	var summary := manager.get_hotbar_summary()
	assert_string_contains(summary, "[빈 슬롯]", "Unassigned slot must show localized empty marker")

func test_toggle_summary_shows_soul_dominion_risk_detail_inline() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	var summary := manager.get_toggle_summary()
	assert_string_contains(summary, "MP 봉인", "Soul Dominion toggle must show mana-lock risk detail")
	assert_string_contains(summary, "피격 +35%", "Soul Dominion toggle must show damage increase percent")
	assert_string_contains(summary, "risk", "Soul Dominion toggle must still carry risk tag")

func test_toggle_summary_other_skills_do_not_show_soul_dominion_detail() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	var summary := manager.get_toggle_summary()
	assert_false(summary.contains("MP 봉인"), "Non-Soul-Dominion toggles must not show Soul Dominion risk detail")

func test_hotbar_mastery_summary_shows_level_and_xp_for_default_slots() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var summary := manager.get_hotbar_mastery_summary()
	assert_string_contains(summary, "스킬", "Mastery summary must start with localized skills prefix")
	assert_string_contains(summary, "Lv.", "Mastery summary must contain level marker")
	assert_string_contains(summary, "1", "Mastery summary must include first hotbar label 1")
	assert_string_contains(summary, "Z", "Mastery summary must include buff hotbar label Z")

func test_hotbar_mastery_summary_reflects_hotbar_changes() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, "dark_soul_dominion"))
	var summary := manager.get_hotbar_mastery_summary()
	assert_string_contains(summary, "소울", "Mastery summary must reflect reassigned slot 0 skill name")
	assert_false(summary.contains("Fire Bolt") or summary.contains("Fire Lv"), "Old skill must not appear in mastery summary after reassignment")

func test_hotbar_mastery_summary_shows_empty_marker_for_unassigned_slot() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(0, ""))
	var summary := manager.get_hotbar_mastery_summary()
	assert_string_contains(summary, "[빈 슬롯]", "Unassigned slot must show localized empty marker in mastery summary")

func test_toggle_summary_glacial_dominion_shows_slow_percent() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	var summary := manager.get_toggle_summary()
	assert_string_contains(summary, "slow", "Glacial Dominion toggle must include slow tag")
	assert_string_contains(summary, "%", "Glacial Dominion toggle must include slow percent value")
	assert_false(summary.contains("MP 봉인"), "Glacial Dominion must not show Soul Dominion risk detail")

func test_toggle_summary_tempest_crown_shows_pierce_count() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(manager.assign_skill_to_slot(2, "lightning_tempest_crown"))
	assert_true(manager.attempt_cast("lightning_tempest_crown"))
	var summary := manager.get_toggle_summary()
	assert_string_contains(summary, "관통 x", "Tempest Crown toggle must show localized pierce count with x prefix")
	assert_false(summary.contains("MP 봉인"), "Tempest Crown must not show Soul Dominion risk detail")
	GameState.reset_progress_for_tests()

func test_toggle_summary_glacial_dominion_does_not_show_pierce_detail() -> void:
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "ice_glacial_dominion"))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	var summary := manager.get_toggle_summary()
	assert_false(summary.contains("관통 x"), "Glacial Dominion must not show pierce count detail")

func test_verdant_overflow_buff_extends_deploy_duration() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("plant_verdant_overflow"))
	var base_data: Dictionary = {"size": 40.0, "duration": 10.0, "damage": 20}
	var modified := GameState.apply_deploy_buff_modifiers(base_data)
	assert_gt(float(modified.get("duration", 0.0)), 10.0, "Verdant Overflow buff must extend deploy duration beyond base")
	GameState.reset_progress_for_tests()

func test_verdant_overflow_buff_extends_deploy_range() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	assert_true(GameState.try_activate_buff("plant_verdant_overflow"))
	var base_data: Dictionary = {"size": 40.0, "duration": 10.0, "damage": 20}
	var modified := GameState.apply_deploy_buff_modifiers(base_data)
	assert_gt(float(modified.get("size", 0.0)), 40.0, "Verdant Overflow buff must extend deploy range beyond base")
	GameState.reset_progress_for_tests()

func test_deploy_buff_modifiers_not_applied_without_active_buff() -> void:
	GameState.reset_progress_for_tests()
	var base_data: Dictionary = {"size": 40.0, "duration": 10.0, "damage": 20}
	var modified := GameState.apply_deploy_buff_modifiers(base_data)
	assert_eq(float(modified.get("size", 0.0)), 40.0, "Without buffs deploy size must remain unchanged")
	assert_eq(float(modified.get("duration", 0.0)), 10.0, "Without buffs deploy duration must remain unchanged")

func test_deploy_recast_delay_penalty_blocks_deploy_cast() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	# Inject deploy_recast_delay penalty (verdant_overflow downside after expiry)
	GameState.active_penalties.append({"stat": "deploy_recast_delay", "mode": "add", "value": 1, "remaining": 6.0})
	assert_false(manager.attempt_cast("earth_stone_spire"), "deploy_recast_delay penalty must block deploy cast")
	GameState.reset_progress_for_tests()

func test_deploy_recast_delay_not_present_allows_deploy_cast() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("earth_stone_spire"), "Without deploy_recast_delay penalty, deploy cast must succeed")
	GameState.reset_progress_for_tests()

func test_stone_spire_deploy_repeatedly_hits_core_enemy_archetypes() -> void:
	for archetype in ENEMY_ARCHETYPE_CASES:
		GameState.reset_progress_for_tests()
		GameState.set_admin_ignore_cooldowns(true)
		GameState.set_admin_infinite_mana(true)
		var root := Node2D.new()
		add_child_autofree(root)
		var player = autofree(PLAYER_SCRIPT.new())
		player.global_position = Vector2.ZERO
		player.facing = 1
		var manager = SPELL_MANAGER_SCRIPT.new()
		manager.setup(player)
		var enemy_type := str(archetype.get("type", ""))
		var enemy := _spawn_enemy_for_spell_coverage(root, enemy_type)
		enemy.target = null
		enemy.velocity = Vector2.ZERO
		enemy.gravity = 0.0
		enemy.set_physics_process(false)
		enemy.global_position = Vector2(48.0, -4.0)
		await _advance_frames(2)
		var hp_before: int = enemy.health
		var payloads: Array = []
		manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
		assert_true(manager.attempt_cast("earth_stone_spire"), "Stone Spire must cast for %s archetype" % enemy_type)
		assert_eq(payloads.size(), 1, "Stone Spire must emit one deploy payload for %s archetype" % enemy_type)
		var payload: Dictionary = payloads[0]
		var single_hit_damage: int = int(
			enemy.debug_calculate_incoming_damage(int(payload.get("damage", 0)), str(payload.get("school", ""))).get("final_damage", 0)
		)
		var projectile := _spawn_projectile_for_spell_coverage(root, payload)
		await _advance_frames(120)
		var enemy_survived := is_instance_valid(enemy)
		if enemy_survived:
			assert_lt(enemy.health, hp_before - single_hit_damage, "Stone Spire must hit %s more than once while deployed" % enemy_type)
		else:
			assert_true(true, "Stone Spire may defeat %s before the deploy finishes" % enemy_type)
		assert_gt(GameState.session_hit_count, 1, "Stone Spire must record repeated hits against %s" % enemy_type)
		assert_false(is_instance_valid(projectile), "Stone Spire deploy must expire after its duration for %s" % enemy_type)
		root.queue_free()


func test_stone_spire_pulses_do_not_change_engine_time_scale() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	Engine.time_scale = 1.0
	var root := Node2D.new()
	add_child_autofree(root)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2.ZERO
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	enemy.target = null
	enemy.global_position = Vector2(52.0, -4.0)
	await _advance_frames(2)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("earth_stone_spire"))
	var projectile := _spawn_projectile_for_spell_coverage(root, payloads[0])
	await _advance_frames(20)
	assert_gt(GameState.session_hit_count, 0, "Stone Spire must still deal damage while hitstop is disabled")
	assert_eq(Engine.time_scale, 1.0, "Persistent deploy pulses must not freeze the global timescale")
	if is_instance_valid(projectile):
		projectile.queue_free()
	root.queue_free()


func test_glacial_dominion_aura_ticks_do_not_change_engine_time_scale() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	Engine.time_scale = 1.0
	var root := Node2D.new()
	add_child_autofree(root)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2.ZERO
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	enemy.target = null
	enemy.velocity = Vector2.ZERO
	enemy.gravity = 0.0
	enemy.set_physics_process(false)
	enemy.global_position = Vector2(56.0, -4.0)
	await _advance_frames(2)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	manager.tick(1.1)
	var projectile := _spawn_projectile_for_spell_coverage(root, payloads[payloads.size() - 1])
	await _advance_frames(10)
	assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "Glacial Dominion must still apply slow while hitstop is disabled")
	assert_eq(Engine.time_scale, 1.0, "Toggle aura ticks must not freeze the global timescale")
	if is_instance_valid(projectile):
		projectile.queue_free()
	root.queue_free()


func test_earth_tremor_area_burst_triggers_short_hitstop_and_recovers() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	Engine.time_scale = 1.0
	var root := Node2D.new()
	add_child_autofree(root)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2.ZERO
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	enemy.target = null
	enemy.global_position = Vector2(20.0, -4.0)
	await _advance_frames(2)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("earth_tremor"))
	var projectile := _spawn_projectile_for_spell_coverage(root, payloads[0])
	assert_true(projectile._hit_enemy(enemy), "Earth Tremor test projectile must register a burst hit")
	assert_lt(Engine.time_scale, 1.0, "Area burst actives should still create a short hitstop window")
	await _advance_frames(12)
	assert_eq(Engine.time_scale, 1.0, "Area burst hitstop must recover automatically")
	if is_instance_valid(projectile):
		projectile.queue_free()
	root.queue_free()


func test_frost_nova_area_burst_applies_freeze_and_feedback_to_core_enemy_archetypes() -> void:
	for archetype in ENEMY_ARCHETYPE_CASES:
		GameState.reset_progress_for_tests()
		GameState.set_admin_ignore_cooldowns(true)
		GameState.set_admin_infinite_mana(true)
		Engine.time_scale = 1.0
		var root := Node2D.new()
		add_child_autofree(root)
		var player = autofree(PLAYER_SCRIPT.new())
		player.global_position = Vector2.ZERO
		var manager = SPELL_MANAGER_SCRIPT.new()
		manager.setup(player)
		var enemy_type := str(archetype.get("type", ""))
		var enemy := _spawn_enemy_for_spell_coverage(root, enemy_type)
		enemy.target = null
		enemy.global_position = Vector2(18.0, -4.0)
		await _advance_frames(2)
		var payloads: Array = []
		manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
		assert_true(manager.attempt_cast("frost_nova"), "Frost Nova must cast for %s archetype" % enemy_type)
		assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst")
		var forced_payload := _force_status_effect_rolls(payloads[0])
		var utility_effects: Array = forced_payload.get("utility_effects", [])
		assert_eq(str(utility_effects[0].get("type", "")), "freeze", "Frost Nova must carry freeze utility for %s archetype" % enemy_type)
		var projectile := _spawn_projectile_for_spell_coverage(root, forced_payload)
		assert_gt(projectile.get_child_count(), 0, "Frost Nova burst must build its visual immediately for %s archetype" % enemy_type)
		var sprite := projectile.get_child(0) as AnimatedSprite2D
		assert_true(sprite != null, "Frost Nova burst must use AnimatedSprite2D feedback for %s archetype" % enemy_type)
		var hp_before: int = enemy.health
		assert_true(projectile._hit_enemy(enemy), "Frost Nova burst must connect through the real projectile hit path for %s archetype" % enemy_type)
		assert_lt(Engine.time_scale, 1.0, "Frost Nova burst must create a short area-burst hitstop window for %s archetype" % enemy_type)
		assert_lt(enemy.health, hp_before, "Frost Nova burst must damage %s archetype" % enemy_type)
		assert_gt(enemy.hit_flash_timer, 0.0, "Frost Nova burst must trigger hit flash on %s archetype" % enemy_type)
		assert_gt(float(enemy.status_timers.get("freeze", 0.0)), 0.0, "Frost Nova burst must apply freeze to %s archetype" % enemy_type)
		await _advance_frames(12)
		assert_eq(Engine.time_scale, 1.0, "Frost Nova area-burst hitstop must recover automatically for %s archetype" % enemy_type)
		if is_instance_valid(projectile):
			projectile.queue_free()
		root.queue_free()

func test_plant_vine_snare_deploy_reapplies_root_during_duration() -> void:
	for archetype in ENEMY_ARCHETYPE_CASES:
		GameState.reset_progress_for_tests()
		GameState.set_admin_ignore_cooldowns(true)
		GameState.set_admin_infinite_mana(true)
		var root := Node2D.new()
		add_child_autofree(root)
		var player = autofree(PLAYER_SCRIPT.new())
		player.global_position = Vector2.ZERO
		player.facing = 1
		var manager = SPELL_MANAGER_SCRIPT.new()
		manager.setup(player)
		var enemy_type := str(archetype.get("type", ""))
		var enemy := _spawn_enemy_for_spell_coverage(root, enemy_type)
		enemy.target = null
		enemy.global_position = Vector2(48.0, -4.0)
		await _advance_frames(2)
		var payloads: Array = []
		manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
		assert_true(manager.attempt_cast("plant_vine_snare"), "Vine Snare deploy must succeed for %s archetype" % enemy_type)
		var forced_payload := _force_status_effect_rolls(payloads[0])
		var utility_effects: Array = forced_payload.get("utility_effects", [])
		assert_eq(str(utility_effects[0].get("type", "")), "root", "Vine Snare must carry root utility for %s archetype" % enemy_type)
		var projectile := _spawn_projectile_for_spell_coverage(root, forced_payload)
		await _advance_frames(75)
		assert_gt(float(enemy.status_timers.get("root", 0.0)), 0.0, "Vine Snare must reapply root during its deploy duration for %s archetype" % enemy_type)
		assert_true(enemy._is_rooted(), "Vine Snare must leave %s in the rooted movement-lock state after a repeated pulse" % enemy_type)
		assert_true(is_instance_valid(projectile), "Vine Snare must persist through repeated pulses for %s archetype" % enemy_type)
		if is_instance_valid(projectile):
			projectile.queue_free()
		root.queue_free()

func test_plant_vine_snare_deploy_cast_emits_payload_with_plant_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("plant_vine_snare"), "plant_vine_snare deploy must succeed with infinite mana")
	assert_eq(payloads.size(), 1, "Exactly one payload must be emitted")
	assert_eq(str(payloads[0].get("spell_id", "")), "plant_vine_snare")
	assert_eq(str(payloads[0].get("school", "")), "plant")
	GameState.reset_progress_for_tests()

func test_plant_vine_snare_deploy_duration_scales_with_verdant_coil() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager_plain = SPELL_MANAGER_SCRIPT.new()
	manager_plain.setup(player)
	var payloads_plain: Array = []
	manager_plain.spell_cast.connect(func(p: Dictionary) -> void: payloads_plain.append(p))
	assert_true(manager_plain.attempt_cast("plant_vine_snare"))
	var duration_plain := float(payloads_plain[0].get("duration", 0.0))

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.set_equipped_item("accessory_2", "ring_verdant_coil")
	var player2 = autofree(PLAYER_SCRIPT.new())
	var manager_coil = SPELL_MANAGER_SCRIPT.new()
	manager_coil.setup(player2)
	var payloads_coil: Array = []
	manager_coil.spell_cast.connect(func(p: Dictionary) -> void: payloads_coil.append(p))
	assert_true(manager_coil.attempt_cast("plant_vine_snare"))
	var duration_coil := float(payloads_coil[0].get("duration", 0.0))
	assert_gt(duration_coil, duration_plain, "Verdant Coil installation_duration must increase vine snare duration")
	GameState.reset_progress_for_tests()

func test_plant_vine_snare_deploy_duration_and_range_scale_with_skill_level() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.skill_level_data["plant_vine_snare"] = 1
	var player_low = autofree(PLAYER_SCRIPT.new())
	var manager_low = SPELL_MANAGER_SCRIPT.new()
	manager_low.setup(player_low)
	var payloads_low: Array = []
	manager_low.spell_cast.connect(func(payload: Dictionary) -> void: payloads_low.append(payload))
	assert_true(manager_low.attempt_cast("plant_vine_snare"))
	assert_true(payloads_low.size() >= 1)
	var low_duration := float(payloads_low[0].get("duration", 0.0))
	var low_size := float(payloads_low[0].get("size", 0.0))

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.skill_level_data["plant_vine_snare"] = 30
	var player_high = autofree(PLAYER_SCRIPT.new())
	var manager_high = SPELL_MANAGER_SCRIPT.new()
	manager_high.setup(player_high)
	var payloads_high: Array = []
	manager_high.spell_cast.connect(func(payload: Dictionary) -> void: payloads_high.append(payload))
	assert_true(manager_high.attempt_cast("plant_vine_snare"))
	assert_true(payloads_high.size() >= 1)
	var high_duration := float(payloads_high[0].get("duration", 0.0))
	var high_size := float(payloads_high[0].get("size", 0.0))

	assert_gt(high_duration, low_duration, "plant_vine_snare duration must scale upward with skill level")
	assert_gt(high_size, low_size, "plant_vine_snare range/size must scale upward with skill level")
	GameState.reset_progress_for_tests()

func test_ice_glacial_dominion_toggle_on_emits_ice_school_payload() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("ice_glacial_dominion"), "Glacial Dominion must activate")
	assert_string_contains(manager.get_feedback_summary(), "활성화")
	manager.tick(2.0)
	assert_true(payloads.size() >= 1, "At least one tick payload must emit")
	assert_eq(str(payloads[0].get("school", "")), "ice")
	assert_eq(str(payloads[0].get("spell_id", "")), "ice_glacial_dominion")
	assert_true(manager.attempt_cast("ice_glacial_dominion"), "Toggle off must succeed")
	assert_string_contains(manager.get_feedback_summary(), "비활성화")
	GameState.reset_progress_for_tests()

func test_lightning_tempest_crown_toggle_on_emits_lightning_school_payload() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("lightning_tempest_crown"), "Tempest Crown must activate")
	manager.tick(2.0)
	assert_true(payloads.size() >= 1, "At least one tick payload must emit")
	assert_eq(str(payloads[0].get("school", "")), "lightning")
	assert_eq(str(payloads[0].get("spell_id", "")), "lightning_tempest_crown")
	assert_true(manager.attempt_cast("lightning_tempest_crown"), "Toggle off must succeed")
	GameState.reset_progress_for_tests()

func test_earth_fortress_toggle_on_emits_earth_school_payload() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("earth_fortress"), "Earth Fortress must activate")
	manager.tick(1.2)
	assert_true(payloads.size() >= 1, "At least one tick payload must emit")
	assert_eq(str(payloads[0].get("school", "")), "earth")
	assert_eq(str(payloads[0].get("spell_id", "")), "earth_fortress")
	assert_eq(int(payloads[0].get("damage", -1)), 0, "earth_fortress must no longer emit offensive placeholder damage once its pure defense meaning is locked")
	var support_effects: Array = payloads[0].get("support_effects", [])
	assert_eq(str(support_effects[0].get("stat", "")), "defense_multiplier", "earth_fortress must emit a defense multiplier rider in its pure defense runtime")
	assert_eq(str(support_effects[1].get("stat", "")), "poise_bonus", "earth_fortress must emit a stability rider in its pure defense runtime")
	assert_eq(str(support_effects[2].get("stat", "")), "status_resistance", "earth_fortress must emit a status-resistance rider in its pure defense runtime")
	assert_true(manager.attempt_cast("earth_fortress"), "Toggle off must succeed")
	GameState.reset_progress_for_tests()


func test_earth_fortress_guard_aura_reduces_damage_taken_and_expires_after_toggle_off() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var base_damage_taken := GameState.get_damage_taken_multiplier()
	assert_eq(base_damage_taken, 1.0, "earth_fortress precondition must start from neutral damage taken")
	assert_eq(GameState.get_poise_bonus(), 0.0, "earth_fortress precondition must start without poise support")
	assert_eq(GameState.get_status_resistance(), 0.0, "earth_fortress precondition must start without status resistance")
	assert_true(manager.attempt_cast("earth_fortress"), "Earth Fortress must activate")
	manager.tick(1.2)
	assert_true(payloads.size() >= 1, "Earth Fortress must emit at least one guard pulse")
	var projectile := _spawn_projectile_for_spell_coverage(root, payloads[0])
	await _advance_frames(12)
	assert_lt(
		GameState.get_damage_taken_multiplier(),
		base_damage_taken,
		"earth_fortress must reduce incoming damage while its guard aura pulse is active"
	)
	assert_gt(GameState.get_poise_bonus(), 0.0, "earth_fortress must grant a stability rider while its guard aura is active")
	assert_gt(
		GameState.get_status_resistance(),
		0.0,
		"earth_fortress must grant a status-resistance rider while its guard aura is active"
	)
	assert_true(manager.attempt_cast("earth_fortress"), "Toggle off must succeed")
	GameState._tick_buff_runtime(1.1)
	assert_eq(
		GameState.get_damage_taken_multiplier(),
		base_damage_taken,
		"earth_fortress guard rider must expire after the aura is turned off"
	)
	assert_eq(GameState.get_poise_bonus(), 0.0, "earth_fortress stability rider must expire after the aura is turned off")
	assert_eq(
		GameState.get_status_resistance(),
		0.0,
		"earth_fortress status-resistance rider must expire after the aura is turned off"
	)
	if is_instance_valid(projectile):
		projectile.queue_free()
	GameState.reset_progress_for_tests()

func test_wind_storm_zone_toggle_on_emits_wind_school_payload() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("wind_storm_zone"), "Storm Zone must activate")
	manager.tick(1.2)
	assert_true(payloads.size() >= 1, "At least one tick payload must emit")
	assert_eq(str(payloads[0].get("school", "")), "wind")
	assert_eq(str(payloads[0].get("spell_id", "")), "wind_storm_zone")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "slow", "wind_storm_zone must lock its enemy control zone around repeated slow utility")
	assert_gt(float(payloads[0].get("pull_strength", 0.0)), 0.0, "wind_storm_zone must carry inward draft control on its runtime payload")
	assert_true(manager.attempt_cast("wind_storm_zone"), "Toggle off must succeed")
	GameState.reset_progress_for_tests()

func test_wind_storm_zone_toggle_applies_slow_and_pull_to_core_enemy_archetypes() -> void:
	for archetype in ENEMY_ARCHETYPE_CASES:
		GameState.reset_progress_for_tests()
		GameState.set_admin_ignore_cooldowns(true)
		GameState.set_admin_infinite_mana(true)
		var root := Node2D.new()
		add_child_autofree(root)
		var player = autofree(PLAYER_SCRIPT.new())
		root.add_child(player)
		await _advance_frames(2)
		var manager = SPELL_MANAGER_SCRIPT.new()
		manager.setup(player)
		var enemy_type := str(archetype.get("type", ""))
		var enemy := _spawn_enemy_for_spell_coverage(root, enemy_type)
		enemy.target = null
		enemy.gravity = 0.0
		enemy.velocity = Vector2.ZERO
		enemy.set_physics_process(false)
		enemy.global_position = Vector2(92.0, -4.0)
		await _advance_frames(2)
		var payloads: Array = []
		manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
		assert_true(manager.attempt_cast("wind_storm_zone"), "Storm Zone must activate for %s archetype" % enemy_type)
		manager.tick(0.6)
		assert_true(payloads.size() >= 1, "Storm Zone must emit at least one control tick for %s" % enemy_type)
		var x_before := enemy.global_position.x
		var projectile := _spawn_projectile_for_spell_coverage(
			root,
			_force_status_effect_rolls(payloads[payloads.size() - 1], 0.0)
		)
		await _advance_frames(12)
		assert_true(is_instance_valid(enemy), "Storm Zone should control %s without deleting it" % enemy_type)
		assert_lt(enemy.global_position.x, x_before, "Storm Zone must pull %s inward toward its control center" % enemy_type)
		assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "Storm Zone must apply slow to %s" % enemy_type)
		assert_lt(enemy.slow_multiplier, 1.0, "Storm Zone slow must reduce movement multiplier for %s" % enemy_type)
		if is_instance_valid(projectile):
			projectile.queue_free()
		Engine.time_scale = 1.0
		GameState.reset_progress_for_tests()
		root.queue_free()

func test_holy_seraph_chorus_toggle_on_emits_holy_school_payload() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("holy_seraph_chorus"), "Seraph Chorus must activate")
	manager.tick(1.2)
	assert_true(payloads.size() >= 1, "At least one tick payload must emit")
	assert_eq(str(payloads[0].get("school", "")), "holy")
	assert_eq(str(payloads[0].get("spell_id", "")), "holy_seraph_chorus")
	assert_gt(int(payloads[0].get("damage", 0)), 0, "holy_seraph_chorus must keep its offensive chorus pulse in the mixed aura runtime")
	assert_gt(int(payloads[0].get("self_heal", 0)), 0, "holy_seraph_chorus must emit a support heal rider alongside its offensive pulse")
	var support_effects: Array = payloads[0].get("support_effects", [])
	assert_eq(str(support_effects[0].get("stat", "")), "poise_bonus", "holy_seraph_chorus must stabilize the owner alongside its offensive pulse")
	assert_true(manager.attempt_cast("holy_seraph_chorus"), "Toggle off must succeed")
	GameState.reset_progress_for_tests()

func test_holy_seraph_chorus_mixed_aura_heals_owner_and_damages_enemy_during_same_pulse() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	GameState.health = 24
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	enemy.target = null
	enemy.gravity = 0.0
	enemy.velocity = Vector2.ZERO
	enemy.set_physics_process(false)
	enemy.global_position = Vector2(56.0, -4.0)
	await _advance_frames(2)
	var health_before := GameState.health
	var enemy_health_before: int = enemy.health
	assert_true(manager.attempt_cast("holy_seraph_chorus"), "Seraph Chorus must activate")
	manager.tick(1.2)
	assert_true(payloads.size() >= 1, "Seraph Chorus must emit at least one mixed aura pulse")
	var projectile := _spawn_projectile_for_spell_coverage(root, payloads[0])
	await _advance_frames(12)
	assert_gt(GameState.health, health_before, "holy_seraph_chorus must heal the owner during the same pulse that carries offense")
	assert_gt(GameState.get_poise_bonus(), 0.0, "holy_seraph_chorus must grant a stability rider while its aura pulse is active")
	assert_lt(enemy.health, enemy_health_before, "holy_seraph_chorus must damage enemies during the same pulse that supports the owner")
	assert_gt(GameState.session_hit_count, 0, "holy_seraph_chorus mixed aura must still register enemy hits")
	assert_true(manager.attempt_cast("holy_seraph_chorus"), "Toggle off must succeed")
	GameState._tick_buff_runtime(1.2)
	assert_eq(GameState.get_poise_bonus(), 0.0, "holy_seraph_chorus support rider must expire after the aura is turned off")
	if is_instance_valid(projectile):
		projectile.queue_free()

func test_wind_sky_dominion_toggle_on_emits_aerial_utility_payload() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("wind_sky_dominion"), "Sky Dominion must activate")
	manager.tick(1.0)
	assert_true(payloads.size() >= 1, "At least one tick payload must emit")
	assert_eq(str(payloads[0].get("school", "")), "wind")
	assert_eq(str(payloads[0].get("spell_id", "")), "wind_sky_dominion")
	assert_eq(int(payloads[0].get("damage", -1)), 0, "wind_sky_dominion must now emit a utility-only toggle pulse")
	var support_effects: Array = payloads[0].get("support_effects", [])
	assert_eq(str(support_effects[0].get("stat", "")), "move_speed_multiplier")
	assert_eq(str(support_effects[1].get("stat", "")), "jump_velocity_multiplier")
	assert_eq(str(support_effects[2].get("stat", "")), "gravity_multiplier")
	assert_eq(str(support_effects[3].get("stat", "")), "air_jump_bonus")
	assert_true((payloads[0].get("utility_effects", []) as Array).is_empty(), "wind_sky_dominion must stop expressing its final utility through enemy slow placeholder effects")
	assert_gt(float(payloads[0].get("size", 0.0)), 220.0, "wind_sky_dominion must keep the widest wind aura footprint")
	assert_true(manager.attempt_cast("wind_sky_dominion"), "Toggle off must succeed")
	GameState.reset_progress_for_tests()


func test_wind_sky_dominion_grants_aerial_mobility_and_expires_after_toggle_off() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_eq(GameState.get_player_move_multiplier(), 1.0)
	assert_eq(GameState.get_player_jump_velocity_multiplier(), 1.0)
	assert_eq(GameState.get_player_gravity_multiplier(), 1.0)
	assert_eq(GameState.get_player_air_jump_bonus(), 0)
	assert_true(manager.attempt_cast("wind_sky_dominion"), "Sky Dominion must activate")
	manager.tick(1.0)
	assert_true(payloads.size() >= 1, "Sky Dominion must emit at least one utility pulse")
	var projectile := _spawn_projectile_for_spell_coverage(root, payloads[0])
	await _advance_frames(12)
	assert_gt(GameState.get_player_move_multiplier(), 1.0, "wind_sky_dominion must accelerate the owner while active")
	assert_gt(GameState.get_player_jump_velocity_multiplier(), 1.0, "wind_sky_dominion must increase jump launch while active")
	assert_lt(GameState.get_player_gravity_multiplier(), 1.0, "wind_sky_dominion must lighten gravity while active")
	assert_eq(GameState.get_player_air_jump_bonus(), 1, "wind_sky_dominion must grant one extra aerial jump while active")
	assert_true(player.debug_try_jump(true))
	assert_true(player.debug_try_jump(false))
	assert_true(player.debug_try_jump(false))
	assert_false(player.debug_try_jump(false), "wind_sky_dominion must stop after granting one extra jump beyond the default double jump")
	assert_true(manager.attempt_cast("wind_sky_dominion"), "Toggle off must succeed")
	GameState._tick_buff_runtime(1.2)
	assert_eq(GameState.get_player_move_multiplier(), 1.0, "wind_sky_dominion move-speed support must expire after toggle off")
	assert_eq(GameState.get_player_jump_velocity_multiplier(), 1.0, "wind_sky_dominion jump support must expire after toggle off")
	assert_eq(GameState.get_player_gravity_multiplier(), 1.0, "wind_sky_dominion gravity support must expire after toggle off")
	assert_eq(GameState.get_player_air_jump_bonus(), 0, "wind_sky_dominion extra jump must expire after toggle off")
	if is_instance_valid(projectile):
		projectile.queue_free()
	GameState.reset_progress_for_tests()

func test_ice_glacial_dominion_and_dark_grave_echo_can_be_active_simultaneously() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.attempt_cast("dark_grave_echo"))
	assert_true(manager.attempt_cast("ice_glacial_dominion"))
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	manager.tick(2.0)
	var schools: Array = []
	for p in payloads:
		var school := str(p.get("school", ""))
		if not schools.has(school):
			schools.append(school)
	assert_true(schools.has("dark"), "Dark toggle must emit dark payloads")
	assert_true(schools.has("ice"), "Ice toggle must emit ice payloads")
	GameState.reset_progress_for_tests()

func test_soul_dominion_aftershock_increases_damage_taken() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var base_mult := GameState.get_damage_taken_multiplier()
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_false(GameState.soul_dominion_active)
	assert_gt(GameState.soul_dominion_aftershock_timer, 0.0)
	var aftershock_mult := GameState.get_damage_taken_multiplier()
	assert_gt(aftershock_mult, base_mult, "Aftershock must still increase damage taken multiplier")
	GameState.reset_progress_for_tests()

func test_soul_dominion_risk_summary_shows_aftershock_text() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	var active_summary := GameState.get_soul_dominion_risk_summary()
	assert_string_contains(active_summary, "활성", "Risk summary must say active while on")
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	var shock_summary := GameState.get_soul_dominion_risk_summary()
	assert_string_contains(shock_summary, "여진", "Risk summary must say aftershock after toggle off")
	GameState.reset_progress_for_tests()

func test_soul_dominion_can_reactivate_after_aftershock_expires() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	assert_true(manager.assign_skill_to_slot(2, "dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	assert_true(manager.attempt_cast("dark_soul_dominion"))
	GameState._tick_buff_runtime(GameState.SOUL_DOMINION_AFTERSHOCK_DURATION + 0.5)
	assert_eq(GameState.soul_dominion_aftershock_timer, 0.0)
	assert_false(GameState.soul_dominion_active)
	assert_true(manager.attempt_cast("dark_soul_dominion"), "Soul Dominion must be re-activatable after aftershock expires")
	assert_true(GameState.soul_dominion_active)
	GameState.reset_progress_for_tests()

func test_water_aqua_bullet_cast_emits_payload_with_water_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("water_aqua_bullet"), "water_aqua_bullet cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "water_aqua_bullet")
	assert_eq(str(payloads[0].get("school", "")), "water")
	assert_gt(float(payloads[0].get("speed", 0.0)), 0.0, "water_aqua_bullet must have positive speed")
	GameState.reset_progress_for_tests()

func test_water_tidal_ring_cast_emits_payload_with_water_school_and_area_burst_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(10.0, 2.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("water_tidal_ring"), "water_tidal_ring cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "water_tidal_ring")
	assert_eq(str(payloads[0].get("school", "")), "water")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "water_tidal_ring must stay as a stationary burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "water_tidal_ring must use area_burst hitstop")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.0, "water_tidal_ring must keep a burst duration for its visual timing")
	assert_gt(float(payloads[0].get("size", 0.0)), 100.0, "water_tidal_ring must keep a readable control radius")
	GameState.reset_progress_for_tests()

func test_water_wave_cast_emits_payload_with_water_school_and_control_line_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("water_wave"), "water_wave cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "water_wave")
	assert_eq(str(payloads[0].get("school", "")), "water")
	assert_gt(float(payloads[0].get("speed", 0.0)), 0.0, "water_wave must stay as a moving wave projectile")
	assert_gt(float(payloads[0].get("size", 0.0)), 24.0, "water_wave must keep a wider-than-bullet control width")
	assert_gt(int(payloads[0].get("pierce", 0)), 1, "water_wave must keep base pierce for multi-target control")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "slow", "water_wave must carry a slow utility rider")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "default", "moving line control projectiles must keep default hitstop")
	GameState.reset_progress_for_tests()

func test_water_tsunami_cast_emits_payload_with_water_school_and_large_control_line_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("water_tsunami"), "water_tsunami cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "water_tsunami")
	assert_eq(str(payloads[0].get("school", "")), "water")
	assert_gt(float(payloads[0].get("speed", 0.0)), 0.0, "water_tsunami must stay as a moving tidal projectile")
	assert_gt(float(payloads[0].get("size", 0.0)), 50.0, "water_tsunami must keep a much wider body than water_wave")
	assert_gt(int(payloads[0].get("pierce", 0)), 4, "water_tsunami must keep high pierce for late-game crowd control")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "water_tsunami_end", "water_tsunami must carry a trailing vortex terminal effect id")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "slow", "water_tsunami must carry a slow utility rider")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "default", "moving tidal projectiles must keep default hitstop")
	GameState.reset_progress_for_tests()

func test_water_ocean_collapse_cast_emits_payload_with_water_school_and_ultimate_control_line_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("water_ocean_collapse"), "water_ocean_collapse cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "water_ocean_collapse")
	assert_eq(str(payloads[0].get("school", "")), "water")
	assert_gt(float(payloads[0].get("speed", 0.0)), 0.0, "water_ocean_collapse must stay as a moving tidal-collapse projectile")
	assert_gt(float(payloads[0].get("size", 0.0)), 64.0, "water_ocean_collapse must keep a wider body than water_tsunami")
	assert_gt(int(payloads[0].get("pierce", 0)), 6, "water_ocean_collapse must keep ultimate-tier pierce for crowd control")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "water_ocean_collapse_end", "water_ocean_collapse must carry a larger trailing vortex terminal effect id")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "slow", "water_ocean_collapse must carry a slow utility rider")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "default", "moving tidal-collapse projectiles must keep default hitstop")
	GameState.reset_progress_for_tests()

func test_volt_spear_cast_emits_payload_with_lightning_school_and_lance_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var lightning_bolt_runtime := GameState.get_spell_runtime("lightning_bolt")
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(8.0, 1.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("volt_spear"), "volt_spear cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "volt_spear")
	assert_eq(str(payloads[0].get("school", "")), "lightning")
	assert_gt(float(payloads[0].get("speed", 0.0)), 1000.0, "volt_spear must stay as a fast lightning lance")
	assert_lt(
		float(payloads[0].get("size", 0.0)),
		float(lightning_bolt_runtime.get("size", 0.0)),
		"volt_spear must stay narrower than the crowd-control lightning bolt family"
	)
	assert_gte(int(payloads[0].get("pierce", 0)), 2, "volt_spear must keep at least two pierces for boss-line pressure")
	assert_eq(int(payloads[0].get("multi_hit_total", 0)), 3, "volt_spear must keep its authored 3-hit lance split")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "volt_spear_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "volt_spear_hit")
	GameState.reset_progress_for_tests()

func test_lightning_bolt_cast_emits_payload_with_lightning_school_and_chain_control_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("lightning_bolt"), "lightning_bolt cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "lightning_bolt")
	assert_eq(str(payloads[0].get("school", "")), "lightning")
	assert_gt(float(payloads[0].get("speed", 0.0)), 0.0, "lightning_bolt must stay as a moving chain-read projectile")
	assert_gt(int(payloads[0].get("pierce", 0)), 2, "lightning_bolt must keep base pierce for multi-target chain read")
	assert_gt(float(payloads[0].get("size", 0.0)), 10.0, "lightning_bolt must read slightly wider than thunder_arrow")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "shock", "lightning_bolt must carry a shock utility rider")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "default", "moving lightning control projectiles must keep default hitstop")
	GameState.reset_progress_for_tests()

func test_ice_absolute_freeze_cast_emits_payload_with_ice_school_and_area_burst_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(8.0, -2.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("ice_absolute_freeze"), "ice_absolute_freeze cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "ice_absolute_freeze")
	assert_eq(str(payloads[0].get("school", "")), "ice")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "ice_absolute_freeze must stay as a stationary burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "ice_absolute_freeze must use area_burst hitstop")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.0, "ice_absolute_freeze must keep burst duration for visual timing")
	assert_gt(float(payloads[0].get("size", 0.0)), 140.0, "ice_absolute_freeze must keep a wide control radius")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "freeze", "ice_absolute_freeze must carry freeze utility as the late-game burst read")
	GameState.reset_progress_for_tests()

func test_fire_inferno_buster_cast_emits_payload_with_fire_school_and_area_burst_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(12.0, 4.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("fire_inferno_buster"), "fire_inferno_buster cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "fire_inferno_buster")
	assert_eq(str(payloads[0].get("school", "")), "fire")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "fire_inferno_buster must stay as a stationary burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "fire_inferno_buster must use area_burst hitstop")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.0, "fire_inferno_buster must keep burst duration for visual timing")
	assert_gt(float(payloads[0].get("size", 0.0)), 150.0, "fire_inferno_buster must keep a wide late-game burst radius")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "burn", "fire_inferno_buster must carry burn utility as the late-game fire burst read")
	GameState.reset_progress_for_tests()

func test_fire_meteor_strike_cast_emits_payload_with_fire_school_and_delayed_area_burst_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(12.0, -4.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("fire_meteor_strike"), "fire_meteor_strike cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "fire_meteor_strike")
	assert_eq(str(payloads[0].get("school", "")), "fire")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "fire_meteor_strike must stay as a stationary burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "fire_meteor_strike must use area_burst hitstop")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "fire_meteor_strike_end", "fire_meteor_strike must carry its ember terminal effect id")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.4, "fire_meteor_strike must keep a slightly longer burst timing for delayed impact read")
	assert_gt(float(payloads[0].get("size", 0.0)), 180.0, "fire_meteor_strike must keep a larger late-game impact radius")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "burn", "fire_meteor_strike must carry burn utility as the meteor impact read")
	GameState.reset_progress_for_tests()

func test_fire_apocalypse_flame_cast_emits_payload_with_fire_school_and_ultimate_burst_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(14.0, -2.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("fire_apocalypse_flame"), "fire_apocalypse_flame cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "fire_apocalypse_flame")
	assert_eq(str(payloads[0].get("school", "")), "fire")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "fire_apocalypse_flame must stay as a stationary burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "fire_apocalypse_flame must use area_burst hitstop")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "fire_apocalypse_flame_end", "fire_apocalypse_flame must carry its ember-collapse terminal effect id")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.5, "fire_apocalypse_flame must keep a slightly longer burst timing than meteor_strike")
	assert_gt(float(payloads[0].get("size", 0.0)), 200.0, "fire_apocalypse_flame must keep an ultimate fire impact radius")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "burn", "fire_apocalypse_flame must carry burn utility as the apocalyptic impact read")
	GameState.reset_progress_for_tests()

func test_fire_solar_cataclysm_cast_emits_payload_with_fire_school_and_final_burst_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(16.0, -3.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("fire_solar_cataclysm"), "fire_solar_cataclysm cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "fire_solar_cataclysm")
	assert_eq(str(payloads[0].get("school", "")), "fire")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "fire_solar_cataclysm must stay as a stationary burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "fire_solar_cataclysm must use area_burst hitstop")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "fire_solar_cataclysm_end", "fire_solar_cataclysm must carry its solar-collapse terminal effect id")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.54, "fire_solar_cataclysm must keep the longest fire fallback burst timing")
	assert_gt(float(payloads[0].get("size", 0.0)), 210.0, "fire_solar_cataclysm must keep the widest fire impact radius")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "burn", "fire_solar_cataclysm must carry burn utility as the solar impact read")
	GameState.reset_progress_for_tests()

func test_ice_absolute_zero_cast_emits_payload_with_ice_school_and_final_freeze_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(11.0, -3.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("ice_absolute_zero"), "ice_absolute_zero cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "ice_absolute_zero")
	assert_eq(str(payloads[0].get("school", "")), "ice")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "ice_absolute_zero must stay as a stationary final burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "ice_absolute_zero must use area_burst hitstop")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "ice_absolute_zero_end", "ice_absolute_zero must carry its final freeze terminal effect id")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.5, "ice_absolute_zero must keep the longest ice burst timing")
	assert_gt(float(payloads[0].get("size", 0.0)), 210.0, "ice_absolute_zero must keep the widest ice impact radius")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "freeze", "ice_absolute_zero must carry freeze utility as the final ice impact read")
	GameState.reset_progress_for_tests()

func test_earth_gaia_break_cast_emits_payload_with_earth_school_and_collapse_burst_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(10.0, 0.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("earth_gaia_break"), "earth_gaia_break cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "earth_gaia_break")
	assert_eq(str(payloads[0].get("school", "")), "earth")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "earth_gaia_break must stay as a stationary burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "earth_gaia_break must use area_burst hitstop")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "earth_gaia_break_end", "earth_gaia_break must carry its dust-collapse terminal effect id")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.3, "earth_gaia_break must keep burst duration for collapse readability")
	assert_gt(float(payloads[0].get("size", 0.0)), 170.0, "earth_gaia_break must keep a wide late-game collapse radius")
	assert_gt(float(payloads[0].get("knockback", 0.0)), 400.0, "earth_gaia_break must keep a heavy knockback profile")
	GameState.reset_progress_for_tests()

func test_earth_continental_crush_cast_emits_payload_with_earth_school_and_ultimate_collapse_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(12.0, 0.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("earth_continental_crush"), "earth_continental_crush cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "earth_continental_crush")
	assert_eq(str(payloads[0].get("school", "")), "earth")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "earth_continental_crush must stay as a stationary burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "earth_continental_crush must use area_burst hitstop")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "earth_continental_crush_end", "earth_continental_crush must carry its terminal dust-collapse effect id")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.45, "earth_continental_crush must keep a slightly longer collapse timing than gaia_break")
	assert_gt(float(payloads[0].get("size", 0.0)), 190.0, "earth_continental_crush must keep an ultimate collapse radius")
	assert_gt(float(payloads[0].get("knockback", 0.0)), 440.0, "earth_continental_crush must keep the heaviest earth knockback profile")
	GameState.reset_progress_for_tests()

func test_earth_world_end_break_cast_emits_payload_with_earth_school_and_final_collapse_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(14.0, 0.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("earth_world_end_break"), "earth_world_end_break cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "earth_world_end_break")
	assert_eq(str(payloads[0].get("school", "")), "earth")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "earth_world_end_break must stay as a stationary final burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "earth_world_end_break must use area_burst hitstop")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "earth_world_end_break_end", "earth_world_end_break must carry its final dust-collapse terminal effect id")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.5, "earth_world_end_break must keep the longest earth collapse timing")
	assert_gt(float(payloads[0].get("size", 0.0)), 210.0, "earth_world_end_break must keep the widest earth impact radius")
	assert_gt(float(payloads[0].get("knockback", 0.0)), 480.0, "earth_world_end_break must keep the strongest earth knockback profile")
	GameState.reset_progress_for_tests()

func test_wind_storm_cast_emits_payload_with_wind_school_and_area_burst_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(10.0, 2.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("wind_storm"), "wind_storm cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "wind_storm")
	assert_eq(str(payloads[0].get("school", "")), "wind")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "wind_storm must stay as a stationary burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "wind_storm must use area_burst hitstop")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.0, "wind_storm must keep burst duration for visual timing")
	assert_gt(float(payloads[0].get("size", 0.0)), 140.0, "wind_storm must keep a wide control radius")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "slow", "wind_storm must carry slow utility as the burst-control read")
	GameState.reset_progress_for_tests()

func test_wind_heavenly_storm_cast_emits_payload_with_wind_school_and_ultimate_area_burst_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(12.0, 4.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("wind_heavenly_storm"), "wind_heavenly_storm cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "wind_heavenly_storm")
	assert_eq(str(payloads[0].get("school", "")), "wind")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "wind_heavenly_storm must stay as a stationary burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "wind_heavenly_storm must use area_burst hitstop")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.4, "wind_heavenly_storm must keep a longer ultimate burst timing")
	assert_gt(float(payloads[0].get("size", 0.0)), 180.0, "wind_heavenly_storm must keep an ultimate wind burst radius")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "slow", "wind_heavenly_storm must carry slow utility as the burst-control read")
	GameState.reset_progress_for_tests()

func test_fire_flame_arc_cast_emits_payload_with_fire_school_and_area_burst_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(12.0, 4.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("fire_flame_arc"), "fire_flame_arc cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "fire_flame_arc")
	assert_eq(str(payloads[0].get("school", "")), "fire")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "fire_flame_arc must stay as a stationary burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "stationary fire burst must use area_burst hitstop")
	assert_gt(float(payloads[0].get("duration", 0.0)), 0.0, "fire_flame_arc must keep a burst duration for its one-shot visual")
	assert_gt(float(payloads[0].get("size", 0.0)), 100.0, "fire_flame_arc must keep a large circle radius")
	GameState.reset_progress_for_tests()

func test_fire_inferno_breath_cast_emits_payload_with_cone_multi_hit_and_burn_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(16.0, 6.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("fire_inferno_breath"), "fire_inferno_breath cast must succeed")
	assert_eq(payloads.size(), 1)
	var payload: Dictionary = payloads[0]
	assert_eq(str(payload.get("spell_id", "")), "fire_inferno_breath")
	assert_eq(str(payload.get("school", "")), "fire")
	assert_eq(float(payload.get("speed", -1.0)), 0.0, "fire_inferno_breath must stay as a stationary cone burst")
	assert_eq(str(payload.get("hitstop_mode", "")), "area_burst", "fire_inferno_breath must use area_burst hitstop for its short cone sweep")
	assert_eq(str(payload.get("attack_effect_id", "")), "fire_inferno_breath_attack")
	assert_eq(str(payload.get("hit_effect_id", "")), "fire_inferno_breath_hit")
	assert_eq(int(payload.get("multi_hit_count", 0)), 5, "fire_inferno_breath must keep its authored five-hit cadence")
	assert_gt(float(payload.get("duration", 0.0)), 0.35, "fire_inferno_breath must keep enough linger time to deliver its full cone pressure")
	assert_gt(float(payload.get("size", 0.0)), 100.0, "fire_inferno_breath must keep a readable cone footprint")
	var utility_effects: Array = payload.get("utility_effects", [])
	assert_eq(utility_effects.size(), 1)
	assert_eq(str(utility_effects[0].get("type", "")), "burn")
	assert_gte(float(utility_effects[0].get("chance", 0.0)), 0.2, "fire_inferno_breath must keep a reliable base burn rider")
	GameState.reset_progress_for_tests()

func test_fire_inferno_sigil_cast_emits_deploy_payload_with_visual_and_terminal_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("fire_inferno_sigil"), "fire_inferno_sigil deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "fire_inferno_sigil")
	assert_eq(str(payloads[0].get("school", "")), "fire")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "fire_inferno_sigil_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "fire_inferno_sigil_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "fire_inferno_sigil_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "deploy inferno field ticks must not freeze the whole combat loop")
	assert_gt(float(payloads[0].get("duration", 0.0)), 1.0, "fire_inferno_sigil must keep persistent field duration")
	assert_almost_eq(
		float(payloads[0].get("tick_interval", 0.0)),
		0.4,
		0.001,
		"fire_inferno_sigil must keep the rapid repeat cadence authored for 8-hit inferno pulses"
	)
	GameState.reset_progress_for_tests()

func test_fire_flame_storm_cast_emits_deploy_payload_with_dedicated_field_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("fire_flame_storm"), "fire_flame_storm deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "fire_flame_storm")
	assert_eq(str(payloads[0].get("school", "")), "fire")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "fire_flame_storm_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "fire_flame_storm_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "fire_flame_storm_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "persistent flame_storm ticks must not freeze the combat loop")
	assert_gt(float(payloads[0].get("duration", 0.0)), 1.0, "fire_flame_storm must persist as a field")
	assert_gt(float(payloads[0].get("tick_interval", 0.0)), 0.0, "fire_flame_storm must tick over time")
	GameState.reset_progress_for_tests()

func test_holy_bless_field_cast_emits_deploy_payload_with_support_field_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("holy_bless_field"), "holy_bless_field deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "holy_bless_field")
	assert_eq(str(payloads[0].get("school", "")), "holy")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "holy_bless_field_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "holy_bless_field_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "holy_bless_field_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "holy_bless_field field ticks must stay readable in combat")
	assert_gt(float(payloads[0].get("duration", 0.0)), 1.0, "holy_bless_field must persist as a blessing field")
	assert_gt(float(payloads[0].get("tick_interval", 0.0)), 0.0, "holy_bless_field must tick over time")
	assert_eq(int(payloads[0].get("damage", 0)), 0, "holy_bless_field must no longer use an offensive placeholder payload once its support meaning is locked")
	assert_gt(int(payloads[0].get("self_heal", 0)), 0, "holy_bless_field must carry a per-tick self-heal rider in the current solo runtime")
	var support_effects: Array = payloads[0].get("support_effects", [])
	assert_eq(str(support_effects[0].get("stat", "")), "poise_bonus")
	GameState.reset_progress_for_tests()


func test_holy_bless_field_support_ticks_heal_and_stabilize_owner_inside_field() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.health = GameState.max_health - 28
	var root := Node2D.new()
	add_child_autofree(root)
	var player = autofree(PLAYER_SCRIPT.new())
	root.add_child(player)
	player.global_position = Vector2.ZERO
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("holy_bless_field"), "holy_bless_field deploy cast must succeed")
	var projectile := _spawn_projectile_for_spell_coverage(root, payloads[0])
	await _advance_frames(70)
	assert_gt(GameState.health, GameState.max_health - 28, "holy_bless_field must restore health while the owner stays inside the blessing field")
	assert_gt(GameState.get_poise_bonus(), 0.0, "holy_bless_field must grant a stability buff while the owner stays inside the blessing field")
	player.global_position = Vector2(260.0, 0.0)
	await _advance_frames(180)
	assert_eq(GameState.get_poise_bonus(), 0.0, "holy_bless_field stability buff must expire shortly after the owner leaves the field")
	if is_instance_valid(projectile):
		projectile.queue_free()
	GameState.reset_progress_for_tests()

func test_ice_storm_cast_emits_deploy_payload_with_dedicated_field_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("ice_storm"), "ice_storm deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "ice_storm")
	assert_eq(str(payloads[0].get("school", "")), "ice")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "ice_storm_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "ice_storm_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "ice_storm_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "ice_storm field ticks must stay readable in combat")
	assert_gt(float(payloads[0].get("duration", 0.0)), 1.0, "ice_storm must persist as a frost field")
	assert_gt(float(payloads[0].get("tick_interval", 0.0)), 0.0, "ice_storm must tick over time")
	GameState.reset_progress_for_tests()

func test_ice_ice_wall_cast_emits_deploy_payload_with_dedicated_wall_control_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("ice_ice_wall"), "ice_ice_wall deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "ice_ice_wall")
	assert_eq(str(payloads[0].get("school", "")), "ice")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "ice_ice_wall_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "ice_ice_wall_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "ice_ice_wall_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "ice_ice_wall wall deploy should stay readable without burst hitstop")
	assert_gt(float(payloads[0].get("duration", 0.0)), 1.0, "ice_ice_wall must persist as a blocking wall shell")
	var payload_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(payload_effects.size(), 2, "ice_ice_wall must carry its chilling wall-control rider in the deploy payload")
	assert_eq(str(payload_effects[0].get("type", "")), "slow")
	assert_eq(str(payload_effects[1].get("type", "")), "root")
	GameState.reset_progress_for_tests()


func test_earth_stone_rampart_cast_emits_deploy_payload_with_dedicated_wall_control_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("earth_stone_rampart"), "earth_stone_rampart deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "earth_stone_rampart")
	assert_eq(str(payloads[0].get("school", "")), "earth")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "earth_stone_rampart_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "earth_stone_rampart_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "earth_stone_rampart_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "earth_stone_rampart wall deploy should stay readable without burst hitstop")
	assert_gt(float(payloads[0].get("duration", 0.0)), 1.0, "earth_stone_rampart must persist as a blocking wall shell")
	var payload_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(payload_effects.size(), 2, "earth_stone_rampart must carry its heavy wall-control rider in the deploy payload")
	assert_eq(str(payload_effects[0].get("type", "")), "slow")
	assert_eq(str(payload_effects[1].get("type", "")), "root")
	GameState.reset_progress_for_tests()

func test_fire_meteor_strike_cast_emits_payload_with_fallback_terminal_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("fire_meteor_strike"), "fire_meteor_strike cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "fire_meteor_strike_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "fire_meteor_strike_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "fire_meteor_strike_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst")
	GameState.reset_progress_for_tests()

func test_fire_apocalypse_flame_cast_emits_payload_with_fallback_terminal_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("fire_apocalypse_flame"), "fire_apocalypse_flame cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "fire_apocalypse_flame_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "fire_apocalypse_flame_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "fire_apocalypse_flame_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst")
	GameState.reset_progress_for_tests()

func test_fire_solar_cataclysm_cast_emits_payload_with_fallback_terminal_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("fire_solar_cataclysm"), "fire_solar_cataclysm cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "fire_solar_cataclysm_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "fire_solar_cataclysm_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "fire_solar_cataclysm_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst")
	GameState.reset_progress_for_tests()

func test_holy_cure_ray_cast_emits_payload_with_holy_school_and_self_heal_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.health = GameState.max_health - 24
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("holy_cure_ray"), "holy_cure_ray cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "holy_cure_ray")
	assert_eq(str(payloads[0].get("school", "")), "holy")
	assert_gt(float(payloads[0].get("speed", 0.0)), 0.0, "holy_cure_ray must stay as a moving ray projectile")
	assert_gt(int(payloads[0].get("self_heal", 0)), 0, "holy_cure_ray must carry a self-heal rider in the payload")
	assert_gt(GameState.health, GameState.max_health - 24, "holy_cure_ray cast must restore some player health in the current solo runtime")
	GameState.reset_progress_for_tests()

func test_wind_gale_cutter_cast_emits_payload_with_wind_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("wind_gale_cutter"), "wind_gale_cutter cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "wind_gale_cutter")
	assert_eq(str(payloads[0].get("school", "")), "wind")
	assert_gt(int(payloads[0].get("pierce", 0)), 0, "wind_gale_cutter must have pierce > 0")
	GameState.reset_progress_for_tests()

func test_wind_cyclone_prison_cast_emits_deploy_payload_with_visual_and_pull_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("wind_cyclone_prison"), "wind_cyclone_prison deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "wind_cyclone_prison")
	assert_eq(str(payloads[0].get("school", "")), "wind")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "wind_cyclone_prison_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "wind_cyclone_prison_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "wind_cyclone_prison_end")
	assert_gt(float(payloads[0].get("pull_strength", 0.0)), 0.0, "wind_cyclone_prison must carry pull_strength runtime data")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "persistent cyclone prison ticks must not freeze the whole combat loop")
	GameState.reset_progress_for_tests()

func test_holy_sanctuary_of_reversal_cast_emits_deploy_payload_with_reversal_survival_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("holy_sanctuary_of_reversal"), "holy_sanctuary_of_reversal deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "holy_sanctuary_of_reversal")
	assert_eq(str(payloads[0].get("school", "")), "holy")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "holy_sanctuary_of_reversal_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "holy_sanctuary_of_reversal_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "holy_sanctuary_of_reversal_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "sanctuary field ticks must stay readable in combat")
	assert_lt(float(payloads[0].get("duration", 0.0)), 3.5, "holy_sanctuary_of_reversal must stay a short reversal window instead of a long sanctuary field")
	assert_gt(float(payloads[0].get("tick_interval", 0.0)), 0.0, "holy_sanctuary_of_reversal must tick over time")
	assert_eq(int(payloads[0].get("damage", 0)), 0, "holy_sanctuary_of_reversal must not keep an offensive placeholder payload once its survival meaning is locked")
	assert_gt(int(payloads[0].get("self_heal", 0)), 0, "holy_sanctuary_of_reversal must carry an immediate heal rider for reversal play")
	var support_effects: Array = payloads[0].get("support_effects", [])
	assert_eq(str(support_effects[0].get("stat", "")), "damage_taken_multiplier")
	assert_eq(str(support_effects[1].get("stat", "")), "poise_bonus")
	GameState.reset_progress_for_tests()


func test_holy_sanctuary_of_reversal_support_window_heals_and_reduces_damage_taken_inside_field() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var base_multiplier := GameState.get_damage_taken_multiplier()
	GameState.health = 18
	var root := Node2D.new()
	add_child_autofree(root)
	var player = autofree(PLAYER_SCRIPT.new())
	root.add_child(player)
	player.global_position = Vector2.ZERO
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("holy_sanctuary_of_reversal"), "holy_sanctuary_of_reversal deploy cast must succeed")
	var projectile := _spawn_projectile_for_spell_coverage(root, payloads[0])
	await _advance_frames(20)
	assert_gt(GameState.health, 18, "holy_sanctuary_of_reversal must immediately recover enough health to create a reversal window")
	assert_lt(GameState.get_damage_taken_multiplier(), base_multiplier, "holy_sanctuary_of_reversal must reduce incoming damage while the owner stays inside the sanctuary")
	var health_before_hit := GameState.health
	GameState.damage(50, "fire")
	var damage_taken := health_before_hit - GameState.health
	assert_lt(damage_taken, 50, "holy_sanctuary_of_reversal reversal window must cut incoming damage instead of reading like a plain heal field")
	player.global_position = Vector2(480.0, 0.0)
	await _advance_frames(180)
	assert_eq(GameState.get_damage_taken_multiplier(), base_multiplier, "holy_sanctuary_of_reversal guard window must expire shortly after the owner leaves the sanctuary")
	if is_instance_valid(projectile):
		projectile.queue_free()
	GameState.reset_progress_for_tests()

func test_fire_hellfire_field_cast_emits_deploy_payload_with_large_dedicated_field_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("fire_hellfire_field"), "fire_hellfire_field deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "fire_hellfire_field")
	assert_eq(str(payloads[0].get("school", "")), "fire")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "fire_hellfire_field_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "fire_hellfire_field_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "fire_hellfire_field_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "persistent hellfire ticks must not freeze the combat loop")
	assert_gt(float(payloads[0].get("size", 0.0)), 180.0, "fire_hellfire_field must preserve its large late-game footprint")
	assert_gt(float(payloads[0].get("tick_interval", 0.0)), 0.0, "fire_hellfire_field must tick over time")
	GameState.reset_progress_for_tests()

func test_plant_world_root_cast_emits_deploy_payload_with_dedicated_field_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("plant_world_root"), "plant_world_root deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "plant_world_root")
	assert_eq(str(payloads[0].get("school", "")), "plant")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "plant_world_root_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "plant_world_root_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "plant_world_root_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "plant_world_root field ticks must stay readable in combat")
	assert_gt(float(payloads[0].get("size", 0.0)), 170.0, "plant_world_root must preserve its wide root field footprint")
	assert_gt(float(payloads[0].get("tick_interval", 0.0)), 0.0, "plant_world_root must tick over time")
	GameState.reset_progress_for_tests()

func test_plant_worldroot_bastion_cast_emits_deploy_payload_with_dedicated_field_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("plant_worldroot_bastion"), "plant_worldroot_bastion deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "plant_worldroot_bastion")
	assert_eq(str(payloads[0].get("school", "")), "plant")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "plant_worldroot_bastion_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "plant_worldroot_bastion_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "plant_worldroot_bastion_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "plant_worldroot_bastion field ticks must stay readable in combat")
	assert_gte(float(payloads[0].get("size", 0.0)), 140.0, "plant_worldroot_bastion must preserve at least its authored bastion radius")
	var genesis_runtime := GameState.get_data_driven_skill_runtime(
		"plant_genesis_arbor",
		GameDatabase.get_skill_data("plant_genesis_arbor")
	)
	assert_lt(
		float(payloads[0].get("size", 0.0)),
		float(genesis_runtime.get("size", 0.0)),
		"plant_worldroot_bastion field should stay below genesis_arbor's endgame canopy footprint"
	)
	assert_gt(float(payloads[0].get("tick_interval", 0.0)), 0.0, "plant_worldroot_bastion must tick over time")
	GameState.reset_progress_for_tests()

func test_plant_genesis_arbor_cast_emits_deploy_payload_with_dedicated_field_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("plant_genesis_arbor"), "plant_genesis_arbor deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "plant_genesis_arbor")
	assert_eq(str(payloads[0].get("school", "")), "plant")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "plant_genesis_arbor_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "plant_genesis_arbor_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "plant_genesis_arbor_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "plant_genesis_arbor field ticks must stay readable in combat")
	assert_gt(float(payloads[0].get("size", 0.0)), 190.0, "plant_genesis_arbor must preserve its final-tier canopy footprint")
	assert_gt(float(payloads[0].get("tick_interval", 0.0)), 0.0, "plant_genesis_arbor must tick over time")
	GameState.reset_progress_for_tests()

func test_plant_vine_snare_cast_emits_deploy_payload_with_dedicated_vine_bind_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("plant_vine_snare"), "plant_vine_snare deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "plant_vine_snare")
	assert_eq(str(payloads[0].get("school", "")), "plant")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "plant_vine_snare_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "plant_vine_snare_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "plant_vine_snare_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "plant_vine_snare field ticks must stay readable in combat")
	assert_gte(float(payloads[0].get("size", 0.0)), 96.0, "plant_vine_snare must preserve at least its authored snare radius")
	assert_lt(float(payloads[0].get("size", 0.0)), 150.0, "plant_vine_snare dedicated vine-bind field must stay below later plant field tiers")
	assert_gt(float(payloads[0].get("tick_interval", 0.0)), 0.0, "plant_vine_snare must tick over time")
	var utility_effects: Array = payloads[0].get("utility_effects", [])
	assert_eq(str(utility_effects[0].get("type", "")), "root", "plant_vine_snare dedicated contract must keep repeated root pulses")
	GameState.reset_progress_for_tests()

func test_dark_shadow_bind_cast_emits_deploy_payload_with_dedicated_curse_field_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("dark_shadow_bind"), "dark_shadow_bind deploy cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "dark_shadow_bind")
	assert_eq(str(payloads[0].get("school", "")), "dark")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "dark_shadow_bind_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "dark_shadow_bind_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "dark_shadow_bind_end")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "none", "dark_shadow_bind field ticks must stay readable in combat")
	assert_gte(float(payloads[0].get("size", 0.0)), 110.0, "dark_shadow_bind must preserve at least its authored curse field radius")
	assert_lt(float(payloads[0].get("size", 0.0)), 170.0, "dark_shadow_bind placeholder field must stay below later dark field tiers")
	assert_gt(float(payloads[0].get("tick_interval", 0.0)), 0.0, "dark_shadow_bind must tick over time")
	GameState.reset_progress_for_tests()

func test_earth_tremor_cast_emits_payload_with_earth_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("earth_tremor"), "earth_tremor cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "earth_tremor")
	assert_eq(str(payloads[0].get("school", "")), "earth")
	assert_gt(int(payloads[0].get("knockback", 0)), 0, "earth_tremor must have knockback > 0")
	GameState.reset_progress_for_tests()

func test_holy_radiant_burst_cast_emits_payload_with_holy_school_and_self_heal_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.health = GameState.max_health - 18
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("holy_radiant_burst"), "holy_radiant_burst cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "holy_radiant_burst")
	assert_eq(str(payloads[0].get("school", "")), "holy")
	assert_gt(float(payloads[0].get("speed", 0.0)), 0.0, "holy_radiant_burst must have positive speed")
	assert_gt(int(payloads[0].get("self_heal", 0)), 0, "holy_radiant_burst must carry a self-heal rider in the current solo runtime")
	assert_gt(GameState.health, GameState.max_health - 18, "holy_radiant_burst cast must restore some player health on cast")
	GameState.reset_progress_for_tests()

func test_holy_judgment_halo_cast_emits_payload_with_holy_school_and_area_burst_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(6.0, 3.0)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("holy_judgment_halo"), "holy_judgment_halo cast must succeed")
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("spell_id", "")), "holy_judgment_halo")
	assert_eq(str(payloads[0].get("school", "")), "holy")
	assert_eq(float(payloads[0].get("speed", -1.0)), 0.0, "holy_judgment_halo must stay as a stationary final burst")
	assert_eq(str(payloads[0].get("hitstop_mode", "")), "area_burst", "holy_judgment_halo must use area_burst hitstop")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "holy_judgment_halo_end", "holy_judgment_halo must carry its closing heavenly burst id")
	assert_gt(float(payloads[0].get("size", 0.0)), 120.0, "holy_judgment_halo must keep a wide burst radius")
	GameState.reset_progress_for_tests()

func test_dark_void_bolt_cast_emits_payload_with_dark_school() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("dark_void_bolt"), "dark_void_bolt cast must succeed with infinite mana")
	assert_eq(payloads.size(), 1, "Exactly one payload must be emitted for dark_void_bolt")
	assert_eq(str(payloads[0].get("spell_id", "")), "dark_void_bolt")
	assert_eq(str(payloads[0].get("school", "")), "dark", "Payload school must be dark")
	GameState.reset_progress_for_tests()

func test_arcane_force_pulse_cast_emits_payload_with_arcane_school_and_split_effect_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("arcane_force_pulse"), "arcane_force_pulse cast must succeed with infinite mana")
	assert_eq(payloads.size(), 1, "Exactly one payload must be emitted for arcane_force_pulse")
	assert_eq(str(payloads[0].get("spell_id", "")), "arcane_force_pulse")
	assert_eq(str(payloads[0].get("school", "")), "arcane", "Payload school must be arcane")
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "arcane_force_pulse_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "arcane_force_pulse_hit")
	assert_eq(float(payloads[0].get("cooldown", -1.0)), 0.0, "arcane_force_pulse must now behave like a zero-cooldown low-circle active")
	assert_gt(float(payloads[0].get("speed", 0.0)), 900.0, "arcane_force_pulse must keep its fast arcane projectile travel speed")
	GameState.reset_progress_for_tests()

func test_arcane_pulse_preset_applies_and_boosts_arcane_damage() -> void:
	GameState.reset_progress_for_tests()
	var base := GameState.get_equipment_damage_multiplier("arcane")
	assert_true(GameState.apply_equipment_preset("arcane_pulse"), "arcane_pulse preset must apply")
	var boosted := GameState.get_equipment_damage_multiplier("arcane")
	assert_gt(boosted, base, "arcane_pulse preset must boost arcane damage multiplier")
	GameState.reset_progress_for_tests()

func test_dark_void_bolt_damage_boosted_by_void_lens() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager_plain = SPELL_MANAGER_SCRIPT.new()
	manager_plain.setup(player)
	var payloads_plain: Array = []
	manager_plain.spell_cast.connect(func(p: Dictionary) -> void: payloads_plain.append(p))
	assert_true(manager_plain.attempt_cast("dark_void_bolt"))
	var dmg_plain: int = int(payloads_plain[0].get("damage", 0))

	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.set_equipped_item("offhand", "focus_void_lens")
	var player2 = autofree(PLAYER_SCRIPT.new())
	var manager_lens = SPELL_MANAGER_SCRIPT.new()
	manager_lens.setup(player2)
	var payloads_lens: Array = []
	manager_lens.spell_cast.connect(func(p: Dictionary) -> void: payloads_lens.append(p))
	assert_true(manager_lens.attempt_cast("dark_void_bolt"))
	var dmg_lens: int = int(payloads_lens[0].get("damage", 0))
	assert_gt(dmg_lens, dmg_plain, "focus_void_lens must increase dark_void_bolt damage payload")
	GameState.reset_progress_for_tests()

func test_volt_spear_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 440.0,
		"team": "player",
		"damage": 22,
		"knockback": 320.0,
		"school": "lightning",
		"size": 12.0,
		"spell_id": "volt_spear",
		"color": "#f7ef6a"
	})
	assert_gt(projectile.get_child_count(), 0, "volt_spear projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "volt_spear must use AnimatedSprite2D effect visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 15, "volt_spear effect must load all sampled frames")
	assert_lt(sprite.scale.x, 0.0, "volt_spear effect must flip when traveling left")

func test_arcane_force_pulse_projectile_uses_dedicated_arcane_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 460.0,
		"team": "player",
		"damage": 17,
		"knockback": 240.0,
		"school": "arcane",
		"size": 12.0,
		"spell_id": "arcane_force_pulse"
	})
	var visual_spec: Dictionary = projectile.SPELL_VISUAL_SPECS.get("arcane_force_pulse", {})
	assert_eq(
		str(visual_spec.get("dir_path", "")),
		"res://assets/effects/arcane_force_pulse/",
		"arcane_force_pulse must read projectile frames from its dedicated family path"
	)
	var attack_spec: Dictionary = projectile.WORLD_EFFECT_SPECS.get("arcane_force_pulse_attack", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/arcane_force_pulse_attack/",
		"arcane_force_pulse must read its attack burst from a dedicated family path"
	)
	assert_gt(projectile.get_child_count(), 0, "arcane_force_pulse projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "arcane_force_pulse must use AnimatedSprite2D effect visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 6, "arcane_force_pulse effect must load all dedicated sampled frames")
	assert_lt(sprite.scale.x, 0.0, "arcane_force_pulse effect must flip when traveling left")

func test_fire_inferno_breath_projectile_uses_dedicated_breath_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 240.0,
		"team": "player",
		"damage": 50,
		"knockback": 180.0,
		"school": "fire",
		"size": 128.0,
		"duration": 0.42,
		"spell_id": "fire_inferno_breath"
	})
	var visual_spec: Dictionary = projectile.SPELL_VISUAL_SPECS.get("fire_inferno_breath", {})
	assert_eq(
		str(visual_spec.get("dir_path", "")),
		"res://assets/effects/fire_inferno_breath/",
		"fire_inferno_breath must read projectile frames from its dedicated fire-breath family path"
	)
	var attack_spec: Dictionary = projectile.WORLD_EFFECT_SPECS.get("fire_inferno_breath_attack", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/fire_inferno_breath_attack/",
		"fire_inferno_breath must read its startup breath from a dedicated family path"
	)
	assert_gt(projectile.get_child_count(), 0, "fire_inferno_breath projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "fire_inferno_breath must use AnimatedSprite2D effect visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 24, "fire_inferno_breath effect must load all dedicated sampled frames")
	assert_lt(sprite.scale.x, 0.0, "fire_inferno_breath effect must flip when traveling left")

func test_volt_spear_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("volt_spear"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "volt_spear_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "volt_spear_hit")
	GameState.reset_progress_for_tests()

func test_fire_bolt_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("fire_bolt"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "fire_bolt_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "fire_bolt_hit")
	GameState.reset_progress_for_tests()

func test_fire_bolt_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(120.0, 0.0),
		"range": 320.0,
		"team": "player",
		"damage": 16,
		"knockback": 180.0,
		"school": "fire",
		"size": 10.0,
		"spell_id": "fire_bolt",
		"attack_effect_id": "fire_bolt_attack",
		"hit_effect_id": "fire_bolt_hit",
		"color": "#ff9f45"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("fire_bolt_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "fire_bolt must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 8, "fire_bolt attack effect must use cropped single-effect sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "fire_bolt attack effect frame must be a 64px cropped tile")
	assert_gt(attack_effect.scale.x, 0.0, "fire_bolt attack effect should keep native orientation on rightward cast")

func test_fire_bolt_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var spawned_effects: Array = []
	projectile.world_effect_spawned.connect(func(effect_id: String, effect_stage: String) -> void:
		spawned_effects.append({"id": effect_id, "stage": effect_stage})
	)
	projectile.setup({
		"position": Vector2(18.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 320.0,
		"team": "player",
		"damage": 16,
		"total_damage": 16,
		"knockback": 180.0,
		"school": "fire",
		"size": 10.0,
		"spell_id": "fire_bolt",
		"multi_hit_count": 2,
		"hit_interval": 0.06,
		"attack_effect_id": "fire_bolt_attack",
		"hit_effect_id": "fire_bolt_hit",
		"color": "#ff9f45"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().create_timer(0.18).timeout
	var hit_effect := root.get_node_or_null("fire_bolt_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "fire_bolt must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8, "fire_bolt hit effect must use cropped single-effect sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "fire_bolt hit effect frame must be a 64px cropped tile")
	var attack_effect_count := 0
	var hit_effect_count := 0
	for effect in spawned_effects:
		if str(effect.get("id", "")) == "fire_bolt_attack" and str(effect.get("stage", "")) == "attack":
			attack_effect_count += 1
		if str(effect.get("id", "")) == "fire_bolt_hit" and str(effect.get("stage", "")) == "hit":
			hit_effect_count += 1
	assert_eq(attack_effect_count, 1, "fire_bolt attack effect must spawn once even when the hit count is greater than 1")
	assert_eq(hit_effect_count, 2, "fire_bolt hit effect must repeat once per authored hit")
	assert_eq(target.received_hits.size(), 2)
	assert_eq(int(target.received_hits[0].get("damage", 0)), 8)
	assert_eq(int(target.received_hits[1].get("damage", 0)), 8)
	assert_eq(str(target.received_hits[0].get("school", "")), "fire")

func test_fire_inferno_sigil_deploy_spawns_hit_and_terminal_effects() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 180.0,
		"duration": 6.0,
		"team": "player",
		"damage": 56,
		"knockback": 220.0,
		"school": "fire",
		"size": 180.0,
		"spell_id": "fire_inferno_sigil",
		"attack_effect_id": "fire_inferno_sigil_attack",
		"hit_effect_id": "fire_inferno_sigil_hit",
		"terminal_effect_id": "fire_inferno_sigil_end",
		"tick_interval": 2.4,
		"color": "#ffbb74"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("fire_inferno_sigil_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "fire_inferno_sigil must spawn a sigil startup effect when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 17)
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target, false)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("fire_inferno_sigil_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "fire_inferno_sigil must spawn a looping explosion hit effect during field ticks")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 13)
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "fire")
	projectile._finish_projectile()
	await get_tree().process_frame
	assert_true(projectile.terminal_effect_played, "fire_inferno_sigil must play a terminal burst when the field expires")
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "fire_inferno_sigil must swap in a terminal inferno burst visual")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 17)

func test_fire_inferno_sigil_practical_tuning_keeps_gap_between_tick_flashes() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 180.0,
		"duration": 6.0,
		"team": "player",
		"damage": 56,
		"knockback": 220.0,
		"school": "fire",
		"size": 180.0,
		"spell_id": "fire_inferno_sigil",
		"attack_effect_id": "fire_inferno_sigil_attack",
		"hit_effect_id": "fire_inferno_sigil_hit",
		"terminal_effect_id": "fire_inferno_sigil_end",
		"tick_interval": 2.4,
		"target_count": 6,
		"color": "#ffbb74"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile.tracked_bodies[target.get_instance_id()] = target
	assert_true(projectile._hit_enemy(target, false), "fire_inferno_sigil must support an immediate placement hit without collapsing the field")
	assert_eq(target.received_hits.size(), 1, "fire_inferno_sigil should apply one opening hit when cast directly on a target")
	var hit_sprite := projectile._create_world_effect_visual("fire_inferno_sigil_hit") as AnimatedSprite2D
	assert_true(hit_sprite != null, "fire_inferno_sigil hit flash must resolve from the shared world-effect registry")
	var hit_frame_count := hit_sprite.sprite_frames.get_frame_count("fly")
	var hit_fps := hit_sprite.sprite_frames.get_animation_speed("fly")
	var hit_duration := float(hit_frame_count) / maxf(hit_fps, 1.0)
	assert_lt(
		hit_duration,
		float(projectile.tick_interval),
		"fire_inferno_sigil hit flash must finish before the next tuned pulse to preserve readability"
	)
	hit_sprite.free()
	projectile._tick_hit_windows(1.2)
	assert_false(projectile._can_hit_body(target.get_instance_id()), "fire_inferno_sigil should keep the target on cooldown through the mid-gap window")
	projectile._tick_hit_windows(1.2)
	assert_true(projectile._can_hit_body(target.get_instance_id()), "fire_inferno_sigil should reopen damage exactly on the tuned 2.4s pulse window")
	assert_true(projectile._hit_enemy(target, false), "fire_inferno_sigil should accept the next pulse hit once the tuned cooldown window ends")
	assert_eq(target.received_hits.size(), 2, "fire_inferno_sigil should resume damage when the next tuned pulse actually fires")

func test_fire_inferno_sigil_sandbox_boss_and_mob_mix_feel_validation() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("fire_inferno_sigil"), "fire_inferno_sigil must cast in the mixed sandbox scenario")
	assert_eq(payloads.size(), 1)
	var payload: Dictionary = payloads[0]
	var boss := _spawn_enemy_for_spell_coverage(root, "boss")
	var brute := _spawn_enemy_for_spell_coverage(root, "brute")
	var sentinel := _spawn_enemy_for_spell_coverage(root, "sentinel")
	for enemy in [boss, brute, sentinel]:
		enemy.target = null
		enemy.gravity = 0.0
		enemy.velocity = Vector2.ZERO
		enemy.set_physics_process(false)
	boss.global_position = Vector2(54.0, -6.0)
	brute.global_position = Vector2(108.0, -8.0)
	sentinel.global_position = Vector2(8.0, -2.0)
	var boss_hp_before: int = boss.health
	var brute_hp_before: int = brute.health
	var sentinel_hp_before: int = sentinel.health
	var session_hits_before: int = GameState.session_hit_count
	var projectile := SPELL_PROJECTILE_SCRIPT.new()
	projectile.setup(payload)
	root.add_child(projectile)
	projectile.tracked_bodies[boss.get_instance_id()] = boss
	projectile.tracked_bodies[brute.get_instance_id()] = brute
	projectile.tracked_bodies[sentinel.get_instance_id()] = sentinel
	projectile._tick_persistent_hits(0.0)
	assert_lt(boss.health, boss_hp_before, "fire_inferno_sigil must pressure the boss on the opening pulse")
	assert_lt(brute.health, brute_hp_before, "fire_inferno_sigil opening pulse must also tag nearby melee trash")
	assert_lt(sentinel.health, sentinel_hp_before, "fire_inferno_sigil opening pulse must also tag nearby support trash")
	assert_gte(GameState.session_hit_count, session_hits_before + 3, "fire_inferno_sigil mixed scenario should register at least one hit per enemy on the opening pulse")
	var boss_after_opening: int = boss.health
	var brute_after_opening: int = brute.health
	var sentinel_after_opening: int = sentinel.health
	projectile._tick_hit_windows(0.2)
	projectile._tick_persistent_hits(0.2)
	assert_eq(boss.health, boss_after_opening, "fire_inferno_sigil follow-up pulse must not land before the 0.4s cadence completes")
	assert_eq(brute.health, brute_after_opening, "trash enemies should wait until the first 0.4s inferno follow-up pulse")
	assert_eq(sentinel.health, sentinel_after_opening, "support trash should also wait until the first 0.4s inferno follow-up pulse")
	projectile._tick_hit_windows(0.2)
	projectile._tick_persistent_hits(0.2)
	assert_lt(boss.health, boss_after_opening, "fire_inferno_sigil must resume boss pressure once the 0.4s inferno cadence completes")
	assert_true(
		brute.health < brute_after_opening or sentinel.health < sentinel_after_opening,
		"fire_inferno_sigil next pulse should keep contributing to mixed-pack clear pressure"
	)
	assert_false(projectile.terminal_effect_played, "fire_inferno_sigil should still be sustaining its field during the mixed-pack pressure window")

func test_holy_radiant_burst_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("holy_radiant_burst"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "holy_radiant_burst_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "holy_radiant_burst_hit")
	GameState.reset_progress_for_tests()

func test_holy_cure_ray_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("holy_cure_ray"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "holy_cure_ray_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "holy_cure_ray_hit")
	GameState.reset_progress_for_tests()

func test_holy_judgment_halo_cast_payload_includes_attack_hit_and_terminal_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("holy_judgment_halo"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "holy_judgment_halo_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "holy_judgment_halo_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "holy_judgment_halo_end")
	GameState.reset_progress_for_tests()

func test_holy_radiant_burst_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(120.0, 0.0),
		"range": 360.0,
		"team": "player",
		"damage": 24,
		"knockback": 220.0,
		"school": "holy",
		"size": 12.0,
		"spell_id": "holy_radiant_burst",
		"attack_effect_id": "holy_radiant_burst_attack",
		"hit_effect_id": "holy_radiant_burst_hit",
		"color": "#fff5b8"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("holy_radiant_burst_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "holy_radiant_burst must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 8, "holy attack effect must use cropped single-effect sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "holy attack effect frame must be a 64px cropped tile")
	assert_gt(attack_effect.scale.x, 0.0, "holy attack effect should keep native orientation on rightward cast")

func test_holy_radiant_burst_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(20.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 360.0,
		"team": "player",
		"damage": 24,
		"knockback": 220.0,
		"school": "holy",
		"size": 12.0,
		"spell_id": "holy_radiant_burst",
		"attack_effect_id": "holy_radiant_burst_attack",
		"hit_effect_id": "holy_radiant_burst_hit",
		"color": "#fff5b8"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("holy_radiant_burst_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "holy_radiant_burst must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8, "holy hit effect must use cropped single-effect sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "holy hit effect frame must be a 64px cropped tile")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "holy")

func test_holy_cure_ray_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(160.0, 0.0),
		"range": 420.0,
		"team": "player",
		"damage": 20,
		"knockback": 180.0,
		"school": "holy",
		"size": 16.0,
		"spell_id": "holy_cure_ray",
		"attack_effect_id": "holy_cure_ray_attack",
		"hit_effect_id": "holy_cure_ray_hit",
		"color": "#fff2b0"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("holy_cure_ray_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "holy_cure_ray must spawn a heal-mark attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 12)
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64)
	assert_gt(attack_effect.scale.x, 0.0, "holy_cure_ray attack effect should keep native orientation on rightward cast")

func test_holy_cure_ray_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(20.0, -10.0),
		"velocity": Vector2(160.0, 0.0),
		"range": 420.0,
		"team": "player",
		"damage": 20,
		"knockback": 180.0,
		"school": "holy",
		"size": 16.0,
		"spell_id": "holy_cure_ray",
		"attack_effect_id": "holy_cure_ray_attack",
		"hit_effect_id": "holy_cure_ray_hit",
		"color": "#fff2b0"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("holy_cure_ray_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "holy_cure_ray must spawn a holy impact sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 7)
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64)
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "holy")

func test_holy_judgment_halo_projectile_spawns_attack_and_terminal_effects() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 160.0,
		"duration": 0.02,
		"team": "player",
		"damage": 78,
		"knockback": 360.0,
		"school": "holy",
		"size": 150.0,
		"spell_id": "holy_judgment_halo",
		"attack_effect_id": "holy_judgment_halo_attack",
		"hit_effect_id": "holy_judgment_halo_hit",
		"terminal_effect_id": "holy_judgment_halo_end",
		"color": "#fff8d2"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("holy_judgment_halo_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "holy_judgment_halo must spawn a startup judgment mark when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 11)
	projectile._finish_projectile()
	await get_tree().process_frame
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "holy_judgment_halo must replace its body visual with a heavenly terminal burst")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 12)

func test_fire_meteor_strike_projectile_spawns_attack_and_terminal_effects() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 184.0,
		"duration": 0.02,
		"team": "player",
		"damage": 54,
		"knockback": 300.0,
		"school": "fire",
		"size": 184.0,
		"spell_id": "fire_meteor_strike",
		"attack_effect_id": "fire_meteor_strike_attack",
		"hit_effect_id": "fire_meteor_strike_hit",
		"terminal_effect_id": "fire_meteor_strike_end",
		"color": "#ffd29a"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("fire_meteor_strike_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "fire_meteor_strike must spawn a meteor telegraph when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 4)
	projectile._finish_projectile()
	await get_tree().process_frame
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "fire_meteor_strike must replace its body visual with an ember terminal burst")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 4)

func test_fire_apocalypse_flame_projectile_spawns_attack_and_terminal_effects() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 204.0,
		"duration": 0.02,
		"team": "player",
		"damage": 68,
		"knockback": 340.0,
		"school": "fire",
		"size": 204.0,
		"spell_id": "fire_apocalypse_flame",
		"attack_effect_id": "fire_apocalypse_flame_attack",
		"hit_effect_id": "fire_apocalypse_flame_hit",
		"terminal_effect_id": "fire_apocalypse_flame_end",
		"color": "#ffe1b2"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("fire_apocalypse_flame_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "fire_apocalypse_flame must spawn a large apocalypse telegraph when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 4)
	projectile._finish_projectile()
	await get_tree().process_frame
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "fire_apocalypse_flame must replace its body visual with a heavier ember-collapse burst")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 4)

func test_fire_solar_cataclysm_projectile_spawns_attack_and_terminal_effects() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 218.0,
		"duration": 0.02,
		"team": "player",
		"damage": 74,
		"knockback": 380.0,
		"school": "fire",
		"size": 218.0,
		"spell_id": "fire_solar_cataclysm",
		"attack_effect_id": "fire_solar_cataclysm_attack",
		"hit_effect_id": "fire_solar_cataclysm_hit",
		"terminal_effect_id": "fire_solar_cataclysm_end",
		"color": "#fff0c6"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("fire_solar_cataclysm_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "fire_solar_cataclysm must spawn a large solar telegraph when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 4)
	projectile._finish_projectile()
	await get_tree().process_frame
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "fire_solar_cataclysm must replace its body visual with a heavier solar-collapse burst")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 4)

func test_ice_absolute_zero_projectile_spawns_attack_and_terminal_effects() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -10.0),
		"velocity": Vector2.ZERO,
		"range": 216.0,
		"duration": 0.02,
		"team": "player",
		"damage": 70,
		"knockback": 260.0,
		"school": "ice",
		"size": 216.0,
		"spell_id": "ice_absolute_zero",
		"attack_effect_id": "ice_absolute_zero_attack",
		"hit_effect_id": "ice_absolute_zero_hit",
		"terminal_effect_id": "ice_absolute_zero_end",
		"color": "#f0feff"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("ice_absolute_zero_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "ice_absolute_zero must spawn a final freeze telegraph when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 4)
	projectile._finish_projectile()
	await get_tree().process_frame
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "ice_absolute_zero must replace its body visual with a final freeze-collapse burst")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 4)

func test_earth_gaia_break_projectile_spawns_attack_and_terminal_effects() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 176.0,
		"duration": 0.02,
		"team": "player",
		"damage": 52,
		"knockback": 420.0,
		"school": "earth",
		"size": 176.0,
		"spell_id": "earth_gaia_break",
		"attack_effect_id": "earth_gaia_break_attack",
		"hit_effect_id": "earth_gaia_break_hit",
		"terminal_effect_id": "earth_gaia_break_end",
		"color": "#d0b080"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("earth_gaia_break_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "earth_gaia_break must spawn a collapse startup flare when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 6)
	projectile._finish_projectile()
	await get_tree().process_frame
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "earth_gaia_break must replace its body visual with a dust-collapse terminal burst")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 6)

func test_earth_continental_crush_projectile_spawns_attack_and_terminal_effects() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 198.0,
		"duration": 0.02,
		"team": "player",
		"damage": 64,
		"knockback": 460.0,
		"school": "earth",
		"size": 198.0,
		"spell_id": "earth_continental_crush",
		"attack_effect_id": "earth_continental_crush_attack",
		"hit_effect_id": "earth_continental_crush_hit",
		"terminal_effect_id": "earth_continental_crush_end",
		"color": "#dfc295"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("earth_continental_crush_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "earth_continental_crush must spawn a large collapse telegraph when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 6)
	projectile._finish_projectile()
	await get_tree().process_frame
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "earth_continental_crush must replace its body visual with a heavier terminal dust burst")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 6)

func test_earth_world_end_break_projectile_spawns_attack_and_terminal_effects() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -12.0),
		"velocity": Vector2.ZERO,
		"range": 214.0,
		"duration": 0.02,
		"team": "player",
		"damage": 72,
		"knockback": 500.0,
		"school": "earth",
		"size": 214.0,
		"spell_id": "earth_world_end_break",
		"attack_effect_id": "earth_world_end_break_attack",
		"hit_effect_id": "earth_world_end_break_hit",
		"terminal_effect_id": "earth_world_end_break_end",
		"color": "#ead3ab"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("earth_world_end_break_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "earth_world_end_break must spawn a final collapse telegraph when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 6)
	projectile._finish_projectile()
	await get_tree().process_frame
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "earth_world_end_break must replace its body visual with the heaviest terminal dust burst")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 6)

func test_water_tsunami_projectile_spawns_attack_and_terminal_effects() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(220.0, 0.0),
		"range": 520.0,
		"duration": 0.02,
		"team": "player",
		"damage": 40,
		"knockback": 340.0,
		"school": "water",
		"size": 56.0,
		"pierce": 5,
		"spell_id": "water_tsunami",
		"attack_effect_id": "water_tsunami_attack",
		"hit_effect_id": "water_tsunami_hit",
		"terminal_effect_id": "water_tsunami_end",
		"color": "#a2f2ff"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("water_tsunami_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "water_tsunami must spawn a startup tidal flare when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 6)
	projectile._finish_projectile()
	await get_tree().process_frame
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "water_tsunami must replace its body visual with a trailing vortex burst")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 6)

func test_water_ocean_collapse_projectile_spawns_attack_and_terminal_effects() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(220.0, 0.0),
		"range": 560.0,
		"duration": 0.02,
		"team": "player",
		"damage": 52,
		"knockback": 380.0,
		"school": "water",
		"size": 68.0,
		"pierce": 7,
		"spell_id": "water_ocean_collapse",
		"attack_effect_id": "water_ocean_collapse_attack",
		"hit_effect_id": "water_ocean_collapse_hit",
		"terminal_effect_id": "water_ocean_collapse_end",
		"color": "#b7f8ff"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("water_ocean_collapse_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "water_ocean_collapse must spawn a broader tidal-collapse flare when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 6)
	projectile._finish_projectile()
	await get_tree().process_frame
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "water_ocean_collapse must replace its body visual with a larger collapse vortex burst")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 6)

func test_holy_judgment_halo_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 160.0,
		"duration": 0.44,
		"team": "player",
		"damage": 78,
		"knockback": 360.0,
		"school": "holy",
		"size": 150.0,
		"spell_id": "holy_judgment_halo",
		"attack_effect_id": "holy_judgment_halo_attack",
		"hit_effect_id": "holy_judgment_halo_hit",
		"terminal_effect_id": "holy_judgment_halo_end",
		"color": "#fff8d2"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("holy_judgment_halo_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "holy_judgment_halo must spawn a judgment burst sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 11)
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64)
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "holy")

func test_ice_frost_needle_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("ice_frost_needle"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "ice_frost_needle_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "ice_frost_needle_hit")
	GameState.reset_progress_for_tests()

func test_ice_frost_needle_projectile_spawns_hit_effect_and_applies_slow_to_enemy() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	enemy.target = null
	enemy.global_position = Vector2(24.0, -4.0)
	await _advance_frames(2)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup(_force_status_effect_rolls({
		"position": Vector2(18.0, -10.0),
		"velocity": Vector2(160.0, 0.0),
		"range": 460.0,
		"duration": 1.6,
		"team": "player",
		"damage": 18,
		"knockback": 180.0,
		"school": "ice",
		"size": 12.0,
		"spell_id": "ice_frost_needle",
		"attack_effect_id": "ice_frost_needle_attack",
		"hit_effect_id": "ice_frost_needle_hit",
		"utility_effects": [
			{"type": "slow", "value": 0.25, "duration": 1.6}
		],
		"color": "#b9f4ff"
	}))
	root.add_child(projectile)
	await get_tree().process_frame
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy), "ice_frost_needle must connect through the projectile hit path")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "ice_frost_needle_hit", "hit")
	assert_true(hit_effect != null, "ice_frost_needle must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8)
	assert_lt(enemy.health, hp_before, "ice_frost_needle must deal damage on hit")
	assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "ice_frost_needle must apply slow on hit")
	assert_lt(enemy.slow_multiplier, 1.0, "ice_frost_needle slow must reduce movement multiplier")

func test_water_tidal_ring_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("water_tidal_ring"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "water_tidal_ring_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "water_tidal_ring_hit")
	GameState.reset_progress_for_tests()

func test_water_aqua_geyser_cast_emits_fixed_forward_burst_payload_with_terminal_contract() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	player.global_position = Vector2(20.0, 4.0)
	player.facing = 1
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("water_aqua_geyser"))
	assert_eq(payloads.size(), 1)
	var payload: Dictionary = payloads[0]
	assert_eq(str(payload.get("spell_id", "")), "water_aqua_geyser")
	assert_eq(str(payload.get("school", "")), "water")
	assert_eq(payload.get("position", Vector2.ZERO), Vector2(116.0, -2.0))
	assert_eq(payload.get("velocity", Vector2.ONE), Vector2.ZERO)
	assert_eq(str(payload.get("attack_effect_id", "")), "water_aqua_geyser_attack")
	assert_eq(str(payload.get("hit_effect_id", "")), "water_aqua_geyser_hit")
	assert_eq(str(payload.get("terminal_effect_id", "")), "water_aqua_geyser_end")
	assert_eq(str(payload.get("hitstop_mode", "")), "area_burst")
	assert_gt(float(payload.get("duration", 0.0)), 0.3, "water_aqua_geyser must keep enough linger time for the fixed forward burst read")
	assert_gt(float(payload.get("knockback", 0.0)), 400.0, "water_aqua_geyser must keep a strong launch-style knockback payload")
	GameState.reset_progress_for_tests()

func test_water_wave_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("water_wave"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "water_wave_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "water_wave_hit")
	GameState.reset_progress_for_tests()

func test_water_tsunami_cast_payload_includes_attack_hit_and_terminal_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("water_tsunami"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "water_tsunami_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "water_tsunami_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "water_tsunami_end")
	GameState.reset_progress_for_tests()

func test_water_ocean_collapse_cast_payload_includes_attack_hit_and_terminal_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("water_ocean_collapse"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "water_ocean_collapse_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "water_ocean_collapse_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "water_ocean_collapse_end")
	GameState.reset_progress_for_tests()

func test_lightning_bolt_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("lightning_bolt"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "lightning_bolt_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "lightning_bolt_hit")
	GameState.reset_progress_for_tests()

func test_ice_absolute_freeze_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("ice_absolute_freeze"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "ice_absolute_freeze_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "ice_absolute_freeze_hit")
	GameState.reset_progress_for_tests()

func test_ice_absolute_zero_cast_payload_includes_attack_hit_and_terminal_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("ice_absolute_zero"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "ice_absolute_zero_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "ice_absolute_zero_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "ice_absolute_zero_end")
	GameState.reset_progress_for_tests()

func test_fire_inferno_buster_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("fire_inferno_buster"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "fire_inferno_buster_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "fire_inferno_buster_hit")
	GameState.reset_progress_for_tests()

func test_fire_meteor_strike_cast_payload_includes_attack_hit_and_terminal_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("fire_meteor_strike"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "fire_meteor_strike_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "fire_meteor_strike_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "fire_meteor_strike_end")
	GameState.reset_progress_for_tests()

func test_fire_apocalypse_flame_cast_payload_includes_attack_hit_and_terminal_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("fire_apocalypse_flame"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "fire_apocalypse_flame_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "fire_apocalypse_flame_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "fire_apocalypse_flame_end")
	GameState.reset_progress_for_tests()

func test_earth_gaia_break_cast_payload_includes_attack_hit_and_terminal_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("earth_gaia_break"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "earth_gaia_break_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "earth_gaia_break_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "earth_gaia_break_end")
	GameState.reset_progress_for_tests()

func test_earth_continental_crush_cast_payload_includes_attack_hit_and_terminal_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("earth_continental_crush"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "earth_continental_crush_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "earth_continental_crush_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "earth_continental_crush_end")
	GameState.reset_progress_for_tests()

func test_earth_world_end_break_cast_payload_includes_attack_hit_and_terminal_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("earth_world_end_break"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "earth_world_end_break_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "earth_world_end_break_hit")
	assert_eq(str(payloads[0].get("terminal_effect_id", "")), "earth_world_end_break_end")
	GameState.reset_progress_for_tests()

func test_wind_storm_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("wind_storm"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "wind_storm_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "wind_storm_hit")
	GameState.reset_progress_for_tests()

func test_wind_heavenly_storm_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("wind_heavenly_storm"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "wind_heavenly_storm_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "wind_heavenly_storm_hit")
	GameState.reset_progress_for_tests()

func test_water_tidal_ring_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(0.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 120.0,
		"duration": 0.28,
		"team": "player",
		"damage": 44,
		"knockback": 360.0,
		"school": "water",
		"size": 120.0,
		"spell_id": "water_tidal_ring",
		"attack_effect_id": "water_tidal_ring_attack",
		"hit_effect_id": "water_tidal_ring_hit",
		"color": "#7fd9ff"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("water_tidal_ring_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "water_tidal_ring must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 19, "water_tidal_ring hit effect must use the authored splash sequence")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "water")

func test_water_aqua_geyser_projectile_spawns_hit_effect_and_keeps_launch_knockback_profile() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(96.0, -6.0),
		"velocity": Vector2.ZERO,
		"range": 104.0,
		"duration": 0.36,
		"team": "player",
		"damage": 40,
		"knockback": 420.0,
		"school": "water",
		"size": 104.0,
		"spell_id": "water_aqua_geyser",
		"attack_effect_id": "water_aqua_geyser_attack",
		"hit_effect_id": "water_aqua_geyser_hit",
		"terminal_effect_id": "water_aqua_geyser_end",
		"color": "#8aeaff"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("water_aqua_geyser_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "water_aqua_geyser must spawn a geyser hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 20, "water_aqua_geyser hit effect must use the authored splash sequence")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "water")
	assert_gt(float(target.received_hits[0].get("knockback", 0.0)), 400.0, "water_aqua_geyser must keep its strong launch-style knockback on actual hit")

func test_water_wave_projectile_spawns_hit_effect_and_applies_slow_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var player_target := Node2D.new()
	root.add_child(player_target)
	player_target.global_position = Vector2(420.0, 0.0)
	var enemy = ENEMY_SCRIPT.new()
	root.add_child(enemy)
	enemy.configure({"type": "dummy", "position": Vector2(32.0, 0.0)}, player_target)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup(_force_status_effect_rolls({
		"position": Vector2.ZERO,
		"velocity": Vector2(180.0, 0.0),
		"range": 360.0,
		"team": "player",
		"damage": 30,
		"knockback": 280.0,
		"school": "water",
		"size": 34.0,
		"pierce": 3,
		"spell_id": "water_wave",
		"attack_effect_id": "water_wave_attack",
		"hit_effect_id": "water_wave_hit",
		"utility_effects": [
			{"type": "slow", "value": 0.22, "duration": 1.1}
		],
		"color": "#8de8ff"
	}))
	root.add_child(projectile)
	await get_tree().process_frame
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy, false), "water_wave must connect through the projectile hit path without collapsing on first target")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "water_wave_hit", "hit")
	assert_true(hit_effect != null, "water_wave must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 6)
	assert_lt(enemy.health, hp_before, "water_wave must deal damage on hit")
	assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "water_wave must apply slow on hit")

func test_water_tsunami_projectile_spawns_hit_effect_and_applies_slow_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var player_target := Node2D.new()
	root.add_child(player_target)
	player_target.global_position = Vector2(560.0, 0.0)
	var enemy = ENEMY_SCRIPT.new()
	root.add_child(enemy)
	enemy.configure({"type": "brute", "position": Vector2(40.0, 0.0)}, player_target)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup(_force_status_effect_rolls({
		"position": Vector2.ZERO,
		"velocity": Vector2(220.0, 0.0),
		"range": 520.0,
		"team": "player",
		"damage": 40,
		"knockback": 340.0,
		"school": "water",
		"size": 56.0,
		"pierce": 5,
		"spell_id": "water_tsunami",
		"attack_effect_id": "water_tsunami_attack",
		"hit_effect_id": "water_tsunami_hit",
		"terminal_effect_id": "water_tsunami_end",
		"utility_effects": [
			{"type": "slow", "value": 0.3, "duration": 1.4}
		],
		"color": "#a2f2ff"
	}))
	root.add_child(projectile)
	await get_tree().process_frame
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy, false), "water_tsunami must connect through the projectile hit path without collapsing on first target")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "water_tsunami_hit", "hit")
	assert_true(hit_effect != null, "water_tsunami must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 6)
	assert_lt(enemy.health, hp_before, "water_tsunami must deal damage on hit")
	assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "water_tsunami must apply slow on hit")

func test_water_ocean_collapse_projectile_spawns_hit_effect_and_applies_slow_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var player_target := Node2D.new()
	root.add_child(player_target)
	player_target.global_position = Vector2(620.0, 0.0)
	var enemy = ENEMY_SCRIPT.new()
	root.add_child(enemy)
	enemy.configure({"type": "brute", "position": Vector2(40.0, 0.0)}, player_target)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup(_force_status_effect_rolls({
		"position": Vector2.ZERO,
		"velocity": Vector2(220.0, 0.0),
		"range": 560.0,
		"team": "player",
		"damage": 52,
		"knockback": 380.0,
		"school": "water",
		"size": 68.0,
		"pierce": 7,
		"spell_id": "water_ocean_collapse",
		"attack_effect_id": "water_ocean_collapse_attack",
		"hit_effect_id": "water_ocean_collapse_hit",
		"terminal_effect_id": "water_ocean_collapse_end",
		"utility_effects": [
			{"type": "slow", "value": 0.34, "duration": 1.6}
		],
		"color": "#b7f8ff"
	}))
	root.add_child(projectile)
	await get_tree().process_frame
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy, false), "water_ocean_collapse must connect through the projectile hit path without collapsing on first target")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "water_ocean_collapse_hit", "hit")
	assert_true(hit_effect != null, "water_ocean_collapse must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 6)
	assert_lt(enemy.health, hp_before, "water_ocean_collapse must deal damage on hit")
	assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "water_ocean_collapse must apply slow on hit")

func test_lightning_bolt_projectile_spawns_hit_effect_and_applies_shock_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	var payload := _force_status_effect_rolls({
		"spell_id": "lightning_bolt",
		"attack_effect_id": "lightning_bolt_attack",
		"hit_effect_id": "lightning_bolt_hit",
		"position": Vector2.ZERO,
		"velocity": Vector2(1040.0, 0.0),
		"range": 430.0,
		"team": "player",
		"damage": 26,
		"knockback": 280.0,
		"school": "lightning",
		"size": 14.0,
		"pierce": 3,
		"utility_effects": [
			{"type": "shock", "chance": 1.0, "value": 1.0, "duration": 1.25}
		]
	})
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	assert_true(projectile._hit_enemy(enemy, false), "lightning_bolt must connect through the projectile hit path without collapsing on first target")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "lightning_bolt_hit", "hit")
	assert_true(hit_effect != null, "lightning_bolt must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8)
	assert_gt(float(enemy.status_timers.get("shock", 0.0)), 0.0, "lightning_bolt must apply shock on hit when the status roll is forced")

func test_ice_absolute_freeze_projectile_spawns_hit_effect_and_applies_freeze_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "elite")
	var payload := _force_status_effect_rolls({
		"spell_id": "ice_absolute_freeze",
		"attack_effect_id": "ice_absolute_freeze_attack",
		"hit_effect_id": "ice_absolute_freeze_hit",
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 156.0,
		"duration": 0.34,
		"team": "player",
		"damage": 42,
		"knockback": 220.0,
		"school": "ice",
		"size": 156.0,
		"utility_effects": [
			{"type": "freeze", "chance": 1.0, "value": 1.0, "duration": 1.0}
		]
	})
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy), "ice_absolute_freeze must connect through the projectile hit path as a stationary burst")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "ice_absolute_freeze_hit", "hit")
	assert_true(hit_effect != null, "ice_absolute_freeze must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 4)
	assert_lt(enemy.health, hp_before, "ice_absolute_freeze must deal burst damage on hit")
	assert_gt(float(enemy.status_timers.get("freeze", 0.0)), 0.0, "ice_absolute_freeze must apply freeze on hit when the status roll is forced")

func test_ice_absolute_zero_projectile_spawns_hit_effect_and_applies_freeze_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "elite")
	var payload := _force_status_effect_rolls({
		"spell_id": "ice_absolute_zero",
		"attack_effect_id": "ice_absolute_zero_attack",
		"hit_effect_id": "ice_absolute_zero_hit",
		"terminal_effect_id": "ice_absolute_zero_end",
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 216.0,
		"duration": 0.56,
		"team": "player",
		"damage": 70,
		"knockback": 260.0,
		"school": "ice",
		"size": 216.0,
		"utility_effects": [
			{"type": "freeze", "chance": 1.0, "value": 1.0, "duration": 1.4}
		]
	})
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy), "ice_absolute_zero must connect through the projectile hit path as the final stationary freeze burst")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "ice_absolute_zero_hit", "hit")
	assert_true(hit_effect != null, "ice_absolute_zero must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 4)
	assert_lt(enemy.health, hp_before, "ice_absolute_zero must deal final burst damage on hit")
	assert_gt(float(enemy.status_timers.get("freeze", 0.0)), 0.0, "ice_absolute_zero must apply freeze on hit when the status roll is forced")

func test_fire_inferno_buster_projectile_spawns_hit_effect_and_applies_burn_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "elite")
	var payload := _force_status_effect_rolls({
		"spell_id": "fire_inferno_buster",
		"attack_effect_id": "fire_inferno_buster_attack",
		"hit_effect_id": "fire_inferno_buster_hit",
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 168.0,
		"duration": 0.32,
		"team": "player",
		"damage": 48,
		"knockback": 260.0,
		"school": "fire",
		"size": 168.0,
		"utility_effects": [
			{"type": "burn", "chance": 1.0, "value": 1.0, "duration": 1.2}
		]
	})
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy), "fire_inferno_buster must connect through the projectile hit path as a stationary burst")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "fire_inferno_buster_hit", "hit")
	assert_true(hit_effect != null, "fire_inferno_buster must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 4)
	assert_lt(enemy.health, hp_before, "fire_inferno_buster must deal burst damage on hit")
	assert_gt(float(enemy.status_timers.get("burn", 0.0)), 0.0, "fire_inferno_buster must apply burn on hit when the status roll is forced")

func test_fire_meteor_strike_projectile_spawns_hit_effect_and_applies_burn_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "elite")
	var payload := _force_status_effect_rolls({
		"spell_id": "fire_meteor_strike",
		"attack_effect_id": "fire_meteor_strike_attack",
		"hit_effect_id": "fire_meteor_strike_hit",
		"terminal_effect_id": "fire_meteor_strike_end",
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 184.0,
		"duration": 0.46,
		"team": "player",
		"damage": 54,
		"knockback": 300.0,
		"school": "fire",
		"size": 184.0,
		"utility_effects": [
			{"type": "burn", "chance": 1.0, "value": 1.0, "duration": 1.4}
		]
	})
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy), "fire_meteor_strike must connect through the projectile hit path as a stationary burst")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "fire_meteor_strike_hit", "hit")
	assert_true(hit_effect != null, "fire_meteor_strike must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 4)
	assert_lt(enemy.health, hp_before, "fire_meteor_strike must deal burst damage on hit")
	assert_gt(float(enemy.status_timers.get("burn", 0.0)), 0.0, "fire_meteor_strike must apply burn on hit when the status roll is forced")

func test_fire_apocalypse_flame_projectile_spawns_hit_effect_and_applies_burn_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "elite")
	var payload := _force_status_effect_rolls({
		"spell_id": "fire_apocalypse_flame",
		"attack_effect_id": "fire_apocalypse_flame_attack",
		"hit_effect_id": "fire_apocalypse_flame_hit",
		"terminal_effect_id": "fire_apocalypse_flame_end",
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 204.0,
		"duration": 0.52,
		"team": "player",
		"damage": 68,
		"knockback": 340.0,
		"school": "fire",
		"size": 204.0,
		"utility_effects": [
			{"type": "burn", "chance": 1.0, "value": 1.0, "duration": 1.6}
		]
	})
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy), "fire_apocalypse_flame must connect through the projectile hit path as an ultimate stationary burst")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "fire_apocalypse_flame_hit", "hit")
	assert_true(hit_effect != null, "fire_apocalypse_flame must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 4)
	assert_lt(enemy.health, hp_before, "fire_apocalypse_flame must deal burst damage on hit")
	assert_gt(float(enemy.status_timers.get("burn", 0.0)), 0.0, "fire_apocalypse_flame must apply burn on hit when the status roll is forced")

func test_fire_solar_cataclysm_projectile_spawns_hit_effect_and_applies_burn_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "elite")
	var payload := _force_status_effect_rolls({
		"spell_id": "fire_solar_cataclysm",
		"attack_effect_id": "fire_solar_cataclysm_attack",
		"hit_effect_id": "fire_solar_cataclysm_hit",
		"terminal_effect_id": "fire_solar_cataclysm_end",
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 218.0,
		"duration": 0.56,
		"team": "player",
		"damage": 74,
		"knockback": 380.0,
		"school": "fire",
		"size": 218.0,
		"utility_effects": [
			{"type": "burn", "chance": 1.0, "value": 1.0, "duration": 1.8}
		]
	})
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy), "fire_solar_cataclysm must connect through the projectile hit path as a final stationary burst")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "fire_solar_cataclysm_hit", "hit")
	assert_true(hit_effect != null, "fire_solar_cataclysm must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 4)
	assert_lt(enemy.health, hp_before, "fire_solar_cataclysm must deal burst damage on hit")
	assert_gt(float(enemy.status_timers.get("burn", 0.0)), 0.0, "fire_solar_cataclysm must apply burn on hit when the status roll is forced")

func test_earth_gaia_break_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "elite")
	var payload := {
		"spell_id": "earth_gaia_break",
		"attack_effect_id": "earth_gaia_break_attack",
		"hit_effect_id": "earth_gaia_break_hit",
		"terminal_effect_id": "earth_gaia_break_end",
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 176.0,
		"duration": 0.40,
		"team": "player",
		"damage": 52,
		"knockback": 420.0,
		"school": "earth",
		"size": 176.0
	}
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy), "earth_gaia_break must connect through the projectile hit path as a stationary collapse burst")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "earth_gaia_break_hit", "hit")
	assert_true(hit_effect != null, "earth_gaia_break must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 6)
	assert_lt(enemy.health, hp_before, "earth_gaia_break must deal burst damage on hit")

func test_earth_continental_crush_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "elite")
	var payload := {
		"spell_id": "earth_continental_crush",
		"attack_effect_id": "earth_continental_crush_attack",
		"hit_effect_id": "earth_continental_crush_hit",
		"terminal_effect_id": "earth_continental_crush_end",
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 198.0,
		"duration": 0.48,
		"team": "player",
		"damage": 64,
		"knockback": 460.0,
		"school": "earth",
		"size": 198.0
	}
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy), "earth_continental_crush must connect through the projectile hit path as an ultimate stationary collapse burst")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "earth_continental_crush_hit", "hit")
	assert_true(hit_effect != null, "earth_continental_crush must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 6)
	assert_lt(enemy.health, hp_before, "earth_continental_crush must deal burst damage on hit")

func test_earth_world_end_break_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "elite")
	var payload := {
		"spell_id": "earth_world_end_break",
		"attack_effect_id": "earth_world_end_break_attack",
		"hit_effect_id": "earth_world_end_break_hit",
		"terminal_effect_id": "earth_world_end_break_end",
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 214.0,
		"duration": 0.54,
		"team": "player",
		"damage": 72,
		"knockback": 500.0,
		"school": "earth",
		"size": 214.0
	}
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy), "earth_world_end_break must connect through the projectile hit path as the final stationary collapse burst")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "earth_world_end_break_hit", "hit")
	assert_true(hit_effect != null, "earth_world_end_break must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 6)
	assert_lt(enemy.health, hp_before, "earth_world_end_break must deal final burst damage on hit")

func test_wind_storm_projectile_spawns_hit_effect_and_applies_slow_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	var payload := _force_status_effect_rolls({
		"spell_id": "wind_storm",
		"attack_effect_id": "wind_storm_attack",
		"hit_effect_id": "wind_storm_hit",
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 148.0,
		"duration": 0.36,
		"team": "player",
		"damage": 40,
		"knockback": 240.0,
		"school": "wind",
		"size": 148.0,
		"utility_effects": [
			{"type": "slow", "chance": 1.0, "value": 0.28, "duration": 1.2}
		]
	})
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy), "wind_storm must connect through the projectile hit path as a stationary burst")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "wind_storm_hit", "hit")
	assert_true(hit_effect != null, "wind_storm must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8)
	assert_lt(enemy.health, hp_before, "wind_storm must deal burst damage on hit")
	assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "wind_storm must apply slow on hit when the status roll is forced")

func test_wind_heavenly_storm_projectile_spawns_hit_effect_and_applies_slow_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	var payload := _force_status_effect_rolls({
		"spell_id": "wind_heavenly_storm",
		"attack_effect_id": "wind_heavenly_storm_attack",
		"hit_effect_id": "wind_heavenly_storm_hit",
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 188.0,
		"duration": 0.42,
		"team": "player",
		"damage": 60,
		"knockback": 300.0,
		"school": "wind",
		"size": 188.0,
		"utility_effects": [
			{"type": "slow", "chance": 1.0, "value": 0.36, "duration": 1.6}
		]
	})
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	var hp_before: int = enemy.health
	assert_true(projectile._hit_enemy(enemy), "wind_heavenly_storm must connect through the projectile hit path as an ultimate stationary burst")
	await get_tree().process_frame
	var hit_effect := _find_effect_sprite(root, "wind_heavenly_storm_hit", "hit")
	assert_true(hit_effect != null, "wind_heavenly_storm must spawn a hit effect sibling when it lands")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8)
	assert_lt(enemy.health, hp_before, "wind_heavenly_storm must deal burst damage on hit")
	assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "wind_heavenly_storm must apply slow on hit when the status roll is forced")

func test_water_aqua_bullet_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("water_aqua_bullet"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "water_aqua_bullet_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "water_aqua_bullet_hit")
	GameState.reset_progress_for_tests()

func test_water_aqua_bullet_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(120.0, 0.0),
		"range": 360.0,
		"team": "player",
		"damage": 16,
		"knockback": 160.0,
		"school": "water",
		"size": 10.0,
		"spell_id": "water_aqua_bullet",
		"attack_effect_id": "water_aqua_bullet_attack",
		"hit_effect_id": "water_aqua_bullet_hit",
		"color": "#9be9ff"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("water_aqua_bullet_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "water_aqua_bullet must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 8, "water attack effect must use the authored startup sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "water attack effect frame must be a 64px cropped tile")
	assert_gt(attack_effect.scale.x, 0.0, "water attack effect should keep native orientation on rightward cast")

func test_water_aqua_bullet_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(18.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 360.0,
		"team": "player",
		"damage": 16,
		"knockback": 160.0,
		"school": "water",
		"size": 10.0,
		"spell_id": "water_aqua_bullet",
		"attack_effect_id": "water_aqua_bullet_attack",
		"hit_effect_id": "water_aqua_bullet_hit",
		"color": "#9be9ff"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("water_aqua_bullet_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "water_aqua_bullet must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 15, "water hit effect must use the authored impact sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "water hit effect frame must be a 64px cropped tile")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "water")

func test_earth_tremor_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("earth_tremor"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "earth_tremor_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "earth_tremor_hit")
	GameState.reset_progress_for_tests()

func test_earth_stone_spire_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("earth_stone_spire"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "earth_stone_spire_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "earth_stone_spire_hit")
	GameState.reset_progress_for_tests()


func test_earth_stone_spire_deploy_payload_syncs_runtime_contract_and_cone_burst_read() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	GameState.skill_level_data["earth_stone_spire"] = 30
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	var skill_id := "earth_stone_spire"
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	var runtime := GameState.apply_deploy_buff_modifiers(
		GameState.get_data_driven_skill_runtime(skill_id, skill_data)
	)
	assert_true(manager.attempt_cast(skill_id))
	assert_eq(payloads.size(), 1)
	var payload: Dictionary = payloads[0]
	assert_eq(str(payload.get("spell_id", "")), skill_id)
	assert_eq(str(payload.get("school", "")), str(runtime.get("school", "")))
	assert_eq(int(payload.get("damage", 0)), int(runtime.get("damage", 0)))
	assert_eq(float(payload.get("duration", 0.0)), float(runtime.get("duration", 0.0)))
	assert_eq(float(payload.get("size", 0.0)), float(runtime.get("size", 0.0)))
	assert_eq(int(payload.get("target_count", 0)), int(runtime.get("target_count", 0)))
	assert_eq(str(payload.get("attack_effect_id", "")), "earth_stone_spire_attack")
	assert_eq(str(payload.get("hit_effect_id", "")), "earth_stone_spire_hit")
	assert_almost_eq(
		manager.get_cooldown(skill_id),
		float(runtime.get("cooldown", 0.0)),
		0.0001,
		"earth_stone_spire cast must still sync the deploy cooldown in the spell manager"
	)
	var utility_effects: Array = payload.get("utility_effects", [])
	assert_true(utility_effects.is_empty(), "earth_stone_spire payload must stay as a pure cone burst without utility riders")
	var projectile := _spawn_projectile_for_spell_coverage(root, _force_status_effect_rolls(payload, 0.0))
	await _advance_frames(1)
	var attack_effect := root.get_node_or_null("earth_stone_spire_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "earth_stone_spire must spawn its startup effect when the deploy enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 7, "earth_stone_spire startup effect must use the authored rising-spire strip")
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	target.global_position = Vector2(64.0, -4.0)
	projectile._hit_enemy(target)
	await _advance_frames(1)
	var hit_effect := root.get_node_or_null("earth_stone_spire_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "earth_stone_spire must spawn a hit effect sibling on impact")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 6, "earth_stone_spire hit effect must use the authored impact strip")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "earth")
	GameState.reset_progress_for_tests()


func test_earth_tremor_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var cast_origin := Vector2.ZERO
	projectile.setup({
		"position": cast_origin,
		"velocity": Vector2(120.0, 0.0),
		"range": 320.0,
		"team": "player",
		"damage": 18,
		"knockback": 180.0,
		"school": "earth",
		"size": 14.0,
		"spell_id": "earth_tremor",
		"attack_effect_id": "earth_tremor_attack",
		"hit_effect_id": "earth_tremor_hit",
		"color": "#d9c19b"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("earth_tremor_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "earth_tremor must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 12, "earth attack effect must use the authored quake startup sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "earth attack effect frame must be a 64px cropped tile")
	assert_gt(attack_effect.scale.x, 0.0, "earth attack effect should keep native orientation on rightward cast")
	assert_almost_eq(
		attack_effect.global_position.x,
		cast_origin.x,
		0.001,
		"earth_tremor startup effect must stay centered on the cast origin for quake read"
	)

func test_earth_tremor_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(18.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 320.0,
		"team": "player",
		"damage": 18,
		"knockback": 180.0,
		"school": "earth",
		"size": 14.0,
		"spell_id": "earth_tremor",
		"attack_effect_id": "earth_tremor_attack",
		"hit_effect_id": "earth_tremor_hit",
		"color": "#d9c19b"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("earth_tremor_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "earth_tremor must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 7, "earth hit effect must use the authored impact strip sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "earth hit effect frame must be a 64px cropped tile")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "earth")

func test_ice_ice_wall_projectile_uses_dedicated_icy_wall_visual_family() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(12.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 180.0,
		"duration": 2.0,
		"team": "player",
		"damage": 20,
		"knockback": 0.0,
		"school": "ice",
		"size": 180.0,
		"spell_id": "ice_ice_wall",
		"attack_effect_id": "ice_ice_wall_attack",
		"hit_effect_id": "ice_ice_wall_hit",
		"terminal_effect_id": "ice_ice_wall_end",
		"color": "#dff8ff"
	})
	var wall_sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(wall_sprite != null, "ice_ice_wall must build a sampled wall visual instead of the generic polygon fallback")
	assert_eq(wall_sprite.sprite_frames.get_frame_count("fly"), 12, "ice_ice_wall main wall loop must load its authored icy wall strip")
	assert_gt(wall_sprite.scale.x, 1.65, "ice_ice_wall loop must stay wide enough to read as a wall instead of a narrow ice burst")
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("ice_ice_wall_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "ice_ice_wall must spawn a startup wall effect when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 12)
	assert_gt(attack_effect.scale.x, 1.4, "ice_ice_wall startup must stay broader than a generic burst so the barrier read lands immediately")
	assert_almost_eq(
		attack_effect.global_position.x,
		projectile.global_position.x,
		0.001,
		"ice_ice_wall startup effect must stay centered on the wall origin"
	)
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target, false)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("ice_ice_wall_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "ice_ice_wall must spawn a frosted wall impact effect on contact")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 7)
	projectile._finish_projectile()
	await get_tree().process_frame
	assert_true(projectile.terminal_effect_played, "ice_ice_wall must swap into its icy collapse terminal effect when it ends")
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "ice_ice_wall must expose a terminal wall-collapse visual")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 7)
	assert_gt(terminal_sprite.scale.x, 1.45, "ice_ice_wall collapse must stay wide enough to read as a wall break instead of a point flash")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "ice")


func test_earth_stone_rampart_projectile_uses_dedicated_stone_wall_visual_family() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(16.0, -8.0),
		"velocity": Vector2.ZERO,
		"range": 168.0,
		"duration": 2.0,
		"team": "player",
		"damage": 14,
		"knockback": 0.0,
		"school": "earth",
		"size": 168.0,
		"spell_id": "earth_stone_rampart",
		"attack_effect_id": "earth_stone_rampart_attack",
		"hit_effect_id": "earth_stone_rampart_hit",
		"terminal_effect_id": "earth_stone_rampart_end",
		"color": "#e5c99c"
	})
	var wall_sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(wall_sprite != null, "earth_stone_rampart must build a sampled wall visual instead of the generic polygon fallback")
	assert_eq(wall_sprite.sprite_frames.get_frame_count("fly"), 9, "earth_stone_rampart main wall loop must load its authored stone wall strip")
	assert_gt(wall_sprite.scale.x, 1.70, "earth_stone_rampart loop must stay broad enough to read as a blocking stone wall")
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("earth_stone_rampart_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "earth_stone_rampart must spawn a startup wall effect when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 9)
	assert_gt(attack_effect.scale.x, 1.20, "earth_stone_rampart startup must stay wider than a point bump so the wall read lands immediately")
	assert_almost_eq(
		attack_effect.global_position.x,
		projectile.global_position.x,
		0.001,
		"earth_stone_rampart startup effect must stay centered on the wall origin"
	)
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target, false)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("earth_stone_rampart_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "earth_stone_rampart must spawn a stone impact effect on contact")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 9)
	projectile._finish_projectile()
	await get_tree().process_frame
	assert_true(projectile.terminal_effect_played, "earth_stone_rampart must swap into its stone collapse terminal effect when it ends")
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "earth_stone_rampart must expose a terminal wall-collapse visual")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 9)
	assert_gt(terminal_sprite.scale.x, 1.35, "earth_stone_rampart collapse must stay wide enough to read as a wall break instead of a point flash")

func test_dark_void_bolt_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("dark_void_bolt"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "dark_void_bolt_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "dark_void_bolt_hit")
	GameState.reset_progress_for_tests()

func test_dark_void_bolt_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 400.0,
		"team": "player",
		"damage": 18,
		"knockback": 170.0,
		"school": "dark",
		"size": 11.0,
		"spell_id": "dark_void_bolt",
		"attack_effect_id": "dark_void_bolt_attack",
		"hit_effect_id": "dark_void_bolt_hit",
		"color": "#7a63ff"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("dark_void_bolt_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "dark_void_bolt must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 8, "dark attack effect must use cropped single-effect sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "dark attack effect frame must be a 64px cropped tile")
	assert_lt(attack_effect.scale.x, 0.0, "dark attack effect must mirror with leftward cast direction")

func test_dark_void_bolt_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(18.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 400.0,
		"team": "player",
		"damage": 18,
		"knockback": 170.0,
		"school": "dark",
		"size": 11.0,
		"spell_id": "dark_void_bolt",
		"attack_effect_id": "dark_void_bolt_attack",
		"hit_effect_id": "dark_void_bolt_hit",
		"color": "#7a63ff"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("dark_void_bolt_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "dark_void_bolt must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8, "dark hit effect must use cropped single-effect sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "dark hit effect frame must be a 64px cropped tile")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "dark")

func test_arcane_force_pulse_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 460.0,
		"team": "player",
		"damage": 17,
		"knockback": 240.0,
		"school": "arcane",
		"size": 12.0,
		"spell_id": "arcane_force_pulse",
		"attack_effect_id": "arcane_force_pulse_attack",
		"hit_effect_id": "arcane_force_pulse_hit",
		"color": "#c084fc"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("arcane_force_pulse_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "arcane_force_pulse must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 6, "arcane_force_pulse attack effect must use its dedicated 6-frame sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "arcane_force_pulse attack effect frame must be a 64px cropped tile")
	assert_lt(attack_effect.scale.x, 0.0, "arcane_force_pulse attack effect must mirror with leftward cast direction")

func test_arcane_force_pulse_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(18.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 460.0,
		"team": "player",
		"damage": 17,
		"knockback": 240.0,
		"school": "arcane",
		"size": 12.0,
		"spell_id": "arcane_force_pulse",
		"attack_effect_id": "arcane_force_pulse_attack",
		"hit_effect_id": "arcane_force_pulse_hit",
		"color": "#c084fc"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("arcane_force_pulse_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "arcane_force_pulse must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8, "arcane_force_pulse hit effect must use its dedicated 8-frame sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "arcane_force_pulse hit effect frame must be a 64px cropped tile")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "arcane")

func test_fire_inferno_breath_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 240.0,
		"team": "player",
		"damage": 50,
		"knockback": 180.0,
		"school": "fire",
		"size": 128.0,
		"duration": 0.42,
		"spell_id": "fire_inferno_breath",
		"attack_effect_id": "fire_inferno_breath_attack",
		"hit_effect_id": "fire_inferno_breath_hit",
		"color": "#ffb468"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("fire_inferno_breath_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "fire_inferno_breath must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 8, "fire_inferno_breath attack effect must use its dedicated 8-frame startup strip")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "fire_inferno_breath attack effect frame must be a 64px cropped tile")
	assert_lt(attack_effect.scale.x, 0.0, "fire_inferno_breath attack effect must mirror with leftward cast direction")

func test_fire_inferno_breath_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(18.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 240.0,
		"team": "player",
		"damage": 50,
		"knockback": 180.0,
		"school": "fire",
		"size": 128.0,
		"duration": 0.42,
		"spell_id": "fire_inferno_breath",
		"attack_effect_id": "fire_inferno_breath_attack",
		"hit_effect_id": "fire_inferno_breath_hit",
		"color": "#ffb468"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	target.global_position = Vector2(54.0, -10.0)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("fire_inferno_breath_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "fire_inferno_breath must spawn a hit effect sibling on enemy impact")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 5, "fire_inferno_breath hit effect must use its dedicated 5-frame impact strip")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "fire_inferno_breath hit effect frame must be a 64px cropped tile")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "fire")

func test_wind_gale_cutter_cast_payload_includes_attack_and_hit_effect_ids() -> void:
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var player = autofree(PLAYER_SCRIPT.new())
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(payload: Dictionary) -> void: payloads.append(payload))
	assert_true(manager.attempt_cast("wind_gale_cutter"))
	assert_eq(payloads.size(), 1)
	assert_eq(str(payloads[0].get("attack_effect_id", "")), "wind_gale_cutter_attack")
	assert_eq(str(payloads[0].get("hit_effect_id", "")), "wind_gale_cutter_hit")
	GameState.reset_progress_for_tests()

func test_wind_gale_cutter_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 480.0,
		"team": "player",
		"damage": 14,
		"knockback": 140.0,
		"school": "wind",
		"size": 10.0,
		"spell_id": "wind_gale_cutter",
		"attack_effect_id": "wind_gale_cutter_attack",
		"hit_effect_id": "wind_gale_cutter_hit",
		"color": "#b8ffe5"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("wind_gale_cutter_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "wind_gale_cutter must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 2, "wind attack effect must use the authored cutter sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "wind attack effect frame must be a 64px cropped tile")
	assert_lt(attack_effect.scale.x, 0.0, "wind attack effect must mirror with leftward cast direction")

func test_wind_gale_cutter_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(18.0, -10.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 480.0,
		"team": "player",
		"damage": 14,
		"knockback": 140.0,
		"school": "wind",
		"size": 10.0,
		"spell_id": "wind_gale_cutter",
		"attack_effect_id": "wind_gale_cutter_attack",
		"hit_effect_id": "wind_gale_cutter_hit",
		"color": "#b8ffe5"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("wind_gale_cutter_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "wind_gale_cutter must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 2, "wind hit effect must use the authored puff sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "wind hit effect frame must be a 64px cropped tile")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "wind")

func test_volt_spear_projectile_spawns_attack_effect_when_added_to_scene() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 440.0,
		"team": "player",
		"damage": 22,
		"knockback": 320.0,
		"school": "lightning",
		"size": 12.0,
		"spell_id": "volt_spear",
		"attack_effect_id": "volt_spear_attack",
		"hit_effect_id": "volt_spear_hit",
		"color": "#f7ef6a"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var attack_effect := root.get_node_or_null("volt_spear_attack_sprite") as AnimatedSprite2D
	assert_true(attack_effect != null, "volt_spear must spawn an attack effect sibling when it enters the scene")
	assert_eq(str(attack_effect.get_meta("effect_stage", "")), "attack")
	assert_eq(attack_effect.sprite_frames.get_frame_count("fly"), 8, "attack effect must use cropped single-effect sequence")
	assert_eq(attack_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "attack effect frame must be a 64px cropped tile, not the full preview sheet")
	assert_lt(attack_effect.scale.x, 0.0, "attack effect must mirror with leftward cast direction")

func test_volt_spear_projectile_spawns_hit_effect_on_enemy_hit() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2(24.0, -12.0),
		"velocity": Vector2(120.0, 0.0),
		"range": 440.0,
		"team": "player",
		"damage": 22,
		"knockback": 320.0,
		"school": "lightning",
		"size": 12.0,
		"spell_id": "volt_spear",
		"attack_effect_id": "volt_spear_attack",
		"hit_effect_id": "volt_spear_hit",
		"color": "#f7ef6a"
	})
	root.add_child(projectile)
	await get_tree().process_frame
	var target := DummyProjectileTarget.new()
	root.add_child(target)
	projectile._hit_enemy(target)
	await get_tree().process_frame
	var hit_effect := root.get_node_or_null("volt_spear_hit_sprite") as AnimatedSprite2D
	assert_true(hit_effect != null, "volt_spear must spawn a hit effect sibling when it lands")
	assert_eq(str(hit_effect.get_meta("effect_stage", "")), "hit")
	assert_eq(hit_effect.sprite_frames.get_frame_count("fly"), 8, "hit effect must use cropped single-effect sequence")
	assert_eq(hit_effect.sprite_frames.get_frame_texture("fly", 0).get_width(), 64, "hit effect frame must be a 64px cropped tile, not the full preview sheet")
	assert_eq(target.received_hits.size(), 1)
	assert_eq(str(target.received_hits[0].get("school", "")), "lightning")

func test_all_connected_split_effect_visuals_use_cropped_single_tiles() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(120.0, 0.0),
		"range": 360.0,
		"team": "player",
		"damage": 10,
		"knockback": 100.0,
		"school": "arcane",
		"size": 10.0,
		"spell_id": "volt_spear"
	})
	for split_case in SPLIT_EFFECT_CASES:
		_assert_split_effect_visual_uses_cropped_single_tile(
			projectile,
			str(split_case.get("attack", "")),
			int(split_case.get("attack_frames", 8))
		)
		_assert_split_effect_visual_uses_cropped_single_tile(
			projectile,
			str(split_case.get("hit", "")),
			int(split_case.get("hit_frames", 8))
		)

func test_split_effect_payload_registry_stays_in_sync_with_world_effect_registry() -> void:
	var manager = SPELL_MANAGER_SCRIPT.new()
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var expected_effect_ids: Array[String] = []
	for skill_id in manager.get_split_effect_skill_ids():
		var payload := manager.get_split_effect_payload(skill_id)
		assert_false(payload.is_empty(), "%s must keep a split-effect payload entry" % skill_id)
		var attack_id := str(payload.get("attack", ""))
		var hit_id := str(payload.get("hit", ""))
		assert_false(attack_id.is_empty(), "%s must keep an attack effect id" % skill_id)
		assert_false(hit_id.is_empty(), "%s must keep a hit effect id" % skill_id)
		assert_true(projectile.has_world_effect_spec(attack_id), "%s attack effect must have a matching world effect spec" % skill_id)
		assert_true(projectile.has_world_effect_spec(hit_id), "%s hit effect must have a matching world effect spec" % skill_id)
		expected_effect_ids.append(attack_id)
		expected_effect_ids.append(hit_id)
	expected_effect_ids.sort()
	assert_eq(projectile.get_world_effect_ids(), expected_effect_ids, "world effect registry must stay aligned with split-effect payload registry")

func test_single_projectile_active_hits_all_core_enemy_archetypes() -> void:
	for archetype in ENEMY_ARCHETYPE_CASES:
		var root := Node2D.new()
		add_child_autofree(root)
		var enemy_type := str(archetype.get("type", ""))
		var enemy := _spawn_enemy_for_spell_coverage(root, enemy_type)
		await get_tree().process_frame
		var hp_before: int = enemy.health
		var session_hits_before: int = GameState.session_hit_count
		var expected_damage: int = int(enemy.debug_calculate_incoming_damage(16, "fire").get("final_damage", 0))
		var projectile := _spawn_projectile_for_spell_coverage(root, {
			"position": Vector2(18.0, -10.0),
			"velocity": Vector2(120.0, 0.0),
			"range": 320.0,
			"team": "player",
			"damage": 16,
			"knockback": 180.0,
			"school": "fire",
			"size": 10.0,
			"spell_id": "fire_bolt",
			"attack_effect_id": "fire_bolt_attack",
			"hit_effect_id": "fire_bolt_hit",
			"color": "#ff9f45"
		})
		projectile._hit_enemy(enemy)
		await get_tree().process_frame
		var hit_effect := _find_effect_sprite(root, "fire_bolt_hit", "hit")
		assert_true(hit_effect != null, "fire_bolt hit effect must appear for %s archetype" % enemy_type)
		assert_eq(enemy.health, hp_before - expected_damage, "fire_bolt must damage %s archetype through projectile hit path" % enemy_type)
		assert_eq(GameState.session_hit_count, session_hits_before + 1, "fire_bolt must record one enemy hit for %s archetype" % enemy_type)
		assert_gt(enemy.hit_flash_timer, 0.0, "fire_bolt hit must trigger hit flash on %s archetype" % enemy_type)

func test_piercing_projectile_active_hits_all_core_enemy_archetypes() -> void:
	for archetype in ENEMY_ARCHETYPE_CASES:
		var root := Node2D.new()
		add_child_autofree(root)
		var enemy_type := str(archetype.get("type", ""))
		var enemy := _spawn_enemy_for_spell_coverage(root, enemy_type)
		await get_tree().process_frame
		var hp_before: int = enemy.health
		var expected_damage: int = int(enemy.debug_calculate_incoming_damage(14, "wind").get("final_damage", 0))
		var projectile := _spawn_projectile_for_spell_coverage(root, {
			"position": Vector2(18.0, -10.0),
			"velocity": Vector2(120.0, 0.0),
			"range": 480.0,
			"team": "player",
			"damage": 14,
			"knockback": 140.0,
			"school": "wind",
			"size": 10.0,
			"spell_id": "wind_gale_cutter",
			"attack_effect_id": "wind_gale_cutter_attack",
			"hit_effect_id": "wind_gale_cutter_hit",
			"pierce": 3,
			"color": "#b8ffe5"
		})
		projectile._hit_enemy(enemy)
		await get_tree().process_frame
		var hit_effect := _find_effect_sprite(root, "wind_gale_cutter_hit", "hit")
		assert_true(hit_effect != null, "wind_gale_cutter hit effect must appear for %s archetype" % enemy_type)
		assert_eq(enemy.health, hp_before - expected_damage, "wind_gale_cutter must damage %s archetype through projectile hit path" % enemy_type)
		assert_gt(enemy.hit_flash_timer, 0.0, "wind_gale_cutter hit must trigger hit flash on %s archetype" % enemy_type)
		assert_eq(projectile.pierce, 2, "wind_gale_cutter must preserve remaining pierce after hitting %s archetype" % enemy_type)

func test_frost_nova_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 76.0,
		"duration": 0.2,
		"team": "player",
		"damage": 14,
		"knockback": 120.0,
		"school": "ice",
		"size": 72.0,
		"spell_id": "frost_nova",
		"color": "#8cecff"
	})
	assert_gt(projectile.get_child_count(), 0, "frost_nova projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "frost_nova must use AnimatedSprite2D burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 8, "frost_nova effect must load all sampled frames")
	assert_gt(sprite.scale.x, 0.0, "frost_nova burst must keep native non-flipped orientation")

func test_ice_frost_needle_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-180.0, 0.0),
		"range": 460.0,
		"duration": 1.6,
		"team": "player",
		"damage": 18,
		"knockback": 180.0,
		"school": "ice",
		"size": 12.0,
		"spell_id": "ice_frost_needle",
		"attack_effect_id": "ice_frost_needle_attack",
		"hit_effect_id": "ice_frost_needle_hit",
		"color": "#b9f4ff"
	})
	assert_gt(projectile.get_child_count(), 0, "ice_frost_needle projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "ice_frost_needle must use AnimatedSprite2D projectile visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 10, "ice_frost_needle effect must load its full loop sequence")
	assert_lt(sprite.scale.x, 0.0, "ice_frost_needle projectile must flip when traveling left")

func test_holy_cure_ray_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-180.0, 0.0),
		"range": 420.0,
		"team": "player",
		"damage": 20,
		"knockback": 180.0,
		"school": "holy",
		"size": 16.0,
		"spell_id": "holy_cure_ray",
		"attack_effect_id": "holy_cure_ray_attack",
		"hit_effect_id": "holy_cure_ray_hit",
		"color": "#fff2b0"
	})
	assert_gt(projectile.get_child_count(), 0, "holy_cure_ray projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "holy_cure_ray must use AnimatedSprite2D ray visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 16, "holy_cure_ray effect must load its full ray sequence")
	assert_lt(sprite.scale.x, 0.0, "holy_cure_ray projectile must flip when traveling left")

func test_water_tidal_ring_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 120.0,
		"duration": 0.28,
		"team": "player",
		"damage": 44,
		"knockback": 360.0,
		"school": "water",
		"size": 120.0,
		"spell_id": "water_tidal_ring",
		"attack_effect_id": "water_tidal_ring_attack",
		"hit_effect_id": "water_tidal_ring_hit",
		"color": "#7fd9ff"
	})
	assert_gt(projectile.get_child_count(), 0, "water_tidal_ring projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "water_tidal_ring must use AnimatedSprite2D burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 20, "water_tidal_ring effect must load its full ring sequence")
	assert_gt(sprite.scale.x, 0.0, "water_tidal_ring burst must keep native non-flipped orientation")

func test_water_aqua_geyser_projectile_uses_dedicated_geyser_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("water_aqua_geyser_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("water_aqua_geyser", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("water_aqua_geyser_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("water_aqua_geyser_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/water_aqua_geyser_attack/",
		"water_aqua_geyser must read startup frames from a dedicated geyser family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/water_aqua_geyser/",
		"water_aqua_geyser must read burst frames from a dedicated geyser family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/water_aqua_geyser_hit/",
		"water_aqua_geyser must read hit frames from a dedicated geyser family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/water_aqua_geyser_end/",
		"water_aqua_geyser must read terminal frames from a dedicated geyser family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 104.0,
		"duration": 0.36,
		"team": "player",
		"damage": 40,
		"knockback": 420.0,
		"school": "water",
		"size": 104.0,
		"spell_id": "water_aqua_geyser",
		"attack_effect_id": "water_aqua_geyser_attack",
		"hit_effect_id": "water_aqua_geyser_hit",
		"terminal_effect_id": "water_aqua_geyser_end",
		"color": "#8aeaff"
	})
	assert_gt(projectile.get_child_count(), 0, "water_aqua_geyser projectile must build a burst visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "water_aqua_geyser must use AnimatedSprite2D geyser visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 25, "water_aqua_geyser dedicated geyser burst must load all loop frames")
	assert_gt(sprite.scale.x, 0.0, "water_aqua_geyser burst must keep native non-flipped orientation")

func test_holy_judgment_halo_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 160.0,
		"duration": 0.44,
		"team": "player",
		"damage": 78,
		"knockback": 360.0,
		"school": "holy",
		"size": 150.0,
		"spell_id": "holy_judgment_halo",
		"attack_effect_id": "holy_judgment_halo_attack",
		"hit_effect_id": "holy_judgment_halo_hit",
		"terminal_effect_id": "holy_judgment_halo_end",
		"color": "#fff8d2"
	})
	assert_gt(projectile.get_child_count(), 0, "holy_judgment_halo projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "holy_judgment_halo must use AnimatedSprite2D judgment visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 13, "holy_judgment_halo effect must load its full sword-of-justice sequence")
	assert_gt(sprite.scale.x, 0.0, "holy_judgment_halo burst must keep native non-flipped orientation")

func test_water_aqua_bullet_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 360.0,
		"team": "player",
		"damage": 16,
		"knockback": 160.0,
		"school": "water",
		"size": 10.0,
		"spell_id": "water_aqua_bullet",
		"attack_effect_id": "water_aqua_bullet_attack",
		"hit_effect_id": "water_aqua_bullet_hit",
		"color": "#9be9ff"
	})
	assert_gt(projectile.get_child_count(), 0, "water_aqua_bullet projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "water_aqua_bullet must use AnimatedSprite2D projectile visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 18, "water_aqua_bullet effect must load its full loop sequence")
	assert_lt(sprite.scale.x, 0.0, "water_aqua_bullet projectile must flip when traveling left")

func test_water_wave_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-180.0, 0.0),
		"range": 360.0,
		"team": "player",
		"damage": 30,
		"knockback": 280.0,
		"school": "water",
		"size": 34.0,
		"pierce": 3,
		"spell_id": "water_wave",
		"attack_effect_id": "water_wave_attack",
		"hit_effect_id": "water_wave_hit",
		"color": "#8de8ff"
	})
	assert_gt(projectile.get_child_count(), 0, "water_wave projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "water_wave must use AnimatedSprite2D wave visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 8, "water_wave effect must load its full line-wave sequence")
	assert_lt(sprite.scale.x, 0.0, "water_wave projectile must flip when traveling left")
	assert_gt(absf(sprite.scale.x), 1.2, "water_wave visual must read wider than the base water spear placeholder")

func test_water_tsunami_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-220.0, 0.0),
		"range": 520.0,
		"team": "player",
		"damage": 40,
		"knockback": 340.0,
		"school": "water",
		"size": 56.0,
		"pierce": 5,
		"spell_id": "water_tsunami",
		"attack_effect_id": "water_tsunami_attack",
		"hit_effect_id": "water_tsunami_hit",
		"terminal_effect_id": "water_tsunami_end",
		"color": "#a2f2ff"
	})
	assert_gt(projectile.get_child_count(), 0, "water_tsunami projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "water_tsunami must use AnimatedSprite2D tidal wave visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 8, "water_tsunami effect must load its full dedicated tidal sequence")
	assert_lt(sprite.scale.x, 0.0, "water_tsunami projectile must flip when traveling left")
	assert_gt(absf(sprite.scale.x), 1.6, "water_tsunami visual must read wider than water_wave")

func test_water_ocean_collapse_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-220.0, 0.0),
		"range": 560.0,
		"team": "player",
		"damage": 52,
		"knockback": 380.0,
		"school": "water",
		"size": 68.0,
		"pierce": 7,
		"spell_id": "water_ocean_collapse",
		"attack_effect_id": "water_ocean_collapse_attack",
		"hit_effect_id": "water_ocean_collapse_hit",
		"terminal_effect_id": "water_ocean_collapse_end",
		"color": "#b7f8ff"
	})
	assert_gt(projectile.get_child_count(), 0, "water_ocean_collapse projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "water_ocean_collapse must use AnimatedSprite2D ocean-collapse visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 8, "water_ocean_collapse effect must load its full dedicated ocean-collapse sequence")
	assert_lt(sprite.scale.x, 0.0, "water_ocean_collapse projectile must flip when traveling left")
	assert_gt(absf(sprite.scale.x), 1.9, "water_ocean_collapse visual must read wider than water_tsunami")


func test_water_tsunami_projectile_uses_dedicated_tidal_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("water_tsunami_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("water_tsunami", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("water_tsunami_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("water_tsunami_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/water_tsunami_attack/",
		"water_tsunami must read startup frames from a dedicated tidal family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/water_tsunami/",
		"water_tsunami must read loop frames from a dedicated tidal family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/water_tsunami_hit/",
		"water_tsunami must read hit frames from a dedicated tidal family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/water_tsunami_end/",
		"water_tsunami must read terminal frames from a dedicated tidal family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-220.0, 0.0),
		"range": 520.0,
		"team": "player",
		"damage": 40,
		"knockback": 340.0,
		"school": "water",
		"size": 56.0,
		"pierce": 5,
		"spell_id": "water_tsunami",
		"attack_effect_id": "water_tsunami_attack",
		"hit_effect_id": "water_tsunami_hit",
		"terminal_effect_id": "water_tsunami_end",
		"color": "#a2f2ff"
	})
	assert_gt(projectile.get_child_count(), 0, "water_tsunami projectile must still build a tidal visual child after dedicated family split")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "water_tsunami must still use AnimatedSprite2D tidal visual after dedicated family split")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 8, "water_tsunami dedicated tidal family must keep its eight-frame lane sequence")


func test_water_ocean_collapse_projectile_uses_dedicated_ocean_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("water_ocean_collapse_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("water_ocean_collapse", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("water_ocean_collapse_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("water_ocean_collapse_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/water_ocean_collapse_attack/",
		"water_ocean_collapse must read startup frames from a dedicated ocean-collapse family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/water_ocean_collapse/",
		"water_ocean_collapse must read loop frames from a dedicated ocean-collapse family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/water_ocean_collapse_hit/",
		"water_ocean_collapse must read hit frames from a dedicated ocean-collapse family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/water_ocean_collapse_end/",
		"water_ocean_collapse must read terminal frames from a dedicated ocean-collapse family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-220.0, 0.0),
		"range": 560.0,
		"team": "player",
		"damage": 52,
		"knockback": 380.0,
		"school": "water",
		"size": 68.0,
		"pierce": 7,
		"spell_id": "water_ocean_collapse",
		"attack_effect_id": "water_ocean_collapse_attack",
		"hit_effect_id": "water_ocean_collapse_hit",
		"terminal_effect_id": "water_ocean_collapse_end",
		"color": "#b7f8ff"
	})
	assert_gt(projectile.get_child_count(), 0, "water_ocean_collapse projectile must still build an ocean-collapse visual child after dedicated family split")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "water_ocean_collapse must still use AnimatedSprite2D ocean-collapse visual after dedicated family split")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 8, "water_ocean_collapse dedicated family must keep its eight-frame ocean lane sequence")

func test_lightning_bolt_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-180.0, 0.0),
		"range": 430.0,
		"team": "player",
		"damage": 26,
		"knockback": 280.0,
		"school": "lightning",
		"size": 14.0,
		"pierce": 3,
		"spell_id": "lightning_bolt",
		"attack_effect_id": "lightning_bolt_attack",
		"hit_effect_id": "lightning_bolt_hit",
		"color": "#fff5a6"
	})
	assert_gt(projectile.get_child_count(), 0, "lightning_bolt projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "lightning_bolt must use AnimatedSprite2D lightning visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 6, "lightning_bolt effect must load its full chain-read sequence")
	assert_lt(sprite.scale.x, 0.0, "lightning_bolt projectile must flip when traveling left")
	assert_gt(absf(sprite.scale.x), 0.9, "lightning_bolt visual must read slightly wider than thunder_arrow")

func test_ice_absolute_freeze_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 156.0,
		"duration": 0.34,
		"team": "player",
		"damage": 42,
		"knockback": 220.0,
		"school": "ice",
		"size": 156.0,
		"spell_id": "ice_absolute_freeze",
		"attack_effect_id": "ice_absolute_freeze_attack",
		"hit_effect_id": "ice_absolute_freeze_hit",
		"color": "#d8fbff"
	})
	assert_gt(projectile.get_child_count(), 0, "ice_absolute_freeze projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "ice_absolute_freeze must use AnimatedSprite2D freeze burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "ice_absolute_freeze effect must load its full dedicated freeze sequence")
	assert_gt(sprite.scale.x, 0.0, "ice_absolute_freeze burst must keep native non-flipped orientation")
	assert_gt(sprite.scale.x, 2.5, "ice_absolute_freeze visual must read wider than ice_storm loop placeholder")

func test_ice_absolute_zero_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 216.0,
		"duration": 0.56,
		"team": "player",
		"damage": 70,
		"knockback": 260.0,
		"school": "ice",
		"size": 216.0,
		"spell_id": "ice_absolute_zero",
		"attack_effect_id": "ice_absolute_zero_attack",
		"hit_effect_id": "ice_absolute_zero_hit",
		"terminal_effect_id": "ice_absolute_zero_end",
		"color": "#f0feff"
	})
	assert_gt(projectile.get_child_count(), 0, "ice_absolute_zero projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "ice_absolute_zero must use AnimatedSprite2D final freeze burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "ice_absolute_zero effect must load its full dedicated freeze sequence")
	assert_gt(sprite.scale.x, 0.0, "ice_absolute_zero burst must keep native non-flipped orientation")
	assert_gt(sprite.scale.x, 2.9, "ice_absolute_zero visual must read wider than absolute_freeze")


func test_ice_absolute_freeze_projectile_uses_dedicated_freeze_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("ice_absolute_freeze_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("ice_absolute_freeze", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("ice_absolute_freeze_hit", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/ice_absolute_freeze_attack/",
		"ice_absolute_freeze must read startup frames from a dedicated freeze family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/ice_absolute_freeze/",
		"ice_absolute_freeze must read burst frames from a dedicated freeze family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/ice_absolute_freeze_hit/",
		"ice_absolute_freeze must read hit frames from a dedicated freeze family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 156.0,
		"duration": 0.34,
		"team": "player",
		"damage": 42,
		"knockback": 220.0,
		"school": "ice",
		"size": 156.0,
		"spell_id": "ice_absolute_freeze",
		"attack_effect_id": "ice_absolute_freeze_attack",
		"hit_effect_id": "ice_absolute_freeze_hit",
		"color": "#d8fbff"
	})
	assert_gt(projectile.get_child_count(), 0, "ice_absolute_freeze projectile must still build a freeze visual child after dedicated family split")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "ice_absolute_freeze must still use AnimatedSprite2D freeze burst visual after dedicated family split")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "ice_absolute_freeze dedicated freeze family must keep its four-frame burst sequence")


func test_ice_absolute_zero_projectile_uses_dedicated_freeze_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("ice_absolute_zero_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("ice_absolute_zero", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("ice_absolute_zero_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("ice_absolute_zero_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/ice_absolute_zero_attack/",
		"ice_absolute_zero must read startup frames from a dedicated final-freeze family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/ice_absolute_zero/",
		"ice_absolute_zero must read burst frames from a dedicated final-freeze family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/ice_absolute_zero_hit/",
		"ice_absolute_zero must read hit frames from a dedicated final-freeze family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/ice_absolute_zero_end/",
		"ice_absolute_zero must read terminal frames from a dedicated final-freeze family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 216.0,
		"duration": 0.56,
		"team": "player",
		"damage": 70,
		"knockback": 260.0,
		"school": "ice",
		"size": 216.0,
		"spell_id": "ice_absolute_zero",
		"attack_effect_id": "ice_absolute_zero_attack",
		"hit_effect_id": "ice_absolute_zero_hit",
		"terminal_effect_id": "ice_absolute_zero_end",
		"color": "#f0feff"
	})
	assert_gt(projectile.get_child_count(), 0, "ice_absolute_zero projectile must still build a freeze visual child after dedicated family split")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "ice_absolute_zero must still use AnimatedSprite2D final freeze burst visual after dedicated family split")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "ice_absolute_zero dedicated freeze family must keep its four-frame burst sequence")

func test_fire_inferno_buster_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 168.0,
		"duration": 0.32,
		"team": "player",
		"damage": 48,
		"knockback": 260.0,
		"school": "fire",
		"size": 168.0,
		"spell_id": "fire_inferno_buster",
		"attack_effect_id": "fire_inferno_buster_attack",
		"hit_effect_id": "fire_inferno_buster_hit",
		"color": "#ffbf78"
	})
	assert_gt(projectile.get_child_count(), 0, "fire_inferno_buster projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "fire_inferno_buster must use AnimatedSprite2D inferno burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "fire_inferno_buster effect must load its full dedicated inferno sequence")
	assert_gt(sprite.scale.x, 0.0, "fire_inferno_buster burst must keep native non-flipped orientation")
	assert_gt(sprite.scale.x, 2.7, "fire_inferno_buster visual must read wider than fire_flame_arc placeholder")


func test_fire_inferno_buster_projectile_uses_dedicated_inferno_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("fire_inferno_buster_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("fire_inferno_buster", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("fire_inferno_buster_hit", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/fire_inferno_buster_attack/",
		"fire_inferno_buster must read startup frames from a dedicated inferno family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/fire_inferno_buster/",
		"fire_inferno_buster must read burst frames from a dedicated inferno family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/fire_inferno_buster_hit/",
		"fire_inferno_buster must read hit frames from a dedicated inferno family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 168.0,
		"duration": 0.32,
		"team": "player",
		"damage": 48,
		"knockback": 260.0,
		"school": "fire",
		"size": 168.0,
		"spell_id": "fire_inferno_buster",
		"attack_effect_id": "fire_inferno_buster_attack",
		"hit_effect_id": "fire_inferno_buster_hit",
		"color": "#ffbf78"
	})
	assert_gt(projectile.get_child_count(), 0, "fire_inferno_buster projectile must still build an inferno visual child after dedicated family split")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "fire_inferno_buster must still use AnimatedSprite2D inferno burst visual after dedicated family split")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "fire_inferno_buster dedicated inferno family must keep its four-frame burst sequence")


func test_fire_meteor_strike_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 184.0,
		"duration": 0.46,
		"team": "player",
		"damage": 54,
		"knockback": 300.0,
		"school": "fire",
		"size": 184.0,
		"spell_id": "fire_meteor_strike",
		"attack_effect_id": "fire_meteor_strike_attack",
		"hit_effect_id": "fire_meteor_strike_hit",
		"terminal_effect_id": "fire_meteor_strike_end",
		"color": "#ffd29a"
	})
	assert_gt(projectile.get_child_count(), 0, "fire_meteor_strike projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "fire_meteor_strike must use AnimatedSprite2D meteor burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "fire_meteor_strike effect must load its full fallback meteor sequence")
	assert_gt(sprite.scale.x, 0.0, "fire_meteor_strike burst must keep native non-flipped orientation")
	assert_gt(sprite.scale.x, 3.0, "fire_meteor_strike visual must read wider than inferno_buster placeholder")


func test_fire_meteor_strike_projectile_uses_dedicated_meteor_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("fire_meteor_strike_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("fire_meteor_strike", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("fire_meteor_strike_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("fire_meteor_strike_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/fire_meteor_strike_attack/",
		"fire_meteor_strike must read startup frames from a dedicated meteor family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/fire_meteor_strike/",
		"fire_meteor_strike must read burst frames from a dedicated meteor family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/fire_meteor_strike_hit/",
		"fire_meteor_strike must read hit frames from a dedicated meteor family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/fire_meteor_strike_end/",
		"fire_meteor_strike must read terminal frames from a dedicated meteor family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 184.0,
		"duration": 0.46,
		"team": "player",
		"damage": 54,
		"knockback": 300.0,
		"school": "fire",
		"size": 184.0,
		"spell_id": "fire_meteor_strike",
		"attack_effect_id": "fire_meteor_strike_attack",
		"hit_effect_id": "fire_meteor_strike_hit",
		"terminal_effect_id": "fire_meteor_strike_end",
		"color": "#ffd29a"
	})
	assert_gt(projectile.get_child_count(), 0, "fire_meteor_strike projectile must still build a meteor visual child after dedicated family split")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "fire_meteor_strike must still use AnimatedSprite2D meteor burst visual after dedicated family split")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "fire_meteor_strike dedicated meteor family must keep its four-frame burst sequence")

func test_fire_apocalypse_flame_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 204.0,
		"duration": 0.52,
		"team": "player",
		"damage": 68,
		"knockback": 340.0,
		"school": "fire",
		"size": 204.0,
		"spell_id": "fire_apocalypse_flame",
		"attack_effect_id": "fire_apocalypse_flame_attack",
		"hit_effect_id": "fire_apocalypse_flame_hit",
		"terminal_effect_id": "fire_apocalypse_flame_end",
		"color": "#ffe1b2"
	})
	assert_gt(projectile.get_child_count(), 0, "fire_apocalypse_flame projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "fire_apocalypse_flame must use AnimatedSprite2D apocalypse burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "fire_apocalypse_flame effect must load its full dedicated apocalypse sequence")
	assert_gt(sprite.scale.x, 0.0, "fire_apocalypse_flame burst must keep native non-flipped orientation")
	assert_gt(sprite.scale.x, 3.2, "fire_apocalypse_flame visual must read wider than meteor_strike")

func test_fire_solar_cataclysm_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 218.0,
		"duration": 0.56,
		"team": "player",
		"damage": 74,
		"knockback": 380.0,
		"school": "fire",
		"size": 218.0,
		"spell_id": "fire_solar_cataclysm",
		"attack_effect_id": "fire_solar_cataclysm_attack",
		"hit_effect_id": "fire_solar_cataclysm_hit",
		"terminal_effect_id": "fire_solar_cataclysm_end",
		"color": "#fff0c6"
	})
	assert_gt(projectile.get_child_count(), 0, "fire_solar_cataclysm projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "fire_solar_cataclysm must use AnimatedSprite2D solar burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "fire_solar_cataclysm effect must load its full dedicated solar sequence")
	assert_gt(sprite.scale.x, 0.0, "fire_solar_cataclysm burst must keep native non-flipped orientation")
	assert_gt(sprite.scale.x, 3.4, "fire_solar_cataclysm visual must read wider than apocalypse_flame")


func test_fire_apocalypse_flame_projectile_uses_dedicated_apocalypse_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("fire_apocalypse_flame_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("fire_apocalypse_flame", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("fire_apocalypse_flame_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("fire_apocalypse_flame_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/fire_apocalypse_flame_attack/",
		"fire_apocalypse_flame must read startup frames from a dedicated apocalypse family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/fire_apocalypse_flame/",
		"fire_apocalypse_flame must read burst frames from a dedicated apocalypse family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/fire_apocalypse_flame_hit/",
		"fire_apocalypse_flame must read hit frames from a dedicated apocalypse family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/fire_apocalypse_flame_end/",
		"fire_apocalypse_flame must read terminal frames from a dedicated apocalypse family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 204.0,
		"duration": 0.52,
		"team": "player",
		"damage": 68,
		"knockback": 340.0,
		"school": "fire",
		"size": 204.0,
		"spell_id": "fire_apocalypse_flame",
		"attack_effect_id": "fire_apocalypse_flame_attack",
		"hit_effect_id": "fire_apocalypse_flame_hit",
		"terminal_effect_id": "fire_apocalypse_flame_end",
		"color": "#ffe1b2"
	})
	assert_gt(projectile.get_child_count(), 0, "fire_apocalypse_flame projectile must still build an apocalypse visual child after dedicated family split")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "fire_apocalypse_flame must still use AnimatedSprite2D apocalypse burst visual after dedicated family split")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "fire_apocalypse_flame dedicated apocalypse family must keep its four-frame burst sequence")


func test_fire_solar_cataclysm_projectile_uses_dedicated_solar_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("fire_solar_cataclysm_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("fire_solar_cataclysm", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("fire_solar_cataclysm_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("fire_solar_cataclysm_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/fire_solar_cataclysm_attack/",
		"fire_solar_cataclysm must read startup frames from a dedicated solar family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/fire_solar_cataclysm/",
		"fire_solar_cataclysm must read burst frames from a dedicated solar family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/fire_solar_cataclysm_hit/",
		"fire_solar_cataclysm must read hit frames from a dedicated solar family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/fire_solar_cataclysm_end/",
		"fire_solar_cataclysm must read terminal frames from a dedicated solar family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 218.0,
		"duration": 0.56,
		"team": "player",
		"damage": 74,
		"knockback": 380.0,
		"school": "fire",
		"size": 218.0,
		"spell_id": "fire_solar_cataclysm",
		"attack_effect_id": "fire_solar_cataclysm_attack",
		"hit_effect_id": "fire_solar_cataclysm_hit",
		"terminal_effect_id": "fire_solar_cataclysm_end",
		"color": "#fff0c6"
	})
	assert_gt(projectile.get_child_count(), 0, "fire_solar_cataclysm projectile must still build a solar visual child after dedicated family split")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "fire_solar_cataclysm must still use AnimatedSprite2D solar burst visual after dedicated family split")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "fire_solar_cataclysm dedicated solar family must keep its four-frame burst sequence")


func test_earth_gaia_break_projectile_uses_dedicated_collapse_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("earth_gaia_break_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("earth_gaia_break", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("earth_gaia_break_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("earth_gaia_break_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/earth_gaia_break_attack/",
		"earth_gaia_break must read startup frames from a dedicated collapse family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/earth_gaia_break/",
		"earth_gaia_break must read burst frames from a dedicated collapse family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/earth_gaia_break_hit/",
		"earth_gaia_break must read hit frames from a dedicated collapse family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/earth_gaia_break_end/",
		"earth_gaia_break must read terminal frames from a dedicated collapse family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 176.0,
		"duration": 0.40,
		"team": "player",
		"damage": 52,
		"knockback": 420.0,
		"school": "earth",
		"size": 176.0,
		"spell_id": "earth_gaia_break",
		"attack_effect_id": "earth_gaia_break_attack",
		"hit_effect_id": "earth_gaia_break_hit",
		"terminal_effect_id": "earth_gaia_break_end",
		"color": "#d0b080"
	})
	assert_gt(projectile.get_child_count(), 0, "earth_gaia_break projectile must still build a collapse visual child after dedicated family split")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "earth_gaia_break must still use AnimatedSprite2D collapse burst visual after dedicated family split")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 6, "earth_gaia_break dedicated collapse family must keep its six-frame burst sequence")


func test_earth_continental_crush_projectile_uses_dedicated_collapse_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("earth_continental_crush_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("earth_continental_crush", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("earth_continental_crush_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("earth_continental_crush_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/earth_continental_crush_attack/",
		"earth_continental_crush must read startup frames from a dedicated collapse family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/earth_continental_crush/",
		"earth_continental_crush must read burst frames from a dedicated collapse family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/earth_continental_crush_hit/",
		"earth_continental_crush must read hit frames from a dedicated collapse family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/earth_continental_crush_end/",
		"earth_continental_crush must read terminal frames from a dedicated collapse family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 198.0,
		"duration": 0.48,
		"team": "player",
		"damage": 64,
		"knockback": 460.0,
		"school": "earth",
		"size": 198.0,
		"spell_id": "earth_continental_crush",
		"attack_effect_id": "earth_continental_crush_attack",
		"hit_effect_id": "earth_continental_crush_hit",
		"terminal_effect_id": "earth_continental_crush_end",
		"color": "#dfc295"
	})
	assert_gt(projectile.get_child_count(), 0, "earth_continental_crush projectile must still build a collapse visual child after dedicated family split")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "earth_continental_crush must still use AnimatedSprite2D collapse burst visual after dedicated family split")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 6, "earth_continental_crush dedicated collapse family must keep its six-frame burst sequence")


func test_earth_world_end_break_projectile_uses_dedicated_collapse_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("earth_world_end_break_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("earth_world_end_break", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("earth_world_end_break_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("earth_world_end_break_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/earth_world_end_break_attack/",
		"earth_world_end_break must read startup frames from a dedicated collapse family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/earth_world_end_break/",
		"earth_world_end_break must read burst frames from a dedicated collapse family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/earth_world_end_break_hit/",
		"earth_world_end_break must read hit frames from a dedicated collapse family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/earth_world_end_break_end/",
		"earth_world_end_break must read terminal frames from a dedicated collapse family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 214.0,
		"duration": 0.54,
		"team": "player",
		"damage": 72,
		"knockback": 500.0,
		"school": "earth",
		"size": 214.0,
		"spell_id": "earth_world_end_break",
		"attack_effect_id": "earth_world_end_break_attack",
		"hit_effect_id": "earth_world_end_break_hit",
		"terminal_effect_id": "earth_world_end_break_end",
		"color": "#ead3ab"
	})
	assert_gt(projectile.get_child_count(), 0, "earth_world_end_break projectile must still build a collapse visual child after dedicated family split")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "earth_world_end_break must still use AnimatedSprite2D collapse burst visual after dedicated family split")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 6, "earth_world_end_break dedicated collapse family must keep its six-frame burst sequence")


func test_earth_gaia_break_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 176.0,
		"duration": 0.40,
		"team": "player",
		"damage": 52,
		"knockback": 420.0,
		"school": "earth",
		"size": 176.0,
		"spell_id": "earth_gaia_break",
		"attack_effect_id": "earth_gaia_break_attack",
		"hit_effect_id": "earth_gaia_break_hit",
		"terminal_effect_id": "earth_gaia_break_end",
		"color": "#d0b080"
	})
	assert_gt(projectile.get_child_count(), 0, "earth_gaia_break projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "earth_gaia_break must use AnimatedSprite2D collapse burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 6, "earth_gaia_break effect must load its full dedicated earth sequence")
	assert_gt(sprite.scale.x, 0.0, "earth_gaia_break burst must keep native non-flipped orientation")
	assert_gt(sprite.scale.x, 2.7, "earth_gaia_break visual must read wider than moving earth projectile placeholders")

func test_earth_continental_crush_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 198.0,
		"duration": 0.48,
		"team": "player",
		"damage": 64,
		"knockback": 460.0,
		"school": "earth",
		"size": 198.0,
		"spell_id": "earth_continental_crush",
		"attack_effect_id": "earth_continental_crush_attack",
		"hit_effect_id": "earth_continental_crush_hit",
		"terminal_effect_id": "earth_continental_crush_end",
		"color": "#dfc295"
	})
	assert_gt(projectile.get_child_count(), 0, "earth_continental_crush projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "earth_continental_crush must use AnimatedSprite2D collapse burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 6, "earth_continental_crush effect must load its full dedicated earth sequence")
	assert_gt(sprite.scale.x, 0.0, "earth_continental_crush burst must keep native non-flipped orientation")
	assert_gt(sprite.scale.x, 3.0, "earth_continental_crush visual must read larger than gaia_break")

func test_earth_world_end_break_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 214.0,
		"duration": 0.54,
		"team": "player",
		"damage": 72,
		"knockback": 500.0,
		"school": "earth",
		"size": 214.0,
		"spell_id": "earth_world_end_break",
		"attack_effect_id": "earth_world_end_break_attack",
		"hit_effect_id": "earth_world_end_break_hit",
		"terminal_effect_id": "earth_world_end_break_end",
		"color": "#ead3ab"
	})
	assert_gt(projectile.get_child_count(), 0, "earth_world_end_break projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "earth_world_end_break must use AnimatedSprite2D collapse burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 6, "earth_world_end_break effect must load its full dedicated earth sequence")
	assert_gt(sprite.scale.x, 0.0, "earth_world_end_break burst must keep native non-flipped orientation")
	assert_gt(sprite.scale.x, 3.2, "earth_world_end_break visual must read larger than continental_crush")

func test_wind_storm_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 148.0,
		"duration": 0.36,
		"team": "player",
		"damage": 40,
		"knockback": 240.0,
		"school": "wind",
		"size": 148.0,
		"spell_id": "wind_storm",
		"attack_effect_id": "wind_storm_attack",
		"hit_effect_id": "wind_storm_hit",
		"color": "#d6ffd5"
	})
	assert_gt(projectile.get_child_count(), 0, "wind_storm projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "wind_storm must use AnimatedSprite2D burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "wind_storm effect must load its full dedicated storm sequence")
	assert_gt(sprite.scale.x, 0.0, "wind_storm burst must keep native non-flipped orientation")
	assert_gt(sprite.scale.x, 2.2, "wind_storm visual must read wider than moving wind projectile placeholders")


func test_wind_storm_projectile_uses_dedicated_storm_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("wind_storm_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("wind_storm", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("wind_storm_hit", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/wind_storm_attack/",
		"wind_storm must read startup frames from a dedicated storm family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/wind_storm/",
		"wind_storm must read burst frames from a dedicated storm family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/wind_storm_hit/",
		"wind_storm must read hit frames from a dedicated storm family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 148.0,
		"duration": 0.36,
		"team": "player",
		"damage": 40,
		"knockback": 240.0,
		"school": "wind",
		"size": 148.0,
		"spell_id": "wind_storm",
		"attack_effect_id": "wind_storm_attack",
		"hit_effect_id": "wind_storm_hit",
		"color": "#d6ffd5"
	})
	assert_gt(projectile.get_child_count(), 0, "wind_storm projectile must still build a storm visual child after dedicated family split")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "wind_storm must still use AnimatedSprite2D storm burst visual after dedicated family split")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "wind_storm dedicated storm family must keep its four-frame burst sequence")


func test_wind_heavenly_storm_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 188.0,
		"duration": 0.42,
		"team": "player",
		"damage": 60,
		"knockback": 300.0,
		"school": "wind",
		"size": 188.0,
		"spell_id": "wind_heavenly_storm",
		"attack_effect_id": "wind_heavenly_storm_attack",
		"hit_effect_id": "wind_heavenly_storm_hit",
		"color": "#e6ffe0"
	})
	assert_gt(projectile.get_child_count(), 0, "wind_heavenly_storm projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "wind_heavenly_storm must use AnimatedSprite2D burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "wind_heavenly_storm effect must load its full dedicated heavenly sequence")
	assert_gt(sprite.scale.x, 0.0, "wind_heavenly_storm burst must keep native non-flipped orientation")
	assert_gt(sprite.scale.x, 2.6, "wind_heavenly_storm visual must read larger than wind_storm")


func test_wind_heavenly_storm_projectile_uses_dedicated_heavenly_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("wind_heavenly_storm_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("wind_heavenly_storm", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("wind_heavenly_storm_hit", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/wind_heavenly_storm_attack/",
		"wind_heavenly_storm must read startup frames from a dedicated heavenly family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/wind_heavenly_storm/",
		"wind_heavenly_storm must read burst frames from a dedicated heavenly family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/wind_heavenly_storm_hit/",
		"wind_heavenly_storm must read hit frames from a dedicated heavenly family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 188.0,
		"duration": 0.42,
		"team": "player",
		"damage": 60,
		"knockback": 300.0,
		"school": "wind",
		"size": 188.0,
		"spell_id": "wind_heavenly_storm",
		"attack_effect_id": "wind_heavenly_storm_attack",
		"hit_effect_id": "wind_heavenly_storm_hit",
		"color": "#e6ffe0"
	})
	assert_gt(projectile.get_child_count(), 0, "wind_heavenly_storm projectile must still build a heavenly visual child after dedicated family split")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "wind_heavenly_storm must still use AnimatedSprite2D heavenly burst visual after dedicated family split")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "wind_heavenly_storm dedicated heavenly family must keep its four-frame burst sequence")

func test_wind_gale_cutter_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2(-120.0, 0.0),
		"range": 480.0,
		"team": "player",
		"damage": 14,
		"knockback": 140.0,
		"school": "wind",
		"size": 10.0,
		"spell_id": "wind_gale_cutter",
		"attack_effect_id": "wind_gale_cutter_attack",
		"hit_effect_id": "wind_gale_cutter_hit",
		"color": "#b8ffe5"
	})
	assert_gt(projectile.get_child_count(), 0, "wind_gale_cutter projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "wind_gale_cutter must use AnimatedSprite2D projectile visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 2, "wind_gale_cutter effect must load its full cutter loop sequence")
	assert_lt(sprite.scale.x, 0.0, "wind_gale_cutter projectile must flip when traveling left")

func test_fire_flame_arc_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 180.0,
		"duration": 0.28,
		"team": "player",
		"damage": 46,
		"knockback": 220.0,
		"school": "fire",
		"size": 180.0,
		"spell_id": "fire_flame_arc",
		"color": "#ffb56a"
	})
	assert_gt(projectile.get_child_count(), 0, "fire_flame_arc projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "fire_flame_arc must use AnimatedSprite2D burst visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 16, "fire_flame_arc effect must load its full burst sequence")
	assert_gt(sprite.scale.x, 0.0, "fire_flame_arc burst must keep native non-flipped orientation")

func test_fire_inferno_sigil_projectile_uses_animated_effect_asset() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 180.0,
		"duration": 6.0,
		"team": "player",
		"damage": 56,
		"knockback": 220.0,
		"school": "fire",
		"size": 180.0,
		"spell_id": "fire_inferno_sigil",
		"attack_effect_id": "fire_inferno_sigil_attack",
		"hit_effect_id": "fire_inferno_sigil_hit",
		"terminal_effect_id": "fire_inferno_sigil_end",
		"tick_interval": 2.4,
		"color": "#ffbb74"
	})
	assert_gt(projectile.get_child_count(), 0, "fire_inferno_sigil projectile must build a visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "fire_inferno_sigil must use AnimatedSprite2D looping deploy visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 13, "fire_inferno_sigil effect must load its full looping explosion sequence")
	assert_gt(sprite.scale.x, 0.0, "fire_inferno_sigil field must keep native non-flipped orientation")

func test_fire_flame_storm_projectile_uses_dedicated_field_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("fire_flame_storm_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("fire_flame_storm", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("fire_flame_storm_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("fire_flame_storm_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/fire_flame_storm_attack/",
		"fire_flame_storm must read startup frames from a dedicated flame-storm family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/fire_flame_storm/",
		"fire_flame_storm must read loop frames from a dedicated flame-storm family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/fire_flame_storm_hit/",
		"fire_flame_storm must read hit frames from a dedicated flame-storm family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/fire_flame_storm_end/",
		"fire_flame_storm must read terminal frames from a dedicated flame-storm family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 132.0,
		"duration": 6.0,
		"team": "player",
		"damage": 28,
		"knockback": 0.0,
		"school": "fire",
		"size": 132.0,
		"spell_id": "fire_flame_storm",
		"attack_effect_id": "fire_flame_storm_attack",
		"hit_effect_id": "fire_flame_storm_hit",
		"terminal_effect_id": "fire_flame_storm_end",
		"tick_interval": 1.0,
		"color": "#ff9e5a"
	})
	assert_gt(projectile.get_child_count(), 0, "fire_flame_storm projectile must build a field visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "fire_flame_storm must use AnimatedSprite2D looping field visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "fire_flame_storm dedicated field must load all loop frames")
	assert_gt(sprite.scale.x, 0.0, "fire_flame_storm field must keep native non-flipped orientation")

func test_holy_sanctuary_of_reversal_projectile_uses_dedicated_reversal_field_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 156.0,
		"duration": 2.4,
		"team": "player",
		"damage": 0,
		"knockback": 0.0,
		"school": "holy",
		"size": 170.0,
		"spell_id": "holy_sanctuary_of_reversal",
		"attack_effect_id": "holy_sanctuary_of_reversal_attack",
		"hit_effect_id": "holy_sanctuary_of_reversal_hit",
		"terminal_effect_id": "holy_sanctuary_of_reversal_end",
		"tick_interval": 0.35,
		"self_heal": 35,
		"support_effects": [
			{"stat": "damage_taken_multiplier", "mode": "mul", "value": 0.62},
			{"stat": "poise_bonus", "mode": "add", "value": 20}
		],
		"support_effect_duration": 0.7,
		"color": "#fff7e8"
	})
	assert_gt(projectile.get_child_count(), 0, "holy_sanctuary_of_reversal projectile must build a field visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "holy_sanctuary_of_reversal must use AnimatedSprite2D looping sanctuary visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "holy_sanctuary_of_reversal dedicated reversal field must load all authored loop frames")
	assert_gt(sprite.scale.x, 0.0, "holy_sanctuary_of_reversal field must keep native non-flipped orientation")

func test_fire_hellfire_field_projectile_uses_dedicated_field_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("fire_hellfire_field_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("fire_hellfire_field", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("fire_hellfire_field_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("fire_hellfire_field_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/fire_hellfire_field_attack/",
		"fire_hellfire_field must read startup frames from a dedicated hellfire family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/fire_hellfire_field/",
		"fire_hellfire_field must read loop frames from a dedicated hellfire family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/fire_hellfire_field_hit/",
		"fire_hellfire_field must read hit frames from a dedicated hellfire family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/fire_hellfire_field_end/",
		"fire_hellfire_field must read terminal frames from a dedicated hellfire family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 196.0,
		"duration": 8.0,
		"team": "player",
		"damage": 40,
		"knockback": 0.0,
		"school": "fire",
		"size": 196.0,
		"spell_id": "fire_hellfire_field",
		"attack_effect_id": "fire_hellfire_field_attack",
		"hit_effect_id": "fire_hellfire_field_hit",
		"terminal_effect_id": "fire_hellfire_field_end",
		"tick_interval": 1.0,
		"color": "#ff8d4c"
	})
	assert_gt(projectile.get_child_count(), 0, "fire_hellfire_field projectile must build a field visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "fire_hellfire_field must use AnimatedSprite2D looping hellfire visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "fire_hellfire_field dedicated field must load all loop frames")
	assert_gt(sprite.scale.x, 0.0, "fire_hellfire_field field must keep native non-flipped orientation")

func test_holy_bless_field_projectile_uses_dedicated_blessing_field_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 148.0,
		"duration": 6.0,
		"team": "player",
		"damage": 18,
		"knockback": 0.0,
		"school": "holy",
		"size": 148.0,
		"spell_id": "holy_bless_field",
		"attack_effect_id": "holy_bless_field_attack",
		"hit_effect_id": "holy_bless_field_hit",
		"terminal_effect_id": "holy_bless_field_end",
		"tick_interval": 1.0,
		"color": "#fff4d2"
	})
	assert_gt(projectile.get_child_count(), 0, "holy_bless_field projectile must build a field visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "holy_bless_field must use AnimatedSprite2D looping blessing visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "holy_bless_field dedicated blessing loop must load all authored frames")
	assert_gt(sprite.scale.x, 0.0, "holy_bless_field field must keep native non-flipped orientation")

func test_ice_storm_projectile_uses_dedicated_field_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("ice_storm_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("ice_storm", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("ice_storm_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("ice_storm_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/ice_storm_attack/",
		"ice_storm must read startup frames from a dedicated frost-storm family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/ice_storm/",
		"ice_storm must read loop frames from a dedicated frost-storm family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/ice_storm_hit/",
		"ice_storm must read hit frames from a dedicated frost-storm family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/ice_storm_end/",
		"ice_storm must read terminal frames from a dedicated frost-storm family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 142.0,
		"duration": 6.0,
		"team": "player",
		"damage": 20,
		"knockback": 0.0,
		"school": "ice",
		"size": 142.0,
		"spell_id": "ice_storm",
		"attack_effect_id": "ice_storm_attack",
		"hit_effect_id": "ice_storm_hit",
		"terminal_effect_id": "ice_storm_end",
		"tick_interval": 1.0,
		"color": "#cff4ff"
	})
	assert_gt(projectile.get_child_count(), 0, "ice_storm projectile must build a field visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "ice_storm must use AnimatedSprite2D looping frost visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "ice_storm dedicated field must load all loop frames")
	assert_gt(sprite.scale.x, 0.0, "ice_storm field must keep native non-flipped orientation")

func test_wind_cyclone_prison_pull_and_terminal_effect_runtime_behaviour() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("wind_cyclone_prison"))
	assert_eq(payloads.size(), 1)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	enemy.target = null
	enemy.gravity = 0.0
	enemy.velocity = Vector2.ZERO
	enemy.set_physics_process(false)
	enemy.global_position = Vector2(102.0, -4.0)
	await _advance_frames(2)
	var x_before := enemy.global_position.x
	var projectile := _spawn_projectile_for_spell_coverage(root, _force_status_effect_rolls(payloads[0], 0.0))
	await _advance_frames(70)
	assert_lt(enemy.global_position.x, x_before, "wind_cyclone_prison must pull enemies inward while the field persists")
	assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "wind_cyclone_prison must apply slow through its repeated field ticks")
	assert_gt(float(enemy.status_timers.get("root", 0.0)), 0.0, "wind_cyclone_prison must apply a short root to sell the prison behaviour")
	projectile.duration = 0.01
	await _advance_frames(3)
	assert_true(projectile.terminal_effect_played, "wind_cyclone_prison must play a terminal burst when the field expires")
	var terminal_sprite: AnimatedSprite2D = null
	for child in projectile.get_children():
		terminal_sprite = child as AnimatedSprite2D
		if terminal_sprite != null:
			break
	assert_true(terminal_sprite != null, "wind_cyclone_prison terminal burst must swap in an AnimatedSprite2D visual")
	assert_eq(terminal_sprite.sprite_frames.get_frame_count("fly"), 12, "wind_cyclone_prison terminal burst must load all ending frames")


func test_ice_ice_wall_applies_slow_and_root_on_contact() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("ice_ice_wall"))
	assert_eq(payloads.size(), 1)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	enemy.target = null
	enemy.gravity = 0.0
	enemy.velocity = Vector2.ZERO
	enemy.set_physics_process(false)
	enemy.global_position = Vector2(60.0, -4.0)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup(_force_status_effect_rolls(payloads[0], 0.0))
	root.add_child(projectile)
	await _advance_frames(1)
	projectile._hit_enemy(enemy, false)
	await _advance_frames(1)
	assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "ice_ice_wall must slow enemies that touch the wall shell")
	assert_gt(float(enemy.status_timers.get("root", 0.0)), 0.0, "ice_ice_wall must briefly root enemies that collide with the wall shell")
	assert_false(projectile.terminal_effect_played, "ice_ice_wall contact control must not consume the wall shell immediately")
	GameState.reset_progress_for_tests()


func test_earth_stone_rampart_applies_slow_and_root_on_contact() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	var payloads: Array = []
	manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p))
	assert_true(manager.attempt_cast("earth_stone_rampart"))
	assert_eq(payloads.size(), 1)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	enemy.target = null
	enemy.gravity = 0.0
	enemy.velocity = Vector2.ZERO
	enemy.set_physics_process(false)
	enemy.global_position = Vector2(60.0, -4.0)
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup(_force_status_effect_rolls(payloads[0], 0.0))
	root.add_child(projectile)
	await _advance_frames(1)
	projectile._hit_enemy(enemy, false)
	await _advance_frames(1)
	assert_gt(float(enemy.status_timers.get("slow", 0.0)), 0.0, "earth_stone_rampart must slow enemies that run into the wall shell")
	assert_gt(float(enemy.status_timers.get("root", 0.0)), 0.0, "earth_stone_rampart must briefly root enemies that collide with the wall shell")
	assert_false(projectile.terminal_effect_played, "earth_stone_rampart contact control must not consume the wall shell immediately")
	GameState.reset_progress_for_tests()

func test_plant_world_root_projectile_uses_dedicated_field_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("plant_world_root_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("plant_world_root", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("plant_world_root_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("plant_world_root_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/plant_world_root_attack/",
		"plant_world_root must read startup frames from a dedicated world-root family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/plant_world_root/",
		"plant_world_root must read loop frames from a dedicated world-root family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/plant_world_root_hit/",
		"plant_world_root must read hit frames from a dedicated world-root family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/plant_world_root_end/",
		"plant_world_root must read terminal frames from a dedicated world-root family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 186.0,
		"duration": 8.0,
		"team": "player",
		"damage": 28,
		"knockback": 0.0,
		"school": "plant",
		"size": 186.0,
		"spell_id": "plant_world_root",
		"attack_effect_id": "plant_world_root_attack",
		"hit_effect_id": "plant_world_root_hit",
		"terminal_effect_id": "plant_world_root_end",
		"tick_interval": 1.0,
		"color": "#b9df98"
	})
	assert_gt(projectile.get_child_count(), 0, "plant_world_root projectile must build a field visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "plant_world_root must use AnimatedSprite2D looping rootfield visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "plant_world_root dedicated field must load all loop frames")
	assert_gt(sprite.scale.x, 0.0, "plant_world_root field must keep native non-flipped orientation")

func test_plant_worldroot_bastion_projectile_uses_dedicated_field_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("plant_worldroot_bastion_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("plant_worldroot_bastion", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("plant_worldroot_bastion_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("plant_worldroot_bastion_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/plant_worldroot_bastion_attack/",
		"plant_worldroot_bastion must read startup frames from a dedicated bastion family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/plant_worldroot_bastion/",
		"plant_worldroot_bastion must read loop frames from a dedicated bastion family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/plant_worldroot_bastion_hit/",
		"plant_worldroot_bastion must read hit frames from a dedicated bastion family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/plant_worldroot_bastion_end/",
		"plant_worldroot_bastion must read terminal frames from a dedicated bastion family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 156.0,
		"duration": 9.0,
		"team": "player",
		"damage": 31,
		"knockback": 0.0,
		"school": "plant",
		"size": 156.0,
		"spell_id": "plant_worldroot_bastion",
		"attack_effect_id": "plant_worldroot_bastion_attack",
		"hit_effect_id": "plant_worldroot_bastion_hit",
		"terminal_effect_id": "plant_worldroot_bastion_end",
		"tick_interval": 1.0,
		"color": "#c0dfa0"
	})
	assert_gt(projectile.get_child_count(), 0, "plant_worldroot_bastion projectile must build a field visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "plant_worldroot_bastion must use AnimatedSprite2D looping bastion field visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "plant_worldroot_bastion dedicated field must load all loop frames")
	assert_gt(sprite.scale.x, 0.0, "plant_worldroot_bastion field must keep native non-flipped orientation")
	assert_gt(sprite.scale.y, 2.5, "plant_worldroot_bastion dedicated field must read larger than plant_world_root")
	var genesis_projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	genesis_projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 210.0,
		"duration": 10.0,
		"team": "player",
		"damage": 34,
		"knockback": 0.0,
		"school": "plant",
		"size": 210.0,
		"spell_id": "plant_genesis_arbor",
		"attack_effect_id": "plant_genesis_arbor_attack",
		"hit_effect_id": "plant_genesis_arbor_hit",
		"terminal_effect_id": "plant_genesis_arbor_end",
		"tick_interval": 1.0,
		"color": "#c7e7a2"
	})
	var genesis_sprite := genesis_projectile.get_child(0) as AnimatedSprite2D
	assert_true(genesis_sprite != null, "plant_genesis_arbor comparison visual must build successfully")
	assert_lt(
		sprite.scale.y,
		genesis_sprite.scale.y,
		"plant_worldroot_bastion dedicated field must stay below plant_genesis_arbor"
	)

func test_plant_vine_snare_projectile_uses_dedicated_vine_bind_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 96.0,
		"duration": 5.0,
		"team": "player",
		"damage": 12,
		"knockback": 0.0,
		"school": "plant",
		"size": 96.0,
		"spell_id": "plant_vine_snare",
		"attack_effect_id": "plant_vine_snare_attack",
		"hit_effect_id": "plant_vine_snare_hit",
		"terminal_effect_id": "plant_vine_snare_end",
		"tick_interval": 1.0,
		"color": "#a8d68f"
	})
	assert_gt(projectile.get_child_count(), 0, "plant_vine_snare projectile must build a field visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "plant_vine_snare must use AnimatedSprite2D looping snare-field visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "plant_vine_snare dedicated vine-bind loop must load all authored frames")
	assert_gt(sprite.scale.x, 0.0, "plant_vine_snare field must keep native non-flipped orientation")
	assert_gt(sprite.scale.y, 1.9, "plant_vine_snare dedicated field must read larger than a single root burst")
	assert_lt(sprite.scale.y, 2.3, "plant_vine_snare dedicated field must stay below plant_world_root")

func test_plant_genesis_arbor_projectile_uses_dedicated_field_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("plant_genesis_arbor_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("plant_genesis_arbor", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("plant_genesis_arbor_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("plant_genesis_arbor_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/plant_genesis_arbor_attack/",
		"plant_genesis_arbor must read startup frames from a dedicated genesis family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/plant_genesis_arbor/",
		"plant_genesis_arbor must read loop frames from a dedicated genesis family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/plant_genesis_arbor_hit/",
		"plant_genesis_arbor must read hit frames from a dedicated genesis family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/plant_genesis_arbor_end/",
		"plant_genesis_arbor must read terminal frames from a dedicated genesis family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 210.0,
		"duration": 10.0,
		"team": "player",
		"damage": 34,
		"knockback": 0.0,
		"school": "plant",
		"size": 210.0,
		"spell_id": "plant_genesis_arbor",
		"attack_effect_id": "plant_genesis_arbor_attack",
		"hit_effect_id": "plant_genesis_arbor_hit",
		"terminal_effect_id": "plant_genesis_arbor_end",
		"tick_interval": 1.0,
		"color": "#c7e7a2"
	})
	assert_gt(projectile.get_child_count(), 0, "plant_genesis_arbor projectile must build a field visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "plant_genesis_arbor must use AnimatedSprite2D looping canopy visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "plant_genesis_arbor dedicated field must load all loop frames")
	assert_gt(sprite.scale.x, 0.0, "plant_genesis_arbor field must keep native non-flipped orientation")
	assert_gt(sprite.scale.y, 2.7, "plant_genesis_arbor dedicated field must read larger than plant_world_root")

func test_dark_shadow_bind_projectile_uses_dedicated_curse_field_effect_family() -> void:
	var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
	var attack_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("dark_shadow_bind_attack", {})
	var loop_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.SPELL_VISUAL_SPECS.get("dark_shadow_bind", {})
	var hit_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.WORLD_EFFECT_SPECS.get("dark_shadow_bind_hit", {})
	var end_spec: Dictionary = SPELL_PROJECTILE_SCRIPT.TERMINAL_EFFECT_SPECS.get("dark_shadow_bind_end", {})
	assert_eq(
		str(attack_spec.get("dir_path", "")),
		"res://assets/effects/dark_shadow_bind_attack/",
		"dark_shadow_bind must read startup frames from a dedicated curse-field family path"
	)
	assert_eq(
		str(loop_spec.get("dir_path", "")),
		"res://assets/effects/dark_shadow_bind/",
		"dark_shadow_bind must read loop frames from a dedicated curse-field family path"
	)
	assert_eq(
		str(hit_spec.get("dir_path", "")),
		"res://assets/effects/dark_shadow_bind_hit/",
		"dark_shadow_bind must read hit frames from a dedicated curse-field family path"
	)
	assert_eq(
		str(end_spec.get("dir_path", "")),
		"res://assets/effects/dark_shadow_bind_end/",
		"dark_shadow_bind must read terminal frames from a dedicated curse-field family path"
	)
	projectile.setup({
		"position": Vector2.ZERO,
		"velocity": Vector2.ZERO,
		"range": 110.0,
		"duration": 6.0,
		"team": "player",
		"damage": 16,
		"knockback": 0.0,
		"school": "dark",
		"size": 110.0,
		"spell_id": "dark_shadow_bind",
		"attack_effect_id": "dark_shadow_bind_attack",
		"hit_effect_id": "dark_shadow_bind_hit",
		"terminal_effect_id": "dark_shadow_bind_end",
		"tick_interval": 1.0,
		"color": "#bca6da"
	})
	assert_gt(projectile.get_child_count(), 0, "dark_shadow_bind projectile must build a curse field visual child")
	var sprite := projectile.get_child(0) as AnimatedSprite2D
	assert_true(sprite != null, "dark_shadow_bind must use AnimatedSprite2D looping curse-field visual")
	assert_eq(sprite.sprite_frames.get_frame_count("fly"), 4, "dark_shadow_bind dedicated curse field must load all loop frames")
	assert_gt(sprite.scale.x, 0.0, "dark_shadow_bind field must keep native non-flipped orientation")
	assert_gt(sprite.scale.y, 2.0, "dark_shadow_bind dedicated field must read larger than a bolt-sized dark hit")
	assert_lt(sprite.scale.y, 2.4, "dark_shadow_bind dedicated field must stay below late-game field tiers")

func test_fallback_projectile_first_wave_cast_payloads_preserve_school_and_split_effect_contracts() -> void:
	GameState.reset_progress_for_tests()
	GameState.set_admin_ignore_cooldowns(true)
	GameState.set_admin_infinite_mana(true)
	var root := Node2D.new()
	add_child_autofree(root)
	var player = PLAYER_SCRIPT.new()
	root.add_child(player)
	await _advance_frames(2)
	var manager = SPELL_MANAGER_SCRIPT.new()
	manager.setup(player)
	for runtime_case in FALLBACK_PROJECTILE_RUNTIME_CASES:
		var payloads: Array = []
		manager.spell_cast.connect(func(p: Dictionary) -> void: payloads.append(p), CONNECT_ONE_SHOT)
		if str(runtime_case.get("spell_id", "")) == "holy_halo_touch":
			GameState.health = GameState.max_health - 20
		assert_true(manager.attempt_cast(str(runtime_case.get("spell_id", ""))), "%s cast must succeed" % runtime_case.get("spell_id"))
		assert_eq(payloads.size(), 1, "%s cast must emit exactly one payload" % runtime_case.get("spell_id"))
		var payload: Dictionary = payloads[0]
		assert_eq(str(payload.get("spell_id", "")), str(runtime_case.get("spell_id", "")))
		assert_eq(str(payload.get("school", "")), str(runtime_case.get("school", "")))
		assert_eq(str(payload.get("attack_effect_id", "")), str(runtime_case.get("attack", "")))
		assert_eq(str(payload.get("hit_effect_id", "")), str(runtime_case.get("hit", "")))
		assert_gt(float(payload.get("speed", 0.0)), 0.0, "%s must remain a moving projectile/line payload" % runtime_case.get("spell_id"))
		if str(runtime_case.get("spell_id", "")) == "holy_halo_touch":
			assert_gt(int(payload.get("self_heal", 0)), 0, "holy_halo_touch must carry a self-heal rider in the current solo runtime")
			assert_gt(GameState.health, GameState.max_health - 20, "holy_halo_touch must restore some player health on cast")

func test_fallback_projectile_first_wave_uses_sampled_placeholder_visuals() -> void:
	for runtime_case in FALLBACK_PROJECTILE_RUNTIME_CASES:
		var projectile = autofree(SPELL_PROJECTILE_SCRIPT.new())
		projectile.setup({
			"position": Vector2.ZERO,
			"velocity": Vector2(-720.0, 0.0),
			"range": 420.0,
			"duration": 0.6,
			"team": "player",
			"damage": 20,
			"knockback": 220.0,
			"school": str(runtime_case.get("school", "")),
			"size": 14.0,
			"spell_id": str(runtime_case.get("spell_id", "")),
			"attack_effect_id": str(runtime_case.get("attack", "")),
			"hit_effect_id": str(runtime_case.get("hit", "")),
			"color": "#ffffff"
		})
		assert_gt(projectile.get_child_count(), 0, "%s projectile must build a visual child" % runtime_case.get("spell_id"))
		var sprite := projectile.get_child(0) as AnimatedSprite2D
		assert_true(sprite != null, "%s projectile must use AnimatedSprite2D fallback visual" % runtime_case.get("spell_id"))
		assert_eq(sprite.sprite_frames.get_frame_count("fly"), int(runtime_case.get("visual_frames", 0)), "%s fallback visual must load all authored placeholder frames" % runtime_case.get("spell_id"))
		assert_lt(sprite.scale.x, 0.0, "%s fallback projectile must flip when traveling left" % runtime_case.get("spell_id"))

func test_ice_spear_projectile_applies_freeze_with_forced_roll() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	var payload := _force_status_effect_rolls({
		"spell_id": "ice_spear",
		"attack_effect_id": "ice_spear_attack",
		"hit_effect_id": "ice_spear_hit",
		"position": Vector2.ZERO,
		"velocity": Vector2(880.0, 0.0),
		"range": 440.0,
		"team": "player",
		"damage": 24,
		"knockback": 220.0,
		"school": "ice",
		"size": 12.0,
		"utility_effects": [
			{"type": "freeze", "chance": 1.0, "value": 1.0, "duration": 0.75}
		]
	})
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	assert_true(projectile._hit_enemy(enemy), "ice_spear must connect through the projectile hit path")
	assert_gt(float(enemy.status_timers.get("freeze", 0.0)), 0.0, "ice_spear must apply freeze on hit when the status roll is forced")

func test_lightning_thunder_arrow_projectile_applies_shock_with_forced_roll() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var enemy := _spawn_enemy_for_spell_coverage(root, "brute")
	var payload := _force_status_effect_rolls({
		"spell_id": "lightning_thunder_arrow",
		"attack_effect_id": "lightning_thunder_arrow_attack",
		"hit_effect_id": "lightning_thunder_arrow_hit",
		"position": Vector2.ZERO,
		"velocity": Vector2(980.0, 0.0),
		"range": 470.0,
		"team": "player",
		"damage": 22,
		"knockback": 300.0,
		"school": "lightning",
		"size": 10.0,
		"utility_effects": [
			{"type": "shock", "chance": 1.0, "value": 1.0, "duration": 1.1}
		]
	})
	var projectile := _spawn_projectile_for_spell_coverage(root, payload)
	assert_true(projectile._hit_enemy(enemy), "lightning_thunder_arrow must connect through the projectile hit path")
	assert_gt(float(enemy.status_timers.get("shock", 0.0)), 0.0, "lightning_thunder_arrow must apply shock on hit when the status roll is forced")
