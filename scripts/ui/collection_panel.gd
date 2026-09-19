extends PanelContainer
class_name CollectionPanel

@onready var title_label: Label = %Title
@onready var body_label: Label = %Body

var mode: String = "party"


func _ready() -> void:
	hide()
	GameState.party_changed.connect(_refresh_if_visible)
	GameState.active_hero_changed.connect(func(_hero_id: String) -> void: _refresh_if_visible())
	GameState.inventory_changed.connect(func(_item_id: String, _amount: int) -> void: _refresh_if_visible())
	GameState.codex_updated.connect(func(_monster_id: String, _defeats: int) -> void: _refresh_if_visible())
	GameState.equipment_changed.connect(func(_hero_id: String) -> void: _refresh_if_visible())


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return
	if GameState.dialogue_open:
		return

	match event.keycode:
		KEY_P:
			_toggle_mode("party")
		KEY_I:
			_toggle_mode("inventory")
		KEY_C:
			_toggle_mode("codex")
		KEY_ESCAPE:
			if visible:
				_close()
			else:
				return
		_:
			return

	get_viewport().set_input_as_handled()


func _toggle_mode(next_mode: String) -> void:
	if visible and mode == next_mode:
		_close()
		return

	mode = next_mode
	GameState.menu_open = true
	show()
	_refresh()


func _close() -> void:
	hide()
	GameState.menu_open = false


func _refresh_if_visible() -> void:
	if visible:
		_refresh()


func _refresh() -> void:
	match mode:
		"party":
			_refresh_party()
		"inventory":
			_refresh_inventory()
		"codex":
			_refresh_codex()


func _refresh_party() -> void:
	title_label.text = "PARTY / HEROES"
	var lines: Array[String] = []
	lines.append("숫자 1~4: 전투 캐릭터 교체")
	lines.append("")

	for index in range(GameState.current_party.size()):
		var hero_id := GameState.current_party[index]
		var hero := GameDatabase.get_hero(hero_id)
		var marker := "▶" if index == GameState.active_party_index else " "
		var gear := GameState.get_equipment(hero_id)
		var weapon_id := String(gear.get("weapon", ""))
		var armor_id := String(gear.get("armor", ""))
		var weapon_name := "-" if weapon_id.is_empty() else String(GameDatabase.get_item(weapon_id).get("name", weapon_id))
		var armor_name := "-" if armor_id.is_empty() else String(GameDatabase.get_item(armor_id).get("name", armor_id))
		lines.append("%s %d. %s  [%s]" % [marker, index + 1, String(hero.get("name", hero_id)), String(hero.get("role", ""))])
		lines.append("    무기: %s / 방어구: %s" % [weapon_name, armor_name])

	lines.append("")
	lines.append("해금 영웅: %d / %d" % [GameState.unlocked_heroes.size(), GameDatabase.heroes.size()])
	body_label.text = "\n".join(lines)


func _refresh_inventory() -> void:
	title_label.text = "INVENTORY / EQUIPMENT"
	var lines: Array[String] = []
	var item_ids := GameState.inventory.keys()
	item_ids.sort()

	if item_ids.is_empty():
		lines.append("보유 아이템이 없습니다.")
	else:
		for raw_id in item_ids:
			var item_id := String(raw_id)
			var item := GameDatabase.get_item(item_id)
			lines.append("%s  x%d  [%s]" % [
				String(item.get("name", item_id)),
				GameState.get_item_amount(item_id),
				String(item.get("type", "unknown"))
			])

	lines.append("")
	lines.append("현재 장비는 영웅 영입 보상 획득 시 자동 장착됩니다.")
	body_label.text = "\n".join(lines)


func _refresh_codex() -> void:
	title_label.text = "MONSTER CODEX"
	var lines: Array[String] = []
	var monster_ids := GameDatabase.monsters.keys()
	monster_ids.sort()

	for raw_id in monster_ids:
		var monster_id := String(raw_id)
		var monster := GameDatabase.get_monster(monster_id)
		var defeats := GameState.get_monster_defeats(monster_id)

		if defeats <= 0:
			lines.append("???  미발견")
			continue

		var line := "%s  처치 %d" % [String(monster.get("name", monster_id)), defeats]
		if defeats >= 3:
			line += "  / 속성 %s" % String(monster.get("element", "?"))
		if defeats >= 5:
			var drops: Array = monster.get("drops", [])
			line += "  / 드롭 %s" % ", ".join(PackedStringArray(drops))
		lines.append(line)

	body_label.text = "\n".join(lines)
