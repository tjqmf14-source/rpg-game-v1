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

var gold: int = 0
var unlocked_heroes: Array[String] = ["wanderer"]
var current_party: Array[String] = ["wanderer"]
var inventory: Dictionary = {}
var world_state: Dictionary = {
	"map_id": "bootstrap_meadow",
	"player_x": 240.0,
	"player_y": 135.0
}

var dialogue_open: bool = false

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
	unlocked_heroes.append(hero_id)
	hero_unlocked.emit(hero_id)
	return true


func add_item(item_id: String, amount: int = 1) -> void:
	if item_id.is_empty() or amount <= 0:
		return
	inventory[item_id] = int(inventory.get(item_id, 0)) + amount
	inventory_changed.emit(item_id, inventory[item_id])


func get_item_amount(item_id: String) -> int:
	return int(inventory.get(item_id, 0))


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
		"version": 2,
		"gold": gold,
		"unlocked_heroes": unlocked_heroes,
		"current_party": current_party,
		"inventory": inventory,
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
		current_party.append(String(hero_id))
	if current_party.is_empty():
		current_party.append("wanderer")

	inventory = Dictionary(data.get("inventory", {})).duplicate(true)
	world_state = Dictionary(data.get("world_state", {})).duplicate(true)

	player_level = maxi(1, int(data.get("player_level", 1)))
	experience = maxi(0, int(data.get("experience", 0)))
	experience_to_next = maxi(1, int(data.get("experience_to_next", 50)))
	player_max_hp = maxi(1, int(data.get("player_max_hp", 120)))
	player_hp = clampi(int(data.get("player_hp", player_max_hp)), 1, player_max_hp)

	dialogue_open = false
	gold_changed.emit(gold)
	player_hp_changed.emit(player_hp, player_max_hp)
	experience_changed.emit(experience, experience_to_next)
