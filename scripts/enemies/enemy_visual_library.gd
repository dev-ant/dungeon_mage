extends RefCounted

const MUSHROOM_SHEETS := {
	"idle": {"frames": 7, "fps": 8.0, "loop": true},
	"run": {"frames": 8, "fps": 10.0, "loop": true},
	"attack": {"frames": 10, "fps": 10.0, "loop": false},
	"hurt": {"frames": 5, "fps": 10.0, "loop": false},
	"death": {"frames": 15, "fps": 8.0, "loop": false}
}
const MUSHROOM_SHEET_DIR := "res://assets/monsters/mushroom/"
const MUSHROOM_ANIM_FILES := {
	"idle": "Mushroom-Idle.png",
	"run": "Mushroom-Run.png",
	"attack": "Mushroom-Attack.png",
	"hurt": "Mushroom-Hit.png",
	"death": "Mushroom-Die.png"
}

const BAT_SHEETS := {
	"idle": {"frames": 9, "fps": 8.0, "loop": true},
	"run": {"frames": 8, "fps": 10.0, "loop": true},
	"attack": {"frames": 8, "fps": 10.0, "loop": false},
	"attack2": {"frames": 11, "fps": 10.0, "loop": false},
	"hurt": {"frames": 5, "fps": 10.0, "loop": false},
	"death": {"frames": 12, "fps": 8.0, "loop": false},
	"sleep": {"frames": 3, "fps": 6.0, "loop": true},
	"wakeup": {"frames": 16, "fps": 10.0, "loop": false}
}
const BAT_SHEET_DIR := "res://assets/monsters/bat/"
const BAT_ANIM_FILES := {
	"idle": "Bat-IdleFly.png",
	"run": "Bat-Run.png",
	"attack": "Bat-Attack1.png",
	"attack2": "Bat-Attack2.png",
	"hurt": "Bat-Hurt.png",
	"death": "Bat-Die.png",
	"sleep": "Bat-Sleep.png",
	"wakeup": "Bat-WakeUp.png"
}

const WORM_SHEETS := {
	"idle": {"frames": 9, "fps": 8.0, "loop": true},
	"run": {"frames": 9, "fps": 10.0, "loop": true},
	"attack": {"frames": 16, "fps": 12.0, "loop": false},
	"hurt": {"frames": 3, "fps": 10.0, "loop": false},
	"death": {"frames": 8, "fps": 8.0, "loop": false}
}
const WORM_SHEET_DIR := "res://assets/monsters/worm/"
const WORM_ANIM_FILES := {
	"idle": "Idle.png",
	"run": "Walk.png",
	"attack": "Attack.png",
	"hurt": "Get Hit.png",
	"death": "Death.png"
}

const MUSHROOM_FULL_SHEETS := {
	"idle": {"frames": 7, "fps": 8.0, "loop": true},
	"run": {"frames": 8, "fps": 10.0, "loop": true},
	"attack": {"frames": 10, "fps": 10.0, "loop": false},
	"attack2": {"frames": 24, "fps": 10.0, "loop": false},
	"hurt": {"frames": 5, "fps": 10.0, "loop": false},
	"stun": {"frames": 18, "fps": 8.0, "loop": true},
	"death": {"frames": 15, "fps": 8.0, "loop": false}
}
const MUSHROOM_FULL_ANIM_FILES := {
	"idle": "Mushroom-Idle.png",
	"run": "Mushroom-Run.png",
	"attack": "Mushroom-Attack.png",
	"attack2": "Mushroom-AttackWithStun.png",
	"hurt": "Mushroom-Hit.png",
	"stun": "Mushroom-Stun.png",
	"death": "Mushroom-Die.png"
}

const RAT_SHEETS := {
	"idle": {"frames": 6, "fps": 8.0, "loop": true},
	"run": {"frames": 6, "fps": 12.0, "loop": true},
	"attack": {"frames": 6, "fps": 10.0, "loop": false},
	"hurt": {"frames": 1, "fps": 8.0, "loop": false},
	"death": {"frames": 6, "fps": 8.0, "loop": false}
}
const RAT_SHEET_DIR := "res://assets/monsters/rat/"
const RAT_ANIM_FILES := {
	"idle": "rat-idle.png",
	"run": "rat-run.png",
	"attack": "rat-attack.png",
	"hurt": "rat-hurt.png",
	"death": "rat-death.png"
}

const TOOTH_WALKER_SHEET_PATH := "res://assets/monsters/tooth_walker/tooth-walker-sheet.png"
const TOOTH_WALKER_ANIM_ROWS := {
	"idle": {"row": 0, "frames": 6, "fps": 7.0, "loop": true},
	"run": {"row": 1, "frames": 6, "fps": 10.0, "loop": true},
	"attack": {"row": 2, "frames": 6, "fps": 10.0, "loop": false},
	"hurt": {"row": 3, "frames": 6, "fps": 10.0, "loop": false},
	"death": {"row": 4, "frames": 6, "fps": 7.0, "loop": false, "trim_empty_tail": true}
}

