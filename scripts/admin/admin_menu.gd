extends Control

signal spawn_enemy_requested(enemy_type: String)
signal reset_cooldowns_requested
signal heal_requested
signal clear_enemies_requested
signal freeze_ai_toggled(frozen: bool)
signal room_jump_requested(room_id: String)

const SPAWN_KEY_MAP := {
	"brute": "C",
	"ranged": "V",
	"boss": "G",
	"dasher": "B",
	"sentinel": "J",
	"elite": "H",
	"leaper": "N",
	"bomber": "Y",
	"charger": "R",
	"dummy": "Q"
}
const SPAWN_BUTTON_LABELS := {
	"brute": "브루트",
	"ranged": "원거리",
	"boss": "보스",
	"dasher": "돌진",
	"sentinel": "감시자",
	"elite": "엘리트",
	"leaper": "도약",
	"bomber": "폭탄",
	"charger": "차저",
	"dummy": "허수아비"
}
const SPAWN_ENEMY_ORDER := [
	"brute", "ranged", "boss", "dasher", "sentinel", "elite", "leaper", "bomber", "charger", "dummy"
]
const ADMIN_TABS := ["hotbar", "resources", "equipment", "spawn", "buffs"]
const ADMIN_TAB_LABELS := {
	"hotbar": "단축창",
	"resources": "자원",
	"equipment": "장비",
	"spawn": "소환",
	"buffs": "버프"
}
const EQUIPMENT_PANEL_TEXTURE: Texture2D = preload("res://assets/ui/pixel_rpg/Equipment.png")
const INVENTORY_PANEL_TEXTURE: Texture2D = preload("res://assets/ui/pixel_rpg/Inventory.png")
const UI_WINDOW_FRAME_SCRIPT := preload("res://scripts/ui/widgets/ui_window_frame.gd")
const EQUIPMENT_RARITY_ORDER := {"common": 0, "uncommon": 1, "rare": 2, "epic": 3, "legendary": 4}
const EQUIPMENT_SLOT_LABELS := {
	"weapon": "무기",
	"offhand": "보조",
	"head": "머리",
	"body": "몸통",
	"legs": "다리",
	"accessory_1": "장신구 1",
	"accessory_2": "장신구 2"
}
const EQUIPMENT_FOCUS_MODES := ["candidate", "owned"]
const EQUIPMENT_SORT_MODES := ["rarity", "name"]
const EQUIPMENT_FILTER_MODES := ["all", "tempo", "ritual", "burst", "defense"]
const EQUIPMENT_PAGE_SIZE := 5
const CANDIDATE_PREVIEW_RADIUS := 1
const HOTBAR_SLOT_COUNT := 6
const BUFF_PAGE_SIZE := 8
const PROTOTYPE_ROOM_PAGE_SIZE := 12
const PROTOTYPE_ROOM_PAGE_COLUMNS := 6
const EQUIPMENT_PANEL_COLUMN_MIN_WIDTH := 36
const EQUIPMENT_PANEL_COLUMN_MAX_WIDTH := 60
const EQUIPMENT_PANEL_COLUMN_SEPARATOR := "  |  "
const EQUIPMENT_VISUAL_PANEL_SCALE := 1.3
const EQUIPMENT_VISUAL_EQUIPMENT_REGION := Rect2(0, 0, 160, 96)
const EQUIPMENT_VISUAL_INVENTORY_REGION := Rect2(231, 0, 105, 101)
const EQUIPMENT_VISUAL_GRID_COLUMNS := 5
const EQUIPMENT_VISUAL_GRID_ROWS := 4
const EQUIPMENT_VISUAL_GRID_CAPACITY := EQUIPMENT_VISUAL_GRID_COLUMNS * EQUIPMENT_VISUAL_GRID_ROWS
const EQUIPMENT_VISUAL_GRID_CELL_ORIGIN := Vector2(10.0, 17.0)
const EQUIPMENT_VISUAL_GRID_CELL_SIZE := Vector2(14.0, 14.0)
const EQUIPMENT_VISUAL_GRID_CELL_PITCH := Vector2(16.0, 16.0)
const EQUIPMENT_VISUAL_SLOT_BUTTON_SIZE := Vector2(30.0, 15.0)
const ADMIN_TAB_ACCENTS := {
	"hotbar": Color(0.31, 0.63, 0.95, 1.0),
	"resources": Color(0.26, 0.74, 0.63, 1.0),
	"equipment": Color(0.98, 0.67, 0.32, 1.0),
	"spawn": Color(0.91, 0.38, 0.36, 1.0),
	"buffs": Color(0.69, 0.52, 0.93, 1.0)
}
var is_open := false
var pause_on_open := true
var selected_slot := 0
var selected_equipment_slot := 0
var selected_library_index := 0
var current_hotbar_preset_id := "default"
var current_tab := "hotbar"
var equipment_focus_mode := "owned"
var equipment_sort_mode := "rarity"
var equipment_filter_mode := "all"
var equipment_panel_layout_mode_override := ""
var recent_granted_slot_name := ""
var recent_granted_item_id := ""
var skill_catalog: Array = []
var buff_catalog: Array = []
var selected_buff_catalog_index := 0
var equipment_slot_order := [
	"weapon", "offhand", "head", "body", "legs", "accessory_1", "accessory_2"
]
var equipment_catalog_by_slot: Dictionary = {}
var equipment_candidate_index_by_slot: Dictionary = {}
var equipment_owned_index_by_slot: Dictionary = {}
var edit_mode := "hotbar"
var library_focus := false
var selected_prototype_room_index := 0
var selected_prototype_room_page := 0
var _style_helper: PanelContainer = null

var panel: PanelContainer
var body_label: Label
var footer_label: Label
var _title_label: Label = null
var _tab_shell: PanelContainer = null
var _tab_button_nodes: Dictionary = {}
var _slot_button_bar: HBoxContainer = null
var _slot_button_nodes: Array[Button] = []
var _hotbar_slot_button_bar: HBoxContainer = null
var _hotbar_slot_button_nodes: Array[Button] = []
var _owned_item_button_bar: HBoxContainer = null
var _owned_item_button_nodes: Array[Button] = []
var _candidate_item_button_bar: HBoxContainer = null
var _candidate_item_button_nodes: Array[Button] = []
var _spawn_button_bar: HBoxContainer = null
var _spawn_button_nodes: Dictionary = {}
var _spawn_action_button_bar: HBoxContainer = null
var _spawn_freeze_button: Button = null
var _resource_button_bar: HBoxContainer = null
var _resource_hp_button: Button = null
var _resource_mp_button: Button = null
var _resource_cd_button: Button = null
var _resource_buff_button: Button = null
var _resource_prev_room_button: Button = null
var _resource_next_room_button: Button = null
var _resource_jump_room_button: Button = null
var _resource_room_page_bar: HBoxContainer = null
var _resource_prev_page_button: Button = null
var _resource_next_page_button: Button = null
var _resource_room_page_label: Label = null
var _resource_room_button_bar: GridContainer = null
var _resource_room_button_nodes: Array[Button] = []
var _buff_item_button_bar: HBoxContainer = null
var _buff_item_button_nodes: Array[Button] = []
var _buff_action_button_bar: HBoxContainer = null
var _buff_prev_page_button: Button = null
var _buff_next_page_button: Button = null
var _preset_button_bar: HBoxContainer = null
var _preset_button_nodes: Dictionary = {}
var _library_item_button_bar: HBoxContainer = null
var _library_item_button_nodes: Array[Button] = []
var _library_focus_button: Button = null
var _equipment_action_button_bar: HBoxContainer = null
var _equipment_interact_button: Button = null
var _equipment_visual_shell: HBoxContainer = null
var _equipment_visual_equipment_panel: Control = null
var _equipment_visual_slot_summary_label: Label = null
var _equipment_visual_slot_button_nodes: Dictionary = {}
var _equipment_visual_inventory_panel: Control = null
var _equipment_visual_inventory_page_label: Label = null
var _equipment_visual_inventory_cell_nodes: Array[Button] = []


func _get_toggle_text(enabled: bool) -> String:
	return "켜짐" if enabled else "꺼짐"


func _get_freeze_state_text(frozen: bool) -> String:
	return "정지" if frozen else "활성"


func _get_edit_mode_label() -> String:
	return "장비" if edit_mode == "equipment" else "단축창"


func _get_enemy_role_label(role: String) -> String:
	match role:
		"melee_chaser":
			return "근접 추격"
		"ranged_harasser":
			return "원거리 견제"
		"boss_volley":
			return "보스 탄막"
		"training_target":
			return "훈련 표적"
		"telegraph_charger":
			return "예고 돌진"
		"area_control":
			return "구역 제어"
		"burst_check":
			return "폭딜 점검"
		"mobile_burst":
			return "기동 폭발"
		"slow_ranged_denial":
			return "지연 투척 견제"
		"punish_stationary":
			return "정지 처벌"
		"flying_ranged_harasser":
			return "비행 견제"
		"ground_charge_presser":
			return "지중 압박 돌진"
		"melee_stunner":
			return "근접 기절"
		"fast_melee_swarm":
			return "고속 근접 떼"
		"slow_bite_chaser":
			return "둔중 추격"
		"flying_observer":
			return "비행 감시"
		"trash_tank":
			return "잡몹 탱커"
		"agile_sword_fighter":
			return "민첩 검투"
	return role


func _get_equipment_rarity_label(rarity: String) -> String:
	match rarity:
		"common":
			return "일반"
		"uncommon":
			return "고급"
		"rare":
			return "희귀"
		"epic":
			return "영웅"
		"legendary":
			return "전설"
	return rarity


func _get_tag_label(tag: String) -> String:
	match tag:
		"all":
			return "전체"
		"tempo":
			return "템포"
		"ritual":
			return "의식"
		"burst":
			return "폭딜"
		"defense":
			return "방어"
		"fire":
			return "화염"
		"ice":
			return "냉기"
		"lightning":
			return "번개"
		"earth":
			return "대지"
		"wind":
			return "바람"
		"water":
			return "물"
		"dark":
			return "암흑"
		"holy":
			return "신성"
		"arcane":
			return "비전"
		"plant":
			return "식물"
		"buff":
			return "버프"
		"deploy":
			return "설치"
		"toggle":
			return "토글"
		"sustain":
			return "유지"
		"guard":
			return "가드"
		"mana":
			return "마나"
		"chain":
			return "연쇄"
		"spread":
			return "확산"
		"projectile":
			return "투사체"
		"pierce":
			return "관통"
		"knockback":
			return "넉백"
		"universal":
			return "범용"
		"dense":
			return "높음"
		"medium":
			return "보통"
		"light":
			return "낮음"
		"none":
			return "없음"
	return tag


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_to_group("admin_menu")
	visible = false
	_style_helper = UI_WINDOW_FRAME_SCRIPT.new()
	_style_helper.visible = false
	_style_helper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_style_helper)
	_build_ui()
	_build_skill_catalog()
	_build_buff_catalog()
	_build_equipment_catalog()
	_refresh()


func _get_admin_tab_accent(tab_id: String) -> Color:
	return ADMIN_TAB_ACCENTS.get(tab_id, Color(0.31, 0.63, 0.95, 1.0))


func _get_current_admin_accent() -> Color:
	return _get_admin_tab_accent(current_tab)


func _apply_admin_button_skin(
	button: Button,
	accent_color: Color,
	is_active: bool = false,
	is_secondary: bool = true
) -> void:
	if button == null:
		return
	_style_helper._apply_action_button_skin(button, accent_color, is_secondary and not is_active)
	button.add_theme_color_override("font_outline_color", accent_color.darkened(0.62))
	button.add_theme_constant_override("outline_size", 1)


func _append_buttons_from_collection(target: Array[Button], collection: Variant) -> void:
	match typeof(collection):
		TYPE_ARRAY:
			for value in collection:
				if value is Button:
					target.append(value)
		TYPE_DICTIONARY:
			for key in collection:
				var value = collection[key]
				if value is Button:
					target.append(value)


func _apply_admin_shell_theme() -> void:
	var accent := _get_current_admin_accent()
	if panel != null:
		panel.add_theme_stylebox_override(
			"panel",
			_style_helper._build_asset_window_panel_style()
		)
	if _tab_shell != null:
		_tab_shell.add_theme_stylebox_override(
			"panel",
			_style_helper._build_asset_compact_panel_style()
		)
	if _title_label != null:
		_title_label.add_theme_color_override("font_color", Color(0.08, 0.12, 0.20, 1.0))
		_title_label.add_theme_color_override("font_outline_color", accent.darkened(0.64))
		_title_label.add_theme_constant_override("outline_size", 1)
	if body_label != null:
		body_label.add_theme_color_override("font_color", Color(0.12, 0.17, 0.24, 1.0))
		body_label.add_theme_color_override("font_outline_color", Color(1.0, 1.0, 1.0, 0.34))
		body_label.add_theme_constant_override("outline_size", 1)
	if footer_label != null:
		footer_label.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 0.92))
		footer_label.add_theme_color_override("font_outline_color", Color(1.0, 1.0, 1.0, 0.28))
		footer_label.add_theme_constant_override("outline_size", 1)
	for tab_id in _tab_button_nodes:
		var tab_button := _tab_button_nodes[tab_id] as Button
		_apply_admin_button_skin(
			tab_button,
			_get_admin_tab_accent(str(tab_id)),
			str(tab_id) == current_tab,
			true
		)
	var shared_buttons: Array[Button] = []
	_append_buttons_from_collection(shared_buttons, _slot_button_nodes)
	_append_buttons_from_collection(shared_buttons, _hotbar_slot_button_nodes)
	_append_buttons_from_collection(shared_buttons, _owned_item_button_nodes)
	_append_buttons_from_collection(shared_buttons, _candidate_item_button_nodes)
	_append_buttons_from_collection(shared_buttons, _spawn_button_nodes)
	_append_buttons_from_collection(shared_buttons, _resource_room_button_nodes)
	_append_buttons_from_collection(shared_buttons, _buff_item_button_nodes)
	_append_buttons_from_collection(shared_buttons, _preset_button_nodes)
	_append_buttons_from_collection(shared_buttons, _library_item_button_nodes)
	_append_buttons_from_collection(shared_buttons, _equipment_visual_slot_button_nodes)
	_append_buttons_from_collection(shared_buttons, _equipment_visual_inventory_cell_nodes)
	var singleton_buttons: Array[Button] = [
		_equipment_interact_button,
		_spawn_freeze_button,
		_resource_hp_button,
		_resource_mp_button,
		_resource_cd_button,
		_resource_buff_button,
		_resource_prev_room_button,
		_resource_next_room_button,
		_resource_jump_room_button,
		_resource_prev_page_button,
		_resource_next_page_button,
		_buff_prev_page_button,
		_buff_next_page_button,
		_library_focus_button
	]
	shared_buttons.append_array(singleton_buttons)
	for button in shared_buttons:
		if button == null:
			continue
		_apply_admin_button_skin(button, accent, not button.flat and not button.disabled, true)


func _get_hotbar_preset_ids() -> Array[String]:
	return GameState.get_hotbar_preset_ids()


func _get_hotbar_preset_label(preset_id: String) -> String:
	var label := str(GameState.get_hotbar_preset_label(preset_id))
	return label if label != "" else preset_id


func _sync_hotbar_preset_state() -> void:
	var preset_state: Dictionary = GameState.get_hotbar_preset_state()
	current_hotbar_preset_id = str(preset_state.get("current_preset_id", ""))


func _get_current_hotbar_preset_display_label() -> String:
	var preset_state: Dictionary = GameState.get_hotbar_preset_state()
	var current_label := str(preset_state.get("current_label", ""))
	if current_label != "":
		return current_label
	if current_hotbar_preset_id != "":
		return _get_hotbar_preset_label(current_hotbar_preset_id)
	return "사용자 지정"


