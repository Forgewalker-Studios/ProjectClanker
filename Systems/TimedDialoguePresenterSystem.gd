class_name TimedDialoguePresenterSystem
extends Node

signal dialogue_hidden
signal yes_no_choice_made(picked_yes: bool)

## These are presentation-only timings; gameplay simulation should not depend on them.
## Use this as a presentation-only dialogue pop-up.
## It does not own dialogue content and should not decide gameplay consequences.
## Requires caller-provided UI nodes.
## Emits only the yes/no result; caller must track active question/context.
@export var fade_in_seconds: float = 0.22
@export var fade_out_seconds: float = 0.28

var _panel: PanelContainer
var _label: Label
var _question_row: Control
var _yes_button: Button
var _no_button: Button
var _active_tween: Tween
var _sequence_token: int = 0
var _yes_handler: Callable = Callable()
var _no_handler: Callable = Callable()


## Injects UI dependencies.
## Keep this as glue-layer wiring; the dialogue content system should remain UI-agnostic.
func setup(
	panel_node: PanelContainer,
	label_node: Label,
	question_row_node: Control,
	yes_button: Button,
	no_button: Button
) -> void:
	_panel = panel_node
	_label = label_node
	_question_row = question_row_node
	_yes_button = yes_button
	_no_button = no_button
	if _panel != null:
		_panel.visible = false
		_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_set_question_visible(false)


## Shows a single line then auto-hides.
func show_line(text: String, hold_seconds: float) -> void:
	if _panel == null or _label == null:
		dialogue_hidden.emit()
		return
	if text.strip_edges() == "":
		dialogue_hidden.emit()
		return
	hold_seconds = maxf(hold_seconds, 0.0)
	_sequence_token += 1
	var token: int = _sequence_token
	_clear_yes_no_handlers()
	_set_question_visible(false)
	_kill_active_tween()
	_label.text = text
	_panel.visible = true
	_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tw_in: Tween = create_tween()
	_active_tween = tw_in
	tw_in.tween_property(_panel, "modulate:a", 1.0, fade_in_seconds)
	await tw_in.finished
	if token != _sequence_token:
		return
	await get_tree().create_timer(hold_seconds).timeout
	if token != _sequence_token:
		return
	await _fade_out(token)


## Shows question + yes/no choice, then displays response text.
func show_yes_no(question: String, yes_reply: String, no_reply: String, question_hold_seconds: float, reply_hold_seconds: float) -> void:
	if _panel == null or _label == null:
		dialogue_hidden.emit()
		return
	if _question_row == null or _yes_button == null or _no_button == null:
		push_error("TimedDialoguePresenterSystem: missing yes/no controls.")
		dialogue_hidden.emit()
		return
	if question.strip_edges() == "":
		dialogue_hidden.emit()
		return
	if yes_reply.strip_edges() == "" or no_reply.strip_edges() == "":
		dialogue_hidden.emit()
		return
	question_hold_seconds = maxf(question_hold_seconds, 0.0)
	reply_hold_seconds = maxf(reply_hold_seconds, 0.0)
	_sequence_token += 1
	var token: int = _sequence_token
	_clear_yes_no_handlers()
	_kill_active_tween()
	_label.text = question
	_set_question_visible(true)
	_panel.visible = true
	_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tw_in: Tween = create_tween()
	_active_tween = tw_in
	tw_in.tween_property(_panel, "modulate:a", 1.0, fade_in_seconds)
	await tw_in.finished
	if token != _sequence_token:
		return
	if question_hold_seconds > 0.0:
		await get_tree().create_timer(question_hold_seconds).timeout
		if token != _sequence_token:
			return
	var picked_yes: bool = await _await_choice(token)
	if token != _sequence_token:
		return
	yes_no_choice_made.emit(picked_yes)
	_set_question_visible(false)
	if picked_yes:
		_label.text = yes_reply
	else:
		_label.text = no_reply
	await get_tree().create_timer(reply_hold_seconds).timeout
	if token != _sequence_token:
		return
	await _fade_out(token)


## Hard stop used on scene transitions or game-over swaps.
func hide_immediate() -> void:
	_sequence_token += 1
	_clear_yes_no_handlers()
	_set_question_visible(false)
	_kill_active_tween()
	if _panel != null:
		_panel.visible = false
		_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	dialogue_hidden.emit()


func _set_question_visible(visible: bool) -> void:
	if _question_row != null:
		_question_row.visible = visible


func _fade_out(token: int) -> void:
	var tw_out: Tween = create_tween()
	_active_tween = tw_out
	tw_out.tween_property(_panel, "modulate:a", 0.0, fade_out_seconds)
	await tw_out.finished
	if token != _sequence_token:
		return
	_panel.visible = false
	_set_question_visible(false)
	dialogue_hidden.emit()


func _await_choice(token: int) -> bool:
	var state: Dictionary = {}
	state["done"] = false
	state["yes"] = false
	_yes_handler = _on_yes.bind(token, state)
	_no_handler = _on_no.bind(token, state)
	if not _yes_button.pressed.is_connected(_yes_handler):
		_yes_button.pressed.connect(_yes_handler)
	if not _no_button.pressed.is_connected(_no_handler):
		_no_button.pressed.connect(_no_handler)
	while not state["done"]:
		if token != _sequence_token:
			_clear_yes_no_handlers()
			return false
		await get_tree().process_frame
	return state["yes"] as bool


func _on_yes(token: int, state: Dictionary) -> void:
	if token != _sequence_token:
		return
	_clear_yes_no_handlers()
	state["yes"] = true
	state["done"] = true


func _on_no(token: int, state: Dictionary) -> void:
	if token != _sequence_token:
		return
	_clear_yes_no_handlers()
	state["yes"] = false
	state["done"] = true


func _clear_yes_no_handlers() -> void:
	if _yes_button != null:
		if _yes_handler.is_valid():
			if _yes_button.pressed.is_connected(_yes_handler):
				_yes_button.pressed.disconnect(_yes_handler)
		_yes_handler = Callable()
	if _no_button != null:
		if _no_handler.is_valid():
			if _no_button.pressed.is_connected(_no_handler):
				_no_button.pressed.disconnect(_no_handler)
		_no_handler = Callable()


func _kill_active_tween() -> void:
	if _active_tween == null:
		return
	_active_tween.kill()
	_active_tween = null
