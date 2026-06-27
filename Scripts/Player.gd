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
	MELEE,
	DOWN,
	DOWNFALL
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
## Damage points inflicted with melee attack.
@export var melee_damage: int = 1
## Seconds of the melee hitbox being active.
@export var melee_active_time: float = 0.12
## Seconds until another melee attack can be executed.
@export var melee_recovery_time: float = 0.18

@onready var sprite: Sprite2D = $PlayerSprite
@onready var melee: Node2D = $Melee
@onready var hit_detection: Area2D = $Melee/HitDetection
@onready var hit_box: CollisionShape2D = $Melee/HitDetection/HitBox
@onready var melee_visual: Sprite2D = $Melee/MeleeVisual

var start_position: Vector2
var current_health: int
var death_respawn_override: Marker2D = null
var current_state: PlayerState = PlayerState.IDLE
var facing_direction: float = 1.0
var is_invulnerable: bool = false
var is_attacking: bool = false
var hit_targets: Array[Node] = []
var is_dead: bool = false
var dialogue_movement_locked: bool = false
var _interact_release_required: bool = false

var _interact_target: Interactable2D = null


func _ready() -> void:
	add_to_group("player")
	_apply_scene_spawn()
	start_position = global_position
	PlayerStats.setup_health(max_health)
	_sync_health_from_stats()
	health_changed.emit(current_health, max_health)

	hit_detection.monitoring = false
	hit_box.disabled = true

	melee_visual.texture = preload("res://Art/Placeholders/PlayerStates/VFX/ATTACK.png")
	melee_visual.visible = false

	hit_detection.body_entered.connect(_on_attack_area_body_entered)
	hit_detection.area_entered.connect(_on_attack_area_area_entered)


## Spawn according to designated Marker2D using ScenePortal.gd
func _apply_scene_spawn() -> void:
	var spawn_name: StringName = SceneSpawn.consume_spawn_name()
	var current_scene: Node = get_tree().current_scene

	if current_scene == null:
		return

	var spawn_point: Node2D = current_scene.find_child(str(spawn_name), true, false) as Node2D

	if spawn_point == null:
		push_warning("Player: Could not find spawn point named '%s' in scene '%s'." % [spawn_name, current_scene.name])
		return

	global_position = spawn_point.global_position


## Apply stored HP data to current scene
func _sync_health_from_stats() -> void:
	max_health = PlayerStats.max_health
	current_health = PlayerStats.current_health


## Apply movement, gravity, jump, attack, and debug health inputs.
## @param delta: Physics frame delta in seconds.
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

	sprite.flip_h = facing_direction > 0

	if Input.is_action_just_pressed("melee_attack"):
		melee_attack()

	if Input.is_action_just_pressed("test_damage"):
		take_damage(1)
	if Input.is_action_just_pressed("test_death"):
		take_damage(max_health)
	if Input.is_action_just_pressed("test_heal"):
		heal(1)
	if Input.is_action_just_pressed("test_full_heal"):
		heal(max_health)

	if _should_trigger_interaction():
		_try_interact()

	if Input.is_action_just_pressed("melee_attack"):
		AudioDirector.play_attack()

	move_and_slide()
	update_state()


## Starts a short attack window.
## Prevented during attack or while dead.
## Activates hitbox according to hit detection.
func melee_attack() -> void:
	if is_dead:
		return

	if is_attacking:
		return

	is_attacking = true
	hit_targets.clear()

	melee.scale.x = facing_direction

	change_state(PlayerState.MELEE)

	hit_detection.monitoring = true
	hit_box.set_deferred("disabled", false)
	melee_visual.visible = true

	await get_tree().physics_frame
	check_current_attack_overlaps()

	await get_tree().create_timer(melee_active_time).timeout

	hit_detection.monitoring = false
	hit_box.set_deferred("disabled", true)
	melee_visual.visible = false

	await get_tree().create_timer(melee_recovery_time).timeout

	is_attacking = false
	update_state()


## Registers overlap with hit detection when attack is activated.
func check_current_attack_overlaps() -> void:
	var overlapping_bodies: Array[Node2D] = hit_detection.get_overlapping_bodies()
	var overlapping_areas: Array[Area2D] = hit_detection.get_overlapping_areas()

	for body: Node2D in overlapping_bodies:
		try_hit_target(body)

	for area: Area2D in overlapping_areas:
		try_hit_area(area)


