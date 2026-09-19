extends Node

const SAVE_DIR := "user://saves"
const DEFAULT_SLOT := "autosave"
const MAX_SAVE_BYTES := 1048576


func save_game(slot: String = DEFAULT_SLOT) -> bool:
	if not _is_valid_slot(slot):
		return false

	var absolute_dir := ProjectSettings.globalize_path(SAVE_DIR)
	var error := DirAccess.make_dir_recursive_absolute(absolute_dir)
	if error != OK and error != ERR_ALREADY_EXISTS:
		push_error("SaveManager: failed to create save directory")
		return false

	var payload := GameState.to_save_dict()
	var json_text := JSON.stringify(payload, "\t")
	if json_text.to_utf8_buffer().size() > MAX_SAVE_BYTES:
		push_error("SaveManager: save payload exceeds size limit")
		return false

	var path := "%s/%s.json" % [SAVE_DIR, slot]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to open save file for writing")
		return false

	file.store_string(json_text)
	file.flush()
	return true


func load_game(slot: String = DEFAULT_SLOT) -> bool:
	if not _is_valid_slot(slot):
		return false

	var path := "%s/%s.json" % [SAVE_DIR, slot]
	if not FileAccess.file_exists(path):
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	if file.get_length() <= 0 or file.get_length() > MAX_SAVE_BYTES:
		push_error("SaveManager: invalid save file size")
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveManager: invalid save data")
		return false

	var version := int(parsed.get("version", 1))
	if version < 1 or version > GameState.SAVE_VERSION:
		push_error("SaveManager: unsupported save version %d" % version)
		return false

	GameState.load_from_dict(parsed)
	return true


func _is_valid_slot(slot: String) -> bool:
	if slot.is_empty() or slot.length() > 48:
		return false
	for character in slot:
		if not (character.is_valid_identifier() or character.is_valid_int() or character == "-" or character == "_"):
			return false
	return true
