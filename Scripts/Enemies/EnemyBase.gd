class_name EnemyBase
extends CharacterBody2D

## Shared enemy health, damage reception, reset, and behavior delegation.

const GRAVITY: float = 800.0
const FLOOR_LOOKAHEAD_DISTANCE: float = 28.0
const FLOOR_PROBE_DEPTH: float = 64.0
const ENVIRONMENT_COLLISION_MASK: int = 1

enum EnemyState {
	IDLE,
	MOVE,
	ATTACK,
	HIT,
	DOWN,
}

signal health_changed(current_health: int, max_health: int)
signal damage_taken(amount: int)
signal dead
signal boss_defeated

## Inspector-authored combat and movement values for this instance.
@export var config: EnemyConfig
## When true, the enemy is removed after death instead of staying downed.
@export var destroy_on_death: bool = false
## When true, the enemy stays visible but stops processing after death.
@export var disable_on_death: bool = false
## When true, registers with the boss group and boss music on spawn.
@export var is_boss: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var contact_hurtbox: EnemyContactHurtbox = $ContactHurtbox
@onready var attack_hitbox: EnemyAttackHitbox = $AttackHitbox
@onready var line_of_sight: EnemyLineOfSight = $LineOfSight
@onready var behavior: EnemyBehavior = $Behavior
@onready var patrol_points_root: Node2D = $PatrolPoints

var start_position: Vector2
var current_health: int = 0
var current_state: EnemyState = EnemyState.IDLE
var facing_direction: float = 1.0
var is_dead: bool = false
var is_invulnerable: bool = false
var is_attacking: bool = false

var _behavior_ready: bool = false


func _ready() -> void:
	add_to_group("Resettable")
	start_position = global_position

	if config == null:
		push_error("EnemyBase._ready: config is required on %s." % name)
		return

	current_health = config.max_health
	health_changed.emit(current_health, config.max_health)

	contact_hurtbox.setup(self)
	attack_hitbox.setup(self)
	line_of_sight.setup(config.detection_range)

	if is_boss:
		add_to_group("boss")
		AudioDirector.enter_boss_fight()

	if behavior != null:
		behavior.setup(self)
		_behavior_ready = true

	_update_contact_hurtbox_enabled()
	_update_state_visuals()


func _exit_tree() -> void:
	if is_boss:
		AudioDirector.exit_boss_fight()


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if config.gravity_scale > 0.0:
		if not is_on_floor():
			velocity.y += GRAVITY * config.gravity_scale * delta
	else:
		velocity.y = 0.0

	if _behavior_ready and behavior != null:
		behavior.tick_physics(self, delta)

	move_and_slide()
	_update_facing_from_velocity()
	_update_movement_state()


## Reset enemy health, position, and behavior after player respawn.
func reset() -> void:
	is_dead = false
	is_invulnerable = false
	is_attacking = false
	current_state = EnemyState.IDLE

	if config != null:
		current_health = config.max_health

	global_position = start_position
	velocity = Vector2.ZERO

	visible = true
	sprite.modulate = Color.WHITE
	collision_shape.set_deferred("disabled", false)
	attack_hitbox.set_active(false)

	set_process(true)
	set_physics_process(true)

	if _behavior_ready and behavior != null:
		behavior.reset_behavior(self)

	_update_contact_hurtbox_enabled()
	_update_state_visuals()
	health_changed.emit(current_health, config.max_health)


## Apply damage unless dead or invulnerable.
## @param amount: Damage to subtract from current health.
func take_damage(amount: int) -> void:
	if is_dead:
		return
	if is_invulnerable:
		return

	current_health -= amount
	current_health = clampi(current_health, 0, config.max_health)

	damage_taken.emit(amount)
	health_changed.emit(current_health, config.max_health)

	if current_health <= 0:
		die()
		return

	show_damage_feedback()


## Flash the hit sprite briefly after taking damage.
func show_damage_feedback() -> void:
	if is_dead:
		return

	change_state(EnemyState.HIT)
	sprite.modulate = Color(1.0, 0.35, 0.35, 1.0)

	await get_tree().create_timer(0.12).timeout

	if is_dead:
		return

	sprite.modulate = Color.WHITE
	_update_movement_state()


## Handle enemy death, optional removal, and boss defeat signaling.
func die() -> void:
	if is_dead:
		return

	is_dead = true
	attack_hitbox.set_active(false)
	dead.emit()

	if is_boss:
		boss_defeated.emit()

	change_state(EnemyState.DOWN)
	sprite.modulate = Color.WHITE
	collision_shape.set_deferred("disabled", true)
	set_process(false)
	set_physics_process(false)

	if destroy_on_death:
		await get_tree().create_timer(0.5).timeout
		queue_free()
		return

	if disable_on_death:
		disable_enemy()


