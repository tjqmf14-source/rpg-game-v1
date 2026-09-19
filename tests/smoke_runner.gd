extends Node

var failures: Array[String] = []


func _ready() -> void:
	GameDatabase.reload()
	GameState.load_from_dict({
		"version": GameState.SAVE_VERSION,
		"unlocked_heroes": ["wanderer"],
		"current_party": ["wanderer"],
		"world_state": {
			"map_id": "start_village",
			"player_x": 240.0,
			"player_y": 270.0,
			"flags": {}
		}
	})

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
	var world_root := instance.get_node_or_null("WorldRoot")
	var collection_panel := instance.get_node_or_null("UI/CollectionPanel")

	if instance.get_script() == null or not instance.has_method("change_map"):
		failures.append("Main map controller script is missing or failed to compile")
	if player == null or player.get_script() == null or not player.has_method("take_damage"):
		failures.append("Player script is missing or failed to compile")
	if collection_panel == null or collection_panel.get_script() == null:
		failures.append("Collection panel script is missing or failed to compile")
	if world_root == null or world_root.get_child_count() != 1:
		failures.append("Start village was not loaded into WorldRoot")
		return

	if String(instance.call("get_current_map_id")) != "start_village":
		failures.append("Initial map id must be start_village")

	var village := world_root.get_child(0)
	if village.name != "StartVillage" or village.get_script() == null:
		failures.append("Start village scene/script failed to load")

	var changed := bool(instance.call("change_map", "meadow", "SpawnFromVillage"))
	if not changed:
		failures.append("Map transition to meadow failed")
		return
	if String(instance.call("get_current_map_id")) != "meadow":
		failures.append("Current map id did not update to meadow")
	if world_root.get_child_count() != 1:
		failures.append("WorldRoot must contain exactly one active map")
		return

	var meadow := world_root.get_child(0)
	var slime := meadow.get_node_or_null("Slime")
	if meadow.name != "Meadow" or meadow.get_script() == null:
		failures.append("Meadow scene/script failed to load")
	if slime == null or slime.get_script() == null or not slime.has_method("take_damage"):
		failures.append("Meadow enemy script is missing or failed to compile")
	if player.position.distance_to(Vector2(72, 270)) > 0.1:
		failures.append("Player did not move to meadow spawn point")
	if bool(instance.call("change_map", "missing_map", "SpawnDefault")):
		failures.append("Unknown runtime map id must be rejected")


func _finish() -> void:
	if failures.is_empty():
		print("RUNTIME SMOKE TEST PASS")
		get_tree().quit(0)
		return

	for failure in failures:
		push_error(failure)
	print("RUNTIME SMOKE TEST FAIL: %d issue(s)" % failures.size())
	get_tree().quit(1)
