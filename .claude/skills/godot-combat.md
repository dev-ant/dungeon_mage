---
name: godot-combat
description: Use when implementing any spell, combat state, hit reaction, damage number, or mana mechanic in Dungeon Mage.
---

# godot-combat

Reference patterns for MapleStory/Skul-style combat in Godot 4 using State Charts, Phantom Camera, and GUT.

## State Machine (Godot State Charts)

States and transitions for player and enemies:

```
Idle ─→ Walk ─→ Jump ─→ Fall
  └────→ Cast ────────────→ Idle
  └────→ Hit  ────────────→ Idle
  └────→ Dead (terminal)
```

Each state owns its animation name. Transition on signal, not polling:

```gdscript
# In player.gd — trigger transition by sending event to state chart
@onready var state_chart: StateChart = $StateChart

func _cast_spell(spell_id: String) -> void:
    if current_mana >= spells[spell_id].mana_cost:
        state_chart.send_event("cast")
        _execute_spell(spell_id)
```

```gdscript
# State chart node (in .tscn) — connect animation on state enter
func _on_cast_state_entered() -> void:
    $Sprite.play("cast")

func _on_cast_state_exited() -> void:
    pass  # animation auto-stops when next state plays its own
```

## Spell Types — Implementation Patterns

### Active (projectile / area burst)

```gdscript
func _execute_active_spell(spell: SpellResource) -> void:
    var proj = spell.projectile_scene.instantiate()
    proj.damage = spell.current_damage()
    proj.global_position = $SpellOrigin.global_position
    proj.direction = Vector2(sign($Sprite.scale.x), 0)
    get_parent().add_child(proj)
    current_mana -= spell.current_mana_cost()
    $CooldownTimers.get_node(spell.id).start(spell.current_cooldown())
```

### Buff (stat modifier)

```gdscript
func _execute_buff_spell(spell: SpellResource) -> void:
    active_buffs[spell.id] = {
        "stat": spell.buff_stat,
        "value": spell.buff_value,
        "timer": spell.current_duration()
    }
    current_mana -= spell.current_mana_cost()
    $CooldownTimers.get_node(spell.id).start(spell.current_cooldown())

func _process_buffs(delta: float) -> void:
    for id in active_buffs.keys():
        active_buffs[id]["timer"] -= delta
        if active_buffs[id]["timer"] <= 0:
            active_buffs.erase(id)
```

### Installation (placed object)

```gdscript
func _execute_installation_spell(spell: SpellResource) -> void:
    var install = spell.installation_scene.instantiate()
    install.global_position = $SpellOrigin.global_position
    install.lifetime = spell.current_duration()
    install.damage = spell.current_damage()
    get_parent().add_child(install)
    current_mana -= spell.current_mana_cost()
```

### On-and-Off (toggle aura)

```gdscript
var aura_active := false

func _execute_onoff_spell(spell: SpellResource) -> void:
    if aura_active:
        aura_active = false
        $AuraEffect.hide()
        $AuraArea.monitoring = false
    else:
        if current_mana < spell.current_mana_cost():
            return
        aura_active = true
        $AuraEffect.show()
        $AuraArea.monitoring = true

func _physics_process(delta: float) -> void:
    if aura_active:
        current_mana -= spell.drain_per_second * delta
        if current_mana <= 0:
            _execute_onoff_spell(spell)  # auto-disable
```

### Passive (applies at level-up only)

```gdscript
# In GameState.gd — called when a passive spell gains a level
func _apply_passive(spell_id: String, new_level: int) -> void:
    match spell_id:
        "soul_dominion":
            player_stats["spell_control_mult"] = 1.0 + (new_level * 0.04)
```

## Hit Feel

### Hitstop

```gdscript
func trigger_hitstop(duration_frames: int = 4) -> void:
    Engine.time_scale = 0.05
    await get_tree().create_timer(duration_frames / 60.0 * Engine.time_scale).timeout
    Engine.time_scale = 1.0
```

### Screen shake (Phantom Camera)

```gdscript
@onready var phantom_cam: PhantomCamera2D = $PhantomCamera2D

func trigger_shake(trauma: float = 0.3) -> void:
    phantom_cam.noise_emitted.emit(trauma)
```

### Damage numbers

```gdscript
const DamageLabel = preload("res://scenes/ui/damage_label.tscn")

func spawn_damage_number(amount: int, world_pos: Vector2) -> void:
    var lbl = DamageLabel.instantiate()
    lbl.text = str(amount)
    lbl.global_position = world_pos
    get_tree().root.add_child(lbl)
    var tween = lbl.create_tween()
    tween.tween_property(lbl, "position:y", lbl.position.y - 40, 0.6)
    tween.parallel().tween_property(lbl, "modulate:a", 0.0, 0.5)
    tween.tween_callback(lbl.queue_free)
```

## Mana System

```gdscript
var current_mana: float = 100.0
var max_mana: float = 100.0

func can_cast(spell: SpellResource) -> bool:
    return current_mana >= spell.current_mana_cost()

func _before_cast(spell: SpellResource) -> bool:
    if not can_cast(spell):
        return false
    return true
```

## Skill Mastery Data (spells.json shape)

```json
{
  "ember_dart": {
    "id": "ember_dart",
    "circle": 1,
    "school": "elemental",
    "type": "active",
    "base_damage": 12,
    "base_mana_cost": 8,
    "base_cooldown": 0.4,
    "scaling": {
      "damage_per_level": 1.08,
      "mana_cost_per_level": 0.97,
      "cooldown_per_level": 0.98
    }
  }
}
```

```gdscript
# SpellResource.gd — computed stats from level
class_name SpellResource
extends Resource

@export var id: String
@export var base_damage: float
@export var base_mana_cost: float
@export var base_cooldown: float
@export var scaling: Dictionary

func current_level() -> int:
    return GameState.skill_levels.get(id, 1)

func current_damage() -> float:
    return base_damage * pow(scaling.get("damage_per_level", 1.0), current_level() - 1)

func current_mana_cost() -> float:
    return base_mana_cost * pow(scaling.get("mana_cost_per_level", 1.0), current_level() - 1)

func current_cooldown() -> float:
    return base_cooldown * pow(scaling.get("cooldown_per_level", 1.0), current_level() - 1)
```

## GUT Test Template

```gdscript
# tests/test_spell_mastery.gd
extends GutTest

func test_ember_dart_damage_increases_per_level() -> void:
    var spell = SpellResource.new()
    spell.base_damage = 12.0
    spell.scaling = {"damage_per_level": 1.08}
    GameState.skill_levels["ember_dart"] = 1
    var lvl1 = spell.current_damage()
    GameState.skill_levels["ember_dart"] = 5
    var lvl5 = spell.current_damage()
    assert_gt(lvl5, lvl1, "Damage should increase with level")

func test_mana_blocks_cast_when_insufficient() -> void:
    var player = preload("res://scenes/player/Player.tscn").instantiate()
    add_child_autofree(player)
    player.current_mana = 0.0
    var spell = SpellResource.new()
    spell.base_mana_cost = 8.0
    assert_false(player.can_cast(spell), "Cast should be blocked with 0 mana")
```
