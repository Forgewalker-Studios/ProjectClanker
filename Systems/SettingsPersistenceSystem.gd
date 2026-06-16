class_name SettingsPersistenceSystem
extends RefCounted

## PURPOSE:
## Manage default/current settings dictionaries with safe get/set/reset/import/export behavior.
##
## USE WHEN:
## A project needs reusable settings state management without engine-specific side effects.
##
## DO NOT USE WHEN:
## You need direct InputMap, AudioServer, renderer, or scene/UI mutations in the same module.
##
## OWNS:
## Default settings dictionary, current settings dictionary, and optional version number.
##
## CALLER MUST PROVIDE:
## Default values, key paths, and external application of changed settings.
##
## GAME-SPECIFIC GLUE BELONGS:
## In game-level settings managers that apply values to engine APIs and UI.

var version: int = 1
var _defaults: Dictionary = {}
var _current: Dictionary = {}

func configure_defaults(defaults: Dictionary, initial_version: int = 1) -> void:
	version = initial_version
	_defaults = defaults.duplicate(true)
	_current = defaults.duplicate(true)

func get_value(category: String, key: String, fallback: Variant = null) -> Variant:
	var normalized_category: String = category.strip_edges()
	var normalized_key: String = key.strip_edges()
	if not _current.has(normalized_category):
		return fallback
	var category_data: Variant = _current[normalized_category]
	if category_data is Dictionary:
		return _clone_if_container((category_data as Dictionary).get(normalized_key, fallback))
	return fallback

func set_value(category: String, key: String, value: Variant) -> bool:
	var normalized_category: String = category.strip_edges()
	var normalized_key: String = key.strip_edges()
	if normalized_category == "" or normalized_key == "":
		return false
	if not _current.has(normalized_category) or not (_current[normalized_category] is Dictionary):
		_current[normalized_category] = {}
	var category_dict: Dictionary = (_current[normalized_category] as Dictionary).duplicate(true)
	category_dict[normalized_key] = _clone_if_container(value)
	_current[normalized_category] = category_dict
	return true

func reset_to_defaults() -> void:
	_current = _defaults.duplicate(true)

func has_category(category: String) -> bool:
	return _current.has(category.strip_edges())

func export_state() -> Dictionary:
	return {
		"version": version,
		"settings": _current.duplicate(true),
	}

func import_state(state: Dictionary, merge_defaults: bool = true) -> void:
	var imported_settings: Dictionary = {}
	if state.has("settings") and state["settings"] is Dictionary:
		imported_settings = (state["settings"] as Dictionary).duplicate(true)
	if state.has("version"):
		version = int(state["version"])
	if merge_defaults:
		var merged: Dictionary = _defaults.duplicate(true)
		for category_variant: Variant in imported_settings.keys():
			var category: String = String(category_variant).strip_edges()
			if category == "":
				continue
			var imported_category_data: Variant = imported_settings[category_variant]
			if imported_category_data is Dictionary:
				var merged_category: Dictionary = {}
				if merged.has(category) and merged[category] is Dictionary:
					merged_category = (merged[category] as Dictionary).duplicate(true)
				for key_variant: Variant in (imported_category_data as Dictionary).keys():
					var key: String = String(key_variant).strip_edges()
					if key == "":
						continue
					merged_category[key] = _clone_if_container((imported_category_data as Dictionary)[key_variant])
				merged[category] = merged_category
			else:
				merged[category] = _clone_if_container(imported_category_data)
		_current = merged
	else:
		_current = {}
		for category_variant: Variant in imported_settings.keys():
			var category: String = String(category_variant).strip_edges()
			if category == "":
				continue
			var imported_category_data: Variant = imported_settings[category_variant]
			if imported_category_data is Dictionary:
				var normalized_category_data: Dictionary = {}
				for key_variant: Variant in (imported_category_data as Dictionary).keys():
					var key: String = String(key_variant).strip_edges()
					if key == "":
						continue
					normalized_category_data[key] = _clone_if_container((imported_category_data as Dictionary)[key_variant])
				_current[category] = normalized_category_data
			else:
				_current[category] = _clone_if_container(imported_category_data)

func _clone_if_container(value: Variant) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	return value
