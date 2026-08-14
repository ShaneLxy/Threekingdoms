extends RefCounted

const MILITARY_STRATEGY = preload("res://scripts/domain/military_strategy.gd")
const HERO_IDS: Array[String] = ["guan_yu", "zhang_fei", "zhao_yun", "ma_chao", "huang_zhong"]

const HEROES := {
	"guan_yu": {
		"id": "guan_yu",
		"name": "关羽",
		"role": "重击·破势",
		"unlock_cost": 0,
		"playable": true,
		"actor_scene": "res://scenes/actors/guan_yu_actor.tscn",
		"ultimate_cutin": "res://assets/art/characters/guan_yu/cutins/wushuang.png",
		"portrait": "res://assets/art/characters/guan_yu/portraits/guanyu.png",
		"stats": {
			"attack": 20.0,
			"defense": 16.0,
			"health": 145.0,
			"move_speed": 100.0,
			"basic_range": 164.0,
			"basic_pierce": 12,
			"active_cooldown": 7.5,
			"ultimate_cost": 60.0,
		},
		"skills": [
			{"name": "普攻·青龙三斩", "type": "普攻", "description": "三段大开大合的偃月横扫；长按蓄满可施放脱手刀浪，武圣期间支持八方向挥斩。"},
			{"name": "被动·兵势 / 斩将", "type": "被动", "description": "周围敌人越多，关羽攻防越强；攻击精英与BOSS会叠加斩将印。"},
			{"name": "主动·青龙断浪", "type": "主动", "description": "短距离破阵滑步撞开轻敌，随后斩出长距离巨型刀浪，击退并减速敌人。"},
			{"name": "无双·武圣", "type": "无双", "description": "消耗60能量，持续15秒强化攻击与移速；青龙断浪冷却减半（最低3.5秒），蓄满拖刀会追加上下两路刀浪与小范围震阵。"},
		],
		"talent_tree": [
			{"title": "偃月 / 拖刀", "core_title": "基础偃月", "core_summary": "三段横扫与蓄力拖刀默认开放。", "nodes": [{"id": "guan_broad_edge", "summary": "横扫范围", "is_core": true}, {"id": "guan_heavy_blade", "summary": "沉重斩击", "is_core": true}, {"id": "guan_drag_waves", "summary": "追加刀浪", "is_core": true}, {"id": "guan_drag_reach", "summary": "延长刀浪", "is_core": true}, {"id": "guan_sweeping_guard", "cost": 180, "summary": "正面拦矢"}, {"id": "guan_sweeping_guard_large", "cost": 300, "summary": "扩大拦截"}]},
			{"title": "兵势 / 斩将", "core_title": "基础兵势", "core_summary": "近敌增益与高级目标易伤默认开放。", "nodes": [{"id": "guan_martial_pressure", "summary": "近敌攻防", "is_core": true}, {"id": "guan_iron_guard", "summary": "斩将易伤", "is_core": true}]},
			{"title": "断浪", "core_title": "基础断浪", "core_summary": "滑步巨型刀浪默认开放。", "nodes": [{"id": "guan_breaking_wave", "summary": "刀浪距离", "is_core": true}, {"id": "guan_rending_tide", "summary": "减速击退", "is_core": true}, {"id": "guan_wave_count", "summary": "刀浪数量", "is_core": true}]},
			{"title": "武圣", "core_title": "基础武圣", "core_summary": "15秒压阵状态默认开放。", "nodes": [{"id": "guan_saintly_wrath", "summary": "武圣强化", "is_core": true}, {"id": "guan_war_banner", "summary": "军威充能", "is_core": true}]},
		],
	},
	"zhang_fei": {
		"id": "zhang_fei",
		"name": "张飞",
		"role": "近战·震退",
		"unlock_cost": 0,
		"playable": true,
		"actor_scene": "res://scenes/actors/zhang_fei_actor.tscn",
		"portrait": "res://assets/art/characters/zhang_fei/portraits/zhangfei.png",
		"stats": {
			"attack": 23.0,
			"defense": 20.0,
			"health": 178.0,
			"move_speed": 92.0,
			"basic_range": 174.0,
			"basic_pierce": 20,
			"active_cooldown": 7.6,
			"ultimate_cost": 40.0,
		},
		"skills": [
			{"name": "普攻·丈八三式", "type": "普攻", "description": "三段蛇矛横扫，终式以大范围震退清开包围。"},
			{"name": "被动·燕人怒势", "type": "被动", "description": "连续作战后进入短暂怒势，获得减伤并强化压阵能力。"},
			{"name": "主动·据水断桥", "type": "主动", "description": "短暂格挡一次伤害后，向正面发出强力喝退。"},
			{"name": "无双·当阳怒吼", "type": "无双", "description": "消耗 40 能量，连续横断、震地与断喝，重创周围敌军。"},
		],
		"talent_tree": [
			{"title": "蛇矛", "core_title": "基础蛇矛", "core_summary": "横扫、断阵与震退三式默认开放。", "nodes": [{"id": "zhang_heavy_roar", "summary": "范围与击退", "is_core": true}, {"id": "zhang_rage", "summary": "怒势强化", "is_core": true}]},
			{"title": "断桥", "core_title": "基础断桥", "core_summary": "格挡与正面喝退默认开放。", "nodes": [{"id": "zhang_iron_hide", "summary": "格挡与防御", "is_core": true}]},
			{"title": "无双", "core_title": "基础怒吼", "core_summary": "当阳怒吼默认开放。", "nodes": [{"id": "zhang_earthshaker", "summary": "震地与破势", "is_core": true}]},
		],
	},
	"zhao_yun": {
		"id": "zhao_yun",
		"name": "赵云",
		"role": "突进·连击",
		"unlock_cost": 0,
		"playable": true,
		"actor_scene": "res://scenes/actors/player_actor.tscn",
		"ultimate_cutin": "res://assets/art/characters/zhao_yun/cutins/wushuang.png",
		"portrait": "res://assets/art/characters/zhao_yun/portraits/zhaoyun.png",
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
			{"name": "被动·龙胆", "type": "被动", "description": "击杀基础敌军积累进度；命中精英 +3、Boss +5，达到阈值后获得护体与疾行。"},
			{"name": "主动·破军", "type": "主动", "description": "沿当前面朝高速穿阵，击退路径敌军，落点追加横扫。"},
			{"name": "无双·七进七出", "type": "无双", "description": "消耗 40 能量，七段可转向龙影穿阵，终段造成高额伤害。"},
		],
		"talent_tree": [
			{
				"title": "枪法",
				"core_title": "基础枪法",
				"core_summary": "枪势延展、横扫余威、追云突刺默认开放。",
				"nodes": [
					{"id": "spear_reach", "summary": "距离与穿透", "is_core": true},
					{"id": "sweeping_wind", "summary": "横扫与击退", "is_core": true},
					{"id": "dash_echo", "summary": "突进与恢复", "is_core": true},
					{"id": "sweeping_guard", "cost": 180, "summary": "小扇区拦箭"},
					{"id": "sweeping_guard_large", "cost": 300, "summary": "扩大拦箭范围"},
					{"id": "firewheel", "cost": 380, "summary": "火轮免疫"},
					{"id": "firewheel_duration", "cost": 240, "summary": "延时震荡"},
					{"id": "firewheel_volley", "cost": 320, "summary": "随机投掷"},
					{"id": "firewheel_capstone", "cost": 800, "summary": "第五段贯阵"},
				],
			},
			{
				"title": "龙胆",
				"core_title": "基础龙胆",
				"core_summary": "胆魄凝甲、破阵疾行、龙鳞不灭默认开放。",
				"nodes": [
					{"id": "dragon_armor", "summary": "防御与减伤", "is_core": true},
					{"id": "dragon_stride", "summary": "持续与疾行", "is_core": true},
					{"id": "dragon_scale", "summary": "生命与回复", "is_core": true},
					{"id": "dragon_stride_double", "cost": 300, "summary": "满阶疾行翻倍"},
					{"id": "dragon_stride_threefold", "cost": 480, "summary": "三层持续再翻倍"},
					{"id": "dragon_scale_regen", "cost": 260, "summary": "击杀概率回春"},
					{"id": "dragon_focus", "cost": 220, "summary": "触发层数降低"},
					{"id": "dragon_focus_guard", "cost": 420, "summary": "护体抵挡四次"},
					{"id": "dragon_focus_invulnerable", "cost": 800, "summary": "新护体五秒无敌"},
				],
			},
			{
				"title": "破军",
				"core_title": "基础破军",
				"core_summary": "破军余锋、破军回旋默认开放。",
				"nodes": [
					{"id": "seven_edge", "summary": "冷却缩短", "is_core": true},
					{"id": "snake_spin", "summary": "范围与击退", "is_core": true},
				{"id": "spear_shadow", "cost": 300, "summary": "追加枪影补击"},
				],
			},
			{
				"title": "无双",
				"core_title": "基础无双",
				"core_summary": "七进七出为赵云固有无双。",
				"nodes": [
				{"id": "white_dragon", "cost": 220, "summary": "突进与能量提升"},
				{"id": "returning_spear", "cost": 260, "summary": "穿阵伤害提高"},
				{"id": "triumph", "cost": 380, "summary": "充能与精英奖励"},
				],
			},
		],
	},
	"ma_chao": {
		"id": "ma_chao",
		"name": "马超",
		"role": "冲锋·穿阵",
		"unlock_cost": 0,
		"playable": true,
		"actor_scene": "res://scenes/actors/ma_chao_actor.tscn",
		"portrait": "res://assets/art/characters/ma_chao/portraits/machao.png",
		"stats": {
			"attack": 19.0,
			"defense": 14.0,
			"health": 138.0,
			"move_speed": 116.0,
			"basic_range": 162.0,
			"basic_pierce": 16,
			"active_cooldown": 7.2,
			"ultimate_cost": 40.0,
		},
		"skills": [
			{"name": "普攻·西凉连骑", "type": "普攻", "description": "点阵、横挑、踏阵突刺；持续直线移动会积累奔势。"},
			{"name": "被动·奔势", "type": "被动", "description": "持续同向移动积累奔势，急转、停步会衰减；奔势强化冲阵招式。"},
			{"name": "主动·西凉破阵", "type": "主动", "description": "沿指定方向高速平移穿阵，保留清晰的残影与冲势轨迹。"},
			{"name": "无双·银枪奔雷", "type": "无双", "description": "消耗 40 能量，连续多段长距离冲锋，可在有限转角内修正方向。"},
		],
		"talent_tree": [
			{"title": "银枪", "core_title": "基础银枪", "core_summary": "点阵、横挑与踏阵突刺默认开放。", "nodes": [{"id": "ma_long_stride", "summary": "距离与起势", "is_core": true}, {"id": "ma_iron_hoof", "summary": "伤害与击退", "is_core": true}]},
			{"title": "奔势", "core_title": "基础奔势", "core_summary": "同向移动积累冲锋势能。", "nodes": [{"id": "ma_storm_charge", "summary": "主动冷却与距离", "is_core": true}]},
			{"title": "无双", "core_title": "基础奔雷", "core_summary": "银枪奔雷默认开放。", "nodes": [{"id": "ma_silver_afterimage", "summary": "无双与破势", "is_core": true}]},
		],
	},
	"huang_zhong": {
		"id": "huang_zhong",
		"name": "黄忠",
		"role": "远程·狙击",
		"unlock_cost": 0,
		"playable": true,
		"actor_scene": "res://scenes/actors/huang_zhong_actor.tscn",
		"portrait": "res://assets/art/characters/huang_zhong/portraits/huangzhong.png",
		"stats": {
			"attack": 18.0,
			"defense": 11.0,
			"health": 122.0,
			"move_speed": 102.0,
			"basic_range": 326.0,
			"basic_pierce": 8,
			"active_cooldown": 7.4,
			"ultimate_cost": 40.0,
		},
		"skills": [
			{"name": "普攻·连珠箭 / 断弦刀", "type": "普攻", "description": "弓形态八方向远射与蓄力穿云；刀形态用于近身击退和脱离。"},
			{"name": "被动·弓刀切换", "type": "被动", "description": "独立切换按钮可在弓、刀之间切换；返弦斩命中后自动回到弓形态。"},
			{"name": "主动·贯星矢 / 返弦斩", "type": "主动", "description": "弓形态射出长距离贯星矢；刀形态发出大范围返身斩并恢复远射。"},
			{"name": "无双·定军连珠", "type": "无双", "description": "消耗 40 能量，朝指定方向连续发射五支重箭，专长压制精英与BOSS。"},
		],
		"talent_tree": [
			{"title": "弓术", "core_title": "基础弓术", "core_summary": "连珠箭与蓄力穿云默认开放。", "nodes": [{"id": "huang_draw_strength", "summary": "伤害与穿透", "is_core": true}, {"id": "huang_hawk_eye", "summary": "射程与狙击", "is_core": true}]},
			{"title": "刀势", "core_title": "基础刀势", "core_summary": "断弦横斩与返弦斩默认开放。", "nodes": [{"id": "huang_blade_return", "summary": "击退与防御", "is_core": true}]},
			{"title": "无双", "core_title": "基础定军", "core_summary": "定军连珠默认开放。", "nodes": [{"id": "huang_dingjun_volley", "summary": "箭阵与破势", "is_core": true}]},
		],
	},
}

