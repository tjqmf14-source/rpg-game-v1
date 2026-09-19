extends RefCounted
class_name FirstDungeonTrial

const UNLOCK_FLAG := "quest_meadow_trial_completed"
const BOSS_FLAG := "boss_ancient_warden_defeated"
const BOSS_NAME := "고대 수호자"


static func get_status() -> String:
	if not GameState.has_world_flag(UNLOCK_FLAG):
		return "locked"
	if GameState.has_world_flag(BOSS_FLAG):
		return "completed"
	return "active"


static func get_tracker_text() -> String:
	match get_status():
		"locked":
			return "첫 던전  잠김"
		"completed":
			return "첫 던전  고대 수호자 처치 완료"
		_:
			return "첫 던전  고대 수호자 처치 0/1"
