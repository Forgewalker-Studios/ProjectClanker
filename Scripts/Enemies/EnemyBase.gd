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
## Used for this prototype to trigger dependent functions.
@export var boss_id: StringName = &"room_03_type05_boss"
## Visual warning shown before the attack hitbox becomes active.
@export var attack_telegraph_duration_sec: float = 0.5
@export var attack_telegraph_flash_interval_sec: float = 0.2
@export var attack_telegraph_color: Color = Color(1.0, 0.85, 0.0, 1.0)
@export var attack_telegraph_pulse_scale: float = 1.1
## When true, taking damage interrupts attacks and shows the HIT state.
## Bosses can set this to false so they keep acting after being hit.
@export var uses_hit_stun_on_damage: bool = true
@export var hit_stun_duration_sec: float = 0.12
@export var hit_flash_color: Color = Color(1.0, 0.35, 0.35, 1.0)

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var contact_hurtbox: EnemyContactHurtbox = $ContactHurtbox
@onready var attack_hitbox: EnemyAttackHitbox = $AttackHitbox
@onready var line_of_sight: EnemyLineOfSight = $LineOfSight
@onready var behavior: EnemyBehavior = $Behavior
@onready var patrol_points_root: Node2D = $PatrolPoints
@onready var defend_visual: Sprite2D = get_node_or_null("DefendVisual") as Sprite2D

var start_position: Vector2
var current_health: int = 0
var current_state: EnemyState = EnemyState.IDLE
var facing_direction: float = 1.0
var is_dead: bool = false
var is_invulnerable: bool = false
var is_attacking: bool = false
var is_in_hit_stun: bool = false

var _behavior_ready: bool = false
var _attack_sequence_id: int = 0
var _sprite_base_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	add_to_group("Resettable")
	start_position = global_position
	_sprite_base_scale = sprite.scale

	if defend_visual != null:
		defend_visual.visible = false

	if is_boss and boss_id != &"room_03_type05_boss" and BossProgress.is_boss_defeated(boss_id):
		call_deferred("queue_free")
		return

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

	if not is_in_hit_stun and _behavior_ready and behavior != null:
		behavior.tick_physics(self, delta)

	move_and_slide()
	_update_facing_from_velocity()
	_update_movement_state()


## Reset enemy health, position, and behavior after player respawn.
## Also separates boss entities from reset.
func reset() -> void:
	if is_boss and boss_id != &"" and BossProgress.is_boss_defeated(boss_id):
		call_deferred("queue_free")
		return
	is_dead = false
	is_invulnerable = false
	is_attacking = false
	is_in_hit_stun = false
	_attack_sequence_id += 1
	_clear_attack_telegraph_visuals(true)
	sprite.modulate = Color.WHITE
	_restore_sprite_scale()
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
## Taking damage now also stops telegraphs or active attacks.
## Hit stun ignored by bosses.
## @param amount: Damage to subtract from current health.
func take_damage(amount: int) -> void:
	if is_dead:
		return
	if is_invulnerable:
		return

	if uses_hit_stun_on_damage:
		_interrupt_attack_sequence()

	current_health -= amount
	current_health = clampi(current_health, 0, config.max_health)

	damage_taken.emit(amount)
	health_changed.emit(current_health, config.max_health)

	if current_health <= 0:
		die()
		return

	if uses_hit_stun_on_damage:
		show_damage_feedback()
	else:
		show_damage_flash_only()


## Flash the hit sprite briefly after taking damage.
func show_damage_feedback() -> void:
	if is_dead:
		return

	is_in_hit_stun = true
	is_attacking = false
	attack_hitbox.set_active(false)
	_clear_attack_telegraph_visuals(true)

	change_state(EnemyState.HIT)
	sprite.modulate = hit_flash_color

	await get_tree().create_timer(hit_stun_duration_sec).timeout

	if is_dead:
		return

	is_in_hit_stun = false
	sprite.modulate = _get_resting_modulate()
	_update_movement_state()


## Flash the hit sprite briefly after taking damage without entering HIT.
func show_damage_flash_only() -> void:
	if is_dead:
		return

	sprite.modulate = Color(1.0, 0.35, 0.35, 1.0)

	await get_tree().create_timer(0.08).timeout

	if is_dead:
		return

	sprite.modulate = _get_resting_modulate()


## Handle enemy death, optional removal, and boss defeat signaling.
## Bosses now tied to BossProgress Autoload.
func die() -> void:
	if is_dead:
		return

	is_dead = true
	is_in_hit_stun = false
	_attack_sequence_id += 1
	_clear_attack_telegraph_visuals(true)
	_restore_sprite_scale()
	attack_hitbox.set_active(false)
	set_defend_visual_enabled(false)
	dead.emit()

	if is_boss:
		if boss_id != &"":
			BossProgress.mark_boss_defeated(boss_id)

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


