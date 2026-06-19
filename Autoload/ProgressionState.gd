extends Node

enum State {
	START,
	START_COMPLETED,
	AREA_1,
	AREA_1_COMPLETED,
	AREA_2,
	AREA_2_COMPLETED,
	AREA_3,
	AREA_3_COMPLETED,
	FINAL,
	FINAL_COMPLETED,
}

signal state_changed(new_state: State)

var state: State = State.START


func _ready() -> void:
	pass


## Set the progression state and notify listeners.
## @param new_state: The new state to set.
func set_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	state_changed.emit(state)


## Get the next state after the current one.
## @param current_state: The current state.
## @return: The next state, or the current state when already at the end.
func get_next_state(current_state: State) -> State:
	match current_state:
		State.START:
			return State.START_COMPLETED
		State.START_COMPLETED:
			return State.AREA_1
		State.AREA_1:
			return State.AREA_1_COMPLETED
		State.AREA_1_COMPLETED:
			return State.AREA_2
		State.AREA_2:
			return State.AREA_2_COMPLETED
		State.AREA_2_COMPLETED:
			return State.AREA_3
		State.AREA_3:
			return State.AREA_3_COMPLETED
		State.AREA_3_COMPLETED:
			return State.FINAL
		State.FINAL:
			return State.FINAL_COMPLETED
		State.FINAL_COMPLETED:
			return State.FINAL_COMPLETED
		_:
			push_error("ProgressionState.get_next_state: unhandled state %d" % int(current_state))
			return current_state


## Advance to the next progression state in sequence.
func advance_state() -> void:
	set_state(get_next_state(state))


## Save the state to a string.
## @param save_state: The state to save.
## @return: The saved state as a string.
func to_save(save_state: State) -> String:
	return JSON.stringify({"state": save_state})


## Load the state from a string.
## @param save_data: The saved state as a string.
## @return: The loaded state.
func from_save(save_data: String) -> State:
	var parsed: Variant = JSON.parse_string(save_data)
	if parsed == null:
		push_error("ProgressionState.from_save: invalid JSON: %s" % save_data)
		return State.START
	if not parsed is Dictionary:
		push_error("ProgressionState.from_save: expected Dictionary, got %s" % typeof(parsed))
		return State.START
	var data: Dictionary = parsed
	if not data.has("state"):
		push_error("ProgressionState.from_save: missing 'state' key")
		return State.START
	var saved_state: int = int(data["state"])
	if saved_state < 0 or saved_state > State.FINAL_COMPLETED:
		push_error("ProgressionState.from_save: state out of range: %d" % saved_state)
		return State.START
	return saved_state as State
