extends Area2D

signal world_effect_spawned(effect_id: String, effect_stage: String)

const WORLD_EFFECT_SPECS := {
	"arcane_force_pulse_attack":
	{
		"dir_path": "res://assets/effects/arcane_force_pulse_attack/",
		"frame_prefix": "arcane_force_pulse_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.76,
		"flip_by_velocity": true,
		"modulate_color": "#e6d4ff",
		"loop_animation": false
	},
	"arcane_force_pulse_hit":
	{
		"dir_path": "res://assets/effects/arcane_force_pulse_hit/",
		"frame_prefix": "arcane_force_pulse_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.84,
		"flip_by_velocity": false,
		"modulate_color": "#d9c2ff",
		"loop_animation": false
	},
	"dark_void_bolt_attack":
	{
		"dir_path": "res://assets/effects/dark_void_bolt_attack/",
		"frame_prefix": "dark_void_bolt_attack",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.88,
		"flip_by_velocity": true,
		"modulate_color": "#dfd4ff",
		"loop_animation": false
	},
	"dark_void_bolt_hit":
	{
		"dir_path": "res://assets/effects/dark_void_bolt_hit/",
		"frame_prefix": "dark_void_bolt_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.90,
		"flip_by_velocity": false,
		"modulate_color": "#cfbeff",
		"loop_animation": false
	},
	"dark_shadow_bind_attack":
	{
		"dir_path": "res://assets/effects/dark_shadow_bind_attack/",
		"frame_prefix": "dark_shadow_bind_attack",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.02,
		"flip_by_velocity": false,
		"modulate_color": "#c8b3ec",
		"loop_animation": false
	},
	"dark_shadow_bind_hit":
	{
		"dir_path": "res://assets/effects/dark_shadow_bind_hit/",
		"frame_prefix": "dark_shadow_bind_hit",
		"frame_count": 4,
		"fps": 15.0,
		"scale": 1.08,
		"flip_by_velocity": false,
		"modulate_color": "#d7c7f0",
		"loop_animation": false
	},
	"earth_stone_spire_attack":
	{
		"dir_path": "res://assets/effects/earth_stone_spire_attack/",
		"frame_prefix": "earth_stone_spire_attack",
		"frame_count": 7,
		"fps": 18.0,
		"scale": 0.96,
		"flip_by_velocity": false,
		"modulate_color": "#f0dfbf",
		"loop_animation": false
	},
	"earth_stone_spire_hit":
	{
		"dir_path": "res://assets/effects/earth_stone_spire_hit/",
		"frame_prefix": "earth_stone_spire_hit",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.92,
		"flip_by_velocity": false,
		"modulate_color": "#e8d5b0",
		"loop_animation": false
	},
	"earth_stone_rampart_attack":
	{
		"dir_path": "res://assets/effects/earth_stone_rampart_attack/",
		"frame_prefix": "earth_stone_rampart_attack",
		"frame_count": 9,
		"fps": 13.0,
		"scale": 1.28,
		"flip_by_velocity": false,
		"modulate_color": "#e3c491",
		"loop_animation": false
	},
	"earth_stone_rampart_hit":
	{
		"dir_path": "res://assets/effects/earth_stone_rampart_hit/",
		"frame_prefix": "earth_stone_rampart_hit",
		"frame_count": 9,
		"fps": 15.0,
		"scale": 1.12,
		"flip_by_velocity": false,
		"modulate_color": "#d8b47f",
		"loop_animation": false
	},
	"earth_tremor_attack":
	{
		"dir_path": "res://assets/effects/earth_tremor_attack/",
		"frame_prefix": "earth_tremor_attack",
		"frame_count": 12,
		"fps": 14.0,
		"scale": 1.26,
		"flip_by_velocity": false,
		"modulate_color": "#e7d3ad",
		"loop_animation": false
	},
	"earth_tremor_hit":
	{
		"dir_path": "res://assets/effects/earth_tremor_hit/",
		"frame_prefix": "earth_tremor_hit",
		"frame_count": 7,
		"fps": 18.0,
		"scale": 1.10,
		"flip_by_velocity": false,
		"modulate_color": "#cfaf78",
		"loop_animation": false
	},
	"earth_gaia_break_attack":
	{
		"dir_path": "res://assets/effects/earth_gaia_break_attack/",
		"frame_prefix": "earth_gaia_break_attack",
		"frame_count": 6,
		"fps": 14.0,
		"scale": 1.48,
		"flip_by_velocity": false,
		"modulate_color": "#ead3ad",
		"loop_animation": false
	},
	"earth_gaia_break_hit":
	{
		"dir_path": "res://assets/effects/earth_gaia_break_hit/",
		"frame_prefix": "earth_gaia_break_hit",
		"frame_count": 6,
		"fps": 16.0,
		"scale": 1.42,
		"flip_by_velocity": false,
		"modulate_color": "#d0ae7b",
		"loop_animation": false
	},
	"earth_continental_crush_attack":
	{
		"dir_path": "res://assets/effects/earth_continental_crush_attack/",
		"frame_prefix": "earth_continental_crush_attack",
		"frame_count": 6,
		"fps": 13.0,
		"scale": 1.66,
		"flip_by_velocity": false,
		"modulate_color": "#efdab6",
		"loop_animation": false
	},
	"earth_continental_crush_hit":
	{
		"dir_path": "res://assets/effects/earth_continental_crush_hit/",
		"frame_prefix": "earth_continental_crush_hit",
		"frame_count": 6,
		"fps": 15.0,
		"scale": 1.58,
		"flip_by_velocity": false,
		"modulate_color": "#d7b482",
		"loop_animation": false
	},
	"earth_world_end_break_attack":
	{
		"dir_path": "res://assets/effects/earth_world_end_break_attack/",
		"frame_prefix": "earth_world_end_break_attack",
		"frame_count": 6,
		"fps": 12.0,
		"scale": 1.78,
		"flip_by_velocity": false,
		"modulate_color": "#f3e1bf",
		"loop_animation": false
	},
	"earth_world_end_break_hit":
	{
		"dir_path": "res://assets/effects/earth_world_end_break_hit/",
		"frame_prefix": "earth_world_end_break_hit",
		"frame_count": 6,
		"fps": 14.0,
		"scale": 1.68,
		"flip_by_velocity": false,
		"modulate_color": "#dfbc84",
		"loop_animation": false
	},
	"earth_stone_shot_attack":
	{
		"dir_path": "res://assets/effects/fallback_stone_attack/",
		"frame_prefix": "fallback_stone_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.82,
		"flip_by_velocity": true,
		"modulate_color": "#dcc39a",
		"loop_animation": false
	},
	"earth_stone_shot_hit":
	{
		"dir_path": "res://assets/effects/fallback_stone_hit/",
		"frame_prefix": "fallback_stone_hit",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.90,
		"flip_by_velocity": false,
		"modulate_color": "#ceb084",
		"loop_animation": false
	},
	"earth_rock_spear_attack":
	{
		"dir_path": "res://assets/effects/fallback_stone_attack/",
		"frame_prefix": "fallback_stone_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.90,
		"flip_by_velocity": true,
		"modulate_color": "#d3b386",
		"loop_animation": false
	},
	"earth_rock_spear_hit":
	{
		"dir_path": "res://assets/effects/fallback_stone_hit/",
		"frame_prefix": "fallback_stone_hit",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.98,
		"flip_by_velocity": false,
		"modulate_color": "#c59d69",
		"loop_animation": false
	},
	"fire_bolt_attack":
	{
		"dir_path": "res://assets/effects/fire_bolt_attack/",
		"frame_prefix": "fire_bolt_attack",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.72,
		"flip_by_velocity": true,
		"modulate_color": "#ffd39b",
		"loop_animation": false
	},
	"fire_bolt_hit":
	{
		"dir_path": "res://assets/effects/fire_bolt_hit/",
		"frame_prefix": "fire_bolt_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.86,
		"flip_by_velocity": false,
		"modulate_color": "#ffb06f",
		"loop_animation": false
	},
	"fire_flame_bullet_attack":
	{
		"dir_path": "res://assets/effects/fallback_fire_attack/",
		"frame_prefix": "fallback_fire_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.72,
		"flip_by_velocity": true,
		"modulate_color": "#ffc17f",
		"loop_animation": false
	},
	"fire_flame_bullet_hit":
	{
		"dir_path": "res://assets/effects/fallback_fire_hit/",
		"frame_prefix": "fallback_fire_hit",
		"frame_count": 8,
		"fps": 20.0,
		"scale": 0.82,
		"flip_by_velocity": false,
		"modulate_color": "#ffaf63",
		"loop_animation": false
	},
	"fire_flame_storm_attack":
	{
		"dir_path": "res://assets/effects/fire_flame_storm_attack/",
		"frame_prefix": "fire_flame_storm_attack",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.08,
		"flip_by_velocity": false,
		"modulate_color": "#ffc57f",
		"loop_animation": false
	},
	"fire_flame_storm_hit":
	{
		"dir_path": "res://assets/effects/fire_flame_storm_hit/",
		"frame_prefix": "fire_flame_storm_hit",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 1.16,
		"flip_by_velocity": false,
		"modulate_color": "#ffac5b",
		"loop_animation": false
	},
	"fire_inferno_breath_attack":
	{
		"dir_path": "res://assets/effects/fire_inferno_breath_attack/",
		"frame_prefix": "fire_inferno_breath_attack",
		"frame_count": 8,
		"fps": 20.0,
		"scale": 1.22,
		"flip_by_velocity": true,
		"modulate_color": "#ffcd8d",
		"loop_animation": false
	},
	"fire_inferno_breath_hit":
	{
		"dir_path": "res://assets/effects/fire_inferno_breath_hit/",
		"frame_prefix": "fire_inferno_breath_hit",
		"frame_count": 5,
		"fps": 18.0,
		"scale": 1.12,
		"flip_by_velocity": false,
		"modulate_color": "#ffb464",
		"loop_animation": false
	},
	"fire_inferno_buster_attack":
	{
		"dir_path": "res://assets/effects/fire_inferno_buster_attack/",
		"frame_prefix": "fire_inferno_buster_attack",
		"frame_count": 4,
		"fps": 18.0,
		"scale": 1.40,
		"flip_by_velocity": false,
		"modulate_color": "#ffd09c",
		"loop_animation": false
	},
	"fire_inferno_buster_hit":
	{
		"dir_path": "res://assets/effects/fire_inferno_buster_hit/",
		"frame_prefix": "fire_inferno_buster_hit",
		"frame_count": 4,
		"fps": 18.0,
		"scale": 1.34,
		"flip_by_velocity": false,
		"modulate_color": "#ffe0b6",
		"loop_animation": false
	},
	"fire_meteor_strike_attack":
	{
		"dir_path": "res://assets/effects/fire_meteor_strike_attack/",
		"frame_prefix": "fire_meteor_strike_attack",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.58,
		"flip_by_velocity": false,
		"modulate_color": "#ffe0ba",
		"loop_animation": false
	},
	"fire_meteor_strike_hit":
	{
		"dir_path": "res://assets/effects/fire_meteor_strike_hit/",
		"frame_prefix": "fire_meteor_strike_hit",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.56,
		"flip_by_velocity": false,
		"modulate_color": "#ffd39f",
		"loop_animation": false
	},
	"fire_apocalypse_flame_attack":
	{
		"dir_path": "res://assets/effects/fire_apocalypse_flame_attack/",
		"frame_prefix": "fire_apocalypse_flame_attack",
		"frame_count": 4,
		"fps": 15.0,
		"scale": 1.74,
		"flip_by_velocity": false,
		"modulate_color": "#ffebc7",
		"loop_animation": false
	},
	"fire_apocalypse_flame_hit":
	{
		"dir_path": "res://assets/effects/fire_apocalypse_flame_hit/",
		"frame_prefix": "fire_apocalypse_flame_hit",
		"frame_count": 4,
		"fps": 15.0,
		"scale": 1.72,
		"flip_by_velocity": false,
		"modulate_color": "#ffd8a8",
		"loop_animation": false
	},
	"fire_solar_cataclysm_attack":
	{
		"dir_path": "res://assets/effects/fire_solar_cataclysm_attack/",
		"frame_prefix": "fire_solar_cataclysm_attack",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 1.88,
		"flip_by_velocity": false,
		"modulate_color": "#fff3d6",
		"loop_animation": false
	},
	"fire_solar_cataclysm_hit":
	{
		"dir_path": "res://assets/effects/fire_solar_cataclysm_hit/",
		"frame_prefix": "fire_solar_cataclysm_hit",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 1.84,
		"flip_by_velocity": false,
		"modulate_color": "#ffe0b2",
		"loop_animation": false
	},
	"fire_hellfire_field_attack":
	{
		"dir_path": "res://assets/effects/fire_hellfire_field_attack/",
		"frame_prefix": "fire_hellfire_field_attack",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.28,
		"flip_by_velocity": false,
		"modulate_color": "#ffbf72",
		"loop_animation": false
	},
	"fire_hellfire_field_hit":
	{
		"dir_path": "res://assets/effects/fire_hellfire_field_hit/",
		"frame_prefix": "fire_hellfire_field_hit",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 1.34,
		"flip_by_velocity": false,
		"modulate_color": "#ff9352",
		"loop_animation": false
	},
	"fire_inferno_sigil_attack":
	{
		"dir_path": "res://assets/effects/fire_inferno_sigil_attack/",
		"frame_prefix": "fire_inferno_sigil_attack",
		"frame_count": 17,
		"fps": 16.0,
		"scale": 1.16,
		"flip_by_velocity": false,
		"modulate_color": "#ffc181",
		"loop_animation": false
	},
	"fire_inferno_sigil_hit":
	{
		"dir_path": "res://assets/effects/fire_inferno_sigil_hit/",
		"frame_prefix": "fire_inferno_sigil_hit",
		"frame_count": 13,
		"fps": 11.0,
		"scale": 1.12,
		"flip_by_velocity": false,
		"modulate_color": "#ffb15b",
		"loop_animation": false
	},
	"holy_radiant_burst_attack":
	{
		"dir_path": "res://assets/effects/holy_radiant_burst_attack/",
		"frame_prefix": "holy_radiant_burst_attack",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.88,
		"flip_by_velocity": true,
		"modulate_color": "#fff2bb",
		"loop_animation": false
	},
	"holy_radiant_burst_hit":
	{
		"dir_path": "res://assets/effects/holy_radiant_burst_hit/",
		"frame_prefix": "holy_radiant_burst_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.82,
		"flip_by_velocity": false,
		"modulate_color": "#fff8d6",
		"loop_animation": false
	},
	"holy_halo_touch_attack":
	{
		"dir_path": "res://assets/effects/fallback_holy_attack/",
		"frame_prefix": "fallback_holy_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.86,
		"flip_by_velocity": true,
		"modulate_color": "#fff2cc",
		"loop_animation": false
	},
	"holy_halo_touch_hit":
	{
		"dir_path": "res://assets/effects/fallback_holy_hit/",
		"frame_prefix": "fallback_holy_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.92,
		"flip_by_velocity": false,
		"modulate_color": "#fff8e0",
		"loop_animation": false
	},
	"holy_bless_field_attack":
	{
		"dir_path": "res://assets/effects/holy_bless_field_attack/",
		"frame_prefix": "holy_bless_field_attack",
		"frame_count": 4,
		"fps": 17.0,
		"scale": 1.10,
		"flip_by_velocity": false,
		"modulate_color": "#ffe7a8",
		"loop_animation": false
	},
	"holy_bless_field_hit":
	{
		"dir_path": "res://assets/effects/holy_bless_field_hit/",
		"frame_prefix": "holy_bless_field_hit",
		"frame_count": 4,
		"fps": 15.0,
		"scale": 1.06,
		"flip_by_velocity": false,
		"modulate_color": "#fff8d0",
		"loop_animation": false
	},
	"holy_cure_ray_attack":
	{
		"dir_path": "res://assets/effects/holy_cure_ray_attack/",
		"frame_prefix": "holy_cure_ray_attack",
		"frame_count": 12,
		"fps": 20.0,
		"scale": 0.92,
		"flip_by_velocity": true,
		"modulate_color": "#fff1b1",
		"loop_animation": false
	},
	"holy_cure_ray_hit":
	{
		"dir_path": "res://assets/effects/holy_cure_ray_hit/",
		"frame_prefix": "holy_cure_ray_hit",
		"frame_count": 7,
		"fps": 18.0,
		"scale": 0.86,
		"flip_by_velocity": false,
		"modulate_color": "#fff7d4",
		"loop_animation": false
	},
	"holy_judgment_halo_attack":
	{
		"dir_path": "res://assets/effects/holy_judgment_halo_attack/",
		"frame_prefix": "holy_judgment_halo_attack",
		"frame_count": 11,
		"fps": 18.0,
		"scale": 1.12,
		"flip_by_velocity": false,
		"modulate_color": "#fff3c6",
		"loop_animation": false
	},
	"holy_judgment_halo_hit":
	{
		"dir_path": "res://assets/effects/holy_judgment_halo_hit/",
		"frame_prefix": "holy_judgment_halo_hit",
		"frame_count": 11,
		"fps": 18.0,
		"scale": 1.08,
		"flip_by_velocity": false,
		"modulate_color": "#fff8dd",
		"loop_animation": false
	},
	"holy_sanctuary_of_reversal_attack":
	{
		"dir_path": "res://assets/effects/holy_sanctuary_of_reversal_attack/",
		"frame_prefix": "holy_sanctuary_of_reversal_attack",
		"frame_count": 4,
		"fps": 18.0,
		"scale": 1.20,
		"flip_by_velocity": false,
		"modulate_color": "#fff1cf",
		"loop_animation": false
	},
	"holy_sanctuary_of_reversal_hit":
	{
		"dir_path": "res://assets/effects/holy_sanctuary_of_reversal_hit/",
		"frame_prefix": "holy_sanctuary_of_reversal_hit",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.12,
		"flip_by_velocity": false,
		"modulate_color": "#fffbe8",
		"loop_animation": false
	},
	"ice_storm_attack":
	{
		"dir_path": "res://assets/effects/ice_storm_attack/",
		"frame_prefix": "ice_storm_attack",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.12,
		"flip_by_velocity": false,
		"modulate_color": "#d8f6ff",
		"loop_animation": false
	},
	"ice_storm_hit":
	{
		"dir_path": "res://assets/effects/ice_storm_hit/",
		"frame_prefix": "ice_storm_hit",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.08,
		"flip_by_velocity": false,
		"modulate_color": "#e7fbff",
		"loop_animation": false
	},
	"ice_ice_wall_attack":
	{
		"dir_path": "res://assets/effects/ice_ice_wall_attack/",
		"frame_prefix": "ice_ice_wall_attack",
		"frame_count": 12,
		"fps": 12.0,
		"scale": 1.48,
		"flip_by_velocity": false,
		"modulate_color": "#e8fcff",
		"loop_animation": false
	},
	"ice_ice_wall_hit":
	{
		"dir_path": "res://assets/effects/ice_ice_wall_hit/",
		"frame_prefix": "ice_ice_wall_hit",
		"frame_count": 7,
		"fps": 17.0,
		"scale": 1.34,
		"flip_by_velocity": false,
		"modulate_color": "#def9ff",
		"loop_animation": false
	},
	"ice_absolute_freeze_attack":
	{
		"dir_path": "res://assets/effects/ice_absolute_freeze_attack/",
		"frame_prefix": "ice_absolute_freeze_attack",
		"frame_count": 4,
		"fps": 18.0,
		"scale": 1.34,
		"flip_by_velocity": false,
		"modulate_color": "#e6fcff",
		"loop_animation": false
	},
	"ice_absolute_freeze_hit":
	{
		"dir_path": "res://assets/effects/ice_absolute_freeze_hit/",
		"frame_prefix": "ice_absolute_freeze_hit",
		"frame_count": 4,
		"fps": 18.0,
		"scale": 1.28,
		"flip_by_velocity": false,
		"modulate_color": "#f2fdff",
		"loop_animation": false
	},
	"ice_absolute_zero_attack":
	{
		"dir_path": "res://assets/effects/ice_absolute_zero_attack/",
		"frame_prefix": "ice_absolute_zero_attack",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.58,
		"flip_by_velocity": false,
		"modulate_color": "#f2ffff",
		"loop_animation": false
	},
	"ice_absolute_zero_hit":
	{
		"dir_path": "res://assets/effects/ice_absolute_zero_hit/",
		"frame_prefix": "ice_absolute_zero_hit",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.52,
		"flip_by_velocity": false,
		"modulate_color": "#fbffff",
		"loop_animation": false
	},
	"ice_frost_needle_attack":
	{
		"dir_path": "res://assets/effects/ice_frost_needle_attack/",
		"frame_prefix": "ice_frost_needle_attack",
		"frame_count": 3,
		"fps": 22.0,
		"scale": 0.76,
		"flip_by_velocity": true,
		"modulate_color": "#ebfbff",
		"loop_animation": false
	},
	"ice_frost_needle_hit":
	{
		"dir_path": "res://assets/effects/ice_frost_needle_hit/",
		"frame_prefix": "ice_frost_needle_hit",
		"frame_count": 8,
		"fps": 20.0,
		"scale": 0.86,
		"flip_by_velocity": false,
		"modulate_color": "#d8f8ff",
		"loop_animation": false
	},
	"ice_spear_attack":
	{
		"dir_path": "res://assets/effects/fallback_shard_attack/",
		"frame_prefix": "fallback_shard_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.80,
		"flip_by_velocity": true,
		"modulate_color": "#eefcff",
		"loop_animation": false
	},
	"ice_spear_hit":
	{
		"dir_path": "res://assets/effects/fallback_shard_hit/",
		"frame_prefix": "fallback_shard_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.90,
		"flip_by_velocity": false,
		"modulate_color": "#ddf8ff",
		"loop_animation": false
	},
	"lightning_thunder_arrow_attack":
	{
		"dir_path": "res://assets/effects/fallback_shard_attack/",
		"frame_prefix": "fallback_shard_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.78,
		"flip_by_velocity": true,
		"modulate_color": "#fff0ab",
		"loop_animation": false
	},
	"lightning_thunder_arrow_hit":
	{
		"dir_path": "res://assets/effects/fallback_shard_hit/",
		"frame_prefix": "fallback_shard_hit",
		"frame_count": 8,
		"fps": 20.0,
		"scale": 0.90,
		"flip_by_velocity": false,
		"modulate_color": "#ffe98d",
		"loop_animation": false
	},
	"lightning_bolt_attack":
	{
		"dir_path": "res://assets/effects/fallback_shard_attack/",
		"frame_prefix": "fallback_shard_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.88,
		"flip_by_velocity": true,
		"modulate_color": "#fff7bc",
		"loop_animation": false
	},
	"lightning_bolt_hit":
	{
		"dir_path": "res://assets/effects/fallback_shard_hit/",
		"frame_prefix": "fallback_shard_hit",
		"frame_count": 8,
		"fps": 20.0,
		"scale": 1.02,
		"flip_by_velocity": false,
		"modulate_color": "#fff09a",
		"loop_animation": false
	},
	"plant_world_root_attack":
	{
		"dir_path": "res://assets/effects/plant_world_root_attack/",
		"frame_prefix": "plant_world_root_attack",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.18,
		"flip_by_velocity": false,
		"modulate_color": "#b7ebb0",
		"loop_animation": false
	},
	"plant_vine_snare_attack":
	{
		"dir_path": "res://assets/effects/plant_vine_snare_attack/",
		"frame_prefix": "plant_vine_snare_attack",
		"frame_count": 4,
		"fps": 17.0,
		"scale": 1.06,
		"flip_by_velocity": false,
		"modulate_color": "#9cd878",
		"loop_animation": false
	},
	"plant_vine_snare_hit":
	{
		"dir_path": "res://assets/effects/plant_vine_snare_hit/",
		"frame_prefix": "plant_vine_snare_hit",
		"frame_count": 4,
		"fps": 17.0,
		"scale": 1.04,
		"flip_by_velocity": false,
		"modulate_color": "#d2f0a9",
		"loop_animation": false
	},
	"plant_world_root_hit":
	{
		"dir_path": "res://assets/effects/plant_world_root_hit/",
		"frame_prefix": "plant_world_root_hit",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.14,
		"flip_by_velocity": false,
		"modulate_color": "#d0f0b2",
		"loop_animation": false
	},
	"plant_worldroot_bastion_attack":
	{
		"dir_path": "res://assets/effects/plant_worldroot_bastion_attack/",
		"frame_prefix": "plant_worldroot_bastion_attack",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.24,
		"flip_by_velocity": false,
		"modulate_color": "#bfe6a4",
		"loop_animation": false
	},
	"plant_worldroot_bastion_hit":
	{
		"dir_path": "res://assets/effects/plant_worldroot_bastion_hit/",
		"frame_prefix": "plant_worldroot_bastion_hit",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.20,
		"flip_by_velocity": false,
		"modulate_color": "#d5efb8",
		"loop_animation": false
	},
	"plant_genesis_arbor_attack":
	{
		"dir_path": "res://assets/effects/plant_genesis_arbor_attack/",
		"frame_prefix": "plant_genesis_arbor_attack",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.34,
		"flip_by_velocity": false,
		"modulate_color": "#c6f1b4",
		"loop_animation": false
	},
	"plant_genesis_arbor_hit":
	{
		"dir_path": "res://assets/effects/plant_genesis_arbor_hit/",
		"frame_prefix": "plant_genesis_arbor_hit",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.30,
		"flip_by_velocity": false,
		"modulate_color": "#d8f4bb",
		"loop_animation": false
	},
	"water_aqua_bullet_attack":
	{
		"dir_path": "res://assets/effects/water_aqua_bullet_attack/",
		"frame_prefix": "water_aqua_bullet_attack",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.88,
		"flip_by_velocity": true,
		"modulate_color": "#d4f6ff",
		"loop_animation": false
	},
	"water_aqua_bullet_hit":
	{
		"dir_path": "res://assets/effects/water_aqua_bullet_hit/",
		"frame_prefix": "water_aqua_bullet_hit",
		"frame_count": 15,
		"fps": 20.0,
		"scale": 0.96,
		"flip_by_velocity": false,
		"modulate_color": "#c4f2ff",
		"loop_animation": false
	},
	"water_aqua_spear_attack":
	{
		"dir_path": "res://assets/effects/fallback_water_attack/",
		"frame_prefix": "fallback_water_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.82,
		"flip_by_velocity": true,
		"modulate_color": "#d9f7ff",
		"loop_animation": false
	},
	"water_aqua_spear_hit":
	{
		"dir_path": "res://assets/effects/fallback_water_hit/",
		"frame_prefix": "fallback_water_hit",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.90,
		"flip_by_velocity": false,
		"modulate_color": "#c9f2ff",
		"loop_animation": false
	},
	"water_tidal_ring_attack":
	{
		"dir_path": "res://assets/effects/water_tidal_ring_attack/",
		"frame_prefix": "water_tidal_ring_attack",
		"frame_count": 11,
		"fps": 20.0,
		"scale": 2.18,
		"flip_by_velocity": false,
		"modulate_color": "#dff7ff",
		"loop_animation": false
	},
	"water_tidal_ring_hit":
	{
		"dir_path": "res://assets/effects/water_tidal_ring_hit/",
		"frame_prefix": "water_tidal_ring_hit",
		"frame_count": 19,
		"fps": 20.0,
		"scale": 1.68,
		"flip_by_velocity": false,
		"modulate_color": "#d6f5ff",
		"loop_animation": false
	},
	"water_aqua_geyser_attack":
	{
		"dir_path": "res://assets/effects/water_aqua_geyser_attack/",
		"frame_prefix": "water_aqua_geyser_attack",
		"frame_count": 4,
		"fps": 18.0,
		"scale": 1.18,
		"flip_by_velocity": false,
		"modulate_color": "#e6fbff",
		"loop_animation": false
	},
	"water_aqua_geyser_hit":
	{
		"dir_path": "res://assets/effects/water_aqua_geyser_hit/",
		"frame_prefix": "water_aqua_geyser_hit",
		"frame_count": 20,
		"fps": 22.0,
		"scale": 1.42,
		"flip_by_velocity": false,
		"modulate_color": "#d9f7ff",
		"loop_animation": false
	},
	"water_wave_attack":
	{
		"dir_path": "res://assets/effects/fallback_water_attack/",
		"frame_prefix": "fallback_water_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 1.02,
		"flip_by_velocity": true,
		"modulate_color": "#dcfbff",
		"loop_animation": false
	},
	"water_wave_hit":
	{
		"dir_path": "res://assets/effects/fallback_water_hit/",
		"frame_prefix": "fallback_water_hit",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 1.10,
		"flip_by_velocity": false,
		"modulate_color": "#d0f8ff",
		"loop_animation": false
	},
	"water_tsunami_attack":
	{
		"dir_path": "res://assets/effects/water_tsunami_attack/",
		"frame_prefix": "water_tsunami_attack",
		"frame_count": 6,
		"fps": 16.0,
		"scale": 1.24,
		"flip_by_velocity": true,
		"modulate_color": "#e7fdff",
		"loop_animation": false
	},
	"water_tsunami_hit":
	{
		"dir_path": "res://assets/effects/water_tsunami_hit/",
		"frame_prefix": "water_tsunami_hit",
		"frame_count": 6,
		"fps": 16.0,
		"scale": 1.34,
		"flip_by_velocity": false,
		"modulate_color": "#dafcff",
		"loop_animation": false
	},
	"water_ocean_collapse_attack":
	{
		"dir_path": "res://assets/effects/water_ocean_collapse_attack/",
		"frame_prefix": "water_ocean_collapse_attack",
		"frame_count": 6,
		"fps": 15.0,
		"scale": 1.38,
		"flip_by_velocity": true,
		"modulate_color": "#eefeff",
		"loop_animation": false
	},
	"water_ocean_collapse_hit":
	{
		"dir_path": "res://assets/effects/water_ocean_collapse_hit/",
		"frame_prefix": "water_ocean_collapse_hit",
		"frame_count": 6,
		"fps": 15.0,
		"scale": 1.46,
		"flip_by_velocity": false,
		"modulate_color": "#e2fdff",
		"loop_animation": false
	},
	"wind_cyclone_prison_attack":
	{
		"dir_path": "res://assets/effects/wind_cyclone_prison_attack/",
		"frame_prefix": "wind_cyclone_prison_attack",
		"frame_count": 12,
		"fps": 18.0,
		"scale": 1.02,
		"flip_by_velocity": false,
		"modulate_color": "#dfffcf",
		"loop_animation": false
	},
	"wind_cyclone_prison_hit":
	{
		"dir_path": "res://assets/effects/wind_cyclone_prison_hit/",
		"frame_prefix": "wind_cyclone_prison_hit",
		"frame_count": 9,
		"fps": 18.0,
		"scale": 0.96,
		"flip_by_velocity": false,
		"modulate_color": "#e8ffd4",
		"loop_animation": false
	},
	"wind_arrow_attack":
	{
		"dir_path": "res://assets/effects/fallback_wind_attack/",
		"frame_prefix": "fallback_wind_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.82,
		"flip_by_velocity": true,
		"modulate_color": "#dbffd6",
		"loop_animation": false
	},
	"wind_arrow_hit":
	{
		"dir_path": "res://assets/effects/fallback_wind_hit/",
		"frame_prefix": "fallback_wind_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.86,
		"flip_by_velocity": false,
		"modulate_color": "#d2ffce",
		"loop_animation": false
	},
	"wind_gust_bolt_attack":
	{
		"dir_path": "res://assets/effects/fallback_wind_attack/",
		"frame_prefix": "fallback_wind_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.88,
		"flip_by_velocity": true,
		"modulate_color": "#d4ffcf",
		"loop_animation": false
	},
	"wind_gust_bolt_hit":
	{
		"dir_path": "res://assets/effects/fallback_wind_hit/",
		"frame_prefix": "fallback_wind_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.92,
		"flip_by_velocity": false,
		"modulate_color": "#cbffc7",
		"loop_animation": false
	},
	"wind_gale_cutter_attack":
	{
		"dir_path": "res://assets/effects/wind_gale_cutter_attack/",
		"frame_prefix": "wind_gale_cutter_attack",
		"frame_count": 2,
		"fps": 18.0,
		"scale": 0.96,
		"flip_by_velocity": true,
		"modulate_color": "#d9ffd0",
		"loop_animation": false
	},
	"wind_gale_cutter_hit":
	{
		"dir_path": "res://assets/effects/wind_gale_cutter_hit/",
		"frame_prefix": "wind_gale_cutter_hit",
		"frame_count": 2,
		"fps": 18.0,
		"scale": 0.92,
		"flip_by_velocity": false,
		"modulate_color": "#d7ffd5",
		"loop_animation": false
	},
	"wind_tempest_drive_attack":
	{
		"dir_path": "res://assets/effects/fallback_wind_attack/",
		"frame_prefix": "fallback_wind_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 1.04,
		"flip_by_velocity": false,
		"modulate_color": "#e7ffe2",
		"loop_animation": false
	},
	"wind_tempest_drive_hit":
	{
		"dir_path": "res://assets/effects/fallback_wind_hit/",
		"frame_prefix": "fallback_wind_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 1.08,
		"flip_by_velocity": false,
		"modulate_color": "#dcffd7",
		"loop_animation": false
	},
	"wind_storm_attack":
	{
		"dir_path": "res://assets/effects/wind_storm_attack/",
		"frame_prefix": "wind_storm_attack",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 1.24,
		"flip_by_velocity": false,
		"modulate_color": "#e4ffe1",
		"loop_animation": false
	},
	"wind_storm_hit":
	{
		"dir_path": "res://assets/effects/wind_storm_hit/",
		"frame_prefix": "wind_storm_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 1.28,
		"flip_by_velocity": false,
		"modulate_color": "#d9ffd4",
		"loop_animation": false
	},
	"wind_heavenly_storm_attack":
	{
		"dir_path": "res://assets/effects/wind_heavenly_storm_attack/",
		"frame_prefix": "wind_heavenly_storm_attack",
		"frame_count": 6,
		"fps": 17.0,
		"scale": 1.44,
		"flip_by_velocity": false,
		"modulate_color": "#ecffe8",
		"loop_animation": false
	},
	"wind_heavenly_storm_hit":
	{
		"dir_path": "res://assets/effects/wind_heavenly_storm_hit/",
		"frame_prefix": "wind_heavenly_storm_hit",
		"frame_count": 8,
		"fps": 17.0,
		"scale": 1.48,
		"flip_by_velocity": false,
		"modulate_color": "#e2ffdd",
		"loop_animation": false
	},
	"volt_spear_attack":
	{
		"dir_path": "res://assets/effects/volt_spear_attack/",
		"frame_prefix": "volt_spear_attack",
		"frame_count": 8,
		"fps": 20.0,
		"scale": 0.78,
		"flip_by_velocity": true,
		"modulate_color": "#dff8ff",
		"loop_animation": false
	},
	"volt_spear_hit":
	{
		"dir_path": "res://assets/effects/volt_spear_hit/",
		"frame_prefix": "volt_spear_hit",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.86,
		"flip_by_velocity": false,
		"modulate_color": "#b7f6ff",
		"loop_animation": false
	}
}
const SPELL_VISUAL_SPECS := {
	"arcane_force_pulse":
	{
		"dir_path": "res://assets/effects/arcane_force_pulse/",
		"frame_prefix": "arcane_force_pulse",
		"frame_count": 6,
		"fps": 16.0,
		"scale": 0.80,
		"flip_by_velocity": true,
		"modulate_color": "#d3b9ff",
		"loop_animation": true
	},
	"earth_stone_spire":
	{
		"dir_path": "res://assets/effects/earth_stone_spire/",
		"frame_prefix": "earth_stone_spire",
		"frame_count": 12,
		"fps": 14.0,
		"scale": 1.16,
		"flip_by_velocity": false,
		"modulate_color": "#ebd4af",
		"loop_animation": false
	},
	"earth_stone_rampart":
	{
		"dir_path": "res://assets/effects/earth_stone_rampart/",
		"frame_prefix": "earth_stone_rampart",
		"frame_count": 9,
		"fps": 8.0,
		"scale": 1.76,
		"flip_by_velocity": false,
		"modulate_color": "#e2c08c",
		"loop_animation": true
	},
	"earth_stone_shot":
	{
		"dir_path": "res://assets/effects/fallback_stone_projectile/",
		"frame_prefix": "fallback_stone_projectile",
		"frame_count": 6,
		"fps": 12.0,
		"scale": 0.92,
		"flip_by_velocity": true,
		"modulate_color": "#d9bf93",
		"loop_animation": true
	},
	"earth_rock_spear":
	{
		"dir_path": "res://assets/effects/fallback_stone_projectile/",
		"frame_prefix": "fallback_stone_projectile",
		"frame_count": 6,
		"fps": 14.0,
		"scale": 1.02,
		"flip_by_velocity": true,
		"modulate_color": "#cda978",
		"loop_animation": true
	},
	"earth_gaia_break":
	{
		"dir_path": "res://assets/effects/earth_gaia_break/",
		"frame_prefix": "earth_gaia_break",
		"frame_count": 6,
		"fps": 12.0,
		"scale": 2.88,
		"flip_by_velocity": false,
		"modulate_color": "#d8bc92",
		"loop_animation": false
	},
	"earth_continental_crush":
	{
		"dir_path": "res://assets/effects/earth_continental_crush/",
		"frame_prefix": "earth_continental_crush",
		"frame_count": 6,
		"fps": 11.0,
		"scale": 3.18,
		"flip_by_velocity": false,
		"modulate_color": "#e5ca9e",
		"loop_animation": false
	},
	"earth_world_end_break":
	{
		"dir_path": "res://assets/effects/earth_world_end_break/",
		"frame_prefix": "earth_world_end_break",
		"frame_count": 6,
		"fps": 10.0,
		"scale": 3.42,
		"flip_by_velocity": false,
		"modulate_color": "#efd9b1",
		"loop_animation": false
	},
	"fire_flame_arc":
	{
		"dir_path": "res://assets/effects/fire_flame_arc/",
		"frame_prefix": "fire_flame_arc",
		"frame_count": 16,
		"fps": 22.0,
		"scale": 2.18,
		"flip_by_velocity": false,
		"modulate_color": "#ffcb8a",
		"loop_animation": false
	},
	"fire_inferno_breath":
	{
		"dir_path": "res://assets/effects/fire_inferno_breath/",
		"frame_prefix": "fire_inferno_breath",
		"frame_count": 24,
		"fps": 24.0,
		"scale": 1.72,
		"flip_by_velocity": true,
		"modulate_color": "#ffbf73",
		"loop_animation": false
	},
	"fire_inferno_sigil":
	{
		"dir_path": "res://assets/effects/fire_inferno_sigil/",
		"frame_prefix": "fire_inferno_sigil",
		"frame_count": 13,
		"fps": 7.0,
		"scale": 1.84,
		"flip_by_velocity": false,
		"modulate_color": "#f0a154",
		"loop_animation": true
	},
	"fire_flame_bullet":
	{
		"dir_path": "res://assets/effects/fallback_fire_projectile/",
		"frame_prefix": "fallback_fire_projectile",
		"frame_count": 10,
		"fps": 16.0,
		"scale": 0.74,
		"flip_by_velocity": true,
		"modulate_color": "#ffbc79",
		"loop_animation": true
	},
	"fire_flame_storm":
	{
		"dir_path": "res://assets/effects/fire_flame_storm/",
		"frame_prefix": "fire_flame_storm",
		"frame_count": 4,
		"fps": 9.0,
		"scale": 2.10,
		"flip_by_velocity": false,
		"modulate_color": "#ff9e5a",
		"loop_animation": true
	},
	"fire_inferno_buster":
	{
		"dir_path": "res://assets/effects/fire_inferno_buster/",
		"frame_prefix": "fire_inferno_buster",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 2.78,
		"flip_by_velocity": false,
		"modulate_color": "#ffbe78",
		"loop_animation": false
	},
	"fire_meteor_strike":
	{
		"dir_path": "res://assets/effects/fire_meteor_strike/",
		"frame_prefix": "fire_meteor_strike",
		"frame_count": 4,
		"fps": 12.0,
		"scale": 3.06,
		"flip_by_velocity": false,
		"modulate_color": "#ffd099",
		"loop_animation": false
	},
	"fire_apocalypse_flame":
	{
		"dir_path": "res://assets/effects/fire_apocalypse_flame/",
		"frame_prefix": "fire_apocalypse_flame",
		"frame_count": 4,
		"fps": 11.0,
		"scale": 3.34,
		"flip_by_velocity": false,
		"modulate_color": "#ffe1b0",
		"loop_animation": false
	},
	"fire_solar_cataclysm":
	{
		"dir_path": "res://assets/effects/fire_solar_cataclysm/",
		"frame_prefix": "fire_solar_cataclysm",
		"frame_count": 4,
		"fps": 10.0,
		"scale": 3.56,
		"flip_by_velocity": false,
		"modulate_color": "#fff0c8",
		"loop_animation": false
	},
	"fire_hellfire_field":
	{
		"dir_path": "res://assets/effects/fire_hellfire_field/",
		"frame_prefix": "fire_hellfire_field",
		"frame_count": 4,
		"fps": 10.0,
		"scale": 2.56,
		"flip_by_velocity": false,
		"modulate_color": "#ff8d4c",
		"loop_animation": true
	},
	"holy_halo_touch":
	{
		"dir_path": "res://assets/effects/fallback_holy_projectile/",
		"frame_prefix": "fallback_holy_projectile",
		"frame_count": 8,
		"fps": 14.0,
		"scale": 0.82,
		"flip_by_velocity": true,
		"modulate_color": "#fff2cb",
		"loop_animation": true
	},
	"holy_bless_field":
	{
		"dir_path": "res://assets/effects/holy_bless_field/",
		"frame_prefix": "holy_bless_field",
		"frame_count": 4,
		"fps": 10.0,
		"scale": 2.08,
		"flip_by_velocity": false,
		"modulate_color": "#ffefbd",
		"loop_animation": true
	},
	"holy_cure_ray":
	{
		"dir_path": "res://assets/effects/holy_cure_ray/",
		"frame_prefix": "holy_cure_ray",
		"frame_count": 16,
		"fps": 22.0,
		"scale": 0.98,
		"flip_by_velocity": true,
		"modulate_color": "#fff4ba",
		"loop_animation": true
	},
	"holy_judgment_halo":
	{
		"dir_path": "res://assets/effects/holy_judgment_halo/",
		"frame_prefix": "holy_judgment_halo",
		"frame_count": 13,
		"fps": 18.0,
		"scale": 1.42,
		"flip_by_velocity": false,
		"modulate_color": "#fff6d8",
		"loop_animation": false
	},
	"holy_sanctuary_of_reversal":
	{
		"dir_path": "res://assets/effects/holy_sanctuary_of_reversal/",
		"frame_prefix": "holy_sanctuary_of_reversal",
		"frame_count": 4,
		"fps": 11.0,
		"scale": 2.18,
		"flip_by_velocity": false,
		"modulate_color": "#fff9ef",
		"loop_animation": true
	},
	"ice_storm":
	{
		"dir_path": "res://assets/effects/ice_storm/",
		"frame_prefix": "ice_storm",
		"frame_count": 4,
		"fps": 9.0,
		"scale": 2.16,
		"flip_by_velocity": false,
		"modulate_color": "#cff4ff",
		"loop_animation": true
	},
	"ice_ice_wall":
	{
		"dir_path": "res://assets/effects/ice_ice_wall/",
		"frame_prefix": "ice_ice_wall",
		"frame_count": 12,
		"fps": 7.0,
		"scale": 1.70,
		"flip_by_velocity": false,
		"modulate_color": "#ecfdff",
		"loop_animation": true
	},
	"ice_absolute_freeze":
	{
		"dir_path": "res://assets/effects/ice_absolute_freeze/",
		"frame_prefix": "ice_absolute_freeze",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 2.64,
		"flip_by_velocity": false,
		"modulate_color": "#defcff",
		"loop_animation": false
	},
	"ice_absolute_zero":
	{
		"dir_path": "res://assets/effects/ice_absolute_zero/",
		"frame_prefix": "ice_absolute_zero",
		"frame_count": 4,
		"fps": 12.0,
		"scale": 3.02,
		"flip_by_velocity": false,
		"modulate_color": "#efffff",
		"loop_animation": false
	},
	"ice_frost_needle":
	{
		"dir_path": "res://assets/effects/ice_frost_needle/",
		"frame_prefix": "ice_frost_needle",
		"frame_count": 10,
		"fps": 18.0,
		"scale": 0.86,
		"flip_by_velocity": true,
		"modulate_color": "#e6fbff",
		"loop_animation": true
	},
	"ice_spear":
	{
		"dir_path": "res://assets/effects/fallback_shard_projectile/",
		"frame_prefix": "fallback_shard_projectile",
		"frame_count": 6,
		"fps": 16.0,
		"scale": 0.86,
		"flip_by_velocity": true,
		"modulate_color": "#ecfbff",
		"loop_animation": true
	},
	"lightning_thunder_arrow":
	{
		"dir_path": "res://assets/effects/fallback_shard_projectile/",
		"frame_prefix": "fallback_shard_projectile",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.84,
		"flip_by_velocity": true,
		"modulate_color": "#fff0a6",
		"loop_animation": true
	},
	"lightning_bolt":
	{
		"dir_path": "res://assets/effects/fallback_shard_projectile/",
		"frame_prefix": "fallback_shard_projectile",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.96,
		"flip_by_velocity": true,
		"modulate_color": "#fff6b2",
		"loop_animation": true
	},
	"plant_vine_snare":
	{
		"dir_path": "res://assets/effects/plant_vine_snare/",
		"frame_prefix": "plant_vine_snare",
		"frame_count": 4,
		"fps": 10.0,
		"scale": 2.12,
		"flip_by_velocity": false,
		"modulate_color": "#9fcf78",
		"loop_animation": true
	},
	"dark_shadow_bind":
	{
		"dir_path": "res://assets/effects/dark_shadow_bind/",
		"frame_prefix": "dark_shadow_bind",
		"frame_count": 4,
		"fps": 8.0,
		"scale": 2.18,
		"flip_by_velocity": false,
		"modulate_color": "#bca6da",
		"loop_animation": true
	},
	"plant_world_root":
	{
		"dir_path": "res://assets/effects/plant_world_root/",
		"frame_prefix": "plant_world_root",
		"frame_count": 4,
		"fps": 9.0,
		"scale": 2.44,
		"flip_by_velocity": false,
		"modulate_color": "#b9df98",
		"loop_animation": true
	},
	"plant_worldroot_bastion":
	{
		"dir_path": "res://assets/effects/plant_worldroot_bastion/",
		"frame_prefix": "plant_worldroot_bastion",
		"frame_count": 4,
		"fps": 9.0,
		"scale": 2.62,
		"flip_by_velocity": false,
		"modulate_color": "#c0dfa0",
		"loop_animation": true
	},
	"plant_genesis_arbor":
	{
		"dir_path": "res://assets/effects/plant_genesis_arbor/",
		"frame_prefix": "plant_genesis_arbor",
		"frame_count": 4,
		"fps": 9.0,
		"scale": 2.86,
		"flip_by_velocity": false,
		"modulate_color": "#c7e7a2",
		"loop_animation": true
	},
	"water_aqua_bullet":
	{
		"dir_path": "res://assets/effects/water_aqua_bullet/",
		"frame_prefix": "water_aqua_bullet",
		"frame_count": 18,
		"fps": 16.0,
		"scale": 0.92,
		"flip_by_velocity": true,
		"modulate_color": "#c9f2ff",
		"loop_animation": true
	},
	"water_aqua_spear":
	{
		"dir_path": "res://assets/effects/fallback_water_line/",
		"frame_prefix": "fallback_water_line",
		"frame_count": 8,
		"fps": 18.0,
		"scale": 0.88,
		"flip_by_velocity": true,
		"modulate_color": "#d6f7ff",
		"loop_animation": true
	},
	"water_tidal_ring":
	{
		"dir_path": "res://assets/effects/water_tidal_ring/",
		"frame_prefix": "water_tidal_ring",
		"frame_count": 20,
		"fps": 22.0,
		"scale": 2.28,
		"flip_by_velocity": false,
		"modulate_color": "#d7f6ff",
		"loop_animation": false
	},
	"water_aqua_geyser":
	{
		"dir_path": "res://assets/effects/water_aqua_geyser/",
		"frame_prefix": "water_aqua_geyser",
		"frame_count": 25,
		"fps": 28.0,
		"scale": 1.94,
		"flip_by_velocity": false,
		"modulate_color": "#dcfaff",
		"loop_animation": false
	},
	"water_wave":
	{
		"dir_path": "res://assets/effects/fallback_water_line/",
		"frame_prefix": "fallback_water_line",
		"frame_count": 8,
		"fps": 16.0,
		"scale": 1.28,
		"flip_by_velocity": true,
		"modulate_color": "#cff6ff",
		"loop_animation": true
	},
	"water_tsunami":
	{
		"dir_path": "res://assets/effects/water_tsunami/",
		"frame_prefix": "water_tsunami",
		"frame_count": 8,
		"fps": 14.0,
		"scale": 1.72,
		"flip_by_velocity": true,
		"modulate_color": "#d9fbff",
		"loop_animation": true
	},
	"water_ocean_collapse":
	{
		"dir_path": "res://assets/effects/water_ocean_collapse/",
		"frame_prefix": "water_ocean_collapse",
		"frame_count": 8,
		"fps": 13.0,
		"scale": 1.94,
		"flip_by_velocity": true,
		"modulate_color": "#e5feff",
		"loop_animation": true
	},
	"wind_gale_cutter":
	{
		"dir_path": "res://assets/effects/wind_gale_cutter/",
		"frame_prefix": "wind_gale_cutter",
		"frame_count": 2,
		"fps": 14.0,
		"scale": 0.96,
		"flip_by_velocity": true,
		"modulate_color": "#dfffd8",
		"loop_animation": true
	},
	"wind_tempest_drive":
	{
		"dir_path": "res://assets/effects/fallback_wind_projectile/",
		"frame_prefix": "fallback_wind_projectile",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.22,
		"flip_by_velocity": false,
		"modulate_color": "#eaffdf",
		"loop_animation": false
	},
	"wind_cyclone_prison":
	{
		"dir_path": "res://assets/effects/wind_cyclone_prison_loop/",
		"frame_prefix": "wind_cyclone_prison_loop",
		"frame_count": 9,
		"fps": 10.0,
		"scale": 1.62,
		"flip_by_velocity": false,
		"modulate_color": "#dbffc8",
		"loop_animation": true
	},
	"wind_arrow":
	{
		"dir_path": "res://assets/effects/fallback_wind_projectile/",
		"frame_prefix": "fallback_wind_projectile",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 0.92,
		"flip_by_velocity": true,
		"modulate_color": "#d7ffd2",
		"loop_animation": true
	},
	"wind_gust_bolt":
	{
		"dir_path": "res://assets/effects/fallback_wind_projectile/",
		"frame_prefix": "fallback_wind_projectile",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.02,
		"flip_by_velocity": true,
		"modulate_color": "#d0ffcb",
		"loop_animation": true
	},
	"wind_storm":
	{
		"dir_path": "res://assets/effects/wind_storm/",
		"frame_prefix": "wind_storm",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 2.36,
		"flip_by_velocity": false,
		"modulate_color": "#e1ffd8",
		"loop_animation": false
	},
	"wind_heavenly_storm":
	{
		"dir_path": "res://assets/effects/wind_heavenly_storm/",
		"frame_prefix": "wind_heavenly_storm",
		"frame_count": 4,
		"fps": 13.0,
		"scale": 2.78,
		"flip_by_velocity": false,
		"modulate_color": "#ecffe2",
		"loop_animation": false
	}
}
const TERMINAL_EFFECT_SPECS := {
	"bomber_burst":
	{
		"dir_path": "res://assets/effects/bomber_burst/",
		"frame_prefix": "bomber_burst",
		"frame_count": 6,
		"fps": 18.0,
		"scale": 0.92,
		"flip_by_velocity": false,
		"modulate_color": "#ffca86",
		"loop_animation": false
	},
	"fire_inferno_sigil_end":
	{
		"dir_path": "res://assets/effects/fire_inferno_sigil_end/",
		"frame_prefix": "fire_inferno_sigil_end",
		"frame_count": 17,
		"fps": 16.0,
		"scale": 1.22,
		"flip_by_velocity": false,
		"modulate_color": "#ffc78a",
		"loop_animation": false
	},
	"fire_flame_storm_end":
	{
		"dir_path": "res://assets/effects/fire_flame_storm_end/",
		"frame_prefix": "fire_flame_storm_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 1.36,
		"flip_by_velocity": false,
		"modulate_color": "#ffc07a",
		"loop_animation": false
	},
	"fire_meteor_strike_end":
	{
		"dir_path": "res://assets/effects/fire_meteor_strike_end/",
		"frame_prefix": "fire_meteor_strike_end",
		"frame_count": 4,
		"fps": 12.0,
		"scale": 1.70,
		"flip_by_velocity": false,
		"modulate_color": "#ffb36f",
		"loop_animation": false
	},
	"fire_apocalypse_flame_end":
	{
		"dir_path": "res://assets/effects/fire_apocalypse_flame_end/",
		"frame_prefix": "fire_apocalypse_flame_end",
		"frame_count": 4,
		"fps": 11.0,
		"scale": 1.86,
		"flip_by_velocity": false,
		"modulate_color": "#ffbf7c",
		"loop_animation": false
	},
	"fire_solar_cataclysm_end":
	{
		"dir_path": "res://assets/effects/fire_solar_cataclysm_end/",
		"frame_prefix": "fire_solar_cataclysm_end",
		"frame_count": 4,
		"fps": 10.0,
		"scale": 1.98,
		"flip_by_velocity": false,
		"modulate_color": "#ffd08d",
		"loop_animation": false
	},
	"earth_gaia_break_end":
	{
		"dir_path": "res://assets/effects/earth_gaia_break_end/",
		"frame_prefix": "earth_gaia_break_end",
		"frame_count": 6,
		"fps": 14.0,
		"scale": 1.82,
		"flip_by_velocity": false,
		"modulate_color": "#c79f68",
		"loop_animation": false
	},
	"earth_continental_crush_end":
	{
		"dir_path": "res://assets/effects/earth_continental_crush_end/",
		"frame_prefix": "earth_continental_crush_end",
		"frame_count": 6,
		"fps": 13.0,
		"scale": 2.10,
		"flip_by_velocity": false,
		"modulate_color": "#d1a96e",
		"loop_animation": false
	},
	"earth_world_end_break_end":
	{
		"dir_path": "res://assets/effects/earth_world_end_break_end/",
		"frame_prefix": "earth_world_end_break_end",
		"frame_count": 6,
		"fps": 12.0,
		"scale": 2.22,
		"flip_by_velocity": false,
		"modulate_color": "#ddb57b",
		"loop_animation": false
	},
	"fire_hellfire_field_end":
	{
		"dir_path": "res://assets/effects/fire_hellfire_field_end/",
		"frame_prefix": "fire_hellfire_field_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 1.52,
		"flip_by_velocity": false,
		"modulate_color": "#ffb06d",
		"loop_animation": false
	},
	"holy_bless_field_end":
	{
		"dir_path": "res://assets/effects/holy_bless_field_end/",
		"frame_prefix": "holy_bless_field_end",
		"frame_count": 4,
		"fps": 15.0,
		"scale": 1.28,
		"flip_by_velocity": false,
		"modulate_color": "#fff6cf",
		"loop_animation": false
	},
	"holy_sanctuary_of_reversal_end":
	{
		"dir_path": "res://assets/effects/holy_sanctuary_of_reversal_end/",
		"frame_prefix": "holy_sanctuary_of_reversal_end",
		"frame_count": 4,
		"fps": 16.0,
		"scale": 1.36,
		"flip_by_velocity": false,
		"modulate_color": "#fffdf0",
		"loop_animation": false
	},
	"ice_storm_end":
	{
		"dir_path": "res://assets/effects/ice_storm_end/",
		"frame_prefix": "ice_storm_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 1.34,
		"flip_by_velocity": false,
		"modulate_color": "#eafcff",
		"loop_animation": false
	},
	"ice_ice_wall_end":
	{
		"dir_path": "res://assets/effects/ice_ice_wall_end/",
		"frame_prefix": "ice_ice_wall_end",
		"frame_count": 7,
		"fps": 14.0,
		"scale": 1.52,
		"flip_by_velocity": false,
		"modulate_color": "#f7ffff",
		"loop_animation": false
	},
	"earth_stone_rampart_end":
	{
		"dir_path": "res://assets/effects/earth_stone_rampart_end/",
		"frame_prefix": "earth_stone_rampart_end",
		"frame_count": 9,
		"fps": 12.0,
		"scale": 1.46,
		"flip_by_velocity": false,
		"modulate_color": "#efddba",
		"loop_animation": false
	},
	"ice_absolute_zero_end":
	{
		"dir_path": "res://assets/effects/ice_absolute_zero_end/",
		"frame_prefix": "ice_absolute_zero_end",
		"frame_count": 4,
		"fps": 12.0,
		"scale": 1.84,
		"flip_by_velocity": false,
		"modulate_color": "#f3ffff",
		"loop_animation": false
	},
	"plant_vine_snare_end":
	{
		"dir_path": "res://assets/effects/plant_vine_snare_end/",
		"frame_prefix": "plant_vine_snare_end",
		"frame_count": 4,
		"fps": 15.0,
		"scale": 1.30,
		"flip_by_velocity": false,
		"modulate_color": "#def0b8",
		"loop_animation": false
	},
	"plant_world_root_end":
	{
		"dir_path": "res://assets/effects/plant_world_root_end/",
		"frame_prefix": "plant_world_root_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 1.44,
		"flip_by_velocity": false,
		"modulate_color": "#dceec1",
		"loop_animation": false
	},
	"plant_worldroot_bastion_end":
	{
		"dir_path": "res://assets/effects/plant_worldroot_bastion_end/",
		"frame_prefix": "plant_worldroot_bastion_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 1.54,
		"flip_by_velocity": false,
		"modulate_color": "#deedc0",
		"loop_animation": false
	},
	"dark_shadow_bind_end":
	{
		"dir_path": "res://assets/effects/dark_shadow_bind_end/",
		"frame_prefix": "dark_shadow_bind_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 1.18,
		"flip_by_velocity": false,
		"modulate_color": "#e1d6f3",
		"loop_animation": false
	},
	"plant_genesis_arbor_end":
	{
		"dir_path": "res://assets/effects/plant_genesis_arbor_end/",
		"frame_prefix": "plant_genesis_arbor_end",
		"frame_count": 4,
		"fps": 14.0,
		"scale": 1.62,
		"flip_by_velocity": false,
		"modulate_color": "#e1f0c3",
		"loop_animation": false
	},
	"water_tsunami_end":
	{
		"dir_path": "res://assets/effects/water_tsunami_end/",
		"frame_prefix": "water_tsunami_end",
		"frame_count": 6,
		"fps": 14.0,
		"scale": 1.48,
		"flip_by_velocity": false,
		"modulate_color": "#d4fbff",
		"loop_animation": false
	},
	"water_ocean_collapse_end":
	{
		"dir_path": "res://assets/effects/water_ocean_collapse_end/",
		"frame_prefix": "water_ocean_collapse_end",
		"frame_count": 6,
		"fps": 13.0,
		"scale": 1.68,
		"flip_by_velocity": false,
		"modulate_color": "#dcffff",
		"loop_animation": false
	},
	"wind_cyclone_prison_end":
	{
		"dir_path": "res://assets/effects/wind_cyclone_prison_end/",
		"frame_prefix": "wind_cyclone_prison_end",
		"frame_count": 12,
		"fps": 18.0,
		"scale": 1.28,
		"flip_by_velocity": false,
		"modulate_color": "#ecffd8",
		"loop_animation": false
	},
	"holy_judgment_halo_end":
	{
		"dir_path": "res://assets/effects/holy_judgment_halo_end/",
		"frame_prefix": "holy_judgment_halo_end",
		"frame_count": 12,
		"fps": 18.0,
		"scale": 1.58,
		"flip_by_velocity": false,
		"modulate_color": "#fff7de",
		"loop_animation": false
	},
	"water_aqua_geyser_end":
	{
		"dir_path": "res://assets/effects/water_aqua_geyser_end/",
		"frame_prefix": "water_aqua_geyser_end",
		"frame_count": 12,
		"fps": 18.0,
		"scale": 1.24,
		"flip_by_velocity": false,
		"modulate_color": "#e9fcff",
		"loop_animation": false
	}
}

