extends SceneTree

var failures: Array[String] = []


func _init() -> void:
	_check_texture("res://assets/generated/tiles/world_tiles_v1.png", Vector2i(128, 128))
	_check_texture("res://assets/generated/characters/heroes_v1.png", Vector2i(192, 96))
	_check_texture("res://assets/generated/monsters/enemies_v1.png", Vector2i(64, 48))
	_check_texture("res://assets/generated/ui/ui_icons_v1.png", Vector2i(128, 16))
	_finish()


func _check_texture(path: String, expected_size: Vector2i) -> void:
	var texture := load(path) as Texture2D
	if texture == null:
		failures.append("Failed to load texture: %s" % path)
		return
	if Vector2i(texture.get_width(), texture.get_height()) != expected_size:
		failures.append("Unexpected texture size for %s: %dx%d" % [
			path,
			texture.get_width(),
			texture.get_height()
		])


func _finish() -> void:
	if failures.is_empty():
		print("ASSET INTEGRITY TEST PASS")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	print("ASSET INTEGRITY TEST FAIL: %d issue(s)" % failures.size())
	quit(1)
