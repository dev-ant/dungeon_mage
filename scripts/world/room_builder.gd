extends RefCounted

const ROOM_HEIGHT := 720.0
const ROOM_FLOOR_THRESHOLD := 40.0
const PLATFORM_ONE_WAY_COLLISION_HEIGHT := 8.0
const PLATFORM_ONE_WAY_COLLISION_MARGIN := 2.0
const FLOOR_SEGMENT_DECOR_AUTO := "auto"
const FLOOR_SEGMENT_DECOR_GROUND := "ground"
const FLOOR_SEGMENT_DECOR_PLATFORM := "platform"
const FLOOR_SEGMENT_COLLISION_AUTO := "auto"
const FLOOR_SEGMENT_COLLISION_SOLID := "solid"
const FLOOR_SEGMENT_COLLISION_ONE_WAY := "one_way_platform"
const FLOOR_TILE_SIZE := Vector2(96, 96)
const PLATFORM_TILE_SIZE := Vector2(96, 32)
const BG_SCALE := Vector2(4.0, 4.0)
const OUTER_RUINS_DECOR_COLOR := Color("#2b3646")
const OUTER_RUINS_ACCENT_COLOR := Color("#4d5d73")
const TRANSITION_DECOR_COLOR := Color("#2f2e3f")
const TRANSITION_ACCENT_COLOR := Color("#8b7a68")
const SANCTUARY_DECOR_COLOR := Color("#314853")
const SANCTUARY_ACCENT_COLOR := Color("#7ea7a1")
const GATE_DECOR_COLOR := Color("#3c3347")
const GATE_ACCENT_COLOR := Color("#8c7f6a")
const SPIRE_DECOR_COLOR := Color("#2d1f35")
const SPIRE_ACCENT_COLOR := Color("#a36bb1")
const INNER_KEEP_DECOR_COLOR := Color("#433947")
const INNER_KEEP_ACCENT_COLOR := Color("#8f7485")
const THRONE_DECOR_COLOR := Color("#4a2532")
const THRONE_ACCENT_COLOR := Color("#b28a66")

const BG_TEXTURE_PATHS := [
	"res://assets/background/gandalf_hardcore/bg_dirt_1.png",
	"res://assets/background/gandalf_hardcore/bg_dirt_2.png"
]
const FLOOR_TEXTURE_PATHS := [
	"res://assets/background/gandalf_hardcore/floor_tiles_1.png",
	"res://assets/background/gandalf_hardcore/floor_tiles_2.png"
]
const OTHER_TEXTURE_PATHS := [
	"res://assets/background/gandalf_hardcore/other_tiles_1.png",
	"res://assets/background/gandalf_hardcore/other_tiles_2.png"
]

var _texture_cache: Dictionary = {}


func build(room_layer: Node2D, room_data: Dictionary, variant: Dictionary) -> void:
	for child in room_layer.get_children():
		child.queue_free()

	var room_width := float(room_data.get("width", 1600))
	var palette_index := _choose_palette_index(room_data)

	var background_layer := Node2D.new()
	background_layer.name = "BackgroundLayer"
	background_layer.z_index = -30
	room_layer.add_child(background_layer)
	_build_background(background_layer, room_width, room_data, variant)

	var terrain_decor_layer := Node2D.new()
	terrain_decor_layer.name = "TerrainDecorLayer"
	terrain_decor_layer.z_index = -8
	room_layer.add_child(terrain_decor_layer)

	var landmark_layer := Node2D.new()
	landmark_layer.name = "LandmarkLayer"
	landmark_layer.z_index = -18
	room_layer.add_child(landmark_layer)
	_build_landmarks(landmark_layer, room_width, room_data)

	var raw_segments: Array = room_data.get("floor_segments", [])
	for segment_index in raw_segments.size():
		var segment_spec: Dictionary = _normalize_floor_segment(raw_segments[segment_index])
		if not bool(segment_spec.get("valid", false)):
			continue
		var position_value: Vector2 = segment_spec.get("position", Vector2.ZERO)
		var size: Vector2 = segment_spec.get("size", Vector2.ZERO)
		terrain_decor_layer.add_child(
			_make_segment_decor(position_value, size, palette_index, segment_index, segment_spec)
		)
		room_layer.add_child(
			_make_floor_collision_body(
				position_value,
				size,
				_segment_color(segment_index, size, palette_index, segment_spec),
				str(segment_spec.get("collision_mode", FLOOR_SEGMENT_COLLISION_AUTO))
			)
		)

	room_layer.add_child(_make_wall(Vector2(-24, ROOM_HEIGHT * 0.5), Vector2(48, ROOM_HEIGHT)))
	room_layer.add_child(
		_make_wall(
			Vector2(room_width + 24, ROOM_HEIGHT * 0.5), Vector2(48, ROOM_HEIGHT)
		)
	)


func _build_background(
	background_layer: Node2D, room_width: float, room_data: Dictionary, variant: Dictionary
) -> void:
	var background_textures := _get_background_textures()
	var base := Polygon2D.new()
	base.name = "BaseBackdrop"
	base.color = (
		Color(room_data.get("background", "#101820"))
		+ Color(variant.get("tint", Color("#ffffff"))) * 0.16
	)
	base.polygon = PackedVector2Array(
		[
			Vector2(0, 0),
			Vector2(room_width, 0),
			Vector2(room_width, ROOM_HEIGHT),
			Vector2(0, ROOM_HEIGHT)
		]
	)
	background_layer.add_child(base)

	var chunk_width: float = background_textures[0].get_width() * BG_SCALE.x
	var bottom_y: float = ROOM_HEIGHT - (background_textures[0].get_height() * BG_SCALE.y * 0.5) + 18.0
	var top_y := 250.0
	var idx := 0
	var x: float = -chunk_width * 0.5
	while x <= room_width + chunk_width:
		background_layer.add_child(
			_make_background_sprite(
				background_textures[idx % background_textures.size()], Vector2(x, bottom_y), 0.34
			)
		)
		background_layer.add_child(
			_make_background_sprite(
				background_textures[(idx + 1) % background_textures.size()],
				Vector2(x + chunk_width * 0.25, top_y),
				0.18
			)
		)
		idx += 1
		x += chunk_width * 0.9