func _push_hotbar_preset_applied_message(preset_id: String) -> void:
	GameState.push_message("단축창 프리셋 %s 적용." % _get_hotbar_preset_label(preset_id), 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("admin_menu"):
		_toggle_menu()
		get_viewport().set_input_as_handled()
		return
	if not is_open:
		return
	if event.is_action_pressed("move_up"):
		if edit_mode == "hotbar":
			if current_tab == "buffs":
				selected_buff_catalog_index = max(selected_buff_catalog_index - 1, 0)
			elif library_focus:
				_cycle_library_selection(-1)
			else:
				selected_slot = max(selected_slot - 1, 0)
				_sync_library_selection_to_slot()
		else:
			_clear_recent_granted_selection()
			selected_equipment_slot = max(selected_equipment_slot - 1, 0)
		_refresh()
	elif event.is_action_pressed("move_down"):
		if edit_mode == "hotbar":
			if current_tab == "buffs":
				selected_buff_catalog_index = mini(
					selected_buff_catalog_index + 1, max(buff_catalog.size() - 1, 0)
				)
			elif library_focus:
				_cycle_library_selection(1)
			else:
				selected_slot = min(selected_slot + 1, GameState.get_spell_hotbar().size() - 1)
				_sync_library_selection_to_slot()
		else:
			_clear_recent_granted_selection()
			selected_equipment_slot = min(
				selected_equipment_slot + 1, equipment_slot_order.size() - 1
			)
		_refresh()
	elif event.is_action_pressed("move_left"):
		if edit_mode == "hotbar":
			if library_focus:
				_cycle_library_selection(-1)
			else:
				_cycle_selected_skill(-1)
		else:
			_cycle_selected_equipment(-1)
		_refresh()
	elif event.is_action_pressed("move_right"):
		if edit_mode == "hotbar":
			if library_focus:
				_cycle_library_selection(1)
			else:
				_cycle_selected_skill(1)
		else:
			_cycle_selected_equipment(1)
		_refresh()
	elif event.is_action_pressed("jump"):
		_apply_next_preset()
		_refresh()
	elif event.is_action_pressed("interact"):
		if edit_mode == "hotbar":
			if current_tab == "buffs":
				_force_activate_selected_buff()
			elif current_tab == "spawn":
				GameState.admin_freeze_ai = not GameState.admin_freeze_ai
				freeze_ai_toggled.emit(GameState.admin_freeze_ai)
				GameState.push_message(
					"적 AI %s." % _get_freeze_state_text(GameState.admin_freeze_ai), 1.2
				)
			elif library_focus:
				_assign_selected_library_skill_to_slot()
			else:
				GameState.set_hotbar_skill(selected_slot, "")
				_sync_library_selection_to_slot()
		else:
			_handle_equipment_interact()
		_refresh()
	elif event.is_action_pressed("dash"):
		GameState.set_admin_infinite_health(not GameState.admin_infinite_health)
		GameState.push_message(
			"무한 HP %s" % _get_toggle_text(GameState.admin_infinite_health), 1.0
		)
		_refresh()
	elif event.is_action_pressed("spell_fire"):
		reset_cooldowns_requested.emit()
		GameState.push_message("모든 재사용 대기시간을 초기화했다.", 1.0)
	elif event.is_action_pressed("spell_ice"):
		spawn_enemy_requested.emit("brute")
		GameState.push_message("브루트를 소환했다.", 1.0)
	elif event.is_action_pressed("spell_lightning"):
		spawn_enemy_requested.emit("ranged")
		GameState.push_message("원거리 적을 소환했다.", 1.0)
	elif event.is_action_pressed("buff_surge"):
		if current_tab == "equipment":
			_cycle_equipment_sort_mode(1)
			GameState.push_message("보유 장비 정렬: %s." % _get_equipment_sort_label(), 1.0)
		elif current_tab == "spawn":
			spawn_enemy_requested.emit("dasher")
			GameState.push_message("돌진 적을 소환했다.", 1.0)
		else:
			_apply_next_equipment_preset()
		_refresh()
	elif event.is_action_pressed("buff_aegis"):
		if current_tab == "hotbar":
			library_focus = not library_focus
			GameState.push_message("라이브러리 포커스 %s" % _get_toggle_text(library_focus), 1.0)
		elif current_tab == "equipment":
			_toggle_equipment_focus()
			GameState.push_message("장비 포커스: %s" % _get_equipment_focus_label(), 1.0)
		_refresh()
	elif event.is_action_pressed("buff_ward"):
		_cycle_tab(1)
		_refresh()
	elif event.is_action_pressed("buff_compression"):
		if current_tab == "equipment":
			if equipment_focus_mode == "candidate":
				_cycle_candidate_window(1)
				GameState.push_message(
					(
						"후보 페이지 %s."
						% _get_candidate_window_short_label(
							str(equipment_slot_order[selected_equipment_slot])
						)
					),
					1.0
				)
			else:
				_cycle_owned_page(1)
				GameState.push_message(
					(
						"보유 페이지 %s."
						% _get_owned_page_short_label(
							str(equipment_slot_order[selected_equipment_slot])
						)
					),
					1.0
				)
		elif current_tab == "spawn":
			spawn_enemy_requested.emit("bomber")
			GameState.push_message("폭탄 적을 소환했다.", 1.0)
		else:
			GameState.set_admin_infinite_mana(not GameState.admin_infinite_mana)
			GameState.push_message(
				"무한 MP %s" % _get_toggle_text(GameState.admin_infinite_mana), 1.0
			)
		_refresh()
	elif event.is_action_pressed("buff_hourglass"):
		if current_tab == "equipment":
			if equipment_focus_mode == "candidate":
				_cycle_candidate_window(-1)
				GameState.push_message(
					(
						"후보 페이지 %s."
						% _get_candidate_window_short_label(
							str(equipment_slot_order[selected_equipment_slot])
						)
					),
					1.0
				)
			else:
				_cycle_owned_page(-1)
				GameState.push_message(
					(
						"보유 페이지 %s."
						% _get_owned_page_short_label(
							str(equipment_slot_order[selected_equipment_slot])
						)
					),
					1.0
				)
		elif current_tab == "spawn":
			spawn_enemy_requested.emit("elite")
			GameState.push_message("엘리트를 소환했다.", 1.0)
		else:
			GameState.set_admin_ignore_cooldowns(not GameState.admin_ignore_cooldowns)
			GameState.push_message(
				"재사용 무시 %s" % _get_toggle_text(GameState.admin_ignore_cooldowns), 1.0
			)
		_refresh()
	elif event.is_action_pressed("buff_pact"):
		if current_tab == "equipment":
			_cycle_equipment_filter_mode(1)
			GameState.push_message("보유 장비 필터: %s." % _get_equipment_filter_label(), 1.0)
		elif current_tab == "spawn":
			spawn_enemy_requested.emit("sentinel")
			GameState.push_message("감시자를 소환했다.", 1.0)
		else:
			GameState.set_admin_ignore_buff_slot_limit(not GameState.admin_ignore_buff_slot_limit)
			GameState.push_message(
				"버프 슬롯 제한 무시 %s" % _get_toggle_text(GameState.admin_ignore_buff_slot_limit),
				1.0
			)
		_refresh()
	elif event.is_action_pressed("buff_tempo"):
		spawn_enemy_requested.emit("boss")
		GameState.push_message("보스 허수아비를 소환했다.", 1.0)
	elif event.is_action_pressed("buff_guard"):
		if current_tab == "equipment":
			var slot_name := str(equipment_slot_order[selected_equipment_slot])
			var candidate_item_id := _get_selected_equipment_candidate_id()
			if GameState.grant_equipment_item(candidate_item_id):
				_apply_post_grant_equipment_selection(slot_name, candidate_item_id)
				GameState.push_message(
					"%s을(를) 인벤토리에 추가했다." % _display_name(candidate_item_id), 1.0
				)
		elif current_tab == "buffs":
			_clear_active_buffs()
		elif current_tab == "spawn":
			clear_enemies_requested.emit()
			GameState.push_message("모든 적을 정리했다.", 1.0)
		else:
			heal_requested.emit()
			GameState.push_message("체력을 회복했다.", 1.0)
	elif event.is_action_pressed("buff_throne"):
		if current_tab == "equipment":
			_cycle_equipment_focus_selection(1)
		elif current_tab == "spawn":
			spawn_enemy_requested.emit("leaper")
			GameState.push_message("도약 적을 소환했다.", 1.0)
		else:
			_adjust_selected_skill_level(1)
		_refresh()
	elif event.is_action_pressed("buff_power"):
		if edit_mode == "hotbar":
			_adjust_selected_skill_level(-1)
			_refresh()
		elif current_tab == "equipment":
			_cycle_equipment_focus_selection(-1)
			_refresh()
		elif current_tab == "spawn":
			spawn_enemy_requested.emit("charger")
			GameState.push_message("차저를 소환했다.", 1.0)
		else:
			spawn_enemy_requested.emit("dummy")
			GameState.push_message("훈련용 허수아비를 소환했다.", 1.0)
	get_viewport().set_input_as_handled()


func _build_ui() -> void:
	panel = PanelContainer.new()
	panel.name = "Panel"
	panel.offset_left = 56.0
	panel.offset_top = 56.0
	panel.offset_right = 620.0
	panel.offset_bottom = 420.0
	panel.visible = true
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	_title_label = Label.new()
	_title_label.text = "관리자 모드"
	_title_label.add_theme_font_size_override("font_size", 28)
	root.add_child(_title_label)

	_tab_shell = PanelContainer.new()
	_tab_shell.name = "TabShell"
	root.add_child(_tab_shell)
	var tab_margin := MarginContainer.new()
	tab_margin.add_theme_constant_override("margin_left", 8)
	tab_margin.add_theme_constant_override("margin_top", 8)
	tab_margin.add_theme_constant_override("margin_right", 8)
	tab_margin.add_theme_constant_override("margin_bottom", 8)
	_tab_shell.add_child(tab_margin)
	var tab_bar := HBoxContainer.new()
	tab_bar.add_theme_constant_override("separation", 4)
	tab_margin.add_child(tab_bar)
	for tab_id in ADMIN_TABS:
		var btn := Button.new()
		btn.text = str(ADMIN_TAB_LABELS.get(tab_id, tab_id))
		btn.name = "TabBtn_%s" % tab_id
		btn.add_theme_font_size_override("font_size", 15)
		btn.pressed.connect(_on_tab_button_pressed.bind(tab_id))
		tab_bar.add_child(btn)
		_tab_button_nodes[tab_id] = btn

	_equipment_visual_shell = HBoxContainer.new()
	_equipment_visual_shell.add_theme_constant_override("separation", 18)
	_equipment_visual_shell.visible = false
	root.add_child(_equipment_visual_shell)

	var equipped_visual_column := VBoxContainer.new()
	equipped_visual_column.add_theme_constant_override("separation", 4)
	_equipment_visual_shell.add_child(equipped_visual_column)

	var equipped_visual_title := Label.new()
	equipped_visual_title.text = "장착 패널"
	equipped_visual_title.add_theme_font_size_override("font_size", 14)
	equipped_visual_column.add_child(equipped_visual_title)

	_equipment_visual_equipment_panel = Control.new()
	_equipment_visual_equipment_panel.custom_minimum_size = (
		EQUIPMENT_VISUAL_EQUIPMENT_REGION.size * EQUIPMENT_VISUAL_PANEL_SCALE
	)
	equipped_visual_column.add_child(_equipment_visual_equipment_panel)

	var equipment_texture_rect := TextureRect.new()
	equipment_texture_rect.texture = _build_atlas_texture(
		EQUIPMENT_PANEL_TEXTURE, EQUIPMENT_VISUAL_EQUIPMENT_REGION
	)
	equipment_texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	equipment_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	equipment_texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_equipment_visual_equipment_panel.add_child(equipment_texture_rect)

	for slot_index in range(equipment_slot_order.size()):
		var slot_name := str(equipment_slot_order[slot_index])
		var slot_btn := Button.new()
		slot_btn.text = _get_equipment_slot_short_label(slot_name)
		slot_btn.add_theme_font_size_override("font_size", 10)
		slot_btn.custom_minimum_size = EQUIPMENT_VISUAL_SLOT_BUTTON_SIZE * EQUIPMENT_VISUAL_PANEL_SCALE
		slot_btn.size = slot_btn.custom_minimum_size
		slot_btn.position = _get_equipment_slot_visual_position(slot_name) * EQUIPMENT_VISUAL_PANEL_SCALE
		slot_btn.pressed.connect(_on_equipment_visual_slot_button_pressed.bind(slot_index))
		_equipment_visual_equipment_panel.add_child(slot_btn)
		_equipment_visual_slot_button_nodes[slot_name] = slot_btn

	_equipment_visual_slot_summary_label = Label.new()
	_equipment_visual_slot_summary_label.add_theme_font_size_override("font_size", 12)
	equipped_visual_column.add_child(_equipment_visual_slot_summary_label)

	var inventory_visual_column := VBoxContainer.new()
	inventory_visual_column.add_theme_constant_override("separation", 4)
	_equipment_visual_shell.add_child(inventory_visual_column)

	var inventory_visual_title := Label.new()
	inventory_visual_title.text = "보유 인벤토리"
	inventory_visual_title.add_theme_font_size_override("font_size", 14)
	inventory_visual_column.add_child(inventory_visual_title)

	_equipment_visual_inventory_panel = Control.new()
	_equipment_visual_inventory_panel.custom_minimum_size = (
		EQUIPMENT_VISUAL_INVENTORY_REGION.size * EQUIPMENT_VISUAL_PANEL_SCALE
	)
	inventory_visual_column.add_child(_equipment_visual_inventory_panel)

	var inventory_texture_rect := TextureRect.new()
	inventory_texture_rect.texture = _build_atlas_texture(
		INVENTORY_PANEL_TEXTURE, EQUIPMENT_VISUAL_INVENTORY_REGION
	)
	inventory_texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	inventory_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	inventory_texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_equipment_visual_inventory_panel.add_child(inventory_texture_rect)

	for cell_index in range(EQUIPMENT_VISUAL_GRID_CAPACITY):
		var inventory_btn := Button.new()
		inventory_btn.text = ""
		inventory_btn.add_theme_font_size_override("font_size", 10)
		inventory_btn.custom_minimum_size = EQUIPMENT_VISUAL_GRID_CELL_SIZE * EQUIPMENT_VISUAL_PANEL_SCALE
		inventory_btn.size = inventory_btn.custom_minimum_size
		inventory_btn.position = _get_equipment_inventory_cell_position(cell_index)
		inventory_btn.pressed.connect(_on_equipment_visual_owned_cell_pressed.bind(cell_index))
		_equipment_visual_inventory_panel.add_child(inventory_btn)
		_equipment_visual_inventory_cell_nodes.append(inventory_btn)

	_equipment_visual_inventory_page_label = Label.new()
	_equipment_visual_inventory_page_label.add_theme_font_size_override("font_size", 12)
	inventory_visual_column.add_child(_equipment_visual_inventory_page_label)

	body_label = Label.new()
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", 17)
	body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body_label)

	_slot_button_bar = HBoxContainer.new()
	_slot_button_bar.add_theme_constant_override("separation", 4)
	_slot_button_bar.visible = false
	for i in range(equipment_slot_order.size()):
		var slot_name := str(equipment_slot_order[i])
		var slot_btn := Button.new()
		slot_btn.text = str(EQUIPMENT_SLOT_LABELS.get(slot_name, slot_name))
		slot_btn.add_theme_font_size_override("font_size", 14)
		slot_btn.pressed.connect(_on_equipment_slot_button_pressed.bind(i))
		_slot_button_bar.add_child(slot_btn)
		_slot_button_nodes.append(slot_btn)
	root.add_child(_slot_button_bar)

	_hotbar_slot_button_bar = HBoxContainer.new()
	_hotbar_slot_button_bar.add_theme_constant_override("separation", 4)
	_hotbar_slot_button_bar.visible = false
	for i in range(HOTBAR_SLOT_COUNT):
		var hbar_btn := Button.new()
		hbar_btn.text = str(i + 1)
		hbar_btn.add_theme_font_size_override("font_size", 14)
		hbar_btn.pressed.connect(_on_hotbar_slot_button_pressed.bind(i))
		_hotbar_slot_button_bar.add_child(hbar_btn)
		_hotbar_slot_button_nodes.append(hbar_btn)
	root.add_child(_hotbar_slot_button_bar)

	_owned_item_button_bar = HBoxContainer.new()
	_owned_item_button_bar.add_theme_constant_override("separation", 4)
	_owned_item_button_bar.visible = false
	for i in range(EQUIPMENT_PAGE_SIZE):
		var owned_btn := Button.new()
		owned_btn.text = "---"
		owned_btn.add_theme_font_size_override("font_size", 13)
		owned_btn.pressed.connect(_on_owned_item_button_pressed.bind(i))
		_owned_item_button_bar.add_child(owned_btn)
		_owned_item_button_nodes.append(owned_btn)
	root.add_child(_owned_item_button_bar)

	_candidate_item_button_bar = HBoxContainer.new()
	_candidate_item_button_bar.add_theme_constant_override("separation", 4)
	_candidate_item_button_bar.visible = false
	for i in range(EQUIPMENT_PAGE_SIZE):
		var cand_btn := Button.new()
		cand_btn.text = "---"
		cand_btn.add_theme_font_size_override("font_size", 13)
		cand_btn.pressed.connect(_on_candidate_item_button_pressed.bind(i))
		_candidate_item_button_bar.add_child(cand_btn)
		_candidate_item_button_nodes.append(cand_btn)
	root.add_child(_candidate_item_button_bar)

	_equipment_action_button_bar = HBoxContainer.new()
	_equipment_action_button_bar.add_theme_constant_override("separation", 4)
	_equipment_action_button_bar.visible = false
	_equipment_interact_button = Button.new()
	_equipment_interact_button.text = "상호작용"
	_equipment_interact_button.add_theme_font_size_override("font_size", 13)
	_equipment_interact_button.pressed.connect(_on_equipment_interact_button_pressed)
	_equipment_action_button_bar.add_child(_equipment_interact_button)
	root.add_child(_equipment_action_button_bar)

	_spawn_button_bar = HBoxContainer.new()
	_spawn_button_bar.add_theme_constant_override("separation", 4)
	_spawn_button_bar.visible = false
	for enemy_type in SPAWN_ENEMY_ORDER:
		var spawn_btn := Button.new()
		spawn_btn.text = str(SPAWN_BUTTON_LABELS.get(enemy_type, enemy_type))
		spawn_btn.add_theme_font_size_override("font_size", 13)
		spawn_btn.pressed.connect(_on_spawn_enemy_button_pressed.bind(enemy_type))
		_spawn_button_bar.add_child(spawn_btn)
		_spawn_button_nodes[enemy_type] = spawn_btn
	root.add_child(_spawn_button_bar)

	_spawn_action_button_bar = HBoxContainer.new()
	_spawn_action_button_bar.add_theme_constant_override("separation", 4)
	_spawn_action_button_bar.visible = false
	var clear_btn := Button.new()
	clear_btn.text = "전체 제거"
	clear_btn.add_theme_font_size_override("font_size", 13)
	clear_btn.pressed.connect(_on_spawn_clear_button_pressed)
	_spawn_action_button_bar.add_child(clear_btn)
	_spawn_freeze_button = Button.new()
	_spawn_freeze_button.text = "AI 정지"
	_spawn_freeze_button.add_theme_font_size_override("font_size", 13)
	_spawn_freeze_button.pressed.connect(_on_spawn_freeze_button_pressed)
	_spawn_action_button_bar.add_child(_spawn_freeze_button)
	root.add_child(_spawn_action_button_bar)

	_resource_button_bar = HBoxContainer.new()
	_resource_button_bar.add_theme_constant_override("separation", 4)
	_resource_button_bar.visible = false
	_resource_hp_button = Button.new()
	_resource_hp_button.text = "무한 HP"
	_resource_hp_button.add_theme_font_size_override("font_size", 13)
	_resource_hp_button.pressed.connect(_on_resource_hp_button_pressed)
	_resource_button_bar.add_child(_resource_hp_button)
	_resource_mp_button = Button.new()
	_resource_mp_button.text = "무한 MP"
	_resource_mp_button.add_theme_font_size_override("font_size", 13)
	_resource_mp_button.pressed.connect(_on_resource_mp_button_pressed)
	_resource_button_bar.add_child(_resource_mp_button)
	_resource_cd_button = Button.new()
	_resource_cd_button.text = "재사용 무시"
	_resource_cd_button.add_theme_font_size_override("font_size", 13)
	_resource_cd_button.pressed.connect(_on_resource_cd_button_pressed)
	_resource_button_bar.add_child(_resource_cd_button)
	_resource_buff_button = Button.new()
	_resource_buff_button.text = "버프 제한 해제"
	_resource_buff_button.add_theme_font_size_override("font_size", 13)
	_resource_buff_button.pressed.connect(_on_resource_buff_button_pressed)
	_resource_button_bar.add_child(_resource_buff_button)
	var heal_btn := Button.new()
	heal_btn.text = "회복"
	heal_btn.add_theme_font_size_override("font_size", 13)
	heal_btn.pressed.connect(_on_resource_heal_button_pressed)
	_resource_button_bar.add_child(heal_btn)
	var reset_cd_btn := Button.new()
	reset_cd_btn.text = "재사용 초기화"
	reset_cd_btn.add_theme_font_size_override("font_size", 13)
	reset_cd_btn.pressed.connect(_on_resource_reset_cd_button_pressed)
	_resource_button_bar.add_child(reset_cd_btn)
	_resource_prev_room_button = Button.new()
	_resource_prev_room_button.text = "< 이전 방"
	_resource_prev_room_button.add_theme_font_size_override("font_size", 13)
	_resource_prev_room_button.pressed.connect(_on_resource_prev_room_button_pressed)
	_resource_button_bar.add_child(_resource_prev_room_button)
	_resource_next_room_button = Button.new()
	_resource_next_room_button.text = "다음 방 >"
	_resource_next_room_button.add_theme_font_size_override("font_size", 13)
	_resource_next_room_button.pressed.connect(_on_resource_next_room_button_pressed)
	_resource_button_bar.add_child(_resource_next_room_button)
	_resource_jump_room_button = Button.new()
	_resource_jump_room_button.text = "이동"
	_resource_jump_room_button.add_theme_font_size_override("font_size", 13)
	_resource_jump_room_button.pressed.connect(_on_resource_jump_room_button_pressed)
	_resource_button_bar.add_child(_resource_jump_room_button)
	root.add_child(_resource_button_bar)

	_resource_room_page_bar = HBoxContainer.new()
	_resource_room_page_bar.add_theme_constant_override("separation", 4)
	_resource_room_page_bar.visible = false
	_resource_prev_page_button = Button.new()
	_resource_prev_page_button.text = "< 이전 묶음"
	_resource_prev_page_button.add_theme_font_size_override("font_size", 13)
	_resource_prev_page_button.pressed.connect(_on_resource_prev_room_page_button_pressed)
	_resource_room_page_bar.add_child(_resource_prev_page_button)
	_resource_room_page_label = Label.new()
	_resource_room_page_label.text = "방 0-0 / 0"
	_resource_room_page_label.add_theme_font_size_override("font_size", 13)
	_resource_room_page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_resource_room_page_bar.add_child(_resource_room_page_label)
	_resource_next_page_button = Button.new()
	_resource_next_page_button.text = "다음 묶음 >"
	_resource_next_page_button.add_theme_font_size_override("font_size", 13)
	_resource_next_page_button.pressed.connect(_on_resource_next_room_page_button_pressed)
	_resource_room_page_bar.add_child(_resource_next_page_button)
	root.add_child(_resource_room_page_bar)

	_resource_room_button_bar = GridContainer.new()
	_resource_room_button_bar.columns = PROTOTYPE_ROOM_PAGE_COLUMNS
	_resource_room_button_bar.add_theme_constant_override("h_separation", 4)
	_resource_room_button_bar.add_theme_constant_override("v_separation", 4)
	_resource_room_button_bar.visible = false
	for room_index in range(PROTOTYPE_ROOM_PAGE_SIZE):
		var room_btn := Button.new()
		room_btn.text = "---"
		room_btn.custom_minimum_size = Vector2(74.0, 0.0)
		room_btn.add_theme_font_size_override("font_size", 12)
		room_btn.pressed.connect(_on_resource_room_page_button_pressed.bind(room_index))
		_resource_room_button_bar.add_child(room_btn)
		_resource_room_button_nodes.append(room_btn)
	root.add_child(_resource_room_button_bar)

	_buff_item_button_bar = HBoxContainer.new()
	_buff_item_button_bar.add_theme_constant_override("separation", 4)
	_buff_item_button_bar.visible = false
	for i in range(BUFF_PAGE_SIZE):
		var buff_btn := Button.new()
		buff_btn.text = "---"
		buff_btn.add_theme_font_size_override("font_size", 13)
		buff_btn.pressed.connect(_on_buff_item_button_pressed.bind(i))
		_buff_item_button_bar.add_child(buff_btn)
		_buff_item_button_nodes.append(buff_btn)
	root.add_child(_buff_item_button_bar)

	_buff_action_button_bar = HBoxContainer.new()
	_buff_action_button_bar.add_theme_constant_override("separation", 4)
	_buff_action_button_bar.visible = false
	_buff_prev_page_button = Button.new()
	_buff_prev_page_button.text = "< 이전"
	_buff_prev_page_button.add_theme_font_size_override("font_size", 13)
	_buff_prev_page_button.pressed.connect(_on_buff_prev_page_pressed)
	_buff_action_button_bar.add_child(_buff_prev_page_button)
	_buff_next_page_button = Button.new()
	_buff_next_page_button.text = "다음 >"
	_buff_next_page_button.add_theme_font_size_override("font_size", 13)
	_buff_next_page_button.pressed.connect(_on_buff_next_page_pressed)
	_buff_action_button_bar.add_child(_buff_next_page_button)
	var buff_activate_btn := Button.new()
	buff_activate_btn.text = "활성화"
	buff_activate_btn.add_theme_font_size_override("font_size", 13)
	buff_activate_btn.pressed.connect(_on_buff_activate_button_pressed)
	_buff_action_button_bar.add_child(buff_activate_btn)
	var buff_clear_btn := Button.new()
	buff_clear_btn.text = "전체 해제"
	buff_clear_btn.add_theme_font_size_override("font_size", 13)
	buff_clear_btn.pressed.connect(_on_buff_clear_button_pressed)
	_buff_action_button_bar.add_child(buff_clear_btn)
	root.add_child(_buff_action_button_bar)

	_preset_button_bar = HBoxContainer.new()
	_preset_button_bar.add_theme_constant_override("separation", 4)
	_preset_button_bar.visible = false
	for preset_id in _get_hotbar_preset_ids():
		var pre_btn := Button.new()
		pre_btn.text = _get_hotbar_preset_label(preset_id)
		pre_btn.add_theme_font_size_override("font_size", 13)
		pre_btn.pressed.connect(_on_preset_button_pressed.bind(preset_id))
		_preset_button_bar.add_child(pre_btn)
		_preset_button_nodes[preset_id] = pre_btn
	root.add_child(_preset_button_bar)

	_library_item_button_bar = HBoxContainer.new()
	_library_item_button_bar.add_theme_constant_override("separation", 4)
	_library_item_button_bar.visible = false
	for i in range(5):
		var lib_btn := Button.new()
		lib_btn.text = "---"
		lib_btn.add_theme_font_size_override("font_size", 13)
		lib_btn.pressed.connect(_on_library_item_button_pressed.bind(i))
		_library_item_button_bar.add_child(lib_btn)
		_library_item_button_nodes.append(lib_btn)
	_library_focus_button = Button.new()
	_library_focus_button.text = "포커스"
	_library_focus_button.add_theme_font_size_override("font_size", 13)
	_library_focus_button.pressed.connect(_on_library_focus_button_pressed)
	_library_item_button_bar.add_child(_library_focus_button)
	root.add_child(_library_item_button_bar)

	footer_label = Label.new()
	footer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer_label.add_theme_font_size_override("font_size", 16)
	root.add_child(footer_label)


