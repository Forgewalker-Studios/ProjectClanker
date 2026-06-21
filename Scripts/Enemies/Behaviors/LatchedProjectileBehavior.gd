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

	_fire_projectile(enemy)
	_cooldown_remaining_sec = enemy.config.projectile_cooldown_sec


func reset_behavior(enemy: EnemyBase) -> void:
	_cooldown_remaining_sec = 0.0
	enemy.global_position = enemy.start_position


func _fire_projectile(enemy: EnemyBase) -> void:
	if enemy.config.projectile_scene == null:
		push_error("LatchedProjectileBehavior: projectile_scene is not assigned on %s." % enemy.name)
		return

	var player: Player = enemy.get_player()
	if player == null:
		return

	var spawn_root: Node = enemy.get_node_or_null("ProjectileSpawn")
	var spawn_position: Vector2 = enemy.global_position
	if spawn_root is Node2D:
		spawn_position = (spawn_root as Node2D).global_position

	var to_player: Vector2 = player.global_position - spawn_position
	if to_player.length_squared() <= 0.0001:
		return

	var projectile_instance: Node = enemy.config.projectile_scene.instantiate()
	if not projectile_instance is EnemyProjectile:
		push_error("LatchedProjectileBehavior: projectile_scene must instantiate EnemyProjectile.")
		projectile_instance.queue_free()
		return

	var projectile: EnemyProjectile = projectile_instance as EnemyProjectile
	enemy.get_tree().current_scene.add_child(projectile)
	projectile.global_position = spawn_position
	projectile.launch(to_player, enemy.config.projectile_speed, enemy.config.attack_damage)
