class_name RoamingPatrolBehavior
extends EnemyBehavior

## Type 01 — fixed patrol between Marker2D waypoints with contact damage.

var _patrol_points: Array[Marker2D] = []
var _current_point_index: int = 0


func setup(enemy: EnemyBase) -> void:
	_collect_patrol_points(enemy)
	if _patrol_points.size() >= 2:
		_current_point_index = 0


func tick_physics(enemy: EnemyBase, _delta: float) -> void:
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


func reset_behavior(enemy: EnemyBase) -> void:
	_current_point_index = 0
	enemy.contact_hurtbox.reset_cooldown()


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
