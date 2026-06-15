extends CharacterBody2D

## Player character script: movement with acceleration and a centered camera.

const SPEED: float = 200.0
const ACCELERATION: float = 800.0
const FRICTION: float = 600.0

@onready var _camera: Camera2D = $Camera2D

func _ready() -> void:
    if _camera:
        _camera.current = true

func _physics_process(delta: float) -> void:
    _handle_input(delta)
    move_and_slide()
    if _camera:
        _camera.global_position = global_position

func _handle_input(delta: float) -> void:
    var input_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if input_vector != Vector2.ZERO:
        velocity = velocity.move_toward(input_vector * SPEED, ACCELERATION * delta)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
