class_name UpgradeSystem
extends Node

const TIANJI_CATALOG = preload("res://scripts/domain/tianji_catalog.gd")
const MILITARY_STRATEGY = preload("res://scripts/domain/military_strategy.gd")
const COMMON_UPGRADE_IDS := ["common_attack", "common_defense", "common_speed", "common_heal"]
const TIANJI_ACTIVATION_IDS := ["tianji_lightning_activate", "tianji_wind_activate", "tianji_water_activate", "tianji_fire_activate", "tianji_arrow_activate"]
const TIANJI_UPGRADE_IDS := [
	"tianji_lightning_cooldown", "tianji_lightning_damage", "tianji_lightning_targets",
	"tianji_wind_cooldown", "tianji_wind_slow", "tianji_wind_knockback",
	"tianji_water_duration", "tianji_water_radius", "tianji_water_slow",
	"tianji_fire_cooldown", "tianji_fire_damage", "tianji_fire_spread",
	"tianji_arrow_cooldown", "tianji_arrow_damage", "tianji_arrow_volley",
]

const HERO_POOLS := {
	"zhang_fei": {
		"upgrade_ids": [
			"zhang_heavy_roar", "zhang_slam_leap", "zhang_slam_mastery",
			"zhang_rage", "zhang_rage_hunt", "zhang_rage_fervor", "zhang_rage_overwhelm",
			"zhang_iron_hide", "zhang_active_charge", "zhang_bridge_breaker", "zhang_bridge_repel", "zhang_bridge_shockwave",
			"zhang_earthshaker", "zhang_immovable", "zhang_battle_cry", "zhang_war_stomp",
		],
		"weapon_ids": ["zhang_heavy_roar", "zhang_slam_leap", "zhang_slam_mastery"],
		"passive_ids": ["zhang_rage", "zhang_rage_hunt", "zhang_rage_fervor", "zhang_rage_overwhelm"],
		"active_ids": ["zhang_iron_hide", "zhang_active_charge", "zhang_bridge_breaker", "zhang_bridge_repel", "zhang_bridge_shockwave"],
		"rare_ids": ["zhang_earthshaker", "zhang_immovable", "zhang_battle_cry", "zhang_war_stomp"],
		"core_talent_ids": ["zhang_heavy_roar", "zhang_iron_hide", "zhang_rage", "zhang_earthshaker"],
		"talent_blueprint_ids": [
			"zhang_slam_leap", "zhang_slam_mastery",
			"zhang_rage_hunt", "zhang_rage_fervor", "zhang_rage_overwhelm",
			"zhang_active_charge", "zhang_bridge_breaker", "zhang_bridge_repel", "zhang_bridge_shockwave",
			"zhang_immovable", "zhang_battle_cry", "zhang_war_stomp",
		],
		"progression_chains": [],
	},
	"guan_yu": {
		"upgrade_ids": [
			"guan_broad_edge", "guan_heavy_blade", "guan_drag_blade", "guan_drag_steadiness", "guan_drag_charge", "guan_drag_waves", "guan_drag_reach",
			"guan_fourth_strike", "guan_fourth_dash", "guan_fourth_collision", "guan_fourth_wave", "guan_fourth_execution",
			"guan_martial_pressure", "guan_battlefield_radius", "guan_iron_guard", "guan_pressure_recovery", "guan_mark_hunt",
			"guan_breaking_wave", "guan_rending_tide", "guan_wave_count", "guan_breaking_step", "guan_river_cleaver",
			"guan_saintly_wrath", "guan_war_banner", "guan_saintly_duration", "guan_saintly_warfront", "guan_sweeping_guard", "guan_sweeping_guard_large",
		],
		"weapon_ids": ["guan_broad_edge", "guan_heavy_blade", "guan_drag_blade", "guan_drag_steadiness", "guan_drag_charge", "guan_drag_waves", "guan_drag_reach", "guan_fourth_strike", "guan_fourth_dash", "guan_fourth_collision", "guan_fourth_wave", "guan_fourth_execution", "guan_sweeping_guard", "guan_sweeping_guard_large"],
		"passive_ids": ["guan_martial_pressure", "guan_battlefield_radius", "guan_iron_guard", "guan_pressure_recovery", "guan_mark_hunt"],
		"active_ids": ["guan_breaking_wave", "guan_rending_tide", "guan_wave_count", "guan_breaking_step", "guan_river_cleaver"],
		"rare_ids": ["guan_saintly_wrath", "guan_war_banner", "guan_saintly_duration", "guan_saintly_warfront"],
		"core_talent_ids": [
			"guan_broad_edge", "guan_heavy_blade", "guan_drag_waves", "guan_fourth_dash",
			"guan_martial_pressure", "guan_iron_guard", "guan_breaking_wave", "guan_rending_tide",
			"guan_wave_count", "guan_saintly_wrath", "guan_war_banner",
		],
		"talent_blueprint_ids": [
			"guan_sweeping_guard", "guan_sweeping_guard_large", "guan_drag_blade", "guan_drag_steadiness", "guan_drag_charge", "guan_drag_reach",
			"guan_fourth_strike", "guan_fourth_collision", "guan_fourth_wave", "guan_fourth_execution",
			"guan_battlefield_radius", "guan_pressure_recovery", "guan_mark_hunt",
			"guan_breaking_step", "guan_river_cleaver", "guan_saintly_duration", "guan_saintly_warfront",
		],
		"progression_chains": [],
	},
	"zhao_yun": {
		"upgrade_ids": [
			"spear_reach", "sweeping_wind", "dash_echo", "firewheel", "dragon_armor",
			"dragon_stride", "dragon_scale", "seven_edge", "snake_spin",
			"spear_shadow", "white_dragon", "returning_spear", "triumph", "dragon_focus",
			"firewheel_duration", "firewheel_volley", "firewheel_capstone",
			"sweeping_guard", "sweeping_guard_large", "dragon_scale_regen",
			"dragon_stride_double", "dragon_stride_threefold", "dragon_focus_guard", "dragon_focus_invulnerable",
		],
		"weapon_ids": ["spear_reach", "sweeping_wind", "dash_echo"],
		"passive_ids": ["dragon_armor", "dragon_stride", "dragon_scale", "dragon_focus"],
		"active_ids": ["seven_edge", "snake_spin", "spear_shadow"],
		"rare_ids": ["firewheel"],
		"core_talent_ids": [
			"spear_reach", "sweeping_wind", "dash_echo",
			"dragon_armor", "dragon_stride", "dragon_scale",
			"seven_edge", "snake_spin",
		],
		"talent_blueprint_ids": [
			"firewheel", "firewheel_duration", "firewheel_volley", "firewheel_capstone",
			"dragon_focus", "spear_shadow", "white_dragon", "returning_spear", "triumph",
			"sweeping_guard", "sweeping_guard_large", "dragon_scale_regen",
			"dragon_stride_double", "dragon_stride_threefold", "dragon_focus_guard", "dragon_focus_invulnerable",
		],
		"progression_chains": [["firewheel", "firewheel_duration", "firewheel_volley", "firewheel_capstone"]],
	},
	"ma_chao": {
		"upgrade_ids": ["ma_long_stride", "ma_iron_hoof", "ma_storm_charge", "ma_silver_afterimage"],
		"weapon_ids": ["ma_long_stride", "ma_iron_hoof"],
		"passive_ids": ["ma_long_stride", "ma_iron_hoof"],
		"active_ids": ["ma_storm_charge"],
		"rare_ids": ["ma_silver_afterimage"],
		"core_talent_ids": ["ma_long_stride", "ma_iron_hoof", "ma_storm_charge", "ma_silver_afterimage"],
		"talent_blueprint_ids": [],
		"progression_chains": [],
	},
	"huang_zhong": {
		"upgrade_ids": ["huang_draw_strength", "huang_hawk_eye", "huang_blade_return", "huang_dingjun_volley"],
		"weapon_ids": ["huang_draw_strength", "huang_hawk_eye"],
		"passive_ids": ["huang_blade_return", "huang_hawk_eye"],
		"active_ids": ["huang_hawk_eye", "huang_blade_return"],
		"rare_ids": ["huang_dingjun_volley"],
		"core_talent_ids": ["huang_draw_strength", "huang_hawk_eye", "huang_blade_return", "huang_dingjun_volley"],
		"talent_blueprint_ids": [],
		"progression_chains": [],
	},
}

