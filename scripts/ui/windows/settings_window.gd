extends "res://scripts/ui/widgets/ui_window_frame.gd"

var _music_slider: HSlider = null
var _music_value_label: Label = null
var _sfx_slider: HSlider = null
var _sfx_value_label: Label = null
var _brightness_slider: HSlider = null
var _brightness_value_label: Label = null
var _ui_opacity_slider: HSlider = null
var _ui_opacity_value_label: Label = null
var _effect_opacity_slider: HSlider = null
var _effect_opacity_value_label: Label = null
var _special_effects_checkbox: CheckBox = null
var _screen_shake_checkbox: CheckBox = null
var _show_primary_action_row_checkbox: CheckBox = null
var _show_active_buff_row_checkbox: CheckBox = null


func _enter_tree() -> void:
	window_id = "settings"
	window_title = "설정"
	placeholder_text = ""
	default_size = Vector2(460.0, 360.0)
	default_position = Vector2(220.0, 80.0)
	window_accent_color = Color(0.56, 0.82, 0.60, 0.98)


func _ready() -> void:
	super._ready()
	clear_content_root()
	_build_settings_content()
	_connect_state_signals()
	_sync_from_state()


func _build_settings_content() -> void:
	var content_root := get_content_root()
	if content_root == null:
		return
	var content := VBoxContainer.new()
	content.name = "SettingsContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	content_root.add_child(content)

	var description := Label.new()
	description.name = "DescriptionLabel"
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.text = "메이플식 기본 UX를 기준으로, 지금 증분에서는 즉시 적용 가능한 옵션부터 연결합니다."
	content.add_child(description)

	var tabs := TabContainer.new()
	tabs.name = "SettingsTabs"
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_tab_container_skin(tabs, Color(0.56, 0.82, 0.60, 0.98))
	content.add_child(tabs)

	var audio_tab := _create_tab_page(tabs, "오디오")
	_music_slider = _add_slider_row(
		audio_tab,
		"MusicVolume",
		"음악 볼륨",
		UiState.get_music_volume(),
		0.0,
		1.0,
		func(value: float) -> void: UiState.set_music_volume(value)
	)
	_music_value_label = audio_tab.get_node("MusicVolume/Padding/Content/ValueLabel") as Label
	_sfx_slider = _add_slider_row(
		audio_tab,
		"SfxVolume",
		"효과음 볼륨",
		UiState.get_sfx_volume(),
		0.0,
		1.0,
		func(value: float) -> void: UiState.set_sfx_volume(value)
	)
	_sfx_value_label = audio_tab.get_node("SfxVolume/Padding/Content/ValueLabel") as Label
	_add_hint_label(audio_tab, "Music / SFX 버스는 현재 런타임에서 분리되어 즉시 적용됩니다. 실제 플레이어 노드도 이 버스 이름으로 라우팅하면 같은 규칙을 그대로 사용합니다.")

	var graphics_tab := _create_tab_page(tabs, "그래픽")
	_brightness_slider = _add_slider_row(
		graphics_tab,
		"Brightness",
		"밝기",
		UiState.get_brightness(),
		UiState.MIN_BRIGHTNESS,
		UiState.MAX_BRIGHTNESS,
		func(value: float) -> void: UiState.set_brightness(value)
	)
	_brightness_value_label = graphics_tab.get_node("Brightness/Padding/Content/ValueLabel") as Label
	_ui_opacity_slider = _add_slider_row(
		graphics_tab,
		"UiOpacity",
		"UI 투명도",
		UiState.get_ui_opacity(),
		UiState.MIN_UI_OPACITY,
		UiState.MAX_UI_OPACITY,
		func(value: float) -> void: UiState.set_ui_opacity(value)
	)
	_ui_opacity_value_label = graphics_tab.get_node("UiOpacity/Padding/Content/ValueLabel") as Label

	var effects_tab := _create_tab_page(tabs, "효과")
	_effect_opacity_slider = _add_slider_row(
		effects_tab,
		"EffectOpacity",
		"이펙트 투명도",
		UiState.get_effect_opacity(),
		UiState.MIN_EFFECT_OPACITY,
		UiState.MAX_EFFECT_OPACITY,
		func(value: float) -> void: UiState.set_effect_opacity(value)
	)
	_effect_opacity_value_label = effects_tab.get_node("EffectOpacity/Padding/Content/ValueLabel") as Label
	_special_effects_checkbox = _add_checkbox_row(
		effects_tab,
		"SpecialEffects",
		"특수효과",
		"화면 전역 연출과 경고 오버레이를 표시합니다.",
		func(enabled: bool) -> void: UiState.set_special_effects_enabled(enabled)
	)
	_screen_shake_checkbox = _add_checkbox_row(
		effects_tab,
		"ScreenShake",
		"화면 흔들림",
		"피격과 광역 스킬의 카메라 흔들림을 허용합니다.",
		func(enabled: bool) -> void: UiState.set_screen_shake_enabled(enabled)
	)

	var hud_tab := _create_tab_page(tabs, "HUD")
	_show_primary_action_row_checkbox = _add_checkbox_row(
		hud_tab,
		"ShowPrimaryActionRow",
		"주요 액션 바 표시",
		"하단 1~0 quickslot row를 표시합니다.",
		func(enabled: bool) -> void: UiState.set_show_primary_action_row(enabled)
	)
	_show_active_buff_row_checkbox = _add_checkbox_row(
		hud_tab,
		"ShowActiveBuffRow",
		"활성 버프 줄 표시",
		"좌하단 상태 패널의 버프 chip row를 표시합니다.",
		func(enabled: bool) -> void: UiState.set_show_active_buff_row(enabled)
	)
	_add_hint_label(hud_tab, "메이플식 전투 HUD 읽힘을 유지하되, 화면 점유가 부담될 때 행 단위로 숨길 수 있습니다.")


