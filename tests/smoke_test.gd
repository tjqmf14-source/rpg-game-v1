extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	_check_required_file("res://project.godot")
	_check_required_file("res://scenes/main.tscn")
	_check_required_file("res://scripts/core/save_manager.gd")
	_check_required_file("res://scripts/interaction/interaction_sensor.gd")
	_check_required_file("res://scripts/interaction/interactable_npc.gd")
	_check_required_file("res://scripts/ui/dialogue_box.gd")
	_check_required_file("res://scripts/combat/enemy_controller.gd")
	_check_json_array("res://data/heroes.json")
	_check_json_array("res://data/monsters.json")
	_check_json_array("res://data/items.json")
	_check_main_scene()

	if failures.is_empty():
		print("SMOKE TEST PASS")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	print("SMOKE TEST FAIL: %d issue(s)" % failures.size())
	quit(1)


func _check_required_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		failures.append("Missing required file: %s" % path)


func _check_json_array(path: String) -> void:
	if not FileAccess.file_exists(path):
		failures.append("Missing JSON file: %s" % path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		failures.append("Cannot open JSON file: %s" % path)
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		failures.append("JSON root must be an array: %s" % path)
	elif parsed.is_empty():
		failures.append("JSON must contain at least one record: %s" % path)


func _check_main_scene() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		failures.append("Main scene failed to load")
		return

	var instance := packed.instantiate()
	if instance == null:
		failures.append("Main scene failed to instantiate")
		return

	instance.free()