const DEFINITIONS := {
	"common_attack": {"title": "猛攻", "category": "通用强化", "description": "基础攻击力 +5%，最多叠加 4 层。", "max_stacks": 4},
	"common_defense": {"title": "坚甲", "category": "通用强化", "description": "基础防御力 +5%，最多叠加 4 层。", "max_stacks": 4},
	"common_speed": {"title": "轻身", "category": "通用强化", "description": "基础移动速度 +2%，最多叠加 4 层。", "max_stacks": 4},
	"common_heal": {"title": "战地疗伤", "category": "通用强化", "description": "立即回复最大生命值的 10%；溢出部分转为 1 层护体。", "max_stacks": 99},
	"tianji_lightning_activate": {"title": "七星引雷·启阵", "category": "天机", "description": "解锁的七星引雷在本局开始演算。", "max_stacks": 1},
	"tianji_wind_activate": {"title": "巽风破阵·启阵", "category": "天机", "description": "解锁的巽风破阵在本局开始演算。", "max_stacks": 1},
	"tianji_water_activate": {"title": "八阵水势·启阵", "category": "天机", "description": "解锁的八阵水势在本局开始演算。", "max_stacks": 1},
	"tianji_fire_activate": {"title": "火雨焚营·启阵", "category": "天机", "description": "解锁的火雨焚营在本局开始演算。", "max_stacks": 1},
	"tianji_arrow_activate": {"title": "万箭穿云·启阵", "category": "天机", "description": "解锁的万箭穿云在本局开始演算。", "max_stacks": 1},
	"tianji_lightning_cooldown": {"title": "雷阵·疾演", "category": "七星引雷", "description": "七星引雷冷却时间 -6%。", "max_stacks": 3, "requires": "tianji_lightning_activate"},
	"tianji_lightning_damage": {"title": "雷阵·增幅", "category": "七星引雷", "description": "七星引雷伤害 +20%。", "max_stacks": 3, "requires": "tianji_lightning_activate"},
	"tianji_lightning_targets": {"title": "雷引·连锁", "category": "七星引雷", "description": "主雷后向范围外的目标追加 1 道延时副雷；副雷随机采用较低阶雷阵效果。", "max_stacks": 2, "requires": "tianji_lightning_activate", "min_skill_rank": 2},
	"tianji_wind_cooldown": {"title": "巽风·疾行", "category": "巽风破阵", "description": "巽风破阵冷却时间 -6%。", "max_stacks": 3, "requires": "tianji_wind_activate"},
	"tianji_wind_slow": {"title": "巽风·缚敌", "category": "巽风破阵", "description": "巽风破阵的迟滞效果提高。", "max_stacks": 3, "requires": "tianji_wind_activate"},
	"tianji_wind_knockback": {"title": "巽风·推山", "category": "巽风破阵", "description": "巽风破阵击退距离提高。", "max_stacks": 3, "requires": "tianji_wind_activate"},
	"tianji_water_duration": {"title": "水阵·久驻", "category": "八阵水势", "description": "八阵水势持续时间 +0.6 秒。", "max_stacks": 3, "requires": "tianji_water_activate"},
	"tianji_water_radius": {"title": "水阵·扩域", "category": "八阵水势", "description": "八阵水势作用范围 +12%。", "max_stacks": 3, "requires": "tianji_water_activate"},
	"tianji_water_slow": {"title": "水阵·沉流", "category": "八阵水势", "description": "八阵水势减速效果提高。", "max_stacks": 3, "requires": "tianji_water_activate"},
	"tianji_fire_cooldown": {"title": "火雨·疾落", "category": "火雨焚营", "description": "火雨焚营冷却时间 -6%。", "max_stacks": 3, "requires": "tianji_fire_activate"},
	"tianji_fire_damage": {"title": "火雨·烈焰", "category": "火雨焚营", "description": "火雨直击与燃烧伤害 +20%。", "max_stacks": 3, "requires": "tianji_fire_activate"},
	"tianji_fire_spread": {"title": "火雨·连营", "category": "火雨焚营", "description": "每轮火雨额外落下 1 颗火陨。", "max_stacks": 2, "requires": "tianji_fire_activate"},
	"tianji_arrow_cooldown": {"title": "箭阵·疾发", "category": "万箭穿云", "description": "万箭穿云冷却时间 -6%。", "max_stacks": 3, "requires": "tianji_arrow_activate"},
	"tianji_arrow_damage": {"title": "箭阵·破甲", "category": "万箭穿云", "description": "万箭穿云伤害 +20%。", "max_stacks": 3, "requires": "tianji_arrow_activate"},
	"tianji_arrow_volley": {"title": "箭阵·加急", "category": "万箭穿云", "description": "万箭穿云额外追加 1 轮齐射。", "max_stacks": 2, "requires": "tianji_arrow_activate"},
	"zhang_heavy_roar": {"title": "蛇矛掷阵", "category": "掷阵", "description": "普攻范围扩大，飞兵冲量与碰撞击退提高。", "max_stacks": 3},
	# Retained only so saves from the former three-node tree remain readable.
	"zhang_slam_range": {"title": "丈八跃砸·震域（旧版）", "category": "旧版兼容", "description": "旧存档兼容数据，不再提供购买或局内选择。", "max_stacks": 1, "shop_max_rank": 1, "shop_costs": [500], "shop_rank_limited": true},
	"zhang_slam_leap": {"title": "丈八跃砸·跃步", "category": "跃砸", "description": "第三段短距前跳，可有限修正方向；落地强化击退并造成短暂硬直。", "max_stacks": 1, "requires": "zhang_heavy_roar", "shop_max_rank": 1, "shop_costs": [600], "shop_rank_limited": true},
	"zhang_slam_mastery": {"title": "丈八跃砸·裂阵", "category": "跃砸", "description": "第三段支持摇杆控制方向与距离；扩大落点范围并提高伤害。", "max_stacks": 1, "requires": "zhang_slam_leap", "shop_max_rank": 1, "shop_costs": [1400], "shop_rank_limited": true},
	"zhang_leaping_slam": {"title": "丈八跃砸（旧版）", "category": "跃砸", "description": "旧版三阶战法数据，仅用于兼容旧存档，已拆分为震域、跃步、裂阵三个独立节点。", "max_stacks": 3, "shop_max_rank": 3, "shop_costs": [500, 600, 1400], "shop_rank_limited": true},
	"zhang_rage": {"title": "怒势借势", "category": "怒势", "description": "击杀 +1、格挡 +3、完美格挡 +4；累计 15 点获得 1 层怒势，最多 4 层。", "max_stacks": 1},
	"zhang_rage_hunt": {"title": "燕人疾怒", "category": "怒势", "description": "每级怒势触发门槛 -3 点，最多两级。", "max_stacks": 2, "requires": "zhang_rage", "shop_max_rank": 2, "shop_costs": [500, 900], "shop_rank_limited": true},
	"zhang_rage_fervor": {"title": "咆哮疾行", "category": "怒势", "description": "每级怒势持续 +2 秒、移速 +7%。", "max_stacks": 2, "requires": "zhang_rage_hunt", "shop_max_rank": 2, "shop_costs": [700, 1200], "shop_rank_limited": true},
	"zhang_rage_overwhelm": {"title": "怒势破军", "category": "怒势", "description": "怒势飞兵冲量、碰撞伤害与贯穿提高。", "max_stacks": 1, "requires": "zhang_rage_fervor", "shop_max_rank": 1, "shop_costs": [1800], "shop_rank_limited": true},
	"zhang_iron_hide": {"title": "铁躯震地", "category": "断桥", "description": "防御提高；据水断桥范围与架势伤害提高。", "max_stacks": 3},
	"zhang_active_charge": {"title": "据水蓄势", "category": "断桥", "description": "据水断桥默认可长按蓄力；此强化将满蓄时间缩短至 0.56 秒，并提高最远跳跃距离。", "max_stacks": 1, "requires": "zhang_iron_hide", "shop_max_rank": 1, "shop_costs": [650], "shop_rank_limited": true},
	"zhang_bridge_breaker": {"title": "断桥破阵", "category": "断桥", "description": "据水断桥伤害与落点范围提高。", "max_stacks": 3, "requires": "zhang_iron_hide", "shop_max_rank": 3, "shop_costs": [500, 850, 1400], "shop_rank_limited": true},
	"zhang_bridge_repel": {"title": "震退千军", "category": "断桥", "description": "据水断桥击退距离与硬直提高。", "max_stacks": 2, "requires": "zhang_bridge_breaker", "shop_max_rank": 2, "shop_costs": [700, 1200], "shop_rank_limited": true},
	"zhang_bridge_shockwave": {"title": "桥断余震", "category": "断桥", "description": "据水断桥中心命中伤害提高。", "max_stacks": 1, "requires": "zhang_bridge_repel", "shop_max_rank": 1, "shop_costs": [1800], "shop_rank_limited": true},
	"zhang_earthshaker": {"title": "万夫莫开", "category": "无双", "description": "万夫莫开的飞兵伤害与架势伤害提高。", "max_stacks": 3},
	"zhang_immovable": {"title": "万夫壁垒", "category": "无双", "description": "万夫状态减伤提高。", "max_stacks": 2, "requires": "zhang_earthshaker", "shop_max_rank": 2, "shop_costs": [600, 1100], "shop_rank_limited": true},
	"zhang_battle_cry": {"title": "当阳怒喝", "category": "无双", "description": "万夫状态持续时间与移速提高。", "max_stacks": 2, "requires": "zhang_immovable", "shop_max_rank": 2, "shop_costs": [750, 1300], "shop_rank_limited": true},
	"zhang_war_stomp": {"title": "裂地余威", "category": "无双", "description": "万夫初始震阵范围、伤害与击退提高。", "max_stacks": 1, "requires": "zhang_battle_cry", "shop_max_rank": 1, "shop_costs": [2200], "shop_rank_limited": true},
	"guan_broad_edge": {"title": "偃月展锋", "category": "偃月", "description": "三段横扫范围扩大，穿透 +2。", "max_stacks": 3},
	"guan_heavy_blade": {"title": "沉锋断阵", "category": "偃月", "description": "普攻伤害与击退提高。", "max_stacks": 3},
	"guan_drag_blade": {"title": "拖刀计", "category": "拖刀", "description": "长按普攻可蓄力拖刀；蓄满松开后斩出拖刀刀浪。", "max_stacks": 1, "shop_max_rank": 1, "shop_costs": [450], "shop_rank_limited": true},
	"guan_drag_steadiness": {"title": "持刃稳步", "category": "拖刀", "description": "拖刀蓄力时的减速幅度降低。商城每升 1 阶，局内最多可选择 1 层：10% / 30% / 50%。", "max_stacks": 3, "requires": "guan_drag_blade", "shop_max_rank": 3, "shop_costs": [500, 850, 1400], "shop_rank_limited": true},
	"guan_drag_charge": {"title": "蓄势疾斩", "category": "拖刀", "description": "拖刀所需蓄力时间缩短。商城每升 1 阶，局内最多可选择 1 层：10% / 30% / 50%。", "max_stacks": 3, "requires": "guan_drag_blade", "shop_max_rank": 3, "shop_costs": [500, 850, 1400], "shop_rank_limited": true},
	"guan_drag_waves": {"title": "拖刀分澜", "category": "拖刀", "description": "拖刀固定三道刀浪的有效距离与尺寸提升，最多两级。", "max_stacks": 2, "requires": "guan_drag_blade"},
	"guan_drag_reach": {"title": "长风拖刀", "category": "拖刀", "description": "拖刀刀浪移动距离与尺寸进一步提升。商城购买后，局内每阶可继续强化。", "max_stacks": 3, "requires": "guan_drag_blade", "shop_max_rank": 3, "shop_costs": [650, 1100, 1700], "shop_rank_limited": true},
	"guan_fourth_strike": {"title": "追锋断浪", "category": "偃月", "description": "普攻连招解锁第四段：向指定方向短距突进，并斩出小型刀浪。", "max_stacks": 1, "shop_max_rank": 1, "shop_costs": [500], "shop_rank_limited": true},
	"guan_fourth_dash": {"title": "追锋疾进", "category": "追锋断浪", "description": "第四段普攻的突进距离提高，最多叠加 3 层。", "max_stacks": 3, "requires": "guan_fourth_strike"},
	"guan_fourth_collision": {"title": "断阵冲势", "category": "追锋断浪", "description": "商城购买后，第四段突进路径可撞开敌人并造成击退。", "max_stacks": 1, "requires": "guan_fourth_strike", "shop_max_rank": 1, "shop_costs": [700], "shop_rank_limited": true},
	"guan_fourth_wave": {"title": "追锋横江", "category": "追锋断浪", "description": "第四段刀浪范围、伤害与尺寸提高。", "max_stacks": 3, "requires": "guan_fourth_strike", "shop_max_rank": 3, "shop_costs": [600, 1000, 1600], "shop_rank_limited": true},
	"guan_fourth_execution": {"title": "追锋斩将", "category": "追锋断浪", "description": "第四段刀浪对精英与领主伤害提高。", "max_stacks": 1, "requires": "guan_fourth_wave", "requires_stacks": 3, "shop_max_rank": 1, "shop_costs": [2200], "shop_rank_limited": true},
	"guan_martial_pressure": {"title": "兵临之势", "category": "兵势", "description": "近敌增益上限提高，敌阵中的攻防收益提高。", "max_stacks": 2},
	"guan_battlefield_radius": {"title": "兵势扩域", "category": "兵势", "description": "兵临之势的近敌判定范围扩大，最多叠加 3 层。", "max_stacks": 3, "shop_max_rank": 3, "shop_costs": [550, 900, 1400], "shop_rank_limited": true},
	"guan_iron_guard": {"title": "斩将锋芒", "category": "斩将", "description": "精英/BOSS斩将印上限与易伤效果提高。", "max_stacks": 3},
	"guan_pressure_recovery": {"title": "兵势回锋", "category": "兵势", "description": "兵势范围内击破敌军时恢复生命。", "max_stacks": 3, "requires": "guan_martial_pressure", "shop_max_rank": 3, "shop_costs": [600, 1000, 1600], "shop_rank_limited": true},
	"guan_mark_hunt": {"title": "斩将夺势", "category": "斩将", "description": "斩将印持续时间与易伤效果提高。", "max_stacks": 2, "requires": "guan_iron_guard", "shop_max_rank": 2, "shop_costs": [700, 1200], "shop_rank_limited": true},
	"guan_breaking_wave": {"title": "断浪追锋", "category": "断浪", "description": "青龙断浪冷却缩短，刀浪距离扩大。", "max_stacks": 3},
	"guan_rending_tide": {"title": "裂潮缓敌", "category": "断浪", "description": "刀浪伤害、击退与减速提高。", "max_stacks": 3},
	"guan_wave_count": {"title": "断浪成阵", "category": "断浪", "description": "青龙断浪固定三道刀浪的有效距离与尺寸提升，最多两级。", "max_stacks": 2},
	"guan_breaking_step": {"title": "青龙破阵", "category": "断浪", "description": "青龙断浪滑步距离与撞阵伤害提高。", "max_stacks": 3, "requires": "guan_breaking_wave", "shop_max_rank": 3, "shop_costs": [650, 1100, 1700], "shop_rank_limited": true},
	"guan_river_cleaver": {"title": "横江断流", "category": "断浪", "description": "青龙断浪刀浪宽度、伤害与击退提高。", "max_stacks": 2, "requires": "guan_breaking_step", "requires_stacks": 3, "shop_max_rank": 2, "shop_costs": [1000, 1800], "shop_rank_limited": true},
	"guan_saintly_wrath": {"title": "武圣怒斩", "category": "武圣", "description": "武圣期间刀浪与冲击波伤害、架势伤害提高。", "max_stacks": 3},
	"guan_war_banner": {"title": "军威如岳", "category": "武圣", "description": "无双能量获取效率提高，并立刻获得 12 点能量。", "max_stacks": 2},
	"guan_saintly_duration": {"title": "武圣久战", "category": "武圣", "description": "武圣持续时间 +2秒。", "max_stacks": 2, "requires": "guan_saintly_wrath", "shop_max_rank": 2, "shop_costs": [700, 1200], "shop_rank_limited": true},
	"guan_saintly_warfront": {"title": "武圣压阵", "category": "武圣", "description": "武圣震阵范围、伤害与击退提高。", "max_stacks": 2, "requires": "guan_saintly_duration", "requires_stacks": 2, "shop_max_rank": 2, "shop_costs": [1100, 2000], "shop_rank_limited": true},
	"guan_sweeping_guard": {"title": "偃月拦矢", "category": "偃月", "description": "普攻、拖刀斩浪与青龙断浪期间，可拦下正前方约 110° 内最多 3 枚弓箭或弩箭。", "max_stacks": 1, "shop_max_rank": 1, "shop_costs": [450], "shop_rank_limited": true},
	"guan_sweeping_guard_large": {"title": "青龙御矢", "category": "偃月", "description": "正前方拦截范围扩大至约 160°，每个动作最多可拦截 5 枚弹道。", "max_stacks": 1, "requires": "guan_sweeping_guard", "shop_max_rank": 1, "shop_costs": [700], "shop_rank_limited": true},
	"spear_reach": {"title": "枪势延展", "category": "枪法", "description": "三段普攻距离 +28，穿透 +2。", "max_stacks": 3},
	"sweeping_wind": {"title": "横扫余威", "category": "枪法", "description": "第二段横扫范围 +32、角度 +30°，击退更强。", "max_stacks": 3},
	"sweeping_guard": {"title": "枪幕拦矢", "category": "枪法", "description": "普攻动作中可拦下正前方小扇区内最多 3 枚弓箭或弩箭。", "max_stacks": 1, "requires": "sweeping_wind", "shop_max_rank": 1, "shop_costs": [450], "shop_rank_limited": true},
	"sweeping_guard_large": {"title": "龙枪御矢", "category": "枪法", "description": "枪幕拦矢的正前方防御扇区扩大。", "max_stacks": 1, "requires": "sweeping_guard", "shop_max_rank": 1, "shop_costs": [700], "shop_rank_limited": true},
	"dash_echo": {"title": "追云突刺", "category": "枪法", "description": "第三段突进 +46，命中后可移动恢复更长。", "max_stacks": 3},
	"firewheel": {"title": "哪吒火轮", "category": "枪法", "description": "龙胆激活时，第三段结束自动接火轮；完整释放后冷却 5 秒。", "max_stacks": 1, "shop_max_rank": 1, "shop_costs": [750], "shop_rank_limited": true},
	"firewheel_duration": {"title": "焰轮延烧", "category": "哪吒火轮", "description": "哪吒火轮完整旋转与免疫时间 +0.24 秒，并追加一次火轮震荡。", "max_stacks": 1, "requires": "firewheel", "shop_max_rank": 1, "shop_costs": [1100], "shop_rank_limited": true},
	"firewheel_volley": {"title": "乾坤掷轮", "category": "哪吒火轮", "description": "火轮期间随机掷出 12 枚远程火轮；无双每段追加 3 枚。", "max_stacks": 1, "requires": "firewheel_duration", "shop_max_rank": 1, "shop_costs": [1700], "shop_rank_limited": true},
	"firewheel_capstone": {"title": "风火贯阵", "category": "哪吒火轮", "description": "火轮持续至 3 秒，升级为巨型火轮并自动接第五段贯阵；无双每段追加 6 枚。", "max_stacks": 1, "requires": "firewheel_volley", "shop_max_rank": 1, "shop_costs": [2800], "shop_rank_limited": true},
	"dragon_armor": {"title": "胆魄凝甲", "category": "龙胆", "description": "防御 +8；龙胆状态下受到的伤害 -25%。", "max_stacks": 2},
	"dragon_stride": {"title": "破阵疾行", "category": "龙胆", "description": "龙胆持续 +1 秒，期间移速额外提高。", "max_stacks": 3},
	"dragon_stride_double": {"title": "龙行疾影", "category": "龙胆", "description": "破阵疾行满阶后，龙胆持续时间与移速加成翻倍。", "max_stacks": 1, "requires": "dragon_stride", "requires_stacks": 3, "shop_max_rank": 1, "shop_costs": [750], "shop_rank_limited": true},
	"dragon_stride_threefold": {"title": "云龙三叠", "category": "龙胆", "description": "龙胆达到 3 层时，共享持续时间再次翻倍。", "max_stacks": 1, "requires": "dragon_stride_double", "shop_max_rank": 1, "shop_costs": [1500], "shop_rank_limited": true},
	"dragon_scale": {"title": "龙鳞不灭", "category": "龙胆", "description": "生命上限 +18，并立即回复等量生命。", "max_stacks": 3},
	"dragon_scale_regen": {"title": "龙鳞回春", "category": "龙胆", "description": "击杀基础敌军有 8% / 11% / 14% 概率回复 1 / 2 / 3 点生命。", "max_stacks": 3, "requires": "dragon_scale", "shop_max_rank": 3, "shop_costs": [650, 1100, 1700], "shop_rank_limited": true},
	"dragon_focus": {"title": "龙胆精进", "category": "龙胆", "description": "龙胆触发门槛降至 12；再次选择后降至 9。", "max_stacks": 2, "shop_max_rank": 2, "shop_costs": [600, 1100], "shop_rank_limited": true},
	"dragon_focus_guard": {"title": "龙甲叠护", "category": "龙胆", "description": "龙胆新获得的护体可抵挡 4 次伤害。", "max_stacks": 1, "requires": "dragon_focus", "requires_stacks": 1, "shop_max_rank": 1, "shop_costs": [1400], "shop_rank_limited": true},
	"dragon_focus_invulnerable": {"title": "真龙不灭", "category": "龙胆", "description": "新获得龙胆护体时免疫所有伤害 5 秒，期间不消耗护体次数。", "max_stacks": 1, "requires": "dragon_focus_guard", "shop_max_rank": 1, "shop_costs": [2600], "shop_rank_limited": true},
	"seven_edge": {"title": "破军余锋", "category": "破军", "description": "破军冷却 -1.25 秒，最低 4.5 秒。", "max_stacks": 3},
	"snake_spin": {"title": "破军回旋", "category": "破军", "description": "破军范围、伤害、击退与脱离恢复均大幅提升。", "max_stacks": 3},
	"spear_shadow": {"title": "枪影随行", "category": "破军", "description": "破军结束后追加一次延迟枪影补击；本战法仅可获得一次。", "max_stacks": 1, "shop_max_rank": 1, "shop_costs": [800], "shop_rank_limited": true},
	"white_dragon": {"title": "白龙长驱", "category": "无双", "description": "七进七出每段突进距离 +24，并立刻获得 30 无双能量。", "max_stacks": 3, "shop_max_rank": 3, "shop_costs": [600, 1100, 1800], "shop_rank_limited": true},
	"returning_spear": {"title": "回马穿心", "category": "无双", "description": "七进七出每次穿阵的伤害提高。", "max_stacks": 3, "shop_max_rank": 3, "shop_costs": [650, 1150, 1900], "shop_rank_limited": true},
	"triumph": {"title": "凯歌", "category": "无双", "description": "无双充能效率提高；击败精英额外回血并充能。", "max_stacks": 1, "shop_max_rank": 1, "shop_costs": [1500], "shop_rank_limited": true},
	"ma_long_stride": {"title": "踏雪长驱", "category": "银枪", "description": "普攻距离提高，并立刻获得部分奔势。", "max_stacks": 3},
	"ma_iron_hoof": {"title": "铁骑余威", "category": "奔势", "description": "招式伤害与击退强度提高。", "max_stacks": 3},
	"ma_storm_charge": {"title": "西凉雷骑", "category": "破阵", "description": "西凉破阵冷却缩短，冲阵距离扩大。", "max_stacks": 3},
	"ma_silver_afterimage": {"title": "银影奔雷", "category": "无双", "description": "银枪奔雷伤害与架势伤害提高。", "max_stacks": 3},
	"huang_draw_strength": {"title": "强弓贯甲", "category": "弓术", "description": "弓箭伤害提高，穿透目标数增加。", "max_stacks": 3},
	"huang_hawk_eye": {"title": "百步鹰眼", "category": "弓术", "description": "普攻与主动技能射程提高。", "max_stacks": 3},
	"huang_blade_return": {"title": "刀弦自守", "category": "刀势", "description": "刀形态击退提高，防御提高。", "max_stacks": 3},
	"huang_dingjun_volley": {"title": "定军绝响", "category": "无双", "description": "定军连珠伤害与架势伤害提高。", "max_stacks": 3},
}

