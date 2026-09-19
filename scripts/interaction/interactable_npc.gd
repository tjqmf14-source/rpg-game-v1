extends Area2D
class_name InteractableNpc

@export var speaker_name: String = "NPC"
@export_multiline var dialogue_text: String = "..."
@export var unlock_hero_id: String = ""
@export var reward_item_id: String = ""
@export var reward_once_flag: String = ""


func _ready() -> void:
	add_to_group("interactable")
	queue_redraw()


func interact() -> void:
	var first_claim := GameState.claim_world_flag(reward_once_flag)

	if first_claim:
		if not unlock_hero_id.is_empty():
			GameState.unlock_hero(unlock_hero_id)
		if not reward_item_id.is_empty():
			GameState.add_item(reward_item_id, 1)
			var equip_target := unlock_hero_id
			if equip_target.is_empty():
				equip_target = GameState.get_active_hero_id()
			GameState.equip_item(equip_target, reward_item_id)

	GameState.open_dialogue(speaker_name, dialogue_text)


func _draw() -> void:
	draw_rect(Rect2(-6, -7, 12, 14), Color("6f557c"))
	draw_rect(Rect2(-5, -6, 10, 5), Color("e3bf86"))
	draw_rect(Rect2(-6, -7, 12, 3), Color("403247"))
	draw_rect(Rect2(-4, 7, 3, 2), Color("352c32"))
	draw_rect(Rect2(1, 7, 3, 2), Color("352c32"))