const EYEBALL_SHEET_PATH := "res://assets/monsters/eyeball/eyeball-sheet.png"
const EYEBALL_ANIM_VERT := {
	"idle": {"start": 0, "frames": 10, "fps": 7.0, "loop": true},
	"run": {"start": 10, "frames": 10, "fps": 10.0, "loop": true},
	"attack": {"start": 20, "frames": 15, "fps": 10.0, "loop": false},
	"hurt": {"start": 35, "frames": 10, "fps": 10.0, "loop": false},
	"death": {"start": 45, "frames": 5, "fps": 7.0, "loop": false}
}

const TRASH_MONSTER_SHEET_PATH := "res://assets/monsters/trash_monster/trash-monster-sheet.png"
const TRASH_MONSTER_ANIM_ROWS := {
	"idle": {"row": 0, "frames": 6, "fps": 6.0, "loop": true},
	"run": {"row": 1, "frames": 6, "fps": 8.0, "loop": true},
	"attack": {"row": 2, "frames": 6, "fps": 10.0, "loop": false},
	"hurt": {"row": 3, "frames": 6, "fps": 10.0, "loop": false},
	"death": {"row": 4, "frames": 6, "fps": 7.0, "loop": false}
}

const SWORD_SHEET_PATH := "res://assets/monsters/sword/sword-sheet.png"
const SWORD_ANIM_ROWS := {
	"idle": {"row": 0, "frames": 14, "fps": 8.0, "loop": true, "trim_empty_tail": true},
	"run": {"row": 1, "frames": 14, "fps": 12.0, "loop": true, "trim_empty_tail": true},
	"attack": {"row": 2, "frames": 14, "fps": 12.0, "loop": false, "trim_empty_tail": true},
	"hurt": {"row": 4, "frames": 14, "fps": 10.0, "loop": false},
	"death": {"row": 6, "frames": 14, "fps": 8.0, "loop": false, "trim_empty_tail": true}
}


static func setup_enemy_sprite(
	enemy: Node, enemy_type: String, body_polygon: Polygon2D
) -> AnimatedSprite2D:
	if DisplayServer.get_name() == "headless":
		return null
	if body_polygon != null:
		body_polygon.visible = true
	var sprite := _build_enemy_sprite(enemy, enemy_type)
	if sprite == null:
		return null
	enemy.add_child(sprite)
	sprite.play("idle")
	if body_polygon != null:
		body_polygon.visible = false
	return sprite


static func update_animation(
	enemy_sprite: AnimatedSprite2D,
	behavior_state: String,
	enemy_type: String,
	mushroom_stun_attack_active: bool,
	velocity: Vector2
) -> void:
	if enemy_sprite == null:
		return
	var facing_dir: float = sign(velocity.x)
	if facing_dir != 0.0:
		enemy_sprite.scale.x = facing_dir * enemy_sprite.scale.y
	var target_anim := "idle"
	match behavior_state:
		"stagger":
			target_anim = "hurt"
		"attack":
			target_anim = (
				"attack2" if enemy_type == "mushroom" and mushroom_stun_attack_active else "attack"
			)
		"pursue":
			target_anim = "run" if abs(velocity.x) > 10.0 else "idle"
	if not enemy_sprite.sprite_frames.has_animation(target_anim):
		target_anim = "idle"
	if enemy_sprite.animation != target_anim:
		enemy_sprite.play(target_anim)


static func _build_enemy_sprite(enemy: Node, enemy_type: String) -> AnimatedSprite2D:
	var frames: SpriteFrames = null
	var sprite_scale := 1.0
	var sprite_pos := Vector2.ZERO
	if enemy_type == "tooth_walker":
		frames = _build_grid_sprite_frames(TOOTH_WALKER_SHEET_PATH, TOOTH_WALKER_ANIM_ROWS, 64, 64)
		sprite_scale = 1.2
		sprite_pos = Vector2(0, -8)
	elif enemy_type == "eyeball":
		frames = _build_vertical_sprite_frames(EYEBALL_SHEET_PATH, EYEBALL_ANIM_VERT, 128, 48)
		sprite_scale = 1.1
		sprite_pos = Vector2(0, -10)
	elif enemy_type == "trash_monster":
		frames = _build_grid_sprite_frames(
			TRASH_MONSTER_SHEET_PATH, TRASH_MONSTER_ANIM_ROWS, 64, 64
		)
		sprite_scale = 1.2
		sprite_pos = Vector2(0, -8)
	elif enemy_type == "sword":
		frames = _build_grid_sprite_frames(SWORD_SHEET_PATH, SWORD_ANIM_ROWS, 128, 64)
		sprite_scale = 1.3
		sprite_pos = Vector2(0, -10)
	else:
		var profile := _get_strip_profile(enemy_type)
		if profile.is_empty():
			return null
		frames = _build_strip_sprite_frames(
			str(profile.get("sheet_dir", "")),
			profile.get("sheets", {}),
			profile.get("anim_files", {}),
			int(profile.get("frame_w", 64)),
			int(profile.get("frame_h", 64))
		)
		sprite_scale = float(profile.get("scale", 1.0))
		sprite_pos = profile.get("position", Vector2.ZERO)
	if frames == null:
		return null
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.position = sprite_pos
	sprite.animation = "idle"
	return sprite