func _create_tab_page(tabs: TabContainer, title: String) -> VBoxContainer:
	var page := VBoxContainer.new()
	page.name = title
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 10)
	tabs.add_child(page)
	return page


func _add_slider_row(
	parent: VBoxContainer,
	row_name: String,
	label_text: String,
	initial_value: float,
	min_value: float,
	max_value: float,
	on_change: Callable
) -> HSlider:
	var row := PanelContainer.new()
	row.name = row_name
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_setting_row_skin(row, window_accent_color)
	parent.add_child(row)

	var padding := MarginContainer.new()
	padding.name = "Padding"
	padding.add_theme_constant_override("margin_left", 10)
	padding.add_theme_constant_override("margin_top", 8)
	padding.add_theme_constant_override("margin_right", 10)
	padding.add_theme_constant_override("margin_bottom", 8)
	row.add_child(padding)

	var content := HBoxContainer.new()
	content.name = "Content"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	padding.add_child(content)

	var label := Label.new()
	label.name = "Label"
	label.custom_minimum_size = Vector2(110.0, 0.0)
	label.text = label_text
	label.add_theme_color_override("font_color", Color(0.12, 0.18, 0.26, 1.0))
	content.add_child(label)

	var slider := HSlider.new()
	slider.name = "Slider"
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = 0.01
	slider.value = initial_value
	_apply_slider_skin(slider, window_accent_color)
	slider.value_changed.connect(func(value: float) -> void: on_change.call(value))
	content.add_child(slider)

	var value_label := Label.new()
	value_label.name = "ValueLabel"
	value_label.custom_minimum_size = Vector2(48.0, 0.0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_color_override("font_color", window_accent_color.darkened(0.55))
	content.add_child(value_label)
	return slider


func _add_checkbox_row(
	parent: VBoxContainer,
	row_name: String,
	label_text: String,
	hint_text: String,
	on_toggle: Callable
) -> CheckBox:
	var row := PanelContainer.new()
	row.name = row_name
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_setting_row_skin(row, window_accent_color, true)
	parent.add_child(row)

	var padding := MarginContainer.new()
	padding.name = "Padding"
	padding.add_theme_constant_override("margin_left", 10)
	padding.add_theme_constant_override("margin_top", 8)
	padding.add_theme_constant_override("margin_right", 10)
	padding.add_theme_constant_override("margin_bottom", 8)
	row.add_child(padding)

	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 4)
	padding.add_child(content)

	var checkbox := CheckBox.new()
	checkbox.name = "CheckBox"
	checkbox.text = label_text
	_apply_checkbox_skin(checkbox, window_accent_color)
	checkbox.toggled.connect(func(enabled: bool) -> void: on_toggle.call(enabled))
	content.add_child(checkbox)

	var hint_label := Label.new()
	hint_label.name = "HintLabel"
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.modulate = Color(0.78, 0.82, 0.90, 0.78)
	hint_label.text = hint_text
	content.add_child(hint_label)
	return checkbox


