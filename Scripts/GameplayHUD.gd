extends CanvasLayer

## Player health HUD with high-contrast labels for silhouette readability.

@export var player: Player

@onready var _health_bar: ProgressBar = %HealthBar
@onready var _health_label: Label = %HealthLabel
@onready var _damage_flash: ColorRect = %DamageFlash
@onready var _heal_flash: ColorRect = %HealFlash

var _damage_flash_tween: Tween
var _heal_flash_tween: Tween


func _ready() -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Player
	if player == null:
		push_error("GameplayHUD: player is not assigned.")
		return

	player.health_changed.connect(_on_health_changed)
	player.damage_taken.connect(_on_damage_taken)
	player.health_healed.connect(_on_health_healed)

	_health_bar.min_value = 0
	_health_bar.max_value = player.max_health
	_health_bar.value = player.current_health
	_on_health_changed(player.current_health, player.max_health)


## Update health bar and label text.
## @param current_health: Current hit points.
## @param max_health: Maximum hit points.
func _on_health_changed(current_health: int, max_health: int) -> void:
	_health_label.text = "Health: %d / %d" % [current_health, max_health]
	_health_bar.max_value = max_health
	_health_bar.value = current_health


## Flash the screen red when damage is taken.
## @param _amount: Damage dealt.
func _on_damage_taken(_amount: int) -> void:
	if _damage_flash_tween != null:
		_damage_flash_tween.kill()
	_damage_flash.color = Color(0.455, 0.094, 0.075, 0.35)
	_damage_flash_tween = create_tween()
	_damage_flash_tween.tween_property(
		_damage_flash,
		"color",
		Color(0.455, 0.094, 0.075, 0.0),
		0.3
	)


## Flash the screen green when health is restored.
## @param _amount: Health restored.
func _on_health_healed(_amount: int) -> void:
	if _heal_flash_tween != null:
		_heal_flash_tween.kill()
	_heal_flash.color = Color(0.267, 0.957, 0.361, 0.35)
	_heal_flash_tween = create_tween()
	_heal_flash_tween.tween_property(
		_heal_flash,
		"color",
		Color(0.267, 0.957, 0.361, 0.0),
		0.3
	)
