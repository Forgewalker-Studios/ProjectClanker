extends CanvasLayer


@onready var dim_overlay: ColorRect = $DimOverlay
@onready var pause_label: Label = $Pause


##Set process to always to allow inputs within pause state
##Set visibility to false to prevent overlap outside pause state
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	visible = false
	
	dim_overlay.color = Color(0, 0, 0, 0.5)
	pause_label.text = "PAUSED"
	pause_label.add_theme_font_size_override("font_size", 48)
	pause_label.add_theme_constant_override("outline_size", 8)
	pause_label.add_theme_color_override("font_outline_color", Color.BLACK)
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


##Input (ESC) sets the pause state
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()


##Makes the pause screen visible only within pause state
##Only pause functions during pause state
##Processes outside of pause are halted
func toggle_pause() -> void:
	var should_pause = not get_tree().paused
	
	get_tree().paused = should_pause
	visible = should_pause
