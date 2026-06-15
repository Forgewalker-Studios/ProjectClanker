extends CharacterBody2D

## Player character script: movement with acceleration and a centered camera.

const SPEED: float = 200.0
const FRICTION: float = 600.0
const GRAVITY: float = 800.0
const JUMP_FORCE: float = 400.0
const COLOR_IDLE: Color = Color(1, 0, 0, 1)
const COLOR_MOVING: Color = Color(0, 1, 0, 1)
const COLOR_JUMPING: Color = Color(1, 1, 0, 1)
const COLOR_FALLING: Color = Color(1, 0, 1, 1)

@onready var _camera: Camera2D = $Camera2D
@onready var _sprite: Sprite2D = $Sprite2D

var _is_moving: bool = false
var _spawn_position: Vector2 = Vector2(512, 300)

func _ready() -> void:
	_spawn_position = global_position
	if _camera:
		_camera.make_current()

	# Create a simple placeholder texture at runtime if no texture assigned
	if _sprite and _sprite.texture == null:
		var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color(1, 1, 1, 1))
		var tex := ImageTexture.create_from_image(img)
		_sprite.texture = tex

func _physics_process(delta: float) -> void:
	if GameServices.is_paused:
		return
	# Apply gravity
	velocity.y += GRAVITY * delta
	_handle_input(delta)
	move_and_slide()
	_update_color()
	
	# Respawn if fell too far below the play area
	if global_position.y > 600:
		global_position = _spawn_position
		velocity = Vector2.ZERO
	
	if _camera:
		_camera.global_position = global_position

func _handle_input(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector.x != 0:
		velocity.x = input_vector.x * SPEED
		_is_moving = true
	else:
		velocity.x = 0
		_is_moving = false
	
	# Handle jumping
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -JUMP_FORCE

func _update_color() -> void:
	if not _sprite:
		return
	
	# Vertical movement takes priority over horizontal
	if velocity.y < 0:
		# Ascending/jumping
		_sprite.self_modulate = COLOR_JUMPING
	elif velocity.y > 0:
		# Falling
		_sprite.self_modulate = COLOR_FALLING
	elif _is_moving:
		# Moving horizontally
		_sprite.self_modulate = COLOR_MOVING
	else:
		# Idle
		_sprite.self_modulate = COLOR_IDLE