func _on_attack_area_body_entered(body: Node2D) -> void:
	try_hit_target(body)


func _on_attack_area_area_entered(area: Area2D) -> void:
	try_hit_area(area)


## Hit detection for area.
func try_hit_area(area: Area2D) -> void:
	if area.has_method("take_damage"):
		try_hit_target(area)
		return

	var parent: Node = area.get_parent()

	if parent == null:
		return

	try_hit_target(parent)

 ## Hit detection for target.
func try_hit_target(target: Node) -> void:
	if not is_attacking:
		return

	if hit_targets.has(target):
		return

	if not target.has_method("take_damage"):
		return

	hit_targets.append(target)
	target.call("take_damage", melee_damage)


## Derive the movement state from floor contact and velocity.
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
		PlayerState.MELEE:
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/ATTACK.png")
		PlayerState.DOWN:
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/DOWNED.png")
		PlayerState.DOWNFALL:
			sprite.texture = preload("res://Art/Placeholders/PlayerStates/FREEFALL.png")


## Apply damage, emit HUD signals, and start invulnerability or death.
## @param amount: Damage to subtract from current health.
func take_damage(amount: int) -> void:
	if is_dead:
		return
	if is_invulnerable:
		return

	PlayerStats.take_damage(amount)
	_sync_health_from_stats()

	health_changed.emit(current_health, max_health)
	damage_taken.emit(amount)
	AudioDirector.play_hurt()

	if current_health <= 0:
		die()
		return

	show_hit_sprite()
	start_invulnerability()


## Visual feedback when damage is taken
func show_hit_sprite() -> void:
	if is_dead:
		return

	sprite.texture = preload("res://Art/Placeholders/PlayerStates/HIT.png")

	await get_tree().create_timer(0.2).timeout

	if is_dead:
		return

	update_state()
	_update_state_visuals()


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
	PlayerStats.heal(amount)
	_sync_health_from_stats()

	health_changed.emit(current_health, max_health)
	health_healed.emit(amount)


## Play the death sequence, refill health, and respawn at the level start.
func die() -> void:
	is_dead = true
	velocity.x = 0.0
	if velocity.y < 0:
		velocity.y = 0.0
	if is_on_floor():
		change_state(PlayerState.DOWN)
	else:
		change_state(PlayerState.DOWNFALL)
	var fade_data: Dictionary = await fade_to_black()
	PlayerStats.refill_health()
	_sync_health_from_stats()
	health_changed.emit(current_health, max_health)
	var respawn_position: Vector2 = _get_death_respawn_position()
	respawn_at(respawn_position)
	player_died.emit()
	is_dead = false
	current_state = PlayerState.IDLE
	_update_state_visuals()
	await fade_back_in(fade_data)


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


##Deactivates the OutOfBounds.gd if in the dead state
func can_trigger_out_of_bounds() -> bool:
	return not is_dead \
		and current_state != PlayerState.DOWN \
		and current_state != PlayerState.DOWNFALL


## Teleport the player and clear velocity. Emits player_left_bounds for checkpoint respawns.
## @param respawn_position: World position to move to.
func respawn_at(respawn_position: Vector2) -> void:
	global_position = respawn_position
	velocity = Vector2.ZERO
	if respawn_position != start_position:
		player_left_bounds.emit()


func set_death_respawn_override(marker: Marker2D) -> void:
	death_respawn_override = marker


func clear_death_respawn_override() -> void:
	death_respawn_override = null


func _get_death_respawn_position() -> Vector2:
	if death_respawn_override != null and is_instance_valid(death_respawn_override):
		return death_respawn_override.global_position

	return start_position


## Lock or unlock movement while dialogue is active.
## @param locked: True when dialogue should freeze movement.
func set_dialogue_movement_locked(locked: bool) -> void:
	var was_locked: bool = dialogue_movement_locked
	dialogue_movement_locked = locked
	if locked:
		velocity = Vector2.ZERO
	elif was_locked:
		_interact_release_required = true


## Consume the dialogue-closing interact until the player releases the key.
## @return: True only for a fresh interact press after any release latch clears.
func _should_trigger_interaction() -> bool:
	if _interact_release_required:
		if not Input.is_action_pressed("interact"):
			_interact_release_required = false
		return false
	return Input.is_action_just_pressed("interact")


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
