class_name PhaseTickSystem
extends Node

## Lightweight gameplay scheduler for deterministic order.
## Use this when gameplay-critical systems should run in explicit phases.
## Visual-only effects should generally remain outside this scheduler.
## This scheduler does not tick itself; scene glue calls [method run_tick].
## Registering callbacks to phases not present in [member _phase_order]
## will not execute until that phase is added to the order.

const PHASE_PRE_SIM: StringName = &"pre_sim"
const PHASE_SIM: StringName = &"sim"
const PHASE_POST_SIM: StringName = &"post_sim"
const PHASE_PRESENTATION: StringName = &"presentation"

var _phase_order: Array[StringName] = [
	PHASE_PRE_SIM,
	PHASE_SIM,
	PHASE_POST_SIM,
	PHASE_PRESENTATION,
]

var _phase_callbacks: Dictionary = {}


## Registers a callback into a phase list.
## Parameters:
##   phase: One of PHASE_* keys or a custom phase in _phase_order.
##   callback: Callable expecting one float parameter (delta_sec).
func register_callback(phase: StringName, callback: Callable) -> void:
	if not callback.is_valid():
		push_error("PhaseTickSystem: callback is not valid.")
		return
	if not _phase_callbacks.has(phase):
		_phase_callbacks[phase] = []
	if _phase_order.find(phase) == -1:
		push_warning("PhaseTickSystem: registered callback for phase not in order: " + str(phase))
	var list: Array = _phase_callbacks[phase] as Array
	if list.has(callback):
		return
	list.append(callback)
	_phase_callbacks[phase] = list


## Removes a callback from a phase.
func unregister_callback(phase: StringName, callback: Callable) -> void:
	if not _phase_callbacks.has(phase):
		return
	var list: Array = _phase_callbacks[phase] as Array
	var next: Array = []
	var i: int = 0
	while i < list.size():
		var entry: Variant = list[i]
		if entry is Callable:
			var cb: Callable = entry as Callable
			if cb != callback:
				next.append(cb)
		i += 1
	_phase_callbacks[phase] = next


## Optionally override phase order.
## Only do this in one place (bootstrapping) to avoid hard-to-debug behavior drift.
func set_phase_order(order: Array[StringName]) -> void:
	var next: Array[StringName] = []
	var i: int = 0
	while i < order.size():
		var phase: StringName = order[i]
		if next.find(phase) == -1:
			next.append(phase)
		else:
			push_warning("PhaseTickSystem: duplicate phase ignored: " + str(phase))
		i += 1
	_phase_order = next


## Drives all callbacks in configured phase order.
## Glue layer chooses whether to call this from _process or _physics_process.
func run_tick(delta_sec: float) -> void:
	var phase_i: int = 0
	while phase_i < _phase_order.size():
		var phase: StringName = _phase_order[phase_i]
		_execute_phase(phase, delta_sec)
		phase_i += 1


func _execute_phase(phase: StringName, delta_sec: float) -> void:
	if not _phase_callbacks.has(phase):
		return
	var callbacks: Array = (_phase_callbacks[phase] as Array).duplicate()
	var i: int = 0
	while i < callbacks.size():
		var item: Variant = callbacks[i]
		if item is Callable:
			var callback: Callable = item as Callable
			if callback.is_valid():
				callback.call(delta_sec)
		i += 1
