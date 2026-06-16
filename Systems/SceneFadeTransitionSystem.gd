class_name SceneFadeTransitionSystem
extends RefCounted

## PURPOSE:
## Manage reusable fade-transition sequencing state and ordered transition steps.
##
## USE WHEN:
## A game needs deterministic transition phase ordering without hardcoded scene flow.
##
## DO NOT USE WHEN:
## Scene flow is tightly coupled to project-specific lifecycle logic in this same module.
##
## OWNS:
## Current transition state, active request payload, and phase step order.
##
## CALLER MUST PROVIDE:
## Actual fade rendering and scene-loading side effects via external glue.
##
## GAME-SPECIFIC GLUE BELONGS:
## In scene managers/controllers that consume emitted phase steps.

enum TransitionState {
	IDLE,
	FADE_OUT,
	SCENE_CHANGE,
	FADE_IN,
	FINISHED,
}

var _state: TransitionState = TransitionState.IDLE
var _request: Dictionary = {}

func request_transition(target_scene: String, fade_out_duration: float, delay: float, fade_in_duration: float) -> bool:
	## Reject active transition requests; caller may cancel then request again.
	if _state != TransitionState.IDLE:
		return false
	var normalized_target: String = target_scene.strip_edges()
	if normalized_target == "":
		return false
	_request = {
		"target_scene": normalized_target,
		"fade_out_duration": maxf(0.0, fade_out_duration),
		"delay": maxf(0.0, delay),
		"fade_in_duration": maxf(0.0, fade_in_duration),
	}
	_state = TransitionState.FADE_OUT
	return true

func get_state() -> TransitionState:
	return _state

func get_request() -> Dictionary:
	return _request.duplicate(true)

func next_step() -> Dictionary:
	match _state:
		TransitionState.IDLE:
			return {}
		TransitionState.FADE_OUT:
			_state = TransitionState.SCENE_CHANGE
			return {"phase": "fade_out_requested", "duration": float(_request.get("fade_out_duration", 0.0))}
		TransitionState.SCENE_CHANGE:
			_state = TransitionState.FADE_IN
			return {"phase": "scene_change_requested", "target_scene": String(_request.get("target_scene", "")), "delay": float(_request.get("delay", 0.0))}
		TransitionState.FADE_IN:
			_state = TransitionState.FINISHED
			return {"phase": "fade_in_requested", "duration": float(_request.get("fade_in_duration", 0.0))}
		TransitionState.FINISHED:
			var finished_target: String = String(_request.get("target_scene", ""))
			_state = TransitionState.IDLE
			_request = {}
			return {"phase": "transition_finished", "target_scene": finished_target}
	return {}

func cancel() -> void:
	_state = TransitionState.IDLE
	_request = {}
