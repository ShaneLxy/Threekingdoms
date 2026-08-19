class_name UpgradeSystem
extends Node

const TIANJI_CATALOG = preload("res://scripts/domain/tianji_catalog.gd")
const COMMON_UPGRADE_IDS := ["common_attack", "common_defense", "common_speed", "common_heal"]
const COMMON_UPGRADE_CHANCE_EARLY := 0.38
const COMMON_UPGRADE_CHANCE := 0.30
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
		"upgrade_ids": ["zhang_heavy_roar", "zhang_iron_hide", "zhang_rage", "zhang_earthshaker"],
		"weapon_ids": ["zhang_heavy_roar", "zhang_rage"],
		"passive_ids": ["zhang_iron_hide", "zhang_rage"],
		"active_ids": ["zhang_iron_hide"],
		"rare_ids": ["zhang_earthshaker"],
		"core_talent_ids": ["zhang_heavy_roar", "zhang_iron_hide", "zhang_rage", "zhang_earthshaker"],
		"talent_blueprint_ids": [],
		"progression_chains": [],
	},
	"guan_yu": {
		"upgrade_ids": [
			"guan_broad_edge", "guan_heavy_blade", "guan_drag_waves", "guan_drag_reach",
			"guan_martial_pressure", "guan_iron_guard", "guan_breaking_wave", "guan_rending_tide",
			"guan_wave_count", "guan_saintly_wrath", "guan_war_banner", "guan_sweeping_guard", "guan_sweeping_guard_large",
		],
		"weapon_ids": ["guan_broad_edge", "guan_heavy_blade", "guan_drag_waves", "guan_drag_reach", "guan_sweeping_guard", "guan_sweeping_guard_large"],
		"passive_ids": ["guan_martial_pressure", "guan_iron_guard"],
		"active_ids": ["guan_breaking_wave", "guan_rending_tide", "guan_wave_count"],
		"rare_ids": ["guan_saintly_wrath", "guan_war_banner"],
		"core_talent_ids": [
			"guan_broad_edge", "guan_heavy_blade", "guan_drag_waves", "guan_drag_reach",
			"guan_martial_pressure", "guan_iron_guard", "guan_breaking_wave", "guan_rending_tide",
			"guan_wave_count", "guan_saintly_wrath", "guan_war_banner",
		],
		"talent_blueprint_ids": ["guan_sweeping_guard", "guan_sweeping_guard_large"],
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
	"tianji_lightning_cooldown": {"title": "雷阵·疾演", "category": "七星引雷", "description": "七星引雷冷却时间 -12%。", "max_stacks": 3, "requires": "tianji_lightning_activate"},
	"tianji_lightning_damage": {"title": "雷阵·增幅", "category": "七星引雷", "description": "七星引雷伤害 +20%。", "max_stacks": 3, "requires": "tianji_lightning_activate"},
	"tianji_lightning_targets": {"title": "雷阵·分光", "category": "七星引雷", "description": "七星引雷额外锁定 1 个目标。", "max_stacks": 2, "requires": "tianji_lightning_activate"},
	"tianji_wind_cooldown": {"title": "巽风·疾行", "category": "巽风破阵", "description": "巽风破阵冷却时间 -12%。", "max_stacks": 3, "requires": "tianji_wind_activate"},
	"tianji_wind_slow": {"title": "巽风·缚敌", "category": "巽风破阵", "description": "巽风破阵的迟滞效果提高。", "max_stacks": 3, "requires": "tianji_wind_activate"},
	"tianji_wind_knockback": {"title": "巽风·推山", "category": "巽风破阵", "description": "巽风破阵击退距离提高。", "max_stacks": 3, "requires": "tianji_wind_activate"},
	"tianji_water_duration": {"title": "水阵·久驻", "category": "八阵水势", "description": "八阵水势持续时间 +0.6 秒。", "max_stacks": 3, "requires": "tianji_water_activate"},
	"tianji_water_radius": {"title": "水阵·扩域", "category": "八阵水势", "description": "八阵水势作用范围 +12%。", "max_stacks": 3, "requires": "tianji_water_activate"},
	"tianji_water_slow": {"title": "水阵·沉流", "category": "八阵水势", "description": "八阵水势减速效果提高。", "max_stacks": 3, "requires": "tianji_water_activate"},
	"tianji_fire_cooldown": {"title": "火雨·疾落", "category": "火雨焚营", "description": "火雨焚营冷却时间 -12%。", "max_stacks": 3, "requires": "tianji_fire_activate"},
	"tianji_fire_damage": {"title": "火雨·烈焰", "category": "火雨焚营", "description": "火雨直击与燃烧伤害 +20%。", "max_stacks": 3, "requires": "tianji_fire_activate"},
	"tianji_fire_spread": {"title": "火雨·连营", "category": "火雨焚营", "description": "每轮火雨额外落下 1 颗火陨。", "max_stacks": 2, "requires": "tianji_fire_activate"},
	"tianji_arrow_cooldown": {"title": "箭阵·疾发", "category": "万箭穿云", "description": "万箭穿云冷却时间 -12%。", "max_stacks": 3, "requires": "tianji_arrow_activate"},
	"tianji_arrow_damage": {"title": "箭阵·破甲", "category": "万箭穿云", "description": "万箭穿云伤害 +20%。", "max_stacks": 3, "requires": "tianji_arrow_activate"},
	"tianji_arrow_volley": {"title": "箭阵·加急", "category": "万箭穿云", "description": "万箭穿云额外追加 1 轮齐射。", "max_stacks": 2, "requires": "tianji_arrow_activate"},
	"zhang_heavy_roar": {"title": "蛇矛掷阵", "category": "掷阵", "description": "普攻范围扩大，飞兵冲量与碰撞击退提高。", "max_stacks": 3},
	"zhang_iron_hide": {"title": "铁躯震地", "category": "断桥", "description": "防御提高；主动跃砸范围与架势伤害提高。", "max_stacks": 3},
	"zhang_rage": {"title": "怒势借势", "category": "怒势", "description": "立刻获得怒势，并提高飞兵碰撞伤害。", "max_stacks": 3},
	"zhang_earthshaker": {"title": "万夫莫开", "category": "无双", "description": "万夫莫开的飞兵伤害与架势伤害提高。", "max_stacks": 3},
	"guan_broad_edge": {"title": "偃月展锋", "category": "偃月", "description": "三段横扫范围扩大，穿透 +2。", "max_stacks": 3},
	"guan_heavy_blade": {"title": "沉锋断阵", "category": "偃月", "description": "普攻伤害与击退提高。", "max_stacks": 3},
	"guan_drag_waves": {"title": "拖刀分澜", "category": "拖刀", "description": "蓄满拖刀额外发射一道刀浪，最多三道。", "max_stacks": 2},
	"guan_drag_reach": {"title": "长风拖刃", "category": "拖刀", "description": "拖刀刀浪移动距离延长。", "max_stacks": 3},
	"guan_martial_pressure": {"title": "兵临之势", "category": "兵势", "description": "近敌增益上限提高，敌阵中的攻防收益提高。", "max_stacks": 2},
	"guan_iron_guard": {"title": "斩将锋芒", "category": "斩将", "description": "精英/BOSS斩将印上限与易伤效果提高。", "max_stacks": 3},
	"guan_breaking_wave": {"title": "断浪追锋", "category": "断浪", "description": "青龙断浪冷却缩短，刀浪距离扩大。", "max_stacks": 3},
	"guan_rending_tide": {"title": "裂潮缓敌", "category": "断浪", "description": "刀浪伤害、击退与减速提高。", "max_stacks": 3},
	"guan_wave_count": {"title": "断浪成阵", "category": "断浪", "description": "青龙断浪额外发射刀浪，最多三道。", "max_stacks": 2},
	"guan_saintly_wrath": {"title": "武圣怒斩", "category": "武圣", "description": "武圣期间刀浪与冲击波伤害、架势伤害提高。", "max_stacks": 3},
	"guan_war_banner": {"title": "军威如岳", "category": "武圣", "description": "无双能量获取效率提高，并立刻获得 12 点能量。", "max_stacks": 2},
	"guan_sweeping_guard": {"title": "偃月拦矢", "category": "偃月", "description": "普攻、拖刀斩浪与青龙断浪期间，可拦下正前方约 110° 内最多 3 枚弓箭或弩箭。", "max_stacks": 1},
	"guan_sweeping_guard_large": {"title": "青龙御矢", "category": "偃月", "description": "正前方拦截范围扩大至约 160°，每个动作最多可拦截 5 枚弹道。", "max_stacks": 1, "requires": "guan_sweeping_guard"},
	"spear_reach": {"title": "枪势延展", "category": "枪法", "description": "三段普攻距离 +28，穿透 +2。", "max_stacks": 3},
	"sweeping_wind": {"title": "横扫余威", "category": "枪法", "description": "第二段横扫范围 +32、角度 +30°，击退更强。", "max_stacks": 3},
	"sweeping_guard": {"title": "枪幕拦矢", "category": "枪法", "description": "普攻动作中可拦下正前方小扇区内最多 3 枚弓箭或弩箭。", "max_stacks": 1, "requires": "sweeping_wind"},
	"sweeping_guard_large": {"title": "龙枪御矢", "category": "枪法", "description": "枪幕拦矢的正前方防御扇区扩大。", "max_stacks": 1, "requires": "sweeping_guard"},
	"dash_echo": {"title": "追云突刺", "category": "枪法", "description": "第三段突进 +46，命中后可移动恢复更长。", "max_stacks": 3},
	"firewheel": {"title": "哪吒火轮", "category": "枪法", "description": "龙胆激活时，第三段结束自动接火轮；完整释放后冷却 5 秒。", "max_stacks": 1},
	"firewheel_duration": {"title": "焰轮延烧", "category": "哪吒火轮", "description": "哪吒火轮完整旋转与免疫时间 +0.24 秒，并追加一次火轮震荡。", "max_stacks": 1, "requires": "firewheel"},
	"firewheel_volley": {"title": "乾坤掷轮", "category": "哪吒火轮", "description": "火轮期间随机掷出 12 枚远程火轮；无双每段追加 3 枚。", "max_stacks": 1, "requires": "firewheel_duration"},
	"firewheel_capstone": {"title": "风火贯阵", "category": "哪吒火轮", "description": "火轮持续至 3 秒，升级为巨型火轮并自动接第五段贯阵；无双每段追加 6 枚。", "max_stacks": 1, "requires": "firewheel_volley"},
	"dragon_armor": {"title": "胆魄凝甲", "category": "龙胆", "description": "防御 +8；龙胆状态下受到的伤害 -25%。", "max_stacks": 2},
	"dragon_stride": {"title": "破阵疾行", "category": "龙胆", "description": "龙胆持续 +1 秒，期间移速额外提高。", "max_stacks": 3},
	"dragon_stride_double": {"title": "龙行疾影", "category": "龙胆", "description": "破阵疾行满阶后，龙胆持续时间与移速加成翻倍。", "max_stacks": 1, "requires": "dragon_stride", "requires_stacks": 3},
	"dragon_stride_threefold": {"title": "云龙三叠", "category": "龙胆", "description": "龙胆达到 3 层时，共享持续时间再次翻倍。", "max_stacks": 1, "requires": "dragon_stride_double"},
	"dragon_scale": {"title": "龙鳞不灭", "category": "龙胆", "description": "生命上限 +18，并立即回复等量生命。", "max_stacks": 3},
	"dragon_scale_regen": {"title": "龙鳞回春", "category": "龙胆", "description": "击杀基础敌军时有 8% 概率回复 1 点生命。", "max_stacks": 1, "requires": "dragon_scale"},
	"dragon_focus": {"title": "龙胆精进", "category": "龙胆", "description": "龙胆触发层数降至 18；再次选择后降至 15。", "max_stacks": 2},
	"dragon_focus_guard": {"title": "龙甲叠护", "category": "龙胆", "description": "龙胆新获得的护体可抵挡 4 次伤害。", "max_stacks": 1, "requires": "dragon_focus", "requires_stacks": 2},
	"dragon_focus_invulnerable": {"title": "真龙不灭", "category": "龙胆", "description": "新获得龙胆护体时免疫所有伤害 5 秒，期间不消耗护体次数。", "max_stacks": 1, "requires": "dragon_focus_guard"},
	"seven_edge": {"title": "破军余锋", "category": "破军", "description": "破军冷却 -1.25 秒，最低 4.5 秒。", "max_stacks": 3},
	"snake_spin": {"title": "破军回旋", "category": "破军", "description": "破军范围、伤害、击退与脱离恢复均大幅提升。", "max_stacks": 3},
	"spear_shadow": {"title": "枪影随行", "category": "破军", "description": "破军结束后追加一次延迟枪影补击。", "max_stacks": 2},
	"white_dragon": {"title": "白龙长驱", "category": "无双", "description": "七进七出每段突进距离 +24，并立刻获得 30 无双能量。", "max_stacks": 3},
	"returning_spear": {"title": "回马穿心", "category": "无双", "description": "七进七出每次穿阵的伤害提高。", "max_stacks": 3},
	"triumph": {"title": "凯歌", "category": "无双", "description": "无双充能效率提高；击败精英额外回血并充能。", "max_stacks": 1},
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
var active_hero_id := "zhao_yun"
var active_pool: Dictionary = HERO_POOLS["zhao_yun"] as Dictionary
var unlocked_tianji_ids: Array[String] = []
var active_tianji_ids: Array[String] = []

func configure_talent_pool(profile: Dictionary, hero_id: String) -> void:
	active_hero_id = hero_id
	active_pool = HERO_POOLS.get(hero_id, {}) as Dictionary
	unlocked_talents.clear()
	var hero_talents: Dictionary = profile.get("hero_talents", {})
	var talent_ids: Array = hero_talents.get(hero_id, [])
	for talent_id in talent_ids:
		var normalized_id := str(talent_id)
		if _pool_ids("talent_blueprint_ids").has(normalized_id):
			unlocked_talents[normalized_id] = true

func configure_tianji_pool(profile: Dictionary) -> void:
	unlocked_tianji_ids.clear()
	var ranks: Dictionary = profile.get("tianji_skills", {}) as Dictionary
	for skill_id in TIANJI_CATALOG.all_ids():
		if int(ranks.get(skill_id, 0)) > 0:
			unlocked_tianji_ids.append(skill_id)
	active_tianji_ids.clear()

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

func seed_with(value: int) -> void:
	rng.seed = value
	owned_counts.clear()

func draft(level: int) -> Array[String]:
	var result: Array[String] = []
	var chained_follow_up := _next_chained_upgrade()
	if not chained_follow_up.is_empty():
		result.append(chained_follow_up)
	if _should_offer_tianji_activation(level):
		_pick_from_bucket(_available_tianji_activation_ids(), result)
	var common_chance := COMMON_UPGRADE_CHANCE_EARLY if level <= 2 else COMMON_UPGRADE_CHANCE
	if result.size() < 3 and rng.randf() < common_chance:
		_pick_from_bucket(COMMON_UPGRADE_IDS, result)
	if level <= 2:
		_pick_from_bucket(_pool_ids("weapon_ids"), result)
		_pick_from_bucket(_pool_ids("passive_ids"), result)
		_pick_from_bucket(_pool_ids("active_ids"), result)
	_pick_from_bucket(_available_tianji_upgrade_ids(), result)
	_fill_random(result)
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

func _should_offer_tianji_activation(level: int) -> bool:
	if active_tianji_ids.size() >= TIANJI_CATALOG.MAX_ACTIVE_PER_RUN or unlocked_tianji_ids.is_empty():
		return false
	return level <= 3 or active_tianji_ids.is_empty()

func _available_tianji_activation_ids() -> Array[String]:
	var available: Array[String] = []
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

func _pick_from_bucket(bucket: Array, result: Array[String]) -> void:
	var available := _available_from(bucket)
	if available.is_empty() or result.size() >= 3:
		return
	result.append(available.pop_at(rng.randi_range(0, available.size() - 1)))

func _fill_random(result: Array[String]) -> void:
	var available := _available_from(_pool_ids("upgrade_ids"))
	var rare_available := _available_from(_pool_ids("rare_ids"))
	for rare_id in _pool_ids("rare_ids"):
		available.erase(rare_id)
	while result.size() < 3 and not available.is_empty():
		var pick_from_rare := not rare_available.is_empty() and rng.randf() < 0.18
		var pool := rare_available if pick_from_rare else available
		var index := rng.randi_range(0, pool.size() - 1)
		var upgrade_id: String = pool.pop_at(index)
		if not result.has(upgrade_id):
			result.append(upgrade_id)
		available.erase(upgrade_id)
		rare_available.erase(upgrade_id)
	if result.size() < 3 and not rare_available.is_empty():
		result.append(rare_available.pop_at(rng.randi_range(0, rare_available.size() - 1)))

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
		if int(owned_counts.get(upgrade_id, 0)) < int(definition.get("max_stacks", 1)):
			available.append(upgrade_id)
	return available

func _next_chained_upgrade() -> String:
	for chain_variant in _pool_arrays("progression_chains"):
		var chain: Array = chain_variant as Array
		for index in range(1, chain.size()):
			var previous_id := str(chain[index - 1])
			var next_id := str(chain[index])
			if is_talent_unlocked(next_id) and int(owned_counts.get(previous_id, 0)) > 0 and int(owned_counts.get(next_id, 0)) == 0:
				return next_id
	return ""

func _pool_ids(key: String) -> Array:
	return _pool_arrays(key)

func _pool_arrays(key: String) -> Array:
	return active_pool.get(key, []) as Array

func _definition(upgrade_id: String) -> Dictionary:
	return DEFINITIONS.get(upgrade_id, {}) as Dictionary
