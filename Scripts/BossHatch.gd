extends StaticBody2D

## Hatch present while boss is undefeated, and opens upon defeat.

## Boss designated to be tied to the hatch.
@export var boss_id: StringName = &"room_03_type05_boss"
@export var boss_mob: NodePath
@export var remove_completely: bool = true
@export var fade_duration: float = 1.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


## BossProgress.gd keeps the hatch open once this boss is registered.
## Expects EnemyBase with boss_defeated signal to activate.
func _ready() -> void:
	if BossProgress.is_boss_defeated(boss_id):
		call_deferred("open_hatch", false)
		return

	var boss: EnemyBase = get_node_or_null(boss_mob) as EnemyBase

	if not boss.boss_defeated.is_connected(_on_boss_defeated):
		boss.boss_defeated.connect(_on_boss_defeated, CONNECT_ONE_SHOT)


## Registers the boss into BossProgress.gd through mark_boss_defeated, then runs open_hatch.
func _on_boss_defeated() -> void:
	BossProgress.mark_boss_defeated(boss_id)
	open_hatch()


## Disables collision and sprite, "opening" the hatch.
## Also sets layer to 0 to not collide with anything.
func open_hatch(animate: bool = true) -> void:
	collision_shape.set_deferred("disabled", true)
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)

	if animate:
		var tween: Tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, fade_duration)
		await tween.finished
	else:
		sprite.modulate.a = 0.0

	sprite.visible = false

	if remove_completely:
		call_deferred("queue_free")