var rng := RandomNumberGenerator.new()
var owned_counts: Dictionary = {}
var unlocked_talents: Dictionary = {}
var unlocked_talent_ranks: Dictionary = {}
var active_hero_id := "zhao_yun"
var active_pool: Dictionary = HERO_POOLS["zhao_yun"] as Dictionary
var unlocked_tianji_ids: Array[String] = []
var tianji_ranks: Dictionary = {}
var active_tianji_ids: Array[String] = []
var tianji_slot_limit := TIANJI_CATALOG.MAX_ACTIVE_PER_RUN
var draft_option_count := 3
var draft_selection_limit := 1

func configure_talent_pool(profile: Dictionary, hero_id: String) -> void:
	active_hero_id = hero_id
	active_pool = HERO_POOLS.get(hero_id, {}) as Dictionary
	unlocked_talents.clear()
	unlocked_talent_ranks.clear()
	var hero_talents: Dictionary = profile.get("hero_talents", {})
	var talent_ids: Array = hero_talents.get(hero_id, [])
	var all_ranks: Dictionary = profile.get("hero_talent_ranks", {}) as Dictionary
	var hero_ranks: Dictionary = all_ranks.get(hero_id, {}) as Dictionary
	for talent_id in talent_ids:
		var normalized_id := str(talent_id)
		if _pool_ids("talent_blueprint_ids").has(normalized_id):
			unlocked_talents[normalized_id] = true
			unlocked_talent_ranks[normalized_id] = maxi(1, int(hero_ranks.get(normalized_id, 0)))
	for talent_id in _pool_ids("talent_blueprint_ids"):
		var normalized_id := str(talent_id)
		var rank := int(hero_ranks.get(normalized_id, 0))
		if rank <= 0:
			continue
		unlocked_talents[normalized_id] = true
		unlocked_talent_ranks[normalized_id] = rank

