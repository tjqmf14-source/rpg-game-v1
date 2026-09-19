extends Node

var failures: Array[String] = []


func _ready() -> void:
	GameDatabase.reload()
	_check_database()
	_check_main_scene()
	await get_tree().process_frame
	await get_tree().process_frame
	_finish()


func _check_database() -> void:
	if GameDatabase.heroes.is_empty():
		failures.append("GameDatabase heroes failed to load")
	if GameDatabase.monsters.is_empty():
		failures.append("GameDatabase monsters failed to load")
	if GameDatabase.items.is_empty():
		failures.append("GameDatabase items failed to load")


func _check_main_scene() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		failures.append("Main scene failed to load")
		return

	var instance := packed.instantiate()
	if instance == null:
		failures.append("Main scene failed to instantiate")
		return

	add_child(instance)

	var player := instance.get_node_or_null("Player")
	var slime := instance.get_node_or_null("Slime")
	var collection_panel := instance.get_node_or_null("UI/CollectionPanel")

	if instance.get_script() == null:
		failures.append("Main root script is missing or failed to compile")
	if player == null or player.get_script() == null or not player.has_method("take_damage"):
		failures.append("Player script is missing or failed to compile")
	if slime == null or slime.get_script() == null or not slime.has_method("take_damage"):
		failures.append("Enemy script is missing or failed to compile")
	if collection_panel == null or collection_panel.get_script() == null:
		failures.append("Collection panel script is missing or failed to compile")


func _finish() -> void:
	if failures.is_empty():
		print("RUNTIME SMOKE TEST PASS")
		get_tree().quit(0)
		return

	for failure in failures:
		push_error(failure)
	print("RUNTIME SMOKE TEST FAIL: %d issue(s)" % failures.size())
	get_tree().quit(1)
