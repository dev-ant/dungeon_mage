extends CharacterBody2D

signal cast_spell(payload: Dictionary)
signal request_room_shift(direction: int)

const SPEED := 310.0
const JUMP_VELOCITY := -680.0
const DASH_SPEED := 780.0
const DASH_TIME := 0.16
const DASH_COOLDOWN := 0.5
const IFRAME_TIME := 0.8
const HIT_STUN_TIME := 0.18
const CAST_LOCK_TIME := 0.08
const MAX_JUMPS := 2
const PLATFORM_DROP_THROUGH_TIME := 0.18
const PLATFORM_DROP_THROUGH_FALL_SPEED := 160.0
const ROOM_SHIFT_LEFT_MARGIN := 20.0
const ROOM_SHIFT_RIGHT_MARGIN := 60.0

const StateChartScript := preload("res://addons/godot_state_charts/state_chart.gd")
const CompoundStateScript := preload("res://addons/godot_state_charts/compound_state.gd")
const AtomicStateScript := preload("res://addons/godot_state_charts/atomic_state.gd")
const TransitionScript := preload("res://addons/godot_state_charts/transition.gd")

const ROPE_CLIMB_SPEED := 180.0
const BUFF_VISUAL_SPECS := {
	"holy_guard_activation":
	{
		"dir_path": "res://assets/effects/holy_guard_activation/",
		"frame_prefix": "holy_guard_activation",
		"frame_count": 11,
		"fps": 18.0,
		"scale": 1.0,
		"flip_by_facing": false,
		"modulate_color": "#fff5be",
		"loop_animation": false
	},
	"holy_guard_overlay":
	{
		"dir_path": "res://assets/effects/holy_guard_overlay/",
		"frame_prefix": "holy_guard_overlay",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 1.0,
		"flip_by_facing": false,
		"modulate_color": "#fff5be",
		"loop_animation": true
	},
	"holy_dawn_oath_activation":
	{
		"dir_path": "res://assets/effects/holy_dawn_oath_activation/",
		"frame_prefix": "holy_dawn_oath_activation",
		"frame_count": 11,
		"fps": 18.0,
		"scale": 1.08,
		"flip_by_facing": false,
		"modulate_color": "#fff7cf",
		"loop_animation": false
	},
	"holy_dawn_oath_overlay":
	{
		"dir_path": "res://assets/effects/holy_dawn_oath_overlay/",
		"frame_prefix": "holy_dawn_oath_overlay",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 1.1,
		"flip_by_facing": false,
		"modulate_color": "#fff9de",
		"loop_animation": true
	},
	"pyre_heart_activation":
	{
		"dir_path": "res://assets/effects/pyre_heart_activation/",
		"frame_prefix": "pyre_heart_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.0,
		"flip_by_facing": false,
		"modulate_color": "#ffb47f",
		"loop_animation": false
	},
	"pyre_heart_overlay":
	{
		"dir_path": "res://assets/effects/pyre_heart_overlay/",
		"frame_prefix": "pyre_heart_overlay",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 1.0,
		"flip_by_facing": false,
		"modulate_color": "#ffd8c2",
		"loop_animation": true
	},
	"frostblood_ward_activation":
	{
		"dir_path": "res://assets/effects/frostblood_ward_activation/",
		"frame_prefix": "frostblood_ward_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.0,
		"flip_by_facing": false,
		"modulate_color": "#c9f4ff",
		"loop_animation": false
	},
	"frostblood_ward_overlay":
	{
		"dir_path": "res://assets/effects/frostblood_ward_overlay/",
		"frame_prefix": "frostblood_ward_overlay",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 1.0,
		"flip_by_facing": false,
		"modulate_color": "#e3fbff",
		"loop_animation": true
	},
	"dark_throne_activation":
	{
		"dir_path": "res://assets/effects/dark_throne_activation/",
		"frame_prefix": "dark_throne_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.06,
		"flip_by_facing": false,
		"modulate_color": "#ff9d7a",
		"loop_animation": false
	},
	"dark_throne_overlay":
	{
		"dir_path": "res://assets/effects/dark_throne_overlay/",
		"frame_prefix": "dark_throne_overlay",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 1.08,
		"flip_by_facing": false,
		"modulate_color": "#d68f84",
		"loop_animation": true
	},
	"conductive_surge_activation":
	{
		"dir_path": "res://assets/effects/conductive_surge_activation/",
		"frame_prefix": "conductive_surge_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.04,
		"flip_by_facing": false,
		"modulate_color": "#fff2a6",
		"loop_animation": false
	},
	"conductive_surge_overlay":
	{
		"dir_path": "res://assets/effects/conductive_surge_overlay/",
		"frame_prefix": "conductive_surge_overlay",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 1.02,
		"flip_by_facing": false,
		"modulate_color": "#fff7c7",
		"loop_animation": true
	},
	"astral_compression_activation":
	{
		"dir_path": "res://assets/effects/astral_compression_activation/",
		"frame_prefix": "astral_compression_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.0,
		"flip_by_facing": false,
		"modulate_color": "#dbc9ff",
		"loop_animation": false
	},
	"astral_compression_overlay":
	{
		"dir_path": "res://assets/effects/astral_compression_overlay/",
		"frame_prefix": "astral_compression_overlay",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 1.0,
		"flip_by_facing": false,
		"modulate_color": "#efe7ff",
		"loop_animation": true
	},
	"grave_pact_activation":
	{
		"dir_path": "res://assets/effects/grave_pact_activation/",
		"frame_prefix": "grave_pact_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.03,
		"flip_by_facing": false,
		"modulate_color": "#b58ad1",
		"loop_animation": false
	},
	"grave_pact_overlay":
	{
		"dir_path": "res://assets/effects/grave_pact_overlay/",
		"frame_prefix": "grave_pact_overlay",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 1.02,
		"flip_by_facing": false,
		"modulate_color": "#d5c0e6",
		"loop_animation": true
	},
	"verdant_overflow_activation":
	{
		"dir_path": "res://assets/effects/verdant_overflow_activation/",
		"frame_prefix": "verdant_overflow_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.03,
		"flip_by_facing": false,
		"modulate_color": "#baffb0",
		"loop_animation": false
	},
	"verdant_overflow_overlay":
	{
		"dir_path": "res://assets/effects/verdant_overflow_overlay/",
		"frame_prefix": "verdant_overflow_overlay",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 1.01,
		"flip_by_facing": false,
		"modulate_color": "#d9ffd2",
		"loop_animation": true
	},
	"tempest_drive_activation":
	{
		"dir_path": "res://assets/effects/fallback_aura_activation/",
		"frame_prefix": "fallback_aura_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.0,
		"flip_by_facing": false,
		"modulate_color": "#d4ffe3",
		"loop_animation": false
	},
	"world_hourglass_activation":
	{
		"dir_path": "res://assets/effects/world_hourglass_activation/",
		"frame_prefix": "world_hourglass_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.0,
		"flip_by_facing": false,
		"modulate_color": "#ffe2c2",
		"loop_animation": false
	},
	"world_hourglass_overlay":
	{
		"dir_path": "res://assets/effects/world_hourglass_overlay/",
		"frame_prefix": "world_hourglass_overlay",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 1.0,
		"flip_by_facing": false,
		"modulate_color": "#fff1e3",
		"loop_animation": true
	}
}
const BUFF_VISUAL_PRIORITY := {
	"plant_verdant_overflow": 1,
	"fire_pyre_heart": 2,
	"lightning_conductive_surge": 3,
	"arcane_astral_compression": 4,
	"dark_grave_pact": 5,
	"arcane_world_hourglass": 6,
	"ice_frostblood_ward": 7,
	"holy_mana_veil": 8,
	"holy_crystal_aegis": 9,
	"holy_dawn_oath": 10,
	"dark_throne_of_ash": 11
}
const TOGGLE_VISUAL_SPECS := {
	"ice_frozen_domain_activation":
	{
		"dir_path": "res://assets/effects/ice_frozen_domain_activation/",
		"frame_prefix": "ice_frozen_domain_activation",
		"frame_count": 9,
		"fps": 16.0,
		"scale": 3.2,
		"flip_by_facing": false,
		"modulate_color": "#dffaff",
		"loop_animation": false
	},
	"ice_frozen_domain_loop":
	{
		"dir_path": "res://assets/effects/ice_frozen_domain_loop/",
		"frame_prefix": "ice_frozen_domain_loop",
		"frame_count": 8,
		"fps": 9.0,
		"scale": 3.4,
		"flip_by_facing": false,
		"modulate_color": "#d6f6ff",
		"loop_animation": true
	},
	"ice_frozen_domain_end":
	{
		"dir_path": "res://assets/effects/ice_frozen_domain_end/",
		"frame_prefix": "ice_frozen_domain_end",
		"frame_count": 18,
		"fps": 16.0,
		"scale": 3.2,
		"flip_by_facing": false,
		"modulate_color": "#e9fbff",
		"loop_animation": false
	},
	"tempest_crown_activation":
	{
		"dir_path": "res://assets/effects/tempest_crown_activation/",
		"frame_prefix": "tempest_crown_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 2.6,
		"flip_by_facing": false,
		"modulate_color": "#fff0a8",
		"loop_animation": false
	},
	"tempest_crown_loop":
	{
		"dir_path": "res://assets/effects/tempest_crown_loop/",
		"frame_prefix": "tempest_crown_loop",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 2.8,
		"flip_by_facing": false,
		"modulate_color": "#fff3b8",
		"loop_animation": true
	},
	"tempest_crown_end":
	{
		"dir_path": "res://assets/effects/tempest_crown_end/",
		"frame_prefix": "tempest_crown_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 2.6,
		"flip_by_facing": false,
		"modulate_color": "#fff8d4",
		"loop_animation": false
	},
	"earth_fortress_activation":
	{
		"dir_path": "res://assets/effects/fallback_aura_activation/",
		"frame_prefix": "fallback_aura_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 2.8,
		"flip_by_facing": false,
		"modulate_color": "#d7bf96",
		"loop_animation": false
	},
	"earth_fortress_loop":
	{
		"dir_path": "res://assets/effects/fallback_aura_loop/",
		"frame_prefix": "fallback_aura_loop",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 3.0,
		"flip_by_facing": false,
		"modulate_color": "#ccb186",
		"loop_animation": true
	},
	"earth_fortress_end":
	{
		"dir_path": "res://assets/effects/fallback_aura_end/",
		"frame_prefix": "fallback_aura_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 2.8,
		"flip_by_facing": false,
		"modulate_color": "#ead9b7",
		"loop_animation": false
	},
	"storm_zone_activation":
	{
		"dir_path": "res://assets/effects/wind_storm_zone_activation/",
		"frame_prefix": "wind_storm_zone_activation",
		"frame_count": 4,
		"fps": 17.0,
		"scale": 2.9,
		"flip_by_facing": false,
		"modulate_color": "#d8ffea",
		"loop_animation": false
	},
	"storm_zone_loop":
	{
		"dir_path": "res://assets/effects/wind_storm_zone_loop/",
		"frame_prefix": "wind_storm_zone_loop",
		"frame_count": 4,
		"fps": 9.0,
		"scale": 3.1,
		"flip_by_facing": false,
		"modulate_color": "#c9ffe4",
		"loop_animation": true
	},
	"storm_zone_end":
	{
		"dir_path": "res://assets/effects/wind_storm_zone_end/",
		"frame_prefix": "wind_storm_zone_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 2.9,
		"flip_by_facing": false,
		"modulate_color": "#ecfff5",
		"loop_animation": false
	},
	"seraph_chorus_activation":
	{
		"dir_path": "res://assets/effects/holy_seraph_chorus_activation/",
		"frame_prefix": "holy_seraph_chorus_activation",
		"frame_count": 4,
		"fps": 17.0,
		"scale": 3.0,
		"flip_by_facing": false,
		"modulate_color": "#fff3cc",
		"loop_animation": false
	},
	"seraph_chorus_loop":
	{
		"dir_path": "res://assets/effects/holy_seraph_chorus_loop/",
		"frame_prefix": "holy_seraph_chorus_loop",
		"frame_count": 4,
		"fps": 9.0,
		"scale": 3.2,
		"flip_by_facing": false,
		"modulate_color": "#fff7dd",
		"loop_animation": true
	},
	"seraph_chorus_end":
	{
		"dir_path": "res://assets/effects/holy_seraph_chorus_end/",
		"frame_prefix": "holy_seraph_chorus_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 3.0,
		"flip_by_facing": false,
		"modulate_color": "#fffbef",
		"loop_animation": false
	},
	"soul_dominion_activation":
	{
		"dir_path": "res://assets/effects/soul_dominion_activation/",
		"frame_prefix": "soul_dominion_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 2.8,
		"flip_by_facing": false,
		"modulate_color": "#b694ff",
		"loop_animation": false
	},
	"soul_dominion_loop":
	{
		"dir_path": "res://assets/effects/soul_dominion_loop/",
		"frame_prefix": "soul_dominion_loop",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 3.0,
		"flip_by_facing": false,
		"modulate_color": "#ae89ff",
		"loop_animation": true
	},
	"soul_dominion_end":
	{
		"dir_path": "res://assets/effects/soul_dominion_end/",
		"frame_prefix": "soul_dominion_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 2.8,
		"flip_by_facing": false,
		"modulate_color": "#d4c0ff",
		"loop_animation": false
	},
	"soul_dominion_aftershock":
	{
		"dir_path": "res://assets/effects/soul_dominion_aftershock/",
		"frame_prefix": "soul_dominion_aftershock",
		"frame_count": 4,
		"fps": 12.0,
		"scale": 3.0,
		"flip_by_facing": false,
		"modulate_color": "#efe6ff",
		"loop_animation": false
	},
	"soul_dominion_clear":
	{
		"dir_path": "res://assets/effects/soul_dominion_clear/",
		"frame_prefix": "soul_dominion_clear",
		"frame_count": 4,
		"fps": 11.0,
		"scale": 2.6,
		"flip_by_facing": false,
		"modulate_color": "#d3dfff",
		"loop_animation": false
	},
	"grave_echo_activation":
	{
		"dir_path": "res://assets/effects/grave_echo_activation/",
		"frame_prefix": "grave_echo_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 2.7,
		"flip_by_facing": false,
		"modulate_color": "#9a82c7",
		"loop_animation": false
	},
	"grave_echo_loop":
	{
		"dir_path": "res://assets/effects/grave_echo_loop/",
		"frame_prefix": "grave_echo_loop",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 2.9,
		"flip_by_facing": false,
		"modulate_color": "#b8a6d8",
		"loop_animation": true
	},
	"grave_echo_end":
	{
		"dir_path": "res://assets/effects/grave_echo_end/",
		"frame_prefix": "grave_echo_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 2.7,
		"flip_by_facing": false,
		"modulate_color": "#d7cae8",
		"loop_animation": false
	},
	"sky_dominion_activation":
	{
		"dir_path": "res://assets/effects/fallback_aura_activation/",
		"frame_prefix": "fallback_aura_activation",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 3.0,
		"flip_by_facing": false,
		"modulate_color": "#edfff8",
		"loop_animation": false
	},
	"sky_dominion_loop":
	{
		"dir_path": "res://assets/effects/fallback_aura_loop/",
		"frame_prefix": "fallback_aura_loop",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 3.2,
		"flip_by_facing": false,
		"modulate_color": "#dcfff2",
		"loop_animation": true
	},
	"sky_dominion_end":
	{
		"dir_path": "res://assets/effects/fallback_aura_end/",
		"frame_prefix": "fallback_aura_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 3.0,
		"flip_by_facing": false,
		"modulate_color": "#f4fffb",
		"loop_animation": false
	}
}
const TOGGLE_VISUAL_FAMILIES := {
	"ice_glacial_dominion":
	{
		"activation_effect_id": "ice_frozen_domain_activation",
		"overlay_effect_id": "ice_frozen_domain_loop",
		"end_effect_id": "ice_frozen_domain_end",
		"activation_scale": 1.0,
		"overlay_scale": 1.0,
		"end_scale": 1.0,
		"color": "#dffaff"
	},
	"lightning_tempest_crown":
	{
		"activation_effect_id": "tempest_crown_activation",
		"overlay_effect_id": "tempest_crown_loop",
		"end_effect_id": "tempest_crown_end",
		"activation_scale": 1.0,
		"overlay_scale": 1.0,
		"end_scale": 1.0,
		"color": "#fff0a8"
	},
	"earth_fortress":
	{
		"activation_effect_id": "earth_fortress_activation",
		"overlay_effect_id": "earth_fortress_loop",
		"end_effect_id": "earth_fortress_end",
		"activation_scale": 1.0,
		"overlay_scale": 1.0,
		"end_scale": 1.0,
		"color": "#d7bf96"
	},
	"wind_storm_zone":
	{
		"activation_effect_id": "storm_zone_activation",
		"overlay_effect_id": "storm_zone_loop",
		"end_effect_id": "storm_zone_end",
		"activation_scale": 1.0,
		"overlay_scale": 1.0,
		"end_scale": 1.0,
		"color": "#d8ffe2"
	},
	"holy_seraph_chorus":
	{
		"activation_effect_id": "seraph_chorus_activation",
		"overlay_effect_id": "seraph_chorus_loop",
		"end_effect_id": "seraph_chorus_end",
		"activation_scale": 1.0,
		"overlay_scale": 1.0,
		"end_scale": 1.0,
		"color": "#fff2c2"
	},
	"dark_soul_dominion":
	{
		"signature_key": "dark_soul_dominion",
		"activation_effect_id": "soul_dominion_activation",
		"overlay_effect_id": "soul_dominion_loop",
		"end_effect_id": "soul_dominion_end",
		"aftershock_effect_id": "soul_dominion_aftershock",
		"clear_effect_id": "soul_dominion_clear",
		"activation_scale": 1.12,
		"overlay_scale": 1.18,
		"end_scale": 1.10,
		"aftershock_scale": 1.26,
		"clear_scale": 1.04,
		"color": "#b694ff",
		"activation_color": "#ceb3ff",
		"overlay_color": "#be97ff",
		"end_color": "#ece1ff",
		"aftershock_color": "#f2e9ff",
		"clear_color": "#d9e4ff",
		"aftershock_signature_key": "dark_soul_dominion_aftershock",
		"clear_signature_key": "dark_soul_dominion_clear"
	},
	"dark_grave_echo":
	{
		"signature_key": "dark_grave_echo",
		"activation_effect_id": "grave_echo_activation",
		"overlay_effect_id": "grave_echo_loop",
		"end_effect_id": "grave_echo_end",
		"activation_scale": 0.96,
		"overlay_scale": 1.00,
		"end_scale": 0.98,
		"color": "#9a82c7",
		"activation_color": "#9f86cc",
		"overlay_color": "#b9a7d8",
		"end_color": "#d8cbe7"
	},
	"wind_sky_dominion":
	{
		"signature_key": "wind_sky_dominion",
		"activation_effect_id": "sky_dominion_activation",
		"overlay_effect_id": "sky_dominion_loop",
		"end_effect_id": "sky_dominion_end",
		"activation_scale": 1.12,
		"overlay_scale": 1.16,
		"end_scale": 1.1,
		"color": "#edfff8",
		"activation_color": "#effffb",
		"overlay_color": "#edfff8",
		"end_color": "#d8fff1"
	}
}
const TOGGLE_VISUAL_PRIORITY := {
	"ice_glacial_dominion": 1,
	"earth_fortress": 2,
	"wind_storm_zone": 3,
	"lightning_tempest_crown": 4,
	"holy_seraph_chorus": 5,
	"dark_grave_echo": 6,
	"wind_sky_dominion": 7,
	"dark_soul_dominion": 8
}