func configure_tianji_pool(profile: Dictionary) -> void:
	unlocked_tianji_ids.clear()
	var ranks: Dictionary = profile.get("tianji_skills", {}) as Dictionary
	tianji_ranks = ranks.duplicate()
	for skill_id in TIANJI_CATALOG.all_ids():
		if int(ranks.get(skill_id, 0)) > 0:
			unlocked_tianji_ids.append(skill_id)
	active_tianji_ids.clear()
	var strategy_effects := MILITARY_STRATEGY.effects_for_profile(profile)
	tianji_slot_limit = maxi(TIANJI_CATALOG.MAX_ACTIVE_PER_RUN, int(strategy_effects.get("tianji_slot_capacity", TIANJI_CATALOG.MAX_ACTIVE_PER_RUN)))
	draft_option_count = clampi(int(strategy_effects.get("upgrade_option_count", 3)), 3, 5)
	draft_selection_limit = clampi(int(strategy_effects.get("upgrade_selection_count", 1)), 1, 2)

func set_active_tianji_ids(ids: Array[String]) -> void:
	active_tianji_ids = ids.duplicate()

func is_tianji_upgrade(upgrade_id: String) -> bool:
	return TIANJI_ACTIVATION_IDS.has(upgrade_id) or TIANJI_UPGRADE_IDS.has(upgrade_id)

