class_name StatSimulationSystem
extends RefCounted

## Use this for named numeric stats (health, stamina, hunger, morale, oxygen, etc.).
## Missing current stat values are treated as full/max by default.
## Missing max values default to 100.
## Stat keys should be plain [String] values for consistency.
## This system only mutates numbers; gameplay consequences belong in higher-level glue.

## Named stat snapshot used by simulation and gameplay glue.
## Keep this data-only type free of scene/node references so it can be used in tests or servers.
class StatState:
	var values: Dictionary = {}
	var max_values: Dictionary = {}


## Per-stat passive drain rates in points-per-second.
## Example: with max 100, rate 0.0333 means ~1% every 30 seconds.
class DrainProfile:
	var rates_per_second: Dictionary = {}


## Applies passive drain to all stats listed in [param profile].
## Parameters:
##   state: Mutable stat state.
##   profile: Drain rates by stat key.
##   delta_sec: Frame/tick delta in seconds.
## Returns: nothing
static func apply_passive_drain(state: StatState, profile: DrainProfile, delta_sec: float) -> void:
	if delta_sec <= 0.0:
		return
	var keys: Array = profile.rates_per_second.keys()
	var i: int = 0
	while i < keys.size():
		var key_variant: Variant = keys[i]
		var key: String = str(key_variant)
		var rate: float = float(profile.rates_per_second[key_variant])
		var current_value: float = get_stat_value(state, key)
		var next_value: float = current_value - rate * delta_sec
		set_stat_value_clamped(state, key, next_value)
		i += 1


## Adds a stat delta (positive or negative) and clamps into [0..max].
## Parameters:
##   state: Mutable stat state.
##   stat_key: Name of stat.
##   delta_value: Change amount.
## Returns: nothing
static func apply_stat_delta(state: StatState, stat_key: String, delta_value: float) -> void:
	var current_value: float = get_stat_value(state, stat_key)
	set_stat_value_clamped(state, stat_key, current_value + delta_value)


## Sets stat directly, clamped to a legal range.
## Parameters:
##   state: Mutable stat state.
##   stat_key: Name of stat.
##   raw_value: Unclamped target value.
## Returns: nothing
static func set_stat_value_clamped(state: StatState, stat_key: String, raw_value: float) -> void:
	var max_value: float = get_max_value(state, stat_key)
	var clamped_value: float = clampf(raw_value, 0.0, max_value)
	state.values[stat_key] = clamped_value


## Returns current value for a stat (defaults to max when not initialized).
## Parameters:
##   state: Stat state.
##   stat_key: Name of stat.
## Returns: Current value.
static func get_stat_value(state: StatState, stat_key: String) -> float:
	if state.values.has(stat_key):
		return float(state.values[stat_key])
	return get_max_value(state, stat_key)


## Returns max value for a stat (defaults to 100 when missing).
## Parameters:
##   state: Stat state.
##   stat_key: Name of stat.
## Returns: Maximum allowed value.
static func get_max_value(state: StatState, stat_key: String) -> float:
	if state.max_values.has(stat_key):
		var max_value: float = float(state.max_values[stat_key])
		if max_value > 0.0:
			return max_value
	return 100.0


## Computes a per-second drain rate from "percent of max over interval".
## Use this helper to keep balancing numbers data-driven.
## Parameters:
##   max_value: Ceiling for this stat.
##   percent: Fraction of max drained per interval (0.01 = 1%).
##   interval_seconds: Interval length in seconds.
## Returns: Points-per-second rate.
static func rate_from_percent_interval(max_value: float, percent: float, interval_seconds: float) -> float:
	if max_value <= 0.0:
		return 0.0
	if interval_seconds <= 0.0:
		return 0.0
	return max_value * percent / interval_seconds


## Returns true when one or more tracked stats are empty (<= 0).
## Parameters:
##   state: Stat state.
##   stat_keys: Stats to inspect.
## Returns: True if any listed stat is empty.
static func any_empty(state: StatState, stat_keys: PackedStringArray) -> bool:
	var i: int = 0
	while i < stat_keys.size():
		var key: String = stat_keys[i]
		if get_stat_value(state, key) <= 0.0:
			return true
		i += 1
	return false
