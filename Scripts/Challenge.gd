extends Area2D

@export var prompt_text: String = "Enter?"
@export var player_group: String = "player"

@onready var prompt_label: Label = $ChallengeBoss
@onready var destination: Marker2D = $BossBattle

var player_inside: Node2D = null


func _ready() -> void:
	prompt_label.text = prompt_text
	prompt_label.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if player_inside == null:
		return

	if Input.is_action_just_pressed("interact"):
		teleport_player()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(player_group):
		player_inside = body
		prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body == player_inside:
		player_inside = null
		prompt_label.visible = false


func teleport_player() -> void:
	player_inside.global_position = destination.global_position
	prompt_label.visible = false
	player_inside = null
