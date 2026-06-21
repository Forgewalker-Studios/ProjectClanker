class_name BossBehavior
extends EnemyBehavior

## Type 05 — boss that always tracks the player, alternates attacks, and defends with i-frames.

enum BossState {
	IDLE,
	CHARGE,
	SWIPE,
	DEFEND,
}

const CHARGE_RANGE: float = 180.0
const SWIPE_RANGE: float = 72.0

var _boss_state: BossState = BossState.IDLE
var _state_timer_sec: float = 0.0
var _defend_cooldown_sec: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func setup(enemy: EnemyBase) -> void:
	_rng.randomize()
	_boss_state = BossState.IDLE
	_state_timer_sec = 0.4
	_defend_cooldown_sec = enemy.config.boss_defend_interval_sec


func tick_physics(enemy: EnemyBase, delta: float) -> void:
	enemy.face_player()

	if _defend_cooldown_sec > 0.0:
		_defend_cooldown_sec -= delta

	if enemy.is_attacking:
		enemy.velocity.x = 0.0
		return

	if _boss_state == BossState.DEFEND:
		_tick_defend(enemy, delta)
		return

	if _boss_state == BossState.CHARGE:
		_tick_charge(enemy, delta)
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
	enemy.set_invulnerable(false)
	enemy.contact_hurtbox.reset_cooldown()


func _choose_next_action(enemy: EnemyBase) -> void:
	var player: Player = enemy.get_player()
	if player == null:
		enemy.velocity.x = 0.0
		_state_timer_sec = 0.5
		return

	var distance: float = enemy.global_position.distance_to(player.global_position)

	if _defend_cooldown_sec <= 0.0:
		var defend_roll: float = _rng.randf()
		if defend_roll <= enemy.config.boss_defend_chance:
			_begin_defend(enemy)
			return

	if distance > CHARGE_RANGE:
		_begin_charge(enemy)
		return

	if distance > SWIPE_RANGE:
		_begin_charge(enemy)
		return

	_begin_swipe(enemy)


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
	_boss_state = BossState.IDLE
	_state_timer_sec = 0.35
