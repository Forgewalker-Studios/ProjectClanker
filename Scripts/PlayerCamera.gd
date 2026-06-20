extends Camera2D


##Separated from Player in order to expand features

@export var player: CharacterBody2D
@export var follow_speed: float = 10.0


func _ready() -> void:
	make_current()


func _physics_process(delta: float) -> void:
	if player == null:
		return

	if player.current_state == player.PlayerState.DOWNFALL:
		return

	global_position = global_position.lerp(
		player.global_position,
		1.0 - exp(-follow_speed * delta)
	)
