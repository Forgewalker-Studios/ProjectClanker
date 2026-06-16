class_name DialogueContentSystem
extends RefCounted

## Category payload shape:
## {
##   "display_seconds": float,
##   "lines": Array[String],
##   "items": Array[{"question": String, "yes": String, "no": String}],
##   "reply_display_seconds": float,
##   "question_hold_seconds": float
## }
##
## Use this as a data-only dialogue/random text picker.
## This script does not display UI, trigger gameplay consequences, or own timing.
## Pair it with a presenter/view script such as TimedDialoguePresenterSystem.
##
## Expected JSON:
## {
##   "defaults": { "display_seconds": 5.0 },
##   "categories": {
##     "ambient": {
##       "display_seconds": 4.0,
##       "lines": ["Line one", "Line two"]
##     },
##     "prompts": {
##       "items": [
##         { "question": "Continue?", "yes": "You continue.", "no": "You stop." }
##       ]
##     }
##   }
## }

var _defaults_display_seconds: float = 5.0
var _categories: Dictionary = {}


## Loads dialogue table from a JSON file.
## Parameters:
##   json_path: res:// or user:// JSON path.
## Returns: Parsed system instance.
static func load_from_json_file(json_path: String):
	var db = load("res://Systems/DialogueContentSystem.gd").new()
	if not FileAccess.file_exists(json_path):
		push_error("DialogueContentSystem: missing file " + json_path)
		return db
	var file: FileAccess = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_error("DialogueContentSystem: failed to open " + json_path)
		return db
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("DialogueContentSystem: JSON root must be object.")
		return db
	db._ingest(parsed as Dictionary)
	return db


## Builds instance from in-memory dictionary (useful in tests/tools).
static func create_from_dictionary(data: Dictionary):
	var db = load("res://Systems/DialogueContentSystem.gd").new()
	db._ingest(data)
	return db


## Picks a random line and timing for a category.
## Returns empty text when category has no valid lines.
func pick_line_with_timing(category_key: String, rng: RandomNumberGenerator) -> Dictionary:
	var out: Dictionary = {}
	out["text"] = _pick_line(category_key, rng)
	out["seconds"] = get_display_seconds(category_key)
	return out


## Returns display seconds for category or global default.
func get_display_seconds(category_key: String) -> float:
	var cat: Dictionary = _get_category(category_key)
	if cat.is_empty():
		return _defaults_display_seconds
	if not cat.has("display_seconds"):
		return _defaults_display_seconds
	return float(cat["display_seconds"])


## Returns true if category has at least one valid question item.
func has_question_items(category_key: String) -> bool:
	return _get_valid_question_items(category_key).size() > 0


## Picks a yes/no package and avoids immediate repeat when possible.
## Returns empty dictionary when no valid data exists.
func pick_question_pack(category_key: String, rng: RandomNumberGenerator, avoid_item_index: int = -1) -> Dictionary:
	var valid_items: Array = _get_valid_question_items(category_key)
	var empty: Dictionary = {}
	if valid_items.size() == 0:
		return empty
	var idx: int = _pick_item_index(valid_items.size(), rng, avoid_item_index)
	var obj: Dictionary = valid_items[idx] as Dictionary
	var q: String = str(obj["question"])
	var y: String = str(obj["yes"])
	var n: String = str(obj["no"])
	var out: Dictionary = {}
	out["valid_item_index"] = idx
	out["source_item_index"] = int(obj["source_index"])
	out["question"] = q
	out["yes"] = y
	out["no"] = n
	out["question_hold_seconds"] = get_question_hold_seconds(category_key)
	out["reply_seconds"] = get_reply_display_seconds(category_key)
	return out


func get_reply_display_seconds(category_key: String) -> float:
	var cat: Dictionary = _get_category(category_key)
	if cat.is_empty():
		return _defaults_display_seconds
	if not cat.has("reply_display_seconds"):
		return _defaults_display_seconds
	return float(cat["reply_display_seconds"])