var facing := 1
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var dash_timer := 0.0
var dash_cooldown := 0.0
var buff_mobility_timer := 0.0
var buff_mobility_speed := 0.0
var invuln_timer := 0.0
var hit_stun_timer := 0.0
var cast_lock_timer := 0.0
var jump_count := 0
var state_name := "Idle"
var is_dead := false
var current_interactable: Node = null
var nearby_interactables: Array = []
var current_rope = null
var nearby_ropes: Array = []
var current_floor_platform = null
var drop_through_platform = null
var drop_through_timer := 0.0
var spell_manager = null
var state_chart = null
var _sc_root = null
var _cam_shake_timer := 0.0
var _cam_shake_intensity := 0.0
var player_slow_timer := 0.0
var player_slow_multiplier := 1.0
var _room_shift_edge_lock := 0

@onready var body_polygon: Polygon2D = get_node_or_null("Body") as Polygon2D
# SPRITE DIRECTION: native facing = RIGHT (detected by analyzer)
# sprite.scale.x = 1.0 → faces RIGHT, sprite.scale.x = -1.0 → faces LEFT
# @onready set after editor import: var sprite: AnimatedSprite2D = $Sprite
var sprite: AnimatedSprite2D = null
var buff_visual_layer: Node2D = null
var toggle_visual_layer: Node2D = null
var active_toggle_visuals: Dictionary = {}
var _soul_dominion_aftershock_visual_played := false
var _soul_dominion_clear_visual_played := false


