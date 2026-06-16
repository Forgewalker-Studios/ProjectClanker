class_name EnvironmentPhasePresenterSystem
extends RefCounted

## PURPOSE:
## Interpolate environment presentation values over normalized phase progress.
##
## USE WHEN:
## A game needs reusable float/color interpolation for phase-based environment presentation.
##
## DO NOT USE WHEN:
## Module must directly own game-specific node wiring, simulation timing, or save logic.
##
## OWNS:
## Phase definitions dictionary and interpolation helpers.
##
## CALLER MUST PROVIDE:
## Phase definitions and application of computed values to scene nodes.
##
## GAME-SPECIFIC GLUE BELONGS:
## In environment/time-of-day controllers that bind computed values to actual nodes/resources.

var _phases: Dictionary = {}

func configure_phases(phases: Dictionary) -> void:
	_phases.clear()
	for phase_key_variant: Variant in phases.keys():
		var normalized_name: String = String(phase_key_variant).strip_edges()
		if normalized_name == "":
			continue
		_phases[normalized_name] = phases[phase_key_variant]

func has_phase(phase_name: String) -> bool:
	return _phases.has(phase_name.strip_edges())

func get_phase_value(phase_name: String, progress: float) -> Dictionary:
	var normalized_phase: String = phase_name.strip_edges()
	if not _phases.has(normalized_phase):
		return {}
	var phase_data: Variant = _phases[normalized_phase]
	if not (phase_data is Dictionary):
		return {}
	var raw_start: Variant = (phase_data as Dictionary).get("start", {})
	var raw_end: Variant = (phase_data as Dictionary).get("end", {})
	if not (raw_start is Dictionary) or not (raw_end is Dictionary):
		return {}
	var start_values: Dictionary = raw_start as Dictionary
	var end_values: Dictionary = raw_end as Dictionary
	var t: float = clampf(progress, 0.0, 1.0)
	var result: Dictionary = {}
	for key_variant: Variant in start_values.keys():
		var key: String = String(key_variant)
		if not end_values.has(key):
			continue
		var start_value: Variant = start_values[key]
		var end_value: Variant = end_values[key]
		if (start_value is float or start_value is int) and (end_value is float or end_value is int):
			result[key] = lerpf(float(start_value), float(end_value), t)
		elif start_value is Color and end_value is Color:
			result[key] = (start_value as Color).lerp(end_value as Color, t)
	return result
