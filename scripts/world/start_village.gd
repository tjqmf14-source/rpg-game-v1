extends Node2D

const MAP_SIZE := Vector2i(960, 540)
const TILE_SIZE := 16


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(MAP_SIZE)), Color("6f8b45"))

	# Main roads.
	draw_rect(Rect2(0, 238, 960, 64), Color("ae9064"))
	draw_rect(Rect2(432, 0, 80, 540), Color("ae9064"))

	# Village square.
	draw_rect(Rect2(352, 190, 240, 160), Color("9e9578"))
	for x in range(352, 592, TILE_SIZE):
		draw_line(Vector2(x, 190), Vector2(x, 350), Color(0.2, 0.2, 0.18, 0.08), 1.0)
	for y in range(190, 350, TILE_SIZE):
		draw_line(Vector2(352, y), Vector2(592, y), Color(0.2, 0.2, 0.18, 0.08), 1.0)

	# Houses matching collision footprints.
	_draw_house(Vector2(120, 90), Vector2(144, 96), Color("b96745"))
	_draw_house(Vector2(616, 86), Vector2(152, 96), Color("a85d44"))
	_draw_house(Vector2(642, 360), Vector2(136, 92), Color("8f5a43"))

	# Pond.
	draw_rect(Rect2(64, 350, 192, 112), Color("4c8192"))
	draw_rect(Rect2(80, 366, 160, 80), Color("5793a4"))

	# Trees / vegetation placeholders aligned to 16px grid.
	for point in [
		Vector2(48, 80), Vector2(64, 112), Vector2(48, 144),
		Vector2(840, 96), Vector2(864, 128), Vector2(840, 160),
		Vector2(824, 416), Vector2(856, 432)
	]:
		draw_circle(point, 15.0, Color("3f6737"))
		draw_rect(Rect2(point + Vector2(-3, 10), Vector2(6, 12)), Color("5e4932"))

	# East gate.
	draw_rect(Rect2(904, 220, 24, 100), Color("6a5035"))
	draw_rect(Rect2(936, 220, 24, 100), Color("6a5035"))


func _draw_house(position: Vector2, size: Vector2, roof_color: Color) -> void:
	draw_rect(Rect2(position, size), Color("e0cfad"))
	draw_rect(Rect2(position + Vector2(-8, -18), Vector2(size.x + 16, 28)), roof_color)
	draw_rect(Rect2(position + Vector2(size.x * 0.5 - 10, size.y - 28), Vector2(20, 28)), Color("68452f"))
