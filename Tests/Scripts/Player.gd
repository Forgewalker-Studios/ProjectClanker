extends CharacterBody2D


const SPEED: float = 250.0
const GRAVITY: float = 800.00
const JUMP_VELOCITY: float = -400.0


##Provided list of player states
enum PlayerState {
	IDLE,
	MOVE,
	JUMP,
	FALL,
}

signal health_changed(current_health: int, max_health: int)
signal damage_taken(amount: int)
signal health_healed(amount: int)
signal player_died
signal player_left_bounds

@export var max_health: int = 10
@export var invulnerability_time: float = 1.0
@export var blink_interval: float = 0.1

@onready var sprite: Sprite2D = $PlayerSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var start_position: Vector2
var current_health: int
var current_state: PlayerState = PlayerState.IDLE
var facing_direction: float = 1.0
var is_invulnerable: bool = false
var is_dead: bool = false


func _ready() -> void:
	start_position = global_position
	current_health = max_health
	health_changed.emit(current_health, max_health)
	
	##Auto-scales sprite to match collision hitbox
	##Provided by Claude Haiku 4.5
	if collision_shape.shape is RectangleShape2D and sprite.texture:
		var rect_shape: RectangleShape2D = collision_shape.shape as RectangleShape2D
		var extents: Vector2 = rect_shape.extents
		var tex_size: Vector2 = sprite.texture.get_size()
		var target_size: Vector2 = extents * 2
		
		sprite.scale = target_size / tex_size
		sprite.centered = true
		##Aligns the sprite and collision shape
		sprite.position = collision_shape.position

##Establishes physics according to above values
##Includes movement rules/inputs and excludes momentum
##Includes dead/alive state
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction: float = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		facing_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Flip sprite to face left/right based on last input
	sprite.flip_h = facing_direction < 0

##Testing tools for health
	if Input.is_action_just_pressed("test_damage"):
		take_damage(1)
	if Input.is_action_just_pressed("test_death"):
		take_damage(max_health)
	if Input.is_action_just_pressed("test_heal"):
		heal(1)
	if Input.is_action_just_pressed("test_full_heal"):
		heal(max_health)

	move_and_slide()
	update_state()


##Conditions to be met to update PlayerState
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


##Changes state according to update
func change_state(new_state: PlayerState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	_update_state_visuals()


##Updates sprite visual for current state
##Provided with print to check state
func _update_state_visuals() -> void:
	match current_state:
		PlayerState.IDLE:
			print("State: Idle")
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/IDLE.png")
		PlayerState.MOVE:
			print("State: Move")
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/MOVE.png")
		PlayerState.JUMP:
			print("State: Jump")
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/JUMP.png")
		PlayerState.FALL:
			print("State: Fall")
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/FALL.png")


##
##Emits to HUD.gd to update visual display
##Tied to death and iframe mechanics
##Provided with print to check for values
func take_damage(amount: int) -> void:
	if is_dead:
		return
	if is_invulnerable:
		return

	current_health -= amount
	current_health = clampi(current_health, 0, max_health)
	
	print("Damage Taken: ", amount)
	print("Health: ", current_health, " / ", max_health)

	health_changed.emit(current_health, max_health)
	damage_taken.emit(amount)

	if current_health <= 0:
		die()

	start_invulnerability()

##Provides invulnerability when damage is taken
##Also provides blink visual to convey invulnerability
func start_invulnerability() -> void:
	is_invulnerable = true

	var elapsed_time = 0.0

	##Sets the length of animation until time set for iframes
	while elapsed_time < invulnerability_time:
		sprite.visible = false
		await get_tree().create_timer(blink_interval).timeout

		sprite.visible = true
		await get_tree().create_timer(blink_interval).timeout

		elapsed_time += blink_interval * 2.0

	sprite.visible = true
	is_invulnerable = false


##
##Emits to HUD.gd to update visual display
##Provided with print to check for values
func heal(amount: int) -> void:
	current_health += amount
	current_health = clampi(current_health, 0, max_health)
	
	print("Healed: ", amount)
	print("Health: ", current_health, " / ", max_health)

	health_changed.emit(current_health, max_health)
	health_healed.emit(amount)


##Tied to the take_damage condition
##Triggers death animation
##Resets health to full
##Emits signal and respawns at start position
func die() -> void:
	print("Player Died")
	is_dead = true
	velocity = Vector2.ZERO
	player_died.emit()
	var fade_data: Dictionary = await fade_to_black()
	current_health = max_health
	health_changed.emit(current_health, max_health)
	respawn_at(start_position)
	await fade_back_in(fade_data)
	is_dead = false


##Death animation 1/2: fade to black
##Constructed by Claude Haiku 4.5 with modifications
##Split death animation to allow respawn in between animations
func fade_to_black() -> Dictionary:
	await get_tree().create_timer(1.0).timeout

	var overlay = CanvasLayer.new()
	var color_rect = ColorRect.new()

	color_rect.color = Color.BLACK
	color_rect.modulate = Color(1, 1, 1, 0)
	color_rect.anchor_left = 0.0
	color_rect.anchor_top = 0.0
	color_rect.anchor_right = 1.0
	color_rect.anchor_bottom = 1.0
	overlay.add_child(color_rect)
	get_parent().add_child(overlay)

	var tween = create_tween()
	tween.tween_property(color_rect, "modulate", Color(1, 1, 1, 1), 0.5)

	await tween.finished

	return {"overlay": overlay, "color_rect": color_rect}

##Death animation 2/2: fade back in
func fade_back_in(fade_data: Dictionary) -> void:
	var overlay: CanvasLayer = fade_data["overlay"]
	var color_rect: ColorRect = fade_data["color_rect"]

	var tween = create_tween()
	tween.tween_property(color_rect, "modulate", Color(1, 1, 1, 0), 0.5)

	await tween.finished

	overlay.queue_free()


##Tied to out of bounds for respawning
##Neutralizes movement upon respawn
func respawn_at(respawn_position: Vector2) -> void:
	global_position = respawn_position
	velocity = Vector2.ZERO
	if respawn_position != start_position:
		player_left_bounds.emit()
