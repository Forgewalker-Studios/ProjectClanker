extends Node2D

## Wires hub dialogue nodes before child scripts finish _ready.


func _enter_tree() -> void:
	var dialogue_controller: DialogueController = $DialogueController as DialogueController
	var dialogue_box: DialogueBox = $DialogueBox as DialogueBox
	var d0r1: D0R1 = $D0R1 as D0R1

	if dialogue_controller == null:
		push_error("DoorHub: DialogueController node is missing.")
		return
	if dialogue_box == null:
		push_error("DoorHub: DialogueBox node is missing.")
		return
	if d0r1 == null:
		push_error("DoorHub: D0R1 node is missing.")
		return

	dialogue_controller.bind_dialogue_box(dialogue_box)
	d0r1.dialogue_controller = dialogue_controller