## Fire this enemy's configured projectile toward the current player position.
## @return: True when a projectile was successfully fired.
## Fire this enemy's configured projectile toward the predicted player position.
## Optional angle offset allows fan/burst attacks.
## @param prediction_strength: 0.0 means aim at current position; 1.0 means fully lead based on player velocity.
## @param angle_offset_degrees: Rotates the aim direction for arc/fan spreads.
## @return: True when a projectile was successfully fired.
func fire_projectile_at_player(
	prediction_strength: float = 0.0,
	angle_offset_degrees: float = 0.0
) -> bool:
	if config == null:
		push_error("EnemyBase.fire_projectile_at_player: config is missing on %s." % name)
		return false

	if config.projectile_scene == null:
		push_error("EnemyBase.fire_projectile_at_player: projectile_scene is not assigned on %s." % name)
		return false

	var player: Player = get_player()
	if player == null:
		return false
	if player.is_dead:
		return false

	var spawn_position: Vector2 = _get_projectile_spawn_position()
	var aim_position: Vector2 = player.global_position

	if prediction_strength > 0.0:
		var safe_projectile_speed: float = maxf(config.projectile_speed, 1.0)
		var estimated_travel_time: float = spawn_position.distance_to(player.global_position) / safe_projectile_speed

		estimated_travel_time = clampf(estimated_travel_time, 0.0, 0.7)

		aim_position += player.velocity * estimated_travel_time * prediction_strength

	var to_target: Vector2 = aim_position - spawn_position

	if to_target.length_squared() <= 0.0001:
		return false

	# Angle offset creates the arc/fan spread.
	to_target = to_target.rotated(deg_to_rad(angle_offset_degrees))

	var projectile_instance: Node = config.projectile_scene.instantiate()
	if not projectile_instance is EnemyProjectile:
		push_error("EnemyBase.fire_projectile_at_player: projectile_scene must instantiate EnemyProjectile.")
		projectile_instance.queue_free()
		return false

	var projectile: EnemyProjectile = projectile_instance as EnemyProjectile

	projectile.collision_layer = 4

	if config.projectile_ignores_environment:
		projectile.collision_mask = 2
	else:
		projectile.collision_mask = 3

	get_tree().current_scene.add_child(projectile)
	projectile.global_position = spawn_position
	projectile.launch(to_target, config.projectile_speed, config.attack_damage)

	return true


## Return the projectile spawn position.
## If a child Marker2D/Node2D named ProjectileSpawn exists, use it.
## The X offset is mirrored based on facing_direction.
func _get_projectile_spawn_position() -> Vector2:
	var spawn_root: Node = get_node_or_null("ProjectileSpawn")

	if not spawn_root is Node2D:
		return global_position

	var spawn_marker: Node2D = spawn_root as Node2D
	var local_offset: Vector2 = spawn_marker.position
	local_offset.x = absf(local_offset.x) * facing_direction

	return to_global(local_offset)


## Telegraphs, then fires a predictive projectile burst instead of enabling the melee hitbox.
func begin_projectile_attack(
	burst_count: int = 1,
	arc_spread_degrees: float = 0.0,
	burst_interval_sec: float = 0.0,
	prediction_strength: float = 0.0
) -> void:
	if is_dead:
		return
	if is_attacking:
		return
	if is_in_hit_stun:
		return
	if current_state == EnemyState.HIT:
		return
	if config == null:
		return
	if config.projectile_scene == null:
		return

	is_attacking = true
	velocity.x = 0.0
	_attack_sequence_id += 1

	var sequence_id: int = _attack_sequence_id

	await _show_attack_telegraph(sequence_id)

	if _is_attack_sequence_cancelled(sequence_id):
		is_attacking = false
		_clear_attack_telegraph_visuals()
		return

	change_state(EnemyState.ATTACK)
	sprite.modulate = _get_resting_modulate()

	var shots_to_fire: int = maxi(1, burst_count)
	var interval: float = maxf(0.0, burst_interval_sec)

	for shot_index: int in range(shots_to_fire):
		if _is_attack_sequence_cancelled(sequence_id):
			is_attacking = false
			_clear_attack_telegraph_visuals()
			return

		var angle_offset: float = 0.0

		if shots_to_fire > 1:
			var shot_ratio: float = float(shot_index) / float(shots_to_fire - 1)
			angle_offset = lerpf(
				-arc_spread_degrees * 0.5,
				arc_spread_degrees * 0.5,
				shot_ratio
			)

		fire_projectile_at_player(prediction_strength, angle_offset)

		if shot_index < shots_to_fire - 1 and interval > 0.0:
			await get_tree().create_timer(interval).timeout

	await get_tree().create_timer(config.attack_recovery_time_sec).timeout

	if _is_attack_sequence_cancelled(sequence_id):
		is_attacking = false
		_clear_attack_telegraph_visuals()
		return

	is_attacking = false
	sprite.modulate = _get_resting_modulate()
	_update_movement_state()


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


