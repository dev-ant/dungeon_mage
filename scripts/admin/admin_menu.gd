extends Control

signal spawn_enemy_requested(enemy_type: String)
signal reset_cooldowns_requested
signal heal_requested
signal clear_enemies_requested
signal freeze_ai_toggled(frozen: bool)

const PRESET_DEFAULT := [
	"fire_bolt",
	"frost_nova",
	"volt_spear",
	"holy_mana_veil",
	"fire_pyre_heart",
	"ice_frostblood_ward"
]
const PRESET_RITUAL := [
	"earth_stone_spire",
	"dark_grave_echo",
	"volt_spear",
	"holy_mana_veil",
	"holy_crystal_aegis",
	"arcane_world_hourglass"
]
const PRESET_OVERCLOCK := [
	"volt_spear",
	"earth_stone_spire",
	"dark_grave_echo",
	"wind_tempest_drive",
	"lightning_conductive_surge",
	"fire_pyre_heart"
]
const PRESET_DEPLOY_LAB := [
	"earth_stone_spire",
	"dark_grave_echo",
	"fire_bolt",
	"holy_mana_veil",
	"wind_tempest_drive",
	"arcane_world_hourglass"
]
const PRESET_ASHEN_RITE := [
	"fire_bolt",
	"volt_spear",
	"dark_grave_echo",
	"dark_grave_pact",
	"arcane_world_hourglass",
	"dark_throne_of_ash"
]
const PRESET_APEX_TOGGLES := [
	"ice_glacial_dominion",
	"lightning_tempest_crown",
	"dark_soul_dominion",
	"holy_crystal_aegis",
	"arcane_astral_compression",
	"arcane_world_hourglass"
]
const PRESET_FUNERAL_BLOOM := [
	"earth_stone_spire",
	"dark_grave_echo",
	"fire_bolt",
	"dark_grave_pact",
	"plant_verdant_overflow",
	"holy_mana_veil"
]
const HOTBAR_PRESET_IDS := [
	"default", "ritual", "overclock", "deploy_lab", "ashen_rite", "apex_toggles", "funeral_bloom"
]
const HOTBAR_PRESET_LABELS := {
	"default": "Default",
	"ritual": "Ritual",
	"overclock": "Overclock",
	"deploy_lab": "DeployLab",
	"ashen_rite": "AshenRite",
	"apex_toggles": "ApexToggles",
	"funeral_bloom": "FuneralBloom"
}
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
	"brute": "Brute",
	"ranged": "Range",
	"boss": "Boss",
	"dasher": "Dash",
	"sentinel": "Sntl",
	"elite": "Elite",
	"leaper": "Leap",
	"bomber": "Bomb",
	"charger": "Chrg",
	"dummy": "Dummy"
}
const SPAWN_ENEMY_ORDER := [
	"brute", "ranged", "boss", "dasher", "sentinel", "elite", "leaper", "bomber", "charger", "dummy"
]
const ADMIN_TABS := ["hotbar", "resources", "equipment", "spawn", "buffs"]
const ADMIN_TAB_LABELS := {
	"hotbar": "Hotbar",
	"resources": "Resources",
	"equipment": "Equipment",
	"spawn": "Spawn",
	"buffs": "Buffs"
}
const EQUIPMENT_RARITY_ORDER := {"common": 0, "uncommon": 1, "rare": 2, "epic": 3, "legendary": 4}
const EQUIPMENT_SLOT_LABELS := {
	"weapon": "Weapon",
	"offhand": "Offhand",
	"head": "Head",
	"body": "Body",
	"legs": "Legs",
	"accessory_1": "Acc 1",
	"accessory_2": "Acc 2"
}
const EQUIPMENT_FOCUS_MODES := ["candidate", "owned"]
const EQUIPMENT_SORT_MODES := ["rarity", "name"]
const EQUIPMENT_FILTER_MODES := ["all", "tempo", "ritual", "burst", "defense"]
const EQUIPMENT_PAGE_SIZE := 5
const CANDIDATE_PREVIEW_RADIUS := 1
const HOTBAR_SLOT_COUNT := 6
const BUFF_PAGE_SIZE := 8
const EQUIPMENT_PANEL_COLUMN_MIN_WIDTH := 36
const EQUIPMENT_PANEL_COLUMN_MAX_WIDTH := 60
const EQUIPMENT_PANEL_COLUMN_SEPARATOR := "  |  "

var is_open := false
var pause_on_open := true
var selected_slot := 0
var selected_equipment_slot := 0
var selected_library_index := 0
var preset_index := 0
var equipment_preset_index := -1
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

