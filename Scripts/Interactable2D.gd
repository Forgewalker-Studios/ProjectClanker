class_name Interactable2D
extends Area2D

signal interact_requested(player: Player)

## Prompt shown while the player is in range.
@export var prompt_text: String = "[E] Interact"
@export var prompt_label_path: NodePath = ^"PromptLabel"

@onready var prompt_label: Label = get_node_or_null(prompt_label_path) as Label


func _ready() -> void:
	collision_mask = 2
	monitorable = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if prompt_label != null:
		prompt_label.text = prompt_text
		prompt_label.visible = false


## Register this target when the player enters range.
## @param body: Body that entered the area.
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player: Player = body as Player
		player.set_interact_target(self )

		if prompt_label != null:
			prompt_label.visible = true


## Clear this target when the player leaves range.
## @param body: Body that exited the area.
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		var player: Player = body as Player
		player.clear_interact_target(self )

		if prompt_label != null:
			prompt_label.visible = false

## Return the prompt for HUD display.
## @return: Interaction prompt text.
func get_prompt_text() -> String:
	return prompt_text


## Called when the player presses interact while this is the active target.
## @param player: The interacting player.
func interact(player: Player) -> void:
	interact_requested.emit(player)