func _get_effective_gravity() -> float:
	return gravity * GameState.get_player_gravity_multiplier()


func _get_effective_jump_velocity() -> float:
	return JUMP_VELOCITY * GameState.get_player_jump_velocity_multiplier()


func _get_effective_max_jumps() -> int:
	return MAX_JUMPS + GameState.get_player_air_jump_bonus()


func _ready() -> void:
	add_to_group("player")
	spell_manager = preload("res://scripts/player/spell_manager.gd").new()
	spell_manager.setup(self)
	spell_manager.spell_cast.connect(_on_spell_cast)
	if not GameState.player_died.is_connected(_on_player_died):
		GameState.player_died.connect(_on_player_died)
	_build_player_state_chart()
	if has_node("Sprite"):
		sprite = $Sprite
	_ensure_buff_visual_layer()
	_ensure_toggle_visual_layer()


func _build_player_state_chart() -> void:
	state_chart = StateChartScript.new()
	state_chart.name = "PlayerStateChart"
	_sc_root = CompoundStateScript.new()
	_sc_root.name = "Root"
	state_chart.add_child(_sc_root)

	var sc_idle := _add_player_state("Idle")
	var sc_walk := _add_player_state("Walk")
	var sc_jump := _add_player_state("Jump")
	var sc_double_jump := _add_player_state("DoubleJump")
	var sc_fall := _add_player_state("Fall")
	var sc_dash := _add_player_state("Dash")
	var sc_cast := _add_player_state("Cast")
	var sc_hit := _add_player_state("Hit")
	var sc_dead := _add_player_state("Dead")
	var sc_on_rope := _add_player_state("OnRope")

	sc_idle.state_entered.connect(func() -> void: state_name = "Idle")
	sc_walk.state_entered.connect(func() -> void: state_name = "Walk")
	sc_jump.state_entered.connect(func() -> void: state_name = "Jump")
	sc_double_jump.state_entered.connect(func() -> void: state_name = "DoubleJump")
	sc_fall.state_entered.connect(func() -> void: state_name = "Fall")
	sc_dash.state_entered.connect(func() -> void: state_name = "Dash")
	sc_cast.state_entered.connect(func() -> void: state_name = "Cast")
	sc_hit.state_entered.connect(func() -> void: state_name = "Hit")
	sc_dead.state_entered.connect(func() -> void: state_name = "Dead")
	sc_on_rope.state_entered.connect(func() -> void: state_name = "OnRope")

	# player_died: any locomotion state → Dead
	for from in [
		sc_idle, sc_walk, sc_jump, sc_double_jump, sc_fall, sc_dash, sc_cast, sc_hit, sc_on_rope
	]:
		_add_player_transition(from, sc_dead, "player_died")
	# revived: Dead → Idle
	_add_player_transition(sc_dead, sc_idle, "revived")

	# hit_taken: non-dead states → Hit
	for from in [sc_idle, sc_walk, sc_jump, sc_double_jump, sc_fall, sc_cast, sc_dash]:
		_add_player_transition(from, sc_hit, "hit_taken")
	# hit_recovered: Hit → Idle
	_add_player_transition(sc_hit, sc_idle, "hit_recovered")

	# dash_start / dash_end
	for from in [sc_idle, sc_walk, sc_jump, sc_double_jump, sc_fall, sc_hit]:
		_add_player_transition(from, sc_dash, "dash_start")
	_add_player_transition(sc_dash, sc_idle, "dash_end")

	# jump / double_jump / peak / land
	for from in [sc_idle, sc_walk, sc_hit, sc_fall]:
		_add_player_transition(from, sc_jump, "jumped")
	for from in [sc_jump, sc_fall, sc_hit]:
		_add_player_transition(from, sc_double_jump, "double_jumped")
	_add_player_transition(sc_jump, sc_fall, "peaked")
	_add_player_transition(sc_double_jump, sc_fall, "peaked")
	for from in [sc_jump, sc_double_jump, sc_fall, sc_dash]:
		_add_player_transition(from, sc_idle, "landed")

	# walk / idle
	_add_player_transition(sc_idle, sc_walk, "started_walking")
	_add_player_transition(sc_walk, sc_idle, "stopped_walking")

	# cast_start / cast_end
	for from in [sc_idle, sc_walk, sc_jump, sc_double_jump, sc_fall]:
		_add_player_transition(from, sc_cast, "cast_start")
	_add_player_transition(sc_cast, sc_idle, "cast_end")

	# rope_grabbed / rope_released
	for from in [sc_idle, sc_walk, sc_jump, sc_double_jump, sc_fall, sc_hit]:
		_add_player_transition(from, sc_on_rope, "rope_grabbed")
	_add_player_transition(sc_on_rope, sc_fall, "rope_released")

	add_child(state_chart)


func _add_player_state(state_label: String) -> Object:
	var st := AtomicStateScript.new()
	st.name = state_label
	_sc_root.add_child(st)
	if _sc_root.initial_state.is_empty():
		_sc_root.initial_state = _sc_root.get_path_to(st)
	return st


func _add_player_transition(from_state: Object, to_state: Object, event: String) -> void:
	var t := TransitionScript.new()
	t.name = "%s_to_%s" % [from_state.name, to_state.name]
	from_state.add_child(t)
	t.to = t.get_path_to(to_state)
	t.event = event


func _sc_send(event: String) -> void:
	if state_chart and is_node_ready():
		state_chart.send_event(event)


