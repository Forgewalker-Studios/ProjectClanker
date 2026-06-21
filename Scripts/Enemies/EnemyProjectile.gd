class_name EnemyProjectile
extends Area2D

## Straight-line projectile fired by latched enemies.

signal hit_target

## Travel speed in pixels per second.
@export var speed: float = 320.0
## Damage applied to the player on hit.
@export var damage: int = 1

var direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


## Aim the projectile and start moving.
## @param fire_direction: Normalized travel direction.
## @param travel_speed: Optional override for speed.
## @param projectile_damage: Optional override for damage.
func launch(fire_direction: Vector2, travel_speed: float, projectile_damage: int) -> void:
	if fire_direction.length_squared() <= 0.0001:
		push_error("EnemyProjectile.launch: fire_direction must be non-zero.")
		return

	direction = fire_direction.normalized()
	speed = travel_speed
	damage = projectile_damage
	rotation = direction.angle()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.call("take_damage", damage)
		hit_target.emit()
		queue_free()
		return

	if body is StaticBody2D or body is TileMapLayer:
		hit_target.emit()
		queue_free()