var velocity := Vector2.ZERO
var remaining_range := 0.0
var team := "player"
var damage := 0
var total_damage := 0
var knockback := 0.0
var school := "fire"
var hit_targets: Dictionary = {}
var active_multi_hit_sequences: Dictionary = {}
var duration := 3.0
var pierce := 0
var radius := 10.0
var owner_ref: Node = null
var spell_id := ""
var utility_effects: Array = []
var support_self_heal := 0
var support_effects: Array = []
var support_effect_duration := 0.0
var multi_hit_count := 1
var hit_interval := 0.0
var hit_damage_sequence: Array[int] = []
var pending_sequence_hits := 0
var finish_after_multi_hit_sequences := false
var multi_hit_suspended := false
var is_marker := false
var horizontal_drag_per_second := 0.0
var min_horizontal_speed := 0.0
var gravity_per_second := 0.0
var attack_effect_id := ""
var hit_effect_id := ""
var terminal_effect_id := ""
var terminal_effect_played := false
var hitstop_mode := "default"
var tick_interval := 0.0
var tick_timer := 0.0
var max_targets_per_tick := 0
var tracked_bodies: Dictionary = {}
var pull_strength := 0.0
var visual_scale_multiplier := 1.0
var visual_color := Color.WHITE

const GROUND_TELEGRAPH_MIN_RADIUS := 96.0
const GROUND_TELEGRAPH_VERTICAL_SCALE := 0.42
const GROUND_TELEGRAPH_STARTUP_DURATION := 0.24
const GROUND_TELEGRAPH_STARTUP_INITIAL_SCALE := 0.72
const GROUND_TELEGRAPH_STARTUP_EXPAND_SCALE := 1.10
const TERMINAL_FLASH_DURATION := 0.22
const TERMINAL_FLASH_INITIAL_SCALE := 0.82
const TERMINAL_FLASH_EXPAND_SCALE := 1.18
const TELEGRAPH_PHASE_SCHOOL_PROFILES := {
	"default":
	{
		"accent_color": "#ffffff",
		"accent_mix": 0.42,
		"startup_duration": 0.24,
		"startup_width_scale": 0.08,
		"startup_radius_scale": 0.82,
		"startup_expand_scale": 1.10,
		"startup_color_lighten": 0.40,
		"startup_alpha": 0.92,
		"terminal_duration": 0.22,
		"terminal_fill_alpha_burst": 0.20,
		"terminal_fill_alpha_persistent": 0.24,
		"terminal_fill_lighten": 0.18,
		"terminal_outline_lighten": 0.52,
		"terminal_outline_width_scale": 0.08,
		"terminal_fill_radius_scale": 0.78,
		"terminal_outline_radius_scale": 0.96,
		"terminal_expand_scale": 1.18
	},
	"fire":
	{
		"accent_color": "#ffb15d",
		"accent_mix": 0.48,
		"startup_duration": 0.20,
		"startup_width_scale": 0.09,
		"startup_radius_scale": 0.80,
		"startup_expand_scale": 1.18,
		"terminal_duration": 0.24,
		"terminal_fill_alpha_burst": 0.24,
		"terminal_fill_alpha_persistent": 0.28,
		"terminal_outline_width_scale": 0.09,
		"terminal_expand_scale": 1.26
	},
	"ice":
	{
		"accent_color": "#dff8ff",
		"accent_mix": 0.44,
		"startup_duration": 0.28,
		"startup_width_scale": 0.065,
		"startup_radius_scale": 0.88,
		"startup_expand_scale": 1.05,
		"terminal_duration": 0.26,
		"terminal_fill_alpha_burst": 0.18,
		"terminal_fill_alpha_persistent": 0.22,
		"terminal_outline_width_scale": 0.07,
		"terminal_expand_scale": 1.12
	},
	"lightning":
	{
		"accent_color": "#fff7bc",
		"accent_mix": 0.50,
		"startup_duration": 0.18,
		"startup_width_scale": 0.10,
		"startup_radius_scale": 0.78,
		"startup_expand_scale": 1.22,
		"terminal_duration": 0.18,
		"terminal_fill_alpha_burst": 0.22,
		"terminal_fill_alpha_persistent": 0.26,
		"terminal_outline_width_scale": 0.085,
		"terminal_expand_scale": 1.30
	},
	"holy":
	{
		"accent_color": "#fff8e3",
		"accent_mix": 0.46,
		"startup_duration": 0.24,
		"startup_width_scale": 0.075,
		"startup_radius_scale": 0.84,
		"startup_expand_scale": 1.12,
		"terminal_duration": 0.24,
		"terminal_outline_width_scale": 0.08,
		"terminal_expand_scale": 1.20
	},
	"dark":
	{
		"accent_color": "#d6c6ff",
		"accent_mix": 0.46,
		"startup_duration": 0.27,
		"startup_width_scale": 0.075,
		"startup_radius_scale": 0.86,
		"startup_expand_scale": 1.04,
		"terminal_duration": 0.30,
		"terminal_fill_alpha_burst": 0.16,
		"terminal_fill_alpha_persistent": 0.20,
		"terminal_outline_lighten": 0.40,
		"terminal_outline_width_scale": 0.075,
		"terminal_expand_scale": 1.12
	},
	"earth":
	{
		"accent_color": "#e9d1a1",
		"accent_mix": 0.44,
		"startup_duration": 0.30,
		"startup_width_scale": 0.11,
		"startup_radius_scale": 0.90,
		"startup_expand_scale": 1.02,
		"terminal_duration": 0.28,
		"terminal_fill_alpha_burst": 0.22,
		"terminal_fill_alpha_persistent": 0.26,
		"terminal_outline_width_scale": 0.11,
		"terminal_expand_scale": 1.10
	},
	"wind":
	{
		"accent_color": "#e6ffe3",
		"accent_mix": 0.48,
		"startup_duration": 0.19,
		"startup_width_scale": 0.06,
		"startup_radius_scale": 0.76,
		"startup_expand_scale": 1.20,
		"terminal_duration": 0.17,
		"terminal_fill_alpha_burst": 0.18,
		"terminal_fill_alpha_persistent": 0.22,
		"terminal_outline_width_scale": 0.06,
		"terminal_expand_scale": 1.28
	},
	"water":
	{
		"accent_color": "#d8fbff",
		"accent_mix": 0.44,
		"startup_duration": 0.22,
		"startup_width_scale": 0.07,
		"startup_radius_scale": 0.84,
		"startup_expand_scale": 1.14,
		"terminal_duration": 0.20,
		"terminal_fill_alpha_burst": 0.22,
		"terminal_fill_alpha_persistent": 0.26,
		"terminal_outline_width_scale": 0.075,
		"terminal_expand_scale": 1.16
	},
	"plant":
	{
		"accent_color": "#d8f4bb",
		"accent_mix": 0.44,
		"startup_duration": 0.26,
		"startup_width_scale": 0.085,
		"startup_radius_scale": 0.86,
		"startup_expand_scale": 1.08,
		"terminal_duration": 0.24,
		"terminal_fill_alpha_burst": 0.18,
		"terminal_fill_alpha_persistent": 0.22,
		"terminal_outline_width_scale": 0.085,
		"terminal_expand_scale": 1.14
	},
	"arcane":
	{
		"accent_color": "#f0d6ff",
		"accent_mix": 0.46,
		"startup_duration": 0.21,
		"startup_width_scale": 0.08,
		"startup_radius_scale": 0.80,
		"startup_expand_scale": 1.16,
		"terminal_duration": 0.21,
		"terminal_outline_width_scale": 0.08,
		"terminal_expand_scale": 1.22
	}
}
const TELEGRAPH_PHASE_SIGNATURE_OVERRIDES := {
	"fire_inferno_buster":
	{
		"accent_color": "#ff9c4f",
		"startup_duration": 0.17,
		"startup_width_scale": 0.095,
		"startup_radius_scale": 0.76,
		"startup_expand_scale": 1.24,
		"terminal_duration": 0.20,
		"terminal_outline_width_scale": 0.085,
		"terminal_fill_radius_scale": 0.74,
		"terminal_expand_scale": 1.20
	},
	"wind_storm":
	{
		"accent_color": "#d8ffd3",
		"accent_mix": 0.48,
		"startup_duration": 0.20,
		"startup_width_scale": 0.072,
		"startup_radius_scale": 0.80,
		"startup_expand_scale": 1.10,
		"terminal_duration": 0.18,
		"terminal_outline_width_scale": 0.076,
		"terminal_fill_radius_scale": 0.72,
		"terminal_expand_scale": 1.12
	},
	"fire_meteor_strike":
	{
		"accent_color": "#ffd7a8",
		"accent_mix": 0.52,
		"startup_duration": 0.23,
		"startup_width_scale": 0.10,
		"startup_radius_scale": 0.84,
		"startup_expand_scale": 1.28,
		"terminal_duration": 0.24,
		"terminal_fill_alpha_burst": 0.22,
		"terminal_outline_width_scale": 0.09,
		"terminal_fill_radius_scale": 0.78,
		"terminal_expand_scale": 1.28
	},
	"fire_apocalypse_flame":
	{
		"accent_color": "#ffe5bf",
		"accent_mix": 0.55,
		"startup_duration": 0.25,
		"startup_width_scale": 0.102,
		"startup_radius_scale": 0.88,
		"startup_expand_scale": 1.30,
		"terminal_duration": 0.28,
		"terminal_fill_alpha_burst": 0.26,
		"terminal_fill_alpha_persistent": 0.30,
		"terminal_outline_width_scale": 0.095,
		"terminal_fill_radius_scale": 0.82,
		"terminal_outline_radius_scale": 1.02,
		"terminal_expand_scale": 1.34
	},
	"fire_solar_cataclysm":
	{
		"accent_color": "#fff3c7",
		"accent_mix": 0.58,
		"startup_duration": 0.27,
		"startup_width_scale": 0.105,
		"startup_radius_scale": 0.90,
		"startup_expand_scale": 1.34,
		"terminal_duration": 0.31,
		"terminal_fill_alpha_burst": 0.28,
		"terminal_fill_alpha_persistent": 0.32,
		"terminal_outline_width_scale": 0.10,
		"terminal_fill_radius_scale": 0.86,
		"terminal_outline_radius_scale": 1.04,
		"terminal_expand_scale": 1.38
	},
	"earth_gaia_break":
	{
		"accent_color": "#ddbe88",
		"accent_mix": 0.46,
		"startup_duration": 0.26,
		"startup_width_scale": 0.115,
		"startup_radius_scale": 0.88,
		"startup_expand_scale": 1.06,
		"terminal_duration": 0.24,
		"terminal_fill_alpha_burst": 0.20,
		"terminal_fill_alpha_persistent": 0.24,
		"terminal_outline_width_scale": 0.11,
		"terminal_fill_radius_scale": 0.78,
		"terminal_outline_radius_scale": 1.00,
		"terminal_expand_scale": 1.08
	},
	"earth_continental_crush":
	{
		"accent_color": "#ead0a1",
		"accent_mix": 0.48,
		"startup_duration": 0.31,
		"startup_width_scale": 0.122,
		"startup_radius_scale": 0.91,
		"startup_expand_scale": 1.10,
		"terminal_duration": 0.29,
		"terminal_fill_alpha_burst": 0.22,
		"terminal_fill_alpha_persistent": 0.26,
		"terminal_outline_width_scale": 0.12,
		"terminal_fill_radius_scale": 0.80,
		"terminal_outline_radius_scale": 1.01,
		"terminal_expand_scale": 1.12
	},
	"earth_tremor":
	{
		"accent_color": "#d6bb8a",
		"accent_mix": 0.48,
		"startup_duration": 0.21,
		"startup_width_scale": 0.092,
		"startup_radius_scale": 0.82,
		"startup_expand_scale": 1.04,
		"terminal_duration": 0.20,
		"terminal_fill_alpha_burst": 0.20,
		"terminal_fill_alpha_persistent": 0.24,
		"terminal_outline_width_scale": 0.09,
		"terminal_fill_radius_scale": 0.80,
		"terminal_outline_radius_scale": 1.00,
		"terminal_expand_scale": 1.04
	},
	"plant_vine_snare":
	{
		"accent_color": "#c9f08b",
		"accent_mix": 0.50,
		"startup_duration": 0.20,
		"startup_width_scale": 0.10,
		"startup_radius_scale": 0.78,
		"startup_expand_scale": 1.02,
		"terminal_duration": 0.21,
		"terminal_fill_alpha_burst": 0.20,
		"terminal_fill_alpha_persistent": 0.24,
		"terminal_outline_width_scale": 0.095,
		"terminal_fill_radius_scale": 0.82,
		"terminal_outline_radius_scale": 1.01,
		"terminal_expand_scale": 1.04
	},
	"water_aqua_geyser":
	{
		"accent_color": "#dff9ff",
		"accent_mix": 0.52,
		"startup_duration": 0.18,
		"startup_width_scale": 0.085,
		"startup_radius_scale": 0.74,
		"startup_expand_scale": 1.18,
		"terminal_duration": 0.22,
		"terminal_fill_alpha_burst": 0.22,
		"terminal_fill_alpha_persistent": 0.26,
		"terminal_outline_width_scale": 0.08,
		"terminal_fill_radius_scale": 0.76,
		"terminal_outline_radius_scale": 1.02,
		"terminal_expand_scale": 1.20
	},
	"earth_world_end_break":
	{
		"accent_color": "#f0ddb4",
		"accent_mix": 0.50,
		"startup_duration": 0.36,
		"startup_width_scale": 0.13,
		"startup_radius_scale": 0.94,
		"terminal_duration": 0.34,
		"terminal_fill_alpha_burst": 0.24,
		"terminal_fill_alpha_persistent": 0.28,
		"terminal_outline_width_scale": 0.13,
		"terminal_fill_radius_scale": 0.82,
		"terminal_outline_radius_scale": 1.02,
		"terminal_expand_scale": 1.16
	},
	"ice_absolute_freeze":
	{
		"accent_color": "#eefcff",
		"accent_mix": 0.50,
		"startup_duration": 0.25,
		"startup_width_scale": 0.075,
		"startup_radius_scale": 0.84,
		"startup_expand_scale": 1.08,
		"terminal_duration": 0.24,
		"terminal_fill_alpha_burst": 0.20,
		"terminal_outline_width_scale": 0.075,
		"terminal_fill_radius_scale": 0.76,
		"terminal_expand_scale": 1.16
	},
	"ice_absolute_zero":
	{
		"accent_color": "#fbffff",
		"accent_mix": 0.56,
		"startup_duration": 0.35,
		"startup_width_scale": 0.095,
		"startup_radius_scale": 0.94,
		"startup_expand_scale": 1.12,
		"terminal_duration": 0.33,
		"terminal_fill_alpha_burst": 0.24,
		"terminal_outline_width_scale": 0.095,
		"terminal_fill_radius_scale": 0.84,
		"terminal_outline_radius_scale": 1.02,
		"terminal_expand_scale": 1.22
	},
	"ice_ice_wall":
	{
		"accent_color": "#f4feff",
		"accent_mix": 0.58,
		"startup_duration": 0.22,
		"startup_width_scale": 0.14,
		"startup_radius_scale": 0.98,
		"startup_expand_scale": 1.06,
		"terminal_duration": 0.30,
		"terminal_fill_alpha_burst": 0.24,
		"terminal_fill_alpha_persistent": 0.30,
		"terminal_outline_width_scale": 0.13,
		"terminal_fill_radius_scale": 0.84,
		"terminal_outline_radius_scale": 1.05,
		"terminal_expand_scale": 1.10
	},
	"earth_stone_rampart":
	{
		"accent_color": "#ead0a5",
		"accent_mix": 0.50,
		"startup_duration": 0.24,
		"startup_width_scale": 0.15,
		"startup_radius_scale": 0.96,
		"startup_expand_scale": 1.04,
		"terminal_duration": 0.28,
		"terminal_fill_alpha_burst": 0.22,
		"terminal_fill_alpha_persistent": 0.28,
		"terminal_outline_width_scale": 0.14,
		"terminal_fill_radius_scale": 0.82,
		"terminal_outline_radius_scale": 1.04,
		"terminal_expand_scale": 1.08
	},
	"holy_judgment_halo":
	{
		"accent_color": "#fff9ea",
		"accent_mix": 0.54,
		"startup_duration": 0.18,
		"startup_width_scale": 0.07,
		"startup_radius_scale": 0.76,
		"startup_expand_scale": 1.18,
		"terminal_duration": 0.20,
		"terminal_outline_width_scale": 0.075,
		"terminal_fill_radius_scale": 0.74,
		"terminal_expand_scale": 1.24
	},
	"holy_bless_field":
	{
		"accent_color": "#fff1ba",
		"accent_mix": 0.52,
		"startup_duration": 0.27,
		"startup_width_scale": 0.086,
		"startup_radius_scale": 0.88,
		"startup_expand_scale": 1.08,
		"terminal_duration": 0.27,
		"terminal_fill_alpha_burst": 0.18,
		"terminal_fill_alpha_persistent": 0.24,
		"terminal_outline_width_scale": 0.09,
		"terminal_fill_radius_scale": 0.80,
		"terminal_outline_radius_scale": 1.00,
		"terminal_expand_scale": 1.12
	},
	"holy_sanctuary_of_reversal":
	{
		"accent_color": "#fff8e6",
		"accent_mix": 0.60,
		"startup_duration": 0.22,
		"startup_width_scale": 0.10,
		"startup_radius_scale": 0.84,
		"startup_expand_scale": 1.16,
		"terminal_duration": 0.24,
		"terminal_fill_alpha_burst": 0.22,
		"terminal_fill_alpha_persistent": 0.18,
		"terminal_outline_width_scale": 0.10,
		"terminal_fill_radius_scale": 0.76,
		"terminal_outline_radius_scale": 1.02,
		"terminal_expand_scale": 1.18
	},
	"plant_genesis_arbor":
	{
		"accent_color": "#e4f8ca",
		"accent_mix": 0.50,
		"startup_duration": 0.33,
		"startup_width_scale": 0.10,
		"startup_radius_scale": 0.96,
		"startup_expand_scale": 1.12,
		"terminal_duration": 0.32,
		"terminal_fill_alpha_burst": 0.20,
		"terminal_fill_alpha_persistent": 0.26,
		"terminal_outline_width_scale": 0.10,
		"terminal_fill_radius_scale": 0.86,
		"terminal_expand_scale": 1.18
	},
	"wind_heavenly_storm":
	{
		"accent_color": "#efffe8",
		"accent_mix": 0.50,
		"startup_duration": 0.24,
		"startup_width_scale": 0.078,
		"startup_radius_scale": 0.88,
		"startup_expand_scale": 1.14,
		"terminal_duration": 0.22,
		"terminal_fill_alpha_burst": 0.18,
		"terminal_fill_alpha_persistent": 0.20,
		"terminal_outline_width_scale": 0.082,
		"terminal_fill_radius_scale": 0.80,
		"terminal_outline_radius_scale": 1.03,
		"terminal_expand_scale": 1.16
	}
}


