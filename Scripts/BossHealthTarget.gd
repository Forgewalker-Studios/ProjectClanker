class_name BossHealthTarget
extends Node2D

## Minimal boss health source for HUD and boss music testing.

signal health_changed(current_health: int, max_health: int)
signal boss_defeated

## Display name shown on the boss health bar.
@export var display_name: String = "Boss"
## Maximum boss hit points.
@export var max_health: int = 20
## Seconds between automatic demo damage ticks (0 disables).
@export var demo_damage_interval_sec: float = 0.0
## Damage dealt per demo tick.
@export var demo_damage_amount: int = 1

var current_health: int = 0

var _demo_timer: Timer


func _ready() -> void:
	add_to_group("boss")
	current_health = max_health
	health_changed.emit(current_health, max_health)
	AudioDirector.enter_boss_fight()
	_setup_demo_timer()


func _exit_tree() -> void:
	AudioDirector.exit_boss_fight()


## Apply damage to the boss and notify listeners.
## @param amount: Damage to subtract.
func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	current_health = maxi(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		boss_defeated.emit()


func _setup_demo_timer() -> void:
	if demo_damage_interval_sec <= 0.0:
		return
	_demo_timer = Timer.new()
	_demo_timer.wait_time = demo_damage_interval_sec
	_demo_timer.autostart = true
	add_child(_demo_timer)
	_demo_timer.timeout.connect(_on_demo_timer_timeout)


func _on_demo_timer_timeout() -> void:
	take_damage(demo_damage_amount)
