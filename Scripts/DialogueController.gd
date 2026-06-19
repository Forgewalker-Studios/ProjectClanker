class_name DialogueController
extends Node

signal dialogue_started
signal dialogue_finished

@export var dialogue_box: DialogueBox

var _active_set: DialogueSet = null
var _active_entry_index: int = 0
var _is_active: bool = false
var _on_finished: Callable = Callable()


## Connect dialogue box after DoorHub assigns references.
## @param box: Dialogue UI used for presentation.
func bind_dialogue_box(box: DialogueBox) -> void:
	dialogue_box = box
	if not dialogue_box.advance_requested.is_connected(_on_advance_requested):
		dialogue_box.advance_requested.connect(_on_advance_requested)


## Return whether a conversation is currently playing.
## @return: True when dialogue is active.
func is_active() -> bool:
	return _is_active


## Begin playing a dialogue set from the first entry.
## @param dialogue_set: Lines to present.
## @param on_finished: Optional callback when the set completes.
func start_dialogue(dialogue_set: DialogueSet, on_finished: Callable = Callable()) -> void:
	if dialogue_set == null:
		push_error("DialogueController.start_dialogue: dialogue_set is null.")
		return
	if dialogue_set.get_entry_count() == 0:
		push_error("DialogueController.start_dialogue: dialogue_set has no entries.")
		return
	if _is_active:
		push_error("DialogueController.start_dialogue: dialogue already active.")
		return

	_active_set = dialogue_set
	_active_entry_index = 0
	_on_finished = on_finished
	_is_active = true
	dialogue_started.emit()
	_show_current_entry()


## Advance or close the active conversation.
func _on_advance_requested() -> void:
	if not _is_active:
		return

	var entry: DialogueEntry = _active_set.get_entry(_active_entry_index)
	if entry != null and entry.has_choices():
		push_error("DialogueController: choices are not supported yet.")
		_finish_dialogue()
		return

	var result: DialogueSet.DialogueAdvanceResult = _active_set.resolve_advance(
		_active_entry_index,
		-1
	)
	if result.is_finished:
		_finish_dialogue()
		return

	_active_set = result.next_set
	_active_entry_index = result.next_entry_index
	_show_current_entry()


## Display the entry at the current index.
func _show_current_entry() -> void:
	var entry: DialogueEntry = _active_set.get_entry(_active_entry_index)
	if entry == null:
		_finish_dialogue()
		return
	dialogue_box.show_line("D-0R1", entry.text)


## End the conversation and run the completion callback.
func _finish_dialogue() -> void:
	_is_active = false
	_active_set = null
	_active_entry_index = 0
	dialogue_box.hide_dialogue()
	dialogue_finished.emit()
	if _on_finished.is_valid():
		_on_finished.call()
	_on_finished = Callable()
