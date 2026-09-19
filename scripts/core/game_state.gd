extends Node

signal gold_changed(new_value: int)
signal hero_unlocked(hero_id: String)
signal inventory_changed(item_id: String, new_amount: int)
signal dialogue_opened(speaker: String, text: String)
signal dialogue_closed
signal player_hp_changed(current_hp: int, max_hp: int)
signal experience_changed(current_xp: int, next_xp: int)
signal player_leveled_up(new_level: int)
signal player_defeated
signal party_changed
signal active_hero_changed(hero_id: String)
signal codex_updated(monster_id: String, defeats: int)
signal equipment_changed(hero_id: String)

var gold: int = 0
var unlocked_heroes: Array[String] = ["wanderer"]
var current_party: Array[String] = ["wanderer"]
var active_party_index: int = 0
var inventory: Dictionary = {}
var monster_codex: Dictionary = {}
var equipment: Dictionary = {}
var world_state: Dictionary = {
	"map_id": "bootstrap_meadow",
	"player_x": 240.0,
	"player_y": 135.0,
	"flags": {}
}

var dialogue_open: bool = false
var menu_open: bool = false

var player_level: int = 1
var experience: int = 0
var experience_to_next: int = 50
var player_max_hp: int = 120
var player_hp: int = 120


func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	gold += amount
	gold_changed.emit(gold)


func spend_gold(amount: int) -> bool:
	if amount <= 0 or amount > gold:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true


func unlock_hero(hero_id: String) -> bool:
	if hero_id.is_empty() or hero_id in unlocked_heroes:
		return false
	if GameDatabase.get_hero(hero_id).is_empty():
		return false

	unlocked_heroes.append(hero_id)
	_ensure_equipment(hero_id)

	if current_party.size() < 4:
		current_party.append(hero_id)
		party_changed.emit()

	hero_unlocked.emit(hero_id)
	return true


func get_active_hero_id() -> String:
	if current_party.is_empty():
		return "wanderer"
	active_party_index = clampi(active_party_index, 0, current_party.size() - 1)
	return current_party[active_party_index]


func set_active_party_slot(index: int) -> bool:
	if index < 0 or index >= current_party.size():
		return false
	if index == active_party_index:
		return true
	active_party_index = index
	active_hero_changed.emit(get_active_hero_id())
	return true


func set_party(hero_ids: Array[String]) -> bool:
	var next_party: Array[String] = []
	for hero_id in hero_ids:
		if hero_id not in unlocked_heroes or hero_id in next_party:
			continue
		next_party.append(hero_id)
		if next_party.size() == 4:
			break

	if next_party.is_empty():
		return false

	current_party = next_party
	active_party_index = mini(active_party_index, current_party.size() - 1)
	party_changed.emit()
	active_hero_changed.emit(get_active_hero_id())
	return true


func add_item(item_id: String, amount: int = 1) -> void:
	if item_id.is_empty() or amount <= 0:
		return
	if GameDatabase.get_item(item_id).is_empty():
		return
	inventory[item_id] = int(inventory.get(item_id, 0)) + amount
	inventory_changed.emit(item_id, inventory[item_id])


func get_item_amount(item_id: String) -> int:
	return int(inventory.get(item_id, 0))


func equip_item(hero_id: String, item_id: String) -> bool:
	if hero_id not in unlocked_heroes or get_item_amount(item_id) <= 0:
		return false

	var item := GameDatabase.get_item(item_id)
	if item.is_empty():
		return false

	_ensure_equipment(hero_id)
	var gear: Dictionary = equipment[hero_id]
	var item_type := String(item.get("type", ""))

	match item_type:
		"weapon":
			gear["weapon"] = item_id
		"armor":
			gear["armor"] = item_id
		"relic":
			var relics: Array = gear.get("relics", [])
			if item_id in relics:
				return true
			if relics.size() >= 2:
				relics.pop_front()
			relics.append(item_id)
			gear["relics"] = relics
		_:
			return false

	equipment[hero_id] = gear
	equipment_changed.emit(hero_id)
	if hero_id == get_active_hero_id():
		active_hero_changed.emit(hero_id)
	return true


func get_equipment(hero_id: String) -> Dictionary:
	_ensure_equipment(hero_id)
	return Dictionary(equipment.get(hero_id, {})).duplicate(true)


func get_equipped_stat_bonus(hero_id: String, stat_name: String) -> int:
	_ensure_equipment(hero_id)
	var total := 0
	var gear: Dictionary = equipment.get(hero_id, {})

	for slot in ["weapon", "armor"]:
		var item_id := String(gear.get(slot, ""))
		if item_id.is_empty():
			continue
		var item := GameDatabase.get_item(item_id)
		var stats: Dictionary = item.get("stats", {})
		total += int(stats.get(stat_name, 0))

	for relic_id in gear.get("relics", []):
		var relic := GameDatabase.get_item(String(relic_id))
		var stats: Dictionary = relic.get("stats", {})
		total += int(stats.get(stat_name, 0))

	return total


