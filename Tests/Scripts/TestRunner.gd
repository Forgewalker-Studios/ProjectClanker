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
