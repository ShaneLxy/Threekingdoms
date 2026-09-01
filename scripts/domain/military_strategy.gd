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
		"nodes": ["armor_drill", "armor_fortify", "armor_medicine", "armor_kill_recovery", "armor_morale"],
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
	{
		"id": "training",
		"title": "练兵营",
		"subtitle": "整训军士，降低战斗中的升级经验需求。",
		"nodes": ["training_efficiency"],
	},
	{
		"id": "tianji",
		"title": "奇门营",
		"subtitle": "扩充阵位，让更多天机阵法同时运转。",
		"nodes": ["tianji_expansion"],
	},
	{
		"id": "grand_command",
		"title": "中军帐",
		"subtitle": "统合全部军略，扩展每次战斗的战法抉择。",
		"nodes": ["grand_strategy"],
	},
]

const DEFINITIONS := {
	"arsenal_refine": {"branch": "arsenal", "title": "兵刃精炼", "card_summary": "全英雄攻击 +1", "description": "全英雄攻击 +1。", "max_rank": 3, "costs": [180, 520, 980]},
	"arsenal_breaker": {"branch": "arsenal", "title": "破甲研修", "card_summary": "精英与敌将伤害 +3%", "description": "对精英与 Boss 的伤害 +3%。", "max_rank": 2, "costs": [260, 720]},
	"arsenal_piercing": {"branch": "arsenal", "title": "穿阵锋刃", "card_summary": "普攻穿透 +1", "description": "全英雄攻击的额外穿透 +1。", "max_rank": 2, "costs": [280, 760]},
	"arsenal_vanguard": {"branch": "arsenal", "title": "先锋锋芒", "card_summary": "全英雄攻击 +2", "description": "全英雄攻击额外 +2。", "max_rank": 1, "costs": [1500]},
	"armor_drill": {"branch": "armor", "title": "披甲操练", "card_summary": "最大生命 +4%", "description": "全英雄最大生命 +4%。", "max_rank": 3, "costs": [180, 520, 980]},
	"armor_fortify": {"branch": "armor", "title": "精甲校阅", "card_summary": "护甲 +2", "description": "全英雄护甲 +2。", "max_rank": 2, "costs": [260, 720]},
	"armor_medicine": {"branch": "armor", "title": "战地救护", "card_summary": "击败精英回复生命", "description": "击败精英或 Boss 时回复最大生命的 8%。", "max_rank": 1, "costs": [320]},
	"armor_kill_recovery": {"branch": "armor", "title": "行伍回春", "card_summary": "击杀概率回生命", "description": "战局内直接生效。击杀敌人有 5% / 8% / 11% 概率回复 1 / 2 / 3 点生命。", "max_rank": 3, "costs": [300, 650, 1050]},
	"armor_morale": {"branch": "armor", "title": "坚守军心", "card_summary": "开局获得一次护体", "description": "每局开战获得 1 次护体，可抵挡一次伤害。", "max_rank": 1, "costs": [1400]},
	"march_pace": {"branch": "march", "title": "行军节奏", "card_summary": "移动速度 +2%", "description": "全英雄移动速度 +2%。", "max_rank": 3, "costs": [180, 520, 980]},
	"march_supply": {"branch": "march", "title": "粮秣辎重", "card_summary": "掉落吸取范围 +10%", "description": "经验与军功掉落的吸引范围 +10%。", "max_rank": 2, "costs": [260, 720]},
	"march_recovery": {"branch": "march", "title": "战阵回息", "card_summary": "升级时回复生命", "description": "升级时额外回复最大生命的 5%。", "max_rank": 1, "costs": [320]},
	"march_scavenge": {"branch": "march", "title": "行军缴获", "card_summary": "本局军功 +10%", "description": "本局拾取的军功 +10%；行军营核心节点。", "max_rank": 1, "costs": [1500]},
	"command_manual": {"branch": "command", "title": "战法操典", "card_summary": "主动冷却 -0.25 秒", "description": "全英雄主动技能基础冷却 -0.25 秒。", "max_rank": 2, "costs": [260, 700]},
	"command_reserve": {"branch": "command", "title": "蓄势待发", "card_summary": "主动技能储能 +1", "description": "主动技能储能层数 + 1。", "max_rank": 2, "costs": [320, 800]},
	"command_drum": {"branch": "command", "title": "鼓角激励", "card_summary": "无双获取 +5%", "description": "全英雄获得的无双能量 +5%。", "max_rank": 2, "costs": [280, 700]},
	"command_opening": {"branch": "command", "title": "先声夺势", "card_summary": "开局无双 +5", "description": "每局开战时获得 5 点无双能量。", "max_rank": 2, "costs": [300, 820]},
	"command_bounty": {"branch": "command", "title": "兵符奖赏", "card_summary": "击败精英无双 +6", "description": "击败精英额外获得 6 点无双能量。", "max_rank": 1, "costs": [1500]},
	"training_efficiency": {"branch": "training", "title": "练兵节制", "card_summary": "升级经验需求降低", "description": "战斗中每次升级所需经验累计降低 1% / 3% / 5%。", "max_rank": 3, "costs": [280, 760, 1400]},
	"tianji_expansion": {"branch": "tianji", "title": "天机扩槽", "card_summary": "天机阵位 +1", "description": "局内天机阵法上限由 2 提升至 3。", "max_rank": 1, "costs": [1800]},
	"grand_strategy": {"branch": "grand_command", "title": "统御全局", "card_summary": "战局抉择扩充", "description": "1阶将局内抉择升级为四选一，2阶升级为五选一，3阶最终升级为五选二。", "max_rank": 3, "costs": [3000, 5000, 7500], "requires_all_strategies": true},
}

