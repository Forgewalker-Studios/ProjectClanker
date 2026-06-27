class_name LatchedProjectileBehavior
extends EnemyBehavior

## Type 04 — fixed turret that fires projectiles when the player is visible.

var _cooldown_remaining_sec: float = 0.0


func tick_physics(enemy: EnemyBase, delta: float) -> void:
	enemy.velocity = Vector2.ZERO
	enemy.global_position = enemy.start_position
	enemy.face_player()

	if _cooldown_remaining_sec > 0.0:
		_cooldown_remaining_sec -= delta
		return

	if not enemy.can_see_player():
		return

	enemy.fire_projectile_at_player()
	_cooldown_remaining_sec = enemy.config.projectile_cooldown_sec


func reset_behavior(enemy: EnemyBase) -> void:
	_cooldown_remaining_sec = 0.0
	enemy.global_position = enemy.start_position
