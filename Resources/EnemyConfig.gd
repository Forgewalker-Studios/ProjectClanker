class_name EnemyConfig
extends Resource

## Inspector-tunable combat and movement values for an enemy archetype.

enum DamageMode {
	CONTACT,
	ATTACK_FRAMES,
	PROJECTILE,
}

## HUD or debug label for this enemy type.
@export var display_name: String = "Enemy"
## Maximum hit points before death.
@export var max_health: int = 3
## Ground patrol or idle move speed in pixels per second.
@export var move_speed: float = 80.0
## Charge or rush speed in pixels per second.
@export var charge_speed: float = 220.0
## How this enemy damages the player.
@export var damage_mode: DamageMode = DamageMode.CONTACT
## Damage applied on body contact when damage_mode is CONTACT.
@export var contact_damage: int = 1
## Damage applied during active attack frames when damage_mode is ATTACK_FRAMES.
@export var attack_damage: int = 1
## Seconds before the same target can take contact damage again.
@export var contact_damage_cooldown_sec: float = 0.5
## Seconds the attack hitbox stays active per attack.
@export var attack_active_time_sec: float = 0.15
## Seconds before another attack can begin.
@export var attack_recovery_time_sec: float = 0.6
## Maximum distance at which line-of-sight detection succeeds.
@export var detection_range: float = 280.0
## Distance beyond which a pursuing enemy drops its target.
@export var lose_target_range: float = 420.0
## Gravity multiplier for CharacterBody2D; use 0 for flyers.
@export var gravity_scale: float = 1.0
## Projectile scene spawned by latched enemies.
@export var projectile_scene: PackedScene
## Seconds between projectile shots.
@export var projectile_cooldown_sec: float = 2.0
## Projectile travel speed in pixels per second.
@export var projectile_speed: float = 320.0
## Seconds the boss remains invulnerable while defending.
@export var boss_defend_duration_sec: float = 1.2
## Minimum seconds between boss defend phases.
@export var boss_defend_interval_sec: float = 5.0
## Chance per attack cycle that the boss chooses defend instead of an attack.
@export var boss_defend_chance: float = 0.25
