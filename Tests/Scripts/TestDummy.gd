class_name TestDummy
extends CharacterBody2D


enum EnemyState {
	IDLE,
	DOWN
}

signal health_changed(current_health: int, max_health: int)
signal damage_taken(amount: int)
signal dead


@export var max_health: int = 3

##Two available functions to determine visuals after death
##Reverse statements to run either function
@export var destroy_on_death: bool = false
@export var disable_on_death: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var start_position: Vector2
var current_health: int
var current_state: EnemyState = EnemyState.IDLE
var is_dead: bool = false


##
func _ready() -> void:
	add_to_group("Resettable")
	start_position = global_position

	current_health = max_health
	health_changed.emit(current_health, max_health)


##Built-in to reset when player respawns
func reset() -> void:
	is_dead = false
	current_health = max_health
	current_state = EnemyState.IDLE

	global_position = start_position
	velocity = Vector2.ZERO

	visible = true
	sprite.modulate = Color.WHITE
	collision_shape.set_deferred("disabled", false)

	set_process(true)
	set_physics_process(true)

	_update_state_visuals()
	health_changed.emit(current_health, max_health)


##Conditions to be met to update EnemyState
##For now prevents changing states when dead
func update_state() -> void:
	if is_dead:
		return

	change_state(EnemyState.IDLE)


##Changes state according to update
func change_state(new_state: EnemyState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	_update_state_visuals()


##Updates sprite visual for current state
##Provided with print to check state
func _update_state_visuals() -> void:
	match current_state:
		EnemyState.IDLE:
			print("Enemy State: Idle")
			sprite.texture = preload("res://Art/Placeholders/EnemyStates/IDLE.png")

		EnemyState.DOWN:
			print("Enemy State: Down")
			sprite.texture = preload("res://Art/Placeholders/EnemyStates/DOWNED.png")


##Provided with print to check for values
func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_health -= amount
	current_health = clampi(current_health, 0, max_health)

	print("Enemy Took Damage: ", amount)
	print("Enemy Health: ", current_health, " / ", max_health)

	damage_taken.emit(amount)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		die()

	show_damage_feedback()


##Constructed using show_hit_sprite
func show_damage_feedback() -> void:
	if is_dead:
		return

	sprite.texture = preload("res://Art/Placeholders/EnemyStates/HIT.png")
	sprite.modulate = Color(1, 0.35, 0.35, 1)

	await get_tree().create_timer(0.12).timeout

	if is_dead:
		return

	sprite.modulate = Color.WHITE
	_update_state_visuals()


##Default death that removes the body from the scene
func die() -> void:
	if is_dead:
		return

	is_dead = true
	dead.emit()

	print("Enemy Destroyed")

	current_state = EnemyState.DOWN
	sprite.modulate = Color.WHITE
	_update_state_visuals()

	collision_shape.set_deferred("disabled", true)
	set_process(false)
	set_physics_process(false)

	if destroy_on_death:
		await get_tree().create_timer(0.5).timeout
		queue_free()

	if disable_on_death:
		disable_enemy()


##Death that maintains the body in the scene
##Turns off processes
func disable_enemy() -> void:
	collision_shape.set_deferred("disabled", true)
	set_process(false)
	set_physics_process(false)