func tianji_skill_for_upgrade(upgrade_id: String) -> String:
	if upgrade_id.begins_with("tianji_lightning"):
		return "seven_star_lightning"
	if upgrade_id.begins_with("tianji_wind"):
		return "xun_wind_break"
	if upgrade_id.begins_with("tianji_water"):
		return "eight_trigram_tide"
	if upgrade_id.begins_with("tianji_fire"):
		return "fire_rain_burning"
	if upgrade_id.begins_with("tianji_arrow"):
		return "arrow_support_volley"
	return ""

func tianji_activation_ids() -> Array[String]:
	return TIANJI_ACTIVATION_IDS.duplicate()

func tianji_slot_capacity() -> int:
	return tianji_slot_limit

func upgrade_option_count() -> int:
	return draft_option_count

func upgrade_selection_limit() -> int:
	return draft_selection_limit

func seed_with(value: int) -> void:
	rng.seed = value
	owned_counts.clear()

func randomize_seed() -> void:
	rng.randomize()
	owned_counts.clear()

func draft(_level: int, option_count: int = -1) -> Array[String]:
	var requested_count := draft_option_count if option_count <= 0 else clampi(option_count, 1, 5)
	var result: Array[String] = []
	var available: Array[String] = []
	for candidate_pool in [
		_available_from(COMMON_UPGRADE_IDS),
		_available_from(_pool_ids("upgrade_ids")),
		_available_tianji_activation_ids(),
		_available_tianji_upgrade_ids(),
	]:
		for candidate_variant in candidate_pool:
			var candidate_id := str(candidate_variant)
			if not available.has(candidate_id):
				available.append(candidate_id)
	var activation_slots_remaining := maxi(0, tianji_slot_limit - active_tianji_ids.size())
	var activation_picks := 0
	while result.size() < requested_count and not available.is_empty():
		var index := rng.randi_range(0, available.size() - 1)
		var upgrade_id: String = available.pop_at(index)
		if TIANJI_ACTIVATION_IDS.has(upgrade_id):
			if activation_picks >= activation_slots_remaining:
				continue
			activation_picks += 1
		result.append(upgrade_id)
	return result

