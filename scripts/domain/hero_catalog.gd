extends RefCounted

const HERO_IDS := ["zhao_yun"]

const HEROES := {
	"zhao_yun": {
		"id": "zhao_yun",
		"name": "赵云",
		"title": "常山赵子龙",
		"portrait": "res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-01.png",
		"stats": {
			"attack": 14.0,
			"defense": 12.0,
			"health": 120.0,
			"move_speed": 125.0,
			"basic_range": 120.0,
			"basic_pierce": 2,
			"active_cooldown": 6.5,
			"ultimate_cost": 40.0,
		},
		"skills": [
			{"name": "普攻·龙胆枪", "type": "普攻", "description": "三段连招：点刺破阵、横扫开路、穿阵挑刺。"},
			{"name": "被动·龙胆", "type": "被动", "description": "第三段或破军累计命中 3 名敌军后，获得护体与疾行。"},
			{"name": "主动·破军", "type": "主动", "description": "沿当前面朝高速穿阵，击退路径敌军，落点追加横扫。"},
			{"name": "无双·七进七出", "type": "无双", "description": "消耗 40 能量，七段可转向龙影穿阵，终段造成高额伤害。"},
		],
	},
}

static func has_hero(hero_id: String) -> bool:
	return HEROES.has(hero_id)

static func all_ids() -> Array[String]:
	return HERO_IDS.duplicate()

static func definition_for(hero_id: String) -> Dictionary:
	var fallback := HEROES["zhao_yun"] as Dictionary
	return (HEROES.get(hero_id, fallback) as Dictionary).duplicate(true)

static func display_stats_for(hero_id: String, profile: Dictionary) -> Dictionary:
	var definition := definition_for(hero_id)
	var stats: Dictionary = definition.get("stats", {}).duplicate(true)
	var upgrades: Array = profile.get("purchased_upgrades", [])
	if upgrades.has("dragon_tactics"):
		stats["attack"] = float(stats.get("attack", 0.0)) * 1.05
	if upgrades.has("seven_drill"):
		stats["active_cooldown"] = maxf(4.0, float(stats.get("active_cooldown", 8.0)) - 0.5)
	return stats