func setup(config: Dictionary) -> void:
	position = config.get("position", Vector2.ZERO)
	velocity = config.get("velocity", Vector2.ZERO)
	remaining_range = float(config.get("range", 100.0))
	team = str(config.get("team", "player"))
	damage = int(config.get("damage", 10))
	total_damage = int(config.get("total_damage", damage))
	knockback = float(config.get("knockback", 100.0))
	school = str(config.get("school", "fire"))
	duration = float(config.get("duration", 3.0))
	pierce = int(config.get("pierce", 0))
	radius = float(config.get("size", 10.0))
	owner_ref = config.get("owner", null)
	spell_id = str(config.get("spell_id", ""))
	utility_effects = config.get("utility_effects", []).duplicate(true)
	support_self_heal = int(config.get("self_heal", 0))
	support_effects = config.get("support_effects", []).duplicate(true)
	support_effect_duration = maxf(float(config.get("support_effect_duration", 0.0)), 0.0)
	multi_hit_count = maxi(1, int(config.get("multi_hit_count", 1)))
	hit_interval = maxf(float(config.get("hit_interval", 0.0)), 0.0)
	hit_damage_sequence = _split_total_damage_across_hits(total_damage, multi_hit_count)
	is_marker = bool(config.get("marker", false))
	horizontal_drag_per_second = float(config.get("horizontal_drag_per_second", 0.0))
	min_horizontal_speed = float(config.get("min_horizontal_speed", 0.0))
	gravity_per_second = float(config.get("gravity_per_second", 0.0))
	attack_effect_id = str(config.get("attack_effect_id", ""))
	hit_effect_id = str(config.get("hit_effect_id", ""))
	terminal_effect_id = str(config.get("terminal_effect_id", ""))
	hitstop_mode = str(config.get("hitstop_mode", "default"))
	tick_interval = maxf(float(config.get("tick_interval", 0.0)), 0.0)
	tick_timer = 0.0
	max_targets_per_tick = int(config.get("target_count", 0))
	pull_strength = maxf(float(config.get("pull_strength", 0.0)), 0.0)
	visual_color = Color(config.get("color", "#ffffff"))
	visual_scale_multiplier = _resolve_visual_scale_multiplier()
	_build_visual(visual_color)
	_build_ground_telegraph()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var shape: CollisionShape2D
	if not has_node("CollisionShape2D"):
		shape = CollisionShape2D.new()
		shape.name = "CollisionShape2D"
		add_child(shape)
		shape.shape = CircleShape2D.new()
	else:
		shape = get_node("CollisionShape2D")
	shape.shape.radius = radius
	_play_attack_effect()
	_play_ground_telegraph_intro()