func _build_skill_catalog() -> void:
	skill_catalog = [""]
	skill_catalog.append_array(GameDatabase.get_runtime_castable_skill_catalog())


func _build_atlas_texture(texture: Texture2D, region: Rect2) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = region
	return atlas


func _get_equipment_slot_short_label(slot_name: String) -> String:
	match slot_name:
		"weapon":
			return "무기"
		"offhand":
			return "보조"
		"head":
			return "머리"
		"body":
			return "몸통"
		"legs":
			return "다리"
		"accessory_1":
			return "장1"
		"accessory_2":
			return "장2"
	return slot_name.left(2)


func _get_equipment_slot_visual_position(slot_name: String) -> Vector2:
	match slot_name:
		"head":
			return Vector2(24.0, 8.0)
		"weapon":
			return Vector2(6.0, 28.0)
		"offhand":
			return Vector2(54.0, 28.0)
		"body":
			return Vector2(24.0, 40.0)
		"legs":
			return Vector2(24.0, 58.0)
		"accessory_1":
			return Vector2(6.0, 64.0)
		"accessory_2":
			return Vector2(54.0, 64.0)
	return Vector2.ZERO


func _get_equipment_inventory_cell_position(cell_index: int) -> Vector2:
	var row := cell_index / EQUIPMENT_VISUAL_GRID_COLUMNS
	var column := cell_index % EQUIPMENT_VISUAL_GRID_COLUMNS
	var base_position := EQUIPMENT_VISUAL_GRID_CELL_ORIGIN + Vector2(
		float(column) * EQUIPMENT_VISUAL_GRID_CELL_PITCH.x,
		float(row) * EQUIPMENT_VISUAL_GRID_CELL_PITCH.y
	)
	return base_position * EQUIPMENT_VISUAL_PANEL_SCALE


func _cycle_prototype_room_selection(direction: int) -> void:
	var prototype_room_ids := _get_prototype_room_ids()
	if prototype_room_ids.is_empty():
		selected_prototype_room_index = 0
		selected_prototype_room_page = 0
		return
	selected_prototype_room_index = wrapi(
		selected_prototype_room_index + direction, 0, prototype_room_ids.size()
	)
	_sync_prototype_room_selector_state()


func _sync_prototype_room_selector_state() -> void:
	var prototype_room_ids := _get_prototype_room_ids()
	if prototype_room_ids.is_empty():
		selected_prototype_room_index = 0
		selected_prototype_room_page = 0
		return
	selected_prototype_room_index = clampi(
		selected_prototype_room_index, 0, prototype_room_ids.size() - 1
	)
	selected_prototype_room_page = clampi(
		selected_prototype_room_index / PROTOTYPE_ROOM_PAGE_SIZE,
		0,
		_get_prototype_room_page_count() - 1
	)


func _get_prototype_room_page_count() -> int:
	var total_rooms := _get_prototype_room_catalog().size()
	if total_rooms <= 0:
		return 1
	return int(ceili(float(total_rooms) / float(PROTOTYPE_ROOM_PAGE_SIZE)))


func _get_prototype_room_page_start() -> int:
	_sync_prototype_room_selector_state()
	return selected_prototype_room_page * PROTOTYPE_ROOM_PAGE_SIZE


func _get_prototype_room_page_summary() -> String:
	var total_rooms := _get_prototype_room_catalog().size()
	if total_rooms <= 0:
		return "프로토타입 페이지: 없음"
	var page_start := _get_prototype_room_page_start()
	var page_end := mini(page_start + PROTOTYPE_ROOM_PAGE_SIZE, total_rooms)
	return "프로토타입 페이지: %d/%d  (%d-%d/%d)" % [
		selected_prototype_room_page + 1,
		_get_prototype_room_page_count(),
		page_start + 1,
		page_end,
		total_rooms
	]


func _cycle_prototype_room_page(direction: int) -> void:
	var prototype_room_ids := _get_prototype_room_ids()
	if prototype_room_ids.is_empty():
		selected_prototype_room_index = 0
		selected_prototype_room_page = 0
		return
	_sync_prototype_room_selector_state()
	var next_page := clampi(
		selected_prototype_room_page + direction, 0, _get_prototype_room_page_count() - 1
	)
	if next_page == selected_prototype_room_page:
		return
	var page_offset := posmod(selected_prototype_room_index, PROTOTYPE_ROOM_PAGE_SIZE)
	selected_prototype_room_index = mini(
		next_page * PROTOTYPE_ROOM_PAGE_SIZE + page_offset, prototype_room_ids.size() - 1
	)
	selected_prototype_room_page = next_page


func _get_selected_prototype_room_id() -> String:
	var prototype_room_ids := _get_prototype_room_ids()
	if prototype_room_ids.is_empty():
		return ""
	_sync_prototype_room_selector_state()
	return str(prototype_room_ids[selected_prototype_room_index])


func _get_prototype_room_catalog() -> Array[Dictionary]:
	return GameState.get_prototype_room_catalog()


func _get_prototype_room_ids() -> Array[String]:
	var room_ids: Array[String] = []
	for entry in _get_prototype_room_catalog():
		room_ids.append(str(entry.get("room_id", "")))
	return room_ids


func _get_selected_prototype_room_label() -> String:
	var room_id := _get_selected_prototype_room_id()
	var summary: Dictionary = GameState.get_prototype_room_overview_summary(room_id)
	if summary.is_empty():
		return room_id
	return str(summary.get("title", room_id))


func _get_selected_prototype_room_summary() -> String:
	var room_id := _get_selected_prototype_room_id()
	var summary: Dictionary = GameState.get_prototype_room_overview_summary(room_id)
	if summary.is_empty():
		return ""
	return str(summary.get("summary", ""))


func _get_selected_prototype_room_interaction_lines() -> Array[String]:
	var room_id := _get_selected_prototype_room_id()
	var summary: Dictionary = GameState.get_room_interaction_preview_summary(room_id)
	if summary.is_empty():
		return ["- 없음"]
	var lines: Array[String] = []
	for raw_line in summary.get("lines", []):
		lines.append(str(raw_line))
	return lines


func _get_selected_prototype_room_reactive_preview_lines() -> Array[String]:
	var room_id := _get_selected_prototype_room_id()
	var summary: Dictionary = GameState.get_room_reactive_preview_summary(room_id)
	if summary.is_empty():
		return []
	var lines: Array[String] = []
	for raw_line in summary.get("lines", []):
		lines.append(str(raw_line))
	return lines


func _get_selected_room_reactive_residue_summary_lines() -> Array[String]:
	var room_id := _get_selected_prototype_room_id()
	var summary: Dictionary = GameState.get_room_reactive_residue_summary(room_id)
	if summary.is_empty():
		return []
	var lines: Array[String] = []
	for raw_line in summary.get("lines", []):
		lines.append(str(raw_line))
	return lines


func _get_selected_room_payoff_density_lines() -> Array[String]:
	var room_summary := _get_selected_room_reactive_surface_summary()
	if room_summary.is_empty():
		return []
	var residue_slots := int(room_summary.get("total_reactive_surfaces", 0))
	var density := str(room_summary.get("payoff_density", "none"))
	var guidance := ""
	match density:
		"dense":
			guidance = "방에 반응형 보상 표면이 이미 충분히 배치되어 있다."
		"medium":
			guidance = "보상 연계는 충분하지만 반응형 표면 하나를 더 두면 더 매끄럽다."
		"light":
			guidance = "반응형 표면이 하나뿐이라면 이 층의 보상을 더 강하게 만들 여지가 있다."
		_:
			guidance = "아직 반응형 보상 표면이 없다."
	return [
		" 보상 밀도:",
		"- %s  (표면 %d개)" % [_get_tag_label(density), residue_slots],
		"- %s" % guidance
	]


func _get_selected_room_reactive_surface_mix_lines() -> Array[String]:
	var surface_counts := _get_selected_room_reactive_surface_counts()
	if int(surface_counts.get("total", 0)) <= 0:
		return []
	return [
		" 표면 구성:",
		"- 보드  %d" % int(surface_counts.get("board", 0)),
		"- 메아리  %d" % int(surface_counts.get("echo", 0)),
		"- 관문  %d" % int(surface_counts.get("gate", 0))
	]


func _get_selected_room_weakest_link_lines() -> Array[String]:
	var room_id := _get_selected_prototype_room_id()
	if room_id == "":
		return []
	var weakest_link: Dictionary = GameState.get_room_weakest_link_summary(room_id)
	if weakest_link.is_empty():
		return []
	return [
		" 약한 고리:",
		"- %s" % str(weakest_link.get("message", ""))
	]


func _get_selected_room_reactive_surface_counts() -> Dictionary:
	var room_summary := _get_selected_room_reactive_surface_summary()
	var counts := {"board": 0, "echo": 0, "gate": 0, "total": 0}
	if room_summary.is_empty():
		return counts
	counts["board"] = int(room_summary.get("board_count", 0))
	counts["echo"] = int(room_summary.get("echo_count", 0))
	counts["gate"] = int(room_summary.get("gate_count", 0))
	counts["total"] = int(room_summary.get("total_reactive_surfaces", 0))
	return counts


func _get_selected_room_reactive_surface_summary() -> Dictionary:
	var room_id := _get_selected_prototype_room_id()
	if room_id == "":
		return {}
	return GameDatabase.get_room_reactive_surface_summary(room_id)


func _get_phase_cross_check_preview_lines() -> Array[String]:
	var summary: Dictionary = GameState.get_phase_cross_check_summary()
	if summary.is_empty():
		return []
	var lines: Array[String] = []
	for raw_line in summary.get("lines", []):
		lines.append(str(raw_line))
	return lines


func _get_final_warning_preview_lines() -> Array[String]:
	var summary: Dictionary = GameState.get_final_warning_preview_summary()
	if summary.is_empty():
		return []
	var lines: Array[String] = []
	for raw_line in summary.get("lines", []):
		lines.append(str(raw_line))
	return lines


func _get_progression_chain_preview_lines() -> Array[String]:
	var summary: Dictionary = GameState.get_progression_chain_summary()
	if summary.is_empty():
		return []
	return [str(summary.get("line", ""))]


func _get_progression_phase_summary_lines() -> Array[String]:
	var summary: Dictionary = GameState.get_progression_phase_summary()
	if summary.is_empty():
		return []
	return [str(summary.get("line", ""))]


func _get_lore_handoff_summary_lines() -> Array[String]:
	var summary: Dictionary = GameState.get_lore_handoff_summary()
	if summary.is_empty():
		return []
	var lines: Array[String] = []
	for raw_line in summary.get("lines", []):
		lines.append(str(raw_line))
	return lines


func _get_selected_room_phase_note_lines() -> Array[String]:
	var room_id := _get_selected_prototype_room_id()
	if room_id == "":
		return []
	var summary: Dictionary = GameState.get_room_note_summary(room_id)
	if summary.is_empty():
		return []
	return [" 방 메모:", "- %s" % str(summary.get("note", ""))]


func _get_selected_room_path_note_lines() -> Array[String]:
	var room_id := _get_selected_prototype_room_id()
	if room_id == "":
		return []
	var summary: Dictionary = GameState.get_room_path_note_summary(room_id)
	if summary.is_empty():
		return []
	return [" 경로 메모:", "- %s" % str(summary.get("note", ""))]


func _get_selected_room_clue_check_lines() -> Array[String]:
	var room_id := _get_selected_prototype_room_id()
	if room_id == "":
		return []
	var summary: Dictionary = GameState.get_room_clue_check_summary(room_id)
	if summary.is_empty():
		return []
	var lines: Array[String] = [" 단서 점검:"]
	for raw_clue in summary.get("clues", []):
		lines.append("- %s" % str(raw_clue))
	return lines


func _get_selected_room_verification_status_lines() -> Array[String]:
	var room_id := _get_selected_prototype_room_id()
	if room_id == "":
		return []
	var summary: Dictionary = GameState.get_room_verification_status_summary(room_id)
	if summary.is_empty():
		return []
	return [" 검증 상태:", "- %s" % str(summary.get("status", ""))]


