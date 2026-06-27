extends Node

## The player's Max HP.
var max_health: int = 10
## The player's current HP.
var current_health: int = 10
## Determines whether HP has been setup yet.
var initialized: bool = false


## First-time setup, and prevents healing between scenes.
func setup_health(default_max_health: int) -> void:
	if not initialized:
		max_health = default_max_health
		current_health = max_health
		initialized = true
		return

	max_health = default_max_health
	current_health = clampi(current_health, 0, max_health)


## Tied to Player.gd of the same func name.
func take_damage(amount: int) -> void:
	current_health = clampi(current_health - amount, 0, max_health)


## Tied to Player.gd of the same func name.
func heal(amount: int) -> void:
	current_health = clampi(current_health + amount, 0, max_health)


## Tied to Player.gd func die to reset HP on death.
func refill_health() -> void:
	current_health = max_health


func reset_for_new_game(default_max_health: int = 10) -> void:
	max_health = default_max_health
	current_health = max_health
	initialized = true
	