func _physics_process(delta: float) -> void:
	if terminal_effect_played:
		return
	_tick_hit_windows(delta)
	_tick_persistent_hits(delta)
	_apply_persistent_pull(delta)
	_apply_runtime_motion(delta)
	position += velocity * delta
	remaining_range -= velocity.length() * delta
	duration -= delta
	if remaining_range <= 0.0 or duration <= 0.0:
		_finish_projectile()


func _apply_runtime_motion(delta: float) -> void:
	if gravity_per_second != 0.0:
		velocity.y += gravity_per_second * delta
	if horizontal_drag_per_second > 0.0 and velocity.x != 0.0:
		var target_speed := 0.0
		if min_horizontal_speed > 0.0:
			target_speed = sign(velocity.x) * min_horizontal_speed
		velocity.x = move_toward(velocity.x, target_speed, horizontal_drag_per_second * delta)


func _on_body_entered(body: Node) -> void:
	if body == owner_ref:
		return
	tracked_bodies[body.get_instance_id()] = body
	if _is_support_only_area_effect():
		return
	if team == "player" and body.is_in_group("enemy"):
		_hit_enemy(body, _should_finish_on_body_hit())
	elif team == "enemy" and body.is_in_group("player"):
		_hit_player(body, _should_finish_on_body_hit())


