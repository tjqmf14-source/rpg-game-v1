extends Node

const HEROES_PATH := "res://data/heroes.json"
const MONSTERS_PATH := "res://data/monsters.json"
const ITEMS_PATH := "res://data/items.json"

var heroes: Dictionary = {}
var monsters: Dictionary = {}
var items: Dictionary = {}


func _ready() -> void:
	reload()


func reload() -> void:
	heroes = _load_records(HEROES_PATH)
	monsters = _load_records(MONSTERS_PATH)
	items = _load_records(ITEMS_PATH)


func get_hero(hero_id: String) -> Dictionary:
	return heroes.get(hero_id, {})


func get_monster(monster_id: String) -> Dictionary:
	return monsters.get(monster_id, {})


func get_item(item_id: String) -> Dictionary:
	return items.get(item_id, {})


func _load_records(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("GameDatabase: missing data file: %s" % path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("GameDatabase: failed to open: %s" % path)
		return {}

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		push_error("GameDatabase: root must be an array: %s" % path)
		return {}

	var indexed: Dictionary = {}
	for record in parsed:
		if typeof(record) != TYPE_DICTIONARY:
			continue
		if not record.has("id"):
			continue
		var record_id := String(record["id"])
		if record_id.is_empty():
			continue
		indexed[record_id] = record

	return indexed
