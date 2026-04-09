extends Node

signal ui_opacity_changed(value: float)
signal brightness_changed(value: float)
signal effect_opacity_changed(value: float)
signal music_volume_changed(value: float)
signal sfx_volume_changed(value: float)
signal special_effects_enabled_changed(enabled: bool)
signal screen_shake_enabled_changed(enabled: bool)
signal primary_action_row_visibility_changed(enabled: bool)
signal active_buff_row_visibility_changed(enabled: bool)
signal window_position_changed(window_id: String, position: Vector2)

const SETTINGS_PATH := "user://ui_settings.cfg"
const UI_SECTION := "ui"
const AUDIO_SECTION := "audio"
const EFFECTS_SECTION := "effects"
const HUD_SECTION := "hud"
const WINDOWS_SECTION := "windows"
const MASTER_BUS_NAME := "Master"
const MUSIC_BUS_NAME := "Music"
const LEGACY_MUSIC_BUS_NAME := "BGM"
const SFX_BUS_NAME := "SFX"
const EFFECT_BUS_NAME := "Effect"
const MIN_UI_OPACITY := 0.6
const MAX_UI_OPACITY := 1.0
const MIN_BRIGHTNESS := 0.6
const MAX_BRIGHTNESS := 1.0
const MIN_EFFECT_OPACITY := 0.2
const MAX_EFFECT_OPACITY := 1.0

var ui_opacity := 1.0
var brightness := 1.0
var effect_opacity := 1.0
var music_volume := 1.0
var sfx_volume := 1.0
var special_effects_enabled := true
var screen_shake_enabled := true
var show_primary_action_row := true
var show_active_buff_row := true
var window_positions: Dictionary = {}


func _ready() -> void:
	load_from_disk()


func load_from_disk() -> void:
	var config := ConfigFile.new()
	_reset_defaults()
	if config.load(SETTINGS_PATH) != OK:
		_apply_audio_bus_volumes()
		return
	ui_opacity = clampf(float(config.get_value(UI_SECTION, "opacity", 1.0)), MIN_UI_OPACITY, MAX_UI_OPACITY)
	brightness = clampf(float(config.get_value(UI_SECTION, "brightness", 1.0)), MIN_BRIGHTNESS, MAX_BRIGHTNESS)
	music_volume = clampf(float(config.get_value(AUDIO_SECTION, "music_volume", 1.0)), 0.0, 1.0)
	sfx_volume = clampf(float(config.get_value(AUDIO_SECTION, "sfx_volume", 1.0)), 0.0, 1.0)
	effect_opacity = clampf(
		float(config.get_value(EFFECTS_SECTION, "effect_opacity", 1.0)),
		MIN_EFFECT_OPACITY,
		MAX_EFFECT_OPACITY
	)
	special_effects_enabled = bool(config.get_value(EFFECTS_SECTION, "special_effects_enabled", true))
	screen_shake_enabled = bool(config.get_value(EFFECTS_SECTION, "screen_shake_enabled", true))
	show_primary_action_row = bool(config.get_value(HUD_SECTION, "show_primary_action_row", true))
	show_active_buff_row = bool(config.get_value(HUD_SECTION, "show_active_buff_row", true))
	window_positions.clear()
	for key_value in config.get_section_keys(WINDOWS_SECTION):
		var key := str(key_value)
		var stored_value = config.get_value(WINDOWS_SECTION, key, [0.0, 0.0])
		if typeof(stored_value) != TYPE_ARRAY:
			continue
		var coords: Array = stored_value
		if coords.size() < 2:
			continue
		window_positions[key] = Vector2(float(coords[0]), float(coords[1]))
	_apply_audio_bus_volumes()


func save_to_disk() -> void:
	var config := ConfigFile.new()
	config.set_value(UI_SECTION, "opacity", ui_opacity)
	config.set_value(UI_SECTION, "brightness", brightness)
	config.set_value(AUDIO_SECTION, "music_volume", music_volume)
	config.set_value(AUDIO_SECTION, "sfx_volume", sfx_volume)
	config.set_value(EFFECTS_SECTION, "effect_opacity", effect_opacity)
	config.set_value(EFFECTS_SECTION, "special_effects_enabled", special_effects_enabled)
	config.set_value(EFFECTS_SECTION, "screen_shake_enabled", screen_shake_enabled)
	config.set_value(HUD_SECTION, "show_primary_action_row", show_primary_action_row)
	config.set_value(HUD_SECTION, "show_active_buff_row", show_active_buff_row)
	for window_id_value in window_positions.keys():
		var window_id := str(window_id_value)
		var position: Vector2 = window_positions[window_id]
		config.set_value(WINDOWS_SECTION, window_id, [position.x, position.y])
	config.save(SETTINGS_PATH)


func get_ui_opacity() -> float:
	return ui_opacity


func set_ui_opacity(value: float, persist: bool = true) -> void:
	var clamped := clampf(value, MIN_UI_OPACITY, MAX_UI_OPACITY)
	if is_equal_approx(ui_opacity, clamped):
		return
	ui_opacity = clamped
	if persist:
		save_to_disk()
	ui_opacity_changed.emit(ui_opacity)


func get_brightness() -> float:
	return brightness