func _on_body_exited(body: Node) -> void:
	tracked_bodies.erase(body.get_instance_id())


func _hit_enemy(body: Node, finish_on_hit: bool = true) -> bool:
	var body_id := body.get_instance_id()
	if not _can_hit_body(body_id) or active_multi_hit_sequences.has(body_id):
		return false
	_register_body_hit(body_id)
	active_multi_hit_sequences[body_id] = true
	var impact_position := _resolve_hit_position(body, global_position)
	_apply_enemy_sequence_hit(body, 0, impact_position)
	if multi_hit_count > 1:
		_queue_enemy_follow_up_hit(body, body_id, 1, impact_position)
	else:
		active_multi_hit_sequences.erase(body_id)
	_resolve_contact_finish(finish_on_hit)
	return true


func _hit_player(body: Node, finish_on_hit: bool = true) -> bool:
	var body_id := body.get_instance_id()
	if not _can_hit_body(body_id) or active_multi_hit_sequences.has(body_id):
		return false
	_register_body_hit(body_id)
	active_multi_hit_sequences[body_id] = true
	var impact_position := _resolve_hit_position(body, global_position)
	_apply_player_sequence_hit(body, 0, impact_position)
	if multi_hit_count > 1:
		_queue_player_follow_up_hit(body, body_id, 1, impact_position)
	else:
		active_multi_hit_sequences.erase(body_id)
	_resolve_contact_finish(finish_on_hit)
	return true