func _get_selected_room_next_priority_lines() -> Array[String]:
	var room_id := _get_selected_prototype_room_id()
	if room_id == "":
		return []
	var summary: Dictionary = GameState.get_room_next_priority_summary(room_id)
	if summary.is_empty():
		return []
	return [" 다음 우선순위:", "- %s" % str(summary.get("priority", ""))]


func _get_selected_room_action_candidate_lines() -> Array[String]:
	var room_id := _get_selected_prototype_room_id()
	if room_id == "":
		return []
	var summary: Dictionary = GameState.get_room_action_candidate_summary(room_id)
	if summary.is_empty():
		return []
	var lines: Array[String] = [" 실행 후보:"]
	for raw_action in summary.get("actions", []):
		lines.append("- %s" % str(raw_action))
	return lines


func _build_buff_catalog() -> void:
	buff_catalog = []
	for skill in GameDatabase.get_all_skills():
		if str(skill.get("skill_type", "")) == "buff":
			buff_catalog.append(str(skill.get("skill_id", "")))
	selected_buff_catalog_index = clampi(
		selected_buff_catalog_index, 0, max(buff_catalog.size() - 1, 0)
	)


func _get_buff_tab_lines() -> Array[String]:
	var lines: Array[String] = ["버프  [%d개 사용 가능]" % buff_catalog.size()]
	var page_start := (selected_buff_catalog_index / 8) * 8
	for i in range(page_start, mini(page_start + 8, buff_catalog.size())):
		var skill_id := str(buff_catalog[i])
		var marker := ">" if i == selected_buff_catalog_index else " "
		var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
		var duration_text := ""
		if not skill_data.is_empty():
			duration_text = "  %.0fs" % float(skill_data.get("duration", 0.0))
		lines.append("%s %s%s" % [marker, _display_name(skill_id), duration_text])
	lines.append("")
	var active := GameState.active_buffs
	if active.is_empty():
		lines.append("활성 버프: 없음")
	else:
		lines.append("활성 버프: %d/%d" % [active.size(), GameState.get_buff_slot_limit()])
		for buff in active:
			var sid := str(buff.get("skill_id", ""))
			var rem := "%.1fs" % float(buff.get("remaining", 0.0))
			lines.append("  %s  %s" % [_display_name(sid), rem])
	lines.append("")
	lines.append("연계:")
	var active_combo_names := GameState.get_active_combo_names()
	var all_combos := GameDatabase.get_all_buff_combos()
	if all_combos.is_empty():
		lines.append("  (연계 데이터 없음)")
	else:
		var active_buff_ids: Array[String] = []
		for ab in GameState.active_buffs:
			active_buff_ids.append(str(ab.get("skill_id", "")))
		for combo in all_combos:
			var cname := str(combo.get("display_name", "?"))
			var on_marker := "[활성]" if active_combo_names.has(cname) else "[ ]"
			var reqs: Array = combo.get("required_buffs", [])
			var req_parts: Array[String] = []
			for req in reqs:
				var req_id := str(req)
				var req_check := "[완료]" if active_buff_ids.has(req_id) else "[ ]"
				req_parts.append("%s%s" % [req_check, _display_name(req_id)])
			lines.append("  %s %s  (%s)" % [on_marker, cname, " + ".join(req_parts)])
	if not active_combo_names.is_empty():
		lines.append(GameState.get_combo_summary())
	return lines


func _force_activate_selected_buff() -> void:
	if buff_catalog.is_empty():
		return
	var skill_id := str(buff_catalog[selected_buff_catalog_index])
	if skill_id == "":
		return
	var prev_slot := GameState.admin_ignore_buff_slot_limit
	var prev_cd := GameState.admin_ignore_cooldowns
	GameState.set_admin_ignore_buff_slot_limit(true)
	GameState.set_admin_ignore_cooldowns(true)
	var activated := GameState.try_activate_buff(skill_id)
	GameState.set_admin_ignore_buff_slot_limit(prev_slot)
	GameState.set_admin_ignore_cooldowns(prev_cd)
	if activated:
		GameState.push_message("%s 활성화." % _display_name(skill_id), 1.0)
	else:
		GameState.push_message("%s: 의식 봉인으로 활성화할 수 없다." % _display_name(skill_id), 1.0)
	_refresh()


func _clear_active_buffs() -> void:
	GameState.active_buffs.clear()
	GameState.stats_changed.emit()
	GameState.push_message("활성 버프를 모두 해제했다.", 1.0)
	_refresh()


func _build_equipment_catalog() -> void:
	equipment_catalog_by_slot.clear()
	equipment_candidate_index_by_slot.clear()
	equipment_owned_index_by_slot.clear()
	for slot_name in equipment_slot_order:
		equipment_catalog_by_slot[slot_name] = [""]
		equipment_candidate_index_by_slot[slot_name] = 0
		equipment_owned_index_by_slot[slot_name] = 0
	for item in GameDatabase.get_all_equipment():
		var slot_name := str(item.get("slot_type", ""))
		if not equipment_catalog_by_slot.has(slot_name):
			equipment_catalog_by_slot[slot_name] = [""]
			equipment_candidate_index_by_slot[slot_name] = 0
			equipment_owned_index_by_slot[slot_name] = 0
		equipment_catalog_by_slot[slot_name].append(str(item.get("item_id", "")))


func _refresh() -> void:
	if body_label == null:
		return
	_sync_hotbar_preset_state()
	_refresh_tab_buttons()
	_refresh_equipment_visual_shell()
	_refresh_slot_buttons()
	_refresh_hotbar_slot_buttons()
	_refresh_owned_item_buttons()
	_refresh_candidate_item_buttons()
	_refresh_equipment_action_buttons()
	_refresh_spawn_buttons()
	_refresh_resource_buttons()
	_refresh_buff_buttons()
	_refresh_preset_buttons()
	_refresh_library_buttons()
	var lines: Array[String] = _get_common_status_lines()
	var hotbar: Array = GameState.get_spell_hotbar()
	var selected_skill_id := ""
	for i in range(hotbar.size()):
		if i == selected_slot:
			selected_skill_id = str(hotbar[i].get("skill_id", ""))
	var active_skill_id := _get_active_skill_context_id(selected_skill_id)
	lines.append_array(_get_tab_lines(hotbar, selected_skill_id, active_skill_id))
	body_label.text = "\n".join(lines)
	footer_label.text = _get_footer_text()
	_apply_admin_shell_theme()


func _refresh_equipment_visual_shell() -> void:
	if _equipment_visual_shell == null:
		return
	var is_equipment := current_tab == "equipment"
	_equipment_visual_shell.visible = is_equipment
	if not is_equipment:
		return
	_refresh_equipment_visual_slot_buttons()
	_refresh_equipment_visual_inventory_cells()


func _refresh_equipment_visual_slot_buttons() -> void:
	if _equipment_visual_equipment_panel == null:
		return
	var equipped_items: Dictionary = GameState.get_equipped_items()
	var summary_parts: Array[String] = []
	for slot_index in range(equipment_slot_order.size()):
		var slot_name := str(equipment_slot_order[slot_index])
		var slot_btn: Button = _equipment_visual_slot_button_nodes.get(slot_name, null)
		if slot_btn == null:
			continue
		var equipped_item_id := str(equipped_items.get(slot_name, ""))
		slot_btn.text = _get_equipment_slot_short_label(slot_name)
		slot_btn.tooltip_text = "%s  장착: %s" % [
			str(EQUIPMENT_SLOT_LABELS.get(slot_name, slot_name)),
			_display_name(equipped_item_id)
		]
		slot_btn.flat = (slot_index != selected_equipment_slot)
		if slot_index == selected_equipment_slot:
			summary_parts = [
				"슬롯 %s" % str(EQUIPMENT_SLOT_LABELS.get(slot_name, slot_name)),
				"장착: %s" % _display_name(equipped_item_id)
			]
	if _equipment_visual_slot_summary_label != null:
		_equipment_visual_slot_summary_label.text = "  ".join(summary_parts)


func _refresh_equipment_visual_inventory_cells() -> void:
	if _equipment_visual_inventory_panel == null:
		return
	var slot_name := ""
	if selected_equipment_slot >= 0 and selected_equipment_slot < equipment_slot_order.size():
		slot_name = str(equipment_slot_order[selected_equipment_slot])
	var owned_items: Array = _get_sorted_owned_items_for_slot(slot_name)
	var current_index := int(equipment_owned_index_by_slot.get(slot_name, 0))
	if not owned_items.is_empty():
		current_index = clampi(current_index, 0, owned_items.size() - 1)
	var page_index := (
		int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
		if not owned_items.is_empty()
		else 0
	)
	var page_start := page_index * EQUIPMENT_PAGE_SIZE
	for cell_index in range(_equipment_visual_inventory_cell_nodes.size()):
		var inventory_btn := _equipment_visual_inventory_cell_nodes[cell_index]
		var item_index := page_start + cell_index
		if cell_index < EQUIPMENT_PAGE_SIZE and item_index < owned_items.size():
			var item_id := str(owned_items[item_index])
			inventory_btn.text = str(cell_index + 1)
			inventory_btn.tooltip_text = _get_equipment_list_entry_text(item_id)
			inventory_btn.disabled = false
			inventory_btn.flat = (item_index != current_index)
			continue
		inventory_btn.text = ""
		inventory_btn.tooltip_text = "빈 칸"
		inventory_btn.disabled = true
		inventory_btn.flat = true
	if _equipment_visual_inventory_page_label != null:
		_equipment_visual_inventory_page_label.text = (
			"페이지  %s  (5x4 viewport)"
			% _get_owned_page_short_label(slot_name)
		)


func _refresh_tab_buttons() -> void:
	for tab_id in _tab_button_nodes:
		var btn: Button = _tab_button_nodes[tab_id]
		btn.flat = (tab_id != current_tab)


func _on_tab_button_pressed(tab_id: String) -> void:
	_set_tab(tab_id)
	_refresh()


func debug_click_tab(tab_id: String) -> void:
	_on_tab_button_pressed(tab_id)


func _refresh_slot_buttons() -> void:
	if _slot_button_bar == null:
		return
	var is_equipment := current_tab == "equipment"
	_slot_button_bar.visible = is_equipment
	if not is_equipment:
		return
	for i in range(_slot_button_nodes.size()):
		_slot_button_nodes[i].flat = (i != selected_equipment_slot)


func _on_equipment_slot_button_pressed(slot_index: int) -> void:
	_clear_recent_granted_selection()
	selected_equipment_slot = clampi(slot_index, 0, equipment_slot_order.size() - 1)
	_refresh()


func debug_click_equipment_slot(slot_index: int) -> void:
	_on_equipment_slot_button_pressed(slot_index)


func _on_equipment_visual_slot_button_pressed(slot_index: int) -> void:
	_on_equipment_slot_button_pressed(slot_index)


func _refresh_hotbar_slot_buttons() -> void:
	if _hotbar_slot_button_bar == null:
		return
	var is_hotbar := current_tab == "hotbar"
	_hotbar_slot_button_bar.visible = is_hotbar
	if not is_hotbar:
		return
	for i in range(_hotbar_slot_button_nodes.size()):
		_hotbar_slot_button_nodes[i].flat = (i != selected_slot)


func _on_hotbar_slot_button_pressed(slot_index: int) -> void:
	selected_slot = clampi(slot_index, 0, GameState.get_spell_hotbar().size() - 1)
	_sync_library_selection_to_slot()
	_refresh()


func debug_click_hotbar_slot(slot_index: int) -> void:
	_on_hotbar_slot_button_pressed(slot_index)


func _refresh_owned_item_buttons() -> void:
	if _owned_item_button_bar == null:
		return
	var is_equipment := current_tab == "equipment"
	_owned_item_button_bar.visible = is_equipment
	if not is_equipment:
		return
	if selected_equipment_slot < 0 or selected_equipment_slot >= equipment_slot_order.size():
		for btn in _owned_item_button_nodes:
			btn.text = "---"
			btn.disabled = true
		return
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	var owned_items: Array = _get_sorted_owned_items_for_slot(slot_name)
	var current_index := int(equipment_owned_index_by_slot.get(slot_name, 0))
	if not owned_items.is_empty():
		current_index = clampi(current_index, 0, owned_items.size() - 1)
	var page_index := (
		int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
		if not owned_items.is_empty()
		else 0
	)
	var page_start := page_index * EQUIPMENT_PAGE_SIZE
	for i in range(_owned_item_button_nodes.size()):
		var btn: Button = _owned_item_button_nodes[i]
		var item_index := page_start + i
		if item_index < owned_items.size():
			var item_id := str(owned_items[item_index])
			var short_name := _display_name(item_id).left(10)
			btn.text = short_name
			btn.disabled = false
			btn.flat = (item_index != current_index)
		else:
			btn.text = "---"
			btn.disabled = true
			btn.flat = true


func _on_owned_item_button_pressed(page_position: int) -> void:
	if selected_equipment_slot < 0 or selected_equipment_slot >= equipment_slot_order.size():
		return
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	var owned_items: Array = _get_sorted_owned_items_for_slot(slot_name)
	var current_index := int(equipment_owned_index_by_slot.get(slot_name, 0))
	if not owned_items.is_empty():
		current_index = clampi(current_index, 0, owned_items.size() - 1)
	var page_index := (
		int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
		if not owned_items.is_empty()
		else 0
	)
	var target_index := page_index * EQUIPMENT_PAGE_SIZE + page_position
	if target_index >= owned_items.size():
		return
	_clear_recent_granted_selection()
	equipment_owned_index_by_slot[slot_name] = target_index
	equipment_focus_mode = "owned"
	_refresh()


func debug_click_owned_item_button(page_position: int) -> void:
	_on_owned_item_button_pressed(page_position)


func _on_equipment_visual_owned_cell_pressed(cell_index: int) -> void:
	if cell_index < 0 or cell_index >= EQUIPMENT_PAGE_SIZE:
		return
	_on_owned_item_button_pressed(cell_index)


func _refresh_candidate_item_buttons() -> void:
	if _candidate_item_button_bar == null:
		return
	var is_equipment := current_tab == "equipment"
	_candidate_item_button_bar.visible = is_equipment
	if not is_equipment:
		return
	if selected_equipment_slot < 0 or selected_equipment_slot >= equipment_slot_order.size():
		for btn in _candidate_item_button_nodes:
			btn.text = "---"
			btn.disabled = true
		return
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	var options: Array = equipment_catalog_by_slot.get(slot_name, [])
	var current_index := int(equipment_candidate_index_by_slot.get(slot_name, 0))
	if not options.is_empty():
		current_index = clampi(current_index, 0, options.size() - 1)
	var page_index := (
		int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
		if not options.is_empty()
		else 0
	)
	var page_start := page_index * EQUIPMENT_PAGE_SIZE
	for i in range(_candidate_item_button_nodes.size()):
		var btn: Button = _candidate_item_button_nodes[i]
		var item_index := page_start + i
		if item_index < options.size():
			var item_id := str(options[item_index])
			var short_name := _display_name(item_id).left(10)
			btn.text = short_name
			btn.disabled = false
			btn.flat = (item_index != current_index)
		else:
			btn.text = "---"
			btn.disabled = true
			btn.flat = true


func _on_candidate_item_button_pressed(page_position: int) -> void:
	if selected_equipment_slot < 0 or selected_equipment_slot >= equipment_slot_order.size():
		return
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	var options: Array = equipment_catalog_by_slot.get(slot_name, [])
	var current_index := int(equipment_candidate_index_by_slot.get(slot_name, 0))
	if not options.is_empty():
		current_index = clampi(current_index, 0, options.size() - 1)
	var page_index := (
		int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
		if not options.is_empty()
		else 0
	)
	var target_index := page_index * EQUIPMENT_PAGE_SIZE + page_position
	if target_index >= options.size():
		return
	_clear_recent_granted_selection()
	equipment_candidate_index_by_slot[slot_name] = target_index
	equipment_focus_mode = "candidate"
	_refresh()


func debug_click_candidate_item_button(page_position: int) -> void:
	_on_candidate_item_button_pressed(page_position)


func _get_equipment_interact_label() -> String:
	if selected_equipment_slot < 0 or selected_equipment_slot >= equipment_slot_order.size():
		return "상호작용"
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	if equipment_focus_mode == "candidate":
		var candidate_id := _get_selected_equipment_candidate_id()
		if candidate_id != "":
			return "지급"
	else:
		var owned_id := _get_selected_owned_equipment_id()
		if owned_id != "":
			return "장착"
		var equipped: Dictionary = GameState.get_equipped_items()
		if str(equipped.get(slot_name, "")) != "":
			return "해제"
	return "상호작용"


func _refresh_equipment_action_buttons() -> void:
	if _equipment_action_button_bar == null:
		return
	var is_equipment := current_tab == "equipment"
	_equipment_action_button_bar.visible = is_equipment
	if not is_equipment:
		return
	if _equipment_interact_button != null:
		_equipment_interact_button.text = _get_equipment_interact_label()


func _on_equipment_interact_button_pressed() -> void:
	_handle_equipment_interact()
	_refresh()


func debug_click_equipment_interact() -> void:
	_on_equipment_interact_button_pressed()


func debug_click_equipment_visual_owned_cell(cell_index: int) -> void:
	_on_equipment_visual_owned_cell_pressed(cell_index)


func _refresh_spawn_buttons() -> void:
	if _spawn_button_bar == null or _spawn_action_button_bar == null:
		return
	var is_spawn := current_tab == "spawn"
	_spawn_button_bar.visible = is_spawn
	_spawn_action_button_bar.visible = is_spawn
	if not is_spawn:
		return
	if _spawn_freeze_button != null:
		_spawn_freeze_button.flat = not GameState.admin_freeze_ai


func _on_spawn_enemy_button_pressed(enemy_type: String) -> void:
	spawn_enemy_requested.emit(enemy_type)


func _on_spawn_clear_button_pressed() -> void:
	clear_enemies_requested.emit()


func _on_spawn_freeze_button_pressed() -> void:
	GameState.admin_freeze_ai = not GameState.admin_freeze_ai
	freeze_ai_toggled.emit(GameState.admin_freeze_ai)
	GameState.push_message(
		"적 AI %s." % _get_freeze_state_text(GameState.admin_freeze_ai), 1.2
	)
	_refresh()


func debug_click_spawn_enemy(enemy_type: String) -> void:
	_on_spawn_enemy_button_pressed(enemy_type)


func debug_click_spawn_clear() -> void:
	_on_spawn_clear_button_pressed()


func debug_click_spawn_freeze() -> void:
	_on_spawn_freeze_button_pressed()


