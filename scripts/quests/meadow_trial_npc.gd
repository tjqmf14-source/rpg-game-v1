extends "res://scripts/interaction/interactable_npc.gd"

const MeadowTrial = preload("res://scripts/quests/meadow_trial.gd")


func interact() -> void:
	GameState.open_dialogue(speaker_name, MeadowTrial.advance())
