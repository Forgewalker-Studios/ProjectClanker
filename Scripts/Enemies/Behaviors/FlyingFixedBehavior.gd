class_name FlyingFixedBehavior
extends EnemyBehavior

## Type 03A — hover at spawn with contact damage only.


func tick_physics(enemy: EnemyBase, _delta: float) -> void:
	enemy.velocity = Vector2.ZERO
	enemy.global_position = enemy.start_position


func reset_behavior(enemy: EnemyBase) -> void:
	enemy.contact_hurtbox.reset_cooldown()
	enemy.global_position = enemy.start_position
