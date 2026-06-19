class_name Player
extends CharacterBody2D

const SPEED: float = 250.0
const GRAVITY: float = 800.0
const JUMP_VELOCITY: float = -400.0

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

## Maximum hit points before death.
@export var max_health: int = 10
## Seconds of invulnerability after taking damage.
@export var invulnerability_time: float = 1.0
## Seconds between sprite blink toggles during invulnerability.
@export var blink_interval: float = 0.1

@onready var sprite: Sprite2D = $PlayerSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var start_position: Vector2
var current_health: int
var current_state: PlayerState = PlayerState.IDLE
var facing_direction: float = 1.0
var is_invulnerable: bool = false
var is_dead: bool = false
var dialogue_movement_locked: bool = false

var _interact_target: Interactable2D = null


func _ready() -> void:
	add_to_group("player")
	start_position = global_position
	current_health = max_health
	health_changed.emit(current_health, max_health)
	_fit_sprite_to_collision()


## Scale the sprite to the collision rectangle and align it to the hitbox center.
func _fit_sprite_to_collision() -> void:
	if not collision_shape.shape is RectangleShape2D:
		return
	if sprite.texture == null:
		return

	var rect_shape: RectangleShape2D = collision_shape.shape as RectangleShape2D
	var extents: Vector2 = rect_shape.size * 0.5
	var tex_size: Vector2 = sprite.texture.get_size()
	var target_size: Vector2 = extents * 2.0

	sprite.scale = target_size / tex_size
	sprite.centered = true
	sprite.position = collision_shape.position


## Apply movement, gravity, jump, and debug health inputs.
## @param delta: Physics frame delta in seconds.
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if dialogue_movement_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		AudioDirector.play_jump()

	var direction: float = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		facing_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	sprite.flip_h = facing_direction < 0

	if Input.is_action_just_pressed("test_damage"):
		take_damage(1)
	if Input.is_action_just_pressed("test_death"):
		take_damage(max_health)
	if Input.is_action_just_pressed("test_heal"):
		heal(1)
	if Input.is_action_just_pressed("test_full_heal"):
		heal(max_health)

	if Input.is_action_just_pressed("interact"):
		_try_interact()

	if Input.is_action_just_pressed("attack"):
		AudioDirector.play_attack()

	move_and_slide()
	update_state()


## Derive the movement state from floor contact and velocity.
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


## Switch to a new player state when it changes.
## @param new_state: State to enter.
func change_state(new_state: PlayerState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	_update_state_visuals()


## Swap placeholder art for the active movement state.
func _update_state_visuals() -> void:
	match current_state:
		PlayerState.IDLE:
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/IDLE.png")
		PlayerState.MOVE:
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/MOVE.png")
		PlayerState.JUMP:
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/JUMP.png")
		PlayerState.FALL:
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/FALL.png")


## Apply damage, emit HUD signals, and start invulnerability or death.
## @param amount: Damage to subtract from current health.
func take_damage(amount: int) -> void:
	if is_dead:
		return
	if is_invulnerable:
		return

	current_health -= amount
	current_health = clampi(current_health, 0, max_health)

	health_changed.emit(current_health, max_health)
	damage_taken.emit(amount)
	AudioDirector.play_hurt()

	if current_health <= 0:
		die()
		return

	start_invulnerability()


## Blink the sprite while invulnerability is active.
func start_invulnerability() -> void:
	is_invulnerable = true

	var elapsed_time: float = 0.0

	while elapsed_time < invulnerability_time:
		sprite.visible = false
		await get_tree().create_timer(blink_interval).timeout

		sprite.visible = true
		await get_tree().create_timer(blink_interval).timeout

		elapsed_time += blink_interval * 2.0

	sprite.visible = true
	is_invulnerable = false


## Restore health and notify listeners.
## @param amount: Health to add.
func heal(amount: int) -> void:
	current_health += amount
	current_health = clampi(current_health, 0, max_health)

	health_changed.emit(current_health, max_health)
	health_healed.emit(amount)


## Play the death sequence, refill health, and respawn at the level start.
func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	player_died.emit()
	var fade_data: Dictionary = await fade_to_black()
	current_health = max_health
	health_changed.emit(current_health, max_health)
	respawn_at(start_position)
	await fade_back_in(fade_data)
	is_dead = false


## Fade the screen to black for the first half of the death sequence.
## @return: Overlay nodes used by fade_back_in.
func fade_to_black() -> Dictionary:
	await get_tree().create_timer(1.0).timeout

	var overlay: CanvasLayer = CanvasLayer.new()
	var color_rect: ColorRect = ColorRect.new()

	color_rect.color = Color.BLACK
	color_rect.modulate = Color(1, 1, 1, 0)
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(color_rect)
	get_parent().add_child(overlay)

	var tween: Tween = create_tween()
	tween.tween_property(color_rect, "modulate", Color(1, 1, 1, 1), 0.5)

	await tween.finished

	return {"overlay": overlay, "color_rect": color_rect}


## Fade the death overlay back out and free it.
## @param fade_data: Dictionary returned from fade_to_black.
func fade_back_in(fade_data: Dictionary) -> void:
	var overlay: CanvasLayer = fade_data["overlay"] as CanvasLayer
	var color_rect: ColorRect = fade_data["color_rect"] as ColorRect

	var tween: Tween = create_tween()
	tween.tween_property(color_rect, "modulate", Color(1, 1, 1, 0), 0.5)

	await tween.finished

	overlay.queue_free()


## Teleport the player and clear velocity. Emits player_left_bounds for checkpoint respawns.
## @param respawn_position: World position to move to.
func respawn_at(respawn_position: Vector2) -> void:
	global_position = respawn_position
	velocity = Vector2.ZERO
	if respawn_position != start_position:
		player_left_bounds.emit()


## Lock or unlock movement while dialogue is active.
## @param locked: True when dialogue should freeze movement.
func set_dialogue_movement_locked(locked: bool) -> void:
	dialogue_movement_locked = locked
	if locked:
		velocity = Vector2.ZERO


## Register the interactable currently in range.
## @param target: Interactable area the player entered.
func set_interact_target(target: Interactable2D) -> void:
	_interact_target = target


## Clear the interactable when the player leaves its area.
## @param target: Interactable area the player exited.
func clear_interact_target(target: Interactable2D) -> void:
	if _interact_target == target:
		_interact_target = null


## Return the active interact prompt, if any.
## @return: Prompt text or an empty string.
func get_interact_prompt() -> String:
	if _interact_target == null:
		return ""
	return _interact_target.get_prompt_text()


## Trigger interaction on the current target.
func _try_interact() -> void:
	if _interact_target == null:
		return
	_interact_target.interact(self )
