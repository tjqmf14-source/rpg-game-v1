extends Node2D

const TILE_SIZE := 16
const VIEWPORT_SIZE := Vector2i(480, 270)

@onready var player: CharacterBody2D = $Player
@onready var toast_label: Label = $UI/Toast


func _ready() -> void:
	queue_redraw()
	GameState.player_leveled_up.connect(_on_player_leveled_up)
	_update_hud()


func _process(_delta: float) -> void:
	_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return

	if event.keycode == KEY_F5:
		GameState.set_player_position(player.position)
		var ok := SaveManager.save_game()
		_show_toast("Saved" if ok else "Save failed")
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_F9:
		var ok := SaveManager.load_game()
		if ok:
			player.position = GameState.get_player_position()
			_show_toast("Loaded")
		else:
			_show_toast("No save data")
		get_viewport().set_input_as_handled()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(VIEWPORT_SIZE)), Color("667a3f"))

	draw_rect(Rect2(0, 112, 480, 48), Color("a98b5d"))
	draw_rect(Rect2(208, 0, 64, 270), Color("a98b5d"))

	draw_rect(Rect2(16, 16, 112, 64), Color("467b91"))
	for x in range(16, 128, TILE_SIZE):
		draw_line(Vector2(x, 16), Vector2(x, 80), Color(0.25, 0.43, 0.50, 0.35), 1.0)

	for x in range(0, VIEWPORT_SIZE.x + 1, TILE_SIZE):
		draw_line(Vector2(x, 0), Vector2(x, VIEWPORT_SIZE.y), Color(0, 0, 0, 0.05), 1.0)
	for y in range(0, VIEWPORT_SIZE.y + 1, TILE_SIZE):
		draw_line(Vector2(0, y), Vector2(VIEWPORT_SIZE.x, y), Color(0, 0, 0, 0.05), 1.0)


func _update_hud() -> void:
	var label := get_node_or_null("UI/Margin/VBox/Status") as Label
	if label == null:
		return

	label.text = "Lv.%d  HP %d/%d  XP %d/%d  Gold %d" % [
		GameState.player_level,
		GameState.player_hp,
		GameState.player_max_hp,
		GameState.experience,
		GameState.experience_to_next,
		GameState.gold
	]


func _show_toast(message: String) -> void:
	toast_label.text = message
	toast_label.show()
	get_tree().create_timer(1.5).timeout.connect(func() -> void: toast_label.hide())


func _on_player_leveled_up(new_level: int) -> void:
	_show_toast("Level Up! Lv.%d" % new_level)