static func _get_strip_profile(enemy_type: String) -> Dictionary:
	match enemy_type:
		"brute", "dummy", "ranged":
			return {
				"sheets": MUSHROOM_SHEETS,
				"sheet_dir": MUSHROOM_SHEET_DIR,
				"anim_files": MUSHROOM_ANIM_FILES,
				"scale": 1.2,
				"position": Vector2(0, -10),
				"frame_w": 80,
				"frame_h": 64
			}
		"mushroom":
			return {
				"sheets": MUSHROOM_FULL_SHEETS,
				"sheet_dir": MUSHROOM_SHEET_DIR,
				"anim_files": MUSHROOM_FULL_ANIM_FILES,
				"scale": 1.2,
				"position": Vector2(0, -10),
				"frame_w": 80,
				"frame_h": 64
			}
		"bat":
			return {
				"sheets": BAT_SHEETS,
				"sheet_dir": BAT_SHEET_DIR,
				"anim_files": BAT_ANIM_FILES,
				"scale": 1.4,
				"position": Vector2(0, -10),
				"frame_w": 64,
				"frame_h": 64
			}
		"worm":
			return {
				"sheets": WORM_SHEETS,
				"sheet_dir": WORM_SHEET_DIR,
				"anim_files": WORM_ANIM_FILES,
				"scale": 1.1,
				"position": Vector2(0, 14),
				"frame_w": 90,
				"frame_h": 90
			}
		"rat":
			return {
				"sheets": RAT_SHEETS,
				"sheet_dir": RAT_SHEET_DIR,
				"anim_files": RAT_ANIM_FILES,
				"scale": 1.3,
				"position": Vector2(0, 14),
				"frame_w": 32,
				"frame_h": 32
			}
		_:
			return {}


static func _build_strip_sprite_frames(
	sheet_dir: String, sheets: Dictionary, anim_files: Dictionary, frame_w: int, frame_h: int
) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var loaded_any := false
	for anim_name in sheets:
		var info: Dictionary = sheets[anim_name]
		var file_name: String = anim_files[anim_name]
		var tex: Texture2D = ResourceLoader.load(sheet_dir + file_name, "Texture2D")
		if tex == null:
			continue
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, bool(info["loop"]))
		frames.set_animation_speed(anim_name, float(info["fps"]))
		var frame_count: int = int(info["frames"])
		for i in range(frame_count):
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(i * frame_w, 0, frame_w, frame_h)
			frames.add_frame(anim_name, atlas)
		loaded_any = true
	return frames if loaded_any else null


static func _build_grid_sprite_frames(
	sheet_path: String, anim_rows: Dictionary, frame_w: int, frame_h: int
) -> SpriteFrames:
	var tex: Texture2D = ResourceLoader.load(sheet_path, "Texture2D")
	if tex == null:
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for anim_name in anim_rows:
		var info: Dictionary = anim_rows[anim_name]
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, bool(info.get("loop", true)))
		frames.set_animation_speed(anim_name, float(info.get("fps", 8.0)))
		var frame_count: int = int(info.get("frames", 1))
		var row: int = int(info.get("row", 0))
		if bool(info.get("trim_empty_tail", false)):
			frame_count = _count_non_empty_frames_grid(tex, row, frame_count, frame_w, frame_h)
		for i in range(frame_count):
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(i * frame_w, row * frame_h, frame_w, frame_h)
			frames.add_frame(anim_name, atlas)
	return frames


static func _build_vertical_sprite_frames(
	sheet_path: String, anim_vert: Dictionary, frame_w: int, frame_h: int
) -> SpriteFrames:
	var tex: Texture2D = ResourceLoader.load(sheet_path, "Texture2D")
	if tex == null:
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for anim_name in anim_vert:
		var info: Dictionary = anim_vert[anim_name]
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, bool(info.get("loop", true)))
		frames.set_animation_speed(anim_name, float(info.get("fps", 8.0)))
		var start: int = int(info.get("start", 0))
		var frame_count: int = int(info.get("frames", 1))
		for i in range(frame_count):
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(0, (start + i) * frame_h, frame_w, frame_h)
			frames.add_frame(anim_name, atlas)
	return frames


static func _count_non_empty_frames_grid(
	tex: Texture2D, row: int, max_frames: int, frame_w: int, frame_h: int
) -> int:
	var img: Image = tex.get_image()
	if img == null:
		return max_frames
	var last_non_empty := 0
	for i in range(max_frames):
		var frame_rect := Rect2i(i * frame_w, row * frame_h, frame_w, frame_h)
		if _frame_has_alpha(img, frame_rect):
			last_non_empty = i + 1
	return max(last_non_empty, 1)


static func _frame_has_alpha(img: Image, rect: Rect2i) -> bool:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if img.get_pixel(x, y).a > 0.01:
				return true
	return false