func _resolve_contact_finish(finish_on_hit: bool) -> void:
	if not finish_on_hit:
		return
	if pierce > 0:
		pierce -= 1
		_queue_pierce_resume()
		return
	if pending_sequence_hits > 0:
		_suspend_until_multi_hit_sequences_finish()
		return
	_finish_projectile()


func _apply_enemy_sequence_hit(body: Node, hit_index: int, impact_position: Vector2) -> void:
	if not is_instance_valid(body):
		return
	_spawn_hit_effect(impact_position)
	var hit_damage := _resolve_damage_for_hit_index(hit_index)
	var actual_damage := hit_damage
	if body.has_method("receive_hit"):
		var hit_result = body.receive_hit(
			hit_damage,
			impact_position,
			knockback,
			school,
			_resolve_utility_effects_for_hit(hit_index)
		)
		if typeof(hit_result) == TYPE_INT:
			actual_damage = int(hit_result)
		if team == "player" and spell_id != "":
			GameState.register_skill_damage(spell_id, actual_damage)
		if team == "player" and hit_index == 0:
			var hitstop_duration := _get_hitstop_duration(actual_damage)
			if hitstop_duration > 0.0:
				_trigger_hitstop(hitstop_duration)


func _apply_player_sequence_hit(body: Node, hit_index: int, impact_position: Vector2) -> void:
	if not is_instance_valid(body):
		return
	_spawn_hit_effect(impact_position)
	if body.has_method("receive_hit"):
		body.receive_hit(
			_resolve_damage_for_hit_index(hit_index),
			impact_position,
			knockback,
			school,
			_resolve_utility_effects_for_hit(hit_index)
		)


func _queue_enemy_follow_up_hit(
	body: Node, body_id: int, hit_index: int, fallback_position: Vector2
) -> void:
	if hit_index >= multi_hit_count:
		active_multi_hit_sequences.erase(body_id)
		_flush_multi_hit_completion()
		return
	var tree := get_tree()
	if tree == null:
		active_multi_hit_sequences.erase(body_id)
		_flush_multi_hit_completion()
		return
	pending_sequence_hits += 1
	var timer := tree.create_timer(hit_interval)
	timer.timeout.connect(
		func() -> void:
			pending_sequence_hits = maxi(pending_sequence_hits - 1, 0)
			if not is_instance_valid(self):
				return
			if not active_multi_hit_sequences.has(body_id):
				_flush_multi_hit_completion()
				return
			if not is_instance_valid(body):
				active_multi_hit_sequences.erase(body_id)
				_flush_multi_hit_completion()
				return
			var impact_position := _resolve_hit_position(body, fallback_position)
			_apply_enemy_sequence_hit(body, hit_index, impact_position)
			_queue_enemy_follow_up_hit(body, body_id, hit_index + 1, impact_position),
		CONNECT_ONE_SHOT
	)


func _queue_player_follow_up_hit(
	body: Node, body_id: int, hit_index: int, fallback_position: Vector2
) -> void:
	if hit_index >= multi_hit_count:
		active_multi_hit_sequences.erase(body_id)
		_flush_multi_hit_completion()
		return
	var tree := get_tree()
	if tree == null:
		active_multi_hit_sequences.erase(body_id)
		_flush_multi_hit_completion()
		return
	pending_sequence_hits += 1
	var timer := tree.create_timer(hit_interval)
	timer.timeout.connect(
		func() -> void:
			pending_sequence_hits = maxi(pending_sequence_hits - 1, 0)
			if not is_instance_valid(self):
				return
			if not active_multi_hit_sequences.has(body_id):
				_flush_multi_hit_completion()
				return
			if not is_instance_valid(body):
				active_multi_hit_sequences.erase(body_id)
				_flush_multi_hit_completion()
				return
			var impact_position := _resolve_hit_position(body, fallback_position)
			_apply_player_sequence_hit(body, hit_index, impact_position)
			_queue_player_follow_up_hit(body, body_id, hit_index + 1, impact_position),
		CONNECT_ONE_SHOT
	)


func _flush_multi_hit_completion() -> void:
	if pending_sequence_hits > 0:
		return
	if active_multi_hit_sequences.size() > 0:
		return
	if finish_after_multi_hit_sequences:
		finish_after_multi_hit_sequences = false
		_finish_projectile()


func _resolve_hit_position(body: Node, fallback_position: Vector2) -> Vector2:
	var body_node := body as Node2D
	if body_node != null and is_instance_valid(body_node):
		return body_node.global_position
	return fallback_position


func _resolve_damage_for_hit_index(hit_index: int) -> int:
	if hit_index >= 0 and hit_index < hit_damage_sequence.size():
		return int(hit_damage_sequence[hit_index])
	return damage


func _resolve_utility_effects_for_hit(hit_index: int) -> Array:
	if multi_hit_count <= 1 or hit_index == 0:
		return utility_effects.duplicate(true)
	return []