func _refresh_resource_buttons() -> void:
	if (
		_resource_button_bar == null
		or _resource_room_page_bar == null
		or _resource_room_button_bar == null
	):
		return
	var is_resource := current_tab == "resources"
	_resource_button_bar.visible = is_resource
	_resource_room_page_bar.visible = is_resource
	_resource_room_button_bar.visible = is_resource
	if not is_resource:
		return
	_sync_prototype_room_selector_state()
	if _resource_hp_button != null:
		_resource_hp_button.flat = not GameState.admin_infinite_health
	if _resource_mp_button != null:
		_resource_mp_button.flat = not GameState.admin_infinite_mana
	if _resource_cd_button != null:
		_resource_cd_button.flat = not GameState.admin_ignore_cooldowns
	if _resource_buff_button != null:
		_resource_buff_button.flat = not GameState.admin_ignore_buff_slot_limit
	if _resource_jump_room_button != null:
		_resource_jump_room_button.text = _get_selected_prototype_room_jump_label()
	var page_start := _get_prototype_room_page_start()
	var prototype_room_catalog := _get_prototype_room_catalog()
	var page_end := mini(page_start + PROTOTYPE_ROOM_PAGE_SIZE, prototype_room_catalog.size())
	if _resource_room_page_label != null:
		if prototype_room_catalog.is_empty():
			_resource_room_page_label.text = "방 0-0 / 0"
		else:
			_resource_room_page_label.text = "방 %d-%d / %d  (%d/%d)" % [
				page_start + 1,
				page_end,
				prototype_room_catalog.size(),
				selected_prototype_room_page + 1,
				_get_prototype_room_page_count()
			]
	if _resource_prev_page_button != null:
		_resource_prev_page_button.disabled = (page_start <= 0)
	if _resource_next_page_button != null:
		_resource_next_page_button.disabled = (page_end >= prototype_room_catalog.size())
	for room_index in range(_resource_room_button_nodes.size()):
		var room_btn: Button = _resource_room_button_nodes[room_index]
		var room_entry: Dictionary = {}
		var catalog_index := page_start + room_index
		if catalog_index < prototype_room_catalog.size():
			room_entry = prototype_room_catalog[catalog_index]
		room_btn.tooltip_text = ""
		room_btn.disabled = room_entry.is_empty()
		if room_entry.is_empty():
			room_btn.text = "---"
			room_btn.flat = true
			continue
		room_btn.text = str(room_entry.get("short_label", room_entry.get("room_id", "")))
		room_btn.flat = (catalog_index != selected_prototype_room_index)
		room_btn.tooltip_text = "%s  %s" % [
			str(room_entry.get("title", room_entry.get("room_id", ""))),
			str(room_entry.get("summary", "")).left(48)
		]


func _on_resource_hp_button_pressed() -> void:
	GameState.set_admin_infinite_health(not GameState.admin_infinite_health)
	GameState.push_message(
		"무한 HP %s" % _get_toggle_text(GameState.admin_infinite_health), 1.0
	)
	_refresh()


func _on_resource_mp_button_pressed() -> void:
	GameState.set_admin_infinite_mana(not GameState.admin_infinite_mana)
	GameState.push_message(
		"무한 MP %s" % _get_toggle_text(GameState.admin_infinite_mana), 1.0
	)
	_refresh()


func _on_resource_cd_button_pressed() -> void:
	GameState.set_admin_ignore_cooldowns(not GameState.admin_ignore_cooldowns)
	GameState.push_message(
		"재사용 무시 %s" % _get_toggle_text(GameState.admin_ignore_cooldowns), 1.0
	)
	_refresh()


func _on_resource_buff_button_pressed() -> void:
	GameState.set_admin_ignore_buff_slot_limit(not GameState.admin_ignore_buff_slot_limit)
	GameState.push_message(
		"버프 슬롯 제한 무시 %s" % _get_toggle_text(GameState.admin_ignore_buff_slot_limit), 1.0
	)
	_refresh()


func _on_resource_heal_button_pressed() -> void:
	heal_requested.emit()


func _on_resource_reset_cd_button_pressed() -> void:
	reset_cooldowns_requested.emit()


func _on_resource_prev_room_button_pressed() -> void:
	_cycle_prototype_room_selection(-1)
	_refresh()


func _on_resource_next_room_button_pressed() -> void:
	_cycle_prototype_room_selection(1)
	_refresh()


func _on_resource_prev_room_page_button_pressed() -> void:
	_cycle_prototype_room_page(-1)
	_refresh()


func _on_resource_next_room_page_button_pressed() -> void:
	_cycle_prototype_room_page(1)
	_refresh()


func _on_resource_jump_room_button_pressed() -> void:
	room_jump_requested.emit(_get_selected_prototype_room_id())


func _on_resource_room_select_button_pressed(room_index: int) -> void:
	selected_prototype_room_index = clampi(room_index, 0, max(_get_prototype_room_ids().size() - 1, 0))
	_sync_prototype_room_selector_state()
	_refresh()


func _on_resource_room_page_button_pressed(page_position: int) -> void:
	var target_index := _get_prototype_room_page_start() + page_position
	if target_index >= _get_prototype_room_ids().size():
		return
	_on_resource_room_select_button_pressed(target_index)


func debug_click_resource_hp() -> void:
	_on_resource_hp_button_pressed()


func debug_click_resource_mp() -> void:
	_on_resource_mp_button_pressed()


func debug_click_resource_cd() -> void:
	_on_resource_cd_button_pressed()


func debug_click_resource_buff() -> void:
	_on_resource_buff_button_pressed()


func debug_cycle_prototype_room_page(direction: int) -> void:
	_cycle_prototype_room_page(direction)
	_refresh()


func debug_cycle_prototype_room(direction: int) -> void:
	_cycle_prototype_room_selection(direction)
	_refresh()


func debug_select_prototype_room(room_id: String) -> void:
	var room_index := _get_prototype_room_ids().find(room_id)
	if room_index == -1:
		return
	_on_resource_room_select_button_pressed(room_index)


func debug_emit_room_jump() -> void:
	_on_resource_jump_room_button_pressed()


func _get_buff_page_start() -> int:
	return (selected_buff_catalog_index / BUFF_PAGE_SIZE) * BUFF_PAGE_SIZE


func _refresh_buff_buttons() -> void:
	if _buff_item_button_bar == null or _buff_action_button_bar == null:
		return
	var is_buffs := current_tab == "buffs"
	_buff_item_button_bar.visible = is_buffs
	_buff_action_button_bar.visible = is_buffs
	if not is_buffs:
		return
	var page_start := _get_buff_page_start()
	var page_count := int(ceili(float(max(buff_catalog.size(), 1)) / float(BUFF_PAGE_SIZE)))
	var current_page := page_start / BUFF_PAGE_SIZE
	if _buff_prev_page_button != null:
		_buff_prev_page_button.disabled = (current_page <= 0)
	if _buff_next_page_button != null:
		_buff_next_page_button.disabled = (current_page >= page_count - 1)
	for i in range(_buff_item_button_nodes.size()):
		var btn: Button = _buff_item_button_nodes[i]
		var item_index := page_start + i
		if item_index < buff_catalog.size():
			var skill_id := str(buff_catalog[item_index])
			btn.text = _display_name(skill_id).left(8)
			btn.disabled = false
			btn.flat = (item_index != selected_buff_catalog_index)
		else:
			btn.text = "---"
			btn.disabled = true
			btn.flat = true


func _on_buff_item_button_pressed(page_position: int) -> void:
	var target_index := _get_buff_page_start() + page_position
	if target_index >= buff_catalog.size():
		return
	selected_buff_catalog_index = target_index
	_refresh()


func _on_buff_prev_page_pressed() -> void:
	var page_start := _get_buff_page_start()
	if page_start <= 0:
		return
	selected_buff_catalog_index = max(page_start - BUFF_PAGE_SIZE, 0)
	_refresh()


func _on_buff_next_page_pressed() -> void:
	var page_start := _get_buff_page_start()
	var next_start := page_start + BUFF_PAGE_SIZE
	if next_start >= buff_catalog.size():
		return
	selected_buff_catalog_index = next_start
	_refresh()


func _on_buff_activate_button_pressed() -> void:
	_force_activate_selected_buff()


func _on_buff_clear_button_pressed() -> void:
	_clear_active_buffs()


func debug_click_buff_item(page_position: int) -> void:
	_on_buff_item_button_pressed(page_position)


func debug_click_buff_activate() -> void:
	_on_buff_activate_button_pressed()


func debug_click_buff_clear() -> void:
	_on_buff_clear_button_pressed()


func debug_buff_next_page() -> void:
	_on_buff_next_page_pressed()


func _refresh_preset_buttons() -> void:
	if _preset_button_bar == null:
		return
	var is_hotbar := current_tab == "hotbar"
	_preset_button_bar.visible = is_hotbar
	if not is_hotbar:
		return
	for preset_id in _preset_button_nodes:
		var btn: Button = _preset_button_nodes[preset_id]
		btn.flat = (preset_id != current_hotbar_preset_id)


func _on_preset_button_pressed(preset_id: String) -> void:
	if not _get_hotbar_preset_ids().has(preset_id):
		return
	_apply_hotbar_preset(preset_id)
	_refresh()


func debug_click_preset(preset_id: String) -> void:
	_on_preset_button_pressed(preset_id)


func _refresh_library_buttons() -> void:
	if _library_item_button_bar == null:
		return
	var is_hotbar := current_tab == "hotbar"
	_library_item_button_bar.visible = is_hotbar
	if not is_hotbar:
		return
	var selected_index := selected_library_index
	if selected_index < 0 or selected_index >= skill_catalog.size():
		selected_index = 0
	var start_index: int = maxi(selected_index - 2, 0)
	var end_index: int = mini(selected_index + 3, skill_catalog.size())
	for i in range(5):
		var btn: Button = _library_item_button_nodes[i]
		var item_index := start_index + i
		if item_index < end_index:
			var skill_id := str(skill_catalog[item_index])
			var label := _display_name(skill_id).left(9) if skill_id != "" else "(비어 있음)"
			btn.text = label
			btn.disabled = false
			btn.flat = (item_index != selected_index)
		else:
			btn.text = "---"
			btn.disabled = true
			btn.flat = true
	if _library_focus_button != null:
		_library_focus_button.flat = not library_focus


func _on_library_item_button_pressed(window_position: int) -> void:
	if skill_catalog.is_empty():
		return
	var selected_index := selected_library_index
	if selected_index < 0 or selected_index >= skill_catalog.size():
		selected_index = 0
	var start_index: int = maxi(selected_index - 2, 0)
	var end_index: int = mini(selected_index + 3, skill_catalog.size())
	var target_index := start_index + window_position
	if target_index >= end_index:
		return
	selected_library_index = target_index
	_refresh()


func _on_library_focus_button_pressed() -> void:
	library_focus = not library_focus
	GameState.push_message("라이브러리 포커스 %s" % _get_toggle_text(library_focus), 1.0)
	_refresh()


func debug_click_library_item(window_position: int) -> void:
	_on_library_item_button_pressed(window_position)


func debug_click_library_focus_toggle() -> void:
	_on_library_focus_button_pressed()


func _get_common_status_lines() -> Array[String]:
	var lines: Array[String] = []
	lines.append("탭: %s" % str(ADMIN_TAB_LABELS.get(current_tab, current_tab)))
	lines.append("편집 모드: %s" % _get_edit_mode_label())
	lines.append("라이브러리 포커스: %s" % _get_toggle_text(library_focus))
	lines.append("선택 슬롯: %d" % (selected_slot + 1))
	lines.append(
		"단축창 프리셋: %s" % _get_current_hotbar_preset_display_label()
	)
	lines.append("무한 HP: %s" % _get_toggle_text(GameState.admin_infinite_health))
	lines.append("무한 MP: %s" % _get_toggle_text(GameState.admin_infinite_mana))
	lines.append("재사용 무시: %s" % _get_toggle_text(GameState.admin_ignore_cooldowns))
	lines.append(
		"버프 슬롯 제한 무시: %s" % _get_toggle_text(GameState.admin_ignore_buff_slot_limit)
	)
	if current_tab == "equipment":
		lines.append("장비 포커스: %s" % _get_equipment_focus_label())
	lines.append(GameState.get_resource_summary())
	lines.append(GameState.get_equipment_summary())
	lines.append("")
	return lines


func _get_tab_lines(
	hotbar: Array, selected_skill_id: String, active_skill_id: String
) -> Array[String]:
	match current_tab:
		"hotbar":
			return _get_hotbar_tab_lines(hotbar, selected_skill_id, active_skill_id)
		"resources":
			return _get_resource_tab_lines()
		"equipment":
			return _get_equipment_tab_lines()
		"spawn":
			return _get_spawn_tab_lines()
		"buffs":
			return _get_buff_tab_lines()
	return ["알 수 없는 탭"]


func _get_hotbar_tab_lines(
	hotbar: Array, selected_skill_id: String, active_skill_id: String
) -> Array[String]:
	var lines: Array[String] = ["단축창"]
	for i in range(hotbar.size()):
		var slot: Dictionary = hotbar[i]
		var marker := ">" if i == selected_slot else " "
		var label := str(slot.get("label", "?"))
		var skill_id := str(slot.get("skill_id", ""))
		var level_text := ""
		if skill_id != "":
			level_text = "  Lv.%d" % GameState.get_skill_level(skill_id)
		lines.append("%s %s  %s%s" % [marker, label, _display_name(skill_id), level_text])
	lines.append("")
	lines.append(_get_selected_skill_detail(active_skill_id))
	lines.append(_get_skill_library_preview(selected_skill_id))
	return lines


func _get_resource_tab_lines() -> Array[String]:
	var circle: int = GameState.get_current_circle()
	var score: float = GameState.get_circle_progress_score()
	var buff_slots: int = GameState.get_buff_slot_limit()
	var drop_line: String = "최근 드롭: 없음"
	if GameState.last_drop_display != "":
		drop_line = "최근 드롭: %s  (누적: %d)" % [GameState.last_drop_display, GameState.session_drops]
	var current_room_id := str(GameState.current_room_id)
	var target_room_id := _get_selected_prototype_room_id()
	var target_room_label := _get_selected_prototype_room_label()
	var target_room_summary := _get_selected_prototype_room_summary()
	var lines: Array[String] = [
		"자원",
		"서클: %d  점수: %.1f  버프 슬롯: %d" % [circle, score, buff_slots],
		(
			"HP: %d/%d  MP: %.0f/%.0f"
			% [GameState.health, GameState.max_health, GameState.mana, GameState.max_mana]
		),
		"HP 고정: %s" % _get_toggle_text(GameState.admin_infinite_health),
		"MP 고정: %s" % _get_toggle_text(GameState.admin_infinite_mana),
		"재사용 고정: %s" % _get_toggle_text(GameState.admin_ignore_cooldowns),
		"버프 제한 고정: %s" % _get_toggle_text(GameState.admin_ignore_buff_slot_limit),
		(
			"세션  처치: %d  타격: %d  피해: %d  드롭: %d"
			% [
				GameState.session_kills,
				GameState.session_hit_count,
				GameState.session_damage_dealt,
				GameState.session_drops
			]
		),
		drop_line,
		"현재 방: %s" % current_room_id,
		"프로토타입 대상: %s" % target_room_id,
		"프로토타입 제목: %s" % target_room_label,
		"프로토타입 요약: %s" % target_room_summary,
		_get_prototype_room_page_summary(),
		"프로토타입 흐름:",
	]
	var flow_summary: Dictionary = GameState.get_prototype_flow_preview_summary(target_room_id)
	for raw_line in flow_summary.get("lines", []).slice(1):
		lines.append(str(raw_line))
	lines.append("상호작용 미리보기:")
	lines.append_array(_get_selected_prototype_room_interaction_lines())
	lines.append_array(_get_selected_prototype_room_reactive_preview_lines())
	lines.append_array(_get_selected_room_reactive_residue_summary_lines())
	lines.append_array(_get_selected_room_payoff_density_lines())
	lines.append_array(_get_selected_room_reactive_surface_mix_lines())
	lines.append_array(_get_selected_room_weakest_link_lines())
	lines.append_array(_get_phase_cross_check_preview_lines())
	lines.append_array(_get_progression_phase_summary_lines())
	lines.append_array(_get_lore_handoff_summary_lines())
	lines.append_array(_get_selected_room_phase_note_lines())
	lines.append_array(_get_selected_room_path_note_lines())
	lines.append_array(_get_selected_room_verification_status_lines())
	lines.append_array(_get_selected_room_next_priority_lines())
	lines.append_array(_get_selected_room_action_candidate_lines())
	lines.append_array(_get_selected_room_clue_check_lines())
	lines.append_array(_get_progression_chain_preview_lines())
	lines.append_array([
		"복구: Q 회복, Z 재사용 초기화",
		"프로토타입 이동: 방 버튼을 누르거나 이동 버튼을 사용"
	])
	return lines


func _get_prototype_room_jump_caption(room_id: String) -> String:
	var summary: Dictionary = GameState.get_prototype_room_overview_summary(room_id)
	if summary.is_empty():
		return room_id
	return "%s (%s)" % [
		str(summary.get("title", room_id)),
		str(summary.get("summary", "")).left(32)
	]


func _get_selected_prototype_room_jump_label() -> String:
	var target_room_id := _get_selected_prototype_room_id()
	for entry in _get_prototype_room_catalog():
		if str(entry.get("room_id", "")) == target_room_id:
			return str(entry.get("jump_label", "이동"))
	return "이동"


func _get_equipment_tab_lines() -> Array[String]:
	var focus_display := equipment_focus_mode.to_upper()
	var lines: Array[String] = ["장비  [%s 패널 활성]" % _get_equipment_focus_label()]
	var equipped: Dictionary = GameState.get_equipped_items()
	for i in range(equipment_slot_order.size()):
		var slot_name: String = str(equipment_slot_order[i])
		var marker := ">" if i == selected_equipment_slot else " "
		lines.append(
			"%s %s  %s" % [marker, str(EQUIPMENT_SLOT_LABELS.get(slot_name, slot_name)), _display_name(str(equipped.get(slot_name, "")))]
		)
	if selected_equipment_slot >= 0 and selected_equipment_slot < equipment_slot_order.size():
		var selected_slot_name := str(equipment_slot_order[selected_equipment_slot])
		var candidate_item_id := _get_selected_equipment_candidate_id()
		var owned_item_id := _get_selected_owned_equipment_id()
		var layout_source := _build_equipment_tab_layout_source(
			_get_equipment_overview_section_lines(
				selected_slot_name, candidate_item_id, owned_item_id
			),
			"장비 포커스  %s" % _get_equipment_focus_label(),
			_get_candidate_panel_lines(selected_slot_name, candidate_item_id),
			_get_owned_panel_lines(selected_slot_name, owned_item_id)
		)
		lines.append("")
		lines.append("선택 슬롯  %s" % str(EQUIPMENT_SLOT_LABELS.get(selected_slot_name, selected_slot_name)))
		lines.append_array(_build_equipment_tab_layout_lines_from_source(layout_source))
		lines.append(GameState.get_equipment_slot_inventory_summary(selected_slot_name))
	lines.append(GameState.get_equipment_inventory_summary())
	lines.append("T 포커스 전환  위/아래 슬롯 선택  F 탭 전환  Q 지급 또는 회복")
	return lines


