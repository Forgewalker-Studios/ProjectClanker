extends StaticBody2D

@export var boss_mob: NodePath

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	var boss: EnemyBase = get_node(boss_mob) as EnemyBase

	if boss == null:
		push_error("BossHatch: boss_mob path does not point to an EnemyBase.")
		return

	boss.boss_defeated.connect(_on_boss_defeated)


func _on_boss_defeated() -> void:
	open_hatch()


func open_hatch() -> void:
	sprite.visible = false
	collision_shape.set_deferred("disabled", true)