func _add_hint_label(parent: VBoxContainer, text_value: String) -> void:
	var hint_label := Label.new()
	hint_label.name = "HintLabel"
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.modulate = Color(0.78, 0.82, 0.90, 0.78)
	hint_label.text = text_value
	parent.add_child(hint_label)


func _connect_state_signals() -> void:
	if UiState == null:
		return
	if not UiState.ui_opacity_changed.is_connected(_on_ui_opacity_changed):
		UiState.ui_opacity_changed.connect(_on_ui_opacity_changed)
	if not UiState.brightness_changed.is_connected(_on_brightness_changed):
		UiState.brightness_changed.connect(_on_brightness_changed)
	if not UiState.effect_opacity_changed.is_connected(_on_effect_opacity_changed):
		UiState.effect_opacity_changed.connect(_on_effect_opacity_changed)
	if not UiState.music_volume_changed.is_connected(_on_music_volume_changed):
		UiState.music_volume_changed.connect(_on_music_volume_changed)
	if not UiState.sfx_volume_changed.is_connected(_on_sfx_volume_changed):
		UiState.sfx_volume_changed.connect(_on_sfx_volume_changed)
	if not UiState.special_effects_enabled_changed.is_connected(_on_special_effects_toggled):
		UiState.special_effects_enabled_changed.connect(_on_special_effects_toggled)
	if not UiState.screen_shake_enabled_changed.is_connected(_on_screen_shake_toggled):
		UiState.screen_shake_enabled_changed.connect(_on_screen_shake_toggled)
	if not UiState.primary_action_row_visibility_changed.is_connected(_on_primary_action_row_toggled):
		UiState.primary_action_row_visibility_changed.connect(_on_primary_action_row_toggled)
	if not UiState.active_buff_row_visibility_changed.is_connected(_on_active_buff_row_toggled):
		UiState.active_buff_row_visibility_changed.connect(_on_active_buff_row_toggled)


func _sync_from_state() -> void:
	_on_music_volume_changed(UiState.get_music_volume())
	_on_sfx_volume_changed(UiState.get_sfx_volume())
	_on_brightness_changed(UiState.get_brightness())
	_on_ui_opacity_changed(UiState.get_ui_opacity())
	_on_effect_opacity_changed(UiState.get_effect_opacity())
	_on_special_effects_toggled(UiState.are_special_effects_enabled())
	_on_screen_shake_toggled(UiState.get_screen_shake_enabled())
	_on_primary_action_row_toggled(UiState.get_show_primary_action_row())
	_on_active_buff_row_toggled(UiState.get_show_active_buff_row())


func _on_music_volume_changed(value: float) -> void:
	_set_slider_value(_music_slider, value)
	_set_percentage_label(_music_value_label, value)


func _on_sfx_volume_changed(value: float) -> void:
	_set_slider_value(_sfx_slider, value)
	_set_percentage_label(_sfx_value_label, value)


func _on_brightness_changed(value: float) -> void:
	_set_slider_value(_brightness_slider, value)
	_set_percentage_label(_brightness_value_label, value)


func _on_ui_opacity_changed(value: float) -> void:
	_set_slider_value(_ui_opacity_slider, value)
	_set_percentage_label(_ui_opacity_value_label, value)


func _on_effect_opacity_changed(value: float) -> void:
	_set_slider_value(_effect_opacity_slider, value)
	_set_percentage_label(_effect_opacity_value_label, value)


func _on_special_effects_toggled(enabled: bool) -> void:
	_set_checkbox_value(_special_effects_checkbox, enabled)


func _on_screen_shake_toggled(enabled: bool) -> void:
	_set_checkbox_value(_screen_shake_checkbox, enabled)


func _on_primary_action_row_toggled(enabled: bool) -> void:
	_set_checkbox_value(_show_primary_action_row_checkbox, enabled)


func _on_active_buff_row_toggled(enabled: bool) -> void:
	_set_checkbox_value(_show_active_buff_row_checkbox, enabled)


func _set_slider_value(slider: HSlider, value: float) -> void:
	if slider == null:
		return
	slider.set_value_no_signal(value)


func _set_checkbox_value(checkbox: CheckBox, enabled: bool) -> void:
	if checkbox == null:
		return
	checkbox.set_pressed_no_signal(enabled)


func _set_percentage_label(label: Label, value: float) -> void:
	if label == null:
		return
	label.text = "%d%%" % int(round(value * 100.0))