func _build_landmarks(landmark_layer: Node2D, room_width: float, room_data: Dictionary) -> void:
	var theme := str(room_data.get("theme", ""))
	match theme:
		"outer_ruins":
			_build_outer_ruins_landmarks(landmark_layer, room_width)
		"transition_corridor":
			_build_transition_corridor_landmarks(landmark_layer, room_width)
		"sanctuary_hub":
			_build_sanctuary_hub_landmarks(landmark_layer, room_width)
		"gate_threshold":
			_build_gate_threshold_landmarks(landmark_layer, room_width)
		"inner_keep":
			_build_inner_keep_landmarks(landmark_layer, room_width)
		"throne_approach":
			_build_throne_approach_landmarks(landmark_layer, room_width)
		"inverted_spire":
			_build_inverted_spire_landmarks(landmark_layer, room_width)


func _build_outer_ruins_landmarks(landmark_layer: Node2D, room_width: float) -> void:
	var left_buttress := _make_landmark_rect(
		"CollapsedButtress",
		Vector2(180, 468),
		Vector2(180, 300),
		OUTER_RUINS_DECOR_COLOR
	)
	landmark_layer.add_child(left_buttress)

	var breach_tower := _make_landmark_rect(
		"BrokenWatchtower",
		Vector2(room_width - 170, 392),
		Vector2(160, 420),
		OUTER_RUINS_DECOR_COLOR.darkened(0.08)
	)
	landmark_layer.add_child(breach_tower)

	var breach_notch := Polygon2D.new()
	breach_notch.name = "BreachNotch"
	breach_notch.color = OUTER_RUINS_ACCENT_COLOR
	breach_notch.polygon = PackedVector2Array(
		[
			Vector2(room_width - 250, 160),
			Vector2(room_width - 120, 72),
			Vector2(room_width - 72, 240)
		]
	)
	landmark_layer.add_child(breach_notch)

	var wall_span := Polygon2D.new()
	wall_span.name = "OuterWallSilhouette"
	wall_span.color = OUTER_RUINS_DECOR_COLOR.darkened(0.12)
	wall_span.polygon = PackedVector2Array(
		[
			Vector2(0, 280),
			Vector2(room_width * 0.36, 220),
			Vector2(room_width * 0.58, 260),
			Vector2(room_width * 0.74, 210),
			Vector2(room_width, 250),
			Vector2(room_width, 360),
			Vector2(0, 360)
		]
	)
	landmark_layer.add_child(wall_span)

	var rubble_band := Polygon2D.new()
	rubble_band.name = "RubbleBand"
	rubble_band.color = OUTER_RUINS_ACCENT_COLOR.darkened(0.18)
	rubble_band.polygon = PackedVector2Array(
		[
			Vector2(90, 612),
			Vector2(280, 560),
			Vector2(460, 602),
			Vector2(650, 548),
			Vector2(860, 598),
			Vector2(1020, 562),
			Vector2(1260, 610),
			Vector2(1400, 574),
			Vector2(1510, 620),
			Vector2(1510, 664),
			Vector2(90, 664)
		]
	)
	landmark_layer.add_child(rubble_band)

	var signal_mast := Polygon2D.new()
	signal_mast.name = "SignalMast"
	signal_mast.color = OUTER_RUINS_ACCENT_COLOR
	signal_mast.polygon = PackedVector2Array(
		[
			Vector2(248, 262),
			Vector2(268, 262),
			Vector2(286, 498),
			Vector2(230, 498)
		]
	)
	landmark_layer.add_child(signal_mast)

	var fallen_gate_span := Polygon2D.new()
	fallen_gate_span.name = "FallenGateSpan"
	fallen_gate_span.color = OUTER_RUINS_DECOR_COLOR.darkened(0.18)
	fallen_gate_span.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 - 260, 332),
			Vector2(room_width * 0.5 + 90, 300),
			Vector2(room_width * 0.5 + 180, 342),
			Vector2(room_width * 0.5 - 170, 374)
		]
	)
	landmark_layer.add_child(fallen_gate_span)


