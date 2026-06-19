class_name DialogueBox
extends CanvasLayer

signal advance_requested

@onready var speaker_label: Label = $Panel/MarginContainer/VBoxContainer/SpeakerLabel
@onready var body_label: Label = $Panel/MarginContainer/VBoxContainer/BodyLabel
@onready var prompt_label: Label = $Panel/MarginContainer/VBoxContainer/PromptLabel


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


## Show a dialogue line on screen.
## @param speaker: Name shown above the line.
## @param text: Line body text.
func show_line(speaker: String, text: String) -> void:
	visible = true
	speaker_label.text = speaker
	body_label.text = text
	prompt_label.text = "[E] Continue"


## Hide the dialogue box.
func hide_dialogue() -> void:
	visible = false


## Listen for interact while dialogue is visible.
## @param event: Input event from the viewport.
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact"):
		advance_requested.emit()
		get_viewport().set_input_as_handled()
