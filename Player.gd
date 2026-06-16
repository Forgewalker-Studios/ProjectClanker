extends CharacterBody2D


const SPEED: float = 200.0
const GRAVITY: float = 800.00
const JUMP_VELOCITY: float = -400.0


##Provided List of Current Player Actions
enum PlayerState {
	IDLE,
	MOVE,
	JUMP,
	FALL
}

var current_state: PlayerState = PlayerState.IDLE
var start_position: Vector2


func _ready() -> void:
	start_position = global_position


## Establishes Physics according to Above Values
## Includes Movement Rules, and Excludes Momentum
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction: float = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_state()


##Conditions to Update State
func update_state() -> void:
	var new_state: PlayerState

	if not is_on_floor():
		if velocity.y < 0:
			new_state = PlayerState.JUMP
		else:
			new_state = PlayerState.FALL
	else:
		if velocity.x != 0:
			new_state = PlayerState.MOVE
		else:
			new_state = PlayerState.IDLE

	change_state(new_state)


##Changes State according to Update
func change_state(new_state: PlayerState) -> void:
	if current_state == new_state:
		return

	current_state = new_state

	match current_state:
		PlayerState.IDLE:
			print("State: Idle")
		PlayerState.MOVE:
			print("State: Move")
		PlayerState.JUMP:
			print("State: Jump")
		PlayerState.FALL:
			print("State: Fall")

##Tied to Out of Bounds for Respawning
##Neutralizes Movement upon Respawn
func respawn_at(respawn_position: Vector2) -> void:
	global_position = respawn_position
	velocity = Vector2.ZERO
