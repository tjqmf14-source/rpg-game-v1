extends Node2D

const MAP_SIZE := Vector2i(960, 540)
const TILE_SIZE := 16


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(MAP_SIZE)), Color("73944a"))

	# Road from village into the field.
	draw_rect(Rect2(0, 238, 960, 64), Color("aa8e62"))

	# River and bridge.
	draw_rect(Rect2(446, 0, 84, 540), Color("477f96"))
	for y in range(0, 540, 24):
		draw_line(Vector2(454, y), Vector2(522, y + 8), Color(0.7, 0.9, 0.95, 0.18), 2.0)
	draw_rect(Rect2(430, 232, 116, 76), Color("8a623c"))
	for x in range(438, 540, 16):
		draw_rect(Rect2(x, 238, 10, 64), Color("aa7b48"))

	# Flower/grass patches.
	for point in [
		Vector2(176, 120), Vector2(220, 96), Vector2(300, 390),
		Vector2(650, 104), Vector2(760, 360), Vector2(850, 164)
	]:
		draw_circle(point, 10.0, Color("5f823e"))
		draw_circle(point + Vector2(4, -2), 2.0, Color("e6d38d"))

	# Rock clusters matching collision areas.
	_draw_rock(Vector2(246, 330), Vector2(92, 58))
	_draw_rock(Vector2(696, 334), Vector2(112, 64))

	# West gate markers.
	draw_rect(Rect2(0, 214, 18, 112), Color("5e4a34"))
	draw_rect(Rect2(32, 214, 18, 112), Color("5e4a34"))


func _draw_rock(position: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(position, size), Color("6f7168"))
	draw_rect(Rect2(position + Vector2(8, 8), size - Vector2(16, 16)), Color("85877d"))