func _physics_process(delta: float) -> void:
	var was_on_floor := is_on_floor()
	_tick_timers(delta)
	_sync_special_toggle_aftermath_visuals()
	if is_dead:
		velocity.x = move_toward(velocity.x, 0.0, 1800.0 * delta)
		if not is_on_floor():
			velocity.y += _get_effective_gravity() * delta
		move_and_slide()
		_refresh_current_floor_platform()
		_update_state_name(move_axis_from_velocity())
		_update_visual()
		return
	if state_name == "OnRope":
		_handle_rope_physics()
		move_and_slide()
		_refresh_current_floor_platform()
		_update_visual()
		return
	var move_axis := Input.get_axis("move_left", "move_right")
	var move_speed := SPEED * GameState.get_player_move_multiplier() * player_slow_multiplier
	if move_axis != 0:
		facing = 1 if move_axis > 0 else -1
	if dash_timer > 0.0:
		velocity.x = DASH_SPEED * GameState.get_player_move_multiplier() * facing
	elif buff_mobility_timer > 0.0:
		velocity.x = buff_mobility_speed * GameState.get_player_move_multiplier() * facing
	elif hit_stun_timer > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, 2200.0 * delta)
	else:
		velocity.x = move_axis * move_speed
		if Input.is_action_just_pressed("dash"):
			_begin_dash()
		if Input.is_action_just_pressed("jump"):
			var wants_drop_through := Input.is_action_pressed("move_down")
			if not _try_platform_drop_through(was_on_floor, wants_drop_through):
				_try_jump(was_on_floor)
	var grounded_for_movement := is_on_floor() and not _is_platform_drop_through_active()
	if not grounded_for_movement:
		velocity.y += _get_effective_gravity() * delta
	else:
		if not was_on_floor:
			_on_landed()
		velocity.y = min(velocity.y, 50.0)
	if hit_stun_timer <= 0.0:
		_handle_spell_input()
		if _get_valid_rope() != null and Input.is_action_just_pressed("move_up"):
			_try_grab_rope()
	move_and_slide()
	_refresh_current_floor_platform()
	if is_on_floor() and not was_on_floor and not _is_platform_drop_through_active():
		_on_landed()
	_update_state_name(move_axis)
	_update_visual()
	_check_room_edges()
	if Input.is_action_just_pressed("interact"):
		_try_interact()


func _try_platform_drop_through(was_on_floor: bool, down_pressed: bool) -> bool:
	if not _can_start_platform_drop_through(was_on_floor, down_pressed):
		return false
	var platform = _get_current_floor_platform()
	if platform == null:
		return false
	_begin_platform_drop_through(platform)
	return true


func _can_start_platform_drop_through(was_on_floor: bool, down_pressed: bool) -> bool:
	if is_dead or hit_stun_timer > 0.0:
		return false
	if _is_platform_drop_through_active():
		return false
	if state_name == "OnRope":
		return false
	if not was_on_floor or not down_pressed:
		return false
	return true


func _begin_platform_drop_through(platform) -> void:
	_clear_platform_drop_through()
	if platform == null or not is_instance_valid(platform):
		return
	drop_through_platform = platform
	drop_through_timer = PLATFORM_DROP_THROUGH_TIME
	add_collision_exception_with(platform)
	current_floor_platform = null
	velocity.y = maxf(velocity.y, PLATFORM_DROP_THROUGH_FALL_SPEED)
	state_name = "Fall"


func _is_platform_drop_through_active() -> bool:
	return drop_through_platform != null and is_instance_valid(drop_through_platform)


func _clear_platform_drop_through() -> void:
	if drop_through_platform != null and is_instance_valid(drop_through_platform):
		remove_collision_exception_with(drop_through_platform)
	drop_through_platform = null
	drop_through_timer = 0.0


func _tick_platform_drop_through(delta: float) -> void:
	if drop_through_platform == null:
		drop_through_timer = 0.0
		return
	if not is_instance_valid(drop_through_platform):
		drop_through_platform = null
		drop_through_timer = 0.0
		return
	drop_through_timer = maxf(drop_through_timer - delta, 0.0)
	if drop_through_timer <= 0.0:
		_clear_platform_drop_through()


func _refresh_current_floor_platform() -> void:
	current_floor_platform = null
	if not is_on_floor():
		return
	for collision_index in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(collision_index)
		if collision == null:
			continue
		var collider = collision.get_collider()
		if not _is_one_way_platform_body(collider):
			continue
		var collision_normal: Vector2 = collision.get_normal()
		if collision_normal.dot(Vector2.UP) >= 0.7:
			current_floor_platform = collider
			return


func _get_current_floor_platform():
	if _is_one_way_platform_body(current_floor_platform):
		return current_floor_platform
	current_floor_platform = null
	return null


func _is_one_way_platform_body(body) -> bool:
	return (
		body != null
		and is_instance_valid(body)
		and str(body.get_meta("collision_kind", "")) == "one_way_platform"
	)


func receive_hit(
	amount: int, source: Vector2, knockback: float, school: String = "", utility_effects: Array = []
) -> void:
	if invuln_timer > 0.0 or is_dead:
		return
	invuln_timer = IFRAME_TIME
	if GameState.get_super_armor_charges() > 0:
		GameState.damage(amount, school)
		return
	var stagger_mult: float = GameState.get_stagger_taken_multiplier()
	var poise_reduction: float = clampf(GameState.get_poise_bonus() * 0.01, 0.0, 0.6)
	hit_stun_timer = HIT_STUN_TIME * (1.0 - poise_reduction) * stagger_mult
	var push_dir: float = sign(global_position.x - source.x)
	if push_dir == 0:
		push_dir = -facing
	velocity = Vector2(push_dir * knockback * stagger_mult, -240.0)
	GameState.damage(amount, school)
	if _is_screen_shake_allowed():
		_cam_shake_timer = 0.3
		_cam_shake_intensity = 8.0
	else:
		_cam_shake_timer = 0.0
		_cam_shake_intensity = 0.0
	_apply_player_utility_effects(utility_effects)
	_sc_send("hit_taken")


func register_interactable(target: Node) -> void:
	if target == null or not is_instance_valid(target):
		return
	nearby_interactables.erase(target)
	nearby_interactables.append(target)
	current_interactable = target


func unregister_interactable(target: Node) -> void:
	nearby_interactables.erase(target)
	_refresh_current_interactable()


func _try_interact() -> bool:
	var interactable := _get_valid_interactable()
	if interactable == null or not interactable.has_method("interact"):
		return false
	interactable.interact(self)
	return true


func _get_valid_interactable() -> Node:
	_prune_invalid_interactables()
	if (
		current_interactable != null
		and is_instance_valid(current_interactable)
		and nearby_interactables.has(current_interactable)
	):
		return current_interactable
	_refresh_current_interactable()
	return current_interactable


func _refresh_current_interactable() -> void:
	_prune_invalid_interactables()
	current_interactable = (
		nearby_interactables.back() if not nearby_interactables.is_empty() else null
	)


func _prune_invalid_interactables() -> void:
	for i in range(nearby_interactables.size() - 1, -1, -1):
		var candidate = nearby_interactables[i]
		if candidate == null or not is_instance_valid(candidate):
			nearby_interactables.remove_at(i)


func register_rope(rope: Node) -> void:
	if rope == null or not is_instance_valid(rope):
		return
	nearby_ropes.erase(rope)
	nearby_ropes.append(rope)
	current_rope = rope


func unregister_rope(rope: Node) -> void:
	var was_current: bool = current_rope == rope
	nearby_ropes.erase(rope)
	_refresh_current_rope()
	if was_current and current_rope == null and state_name == "OnRope":
		_exit_rope()


func _try_grab_rope() -> bool:
	var rope := _get_valid_rope()
	if rope == null or state_name == "OnRope":
		return false
	if is_dead or hit_stun_timer > 0.0:
		return false
	current_rope = rope
	state_name = "OnRope"
	velocity = Vector2.ZERO
	_snap_to_rope_anchor()
	_sc_send("rope_grabbed")
	return true


func _exit_rope() -> void:
	if state_name != "OnRope":
		return
	_sc_send("rope_released")
	# state_name will be corrected by next _update_state_name() call


func _handle_rope_physics() -> void:
	var rope := _get_valid_rope()
	if rope == null:
		_exit_rope()
		return
	current_rope = rope
	_snap_to_rope_anchor()
	velocity.x = 0.0
	var vert_input := Input.get_axis("move_up", "move_down")
	velocity.y = vert_input * ROPE_CLIMB_SPEED
	# Jump exits rope with upward impulse
	if Input.is_action_just_pressed("jump"):
		velocity.y = _get_effective_jump_velocity()
		jump_count = 1
		_exit_rope()
		return
	# Dash exits rope
	if Input.is_action_just_pressed("dash"):
		_exit_rope()
		return
	# Rope bounds clamp
	var top_y := _get_rope_bound("rope_top_y", global_position.y)
	var bot_y := _get_rope_bound("rope_bottom_y", global_position.y)
	if global_position.y <= top_y:
		global_position.y = top_y
		velocity.y = max(velocity.y, 0.0)
		if vert_input < 0.0:
			_exit_rope()
	elif global_position.y >= bot_y:
		global_position.y = bot_y
		velocity.y = min(velocity.y, 0.0)


