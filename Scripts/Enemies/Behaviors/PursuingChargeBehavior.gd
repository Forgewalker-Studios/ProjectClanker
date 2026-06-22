class_name PursuingChargeBehavior
extends EnemyBehavior

## Type 02 — line-of-sight pursuit with a ground charge and attack-frame damage.

var _patrol_points: Array[Marker2D] = []
var _current_point_index: int = 0
var _has_target: bool = false


func setup(enemy: EnemyBase) -> void:
	_collect_patrol_points(enemy)
	_has_target = false


func tick_physics(enemy: EnemyBase, _delta: float) -> void:
	if enemy.is_attacking:
		enemy.velocity.x = 0.0
		return

	if _update_target_state(enemy):
		_run_chase(enemy)
		return

	_run_patrol(enemy)


func reset_behavior(enemy: EnemyBase) -> void:
	_has_target = false
	_current_point_index = 0
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


func _run_chase(enemy: EnemyBase) -> void:
	var player: Player = enemy.get_player()
	if player == null:
		enemy.velocity.x = 0.0
		return

	var direction: float = signf(player.global_position.x - enemy.global_position.x)
	if direction == 0.0:
		direction = enemy.facing_direction
	if not enemy.has_floor_ahead(direction):
		enemy.velocity.x = 0.0
		return

	enemy.face_direction(direction)
	enemy.velocity.x = direction * enemy.config.charge_speed

	if absf(player.global_position.x - enemy.global_position.x) <= 28.0:
		enemy.velocity.x = 0.0
		enemy.begin_attack_window()


func _run_patrol(enemy: EnemyBase) -> void:
	if _patrol_points.is_empty():
		enemy.velocity.x = 0.0
		return

	var target: Marker2D = _patrol_points[_current_point_index]
	var direction_to_target: float = _get_direction_to_point(enemy, target)
	if not enemy.has_floor_ahead(direction_to_target):
		enemy.velocity.x = 0.0
		_advance_patrol_index()
		return
	enemy.velocity.x = direction_to_target * enemy.config.move_speed
	enemy.face_direction(direction_to_target)

	if enemy.global_position.distance_to(target.global_position) <= 8.0:
		_advance_patrol_index()


func _collect_patrol_points(enemy: EnemyBase) -> void:
	_patrol_points.clear()
	for child: Node in enemy.patrol_points_root.get_children():
		if child is Marker2D:
			_patrol_points.append(child as Marker2D)


func _advance_patrol_index() -> void:
	_current_point_index += 1
	if _current_point_index >= _patrol_points.size():
		_current_point_index = 0


func _get_direction_to_point(enemy: EnemyBase, point: Marker2D) -> float:
	var delta_x: float = point.global_position.x - enemy.global_position.x
	if delta_x >= 0.0:
		return 1.0
	return -1.0
