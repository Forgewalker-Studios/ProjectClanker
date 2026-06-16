class_name TimedMessageQueueSystem
extends RefCounted

## PURPOSE:
## Manage ordered timed message queue state for reusable notification/sequence workflows.
##
## USE WHEN:
## You need queued timed message data and progression rules separate from UI presentation.
##
## DO NOT USE WHEN:
## Message behavior should directly own tweens, controls, or game-specific event triggers.
##
## OWNS:
## Queue entries and active message pointer.
##
## CALLER MUST PROVIDE:
## Message content, token data, and rendering/presentation behavior.
##
## GAME-SPECIFIC GLUE BELONGS:
## In UI/presentation managers and game narrative/event systems.

var _queue: Array[Dictionary] = []
var _current: Dictionary = {}
var _default_duration: float = 2.0

func set_default_duration(duration: float) -> void:
	_default_duration = maxf(0.0, duration)

func enqueue(message_text: String, duration: float = -1.0, blocking: bool = false, channel: String = "default") -> bool:
	var normalized_text: String = message_text.strip_edges()
	if normalized_text == "":
		return false
	var normalized_channel: String = channel.strip_edges()
	if normalized_channel == "":
		normalized_channel = "default"
	var entry: Dictionary = {
		"text": normalized_text,
		"duration": _default_duration if duration < 0.0 else maxf(0.0, duration),
		"blocking": blocking,
		"channel": normalized_channel,
	}
	_queue.append(entry)
	return true

func enqueue_from_dictionary(entry: Dictionary) -> bool:
	return enqueue(
		String(entry.get("text", "")),
		float(entry.get("duration", -1.0)),
		bool(entry.get("blocking", false)),
		String(entry.get("channel", "default"))
	)

func has_current() -> bool:
	return not _current.is_empty()

func get_current() -> Dictionary:
	return _current.duplicate(true)

func advance() -> Dictionary:
	if _queue.is_empty():
		_current = {}
		return {}
	_current = (_queue.pop_front() as Dictionary).duplicate(true)
	return get_current()

func skip_current() -> Dictionary:
	_current = {}
	return advance()

func clear() -> void:
	_queue.clear()
	_current = {}

func queue_size() -> int:
	return _queue.size()

func list_queue() -> Array[Dictionary]:
	var cloned: Array[Dictionary] = []
	for entry: Dictionary in _queue:
		cloned.append(entry.duplicate(true))
	return cloned

func apply_tokens(text: String, tokens: Dictionary) -> String:
	var result: String = text
	for key_variant: Variant in tokens.keys():
		var key: String = String(key_variant)
		var token: String = "{" + key + "}"
		result = result.replace(token, String(tokens[key_variant]))
	return result

func export_state() -> Dictionary:
	return {
		"default_duration": _default_duration,
		"queue": list_queue(),
		"current": get_current(),
	}

func import_state(state: Dictionary) -> void:
	clear()
	_default_duration = maxf(0.0, float(state.get("default_duration", 2.0)))
	var queue_variant: Variant = state.get("queue", [])
	if queue_variant is Array:
		for entry_variant: Variant in queue_variant as Array:
			if entry_variant is Dictionary:
				enqueue_from_dictionary(entry_variant as Dictionary)
	var current_variant: Variant = state.get("current", {})
	if current_variant is Dictionary:
		var current_dict: Dictionary = current_variant as Dictionary
		var current_text: String = String(current_dict.get("text", "")).strip_edges()
		if current_text != "":
			var current_channel: String = String(current_dict.get("channel", "default")).strip_edges()
			if current_channel == "":
				current_channel = "default"
			_current = {
				"text": current_text,
				"duration": maxf(0.0, float(current_dict.get("duration", _default_duration))),
				"blocking": bool(current_dict.get("blocking", false)),
				"channel": current_channel,
			}