func _build_transition_corridor_landmarks(landmark_layer: Node2D, room_width: float) -> void:
	var corridor_wall := Polygon2D.new()
	corridor_wall.name = "TransitionWall"
	corridor_wall.color = TRANSITION_DECOR_COLOR.darkened(0.08)
	corridor_wall.polygon = PackedVector2Array(
		[
			Vector2(140, 168),
			Vector2(room_width - 140, 168),
			Vector2(room_width - 100, 416),
			Vector2(100, 416)
		]
	)
	landmark_layer.add_child(corridor_wall)

	var bent_checkpoint := _make_landmark_rect(
		"BentCheckpoint",
		Vector2(360, 440),
		Vector2(180, 190),
		TRANSITION_DECOR_COLOR
	)
	landmark_layer.add_child(bent_checkpoint)

	var arch_left := _make_landmark_rect(
		"ArchLeft",
		Vector2(room_width * 0.38, 308),
		Vector2(96, 260),
		TRANSITION_ACCENT_COLOR
	)
	landmark_layer.add_child(arch_left)

	var arch_right := _make_landmark_rect(
		"ArchRight",
		Vector2(room_width * 0.62, 288),
		Vector2(96, 300),
		TRANSITION_ACCENT_COLOR
	)
	landmark_layer.add_child(arch_right)

	var broken_stair := Polygon2D.new()
	broken_stair.name = "BrokenStair"
	broken_stair.color = TRANSITION_DECOR_COLOR.darkened(0.14)
	broken_stair.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 - 220, 610),
			Vector2(room_width * 0.5 - 40, 610),
			Vector2(room_width * 0.5 + 50, 556),
			Vector2(room_width * 0.5 - 130, 556)
		]
	)
	landmark_layer.add_child(broken_stair)

	var signal_channel := Polygon2D.new()
	signal_channel.name = "SignalChannel"
	signal_channel.color = Color(
		TRANSITION_ACCENT_COLOR.r,
		TRANSITION_ACCENT_COLOR.g,
		TRANSITION_ACCENT_COLOR.b,
		0.26
	)
	signal_channel.polygon = PackedVector2Array(
		[
			Vector2(room_width - 420, 214),
			Vector2(room_width - 230, 214),
			Vector2(room_width - 160, 276),
			Vector2(room_width - 350, 276)
		]
	)
	landmark_layer.add_child(signal_channel)

	var loopback_banner := _make_landmark_rect(
		"LoopbackBanner",
		Vector2(room_width - 250, 304),
		Vector2(38, 180),
		TRANSITION_ACCENT_COLOR.lightened(0.08)
	)
	landmark_layer.add_child(loopback_banner)


func _build_sanctuary_hub_landmarks(landmark_layer: Node2D, room_width: float) -> void:
	var sanctuary_backdrop := Polygon2D.new()
	sanctuary_backdrop.name = "SanctuaryBackdrop"
	sanctuary_backdrop.color = SANCTUARY_DECOR_COLOR.darkened(0.12)
	sanctuary_backdrop.polygon = PackedVector2Array(
		[
			Vector2(220, 210),
			Vector2(room_width - 220, 210),
			Vector2(room_width - 120, 450),
			Vector2(120, 450)
		]
	)
	landmark_layer.add_child(sanctuary_backdrop)

	var seal_statue := _make_landmark_rect(
		"SealStatue",
		Vector2(room_width * 0.5, 430),
		Vector2(130, 250),
		SANCTUARY_DECOR_COLOR
	)
	landmark_layer.add_child(seal_statue)

	var ward_ring := Polygon2D.new()
	ward_ring.name = "WardRing"
	ward_ring.position = Vector2(room_width * 0.5, 560)
	ward_ring.color = Color(SANCTUARY_ACCENT_COLOR.r, SANCTUARY_ACCENT_COLOR.g, SANCTUARY_ACCENT_COLOR.b, 0.38)
	ward_ring.polygon = PackedVector2Array(
		[
			Vector2(-230, 12),
			Vector2(-180, -24),
			Vector2(0, -40),
			Vector2(180, -24),
			Vector2(230, 12),
			Vector2(180, 36),
			Vector2(0, 48),
			Vector2(-180, 36)
		]
	)
	landmark_layer.add_child(ward_ring)

	var left_shelter := _make_landmark_rect(
		"LeftShelter",
		Vector2(360, 470),
		Vector2(180, 170),
		SANCTUARY_DECOR_COLOR.darkened(0.06)
	)
	landmark_layer.add_child(left_shelter)

	var right_shelter := _make_landmark_rect(
		"RightShelter",
		Vector2(room_width - 360, 470),
		Vector2(180, 170),
		SANCTUARY_DECOR_COLOR.darkened(0.06)
	)
	landmark_layer.add_child(right_shelter)

	var ward_banner_left := _make_landmark_rect(
		"WardBannerLeft",
		Vector2(room_width * 0.5 - 260, 338),
		Vector2(28, 150),
		SANCTUARY_ACCENT_COLOR
	)
	landmark_layer.add_child(ward_banner_left)

	var ward_banner_right := _make_landmark_rect(
		"WardBannerRight",
		Vector2(room_width * 0.5 + 260, 338),
		Vector2(28, 150),
		SANCTUARY_ACCENT_COLOR
	)
	landmark_layer.add_child(ward_banner_right)

	var ward_boundary_left := Polygon2D.new()
	ward_boundary_left.name = "WardBoundaryLeft"
	ward_boundary_left.color = Color(
		SANCTUARY_ACCENT_COLOR.r, SANCTUARY_ACCENT_COLOR.g, SANCTUARY_ACCENT_COLOR.b, 0.28
	)
	ward_boundary_left.polygon = PackedVector2Array(
		[
			Vector2(180, 438),
			Vector2(250, 230),
			Vector2(286, 230),
			Vector2(214, 438)
		]
	)
	landmark_layer.add_child(ward_boundary_left)

	var ward_boundary_right := Polygon2D.new()
	ward_boundary_right.name = "WardBoundaryRight"
	ward_boundary_right.color = Color(
		SANCTUARY_ACCENT_COLOR.r, SANCTUARY_ACCENT_COLOR.g, SANCTUARY_ACCENT_COLOR.b, 0.28
	)
	ward_boundary_right.polygon = PackedVector2Array(
		[
			Vector2(room_width - 180, 438),
			Vector2(room_width - 250, 230),
			Vector2(room_width - 286, 230),
			Vector2(room_width - 214, 438)
		]
	)
	landmark_layer.add_child(ward_boundary_right)


