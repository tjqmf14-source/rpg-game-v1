extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var heroes := _load_array("res://data/heroes.json")
	var monsters := _load_array("res://data/monsters.json")
	var items := _load_array("res://data/items.json")

	var hero_index := _index_records("heroes", heroes)
	var monster_index := _index_records("monsters", monsters)
	var item_index := _index_records("items", items)

	_validate_heroes(hero_index)
	_validate_monsters(monster_index, item_index)
	_validate_items(item_index)

	_finish()


func _load_array(path: String) -> Array:
	if not FileAccess.file_exists(path):
		failures.append("Missing data file: %s" % path)
		return []

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		failures.append("Cannot open data file: %s" % path)
		return []

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		failures.append("Data root must be an array: %s" % path)
		return []

	return parsed


func _index_records(label: String, records: Array) -> Dictionary:
	var indexed: Dictionary = {}
	for record in records:
		if typeof(record) != TYPE_DICTIONARY:
			failures.append("%s contains a non-dictionary record" % label)
			continue

		var record_id := String(record.get("id", ""))
		if record_id.is_empty():
			failures.append("%s contains an empty id" % label)
			continue
		if indexed.has(record_id):
			failures.append("%s contains duplicate id: %s" % [label, record_id])
			continue
		if String(record.get("name", "")).is_empty():
			failures.append("%s/%s is missing name" % [label, record_id])

		indexed[record_id] = record

	return indexed


func _validate_heroes(heroes: Dictionary) -> void:
	if not heroes.has("wanderer"):
		failures.append("Starter hero 'wanderer' is missing")

	for hero_id in heroes:
		var hero: Dictionary = heroes[hero_id]
		var stats = hero.get("base_stats", {})
		if typeof(stats) != TYPE_DICTIONARY:
			failures.append("Hero %s has invalid base_stats" % hero_id)
			continue
		for stat_name in ["hp", "attack", "defense", "speed"]:
			if int(stats.get(stat_name, 0)) <= 0:
				failures.append("Hero %s has invalid %s" % [hero_id, stat_name])


func _validate_monsters(monsters: Dictionary, items: Dictionary) -> void:
	for monster_id in monsters:
		var monster: Dictionary = monsters[monster_id]
		var stats = monster.get("base_stats", {})
		if typeof(stats) != TYPE_DICTIONARY:
			failures.append("Monster %s has invalid base_stats" % monster_id)
		else:
			for stat_name in ["hp", "attack", "defense", "speed"]:
				if int(stats.get(stat_name, 0)) <= 0:
					failures.append("Monster %s has invalid %s" % [monster_id, stat_name])

		var drops = monster.get("drops", [])
		if typeof(drops) != TYPE_ARRAY:
			failures.append("Monster %s drops must be an array" % monster_id)
			continue
		for raw_drop_id in drops:
			var drop_id := String(raw_drop_id)
			if not items.has(drop_id):
				failures.append("Monster %s references missing drop item: %s" % [monster_id, drop_id])


func _validate_items(items: Dictionary) -> void:
	var valid_types := [
		"material",
		"relic_material",
		"weapon",
		"armor",
		"relic",
		"consumable",
		"quest"
	]

	for item_id in items:
		var item: Dictionary = items[item_id]
		var item_type := String(item.get("type", ""))
		if item_type not in valid_types:
			failures.append("Item %s has invalid type: %s" % [item_id, item_type])
		if int(item.get("stack_limit", 0)) <= 0:
			failures.append("Item %s has invalid stack_limit" % item_id)

		var stats = item.get("stats", {})
		if typeof(stats) == TYPE_DICTIONARY:
			for stat_name in stats:
				if int(stats[stat_name]) < 0:
					failures.append("Item %s has negative stat %s" % [item_id, stat_name])


func _finish() -> void:
	if failures.is_empty():
		print("DATA INTEGRITY TEST PASS")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	print("DATA INTEGRITY TEST FAIL: %d issue(s)" % failures.size())
	quit(1)
