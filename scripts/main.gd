extends Node2D

const TILE_SIZE := 16
const VIEWPORT_SIZE := Vector2i(480, 270)


func _ready() -> void:
	queue_redraw()
	_update_hud()


func _draw() -> void:
	# Placeholder environment aligned to the 16px world grid.
	draw_rect(Rect2(Vector2.ZERO, Vector2(VIEWPORT_SIZE)), Color("667a3f"))

	# Dirt road.
	draw_rect(Rect2(0, 112, 480, 48), Color("a98b5d"))
	draw_rect(Rect2(208, 0, 64, 270), Color("a98b5d"))

	# Small water area.
	draw_rect(Rect2(16, 16, 112, 64), Color("467b91"))
	for x in range(16, 128, TILE_SIZE):
		draw_line(Vector2(x, 16), Vector2(x, 80), Color(0.25, 0.43, 0.50, 0.35), 1.0)

	# 16px debug grid kept intentionally subtle during bootstrap.
	for x in range(0, VIEWPORT_SIZE.x + 1, TILE_SIZE):
		draw_line(Vector2(x, 0), Vector2(x, VIEWPORT_SIZE.y), Color(0, 0, 0, 0.05), 1.0)
	for y in range(0, VIEWPORT_SIZE.y + 1, TILE_SIZE):
		draw_line(Vector2(0, y), Vector2(VIEWPORT_SIZE.x, y), Color(0, 0, 0, 0.05), 1.0)


func _update_hud() -> void:
	var label := get_node_or_null("UI/Margin/VBox/Status") as Label
	if label == null:
		return
	label.text = "RELIC BOUND  |  Heroes %d  Monsters %d  Items %d" % [
		GameDatabase.heroes.size(),
		GameDatabase.monsters.size(),
		GameDatabase.items.size()
	]