var panel: PanelContainer
var body_label: Label
var footer_label: Label
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


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_to_group("admin_menu")
	visible = false
	_build_ui()
	_build_skill_catalog()
	_build_buff_catalog()
	_build_equipment_catalog()
	_refresh()


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
					"Enemy AI %s." % ("FROZEN" if GameState.admin_freeze_ai else "ACTIVE"), 1.2
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
			"Infinite HP %s" % ("ON" if GameState.admin_infinite_health else "OFF"), 1.0
		)
		_refresh()
	elif event.is_action_pressed("spell_fire"):
		reset_cooldowns_requested.emit()
		GameState.push_message("All cooldowns reset.", 1.0)
	elif event.is_action_pressed("spell_ice"):
		spawn_enemy_requested.emit("brute")
		GameState.push_message("Brute spawned.", 1.0)
	elif event.is_action_pressed("spell_lightning"):
		spawn_enemy_requested.emit("ranged")
		GameState.push_message("Ranged enemy spawned.", 1.0)
	elif event.is_action_pressed("buff_surge"):
		if current_tab == "equipment":
			_cycle_equipment_sort_mode(1)
			GameState.push_message("Owned sort: %s." % equipment_sort_mode, 1.0)
		elif current_tab == "spawn":
			spawn_enemy_requested.emit("dasher")
			GameState.push_message("Dasher spawned.", 1.0)
		else:
			_apply_next_equipment_preset()
			GameState.push_message("Equipment preset applied.", 1.0)
		_refresh()
	elif event.is_action_pressed("buff_aegis"):
		if current_tab == "hotbar":
			library_focus = not library_focus
			GameState.push_message("Library Focus %s" % ("ON" if library_focus else "OFF"), 1.0)
		elif current_tab == "equipment":
			_toggle_equipment_focus()
			GameState.push_message("Equipment Focus %s" % _get_equipment_focus_label(), 1.0)
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
						"Candidate page %s."
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
						"Owned page %s."
						% _get_owned_page_short_label(
							str(equipment_slot_order[selected_equipment_slot])
						)
					),
					1.0
				)
		elif current_tab == "spawn":
			spawn_enemy_requested.emit("bomber")
			GameState.push_message("Bomber spawned.", 1.0)
		else:
			GameState.set_admin_infinite_mana(not GameState.admin_infinite_mana)
			GameState.push_message(
				"Infinite MP %s" % ("ON" if GameState.admin_infinite_mana else "OFF"), 1.0
			)
		_refresh()
	elif event.is_action_pressed("buff_hourglass"):
		if current_tab == "equipment":
			if equipment_focus_mode == "candidate":
				_cycle_candidate_window(-1)
				GameState.push_message(
					(
						"Candidate page %s."
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
						"Owned page %s."
						% _get_owned_page_short_label(
							str(equipment_slot_order[selected_equipment_slot])
						)
					),
					1.0
				)
		elif current_tab == "spawn":
			spawn_enemy_requested.emit("elite")
			GameState.push_message("Elite spawned.", 1.0)
		else:
			GameState.set_admin_ignore_cooldowns(not GameState.admin_ignore_cooldowns)
			GameState.push_message(
				"No Cooldown %s" % ("ON" if GameState.admin_ignore_cooldowns else "OFF"), 1.0
			)
		_refresh()
	elif event.is_action_pressed("buff_pact"):
		if current_tab == "equipment":
			_cycle_equipment_filter_mode(1)
			GameState.push_message("Owned filter: %s." % equipment_filter_mode, 1.0)
		elif current_tab == "spawn":
			spawn_enemy_requested.emit("sentinel")
			GameState.push_message("Sentinel spawned.", 1.0)
		else:
			GameState.set_admin_ignore_buff_slot_limit(not GameState.admin_ignore_buff_slot_limit)
			GameState.push_message(
				"Free Buff Slots %s" % ("ON" if GameState.admin_ignore_buff_slot_limit else "OFF"),
				1.0
			)
		_refresh()
	elif event.is_action_pressed("buff_tempo"):
		spawn_enemy_requested.emit("boss")
		GameState.push_message("Boss dummy spawned.", 1.0)
	elif event.is_action_pressed("buff_guard"):
		if current_tab == "equipment":
			var slot_name := str(equipment_slot_order[selected_equipment_slot])
			var candidate_item_id := _get_selected_equipment_candidate_id()
			if GameState.grant_equipment_item(candidate_item_id):
				_apply_post_grant_equipment_selection(slot_name, candidate_item_id)
				GameState.push_message(
					"%s added to inventory." % _display_name(candidate_item_id), 1.0
				)
		elif current_tab == "buffs":
			_clear_active_buffs()
		elif current_tab == "spawn":
			clear_enemies_requested.emit()
			GameState.push_message("All enemies cleared.", 1.0)
		else:
			heal_requested.emit()
			GameState.push_message("Health restored.", 1.0)
	elif event.is_action_pressed("buff_throne"):
		if current_tab == "equipment":
			_cycle_equipment_focus_selection(1)
		elif current_tab == "spawn":
			spawn_enemy_requested.emit("leaper")
			GameState.push_message("Leaper spawned.", 1.0)
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
			GameState.push_message("Charger spawned.", 1.0)
		else:
			spawn_enemy_requested.emit("dummy")
			GameState.push_message("Training dummy spawned.", 1.0)
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

	var title := Label.new()
	title.text = "Admin Mode"
	title.add_theme_font_size_override("font_size", 28)
	root.add_child(title)

	var tab_bar := HBoxContainer.new()
	tab_bar.add_theme_constant_override("separation", 4)
	root.add_child(tab_bar)
	for tab_id in ADMIN_TABS:
		var btn := Button.new()
		btn.text = str(ADMIN_TAB_LABELS.get(tab_id, tab_id))
		btn.name = "TabBtn_%s" % tab_id
		btn.add_theme_font_size_override("font_size", 15)
		btn.pressed.connect(_on_tab_button_pressed.bind(tab_id))
		tab_bar.add_child(btn)
		_tab_button_nodes[tab_id] = btn

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
	_equipment_interact_button.text = "Interact"
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
	clear_btn.text = "Clear All"
	clear_btn.add_theme_font_size_override("font_size", 13)
	clear_btn.pressed.connect(_on_spawn_clear_button_pressed)
	_spawn_action_button_bar.add_child(clear_btn)
	_spawn_freeze_button = Button.new()
	_spawn_freeze_button.text = "Freeze AI"
	_spawn_freeze_button.add_theme_font_size_override("font_size", 13)
	_spawn_freeze_button.pressed.connect(_on_spawn_freeze_button_pressed)
	_spawn_action_button_bar.add_child(_spawn_freeze_button)
	root.add_child(_spawn_action_button_bar)

	_resource_button_bar = HBoxContainer.new()
	_resource_button_bar.add_theme_constant_override("separation", 4)
	_resource_button_bar.visible = false
	_resource_hp_button = Button.new()
	_resource_hp_button.text = "Inf HP"
	_resource_hp_button.add_theme_font_size_override("font_size", 13)
	_resource_hp_button.pressed.connect(_on_resource_hp_button_pressed)
	_resource_button_bar.add_child(_resource_hp_button)
	_resource_mp_button = Button.new()
	_resource_mp_button.text = "Inf MP"
	_resource_mp_button.add_theme_font_size_override("font_size", 13)
	_resource_mp_button.pressed.connect(_on_resource_mp_button_pressed)
	_resource_button_bar.add_child(_resource_mp_button)
	_resource_cd_button = Button.new()
	_resource_cd_button.text = "No CD"
	_resource_cd_button.add_theme_font_size_override("font_size", 13)
	_resource_cd_button.pressed.connect(_on_resource_cd_button_pressed)
	_resource_button_bar.add_child(_resource_cd_button)
	_resource_buff_button = Button.new()
	_resource_buff_button.text = "Free Buff"
	_resource_buff_button.add_theme_font_size_override("font_size", 13)
	_resource_buff_button.pressed.connect(_on_resource_buff_button_pressed)
	_resource_button_bar.add_child(_resource_buff_button)
	var heal_btn := Button.new()
	heal_btn.text = "Heal"
	heal_btn.add_theme_font_size_override("font_size", 13)
	heal_btn.pressed.connect(_on_resource_heal_button_pressed)
	_resource_button_bar.add_child(heal_btn)
	var reset_cd_btn := Button.new()
	reset_cd_btn.text = "Rst CD"
	reset_cd_btn.add_theme_font_size_override("font_size", 13)
	reset_cd_btn.pressed.connect(_on_resource_reset_cd_button_pressed)
	_resource_button_bar.add_child(reset_cd_btn)
	root.add_child(_resource_button_bar)

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
	_buff_prev_page_button.text = "< Prev"
	_buff_prev_page_button.add_theme_font_size_override("font_size", 13)
	_buff_prev_page_button.pressed.connect(_on_buff_prev_page_pressed)
	_buff_action_button_bar.add_child(_buff_prev_page_button)
	_buff_next_page_button = Button.new()
	_buff_next_page_button.text = "Next >"
	_buff_next_page_button.add_theme_font_size_override("font_size", 13)
	_buff_next_page_button.pressed.connect(_on_buff_next_page_pressed)
	_buff_action_button_bar.add_child(_buff_next_page_button)
	var buff_activate_btn := Button.new()
	buff_activate_btn.text = "Activate"
	buff_activate_btn.add_theme_font_size_override("font_size", 13)
	buff_activate_btn.pressed.connect(_on_buff_activate_button_pressed)
	_buff_action_button_bar.add_child(buff_activate_btn)
	var buff_clear_btn := Button.new()
	buff_clear_btn.text = "Clear All"
	buff_clear_btn.add_theme_font_size_override("font_size", 13)
	buff_clear_btn.pressed.connect(_on_buff_clear_button_pressed)
	_buff_action_button_bar.add_child(buff_clear_btn)
	root.add_child(_buff_action_button_bar)

	_preset_button_bar = HBoxContainer.new()
	_preset_button_bar.add_theme_constant_override("separation", 4)
	_preset_button_bar.visible = false
	for preset_id in HOTBAR_PRESET_IDS:
		var pre_btn := Button.new()
		pre_btn.text = str(HOTBAR_PRESET_LABELS.get(preset_id, preset_id))
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
	_library_focus_button.text = "LibFocus"
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