func _build_gate_threshold_landmarks(landmark_layer: Node2D, room_width: float) -> void:
	var gate_wall := Polygon2D.new()
	gate_wall.name = "GateWall"
	gate_wall.color = GATE_DECOR_COLOR.darkened(0.08)
	gate_wall.polygon = PackedVector2Array(
		[
			Vector2(120, 170),
			Vector2(room_width - 120, 170),
			Vector2(room_width - 80, 420),
			Vector2(80, 420)
		]
	)
	landmark_layer.add_child(gate_wall)

	var gate_arch := _make_landmark_rect(
		"GateArch",
		Vector2(room_width * 0.5, 356),
		Vector2(360, 350),
		GATE_DECOR_COLOR
	)
	landmark_layer.add_child(gate_arch)

	var gate_void := _make_landmark_rect(
		"GateVoid",
		Vector2(room_width * 0.5, 394),
		Vector2(180, 210),
		GATE_DECOR_COLOR.darkened(0.35)
	)
	landmark_layer.add_child(gate_void)

	var left_guardian := _make_landmark_rect(
		"LeftGuardian",
		Vector2(room_width * 0.5 - 310, 458),
		Vector2(110, 210),
		GATE_DECOR_COLOR.darkened(0.02)
	)
	landmark_layer.add_child(left_guardian)

	var right_guardian := _make_landmark_rect(
		"RightGuardian",
		Vector2(room_width * 0.5 + 310, 458),
		Vector2(110, 210),
		GATE_DECOR_COLOR.darkened(0.02)
	)
	landmark_layer.add_child(right_guardian)

	var inspection_dais := Polygon2D.new()
	inspection_dais.name = "InspectionDais"
	inspection_dais.color = GATE_ACCENT_COLOR.darkened(0.22)
	inspection_dais.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 - 460, 640),
			Vector2(room_width * 0.5 + 460, 640),
			Vector2(room_width * 0.5 + 400, 590),
			Vector2(room_width * 0.5 - 400, 590)
		]
	)
	landmark_layer.add_child(inspection_dais)

	var upper_rampart_left := _make_landmark_rect(
		"UpperRampartLeft",
		Vector2(room_width * 0.5 - 520, 228),
		Vector2(180, 84),
		GATE_ACCENT_COLOR
	)
	landmark_layer.add_child(upper_rampart_left)

	var upper_rampart_right := _make_landmark_rect(
		"UpperRampartRight",
		Vector2(room_width * 0.5 + 520, 228),
		Vector2(180, 84),
		GATE_ACCENT_COLOR
	)
	landmark_layer.add_child(upper_rampart_right)

	var chain_array := Polygon2D.new()
	chain_array.name = "ChainArray"
	chain_array.color = GATE_ACCENT_COLOR.darkened(0.1)
	chain_array.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 - 140, 182),
			Vector2(room_width * 0.5 - 20, 332),
			Vector2(room_width * 0.5 + 20, 332),
			Vector2(room_width * 0.5 - 100, 182)
		]
	)
	landmark_layer.add_child(chain_array)

	var judgement_beam := _make_landmark_rect(
		"JudgementBeam",
		Vector2(room_width * 0.5, 154),
		Vector2(520, 22),
		GATE_ACCENT_COLOR.lightened(0.08)
	)
	landmark_layer.add_child(judgement_beam)


func _build_inner_keep_landmarks(landmark_layer: Node2D, room_width: float) -> void:
	var grand_hall := Polygon2D.new()
	grand_hall.name = "GrandHallBackdrop"
	grand_hall.color = INNER_KEEP_DECOR_COLOR.darkened(0.08)
	grand_hall.polygon = PackedVector2Array(
		[
			Vector2(180, 180),
			Vector2(room_width - 180, 180),
			Vector2(room_width - 120, 430),
			Vector2(120, 430)
		]
	)
	landmark_layer.add_child(grand_hall)

	var portrait_row_left := _make_landmark_rect(
		"PortraitRowLeft",
		Vector2(420, 280),
		Vector2(160, 120),
		INNER_KEEP_ACCENT_COLOR
	)
	landmark_layer.add_child(portrait_row_left)

	var portrait_row_right := _make_landmark_rect(
		"PortraitRowRight",
		Vector2(room_width - 420, 280),
		Vector2(160, 120),
		INNER_KEEP_ACCENT_COLOR
	)
	landmark_layer.add_child(portrait_row_right)

	var central_chandelier := Polygon2D.new()
	central_chandelier.name = "CentralChandelier"
	central_chandelier.color = INNER_KEEP_ACCENT_COLOR.lightened(0.08)
	central_chandelier.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5, 200),
			Vector2(room_width * 0.5 + 90, 270),
			Vector2(room_width * 0.5, 330),
			Vector2(room_width * 0.5 - 90, 270)
		]
	)
	landmark_layer.add_child(central_chandelier)

	var archive_cabinet_left := _make_landmark_rect(
		"ArchiveCabinetLeft",
		Vector2(280, 414),
		Vector2(118, 188),
		INNER_KEEP_DECOR_COLOR.darkened(0.03)
	)
	landmark_layer.add_child(archive_cabinet_left)

	var archive_cabinet_right := _make_landmark_rect(
		"ArchiveCabinetRight",
		Vector2(room_width - 280, 414),
		Vector2(118, 188),
		INNER_KEEP_DECOR_COLOR.darkened(0.03)
	)
	landmark_layer.add_child(archive_cabinet_right)

	var ward_tether_left := Polygon2D.new()
	ward_tether_left.name = "WardTetherLeft"
	ward_tether_left.color = Color(
		INNER_KEEP_ACCENT_COLOR.r, INNER_KEEP_ACCENT_COLOR.g, INNER_KEEP_ACCENT_COLOR.b, 0.28
	)
	ward_tether_left.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 - 176, 214),
			Vector2(room_width * 0.5 - 146, 214),
			Vector2(room_width * 0.5 - 214, 486),
			Vector2(room_width * 0.5 - 244, 486)
		]
	)
	landmark_layer.add_child(ward_tether_left)

	var ward_tether_right := Polygon2D.new()
	ward_tether_right.name = "WardTetherRight"
	ward_tether_right.color = Color(
		INNER_KEEP_ACCENT_COLOR.r, INNER_KEEP_ACCENT_COLOR.g, INNER_KEEP_ACCENT_COLOR.b, 0.28
	)
	ward_tether_right.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 + 176, 214),
			Vector2(room_width * 0.5 + 146, 214),
			Vector2(room_width * 0.5 + 214, 486),
			Vector2(room_width * 0.5 + 244, 486)
		]
	)
	landmark_layer.add_child(ward_tether_right)


