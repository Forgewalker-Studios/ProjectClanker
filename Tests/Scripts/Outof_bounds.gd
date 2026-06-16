extends Area2D


@export var spawn_point: Marker2D

##Area2D tied to Respawn
func _ready() -> void:
	body_entered.connect(_on_body_entered)


##Entry of Player to Area2D moves Player to Spawn
##Specifically tied to Character2DBody and Player Layer
func _on_body_entered(body: CharacterBody2D) -> void:
	if body.has_method("respawn_at") and spawn_point != null:
		body.respawn_at(spawn_point.global_position)
