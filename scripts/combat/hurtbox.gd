extends Area2D
class_name Hurtbox

@export var actor_path: NodePath = NodePath("..")


func receive_damage(amount: int, source: Node = null) -> void:
	if amount <= 0:
		return

	var actor := get_actor()
	if actor != null and actor.has_method("take_damage"):
		actor.call("take_damage", amount, source)


func get_actor() -> Node:
	return get_node_or_null(actor_path)
