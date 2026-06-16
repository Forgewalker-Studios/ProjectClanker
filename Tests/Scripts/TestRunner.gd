extends Node

## Runs registered unit tests and prints pass/fail results to the console.
##
## Open this scene in the editor and press F6 (Run Current Scene) to execute tests.


const _EXIT_DELAY_SECONDS: float = 0.5

var _passed_count: int = 0
var _failed_count: int = 0


func _ready() -> void:
	print("=== ProjectClanker Test Runner ===")
	_run_all_tests()
	_print_summary()
	await get_tree().create_timer(_EXIT_DELAY_SECONDS).timeout
	get_tree().quit()


func _run_all_tests() -> void:
	_test_game_services_version_string()
	_test_game_services_pause_toggle()
	_test_dialogue_set_linear_advance()
	_test_dialogue_set_choice_branch()
	_test_dialogue_set_finish_at_end()


func _test_game_services_version_string() -> void:
	var version: String = GameServices.get_version_string()
	var passed: bool = version.length() > 0
	_record_result("GameServices.get_version_string returns non-empty value", passed)


func _test_game_services_pause_toggle() -> void:
	GameServices.set_paused(false)
	GameServices.toggle_pause()
	var paused_after_toggle: bool = GameServices.is_paused
	GameServices.set_paused(false)
	var passed: bool = paused_after_toggle
	_record_result("GameServices.toggle_pause sets is_paused true", passed)


func _test_dialogue_set_linear_advance() -> void:
	var dialogue_set: DialogueSet = DialogueSet.new()
	var first_entry: DialogueEntry = DialogueEntry.new()
	first_entry.text = "Line one."
	var second_entry: DialogueEntry = DialogueEntry.new()
	second_entry.text = "Line two."
	dialogue_set.dialogue_entries = [first_entry, second_entry]

	var advance_result: DialogueSet.DialogueAdvanceResult = dialogue_set.resolve_advance(0, -1)
	var passed: bool = (
		not advance_result.is_finished
		and advance_result.next_set == dialogue_set
		and advance_result.next_entry_index == 1
	)
	_record_result("DialogueSet.resolve_advance advances linearly without choices", passed)


func _test_dialogue_set_choice_branch() -> void:
	var root_set: DialogueSet = DialogueSet.new()
	var branch_set: DialogueSet = DialogueSet.new()
	var prompt_entry: DialogueEntry = DialogueEntry.new()
	var branch_entry: DialogueEntry = DialogueEntry.new()

	prompt_entry.text = "Pick a path."
	prompt_entry.choice_labels = ["Go left"]
	prompt_entry.choice_branch_sets = [branch_set]
	branch_entry.text = "You went left."
	branch_set.dialogue_entries = [branch_entry]
	root_set.dialogue_entries = [prompt_entry]

	var advance_result: DialogueSet.DialogueAdvanceResult = root_set.resolve_advance(0, 0)
	var passed: bool = (
		not advance_result.is_finished
		and advance_result.next_set == branch_set
		and advance_result.next_entry_index == 0
		and advance_result.next_set.get_entry(0).text == "You went left."
	)
	_record_result("DialogueSet.resolve_advance branches to another set on choice", passed)


func _test_dialogue_set_finish_at_end() -> void:
	var dialogue_set: DialogueSet = DialogueSet.new()
	var only_entry: DialogueEntry = DialogueEntry.new()
	only_entry.text = "Goodbye."
	dialogue_set.dialogue_entries = [only_entry]

	var advance_result: DialogueSet.DialogueAdvanceResult = dialogue_set.resolve_advance(0, -1)
	var passed: bool = advance_result.is_finished and advance_result.next_set == null
	_record_result("DialogueSet.resolve_advance finishes after the last entry", passed)


func _record_result(test_name: String, passed: bool) -> void:
	if passed:
		_passed_count += 1
		print("[PASS] %s" % test_name)
	else:
		_failed_count += 1
		push_error("[FAIL] %s" % test_name)


func _print_summary() -> void:
	print("---")
	print("Passed: %d  Failed: %d" % [_passed_count, _failed_count])
	if _failed_count > 0:
		push_error("Test run finished with failures.")
	else:
		print("All tests passed.")
