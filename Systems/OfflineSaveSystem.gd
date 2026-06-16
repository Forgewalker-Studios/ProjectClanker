class_name OfflineSaveSystem
extends RefCounted

## Stat-focused save payload for lightweight simulation-driven games.
## This class intentionally stores only data so gameplay and presentation stay decoupled.
## Use this for simple offline stat simulation saves.
## This is not a full save framework.
## It assumes game state can be represented as stats, max_stats, metadata, and flags.
## Version is stored, but migrations are intentionally left to caller glue.
## Depends on [StatSimulationSystem] for offline drain simulation.
class SavePayload:
	var version: int = 1
	var saved_unix: int = 0
	var stats: Dictionary = {}
	var max_stats: Dictionary = {}
	var metadata: Dictionary = {}
	var flags: Dictionary = {}


## Reads JSON from [param save_path] or returns [param fallback_payload].
## Parameters:
##   save_path: user:// path.
##   fallback_payload: payload to return if missing/invalid.
## Returns: Loaded or fallback payload.
static func load_or_fallback(save_path: String, fallback_payload: SavePayload) -> SavePayload:
	if not FileAccess.file_exists(save_path):
		return _clone_payload(fallback_payload)
	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		push_error("OfflineSaveSystem: failed to open save for read at " + save_path)
		return _clone_payload(fallback_payload)
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("OfflineSaveSystem: invalid JSON root at " + save_path)
		return _clone_payload(fallback_payload)
	return _payload_from_dictionary(parsed as Dictionary, fallback_payload)


## Writes [param payload] to [param save_path] as pretty JSON.
## Parameters:
##   save_path: user:// path.
##   payload: save payload to write.
## Returns: True on success.
static func write_payload(save_path: String, payload: SavePayload) -> bool:
	payload.saved_unix = int(Time.get_unix_time_from_system())
	_ensure_parent_dir_exists(save_path)
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("OfflineSaveSystem: failed to open save for write at " + save_path)
		return false
	file.store_string(JSON.stringify(_payload_to_dictionary(payload), "\t"))
	file.close()
	return true


## Applies elapsed offline simulation time to stats using [StatSimulationSystem].
## This function does not decide win/lose; caller handles game-specific consequences.
## Parameters:
##   payload: Mutable save payload.
##   drain_profile: Per-stat rates.
## Returns: Elapsed seconds simulated (0 when skipped).
static func apply_offline_drain(payload: SavePayload, drain_profile: StatSimulationSystem.DrainProfile) -> float:
	var now_unix: int = int(Time.get_unix_time_from_system())
	if payload.saved_unix <= 0 or payload.saved_unix > now_unix:
		payload.saved_unix = now_unix
		push_warning("OfflineSaveSystem: invalid saved_unix; skipped offline drain.")
		return 0.0
	var dt: float = float(now_unix - payload.saved_unix)
	if dt <= 0.0:
		return 0.0
	var state: StatSimulationSystem.StatState = _state_from_payload(payload)
	StatSimulationSystem.apply_passive_drain(state, drain_profile, dt)
	payload.stats = state.values.duplicate(true)
	# Move the anchor forward so elapsed time is not double-applied if caller delays write.
	payload.saved_unix = now_unix
	return dt


## Deletes an existing save file.
## Parameters:
##   save_path: user:// path.
## Returns: nothing
static func delete_save(save_path: String) -> void:
	if not FileAccess.file_exists(save_path):
		return
	var folder_path: String = save_path.get_base_dir()
	if folder_path == "":
		folder_path = "user://"
	var file_name: String = save_path.get_file()
	var dir: DirAccess = DirAccess.open(folder_path)
	if dir == null:
		push_error("OfflineSaveSystem: failed to open " + folder_path + " for delete.")
		return
	var err: Error = dir.remove(file_name)
	if err != OK:
		push_error("OfflineSaveSystem: failed to delete " + save_path + " error=" + str(err))


## Converts payload to dictionary for serialization.
static func _payload_to_dictionary(payload: SavePayload) -> Dictionary:
	var out: Dictionary = {}
	out["version"] = payload.version
	out["saved_unix"] = payload.saved_unix
	out["stats"] = payload.stats.duplicate(true)
	out["max_stats"] = payload.max_stats.duplicate(true)
	out["metadata"] = payload.metadata.duplicate(true)
	out["flags"] = payload.flags.duplicate(true)
	return out


## Builds payload from dictionary, using fallback for missing keys.
static func _payload_from_dictionary(raw: Dictionary, fallback_payload: SavePayload) -> SavePayload:
	var payload: SavePayload = _clone_payload(fallback_payload)
	if raw.has("version"):
		payload.version = int(raw["version"])
	if raw.has("saved_unix"):
		payload.saved_unix = int(raw["saved_unix"])
	if raw.has("stats") and typeof(raw["stats"]) == TYPE_DICTIONARY:
		payload.stats = (raw["stats"] as Dictionary).duplicate(true)
	if raw.has("max_stats") and typeof(raw["max_stats"]) == TYPE_DICTIONARY:
		payload.max_stats = (raw["max_stats"] as Dictionary).duplicate(true)
	if raw.has("metadata") and typeof(raw["metadata"]) == TYPE_DICTIONARY:
		payload.metadata = (raw["metadata"] as Dictionary).duplicate(true)
	if raw.has("flags") and typeof(raw["flags"]) == TYPE_DICTIONARY:
		payload.flags = (raw["flags"] as Dictionary).duplicate(true)
	return payload


## Builds stat state from save payload.
static func _state_from_payload(payload: SavePayload) -> StatSimulationSystem.StatState:
	var state: StatSimulationSystem.StatState = StatSimulationSystem.StatState.new()
	state.values = payload.stats.duplicate(true)
	state.max_values = payload.max_stats.duplicate(true)
	return state


## Deep copy helper to avoid mutating caller-owned fallback templates.
static func _clone_payload(src: SavePayload) -> SavePayload:
	var copy: SavePayload = SavePayload.new()
	copy.version = src.version
	copy.saved_unix = src.saved_unix
	copy.stats = src.stats.duplicate(true)
	copy.max_stats = src.max_stats.duplicate(true)
	copy.metadata = src.metadata.duplicate(true)
	copy.flags = src.flags.duplicate(true)
	return copy


static func _ensure_parent_dir_exists(save_path: String) -> void:
	var base_dir: String = save_path.get_base_dir()
	if base_dir == "":
		return
	var dir: DirAccess = DirAccess.open(base_dir)
	if dir != null:
		return
	var absolute_dir: String = ProjectSettings.globalize_path(base_dir)
	var mk_err: Error = DirAccess.make_dir_recursive_absolute(absolute_dir)
	if mk_err != OK and mk_err != ERR_ALREADY_EXISTS:
		push_error("OfflineSaveSystem: failed creating parent dir " + base_dir + " error=" + str(mk_err))
