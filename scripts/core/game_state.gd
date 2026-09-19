extends Node

signal gold_changed(new_value: int)
signal hero_unlocked(hero_id: String)
signal inventory_changed(item_id: String, new_amount: int)

var gold: int = 0
var unlocked_heroes: Array[String] = ["wanderer"]
var current_party: Array[String] = ["wanderer"]
var inventory: Dictionary = {}


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