func record_selection(upgrade_id: String) -> void:
	owned_counts[upgrade_id] = int(owned_counts.get(upgrade_id, 0)) + 1

func title_for(upgrade_id: String) -> String:
	return str(_definition(upgrade_id).get("title", upgrade_id))

func description_for(upgrade_id: String) -> String:
	return str(_definition(upgrade_id).get("description", ""))

func category_for(upgrade_id: String) -> String:
	return str(_definition(upgrade_id).get("category", "强化"))

func is_talent_unlocked(upgrade_id: String) -> bool:
	return COMMON_UPGRADE_IDS.has(upgrade_id) or _pool_ids("core_talent_ids").has(upgrade_id) or unlocked_talents.has(upgrade_id) or is_tianji_upgrade(upgrade_id)

func _available_tianji_activation_ids() -> Array[String]:
	var available: Array[String] = []
	if active_tianji_ids.size() >= tianji_slot_limit:
		return available
	for skill_id in unlocked_tianji_ids:
		if active_tianji_ids.has(skill_id):
			continue
		var activation_id := _activation_id_for_skill(skill_id)
		if int(owned_counts.get(activation_id, 0)) < 1:
			available.append(activation_id)
	return available

func _available_tianji_upgrade_ids() -> Array[String]:
	var available: Array[String] = []
	for upgrade_id in TIANJI_UPGRADE_IDS:
		var skill_id := tianji_skill_for_upgrade(upgrade_id)
		if not active_tianji_ids.has(skill_id):
			continue
		var definition := _definition(upgrade_id)
		if int(tianji_ranks.get(skill_id, 0)) < int(definition.get("min_skill_rank", 1)):
			continue
		if int(owned_counts.get(upgrade_id, 0)) >= int(definition.get("max_stacks", 1)):
			continue
		available.append(upgrade_id)
	return available

