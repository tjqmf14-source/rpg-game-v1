extends Node2D

const MAP_SCENES := {
	"start_village": "res://scenes/world/start_village.tscn",
	"meadow": "res://scenes/world/meadow.tscn"
}

@onready var world_root: Node2D = $WorldRoot
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var toast_label: Label = $UI/Toast

var current_map: Node2D
var current_map_id: String = ""


func _ready() -> void:
	add_to_group("game_root")
	GameState.player_leveled_up.connect(_on_player_leveled_up)
	GameState.hero_unlocked.connect(_on_hero_unlocked)

	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 960
	camera.limit_bottom = 540

	var saved_map_id := _normalize_map_id(String(GameState.world_state.get("map_id", "start_village")))
	_load_map(saved_map_id, "", true)
	_update_hud()


func _process(_delta: float) -> void:
	_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return

	if event.keycode == KEY_F5:
		GameState.world_state["map_id"] = current_map_id
		GameState.set_player_position(player.position)
		var ok := SaveManager.save_game()
		_show_toast("Saved" if ok else "Save failed")
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_F9:
		var ok := SaveManager.load_game()
		if ok:
			var loaded_map_id := _normalize_map_id(String(GameState.world_state.get("map_id", "start_village")))
			_load_map(loaded_map_id, "", true)
			_show_toast("Loaded")
		else:
			_show_toast("No save data")
		get_viewport().set_input_as_handled()


func change_map(map_id: String, spawn_name: String = "SpawnDefault") -> bool:
	if not MAP_SCENES.has(map_id):
		push_error("Main: rejected unknown map id: %s" % map_id)
		return false
	return _load_map(map_id, spawn_name, false)


func get_current_map_id() -> String:
	return current_map_id


func respawn_player() -> void:
	var respawned := _load_map("start_village", "SpawnDefault", false)
	if not respawned:
		push_error("Main: failed to respawn player in start village")
	GameState.respawn_player()
	_show_toast("Returned to village")


func _load_map(map_id: String, spawn_name: String, restore_saved_position: bool) -> bool:
	var scene_path := String(MAP_SCENES.get(map_id, ""))
	if scene_path.is_empty():
		push_error("Main: unknown map id: %s" % map_id)
		return false

	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_error("Main: failed to load map scene: %s" % scene_path)
		return false

	var next_map := packed.instantiate() as Node2D
	if next_map == null:
		push_error("Main: failed to instantiate map scene: %s" % scene_path)
		return false

	if current_map != null and is_instance_valid(current_map):
		var old_map := current_map
		world_root.remove_child(old_map)
		old_map.queue_free()

	current_map = next_map
	world_root.add_child(current_map)
	current_map_id = map_id
	GameState.world_state["map_id"] = map_id

	if restore_saved_position:
		player.position = GameState.get_player_position()
	else:
		var spawn := current_map.get_node_or_null(spawn_name) as Marker2D
		if spawn == null:
			spawn = current_map.get_node_or_null("SpawnDefault") as Marker2D
		if spawn == null:
			push_error("Main: map %s has no usable spawn point" % map_id)
			return false
		player.global_position = spawn.global_position

	GameState.set_player_position(player.position)
	return true


func _normalize_map_id(map_id: String) -> String:
	if map_id == "bootstrap_meadow":
		return "start_village"
	if MAP_SCENES.has(map_id):
		return map_id
	return "start_village"


func _update_hud() -> void:
	var label := get_node_or_null("UI/Margin/VBox/Status") as Label
	if label == null:
		return

	var hero := GameDatabase.get_hero(GameState.get_active_hero_id())
	label.text = "%s  Lv.%d  HP %d/%d  XP %d/%d  Gold %d  [%s]" % [
		String(hero.get("name", "방랑자")),
		GameState.player_level,
		GameState.player_hp,
		GameState.player_max_hp,
		GameState.experience,
		GameState.experience_to_next,
		GameState.gold,
		current_map_id
	]


func _show_toast(message: String) -> void:
	toast_label.text = message
	toast_label.show()
	get_tree().create_timer(1.5).timeout.connect(func() -> void: toast_label.hide())


func _on_player_leveled_up(new_level: int) -> void:
	_show_toast("Level Up! Lv.%d" % new_level)


func _on_hero_unlocked(hero_id: String) -> void:
	var hero := GameDatabase.get_hero(hero_id)
	_show_toast("%s joined!" % String(hero.get("name", hero_id)))
