extends CanvasLayer

@onready var prompt_label: Label = $PromptLabel


func _process(_delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player == null:
		prompt_label.text = ""
		return
	prompt_label.text = player.get_interact_prompt()
