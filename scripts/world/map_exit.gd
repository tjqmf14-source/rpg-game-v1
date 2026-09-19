extends Area2D
class_name MapExit

@export var target_map_id: String = ""
@export var target_spawn: String = "SpawnDefault"

var triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if triggered or not body.is_in_group("player"):
		return
	if target_map_id.is_empty():
		push_error("MapExit: target_map_id is empty")
		return

	var game_root := get_tree().get_first_node_in_group("game_root")
	if game_root == null or not game_root.has_method("change_map"):
		push_error("MapExit: game root with change_map() not found")
		return

	triggered = true
	var changed := bool(game_root.call("change_map", target_map_id, target_spawn))
	if not changed:
		triggered = false