func _build_buff_catalog() -> void:
	buff_catalog = []
	for skill in GameDatabase.get_all_skills():
		if str(skill.get("skill_type", "")) == "buff":
			buff_catalog.append(str(skill.get("skill_id", "")))
	selected_buff_catalog_index = clampi(
		selected_buff_catalog_index, 0, max(buff_catalog.size() - 1, 0)
	)


func _get_buff_tab_lines() -> Array[String]:
	var lines: Array[String] = ["Buffs  [%d available]" % buff_catalog.size()]
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
		lines.append("Active: none")
	else:
		lines.append("Active: %d/%d" % [active.size(), GameState.get_buff_slot_limit()])
		for buff in active:
			var sid := str(buff.get("skill_id", ""))
			var rem := "%.1fs" % float(buff.get("remaining", 0.0))
			lines.append("  %s  %s" % [_display_name(sid), rem])
	lines.append("")
	lines.append("Combos:")
	var active_combo_names := GameState.get_active_combo_names()
	var all_combos := GameDatabase.get_all_buff_combos()
	if all_combos.is_empty():
		lines.append("  (no combo data)")
	else:
		var active_buff_ids: Array[String] = []
		for ab in GameState.active_buffs:
			active_buff_ids.append(str(ab.get("skill_id", "")))
		for combo in all_combos:
			var cname := str(combo.get("display_name", "?"))
			var on_marker := "[ON]" if active_combo_names.has(cname) else "[ ]"
			var reqs: Array = combo.get("required_buffs", [])
			var req_parts: Array[String] = []
			for req in reqs:
				var req_id := str(req)
				var req_check := "[v]" if active_buff_ids.has(req_id) else "[ ]"
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
		GameState.push_message("%s activated." % _display_name(skill_id), 1.0)
	else:
		GameState.push_message("%s: blocked (ritual lock)." % _display_name(skill_id), 1.0)
	_refresh()


func _clear_active_buffs() -> void:
	GameState.active_buffs.clear()
	GameState.stats_changed.emit()
	GameState.push_message("All active buffs cleared.", 1.0)
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
	_refresh_tab_buttons()
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
		return "Interact"
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	if equipment_focus_mode == "candidate":
		var candidate_id := _get_selected_equipment_candidate_id()
		if candidate_id != "":
			return "Grant"
	else:
		var owned_id := _get_selected_owned_equipment_id()
		if owned_id != "":
			return "Equip"
		var equipped: Dictionary = GameState.get_equipped_items()
		if str(equipped.get(slot_name, "")) != "":
			return "Unequip"
	return "Interact"


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
		"Enemy AI %s." % ("FROZEN" if GameState.admin_freeze_ai else "ACTIVE"), 1.2
	)
	_refresh()


func debug_click_spawn_enemy(enemy_type: String) -> void:
	_on_spawn_enemy_button_pressed(enemy_type)


func debug_click_spawn_clear() -> void:
	_on_spawn_clear_button_pressed()


func debug_click_spawn_freeze() -> void:
	_on_spawn_freeze_button_pressed()


