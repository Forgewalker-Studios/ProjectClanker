class_name DialogueRegistry
extends Resource

const _ProgressionStateScript = preload("res://Autoload/ProgressionState.gd")

## Maps progression phases to D-0R1 dialogue sets and placeholder expressions.

@export var dialogue_start: DialogueSet
@export var dialogue_start_completed: DialogueSet
@export var dialogue_area_1: DialogueSet
@export var dialogue_area_1_completed: DialogueSet
@export var dialogue_area_2: DialogueSet
@export var dialogue_area_2_completed: DialogueSet
@export var dialogue_area_3: DialogueSet
@export var dialogue_area_3_completed: DialogueSet
@export var dialogue_final: DialogueSet
@export var dialogue_final_completed: DialogueSet

@export var expression_start: String = "worried"
@export var expression_start_completed: String = "hopeful"
@export var expression_area_1: String = "worried"
@export var expression_area_1_completed: String = "happy"
@export var expression_area_2: String = "worried"
@export var expression_area_2_completed: String = "happy"
@export var expression_area_3: String = "worried"
@export var expression_area_3_completed: String = "knowing"
@export var expression_final: String = "controlling"
@export var expression_final_completed: String = "dim"


## Return the dialogue set for the given progression state.
## @param state: Current progression phase.
## @return: Dialogue lines to play, or null when unassigned.
func get_dialogue_set(state: _ProgressionStateScript.State) -> DialogueSet:
	match state:
		_ProgressionStateScript.State.START:
			return dialogue_start
		_ProgressionStateScript.State.START_COMPLETED:
			return dialogue_start_completed
		_ProgressionStateScript.State.AREA_1:
			return dialogue_area_1
		_ProgressionStateScript.State.AREA_1_COMPLETED:
			return dialogue_area_1_completed
		_ProgressionStateScript.State.AREA_2:
			return dialogue_area_2
		_ProgressionStateScript.State.AREA_2_COMPLETED:
			return dialogue_area_2_completed
		_ProgressionStateScript.State.AREA_3:
			return dialogue_area_3
		_ProgressionStateScript.State.AREA_3_COMPLETED:
			return dialogue_area_3_completed
		_ProgressionStateScript.State.FINAL:
			return dialogue_final
		_ProgressionStateScript.State.FINAL_COMPLETED:
			return dialogue_final_completed
		_:
			push_error("DialogueRegistry.get_dialogue_set: unhandled state %d" % int(state))
			return null


## Return the placeholder expression id for the given progression state.
## @param state: Current progression phase.
## @return: Expression key used by D-0R1 visuals.
func get_expression(state: _ProgressionStateScript.State) -> String:
	match state:
		_ProgressionStateScript.State.START:
			return expression_start
		_ProgressionStateScript.State.START_COMPLETED:
			return expression_start_completed
		_ProgressionStateScript.State.AREA_1:
			return expression_area_1
		_ProgressionStateScript.State.AREA_1_COMPLETED:
			return expression_area_1_completed
		_ProgressionStateScript.State.AREA_2:
			return expression_area_2
		_ProgressionStateScript.State.AREA_2_COMPLETED:
			return expression_area_2_completed
		_ProgressionStateScript.State.AREA_3:
			return expression_area_3
		_ProgressionStateScript.State.AREA_3_COMPLETED:
			return expression_area_3_completed
		_ProgressionStateScript.State.FINAL:
			return expression_final
		_ProgressionStateScript.State.FINAL_COMPLETED:
			return expression_final_completed
		_:
			return "worried"
