class_name Player
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
	MELEE,
	DOWN,
	DOWNFALL
}

signal health_changed(current_health: int, max_health: int)
signal damage_taken(amount: int)
signal health_healed(amount: int)

##To be implemented into a game over screen
signal player_respawned

##Likely to become a checkpoint respawn
signal player_left_bounds

##Player parameters
@export var max_health: int = 10

##iframe parameters and visuals
@export var invulnerability_time: float = .5
@export var blink_interval: float = 0.1

##Melee attack parameters
@export var melee_damage: int = 1
@export var melee_active_time: float = 0.12
@export var melee_recovery_time: float = 0.18


@onready var melee: Node2D = $Melee
@onready var hit_detection: Area2D = $Melee/HitDetection
@onready var hit_box: CollisionShape2D = $Melee/HitDetection/HitBox
@onready var melee_visual: Sprite2D = $Melee/MeleeVisual

@onready var sprite: Sprite2D = $PlayerSprite


var start_position: Vector2
var current_health: int
var current_state: PlayerState = PlayerState.IDLE
var facing_direction: float = 1.0
var is_invulnerable: bool = false
var is_attacking: bool = false
var hit_targets: Array[Node] = []
var is_dead: bool = false


func _ready() -> void:
	start_position = global_position
	current_health = max_health
	health_changed.emit(current_health, max_health)
	
	hit_detection.monitoring = false
	hit_box.disabled = true
	
	melee_visual.texture = preload("res://Art/Placeholders/PlayerStates/VFX/ATTACK.png")
	melee_visual.visible = false

	hit_detection.body_entered.connect(_on_attack_area_body_entered)
	hit_detection.area_entered.connect(_on_attack_area_area_entered)


##Establishes physics according to above values
##Includes movement rules/inputs and excludes momentum
##Includes dead/alive state
##Gravity functions during dead state and differentiates downed states
func _physics_process(delta: float) -> void:
	if is_dead:
		if not is_on_floor():
			velocity.y += GRAVITY * delta

		velocity.x = 0.0
		move_and_slide()

		if is_on_floor():
			change_state(PlayerState.DOWN)
		else:
			change_state(PlayerState.DOWNFALL)

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

	##Flip sprite to face left/right based on last input
	sprite.flip_h = facing_direction > 0
	
	if Input.is_action_just_pressed("melee_attack"):
		melee_attack()

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


##Starts a short attack window
##Turns on the attack hitbox and visual effect temporarily.
func melee_attack() -> void:
	##Prevents attacking while dead
	if is_dead:
		return

	##Prevents attack spam
	if is_attacking:
		return

	is_attacking = true
	hit_targets.clear()

	melee.scale.x = facing_direction

	change_state(PlayerState.MELEE)

	##Activates attack
	hit_detection.monitoring = true
	hit_box.set_deferred("disabled", false)
	melee_visual.visible = true

	await get_tree().physics_frame
	check_current_attack_overlaps()

	await get_tree().create_timer(melee_active_time).timeout

	##Deactivates attack
	hit_detection.monitoring = false
	hit_box.set_deferred("disabled", true)
	melee_visual.visible = false

	await get_tree().create_timer(melee_recovery_time).timeout

	##Return to default state
	is_attacking = false
	update_state()


##Registers bodies inside the hit_detection when func attack is activated
func check_current_attack_overlaps() -> void:
	var overlapping_bodies: Array[Node2D] = hit_detection.get_overlapping_bodies()
	var overlapping_areas: Array[Area2D] = hit_detection.get_overlapping_areas()

	for body: Node2D in overlapping_bodies:
		try_hit_target(body)

	for area: Area2D in overlapping_areas:
		try_hit_area(area)


##Activates when the hitbox comes into contact with a body
func _on_attack_area_body_entered(body: Node2D) -> void:
	try_hit_target(body)


##Activates when the hitbox comes into contact with an area
func _on_attack_area_area_entered(area: Area2D) -> void:
	try_hit_area(area)


##Hit detection function
##Attempts to damage an Area2D or its parent 
func try_hit_area(area: Area2D) -> void:
	if area.has_method("take_damage"):
		try_hit_target(area)
		return

	var parent: Node = area.get_parent()

	if parent == null:
		return

	try_hit_target(parent)


##Result of connected hit detection
##Damages once per hit
##Applies damage to any with the take_damage(amount: int) func
func try_hit_target(target: Node) -> void:
	if not is_attacking:
		return

	if hit_targets.has(target):
		return

	if not target.has_method("take_damage"):
		return

	hit_targets.append(target)
	target.call("take_damage", melee_damage)


##Conditions to be met to update PlayerState
func update_state() -> void:
	var new_state: PlayerState
	if is_dead:
		return
		
	if is_attacking:
		return

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
			
		PlayerState.MELEE:
			print("State: Melee Attack")
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/MELEE.png")
			
		PlayerState.DOWN:
			print("State: Downed")
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/DOWNED.png")
			
		PlayerState.DOWNFALL:
			print("State: Downed")
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/FREEFALL.png")


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
		return

	show_hit_sprite()
	start_invulnerability()


##Additional visual feedback for taking damage
##Also returns the visual to the current state
func show_hit_sprite() -> void:
	if is_dead:
		return

	sprite.texture = preload("res://Art/Placeholders/PlayerStates/HIT.png")

	await get_tree().create_timer(0.2).timeout

	if is_dead:
		return

	update_state()
	_update_state_visuals()

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
##Gravity functions during dead state
##Triggers death animation
##Resets health to full
##Emits signal and respawns at start position
func die() -> void:
	print("Player Died")
	is_dead = true
	
	velocity.x = 0.0
	
	if velocity.y < 0:
		velocity.y = 0.0
	
	if is_on_floor():
		change_state(PlayerState.DOWN)
	else:
		change_state(PlayerState.DOWNFALL)
	
	var fade_data: Dictionary = await fade_to_black()
	
	current_health = max_health
	health_changed.emit(current_health, max_health)
	
	respawn_at(start_position)
	
	player_respawned.emit()
	
	is_dead = false
		
	current_state = PlayerState.IDLE
	_update_state_visuals()
	
	await fade_back_in(fade_data)


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


##Deactivates the OutOfBounds.gd if in the dead state
func can_trigger_out_of_bounds() -> bool:
	return not is_dead \
		and current_state != PlayerState.DOWN \
		and current_state != PlayerState.DOWNFALL


##Tied to out of bounds for respawning
##Neutralizes movement upon respawn
func respawn_at(respawn_position: Vector2) -> void:
	global_position = respawn_position
	velocity = Vector2.ZERO
	if respawn_position != start_position:
		player_left_bounds.emit()