func _refresh_resource_buttons() -> void:
	if _resource_button_bar == null:
		return
	var is_resource := current_tab == "resources"
	_resource_button_bar.visible = is_resource
	if not is_resource:
		return
	if _resource_hp_button != null:
		_resource_hp_button.flat = not GameState.admin_infinite_health
	if _resource_mp_button != null:
		_resource_mp_button.flat = not GameState.admin_infinite_mana
	if _resource_cd_button != null:
		_resource_cd_button.flat = not GameState.admin_ignore_cooldowns
	if _resource_buff_button != null:
		_resource_buff_button.flat = not GameState.admin_ignore_buff_slot_limit


func _on_resource_hp_button_pressed() -> void:
	GameState.set_admin_infinite_health(not GameState.admin_infinite_health)
	GameState.push_message(
		"Infinite HP %s" % ("ON" if GameState.admin_infinite_health else "OFF"), 1.0
	)
	_refresh()


func _on_resource_mp_button_pressed() -> void:
	GameState.set_admin_infinite_mana(not GameState.admin_infinite_mana)
	GameState.push_message(
		"Infinite MP %s" % ("ON" if GameState.admin_infinite_mana else "OFF"), 1.0
	)
	_refresh()


func _on_resource_cd_button_pressed() -> void:
	GameState.set_admin_ignore_cooldowns(not GameState.admin_ignore_cooldowns)
	GameState.push_message(
		"No Cooldown %s" % ("ON" if GameState.admin_ignore_cooldowns else "OFF"), 1.0
	)
	_refresh()


func _on_resource_buff_button_pressed() -> void:
	GameState.set_admin_ignore_buff_slot_limit(not GameState.admin_ignore_buff_slot_limit)
	GameState.push_message(
		"Free Buff Slots %s" % ("ON" if GameState.admin_ignore_buff_slot_limit else "OFF"), 1.0
	)
	_refresh()


func _on_resource_heal_button_pressed() -> void:
	heal_requested.emit()


func _on_resource_reset_cd_button_pressed() -> void:
	reset_cooldowns_requested.emit()


func debug_click_resource_hp() -> void:
	_on_resource_hp_button_pressed()


func debug_click_resource_mp() -> void:
	_on_resource_mp_button_pressed()


func debug_click_resource_cd() -> void:
	_on_resource_cd_button_pressed()


func debug_click_resource_buff() -> void:
	_on_resource_buff_button_pressed()


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
	var index := HOTBAR_PRESET_IDS.find(preset_id)
	if index < 0:
		return
	preset_index = index
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
			var label := _display_name(skill_id).left(9) if skill_id != "" else "(empty)"
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
	GameState.push_message("Library Focus %s" % ("ON" if library_focus else "OFF"), 1.0)
	_refresh()


func debug_click_library_item(window_position: int) -> void:
	_on_library_item_button_pressed(window_position)


func debug_click_library_focus_toggle() -> void:
	_on_library_focus_button_pressed()


func _get_common_status_lines() -> Array[String]:
	var lines: Array[String] = []
	lines.append("Tab: %s" % str(ADMIN_TAB_LABELS.get(current_tab, current_tab)))
	lines.append("Edit Mode: %s" % edit_mode.capitalize())
	lines.append("Library Focus: %s" % ("ON" if library_focus else "OFF"))
	lines.append("Selected Slot: %d" % (selected_slot + 1))
	lines.append(
		(
			"Hotbar Preset: %s"
			% str(HOTBAR_PRESET_LABELS.get(current_hotbar_preset_id, current_hotbar_preset_id))
		)
	)
	lines.append("Infinite HP: %s" % ("ON" if GameState.admin_infinite_health else "OFF"))
	lines.append("Infinite MP: %s" % ("ON" if GameState.admin_infinite_mana else "OFF"))
	lines.append("Ignore Cooldown: %s" % ("ON" if GameState.admin_ignore_cooldowns else "OFF"))
	lines.append(
		"Free Buff Slots: %s" % ("ON" if GameState.admin_ignore_buff_slot_limit else "OFF")
	)
	if current_tab == "equipment":
		lines.append("Equipment Focus: %s" % _get_equipment_focus_label())
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
	return ["Unknown Tab"]


func _get_hotbar_tab_lines(
	hotbar: Array, selected_skill_id: String, active_skill_id: String
) -> Array[String]:
	var lines: Array[String] = ["Hotbar"]
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
	var drop_line: String = "Last drop: none"
	if GameState.last_drop_display != "":
		drop_line = (
			"Last drop: %s  (total: %d)" % [GameState.last_drop_display, GameState.session_drops]
		)
	return [
		"Resources",
		"Circle: %d  Score: %.1f  Buff Slots: %d" % [circle, score, buff_slots],
		(
			"HP: %d/%d  MP: %.0f/%.0f"
			% [GameState.health, GameState.max_health, GameState.mana, GameState.max_mana]
		),
		"HP Lock: %s" % ("ON" if GameState.admin_infinite_health else "OFF"),
		"MP Lock: %s" % ("ON" if GameState.admin_infinite_mana else "OFF"),
		"Cooldown Lock: %s" % ("ON" if GameState.admin_ignore_cooldowns else "OFF"),
		"Buff Limit Lock: %s" % ("ON" if GameState.admin_ignore_buff_slot_limit else "OFF"),
		(
			"Session  Kills: %d  Hits: %d  DMG: %d  Drops: %d"
			% [
				GameState.session_kills,
				GameState.session_hit_count,
				GameState.session_damage_dealt,
				GameState.session_drops
			]
		),
		drop_line,
		"Recovery: Q heal, Z reset cooldowns"
	]


