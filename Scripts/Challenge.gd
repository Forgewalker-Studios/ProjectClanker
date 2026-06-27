extends Area2D

## Activates the Boss upon interaction with panel to enter.

@export var prompt_text: String = "Enter?"
@export var player_group: String = "player"
## Designated boss that ties BossHatch.gd, BossProgress.gd, and Challenge.gd
@export var boss_id: StringName = &"room_03_type05_boss"
@export var boss_path: NodePath
## Sets respawn if player dies to the boss; set_death_spawn_override in Player.gd
@export var boss_death_respawn_path: NodePath

@onready var prompt_label: Label = $ChallengeBoss
@onready var destination: Marker2D = $BossBattle
@onready var boss_death_respawn: Marker2D = get_node_or_null(boss_death_respawn_path) as Marker2D

var player_inside: Node2D = null
var active_player: Node2D = null
var boss_behavior: BossBehavior = null
var boss_node: EnemyBase = null
var encounter_completed: bool = false


## Handles prompt visibility with _entered/_exited.
## Clarifies designated boss mob, and checks with BossProgress Autoload,
## boss_defeated signal checks with is_boss_defeated to run _remove_defeated_boss.
func _ready() -> void:
	prompt_label.text = prompt_text
	prompt_label.visible = false

	boss_node = _resolve_boss_node()
	boss_behavior = _resolve_boss_behavior()
	encounter_completed = BossProgress.is_boss_defeated(boss_id)

	if boss_node != null and not boss_node.boss_defeated.is_connected(_on_boss_defeated):
		boss_node.boss_defeated.connect(_on_boss_defeated, CONNECT_ONE_SHOT)

	if encounter_completed:
		_remove_defeated_boss()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


## Interact would teleport_player and activate the rest therein.
func _process(_delta: float) -> void:
	if player_inside == null:
		return

	if Input.is_action_just_pressed("interact"):
		teleport_player()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(player_group):
		player_inside = body
		prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body == player_inside:
		player_inside = null
		prompt_label.visible = false


## Moves player to @onready var destination: Marker2D = $BossBattle.
## Sets new respawn using @onready var boss_death_respawn: Marker2D,
## and set_death_respawn_override from Player.gd.
## Also handles other functions with _on_player_died_during_boss.
## If undefeated, runs activate_boss from BossBehavior.gd,
## and removes the boss if defeated according to BossProgress.gd.
func teleport_player() -> void:
	if player_inside == null:
		return

	active_player = player_inside
	active_player.global_position = destination.global_position

	if boss_death_respawn != null and active_player.has_method("set_death_respawn_override"):
		active_player.set_death_respawn_override(boss_death_respawn)

	if active_player.has_signal("player_died"):
		if not active_player.player_died.is_connected(_on_player_died_during_boss):
			active_player.player_died.connect(_on_player_died_during_boss)

	if BossProgress.is_boss_defeated(boss_id):
		encounter_completed = true
		_remove_defeated_boss()
	else:
		if boss_behavior != null:
			boss_behavior.activate_boss()

	prompt_label.visible = false
	player_inside = null


## player_died signal from Player.gd connects to deactivate_boss from BossBehavior.gd.
## Does not run if boss is defeated according to BossProgress.gd.
func _on_player_died_during_boss() -> void:
	if encounter_completed:
		return

	if BossProgress.is_boss_defeated(boss_id):
		encounter_completed = true
		return

	if boss_behavior != null:
		boss_behavior.deactivate_boss()


func _on_boss_defeated() -> void:
	encounter_completed = true
	BossProgress.mark_boss_defeated(boss_id)


func _remove_defeated_boss() -> void:
	if boss_node != null and is_instance_valid(boss_node):
		boss_node.call_deferred("queue_free")

	boss_behavior = null


## Clarification for EnemyBase Node.
func _resolve_boss_node() -> EnemyBase:
	if str(boss_path).is_empty():
		push_warning("Challenge: boss_path is empty.")
		return null

	var node: Node = get_node_or_null(boss_path)

	if node == null:
		push_warning("Challenge: boss_path does not point to a valid node: %s" % boss_path)
		return null

	return node as EnemyBase


## Clarification for BossBehavior Node.
func _resolve_boss_behavior() -> BossBehavior:
	if boss_node == null:
		return null

	var behavior: BossBehavior = boss_node.get_node_or_null("Behavior") as BossBehavior

	if behavior != null:
		return behavior

	push_warning("Challenge: boss node exists, but no BossBehavior was found: %s" % boss_node.get_path())
	return null