func _activation_id_for_skill(skill_id: String) -> String:
	match skill_id:
		"seven_star_lightning": return "tianji_lightning_activate"
		"xun_wind_break": return "tianji_wind_activate"
		"eight_trigram_tide": return "tianji_water_activate"
		"fire_rain_burning": return "tianji_fire_activate"
		"arrow_support_volley": return "tianji_arrow_activate"
	return ""

func _available_from(candidates: Array) -> Array[String]:
	var available: Array[String] = []
	for candidate in candidates:
		var upgrade_id := str(candidate)
		if not is_talent_unlocked(upgrade_id):
			continue
		var definition := _definition(upgrade_id)
		var prerequisite := str(definition.get("requires", ""))
		var required_stacks := maxi(1, int(definition.get("requires_stacks", 1)))
		if not prerequisite.is_empty() and int(owned_counts.get(prerequisite, 0)) < required_stacks:
			continue
		var max_stacks := int(definition.get("max_stacks", 1))
		if bool(definition.get("shop_rank_limited", false)):
			max_stacks = mini(max_stacks, int(unlocked_talent_ranks.get(upgrade_id, 0)))
		if int(owned_counts.get(upgrade_id, 0)) < max_stacks:
			available.append(upgrade_id)
	return available

func _pool_ids(key: String) -> Array:
	return _pool_arrays(key)

func _pool_arrays(key: String) -> Array:
	return active_pool.get(key, []) as Array

func _definition(upgrade_id: String) -> Dictionary:
	return DEFINITIONS.get(upgrade_id, {}) as Dictionary