func _get_equipment_tab_lines() -> Array[String]:
	var focus_display := equipment_focus_mode.to_upper()
	var lines: Array[String] = ["Equipment  [%s panel active]" % focus_display]
	var equipped: Dictionary = GameState.get_equipped_items()
	for i in range(equipment_slot_order.size()):
		var slot_name: String = str(equipment_slot_order[i])
		var marker := ">" if i == selected_equipment_slot else " "
		lines.append(
			"%s %s  %s" % [marker, slot_name, _display_name(str(equipped.get(slot_name, "")))]
		)
	if selected_equipment_slot >= 0 and selected_equipment_slot < equipment_slot_order.size():
		var selected_slot_name := str(equipment_slot_order[selected_equipment_slot])
		var candidate_item_id := _get_selected_equipment_candidate_id()
		var owned_item_id := _get_selected_owned_equipment_id()
		var layout_source := _build_equipment_tab_layout_source(
			_get_equipment_overview_section_lines(
				selected_slot_name, candidate_item_id, owned_item_id
			),
			"Equipment Focus  %s" % _get_equipment_focus_label(),
			_get_candidate_panel_lines(selected_slot_name, candidate_item_id),
			_get_owned_panel_lines(selected_slot_name, owned_item_id)
		)
		lines.append("")
		lines.append("Selected Slot  %s" % selected_slot_name)
		lines.append_array(_build_equipment_tab_layout_lines_from_source(layout_source))
		lines.append(GameState.get_equipment_slot_inventory_summary(selected_slot_name))
	lines.append(GameState.get_equipment_inventory_summary())
	lines.append("T toggle focus  Up/Down select slot  F cycle tab  Q grant or heal")
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
		"Panel Columns  Left:Candidate  Right:Owned",
		"Panel Mode  %s" % _get_equipment_panel_layout_mode_label(layout_mode)
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
		"left_slot_lines": _build_equipment_panel_slot_lines("Left", "Candidate", candidate_lines),
		"right_slot_lines": _build_equipment_panel_slot_lines("Right", "Owned", owned_lines)
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
		return "side-by-side"
	return "stacked bridge (2-panel ready)"


func _get_footer_text() -> String:
	match current_tab:
		"hotbar":
			return "F cycle tab  T library focus  Up/Down select slot  Left/Right cycle skill  Alt hotbar preset  N/R tune skill  E clear or assign  Esc close"
		"resources":
			return "F cycle tab  Shift infinite HP  Y infinite MP  H no cooldown  J free buff slots  Q heal  Z reset CD  Esc close"
		"equipment":
			if _has_recent_granted_owned_selection(
				str(equipment_slot_order[selected_equipment_slot])
			):
				return "F cycle tab  T toggle focus  Up/Down slot  Left/Right equip direct  B sort  J filter  Y/H page  Q grant candidate  N/R cycle focused panel  E equip new item  Esc close"
			return "F cycle tab  T toggle focus  Up/Down slot  Left/Right equip direct  B sort  J filter  Y/H page  Q grant candidate  N/R cycle focused panel  E focused action  Esc close"
		"spawn":
			return "F cycle tab  C brute  V ranged  R dummy  G boss  Esc close"
	return "F cycle tab  Esc close"


func _get_equipment_panel_status_line(panel_name: String) -> String:
	var is_focused := equipment_focus_mode == panel_name
	if panel_name == "candidate":
		var candidate_item_id := _get_selected_equipment_candidate_id()
		var candidate_state := (
			"owned" if GameState.has_equipment_in_inventory(candidate_item_id) else "not-owned"
		)
		return "%s  Action:grant  State:%s" % ["FOCUSED" if is_focused else "idle", candidate_state]
	var slot_name := str(equipment_slot_order[selected_equipment_slot])
	var owned_item_id := _get_selected_owned_equipment_id()
	var owned_state := "ready" if owned_item_id != "" else "empty"
	if _has_recent_granted_owned_selection(slot_name):
		return "%s  Action:equip-now  State:fresh  [!]" % ["FOCUSED" if is_focused else "idle"]
	return "%s  Action:equip  State:%s" % ["FOCUSED" if is_focused else "idle", owned_state]


func _get_spawn_tab_lines() -> Array[String]:
	var lines: Array[String] = ["Spawn"]
	var enemies: Array = GameDatabase.get_all_enemies()
	if enemies.is_empty():
		lines.append_array(
			[
				"C brute",
				"V ranged",
				"G boss",
				"B dasher  (mobile pressure / telegraph-dash)",
				"J sentinel  (area control / aimed 2-shot volley)",
				"H elite  (burst-check / super armor / high HP)",
				"N leaper  (anti-stationary / telegraph-jump / aerial arc)",
				"Y bomber  (ranged denial / slow bomb / punish stationary)",
				"R charger  (lock-target rush / punish stationary / spacing test)",
				"Q dummy  (training target)"
			]
		)
		return lines
	for enemy_data in enemies:
		var eid: String = str(enemy_data.get("enemy_id", ""))
		var key: String = str(SPAWN_KEY_MAP.get(eid, "?"))
		var name_text: String = str(enemy_data.get("display_name", eid))
		var role_text: String = str(enemy_data.get("role", ""))
		var hp: int = int(enemy_data.get("max_hp", 0))
		var armor_tags: Array = enemy_data.get("super_armor_tags", [])
		var armor_note: String = "  [SA]" if armor_tags.size() > 0 else ""
		lines.append("%s %s  (%s  HP:%d%s)" % [key, name_text, role_text, hp, armor_note])
	lines.append("")
	var freeze_label: String = "FROZEN" if GameState.admin_freeze_ai else "active"
	lines.append("Q clear all  E freeze AI [%s]" % freeze_label)
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
	preset_index = posmod(preset_index + 1, HOTBAR_PRESET_IDS.size())
	_apply_hotbar_preset(str(HOTBAR_PRESET_IDS[preset_index]))


func _apply_hotbar_preset(preset_id: String) -> void:
	var preset: Array = _get_hotbar_preset_data(preset_id)
	if preset.is_empty():
		return
	current_hotbar_preset_id = preset_id
	for i in range(min(preset.size(), GameState.get_spell_hotbar().size())):
		GameState.set_hotbar_skill(i, str(preset[i]))
	GameState.push_message(
		"Hotbar preset %s applied." % str(HOTBAR_PRESET_LABELS.get(preset_id, preset_id)), 1.0
	)


