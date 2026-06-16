class_name DialogueSet
extends Resource

## Ordered dialogue lines played in sequence unless a choice branches elsewhere.
@export var dialogue_entries: Array[DialogueEntry] = []


## Result of advancing dialogue within or across dialogue sets.
class DialogueAdvanceResult:
	var next_set: DialogueSet = null
	var next_entry_index: int = 0
	var is_finished: bool = false


## Return how many entries this set contains.
## @return: Entry count.
func get_entry_count() -> int:
	return dialogue_entries.size()


## Return the entry at the given index.
## @param entry_index: Index into dialogue_entries.
## @return: The dialogue entry, or null when the index is invalid.
func get_entry(entry_index: int) -> DialogueEntry:
	if entry_index < 0 or entry_index >= dialogue_entries.size():
		push_error(
			"DialogueSet.get_entry: entry_index %d is out of range for %d entries."
			% [entry_index, dialogue_entries.size()]
		)
		return null

	return dialogue_entries[entry_index]


## Resolve the next dialogue position after the player advances or picks a choice.
## @param current_entry_index: Index of the entry currently on screen.
## @param choice_index: Selected choice index when the current entry has choices; use -1 otherwise.
## @return: The next set, entry index, and whether the conversation ended.
func resolve_advance(current_entry_index: int, choice_index: int = -1) -> DialogueAdvanceResult:
	var result: DialogueAdvanceResult = DialogueAdvanceResult.new()
	var entry: DialogueEntry = get_entry(current_entry_index)
	if entry == null:
		result.is_finished = true
		return result

	if not entry.validate_choices():
		result.is_finished = true
		return result

	if entry.has_choices():
		return _resolve_choice_advance(entry, choice_index)

	return _resolve_linear_advance(current_entry_index, result)


## Advance through the next entry in this set when no choice is required.
## @param current_entry_index: Index of the entry currently on screen.
## @param result: Result object to populate.
## @return: The populated advance result.
func _resolve_linear_advance(current_entry_index: int, result: DialogueAdvanceResult) -> DialogueAdvanceResult:
	var next_entry_index: int = current_entry_index + 1
	if next_entry_index >= dialogue_entries.size():
		result.is_finished = true
		return result

	result.next_set = self
	result.next_entry_index = next_entry_index
	return result


## Branch to another dialogue set when the player selects a choice.
## @param entry: Entry that owns the choice list.
## @param choice_index: Selected choice index.
## @return: The populated advance result.
func _resolve_choice_advance(entry: DialogueEntry, choice_index: int) -> DialogueAdvanceResult:
	var result: DialogueAdvanceResult = DialogueAdvanceResult.new()

	if choice_index < 0:
		push_error(
			"DialogueSet._resolve_choice_advance: choice_index is required when entry has choices."
		)
		result.is_finished = true
		return result

	if choice_index >= entry.choice_labels.size():
		push_error(
			"DialogueSet._resolve_choice_advance: choice_index %d is out of range for %d choices."
			% [choice_index, entry.choice_labels.size()]
		)
		result.is_finished = true
		return result

	var branch_set: DialogueSet = entry.choice_branch_sets[choice_index]
	if branch_set == null:
		push_error(
			"DialogueSet._resolve_choice_advance: choice %d has no branch dialogue set."
			% choice_index
		)
		result.is_finished = true
		return result

	if branch_set.get_entry_count() == 0:
		push_error(
			"DialogueSet._resolve_choice_advance: branch set for choice %d has no entries."
			% choice_index
		)
		result.is_finished = true
		return result

	result.next_set = branch_set
	result.next_entry_index = 0
	return result