func get_question_hold_seconds(category_key: String) -> float:
	var cat: Dictionary = _get_category(category_key)
	if cat.is_empty():
		return 0.0
	if not cat.has("question_hold_seconds"):
		return 0.0
	return float(cat["question_hold_seconds"])


func _ingest(data: Dictionary) -> void:
	if data.has("defaults"):
		var defaults_val: Variant = data["defaults"]
		if typeof(defaults_val) == TYPE_DICTIONARY:
			var defaults_dict: Dictionary = defaults_val as Dictionary
			if defaults_dict.has("display_seconds"):
				_defaults_display_seconds = float(defaults_dict["display_seconds"])
	if data.has("categories"):
		var categories_val: Variant = data["categories"]
		if typeof(categories_val) == TYPE_DICTIONARY:
			_categories = (categories_val as Dictionary).duplicate(true)


func _pick_line(category_key: String, rng: RandomNumberGenerator) -> String:
	var cat: Dictionary = _get_category(category_key)
	if cat.is_empty():
		return ""
	if not cat.has("lines"):
		return ""
	var lines_val: Variant = cat["lines"]
	if typeof(lines_val) != TYPE_ARRAY:
		return ""
	var lines: Array = _get_valid_lines_from_array(lines_val as Array)
	if lines.is_empty():
		return ""
	if rng == null:
		return lines[0] as String
	var idx: int = rng.randi_range(0, lines.size() - 1)
	return lines[idx] as String


func _get_category(category_key: String) -> Dictionary:
	if not _categories.has(category_key):
		return {}
	var bucket: Variant = _categories[category_key]
	if typeof(bucket) != TYPE_DICTIONARY:
		return {}
	return bucket as Dictionary


func _get_question_items(category_key: String) -> Array:
	var cat: Dictionary = _get_category(category_key)
	if cat.is_empty():
		return []
	if not cat.has("items"):
		return []
	var items_val: Variant = cat["items"]
	if typeof(items_val) != TYPE_ARRAY:
		return []
	return items_val as Array


func _get_valid_lines_from_array(raw_lines: Array) -> Array:
	var out: Array = []
	var i: int = 0
	while i < raw_lines.size():
		var line_variant: Variant = raw_lines[i]
		if typeof(line_variant) == TYPE_STRING:
			var line: String = str(line_variant).strip_edges()
			if line != "":
				out.append(line)
		i += 1
	return out


func _get_valid_question_items(category_key: String) -> Array:
	var raw_items: Array = _get_question_items(category_key)
	var out: Array = []
	var i: int = 0
	while i < raw_items.size():
		var item_variant: Variant = raw_items[i]
		if typeof(item_variant) == TYPE_DICTIONARY:
			var obj: Dictionary = item_variant as Dictionary
			if obj.has("question") and obj.has("yes") and obj.has("no"):
				var q: String = str(obj["question"]).strip_edges()
				var y: String = str(obj["yes"]).strip_edges()
				var n: String = str(obj["no"]).strip_edges()
				if q != "" and y != "" and n != "":
					var clean: Dictionary = {}
					clean["question"] = q
					clean["yes"] = y
					clean["no"] = n
					clean["source_index"] = i
					out.append(clean)
		i += 1
	return out


func _pick_item_index(size: int, rng: RandomNumberGenerator, avoid_item_index: int) -> int:
	if size <= 1:
		return 0
	if rng == null:
		return 0
	var last: int = size - 1
	var idx: int = rng.randi_range(0, last)
	if avoid_item_index < 0 or avoid_item_index > last:
		return idx
	if idx != avoid_item_index:
		return idx
	var attempts: int = 0
	while idx == avoid_item_index and attempts < 64:
		idx = rng.randi_range(0, last)
		attempts += 1
	if idx == avoid_item_index:
		idx = avoid_item_index + 1
		if idx > last:
			idx = 0
	return idx