func _get_hotbar_preset_data(preset_id: String) -> Array:
	match preset_id:
		"default":
			return PRESET_DEFAULT
		"ritual":
			return PRESET_RITUAL
		"overclock":
			return PRESET_OVERCLOCK
		"deploy_lab":
			return PRESET_DEPLOY_LAB
		"ashen_rite":
			return PRESET_ASHEN_RITE
		"apex_toggles":
			return PRESET_APEX_TOGGLES
		"funeral_bloom":
			return PRESET_FUNERAL_BLOOM
	return []


func _apply_next_equipment_preset() -> void:
	var presets := ["fire_burst", "ritual_control", "storm_tempo"]
	equipment_preset_index = posmod(equipment_preset_index + 1, presets.size())
	GameState.apply_equipment_preset(str(presets[equipment_preset_index]))


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
	return equipment_focus_mode


func _get_equipment_focus_marker(focus_mode: String) -> String:
	if equipment_focus_mode == focus_mode:
		return "  [FOCUS]"
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
		return _build_equipment_selection_line("Candidate", "candidate", "none", 0, 0)
	var current_index := int(equipment_candidate_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, options.size() - 1)
	var candidate_item_id := str(options[current_index])
	return _build_equipment_selection_line(
		"Candidate",
		"candidate",
		_display_name(candidate_item_id),
		current_index + 1,
		options.size()
	)


func _get_candidate_window_line(slot_name: String) -> String:
	var options: Array = equipment_catalog_by_slot.get(slot_name, [""])
	if options.is_empty():
		return _build_equipment_nav_line("Candidate", ["0/0"])
	var current_index := int(equipment_candidate_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, options.size() - 1)
	var page_index := int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
	var start_item := page_index * EQUIPMENT_PAGE_SIZE + 1
	var end_item := mini((page_index + 1) * EQUIPMENT_PAGE_SIZE, options.size())
	return _build_equipment_nav_line(
		"Candidate", ["Items %d-%d/%d" % [start_item, end_item, options.size()]]
	)


func _get_candidate_window_short_label(slot_name: String) -> String:
	var window_line := _get_candidate_window_line(slot_name)
	return window_line.trim_prefix("Candidate Nav  ")


func _get_selected_candidate_meta_line(item_id: String) -> String:
	if item_id == "":
		return "Candidate Detail  none"
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return "Candidate Detail  none"
	var tags_value = item.get("tags", [])
	var tags: Array[String] = []
	if typeof(tags_value) == TYPE_ARRAY:
		for tag_value in tags_value:
			tags.append(str(tag_value))
	var tags_text := "-" if tags.is_empty() else ", ".join(tags)
	var description_text := str(item.get("description", ""))
	return "Candidate Detail  %s\nTags:%s" % [description_text, tags_text]


func _get_candidate_compare_line(slot_name: String, candidate_item_id: String) -> String:
	if candidate_item_id == "":
		return "Candidate Compare  none"
	var candidate_item: Dictionary = GameDatabase.get_equipment(candidate_item_id)
	if candidate_item.is_empty():
		return "Candidate Compare  none"
	var equipped_items: Dictionary = GameState.get_equipped_items()
	var equipped_item_id := str(equipped_items.get(slot_name, ""))
	if equipped_item_id == "":
		return "Candidate Compare  no equipped baseline"
	var equipped_item: Dictionary = GameDatabase.get_equipment(equipped_item_id)
	if equipped_item.is_empty():
		return "Candidate Compare  no equipped baseline"
	var candidate_modifiers: Dictionary = candidate_item.get("stat_modifiers", {})
	var equipped_modifiers: Dictionary = equipped_item.get("stat_modifiers", {})
	var compare_parts: Array[String] = []
	_append_compare_part(
		compare_parts, "magic_attack", "MATK", candidate_modifiers, equipped_modifiers
	)
	_append_compare_part(compare_parts, "max_hp", "MaxHP", candidate_modifiers, equipped_modifiers)
	_append_compare_part(compare_parts, "max_mp", "MaxMP", candidate_modifiers, equipped_modifiers)
	_append_compare_part(
		compare_parts, "mp_regen", "MPRegen", candidate_modifiers, equipped_modifiers
	)
	_append_compare_part(
		compare_parts, "cooldown_recovery", "CDR", candidate_modifiers, equipped_modifiers, true
	)
	_append_damage_taken_compare_part(compare_parts, candidate_modifiers, equipped_modifiers)
	if compare_parts.is_empty():
		return "Candidate Compare  sidegrade / utility"
	return "Candidate Compare  %s" % "  ".join(compare_parts)


func _get_candidate_view_line(slot_name: String, candidate_item_id: String) -> String:
	var ownership_text := (
		"owned" if GameState.has_equipment_in_inventory(candidate_item_id) else "not-owned"
	)
	return _build_equipment_view_line(
		"Candidate",
		["State:%s" % ownership_text, "Browse:%s" % _get_candidate_window_short_label(slot_name)]
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
			"Panel Summary  Candidate:%s  Owned:%s"
			% [
				str(preview_source.get("candidate_name", "(empty)")),
				str(preview_source.get("owned_name", "(empty)"))
			]
		),
		(
			"Panel Flow  Candidate:%s  Owned:%s  Browse:%s | %s"
			% [
				str(preview_source.get("candidate_action", "grant")),
				str(preview_source.get("owned_action", "equip")),
				str(preview_source.get("candidate_browse", "0/0")),
				str(preview_source.get("owned_browse", "0/0"))
			]
		)
	]


func _get_equipment_panel_action_label(panel_name: String, slot_name: String) -> String:
	if panel_name == "candidate":
		return "grant"
	if _has_recent_granted_owned_selection(slot_name):
		return "equip-now"
	return "equip"


func _get_candidate_panel_lines(slot_name: String, candidate_item_id: String) -> Array[String]:
	var body_source := _get_candidate_panel_body_source(slot_name, candidate_item_id)
	var body_lines := _build_equipment_panel_body_lines(body_source)
	return _build_equipment_panel_lines(
		"candidate",
		"Candidate",
		"Candidate Status  %s" % _get_equipment_panel_status_line("candidate"),
		body_lines,
		"  N/R cycle candidate  E grant to inventory"
	)


