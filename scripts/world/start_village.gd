extends Node2D

const MAP_SIZE := Vector2i(960, 540)
const TILE_SIZE := 16
const TILES := preload("res://assets/generated/tiles/world_tiles_v1.png")


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	_fill_tiles(Rect2i(0, 0, MAP_SIZE.x, MAP_SIZE.y), 0)
	_fill_tiles(Rect2i(0, 240, 960, 64), 1)
	_fill_tiles(Rect2i(432, 0, 80, 540), 1)
	_fill_tiles(Rect2i(352, 192, 240, 160), 2)

	_draw_house(Vector2i(120, 96), Vector2i(144, 96))
	_draw_house(Vector2i(616, 96), Vector2i(152, 96))
	_draw_house(Vector2i(640, 368), Vector2i(144, 96))

	_fill_tiles(Rect2i(64, 352, 192, 112), 3)
	for point in [
		Vector2i(48, 80), Vector2i(64, 112), Vector2i(48, 144),
		Vector2i(840, 96), Vector2i(864, 128), Vector2i(840, 160),
		Vector2i(824, 416), Vector2i(856, 432)
	]:
		_draw_tile(8, point - Vector2i(8, 8))

	for point in [Vector2i(320, 176), Vector2i(592, 176), Vector2i(304, 336), Vector2i(800, 336)]:
		_draw_tile(10, point)

	for point in [Vector2i(288, 252), Vector2i(832, 252), Vector2i(400, 350)]:
		_draw_tile(20, point)

	for point in [Vector2i(904, 224), Vector2i(936, 224)]:
		for y in range(0, 96, 16):
			_draw_tile(12, point + Vector2i(0, y))


func _draw_house(position: Vector2i, size: Vector2i) -> void:
	_fill_tiles(Rect2i(position.x, position.y, size.x, size.y), 14)
	_fill_tiles(Rect2i(position.x - 16, position.y - 16, size.x + 32, 32), 15)
	_draw_tile(16, Vector2i(position.x + size.x / 2 - 8, position.y + size.y - 16))
	_draw_tile(17, Vector2i(position.x + 24, position.y + 32))
	_draw_tile(17, Vector2i(position.x + size.x - 40, position.y + 32))


func _fill_tiles(rect: Rect2i, tile_index: int) -> void:
	var start_x := int(floor(float(rect.position.x) / TILE_SIZE) * TILE_SIZE)
	var start_y := int(floor(float(rect.position.y) / TILE_SIZE) * TILE_SIZE)
	var end_x := rect.end.x
	var end_y := rect.end.y
	for y in range(start_y, end_y, TILE_SIZE):
		for x in range(start_x, end_x, TILE_SIZE):
			_draw_tile(tile_index, Vector2i(x, y))


func _draw_tile(tile_index: int, position: Vector2i) -> void:
	var source := Rect2((tile_index % 8) * TILE_SIZE, (tile_index / 8) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
	draw_texture_rect_region(TILES, Rect2(position.x, position.y, TILE_SIZE, TILE_SIZE), source)
