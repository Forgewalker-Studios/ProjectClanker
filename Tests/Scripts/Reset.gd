extends Node2D

##Level script to reset elements under "Resettable" on respawn


@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	player.player_respawned.connect(player_died)


func player_died() -> void:
	reset_level_elements()


func reset_level_elements() -> void:
	get_tree().call_group("Resettable", "reset")


##The following is to be used for enemies:

##func reset() -> void:
	##is_dead = false
	##current_health = max_health
	##current_state = EnemyState.IDLE

	##global_position = start_position
	##velocity = Vector2.ZERO

	##visible = true
	##sprite.modulate = Color.WHITE
	##collision_shape.set_deferred("disabled", false)

	##set_process(true)
	##set_physics_process(true)

	##_update_state_visuals()
	##health_changed.emit(current_health, max_health)


##The following is to be used for pickups:

##var start_visible: bool
##@onready var collision_shape: CollisionShape2D = $CollisionShape2D

##func _ready() -> void:
	##add_to_group("Resettable")
	##start_visible = visible

##func collect() -> void:
	##visible = false
	##collision_shape.set_deferred("disabled", true)

##func reset() -> void:
	##visible = start_visible
	##collision_shape.set_deferred("disabled", false)


##The following is to be used for moving platforms:

##var start_position: Vector2

##func _ready() -> void:
	##add_to_group("Resettable")
	##start_position = global_position

##func reset() -> void:
	##global_position = start_position
	##direction = 1
	##movement_time = 0.0
