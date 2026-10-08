class_name BattleSoulArmory
extends RefCounted

# 五种铭刻内部 rank 0..3，对应显示一级至四级。
# 基础持续 20 秒；独立五魂共鸣二级起持续 30 秒。

const DEFINITIONS := {
	"gale_mastery": {
		"soul_id": "gale",
		"title": "罡风铭刻",
		"short_title": "罡风",
		"icon": "风",
		"color": Color("75d9a6"),
		"card_summary": "基础：普攻攻速 +30%\n铭刻：每阶额外 +6%",
		"description": "拾取罡风后，增益期间提高普攻速度。铭刻等级越高，罡风提供的攻速越高。",
		"max_summary": "满阶：普攻攻速 +48%",
		"max_rank": 3,
		"costs": [300, 800, 1800],
	},
	"thunder_mastery": {
		"soul_id": "thunder",
		"title": "雷霆铭刻",
		"short_title": "雷霆",
		"icon": "雷",
		"color": Color("79baff"),
		"card_summary": "基础：雷击连锁 3 个目标\n铭刻：每阶额外 +2 个目标",
		"description": "拾取雷霆后，攻击命中会触发追加雷击。铭刻等级越高，雷击可连锁的目标越多。",
		"max_summary": "满阶：雷击最多连锁 9 个目标",
		"max_rank": 3,
		"costs": [300, 800, 1800],
	},
	"flame_mastery": {
		"soul_id": "flame",
		"title": "爆炎铭刻",
		"short_title": "爆炎",
		"icon": "炎",
		"color": Color("f28a48"),
		"card_summary": "基础：爆炸范围 100% · 10 个目标\n铭刻：每阶范围 +30% · 目标 +2",
		"description": "拾取爆炎后，攻击命中会触发范围爆炸。铭刻等级越高，爆炸范围和波及目标越多。",
		"max_summary": "满阶：爆炸范围 +90% · 最多 16 个目标",
		"max_rank": 3,
		"costs": [300, 800, 1800],
	},
	"iron_mastery": {
		"soul_id": "iron",
		"title": "玄甲铭刻",
		"short_title": "玄甲",
		"icon": "甲",
		"color": Color("e1c26a"),
		"card_summary": "基础：受到伤害降低 30%\n铭刻：每阶额外减伤 15%，每秒恢复 1 点生命",
		"description": "拾取玄甲后，增益期间降低受到的伤害；铭刻等级越高，减伤与生命恢复越高。",
		"max_summary": "满阶：受到伤害降低 75% · 每秒恢复 3 点生命",
		"max_rank": 3,
		"costs": [300, 800, 1800],
	},
	"machine_mastery": {
		"soul_id": "machine",
		"title": "神机铭刻",
		"short_title": "神机",
		"icon": "机",
		"color": Color("d8a84e"),
		"card_summary": "基础：自动连弩 · 200 范围 · 伤害为攻击力 50%\n铭刻：射击间隔 1.0 / 0.6 / 0.3 / 0.3 秒",
		"description": "战斗中拾取神机战魂后，增益期间在英雄左上方部署一具小连弩。每次自动锁定 200 半径内最近有效敌人，然后射出强力箭矢。",
		"max_summary": "满阶：箭矢真正无视护甲",
		"max_rank": 3,
		"costs": [300, 800, 1800],
	},
}

const DISPLAY_ORDER: Array[String] = ["gale_mastery", "thunder_mastery", "flame_mastery", "iron_mastery", "machine_mastery"]

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

static func description_for(armory_id: String, rank: int = 0) -> String:
	var definition := definition_for(armory_id)
	if definition.is_empty():
		return ""
	var shown_rank := clampi(rank, 0, max_rank_for(armory_id))
	return "%s\n%s\n基础持续20秒，五魂共鸣二级起30秒。" % [str(definition.get("description", "")), current_effect_for(armory_id, shown_rank)]

static func effect_summary_for(armory_id: String, rank: int) -> String:
	var max_rank := max_rank_for(armory_id)
	var current_rank := clampi(rank, 0, max_rank)
	var next_rank := mini(max_rank, current_rank + 1)
	if current_rank >= max_rank:
		return "当前效果：%s\n%s" % [current_effect_for(armory_id, current_rank), str(definition_for(armory_id).get("max_summary", "已达到最高阶"))]
	return "当前效果：%s\n下一阶：%s → %s\n本次提升：%s\n%s" % [current_effect_for(armory_id, current_rank), current_effect_for(armory_id, current_rank), current_effect_for(armory_id, next_rank), upgrade_delta_for(armory_id), str(definition_for(armory_id).get("max_summary", ""))]

static func current_effect_for(armory_id: String, rank: int) -> String:
	var current_rank := clampi(rank, 0, max_rank_for(armory_id))
	match armory_id:
		"gale_mastery": return "罡风期间普攻攻速 +%d%%" % (30 + current_rank * 6)
		"thunder_mastery": return "雷击最多连锁 %d 个目标" % (3 + current_rank * 2)
		"flame_mastery": return "爆炸范围 +%d%% · 最多影响 %d 个目标" % [current_rank * 30, 10 + current_rank * 2]
		"iron_mastery": return "玄甲期间受到伤害降低 %d%% · 每秒恢复 %d 点生命" % [30 + current_rank * 15, current_rank]
		"machine_mastery": return "神机连弩间隔 %.1f 秒 · %s" % [ [1.0, 0.6, 0.3, 0.3][current_rank], "无视护甲" if current_rank >= 3 else "按目标护甲结算" ]
	return "铭刻等级 %d / %d" % [current_rank + 1, max_rank_for(armory_id) + 1]

static func upgrade_delta_for(armory_id: String) -> String:
	match armory_id:
		"gale_mastery": return "普攻攻速 +6%"
		"thunder_mastery": return "连锁目标 +2"
		"flame_mastery": return "爆炸范围 +30% · 目标 +2"
		"iron_mastery": return "受到伤害额外降低 15% · 每秒恢复 +1 点生命"
	return "效果提升"

static func effects_for_profile(profile: Dictionary) -> Dictionary:
	var ranks: Dictionary = profile.get("battle_soul_armory", {}) as Dictionary
	var rank := func(armory_id: String) -> int:
		return clampi(int(ranks.get(armory_id, 0)), 0, max_rank_for(armory_id))
	return {
		"gale_attack_speed_ratio": 0.30 + rank.call("gale_mastery") * 0.06,
		"thunder_chain_targets": 3 + rank.call("thunder_mastery") * 2,
		"flame_radius_multiplier": 1.0 + rank.call("flame_mastery") * 0.30,
		"flame_target_count": 10 + rank.call("flame_mastery") * 2,
		"iron_damage_reduction": 0.30 + rank.call("iron_mastery") * 0.15,
		"iron_regen_per_second": rank.call("iron_mastery"),
		"machine_rank": rank.call("machine_mastery"),
	}
