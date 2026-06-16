class_name ItemPlacementPuzzleSystem
extends RefCounted

## PURPOSE:
## Track pure item-placement puzzle rules (required IDs, placed IDs, wrong attempts, completion).
##
## USE WHEN:
## A game needs reusable rule logic for "place required items into targets" puzzles.
##
## DO NOT USE WHEN:
## Puzzle flow requires story-specific rewards, scene transitions, UI ownership, or save side effects in the same module.
##
## OWNS:
## Required item set, placed items, wrong attempts, and completion state.
##
## CALLER MUST PROVIDE:
## Item IDs, optional target keys, and external consequences/UI/save glue.
##
## GAME-SPECIFIC GLUE BELONGS:
## In puzzle scene scripts and game systems that react to completion/wrong attempts.

var _required_items: Array[String] = []
var _placed_items: Array[String] = []
var _wrong_attempts: Array[String] = []
var _target_requirements: Dictionary = {}

func configure_required_items(required_items: Array[String]) -> void:
	_required_items = []
	for item_id: String in required_items:
		var normalized: String = item_id.strip_edges()
		if normalized != "" and normalized not in _required_items:
			_required_items.append(normalized)
	reset_state()

func configure_target_requirements(target_requirements: Dictionary) -> void:
	_target_requirements = {}
	_required_items = []
	for target_variant: Variant in target_requirements.keys():
		var target: String = String(target_variant).strip_edges()
		var item_id: String = String(target_requirements[target_variant]).strip_edges()
		if target != "" and item_id != "":
			_target_requirements[target] = item_id
			if item_id not in _required_items:
				_required_items.append(item_id)
	reset_state()

func place_item(item_id: String, target: String = "") -> Dictionary:
	var normalized_item: String = item_id.strip_edges()
	if normalized_item == "":
		return {"accepted": false, "reason": "invalid_item"}
	if normalized_item in _placed_items:
		return {"accepted": false, "reason": "duplicate"}
	if not _is_item_allowed_for_target(normalized_item, target):
		_wrong_attempts.append(normalized_item)
		return {"accepted": false, "reason": "wrong_item"}
	_placed_items.append(normalized_item)
	return {
		"accepted": true,
		"reason": "accepted",
		"completed": is_completed(),
	}

func is_completed() -> bool:
	for required_item: String in _required_items:
		if required_item not in _placed_items:
			return false
	return not _required_items.is_empty()

func get_placed_items() -> Array[String]:
	return _placed_items.duplicate()

func get_wrong_attempts() -> Array[String]:
	return _wrong_attempts.duplicate()

func reset_state() -> void:
	_placed_items.clear()
	_wrong_attempts.clear()

func export_state() -> Dictionary:
	return {
		"required_items": _required_items.duplicate(),
		"placed_items": _placed_items.duplicate(),
		"wrong_attempts": _wrong_attempts.duplicate(),
		"target_requirements": _target_requirements.duplicate(true),
	}

func import_state(state: Dictionary) -> void:
	var required_items_variant: Variant = state.get("required_items", [])
	if required_items_variant is Array:
		configure_required_items(required_items_variant as Array[String])
	else:
		configure_required_items([])
	var target_requirements_variant: Variant = state.get("target_requirements", {})
	if target_requirements_variant is Dictionary:
		configure_target_requirements(target_requirements_variant as Dictionary)
	else:
		configure_target_requirements({})
	_placed_items = []
	var placed_items_variant: Variant = state.get("placed_items", [])
	if placed_items_variant is Array:
		for item_variant: Variant in placed_items_variant as Array:
			var normalized: String = String(item_variant).strip_edges()
			if normalized != "" and normalized not in _placed_items:
				_placed_items.append(normalized)
	_wrong_attempts = []
	var wrong_attempts_variant: Variant = state.get("wrong_attempts", [])
	if wrong_attempts_variant is Array:
		for wrong_variant: Variant in wrong_attempts_variant as Array:
			var wrong_id: String = String(wrong_variant).strip_edges()
			if wrong_id != "":
				_wrong_attempts.append(wrong_id)

func _is_item_allowed_for_target(item_id: String, target: String) -> bool:
	var normalized_target: String = target.strip_edges()
	if not _target_requirements.is_empty():
		if normalized_target == "" or not _target_requirements.has(normalized_target):
			return false
		return String(_target_requirements[normalized_target]) == item_id
	return item_id in _required_items
