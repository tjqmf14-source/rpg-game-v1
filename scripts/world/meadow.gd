extends Node2D

const MAP_SIZE := Vector2i(960, 540)
const TILE_SIZE := 16
const TILES := preload("res://assets/generated/tiles/world_tiles_v1.png")


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	_fill_tiles(Rect2i(0, 0, MAP_SIZE.x, MAP_SIZE.y), 0)
	_fill_tiles(Rect2i(0, 240, 960, 64), 1)
	_fill_tiles(Rect2i(448, 0, 80, 540), 3)

	for y in range(240, 304, 16):
		for x in range(432, 544, 16):
			_draw_tile(13, Vector2i(x, y))

	for point in [
		Vector2i(176, 120), Vector2i(224, 96), Vector2i(304, 400),
		Vector2i(656, 112), Vector2i(768, 368), Vector2i(848, 160)
	]:
		_draw_tile(10, point)

	for point in [Vector2i(256, 336), Vector2i(288, 352), Vector2i(704, 336), Vector2i(752, 352)]:
		_draw_tile(11, point)

	for point in [Vector2i(160, 352), Vector2i(624, 112), Vector2i(848, 400)]:
		_draw_tile(9, point)

	for point in [Vector2i(0, 224), Vector2i(32, 224)]:
		for y in range(0, 96, 16):
			_draw_tile(12, point + Vector2i(0, y))


func _fill_tiles(rect: Rect2i, tile_index: int) -> void:
	var start_x := int(floor(float(rect.position.x) / TILE_SIZE) * TILE_SIZE)
	var start_y := int(floor(float(rect.position.y) / TILE_SIZE) * TILE_SIZE)
	for y in range(start_y, rect.end.y, TILE_SIZE):
		for x in range(start_x, rect.end.x, TILE_SIZE):
			_draw_tile(tile_index, Vector2i(x, y))


func _draw_tile(tile_index: int, position: Vector2i) -> void:
	var source := Rect2((tile_index % 8) * TILE_SIZE, (tile_index / 8) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
	draw_texture_rect_region(TILES, Rect2(position.x, position.y, TILE_SIZE, TILE_SIZE), source)
