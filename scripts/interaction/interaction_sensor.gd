extends Area2D
class_name InteractionSensor

var candidates: Array[Area2D] = []


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return
	if event.physical_keycode != KEY_E and event.keycode != KEY_E:
		return

	if GameState.dialogue_open:
		GameState.close_dialogue()
		get_viewport().set_input_as_handled()
		return

	var target := _nearest_candidate()
	if target == null:
		return

	if target.has_method("interact"):
		target.call("interact")
		get_viewport().set_input_as_handled()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable") and area not in candidates:
		candidates.append(area)


func _on_area_exited(area: Area2D) -> void:
	candidates.erase(area)


func _nearest_candidate() -> Area2D:
	var nearest: Area2D = null
	var nearest_distance := INF

	for candidate in candidates:
		if not is_instance_valid(candidate):
			continue
		var distance := global_position.distance_squared_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate

	return nearest
