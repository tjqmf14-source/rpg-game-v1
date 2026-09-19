extends Area2D
class_name InteractableNpc

@export var speaker_name: String = "NPC"
@export_multiline var dialogue_text: String = "..."

func _ready() -> void:
	add_to_group("interactable")
	queue_redraw()


func interact() -> void:
	GameState.open_dialogue(speaker_name, dialogue_text)


func _draw() -> void:
	# Temporary 16px NPC placeholder. Replaced by Sunnyside sprite animation.
	draw_rect(Rect2(-6, -7, 12, 14), Color("6f557c"))
	draw_rect(Rect2(-5, -6, 10, 5), Color("e3bf86"))
	draw_rect(Rect2(-6, -7, 12, 3), Color("403247"))
	draw_rect(Rect2(-4, 7, 3, 2), Color("352c32"))
	draw_rect(Rect2(1, 7, 3, 2), Color("352c32"))
