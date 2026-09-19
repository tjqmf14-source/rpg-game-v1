extends RefCounted
class_name MeadowTrial

const START_FLAG := "quest_meadow_trial_started"
const COMPLETE_FLAG := "quest_meadow_trial_completed"
const GOLD_REWARD := 25
const ITEM_REWARD_ID := "wind_charm"
const REQUIRED_DEFEATS := {
	"meadow_slime": 1,
	"goblin_scout": 1,
	"restless_skeleton": 1
}

const INTRO_TEXT := "동쪽 초원에 몬스터가 늘었네. 슬라임, 고블린, 해골을 각각 한 마리씩 정리하고 돌아와 주게."
const COMPLETE_TEXT := "초원 길이 다시 안전해졌군. 약속한 보상일세. 이 바람의 부적도 가져가게."
const DONE_TEXT := "덕분에 동쪽 길이 한결 조용해졌네. 고맙네."


static func get_status() -> String:
	var flags := _flags()
	if bool(flags.get(COMPLETE_FLAG, false)):
		return "completed"
	if not bool(flags.get(START_FLAG, false)):
		return "available"
	if _requirements_met():
		return "ready"
	return "active"


static func advance() -> String:
	match get_status():
		"available":
			GameState.claim_world_flag(START_FLAG)
			return INTRO_TEXT
		"active":
			return "아직 초원이 소란스럽네. " + get_tracker_text()
		"ready":
			if GameState.claim_world_flag(COMPLETE_FLAG):
				GameState.add_gold(GOLD_REWARD)
				GameState.add_item(ITEM_REWARD_ID, 1)
			return COMPLETE_TEXT
		_:
			return DONE_TEXT


static func get_tracker_text() -> String:
	var slime := mini(GameState.get_monster_defeats("meadow_slime"), 1)
	var goblin := mini(GameState.get_monster_defeats("goblin_scout"), 1)
	var skeleton := mini(GameState.get_monster_defeats("restless_skeleton"), 1)
	return "초원의 위협  슬라임 %d/1  고블린 %d/1  해골 %d/1" % [slime, goblin, skeleton]


static func _requirements_met() -> bool:
	for monster_id in REQUIRED_DEFEATS.keys():
		if GameState.get_monster_defeats(String(monster_id)) < int(REQUIRED_DEFEATS[monster_id]):
			return false
	return true


static func _flags() -> Dictionary:
	var raw_flags = GameState.world_state.get("flags", {})
	if typeof(raw_flags) != TYPE_DICTIONARY:
		return {}
	return raw_flags
