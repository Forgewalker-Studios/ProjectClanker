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
	_test_dialogue_registry_maps_start_state()
	_test_dialogue_set_linear_advance()
	_test_scene_fade_transition_sequence()
	_test_clanker_settings_round_trip()
	_test_enemy_config_type01_loads()
	await _test_enemy_take_damage_reduces_health()
	await _test_enemy_invulnerability_blocks_damage()


func _test_scene_fade_transition_sequence() -> void:
	var transition: SceneFadeTransitionSystem = SceneFadeTransitionSystem.new()
	var accepted: bool = transition.request_transition("res://Scenes/UI/MainMenu.tscn", 0.2, 0.0, 0.2)
	var step_one: Dictionary = transition.next_step()
	var step_two: Dictionary = transition.next_step()
	var passed: bool = (
		accepted
		and String(step_one.get("phase", "")) == "fade_out_requested"
		and String(step_two.get("phase", "")) == "scene_change_requested"
	)
	_record_result("SceneFadeTransitionSystem advances fade then scene change", passed)


func _test_clanker_settings_round_trip() -> void:
	var settings: SettingsPersistenceSystem = SettingsPersistenceSystem.new()
	settings.configure_defaults(
		{
			"audio": {
				"music_volume": 0.5,
				"sfx_volume": 0.6,
				"master_muted": false,
			},
		},
		1
	)
	settings.set_value("audio", "music_volume", 0.42)
	var exported: Dictionary = settings.export_state()
	var reloaded: SettingsPersistenceSystem = SettingsPersistenceSystem.new()
	reloaded.configure_defaults({"audio": {"music_volume": 0.5, "sfx_volume": 0.6, "master_muted": false}}, 1)
	reloaded.import_state(exported, true)
	var passed: bool = float(reloaded.get_value("audio", "music_volume", 0.0)) == 0.42
	_record_result("SettingsPersistenceSystem preserves updated audio volume", passed)


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


func _test_dialogue_registry_maps_start_state() -> void:
	var registry: DialogueRegistry = load("res://Resources/DialogueRegistry.tres") as DialogueRegistry
	const ProgressionStateScript = preload("res://Autoload/ProgressionState.gd")
	var dialogue_set: DialogueSet = registry.get_dialogue_set(ProgressionStateScript.State.START)
	var passed: bool = (
		registry != null
		and dialogue_set != null
		and dialogue_set.get_entry_count() > 0
		and dialogue_set.get_entry(0).text.length() > 0
	)
	_record_result("DialogueRegistry returns start dialogue set from resource", passed)


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

	var finish_result: DialogueSet.DialogueAdvanceResult = dialogue_set.resolve_advance(1, -1)
	var finish_passed: bool = finish_result.is_finished
	_record_result("DialogueSet.resolve_advance finishes after the last entry", finish_passed)


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


func _test_enemy_config_type01_loads() -> void:
	var config: EnemyConfig = load(
		"res://Resources/Enemies/Type01_RoamingEnemyConfig.tres"
	) as EnemyConfig
	var passed: bool = (
		config != null
		and config.display_name == "Roaming Enemy"
		and config.damage_mode == EnemyConfig.DamageMode.CONTACT
	)
	_record_result("Type01 Roaming enemy config loads from resource", passed)


func _test_enemy_take_damage_reduces_health() -> void:
	var enemy: EnemyBase = await _create_test_enemy()
	enemy.take_damage(2)
	var passed: bool = enemy.current_health == enemy.config.max_health - 2
	_record_result("EnemyBase.take_damage reduces current health", passed)
	enemy.queue_free()


func _test_enemy_invulnerability_blocks_damage() -> void:
	var enemy: EnemyBase = await _create_test_enemy()
	enemy.set_invulnerable(true)
	enemy.take_damage(2)
	var passed: bool = enemy.current_health == enemy.config.max_health
	_record_result("EnemyBase.set_invulnerable blocks damage", passed)
	enemy.queue_free()


## Build an EnemyBase node with the children required by its onready references.
## @return: Ready enemy instance attached to the scene tree.
func _create_test_enemy() -> EnemyBase:
	var config: EnemyConfig = EnemyConfig.new()
	config.display_name = "Test Enemy"
	config.max_health = 5
	config.damage_mode = EnemyConfig.DamageMode.CONTACT

	var enemy: EnemyBase = EnemyBase.new()
	enemy.config = config

	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = preload("res://Art/Placeholders/EnemyStates/IDLE.png")

	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"

	var contact_hurtbox: EnemyContactHurtbox = EnemyContactHurtbox.new()
	contact_hurtbox.name = "ContactHurtbox"

	var attack_hitbox: EnemyAttackHitbox = EnemyAttackHitbox.new()
	attack_hitbox.name = "AttackHitbox"

	var line_of_sight: EnemyLineOfSight = EnemyLineOfSight.new()
	line_of_sight.name = "LineOfSight"

	var patrol_points: Node2D = Node2D.new()
	patrol_points.name = "PatrolPoints"

	var behavior: RoamingPatrolBehavior = RoamingPatrolBehavior.new()
	behavior.name = "Behavior"

	enemy.add_child(sprite)
	enemy.add_child(collision_shape)
	enemy.add_child(contact_hurtbox)
	enemy.add_child(attack_hitbox)
	enemy.add_child(line_of_sight)
	enemy.add_child(patrol_points)
	enemy.add_child(behavior)
	add_child(enemy)
	await get_tree().process_frame
	return enemy


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