func _build_equipment_tab_layout_source(
	overview_lines: Array[String],
	focus_line: String,
	candidate_lines: Array[String],
	owned_lines: Array[String]
) -> Dictionary:
	return {
		"overview_lines": overview_lines,
		"focus_line": focus_line,
		"candidate_lines": candidate_lines,
		"owned_lines": owned_lines
	}


func _build_equipment_tab_layout_lines_from_source(layout_source: Dictionary) -> Array[String]:
	var overview_lines: Array = layout_source.get("overview_lines", [])
	var focus_line := str(layout_source.get("focus_line", ""))
	var candidate_lines: Array = layout_source.get("candidate_lines", [])
	var owned_lines: Array = layout_source.get("owned_lines", [])
	var panel_slot_section := _build_equipment_panel_slot_section_source(
		candidate_lines, owned_lines
	)
	return _build_equipment_tab_layout_lines(overview_lines, focus_line, panel_slot_section)


func _build_equipment_tab_layout_lines(
	overview_lines: Array, focus_line: String, panel_slot_section: Dictionary
) -> Array[String]:
	var lines: Array[String] = []
	for line_value in overview_lines:
		lines.append(str(line_value))
	if focus_line != "":
		lines.append(focus_line)
	lines.append_array(_build_equipment_two_panel_bridge_lines())
	lines.append("")
	lines.append_array(_build_equipment_panel_slot_section_lines_from_source(panel_slot_section))
	return lines


func _build_equipment_two_panel_bridge_lines() -> Array[String]:
	var layout_mode := _get_equipment_panel_slot_layout_mode()
	return [
		"패널 열  왼쪽:후보  오른쪽:보유",
		"패널 모드  %s" % _get_equipment_panel_layout_mode_label(layout_mode)
	]


func _build_equipment_panel_slot_lines(
	column_label: String, panel_label: String, panel_lines: Array
) -> Array[String]:
	var lines: Array[String] = ["[%s]" % panel_label]
	for line_value in panel_lines:
		lines.append(str(line_value))
	return lines


func _build_equipment_panel_slot_section_source(
	candidate_lines: Array[String], owned_lines: Array[String]
) -> Dictionary:
	var column_width := _get_equipment_panel_column_width(candidate_lines, owned_lines)
	return {
		"layout_mode": _get_equipment_panel_slot_layout_mode(),
		"column_width": column_width,
		"column_separator": EQUIPMENT_PANEL_COLUMN_SEPARATOR,
		"left_slot_lines": _build_equipment_panel_slot_lines("왼쪽", "후보", candidate_lines),
		"right_slot_lines": _build_equipment_panel_slot_lines("오른쪽", "보유", owned_lines)
	}


func _build_equipment_panel_slot_section_lines_from_source(
	panel_slot_section: Dictionary
) -> Array[String]:
	var layout_mode := str(panel_slot_section.get("layout_mode", "stacked_fallback"))
	if layout_mode == "stacked_fallback":
		return _build_equipment_panel_slot_section_stacked_lines(panel_slot_section)
	if layout_mode == "side_by_side":
		return _build_equipment_panel_slot_section_side_by_side_lines(panel_slot_section)
	return _build_equipment_panel_slot_section_stacked_lines(panel_slot_section)


func _build_equipment_panel_slot_section_stacked_lines(
	panel_slot_section: Dictionary
) -> Array[String]:
	var lines: Array[String] = []
	var left_slot_lines: Array = panel_slot_section.get("left_slot_lines", [])
	var right_slot_lines: Array = panel_slot_section.get("right_slot_lines", [])
	for line_value in left_slot_lines:
		lines.append(str(line_value))
	lines.append("")
	for line_value in right_slot_lines:
		lines.append(str(line_value))
	return lines


func _build_equipment_panel_slot_section_side_by_side_lines(
	panel_slot_section: Dictionary
) -> Array[String]:
	var lines: Array[String] = []
	var left_slot_lines: Array = panel_slot_section.get("left_slot_lines", [])
	var right_slot_lines: Array = panel_slot_section.get("right_slot_lines", [])
	var row_count := maxi(left_slot_lines.size(), right_slot_lines.size())
	var column_width := int(
		panel_slot_section.get(
			"column_width", _get_equipment_panel_column_width(left_slot_lines, right_slot_lines)
		)
	)
	var column_separator := str(
		panel_slot_section.get("column_separator", EQUIPMENT_PANEL_COLUMN_SEPARATOR)
	)
	for i in range(row_count):
		var left_line := ""
		var right_line := ""
		if i < left_slot_lines.size():
			left_line = str(left_slot_lines[i])
		if i < right_slot_lines.size():
			right_line = str(right_slot_lines[i])
		lines.append(
			_build_equipment_side_by_side_row(left_line, right_line, column_width, column_separator)
		)
	return lines


func _get_equipment_panel_column_width(left_slot_lines: Array, _right_slot_lines: Array) -> int:
	var max_width := EQUIPMENT_PANEL_COLUMN_MIN_WIDTH
	for line_value in left_slot_lines:
		max_width = maxi(max_width, str(line_value).length())
	for line_value in _right_slot_lines:
		max_width = maxi(max_width, str(line_value).length())
	return clampi(max_width, EQUIPMENT_PANEL_COLUMN_MIN_WIDTH, EQUIPMENT_PANEL_COLUMN_MAX_WIDTH)


func _clamp_equipment_panel_column_text(text: String, column_width: int) -> String:
	if text.length() <= column_width:
		return text
	if column_width <= 1:
		return text.left(column_width)
	return text.substr(0, column_width - 1) + "~"


func _build_equipment_side_by_side_row(
	left_line: String,
	right_line: String,
	column_width: int,
	column_separator: String = EQUIPMENT_PANEL_COLUMN_SEPARATOR
) -> String:
	var left_clamped := _clamp_equipment_panel_column_text(left_line, column_width)
	var right_clamped := _clamp_equipment_panel_column_text(right_line, column_width)
	if right_clamped == "":
		return left_clamped
	return "%s%s%s" % [left_clamped.rpad(column_width), column_separator, right_clamped]


func _get_equipment_panel_slot_layout_mode() -> String:
	if (
		equipment_panel_layout_mode_override == "stacked_fallback"
		or equipment_panel_layout_mode_override == "side_by_side"
	):
		return equipment_panel_layout_mode_override
	return "side_by_side"


func _get_equipment_panel_layout_mode_label(layout_mode: String) -> String:
	if layout_mode == "side_by_side":
		return "좌우 분할"
	return "세로 적층"


func _get_footer_text() -> String:
	match current_tab:
		"hotbar":
			return "F 탭 전환  T 라이브러리 포커스  위/아래 슬롯 선택  좌/우 스킬 순환  Alt 단축창 프리셋  N/R 스킬 레벨 조정  E 비우기 또는 배치  Esc 닫기"
		"resources":
			return "F 탭 전환  Shift 무한 HP  Y 무한 MP  H 재사용 무시  J 버프 제한 해제  Q 회복  Z 재사용 초기화  Esc 닫기"
		"equipment":
			if _has_recent_granted_owned_selection(
				str(equipment_slot_order[selected_equipment_slot])
			):
				return "F 탭 전환  T 포커스 전환  위/아래 슬롯  좌/우 즉시 장착  B 정렬  J 필터  Y/H 페이지  Q 후보 지급  N/R 집중 패널 순환  E 새 장비 장착  Esc 닫기"
			return "F 탭 전환  T 포커스 전환  위/아래 슬롯  좌/우 즉시 장착  B 정렬  J 필터  Y/H 페이지  Q 후보 지급  N/R 집중 패널 순환  E 현재 동작 실행  Esc 닫기"
		"spawn":
			return "F 탭 전환  C 브루트  V 원거리  R 차저  G 보스  Esc 닫기"
	return "F 탭 전환  Esc 닫기"


func _get_equipment_panel_status_line(panel_name: String) -> String:
	var is_focused := equipment_focus_mode == panel_name
	if panel_name == "candidate":
		var candidate_item_id := _get_selected_equipment_candidate_id()
		var candidate_state := (
			"보유" if GameState.has_equipment_in_inventory(candidate_item_id) else "미보유"
		)
		return "%s  동작:지급  상태:%s" % ["집중" if is_focused else "대기", candidate_state]
	var slot_name := str(equipment_slot_order[selected_equipment_slot])
	var owned_item_id := _get_selected_owned_equipment_id()
	var owned_state := "준비" if owned_item_id != "" else "비어 있음"
	if _has_recent_granted_owned_selection(slot_name):
		return "%s  동작:즉시 장착  상태:신규  [!]" % ["집중" if is_focused else "대기"]
	return "%s  동작:장착  상태:%s" % ["집중" if is_focused else "대기", owned_state]


func _get_spawn_tab_lines() -> Array[String]:
	var lines: Array[String] = ["소환"]
	var enemies: Array = GameDatabase.get_all_enemies()
	if enemies.is_empty():
		lines.append_array(
			[
				"C 브루트",
				"V 원거리",
				"G 보스",
				"B 돌진  (기동 압박 / 예고 돌진)",
				"J 감시자  (구역 제어 / 조준 2연사)",
				"H 엘리트  (폭딜 점검 / 슈퍼아머 / 고체력)",
				"N 도약  (고정 대응 / 예고 점프 / 공중 궤적)",
				"Y 폭탄  (원거리 견제 / 느린 폭탄 / 정지 처벌)",
				"R 차저  (표적 돌진 / 정지 처벌 / 거리 시험)",
				"Q 허수아비  (훈련 표적)"
			]
		)
		return lines
	for enemy_data in enemies:
		var eid: String = str(enemy_data.get("enemy_id", ""))
		var key: String = str(SPAWN_KEY_MAP.get(eid, "?"))
		var name_text: String = str(enemy_data.get("display_name", eid))
		var role_text: String = _get_enemy_role_label(str(enemy_data.get("role", "")))
		var hp: int = int(enemy_data.get("max_hp", 0))
		var armor_tags: Array = enemy_data.get("super_armor_tags", [])
		var armor_note: String = "  [슈퍼아머]" if armor_tags.size() > 0 else ""
		lines.append("%s %s  (%s  HP:%d%s)" % [key, name_text, role_text, hp, armor_note])
	lines.append("")
	var freeze_label: String = _get_freeze_state_text(GameState.admin_freeze_ai)
	lines.append("Q 전체 제거  E AI 정지 [%s]" % freeze_label)
	return lines


func _toggle_menu() -> void:
	is_open = not is_open
	visible = is_open
	if pause_on_open:
		get_tree().paused = is_open
	if is_open:
		_sync_library_selection_to_slot()
	_refresh()


func _cycle_tab(direction: int) -> void:
	var index := ADMIN_TABS.find(current_tab)
	if index == -1:
		index = 0
	index = posmod(index + direction, ADMIN_TABS.size())
	_set_tab(str(ADMIN_TABS[index]))


func _set_tab(tab_id: String) -> void:
	current_tab = tab_id if ADMIN_TAB_LABELS.has(tab_id) else "hotbar"
	if current_tab == "equipment":
		edit_mode = "equipment"
		library_focus = false
	else:
		edit_mode = "hotbar"
		if current_tab != "hotbar":
			library_focus = false


func _cycle_selected_skill(direction: int) -> void:
	var hotbar: Array = GameState.get_spell_hotbar()
	if selected_slot < 0 or selected_slot >= hotbar.size():
		return
	var current_skill := str(hotbar[selected_slot].get("skill_id", ""))
	var index := skill_catalog.find(current_skill)
	if index == -1:
		index = 0
	index = posmod(index + direction, skill_catalog.size())
	GameState.set_hotbar_skill(selected_slot, str(skill_catalog[index]))
	selected_library_index = index


func _apply_next_preset() -> void:
	var preset_id := str(GameState.apply_next_hotbar_preset())
	if preset_id == "":
		return
	_sync_hotbar_preset_state()
	_push_hotbar_preset_applied_message(preset_id)


func _apply_hotbar_preset(preset_id: String) -> void:
	if not GameState.apply_hotbar_preset(preset_id):
		return
	_sync_hotbar_preset_state()
	_push_hotbar_preset_applied_message(preset_id)


func _apply_next_equipment_preset() -> void:
	var preset_id := str(GameState.apply_next_admin_equipment_preset())
	if preset_id == "":
		return
	var preset_label := str(GameState.get_equipment_preset_label(preset_id))
	if preset_label == "":
		preset_label = preset_id
	GameState.push_message("장비 프리셋 %s 적용." % preset_label, 1.0)


func _cycle_selected_equipment(direction: int) -> void:
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	var options: Array = equipment_catalog_by_slot.get(slot_name, [""])
	var equipped: Dictionary = GameState.get_equipped_items()
	var current_item := str(equipped.get(slot_name, ""))
	var index := options.find(current_item)
	if index == -1:
		index = 0
	index = posmod(index + direction, options.size())
	GameState.set_equipped_item(slot_name, str(options[index]))


func _cycle_selected_equipment_candidate(direction: int) -> void:
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	var options: Array = equipment_catalog_by_slot.get(slot_name, [""])
	if options.is_empty():
		equipment_candidate_index_by_slot[slot_name] = 0
		return
	var current_index := int(equipment_candidate_index_by_slot.get(slot_name, 0))
	current_index = posmod(current_index + direction, options.size())
	equipment_candidate_index_by_slot[slot_name] = current_index


func _toggle_equipment_focus() -> void:
	var current_index := EQUIPMENT_FOCUS_MODES.find(equipment_focus_mode)
	if current_index == -1:
		current_index = 0
	current_index = posmod(current_index + 1, EQUIPMENT_FOCUS_MODES.size())
	_clear_recent_granted_selection()
	equipment_focus_mode = str(EQUIPMENT_FOCUS_MODES[current_index])


func _cycle_equipment_focus_selection(direction: int) -> void:
	if equipment_focus_mode == "candidate":
		_cycle_selected_equipment_candidate(direction)
		return
	_cycle_selected_owned_equipment(direction)


func _get_equipment_focus_label() -> String:
	return "후보" if equipment_focus_mode == "candidate" else "보유"


func _get_equipment_focus_marker(focus_mode: String) -> String:
	if equipment_focus_mode == focus_mode:
		return "  [집중]"
	return ""


func _get_selected_equipment_candidate_id() -> String:
	if selected_equipment_slot < 0 or selected_equipment_slot >= equipment_slot_order.size():
		return ""
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	var options: Array = equipment_catalog_by_slot.get(slot_name, [""])
	if options.is_empty():
		return ""
	var current_index := int(equipment_candidate_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, options.size() - 1)
	return str(options[current_index])


func _get_candidate_selection_line(slot_name: String) -> String:
	var options: Array = equipment_catalog_by_slot.get(slot_name, [""])
	if options.is_empty():
		return _build_equipment_selection_line("후보", "candidate", "없음", 0, 0)
	var current_index := int(equipment_candidate_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, options.size() - 1)
	var candidate_item_id := str(options[current_index])
	return _build_equipment_selection_line(
		"후보",
		"candidate",
		_display_name(candidate_item_id),
		current_index + 1,
		options.size()
	)


func _get_candidate_window_line(slot_name: String) -> String:
	var options: Array = equipment_catalog_by_slot.get(slot_name, [""])
	if options.is_empty():
		return _build_equipment_nav_line("후보", ["0/0"])
	var current_index := int(equipment_candidate_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, options.size() - 1)
	var page_index := int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
	var start_item := page_index * EQUIPMENT_PAGE_SIZE + 1
	var end_item := mini((page_index + 1) * EQUIPMENT_PAGE_SIZE, options.size())
	return _build_equipment_nav_line(
		"후보", ["아이템 %d-%d/%d" % [start_item, end_item, options.size()]]
	)


func _get_candidate_window_short_label(slot_name: String) -> String:
	var window_line := _get_candidate_window_line(slot_name)
	return window_line.trim_prefix("후보 탐색  ")


func _get_selected_candidate_meta_line(item_id: String) -> String:
	if item_id == "":
		return "후보 상세  없음"
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return "후보 상세  없음"
	var tags_value = item.get("tags", [])
	var tags: Array[String] = []
	if typeof(tags_value) == TYPE_ARRAY:
		for tag_value in tags_value:
			tags.append(_get_tag_label(str(tag_value)))
	var tags_text := "-" if tags.is_empty() else ", ".join(tags)
	var description_text := str(item.get("description", ""))
	return "후보 상세  %s\n태그:%s" % [description_text, tags_text]


func _get_candidate_compare_line(slot_name: String, candidate_item_id: String) -> String:
	if candidate_item_id == "":
		return "후보 비교  없음"
	var candidate_item: Dictionary = GameDatabase.get_equipment(candidate_item_id)
	if candidate_item.is_empty():
		return "후보 비교  없음"
	var equipped_items: Dictionary = GameState.get_equipped_items()
	var equipped_item_id := str(equipped_items.get(slot_name, ""))
	if equipped_item_id == "":
		return "후보 비교  기준 장비 없음"
	var equipped_item: Dictionary = GameDatabase.get_equipment(equipped_item_id)
	if equipped_item.is_empty():
		return "후보 비교  기준 장비 없음"
	var candidate_modifiers: Dictionary = candidate_item.get("stat_modifiers", {})
	var equipped_modifiers: Dictionary = equipped_item.get("stat_modifiers", {})
	var compare_parts: Array[String] = []
	_append_compare_part(
		compare_parts, "magic_attack", "마공", candidate_modifiers, equipped_modifiers
	)
	_append_compare_part(compare_parts, "max_hp", "최대HP", candidate_modifiers, equipped_modifiers)
	_append_compare_part(compare_parts, "max_mp", "최대MP", candidate_modifiers, equipped_modifiers)
	_append_compare_part(
		compare_parts, "mp_regen", "MP회복", candidate_modifiers, equipped_modifiers
	)
	_append_compare_part(
		compare_parts, "cooldown_recovery", "재감", candidate_modifiers, equipped_modifiers, true
	)
	_append_damage_taken_compare_part(compare_parts, candidate_modifiers, equipped_modifiers)
	if compare_parts.is_empty():
		return "후보 비교  유틸 / 동급"
	return "후보 비교  %s" % "  ".join(compare_parts)


