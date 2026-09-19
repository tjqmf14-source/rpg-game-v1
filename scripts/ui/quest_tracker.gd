extends Label

const MeadowTrial = preload("res://scripts/quests/meadow_trial.gd")
const FirstDungeonTrial = preload("res://scripts/quests/first_dungeon_trial.gd")


func _process(_delta: float) -> void:
	var meadow_status := MeadowTrial.get_status()
	if meadow_status != "completed":
		match meadow_status:
			"available":
				visible = false
			_:
				visible = true
				text = MeadowTrial.get_tracker_text()
		return

	visible = true
	text = FirstDungeonTrial.get_tracker_text()
