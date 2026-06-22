extends CanvasLayer

@onready var prompt_label: Label = $PromptLabel


func _ready() -> void:
	prompt_label.add_theme_constant_override("outline_size", 4)
	prompt_label.add_theme_color_override("font_outline_color", Color.BLACK)
	prompt_label.add_theme_font_size_override("font_size", 18)


func _process(_delta: float) -> void:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player == null:
		prompt_label.text = ""
		return
	if player.dialogue_movement_locked:
		prompt_label.text = ""
		return
	prompt_label.text = player.get_interact_prompt()