func _split_total_damage_across_hits(total_damage_value: int, hit_count: int) -> Array[int]:
	var safe_hit_count: int = maxi(hit_count, 1)
	var split: Array[int] = []
	var base_damage := int(total_damage_value / safe_hit_count)
	var remainder := int(total_damage_value % safe_hit_count)
	for hit_idx in range(safe_hit_count):
		split.append(base_damage + (1 if hit_idx < remainder else 0))
	return split


func _queue_pierce_resume() -> void:
	if not is_inside_tree():
		return
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	if velocity.length() > 0.0:
		global_position += velocity.normalized() * max(radius * 1.5, 18.0)
	call_deferred("_resume_after_pierce")


func _resume_after_pierce() -> void:
	if not is_inside_tree():
		return
	await get_tree().physics_frame
	if not is_inside_tree():
		return
	monitoring = true
	monitorable = true


func _tick_persistent_hits(delta: float) -> void:
	if not _is_persistent_area_effect():
		return
	tick_timer = maxf(tick_timer - delta, 0.0)
	if tick_timer > 0.0:
		return
	tick_timer = tick_interval
	_apply_owner_support_tick()
	var hit_count := 0
	for body_id in tracked_bodies.keys():
		var body = tracked_bodies.get(body_id, null)
		if not is_instance_valid(body):
			tracked_bodies.erase(body_id)
			continue
		if body == owner_ref:
			continue
		if _is_support_only_area_effect():
			continue
		var hit_applied := false
		if team == "player" and body.is_in_group("enemy"):
			hit_applied = _hit_enemy(body, false)
		elif team == "enemy" and body.is_in_group("player"):
			hit_applied = _hit_player(body, false)
		if hit_applied:
			hit_count += 1
			if max_targets_per_tick > 0 and hit_count >= max_targets_per_tick:
				break


func _tick_hit_windows(delta: float) -> void:
	if not _is_persistent_area_effect():
		return
	for body_id in hit_targets.keys():
		var remaining := maxf(float(hit_targets.get(body_id, 0.0)) - delta, 0.0)
		if remaining <= 0.0:
			hit_targets.erase(body_id)
		else:
			hit_targets[body_id] = remaining


func _can_hit_body(body_id: int) -> bool:
	if not _is_persistent_area_effect():
		return not hit_targets.get(body_id, false)
	return float(hit_targets.get(body_id, 0.0)) <= 0.0


func _register_body_hit(body_id: int) -> void:
	if _is_persistent_area_effect():
		hit_targets[body_id] = maxf(tick_interval, 0.01)
		return
	hit_targets[body_id] = true


func _apply_persistent_pull(delta: float) -> void:
	if pull_strength <= 0.0 or not _is_persistent_area_effect():
		return
	var deadzone := maxf(radius * 0.14, 8.0)
	for body_id in tracked_bodies.keys():
		var body = tracked_bodies.get(body_id, null)
		if not is_instance_valid(body):
			tracked_bodies.erase(body_id)
			continue
		if body == owner_ref:
			continue
		var target := body as Node2D
		if target == null:
			continue
		var to_center := global_position - target.global_position
		var distance := to_center.length()
		if distance <= deadzone:
			continue
		var step := minf(pull_strength * delta, distance - deadzone)
		if step <= 0.0:
			continue
		target.global_position += to_center.normalized() * step


func _is_persistent_area_effect() -> bool:
	return tick_interval > 0.0


func _is_support_only_area_effect() -> bool:
	return (
		team == "player"
		and tick_interval > 0.0
		and damage <= 0
		and utility_effects.is_empty()
		and (support_self_heal > 0 or not support_effects.is_empty())
	)


func _apply_owner_support_tick() -> void:
	if team != "player" or owner_ref == null or not is_instance_valid(owner_ref):
		return
	var owner_node := owner_ref as Node2D
	if owner_node == null:
		return
	if owner_node.global_position.distance_to(global_position) > radius:
		return
	var applied := false
	if support_self_heal > 0:
		var healed := GameState.apply_direct_heal(support_self_heal)
		applied = healed > 0
	if not support_effects.is_empty():
		var effect_duration := support_effect_duration
		if effect_duration <= 0.0:
			effect_duration = maxf(tick_interval + 0.15, 0.2)
		GameState.refresh_field_support_effects(spell_id, support_effects, effect_duration)
		applied = true
	if applied and hit_effect_id != "":
		_spawn_hit_effect(owner_node.global_position + Vector2(0, -10))


func _should_finish_on_body_hit() -> bool:
	if _is_persistent_area_effect():
		return false
	return not _is_stationary_burst_effect()


func _is_stationary_burst_effect() -> bool:
	return velocity == Vector2.ZERO and duration > 0.0


func _finish_projectile() -> void:
	if terminal_effect_played:
		return
	if pending_sequence_hits > 0:
		_suspend_until_multi_hit_sequences_finish()
		return
	if _play_terminal_effect():
		return
	queue_free()


func _suspend_until_multi_hit_sequences_finish() -> void:
	finish_after_multi_hit_sequences = true
	if multi_hit_suspended:
		return
	multi_hit_suspended = true
	velocity = Vector2.ZERO
	monitoring = false
	monitorable = false
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape != null:
		collision_shape.disabled = true
	set_physics_process(false)


func _play_terminal_effect() -> bool:
	if terminal_effect_played:
		return false
	var sprite := _build_terminal_effect_visual()
	var terminal_flash := _build_terminal_flash()
	if sprite == null and terminal_flash == null:
		return false
	terminal_effect_played = true
	velocity = Vector2.ZERO
	monitoring = false
	monitorable = false
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape != null:
		collision_shape.disabled = true
	var visual_children: Array[Node] = []
	for child in get_children():
		if child == collision_shape:
			continue
		visual_children.append(child)
	for child in visual_children:
		remove_child(child)
		if child.is_inside_tree():
			child.queue_free()
		else:
			child.free()
	if terminal_flash != null:
		add_child(terminal_flash)
		_play_terminal_flash(terminal_flash)
	if sprite != null:
		add_child(sprite)
		sprite.play("fly")
		sprite.animation_finished.connect(
			func() -> void:
				if is_instance_valid(self):
					queue_free(),
			CONNECT_ONE_SHOT
		)
	else:
		var cleanup_tween := create_tween()
		cleanup_tween.tween_interval(TERMINAL_FLASH_DURATION)
		cleanup_tween.tween_callback(
			func() -> void:
				if is_instance_valid(self):
					queue_free()
		)
	set_physics_process(false)
	return true


func _trigger_hitstop(duration: float) -> void:
	var tree := get_tree()
	if tree == null:
		return
	Engine.time_scale = 0.05
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = duration
	timer.ignore_time_scale = true
	tree.root.add_child(timer)
	timer.timeout.connect(
		func() -> void:
			Engine.time_scale = 1.0
			if is_instance_valid(timer):
				timer.queue_free(),
		CONNECT_ONE_SHOT
	)
	timer.start()


func _get_hitstop_duration(actual_damage: int) -> float:
	if _is_persistent_area_effect():
		return 0.0
	match hitstop_mode:
		"none":
			return 0.0
		"area_burst":
			return clampf(0.02 + float(actual_damage) * 0.001, 0.02, 0.06)
		_:
			return clampf(0.03 + float(actual_damage) * 0.002, 0.03, 0.12)


func _play_attack_effect() -> void:
	if attack_effect_id.is_empty():
		return
	var effect_position := _get_attack_effect_position()
	_spawn_world_effect(attack_effect_id, effect_position, "attack")


func _spawn_hit_effect(world_position: Vector2) -> void:
	if hit_effect_id.is_empty():
		return
	_spawn_world_effect(hit_effect_id, world_position, "hit")


func _spawn_world_effect(effect_id: String, world_position: Vector2, effect_stage: String) -> void:
	var sprite := _create_world_effect_visual(effect_id)
	if sprite == null:
		return
	var parent := get_parent()
	if parent == null:
		return
	sprite.name = "%s_sprite" % effect_id
	sprite.set_meta("effect_id", effect_id)
	sprite.set_meta("effect_stage", effect_stage)
	parent.add_child(sprite)
	sprite.global_position = world_position
	world_effect_spawned.emit(effect_id, effect_stage)
	sprite.play("fly")
	sprite.animation_finished.connect(
		func() -> void:
			if is_instance_valid(sprite):
				sprite.queue_free(),
		CONNECT_ONE_SHOT
	)


func _get_attack_effect_position() -> Vector2:
	if (
		spell_id == "water_tidal_ring"
		or spell_id == "water_aqua_geyser"
		or spell_id == "holy_judgment_halo"
		or spell_id == "earth_tremor"
		or spell_id == "fire_inferno_sigil"
		or spell_id == "fire_flame_storm"
		or spell_id == "fire_hellfire_field"
		or spell_id == "holy_bless_field"
		or spell_id == "holy_sanctuary_of_reversal"
		or spell_id == "ice_storm"
		or spell_id == "ice_ice_wall"
		or spell_id == "earth_stone_rampart"
		or spell_id == "dark_shadow_bind"
		or spell_id == "plant_vine_snare"
		or spell_id == "plant_world_root"
		or spell_id == "plant_worldroot_bastion"
		or spell_id == "plant_genesis_arbor"
	):
		return global_position + Vector2(0, -6)
	var travel_dir := _get_visual_facing_sign()
	return global_position + Vector2(-18.0 * travel_dir, -6.0)


func _get_visual_facing_sign() -> float:
	if velocity.x != 0.0:
		return sign(velocity.x)
	if owner_ref != null:
		return float(owner_ref.get("facing"))
	return 1.0


func has_world_effect_spec(effect_id: String) -> bool:
	return WORLD_EFFECT_SPECS.has(effect_id)


func get_world_effect_ids() -> Array[String]:
	var effect_ids: Array[String] = []
	for effect_id in WORLD_EFFECT_SPECS.keys():
		effect_ids.append(str(effect_id))
	effect_ids.sort()
	return effect_ids


func _create_world_effect_visual(effect_id: String) -> AnimatedSprite2D:
	var spec: Dictionary = WORLD_EFFECT_SPECS.get(effect_id, {})
	if spec.is_empty():
		return null
	return _create_sampled_effect_sprite(
		str(spec.get("dir_path", "")),
		str(spec.get("frame_prefix", "")),
		int(spec.get("frame_count", 0)),
		float(spec.get("fps", 18.0)),
		float(spec.get("scale", 1.0)) * visual_scale_multiplier,
		bool(spec.get("flip_by_velocity", true)),
		Color(str(spec.get("modulate_color", "#ffffff"))),
		bool(spec.get("loop_animation", false))
	)


func _build_visual(color: Color) -> void:
	if spell_id == "fire_bolt":
		if _build_fire_bolt_visual():
			return
	elif spell_id == "volt_spear":
		if _build_volt_spear_visual():
			return
	elif spell_id == "frost_nova":
		if _build_frost_nova_visual():
			return
	elif _build_registered_spell_visual(spell_id):
		return
	var polygon := Polygon2D.new()
	polygon.color = color
	if is_marker:
		# Flat ground-level diamond: wide horizontal, shallow vertical
		polygon.polygon = PackedVector2Array(
			[
				Vector2(-radius, 0.0),
				Vector2(-radius * 0.4, -radius * 0.25),
				Vector2(radius, 0.0),
				Vector2(-radius * 0.4, radius * 0.25)
			]
		)
		polygon.modulate.a = 0.65
	else:
		polygon.polygon = _build_school_polygon(school, radius)
	add_child(polygon)


func _build_ground_telegraph() -> void:
	if has_node("GroundTelegraph"):
		return
	if not _should_build_ground_telegraph():
		return
	var root := Node2D.new()
	root.name = "GroundTelegraph"
	root.set_meta("visual_role", "ground_telegraph")
	root.set_meta("telegraph_radius", radius)
	root.set_meta("telegraph_mode", "persistent" if _is_persistent_area_effect() else "burst")
	root.set_meta("phase_signature", _get_phase_signature_key())
	root.scale = Vector2(1.0, GROUND_TELEGRAPH_VERTICAL_SCALE)
	root.z_index = -10
	var fill := Polygon2D.new()
	fill.name = "Fill"
	fill.color = _get_ground_telegraph_fill_color()
	fill.polygon = _build_circle_polygon(radius * 0.94, 40)
	root.add_child(fill)
	var outline := Line2D.new()
	outline.name = "Outline"
	outline.default_color = _get_ground_telegraph_outline_color()
	outline.width = clampf(radius * 0.06, 3.0, 12.0)
	outline.closed = true
	outline.points = _build_circle_polygon(radius, 40)
	outline.joint_mode = Line2D.LINE_JOINT_ROUND
	outline.begin_cap_mode = Line2D.LINE_CAP_ROUND
	outline.end_cap_mode = Line2D.LINE_CAP_ROUND
	root.add_child(outline)
	var startup_ring := Line2D.new()
	startup_ring.name = "StartupRing"
	startup_ring.default_color = _get_ground_telegraph_startup_color()
	startup_ring.width = clampf(radius * _get_phase_profile_float("startup_width_scale", 0.08), 4.0, 16.0)
	startup_ring.closed = true
	startup_ring.points = _build_circle_polygon(
		radius * _get_phase_profile_float("startup_radius_scale", 0.82), 40
	)
	startup_ring.joint_mode = Line2D.LINE_JOINT_ROUND
	startup_ring.begin_cap_mode = Line2D.LINE_CAP_ROUND
	startup_ring.end_cap_mode = Line2D.LINE_CAP_ROUND
	startup_ring.scale = Vector2(
		GROUND_TELEGRAPH_STARTUP_INITIAL_SCALE, GROUND_TELEGRAPH_STARTUP_INITIAL_SCALE
	)
	startup_ring.set_meta("phase_signature", _get_phase_signature_key())
	startup_ring.set_meta("phase_school", school)
	startup_ring.set_meta(
		"phase_duration", _get_phase_profile_float("startup_duration", GROUND_TELEGRAPH_STARTUP_DURATION)
	)
	startup_ring.set_meta(
		"phase_width_scale", _get_phase_profile_float("startup_width_scale", 0.08)
	)
	startup_ring.set_meta(
		"phase_expand_scale",
		_get_phase_profile_float("startup_expand_scale", GROUND_TELEGRAPH_STARTUP_EXPAND_SCALE)
	)
	root.add_child(startup_ring)
	if _is_persistent_area_effect():
		var inner_outline := Line2D.new()
		inner_outline.name = "InnerOutline"
		inner_outline.default_color = _get_ground_telegraph_inner_color()
		inner_outline.width = clampf(radius * 0.025, 2.0, 6.0)
		inner_outline.closed = true
		inner_outline.points = _build_circle_polygon(radius * 0.72, 32)
		inner_outline.joint_mode = Line2D.LINE_JOINT_ROUND
		inner_outline.begin_cap_mode = Line2D.LINE_CAP_ROUND
		inner_outline.end_cap_mode = Line2D.LINE_CAP_ROUND
		root.add_child(inner_outline)
	add_child(root)


func _should_build_ground_telegraph() -> bool:
	if radius < GROUND_TELEGRAPH_MIN_RADIUS:
		return false
	if velocity != Vector2.ZERO and not _is_persistent_area_effect():
		return false
	return true


