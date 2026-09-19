extends Node

const MeadowTrial = preload("res://scripts/quests/meadow_trial.gd")

var failures: Array[String] = []


func _ready() -> void:
	GameDatabase.reload()
	_test_clean_state()
	_test_collection_and_equipment()
	_test_first_quest()
	_test_progression()
	_test_corrupt_save_sanitization()
	_test_save_round_trip()
	_finish()


func _reset_state() -> void:
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


func _test_clean_state() -> void:
	_reset_state()
	_expect(GameState.get_active_hero_id() == "wanderer", "Starter hero must be active")
	_expect(GameState.current_party.size() == 1, "Clean party must contain exactly one hero")
	_expect(GameState.gold == 0, "Clean gold must be zero")
	_expect(GameState.player_hp == GameState.player_max_hp, "Clean HP must be full")


func _test_collection_and_equipment() -> void:
	_reset_state()

	_expect(GameState.unlock_hero("rowan_knight"), "Rowan should unlock")
	_expect(not GameState.unlock_hero("rowan_knight"), "Duplicate hero unlock must fail")
	_expect(not GameState.unlock_hero("missing_hero"), "Unknown hero unlock must fail")
	_expect("rowan_knight" in GameState.current_party, "Unlocked Rowan should join available party slot")

	GameState.add_item("traveler_sword", 1)
	_expect(GameState.get_item_amount("traveler_sword") == 1, "Known item should enter inventory")
	GameState.add_item("missing_item", 10)
	_expect(GameState.get_item_amount("missing_item") == 0, "Unknown item must be rejected")
	_expect(GameState.equip_item("rowan_knight", "traveler_sword"), "Owned weapon should equip")
	_expect(GameState.get_equipped_stat_bonus("rowan_knight", "attack") == 4, "Weapon attack bonus must apply")

	GameState.record_monster_defeat("meadow_slime")
	GameState.record_monster_defeat("meadow_slime")
	GameState.record_monster_defeat("missing_monster")
	_expect(GameState.get_monster_defeats("meadow_slime") == 2, "Monster codex must count valid defeats")
	_expect(GameState.get_monster_defeats("missing_monster") == 0, "Unknown monster must not enter codex")


func _test_first_quest() -> void:
	_reset_state()
	_expect(MeadowTrial.get_status() == "available", "First quest should begin as available")
	MeadowTrial.advance()
	_expect(MeadowTrial.get_status() == "active", "Talking to Adele should start first quest")
	GameState.record_monster_defeat("meadow_slime")
	GameState.record_monster_defeat("goblin_scout")
	GameState.record_monster_defeat("restless_skeleton")
	_expect(MeadowTrial.get_status() == "ready", "Required meadow defeats should make quest ready")
	var old_gold := GameState.gold
	MeadowTrial.advance()
	_expect(MeadowTrial.get_status() == "completed", "Turning in first quest should complete it")
	_expect(GameState.gold == old_gold + MeadowTrial.GOLD_REWARD, "First quest gold reward must be granted once")
	_expect(GameState.get_item_amount(MeadowTrial.ITEM_REWARD_ID) == 1, "First quest item reward must be granted")
	MeadowTrial.advance()
	_expect(GameState.gold == old_gold + MeadowTrial.GOLD_REWARD, "Completed quest must not grant duplicate gold")
	_expect(GameState.get_item_amount(MeadowTrial.ITEM_REWARD_ID) == 1, "Completed quest must not grant duplicate items")


func _test_progression() -> void:
	_reset_state()
	var old_max_hp := GameState.player_max_hp
	GameState.add_experience(GameState.experience_to_next)
	_expect(GameState.player_level == 2, "Enough XP should level player")
	_expect(GameState.experience == 0, "Exact level threshold should leave zero XP")
	_expect(GameState.player_max_hp == old_max_hp + 10, "Level-up should increase max HP")
	_expect(GameState.player_hp == GameState.player_max_hp, "Level-up should heal to full")


func _test_corrupt_save_sanitization() -> void:
	GameState.dialogue_open = true
	GameState.menu_open = true
	GameState.load_from_dict({
		"version": GameState.SAVE_VERSION,
		"gold": -500,
		"unlocked_heroes": ["wanderer", "missing_hero", "wanderer", "rowan_knight"],
		"current_party": ["missing_hero", "rowan_knight", "rowan_knight", "wanderer"],
		"active_party_index": 99,
		"inventory": {
			"traveler_sword": 7,
			"wind_charm": 1,
			"wild_herb": -4,
			"missing_item": 99
		},
		"monster_codex": {
			"meadow_slime": 3,
			"missing_monster": 8
		},
		"equipment": {
			"rowan_knight": {
				"weapon": "traveler_sword",
				"armor": "missing_item",
				"relics": ["wind_charm", "wind_charm", "missing_item"]
			}
		},
		"world_state": {
			"map_id": "bootstrap_meadow",
			"player_x": 999999999.0,
			"player_y": -999999999.0,
			"flags": {"valid_flag": true, "false_flag": false}
		}
	})

	_expect(GameState.gold == 0, "Negative gold must be sanitized")
	_expect(GameState.unlocked_heroes == ["wanderer", "rowan_knight"], "Invalid and duplicate heroes must be removed")
	_expect(GameState.current_party == ["rowan_knight", "wanderer"], "Party must remove invalid and duplicate heroes")
	_expect(GameState.active_party_index == 1, "Active party index must be clamped")
	_expect(GameState.get_item_amount("traveler_sword") == 1, "Inventory must respect stack_limit")
	_expect(GameState.get_item_amount("wild_herb") == 0, "Negative inventory amount must be removed")
	_expect(GameState.get_item_amount("missing_item") == 0, "Unknown inventory item must be removed")
	_expect(GameState.get_monster_defeats("meadow_slime") == 3, "Valid codex progress must survive")
	_expect(GameState.get_monster_defeats("missing_monster") == 0, "Invalid codex entry must be removed")

	var gear := GameState.get_equipment("rowan_knight")
	_expect(String(gear.get("weapon", "")) == "traveler_sword", "Valid owned weapon must survive sanitation")
	_expect(String(gear.get("armor", "")).is_empty(), "Invalid armor must be removed")
	var relics: Array = gear.get("relics", [])
	_expect(relics.size() == 1 and String(relics[0]) == "wind_charm", "Relics must be valid unique and capped")
	_expect(GameState.get_player_position() == Vector2(100000.0, -100000.0), "Extreme player position must be clamped")
	_expect(String(GameState.world_state.get("map_id", "")) == "start_village", "Legacy bootstrap map id must migrate to start_village")
	_expect(not GameState.dialogue_open and not GameState.menu_open, "Transient UI state must reset on load")


func _test_save_round_trip() -> void:
	_reset_state()
	GameState.add_gold(37)
	GameState.add_item("wild_herb", 2)

	_expect(not SaveManager.save_game("../invalid"), "Unsafe save slot must be rejected")
	_expect(SaveManager.save_game("ci-regression"), "Regression save should succeed")

	GameState.add_gold(1000)
	GameState.add_item("wild_herb", 10)

	_expect(SaveManager.load_game("ci-regression"), "Regression load should succeed")
	_expect(GameState.gold == 37, "Save/load must restore gold")
	_expect(GameState.get_item_amount("wild_herb") == 2, "Save/load must restore inventory")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("GAMEPLAY REGRESSION TEST PASS")
		get_tree().quit(0)
		return

	for failure in failures:
		push_error(failure)
	print("GAMEPLAY REGRESSION TEST FAIL: %d issue(s)" % failures.size())
	get_tree().quit(1)