## Stop processing while leaving the body in the scene.
func disable_enemy() -> void:
	collision_shape.set_deferred("disabled", true)
	set_process(false)
	set_physics_process(false)


## Return the first player node in the scene tree.
## @return: Player node or null when absent.
func get_player() -> Player:
	var player_node: Node = get_tree().get_first_node_in_group("player")
	if player_node == null:
		return null
	return player_node as Player


## Return whether the player is within range and not blocked by geometry.
## @return: True when line of sight is clear.
func can_see_player() -> bool:
	var player: Player = get_player()
	if player == null:
		return false
	if player.is_dead:
		return false
	return line_of_sight.can_see(player.global_position)


## Return squared distance to the player for range checks.
## @return: Squared distance, or INF when no player exists.
func get_player_distance_squared() -> float:
	var player: Player = get_player()
	if player == null:
		return INF
	return global_position.distance_squared_to(player.global_position)


## Return whether environment collision exists ahead of grounded horizontal movement.
## @param direction: Horizontal movement direction.
## @return: True while airborne or when the floor continues ahead.
func has_floor_ahead(direction: float) -> bool:
	if direction == 0.0 or not is_on_floor():
		return true

	var probe_start: Vector2 = global_position + Vector2(
		signf(direction) * FLOOR_LOOKAHEAD_DISTANCE,
		0.0
	)
	var probe_end: Vector2 = probe_start + Vector2.DOWN * FLOOR_PROBE_DEPTH
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		probe_start,
		probe_end,
		ENVIRONMENT_COLLISION_MASK,
		[get_rid()]
	)
	var hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	return not hit.is_empty()


## Flip the sprite to face the given horizontal direction.
## @param direction: -1 for left, 1 for right.
func face_direction(direction: float) -> void:
	if direction == 0.0:
		return
	facing_direction = signf(direction)
	sprite.flip_h = facing_direction > 0.0


## Face the current player position when one exists.
func face_player() -> void:
	var player: Player = get_player()
	if player == null:
		return
	var direction: float = player.global_position.x - global_position.x
	face_direction(direction)


## Enable or disable temporary invulnerability for boss defend phases.
## @param enabled: True while damage should be ignored.
func set_invulnerable(enabled: bool) -> void:
	is_invulnerable = enabled
	if enabled:
		sprite.modulate = Color(0.7, 0.85, 1.0, 1.0)
	else:
		sprite.modulate = Color.WHITE


## Activate the attack hitbox for a timed window.
func begin_attack_window() -> void:
	if is_dead:
		return
	if is_attacking:
		return

	is_attacking = true
	change_state(EnemyState.ATTACK)
	attack_hitbox.set_active(true)

	await get_tree().create_timer(config.attack_active_time_sec).timeout

	attack_hitbox.set_active(false)

	await get_tree().create_timer(config.attack_recovery_time_sec).timeout

	is_attacking = false
	_update_movement_state()


## Switch enemy animation state when it changes.
## @param new_state: State to enter.
func change_state(new_state: EnemyState) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	_update_state_visuals()


## Swap placeholder textures for the active state.
func _update_state_visuals() -> void:
	match current_state:
		EnemyState.IDLE:
			sprite.texture = preload("res://Art/Placeholders/EnemyStates/IDLE.png")
		EnemyState.MOVE:
			sprite.texture = preload("res://Art/Placeholders/EnemyStates/MOVE.png")
		EnemyState.ATTACK:
			sprite.texture = preload("res://Art/Placeholders/EnemyStates/ATTACK.png")
		EnemyState.HIT:
			sprite.texture = preload("res://Art/Placeholders/EnemyStates/HIT.png")
		EnemyState.DOWN:
			sprite.texture = preload("res://Art/Placeholders/EnemyStates/DOWNED.png")


func _update_facing_from_velocity() -> void:
	if absf(velocity.x) > 1.0:
		face_direction(velocity.x)


func _update_movement_state() -> void:
	if is_dead or is_attacking:
		return

	if absf(velocity.x) > 1.0:
		change_state(EnemyState.MOVE)
	else:
		change_state(EnemyState.IDLE)


func _update_contact_hurtbox_enabled() -> void:
	var contact_enabled: bool = config.damage_mode == EnemyConfig.DamageMode.CONTACT
	contact_hurtbox.set_monitoring_enabled(contact_enabled)
