class_name ThresholdStateSystem
extends RefCounted

## PURPOSE:
## Track numeric threshold band transitions (up/down) in a reusable state-only helper.
##
## USE WHEN:
## You need threshold crossing detection without coupling to gameplay consequences.
##
## DO NOT USE WHEN:
## Threshold checks must directly trigger game-specific audio/UI/death logic.
##
## OWNS:
## Ordered thresholds, current band, and last value.
##
## CALLER MUST PROVIDE:
## Threshold definitions and handling for returned crossing events.
##
## GAME-SPECIFIC GLUE BELONGS:
## In gameplay systems that react to threshold events.

var _thresholds: Array[Dictionary] = []
var _current_band: String = "uninitialized"
var _last_value: float = 0.0

func configure_thresholds(thresholds: Array) -> bool:
	_thresholds.clear()
	reset()
	for threshold_variant: Variant in thresholds:
		if threshold_variant is Dictionary:
			var threshold_dict: Dictionary = threshold_variant as Dictionary
			var name: String = String(threshold_dict.get("name", "")).strip_edges()
			if name == "":
				continue
			_thresholds.append({
				"name": name,
				"value": float(threshold_dict.get("value", 0.0)),
			})
	_thresholds.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["value"]) < float(b["value"])
	)
	return not _thresholds.is_empty()

func reset() -> void:
	_current_band = "uninitialized"
	_last_value = 0.0

func evaluate(value: float) -> Dictionary:
	var old_band: String = _current_band
	var next_band: String = _resolve_band(value)
	var is_initial: bool = old_band == "uninitialized"
	var crossed: bool = next_band != old_band
	var crossed_down: bool = crossed and not is_initial and value < _last_value
	var direction: String = "none"
	if is_initial:
		direction = "initial"
	elif crossed:
		if value < _last_value:
			direction = "down"
		elif value > _last_value:
			direction = "up"
	var event: Dictionary = {
		"crossed": crossed,
		"crossed_down": crossed_down,
		"old_band": old_band,
		"new_band": next_band,
		"value": value,
		"initial": is_initial,
		"direction": direction,
	}
	_current_band = next_band
	_last_value = value
	return event

func get_current_band() -> String:
	return _current_band

func _resolve_band(value: float) -> String:
	if _thresholds.is_empty():
		return "default"
	var band_name: String = "below_" + String(_thresholds[0]["name"])
	for threshold: Dictionary in _thresholds:
		if value >= float(threshold["value"]):
			band_name = String(threshold["name"])
	return band_name
