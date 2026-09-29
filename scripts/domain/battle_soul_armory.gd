class_name BattleSoulArmory
extends RefCounted

# 战魂阁是战场临时战魂的局外铭刻，不改变掉落频率、持续时间或拾取方式。
# 每一种铭刻均为三阶；效果仅在拾取到对应战魂的 20 秒内生效。

const DEFINITIONS := {
	"gale_mastery": {
		"soul_id": "gale",
		"title": "罡风铭刻",
		"short_title": "罡风",
		"icon": "风",
		"color": Color("75d9a6"),
		"card_summary": "每阶额外 +6% 攻速",
		"description": "强化罡风战魂。拾取罡风后，普攻速度的提升会随铭刻阶数进一步增加。",
		"max_rank": 3,
		"costs": [300, 800, 1800],
	},
	"thunder_mastery": {
		"soul_id": "thunder",
		"title": "雷霆铭刻",
		"short_title": "雷霆",
		"icon": "雷",
		"color": Color("79baff"),
		"card_summary": "每阶额外 +1 连锁目标",
		"description": "强化雷霆战魂。攻击命中后追加的雷击，每阶可额外跳向 1 个目标。",
		"max_rank": 3,
		"costs": [300, 800, 1800],
	},
	"flame_mastery": {
		"soul_id": "flame",
		"title": "爆炎铭刻",
		"short_title": "爆炎",
		"icon": "炎",
		"color": Color("f28a48"),
		"card_summary": "每阶爆炸半径 +15% · 目标 +2",
		"description": "强化爆炎战魂。攻击命中后触发的爆炸会逐阶扩大范围，并能波及更多敌军。",
		"max_rank": 3,
		"costs": [300, 800, 1800],
	},
	"iron_mastery": {
		"soul_id": "iron",
		"title": "玄甲铭刻",
		"short_title": "玄甲",
		"icon": "甲",
		"color": Color("e1c26a"),
		"card_summary": "每阶额外 -15% 受到伤害",
		"description": "强化玄甲战魂。拾取玄甲后，每升 1 阶额外减少 15% 所受伤害；满阶时总减伤为 75%。",
		"max_rank": 3,
		"costs": [300, 800, 1800],
	},
}

const DISPLAY_ORDER: Array[String] = ["gale_mastery", "thunder_mastery", "flame_mastery", "iron_mastery"]

static func definition_for(armory_id: String) -> Dictionary:
	return DEFINITIONS.get(armory_id, {}) as Dictionary

static func title_for(armory_id: String) -> String:
	return str(definition_for(armory_id).get("title", armory_id))

static func max_rank_for(armory_id: String) -> int:
	return int(definition_for(armory_id).get("max_rank", 0))

static func cost_for(armory_id: String, current_rank: int) -> int:
	var costs: Array = definition_for(armory_id).get("costs", []) as Array
	if current_rank < 0 or current_rank >= costs.size():
		return 0
	return int(costs[current_rank])

static func effect_summary_for(armory_id: String, rank: int) -> String:
	var max_rank := max_rank_for(armory_id)
	var current_rank := clampi(rank, 0, max_rank)
	var next_rank := mini(max_rank, current_rank + 1)
	match armory_id:
		"gale_mastery":
			return "当前：罡风攻速 +%d%%\n下一阶：罡风攻速 +%d%%" % [30 + current_rank * 6, 30 + next_rank * 6]
		"thunder_mastery":
			return "当前：雷击连锁 %d 个目标\n下一阶：雷击连锁 %d 个目标" % [3 + current_rank, 3 + next_rank]
		"flame_mastery":
			return "当前：半径 %d · 最多 %d 个目标\n下一阶：半径 %d · 最多 %d 个目标" % [int(round(78.0 * (1.0 + current_rank * 0.15))), 10 + current_rank * 2, int(round(78.0 * (1.0 + next_rank * 0.15))), 10 + next_rank * 2]
		"iron_mastery":
			return "当前：玄甲减伤 %d%%\n下一阶：玄甲减伤 %d%%" % [30 + current_rank * 15, 30 + next_rank * 15]
	return "当前阶数：%d / %d" % [current_rank, max_rank]

static func effects_for_profile(profile: Dictionary) -> Dictionary:
	var ranks: Dictionary = profile.get("battle_soul_armory", {}) as Dictionary
	var rank := func(armory_id: String) -> int:
		return clampi(int(ranks.get(armory_id, 0)), 0, max_rank_for(armory_id))
	return {
		"gale_attack_speed_ratio": 0.30 + rank.call("gale_mastery") * 0.06,
		"thunder_chain_targets": 3 + rank.call("thunder_mastery"),
		"flame_radius_multiplier": 1.0 + rank.call("flame_mastery") * 0.15,
		"flame_target_count": 10 + rank.call("flame_mastery") * 2,
		"iron_damage_reduction": 0.30 + rank.call("iron_mastery") * 0.15,
	}
