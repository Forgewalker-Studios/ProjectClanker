class_name FinalProgressionPickup
extends Interactable2D

@export var dialogue_controller_path: NodePath
@export var dialogue_set: DialogueSet

## If true, the pickup only works after AREA_3_COMPLETED.
## If false, it can force FINAL from any progression state.
@export var require_area_3_completed: bool = true

## Hide the pickup immediately when used.
@export var hide_on_pickup: bool = true

## Remove this node after the dialogue finishes.
@export var remove_after_pickup: bool = true

@onready var dialogue_controller: DialogueController = get_node_or_null(dialogue_controller_path) as DialogueController

var _used: bool = false


func _ready() -> void:
	super._ready()

	interact_requested.connect(_on_interact_requested)

	if Progression.state >= Progression.State.FINAL:
		_used = true
		_disable_pickup()


func _on_interact_requested(player: Player) -> void:
	if _used:
		return

	if not _can_pick_up():
		push_warning("FinalProgressionPickup: Cannot set progression to FINAL yet.")
		return

	if dialogue_controller == null:
		push_error("FinalProgressionPickup: dialogue_controller_path is missing or invalid.")
		return

	if dialogue_controller.is_active():
		return

	_used = true
	_disable_interaction()

	if hide_on_pickup:
		visible = false

	if player != null:
		player.set_dialogue_movement_locked(true)

	if dialogue_set != null:
		dialogue_controller.start_dialogue(
			dialogue_set,
			Callable(self, "_finish_pickup").bind(player)
		)
	else:
		push_warning("FinalProgressionPickup: dialogue_set is missing. Setting FINAL without dialogue.")
		_finish_pickup(player)


func _finish_pickup(player: Player) -> void:
	Progression.set_state(Progression.State.FINAL)

	if player != null and is_instance_valid(player):
		player.set_dialogue_movement_locked(false)

	if remove_after_pickup:
		queue_free()


func _can_pick_up() -> bool:
	if not require_area_3_completed:
		return true

	return Progression.state == Progression.State.AREA_3_COMPLETED


func _disable_interaction() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	for child: Node in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)


func _disable_pickup() -> void:
	if hide_on_pickup:
		visible = false

	_disable_interaction()