func _get_owned_panel_lines(slot_name: String, owned_item_id: String) -> Array[String]:
	var body_source := _get_owned_panel_body_source(slot_name, owned_item_id)
	var body_lines := _build_equipment_panel_body_lines(body_source)
	return _build_equipment_panel_lines(
		"owned",
		"Owned",
		"Owned Status  %s" % _get_equipment_panel_status_line("owned"),
		body_lines,
		"  N/R cycle owned  E equip  B sort  J filter  Y/H page"
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
	return "Compare Header  Equipped:%s  Candidate:%s" % [equipped_name, candidate_name]


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
	compare_parts.append("DR %s%s%%" % [sign, _format_percent_number(delta * 100.0)])


func _get_candidate_preview_lines(slot_name: String) -> Array[String]:
	var options: Array = equipment_catalog_by_slot.get(slot_name, [""])
	if options.is_empty():
		return ["Candidate List  none"]
	var current_index := int(equipment_candidate_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, options.size() - 1)
	var page_index := int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
	var start_index := page_index * EQUIPMENT_PAGE_SIZE
	var end_index := mini(start_index + EQUIPMENT_PAGE_SIZE, options.size())
	var lines: Array[String] = ["Candidate List"]
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
		return "(empty)"
	var entry_text := _get_equipment_list_entry_text(item_id)
	if GameState.has_equipment_in_inventory(item_id):
		return "%s  [Owned]" % entry_text
	return entry_text


func _get_selected_equipped_stat_line(slot_name: String) -> String:
	var equipped: Dictionary = GameState.get_equipped_items()
	var item_id := str(equipped.get(slot_name, ""))
	if item_id == "":
		return "Slot Stats  none"
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return "Slot Stats  none"
	var stat_modifiers: Dictionary = item.get("stat_modifiers", {})
	if stat_modifiers.is_empty():
		return "Slot Stats  none"
	var stat_parts: Array[String] = []
	if stat_modifiers.has("magic_attack"):
		stat_parts.append(
			"MATK +%s" % _format_stat_number(float(stat_modifiers.get("magic_attack", 0.0)))
		)
	if stat_modifiers.has("max_mp"):
		stat_parts.append(
			"MaxMP +%s" % _format_stat_number(float(stat_modifiers.get("max_mp", 0.0)))
		)
	if stat_modifiers.has("max_hp"):
		stat_parts.append(
			"MaxHP +%s" % _format_stat_number(float(stat_modifiers.get("max_hp", 0.0)))
		)
	if stat_modifiers.has("mp_regen"):
		stat_parts.append(
			"MPRegen +%s" % _format_stat_number(float(stat_modifiers.get("mp_regen", 0.0)))
		)
	if stat_modifiers.has("cooldown_recovery"):
		stat_parts.append(
			(
				"CDR %s%%"
				% _format_percent_number(
					float(stat_modifiers.get("cooldown_recovery", 0.0)) * 100.0
				)
			)
		)
	if stat_modifiers.has("damage_taken_multiplier"):
		var damage_taken_mult := float(stat_modifiers.get("damage_taken_multiplier", 1.0))
		if damage_taken_mult < 1.0:
			stat_parts.append("DR %s%%" % _format_percent_number((1.0 - damage_taken_mult) * 100.0))
	if stat_parts.is_empty():
		return "Slot Stats  utility gear"
	return "Slot Stats  %s" % "  ".join(stat_parts)


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
		return _build_equipment_selection_line("Owned", "owned", "none", 0, 0)
	var current_index := int(equipment_owned_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, owned_items.size() - 1)
	return _build_equipment_selection_line(
		"Owned", "owned", _display_name(owned_item_id), current_index + 1, owned_items.size()
	)


func _build_equipment_selection_line(
	label: String, focus_mode: String, item_name: String, current_index: int, total: int
) -> String:
	if total <= 0:
		return "%s Selection%s  %s" % [label, _get_equipment_focus_marker(focus_mode), item_name]
	return (
		"%s Selection%s  %s  [%d/%d]"
		% [label, _get_equipment_focus_marker(focus_mode), item_name, current_index, total]
	)


func _get_owned_primary_line(slot_name: String, owned_item_id: String) -> String:
	return _get_selected_owned_equipment_line(slot_name, owned_item_id)


func _get_owned_view_line() -> String:
	var slot_name := str(equipment_slot_order[selected_equipment_slot])
	return _build_equipment_view_line(
		"Owned",
		[
			"Sort:%s" % _get_equipment_sort_label(),
			"Filter:%s" % _get_equipment_filter_label(),
			"Browse:%s" % _get_owned_page_short_label(slot_name)
		]
	)


func _build_equipment_view_line(label: String, parts: Array[String]) -> String:
	return "%s View  %s" % [label, "  ".join(parts)]


func _build_equipment_nav_line(label: String, parts: Array[String]) -> String:
	return "%s Nav  %s" % [label, "  ".join(parts)]


func _get_owned_selection_line() -> String:
	return ""


func _get_owned_navigation_line(slot_name: String) -> String:
	return _get_owned_equipment_page_line(slot_name)


func _get_selected_owned_equipment_meta_line(item_id: String) -> String:
	if item_id == "":
		return "Owned Detail  none"
	var item: Dictionary = GameDatabase.get_equipment(item_id)
	if item.is_empty():
		return "Owned Detail  none"
	var tags_value = item.get("tags", [])
	var tags: Array[String] = []
	if typeof(tags_value) == TYPE_ARRAY:
		for tag_value in tags_value:
			tags.append(str(tag_value))
	var tags_text := "-" if tags.is_empty() else ", ".join(tags)
	var description_text := str(item.get("description", ""))
	return "Owned Detail  %s\nTags:%s" % [description_text, tags_text]


func _get_owned_equipment_preview_lines(slot_name: String) -> Array[String]:
	var owned_items: Array = _get_sorted_owned_items_for_slot(slot_name)
	if owned_items.is_empty():
		return ["Owned List  none"]
	var current_index := int(equipment_owned_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, owned_items.size() - 1)
	var page_index := int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
	var start_index := page_index * EQUIPMENT_PAGE_SIZE
	var end_index := mini(start_index + EQUIPMENT_PAGE_SIZE, owned_items.size())
	var lines: Array[String] = ["Owned List"]
	for i in range(start_index, end_index):
		var item_id := str(owned_items[i])
		var marker := ">" if i == current_index else "-"
		lines.append("%s %s" % [marker, _get_equipment_list_entry_text(item_id)])
	return lines


func _get_owned_equipment_page_line(slot_name: String) -> String:
	var owned_items: Array = _get_sorted_owned_items_for_slot(slot_name)
	if owned_items.is_empty():
		return _build_equipment_nav_line("Owned", ["0/0"])
	var current_index := int(equipment_owned_index_by_slot.get(slot_name, 0))
	current_index = clampi(current_index, 0, owned_items.size() - 1)
	var page_index := int(floor(float(current_index) / float(EQUIPMENT_PAGE_SIZE)))
	var page_count := int(ceili(float(owned_items.size()) / float(EQUIPMENT_PAGE_SIZE)))
	var start_item := page_index * EQUIPMENT_PAGE_SIZE + 1
	var end_item := mini((page_index + 1) * EQUIPMENT_PAGE_SIZE, owned_items.size())
	return _build_equipment_nav_line(
		"Owned",
		[
			"%d/%d" % [page_index + 1, page_count],
			"Items %d-%d/%d" % [start_item, end_item, owned_items.size()]
		]
	)


func _get_owned_page_short_label(slot_name: String) -> String:
	var page_line := _get_owned_equipment_page_line(slot_name)
	return page_line.trim_prefix("Owned Nav  ")


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
			return "name"
		_:
			return "rarity -> name"


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
	return equipment_filter_mode


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
	var rarity_text := str(item.get("rarity", "common")).capitalize()
	var slot_text := str(item.get("slot_type", ""))
	return "%s [%s / %s]" % [_display_name(item_id), rarity_text, slot_text]


func _handle_equipment_interact() -> void:
	var slot_name: String = str(equipment_slot_order[selected_equipment_slot])
	if equipment_focus_mode == "candidate":
		var candidate_item_id := _get_selected_equipment_candidate_id()
		if candidate_item_id != "" and GameState.grant_equipment_item(candidate_item_id):
			_apply_post_grant_equipment_selection(slot_name, candidate_item_id)
			GameState.push_message("%s added to inventory." % _display_name(candidate_item_id), 1.0)
			return
		GameState.push_message("Candidate cannot be granted right now.", 1.0)
		return
	var owned_item_id := _get_selected_owned_equipment_id()
	if owned_item_id != "":
		if GameState.equip_inventory_item(slot_name, owned_item_id):
			_clear_recent_granted_selection()
			GameState.push_message(
				"%s equipped from inventory." % _display_name(owned_item_id), 1.0
			)
			return
	if GameState.unequip_item_to_inventory(slot_name):
		_clear_recent_granted_selection()
		GameState.push_message("%s moved to inventory." % slot_name.capitalize(), 1.0)
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
		GameState.push_message("There is no skill selected to tune.", 1.0)
		return
	var new_level := clampi(GameState.get_skill_level(skill_id) + delta, 1, 30)
	if GameState.set_skill_level(skill_id, new_level):
		GameState.push_message("%s tuned to Lv.%d." % [_display_name(skill_id), new_level], 1.0)


func _get_selected_skill_detail(skill_id: String) -> String:
	if skill_id == "":
		return "Skill  (empty)"
	var skill_data: Dictionary = GameDatabase.get_skill_data(skill_id)
	if skill_data.is_empty():
		var linked_skill_id := GameDatabase.get_skill_id_for_runtime_spell(skill_id)
		if linked_skill_id != "":
			skill_data = GameDatabase.get_skill_data(linked_skill_id)
	var circle_text := "?"
	if not skill_data.is_empty():
		circle_text = str(skill_data.get("circle", "?"))
	return (
		"Skill  %s  Lv.%d  XP %.0f  Circle %s"
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
			parts.append("%s (empty)" % marker)
			continue
		parts.append(
			"%s %s Lv.%d" % [marker, _display_name(skill_id), GameState.get_skill_level(skill_id)]
		)
	return "Skill Library  %s" % " | ".join(parts)


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
		"Loaded %s into slot %d." % [_display_name(skill_id), selected_slot + 1], 1.0
	)


func _display_name(skill_id: String) -> String:
	if skill_id == "":
		return "(empty)"
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
	var parts: Array[String] = ["Tab[%s]" % tab_label]
	if current_tab == "hotbar":
		parts.append("Mode[%s]" % edit_mode.capitalize())
		if library_focus:
			parts.append("Library[ON]")
	elif current_tab == "equipment":
		var slot_name := str(equipment_slot_order[selected_equipment_slot])
		parts.append("Focus[%s]" % _get_equipment_focus_label())
		parts.append("Slot[%s]" % slot_name)
		if equipment_focus_mode == "candidate":
			var candidate_item_id := _get_selected_equipment_candidate_id()
			parts.append("Nav[%s]" % _get_candidate_window_short_label(slot_name))
			parts.append("Target[%s]" % _display_name(candidate_item_id))
			if candidate_item_id != "":
				parts.append(
					(
						"Owned[%s]"
						% ("Y" if GameState.has_equipment_in_inventory(candidate_item_id) else "N")
					)
				)
		else:
			var owned_item_id := _get_selected_owned_equipment_id()
			parts.append("Nav[%s]" % _get_owned_page_short_label(slot_name))
			parts.append("Target[%s]" % _display_name(owned_item_id))
	return " ".join(parts)


func debug_toggle() -> void:
	_toggle_menu()


func debug_apply_preset(index: int) -> void:
	preset_index = index - 1
	_apply_next_preset()


func debug_apply_named_preset(preset_id: String) -> void:
	var index := HOTBAR_PRESET_IDS.find(preset_id)
	if index == -1:
		return
	preset_index = index
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