func record_monster_defeat(monster_id: String) -> void:
	if monster_id.is_empty() or GameDatabase.get_monster(monster_id).is_empty():
		return
	monster_codex[monster_id] = int(monster_codex.get(monster_id, 0)) + 1
	codex_updated.emit(monster_id, monster_codex[monster_id])


func get_monster_defeats(monster_id: String) -> int:
	return int(monster_codex.get(monster_id, 0))


func claim_world_flag(flag_id: String) -> bool:
	if flag_id.is_empty():
		return true

	var flags: Dictionary = world_state.get("flags", {})
	if bool(flags.get(flag_id, false)):
		return false

	flags[flag_id] = true
	world_state["flags"] = flags
	return true


func add_experience(amount: int) -> void:
	if amount <= 0:
		return

	experience += amount
	while experience >= experience_to_next:
		experience -= experience_to_next
		player_level += 1
		experience_to_next = 50 + (player_level - 1) * 25
		player_max_hp += 10
		player_hp = player_max_hp
		player_leveled_up.emit(player_level)
		player_hp_changed.emit(player_hp, player_max_hp)

	experience_changed.emit(experience, experience_to_next)


func damage_player(amount: int) -> bool:
	if amount <= 0 or player_hp <= 0:
		return false

	player_hp = maxi(0, player_hp - amount)
	player_hp_changed.emit(player_hp, player_max_hp)

	if player_hp == 0:
		player_defeated.emit()
		return true
	return false


func heal_player(amount: int) -> void:
	if amount <= 0 or player_hp <= 0:
		return
	player_hp = mini(player_max_hp, player_hp + amount)
	player_hp_changed.emit(player_hp, player_max_hp)


func respawn_player() -> void:
	player_hp = player_max_hp
	player_hp_changed.emit(player_hp, player_max_hp)


func open_dialogue(speaker: String, text: String) -> void:
	dialogue_open = true
	dialogue_opened.emit(speaker, text)


func close_dialogue() -> void:
	if not dialogue_open:
		return
	dialogue_open = false
	dialogue_closed.emit()


func set_player_position(value: Vector2) -> void:
	world_state["player_x"] = value.x
	world_state["player_y"] = value.y


func get_player_position() -> Vector2:
	return Vector2(
		float(world_state.get("player_x", 240.0)),
		float(world_state.get("player_y", 135.0))
	)


func to_save_dict() -> Dictionary:
	return {
		"version": 3,
		"gold": gold,
		"unlocked_heroes": unlocked_heroes,
		"current_party": current_party,
		"active_party_index": active_party_index,
		"inventory": inventory,
		"monster_codex": monster_codex,
		"equipment": equipment,
		"world_state": world_state,
		"player_level": player_level,
		"experience": experience,
		"experience_to_next": experience_to_next,
		"player_max_hp": player_max_hp,
		"player_hp": player_hp
	}


func load_from_dict(data: Dictionary) -> void:
	gold = int(data.get("gold", 0))

	unlocked_heroes.clear()
	for hero_id in data.get("unlocked_heroes", ["wanderer"]):
		unlocked_heroes.append(String(hero_id))
	if unlocked_heroes.is_empty():
		unlocked_heroes.append("wanderer")

	current_party.clear()
	for hero_id in data.get("current_party", ["wanderer"]):
		if String(hero_id) in unlocked_heroes:
			current_party.append(String(hero_id))
	if current_party.is_empty():
		current_party.append("wanderer")

	active_party_index = clampi(int(data.get("active_party_index", 0)), 0, current_party.size() - 1)
	inventory = Dictionary(data.get("inventory", {})).duplicate(true)
	monster_codex = Dictionary(data.get("monster_codex", {})).duplicate(true)
	equipment = Dictionary(data.get("equipment", {})).duplicate(true)
	world_state = Dictionary(data.get("world_state", world_state)).duplicate(true)
	if not world_state.has("flags"):
		world_state["flags"] = {}

	for hero_id in unlocked_heroes:
		_ensure_equipment(hero_id)

	player_level = maxi(1, int(data.get("player_level", 1)))
	experience = maxi(0, int(data.get("experience", 0)))
	experience_to_next = maxi(1, int(data.get("experience_to_next", 50)))
	player_max_hp = maxi(1, int(data.get("player_max_hp", 120)))
	player_hp = clampi(int(data.get("player_hp", player_max_hp)), 1, player_max_hp)

	dialogue_open = false
	gold_changed.emit(gold)
	player_hp_changed.emit(player_hp, player_max_hp)
	experience_changed.emit(experience, experience_to_next)
	party_changed.emit()
	active_hero_changed.emit(get_active_hero_id())


func _ensure_equipment(hero_id: String) -> void:
	if equipment.has(hero_id):
		return
	equipment[hero_id] = {
		"weapon": "",
		"armor": "",
		"relics": []
	}
