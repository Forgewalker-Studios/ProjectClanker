extends Area2D


@export var spawn_point: Marker2D

##Does not function as an environmental hazard
##Purpose of OutOfBounds.gd is to not penalize the player
##when found in restricted areas

##Area2D tied to respawn
func _ready() -> void:
	body_entered.connect(_on_body_entered)


##Entry of player to Area2D moves player to spawn
##Specifically tied to Character2DBody and player layer
func _on_body_entered(body: CharacterBody2D) -> void:
	if body.has_method("respawn_at") and spawn_point != null:
		print("Out of Bounds: Respawn at Checkpoint")
		body.respawn_at(spawn_point.global_position)