func _build_throne_approach_landmarks(landmark_layer: Node2D, room_width: float) -> void:
	var approach_wall := Polygon2D.new()
	approach_wall.name = "ApproachWall"
	approach_wall.color = THRONE_DECOR_COLOR.darkened(0.08)
	approach_wall.polygon = PackedVector2Array(
		[
			Vector2(160, 160),
			Vector2(room_width - 160, 160),
			Vector2(room_width - 100, 420),
			Vector2(100, 420)
		]
	)
	landmark_layer.add_child(approach_wall)

	var throne_dais := Polygon2D.new()
	throne_dais.name = "ThroneDais"
	throne_dais.color = THRONE_ACCENT_COLOR.darkened(0.16)
	throne_dais.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 - 280, 620),
			Vector2(room_width * 0.5 + 280, 620),
			Vector2(room_width * 0.5 + 220, 560),
			Vector2(room_width * 0.5 - 220, 560)
		]
	)
	landmark_layer.add_child(throne_dais)

	var throne_back := _make_landmark_rect(
		"ThroneBack",
		Vector2(room_width * 0.5, 310),
		Vector2(160, 220),
		THRONE_DECOR_COLOR
	)
	landmark_layer.add_child(throne_back)

	var banner_left := _make_landmark_rect(
		"ThroneBannerLeft",
		Vector2(room_width * 0.5 - 300, 300),
		Vector2(36, 180),
		THRONE_ACCENT_COLOR
	)
	landmark_layer.add_child(banner_left)

	var banner_right := _make_landmark_rect(
		"ThroneBannerRight",
		Vector2(room_width * 0.5 + 300, 300),
		Vector2(36, 180),
		THRONE_ACCENT_COLOR
	)
	landmark_layer.add_child(banner_right)

	var decree_pillar_left := _make_landmark_rect(
		"DecreePillarLeft",
		Vector2(room_width * 0.5 - 460, 392),
		Vector2(84, 258),
		THRONE_DECOR_COLOR.darkened(0.02)
	)
	landmark_layer.add_child(decree_pillar_left)

	var decree_pillar_right := _make_landmark_rect(
		"DecreePillarRight",
		Vector2(room_width * 0.5 + 460, 392),
		Vector2(84, 258),
		THRONE_DECOR_COLOR.darkened(0.02)
	)
	landmark_layer.add_child(decree_pillar_right)

	var procession_runes := Polygon2D.new()
	procession_runes.name = "ProcessionRunes"
	procession_runes.color = Color(
		THRONE_ACCENT_COLOR.r, THRONE_ACCENT_COLOR.g, THRONE_ACCENT_COLOR.b, 0.24
	)
	procession_runes.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 - 84, 642),
			Vector2(room_width * 0.5 + 84, 642),
			Vector2(room_width * 0.5 + 126, 574),
			Vector2(room_width * 0.5 + 40, 546),
			Vector2(room_width * 0.5, 516),
			Vector2(room_width * 0.5 - 40, 546),
			Vector2(room_width * 0.5 - 126, 574)
		]
	)
	landmark_layer.add_child(procession_runes)


