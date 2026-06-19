class_name D0R1
extends Interactable2D

const _ProgressionStateScript = preload("res://Autoload/ProgressionState.gd")

## Placeholder expression colors until final art replaces primitives.
const EXPRESSION_COLORS: Dictionary = {
	"worried": Color(0.95, 0.75, 0.35, 1.0),
	"hopeful": Color(0.55, 0.85, 0.95, 1.0),
	"happy": Color(0.55, 0.95, 0.65, 1.0),
	"knowing": Color(0.75, 0.55, 0.95, 1.0),
	"controlling": Color(0.95, 0.45, 0.55, 1.0),
	"dim": Color(0.35, 0.35, 0.4, 1.0),
}

@export var dialogue_registry: DialogueRegistry
@export var dialogue_controller: DialogueController

@onready var face_panel: ColorRect = $FacePanel
@onready var left_eye: Label = $FacePanel/LeftEye
@onready var right_eye: Label = $FacePanel/RightEye
@onready var mouth: Label = $FacePanel/Mouth
@onready var blink_timer: Timer = $BlinkTimer


func _ready() -> void:
	super._ready()
	prompt_text = "[E] Talk to D-0R1"
	interact_requested.connect(_on_interact_requested)
	Progression.state_changed.connect(_on_progression_state_changed)
	blink_timer.timeout.connect(_on_blink_timer_timeout)
	_apply_expression_for_state(Progression.state)


## Start dialogue for the current progression phase.
## @param player: The interacting player.
func _on_interact_requested(player: Player) -> void:
	if dialogue_controller == null:
		push_error("D0R1: dialogue_controller is not assigned.")
		return
	if dialogue_registry == null:
		push_error("D0R1: dialogue_registry is not assigned.")
		return
	if dialogue_controller.is_active():
		return

	var dialogue_set: DialogueSet = dialogue_registry.get_dialogue_set(Progression.state)
	if dialogue_set == null:
		push_error("D0R1: no dialogue set for state %d" % int(Progression.state))
		return

	player.set_dialogue_movement_locked(true)
	dialogue_controller.start_dialogue(
		dialogue_set,
		_on_dialogue_finished.bind(player)
	)


## Unlock player movement and apply progression side effects.
## @param player: The interacting player.
func _on_dialogue_finished(player: Player) -> void:
	player.set_dialogue_movement_locked(false)

	if Progression.state == _ProgressionStateScript.State.START:
		Progression.set_state(_ProgressionStateScript.State.START_COMPLETED)


## Update face colors when progression changes.
## @param new_state: Updated progression state.
func _on_progression_state_changed(new_state: _ProgressionStateScript.State) -> void:
	_apply_expression_for_state(new_state)


## Apply placeholder expression visuals for a progression state.
## @param state: Progression phase to reflect.
func _apply_expression_for_state(state: _ProgressionStateScript.State) -> void:
	if dialogue_registry == null:
		return

	var expression_key: String = dialogue_registry.get_expression(state)
	var face_color: Color = EXPRESSION_COLORS.get(expression_key, Color.WHITE)
	face_panel.color = face_color

	match expression_key:
		"happy", "hopeful":
			mouth.text = "u"
		"controlling", "knowing":
			mouth.text = "n"
		"dim":
			mouth.text = "."
			left_eye.text = "-"
			right_eye.text = "-"
			return
		_:
			mouth.text = "o"

	left_eye.text = "o"
	right_eye.text = "o"


## Briefly hide eyes for a simple blink animation.
func _on_blink_timer_timeout() -> void:
	if dialogue_registry.get_expression(Progression.state) == "dim":
		return

	var eyes_visible: bool = left_eye.visible
	left_eye.visible = not eyes_visible
	right_eye.visible = not eyes_visible
	if not eyes_visible:
		blink_timer.wait_time = 0.12
	else:
		blink_timer.wait_time = randf_range(2.0, 4.5)
