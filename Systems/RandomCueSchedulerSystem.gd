class_name RandomCueSchedulerSystem
extends RefCounted

## PURPOSE:
## Schedule and select random cues from weighted/filtered pools with deterministic RNG support.
##
## USE WHEN:
## A game needs reusable random cue timing/selection logic for ambience, stingers, or events.
##
## DO NOT USE WHEN:
## Cue scheduling must directly own playback APIs, scene logic, or game-specific stat semantics.
##
## OWNS:
## Cue pool definitions and last-picked cue ID.
##
## CALLER MUST PROVIDE:
## Cue metadata and external playback/effect handling.
##
## GAME-SPECIFIC GLUE BELONGS:
## In gameplay/audio systems that provide eligibility filters and consume selected cues.

var _cues: Array[Dictionary] = []
var _last_cue_id: String = ""

func clear() -> void:
	_cues.clear()
	_last_cue_id = ""

func set_cues(cues: Array) -> int:
	clear()
	var added: int = 0
	for cue_variant: Variant in cues:
		if cue_variant is Dictionary and _add_cue(cue_variant as Dictionary):
			added += 1
	return added

func select_next_cue(rng: RandomNumberGenerator, eligibility_filter: Callable = Callable(), avoid_immediate_repeat: bool = true) -> Dictionary:
	if rng == null:
		return {}
	var eligible: Array[Dictionary] = _build_eligible_cues(eligibility_filter, avoid_immediate_repeat)
	if eligible.is_empty() and avoid_immediate_repeat:
		eligible = _build_eligible_cues(eligibility_filter, false)
	if eligible.is_empty():
		return {}
	var selected: Dictionary = _pick_weighted(eligible, rng)
	if selected.is_empty():
		return {}
	_last_cue_id = String(selected.get("id", "")).strip_edges()
	return selected

func next_delay_seconds(rng: RandomNumberGenerator, min_delay: float, max_delay: float) -> float:
	var safe_min: float = maxf(0.0, min_delay)
	var safe_max: float = maxf(safe_min, max_delay)
	if is_equal_approx(safe_min, safe_max):
		return safe_min
	if rng == null:
		return safe_min
	return rng.randf_range(safe_min, safe_max)

func get_last_cue_id() -> String:
	return _last_cue_id

func list_cues() -> Array[Dictionary]:
	var cloned: Array[Dictionary] = []
	for cue: Dictionary in _cues:
		cloned.append(cue.duplicate(true))
	return cloned

func _add_cue(cue: Dictionary) -> bool:
	var cue_id: String = String(cue.get("id", "")).strip_edges()
	if cue_id == "":
		return false
	var stored: Dictionary = cue.duplicate(true)
	stored["id"] = cue_id
	_cues.append(stored)
	return true

func _build_eligible_cues(eligibility_filter: Callable, avoid_immediate_repeat: bool) -> Array[Dictionary]:
	var eligible: Array[Dictionary] = []
	for cue: Dictionary in _cues:
		var cue_id: String = String(cue.get("id", "")).strip_edges()
		if cue_id == "":
			continue
		if avoid_immediate_repeat and _cues.size() > 1 and cue_id == _last_cue_id:
			continue
		if eligibility_filter.is_valid() and not bool(eligibility_filter.call(cue.duplicate(true))):
			continue
		if float(cue.get("weight", 1.0)) <= 0.0:
			continue
		eligible.append(cue)
	return eligible

func _pick_weighted(eligible: Array[Dictionary], rng: RandomNumberGenerator) -> Dictionary:
	var total_weight: float = 0.0
	for cue: Dictionary in eligible:
		total_weight += maxf(0.0, float(cue.get("weight", 1.0)))
	if total_weight <= 0.0:
		return {}
	var roll: float = rng.randf() * total_weight
	var accumulator: float = 0.0
	for cue: Dictionary in eligible:
		var weight: float = maxf(0.0, float(cue.get("weight", 1.0)))
		if weight <= 0.0:
			continue
		accumulator += weight
		if roll <= accumulator:
			return cue.duplicate(true)
	return (eligible[eligible.size() - 1] as Dictionary).duplicate(true)
