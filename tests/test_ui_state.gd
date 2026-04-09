extends "res://addons/gut/test.gd"


func before_each() -> void:
	UiState.reset_to_defaults_for_tests()


func test_ui_state_ensures_maple_audio_buses_exist() -> void:
	var music_index := AudioServer.get_bus_index("Music")
	var sfx_index := AudioServer.get_bus_index("SFX")
	var effect_index := AudioServer.get_bus_index("Effect")
	assert_ne(music_index, -1, "UiState must guarantee a Music bus for settings-driven runtime control")
	assert_ne(sfx_index, -1, "UiState must guarantee an SFX bus for settings-driven runtime control")
	assert_ne(effect_index, -1, "UiState must guarantee an Effect bus for shared SFX routing")
	assert_eq(AudioServer.get_bus_send(music_index), "Master")
	assert_eq(AudioServer.get_bus_send(sfx_index), "Master")
	assert_eq(AudioServer.get_bus_send(effect_index), "Master")


func test_ui_state_audio_bus_layout_setup_is_idempotent() -> void:
	UiState.reset_to_defaults_for_tests()
	var bus_count_after_first_reset := AudioServer.bus_count
	UiState.reset_to_defaults_for_tests()
	assert_eq(
		AudioServer.bus_count,
		bus_count_after_first_reset,
		"resetting UiState for tests must not keep appending duplicate audio buses"
	)


func test_ui_state_audio_volume_updates_runtime_bus_levels() -> void:
	UiState.set_music_volume(0.42, false)
	UiState.set_sfx_volume(0.27, false)
	var music_index := AudioServer.get_bus_index("Music")
	var sfx_index := AudioServer.get_bus_index("SFX")
	var effect_index := AudioServer.get_bus_index("Effect")
	assert_almost_eq(AudioServer.get_bus_volume_db(music_index), linear_to_db(0.42), 0.001)
	assert_almost_eq(AudioServer.get_bus_volume_db(sfx_index), linear_to_db(0.27), 0.001)
	assert_almost_eq(AudioServer.get_bus_volume_db(effect_index), linear_to_db(0.27), 0.001)
