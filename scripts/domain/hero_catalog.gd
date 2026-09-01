extends RefCounted

const MILITARY_STRATEGY = preload("res://scripts/domain/military_strategy.gd")
const HERO_IDS: Array[String] = ["guan_yu", "zhang_fei", "zhao_yun", "ma_chao", "huang_zhong"]

const HEROES := {
	"guan_yu": {
		"id": "guan_yu",
		"name": "关羽",
		"hud_name": "关羽 云长",
		"role": "重击·破势",
		"unlock_cost": 0,
		"playable": true,
		"actor_scene": "res://scenes/actors/guan_yu_actor.tscn",
		"ultimate_cutin": "res://assets/art/characters/guan_yu/cutins/wushuang.png",
		"portrait": "res://assets/art/characters/guan_yu/portraits/guanyu.png",
		"stats": {
			"attack": 20.0,
			"defense": 18.0,
			"health": 160.0,
			"move_speed": 98.0,
			"basic_range": 164.0,
			"basic_pierce": 12,
			"active_cooldown": 7.5,
			"ultimate_cost": 60.0,
		},
		"skills": [
			{"name": "普攻·青龙三斩", "type": "普攻", "description": "默认三段大开大合的偃月横扫；拖刀与第四段追锋断浪需在局内通过战法获得。"},
			{"name": "被动·兵势 / 斩将", "type": "被动", "description": "周围敌人越多，关羽攻防越强；攻击精英与BOSS会叠加斩将印。"},
			{"name": "主动·青龙断浪", "type": "主动", "description": "短距离破阵滑步撞开轻敌，随后斩出长距离巨型刀浪，击退并减速敌人。"},
			{"name": "无双·武圣", "type": "无双", "description": "消耗60能量，持续15秒强化攻击与移速；青龙断浪冷却减半（最低3.5秒）。已获得拖刀计时，拖刀刀浪会无限穿透并持续滚出屏幕。"},
		],
		"talent_tree": [
			{"title": "偃月 / 拖刀", "core_title": "基础偃月", "core_summary": "默认三段横扫；拖刀与追锋需先在商城购买，再于局内获取。", "nodes": [{"id": "guan_broad_edge", "summary": "横扫范围", "is_core": true}, {"id": "guan_heavy_blade", "summary": "沉重斩击", "is_core": true}, {"id": "guan_drag_blade", "cost": 450, "summary": "长按拖刀"}, {"id": "guan_drag_steadiness", "cost": 500, "summary": "减速降低"}, {"id": "guan_drag_charge", "cost": 500, "summary": "蓄力缩短"}, {"id": "guan_drag_waves", "summary": "刀浪尺寸", "is_run_upgrade": true}, {"id": "guan_drag_reach", "cost": 650, "summary": "长风拖刀"}, {"id": "guan_fourth_strike", "cost": 500, "summary": "第四段普攻"}, {"id": "guan_fourth_dash", "summary": "突进加距", "is_run_upgrade": true}, {"id": "guan_fourth_collision", "cost": 700, "summary": "断阵冲势"}, {"id": "guan_fourth_wave", "cost": 600, "summary": "刀浪增幅"}, {"id": "guan_fourth_execution", "cost": 2200, "summary": "斩将追锋"}, {"id": "guan_sweeping_guard", "cost": 450, "summary": "正面拦矢"}, {"id": "guan_sweeping_guard_large", "cost": 700, "summary": "扩大拦截"}]},
			{"title": "兵势 / 斩将", "core_title": "基础兵势", "core_summary": "近敌增益与高级目标易伤默认开放。", "nodes": [{"id": "guan_martial_pressure", "summary": "近敌攻防", "is_core": true}, {"id": "guan_battlefield_radius", "cost": 550, "summary": "扩大判定"}, {"id": "guan_pressure_recovery", "cost": 600, "summary": "兵势回血"}, {"id": "guan_iron_guard", "summary": "斩将易伤", "is_core": true}, {"id": "guan_mark_hunt", "cost": 700, "summary": "斩将增幅"}]},
			{"title": "断浪", "core_title": "基础断浪", "core_summary": "滑步巨型刀浪默认开放。", "nodes": [{"id": "guan_breaking_wave", "summary": "刀浪距离", "is_core": true}, {"id": "guan_rending_tide", "summary": "减速击退", "is_core": true}, {"id": "guan_wave_count", "summary": "刀浪尺寸", "is_core": true}, {"id": "guan_breaking_step", "cost": 650, "summary": "滑步撞阵"}, {"id": "guan_river_cleaver", "cost": 1000, "summary": "横江断流"}]},
			{"title": "武圣", "core_title": "基础武圣", "core_summary": "15秒压阵状态默认开放。", "nodes": [{"id": "guan_saintly_wrath", "summary": "武圣强化", "is_core": true}, {"id": "guan_war_banner", "summary": "军威充能", "is_core": true}, {"id": "guan_saintly_duration", "cost": 700, "summary": "武圣延时"}, {"id": "guan_saintly_warfront", "cost": 1100, "summary": "震阵增幅"}]},
		],
	},
	"zhang_fei": {
		"id": "zhang_fei",
		"name": "张飞",
		"hud_name": "张飞 翼德",
		"role": "重击·掷阵",
		"unlock_cost": 3000,
		"playable": true,
		"actor_scene": "res://scenes/actors/zhang_fei_actor.tscn",
		"ultimate_cutin": "res://assets/art/characters/zhang_fei/cutins/wushuang.png",
		"portrait": "res://assets/art/characters/zhang_fei/portraits/zhangfei.png",
		"stats": {
			"attack": 20.0,
			"defense": 17.0,
			"health": 165.0,
			"move_speed": 92.0,
			"basic_range": 158.0,
			"basic_pierce": 16,
			"active_cooldown": 7.6,
			"ultimate_cost": 50.0,
		},
		"skills": [
			{"name": "普攻·丈八掷阵", "type": "普攻", "description": "前两式扫阵挑飞；第三式以扩大砸地范围为中心，并向正面推出低伤害余震。解锁跃步后可短距前跳，裂阵后获得完整的方向跃砸。"},
			{"name": "被动·燕人怒势", "type": "被动", "description": "击杀 +1、格挡 +3、完美格挡 +4；累计 15 点获得怒势，最多 4 层。每层攻速 +4%，侧后受击减伤 18%。"},
			{"name": "主动·据水断桥", "type": "主动", "description": "短按近距离跃砸；长按蓄力，松开时按蓄力时长决定跳跃距离。"},
			{"name": "无双·万夫莫开", "type": "无双", "description": "消耗 40 能量，怒喝震阵后进入 10 秒万夫状态；自身减伤，飞兵撞击与连锁强化，第三式跃砸范围与冲量提升。"},
		],
		"talent_tree": [
			{"title": "掷阵 / 跃砸", "core_title": "基础掷阵", "core_summary": "前两式扫阵挑飞；第三式通过两阶战法获得质变。", "nodes": [{"id": "zhang_heavy_roar", "summary": "飞兵冲量", "is_core": true}, {"id": "zhang_slam_leap", "cost": 600, "summary": "短距前跳"}, {"id": "zhang_slam_mastery", "cost": 1400, "summary": "方向跃砸"}]},
		{"title": "怒势", "core_title": "基础怒势", "core_summary": "击杀或格挡积累怒势，强化飞兵碰撞。", "nodes": [{"id": "zhang_rage", "summary": "怒势增伤", "is_core": true}, {"id": "zhang_rage_hunt", "cost": 500, "summary": "更快触发"}, {"id": "zhang_rage_fervor", "cost": 700, "summary": "怒势疾行"}, {"id": "zhang_rage_overwhelm", "cost": 1800, "summary": "飞兵破军"}]},
			{"title": "断桥", "core_title": "基础断桥", "core_summary": "跃砸、蓄力控制与范围震退默认开放。", "nodes": [{"id": "zhang_iron_hide", "summary": "铁躯震地", "is_core": true}, {"id": "zhang_active_charge", "cost": 650, "summary": "蓄势强化"}, {"id": "zhang_bridge_breaker", "cost": 500, "summary": "落点扩域"}, {"id": "zhang_bridge_repel", "cost": 700, "summary": "震退硬直"}, {"id": "zhang_bridge_shockwave", "cost": 1800, "summary": "中心重击"}]},
			{"title": "无双", "core_title": "基础万夫莫开", "core_summary": "万夫莫开默认开放。", "nodes": [{"id": "zhang_earthshaker", "summary": "飞兵贯阵", "is_core": true}, {"id": "zhang_immovable", "cost": 600, "summary": "万夫减伤"}, {"id": "zhang_battle_cry", "cost": 750, "summary": "怒喝疾行"}, {"id": "zhang_war_stomp", "cost": 2200, "summary": "裂地余威"}]},
		],
	},
	"zhao_yun": {
		"id": "zhao_yun",
		"name": "赵云",
		"hud_name": "赵云 子龙",
		"role": "突进·连击",
		"unlock_cost": 3000,
		"playable": true,
		"actor_scene": "res://scenes/actors/player_actor.tscn",
		"ultimate_cutin": "res://assets/art/characters/zhao_yun/cutins/wushuang.png",
		"portrait": "res://assets/art/characters/zhao_yun/portraits/zhaoyun.png",
		"stats": {
			"attack": 18.0,
			"defense": 13.0,
			"health": 130.0,
			"move_speed": 125.0,
			"basic_range": 144.0,
			"basic_pierce": 4,
			"active_cooldown": 6.5,
			"ultimate_cost": 40.0,
		},
		"skills": [
			{"name": "普攻·龙胆枪", "type": "普攻", "description": "三段连招：点刺破阵、横扫开路、穿阵挑刺。"},
			{"name": "被动·龙胆", "type": "被动", "description": "击杀基础敌军积累进度；命中精英 +3、Boss +5，达到 15 点后获得护体与疾行。"},
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
					{"id": "sweeping_guard", "cost": 450, "summary": "小扇区拦箭"},
					{"id": "sweeping_guard_large", "cost": 700, "summary": "扩大拦箭范围"},
					{"id": "firewheel", "cost": 750, "summary": "火轮免疫"},
					{"id": "firewheel_duration", "cost": 1100, "summary": "延时震荡"},
					{"id": "firewheel_volley", "cost": 1700, "summary": "随机投掷"},
					{"id": "firewheel_capstone", "cost": 2800, "summary": "第五段贯阵"},
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
					{"id": "dragon_stride_double", "cost": 750, "summary": "满阶疾行翻倍"},
					{"id": "dragon_stride_threefold", "cost": 1500, "summary": "三层持续再翻倍"},
					{"id": "dragon_scale_regen", "cost": 650, "summary": "击杀概率回春"},
					{"id": "dragon_focus", "cost": 600, "summary": "触发层数降低"},
					{"id": "dragon_focus_guard", "cost": 1400, "summary": "护体抵挡四次"},
					{"id": "dragon_focus_invulnerable", "cost": 2600, "summary": "新护体五秒无敌"},
				],
			},
			{
				"title": "破军",
				"core_title": "基础破军",
				"core_summary": "破军余锋、破军回旋默认开放。",
				"nodes": [
					{"id": "seven_edge", "summary": "冷却缩短", "is_core": true},
					{"id": "snake_spin", "summary": "范围与击退", "is_core": true},
				{"id": "spear_shadow", "cost": 800, "summary": "追加枪影补击"},
				],
			},
			{
				"title": "无双",
				"core_title": "基础无双",
				"core_summary": "七进七出为赵云固有无双。",
				"nodes": [
				{"id": "white_dragon", "cost": 600, "summary": "突进与能量提升"},
				{"id": "returning_spear", "cost": 650, "summary": "穿阵伤害提高"},
				{"id": "triumph", "cost": 1500, "summary": "充能与精英奖励"},
				],
			},
		],
	},
	"ma_chao": {
		"id": "ma_chao",
		"name": "马超",
		"hud_name": "马超 孟起",
		"role": "冲锋·穿阵",
		"unlock_cost": 3000,
		"playable": true,
		"shop_available": false,
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
		"hud_name": "黄忠 汉升",
		"role": "远程·狙击",
		"unlock_cost": 3000,
		"playable": true,
		"shop_available": false,
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

static func hud_name_for(hero_id: String) -> String:
	var definition := definition_for(hero_id)
	return str(definition.get("hud_name", definition.get("name", "武将")))

static func ultimate_cutin_for(hero_id: String) -> String:
	return str(definition_for(hero_id).get("ultimate_cutin", ""))

static func display_stats_for(hero_id: String, profile: Dictionary) -> Dictionary:
	var definition := definition_for(hero_id)
	var stats: Dictionary = definition.get("stats", {}).duplicate(true)
	var strategy_effects := MILITARY_STRATEGY.effects_for_profile(profile)
	stats["attack"] = float(stats.get("attack", 0.0)) + float(strategy_effects.get("attack_bonus", 0.0))
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