func _snap_to_rope_anchor() -> void:
	if current_rope == null or not is_instance_valid(current_rope):
		return
	if current_rope is Node2D:
		global_position.x = (current_rope as Node2D).global_position.x
	var rope_top := _get_rope_bound("rope_top_y", global_position.y)
	var rope_bottom := _get_rope_bound("rope_bottom_y", global_position.y)
	global_position.y = clampf(global_position.y, rope_top, rope_bottom)


func _get_rope_bound(key: String, fallback: float) -> float:
	var rope := _get_valid_rope()
	if rope == null:
		return fallback
	if rope.has_meta(key):
		return float(rope.get_meta(key))
	var value = rope.get(key)
	if value == null:
		return fallback
	return float(value)


func _get_valid_rope() -> Node:
	_prune_invalid_ropes()
	if current_rope != null and is_instance_valid(current_rope) and nearby_ropes.has(current_rope):
		return current_rope
	_refresh_current_rope()
	return current_rope


func _refresh_current_rope() -> void:
	_prune_invalid_ropes()
	current_rope = nearby_ropes.back() if not nearby_ropes.is_empty() else null


func _prune_invalid_ropes() -> void:
	for i in range(nearby_ropes.size() - 1, -1, -1):
		var candidate = nearby_ropes[i]
		if candidate == null or not is_instance_valid(candidate):
			nearby_ropes.remove_at(i)


func reset_at(position_value: Vector2) -> void:
	_clear_platform_drop_through()
	global_position = position_value
	velocity = Vector2.ZERO
	jump_count = 0
	is_dead = false
	state_name = "Idle"
	dash_timer = 0.0
	dash_cooldown = 0.0
	invuln_timer = 0.0
	hit_stun_timer = 0.0
	cast_lock_timer = 0.0
	player_slow_timer = 0.0
	player_slow_multiplier = 1.0
	_room_shift_edge_lock = 0
	nearby_interactables.clear()
	nearby_ropes.clear()
	current_floor_platform = null
	current_rope = null
	current_interactable = null
	_cam_shake_timer = 0.0
	_cam_shake_intensity = 0.0
	_sc_send("revived")
	if spell_manager != null:
		spell_manager = preload("res://scripts/player/spell_manager.gd").new()
		spell_manager.setup(self)
		spell_manager.spell_cast.connect(_on_spell_cast)
	_clear_buff_visuals()


func respawn_from_saved_route() -> Dictionary:
	var restore_data: Dictionary = GameState.restore_after_death()
	var spawn_position: Vector2 = restore_data.get("spawn_position", global_position)
	reset_at(spawn_position)
	return restore_data


func _handle_spell_input() -> void:
	if is_dead or hit_stun_timer > 0.0 or cast_lock_timer > 0.0:
		return
	spell_manager.handle_input()


func _on_spell_cast(payload: Dictionary) -> void:
	var suppress_cast_lock := bool(payload.get("suppress_cast_lock", false))
	if not suppress_cast_lock:
		cast_lock_timer = CAST_LOCK_TIME
	if (
		not suppress_cast_lock
		and str(payload.get("hitstop_mode", "")) == "area_burst"
		and _is_screen_shake_allowed()
	):
		_cam_shake_timer = max(_cam_shake_timer, 0.12)
		_cam_shake_intensity = max(_cam_shake_intensity, 5.0)
	cast_spell.emit(payload)
	if not suppress_cast_lock:
		_sc_send("cast_start")


func _tick_timers(delta: float) -> void:
	dash_timer = max(dash_timer - delta, 0.0)
	dash_cooldown = max(dash_cooldown - delta, 0.0)
	buff_mobility_timer = max(buff_mobility_timer - delta, 0.0)
	if buff_mobility_timer <= 0.0:
		buff_mobility_speed = 0.0
	invuln_timer = max(invuln_timer - delta, 0.0)
	hit_stun_timer = max(hit_stun_timer - delta, 0.0)
	cast_lock_timer = max(cast_lock_timer - delta, 0.0)
	player_slow_timer = max(player_slow_timer - delta, 0.0)
	if player_slow_timer <= 0.0:
		player_slow_multiplier = 1.0
	_tick_platform_drop_through(delta)
	if spell_manager != null:
		spell_manager.tick(delta)
	if not _is_screen_shake_allowed():
		_cam_shake_timer = 0.0
		_cam_shake_intensity = 0.0
		var disabled_cam: Camera2D = get_node_or_null("Camera2D")
		if disabled_cam != null:
			disabled_cam.offset = Vector2.ZERO
	elif _cam_shake_timer > 0.0:
		_cam_shake_timer = max(_cam_shake_timer - delta, 0.0)
		var cam: Camera2D = get_node_or_null("Camera2D")
		if cam != null:
			if _cam_shake_timer > 0.0:
				var s := _cam_shake_intensity * (_cam_shake_timer / 0.3)
				cam.offset = Vector2(randf_range(-s, s), randf_range(-s, s))
			else:
				cam.offset = Vector2.ZERO


func _update_visual() -> void:
	if body_polygon != null:
		body_polygon.scale.x = facing
		body_polygon.color = (
			Color("#e9f0ff")
			if invuln_timer <= 0.0 or int(Time.get_ticks_msec() / 60) % 2 == 0
			else Color("#6b778d")
		)
	if sprite != null:
		_update_anim()
	_sync_buff_overlay_visual()
	_sync_toggle_overlay_visual()


func on_buff_activated(skill_id: String) -> void:
	_spawn_buff_activation_visual(skill_id)
	_apply_buff_activation_mobility(skill_id)
	_sync_buff_overlay_visual()

func on_active_skill_cast_started(skill_id: String, runtime: Dictionary = {}) -> void:
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	if skill_data.is_empty() or str(skill_data.get("skill_type", "")) != "active":
		return
	_spawn_active_cast_visual(skill_id)
	_apply_active_cast_mobility(skill_id, runtime)

func on_toggle_activated(skill_id: String) -> void:
	if not TOGGLE_VISUAL_FAMILIES.has(skill_id):
		return
	active_toggle_visuals[skill_id] = true
	_spawn_toggle_transition_visual(skill_id, "activation")
	_sync_toggle_overlay_visual()

func on_toggle_deactivated(skill_id: String) -> void:
	active_toggle_visuals.erase(skill_id)
	_spawn_toggle_transition_visual(skill_id, "end")
	_sync_toggle_overlay_visual()


func _ensure_buff_visual_layer() -> void:
	if buff_visual_layer != null and is_instance_valid(buff_visual_layer):
		return
	buff_visual_layer = get_node_or_null("BuffVisualLayer") as Node2D
	if buff_visual_layer == null:
		buff_visual_layer = Node2D.new()
		buff_visual_layer.name = "BuffVisualLayer"
		add_child(buff_visual_layer)

func _ensure_toggle_visual_layer() -> void:
	if toggle_visual_layer != null and is_instance_valid(toggle_visual_layer):
		return
	toggle_visual_layer = get_node_or_null("ToggleVisualLayer") as Node2D
	if toggle_visual_layer == null:
		toggle_visual_layer = Node2D.new()
		toggle_visual_layer.name = "ToggleVisualLayer"
		add_child(toggle_visual_layer)


func _clear_buff_visuals() -> void:
	_ensure_buff_visual_layer()
	for child in buff_visual_layer.get_children():
		child.queue_free()


func _spawn_buff_activation_visual(skill_id: String) -> void:
	var effect_id := _get_skill_buff_visual_string(skill_id, "activation_visual_effect_id")
	if effect_id.is_empty():
		return
	var sprite := _create_buff_visual_sprite(
		effect_id,
		_get_skill_buff_visual_float(skill_id, "activation_visual_scale", 1.0),
		_get_skill_buff_visual_color(skill_id, "activation_visual_color", Color.WHITE)
	)
	if sprite == null:
		return
	var host: Node = get_parent() if get_parent() != null else self
	sprite.name = "%s_sprite" % effect_id
	sprite.set_meta("effect_id", effect_id)
	sprite.set_meta("effect_stage", "buff_activation")
	sprite.set_meta("skill_id", skill_id)
	host.add_child(sprite)
	sprite.global_position = global_position + Vector2(0, -12)
	sprite.play("fly")
	sprite.animation_finished.connect(
		func() -> void:
			if is_instance_valid(sprite):
				sprite.queue_free(),
		CONNECT_ONE_SHOT
	)

