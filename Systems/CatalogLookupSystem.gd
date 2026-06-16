class_name CatalogLookupSystem
extends RefCounted

## PURPOSE:
## Store and query ID-keyed catalog entries in a reusable, game-agnostic way.
##
## USE WHEN:
## You need stable ID lookup, category/tag filtering, and safe catalog import/export.
##
## DO NOT USE WHEN:
## Catalog behavior requires game-specific side effects like scene spawning, save writes, or event dispatch.
##
## OWNS:
## Internal entry dictionary keyed by String ID.
##
## CALLER MUST PROVIDE:
## Entry dictionaries with IDs and optional category/tags metadata.
##
## GAME-SPECIFIC GLUE BELONGS:
## In game-level managers that consume catalog entries for spawning, effects, and progression.

var _entries_by_id: Dictionary = {}

func clear() -> void:
	_entries_by_id.clear()

func size() -> int:
	return _entries_by_id.size()

func has_id(entry_id: String) -> bool:
	return _entries_by_id.has(_normalize_id(entry_id))

func register_entry(entry: Dictionary, overwrite: bool = false) -> bool:
	var entry_id: String = _normalize_id(entry.get("id", ""))
	if entry_id == "":
		return false
	if _entries_by_id.has(entry_id) and not overwrite:
		return false
	var cloned: Dictionary = entry.duplicate(true)
	cloned["id"] = entry_id
	_entries_by_id[entry_id] = cloned
	return true

func register_entries(entries: Array, overwrite: bool = false) -> int:
	var registered_count: int = 0
	for entry_variant: Variant in entries:
		if entry_variant is Dictionary and register_entry(entry_variant as Dictionary, overwrite):
			registered_count += 1
	return registered_count

func get_entry(entry_id: String) -> Dictionary:
	var normalized_id: String = _normalize_id(entry_id)
	if normalized_id == "" or not _entries_by_id.has(normalized_id):
		return {}
	return (_entries_by_id[normalized_id] as Dictionary).duplicate(true)

func get_ids() -> Array[String]:
	var ids: Array[String] = []
	for id_variant: Variant in _entries_by_id.keys():
		ids.append(String(id_variant))
	return ids

func get_entries_by_category(category: String) -> Array[Dictionary]:
	var normalized: String = category.strip_edges().to_lower()
	var results: Array[Dictionary] = []
	if normalized == "":
		return results
	for entry_variant: Variant in _entries_by_id.values():
		var entry: Dictionary = entry_variant as Dictionary
		var entry_category: String = String(entry.get("category", "")).strip_edges().to_lower()
		if entry_category == normalized:
			results.append(entry.duplicate(true))
	return results

func get_entries_by_tag(tag: String) -> Array[Dictionary]:
	var normalized: String = tag.strip_edges().to_lower()
	var results: Array[Dictionary] = []
	if normalized == "":
		return results
	for entry_variant: Variant in _entries_by_id.values():
		var entry: Dictionary = entry_variant as Dictionary
		var tags_variant: Variant = entry.get("tags", [])
		if tags_variant is Array:
			for raw_tag: Variant in tags_variant as Array:
				if String(raw_tag).strip_edges().to_lower() == normalized:
					results.append(entry.duplicate(true))
					break
	return results

func list_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry_variant: Variant in _entries_by_id.values():
		entries.append((entry_variant as Dictionary).duplicate(true))
	return entries

func export_state() -> Dictionary:
	return {
		"entries": list_entries()
	}

func import_state(state: Dictionary, replace_existing: bool = true) -> int:
	if replace_existing:
		clear()
	var imported_entries: Variant = state.get("entries", [])
	if imported_entries is Array:
		return register_entries(imported_entries as Array, replace_existing)
	return 0

func _normalize_id(raw_id: Variant) -> String:
	return String(raw_id).strip_edges()
