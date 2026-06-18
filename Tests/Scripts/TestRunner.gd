extends Node

## Runs registered unit tests and prints pass/fail results to the console.
##
## Open Tests/Scenes/UnitTestRunner.tscn and press F6 (Run Current Scene) to execute tests.
## Use Tests/Scenes/TestRunner.tscn for manual play-testing movement in a small sandbox.


const _EXIT_DELAY_SECONDS: float = 0.5

var _passed_count: int = 0
var _failed_count: int = 0


func _ready() -> void:
	print("=== ProjectClanker Unit Test Runner ===")
	await _run_all_tests()
	_print_summary()
	await get_tree().create_timer(_EXIT_DELAY_SECONDS).timeout
	get_tree().quit()


## Execute every registered test case.
func _run_all_tests() -> void:
	_test_game_services_version_string()
	_test_game_services_pause_toggle()
	await _test_player_take_damage_reduces_health()
	await _test_player_heal_restores_health()
	await _test_player_lethal_damage_skips_invulnerability()


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


func _test_player_take_damage_reduces_health() -> void:
	var player: Player = await _create_test_player()
	player.take_damage(3)
	var passed: bool = player.current_health == player.max_health - 3
	_record_result("Player.take_damage reduces current health", passed)
	player.queue_free()


func _test_player_heal_restores_health() -> void:
	var player: Player = await _create_test_player()
	player.take_damage(4)
	player.heal(2)
	var passed: bool = player.current_health == player.max_health - 2
	_record_result("Player.heal restores health up to max", passed)
	player.queue_free()


func _test_player_lethal_damage_skips_invulnerability() -> void:
	var player: Player = await _create_test_player()
	player.take_damage(player.max_health)
	await get_tree().process_frame
	var passed: bool = player.is_dead and not player.is_invulnerable
	_record_result("Player.take_damage skips invulnerability on lethal damage", passed)
	player.queue_free()


## Build a Player node with the children required by its onready references.
## @return: Ready player instance attached to the scene tree.
func _create_test_player() -> Player:
	var player: Player = Player.new()
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "PlayerSprite"
	sprite.texture = preload("res://Art/Placeholders/PlayerStates/IDLE.png")

	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(35.125, 53.125)
	collision_shape.shape = shape

	player.add_child(sprite)
	player.add_child(collision_shape)
	add_child(player)
	await get_tree().process_frame
	return player


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
