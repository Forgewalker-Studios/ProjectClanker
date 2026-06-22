extends StaticBody2D

@export var enemy_mob: NodePath

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	var enemy: Node = get_node(enemy_mob)

	if enemy.has_signal("destroyed"):
		enemy.destroyed.connect(_on_enemy_destroyed)


func _on_enemy_destroyed() -> void:
	disappear()


func disappear() -> void:
	sprite.visible = false
	collision_shape.set_deferred("disabled", true)
