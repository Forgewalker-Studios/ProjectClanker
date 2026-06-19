extends Node

## Loads and applies player settings using Systems/ persistence helpers.

signal settings_changed()

const SAVE_PATH: String = "user://clanker_settings.json"

const CATEGORY_AUDIO: String = "audio"
const KEY_MUSIC_VOLUME: String = "music_volume"
const KEY_SFX_VOLUME: String = "sfx_volume"
const KEY_MASTER_MUTED: String = "master_muted"

const DEFAULT_MUSIC_VOLUME: float = 0.65
const DEFAULT_SFX_VOLUME: float = 0.75

var _settings: SettingsPersistenceSystem = SettingsPersistenceSystem.new()
var _file_store: JsonFileStoreSystem = JsonFileStoreSystem.new()


func _ready() -> void:
	_configure_defaults()
	load_settings()
	apply_audio_settings()


## Return a stored settings value.
## @param category: Settings category name.
## @param key: Settings key name.
## @param fallback: Value when missing.
## @return: Stored value or fallback.
func get_value(category: String, key: String, fallback: Variant = null) -> Variant:
	return _settings.get_value(category, key, fallback)


## Store a settings value and persist to disk.
## @param category: Settings category name.
## @param key: Settings key name.
## @param value: Value to store.
## @return: True when the value was stored.
func set_value(category: String, key: String, value: Variant) -> bool:
	var stored: bool = _settings.set_value(category, key, value)
	if not stored:
		return false
	save_settings()
	apply_audio_settings()
	settings_changed.emit()
	return true


## Reload settings from disk and apply them.
func load_settings() -> void:
	var loaded: Dictionary = _file_store.read_dictionary(SAVE_PATH)
	if loaded.is_empty():
		_settings.reset_to_defaults()
		return
	_settings.import_state(loaded, true)


## Persist current settings to disk.
func save_settings() -> void:
	var payload: Dictionary = _settings.export_state()
	var saved: bool = _file_store.write_dictionary(SAVE_PATH, payload)
	if not saved:
		push_error("ClankerSettings.save_settings: failed to write %s" % SAVE_PATH)


## Apply audio bus volumes and master mute from stored settings.
func apply_audio_settings() -> void:
	var music_volume: float = float(get_value(CATEGORY_AUDIO, KEY_MUSIC_VOLUME, DEFAULT_MUSIC_VOLUME))
	var sfx_volume: float = float(get_value(CATEGORY_AUDIO, KEY_SFX_VOLUME, DEFAULT_SFX_VOLUME))
	var master_muted: bool = bool(get_value(CATEGORY_AUDIO, KEY_MASTER_MUTED, false))

	_set_bus_linear(&"Music", music_volume)
	_set_bus_linear(&"SFX", sfx_volume)
	_set_master_muted(master_muted)


func _configure_defaults() -> void:
	var defaults: Dictionary = {
		CATEGORY_AUDIO: {
			KEY_MUSIC_VOLUME: DEFAULT_MUSIC_VOLUME,
			KEY_SFX_VOLUME: DEFAULT_SFX_VOLUME,
			KEY_MASTER_MUTED: false,
		},
	}
	_settings.configure_defaults(defaults, 1)


func _set_bus_linear(bus_name: StringName, linear_value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		push_error("ClankerSettings: missing bus %s" % String(bus_name))
		return
	AudioServer.set_bus_volume_linear(bus_index, clampf(linear_value, 0.0, 1.0))


func _set_master_muted(muted: bool) -> void:
	var bus_index: int = AudioServer.get_bus_index(&"Master")
	if bus_index < 0:
		push_error("ClankerSettings: missing Master bus.")
		return
	AudioServer.set_bus_mute(bus_index, muted)
