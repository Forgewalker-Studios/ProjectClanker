class_name DialogueEntry
extends Resource

## Spoken or displayed line of dialogue.
@export var text: String = ""

## Player-facing labels for each choice. Leave empty when this line has no choices.
@export var choice_labels: Array[String] = []

## Dialogue set to open when the player picks the choice at the same index.
@export var choice_branch_sets: Array[DialogueSet] = []


## Return whether this entry waits for a player choice before continuing.
## @return: True when choice labels are present.
func has_choices() -> bool:
	return not choice_labels.is_empty()


## Return the number of choices on this entry.
## @return: Choice count.
func get_choice_count() -> int:
	return choice_labels.size()


## Validate that choice labels and branch targets stay paired.
## @return: True when choice data is consistent.
func validate_choices() -> bool:
	if choice_labels.is_empty():
		if not choice_branch_sets.is_empty():
			push_error(
				"DialogueEntry.validate_choices: choice_branch_sets must be empty when choice_labels is empty."
			)
			return false
		return true

	if choice_branch_sets.size() != choice_labels.size():
		push_error(
			"DialogueEntry.validate_choices: expected %d branch sets, got %d."
			% [choice_labels.size(), choice_branch_sets.size()]
		)
		return false

	return true
