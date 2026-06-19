extends CanvasLayer


@export var player: Player

##Contains visual information for the player on the screen
##Currently includes: health
##Can be modified to include later elements

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthValue
@onready var damage_flash: ColorRect = $DamageFlash
@onready var heal_flash: ColorRect = $HealFlash

var damage_flash_tween: Tween
var heal_flash_tween: Tween

##Tied to health_changed from Player.gd
func _ready() -> void:
	if player == null:
		print("HUD Error: Player is not assigned.")
		return

	if player.has_signal("health_changed"):
		player.health_changed.connect(update_health)

	if player.has_signal("damage_taken"):
		player.damage_taken.connect(flash_damage)

	if player.has_signal("health_healed"):
		player.health_healed.connect(flash_heal)

	health_bar.min_value = 0
	health_bar.max_value = player.max_health
	health_bar.value = player.current_health

	update_health(player.current_health, player.max_health)


##Updates visual display for health
func update_health(current_health: int, max_health: int) -> void:
	health_label.text = "Health: %d / %d" % [current_health, max_health]
	health_bar.max_value = max_health
	health_bar.value = current_health


##Provides visual change when damage is taken
func flash_damage(_amount: int) -> void:
	if damage_flash_tween:
		damage_flash_tween.kill()

	##Final value determines transparency/strength of color
	damage_flash.color = Color(0.455, 0.094, 0.075, 0.35)

	##Provides fade out effect to visual
	damage_flash_tween = create_tween()
	damage_flash_tween.tween_property(
		damage_flash,
		"color",
		Color(0.455, 0.094, 0.075, 0),
		##Value determines duration of visual effect
		0.30
	)

##Provides visual change when damage is healed
func flash_heal(_amount: int) -> void:
	if heal_flash_tween:
		heal_flash_tween.kill()

	##Final value determines transparency/strength of color
	heal_flash.color = Color(0.267, 0.957, 0.361, 0.35)

	##Provides fade out effect to visual
	heal_flash_tween = create_tween()
	heal_flash_tween.tween_property(
		heal_flash,
		"color",
		Color(0.267, 0.957, 0.361, 0),
		##Value determines duration of visual effect
		0.30
	)
