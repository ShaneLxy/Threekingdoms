class_name SiegeArmory
extends RefCounted

# 攻城略地专属的局外成长。该页只影响攻城模式中的援军与攻城锤，
# 不和全英雄军略混用，避免常规剧情、无尽与名将斗阵被被动数值绑架。

const GROUPS := [
	{
		"id": "reinforcement",
		"title": "援军调度",
		"subtitle": "让战线更快补齐。",
		"nodes": ["reinforcement_batch", "reinforcement_interval"],
	},
	{
		"id": "infantry",
		"title": "士卒整训",
		"subtitle": "提升前线步卒的持久交战能力。",
		"nodes": ["infantry_attack", "infantry_defense", "infantry_health"],
	},
	{
		"id": "ram",
		"title": "攻城器械",
		"subtitle": "让攻城锤更稳定地抵达并撞开城门。",
		"nodes": ["ram_attack", "ram_speed", "ram_health", "ram_defense"],
	},
]

const DEFINITIONS := {
	"reinforcement_batch": {
		"branch": "reinforcement", "title": "扩编军令", "card_summary": "每批援军 +1", "description": "每升 1 阶，每批补充的我方士兵 +1 人。场上人数上限仍为 18。", "max_rank": 3, "costs": [300, 760, 1500],
	},
	"reinforcement_interval": {
		"branch": "reinforcement", "title": "急援军令", "card_summary": "补兵间隔 -0.75秒", "description": "每升 1 阶，援军补充间隔缩短 0.75 秒，最低不会低于 2 秒。", "max_rank": 3, "costs": [300, 760, 1500],
	},
	"infantry_attack": {
		"branch": "infantry", "title": "锋矢操练", "card_summary": "我方士兵攻击 +1", "description": "每升 1 阶，我方刀盾兵与长枪兵的基础攻击 +1。", "max_rank": 3, "costs": [260, 720, 1400],
	},
	"infantry_defense": {
		"branch": "infantry", "title": "甲胄整备", "card_summary": "我方士兵防御 +5", "description": "每升 1 阶，我方士兵基础防御 +5，按战斗通用防御公式减伤。", "max_rank": 3, "costs": [260, 720, 1400],
	},
	"infantry_health": {
		"branch": "infantry", "title": "行伍整训", "card_summary": "我方士兵生命 +8", "description": "每升 1 阶，我方士兵最大生命 +8。", "max_rank": 3, "costs": [300, 780, 1500],
	},
	"ram_attack": {
		"branch": "ram", "title": "撞槌加楔", "card_summary": "攻城锤伤害 +10%", "description": "每升 1 阶，攻城锤对城门造成的伤害提高 10%。", "max_rank": 3, "costs": [360, 900, 1750],
	},
	"ram_speed": {
		"branch": "ram", "title": "轮毂整修", "card_summary": "攻城锤速度 +6%", "description": "每升 1 阶，攻城锤行军速度提高 6%。", "max_rank": 3, "costs": [320, 820, 1600],
	},
	"ram_health": {
		"branch": "ram", "title": "车架加固", "card_summary": "攻城锤生命 +10%", "description": "每升 1 阶，攻城锤最大耐久提高 10%。", "max_rank": 3, "costs": [360, 900, 1750],
	},
	"ram_defense": {
		"branch": "ram", "title": "铁甲包覆", "card_summary": "攻城锤防御 +12", "description": "每升 1 阶，攻城锤基础防御 +12，按战斗通用防御公式减伤。", "max_rank": 3, "costs": [360, 900, 1750],
	},
}

static func definition_for(armory_id: String) -> Dictionary:
	return DEFINITIONS.get(armory_id, {}) as Dictionary

static func title_for(armory_id: String) -> String:
	return str(definition_for(armory_id).get("title", armory_id))

static func card_summary_for(armory_id: String) -> String:
	var definition := definition_for(armory_id)
	return str(definition.get("card_summary", definition.get("description", "")))

static func max_rank_for(armory_id: String) -> int:
	return int(definition_for(armory_id).get("max_rank", 0))

static func cost_for(armory_id: String, current_rank: int) -> int:
	var costs: Array = definition_for(armory_id).get("costs", []) as Array
	if current_rank < 0 or current_rank >= costs.size():
		return 0
	return int(costs[current_rank])

static func effects_for_profile(profile: Dictionary) -> Dictionary:
	var ranks: Dictionary = profile.get("siege_armory", {}) as Dictionary
	var rank := func(armory_id: String) -> int:
		return clampi(int(ranks.get(armory_id, 0)), 0, max_rank_for(armory_id))
	return {
		"reinforcement_batch_bonus": rank.call("reinforcement_batch"),
		"reinforcement_interval_reduction": rank.call("reinforcement_interval") * 0.75,
		"friendly_attack_bonus": rank.call("infantry_attack") * 1.0,
		"friendly_defense_bonus": rank.call("infantry_defense") * 5.0,
		"friendly_health_bonus": rank.call("infantry_health") * 8.0,
		"ram_damage_ratio": rank.call("ram_attack") * 0.10,
		"ram_speed_ratio": rank.call("ram_speed") * 0.06,
		"ram_health_ratio": rank.call("ram_health") * 0.10,
		"ram_defense_bonus": rank.call("ram_defense") * 12.0,
	}

static func effect_summary_for(armory_id: String, rank: int) -> String:
	var max_rank := max_rank_for(armory_id)
	var current_rank := clampi(rank, 0, max_rank)
	var next_rank := mini(max_rank, current_rank + 1)
	match armory_id:
		"reinforcement_batch":
			return "当前：每批援军 %d 人\n下一阶：每批援军 %d 人" % [4 + current_rank, 4 + next_rank]
		"reinforcement_interval":
			return "当前：每 %.2f 秒补充一批\n下一阶：每 %.2f 秒补充一批" % [maxf(2.0, 10.0 - current_rank * 0.75), maxf(2.0, 10.0 - next_rank * 0.75)]
		"infantry_attack":
			return "当前：我方士兵攻击 %.0f\n下一阶：我方士兵攻击 %.0f" % [5.0 + current_rank, 5.0 + next_rank]
		"infantry_defense":
			return "当前：我方士兵防御 %.0f\n下一阶：我方士兵防御 %.0f" % [current_rank * 5.0, next_rank * 5.0]
		"infantry_health":
			return "当前：我方士兵生命 %.0f\n下一阶：我方士兵生命 %.0f" % [48.0 + current_rank * 8.0, 48.0 + next_rank * 8.0]
		"ram_attack":
			return "当前：攻城锤撞门伤害 +%.0f%%\n下一阶：攻城锤撞门伤害 +%.0f%%" % [current_rank * 10.0, next_rank * 10.0]
		"ram_speed":
			return "当前：攻城锤速度 %.0f\n下一阶：攻城锤速度 %.0f" % [108.0 * (1.0 + current_rank * 0.06), 108.0 * (1.0 + next_rank * 0.06)]
		"ram_health":
			return "当前：攻城锤耐久 %.0f\n下一阶：攻城锤耐久 %.0f" % [1150.0 * (1.0 + current_rank * 0.10), 1150.0 * (1.0 + next_rank * 0.10)]
		"ram_defense":
			return "当前：攻城锤防御 %.0f\n下一阶：攻城锤防御 %.0f" % [61.0 + current_rank * 12.0, 61.0 + next_rank * 12.0]
	return "当前阶数：%d / %d" % [current_rank, max_rank]