static func has_hero(hero_id: String) -> bool:
	return HEROES.has(hero_id)

static func all_ids() -> Array[String]:
	var ids: Array[String] = []
	for hero_id in HERO_IDS:
		ids.append(str(hero_id))
	return ids

static func definition_for(hero_id: String) -> Dictionary:
	var fallback := HEROES["zhao_yun"] as Dictionary
	return (HEROES.get(hero_id, fallback) as Dictionary).duplicate(true)

static func is_playable(hero_id: String) -> bool:
	return bool(definition_for(hero_id).get("playable", false))

static func actor_scene_for(hero_id: String) -> String:
	return str(definition_for(hero_id).get("actor_scene", ""))

static func display_name_for(hero_id: String) -> String:
	return str(definition_for(hero_id).get("name", "武将"))

static func ultimate_cutin_for(hero_id: String) -> String:
	return str(definition_for(hero_id).get("ultimate_cutin", ""))

static func display_stats_for(hero_id: String, profile: Dictionary) -> Dictionary:
	var definition := definition_for(hero_id)
	var stats: Dictionary = definition.get("stats", {}).duplicate(true)
	var strategy_effects := MILITARY_STRATEGY.effects_for_profile(profile)
	stats["attack"] = float(stats.get("attack", 0.0)) * (1.0 + float(strategy_effects.get("attack_ratio", 0.0)))
	stats["defense"] = float(stats.get("defense", 0.0)) + float(strategy_effects.get("defense_bonus", 0.0))
	stats["health"] = float(stats.get("health", 0.0)) * (1.0 + float(strategy_effects.get("max_health_ratio", 0.0)))
	stats["move_speed"] = float(stats.get("move_speed", 0.0)) * (1.0 + float(strategy_effects.get("move_speed_ratio", 0.0)))
	stats["basic_pierce"] = int(stats.get("basic_pierce", 0)) + int(strategy_effects.get("pierce_bonus", 0))
	var cooldown_floor := 4.2
	if hero_id == "zhao_yun":
		cooldown_floor = 4.0
	elif hero_id == "guan_yu":
		cooldown_floor = 4.8
	stats["active_cooldown"] = maxf(cooldown_floor, float(stats.get("active_cooldown", 8.0)) - float(strategy_effects.get("active_cooldown_reduction", 0.0)))
	return stats
