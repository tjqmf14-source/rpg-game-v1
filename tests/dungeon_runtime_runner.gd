extends Node

var failures: Array[String] = []


func _ready() -> void:
	GameDatabase.reload()
	GameState.load_from_dict({
		"version": GameState.SAVE_VERSION,
		"unlocked_heroes": ["wanderer"],
		"current_party": ["wanderer"],
		"inventory": {},
		"monster_codex": {},
		"equipment": {},
		"world_state": {
			"map_id": "start_village",
			"player_x": 240.0,
			"player_y": 270.0,
			"flags": {"quest_meadow_trial_completed": true}
		}
	})

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		failures.append("Dungeon test could not load main scene")
		_finish()
		return

	var game := packed.instantiate()
	add_child(game)
	await get_tree().physics_frame

	_expect(bool(game.call("change_map", "first_dungeon", "SpawnFromMeadow")), "Dungeon map transition must succeed")
	await get_tree().physics_frame

	var world_root := game.get_node_or_null("WorldRoot")
	var player := game.get_node_or_null("Player")
	if world_root == null or player == null or world_root.get_child_count() != 1:
		failures.append("Dungeon test missing world or player")
		_finish()
		return

	var dungeon := world_root.get_child(0)
	var boss := dungeon.get_node_or_null("AncientWarden")
	if boss == null:
		failures.append("Ancient Warden must exist before first defeat")
		_finish()
		return

	boss.set("move_speed", 0.0)
	boss.set("aggro_range", 0.0)
	var max_hp := int(boss.get("max_hp"))
	boss.call("take_damage", int(max_hp * 0.55), player)
	_expect(bool(boss.get("phase_two_active")), "Boss must enter phase two below 50% HP")
	_expect(float(boss.get("attack_cooldown")) < float(boss.get("base_attack_cooldown")), "Phase two must shorten boss attack cooldown")

	boss.call("take_damage", max_hp * 2, player)
	await get_tree().process_frame
	await get_tree().process_frame

	_expect(GameState.has_world_flag("boss_ancient_warden_defeated"), "Boss defeat flag must persist")
	_expect(GameState.get_item_amount("warden_core") == 1, "Boss must grant Warden Core exactly once")
	_expect(GameState.get_monster_defeats("ancient_warden") == 1, "Boss defeat must enter monster codex")

	_expect(bool(game.call("change_map", "meadow", "SpawnFromDungeon")), "Dungeon exit back to meadow must work")
	await get_tree().physics_frame
	_expect(bool(game.call("change_map", "first_dungeon", "SpawnFromMeadow")), "Dungeon re-entry must work")
	await get_tree().physics_frame

	dungeon = world_root.get_child(0)
	_expect(dungeon.get_node_or_null("AncientWarden") == null, "Defeated boss must not respawn on dungeon re-entry")

	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("DUNGEON RUNTIME TEST PASS")
		get_tree().quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("DUNGEON RUNTIME TEST FAIL: %d issue(s)" % failures.size())
	get_tree().quit(1)
