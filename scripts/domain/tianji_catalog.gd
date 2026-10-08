class_name TianjiCatalog
extends RefCounted

const MAX_ACTIVE_PER_RUN := 2

const SKILLS := {
	"seven_star_lightning": {
		"title": "七星引雷",
		"icon": "雷",
		"subtitle": "延时落雷",
		"description": "锁定敌群落雷，造成范围伤害并短暂麻痹；升阶会扩大落雷范围。",
		"color": Color("8ac7ff"),
		"cooldown": 16.0,
		"precast": 0.62,
		"radius": 72.0,
		"rank_radii": [72.0, 82.0, 94.0, 108.0, 124.0],
		"damage_ratio": 0.59,
		"slow_multiplier": 0.35,
		"slow_duration": 0.70,
		"kind": "lightning",
		"max_rank": 5,
		"costs": [300, 700, 1400, 2200, 3000],
	},
	"xun_wind_break": {
		"title": "巽风破阵",
		"icon": "风",
		"subtitle": "横向龙卷",
		"description": "龙卷风从屏幕左侧横扫至右侧，卷起普通敌军并在甩落时造成伤害；高阶扩大风体并延缓移动。",
		"color": Color("9ce0c7"),
		"cooldown": 20.0,
		"precast": 0.54,
		"range": 206.0,
		"width": 172.0,
		"rank_radii": [172.0, 188.0, 206.0, 228.0, 250.0],
		"wind_widths": [172.0, 188.0, 206.0, 228.0, 250.0],
		"wind_speeds": [390.0, 350.0, 310.0, 270.0, 232.0],
		"wind_lift_limits": [4, 6, 8, 10, 12],
		"wind_air_durations": [0.72, 0.78, 0.84, 0.90, 0.98],
		"wind_rise_heights": [42.0, 48.0, 54.0, 62.0, 70.0],
		"wind_replacement_delay": 0.14,
		"wind_immune_duration": 1.05,
		"wind_fling_distance": [82.0, 90.0, 98.0, 108.0, 118.0],
		"wind_execute_chance": [0.02, 0.04, 0.06, 0.08, 0.10],
		"damage_ratio": 0.36,
		"slow_multiplier": 0.58,
		"slow_duration": 1.65,
		"knockback": 210.0,
		"kind": "wind",
		"max_rank": 5,
		"costs": [300, 700, 1400, 2200, 3000],
	},
	"eight_trigram_tide": {
		"title": "八阵水势",
		"icon": "水",
		"subtitle": "洪潮冲阵",
		"description": "引天河洪潮横扫战场，造成伤害并击退普通敌军；命中后附加浸水减速。五级追加回潮，再次冲散阵型。",
		"color": Color("67c8d7"),
		"cooldown": 30.0,
		"precast": 0.72,
		"radius": 144.0,
		"rank_radii": [144.0, 172.0, 205.0, 244.0, 288.0],
		"flood_widths": [170.0, 205.0, 245.0, 290.0, 340.0],
		# Fixed gameplay band based on the widest/tallest readable crest in each
		# rank. Visual crest layers may still stagger vertically, but all waves
		# resolve damage through this stable band so the effect never appears to
		# pass over an enemy without hitting it.
		"damage_half_heights": [132.0, 164.0, 198.0, 238.0, 282.0],
		"travel_distances": [560.0, 640.0, 720.0, 800.0, 880.0],
		"knockbacks": [150.0, 172.0, 196.0, 224.0, 252.0],
		"duration": 1.55,
		"reflux_delay": 0.16,
		"reflux_duration": 0.72,
		"reflux_damage_ratio": 0.36,
		"damage_ratio": 0.54,
		"armor_ignore_ratio": [0.10, 0.20, 0.30, 0.40, 0.50],
		"slow_multiplier": 0.62,
		"slow_duration": 1.35,
		"kind": "water",
		"max_rank": 5,
		"costs": [300, 700, 1400, 2200, 3000],
	},
	"fire_rain_burning": {
		"title": "火雨焚营",
		"icon": "火",
		"subtitle": "三轮天火",
		"description": "向敌群降下三轮火雨，落点化为短暂燃烧地带。",
		"color": Color("f39b55"),
		"cooldown": 38.0,
		"precast": 0.88,
		"radius": 52.0,
		"rank_radii": [52.0, 62.0, 74.0, 88.0, 104.0],
		"strike_count": 3,
		"visual_strike_count": 3,
		"wave_count": 3,
		"wave_interval": 0.24,
		"duration": 3.40,
		"visual_duration": 3.40,
		"final_visual_duration": 2.80,
		"tick_interval": 0.48,
		"damage_ratio": 0.47,
		"burn_tick_ratio": 0.28,
		"final_meteor_rank": 5,
		"final_meteor_delay": 0.66,
		"final_meteor_damage_ratio": 2.40,
		"final_meteor_radius_ratio": 2.85,
		"kind": "fire_rain",
		"max_rank": 5,
		"costs": [300, 700, 1400, 2200, 3000],
	},
	"arrow_support_volley": {
		"title": "万箭穿云",
		"icon": "箭",
		"subtitle": "圆阵箭雨",
		"description": "屏外援军向敌群降下连续箭雨，覆盖圆形区域内的敌军。",
		"color": Color("e8d08a"),
		"cooldown": 32.0,
		"precast": 0.64,
		"radius": 230.0,
		"volley_count": 3,
		"volley_interval": 0.45,
		"damage_ratio": 0.44,
		"kind": "arrow_volley",
		"max_rank": 5,
		"costs": [300, 700, 1400, 2200, 3000],
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

static func icon_for(skill_id: String) -> String:
	return str(definition_for(skill_id).get("icon", "天"))

static func description_for(skill_id: String, rank: int = 0) -> String:
	var definition := definition_for(skill_id)
	if definition.is_empty():
		return ""
	var shown_rank := clampi(rank, 0, max_rank_for(skill_id))
	if shown_rank <= 0:
		return str(definition.get("description", ""))
	return "%s\n%s" % [str(definition.get("description", "")), effect_summary_for(skill_id, shown_rank)]

static func effect_summary_for(skill_id: String, rank: int) -> String:
	var definition := definition_for(skill_id)
	var shown_rank := clampi(rank, 1, max_rank_for(skill_id))
	var damage := damage_ratio_for(skill_id, shown_rank) * 100.0
	var cooldown := cooldown_for(skill_id, shown_rank)
	var radius := radius_for(skill_id, shown_rank)
	match skill_id:
		"seven_star_lightning": return "%d级：伤害倍率 %.0f%%，落雷半径 %.0f，冷却 %.1f秒，麻痹 %.2f秒" % [shown_rank, damage, radius, cooldown, float(definition.get("slow_duration", 0.0))]
		"xun_wind_break": return "%d级：伤害倍率 %.0f%%，风体宽度 %.0f，卷起%d名普通敌军，击飞 %.0f，冷却 %.1f秒" % [shown_rank, damage, radius, int(_rank_value(definition, "wind_lift_limits", shown_rank, 0)), float(_rank_value(definition, "wind_fling_distance", shown_rank, 0.0)), cooldown]
		"eight_trigram_tide": return "%d级：伤害倍率 %.0f%%，洪潮宽度 %.0f，击退 %.0f，伤害半高 %.0f，冷却 %.1f秒" % [shown_rank, damage, float(_rank_value(definition, "flood_widths", shown_rank, 0.0)), float(_rank_value(definition, "knockbacks", shown_rank, 0.0)), float(_rank_value(definition, "damage_half_heights", shown_rank, 0.0)), cooldown]
		"fire_rain_burning": return "%d级：每轮伤害倍率 %.0f%%，范围半径 %.0f，持续 %.1f秒，末陨倍率 %.0f%%，冷却 %.1f秒" % [shown_rank, damage, radius, float(definition.get("duration", 0.0)), float(definition.get("final_meteor_damage_ratio", 0.0)) * 100.0, cooldown]
		"arrow_support_volley": return "%d级：每轮伤害倍率 %.0f%%，覆盖半径 %.0f，箭雨%d轮，冷却 %.1f秒" % [shown_rank, damage, radius, int(definition.get("volley_count", 0)), cooldown]
	return "等级 %d / %d" % [shown_rank, max_rank_for(skill_id)]

static func _rank_value(definition: Dictionary, key: String, rank: int, fallback: Variant) -> Variant:
	var values: Array = definition.get(key, []) as Array
	if values.is_empty():
		return fallback
	return values[clampi(rank - 1, 0, values.size() - 1)]

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
	var rank_ratios: Array = definition.get("rank_damage_ratios", []) as Array
	if not rank_ratios.is_empty():
		return float(rank_ratios[clampi(maxi(1, rank) - 1, 0, rank_ratios.size() - 1)])
	return float(definition.get("damage_ratio", 0.5))

static func radius_for(skill_id: String, rank: int) -> float:
	var definition := definition_for(skill_id)
	var rank_radii: Array = definition.get("rank_radii", []) as Array
	if not rank_radii.is_empty():
		var index := clampi(maxi(1, rank) - 1, 0, rank_radii.size() - 1)
		return float(rank_radii[index])
	return float(definition.get("radius", 0.0))
