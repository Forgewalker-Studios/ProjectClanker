class_name WeightedSelectionSystem
extends RefCounted

## PURPOSE:
## Perform deterministic weighted entry selection with optional filtering and repeat suppression.
##
## USE WHEN:
## You need reusable weighted random picks for loot, spawn, encounter, or cue tables.
##
## DO NOT USE WHEN:
## Selection rules depend on game-specific runtime side effects or scene state mutation.
##
## OWNS:
## Weight table entries and last-picked ID tracker.
##
## CALLER MUST PROVIDE:
## Entry data dictionaries (`id`, `weight`) and optional filter callbacks.
##
## GAME-SPECIFIC GLUE BELONGS:
## In gameplay systems that decide eligibility semantics and consume chosen IDs.

var _entries: Array[Dictionary] = []
var _last_selected_id: String = ""

func clear() -> void:
	_entries.clear()
	_last_selected_id = ""

func set_entries(entries: Array) -> int:
	clear()
	return add_entries(entries)

func add_entries(entries: Array) -> int:
	var added_count: int = 0
	for entry_variant: Variant in entries:
		if entry_variant is Dictionary and add_entry(entry_variant as Dictionary):
			added_count += 1
	return added_count

func add_entry(entry: Dictionary) -> bool:
	var entry_id: String = String(entry.get("id", "")).strip_edges()
	var weight: float = float(entry.get("weight", 0.0))
	if entry_id == "" or weight <= 0.0:
		return false
	var stored: Dictionary = entry.duplicate(true)
	stored["id"] = entry_id
	stored["weight"] = weight
	_entries.append(stored)
	return true

func size() -> int:
	return _entries.size()

func pick(rng: RandomNumberGenerator, filter_callable: Callable = Callable(), avoid_immediate_repeat: bool = false) -> Dictionary:
	if rng == null:
		return {}
	var eligible: Array[Dictionary] = _build_eligible_entries(filter_callable, avoid_immediate_repeat)
	if eligible.is_empty() and avoid_immediate_repeat:
		eligible = _build_eligible_entries(filter_callable, false)
	if eligible.is_empty():
		return {}
	var selected: Dictionary = _pick_weighted(eligible, rng)
	_last_selected_id = String(selected.get("id", "")).strip_edges()
	return selected.duplicate(true)

func get_last_selected_id() -> String:
	return _last_selected_id

## pick_item_id_from_weighted_spawn_rows
## Purpose: Weighted pick matching legacy ItemManager.select_random_item: sums float(row.get(weight_key, weight_default)) in row order; total_roll in [0, total_weight); first row whose cumulative weight reaches or exceeds total_roll wins; if none match, returns id from the first row.
## Parameters: rows - candidate rows. id_key - dictionary key for returned id (e.g. "item_id"). weight_key - key for weight (e.g. "weight"). weight_default - weight when key missing. total_roll - random mass in [0, total_weight).
## Returns: Selected id string, or "" when rows is empty.
func pick_item_id_from_weighted_spawn_rows(rows: Array[Dictionary], id_key: String, weight_key: String, weight_default: float, total_roll: float) -> String:
	_last_selected_id = ""
	if rows.is_empty():
		return ""
	var total_weight: float = 0.0
	for row: Dictionary in rows:
		total_weight += float(row.get(weight_key, weight_default))
	if total_weight <= 0.0:
		var fallback_id: String = String(rows[0].get(id_key, "")).strip_edges()
		_last_selected_id = fallback_id
		return fallback_id
	var roll: float = total_roll
	var accum: float = 0.0
	for row2: Dictionary in rows:
		accum += float(row2.get(weight_key, weight_default))
		if roll <= accum:
			var picked: String = String(row2.get(id_key, "")).strip_edges()
			_last_selected_id = picked
			return picked
	var first_id: String = String(rows[0].get(id_key, "")).strip_edges()
	_last_selected_id = first_id
	return first_id

func list_entries() -> Array[Dictionary]:
	var cloned: Array[Dictionary] = []
	for entry: Dictionary in _entries:
		cloned.append(entry.duplicate(true))
	return cloned

func _build_eligible_entries(filter_callable: Callable, avoid_immediate_repeat: bool) -> Array[Dictionary]:
	var eligible: Array[Dictionary] = []
	for entry: Dictionary in _entries:
		var entry_id: String = String(entry.get("id", "")).strip_edges()
		if avoid_immediate_repeat and _entries.size() > 1 and entry_id == _last_selected_id:
			continue
		if filter_callable.is_valid() and not bool(filter_callable.call(entry.duplicate(true))):
			continue
		var weight: float = float(entry.get("weight", 0.0))
		if weight <= 0.0:
			continue
		eligible.append(entry)
	return eligible

func _pick_weighted(eligible: Array[Dictionary], rng: RandomNumberGenerator) -> Dictionary:
	var total_weight: float = 0.0
	for entry: Dictionary in eligible:
		total_weight += float(entry.get("weight", 0.0))
	if total_weight <= 0.0:
		return {}
	var roll: float = rng.randf() * total_weight
	var accumulator: float = 0.0
	for entry: Dictionary in eligible:
		accumulator += float(entry.get("weight", 0.0))
		if roll <= accumulator:
			return entry
	return eligible[eligible.size() - 1]
