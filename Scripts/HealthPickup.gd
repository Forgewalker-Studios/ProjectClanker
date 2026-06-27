extends Area2D


##Can be modified for different heal values.
@export var heal_amount: int = 2
@export var collect_when_full_health: bool = false

## Visual flip settings.
@export var flip_half_duration: float = 0.3
@export var flip_pause_duration: float = 0.15
@export var thin_scale_x: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


var start_position: Vector2
var start_sprite_scale: Vector2
var is_collected: bool = false
var flip_tween: Tween


func _ready() -> void:
	add_to_group("Resettable")
	start_position = global_position
	start_sprite_scale = sprite.scale

	body_entered.connect(_on_body_entered)

	start_flip_animation()

## Provided flip animation to differentiate from background.
func start_flip_animation() -> void:
	if flip_tween:
		flip_tween.kill()

	flip_tween = create_tween()
	flip_tween.set_loops()

	flip_tween.tween_property(
		sprite,
		"scale:x",
		start_sprite_scale.x * thin_scale_x,
		flip_half_duration
	)

	flip_tween.tween_interval(flip_pause_duration)

	flip_tween.tween_property(
		sprite,
		"scale:x",
		start_sprite_scale.x,
		flip_half_duration
	)

	flip_tween.tween_interval(flip_pause_duration)


##Tied specifically to the Player for pickup.
##Prevents pickup when at full health or dead.
func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return

	if not body is Player:
		return

	var player: Player = body

	if player.is_dead:
		return

	if player.current_health >= player.max_health and not collect_when_full_health:
		return

	player.heal(heal_amount)
	collect()


##Turns "off" upon collection.
func collect() -> void:
	is_collected = true

	visible = false
	set_deferred("monitoring", false)
	collision_shape.set_deferred("disabled", true)


##Built-in to reset when player respawns.
func reset() -> void:
	is_collected = false

	global_position = start_position

	visible = true
	set_deferred("monitoring", true)
	collision_shape.set_deferred("disabled", false)