static func definition_for(strategy_id: String) -> Dictionary:
	return DEFINITIONS.get(strategy_id, {}) as Dictionary

static func branch_for(strategy_id: String) -> String:
	return str(definition_for(strategy_id).get("branch", ""))

static func title_for(strategy_id: String) -> String:
	return str(definition_for(strategy_id).get("title", strategy_id))

static func description_for(strategy_id: String) -> String:
	return str(definition_for(strategy_id).get("description", ""))

static func card_summary_for(strategy_id: String) -> String:
	var definition := definition_for(strategy_id)
	return str(definition.get("card_summary", definition.get("description", "")))

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

static func all_strategy_ids(include_final: bool = true) -> Array[String]:
	var strategy_ids: Array[String] = []
	for branch_variant in BRANCHES:
		var branch: Dictionary = branch_variant as Dictionary
		for strategy_variant in branch.get("nodes", []) as Array:
			var strategy_id := str(strategy_variant)
			if not include_final and requires_all_strategies(strategy_id):
				continue
			strategy_ids.append(strategy_id)
	return strategy_ids

static func requires_all_strategies(strategy_id: String) -> bool:
	return bool(definition_for(strategy_id).get("requires_all_strategies", false))

static func all_non_final_strategies_maxed(profile: Dictionary) -> bool:
	var ranks: Dictionary = profile.get("military_strategies", {}) as Dictionary
	for strategy_id in all_strategy_ids(false):
		if int(ranks.get(strategy_id, 0)) < max_rank_for(strategy_id):
			return false
	return true

static func prerequisite_satisfied_for(profile: Dictionary, strategy_id: String) -> bool:
	if requires_all_strategies(strategy_id) and not all_non_final_strategies_maxed(profile):
		return false
	var prerequisite_id := prerequisite_for(strategy_id)
	if prerequisite_id.is_empty():
		return true
	var ranks: Dictionary = profile.get("military_strategies", {}) as Dictionary
	return int(ranks.get(prerequisite_id, 0)) > 0

static func prerequisite_requirement_text(profile: Dictionary, strategy_id: String) -> String:
	if requires_all_strategies(strategy_id) and not all_non_final_strategies_maxed(profile):
		return "需先将全部其他军略升至满阶"
	var prerequisite_id := prerequisite_for(strategy_id)
	if not prerequisite_id.is_empty():
		var ranks: Dictionary = profile.get("military_strategies", {}) as Dictionary
		if int(ranks.get(prerequisite_id, 0)) <= 0:
			return "前置军略：%s" % title_for(prerequisite_id)
	return ""

static func effects_for_profile(profile: Dictionary) -> Dictionary:
	var ranks: Dictionary = profile.get("military_strategies", {}) as Dictionary
	var rank := func(strategy_id: String) -> int:
		return clampi(int(ranks.get(strategy_id, 0)), 0, max_rank_for(strategy_id))
	var training_rank: int = rank.call("training_efficiency")
	var experience_requirement_multiplier := 1.0
	match training_rank:
		1: experience_requirement_multiplier = 0.99
		2: experience_requirement_multiplier = 0.97
		3: experience_requirement_multiplier = 0.95
	var grand_strategy_rank: int = rank.call("grand_strategy")
	return {
		"attack_bonus": rank.call("arsenal_refine") * 1.0 + rank.call("arsenal_vanguard") * 2.0,
		"named_damage_ratio": rank.call("arsenal_breaker") * 0.03,
		"pierce_bonus": rank.call("arsenal_piercing"),
		"max_health_ratio": rank.call("armor_drill") * 0.04,
		"defense_bonus": rank.call("armor_fortify") * 2.0,
		"elite_heal_ratio": rank.call("armor_medicine") * 0.08,
		"kill_heal_chance": 0.02 + rank.call("armor_kill_recovery") * 0.03 if rank.call("armor_kill_recovery") > 0 else 0.0,
		"kill_heal_amount": rank.call("armor_kill_recovery"),
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
		"experience_requirement_multiplier": experience_requirement_multiplier,
		"tianji_slot_capacity": 2 + rank.call("tianji_expansion"),
		"upgrade_option_count": 3 + mini(2, grand_strategy_rank),
		"upgrade_selection_count": 2 if grand_strategy_rank >= 3 else 1,
	}
