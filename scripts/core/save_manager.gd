extends Node

const SAVE_DIR := "user://saves"
const DEFAULT_SLOT := "autosave"


func save_game(slot: String = DEFAULT_SLOT) -> bool:
	if slot.is_empty():
		return false

	var absolute_dir := ProjectSettings.globalize_path(SAVE_DIR)
	var error := DirAccess.make_dir_recursive_absolute(absolute_dir)
	if error != OK and error != ERR_ALREADY_EXISTS:
		push_error("SaveManager: failed to create save directory")
		return false

	var path := "%s/%s.json" % [SAVE_DIR, slot]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to open save file for writing")
		return false

	file.store_string(JSON.stringify(GameState.to_save_dict(), "\t"))
	return true


func load_game(slot: String = DEFAULT_SLOT) -> bool:
	if slot.is_empty():
		return false

	var path := "%s/%s.json" % [SAVE_DIR, slot]
	if not FileAccess.file_exists(path):
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveManager: invalid save data")
		return false

	GameState.load_from_dict(parsed)
	return true
