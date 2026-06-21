class_name EnemyBehavior
extends Node

## Base class for enemy AI behaviors attached under an EnemyBase scene.


## Cache references and read inspector wiring once the enemy is ready.
## @param enemy: Owning CharacterBody2D enemy.
func setup(_enemy: EnemyBase) -> void:
	pass


## Run movement, detection, and attack logic for one physics frame.
## @param enemy: Owning CharacterBody2D enemy.
## @param delta: Physics frame delta in seconds.
func tick_physics(_enemy: EnemyBase, _delta: float) -> void:
	pass


## Reset transient behavior state when the level respawns enemies.
## @param enemy: Owning CharacterBody2D enemy.
func reset_behavior(_enemy: EnemyBase) -> void:
	pass
