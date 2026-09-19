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
			"flags": {}
		}
	})

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		failures.append("Combat test could not load main scene")
		_finish()
		return

	var game := packed.instantiate()
	add_child(game)
	await get_tree().physics_frame

	if not bool(game.call("change_map", "meadow", "SpawnFromVillage")):
		failures.append("Combat test could not enter meadow")
		_finish()
		return

	await get_tree().physics_frame

	var player := game.get_node_or_null("Player")
	var world_root := game.get_node_or_null("WorldRoot")
	if player == null or world_root == null or world_root.get_child_count() != 1:
		failures.append("Combat test missing player or active world")
		_finish()
		return

	var meadow := world_root.get_child(0)
	var slime := meadow.get_node_or_null("Slime")
	if slime == null:
		failures.append("Combat test missing slime")
		_finish()
		return

	slime.set("move_speed", 0.0)
	slime.set("aggro_range", 0.0)
	var enemy_hurtbox := slime.get_node_or_null("Hurtbox")
	var player_hurtbox := player.get_node_or_null("Hurtbox")
	_expect(enemy_hurtbox != null, "Enemy hurtbox must exist")
	_expect(player_hurtbox != null, "Player hurtbox must exist")

	player.global_position = slime.global_position + Vector2(-16, 0)
	player.set("facing", Vector2.RIGHT)
	player.set("attack_cooldown_left", 0.0)

	await get_tree().physics_frame

	var hp_before := int(slime.get("hp"))
	player.call("_try_attack")
	var hp_after := int(slime.get("hp"))
	_expect(hp_after < hp_before, "Player hitbox attack must damage enemy hurtbox")

	GameState.respawn_player()
	player.set("dodge_time_left", 0.0)
	player.global_position = slime.global_position + Vector2(8, 0)
	await get_tree().physics_frame

	var player_hp_before := GameState.player_hp
	slime.call("_try_attack", player.global_position - slime.global_position)
	_expect(GameState.player_hp < player_hp_before, "Enemy hitbox attack must damage player hurtbox")

	var dodge_hp := GameState.player_hp
	player.set("dodge_time_left", 0.1)
	player_hurtbox.call("receive_damage", 25, slime)
	_expect(GameState.player_hp == dodge_hp, "Dodge invulnerability must reject hurtbox damage")
	player.set("dodge_time_left", 0.0)

	GameState.damage_player(GameState.player_hp)
	await get_tree().process_frame
	await get_tree().process_frame

	_expect(String(game.call("get_current_map_id")) == "start_village", "Defeat must return player to start village")
	_expect(player.global_position.distance_to(Vector2(240, 270)) < 0.1, "Respawn must use start village safe spawn")
	_expect(GameState.player_hp == GameState.player_max_hp, "Respawn must restore player HP")

	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("COMBAT RUNTIME TEST PASS")
		get_tree().quit(0)
		return

	for failure in failures:
		push_error(failure)
	print("COMBAT RUNTIME TEST FAIL: %d issue(s)" % failures.size())
	get_tree().quit(1)
