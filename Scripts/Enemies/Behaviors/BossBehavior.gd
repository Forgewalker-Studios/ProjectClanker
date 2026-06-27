class_name BossBehavior
extends EnemyBehavior

## Type 05 — boss that always tracks the player, alternates attacks, and defends with i-frames.

enum BossState {
	IDLE,
	CHARGE,
	SWIPE,
	PROJECTILE,
	DEFEND,
}

const CHARGE_RANGE: float = 180.0
const SWIPE_RANGE: float = 72.0
const PROJECTILE_ABOVE_Y_THRESHOLD: float = 48.0
const PROJECTILE_MAX_HORIZONTAL_DISTANCE: float = 240.0

@export var starts_active: bool = false
@export_group("Projectile Burst")
@export_range(1, 12, 1) var projectile_burst_count: int = 5
@export_range(0.0, 90.0, 1.0) var projectile_arc_spread_degrees: float = 30.0
@export_range(0.0, 0.25, 0.01) var projectile_burst_interval_sec: float = 0.07
@export_range(0.0, 1.5, 0.05) var projectile_prediction_strength: float = 0.8
@export_group("Projectile Decision")
@export_range(0.0, 1.0, 0.05) var projectile_chance_when_player_above: float = 1.0
@export_range(0.0, 1.0, 0.05) var projectile_chance_when_player_level: float = 0.25

var is_active: bool = false
var _boss_state: BossState = BossState.IDLE
var _state_timer_sec: float = 0.0
var _defend_cooldown_sec: float = 0.0
var _projectile_cooldown_sec: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func setup(enemy: EnemyBase) -> void:
	_rng.randomize()
	is_active = starts_active
	_boss_state = BossState.IDLE
	_state_timer_sec = 0.4
	_defend_cooldown_sec = enemy.config.boss_defend_interval_sec
	_projectile_cooldown_sec = 0.0

	if not is_active:
		_put_boss_to_sleep(enemy)

func tick_physics(enemy: EnemyBase, delta: float) -> void:
	if not is_active:
		enemy.velocity.x = 0.0
		return

	enemy.face_player()

	if _defend_cooldown_sec > 0.0:
		_defend_cooldown_sec -= delta

	if _projectile_cooldown_sec > 0.0:
		_projectile_cooldown_sec -= delta

	if enemy.is_attacking:
		enemy.velocity.x = 0.0
		return

	if _boss_state == BossState.DEFEND:
		_tick_defend(enemy, delta)
		return

	if _boss_state == BossState.CHARGE:
		_tick_charge(enemy, delta)
		return

	if _boss_state == BossState.PROJECTILE:
		_tick_projectile_recovery(enemy, delta)
		return

	_state_timer_sec -= delta
	if _state_timer_sec > 0.0:
		enemy.velocity.x = 0.0
		return

	_choose_next_action(enemy)


func reset_behavior(enemy: EnemyBase) -> void:
	_boss_state = BossState.IDLE
	_state_timer_sec = 0.4
	_defend_cooldown_sec = enemy.config.boss_defend_interval_sec
	_projectile_cooldown_sec = 0.0
	enemy.set_invulnerable(false)
	enemy.set_defend_visual_enabled(false)
	enemy.contact_hurtbox.reset_cooldown()


func activate_boss() -> void:
	is_active = true

	var enemy: EnemyBase = get_parent() as EnemyBase
	if enemy == null:
		return

	_boss_state = BossState.IDLE
	_state_timer_sec = 0.4
	_defend_cooldown_sec = enemy.config.boss_defend_interval_sec

	_wake_boss(enemy)
	AudioDirector.enter_boss_fight()


func deactivate_boss() -> void:
	is_active = false

	var enemy: EnemyBase = get_parent() as EnemyBase
	if enemy == null:
		return

	_put_boss_to_sleep(enemy)
	AudioDirector.exit_boss_fight()


func _put_boss_to_sleep(enemy: EnemyBase) -> void:
	enemy.velocity.x = 0.0
	enemy.set_invulnerable(true)
	enemy.set_defend_visual_enabled(false)
	enemy.remove_from_group("boss")

	var contact_hurtbox: Area2D = enemy.get_node_or_null("ContactHurtbox") as Area2D
	if contact_hurtbox != null:
		contact_hurtbox.monitoring = false
		contact_hurtbox.monitorable = false

	var attack_hitbox: Area2D = enemy.get_node_or_null("AttackHitbox") as Area2D
	if attack_hitbox != null:
		attack_hitbox.monitoring = false
		attack_hitbox.monitorable = false


func _wake_boss(enemy: EnemyBase) -> void:
	enemy.add_to_group("boss")
	enemy.set_invulnerable(false)

	var contact_hurtbox: Area2D = enemy.get_node_or_null("ContactHurtbox") as Area2D
	if contact_hurtbox != null:
		contact_hurtbox.monitoring = true
		contact_hurtbox.monitorable = true

	var attack_hitbox: Area2D = enemy.get_node_or_null("AttackHitbox") as Area2D
	if attack_hitbox != null:
		attack_hitbox.monitorable = true