func _build_inverted_spire_landmarks(landmark_layer: Node2D, room_width: float) -> void:
	var tower_mass := Polygon2D.new()
	tower_mass.name = "TowerMass"
	tower_mass.color = SPIRE_DECOR_COLOR.darkened(0.08)
	tower_mass.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 - 280, 40),
			Vector2(room_width * 0.5 + 280, 40),
			Vector2(room_width * 0.5 + 180, 290),
			Vector2(room_width * 0.5 - 180, 290)
		]
	)
	landmark_layer.add_child(tower_mass)

	var inverted_spire := Polygon2D.new()
	inverted_spire.name = "InvertedSpire"
	inverted_spire.color = SPIRE_DECOR_COLOR
	inverted_spire.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 - 120, 290),
			Vector2(room_width * 0.5 + 120, 290),
			Vector2(room_width * 0.5 + 40, 520),
			Vector2(room_width * 0.5 - 40, 520)
		]
	)
	landmark_layer.add_child(inverted_spire)

	var covenant_dais := Polygon2D.new()
	covenant_dais.name = "CovenantDais"
	covenant_dais.color = SPIRE_ACCENT_COLOR.darkened(0.14)
	covenant_dais.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 - 300, 590),
			Vector2(room_width * 0.5 + 300, 590),
			Vector2(room_width * 0.5 + 240, 540),
			Vector2(room_width * 0.5 - 240, 540)
		]
	)
	landmark_layer.add_child(covenant_dais)

	var covenant_ring := Polygon2D.new()
	covenant_ring.name = "CovenantRing"
	covenant_ring.position = Vector2(room_width * 0.5, 550)
	covenant_ring.color = Color(SPIRE_ACCENT_COLOR.r, SPIRE_ACCENT_COLOR.g, SPIRE_ACCENT_COLOR.b, 0.42)
	covenant_ring.polygon = PackedVector2Array(
		[
			Vector2(-180, 10),
			Vector2(-120, -22),
			Vector2(0, -34),
			Vector2(120, -22),
			Vector2(180, 10),
			Vector2(120, 32),
			Vector2(0, 42),
			Vector2(-120, 32)
		]
	)
	landmark_layer.add_child(covenant_ring)

	var left_chamber_fragment := _make_landmark_rect(
		"LeftChamberFragment",
		Vector2(430, 320),
		Vector2(200, 130),
		SPIRE_DECOR_COLOR.darkened(0.02)
	)
	landmark_layer.add_child(left_chamber_fragment)

	var right_chamber_fragment := _make_landmark_rect(
		"RightChamberFragment",
		Vector2(room_width - 430, 320),
		Vector2(200, 130),
		SPIRE_DECOR_COLOR.darkened(0.02)
	)
	landmark_layer.add_child(right_chamber_fragment)

	var royal_canopy_remnant := Polygon2D.new()
	royal_canopy_remnant.name = "RoyalCanopyRemnant"
	royal_canopy_remnant.color = SPIRE_ACCENT_COLOR.darkened(0.06)
	royal_canopy_remnant.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 - 340, 128),
			Vector2(room_width * 0.5 + 340, 128),
			Vector2(room_width * 0.5 + 250, 184),
			Vector2(room_width * 0.5 - 250, 184)
		]
	)
	landmark_layer.add_child(royal_canopy_remnant)

	var spire_talon_left := Polygon2D.new()
	spire_talon_left.name = "SpireTalonLeft"
	spire_talon_left.color = SPIRE_DECOR_COLOR.darkened(0.16)
	spire_talon_left.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 - 210, 252),
			Vector2(room_width * 0.5 - 126, 314),
			Vector2(room_width * 0.5 - 182, 412),
			Vector2(room_width * 0.5 - 278, 352)
		]
	)
	landmark_layer.add_child(spire_talon_left)

	var spire_talon_right := Polygon2D.new()
	spire_talon_right.name = "SpireTalonRight"
	spire_talon_right.color = SPIRE_DECOR_COLOR.darkened(0.16)
	spire_talon_right.polygon = PackedVector2Array(
		[
			Vector2(room_width * 0.5 + 210, 252),
			Vector2(room_width * 0.5 + 126, 314),
			Vector2(room_width * 0.5 + 182, 412),
			Vector2(room_width * 0.5 + 278, 352)
		]
	)
	landmark_layer.add_child(spire_talon_right)


func _make_background_sprite(texture: Texture2D, position_value: Vector2, alpha: float) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = position_value
	sprite.centered = true
	sprite.scale = BG_SCALE
	sprite.modulate = Color(1, 1, 1, alpha)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return sprite


func _make_landmark_rect(
	name: String, position_value: Vector2, size: Vector2, color: Color
) -> Polygon2D:
	var rect := Polygon2D.new()
	rect.name = name
	rect.position = position_value
	rect.color = color
	rect.polygon = PackedVector2Array(
		[
			Vector2(-size.x * 0.5, -size.y * 0.5),
			Vector2(size.x * 0.5, -size.y * 0.5),
			Vector2(size.x * 0.5, size.y * 0.5),
			Vector2(-size.x * 0.5, size.y * 0.5)
		]
	)
	return rect


func _make_segment_decor(
	position_value: Vector2,
	size: Vector2,
	palette_index: int,
	segment_index: int,
	segment_spec: Dictionary = {}
) -> Node2D:
	var decor := Node2D.new()
	decor.name = "SegmentDecor_%d" % segment_index
	decor.position = position_value

	if _is_platform_decor_segment(size, str(segment_spec.get("decor_kind", FLOOR_SEGMENT_DECOR_AUTO))):
		_build_platform_decor(decor, size, palette_index, segment_index, segment_spec)
	else:
		_build_ground_decor(decor, size, palette_index, segment_spec)

	return decor


func _build_ground_decor(
	decor: Node2D, size: Vector2, palette_index: int, segment_spec: Dictionary = {}
) -> void:
	var texture: Texture2D = _get_floor_textures()[palette_index]
	var fill := Polygon2D.new()
	fill.name = "GroundFill"
	fill.z_index = -1
	fill.color = _segment_color(0, size, palette_index, segment_spec).darkened(0.08)
	fill.polygon = PackedVector2Array(
		[
			Vector2(-size.x * 0.5, -size.y * 0.5 + 24.0),
			Vector2(size.x * 0.5, -size.y * 0.5 + 24.0),
			Vector2(size.x * 0.5, size.y * 0.5),
			Vector2(-size.x * 0.5, size.y * 0.5)
		]
	)
	decor.add_child(fill)

	var top_row := Node2D.new()
	top_row.name = "GroundDecor"
	decor.add_child(top_row)

	var columns := int(ceil(size.x / FLOOR_TILE_SIZE.x))
	for column in columns:
		var region := Rect2(0, 0, FLOOR_TILE_SIZE.x, FLOOR_TILE_SIZE.y)
		if column == columns - 1 and column > 0:
			region.position.x = FLOOR_TILE_SIZE.x * 2.0
		var sprite := _make_region_sprite(
			texture,
			region,
			Vector2(
				-size.x * 0.5 + FLOOR_TILE_SIZE.x * 0.5 + column * FLOOR_TILE_SIZE.x,
				-size.y * 0.5 + FLOOR_TILE_SIZE.y * 0.5
			)
		)
		top_row.add_child(sprite)