func _get_ground_telegraph_fill_color() -> Color:
	var fill := visual_color
	fill.a = 0.14 if _is_persistent_area_effect() else 0.11
	return fill


func _get_ground_telegraph_outline_color() -> Color:
	var outline := _get_phase_accent_color().lightened(0.22)
	outline.a = 0.82 if _is_persistent_area_effect() else 0.74
	return outline


func _get_ground_telegraph_startup_color() -> Color:
	var startup := _get_phase_accent_color().lightened(
		_get_phase_profile_float("startup_color_lighten", 0.40)
	)
	startup.a = _get_phase_profile_float("startup_alpha", 0.92)
	return startup


func _get_ground_telegraph_inner_color() -> Color:
	var inner := _get_phase_accent_color().lightened(0.35)
	inner.a = 0.38
	return inner


func _build_circle_polygon(r: float, point_count: int = 32) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(point_count):
		var angle := TAU * float(i) / float(point_count)
		points.append(Vector2(cos(angle), sin(angle)) * r)
	return points


func _play_ground_telegraph_intro() -> void:
	var telegraph := get_node_or_null("GroundTelegraph") as Node2D
	if telegraph == null or not telegraph.is_inside_tree():
		return
	var startup_ring := telegraph.get_node_or_null("StartupRing") as Line2D
	if startup_ring == null:
		return
	var startup_duration := _get_phase_profile_float(
		"startup_duration", GROUND_TELEGRAPH_STARTUP_DURATION
	)
	var startup_expand_scale := _get_phase_profile_float(
		"startup_expand_scale", GROUND_TELEGRAPH_STARTUP_EXPAND_SCALE
	)
	var intro_tween := create_tween()
	intro_tween.set_parallel(true)
	intro_tween.tween_property(
		startup_ring,
		"scale",
		Vector2(startup_expand_scale, startup_expand_scale),
		startup_duration
	)
	intro_tween.tween_property(startup_ring, "modulate:a", 0.0, startup_duration)
	intro_tween.chain().tween_callback(
		Callable(self, "_queue_child_node_by_path").bind(NodePath("GroundTelegraph/StartupRing"))
	)


func _build_terminal_flash() -> Node2D:
	if not _should_build_ground_telegraph():
		return null
	var root := Node2D.new()
	root.name = "TerminalFlash"
	root.set_meta("visual_role", "terminal_flash")
	root.set_meta("phase_signature", _get_phase_signature_key())
	root.set_meta("phase_school", school)
	root.set_meta(
		"phase_duration", _get_phase_profile_float("terminal_duration", TERMINAL_FLASH_DURATION)
	)
	root.set_meta(
		"phase_outline_width_scale",
		_get_phase_profile_float("terminal_outline_width_scale", 0.08)
	)
	root.set_meta(
		"phase_expand_scale",
		_get_phase_profile_float("terminal_expand_scale", TERMINAL_FLASH_EXPAND_SCALE)
	)
	root.scale = Vector2(
		TERMINAL_FLASH_INITIAL_SCALE,
		GROUND_TELEGRAPH_VERTICAL_SCALE * TERMINAL_FLASH_INITIAL_SCALE
	)
	root.z_index = -9
	var fill := Polygon2D.new()
	fill.name = "Fill"
	fill.color = _get_terminal_flash_fill_color()
	fill.polygon = _build_circle_polygon(
		radius * _get_phase_profile_float("terminal_fill_radius_scale", 0.78), 36
	)
	root.add_child(fill)
	var outline := Line2D.new()
	outline.name = "Outline"
	outline.default_color = _get_terminal_flash_outline_color()
	outline.width = clampf(
		radius * _get_phase_profile_float("terminal_outline_width_scale", 0.08),
		5.0,
		18.0
	)
	outline.closed = true
	outline.points = _build_circle_polygon(
		radius * _get_phase_profile_float("terminal_outline_radius_scale", 0.96), 36
	)
	outline.joint_mode = Line2D.LINE_JOINT_ROUND
	outline.begin_cap_mode = Line2D.LINE_CAP_ROUND
	outline.end_cap_mode = Line2D.LINE_CAP_ROUND
	root.add_child(outline)
	return root


func _play_terminal_flash(terminal_flash: Node2D) -> void:
	if terminal_flash == null or not terminal_flash.is_inside_tree():
		return
	var terminal_duration := _get_phase_profile_float("terminal_duration", TERMINAL_FLASH_DURATION)
	var terminal_expand_scale := _get_phase_profile_float(
		"terminal_expand_scale", TERMINAL_FLASH_EXPAND_SCALE
	)
	var flash_tween := create_tween()
	flash_tween.set_parallel(true)
	flash_tween.tween_property(
		terminal_flash,
		"scale",
		Vector2(
			terminal_expand_scale,
			GROUND_TELEGRAPH_VERTICAL_SCALE * terminal_expand_scale
		),
		terminal_duration
	)
	flash_tween.tween_property(terminal_flash, "modulate:a", 0.0, terminal_duration)
	flash_tween.chain().tween_callback(
		Callable(self, "_queue_child_node_by_path").bind(NodePath("TerminalFlash"))
	)


func _get_terminal_flash_fill_color() -> Color:
	var fill := _get_phase_accent_color().lightened(_get_phase_profile_float("terminal_fill_lighten", 0.18))
	fill.a = _get_phase_profile_float(
		"terminal_fill_alpha_persistent" if _is_persistent_area_effect() else "terminal_fill_alpha_burst",
		0.24 if _is_persistent_area_effect() else 0.20
	)
	return fill


func _get_terminal_flash_outline_color() -> Color:
	var outline := _get_phase_accent_color().lightened(
		_get_phase_profile_float("terminal_outline_lighten", 0.52)
	)
	outline.a = 0.96
	return outline


func _queue_child_node_by_path(node_path: NodePath) -> void:
	var target := get_node_or_null(node_path)
	if target != null:
		target.queue_free()


func _get_phase_profile() -> Dictionary:
	var profile: Dictionary = TELEGRAPH_PHASE_SCHOOL_PROFILES.get(
		school, TELEGRAPH_PHASE_SCHOOL_PROFILES.get("default", {})
	).duplicate(true)
	var signature_overrides: Dictionary = TELEGRAPH_PHASE_SIGNATURE_OVERRIDES.get(spell_id, {})
	for key in signature_overrides.keys():
		profile[key] = signature_overrides[key]
	return profile


func _get_phase_signature_key() -> String:
	if TELEGRAPH_PHASE_SIGNATURE_OVERRIDES.has(spell_id):
		return spell_id
	if not school.is_empty():
		return school
	return "default"


func _get_phase_profile_float(key: String, fallback: float) -> float:
	return float(_get_phase_profile().get(key, fallback))


func _get_phase_accent_color() -> Color:
	var profile := _get_phase_profile()
	var accent := Color(str(profile.get("accent_color", "#ffffff")))
	var accent_mix := float(profile.get("accent_mix", 0.42))
	return visual_color.lerp(accent, accent_mix)


func _build_registered_spell_visual(target_spell_id: String) -> bool:
	var spec: Dictionary = SPELL_VISUAL_SPECS.get(target_spell_id, {})
	if spec.is_empty():
		return false
	return _build_sampled_effect_visual(
		str(spec.get("dir_path", "")),
		str(spec.get("frame_prefix", "")),
		int(spec.get("frame_count", 0)),
		float(spec.get("fps", 18.0)),
		float(spec.get("scale", 1.0)) * visual_scale_multiplier,
		bool(spec.get("flip_by_velocity", true)),
		Color(str(spec.get("modulate_color", "#ffffff"))),
		bool(spec.get("loop_animation", true))
	)


func _build_school_polygon(p_school: String, r: float) -> PackedVector2Array:
	match p_school:
		"dark":
			# Inverted broad crescent-like pentagon — wide, menacing
			return PackedVector2Array(
				[
					Vector2(-r * 0.5, -r * 0.9),
					Vector2(r, 0.0),
					Vector2(-r * 0.5, r * 0.9),
					Vector2(-r * 1.1, r * 0.4),
					Vector2(-r * 1.1, -r * 0.4)
				]
			)
		"arcane":
			# Diamond (rotated square) — classic magic orb silhouette
			return PackedVector2Array(
				[Vector2(0.0, -r), Vector2(r * 0.7, 0.0), Vector2(0.0, r), Vector2(-r * 0.7, 0.0)]
			)
		"water":
			# Teardrop: wide front, narrow tail
			return PackedVector2Array(
				[
					Vector2(-r * 0.6, -r * 0.5),
					Vector2(r * 0.9, -r * 0.2),
					Vector2(r, 0.0),
					Vector2(r * 0.9, r * 0.2),
					Vector2(-r * 0.6, r * 0.5),
					Vector2(-r, 0.0)
				]
			)
		"wind":
			# Long thin slash — extreme horizontal blade
			return PackedVector2Array(
				[
					Vector2(-r * 1.4, -r * 0.2),
					Vector2(r * 0.6, -r * 0.5),
					Vector2(r * 1.0, 0.0),
					Vector2(r * 0.6, r * 0.5),
					Vector2(-r * 1.4, r * 0.2)
				]
			)
		"earth":
			# Chunky rectangle — heavy stone slab
			return PackedVector2Array(
				[
					Vector2(-r * 0.8, -r * 0.7),
					Vector2(r * 0.8, -r * 0.7),
					Vector2(r * 0.8, r * 0.7),
					Vector2(-r * 0.8, r * 0.7)
				]
			)
		"holy":
			# Wide cross-beam: broad forward, thin vertical
			return PackedVector2Array(
				[
					Vector2(-r * 0.3, -r * 0.3),
					Vector2(r * 0.8, -r * 0.3),
					Vector2(r * 0.8, r * 0.3),
					Vector2(-r * 0.3, r * 0.3)
				]
			)
		"ice":
			# Hexagon (snowflake base)
			return PackedVector2Array(
				[
					Vector2(0.0, -r),
					Vector2(r * 0.87, -r * 0.5),
					Vector2(r * 0.87, r * 0.5),
					Vector2(0.0, r),
					Vector2(-r * 0.87, r * 0.5),
					Vector2(-r * 0.87, -r * 0.5)
				]
			)
		"lightning":
			# Jagged bolt: forward-pointing zigzag
			return PackedVector2Array(
				[
					Vector2(-r * 0.2, -r * 0.8),
					Vector2(r * 0.5, -r * 0.1),
					Vector2(r, 0.0),
					Vector2(r * 0.5, r * 0.1),
					Vector2(-r * 0.2, r * 0.8),
					Vector2(-r * 0.6, r * 0.2),
					Vector2(-r * 0.6, -r * 0.2)
				]
			)
		_:
			# Default: forward-pointing triangle
			return PackedVector2Array(
				[Vector2(-r, -r * 0.6), Vector2(r, 0.0), Vector2(-r, r * 0.6)]
			)


func _build_sampled_effect_visual(
	dir_path: String,
	frame_prefix: String,
	frame_count: int,
	fps: float,
	scale_value: float,
	flip_by_velocity: bool = true,
	modulate_color: Color = Color.WHITE,
	loop_animation: bool = true
) -> bool:
	var sprite := _create_sampled_effect_sprite(
		dir_path,
		frame_prefix,
		frame_count,
		fps,
		scale_value,
		flip_by_velocity,
		modulate_color,
		loop_animation
	)
	if sprite == null:
		return false
	add_child(sprite)
	sprite.play("fly")
	return true


func _create_sampled_effect_sprite(
	dir_path: String,
	frame_prefix: String,
	frame_count: int,
	fps: float,
	scale_value: float,
	flip_by_velocity: bool = true,
	modulate_color: Color = Color.WHITE,
	loop_animation: bool = true
) -> AnimatedSprite2D:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("fly")
	frames.set_animation_loop("fly", loop_animation)
	frames.set_animation_speed("fly", fps)
	for i in range(frame_count):
		var tex := _load_texture_2d("%s%s_%d.png" % [dir_path, frame_prefix, i])
		if tex != null:
			frames.add_frame("fly", tex)
	if frames.get_frame_count("fly") == 0:
		return null
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var scale_x := scale_value
	if flip_by_velocity and _get_visual_facing_sign() < 0.0:
		scale_x *= -1.0
	sprite.scale = Vector2(scale_x, scale_value)
	sprite.modulate = _apply_effect_opacity(modulate_color)
	sprite.animation = "fly"
	return sprite


func _apply_effect_opacity(color: Color) -> Color:
	var adjusted := color
	if UiState != null:
		adjusted.a *= UiState.get_effect_opacity()
	return adjusted


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


func _build_terminal_effect_visual() -> AnimatedSprite2D:
	var spec: Dictionary = TERMINAL_EFFECT_SPECS.get(terminal_effect_id, {})
	if spec.is_empty():
		return null
	return _create_sampled_effect_sprite(
		str(spec.get("dir_path", "")),
		str(spec.get("frame_prefix", "")),
		int(spec.get("frame_count", 0)),
		float(spec.get("fps", 18.0)),
		float(spec.get("scale", 1.0)) * visual_scale_multiplier,
		bool(spec.get("flip_by_velocity", false)),
		Color(str(spec.get("modulate_color", "#ffffff"))),
		bool(spec.get("loop_animation", false))
	)


func _resolve_visual_scale_multiplier() -> float:
	var base_size := _get_visual_base_size()
	if base_size <= 0.0:
		return 1.0
	var size_ratio := radius / base_size
	if size_ratio <= 1.05:
		return 1.0
	if velocity == Vector2.ZERO or radius >= 96.0:
		return clampf(1.0 + (size_ratio - 1.0) * 0.55, 1.0, 2.2)
	return clampf(1.0 + (size_ratio - 1.0) * 0.65, 1.0, 1.8)


func _get_visual_base_size() -> float:
	if spell_id.is_empty():
		return 0.0
	var spell_data: Dictionary = GameDatabase.get_spell(spell_id)
	if not spell_data.is_empty():
		var spell_size := float(spell_data.get("size", 0.0))
		if spell_size > 0.0:
			return spell_size
	var skill_data: Dictionary = GameDatabase.get_skill_data(spell_id)
	if skill_data.is_empty():
		return 0.0
	return float(skill_data.get("range_base", 0.0))


# SPRITE DIRECTION: native facing = RIGHT (content sits at x=15-61 in 100px canvas)
# scale.x = +0.5 → right,  scale.x = -0.5 → left (mirrored)
func _build_fire_bolt_visual() -> bool:
	return _build_sampled_effect_visual(
		"res://assets/effects/fire_bolt/", "fire_bolt", 15, 12.0, 0.5
	)


func _build_volt_spear_visual() -> bool:
	return _build_sampled_effect_visual(
		"res://assets/effects/volt_spear/", "volt_spear", 15, 26.0, 0.46
	)


func _build_frost_nova_visual() -> bool:
	return _build_sampled_effect_visual(
		"res://assets/effects/frost_nova/",
		"frost_nova",
		8,
		40.0,
		0.82,
		false,
		Color("#8cecff"),
		false
	)