## Now includes anti-air capabilities.
## Chooses the boss's next action.
## Projectiles are strongly favored when the player is above the boss.
func _choose_next_action(enemy: EnemyBase) -> void:
	var player: Player = enemy.get_player()
	if player == null:
		enemy.velocity.x = 0.0
		_state_timer_sec = 0.5
		return

	if player.is_dead:
		enemy.velocity.x = 0.0
		_state_timer_sec = 0.5
		return

	var distance: float = enemy.global_position.distance_to(player.global_position)

	if _defend_cooldown_sec <= 0.0:
		var defend_roll: float = _rng.randf()
		if defend_roll <= enemy.config.boss_defend_chance:
			_begin_defend(enemy)
			return

	var is_player_above: bool = _is_player_above_boss(enemy, player)

	if is_player_above:
		if _can_use_projectile_against_above_player(enemy, player):
			var projectile_roll: float = _rng.randf()
			if projectile_roll <= projectile_chance_when_player_above:
				_begin_projectile(enemy)
				return
	else:
		if _can_use_projectile(enemy) and distance > SWIPE_RANGE and distance <= PROJECTILE_MAX_HORIZONTAL_DISTANCE:
			var projectile_roll: float = _rng.randf()
			if projectile_roll <= projectile_chance_when_player_level:
				_begin_projectile(enemy)
				return

	if distance <= SWIPE_RANGE:
		_begin_swipe(enemy)
		return

	_begin_charge(enemy)


func _is_player_above_boss(enemy: EnemyBase, player: Player) -> bool:
	var vertical_difference: float = enemy.global_position.y - player.global_position.y
	return vertical_difference >= PROJECTILE_ABOVE_Y_THRESHOLD


func _can_use_projectile(enemy: EnemyBase) -> bool:
	if _projectile_cooldown_sec > 0.0:
		return false

	if enemy.config.projectile_scene == null:
		return false

	if not enemy.can_see_player():
		return false

	return true


func _can_use_projectile_against_above_player(enemy: EnemyBase, player: Player) -> bool:
	if _projectile_cooldown_sec > 0.0:
		return false

	if enemy.config.projectile_scene == null:
		return false

	if not enemy.can_see_player():
		return false

	var vertical_difference: float = enemy.global_position.y - player.global_position.y
	var horizontal_difference: float = absf(player.global_position.x - enemy.global_position.x)

	if vertical_difference < PROJECTILE_ABOVE_Y_THRESHOLD:
		return false

	if horizontal_difference > PROJECTILE_MAX_HORIZONTAL_DISTANCE:
		return false

	return true


func _begin_projectile(enemy: EnemyBase) -> void:
	_boss_state = BossState.PROJECTILE

	_state_timer_sec = 0.15

	_projectile_cooldown_sec = enemy.config.projectile_cooldown_sec

	enemy.velocity.x = 0.0
	enemy.face_player()

	enemy.begin_projectile_attack(
		projectile_burst_count,
		projectile_arc_spread_degrees,
		projectile_burst_interval_sec,
		projectile_prediction_strength
	)


func _tick_projectile_recovery(enemy: EnemyBase, delta: float) -> void:
	enemy.velocity.x = 0.0

	_state_timer_sec -= delta
	if _state_timer_sec > 0.0:
		return

	_boss_state = BossState.IDLE
	_state_timer_sec = 0.25


func _begin_charge(enemy: EnemyBase) -> void:
	var player: Player = enemy.get_player()
	if player == null:
		return

	_boss_state = BossState.CHARGE
	_state_timer_sec = 0.8

	var direction: float = signf(player.global_position.x - enemy.global_position.x)
	if direction == 0.0:
		direction = enemy.facing_direction

	enemy.face_direction(direction)
	enemy.velocity.x = direction * enemy.config.charge_speed


func _begin_swipe(enemy: EnemyBase) -> void:
	_boss_state = BossState.SWIPE
	_state_timer_sec = enemy.config.attack_recovery_time_sec + enemy.config.attack_active_time_sec
	enemy.velocity.x = 0.0
	enemy.begin_attack_window()


func _begin_defend(enemy: EnemyBase) -> void:
	_boss_state = BossState.DEFEND
	_state_timer_sec = enemy.config.boss_defend_duration_sec
	_defend_cooldown_sec = enemy.config.boss_defend_interval_sec
	enemy.velocity.x = 0.0
	enemy.set_invulnerable(true)
	enemy.set_defend_visual_enabled(true)


func _tick_charge(enemy: EnemyBase, delta: float) -> void:
	enemy.face_player()
	_state_timer_sec -= delta
	if _state_timer_sec > 0.0:
		return

	enemy.velocity.x = 0.0
	_boss_state = BossState.IDLE
	_state_timer_sec = 0.2
	_choose_next_action(enemy)


func _tick_defend(enemy: EnemyBase, delta: float) -> void:
	enemy.velocity.x = 0.0
	_state_timer_sec -= delta
	if _state_timer_sec > 0.0:
		return

	enemy.set_invulnerable(false)
	enemy.set_defend_visual_enabled(false)
	_boss_state = BossState.IDLE
	_state_timer_sec = 0.35