func _build_platform_decor(
	decor: Node2D,
	size: Vector2,
	palette_index: int,
	segment_index: int,
	segment_spec: Dictionary = {}
) -> void:
	var texture: Texture2D = _get_other_textures()[palette_index]
	var underside := Polygon2D.new()
	underside.name = "PlatformUnderside"
	underside.z_index = -1
	underside.color = _segment_color(segment_index, size, palette_index, segment_spec).darkened(0.15)
	underside.polygon = PackedVector2Array(
		[
			Vector2(-size.x * 0.5, -size.y * 0.5 + 8.0),
			Vector2(size.x * 0.5, -size.y * 0.5 + 8.0),
			Vector2(size.x * 0.5, size.y * 0.5),
			Vector2(-size.x * 0.5, size.y * 0.5)
		]
	)
	decor.add_child(underside)

	var platform_row := Node2D.new()
	platform_row.name = "PlatformDecor"
	decor.add_child(platform_row)

	var columns := int(ceil(size.x / FLOOR_TILE_SIZE.x))
	for column in columns:
		var region_x := 0.0
		if column == columns - 1 and column > 0:
			region_x = PLATFORM_TILE_SIZE.x
		var sprite := _make_region_sprite(
			texture,
			Rect2(region_x, 96, PLATFORM_TILE_SIZE.x, PLATFORM_TILE_SIZE.y),
			Vector2(
				-size.x * 0.5 + FLOOR_TILE_SIZE.x * 0.5 + column * FLOOR_TILE_SIZE.x,
				-size.y * 0.5 + PLATFORM_TILE_SIZE.y * 0.5
			)
		)
		platform_row.add_child(sprite)