## Show or hide the optional boss defend visual.
## @param enabled: True while the boss is defending.
func set_defend_visual_enabled(enabled: bool) -> void:
	if defend_visual == null:
		return

	defend_visual.visible = enabled


## Telegraphs, then activates the attack hitbox for a timed window.
func begin_attack_window() -> void:
	if is_dead:
		return
	if is_attacking:
		return
	if is_in_hit_stun:
		return
	if current_state == EnemyState.HIT:
		return

	is_attacking = true
	_attack_sequence_id += 1

	var sequence_id: int = _attack_sequence_id

	await _show_attack_telegraph(sequence_id)

	if _is_attack_sequence_cancelled(sequence_id):
		is_attacking = false
		attack_hitbox.set_active(false)
		_clear_attack_telegraph_visuals()
		return

	change_state(EnemyState.ATTACK)
	sprite.modulate = _get_resting_modulate()
	attack_hitbox.set_active(true)

	await get_tree().create_timer(config.attack_active_time_sec).timeout

	attack_hitbox.set_active(false)

	if _is_attack_sequence_cancelled(sequence_id):
		is_attacking = false
		attack_hitbox.set_active(false)
		_clear_attack_telegraph_visuals()
		return

	await get_tree().create_timer(config.attack_recovery_time_sec).timeout

	if _is_attack_sequence_cancelled(sequence_id):
		is_attacking = false
		attack_hitbox.set_active(false)
		_clear_attack_telegraph_visuals()
		return

	is_attacking = false
	sprite.modulate = _get_resting_modulate()
	_update_movement_state()


## Flashes and pulses sprite before attack window activates.
## @param sequence_id: Current attack sequence used to cancel stale timers.
func _show_attack_telegraph(sequence_id: int) -> void:
	var elapsed_time: float = 0.0
	var flash_interval: float = attack_telegraph_flash_interval_sec
	var warning_scale: Vector2 = _sprite_base_scale * attack_telegraph_pulse_scale

	if flash_interval <= 0.0:
		flash_interval = 0.01

	while elapsed_time < attack_telegraph_duration_sec:
		if _is_attack_sequence_cancelled(sequence_id):
			_clear_attack_telegraph_visuals()
			return

		sprite.modulate = attack_telegraph_color
		sprite.scale = warning_scale

		await get_tree().create_timer(flash_interval).timeout
		elapsed_time += flash_interval

		if _is_attack_sequence_cancelled(sequence_id):
			_clear_attack_telegraph_visuals()
			return

		sprite.modulate = _get_resting_modulate()
		_restore_sprite_scale()

		await get_tree().create_timer(flash_interval).timeout
		elapsed_time += flash_interval

	_restore_sprite_scale()

	if not _is_attack_sequence_cancelled(sequence_id):
		sprite.modulate = _get_resting_modulate()


## Returns whether attack sequence should stop early.
## @param sequence_id: Attack sequence to check.
## @return: True when the enemy died, reset, or started another attack sequence.
func _is_attack_sequence_cancelled(sequence_id: int) -> bool:
	if is_dead:
		return true
	if sequence_id != _attack_sequence_id:
		return true
	if current_state == EnemyState.HIT:
		return true
	if current_state == EnemyState.DOWN:
		return true

	return false


## Returns to normal color at rest.
## @return: Current non-warning sprite color.
func _get_resting_modulate() -> Color:
	if is_invulnerable:
		return Color(0.7, 0.85, 1.0, 1.0)

	return Color.WHITE


## Restore the sprite to its intended scene scale.
func _restore_sprite_scale() -> void:
	sprite.scale = _sprite_base_scale


## Clear any visual effects caused by the attack telegraph.
## @param force_modulate_restore: True when yellow must be cleared even during HIT.
func _clear_attack_telegraph_visuals(force_modulate_restore: bool = false) -> void:
	_restore_sprite_scale()

	if is_dead:
		return

	if current_state == EnemyState.HIT and not force_modulate_restore:
		return

	sprite.modulate = _get_resting_modulate()


## Interrupt any pending telegraph or active attack.
func _interrupt_attack_sequence() -> void:
	_attack_sequence_id += 1
	is_attacking = false
	attack_hitbox.set_active(false)
	_clear_attack_telegraph_visuals(true)


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
	if is_dead or is_attacking or is_in_hit_stun:
		return

	if absf(velocity.x) > 1.0:
		change_state(EnemyState.MOVE)
	else:
		change_state(EnemyState.IDLE)


func _update_contact_hurtbox_enabled() -> void:
	var contact_enabled: bool = config.damage_mode == EnemyConfig.DamageMode.CONTACT
	contact_hurtbox.set_monitoring_enabled(contact_enabled)