func set_brightness(value: float, persist: bool = true) -> void:
	var clamped := clampf(value, MIN_BRIGHTNESS, MAX_BRIGHTNESS)
	if is_equal_approx(brightness, clamped):
		return
	brightness = clamped
	if persist:
		save_to_disk()
	brightness_changed.emit(brightness)


func get_effect_opacity() -> float:
	return effect_opacity


func set_effect_opacity(value: float, persist: bool = true) -> void:
	var clamped := clampf(value, MIN_EFFECT_OPACITY, MAX_EFFECT_OPACITY)
	if is_equal_approx(effect_opacity, clamped):
		return
	effect_opacity = clamped
	if persist:
		save_to_disk()
	effect_opacity_changed.emit(effect_opacity)


func get_music_volume() -> float:
	return music_volume


func set_music_volume(value: float, persist: bool = true) -> void:
	var clamped := clampf(value, 0.0, 1.0)
	if is_equal_approx(music_volume, clamped):
		return
	music_volume = clamped
	_apply_audio_bus_volumes()
	if persist:
		save_to_disk()
	music_volume_changed.emit(music_volume)


func get_sfx_volume() -> float:
	return sfx_volume


func set_sfx_volume(value: float, persist: bool = true) -> void:
	var clamped := clampf(value, 0.0, 1.0)
	if is_equal_approx(sfx_volume, clamped):
		return
	sfx_volume = clamped
	_apply_audio_bus_volumes()
	if persist:
		save_to_disk()
	sfx_volume_changed.emit(sfx_volume)


func are_special_effects_enabled() -> bool:
	return special_effects_enabled


func set_special_effects_enabled(value: bool, persist: bool = true) -> void:
	if special_effects_enabled == value:
		return
	special_effects_enabled = value
	if persist:
		save_to_disk()
	special_effects_enabled_changed.emit(special_effects_enabled)


func get_screen_shake_enabled() -> bool:
	return screen_shake_enabled


func set_screen_shake_enabled(value: bool, persist: bool = true) -> void:
	if screen_shake_enabled == value:
		return
	screen_shake_enabled = value
	if persist:
		save_to_disk()
	screen_shake_enabled_changed.emit(screen_shake_enabled)


func get_show_primary_action_row() -> bool:
	return show_primary_action_row


func set_show_primary_action_row(value: bool, persist: bool = true) -> void:
	if show_primary_action_row == value:
		return
	show_primary_action_row = value
	if persist:
		save_to_disk()
	primary_action_row_visibility_changed.emit(show_primary_action_row)


func get_show_active_buff_row() -> bool:
	return show_active_buff_row


func set_show_active_buff_row(value: bool, persist: bool = true) -> void:
	if show_active_buff_row == value:
		return
	show_active_buff_row = value
	if persist:
		save_to_disk()
	active_buff_row_visibility_changed.emit(show_active_buff_row)


func get_window_position(window_id: String, fallback: Vector2) -> Vector2:
	if not window_positions.has(window_id):
		return fallback
	return window_positions[window_id]


func set_window_position(window_id: String, position: Vector2, persist: bool = true) -> void:
	window_positions[window_id] = position
	if persist:
		save_to_disk()
	window_position_changed.emit(window_id, position)


func reset_to_defaults_for_tests() -> void:
	_reset_defaults()
	_apply_audio_bus_volumes()
	ui_opacity_changed.emit(ui_opacity)
	brightness_changed.emit(brightness)
	effect_opacity_changed.emit(effect_opacity)
	music_volume_changed.emit(music_volume)
	sfx_volume_changed.emit(sfx_volume)
	special_effects_enabled_changed.emit(special_effects_enabled)
	screen_shake_enabled_changed.emit(screen_shake_enabled)
	primary_action_row_visibility_changed.emit(show_primary_action_row)
	active_buff_row_visibility_changed.emit(show_active_buff_row)


func _reset_defaults() -> void:
	ui_opacity = 1.0
	brightness = 1.0
	effect_opacity = 1.0
	music_volume = 1.0
	sfx_volume = 1.0
	special_effects_enabled = true
	screen_shake_enabled = true
	show_primary_action_row = true
	show_active_buff_row = true
	window_positions.clear()


func _apply_audio_bus_volumes() -> void:
	_ensure_audio_bus_layout()
	_apply_audio_bus_if_present(MUSIC_BUS_NAME, music_volume)
	_apply_audio_bus_if_present(LEGACY_MUSIC_BUS_NAME, music_volume)
	_apply_audio_bus_if_present(SFX_BUS_NAME, sfx_volume)
	_apply_audio_bus_if_present(EFFECT_BUS_NAME, sfx_volume)


func _apply_audio_bus_if_present(bus_name: String, volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(volume, 0.0001)))


func _ensure_audio_bus_layout() -> void:
	_ensure_audio_bus(MUSIC_BUS_NAME)
	_ensure_audio_bus(SFX_BUS_NAME)
	_ensure_audio_bus(EFFECT_BUS_NAME)


func _ensure_audio_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	var insert_index := AudioServer.bus_count
	AudioServer.add_bus(insert_index)
	AudioServer.set_bus_name(insert_index, bus_name)
	AudioServer.set_bus_send(insert_index, MASTER_BUS_NAME)
