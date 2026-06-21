class_name FlyingPursuitChargeBehavior
extends EnemyBehavior

## Type 03B — flying enemy that charges on line of sight with attack-frame damage.

var _has_target: bool = false


func tick_physics(enemy: EnemyBase, _delta: float) -> void:
	if enemy.is_attacking:
		enemy.velocity = Vector2.ZERO
		return

	if _update_target_state(enemy):
		_run_air_charge(enemy)
		return

	enemy.velocity = Vector2.ZERO
	enemy.global_position = enemy.start_position


func reset_behavior(enemy: EnemyBase) -> void:
	_has_target = false
	enemy.global_position = enemy.start_position
	enemy.contact_hurtbox.reset_cooldown()


func _update_target_state(enemy: EnemyBase) -> bool:
	if _has_target:
		var lose_range_squared: float = enemy.config.lose_target_range * enemy.config.lose_target_range
		if enemy.get_player_distance_squared() > lose_range_squared:
			_has_target = false
			return false
		return true

	if enemy.can_see_player():
		_has_target = true
		return true

	return false


func _run_air_charge(enemy: EnemyBase) -> void:
	var player: Player = enemy.get_player()
	if player == null:
		enemy.velocity = Vector2.ZERO
		return

	var to_player: Vector2 = player.global_position - enemy.global_position
	if to_player.length_squared() <= 0.0001:
		enemy.velocity = Vector2.ZERO
		return

	var direction: Vector2 = to_player.normalized()
	enemy.velocity = direction * enemy.config.charge_speed
	enemy.face_direction(direction.x)

	if to_player.length() <= 36.0:
		enemy.velocity = Vector2.ZERO
		enemy.begin_attack_window()
