extends Node2D

##Level script to reset elements under "Resettable" on respawn


@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	player.player_respawned.connect(player_died)


func player_died() -> void:
	reset_level_elements()


func reset_level_elements() -> void:
	get_tree().call_group("Resettable", "reset")
