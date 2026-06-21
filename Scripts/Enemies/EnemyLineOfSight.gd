class_name EnemyLineOfSight
extends RayCast2D

## Checks whether the player is visible without environment occlusion.

var _detection_range: float = 280.0


func _ready() -> void:
	enabled = true
	collision_mask = 1
	target_position = Vector2.RIGHT * _detection_range


## Configure detection range from enemy config.
## @param detection_range: Maximum sight distance in pixels.
func setup(detection_range: float) -> void:
	_detection_range = detection_range
	target_position = Vector2.RIGHT * _detection_range


## Return whether the target position is within range and not blocked.
## @param target_global_position: World position to evaluate.
## @return: True when the target is visible.
func can_see(target_global_position: Vector2) -> bool:
	var offset: Vector2 = target_global_position - global_position
	var distance: float = offset.length()
	if distance > _detection_range:
		return false
	if distance <= 0.01:
		return true

	target_position = to_local(target_global_position)
	force_raycast_update()

	if not is_colliding():
		return true

	var collider: Object = get_collider()
	if collider == null:
		return true

	if collider is Node:
		var collider_node: Node = collider as Node
		if collider_node.is_in_group("player"):
			return true

	return false
