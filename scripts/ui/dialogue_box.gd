extends PanelContainer
class_name DialogueBox

@onready var speaker_label: Label = %Speaker
@onready var body_label: Label = %Body


func _ready() -> void:
	GameState.dialogue_opened.connect(_on_dialogue_opened)
	GameState.dialogue_closed.connect(_on_dialogue_closed)
	hide()


func _on_dialogue_opened(speaker: String, text: String) -> void:
	speaker_label.text = speaker
	body_label.text = text
	show()


func _on_dialogue_closed() -> void:
	hide()