func _spawn_active_cast_visual(skill_id: String) -> void:
	var effect_id := _get_skill_runtime_support_string(
		skill_id,
		"activation_visual_effect_id",
		"activation_visual_effect_id"
	)
	if effect_id.is_empty():
		return
	var sprite := _create_buff_visual_sprite(
		effect_id,
		_get_skill_runtime_support_float(skill_id, "activation_visual_scale", "activation_visual_scale", 1.0),
		_get_skill_runtime_support_color(skill_id, "activation_visual_color", "activation_visual_color", Color.WHITE)
	)
	if sprite == null:
		return
	var host: Node = get_parent() if get_parent() != null else self
	sprite.name = "%s_sprite" % effect_id
	sprite.set_meta("effect_id", effect_id)
	sprite.set_meta("effect_stage", "active_activation")
	sprite.set_meta("skill_id", skill_id)
	host.add_child(sprite)
	sprite.global_position = global_position + Vector2(0, -12)
	sprite.play("fly")
	sprite.animation_finished.connect(
		func() -> void:
			if is_instance_valid(sprite):
				sprite.queue_free(),
		CONNECT_ONE_SHOT
	)

func _spawn_toggle_transition_visual(skill_id: String, transition_kind: String) -> void:
	var family: Dictionary = TOGGLE_VISUAL_FAMILIES.get(skill_id, {})
	if family.is_empty():
		return
	var effect_key := "%s_effect_id" % transition_kind
	var effect_id := str(family.get(effect_key, ""))
	if effect_id.is_empty():
		return
	var signature := _get_toggle_visual_signature(skill_id, family, transition_kind)
	var stage_scale := _get_toggle_visual_stage_scale(family, transition_kind, 1.0)
	var stage_color := _get_toggle_visual_stage_color(family, transition_kind)
	var sprite := _create_toggle_visual_sprite(
		effect_id,
		stage_scale,
		stage_color
	)
	if sprite == null:
		return
	var host: Node = get_parent() if get_parent() != null else self
	sprite.name = "%s_sprite" % effect_id
	sprite.set_meta("effect_id", effect_id)
	sprite.set_meta("effect_stage", "toggle_%s" % transition_kind)
	sprite.set_meta("skill_id", skill_id)
	sprite.set_meta("visual_signature", signature)
	sprite.set_meta("visual_stage", transition_kind)
	sprite.set_meta("visual_stage_scale", stage_scale)
	sprite.set_meta("visual_stage_color", stage_color.to_html(false))
	host.add_child(sprite)
	sprite.global_position = global_position + Vector2(0, -10)
	sprite.play("fly")
	sprite.animation_finished.connect(
		func() -> void:
			if is_instance_valid(sprite):
				sprite.queue_free(),
		CONNECT_ONE_SHOT
	)


func _sync_special_toggle_aftermath_visuals() -> void:
	if GameState.soul_dominion_active:
		_soul_dominion_aftershock_visual_played = false
		_soul_dominion_clear_visual_played = false
		return
	var soul_aftershock_active := (
		GameState.soul_dominion_aftershock_timer > 0.0 and not GameState.soul_dominion_active
	)
	if soul_aftershock_active:
		if not _soul_dominion_aftershock_visual_played:
			_spawn_toggle_transition_visual("dark_soul_dominion", "aftershock")
			_soul_dominion_aftershock_visual_played = true
		_soul_dominion_clear_visual_played = false
		return
	if _soul_dominion_aftershock_visual_played and not _soul_dominion_clear_visual_played:
		_spawn_toggle_transition_visual("dark_soul_dominion", "clear")
		_soul_dominion_clear_visual_played = true
	_soul_dominion_aftershock_visual_played = false


func _sync_buff_overlay_visual() -> void:
	_ensure_buff_visual_layer()
	var desired := _get_active_buff_overlay_visual()
	var existing := buff_visual_layer.get_node_or_null("BuffOverlaySprite") as AnimatedSprite2D
	if desired.is_empty():
		if existing != null:
			existing.queue_free()
		return
	var desired_effect_id := str(desired.get("effect_id", ""))
	var desired_skill_id := str(desired.get("skill_id", ""))
	var desired_scale := float(desired.get("scale", 1.0))
	var desired_color := _apply_effect_opacity(Color(str(desired.get("color", "#ffffff"))))
	if existing != null and str(existing.get_meta("effect_id", "")) == desired_effect_id:
		existing.scale = Vector2(desired_scale, desired_scale)
		existing.modulate = desired_color
		existing.set_meta("skill_id", desired_skill_id)
		return
	if existing != null:
		existing.name = "BuffOverlaySprite_Stale"
		existing.queue_free()
	var sprite := _create_buff_visual_sprite(desired_effect_id, desired_scale, desired_color)
	if sprite == null:
		return
	sprite.name = "BuffOverlaySprite"
	sprite.set_meta("effect_id", desired_effect_id)
	sprite.set_meta("effect_stage", "buff_overlay")
	sprite.set_meta("skill_id", desired_skill_id)
	buff_visual_layer.add_child(sprite)
	sprite.position = Vector2(0, -12)
	sprite.play("fly")

func _sync_toggle_overlay_visual() -> void:
	_ensure_toggle_visual_layer()
	var desired := _get_active_toggle_overlay_visual()
	var existing := toggle_visual_layer.get_node_or_null("ToggleOverlaySprite") as AnimatedSprite2D
	if desired.is_empty():
		if existing != null:
			existing.queue_free()
		return
	var desired_effect_id := str(desired.get("effect_id", ""))
	var desired_skill_id := str(desired.get("skill_id", ""))
	var desired_scale := float(desired.get("scale", 1.0))
	var desired_color := _apply_effect_opacity(Color(str(desired.get("color", "#ffffff"))))
	var desired_signature := str(desired.get("visual_signature", desired_skill_id))
	if existing != null and str(existing.get_meta("effect_id", "")) == desired_effect_id:
		existing.scale = Vector2(desired_scale, desired_scale)
		existing.modulate = desired_color
		existing.set_meta("skill_id", desired_skill_id)
		existing.set_meta("visual_signature", desired_signature)
		existing.set_meta("visual_stage", "overlay")
		existing.set_meta("visual_stage_scale", desired_scale)
		existing.set_meta("visual_stage_color", desired_color.to_html(false))
		return
	if existing != null:
		existing.name = "ToggleOverlaySprite_Stale"
		existing.queue_free()
	var sprite := _create_toggle_visual_sprite(desired_effect_id, desired_scale, desired_color)
	if sprite == null:
		return
	sprite.name = "ToggleOverlaySprite"
	sprite.set_meta("effect_id", desired_effect_id)
	sprite.set_meta("effect_stage", "toggle_overlay")
	sprite.set_meta("skill_id", desired_skill_id)
	sprite.set_meta("visual_signature", desired_signature)
	sprite.set_meta("visual_stage", "overlay")
	sprite.set_meta("visual_stage_scale", desired_scale)
	sprite.set_meta("visual_stage_color", desired_color.to_html(false))
	toggle_visual_layer.add_child(sprite)
	sprite.position = Vector2(0, -10)
	sprite.play("fly")


func _get_active_buff_overlay_visual() -> Dictionary:
	var best: Dictionary = {}
	var best_priority := -1
	for raw_buff in GameState.active_buffs:
		if typeof(raw_buff) != TYPE_DICTIONARY:
			continue
		var buff: Dictionary = raw_buff
		var skill_id := str(buff.get("skill_id", ""))
		var effect_id := _get_buff_effect_string(buff, "overlay_visual_effect_id")
		if effect_id.is_empty():
			continue
		var priority := int(BUFF_VISUAL_PRIORITY.get(skill_id, 0))
		if priority < best_priority:
			continue
		best_priority = priority
		best = {
			"skill_id": skill_id,
			"effect_id": effect_id,
			"scale": _get_buff_effect_float(buff, "overlay_visual_scale", 1.0),
			"color": _get_buff_effect_string(buff, "overlay_visual_color", "#ffffff")
		}
	return best

func _get_active_toggle_overlay_visual() -> Dictionary:
	var best: Dictionary = {}
	var best_priority := -1
	for skill_id in active_toggle_visuals.keys():
		var family: Dictionary = TOGGLE_VISUAL_FAMILIES.get(str(skill_id), {})
		if family.is_empty():
			continue
		var effect_id := str(family.get("overlay_effect_id", ""))
		if effect_id.is_empty():
			continue
		var priority := int(TOGGLE_VISUAL_PRIORITY.get(str(skill_id), 0))
		if priority < best_priority:
			continue
		best_priority = priority
		var overlay_scale := _get_toggle_visual_stage_scale(family, "overlay", 1.0)
		var overlay_color := _get_toggle_visual_stage_color(family, "overlay")
		best = {
			"skill_id": str(skill_id),
			"effect_id": effect_id,
			"scale": overlay_scale,
			"color": overlay_color.to_html(false),
			"visual_signature": _get_toggle_visual_signature(str(skill_id), family, "overlay")
		}
	return best


func _get_toggle_visual_signature(
	skill_id: String, family: Dictionary, transition_kind: String = ""
) -> String:
	var specific_key := ""
	if not transition_kind.is_empty():
		specific_key = str(family.get("%s_signature_key" % transition_kind, "")).strip_edges()
	if not specific_key.is_empty():
		return specific_key
	var signature := str(family.get("signature_key", skill_id)).strip_edges()
	if signature.is_empty():
		return skill_id
	return signature


