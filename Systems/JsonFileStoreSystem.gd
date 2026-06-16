class_name JsonFileStoreSystem
extends RefCounted

## PURPOSE:
## Provide generic JSON dictionary file read/write/delete helpers without owning schema.
##
## USE WHEN:
## A project needs reusable low-level JSON file storage operations.
##
## DO NOT USE WHEN:
## You need game-specific save schema, migrations, or gameplay-side persistence behavior.
##
## OWNS:
## No long-lived state; only file operation helpers.
##
## CALLER MUST PROVIDE:
## File paths and dictionary payload shape.
##
## GAME-SPECIFIC GLUE BELONGS:
## In game save/settings managers that define schema and migration rules.

func exists(file_path: String) -> bool:
	return FileAccess.file_exists(file_path)

func write_dictionary(file_path: String, data: Dictionary) -> bool:
	if not _ensure_parent_dir(file_path):
		return false
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	return true

func read_dictionary(file_path: String) -> Dictionary:
	if not exists(file_path):
		return {}
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return {}
	var raw_text: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	var parse_result: int = json.parse(raw_text)
	if parse_result != OK:
		return {}
	if json.data is Dictionary:
		return (json.data as Dictionary).duplicate(true)
	return {}

func delete(file_path: String) -> bool:
	if not exists(file_path):
		return false
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(file_path)) == OK

func backup(original_path: String, backup_path: String) -> bool:
	if not exists(original_path):
		return false
	if not _ensure_parent_dir(backup_path):
		return false
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(original_path)
	var backup_file: FileAccess = FileAccess.open(backup_path, FileAccess.WRITE)
	if backup_file == null:
		return false
	backup_file.store_buffer(bytes)
	backup_file.close()
	return true

func restore(backup_path: String, original_path: String) -> bool:
	if not exists(backup_path):
		return false
	if not _ensure_parent_dir(original_path):
		return false
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(backup_path)
	var file: FileAccess = FileAccess.open(original_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_buffer(bytes)
	file.close()
	return true

func _ensure_parent_dir(file_path: String) -> bool:
	var absolute_path: String = ProjectSettings.globalize_path(file_path)
	var directory_path: String = absolute_path.get_base_dir()
	if DirAccess.dir_exists_absolute(directory_path):
		return true
	return DirAccess.make_dir_recursive_absolute(directory_path) == OK