func _get_candidate_view_line(slot_name: String, candidate_item_id: String) -> String:
	var ownership_text := (
		"보유" if GameState.has_equipment_in_inventory(candidate_item_id) else "미보유"
	)
	return _build_equipment_view_line(
		"후보",
		["상태:%s" % ownership_text, "탐색:%s" % _get_candidate_window_short_label(slot_name)]
	)


func _get_equipment_compare_section_lines(
	slot_name: String, candidate_item_id: String
) -> Array[String]:
	return [
		_get_equipment_compare_header_line(slot_name, candidate_item_id),
		_get_selected_equipped_stat_line(slot_name),
		_get_candidate_compare_line(slot_name, candidate_item_id)
	]


func _get_equipment_overview_section_lines(
	slot_name: String, candidate_item_id: String, owned_item_id: String
) -> Array[String]:
	var overview_source := _build_equipment_overview_section_source(
		slot_name, candidate_item_id, owned_item_id
	)
	return _build_equipment_overview_section_lines_from_source(overview_source)


func _build_equipment_overview_section_source(
	slot_name: String, candidate_item_id: String, owned_item_id: String
) -> Dictionary:
	return {
		"compare_lines": _get_equipment_compare_section_lines(slot_name, candidate_item_id),
		"dual_panel_preview_lines":
		_get_equipment_dual_panel_preview_lines(slot_name, candidate_item_id, owned_item_id)
	}


func _build_equipment_overview_section_lines_from_source(
	overview_source: Dictionary
) -> Array[String]:
	var lines: Array[String] = []
	var compare_lines: Array = overview_source.get("compare_lines", [])
	var dual_panel_preview_lines: Array = overview_source.get("dual_panel_preview_lines", [])
	for line_value in compare_lines:
		lines.append(str(line_value))
	for line_value in dual_panel_preview_lines:
		lines.append(str(line_value))
	return lines


func _get_equipment_dual_panel_preview_lines(
	slot_name: String, candidate_item_id: String, owned_item_id: String
) -> Array[String]:
	var preview_source := _build_equipment_dual_panel_preview_source(
		slot_name, candidate_item_id, owned_item_id
	)
	return _build_equipment_dual_panel_preview_lines_from_source(preview_source)


func _build_equipment_dual_panel_preview_source(
	slot_name: String, candidate_item_id: String, owned_item_id: String
) -> Dictionary:
	return {
		"candidate_name": _display_name(candidate_item_id),
		"owned_name": _display_name(owned_item_id),
		"candidate_action": _get_equipment_panel_action_label("candidate", slot_name),
		"owned_action": _get_equipment_panel_action_label("owned", slot_name),
		"candidate_browse": _get_candidate_window_short_label(slot_name),
		"owned_browse": _get_owned_page_short_label(slot_name)
	}


func _build_equipment_dual_panel_preview_lines_from_source(
	preview_source: Dictionary
) -> Array[String]:
	return [
		(
			"패널 요약  후보:%s  보유:%s"
			% [
				str(preview_source.get("candidate_name", "(비어 있음)")),
				str(preview_source.get("owned_name", "(비어 있음)"))
			]
		),
		(
			"패널 흐름  후보:%s  보유:%s  탐색:%s | %s"
			% [
				str(preview_source.get("candidate_action", "지급")),
				str(preview_source.get("owned_action", "장착")),
				str(preview_source.get("candidate_browse", "0/0")),
				str(preview_source.get("owned_browse", "0/0"))
			]
		)
	]


func _get_equipment_panel_action_label(panel_name: String, slot_name: String) -> String:
	if panel_name == "candidate":
		return "지급"
	if _has_recent_granted_owned_selection(slot_name):
		return "즉시 장착"
	return "장착"


func _get_candidate_panel_lines(slot_name: String, candidate_item_id: String) -> Array[String]:
	var body_source := _get_candidate_panel_body_source(slot_name, candidate_item_id)
	var body_lines := _build_equipment_panel_body_lines(body_source)
	return _build_equipment_panel_lines(
		"candidate",
		"후보",
		"후보 상태  %s" % _get_equipment_panel_status_line("candidate"),
		body_lines,
		"  N/R 후보 순환  E 인벤토리에 지급"
	)


func _get_owned_panel_lines(slot_name: String, owned_item_id: String) -> Array[String]:
	var body_source := _get_owned_panel_body_source(slot_name, owned_item_id)
	var body_lines := _build_equipment_panel_body_lines(body_source)
	return _build_equipment_panel_lines(
		"owned",
		"보유",
		"보유 상태  %s" % _get_equipment_panel_status_line("owned"),
		body_lines,
		"  N/R 보유 순환  E 장착  B 정렬  J 필터  Y/H 페이지"
	)


func _build_equipment_panel_lines(
	panel_name: String,
	label: String,
	status_line: String,
	body_lines: Array[String],
	control_hint: String
) -> Array[String]:
	var lines: Array[String] = [_get_equipment_panel_header_line(panel_name, label), status_line]
	lines.append_array(body_lines)
	_append_equipment_panel_control_hint(lines, panel_name, control_hint)
	return lines


func _build_equipment_panel_body_source(
	primary_line: String, content_section: Dictionary
) -> Dictionary:
	return {"primary_line": primary_line, "content_section": content_section}


func _build_equipment_navigation_section_source(
	view_line: String, selection_line: String, navigation_line: String
) -> Dictionary:
	return {
		"view_line": view_line, "selection_line": selection_line, "navigation_line": navigation_line
	}


func _build_equipment_panel_content_section_source(
	detail_line: String, navigation_section: Dictionary, list_lines: Array[String]
) -> Dictionary:
	return {
		"detail_line": detail_line,
		"navigation_section": navigation_section,
		"list_lines": list_lines
	}


func _get_candidate_panel_body_source(slot_name: String, candidate_item_id: String) -> Dictionary:
	return _build_equipment_panel_body_source(
		_get_candidate_selection_line(slot_name),
		_build_equipment_panel_content_section_source(
			_get_selected_candidate_meta_line(candidate_item_id),
			_build_equipment_navigation_section_source(
				_get_candidate_view_line(slot_name, candidate_item_id),
				"",
				_get_candidate_window_line(slot_name)
			),
			_get_candidate_preview_lines(slot_name)
		),
	)


func _get_owned_panel_body_source(slot_name: String, owned_item_id: String) -> Dictionary:
	return _build_equipment_panel_body_source(
		_get_owned_primary_line(slot_name, owned_item_id),
		_build_equipment_panel_content_section_source(
			_get_selected_owned_equipment_meta_line(owned_item_id),
			_build_equipment_navigation_section_source(
				_get_owned_view_line(),
				_get_owned_selection_line(),
				_get_owned_navigation_line(slot_name)
			),
			_get_owned_equipment_preview_lines(slot_name)
		),
	)


