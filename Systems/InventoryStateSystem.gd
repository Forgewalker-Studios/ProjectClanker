class_name InventoryStateSystem
extends RefCounted

## PURPOSE:
## Own reusable inventory state (item IDs + capacity/duplicate rules) with no game-specific side effects.
##
## USE WHEN:
## A game needs simple inventory state operations (add/remove/has/list/import/export) without UI/save/event glue.
##
## DO NOT USE WHEN:
## Inventory behavior depends on game-specific effects, puzzle/story logic, UI messaging, or save ownership.
##
## OWNS:
## Internal item-id list, max capacity configuration, and duplicate policy.
##
## CALLER MUST PROVIDE:
## Valid item IDs, optional capacity/policy config, persistence glue, and presentation/event wiring.
##
## GAME-SPECIFIC GLUE BELONGS:
## In game scripts/autoloads (for example Project Harvest `PlayerInventory`, `ItemManager`, `SaveManager`, and UI scripts).

enum DuplicatePolicy {
	ALLOW,
	REJECT,
}

var max_items: int = -1
var duplicate_policy: DuplicatePolicy = DuplicatePolicy.REJECT

var _items: Array[String] = []

func _init(initial_max_items: int = -1, initial_duplicate_policy: DuplicatePolicy = DuplicatePolicy.REJECT) -> void:
	max_items = initial_max_items
	duplicate_policy = initial_duplicate_policy

func add_item(item_id: String, count: int = 1) -> bool:
	## Returns true if at least one item is added.
	## For count > 1 this method is partial-success, not all-or-nothing.
	var normalized_id: String = item_id.strip_edges()
	if not _is_valid_item_id(normalized_id):
		return false
	if count <= 0:
		return false

	var added_any: bool = false
	var remaining: int = count
	while remaining > 0:
		if is_full():
			return added_any
		if duplicate_policy == DuplicatePolicy.REJECT and normalized_id in _items:
			return added_any
		_items.append(normalized_id)
		added_any = true
		remaining -= 1
	return added_any

func remove_item(item_id: String, count: int = 1) -> bool:
	## Returns true if at least one item is removed.
	## For count > 1 this method is partial-success, not all-or-nothing.
	var normalized_id: String = item_id.strip_edges()
	if not _is_valid_item_id(normalized_id):
		return false
	if count <= 0:
		return false

	var removed_any: bool = false
	var remaining: int = count
	while remaining > 0:
		var index: int = _items.find(normalized_id)
		if index == -1:
			return removed_any
		_items.remove_at(index)
		removed_any = true
		remaining -= 1
	return removed_any

func has_item(item_id: String, count: int = 1) -> bool:
	var normalized_id: String = item_id.strip_edges()
	if not _is_valid_item_id(normalized_id):
		return false
	if count <= 0:
		return false
	return get_item_count(normalized_id) >= count

func get_item_count(item_id: String) -> int:
	var normalized_id: String = item_id.strip_edges()
	if not _is_valid_item_id(normalized_id):
		return 0
	var total: int = 0
	for existing_id: String in _items:
		if existing_id == normalized_id:
			total += 1
	return total

func get_items() -> Array[String]:
	return _items.duplicate()

func get_unique_items() -> Array[String]:
	var unique: Array[String] = []
	for item_id: String in _items:
		if item_id not in unique:
			unique.append(item_id)
	return unique

func is_full() -> bool:
	if max_items < 0:
		return false
	return _items.size() >= max_items

func clear() -> void:
	_items.clear()

func size() -> int:
	return _items.size()

func export_state() -> Dictionary:
	return {
		"max_items": max_items,
		"duplicate_policy": int(duplicate_policy),
		"items": _items.duplicate(),
	}

func import_state(state: Dictionary) -> void:
	if state.has("max_items"):
		var imported_max: int = int(state.get("max_items", -1))
		max_items = imported_max
	if state.has("duplicate_policy"):
		var imported_policy_int: int = int(state.get("duplicate_policy", int(DuplicatePolicy.REJECT)))
		if imported_policy_int == int(DuplicatePolicy.ALLOW):
			duplicate_policy = DuplicatePolicy.ALLOW
		else:
			duplicate_policy = DuplicatePolicy.REJECT
	_items.clear()
	if state.has("items") and state["items"] is Array:
		for item_variant: Variant in state["items"]:
			var normalized: String = String(item_variant).strip_edges()
			if _is_valid_item_id(normalized):
				if duplicate_policy == DuplicatePolicy.REJECT and normalized in _items:
					continue
				if max_items >= 0 and _items.size() >= max_items:
					break
				_items.append(normalized)

func _is_valid_item_id(item_id: String) -> bool:
	return item_id.strip_edges() != ""
