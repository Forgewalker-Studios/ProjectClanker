class_name EnemyAttackHitbox
extends Area2D

## Applies attack-frame damage to the player during active enemy attacks.

var _owner_enemy: EnemyBase
var _hit_targets: Array[Node] = []


func _ready() -> void:
	monitoring = false
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


## Bind this hitbox to its owning enemy and config.
## @param owner_enemy: Enemy that owns this hitbox.
func setup(owner_enemy: EnemyBase) -> void:
	_owner_enemy = owner_enemy


## Enable or disable attack overlap processing.
## @param active: True during attack active frames.
func set_active(active: bool) -> void:
	if active:
		_hit_targets.clear()
	monitoring = active
	for child: Node in get_children():
		if child is CollisionShape2D:
			var shape: CollisionShape2D = child as CollisionShape2D
			shape.set_deferred("disabled", not active)


func _on_body_entered(body: Node2D) -> void:
	_try_damage_target(body)


func _on_area_entered(area: Area2D) -> void:
	_try_damage_target(area)


func _try_damage_target(target: Node) -> void:
	if _owner_enemy == null:
		return
	if not _owner_enemy.is_attacking:
		return
	if _owner_enemy.config.damage_mode != EnemyConfig.DamageMode.ATTACK_FRAMES:
		return
	if _hit_targets.has(target):
		return

	var damage_target: Node = target
	if not damage_target.has_method("take_damage"):
		var parent: Node = target.get_parent()
		if parent != null and parent.has_method("take_damage"):
			damage_target = parent
		else:
			return

	if _hit_targets.has(damage_target):
		return

	_hit_targets.append(damage_target)
	damage_target.call("take_damage", _owner_enemy.config.attack_damage)