func _build_equipment_panel_body_lines(body_source: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var primary_line := str(body_source.get("primary_line", ""))
	var content_section: Dictionary = body_source.get("content_section", {})
	if primary_line != "":
		lines.append(primary_line)
	lines.append_array(_build_equipment_panel_content_section_lines(content_section))
	return lines


func _build_equipment_panel_content_section_lines(content_section: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var detail_line := str(content_section.get("detail_line", ""))
	var navigation_section: Dictionary = content_section.get("navigation_section", {})
	var view_line := str(navigation_section.get("view_line", ""))
	var selection_line := str(navigation_section.get("selection_line", ""))
	var navigation_line := str(navigation_section.get("navigation_line", ""))
	var list_lines: Array = content_section.get("list_lines", [])
	if detail_line != "":
		for sub_line in detail_line.split("\n"):
			if sub_line != "":
				lines.append(sub_line)
	lines.append_array(
		_build_equipment_navigation_section_lines(view_line, selection_line, navigation_line)
	)
	for line_value in list_lines:
		lines.append(str(line_value))
	return lines


func _build_equipment_navigation_section_lines(
	view_line: String, selection_line: String, navigation_line: String
) -> Array[String]:
	var lines: Array[String] = []
	if view_line != "":
		lines.append(view_line)
	if selection_line != "":
		lines.append(selection_line)
	if navigation_line != "":
		lines.append(navigation_line)
	return lines


func _get_equipment_panel_header_line(panel_name: String, label: String) -> String:
	if equipment_focus_mode == panel_name:
		return "-- %s --" % label
	return "   %s" % label


func _append_equipment_panel_control_hint(
	lines: Array[String], panel_name: String, control_hint: String
) -> void:
	if equipment_focus_mode == panel_name:
		lines.append(control_hint)


func _get_equipment_compare_header_line(slot_name: String, candidate_item_id: String) -> String:
	var equipped_items: Dictionary = GameState.get_equipped_items()
	var equipped_item_id := str(equipped_items.get(slot_name, ""))
	var equipped_name := _display_name(equipped_item_id)
	var candidate_name := _display_name(candidate_item_id)
	return "비교 기준  착용:%s  후보:%s" % [equipped_name, candidate_name]


func _append_compare_part(
	compare_parts: Array[String],
	stat_key: String,
	label: String,
	candidate_modifiers: Dictionary,
	equipped_modifiers: Dictionary,
	is_percent := false
) -> void:
	var candidate_value := float(candidate_modifiers.get(stat_key, 0.0))
	var equipped_value := float(equipped_modifiers.get(stat_key, 0.0))
	var delta := candidate_value - equipped_value
	if is_equal_approx(delta, 0.0):
		return
	var sign := "+" if delta > 0.0 else ""
	if is_percent:
		compare_parts.append("%s %s%s%%" % [label, sign, _format_percent_number(delta * 100.0)])
		return
	compare_parts.append("%s %s%s" % [label, sign, _format_stat_number(delta)])


func _append_damage_taken_compare_part(
	compare_parts: Array[String], candidate_modifiers: Dictionary, equipped_modifiers: Dictionary
) -> void:
	var candidate_dr := 1.0 - float(candidate_modifiers.get("damage_taken_multiplier", 1.0))
	var equipped_dr := 1.0 - float(equipped_modifiers.get("damage_taken_multiplier", 1.0))
	var delta := candidate_dr - equipped_dr
	if is_equal_approx(delta, 0.0):
		return
	var sign := "+" if delta > 0.0 else ""
	compare_parts.append("피감 %s%s%%" % [sign, _format_percent_number(delta * 100.0)])


func _get_candidate_preview_lines(slot_name: String) -> Array[String]:
	var options: Array = equipment_catalog_by_slot.get(slot_name, [""])
	if options.is_empty():
		return ["후보 목록  없음"]
	var current_index := int(equipment_candidate_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, options.size() - 1)
	var page_index := int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
	var start_index := page_index * EQUIPMENT_PAGE_SIZE
	var end_index := mini(start_index + EQUIPMENT_PAGE_SIZE, options.size())
	var lines: Array[String] = ["후보 목록"]
	for i in range(start_index, end_index):
		var item_id := str(options[i])
		var marker := ">" if i == current_index else "-"
		lines.append("%s %s" % [marker, _get_candidate_list_entry_text(item_id)])
	return lines


func _cycle_candidate_window(direction: int) -> void:
	_clear_recent_granted_selection()
	if selected_equipment_slot < 0 or selected_equipment_slot >= equipment_slot_order.size():
		return
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	var options: Array = equipment_catalog_by_slot.get(slot_name, [""])
	if options.is_empty():
		equipment_candidate_index_by_slot[slot_name] = 0
		return
	var current_index := int(equipment_candidate_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, options.size() - 1)
	var current_page_index := int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
	var page_count := int(ceili(float(options.size()) / float(EQUIPMENT_PAGE_SIZE)))
	var next_page_index := clampi(current_page_index + direction, 0, max(page_count - 1, 0))
	var next_index := next_page_index * EQUIPMENT_PAGE_SIZE
	equipment_candidate_index_by_slot[slot_name] = clampi(next_index, 0, options.size() - 1)


func _get_candidate_list_entry_text(item_id: String) -> String:
	if item_id == "":
		return "(비어 있음)"
	var entry_text := _get_equipment_list_entry_text(item_id)
	if GameState.has_equipment_in_inventory(item_id):
		return "%s  [보유]" % entry_text
	return entry_text


func _get_selected_equipped_stat_line(slot_name: String) -> String:
	var equipped: Dictionary = GameState.get_equipped_items()
	var item_id := str(equipped.get(slot_name, ""))
	if item_id == "":
		return "슬롯 스탯  없음"
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return "슬롯 스탯  없음"
	var stat_modifiers: Dictionary = item.get("stat_modifiers", {})
	if stat_modifiers.is_empty():
		return "슬롯 스탯  없음"
	var stat_parts: Array[String] = []
	if stat_modifiers.has("magic_attack"):
		stat_parts.append(
			"MATK +%s" % _format_stat_number(float(stat_modifiers.get("magic_attack", 0.0)))
		)
	if stat_modifiers.has("max_mp"):
		stat_parts.append(
			"최대MP +%s" % _format_stat_number(float(stat_modifiers.get("max_mp", 0.0)))
		)
	if stat_modifiers.has("max_hp"):
		stat_parts.append(
			"최대HP +%s" % _format_stat_number(float(stat_modifiers.get("max_hp", 0.0)))
		)
	if stat_modifiers.has("mp_regen"):
		stat_parts.append(
			"MP회복 +%s" % _format_stat_number(float(stat_modifiers.get("mp_regen", 0.0)))
		)
	if stat_modifiers.has("cooldown_recovery"):
		stat_parts.append(
			(
				"재감 %s%%"
				% _format_percent_number(
					float(stat_modifiers.get("cooldown_recovery", 0.0)) * 100.0
				)
			)
		)
	if stat_modifiers.has("damage_taken_multiplier"):
		var damage_taken_mult := float(stat_modifiers.get("damage_taken_multiplier", 1.0))
		if damage_taken_mult < 1.0:
			stat_parts.append("피감 %s%%" % _format_percent_number((1.0 - damage_taken_mult) * 100.0))
	if stat_parts.is_empty():
		return "슬롯 스탯  유틸 장비"
	return "슬롯 스탯  %s" % "  ".join(stat_parts)


func _format_stat_number(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return "%.1f" % value


func _format_percent_number(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return "%.1f" % value


func _cycle_selected_owned_equipment(direction: int) -> void:
	_clear_recent_granted_selection()
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	var owned_items: Array = _get_sorted_owned_items_for_slot(slot_name)
	if owned_items.is_empty():
		equipment_owned_index_by_slot[slot_name] = 0
		return
	var current_index := int(equipment_owned_index_by_slot.get(slot_name, 0))
	current_index = posmod(current_index + direction, owned_items.size())
	equipment_owned_index_by_slot[slot_name] = current_index


func _get_selected_owned_equipment_id() -> String:
	if selected_equipment_slot < 0 or selected_equipment_slot >= equipment_slot_order.size():
		return ""
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	var owned_items: Array = _get_sorted_owned_items_for_slot(slot_name)
	if owned_items.is_empty():
		equipment_owned_index_by_slot[slot_name] = 0
		return ""
	var current_index := int(equipment_owned_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, owned_items.size() - 1)
	return str(owned_items[current_index])


func _get_selected_owned_equipment_line(slot_name: String, owned_item_id: String) -> String:
	var owned_items: Array = _get_sorted_owned_items_for_slot(slot_name)
	if owned_items.is_empty():
		return _build_equipment_selection_line("보유", "owned", "없음", 0, 0)
	var current_index := int(equipment_owned_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, owned_items.size() - 1)
	return _build_equipment_selection_line(
		"보유", "owned", _display_name(owned_item_id), current_index + 1, owned_items.size()
	)


func _build_equipment_selection_line(
	label: String, focus_mode: String, item_name: String, current_index: int, total: int
) -> String:
	if total <= 0:
		return "%s 선택%s  %s" % [label, _get_equipment_focus_marker(focus_mode), item_name]
	return (
		"%s 선택%s  %s  [%d/%d]"
		% [label, _get_equipment_focus_marker(focus_mode), item_name, current_index, total]
	)


func _get_owned_primary_line(slot_name: String, owned_item_id: String) -> String:
	return _get_selected_owned_equipment_line(slot_name, owned_item_id)


func _get_owned_view_line() -> String:
	var slot_name := str(equipment_slot_order[selected_equipment_slot])
	return _build_equipment_view_line(
		"보유",
		[
			"정렬:%s" % _get_equipment_sort_label(),
			"필터:%s" % _get_equipment_filter_label(),
			"탐색:%s" % _get_owned_page_short_label(slot_name)
		]
	)


func _build_equipment_view_line(label: String, parts: Array[String]) -> String:
	return "%s 보기  %s" % [label, "  ".join(parts)]


func _build_equipment_nav_line(label: String, parts: Array[String]) -> String:
	return "%s 탐색  %s" % [label, "  ".join(parts)]


func _get_owned_selection_line() -> String:
	return ""


func _get_owned_navigation_line(slot_name: String) -> String:
	return _get_owned_equipment_page_line(slot_name)


func _get_selected_owned_equipment_meta_line(item_id: String) -> String:
	if item_id == "":
		return "보유 상세  없음"
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return "보유 상세  없음"
	var tags_value = item.get("tags", [])
	var tags: Array[String] = []
	if typeof(tags_value) == TYPE_ARRAY:
		for tag_value in tags_value:
			tags.append(_get_tag_label(str(tag_value)))
	var tags_text := "-" if tags.is_empty() else ", ".join(tags)
	var description_text := str(item.get("description", ""))
	return "보유 상세  %s\n태그:%s" % [description_text, tags_text]


func _get_owned_equipment_preview_lines(slot_name: String) -> Array[String]:
	var owned_items: Array = _get_sorted_owned_items_for_slot(slot_name)
	if owned_items.is_empty():
		return ["보유 목록  없음"]
	var current_index := int(equipment_owned_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, owned_items.size() - 1)
	var page_index := int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
	var start_index := page_index * EQUIPMENT_PAGE_SIZE
	var end_index := mini(start_index + EQUIPMENT_PAGE_SIZE, owned_items.size())
	var lines: Array[String] = ["보유 목록"]
	for i in range(start_index, end_index):
		var item_id := str(owned_items[i])
		var marker := ">" if i == current_index else "-"
		lines.append("%s %s" % [marker, _get_equipment_list_entry_text(item_id)])
	return lines


func _get_owned_equipment_page_line(slot_name: String) -> String:
	var owned_items: Array = _get_sorted_owned_items_for_slot(slot_name)
	if owned_items.is_empty():
		return _build_equipment_nav_line("보유", ["0/0"])
	var current_index := int(equipment_owned_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, owned_items.size() - 1)
	var page_index := int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
	var page_count := int(ceili(float(owned_items.size()) / float(EQUIPMENT_PAGE_SIZE)))
	var start_item := page_index * EQUIPMENT_PAGE_SIZE + 1
	var end_item := mini((page_index + 1) * EQUIPMENT_PAGE_SIZE, owned_items.size())
	return _build_equipment_nav_line(
		"보유",
		[
			"%d/%d" % [page_index + 1, page_count],
			"아이템 %d-%d/%d" % [start_item, end_item, owned_items.size()]
		]
	)


func _get_owned_page_short_label(slot_name: String) -> String:
	var page_line := _get_owned_equipment_page_line(slot_name)
	return page_line.trim_prefix("보유 탐색  ")


func _cycle_owned_page(direction: int) -> void:
	_clear_recent_granted_selection()
	if selected_equipment_slot < 0 or selected_equipment_slot >= equipment_slot_order.size():
		return
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	var owned_items: Array = _get_sorted_owned_items_for_slot(slot_name)
	if owned_items.is_empty():
		equipment_owned_index_by_slot[slot_name] = 0
		return
	var current_index := int(equipment_owned_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, owned_items.size() - 1)
	var current_page_index := int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
	var page_count := int(ceili(float(owned_items.size()) / float(EQUIPMENT_PAGE_SIZE)))
	var next_page_index := clampi(current_page_index + direction, 0, max(page_count - 1, 0))
	var next_index := next_page_index * EQUIPMENT_PAGE_SIZE
	var max_index := owned_items.size() - 1
	equipment_owned_index_by_slot[slot_name] = clampi(next_index, 0, max_index)


func _cycle_equipment_sort_mode(direction: int) -> void:
	_clear_recent_granted_selection()
	var current_index := EQUIPMENT_SORT_MODES.find(equipment_sort_mode)
	if current_index == -1:
		current_index = 0
	current_index = posmod(current_index + direction, EQUIPMENT_SORT_MODES.size())
	equipment_sort_mode = str(EQUIPMENT_SORT_MODES[current_index])
	for slot_name in equipment_slot_order:
		equipment_owned_index_by_slot[slot_name] = 0


func _get_equipment_sort_label() -> String:
	match equipment_sort_mode:
		"name":
			return "이름"
		_:
			return "등급 -> 이름"


func _cycle_equipment_filter_mode(direction: int) -> void:
	_clear_recent_granted_selection()
	var current_index := EQUIPMENT_FILTER_MODES.find(equipment_filter_mode)
	if current_index == -1:
		current_index = 0
	current_index = posmod(current_index + direction, EQUIPMENT_FILTER_MODES.size())
	equipment_filter_mode = str(EQUIPMENT_FILTER_MODES[current_index])
	for slot_name in equipment_slot_order:
		equipment_owned_index_by_slot[slot_name] = 0


func _get_equipment_filter_label() -> String:
	return _get_tag_label(equipment_filter_mode)


func _get_sorted_owned_items_for_slot(slot_name: String) -> Array:
	var owned_items: Array = GameState.get_equipment_inventory_for_slot(slot_name)
	if equipment_filter_mode != "all":
		var filtered_items: Array = []
		for item_value in owned_items:
			var item_id := str(item_value)
			var item: Dictionary = GameDatabase.get_equipment(item_id)
			var tags_value = item.get("tags", [])
			var matches_filter := false
			if typeof(tags_value) == TYPE_ARRAY:
				for tag_value in tags_value:
					if str(tag_value) == equipment_filter_mode:
						matches_filter = true
						break
			if matches_filter:
				filtered_items.append(item_id)
		owned_items = filtered_items
	owned_items.sort_custom(
		func(a: Variant, b: Variant) -> bool:
			var item_a: Dictionary = GameDatabase.get_equipment(str(a))
			var item_b: Dictionary = GameDatabase.get_equipment(str(b))
			if equipment_sort_mode == "name":
				return _display_name(str(a)).naturalnocasecmp_to(_display_name(str(b))) < 0
			var rarity_a := int(EQUIPMENT_RARITY_ORDER.get(str(item_a.get("rarity", "common")), 0))
			var rarity_b := int(EQUIPMENT_RARITY_ORDER.get(str(item_b.get("rarity", "common")), 0))
			if rarity_a != rarity_b:
				return rarity_a > rarity_b
			return _display_name(str(a)).naturalnocasecmp_to(_display_name(str(b))) < 0
	)
	return owned_items


func _apply_post_grant_equipment_selection(slot_name: String, item_id: String) -> void:
	if item_id == "":
		return
	equipment_filter_mode = "all"
	equipment_focus_mode = "owned"
	recent_granted_slot_name = slot_name
	recent_granted_item_id = item_id
	var owned_items: Array = _get_sorted_owned_items_for_slot(slot_name)
	var selected_index := owned_items.find(item_id)
	if selected_index >= 0:
		equipment_owned_index_by_slot[slot_name] = selected_index


func _clear_recent_granted_selection() -> void:
	recent_granted_slot_name = ""
	recent_granted_item_id = ""


func _has_recent_granted_owned_selection(slot_name: String) -> bool:
	if equipment_focus_mode != "owned":
		return false
	if recent_granted_slot_name != slot_name:
		return false
	if recent_granted_item_id == "":
		return false
	return _get_selected_owned_equipment_id() == recent_granted_item_id


func _get_equipment_list_entry_text(item_id: String) -> String:
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return _display_name(item_id)
	var rarity_text := _get_equipment_rarity_label(str(item.get("rarity", "common")))
	var slot_text := str(EQUIPMENT_SLOT_LABELS.get(str(item.get("slot_type", "")), str(item.get("slot_type", ""))))
	return "%s [%s / %s]" % [_display_name(item_id), rarity_text, slot_text]


func _handle_equipment_interact() -> void:
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	if equipment_focus_mode == "candidate":
		var candidate_item_id := _get_selected_equipment_candidate_id()
		if candidate_item_id != "" and GameState.grant_equipment_item(candidate_item_id):
			_apply_post_grant_equipment_selection(slot_name, candidate_item_id)
			GameState.push_message("%s을(를) 인벤토리에 추가했다." % _display_name(candidate_item_id), 1.0)
			return
		GameState.push_message("지금은 이 후보를 지급할 수 없다.", 1.0)
		return
	var owned_item_id := _get_selected_owned_equipment_id()
	if owned_item_id != "":
		if GameState.equip_inventory_item(slot_name, owned_item_id):
			_clear_recent_granted_selection()
			GameState.push_message(
				"%s을(를) 인벤토리에서 장착했다." % _display_name(owned_item_id), 1.0
			)
			return
	if GameState.unequip_item_to_inventory(slot_name):
		_clear_recent_granted_selection()
		GameState.push_message(
			"%s 슬롯 장비를 인벤토리로 이동했다."
			% str(EQUIPMENT_SLOT_LABELS.get(slot_name, slot_name)),
			1.0
		)
		return
	_clear_recent_granted_selection()
	GameState.set_equipped_item(slot_name, "")


func _adjust_selected_skill_level(delta: int) -> void:
	if edit_mode != "hotbar":
		return
	var hotbar: Array = GameState.get_spell_hotbar()
	if selected_slot < 0 or selected_slot >= hotbar.size():
		return
	var slot_skill_id := str(hotbar[selected_slot].get("skill_id", ""))
	var skill_id := _get_active_skill_context_id(slot_skill_id)
	if skill_id == "":
		GameState.push_message("조정할 스킬이 선택되지 않았다.", 1.0)
		return
	var new_level := clampi(GameState.get_skill_level(skill_id) + delta, 1, 30)
	if GameState.set_skill_level(skill_id, new_level):
		GameState.push_message("%s 레벨을 Lv.%d로 조정했다." % [_display_name(skill_id), new_level], 1.0)


func _get_selected_skill_detail(skill_id: String) -> String:
	if skill_id == "":
		return "스킬  (비어 있음)"
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	if skill_data.is_empty():
		var linked_skill_id := GameDatabase.get_skill_id_for_runtime_spell(skill_id)
		if linked_skill_id != "":
			skill_data = GameDatabase.get_skill_data(linked_skill_id)
	var circle_text := "?"
	if not skill_data.is_empty():
		circle_text = str(skill_data.get("circle", "?"))
	return (
		"스킬  %s  Lv.%d  XP %.0f  서클 %s"
		% [
			_display_name(skill_id),
			GameState.get_skill_level(skill_id),
			GameState.get_skill_experience(skill_id),
			circle_text
		]
	)


func _get_skill_library_preview(selected_skill_id: String) -> String:
	var selected_index: int = selected_library_index
	if selected_index < 0 or selected_index >= skill_catalog.size():
		selected_index = 0
	var start_index: int = maxi(selected_index - 2, 0)
	var end_index: int = mini(selected_index + 3, skill_catalog.size())
	var parts: Array[String] = []
	for i in range(start_index, end_index):
		var skill_id := str(skill_catalog[i])
		var marker := ">" if i == selected_index else "-"
		if skill_id == selected_skill_id and i != selected_index:
			marker = "*"
		if skill_id == "":
			parts.append("%s (비어 있음)" % marker)
			continue
		parts.append(
			"%s %s Lv.%d" % [marker, _display_name(skill_id), GameState.get_skill_level(skill_id)]
		)
	return "스킬 라이브러리  %s" % " | ".join(parts)


func _get_active_skill_context_id(slot_skill_id: String) -> String:
	if (
		library_focus
		and selected_library_index >= 0
		and selected_library_index < skill_catalog.size()
	):
		return str(skill_catalog[selected_library_index])
	return slot_skill_id


func _sync_library_selection_to_slot() -> void:
	var hotbar: Array = GameState.get_spell_hotbar()
	if selected_slot < 0 or selected_slot >= hotbar.size():
		selected_library_index = 0
		return
	var skill_id := str(hotbar[selected_slot].get("skill_id", ""))
	var index := skill_catalog.find(skill_id)
	selected_library_index = index if index >= 0 else 0


func _cycle_library_selection(direction: int) -> void:
	if skill_catalog.is_empty():
		selected_library_index = 0
		return
	selected_library_index = posmod(selected_library_index + direction, skill_catalog.size())


func _assign_selected_library_skill_to_slot() -> void:
	var hotbar: Array = GameState.get_spell_hotbar()
	if selected_slot < 0 or selected_slot >= hotbar.size():
		return
	if selected_library_index < 0 or selected_library_index >= skill_catalog.size():
		return
	var skill_id := str(skill_catalog[selected_library_index])
	GameState.set_hotbar_skill(selected_slot, skill_id)
	GameState.push_message(
		"슬롯 %d에 %s을(를) 배치했다." % [selected_slot + 1, _display_name(skill_id)], 1.0
	)


func _display_name(skill_id: String) -> String:
	if skill_id == "":
		return "(비어 있음)"
	var spell_data: Dictionary = GameDatabase.get_spell(skill_id)
	if not spell_data.is_empty():
		return str(spell_data.get("name", skill_id))
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	if not skill_data.is_empty():
		return str(skill_data.get("display_name", skill_id))
	var equipment_data: Dictionary = GameDatabase.get_equipment(skill_id)
	if not equipment_data.is_empty():
		return str(equipment_data.get("display_name", skill_id))
	return skill_id


func get_admin_tab_summary() -> String:
	var tab_label := str(ADMIN_TAB_LABELS.get(current_tab, current_tab))
	var parts: Array[String] = ["탭[%s]" % tab_label]
	if current_tab == "hotbar":
		parts.append("모드[%s]" % _get_edit_mode_label())
		if library_focus:
			parts.append("라이브러리[켜짐]")
	elif current_tab == "equipment":
		var slot_name := str(equipment_slot_order[selected_equipment_slot])
		parts.append("포커스[%s]" % _get_equipment_focus_label())
		parts.append("슬롯[%s]" % str(EQUIPMENT_SLOT_LABELS.get(slot_name, slot_name)))
		if equipment_focus_mode == "candidate":
			var candidate_item_id := _get_selected_equipment_candidate_id()
			parts.append("탐색[%s]" % _get_candidate_window_short_label(slot_name))
			parts.append("대상[%s]" % _display_name(candidate_item_id))
			if candidate_item_id != "":
				parts.append(
					(
						"보유[%s]"
						% ("예" if GameState.has_equipment_in_inventory(candidate_item_id) else "아니오")
					)
				)
		else:
			var owned_item_id := _get_selected_owned_equipment_id()
			parts.append("탐색[%s]" % _get_owned_page_short_label(slot_name))
			parts.append("대상[%s]" % _display_name(owned_item_id))
	return " ".join(parts)


func debug_toggle() -> void:
	_toggle_menu()


func debug_apply_preset(index: int) -> void:
	var preset_ids := _get_hotbar_preset_ids()
	if index < 0 or index >= preset_ids.size():
		return
	_apply_hotbar_preset(str(preset_ids[index]))
	_refresh()


func debug_apply_named_preset(preset_id: String) -> void:
	if not _get_hotbar_preset_ids().has(preset_id):
		return
	_apply_hotbar_preset(preset_id)
	_refresh()


func debug_cycle_slot(slot_index: int, direction: int) -> void:
	selected_slot = clampi(slot_index, 0, GameState.get_spell_hotbar().size() - 1)
	library_focus = false
	_cycle_selected_skill(direction)
	_refresh()


func debug_cycle_equipment(slot_index: int, direction: int) -> void:
	edit_mode = "equipment"
	_set_tab("equipment")
	selected_equipment_slot = clampi(slot_index, 0, equipment_slot_order.size() - 1)
	_cycle_selected_equipment(direction)
	_refresh()


func debug_cycle_equipment_candidate(slot_index: int, direction: int) -> void:
	_set_tab("equipment")
	selected_equipment_slot = clampi(slot_index, 0, equipment_slot_order.size() - 1)
	_cycle_selected_equipment_candidate(direction)
	_refresh()


func debug_toggle_equipment_focus() -> void:
	_set_tab("equipment")
	_toggle_equipment_focus()
	_refresh()


func debug_grant_selected_equipment_candidate(slot_index: int) -> void:
	_set_tab("equipment")
	selected_equipment_slot = clampi(slot_index, 0, equipment_slot_order.size() - 1)
	var candidate_item_id := _get_selected_equipment_candidate_id()
	var slot_name := str(equipment_slot_order[selected_equipment_slot])
	if GameState.grant_equipment_item(candidate_item_id):
		_apply_post_grant_equipment_selection(slot_name, candidate_item_id)
	_refresh()


func debug_cycle_equipment_sort_mode(direction: int) -> void:
	_set_tab("equipment")
	_cycle_equipment_sort_mode(direction)
	_refresh()


func debug_cycle_equipment_filter_mode(direction: int) -> void:
	_set_tab("equipment")
	_cycle_equipment_filter_mode(direction)
	_refresh()


func debug_cycle_owned_page(slot_index: int, direction: int) -> void:
	_set_tab("equipment")
	selected_equipment_slot = clampi(slot_index, 0, equipment_slot_order.size() - 1)
	_cycle_owned_page(direction)
	_refresh()


func debug_cycle_candidate_window(slot_index: int, direction: int) -> void:
	_set_tab("equipment")
	selected_equipment_slot = clampi(slot_index, 0, equipment_slot_order.size() - 1)
	equipment_focus_mode = "candidate"
	_cycle_candidate_window(direction)
	_refresh()


func debug_cycle_owned_equipment(slot_index: int, direction: int) -> void:
	_set_tab("equipment")
	selected_equipment_slot = clampi(slot_index, 0, equipment_slot_order.size() - 1)
	_cycle_selected_owned_equipment(direction)
	_refresh()


func debug_interact_equipment(slot_index: int) -> void:
	_set_tab("equipment")
	selected_equipment_slot = clampi(slot_index, 0, equipment_slot_order.size() - 1)
	_handle_equipment_interact()
	_refresh()


func debug_toggle_infinite_health() -> void:
	GameState.set_admin_infinite_health(not GameState.admin_infinite_health)
	_refresh()


func debug_toggle_infinite_mana() -> void:
	GameState.set_admin_infinite_mana(not GameState.admin_infinite_mana)
	_refresh()


func debug_toggle_ignore_cooldowns() -> void:
	GameState.set_admin_ignore_cooldowns(not GameState.admin_ignore_cooldowns)
	_refresh()


func debug_toggle_ignore_buff_slot_limit() -> void:
	GameState.set_admin_ignore_buff_slot_limit(not GameState.admin_ignore_buff_slot_limit)
	_refresh()


func debug_adjust_selected_skill_level(slot_index: int, delta: int) -> void:
	edit_mode = "hotbar"
	selected_slot = clampi(slot_index, 0, GameState.get_spell_hotbar().size() - 1)
	_adjust_selected_skill_level(delta)
	_refresh()


func debug_toggle_library_focus() -> void:
	_set_tab("hotbar")
	library_focus = not library_focus
	_sync_library_selection_to_slot()
	_refresh()


func debug_cycle_library(direction: int) -> void:
	_set_tab("hotbar")
	library_focus = true
	_sync_library_selection_to_slot()
	_cycle_library_selection(direction)
	_refresh()


func debug_assign_library_to_slot(slot_index: int) -> void:
	_set_tab("hotbar")
	selected_slot = clampi(slot_index, 0, GameState.get_spell_hotbar().size() - 1)
	library_focus = true
	_assign_selected_library_skill_to_slot()
	_refresh()


func debug_cycle_tab(direction: int) -> void:
	_cycle_tab(direction)
	_refresh()


func debug_emit_spawn(enemy_type: String) -> void:
	spawn_enemy_requested.emit(enemy_type)


func debug_emit_reset_cooldowns() -> void:
	reset_cooldowns_requested.emit()


func debug_apply_equipment_preset(preset_id: String) -> void:
	GameState.apply_equipment_preset(preset_id)
	_refresh()


func debug_set_equipment_panel_layout_mode(mode: String) -> void:
	equipment_panel_layout_mode_override = mode
	_refresh()


func debug_cycle_buff_selection(direction: int) -> void:
	_set_tab("buffs")
	selected_buff_catalog_index = clampi(
		selected_buff_catalog_index + direction, 0, max(buff_catalog.size() - 1, 0)
	)
	_refresh()


func debug_force_activate_selected_buff() -> void:
	_set_tab("buffs")
	_force_activate_selected_buff()


func debug_clear_active_buffs() -> void:
	_clear_active_buffs()


func debug_emit_clear_enemies() -> void:
	clear_enemies_requested.emit()


func debug_toggle_freeze_ai() -> void:
	GameState.admin_freeze_ai = not GameState.admin_freeze_ai
	freeze_ai_toggled.emit(GameState.admin_freeze_ai)
