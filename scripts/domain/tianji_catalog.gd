class_name TianjiCatalog
extends RefCounted

const MAX_ACTIVE_PER_RUN := 2

const SKILLS := {
	"seven_star_lightning": {
		"title": "七星引雷",
		"subtitle": "延时落雷",
		"description": "锁定敌群落雷，造成范围伤害并短暂麻痹。",
		"color": Color("8ac7ff"),
		"cooldown": 8.0,
		"precast": 0.62,
		"radius": 72.0,
		"damage_ratio": 1.18,
		"slow_multiplier": 0.35,
		"slow_duration": 0.70,
		"kind": "lightning",
		"max_rank": 5,
		"costs": [280, 420, 620, 860, 1160],
	},
	"xun_wind_break": {
		"title": "巽风破阵",
		"subtitle": "方向风压",
		"description": "向敌群释放巽风，推开杂兵并让精英短暂迟滞。",
		"color": Color("9ce0c7"),
		"cooldown": 10.0,
		"precast": 0.54,
		"range": 206.0,
		"width": 86.0,
		"damage_ratio": 0.72,
		"slow_multiplier": 0.58,
		"slow_duration": 1.65,
		"knockback": 210.0,
		"kind": "wind",
		"max_rank": 5,
		"costs": [360, 540, 760, 1020, 1380],
	},
	"eight_trigram_tide": {
		"title": "八阵水势",
		"subtitle": "水阵滞敌",
		"description": "在敌群脚下铺开水阵，持续造成小额伤害并减速。",
		"color": Color("67c8d7"),
		"cooldown": 12.0,
		"precast": 0.78,
		"radius": 110.0,
		"duration": 3.0,
		"tick_interval": 0.65,
		"damage_ratio": 0.34,
		"slow_multiplier": 0.52,
		"slow_duration": 0.85,
		"kind": "water",
		"max_rank": 5,
		"costs": [440, 660, 920, 1220, 1640],
	},
	"fire_rain_burning": {
		"title": "火雨焚营",
		"subtitle": "三轮天火",
		"description": "向敌群降下三轮火雨，落点化为短暂燃烧地带。",
		"color": Color("f39b55"),
		"cooldown": 15.0,
		"precast": 0.88,
		"radius": 52.0,
		"strike_count": 5,
		"wave_count": 3,
		"wave_interval": 0.34,
		"duration": 2.30,
		"tick_interval": 0.48,
		"damage_ratio": 0.76,
		"burn_tick_ratio": 0.28,
		"kind": "fire_rain",
		"max_rank": 5,
		"costs": [520, 780, 1100, 1480, 1920],
	},
	"arrow_support_volley": {
		"title": "万箭穿云",
		"subtitle": "圆阵箭雨",
		"description": "屏外援军向敌群降下连续箭雨，覆盖圆形区域内的敌军。",
		"color": Color("e8d08a"),
		"cooldown": 16.0,
		"precast": 0.64,
		"radius": 230.0,
		"volley_count": 3,
		"volley_interval": 0.28,
		"damage_ratio": 0.88,
		"kind": "arrow_volley",
		"max_rank": 5,
		"costs": [600, 900, 1260, 1680, 2160],
	},
}

const ORDER: Array[String] = ["seven_star_lightning", "xun_wind_break", "eight_trigram_tide", "fire_rain_burning", "arrow_support_volley"]

static func definition_for(skill_id: String) -> Dictionary:
	return SKILLS.get(skill_id, {}) as Dictionary

static func all_ids() -> Array[String]:
	return ORDER.duplicate()

static func title_for(skill_id: String) -> String:
	return str(definition_for(skill_id).get("title", skill_id))

static func subtitle_for(skill_id: String) -> String:
	return str(definition_for(skill_id).get("subtitle", "天机"))

static func description_for(skill_id: String) -> String:
	return str(definition_for(skill_id).get("description", ""))

static func max_rank_for(skill_id: String) -> int:
	return int(definition_for(skill_id).get("max_rank", 0))

static func cost_for(skill_id: String, current_rank: int) -> int:
	var costs: Array = definition_for(skill_id).get("costs", []) as Array
	if current_rank < 0 or current_rank >= costs.size():
		return 0
	return int(costs[current_rank])

static func cooldown_for(skill_id: String, rank: int) -> float:
	var definition := definition_for(skill_id)
	return maxf(3.5, float(definition.get("cooldown", 10.0)) * (1.0 - float(maxi(0, rank - 1)) * 0.055))

static func damage_ratio_for(skill_id: String, rank: int) -> float:
	var definition := definition_for(skill_id)
	return float(definition.get("damage_ratio", 0.5)) * (1.0 + float(maxi(0, rank - 1)) * 0.11)