func _get_toggle_visual_stage_scale(
	family: Dictionary, transition_kind: String, fallback: float
) -> float:
	return float(family.get("%s_scale" % transition_kind, fallback))


func _get_toggle_visual_stage_color(family: Dictionary, transition_kind: String) -> Color:
	var fallback := str(family.get("color", "#ffffff"))
	return Color(str(family.get("%s_color" % transition_kind, fallback)))


func _get_skill_buff_visual_string(skill_id: String, stat_name: String, fallback: String = "") -> String:
	var effect := _find_skill_buff_effect(skill_id, stat_name)
	if effect.is_empty():
		return fallback
	return str(effect.get("value", fallback)).strip_edges()


func _get_skill_buff_visual_float(skill_id: String, stat_name: String, fallback: float) -> float:
	var effect := _find_skill_buff_effect(skill_id, stat_name)
	if effect.is_empty():
		return fallback
	return float(effect.get("value", fallback))


func _get_skill_buff_visual_color(skill_id: String, stat_name: String, fallback: Color) -> Color:
	return Color(_get_skill_buff_visual_string(skill_id, stat_name, fallback.to_html()))

func _get_skill_runtime_support_string(
	skill_id: String, field_name: String, fallback_buff_stat: String = "", fallback: String = ""
) -> String:
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	var direct_value := str(skill_data.get(field_name, "")).strip_edges()
	if not direct_value.is_empty():
		return direct_value
	if fallback_buff_stat.is_empty():
		return fallback
	return _get_skill_buff_visual_string(skill_id, fallback_buff_stat, fallback)

func _get_skill_runtime_support_float(
	skill_id: String, field_name: String, fallback_buff_stat: String = "", fallback: float = 0.0
) -> float:
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	if skill_data.has(field_name):
		return float(skill_data.get(field_name, fallback))
	if fallback_buff_stat.is_empty():
		return fallback
	return _get_skill_buff_visual_float(skill_id, fallback_buff_stat, fallback)

func _get_skill_runtime_support_color(
	skill_id: String, field_name: String, fallback_buff_stat: String = "", fallback: Color = Color.WHITE
) -> Color:
	return Color(
		_get_skill_runtime_support_string(skill_id, field_name, fallback_buff_stat, fallback.to_html())
	)


func _apply_buff_activation_mobility(skill_id: String) -> void:
	if is_dead or state_name == "OnRope":
		return
	var dash_duration := _get_skill_buff_visual_float(skill_id, "activation_dash_duration", 0.0)
	var dash_speed := _get_skill_buff_visual_float(skill_id, "activation_dash_speed", 0.0)
	if dash_duration <= 0.0 or dash_speed <= 0.0:
		return
	buff_mobility_timer = max(buff_mobility_timer, dash_duration)
	buff_mobility_speed = dash_speed
	invuln_timer = max(invuln_timer, minf(dash_duration, 0.12))
	velocity.x = dash_speed * facing
	state_name = "Dash"
	_sc_send("dash_start")

func _apply_active_cast_mobility(skill_id: String, runtime: Dictionary = {}) -> void:
	if is_dead or state_name == "OnRope":
		return
	var dash_duration := float(runtime.get("dash_duration", -1.0))
	if dash_duration < 0.0:
		dash_duration = _get_skill_runtime_support_float(
			skill_id,
			"dash_duration_base",
			"activation_dash_duration",
			0.0
		)
	var dash_speed := float(runtime.get("dash_speed", -1.0))
	if dash_speed < 0.0:
		dash_speed = _get_skill_runtime_support_float(
			skill_id,
			"dash_speed_base",
			"activation_dash_speed",
			0.0
		)
	if dash_duration <= 0.0 or dash_speed <= 0.0:
		return
	buff_mobility_timer = max(buff_mobility_timer, dash_duration)
	buff_mobility_speed = dash_speed
	invuln_timer = max(invuln_timer, minf(dash_duration, 0.12))
	velocity.x = dash_speed * facing
	state_name = "Dash"
	_sc_send("dash_start")


func _find_skill_buff_effect(skill_id: String, stat_name: String) -> Dictionary:
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	for raw_effect in skill_data.get("buff_effects", []):
		if typeof(raw_effect) != TYPE_DICTIONARY:
			continue
		var effect: Dictionary = raw_effect
		if str(effect.get("stat", "")).strip_edges() == stat_name:
			return effect
	return {}


func _get_buff_effect_string(buff: Dictionary, stat_name: String, fallback: String = "") -> String:
	for raw_effect in buff.get("effects", []):
		if typeof(raw_effect) != TYPE_DICTIONARY:
			continue
		var effect: Dictionary = raw_effect
		if str(effect.get("stat", "")).strip_edges() == stat_name:
			return str(effect.get("value", fallback)).strip_edges()
	return fallback


func _get_buff_effect_float(buff: Dictionary, stat_name: String, fallback: float) -> float:
	for raw_effect in buff.get("effects", []):
		if typeof(raw_effect) != TYPE_DICTIONARY:
			continue
		var effect: Dictionary = raw_effect
		if str(effect.get("stat", "")).strip_edges() == stat_name:
			return float(effect.get("value", fallback))
	return fallback


func _create_buff_visual_sprite(
	effect_id: String, scale_multiplier: float = 1.0, modulate_color: Color = Color.WHITE
) -> AnimatedSprite2D:
	var spec: Dictionary = BUFF_VISUAL_SPECS.get(effect_id, {})
	if spec.is_empty():
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("fly")
	frames.set_animation_loop("fly", bool(spec.get("loop_animation", false)))
	frames.set_animation_speed("fly", float(spec.get("fps", 18.0)))
	for i in range(int(spec.get("frame_count", 0))):
		var tex := _load_texture_2d(
			"%s%s_%d.png" % [str(spec.get("dir_path", "")), str(spec.get("frame_prefix", "")), i]
		)
		if tex != null:
			frames.add_frame("fly", tex)
	if frames.get_frame_count("fly") == 0:
		return null
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var base_scale := float(spec.get("scale", 1.0)) * scale_multiplier
	var scale_x := base_scale
	if bool(spec.get("flip_by_facing", false)) and facing < 0:
		scale_x *= -1.0
	sprite.scale = Vector2(scale_x, base_scale)
	sprite.modulate = _apply_effect_opacity(modulate_color)
	sprite.animation = "fly"
	return sprite

func _create_toggle_visual_sprite(
	effect_id: String, scale_multiplier: float = 1.0, modulate_color: Color = Color.WHITE
) -> AnimatedSprite2D:
	var spec: Dictionary = TOGGLE_VISUAL_SPECS.get(effect_id, {})
	if spec.is_empty():
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("fly")
	frames.set_animation_loop("fly", bool(spec.get("loop_animation", false)))
	frames.set_animation_speed("fly", float(spec.get("fps", 18.0)))
	for i in range(int(spec.get("frame_count", 0))):
		var tex := _load_texture_2d(
			"%s%s_%d.png" % [str(spec.get("dir_path", "")), str(spec.get("frame_prefix", "")), i]
		)
		if tex != null:
			frames.add_frame("fly", tex)
	if frames.get_frame_count("fly") == 0:
		return null
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var base_scale := float(spec.get("scale", 1.0)) * scale_multiplier
	var scale_x := base_scale
	if bool(spec.get("flip_by_facing", false)) and facing < 0:
		scale_x *= -1.0
	sprite.scale = Vector2(scale_x, base_scale)
	sprite.modulate = _apply_effect_opacity(modulate_color)
	sprite.animation = "fly"
	return sprite


func _apply_effect_opacity(color: Color) -> Color:
	var adjusted := color
	if UiState != null:
		adjusted.a *= UiState.get_effect_opacity()
	return adjusted


func _is_screen_shake_allowed() -> bool:
	if UiState == null:
		return true
	return UiState.are_special_effects_enabled() and UiState.get_screen_shake_enabled()


func _load_texture_2d(texture_path: String) -> Texture2D:
	var local_path := ProjectSettings.globalize_path(texture_path)
	if FileAccess.file_exists(local_path):
		var image := Image.load_from_file(local_path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)
	var texture: Texture2D = ResourceLoader.load(texture_path, "Texture2D")
	if texture != null:
		return texture
	var image := Image.load_from_file(local_path)
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)


func _update_anim() -> void:
	if sprite == null:
		return
	sprite.scale.x = float(facing) * sprite.scale.y
	# iframe flicker: modulate alpha
	if invuln_timer > 0.0 and int(Time.get_ticks_msec() / 60) % 2 == 1:
		sprite.modulate = Color(1, 1, 1, 0.4)
	else:
		sprite.modulate = Color(1, 1, 1, 1)
	# animation selection
	var target_anim: String
	match state_name:
		"Dead":
			target_anim = "death"
		"Hit":
			target_anim = "hurt"
		"Dash":
			target_anim = "dash"
		"Jump", "DoubleJump":
			target_anim = "jump"
		"Fall":
			target_anim = "fall_loop"
		"Walk", "Run":
			target_anim = "run"
		_:
			target_anim = "idle"
	# Only call play() on transition to avoid restart mid-loop
	if sprite.animation != target_anim:
		sprite.play(target_anim)


