extends Label

const MeadowTrial = preload("res://scripts/quests/meadow_trial.gd")


func _process(_delta: float) -> void:
	var status := MeadowTrial.get_status()
	match status:
		"available":
			visible = false
		"completed":
			visible = true
			text = "초원의 위협  완료"
		_:
			visible = true
			text = MeadowTrial.get_tracker_text()
