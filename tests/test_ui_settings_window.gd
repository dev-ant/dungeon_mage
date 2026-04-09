extends "res://addons/gut/test.gd"

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")


func before_each() -> void:
	GameState.reset_progress_for_tests()
	UiState.reset_to_defaults_for_tests()
	GameState.current_room_id = "entrance"
	GameState.save_room_id = "entrance"
	GameState.save_spawn_position = Vector2(120, 480)
	get_tree().paused = false


func after_each() -> void:
	get_tree().paused = false


func _spawn_main_scene() -> Node2D:
	var main: Node2D = autofree(MAIN_SCENE.instantiate())
	add_child_autofree(main)
	await _settle_frames(3)
	return main


func _settle_frames(frame_count: int = 1) -> void:
	for _i in range(frame_count):
		await get_tree().process_frame


func test_settings_window_builds_maple_like_runtime_controls() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("settings")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("settings")
	assert_not_null(window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/오디오/MusicVolume/Padding/Content/Slider"))
	assert_not_null(window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/오디오/SfxVolume/Padding/Content/Slider"))
	assert_not_null(window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/그래픽/Brightness/Padding/Content/Slider"))
	assert_not_null(window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/그래픽/UiOpacity/Padding/Content/Slider"))
	assert_not_null(window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/효과/EffectOpacity/Padding/Content/Slider"))
	assert_not_null(window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/효과/SpecialEffects/Padding/Content/CheckBox"))
	assert_not_null(window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/효과/ScreenShake/Padding/Content/CheckBox"))
	assert_not_null(window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/HUD/ShowPrimaryActionRow/Padding/Content/CheckBox"))
	assert_not_null(window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/HUD/ShowActiveBuffRow/Padding/Content/CheckBox"))


func test_settings_window_tabs_and_close_button_use_custom_skin() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("settings")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("settings")
	var accent := window.get_node("Root/TitleAccent") as ColorRect
	assert_not_null(accent)
	assert_gt(accent.color.g, 0.7)
	var tabs := window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs") as TabContainer
	var selected_style := tabs.get_theme_stylebox("tab_selected") as StyleBoxFlat
	assert_not_null(selected_style)
	assert_gt(selected_style.bg_color.g, 0.6)
	var window_panel_style := window.get_theme_stylebox("panel") as StyleBoxTexture
	assert_not_null(window_panel_style)
	assert_true(window_panel_style.texture is AtlasTexture)
	var close_button := window.get_node("Root/TitleBar/CloseButton") as Button
	var close_hover := close_button.get_theme_stylebox("hover") as StyleBoxTexture
	assert_not_null(close_hover)
	assert_true(close_hover.texture is AtlasTexture)
	var music_row := window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/오디오/MusicVolume") as PanelContainer
	var music_row_style := music_row.get_theme_stylebox("panel")
	assert_not_null(music_row_style)
	assert_true(music_row_style is StyleBoxTexture)
	var slider := window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/오디오/MusicVolume/Padding/Content/Slider") as HSlider
	var slider_highlight := slider.get_theme_stylebox("grabber_area_highlight") as StyleBoxFlat
	assert_not_null(slider_highlight)
	assert_gt(slider_highlight.bg_color.g, 0.7)
	var checkbox := window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/효과/SpecialEffects/Padding/Content/CheckBox") as CheckBox
	assert_not_null(checkbox.get_theme_icon("checked"))


func test_settings_window_ui_opacity_slider_updates_ui_state() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("settings")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("settings")
	var slider := window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/그래픽/UiOpacity/Padding/Content/Slider") as HSlider
	slider.value = 0.72
	await _settle_frames(1)
	assert_almost_eq(UiState.get_ui_opacity(), 0.72, 0.001, "settings UI opacity slider must persist into UiState")


func test_settings_window_brightness_slider_updates_world_overlay() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("settings")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("settings")
	var slider := window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/그래픽/Brightness/Padding/Content/Slider") as HSlider
	var overlay := main.get_node("CanvasLayer/BrightnessOverlay") as ColorRect
	assert_not_null(overlay, "Main must build the brightness overlay so settings can drive it")
	slider.value = 0.65
	await _settle_frames(1)
	assert_true(overlay.visible, "lowering brightness should enable the dimming overlay")
	assert_gt(overlay.color.a, 0.0, "brightness overlay should use a visible alpha when brightness is reduced")


func test_settings_window_hud_toggles_update_ui_state_and_runtime() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("settings")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("settings")
	var primary_checkbox := window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/HUD/ShowPrimaryActionRow/Padding/Content/CheckBox") as CheckBox
	var buff_checkbox := window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/HUD/ShowActiveBuffRow/Padding/Content/CheckBox") as CheckBox
	var ui := main.get_node("CanvasLayer/GameUI")
	primary_checkbox.button_pressed = false
	buff_checkbox.button_pressed = false
	await _settle_frames(1)
	assert_false(UiState.get_show_primary_action_row())
	assert_false(UiState.get_show_active_buff_row())
	assert_false(ui.is_primary_action_row_visible())
	assert_false(ui.is_active_buff_row_visible())


func test_settings_window_audio_sliders_update_runtime_bus_levels() -> void:
	var main: Node2D = await _spawn_main_scene()
	main.window_manager.open_window("settings")
	await _settle_frames(2)
	var window: Control = main.window_manager.get_window_node("settings")
	var music_slider := window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/오디오/MusicVolume/Padding/Content/Slider") as HSlider
	var sfx_slider := window.get_node("Root/ContentRoot/SettingsContent/SettingsTabs/오디오/SfxVolume/Padding/Content/Slider") as HSlider
	music_slider.value = 0.55
	sfx_slider.value = 0.31
	await _settle_frames(1)
	assert_almost_eq(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")),
		linear_to_db(0.55),
		0.001
	)
	assert_almost_eq(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")),
		linear_to_db(0.31),
		0.001
	)
