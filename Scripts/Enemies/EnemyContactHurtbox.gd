class_name EnemyContactHurtbox
extends Area2D

## Applies contact damage to the player when the enemy uses contact damage mode.

var _owner_enemy: EnemyBase
var _cooldown_remaining_sec: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if _cooldown_remaining_sec > 0.0:
		_cooldown_remaining_sec -= delta


## Bind this hurtbox to its owning enemy and config.
## @param owner_enemy: Enemy that owns this hurtbox.
func setup(owner_enemy: EnemyBase) -> void:
	_owner_enemy = owner_enemy


## Enable or disable overlap monitoring for contact damage.
## @param enabled: True when contact damage should be evaluated.
func set_monitoring_enabled(enabled: bool) -> void:
	monitoring = enabled


## Reset contact cooldown after a level reset.
func reset_cooldown() -> void:
	_cooldown_remaining_sec = 0.0


func _on_body_entered(body: Node2D) -> void:
	if _owner_enemy == null:
		return
	if _owner_enemy.is_dead:
		return
	if _owner_enemy.config.damage_mode != EnemyConfig.DamageMode.CONTACT:
		return
	if _cooldown_remaining_sec > 0.0:
		return
	if not body.is_in_group("player"):
		return
	if not body.has_method("take_damage"):
		return

	body.call("take_damage", _owner_enemy.config.contact_damage)
	_cooldown_remaining_sec = _owner_enemy.config.contact_damage_cooldown_sec