func _check_room_edges() -> void:
	var next_direction := 0
	var room_width := _get_current_room_width()
	var right_edge_threshold := maxf(ROOM_SHIFT_LEFT_MARGIN, room_width - ROOM_SHIFT_RIGHT_MARGIN)
	if global_position.x > right_edge_threshold:
		next_direction = 1
	elif global_position.x < ROOM_SHIFT_LEFT_MARGIN:
		next_direction = -1
	if next_direction == 0:
		_room_shift_edge_lock = 0
		return
	if next_direction != _room_shift_edge_lock:
		_room_shift_edge_lock = next_direction
		request_room_shift.emit(next_direction)


func rearm_room_shift_edge() -> void:
	_room_shift_edge_lock = 0


func _get_current_room_width() -> float:
	var room_data: Dictionary = GameDatabase.get_room(GameState.current_room_id)
	return float(room_data.get("width", 1600.0))


func _try_jump(was_on_floor: bool) -> bool:
	if is_dead or hit_stun_timer > 0.0:
		return false
	if was_on_floor:
		jump_count = 0
	if jump_count >= _get_effective_max_jumps():
		return false
	jump_count += 1
	velocity.y = _get_effective_jump_velocity()
	if jump_count == 1:
		state_name = "Jump"
		_sc_send("jumped")
	else:
		state_name = "DoubleJump"
		_sc_send("double_jumped")
	return true


func _on_landed() -> void:
	jump_count = 0
	_sc_send("landed")


func _begin_dash() -> bool:
	if is_dead or hit_stun_timer > 0.0 or dash_cooldown > 0.0:
		return false
	dash_timer = DASH_TIME
	dash_cooldown = DASH_COOLDOWN
	invuln_timer = max(invuln_timer, DASH_TIME)
	velocity.x = DASH_SPEED * facing
	state_name = "Dash"
	_sc_send("dash_start")
	return true


func _update_state_name(move_axis: float) -> void:
	var prev := state_name
	if is_dead:
		state_name = "Dead"
	elif state_name == "OnRope":
		pass  # rope physics loop controls exit; state is managed by _exit_rope()
	elif hit_stun_timer > 0.0:
		state_name = "Hit"
	elif dash_timer > 0.0 or buff_mobility_timer > 0.0:
		state_name = "Dash"
	elif cast_lock_timer > 0.0:
		state_name = "Cast"
	elif not is_on_floor():
		if velocity.y < -20.0:
			state_name = "DoubleJump" if jump_count >= 2 else "Jump"
		else:
			state_name = "Fall"
	elif absf(move_axis) > 0.01:
		state_name = "Walk"
	else:
		state_name = "Idle"
	if state_chart and is_node_ready() and state_name != prev:
		_send_state_transition_event(prev, state_name)


func _send_state_transition_event(prev: String, next: String) -> void:
	match next:
		"Dead":
			state_chart.send_event("player_died")
		"Hit":
			state_chart.send_event("hit_taken")
		"Dash":
			state_chart.send_event("dash_start")
		"Cast":
			state_chart.send_event("cast_start")
		"Jump":
			state_chart.send_event("jumped")
		"DoubleJump":
			state_chart.send_event("double_jumped")
		"Fall":
			if prev in ["Jump", "DoubleJump"]:
				state_chart.send_event("peaked")
			elif prev == "OnRope":
				state_chart.send_event("rope_released")
		"OnRope":
			state_chart.send_event("rope_grabbed")
		"Walk":
			state_chart.send_event("started_walking")
		"Idle":
			if prev == "Walk":
				state_chart.send_event("stopped_walking")
			elif prev == "Hit":
				state_chart.send_event("hit_recovered")
			elif prev == "Dash":
				state_chart.send_event("dash_end")
			elif prev == "Cast":
				state_chart.send_event("cast_end")
			elif prev in ["Jump", "DoubleJump", "Fall"]:
				state_chart.send_event("landed")


func _apply_player_utility_effects(effects: Array) -> void:
	for effect in effects:
		var effect_data: Dictionary = effect
		match str(effect_data.get("type", "")):
			"slow":
				var slow_value: float = clampf(float(effect_data.get("value", 0.2)), 0.0, 0.9)
				player_slow_multiplier = min(player_slow_multiplier, 1.0 - slow_value)
				player_slow_timer = max(player_slow_timer, float(effect_data.get("duration", 0.8)))


func move_axis_from_velocity() -> float:
	if absf(velocity.x) <= 0.01:
		return 0.0
	return signf(velocity.x)


func get_debug_state_name() -> String:
	return state_name


func get_jump_count() -> int:
	return jump_count


func get_max_jump_count() -> int:
	return _get_effective_max_jumps()


func is_input_locked() -> bool:
	return is_dead or hit_stun_timer > 0.0


func can_cast_spell() -> bool:
	return not is_dead and hit_stun_timer <= 0.0 and cast_lock_timer <= 0.0


func get_hotbar_summary() -> String:
	if spell_manager == null:
		return "핫바 정보를 불러올 수 없음"
	return spell_manager.get_hotbar_summary()


func get_hotbar_mastery_summary() -> String:
	if spell_manager == null:
		return "스킬 정보를 불러올 수 없음"
	return spell_manager.get_hotbar_mastery_summary()


func get_visible_hotbar_bindings() -> Array:
	if spell_manager == null:
		return []
	return spell_manager.get_visible_slot_bindings()


func get_visible_hotbar_shortcuts() -> Array:
	return GameState.get_visible_hotbar_shortcuts()


func rebind_visible_hotbar_shortcut(slot_index: int, keycode: int) -> bool:
	return GameState.set_visible_hotbar_shortcut(slot_index, keycode)


func reset_visible_hotbar_shortcuts_to_default() -> void:
	GameState.reset_visible_hotbar_shortcuts_to_default()


func get_hotbar_slot_tooltip_data(slot_index: int) -> Dictionary:
	if spell_manager == null:
		return {}
	return spell_manager.get_hotbar_slot_tooltip_data(slot_index)


func clear_hotbar_slot(slot_index: int) -> bool:
	if spell_manager == null:
		return false
	return spell_manager.clear_slot(slot_index)


func assign_hotbar_skill(slot_index: int, skill_id: String) -> bool:
	if spell_manager == null:
		return false
	return spell_manager.assign_skill_to_slot(slot_index, skill_id)


func swap_hotbar_slots(first_index: int, second_index: int) -> bool:
	if spell_manager == null:
		return false
	return spell_manager.swap_slots(first_index, second_index)


func get_cast_feedback_summary() -> String:
	if spell_manager == null:
		return "시전 정보를 불러올 수 없음"
	return spell_manager.get_feedback_summary()


func get_toggle_summary() -> String:
	if spell_manager == null:
		return "토글 정보를 불러올 수 없음"
	return spell_manager.get_toggle_summary()


func debug_reset_spell_cooldowns() -> void:
	if spell_manager != null:
		spell_manager.reset_all_cooldowns()


func debug_try_jump(grounded: bool) -> bool:
	return _try_jump(grounded)


func debug_try_platform_drop_through(grounded: bool, down_pressed: bool) -> bool:
	return _try_platform_drop_through(grounded, down_pressed)


func debug_begin_dash() -> bool:
	return _begin_dash()


func debug_advance_timers(delta: float) -> void:
	_tick_timers(delta)
	_update_state_name(move_axis_from_velocity())


func debug_apply_air_gravity(delta: float) -> void:
	velocity.y += _get_effective_gravity() * delta


func debug_get_velocity() -> Vector2:
	return velocity


func debug_set_current_floor_platform(platform) -> void:
	current_floor_platform = platform


func debug_is_platform_drop_through_active() -> bool:
	return _is_platform_drop_through_active()


func debug_mark_dead() -> void:
	_on_player_died()


func _on_player_died() -> void:
	_clear_platform_drop_through()
	current_floor_platform = null
	is_dead = true
	state_name = "Dead"
	_sc_send("player_died")


func cast_hotbar_slot(slot_index: int) -> bool:
	if is_dead or hit_stun_timer > 0.0 or cast_lock_timer > 0.0:
		return false
	if spell_manager == null:
		return false
	var hotbar := GameState.get_spell_hotbar()
	if slot_index < 0 or slot_index >= hotbar.size():
		return false
	var skill_id := str(hotbar[slot_index].get("skill_id", ""))
	return spell_manager.attempt_cast(skill_id)


func get_state_chart() -> Object:
	return state_chart


func debug_setup_state_chart() -> void:
	_build_player_state_chart()


func debug_setup_spell_manager() -> void:
	spell_manager = preload("res://scripts/player/spell_manager.gd").new()
	spell_manager.setup(self)
	spell_manager.spell_cast.connect(_on_spell_cast)
