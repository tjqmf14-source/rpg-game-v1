extends Node2D

const MAP_SIZE := Vector2i(960, 540)
const TILE_SIZE := 16
const TILES := preload("res://assets/generated/tiles/world_tiles_v1.png")
const BOSS_FLAG := "boss_ancient_warden_defeated"


func _ready() -> void:
	if GameState.has_world_flag(BOSS_FLAG):
		var boss := get_node_or_null("AncientWarden")
		if boss != null:
			boss.queue_free()
	queue_redraw()


func _draw() -> void:
	_fill_tiles(Rect2i(0, 0, MAP_SIZE.x, MAP_SIZE.y), 18)
	_fill_tiles(Rect2i(0, 0, 960, 48), 19)
	_fill_tiles(Rect2i(0, 492, 960, 48), 19)
	_fill_tiles(Rect2i(0, 0, 48, 540), 19)
	_fill_tiles(Rect2i(912, 0, 48, 540), 19)

	_fill_tiles(Rect2i(208, 112, 96, 176), 19)
	_fill_tiles(Rect2i(432, 252, 112, 176), 19)
	_fill_tiles(Rect2i(656, 96, 96, 144), 19)

	for point in [
		Vector2i(144, 128), Vector2i(352, 400), Vector2i(592, 128),
		Vector2i(816, 400), Vector2i(800, 144), Vector2i(576, 384)
	]:
		_draw_tile(11, point)

	for point in [Vector2i(112, 256), Vector2i(400, 176), Vector2i(608, 320), Vector2i(832, 256)]:
		_draw_tile(20, point)


func _fill_tiles(rect: Rect2i, tile_index: int) -> void:
	var start_x := int(floor(float(rect.position.x) / TILE_SIZE) * TILE_SIZE)
	var start_y := int(floor(float(rect.position.y) / TILE_SIZE) * TILE_SIZE)
	for y in range(start_y, rect.end.y, TILE_SIZE):
		for x in range(start_x, rect.end.x, TILE_SIZE):
			_draw_tile(tile_index, Vector2i(x, y))


func _draw_tile(tile_index: int, position: Vector2i) -> void:
	var source := Rect2((tile_index % 8) * TILE_SIZE, (tile_index / 8) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
	draw_texture_rect_region(TILES, Rect2(position.x, position.y, TILE_SIZE, TILE_SIZE), source)
