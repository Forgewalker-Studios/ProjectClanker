extends Node

## Full-screen fade transitions using SceneFadeTransitionSystem state machine glue.

signal transition_finished(target_scene: String)

const _FADE_LAYER: int = 128

var _fade_layer: CanvasLayer
var _fade_rect: ColorRect
var _transition: SceneFadeTransitionSystem = SceneFadeTransitionSystem.new()
var _active_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = _FADE_LAYER
	_fade_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_layer.add_child(_fade_rect)


## Request a fade-out, scene change, and fade-in sequence.
## @param target_scene: Packed scene path to load.
## @param fade_out_duration: Seconds for fade to black.
## @param delay: Seconds to hold black before loading.
## @param fade_in_duration: Seconds for fade back in.
## @return: True when the transition was accepted.
func request_scene_change(
	target_scene: String,
	fade_out_duration: float = 0.35,
	delay: float = 0.1,
	fade_in_duration: float = 0.35
) -> bool:
	var accepted: bool = _transition.request_transition(
		target_scene,
		fade_out_duration,
		delay,
		fade_in_duration
	)
	if not accepted:
		return false
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_run_next_transition_step()
	return true


func _run_next_transition_step() -> void:
	var step: Dictionary = _transition.next_step()
	if step.is_empty():
		return

	var phase: String = String(step.get("phase", ""))
	match phase:
		"fade_out_requested":
			await _fade_to_alpha(1.0, float(step.get("duration", 0.0)))
			_run_next_transition_step()
		"scene_change_requested":
			var delay_sec: float = float(step.get("delay", 0.0))
			if delay_sec > 0.0:
				await get_tree().create_timer(delay_sec).timeout
			var target_scene: String = String(step.get("target_scene", ""))
			var change_error: Error = get_tree().change_scene_to_file(target_scene)
			if change_error != OK:
				push_error("SceneTransition: failed to load %s (error %d)" % [target_scene, change_error])
				_transition.cancel()
				_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
				return
			await get_tree().process_frame
			_run_next_transition_step()
		"fade_in_requested":
			await _fade_to_alpha(0.0, float(step.get("duration", 0.0)))
			_run_next_transition_step()
		"transition_finished":
			_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			transition_finished.emit(String(step.get("target_scene", "")))


func _fade_to_alpha(target_alpha: float, duration_sec: float) -> void:
	if _active_tween != null:
		_active_tween.kill()

	if duration_sec <= 0.0:
		var instant_color: Color = _fade_rect.color
		instant_color.a = target_alpha
		_fade_rect.color = instant_color
		return

	_active_tween = create_tween()
	_active_tween.tween_property(_fade_rect, "color:a", target_alpha, duration_sec)
	await _active_tween.finished