func _make_region_sprite(texture: Texture2D, region: Rect2, position_value: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = position_value
	sprite.centered = true
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return sprite


func _make_floor_collision_body(
	position_value: Vector2,
	size: Vector2,
	color: Color,
	collision_mode: String = FLOOR_SEGMENT_COLLISION_AUTO
) -> StaticBody2D:
	return _make_static_rect(position_value, size, color, _build_floor_collision_profile(size, collision_mode))


func _build_floor_collision_profile(
	size: Vector2, collision_mode: String = FLOOR_SEGMENT_COLLISION_AUTO
) -> Dictionary:
	if _is_one_way_floor_segment(size, collision_mode):
		var collision_height := minf(size.y, PLATFORM_ONE_WAY_COLLISION_HEIGHT)
		return {
			"collision_kind": "one_way_platform",
			"shape_size": Vector2(size.x, collision_height),
			"shape_offset": Vector2(0.0, -size.y * 0.5 + collision_height * 0.5),
			"one_way": true,
			"one_way_margin": PLATFORM_ONE_WAY_COLLISION_MARGIN
		}
	return {
		"collision_kind": "solid_floor",
		"shape_size": size,
		"shape_offset": Vector2.ZERO,
		"one_way": false,
		"one_way_margin": 0.0
	}


func _is_thin_floor_segment(size: Vector2) -> bool:
	return size.y <= ROOM_FLOOR_THRESHOLD


func _is_platform_decor_segment(size: Vector2, decor_kind: String) -> bool:
	match decor_kind:
		FLOOR_SEGMENT_DECOR_GROUND:
			return false
		FLOOR_SEGMENT_DECOR_PLATFORM:
			return true
	return _is_thin_floor_segment(size)


func _is_one_way_floor_segment(size: Vector2, collision_mode: String) -> bool:
	match collision_mode:
		FLOOR_SEGMENT_COLLISION_SOLID:
			return false
		FLOOR_SEGMENT_COLLISION_ONE_WAY:
			return true
	return _is_thin_floor_segment(size)


func _normalize_floor_segment(raw_segment) -> Dictionary:
	if typeof(raw_segment) != TYPE_DICTIONARY:
		if typeof(raw_segment) == TYPE_ARRAY:
			push_warning("Ignoring legacy floor segment array; runtime room builder expects canonical dictionary floor_segments.")
		else:
			push_warning("Ignoring unsupported floor segment entry type.")
		return {"valid": false}
	var segment_data: Dictionary = raw_segment
	if _is_legacy_floor_segment_fallback_dictionary(segment_data):
		push_warning(
			"Ignoring legacy floor segment dictionary; runtime room builder expects position/size arrays."
		)
		return {"valid": false}
	var position_result := _read_canonical_floor_segment_vector2(segment_data, "position")
	var size_result := _read_canonical_floor_segment_vector2(segment_data, "size")
	if not bool(position_result.get("valid", false)) or not bool(size_result.get("valid", false)):
		push_warning("Ignoring canonical floor segment dictionary with malformed position or size.")
		return {"valid": false}
	var size_value: Vector2 = size_result.get("value", Vector2.ZERO)
	if size_value.x <= 0.0 or size_value.y <= 0.0:
		push_warning("Ignoring canonical floor segment dictionary with invalid size.")
		return {"valid": false}
	return {
		"valid": true,
		"position": position_result.get("value", Vector2.ZERO),
		"size": size_value,
		"decor_kind": _normalize_floor_segment_decor_kind(
			str(segment_data.get("decor_kind", FLOOR_SEGMENT_DECOR_AUTO))
		),
		"collision_mode": _normalize_floor_segment_collision_mode(
			str(segment_data.get("collision_mode", FLOOR_SEGMENT_COLLISION_AUTO))
		)
	}


func _is_legacy_floor_segment_fallback_dictionary(segment_data: Dictionary) -> bool:
	if segment_data.has("position") or segment_data.has("size"):
		return false
	return (
		segment_data.has("x")
		or segment_data.has("y")
		or segment_data.has("width")
		or segment_data.has("height")
	)


func _read_canonical_floor_segment_vector2(segment_data: Dictionary, vector_key: String) -> Dictionary:
	var vector_value = segment_data.get(vector_key, null)
	if vector_value is Vector2:
		return {"valid": true, "value": vector_value}
	if typeof(vector_value) == TYPE_ARRAY:
		var coords: Array = vector_value
		if coords.size() >= 2 and _is_floor_segment_numeric(coords[0]) and _is_floor_segment_numeric(coords[1]):
			return {"valid": true, "value": Vector2(float(coords[0]), float(coords[1]))}
	return {"valid": false}


func _is_floor_segment_numeric(value) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


func _normalize_floor_segment_decor_kind(decor_kind: String) -> String:
	match decor_kind:
		FLOOR_SEGMENT_DECOR_GROUND, FLOOR_SEGMENT_DECOR_PLATFORM:
			return decor_kind
	return FLOOR_SEGMENT_DECOR_AUTO


func _normalize_floor_segment_collision_mode(collision_mode: String) -> String:
	match collision_mode:
		FLOOR_SEGMENT_COLLISION_SOLID, FLOOR_SEGMENT_COLLISION_ONE_WAY:
			return collision_mode
	return FLOOR_SEGMENT_COLLISION_AUTO


func _make_static_rect(
	position_value: Vector2, size: Vector2, color: Color, collision_profile: Dictionary = {}
) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = position_value
	var profile := {
		"collision_kind": "solid_rect",
		"shape_size": size,
		"shape_offset": Vector2.ZERO,
		"one_way": false,
		"one_way_margin": 0.0
	}
	if not collision_profile.is_empty():
		profile.merge(collision_profile, true)
	var collision_size: Vector2 = profile.get("shape_size", size)
	var collision_offset: Vector2 = profile.get("shape_offset", Vector2.ZERO)
	var collision_kind := str(profile.get("collision_kind", "solid_rect"))

	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = collision_size
	shape.shape = rect_shape
	shape.position = collision_offset
	shape.one_way_collision = bool(profile.get("one_way", false))
	shape.one_way_collision_margin = float(profile.get("one_way_margin", 0.0))
	shape.set_meta("collision_kind", collision_kind)
	body.add_child(shape)
	body.set_meta("collision_kind", collision_kind)

	var polygon := Polygon2D.new()
	var overlay_color := color
	overlay_color.a = 0.22
	polygon.color = overlay_color
	polygon.z_index = -6
	polygon.polygon = PackedVector2Array(
		[
			Vector2(-size.x * 0.5, -size.y * 0.5),
			Vector2(size.x * 0.5, -size.y * 0.5),
			Vector2(size.x * 0.5, size.y * 0.5),
			Vector2(-size.x * 0.5, size.y * 0.5)
		]
	)
	body.add_child(polygon)
	return body


func _make_wall(position_value: Vector2, size: Vector2) -> StaticBody2D:
	return _make_static_rect(
		position_value, size, Color("#1d2b3e"), {"collision_kind": "boundary_wall"}
	)


func _choose_palette_index(room_data: Dictionary) -> int:
	var room_id := str(room_data.get("id", ""))
	if room_id in ["conduit", "vault_sector", "arcane_core"]:
		return 1
	return 0


func _get_background_textures() -> Array[Texture2D]:
	return _load_texture_group(BG_TEXTURE_PATHS)


func _get_floor_textures() -> Array[Texture2D]:
	return _load_texture_group(FLOOR_TEXTURE_PATHS)


func _get_other_textures() -> Array[Texture2D]:
	return _load_texture_group(OTHER_TEXTURE_PATHS)


func _load_texture_group(paths: Array) -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	for path in paths:
		textures.append(_load_runtime_texture(str(path)))
	return textures


func _load_runtime_texture(path: String) -> Texture2D:
	if _texture_cache.has(path):
		return _texture_cache[path]

	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty():
		image = Image.create(int(FLOOR_TILE_SIZE.x), int(FLOOR_TILE_SIZE.y), false, Image.FORMAT_RGBA8)
		image.fill(Color(1, 0, 1, 1))

	var texture := ImageTexture.create_from_image(image)
	_texture_cache[path] = texture
	return texture


func _segment_color(
	segment_index: int, size: Vector2, palette_index: int, segment_spec: Dictionary = {}
) -> Color:
	var decor_kind := str(segment_spec.get("decor_kind", FLOOR_SEGMENT_DECOR_AUTO))
	if _is_platform_decor_segment(size, decor_kind):
		return Color("#5b4633") if palette_index == 0 else Color("#6c5134")
	return Color("#403427") if palette_index == 0 else Color("#4a3425")
