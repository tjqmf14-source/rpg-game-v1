extends Node

signal gold_changed(new_value: int)
signal hero_unlocked(hero_id: String)
signal inventory_changed(item_id: String, new_amount: int)
signal dialogue_opened(speaker: String, text: String)
signal dialogue_closed

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
		"version": 1,
		"gold": gold,
		"unlocked_heroes": unlocked_heroes,
		"current_party": current_party,
		"inventory": inventory,
		"world_state": world_state
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

	dialogue_open = false
	gold_changed.emit(gold)
