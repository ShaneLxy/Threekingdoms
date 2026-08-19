class_name MilitaryStrategy
extends RefCounted

const BRANCHES := [
	{
		"id": "arsenal",
		"title": "军械营",
		"subtitle": "锻兵破阵，强化全英雄的输出底盘。",
		"nodes": ["arsenal_refine", "arsenal_breaker", "arsenal_piercing", "arsenal_vanguard"],
	},
	{
		"id": "armor",
		"title": "兵甲营",
		"subtitle": "整备甲胄，提升兵海中的容错与续航。",
		"nodes": ["armor_drill", "armor_fortify", "armor_medicine", "armor_morale"],
	},
	{
		"id": "march",
		"title": "行军营",
		"subtitle": "轻装行军，让每名武将更快完成成长。",
		"nodes": ["march_pace", "march_supply", "march_recovery", "march_scavenge"],
	},
	{
		"id": "command",
		"title": "军令营",
		"subtitle": "整肃号令，改善主动技能与无双节奏。",
		"nodes": ["command_manual", "command_reserve", "command_drum", "command_opening", "command_bounty"],
	},
]

const DEFINITIONS := {
	"arsenal_refine": {"branch": "arsenal", "title": "兵刃精炼", "description": "全英雄攻击 +2%。", "max_rank": 3, "costs": [160, 240, 360]},
	"arsenal_breaker": {"branch": "arsenal", "title": "破甲研修", "description": "对精英与 Boss 的伤害 +3%。", "max_rank": 2, "costs": [220, 360]},
	"arsenal_piercing": {"branch": "arsenal", "title": "穿阵锋刃", "description": "全英雄攻击的额外穿透 +1。", "max_rank": 2, "costs": [240, 400]},
	"arsenal_vanguard": {"branch": "arsenal", "title": "先锋锋芒", "description": "全英雄攻击再提高 4%；军械营核心节点。", "max_rank": 1, "costs": [900]},
	"armor_drill": {"branch": "armor", "title": "披甲操练", "description": "全英雄最大生命 +4%。", "max_rank": 3, "costs": [160, 240, 360]},
	"armor_fortify": {"branch": "armor", "title": "精甲校阅", "description": "全英雄护甲 +2。", "max_rank": 2, "costs": [220, 360]},
	"armor_medicine": {"branch": "armor", "title": "战地救护", "description": "击败精英或 Boss 时回复最大生命的 8%。", "max_rank": 1, "costs": [300]},
	"armor_morale": {"branch": "armor", "title": "坚守军心", "description": "每局开战获得 1 次护体，可抵挡一次伤害。", "max_rank": 1, "costs": [800]},
	"march_pace": {"branch": "march", "title": "行军节奏", "description": "全英雄移动速度 +2%。", "max_rank": 3, "costs": [160, 240, 360]},
	"march_supply": {"branch": "march", "title": "粮秣辎重", "description": "经验与军功掉落的吸引范围 +10%。", "max_rank": 2, "costs": [220, 360]},
	"march_recovery": {"branch": "march", "title": "战阵回息", "description": "升级时额外回复最大生命的 5%。", "max_rank": 1, "costs": [300]},
	"march_scavenge": {"branch": "march", "title": "行军缴获", "description": "本局拾取的军功 +10%；行军营核心节点。", "max_rank": 1, "costs": [850]},
	"command_manual": {"branch": "command", "title": "战法操典", "description": "全英雄主动技能基础冷却 -0.25 秒。", "max_rank": 2, "costs": [220, 360]},
	"command_reserve": {"branch": "command", "title": "蓄势待发", "description": "主动技能可储存使用次数：1阶最多 2 次，2阶最多 3 次。", "max_rank": 2, "costs": [300, 520]},
	"command_drum": {"branch": "command", "title": "鼓角激励", "description": "全英雄获得的无双能量 +5%。", "max_rank": 2, "costs": [240, 400]},
	"command_opening": {"branch": "command", "title": "先声夺势", "description": "每局开战时获得 5 点无双能量。", "max_rank": 2, "costs": [260, 420]},
	"command_bounty": {"branch": "command", "title": "兵符奖赏", "description": "击败精英额外获得 6 点无双能量；军令营核心节点。", "max_rank": 1, "costs": [900]},
}

static func definition_for(strategy_id: String) -> Dictionary:
	return DEFINITIONS.get(strategy_id, {}) as Dictionary

static func branch_for(strategy_id: String) -> String:
	return str(definition_for(strategy_id).get("branch", ""))

static func title_for(strategy_id: String) -> String:
	return str(definition_for(strategy_id).get("title", strategy_id))

static func description_for(strategy_id: String) -> String:
	return str(definition_for(strategy_id).get("description", ""))

static func max_rank_for(strategy_id: String) -> int:
	return int(definition_for(strategy_id).get("max_rank", 0))

static func cost_for(strategy_id: String, current_rank: int) -> int:
	var costs: Array = definition_for(strategy_id).get("costs", []) as Array
	if current_rank < 0 or current_rank >= costs.size():
		return 0
	return int(costs[current_rank])

static func prerequisite_for(strategy_id: String) -> String:
	for branch_variant in BRANCHES:
		var branch: Dictionary = branch_variant as Dictionary
		var nodes: Array = branch.get("nodes", []) as Array
		var node_index := nodes.find(strategy_id)
		if node_index > 0:
			return str(nodes[node_index - 1])
	return ""

static func effects_for_profile(profile: Dictionary) -> Dictionary:
	var ranks: Dictionary = profile.get("military_strategies", {}) as Dictionary
	var rank := func(strategy_id: String) -> int:
		return clampi(int(ranks.get(strategy_id, 0)), 0, max_rank_for(strategy_id))
	return {
		"attack_ratio": rank.call("arsenal_refine") * 0.02 + rank.call("arsenal_vanguard") * 0.04,
		"named_damage_ratio": rank.call("arsenal_breaker") * 0.03,
		"pierce_bonus": rank.call("arsenal_piercing"),
		"max_health_ratio": rank.call("armor_drill") * 0.04,
		"defense_bonus": rank.call("armor_fortify") * 2.0,
		"elite_heal_ratio": rank.call("armor_medicine") * 0.08,
		"starting_shield": rank.call("armor_morale") > 0,
		"move_speed_ratio": rank.call("march_pace") * 0.02,
		"loot_range_ratio": rank.call("march_supply") * 0.10,
		"level_heal_ratio": rank.call("march_recovery") * 0.05,
		"gold_ratio": rank.call("march_scavenge") * 0.10,
		"active_cooldown_reduction": rank.call("command_manual") * 0.25,
		"active_charge_capacity": 1 + rank.call("command_reserve"),
		"ultimate_energy_ratio": 1.0 + rank.call("command_drum") * 0.05,
		"starting_ultimate_energy": rank.call("command_opening") * 5.0,
		"elite_ultimate_energy": rank.call("command_bounty") * 6.0,
	}
