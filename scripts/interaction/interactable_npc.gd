extends Area2D
class_name InteractableNpc

const HERO_SHEET := preload("res://assets/generated/characters/heroes_v1.png")
const FRAME_SIZE := Vector2i(16, 24)

@export var speaker_name: String = "NPC"
@export_multiline var dialogue_text: String = "..."
@export var unlock_hero_id: String = ""
@export var reward_item_id: String = ""
@export var reward_once_flag: String = ""
@export_range(0, 3, 1) var visual_row: int = 3

var visual: Sprite2D


func _ready() -> void:
	add_to_group("interactable")
	_ensure_visual()


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


func _ensure_visual() -> void:
	visual = get_node_or_null("Visual") as Sprite2D
	if visual == null:
		visual = Sprite2D.new()
		visual.name = "Visual"
		add_child(visual)
	visual.texture = HERO_SHEET
	visual.region_enabled = true
	visual.region_rect = Rect2(0, visual_row * FRAME_SIZE.y, FRAME_SIZE.x, FRAME_SIZE.y)
	visual.centered = true
	visual.position = Vector2(0, -4)
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
