class_name HomeScreen
extends Control

const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")
const MILITARY_STRATEGY = preload("res://scripts/domain/military_strategy.gd")
const TIANJI_CATALOG = preload("res://scripts/domain/tianji_catalog.gd")
const BATTLE_SOUL_ARMORY = preload("res://scripts/domain/battle_soul_armory.gd")
const SOUL_RESONANCE = preload("res://scripts/domain/soul_resonance.gd")
const BOWANGPO_GROUND_TEXTURE = preload("res://assets/art/environment/bowangpo1/1.png")
const XINYE_GROUND_CANVAS_TEXTURE = preload("res://assets/art/environment/xinye1/ground-canvas.png")
const BOWANGPO_GROUND_CANVAS_TEXTURE = preload("res://assets/art/environment/bowangpo1/ground-canvas.png")
const HUOSHAO_XINYE_GROUND_CANVAS_TEXTURE = preload("res://assets/art/environment/huoshaoxinye1/ground-canvas.png")
const XIANGYANG_CHETUI_GROUND_CANVAS_TEXTURE = preload("res://assets/art/environment/xiangyangchetui1/ground-canvas.png")
const JINGZHOU_SIEGE_GROUND_CANVAS_TEXTURE = preload("res://assets/art/environment/jingzhou_siege/ground-canvas.png")
const DANGYANG_DUANHOU_GROUND_CANVAS_TEXTURE = preload("res://assets/art/environment/dangyangduanhou/ground-canvas.png")
const CHANGBAN_GROUND_CANVAS_TEXTURE = preload("res://assets/art/environment/changbanpo/ground-canvas.png")
const BOSS_TRIAL_PREVIEW_TEXTURE = preload("res://assets/art/environment/shilian/trial-preview.png")
const NON_COMBAT_FRAME_TEXTURE = preload("res://assets/art/ui/backgrounds/main_menu/mainFrame_new.png")
const HERO_SELECT_BACKGROUND_TEXTURE: Texture2D = preload("res://assets/art/ui/backgrounds/select_hero.png")
const HERO_SELECT_LOGO_TEXTURE: Texture2D = preload("res://assets/art/ui/hero_select/PicHeroLogo.png")
const HERO_SELECT_START_TEXTURE: Texture2D = preload("res://assets/art/ui/hero_select/start.png")
const MAIN_MENU_BUTTON_TEXTURE = preload("res://assets/art/ui/main_menu/button_on.png")
const MAIN_MENU_BATTLE_ICON = preload("res://assets/art/ui/main_menu/battle.png")
const MAIN_MENU_BOOK_ICON = preload("res://assets/art/ui/main_menu/book.png")
const MAIN_MENU_SETTING_ICON = preload("res://assets/art/ui/main_menu/setting.png")
const MAIN_MENU_EXIT_ICON = preload("res://assets/art/ui/main_menu/exist.png")
const SHOP_SELECTED_BUTTON_TEXTURE = preload("res://assets/art/ui/shop/selectBtn.png")
const SHOP_UNSELECTED_BUTTON_TEXTURE = preload("res://assets/art/ui/shop/unselectBtn.png")
const SHOP_PANEL_TEXTURE = preload("res://assets/art/ui/shop/skillTab.png")
const SHOP_BACKGROUND_TEXTURE: Texture2D = preload("res://assets/art/ui/shop/shop_background.png")
const SHOP_MERIT_TEXTURE: Texture2D = preload("res://assets/art/ui/shop/jungong.png")
const KAITI_FONT: Font = preload("res://assets/fonts/kaiti.ttf")
const EXPEDITION_BACKGROUND_TEXTURE = preload("res://assets/art/ui/expedition/select_battle.png")
const EXPEDITION_STORY_TAB_TEXTURE = preload("res://assets/art/ui/expedition/zhuxian.png")
const EXPEDITION_ENDLESS_TAB_TEXTURE = preload("res://assets/art/ui/expedition/fuben.png")
const EXPEDITION_NAMEPLATE_TEXTURE = preload("res://assets/art/ui/expedition/battleName.png")
const EXPEDITION_BACK_TEXTURE = preload("res://assets/art/ui/expedition/back.png")
const SHARED_BACK_BUTTON_SIZE := Vector2(151.8, 66.0)
const EXPEDITION_PLATE_ENTER_DURATION := 0.34
const EXPEDITION_PLATE_EXIT_DURATION := 0.20
const EXPEDITION_PLATE_ENTER_STAGGER := 0.39
const EXPEDITION_MAP_SIZE := Vector2(1672.0, 941.0)
const EXPEDITION_UI_REFERENCE_SIZE := Vector2(1280.0, 720.0)
const EXPEDITION_MODE_TAB_SIZE := Vector2(180.0, 74.0)
const EXPEDITION_STORY_POINTS := {
	"story_01": Vector2(390.0, 340.0),
	"story_03": Vector2(675.0, 445.0),
	"story_05": Vector2(1490.0, 555.0),
}
const EXPEDITION_ENDLESS_POINT := Vector2(1192.0, 340.0)
const EXPEDITION_TRIAL_POINT := Vector2(955.0, 555.0)
const TITLE_LOGO_TEXTURE = preload("res://assets/art/ui/title/logo.png")
const TAPTAP_LOGIN_BUTTON_TEXTURE = preload("res://assets/art/ui/title/taptap_login_button.png")
const TAPTAP_LOGIN_BUTTON_SIZE := Vector2(292.0, 54.0)
const TITLE_VIDEO_STREAM: VideoStream = preload("res://assets/art/ui/title/title-animation.ogv")
const RELEASE_HERO_IDS: Array[String] = ["guan_yu", "zhang_fei", "zhao_yun", "ma_chao"]
const STRATEGY_DISPLAY_GROUPS := [
	{"title": "攻伐", "subtitle": "军械与练兵，强化输出与成长效率。", "branch_ids": ["arsenal", "training"]},
	{"title": "固守", "subtitle": "兵甲与奇门，提升容错并扩充阵位。", "branch_ids": ["armor", "tianji"]},
	{"title": "调度", "subtitle": "行军与中军，改善资源和战场节奏。", "branch_ids": ["march", "grand_command"]},
	{"title": "统御", "subtitle": "军令号召，强化主动与无双循环。", "branch_ids": ["command"]},
]
const TIANJI_ALTAR_ORDER: Array[String] = ["seven_star_lightning", "fire_rain_burning", "arrow_support_volley", "eight_trigram_tide", "xun_wind_break"]
const HERO_SELECT_SLOT_IDS: Array[String] = ["guan_yu", "zhang_fei", "zhao_yun", "ma_chao", "huang_zhong"]
const HERO_SELECT_PLAYABLE_IDS: Array[String] = ["guan_yu", "zhang_fei", "zhao_yun", "ma_chao"]
const HERO_SELECT_TRIAL_IDS: Array[String] = []
const HERO_SELECT_NEW_PORTRAITS := {
	"guan_yu": "res://assets/art/characters/hero_new/guanyu.png",
	"zhang_fei": "res://assets/art/characters/hero_new/zhangfei.png",
	"zhao_yun": "res://assets/art/characters/hero_new/zhaoyun.png",
	"ma_chao": "res://assets/art/characters/hero_new/maochao.png",
}
const HERO_SELECT_IDLE_SPRITE_SIZES := {
	"guan_yu": Vector2(92.0, 72.0),
	"zhao_yun": Vector2(92.0, 72.0),
	"zhang_fei": Vector2(132.0, 76.0),
}
const HERO_SELECT_IDLE_VISUAL_SCALE := 0.75
const HERO_SELECT_IDLE_VERTICAL_OFFSETS := {
	"guan_yu": 0.0,
	"zhao_yun": -16.0,
	"zhang_fei": 8.0,
}
const HERO_SELECT_IDLE_MODEL_TOP := 76.0
const HERO_SELECT_IDLE_MODEL_BOTTOM_GAP := 12.0
const HERO_SELECT_IDLE_BOTTOM_PADDING := {
	"guan_yu": 9.0,
	# Zhao Yun's idle frames include a larger transparent floor margin than
	# the other selectable heroes; this places the visible feet on the model
	# area's baseline without clipping the frame.
	"zhao_yun": 18.0,
	"zhang_fei": 5.0,
}
const ZHAO_YUN_SELECT_IDLE_TEXTURES := [
	preload("res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-01.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-02.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-03.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-04.png"),
]
const GUAN_YU_SELECT_IDLE_TEXTURES := [
	preload("res://assets/art/characters/guan_yu/sprites/idle_right/guan-yu-idle-01.png"),
	preload("res://assets/art/characters/guan_yu/sprites/idle_right/guan-yu-idle-02.png"),
	preload("res://assets/art/characters/guan_yu/sprites/idle_right/guan-yu-idle-03.png"),
	preload("res://assets/art/characters/guan_yu/sprites/idle_right/guan-yu-idle-04.png"),
	preload("res://assets/art/characters/guan_yu/sprites/idle_right/guan-yu-idle-05.png"),
]
const ZHANG_FEI_SELECT_IDLE_TEXTURES := [
	preload("res://assets/art/characters/zhang_fei/sprites/idle_right/zhang-fei-idle-01.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/idle_right/zhang-fei-idle-02.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/idle_right/zhang-fei-idle-03.png"),
]
const MA_CHAO_SELECT_IDLE_TEXTURES := [
	preload("res://assets/art/characters/ma_chao/sprites/stay1/1.png"),
	preload("res://assets/art/characters/ma_chao/sprites/stay1/2.png"),
	preload("res://assets/art/characters/ma_chao/sprites/stay1/3.png"),
	preload("res://assets/art/characters/ma_chao/sprites/stay1/4.png"),
	preload("res://assets/art/characters/ma_chao/sprites/stay1/5.png"),
]
const MA_CHAO_SELECT_WALK_TEXTURES := [
	preload("res://assets/art/characters/ma_chao/sprites/move1/1.png"),
	preload("res://assets/art/characters/ma_chao/sprites/move1/2.png"),
	preload("res://assets/art/characters/ma_chao/sprites/move1/3.png"),
	preload("res://assets/art/characters/ma_chao/sprites/move1/4.png"),
	preload("res://assets/art/characters/ma_chao/sprites/move1/5.png"),
]
const ZHAO_YUN_SELECT_WALK_TEXTURES := [
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-01.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-02.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-03.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-04.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-05.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-06.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-07.png"),
	preload("res://assets/art/characters/zhao_yun/sprites/walk_right/zhaoyun-walk-right-08.png"),
]
const GUAN_YU_SELECT_WALK_TEXTURES := [
	preload("res://assets/art/characters/guan_yu/sprites/walk_right/guan-yu-walk-01.png"),
	preload("res://assets/art/characters/guan_yu/sprites/walk_right/guan-yu-walk-02.png"),
	preload("res://assets/art/characters/guan_yu/sprites/walk_right/guan-yu-walk-03.png"),
	preload("res://assets/art/characters/guan_yu/sprites/walk_right/guan-yu-walk-04.png"),
	preload("res://assets/art/characters/guan_yu/sprites/walk_right/guan-yu-walk-05.png"),
]
const ZHANG_FEI_SELECT_WALK_TEXTURES := [
	preload("res://assets/art/characters/zhang_fei/sprites/walk_right/zhang-fei-walk-01.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/walk_right/zhang-fei-walk-02.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/walk_right/zhang-fei-walk-03.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/walk_right/zhang-fei-walk-04.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/walk_right/zhang-fei-walk-05.png"),
	preload("res://assets/art/characters/zhang_fei/sprites/walk_right/zhang-fei-walk-06.png"),
]
# The current presentation is reduced to 70% while retaining the same source artwork.
const HERO_SELECT_PORTRAIT_SCALE := 1.365
# Keep the outer golden frame visible above and below the character artwork.
const HERO_SELECT_PORTRAIT_CLIP_TOP := 20.0
const HERO_SELECT_PORTRAIT_CLIP_BOTTOM := 20.0
const HERO_SELECT_TRANSITION_DURATION := 0.62
const HERO_SELECT_PORTRAIT_FLASH_DURATION := 0.22
const HERO_SELECT_PORTRAIT_SHADER_CODE := """
shader_type canvas_item;

uniform float dim_amount : hint_range(0.0, 1.0) = 0.0;
uniform float brightness : hint_range(0.0, 1.0) = 1.0;
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	if (source.a < 0.02) {
		discard;
	}
	float luminance = dot(source.rgb, vec3(0.299, 0.587, 0.114));
	vec3 shaded_rgb = mix(source.rgb, vec3(luminance), dim_amount) * brightness;
	COLOR = vec4(mix(shaded_rgb, vec3(1.0), flash_amount), source.a);
}
"""
const PANEL_FILL := Color("10191f")
const PANEL_INNER := Color("18242b")
const GOLD := Color("d5af66")
const GOLD_BRIGHT := Color("f4d58d")
const DRAGON_BLUE := Color("63b9df")
const MUTED := Color("829099")
const HERO_SELECT_SKILL_TYPE_COLORS := {
	"普攻": Color("e2b85f"),
	"被动": Color("67c9b0"),
	"主动": Color("63b9df"),
	"无双": Color("d76b5e"),
}
const HERO_TREE_NODE_SIZE := Vector2(156.0, 64.0)
const HERO_TREE_NODE_GAP := 16.0
const HERO_TREE_BRANCH_START_X := 140.0
const HERO_TREE_BRANCH_TITLE_HEIGHT := 28.0
const HERO_TREE_BRANCH_BOTTOM_GAP := 38.0
const HERO_TREE_ROOT_RECT := Rect2(16.0, 16.0, 108.0, 56.0)
const HERO_TREE_SCROLL_DRAG_THRESHOLD := 10.0
const PAGE_SCROLL_DRAG_THRESHOLD := 10.0
const SHOP_SECTION_LABELS := {
	"heroes": "武将战法",
	"strategies": "军略",
	"tianji": "天机",
	"souls": "战魂阁",
}
# 坐标相对于商城背景源图（1671×941）；节点始终追随背景的居中裁切变换。
const SHOP_ALTAR_POINTS := [
	Vector2(0.452, 0.324), # 上
	Vector2(0.585, 0.438), # 右上
	Vector2(0.542, 0.643), # 右下
	Vector2(0.360, 0.643), # 左下
	Vector2(0.320, 0.439), # 左上
]
const SHOP_SOUL_POINT_SLOTS := [1, 2, 3, 4, 0]
const SHOP_SOUL_CENTER_POINT := Vector2(0.452, 0.500)

class SoulResonanceLines extends Control:
	var points: Array[Vector2] = []
	var center := Vector2.ZERO
	var illuminated := false

	func _draw() -> void:
		var color := Color("edc86a") if illuminated else Color("9b8152")
		for point in points:
			var direction := (center - point).normalized()
			var start := point + direction * 42.0
			var finish := center - direction * 44.0
			draw_line(start, finish, Color(color, 0.10), 9.0, true)
			draw_line(start, finish, Color(color, 0.28), 4.0, true)
			draw_line(start, finish, Color(color, 0.80), 1.5, true)
		draw_arc(center, 25.0, 0.0, TAU, 64, Color(color, 0.20), 8.0, true)
		draw_arc(center, 25.0, 0.0, TAU, 64, color, 2.0, true)
const SHOP_HERO_IDS: Array[String] = ["guan_yu", "zhang_fei", "zhao_yun", "ma_chao", "huang_zhong"]
const SHOP_HERO_SKILL_ICONS := {
	"guan_broad_edge": "sword_slash", "guan_heavy_blade": "blade_arc", "guan_drag_blade": "wind_sweep", "guan_drag_steadiness": "shield", "guan_drag_charge": "focus", "guan_drag_waves": "whirlwind", "guan_drag_reach": "wind_sweep", "guan_fourth_strike": "crossed_swords", "guan_fourth_dash": "dash", "guan_fourth_collision": "shield", "guan_fourth_wave": "blade_arc", "guan_fourth_execution": "skull_mist", "guan_sweeping_guard": "ward_shield", "guan_sweeping_guard_large": "wing_guard", "guan_martial_pressure": "berserk", "guan_battlefield_radius": "group_blessing", "guan_pressure_recovery": "healing_wave", "guan_iron_guard": "iron_helm", "guan_mark_hunt": "true_sight", "guan_breaking_wave": "wind_sweep", "guan_rending_tide": "water_drop", "guan_wave_count": "whirlwind", "guan_breaking_step": "dash", "guan_river_cleaver": "water_drop", "guan_saintly_wrath": "fire_burst", "guan_war_banner": "war_banner", "guan_saintly_duration": "time_sand", "guan_saintly_armor_pierce": "crossed_swords", "guan_saintly_warfront": "fortress",
	"zhang_heavy_roar": "berserk", "zhang_fourth_strike": "fortress", "zhang_fourth_wave_expand": "wind_sweep", "zhang_slam_leap": "dash", "zhang_slam_mastery": "whirlwind", "zhang_rage": "berserk", "zhang_rage_hunt": "skull_mist", "zhang_rage_fervor": "swift_boots", "zhang_rage_overwhelm": "crossed_swords", "zhang_iron_hide": "iron_helm", "zhang_active_charge": "focus", "zhang_bridge_breaker": "fortress", "zhang_bridge_repel": "shield", "zhang_bridge_shockwave": "wind_sweep", "zhang_earthshaker": "fortress", "zhang_immovable": "ward_shield", "zhang_battle_cry": "war_banner", "zhang_ultimate_armor_pierce": "crossed_swords", "zhang_ultimate_bloodlust": "healing_cross", "zhang_war_stomp": "fortress",
	"spear_reach": "sword_slash", "sweeping_wind": "wind_sweep", "sweeping_guard": "ward_shield", "sweeping_guard_large": "wing_guard", "dash_echo": "dash", "firewheel": "fire_burst", "firewheel_duration": "time_sand", "firewheel_capstone": "dragon_fire", "dragon_armor": "iron_helm", "dragon_stride": "swift_boots", "dragon_stride_double": "dash", "dragon_stride_threefold": "dragon_crest", "dragon_scale": "shield", "dragon_scale_regen": "healing_wave", "dragon_focus": "focus", "dragon_focus_guard": "ward_shield", "dragon_focus_invulnerable": "holy_bloom", "seven_edge": "crossed_swords", "snake_spin": "whirlwind", "spear_shadow": "shadow_strike", "white_dragon": "dragon_fire", "returning_spear": "sword_slash", "zhao_ultimate_armor_pierce": "crossed_swords", "triumph": "war_banner",
	"ma_spear_pierce": "crossed_swords", "ma_skybreaker": "wind_sweep", "ma_fourth_strike": "crossed_swords", "ma_iron_cavalry": "dragon_crest", "ma_long_charge": "dash", "ma_cavalry_retinue": "group_blessing", "ma_cavalry_duration": "time_sand",
	"huang_draw_strength": "arrow_shot", "huang_hawk_eye": "true_sight", "huang_blade_return": "blade_arc", "huang_dingjun_volley": "arrow_rain",
}
const STRATEGY_CARD_WIDTH := 286.0
const STRATEGY_CARD_MIN_HEIGHT := 80.0
const STRATEGY_CARD_DESCRIPTION_LINE_HEIGHT := 18.0
const STRATEGY_CARD_DESCRIPTION_CHARS_PER_LINE := 20
const STRATEGY_CARD_GAP := Vector2(12.0, 12.0)
const TITLE_MENU_FADE_DURATION := 0.36
const TITLE_INTRO_DURATION := 1.05
const TITLE_REVEAL_DURATION := 0.72
const TITLE_ENTER_SEAL_DURATION := 0.18
const TITLE_PROMPT_TEXT := "触碰屏幕开始游戏"
const SETTINGS_VERSION_TEXT := "版本号：v2.0.2"
const HEALTH_GAME_NOTICE_TITLE := "健康游戏公告"
const HEALTH_GAME_NOTICE_LINES: Array[String] = [
	"抵制不良游戏，拒绝盗版游戏。",
	"适度游戏益脑，沉迷游戏伤身。",
	"合理安排时间，享受健康生活。",
]
const HEALTH_GAME_NOTICE_FONT_SIZE := 14
const HEALTH_GAME_NOTICE_LINE_HEIGHT := 19.0
const HOME_ACTION_BUTTON_SIZE := Vector2(376.0, 80.0)
const HOME_ACTION_BUTTON_GAP := 16.0
const EXPEDITION_TAB_SIZE := Vector2(176.0, 48.0)
const EXPEDITION_ROUTE_BUTTON_POSITION := Vector2(70.0, 242.0)
const EXPEDITION_ROUTE_BUTTON_SIZE := Vector2(246.0, 92.0)
const EXPEDITION_ROUTE_BUTTON_STEP := 124.0
const EXPEDITION_ROUTE_RAIL_X := 48.0
const STORY_ROUTE_RAIL_X := 94.0
const STORY_ROUTE_BUTTON_START := Vector2(120.0, 242.0)
const STORY_ROUTE_BUTTON_SIZE := Vector2(290.0, 54.0)
const STORY_ROUTE_BUTTON_STEP := 62.0
const STORY_PREVIEW_TOP := 194.0
const STORY_PREVIEW_HEIGHT := 260.0
const STORY_DETAILS_GAP := 20.0
const STORY_DETAILS_HEIGHT := 126.0
const STORY_ACTION_SIZE := Vector2(216.0, 52.0)
const BATTLEFIELD_DEFINITIONS := {
	"changban": {
		"id": "changban",
		"title": "长坂坡",
		"chapter": "主线 第一章",
		"description": "雪夜兵海，持续迎击敌军。",
		"tags": ["雪夜"],
		"implemented": true,
	},
	"jingzhou_siege": {
		"id": "jingzhou_siege",
		"title": "攻取荆州",
		"chapter": "无尽变体",
		"description": "护送攻城锤向右推进，击破敌方城门。",
		"tags": ["攻城略地", "攻城锤", "破门"],
		"implemented": true,
	},
	"bowangpo": {
		"id": "bowangpo",
		"title": "博望坡·火谷",
		"chapter": "战役外传",
		"description": "穿过曹军枪弩阵与火谷封锁，击退夏侯惇。",
		"tags": ["火谷", "枪弩阵", "夏侯惇"],
		"implemented": true,
	},
	"hulao": {
		"id": "hulao",
		"title": "虎牢关外·斗将台",
		"chapter": "名将斗阵",
		"description": "五将连战，击败吕布。",
		"tags": ["精英", "首领"],
		"implemented": true,
	},
}
const STORY_CHAPTER_DEFINITIONS := {
	"story_01": {"id": "story_01", "chapter": "第一章", "title": "新野练兵", "description": "熟悉近战推进与破阵。", "tags": ["约5分钟"], "duration": "约5分钟", "battlefield_id": "xinye"},
	"story_03": {"id": "story_03", "chapter": "第二章", "title": "火烧新野", "description": "掩护撤离，突破追兵。", "tags": ["约6.5分钟"], "duration": "约6.5分钟", "battlefield_id": "huoshaoxinye"},
	"story_04": {"id": "story_04", "chapter": "第三章", "title": "襄阳撤退", "description": "护送南撤，阻截合围。", "tags": ["约8分钟"], "duration": "约8分钟", "battlefield_id": "xiangyangchetui"},
	"story_05": {"id": "story_05", "chapter": "第三章", "title": "当阳断后", "description": "断后掩护，穿越当阳。", "tags": ["约9分钟"], "duration": "约9分钟", "battlefield_id": "dangyangduanhou"},
}
const STORY_CHAPTER_IDS: Array[String] = ["story_01", "story_03", "story_05"]
const STORY_CHAPTER_DIFFICULTIES := {
	"story_01": "简易",
	"story_03": "困难",
	"story_05": "极难",
}
const TUTORIAL_FINAL_STAGE := 20
const TUTORIAL_HINTS := {
	0: "欢迎来到《三国·破阵无双》！本教程将带你熟悉军需、战法与出征流程。",
	1: "请点击“军需”按钮，进入军需商城。",
	2: "这里是军需商城，可以招募武将、解锁专属战法，并用军功逐步提升战法阶数。点击左侧“下一步>”继续。",
	3: "军需商城可解锁武将专属战法。请先查看关羽的“拖刀计”。",
	4: "这是关羽的“拖刀计”详情页：它会强化关羽的主动突进与持续作战能力，购买后可在战斗的升级选择技能中获得。点击左侧“下一步>”继续。",
	5: "请点击购买按钮，解锁关羽的“拖刀计”。",
	6: "接下来查看张飞的专属战法。",
	7: "请查看张飞的“丈八跃砸·跃步”。",
	8: "这是张飞的“丈八跃砸·跃步”详情页：它会强化张飞的跃砸招式，购买后可在战斗中进一步提升爆发。点击左侧“下一步>”继续。",
	9: "请点击购买按钮，解锁张飞的“丈八跃砸·跃步”。",
	10: "军需中的“军略”是全武将永久生效的成长模块，可以强化资源获取、战斗能力和阵容运转。请点击“军略”进入页面。",
	11: "这里是军略页面：不同分支分别强化攻伐、固守、调度与统御，研习后会永久作用于所有武将。点击左侧“下一步>”继续。",
	12: "请点击“天机”进入天机阵法页面。",
	13: "这里是天机阵法页面：可以永久解锁并升阶阵法，战斗中通过升级选择技能启用阵法效果，形成适合本局的战术组合。点击左侧“下一步>”继续。",
	14: "天机阵法介绍完毕，请点击“返回”回到主菜单。",
	15: "准备出征！请点击“出征”进入剧情战役。",
	16: "请选择第一章“新野练兵”。",
	17: "已选好关卡，请点击右下角“出征”进入五虎点将页面。",
	18: "这里是“五虎点将”页面：可以查看武将信息、切换出战武将，并确认本局的出战阵容。点击左侧“下一步>”继续。",
	19: "阵容确认后，请点击右上角“出征”开始战斗。",
}

var page := "main"
var expedition_tab := "story"
var selected_story_chapter_id := "story_01"
var selected_endless_battlefield_id := "changban"
var selected_run_mode := "story"
var selected_run_battlefield_id := "changban"
var selected_run_story_chapter := 1
var departure_loading := false
var hero_select_return_tab := "story"
var hero_details_return_page := "main"
var shop_section := "heroes"
var selected_shop_hero_id := "guan_yu"
var selected_shop_talent_id := ""
var selected_shop_strategy_id := ""
var selected_shop_tianji_id := ""
var selected_shop_soul_id := ""
var selected_shop_item_id := ""
var shop_scroll_positions := {"heroes": 0, "strategies": 0, "tianji": 0, "souls": 0}
var shop_icon_cache: Dictionary = {}
var shop_build_id := 0
var shop_center_panel: Control
var shop_detail_panel: Control
var shop_detail_body: Control
var shop_list_scroll: ScrollContainer
var shop_grid_buttons: Dictionary = {}
var profile: Dictionary = {}
var notice := ""
var buttons: Array[Button] = []
var setting_controls: Array[Control] = []
var music_value_label: Label
var sfx_value_label: Label
var page_controls: Array[Control] = []
var expedition_nameplates: Array[TextureButton] = []
var expedition_exiting_plates: Array[TextureButton] = []
var talent_detail_dialog: Control
var strategy_detail_dialog: Control
var tianji_detail_dialog: Control
var battle_soul_detail_dialog: Control
var strategy_detail_notice := ""
var tianji_detail_notice := ""
var hero_ids: Array[String] = []
var selected_hero_index := 0
var hero_tree_touch_index := -1
var hero_tree_drag_start := Vector2.ZERO
var hero_tree_drag_scroll_start := 0
var hero_tree_dragging := false
var hero_tree_mouse_dragging := false
var page_scroll_touch_index := -1
var page_scroll_drag_start := Vector2.ZERO
var page_scroll_drag_start_offset := Vector2.ZERO
var page_scroll_dragging := false
var page_scroll_mouse_dragging := false
var title_elapsed := 0.0
var title_start_input_held := false
var title_enter_seal_remaining := 0.0
var title_menu_fade_remaining := 0.0
var title_login_button: Button
var title_status := ""
var title_video_player: VideoStreamPlayer
var hero_select_idle_elapsed := 0.0
var hero_select_idle_sprite: TextureRect
var hero_select_portrait_layer: Control
var hero_select_info_overlay: Control
var hero_select_display_portrait: TextureRect
var hero_select_skill_popup: Control
var hero_select_idle_bounds_cache: Dictionary = {}
var portrait_cache: Dictionary = {}
var hero_select_portrait_shader: Shader
var hero_select_transition_pending := false
var hero_select_transition_active := false
var hero_select_transition_elapsed := 0.0
var hero_select_transition_hero_id := ""
var hero_select_transition_from_position := Vector2.ZERO
var hero_select_transition_target_position := Vector2.ZERO
var hero_select_portrait_flash_remaining := 0.0
var hero_select_stat_fill_elapsed := 0.0
var hero_select_stat_fill_progress := 0.0
var hero_select_touch_index := -1
var hero_select_drag_start := Vector2.ZERO
var hero_select_mouse_dragging := false
var tutorial_overlay: ColorRect
var tutorial_panel: Panel
var tutorial_target: Control
var tutorial_skip_button: Button
var tutorial_target_highlight: Panel
var tutorial_target_original_z_index := 0
var tutorial_target_original_mouse_filter := Control.MOUSE_FILTER_PASS
var tutorial_highlight_elapsed := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	UITheme.install(self)
	resized.connect(_rebuild_current_page)
	_setup_title_video_player()
	profile = SaveService.load_profile()
	AdService.rewarded_video_completed.connect(_on_rewarded_video_completed)
	TapAuthService.gate_ready.connect(_on_tap_gate_ready)
	TapAuthService.auth_state_changed.connect(_on_tap_auth_state_changed)
	AudioService.apply_settings(profile.get("settings", {}) as Dictionary)
	AudioService.play_title_bgm()
	LoadingOverlay.finish_transition()
	if SceneRouter.title_seen:
		_show_main()
	else:
		_show_title()
	if DisplayServer.get_name() == "headless" and OS.has_environment("THREE_KINGDOM_LAYOUT_DIAGNOSTIC"):
		call_deferred("_run_hero_select_layout_diagnostic")

func _run_hero_select_layout_diagnostic() -> void:
	_show_hero_select("story", "changban", "story")
	await get_tree().process_frame
	print("HOME size=%s scale=%s rect=%s" % [size, scale, get_global_rect()])
	for child in get_children():
		if child is TextureRect:
			var portrait := child as TextureRect
			var path := portrait.texture.resource_path if portrait.texture != null else ""
			if path.contains("portraits/"):
				print("PORTRAIT path=%s position=%s size=%s scale=%s rect=%s stretch=%s expand=%s" % [path, portrait.position, portrait.size, portrait.scale, portrait.get_global_rect(), portrait.stretch_mode, portrait.expand_mode])
	get_tree().quit()

func _process(delta: float) -> void:
	var needs_redraw := false
	if page == "title":
		var was_revealed := title_elapsed >= TITLE_REVEAL_DURATION
		title_elapsed += delta
		needs_redraw = true
		if not was_revealed and title_elapsed >= TITLE_REVEAL_DURATION:
			_refresh_title_auth_ui()
	if title_enter_seal_remaining > 0.0:
		title_enter_seal_remaining = maxf(0.0, title_enter_seal_remaining - delta)
		needs_redraw = true
		if title_enter_seal_remaining <= 0.0:
			SceneRouter.title_seen = true
			title_menu_fade_remaining = TITLE_MENU_FADE_DURATION
			_show_main()
	if page == "hero_select":
		hero_select_idle_elapsed += delta
		hero_select_stat_fill_elapsed = minf(hero_select_stat_fill_elapsed + delta, 0.62)
		hero_select_stat_fill_progress = clampf(hero_select_stat_fill_elapsed / 0.62, 0.0, 1.0)
		if is_instance_valid(hero_select_info_overlay):
			(hero_select_info_overlay as HeroSelectInfoOverlay).set_stat_fill_progress(hero_select_stat_fill_progress)
		_update_hero_select_idle_sprite()
		_update_hero_select_portrait_flash(delta)
		needs_redraw = true
	if is_instance_valid(tutorial_target_highlight):
		tutorial_highlight_elapsed += delta
		var pulse := 0.5 + 0.5 * sin(tutorial_highlight_elapsed * TAU / 0.9)
		tutorial_target_highlight.modulate.a = 0.55 + pulse * 0.45
		needs_redraw = true
	if title_menu_fade_remaining > 0.0:
		title_menu_fade_remaining = maxf(0.0, title_menu_fade_remaining - delta)
		needs_redraw = true
	if needs_redraw:
		queue_redraw()

func _show_title() -> void:
	page = "title"
	profile = SaveService.load_profile()
	notice = ""
	title_elapsed = 0.0
	title_start_input_held = false
	title_enter_seal_remaining = 0.0
	title_menu_fade_remaining = 0.0
	_play_title_video()
	_clear_buttons()
	_refresh_title_auth_ui()
	grab_focus()
	queue_redraw()

func _enter_from_title() -> void:
	if page != "title" or title_elapsed < TITLE_REVEAL_DURATION or title_start_input_held or title_enter_seal_remaining > 0.0:
		return
	if TapAuthService.requires_taptap_login():
		return
	title_enter_seal_remaining = TITLE_ENTER_SEAL_DURATION
	queue_redraw()

func _on_tap_gate_ready() -> void:
	if page != "title":
		return
	_refresh_title_auth_ui()
	TapAuthService.start_title_flow()

func _on_tap_auth_state_changed() -> void:
	if page != "title":
		return
	if TapAuthService.last_compliance_code == TapAuthService.COMPLIANCE_OK:
		_enter_from_title_after_auth()
		return
	_refresh_title_auth_ui()

func _create_taptap_login_button(at: Vector2, button_size: Vector2) -> Button:
	var button := Button.new()
	button.position = at
	button.size = button_size
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty)
	button.add_theme_stylebox_override("hover", empty)
	button.add_theme_stylebox_override("pressed", empty)
	button.add_theme_stylebox_override("disabled", empty)
	button.add_theme_stylebox_override("focus", empty)
	button.pressed.connect(TapAuthService.start_login)
	var art := TextureRect.new()
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.texture = TAPTAP_LOGIN_BUTTON_TEXTURE
	button.add_child(art)
	add_child(button)
	buttons.append(button)
	return button

func _enter_from_title_after_auth() -> void:
	if page != "title" or title_enter_seal_remaining > 0.0:
		return
	title_enter_seal_remaining = TITLE_ENTER_SEAL_DURATION
	queue_redraw()

func _refresh_title_auth_ui() -> void:
	if page != "title":
		return
	title_status = TapAuthService.title_prompt_text()
	if title_status.is_empty():
		title_status = TapAuthService.status_message
	if title_login_button != null and is_instance_valid(title_login_button):
		buttons.erase(title_login_button)
		title_login_button.queue_free()
	title_login_button = null
	if TapAuthService.should_show_login_button() and title_elapsed >= TITLE_REVEAL_DURATION:
		var button_size := TAPTAP_LOGIN_BUTTON_SIZE
		var at := Vector2(size.x * 0.76 - button_size.x * 0.5, size.y * 0.72)
		title_login_button = _create_taptap_login_button(at, button_size)
	queue_redraw()

func _show_main() -> void:
	page = "main"
	profile = SaveService.load_profile()
	var resume_stage := SaveService.tutorial_stage()
	if resume_stage == 14:
		SaveService.set_tutorial_stage(15)
		profile = SaveService.load_profile()
		resume_stage = 15
	if resume_stage in [2, 3, 6, 7, 10]:
		if resume_stage in [6, 7]:
			selected_shop_hero_id = "zhang_fei"
		_show_shop("heroes")
		return
	elif resume_stage in [4, 5]:
		_show_shop("heroes")
		call_deferred("_resume_tutorial_talent", "guan_yu", "guan_drag_blade")
		return
	elif resume_stage in [8, 9]:
		_show_shop("heroes")
		call_deferred("_resume_tutorial_talent", "zhang_fei", "zhang_slam_leap")
		return
	elif resume_stage in [11, 12]:
		_show_shop("strategies")
		return
	elif resume_stage in [13, 14]:
		_show_shop("tianji")
		return
	elif resume_stage in [16, 17]:
		_show_expedition("story")
		return
	elif resume_stage in [18, 19]:
		_show_hero_select("story", "xinye", "story")
		return
	notice = ""
	_stop_title_video()
	_clear_buttons()
	var margin := _safe_margin()
	var menu_width := clampf(size.x * 0.31, 288.0, 450.0)
	var menu_height := menu_width / 4.5
	var menu_gap := clampf(size.y * 0.024, 16.0, 24.0)
	var menu_total_height := menu_height * 3.0 + menu_gap * 2.0
	var menu_x := clampf(size.x * 0.16, margin + 18.0, size.x * 0.29)
	var menu_y := maxf(margin + 36.0, minf(size.y * 0.28, size.y - margin - menu_total_height - 22.0))
	var menu_size := Vector2(menu_width, menu_height)
	_create_main_menu_button("出征", MAIN_MENU_BATTLE_ICON, Vector2(menu_x, menu_y), _show_modes, menu_size)
	_create_main_menu_button("军需", MAIN_MENU_BOOK_ICON, Vector2(menu_x, menu_y + (menu_height + menu_gap) * 1.0), _show_shop, menu_size)
	_create_main_menu_button("设置", MAIN_MENU_SETTING_ICON, Vector2(menu_x, menu_y + (menu_height + menu_gap) * 2.0), _show_settings, menu_size)
	_tutorial_refresh()
	queue_redraw()

func _open_map_editor() -> void:
	SceneRouter.open_map_editor()

func _show_modes() -> void:
	if SaveService.tutorial_stage() == 15:
		SaveService.set_tutorial_stage(16)
	_show_expedition()

func _show_expedition(tab: String = "story") -> void:
	var switching_tab := page == "expedition" and expedition_tab != tab and tab in ["story", "endless"]
	var departing_plates: Array[TextureButton] = []
	if switching_tab:
		departing_plates.append_array(expedition_nameplates)
	page = "expedition"
	expedition_tab = tab if tab in ["story", "endless"] else "story"
	profile = SaveService.load_profile()
	notice = ""
	_clear_buttons(switching_tab)
	if switching_tab:
		for plate in departing_plates:
			_animate_expedition_plate_exit(plate)
	# Both mode entries use the same pair of state textures.  This keeps the
	# selected entry gold and the unselected entry jade, just like the reference.
	_create_expedition_tab("主线剧情", EXPEDITION_STORY_TAB_TEXTURE if expedition_tab == "story" else EXPEDITION_ENDLESS_TAB_TEXTURE, Vector2(20.0, 154.0), expedition_tab == "story", Callable(self, "_show_expedition").bind("story"))
	_create_expedition_tab("无尽试炼", EXPEDITION_STORY_TAB_TEXTURE if expedition_tab == "endless" else EXPEDITION_ENDLESS_TAB_TEXTURE, Vector2(20.0, 244.0), expedition_tab == "endless", Callable(self, "_show_expedition").bind("endless"))
	_create_expedition_back_button()
	if expedition_tab == "story":
		_create_expedition_level("story_01", "新野练兵", EXPEDITION_STORY_POINTS["story_01"])
		_create_expedition_level("story_03", "火烧新野", EXPEDITION_STORY_POINTS["story_03"])
		_create_expedition_level("story_05", "当阳断后", EXPEDITION_STORY_POINTS["story_05"])
	else:
		_create_expedition_level("changban", "血战长坂坡", EXPEDITION_ENDLESS_POINT)
		_create_expedition_level("hulao", "名将斗阵", EXPEDITION_TRIAL_POINT)
	# Animate first entry as well; creation order is reversed in endless mode.
	var ordered_plates := expedition_nameplates.duplicate()
	ordered_plates.sort_custom(func(a: TextureButton, b: TextureButton) -> bool: return a.position.x < b.position.x)
	for index in ordered_plates.size():
		_animate_expedition_plate_enter(ordered_plates[index], index, EXPEDITION_PLATE_EXIT_DURATION if switching_tab else 0.0)
	_tutorial_refresh()
	queue_redraw()

func _create_expedition_tab(title: String, texture: Texture2D, at: Vector2, selected: bool, callback: Callable) -> void:
	var layout_scale := _expedition_ui_scale()
	var tab := TextureButton.new()
	tab.texture_normal = texture
	tab.ignore_texture_size = true
	tab.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	tab.position = _expedition_ui_position(at)
	tab.size = EXPEDITION_MODE_TAB_SIZE * layout_scale
	tab.tooltip_text = title
	tab.pressed.connect(callback)
	page_controls.append(tab)
	add_child(tab)
	var label := Label.new()
	label.text = title
	label.position = Vector2(12.0, 9.0) * layout_scale
	label.size = Vector2(144.0, 56.0) * layout_scale
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var font_variation := FontVariation.new()
	font_variation.base_font = KAITI_FONT
	font_variation.variation_embolden = 0.68
	label.add_theme_font_override("font", font_variation)
	label.add_theme_font_size_override("font_size", roundi(25.0 * layout_scale))
	label.add_theme_color_override("font_color", Color.WHITE if selected else Color("93a084"))
	label.add_theme_color_override("font_outline_color", Color("17140d", 0.86))
	label.add_theme_constant_override("outline_size", 2)
	tab.add_child(label)
	if selected:
		tab.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _create_shared_back_button(callback: Callable, tooltip: String = "返回") -> TextureButton:
	var back := TextureButton.new()
	back.texture_normal = EXPEDITION_BACK_TEXTURE
	back.ignore_texture_size = true
	back.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	back.position = _expedition_ui_position(Vector2(26.0, 24.0))
	back.size = SHARED_BACK_BUTTON_SIZE * _expedition_ui_scale()
	back.tooltip_text = tooltip
	back.pressed.connect(callback)
	page_controls.append(back)
	add_child(back)
	return back

func _create_expedition_back_button() -> void:
	_create_shared_back_button(_leave_expedition_to_main, "返回首页")

func _leave_expedition_to_main() -> void:
	# Leaving the tutorial's expedition page cancels its resumable checkpoint;
	# otherwise startup would force the player back into the same page forever.
	var stage := SaveService.tutorial_stage()
	if stage in [16, 17]:
		SaveService.complete_tutorial()
	_show_main()

func _animate_expedition_plate_exit(plate: TextureButton) -> void:
	if not is_instance_valid(plate):
		return
	if plate.has_meta("expedition_tween"):
		var previous_tween := plate.get_meta("expedition_tween") as Tween
		if previous_tween != null and previous_tween.is_running():
			previous_tween.kill()
	plate.disabled = true
	expedition_exiting_plates.append(plate)
	plate.pivot_offset = plate.size * 0.5
	var tween := create_tween().bind_node(plate).set_parallel(true)
	plate.set_meta("expedition_tween", tween)
	tween.tween_property(plate, "position:y", -plate.size.y - 24.0, EXPEDITION_PLATE_EXIT_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(plate, "scale", Vector2(0.48, 1.58), EXPEDITION_PLATE_EXIT_DURATION)
	tween.tween_property(plate, "modulate:a", 0.0, EXPEDITION_PLATE_EXIT_DURATION)
	tween.finished.connect(func() -> void:
		expedition_exiting_plates.erase(plate)
		plate.queue_free()
	)

func _animate_expedition_plate_enter(plate: TextureButton, index: int, exit_delay: float = 0.0) -> void:
	var destination := plate.position
	var final_color := plate.modulate
	plate.disabled = true
	plate.pivot_offset = plate.size * 0.5
	plate.position.y = -plate.size.y - 24.0
	plate.scale = Vector2(0.48, 1.58)
	plate.modulate.a = 0.0
	var tween := create_tween().bind_node(plate)
	plate.set_meta("expedition_tween", tween)
	tween.tween_interval(exit_delay + 0.08 + index * EXPEDITION_PLATE_ENTER_STAGGER)
	tween.set_parallel(true)
	tween.tween_property(plate, "position", destination, EXPEDITION_PLATE_ENTER_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(plate, "scale", Vector2.ONE, EXPEDITION_PLATE_ENTER_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(plate, "modulate", final_color, EXPEDITION_PLATE_ENTER_DURATION * 0.74)
	tween.finished.connect(func() -> void:
		if is_instance_valid(plate):
			plate.disabled = not _expedition_level_unlocked(str(plate.get_meta("level_id")))
	)

func _create_expedition_level(level_id: String, title: String, map_point: Vector2) -> void:
	var map_rect := _expedition_map_rect()
	var layout_scale := _expedition_ui_scale()
	var point := map_rect.position + map_point * (map_rect.size / EXPEDITION_MAP_SIZE)
	var plate := TextureButton.new()
	plate.texture_normal = EXPEDITION_NAMEPLATE_TEXTURE
	plate.ignore_texture_size = true
	plate.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	plate.position = point - Vector2(25.0, 90.0) * layout_scale
	plate.size = Vector2(50.0, 180.0) * layout_scale
	plate.tooltip_text = title
	plate.set_meta("level_id", level_id)
	plate.pressed.connect(_on_expedition_level_pressed.bind(level_id))
	expedition_nameplates.append(plate)
	page_controls.append(plate)
	add_child(plate)
	var label := Label.new()
	label.text = "\n".join(title.split(""))
	label.position = Vector2(5.0, 11.0) * layout_scale
	label.size = Vector2(40.0, 148.0) * layout_scale
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var font_variation := FontVariation.new()
	font_variation.base_font = KAITI_FONT
	font_variation.variation_embolden = 0.62
	label.add_theme_font_override("font", font_variation)
	label.add_theme_font_size_override("font_size", roundi(22.0 * layout_scale))
	label.add_theme_color_override("font_color", Color("ebc587") if _expedition_level_unlocked(level_id) else Color("667064"))
	label.add_theme_color_override("font_outline_color", Color("15130f", 0.94))
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_constant_override("line_spacing", roundi(3.0 * layout_scale))
	plate.add_child(label)
	if not _expedition_level_unlocked(level_id):
		plate.disabled = true
		plate.modulate = Color(0.58, 0.62, 0.58, 0.84)

func _expedition_level_unlocked(level_id: String) -> bool:
	if level_id.begins_with("story_"):
		return SaveService.is_story_chapter_unlocked(STORY_CHAPTER_IDS.find(level_id) + 1)
	return SaveService.is_battlefield_unlocked(level_id)

func _on_expedition_level_pressed(level_id: String) -> void:
	if not _expedition_level_unlocked(level_id):
		return
	match level_id:
		"story_01", "story_03", "story_05":
			selected_story_chapter_id = level_id
			selected_run_story_chapter = STORY_CHAPTER_IDS.find(level_id) + 1
			_show_hero_select("story", _story_battlefield_id(selected_run_story_chapter), "story")
		"changban":
			selected_endless_battlefield_id = level_id
			_show_hero_select("endless", level_id, "endless")
		"hulao":
			_show_hero_select("boss_trial", level_id, "boss_trial")

func _populate_story_expedition() -> void:
	for index in range(STORY_CHAPTER_IDS.size()):
		var chapter_id := STORY_CHAPTER_IDS[index]
		var definition := _story_chapter_definition(chapter_id)
		var unlocked := SaveService.is_story_chapter_unlocked(index + 1)
		var selected := selected_story_chapter_id == chapter_id
		var status := "当前选中" if selected else ("可出征" if unlocked else "通关前章解锁")
		var chapter_title := str(definition.get("title", "第%d章" % (index + 1)))
		var chapter_button := _create_button(chapter_title, status, _story_route_button_position(index), Callable(self, "_select_story_chapter").bind(chapter_id), STORY_ROUTE_BUTTON_SIZE, not unlocked, 14)
		if not unlocked:
			_set_button_locked_visual(chapter_button)
		elif selected:
			if not (SaveService.tutorial_stage() == 16 and chapter_id == "story_01"):
				chapter_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			chapter_button.pivot_offset = STORY_ROUTE_BUTTON_SIZE * 0.5
			chapter_button.scale = Vector2.ONE * 1.05
			_set_button_selected_visual(chapter_button)
	var selected_definition := _story_chapter_definition(selected_story_chapter_id)
	var selected_index := STORY_CHAPTER_IDS.find(selected_story_chapter_id)
	var can_start := selected_index >= 0 and SaveService.is_story_chapter_unlocked(selected_index + 1)
	var action_title := "出征" if can_start else "未解锁"
	var action_subtitle := str(selected_definition.get("duration", "")) if can_start else "通关前章解锁"
	var preview := _story_preview_rect()
	var details := _story_details_rect()
	_create_button(action_title, action_subtitle, Vector2(preview.end.x - STORY_ACTION_SIZE.x, details.end.y + 18.0), _start_selected_story, STORY_ACTION_SIZE, not can_start, 16)

func _populate_endless_expedition() -> void:
	if selected_endless_battlefield_id not in ["changban", "jingzhou_siege"]:
		selected_endless_battlefield_id = "changban"
	var definition := _battlefield_definition(selected_endless_battlefield_id)
	var usable := bool(definition.get("implemented", false)) and SaveService.is_battlefield_unlocked(selected_endless_battlefield_id)
	var status := "可用" if usable else ("筹备中" if SaveService.is_battlefield_unlocked(selected_endless_battlefield_id) else "通关剧情第三关后解锁")
	if not SaveService.is_battlefield_unlocked(selected_endless_battlefield_id):
		status = "通关剧情第三关后解锁"
	for index in range(2):
		var battlefield_id := "changban" if index == 0 else "jingzhou_siege"
		var candidate := _battlefield_definition(battlefield_id)
		var candidate_unlocked := SaveService.is_battlefield_unlocked(battlefield_id)
		var candidate_usable := bool(candidate.get("implemented", false)) and candidate_unlocked
		var candidate_status := "当前选中" if battlefield_id == selected_endless_battlefield_id else ("可用" if candidate_usable else "通关剧情第三关后解锁")
		var battlefield_button := _create_button(str(candidate.get("title", battlefield_id)), candidate_status, _expedition_route_button_position(index), Callable(self, "_select_endless_battlefield").bind(battlefield_id), EXPEDITION_ROUTE_BUTTON_SIZE, not candidate_usable, 15)
		if not candidate_usable:
			_set_button_locked_visual(battlefield_button)
		elif battlefield_id == selected_endless_battlefield_id:
			battlefield_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_set_button_owned_visual(battlefield_button)
	var departure_text := "攻城略地 · 破门入城" if selected_endless_battlefield_id == "jingzhou_siege" else "20分钟 · 兵海"
	_create_button("出征", departure_text if usable else "通关剧情第三关后解锁", _expedition_preview_rect().end - Vector2(258.0, 66.0), _start_selected_endless, Vector2(236.0, 52.0), not usable, 16)

func _populate_boss_trial_expedition() -> void:
	var preview := _expedition_preview_rect()
	var unlocked := SaveService.is_battlefield_unlocked("hulao")
	_create_button("进入试炼", "20级开局 · 三轮斗将" if unlocked else "通关剧情第三关后解锁", preview.end - Vector2(258.0, 66.0), _start_boss_trial, Vector2(236.0, 52.0), not unlocked, 16)

func _select_story_chapter(chapter_id: String) -> void:
	var chapter_index := STORY_CHAPTER_IDS.find(chapter_id)
	if chapter_index < 0 or not SaveService.is_story_chapter_unlocked(chapter_index + 1):
		return
	selected_story_chapter_id = chapter_id
	if SaveService.tutorial_stage() == 16 and chapter_id == "story_01":
		SaveService.set_tutorial_stage(17)
	_show_expedition("story")

func _select_endless_battlefield(battlefield_id: String) -> void:
	if battlefield_id not in ["changban", "jingzhou_siege"]:
		return
	var definition := _battlefield_definition(battlefield_id)
	if not SaveService.is_battlefield_unlocked(battlefield_id) or not bool(definition.get("implemented", false)):
		return
	selected_endless_battlefield_id = battlefield_id
	_show_expedition("endless")

func _battlefield_definition(battlefield_id: String) -> Dictionary:
	return BATTLEFIELD_DEFINITIONS.get(battlefield_id, BATTLEFIELD_DEFINITIONS["changban"]) as Dictionary

func _story_chapter_definition(chapter_id: String) -> Dictionary:
	return STORY_CHAPTER_DEFINITIONS.get(chapter_id, STORY_CHAPTER_DEFINITIONS["story_01"]) as Dictionary

func _expedition_map_rect() -> Rect2:
	# The expedition markers are authored against the select-battle canvas.
	# Keep that canvas' aspect ratio when the viewport changes so the clickable
	# nameplates stay aligned with its painted route.
	var canvas_aspect := EXPEDITION_MAP_SIZE.x / EXPEDITION_MAP_SIZE.y
	var viewport_aspect := size.x / maxf(size.y, 1.0)
	var map_size := size
	if viewport_aspect > canvas_aspect:
		map_size.x = size.y * canvas_aspect
	else:
		map_size.y = size.x / canvas_aspect
	return Rect2((size - map_size) * 0.5, map_size)

func _expedition_ui_scale() -> float:
	return _expedition_map_rect().size.x / EXPEDITION_UI_REFERENCE_SIZE.x

func _expedition_ui_position(reference_position: Vector2) -> Vector2:
	var map_rect := _expedition_map_rect()
	return map_rect.position + reference_position * _expedition_ui_scale()

func _expedition_preview_rect() -> Rect2:
	return Rect2(354.0, 170.0, maxf(420.0, size.x - 410.0), maxf(320.0, size.y - 260.0))

func _expedition_route_button_position(index: int) -> Vector2:
	return EXPEDITION_ROUTE_BUTTON_POSITION + Vector2(0.0, float(index) * EXPEDITION_ROUTE_BUTTON_STEP)

func _story_route_button_position(index: int) -> Vector2:
	return STORY_ROUTE_BUTTON_START + Vector2(0.0, float(index) * STORY_ROUTE_BUTTON_STEP)

func _story_preview_rect() -> Rect2:
	var preview_width := clampf(size.x * 0.46, 500.0, 600.0)
	var preview_x := maxf(STORY_ROUTE_BUTTON_START.x + STORY_ROUTE_BUTTON_SIZE.x + 46.0, size.x - preview_width - 160.0)
	return Rect2(preview_x, STORY_PREVIEW_TOP, preview_width, STORY_PREVIEW_HEIGHT)

func _story_details_rect() -> Rect2:
	var preview := _story_preview_rect()
	return Rect2(preview.position.x, preview.end.y + STORY_DETAILS_GAP, preview.size.x, STORY_DETAILS_HEIGHT)

func _show_shop(section: String = "heroes") -> void:
	shop_build_id += 1
	var build_id := shop_build_id
	var opening_shop := page != "shop"
	if page == "shop":
		if shop_list_scroll != null and is_instance_valid(shop_list_scroll):
			shop_scroll_positions[shop_section] = shop_list_scroll.scroll_horizontal if shop_list_scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED else shop_list_scroll.scroll_vertical
		elif shop_section == "heroes":
			shop_scroll_positions[shop_section] = int(shop_scroll_positions.get(shop_section, 0))
	shop_grid_buttons.clear()
	page = "shop"
	shop_section = section if section in ["heroes", "strategies", "tianji", "souls"] else "heroes"
	var restore_scroll := int(shop_scroll_positions.get(shop_section, 0))
	profile = SaveService.load_profile()
	if SaveService.tutorial_stage() == 1 and shop_section == "heroes":
		SaveService.set_tutorial_stage(2)
		profile = SaveService.load_profile()
	notice = ""
	_clear_buttons()
	if opening_shop and shop_section == "heroes":
		selected_shop_hero_id = "guan_yu"
	if not HERO_CATALOG.has_hero(selected_shop_hero_id) or not RELEASE_HERO_IDS.has(selected_shop_hero_id):
		selected_shop_hero_id = "guan_yu"
	shop_center_panel = null
	shop_detail_panel = null
	shop_detail_body = null
	shop_list_scroll = null
	var viewport := _shop_content_rect()
	var left_width := minf(clampf(viewport.size.x * 0.15, 136.0, 188.0), viewport.size.x * 0.23)
	var detail_width := minf(clampf(viewport.size.x * 0.14, 174.0, 190.0), viewport.size.x * 0.20)
	var gap := minf(clampf(viewport.size.x * 0.011, 8.0, 14.0), viewport.size.x * 0.018)
	var center_width := maxf(1.0, viewport.size.x - left_width - detail_width - gap * 2.0)
	var root := Control.new()
	root.position = viewport.position
	root.size = Vector2(left_width + center_width + detail_width + gap * 2.0, viewport.size.y)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	root.clip_contents = true
	add_child(root)
	page_controls.append(root)
	var category_names := ["武将战法", "军略", "天机", "战魂阁"]
	var category_sections := ["heroes", "strategies", "tianji", "souls"]
	var category_callbacks: Array[Callable] = [_show_shop_heroes, _show_shop_strategies, _show_shop_tianji, _show_shop_souls]
	var category_height := clampf(viewport.size.y * 0.112, 60.0, 78.0)
	var category_gap := clampf(viewport.size.y * 0.024, 12.0, 20.0)
	var categories_height := category_height * 4.0 + category_gap * 3.0
	var categories_top := maxf(12.0, (viewport.size.y - categories_height) * 0.5)
	for index in range(category_names.size()):
		var category_at := Vector2(0.0, categories_top + float(index) * (category_height + category_gap))
		var category_button := _create_shop_texture_button(root, str(category_names[index]), category_at, Vector2(left_width, category_height), category_callbacks[index], shop_section == str(category_sections[index]))
		category_button.tooltip_text = str(category_names[index])
	var center_at := Vector2(left_width + gap, 0.0)
	if shop_section in ["tianji", "souls"]:
		# 只移除中心面板的美术底图，保留控件容器用于承载祭坛星角的可点击节点。
		shop_center_panel = Control.new()
		shop_center_panel.position = center_at
		shop_center_panel.size = Vector2(center_width, viewport.size.y)
		shop_center_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(shop_center_panel)
	else:
		shop_center_panel = _create_shop_texture_panel(root, center_at, Vector2(center_width, viewport.size.y))
	var detail_at := Vector2(center_at.x + center_width + gap, 0.0)
	shop_detail_panel = _create_shop_texture_panel(root, detail_at, Vector2(detail_width, viewport.size.y))
	shop_detail_body = Control.new()
	shop_detail_body.position = Vector2(18.0, 28.0)
	shop_detail_body.size = Vector2(detail_width - 36.0, viewport.size.y - 56.0)
	shop_detail_body.mouse_filter = Control.MOUSE_FILTER_PASS
	shop_detail_panel.add_child(shop_detail_body)
	match shop_section:
		"heroes": _populate_hero_shop()
		"strategies": _populate_strategy_shop(restore_scroll)
		"tianji": _populate_tianji_shop(restore_scroll)
		"souls": _populate_battle_soul_shop(restore_scroll)
	if shop_section == "heroes":
		call_deferred("_restore_hero_shop_scroll", restore_scroll, build_id)
	else:
		call_deferred("_restore_shop_scroll", shop_section, restore_scroll, build_id)
	_create_shared_back_button(_show_main)
	call_deferred("_tutorial_refresh_shop", build_id)
	queue_redraw()

func _restore_hero_shop_scroll(scroll_value: int, build_id: int) -> void:
	if build_id != shop_build_id or shop_section != "heroes":
		return
	if shop_list_scroll == null or not is_instance_valid(shop_list_scroll):
		return
	var target_scroll := maxi(0, scroll_value)
	shop_list_scroll.set_deferred("scroll_horizontal", target_scroll)

func _shop_content_rect() -> Rect2:
	var left_margin := clampf(size.x * 0.018, 18.0, 24.0)
	var right_margin := clampf(size.x * 0.035, 36.0, 48.0)
	var top_margin := 100.0
	var bottom_margin := clampf(size.y * 0.045, 30.0, 40.0)
	return Rect2(
		Vector2(left_margin, top_margin),
		Vector2(maxf(1.0, size.x - left_margin - right_margin), maxf(1.0, size.y - top_margin - bottom_margin))
	)

func _create_shop_texture_panel(parent: Control, at: Vector2, panel_size: Vector2) -> Control:
	var panel := Control.new()
	panel.position = at
	panel.size = panel_size
	panel.clip_contents = true
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	parent.add_child(panel)
	var art := TextureRect.new()
	art.texture = SHOP_PANEL_TEXTURE
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(art)
	return panel

func _create_shop_texture_button(parent: Control, title: String, at: Vector2, button_size: Vector2, callback: Callable, selected: bool, disabled: bool = false) -> Button:
	var button := Button.new()
	button.text = title
	button.position = at
	button.size = button_size
	button.disabled = disabled
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_size_override("font_size", 1)
	button.add_theme_color_override("font_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_disabled_color", Color.TRANSPARENT)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	button.pressed.connect(callback)
	parent.add_child(button)
	var art := TextureRect.new()
	art.texture = SHOP_SELECTED_BUTTON_TEXTURE if selected else SHOP_UNSELECTED_BUTTON_TEXTURE
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(art)
	var label := Label.new()
	label.text = title
	label.position = Vector2(button_size.x * 0.10, button_size.y * 0.12)
	label.size = Vector2(button_size.x * 0.80, button_size.y * 0.76)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bold_font := FontVariation.new()
	bold_font.base_font = KAITI_FONT
	bold_font.variation_embolden = 0.82
	label.add_theme_font_override("font", bold_font)
	label.add_theme_font_size_override("font_size", clampi(int(button_size.y * 0.30), 15, 23))
	label.add_theme_color_override("font_color", Color("ebc587"))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	button.add_child(label)
	if disabled:
		button.modulate = Color(0.52, 0.58, 0.56, 0.78)
	return button

func _shop_label(parent: Control, text: String, at: Vector2, label_size: Vector2, font_size: int, color: Color, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, bold: bool = false) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at
	label.size = label_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if bold:
		var font := FontVariation.new()
		font.base_font = KAITI_FONT
		font.variation_embolden = 0.48
		label.add_theme_font_override("font", font)
	parent.add_child(label)
	return label

func _shop_icon_texture(icon_id: String) -> Texture2D:
	if shop_icon_cache.has(icon_id):
		return shop_icon_cache[icon_id] as Texture2D
	var icon_path := "res://assets/art/ui/shop/skillImg/%s.png" % icon_id
	if icon_id.begins_with("res://"):
		icon_path = icon_id
	elif icon_id.contains("/"):
		icon_path = "res://assets/art/ui/shop/%s.png" % icon_id
	var texture := load(icon_path) as Texture2D
	shop_icon_cache[icon_id] = texture
	return texture

func _shop_item_icon(item_id: String, kind: String) -> String:
	if kind == "talent":
		return str(SHOP_HERO_SKILL_ICONS.get(item_id, "crossed_swords"))
	if kind == "strategy":
		if item_id.contains("armor"):
			return "iron_helm"
		if item_id.contains("march") or item_id.contains("training"):
			return "swift_boots"
		if item_id.contains("command") or item_id.contains("grand"):
			return "war_banner"
		return "crossed_swords"
	if kind == "tianji":
		match item_id:
			"seven_star_lightning": return "tianji/lei"
			"xun_wind_break": return "tianji/feng"
			"eight_trigram_tide": return "tianji/shui"
			"fire_rain_burning": return "tianji/huo"
			"arrow_support_volley": return "tianji/jian"
	if kind == "soul":
		match item_id:
			"gale_mastery": return "zhanhun/gangfeng"
			"thunder_mastery": return "zhanhun/leiting"
			"flame_mastery": return "zhanhun/baoyan"
			"iron_mastery": return "zhanhun/xuanjia"
			"machine_mastery": return "res://assets/art/battle_souls/shenji.png"
	return "crossed_swords"

func _show_shop_heroes() -> void:
	if SaveService.tutorial_stage() == 3 and shop_section == "heroes":
		selected_shop_hero_id = "guan_yu"
	_show_shop("heroes")

func _show_shop_strategies() -> void:
	if SaveService.tutorial_stage() == 10:
		SaveService.set_tutorial_stage(11)
	_show_shop("strategies")

func _show_shop_tianji() -> void:
	if SaveService.tutorial_stage() == 12:
		SaveService.set_tutorial_stage(13)
	_show_shop("tianji")

func _show_shop_souls() -> void:
	_show_shop("souls")

func _request_shop_merit_ad() -> void:
	if AdService.is_showing_rewarded_video():
		return
	notice = "正在加载广告…"
	queue_redraw()
	AdService.show_rewarded_video(AdService.PLACEMENT_SHOP_MERIT)

func _on_rewarded_video_completed(placement: String, rewarded: bool, message: String) -> void:
	if placement != AdService.PLACEMENT_SHOP_MERIT or page != "shop":
		return
	if not rewarded:
		notice = message if not message.is_empty() else "广告未完成，未获得军功"
		queue_redraw()
		return
	SaveService.grant_military_merit(500)
	profile = SaveService.load_profile()
	notice = "获得 500 军功"
	queue_redraw()

func _populate_hero_shop() -> void:
	shop_grid_buttons.clear()
	var hero_gap := 8.0
	var hero_margin := 28.0
	var hero_tab_width := (shop_center_panel.size.x - hero_margin * 2.0 - hero_gap * 4.0) / 5.0
	var hero_tab_height := clampf(shop_center_panel.size.y * 0.092, 42.0, 56.0)
	for index in range(SHOP_HERO_IDS.size()):
		var hero_id := SHOP_HERO_IDS[index]
		var hero := HERO_CATALOG.definition_for(hero_id)
		var released := RELEASE_HERO_IDS.has(hero_id)
		var tab := _create_shop_texture_button(
			shop_center_panel,
			str(hero.get("name", "武将")),
			Vector2(hero_margin + float(index) * (hero_tab_width + hero_gap), 19.0),
			Vector2(hero_tab_width, hero_tab_height),
			Callable(self, "_select_shop_hero").bind(hero_id),
			hero_id == selected_shop_hero_id,
			not released
		)
		tab.tooltip_text = "尚未开放" if not released else ("已招募" if SaveService.has_hero(hero_id) else "招募该武将")
	var nodes: Array[Dictionary] = []
	var all_route_ids: Dictionary = {}
	var hero_owned := SaveService.has_hero(selected_shop_hero_id)
	var branch_index := 0
	for branch_variant in _shop_talent_branches():
		var branch: Dictionary = branch_variant as Dictionary
		var branch_nodes: Array[Dictionary] = []
		for node_variant in branch.get("nodes", []) as Array:
			var node: Dictionary = node_variant as Dictionary
			var talent_id := str(node.get("id", ""))
			var definition: Dictionary = UpgradeSystem.DEFINITIONS.get(talent_id, {}) as Dictionary
			if definition.is_empty():
				continue
			var is_core := bool(node.get("is_core", false))
			var is_run_upgrade := bool(node.get("is_run_upgrade", false))
			var is_auto_unlock := UpgradeSystem.is_auto_unlock_talent(talent_id)
			var rank := SaveService.talent_rank(selected_shop_hero_id, talent_id)
			var max_rank := maxi(1, SaveService.talent_max_rank(selected_shop_hero_id, talent_id))
			if is_core and hero_owned:
				rank = max_rank
			var prerequisite_ok := is_core or SaveService.talent_prerequisite_satisfied_for_purchase(selected_shop_hero_id, talent_id)
			var locked := not hero_owned or (not is_core and not is_auto_unlock and not prerequisite_ok)
			var cost := int(node.get("cost", 0))
			branch_nodes.append({
				"id": talent_id,
				"title": str(definition.get("title", talent_id)),
				"description": str(definition.get("description", "")),
				"summary": str(node.get("summary", "")),
				"branch_index": branch_index,
				"branch_title": str(branch.get("title", "战法")),
				"rank": rank,
				"max_rank": max_rank,
				"icon": _shop_item_icon(talent_id, "talent"),
				"locked": locked,
				"core": is_core,
				"run_upgrade": is_run_upgrade,
				"auto_unlock": is_auto_unlock,
				"cost": cost,
			})
		var branch_lookup: Dictionary = {}
		for branch_node in branch_nodes:
			var branch_node_id := str(branch_node.get("id", ""))
			branch_lookup[branch_node_id] = branch_node
			all_route_ids[branch_node_id] = branch_index
		for branch_node in branch_nodes:
			var branch_talent_id := str(branch_node.get("id", ""))
			var branch_definition: Dictionary = UpgradeSystem.DEFINITIONS.get(branch_talent_id, {}) as Dictionary
			var prerequisite_id := str(branch_definition.get("requires", ""))
			branch_node["route_depth"] = _shop_talent_route_depth(branch_talent_id, branch_lookup, {})
			branch_node["prerequisite_id"] = prerequisite_id
			branch_node["prerequisite_rank"] = maxi(1, int(branch_definition.get("requires_stacks", 1)))
		nodes.append_array(branch_nodes)
		branch_index += 1
	for route_node in nodes:
		var route_prerequisite_id := str(route_node.get("prerequisite_id", ""))
		if route_prerequisite_id.is_empty():
			route_node["missing_prerequisite"] = false
			route_node["prerequisite_in_other_branch"] = false
			continue
		var prerequisite_exists := all_route_ids.has(route_prerequisite_id)
		route_node["missing_prerequisite"] = not prerequisite_exists
		route_node["prerequisite_in_other_branch"] = prerequisite_exists and int(all_route_ids[route_prerequisite_id]) != int(route_node.get("branch_index", -1))
	if nodes.is_empty():
		_render_shop_detail("武将战法", "暂未开放", "该武将的战法资料尚未开放。", 0, 0, "敬请期待", "", Callable(), true, "crossed_swords")
		return
	var first_id := str(nodes[0].get("id", ""))
	var selected_exists := false
	for node in nodes:
		if str(node.get("id", "")) == selected_shop_talent_id:
			selected_exists = true
			break
	if not selected_exists:
		selected_shop_talent_id = first_id
	if SaveService.tutorial_stage() == 3 and selected_shop_hero_id == "guan_yu":
		selected_shop_talent_id = "guan_drag_blade"
	if SaveService.tutorial_stage() == 7 and selected_shop_hero_id == "zhang_fei":
		selected_shop_talent_id = "zhang_slam_leap"
	var viewport := Rect2(Vector2(34.0, hero_tab_height + 38.0), Vector2(shop_center_panel.size.x - 68.0, shop_center_panel.size.y - hero_tab_height - 60.0))
	_create_shop_talent_route(nodes, viewport)
	var selected_node: Dictionary = {}
	for node in nodes:
		if str(node.get("id", "")) == selected_shop_talent_id:
			selected_node = node
			break
	if not selected_node.is_empty():
		_show_shop_item_detail(selected_shop_talent_id)

func _shop_talent_route_depth(talent_id: String, branch_nodes: Dictionary, visiting: Dictionary) -> int:
	if visiting.has(talent_id):
		return 0
	var definition: Dictionary = UpgradeSystem.DEFINITIONS.get(talent_id, {}) as Dictionary
	var prerequisite_id := str(definition.get("requires", ""))
	if prerequisite_id.is_empty() or not branch_nodes.has(prerequisite_id):
		return 0
	var next_visiting := visiting.duplicate()
	next_visiting[talent_id] = true
	return _shop_talent_route_depth(prerequisite_id, branch_nodes, next_visiting) + 1

func _shop_talent_subtree_span(talent_id: String, children: Dictionary, spans: Dictionary, visiting: Dictionary) -> int:
	if spans.has(talent_id):
		return int(spans[talent_id])
	if visiting.has(talent_id):
		return 1
	var next_visiting := visiting.duplicate()
	next_visiting[talent_id] = true
	var child_ids: Array = children.get(talent_id, []) as Array
	var span := 0
	for child_id_variant in child_ids:
		span += _shop_talent_subtree_span(str(child_id_variant), children, spans, next_visiting)
	span = maxi(1, span)
	spans[talent_id] = span
	return span

func _shop_talent_subtree_height(talent_id: String, children: Dictionary) -> int:
	var child_ids: Array = children.get(talent_id, []) as Array
	var height := 1
	for child_id_variant in child_ids:
		height = maxi(height, _shop_talent_subtree_height(str(child_id_variant), children) + 1)
	return height

func _shop_talent_wrapped_title(title: String, available_width: float, font: Font, font_size: int) -> String:
	var max_line_width := maxf(1.0, available_width)
	var result := ""
	var line := ""
	for character in title:
		if character == "\n":
			result += line + "\n"
			line = ""
			continue
		if not line.is_empty() and font.get_string_size(line + character, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x > max_line_width:
			result += line + "\n"
			line = character
		else:
			line += character
	return result + line

func _layout_shop_talent_subtree(talent_id: String, subtree_left: float, top_y: float, children: Dictionary, positions: Dictionary, card_width: float, card_height: float, vertical_gap: float, horizontal_gap: float, spans: Dictionary, visiting: Dictionary = {}) -> float:
	if visiting.has(talent_id) or positions.has(talent_id):
		return top_y
	var span := maxi(1, int(spans.get(talent_id, 1)))
	var subtree_width := float(span) * card_width + float(span - 1) * horizontal_gap
	var card_x := subtree_left + (subtree_width - card_width) * 0.5
	positions[talent_id] = Rect2(Vector2(card_x, top_y), Vector2(card_width, card_height))
	var next_visiting := visiting.duplicate()
	next_visiting[talent_id] = true
	var child_ids: Array = children.get(talent_id, []) as Array
	if child_ids.is_empty():
		return top_y + card_height
	var child_width := 0.0
	for index in range(child_ids.size()):
		var child_id := str(child_ids[index])
		var child_span := maxi(1, int(spans.get(child_id, 1)))
		child_width += float(child_span) * card_width + float(child_span - 1) * horizontal_gap
		if index > 0:
			child_width += horizontal_gap
	var child_left := subtree_left + (subtree_width - child_width) * 0.5
	var child_top := top_y + card_height + vertical_gap
	var bottom_y := child_top
	for child_id_variant in child_ids:
		var child_id := str(child_id_variant)
		var child_span := maxi(1, int(spans.get(child_id, 1)))
		var child_subtree_width := float(child_span) * card_width + float(child_span - 1) * horizontal_gap
		bottom_y = maxf(bottom_y, _layout_shop_talent_subtree(child_id, child_left, child_top, children, positions, card_width, card_height, vertical_gap, horizontal_gap, spans, next_visiting))
		child_left += child_subtree_width + horizontal_gap
	return bottom_y

func _create_shop_talent_route(items: Array[Dictionary], viewport: Rect2) -> void:
	var scroll := ScrollContainer.new()
	scroll.position = viewport.position
	scroll.size = viewport.size
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = int(PAGE_SCROLL_DRAG_THRESHOLD)
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.tooltip_text = "拖动查看路线"
	# Native touch scrolling avoids fighting the container's gesture handling.
	scroll.gui_input.connect(_on_shop_talent_route_scroll_gui_input.bind(scroll))
	shop_center_panel.add_child(scroll)
	page_controls.append(scroll)
	shop_list_scroll = scroll
	var available_width := maxf(160.0, viewport.size.x - 18.0)
	var card_height := 82.0
	var vertical_gap := 18.0
	var horizontal_gap := 10.0
	var branch_gap := 14.0
	var content_margin := 18.0
	var min_card_width := 84.0
	var max_card_width := 94.0
	var route_top := 82.0
	var content := Control.new()
	content.custom_minimum_size = Vector2(available_width, 1.0)
	content.size = content.custom_minimum_size
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.add_child(content)

	# Draw only dependencies within one branch. Long cross-branch connectors pass
	# behind unrelated cards and appear as stray horizontal lines when clipped.
	var item_by_id: Dictionary = {}
	var branch_items_by_index: Dictionary = {}
	var branch_titles: Dictionary = {}
	var branch_count := 0
	for item in items:
		var item_id := str(item.get("id", ""))
		if item_id.is_empty():
			continue
		item_by_id[item_id] = item
		var branch_index := int(item.get("branch_index", -1))
		branch_count = maxi(branch_count, branch_index + 1)
		if not branch_items_by_index.has(branch_index):
			branch_items_by_index[branch_index] = []
		var branch_items: Array = branch_items_by_index[branch_index] as Array
		branch_items.append(item)
		branch_titles[branch_index] = str(item.get("branch_title", "战法路线"))
	if item_by_id.is_empty() or branch_count <= 0:
		content.custom_minimum_size = Vector2(available_width, 1.0)
		return
	var children: Dictionary = {}
	for item in items:
		var item_id := str(item.get("id", ""))
		var prerequisite_id := str(item.get("prerequisite_id", ""))
		if item_id.is_empty() or prerequisite_id.is_empty() or not item_by_id.has(prerequisite_id):
			continue
		var prerequisite_item: Dictionary = item_by_id[prerequisite_id] as Dictionary
		if int(item.get("branch_index", -1)) != int(prerequisite_item.get("branch_index", -1)):
			continue
		if not children.has(prerequisite_id):
			children[prerequisite_id] = []
		var child_ids: Array = children[prerequisite_id] as Array
		if not child_ids.has(item_id):
			child_ids.append(item_id)

	# A prerequisite in another branch starts a local route under its own header;
	# the exact prerequisite remains visible in the card's description and tooltip.
	var branch_infos: Array[Dictionary] = []
	var total_span_units := 0
	var total_lane_gaps := 0
	var active_branch_count := 0
	for branch_index in range(branch_count):
		var branch_items: Array = branch_items_by_index.get(branch_index, []) as Array
		if branch_items.is_empty():
			continue
		var local_children: Dictionary = {}
		var roots: Array[String] = []
		for item_variant in branch_items:
			var item: Dictionary = item_variant as Dictionary
			var item_id := str(item.get("id", ""))
			var prerequisite_id := str(item.get("prerequisite_id", ""))
			var prerequisite_item: Dictionary = item_by_id.get(prerequisite_id, {}) as Dictionary
			var same_branch := not prerequisite_item.is_empty() and int(prerequisite_item.get("branch_index", -1)) == branch_index
			if same_branch:
				if not local_children.has(prerequisite_id):
					local_children[prerequisite_id] = []
				var local_child_ids: Array = local_children[prerequisite_id] as Array
				local_child_ids.append(item_id)
			else:
				roots.append(item_id)
		if roots.is_empty() and not branch_items.is_empty():
			roots.append(str((branch_items[0] as Dictionary).get("id", "")))
		var spans: Dictionary = {}
		var span_units := 0
		for root_id in roots:
			var root_span := _shop_talent_subtree_span(root_id, local_children, spans, {})
			span_units += maxi(1, root_span)
		span_units = maxi(1, span_units)
		var lane_gap_count := maxi(0, span_units - 1)
		branch_infos.append({
			"index": branch_index,
			"items": branch_items,
			"roots": roots,
			"children": local_children,
			"spans": spans,
			"span_units": span_units,
			"lane_gap_count": lane_gap_count,
			"title": str(branch_titles.get(branch_index, "战法路线")),
		})
		total_span_units += span_units
		total_lane_gaps += lane_gap_count
		active_branch_count += 1
	if branch_infos.is_empty():
		return
	var fixed_width := content_margin * 2.0 + float(maxi(0, active_branch_count - 1)) * branch_gap + float(total_lane_gaps) * horizontal_gap
	var fitted_card_width := (available_width - fixed_width) / float(maxi(1, total_span_units))
	var card_width := clampf(fitted_card_width, min_card_width, max_card_width)
	var content_width := maxf(available_width, fixed_width + card_width * float(total_span_units))
	var title_font := FontVariation.new()
	title_font.base_font = KAITI_FONT
	title_font.variation_embolden = 0.48
	var wrapped_titles: Dictionary = {}
	var max_title_lines := 1
	for item in items:
		var item_id := str(item.get("id", ""))
		var wrapped_title := _shop_talent_wrapped_title(str(item.get("title", item_id)), card_width - 12.0, title_font, 16)
		wrapped_titles[item_id] = wrapped_title
		max_title_lines = maxi(max_title_lines, wrapped_title.split("\n").size())
	var route_icon_size := clampf(minf(44.0, card_width * 0.52), 36.0, 44.0)
	var route_title_top := route_icon_size + 17.0
	card_height = maxf(card_height, route_title_top + float(max_title_lines) * (title_font.get_height(16) + 2.0) + 4.0)
	var route_bottom := route_top
	var positions: Dictionary = {}
	var branch_connector_specs: Array[Dictionary] = []
	var lane_left := content_margin
	for branch_info in branch_infos:
		var branch_items: Array = branch_info.get("items", []) as Array
		var roots: Array = branch_info.get("roots", []) as Array
		var local_children: Dictionary = branch_info.get("children", {}) as Dictionary
		var spans: Dictionary = branch_info.get("spans", {}) as Dictionary
		var span_units := int(branch_info.get("span_units", 1))
		var lane_gap_count := int(branch_info.get("lane_gap_count", 0))
		var lane_width := float(span_units) * card_width + float(lane_gap_count) * horizontal_gap
		var branch_title := str(branch_info.get("title", "战法路线"))
		var branch_header := Panel.new()
		var header_width := minf(132.0, maxf(68.0, lane_width - 8.0))
		branch_header.position = Vector2(lane_left + (lane_width - header_width) * 0.5, 3.0)
		branch_header.size = Vector2(header_width, 42.0)
		branch_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
		branch_header.add_theme_stylebox_override("panel", UITheme.flat_box_style(Color("283128"), Color("b89b60"), 2))
		content.add_child(branch_header)
		var branch_label := _shop_label(branch_header, branch_title, Vector2(5.0, 3.0), branch_header.size - Vector2(10.0, 6.0), 14, Color("e0c487"), HORIZONTAL_ALIGNMENT_CENTER, true)
		branch_label.z_index = 1
		branch_connector_specs.append({
			"center_x": lane_left + lane_width * 0.5,
			"roots": roots.duplicate(),
		})
		var cursor_x := lane_left
		var branch_bottom := route_top
		for root_id_variant in roots:
			var root_id := str(root_id_variant)
			var root_span := maxi(1, int(spans.get(root_id, 1)))
			var root_width := float(root_span) * card_width + float(root_span - 1) * horizontal_gap
			var bottom_y := _layout_shop_talent_subtree(root_id, cursor_x, route_top, local_children, positions, card_width, card_height, vertical_gap, horizontal_gap, spans)
			branch_bottom = maxf(branch_bottom, bottom_y)
			cursor_x += root_width + horizontal_gap
		route_bottom = maxf(route_bottom, branch_bottom)
		lane_left += lane_width + branch_gap
	content_width = maxf(content_width, lane_left - branch_gap + content_margin)

	# Connect headers to roots and draw only local parent-child dependencies.
	var connector_layer := Control.new()
	connector_layer.position = Vector2.ZERO
	connector_layer.size = Vector2(content_width, route_bottom + 12.0)
	connector_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	connector_layer.clip_contents = true
	connector_layer.z_index = 0
	content.add_child(connector_layer)
	for branch_spec in branch_connector_specs:
		var root_rects: Array[Rect2] = []
		for root_id_variant in branch_spec.get("roots", []) as Array:
			var root_id := str(root_id_variant)
			if positions.has(root_id):
				root_rects.append(positions[root_id])
		if root_rects.is_empty():
			continue
		root_rects.sort_custom(func(a: Rect2, b: Rect2) -> bool: return a.position.x < b.position.x)
		var branch_center_x := float(branch_spec.get("center_x", 0.0))
		var branch_line_y := route_top - 14.0
		var first_root: Rect2 = root_rects[0]
		var last_root: Rect2 = root_rects[root_rects.size() - 1]
		var first_root_x := first_root.position.x + first_root.size.x * 0.5
		var last_root_x := last_root.position.x + last_root.size.x * 0.5
		var group_color := Color("a39064")
		_add_tree_line(connector_layer, [Vector2(branch_center_x, 45.0), Vector2(branch_center_x, branch_line_y)], group_color)
		var group_left := minf(branch_center_x, first_root_x)
		var group_right := maxf(branch_center_x, last_root_x)
		if group_right - group_left > 0.5:
			_add_tree_line(connector_layer, [Vector2(group_left, branch_line_y), Vector2(group_right, branch_line_y)], group_color)
		for root_rect in root_rects:
			var root_x := root_rect.position.x + root_rect.size.x * 0.5
			_add_tree_line(connector_layer, [Vector2(root_x, branch_line_y), Vector2(root_x, root_rect.position.y)], group_color)
	for parent_id_variant in children.keys():
		var parent_id := str(parent_id_variant)
		if not positions.has(parent_id):
			continue
		var child_rects: Array[Rect2] = []
		for child_id_variant in children[parent_id] as Array:
			var child_id := str(child_id_variant)
			if positions.has(child_id):
				child_rects.append(positions[child_id])
		if child_rects.is_empty():
			continue
		child_rects.sort_custom(func(a: Rect2, b: Rect2) -> bool: return a.position.x < b.position.x)
		var parent_item: Dictionary = item_by_id.get(parent_id, {}) as Dictionary
		var line_color := Color("8e9b91") if bool(parent_item.get("locked", false)) else Color("b89b60")
		var parent_rect: Rect2 = positions[parent_id]
		var parent_center := Vector2(parent_rect.position.x + parent_rect.size.x * 0.5, parent_rect.end.y)
		if child_rects.size() == 1:
			var child_rect: Rect2 = child_rects[0]
			var child_center := Vector2(child_rect.position.x + child_rect.size.x * 0.5, child_rect.position.y)
			if absf(parent_center.x - child_center.x) < 1.0:
				_add_tree_line(connector_layer, [parent_center, child_center], line_color)
			else:
				var elbow_y := (parent_center.y + child_center.y) * 0.5
				_add_tree_line(connector_layer, [parent_center, Vector2(parent_center.x, elbow_y), Vector2(child_center.x, elbow_y), child_center], line_color)
			continue
		var first_center_x := child_rects[0].position.x + child_rects[0].size.x * 0.5
		var last_center_x := child_rects[child_rects.size() - 1].position.x + child_rects[child_rects.size() - 1].size.x * 0.5
		var first_child_top := child_rects[0].position.y
		var branch_y := minf(parent_center.y + vertical_gap * 0.5, first_child_top - 6.0)
		if branch_y <= parent_center.y:
			branch_y = (parent_center.y + first_child_top) * 0.5
		_add_tree_line(connector_layer, [parent_center, Vector2(parent_center.x, branch_y), Vector2(first_center_x, branch_y)], line_color)
		if absf(first_center_x - last_center_x) > 0.5:
			_add_tree_line(connector_layer, [Vector2(first_center_x, branch_y), Vector2(last_center_x, branch_y)], line_color)
		for child_rect in child_rects:
			var child_center_x := child_rect.position.x + child_rect.size.x * 0.5
			_add_tree_line(connector_layer, [Vector2(child_center_x, branch_y), Vector2(child_center_x, child_rect.position.y)], line_color)

	for item in items:
		var item_id := str(item.get("id", ""))
		if positions.has(item_id):
			_create_shop_talent_route_card(content, item, positions[item_id] as Rect2, str(wrapped_titles.get(item_id, item.get("title", item_id))), scroll)
	content.custom_minimum_size = Vector2(content_width, route_bottom + 22.0)
	content.size = content.custom_minimum_size

func _create_shop_talent_route_card(parent: Control, item: Dictionary, card_rect: Rect2, wrapped_title: String, scroll: ScrollContainer) -> void:
	var item_id := str(item.get("id", ""))
	var item_key := "%s:%s" % [shop_section, item_id]
	var card := Button.new()
	card.text = ""
	card.position = card_rect.position
	card.size = card_rect.size
	card.clip_contents = true
	card.focus_mode = Control.FOCUS_NONE
	# Let touch drags reach the ScrollContainer, without changing normal tap selection.
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		card.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	card.set_meta("hero_talent_route_card", true)
	card.set_meta("shop_talent_drag_cancelled", false)
	card.gui_input.connect(_on_shop_talent_route_card_gui_input.bind(scroll, card))
	card.pressed.connect(_on_shop_talent_route_card_pressed.bind(item, card))
	var selection_frame := Panel.new()
	selection_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	selection_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection_frame.visible = false
	selection_frame.add_theme_stylebox_override(
		"panel",
		UITheme.flat_box_style(Color(0.08, 0.10, 0.08, 0.58), GOLD_BRIGHT, 2)
	)
	card.add_child(selection_frame)
	card.set_meta("shop_selection_frame", selection_frame)
	var route_kind := str(item.get("route_kind", "talent"))
	var route_label := "军略" if route_kind == "strategy" else "战法"
	var description := str(item.get("description", ""))
	var missing_prerequisite := bool(item.get("missing_prerequisite", false))
	var prerequisite_in_other_branch := bool(item.get("prerequisite_in_other_branch", false))
	var prerequisite_id := str(item.get("prerequisite_id", ""))
	var prerequisite_rank := int(item.get("prerequisite_rank", 1))
	if missing_prerequisite:
		description = "路线前置缺失，无法绘制依赖连线。\n" + description
	elif prerequisite_in_other_branch:
		description = "前置%s位于其他分支；请查看下方前置名称。\n" % route_label + description
	var prerequisite_text := ""
	if not prerequisite_id.is_empty():
		var prerequisite_title := str(item.get("prerequisite_title", prerequisite_id))
		if route_kind == "strategy":
			prerequisite_title = MILITARY_STRATEGY.title_for(prerequisite_id)
		else:
			prerequisite_title = str((UpgradeSystem.DEFINITIONS.get(prerequisite_id, {}) as Dictionary).get("title", prerequisite_id))
		prerequisite_text = "\n前置：%s · 至少 %d 阶" % [prerequisite_title, prerequisite_rank]
	var requirement_text := str(item.get("prerequisite_text", ""))
	if not requirement_text.is_empty():
		prerequisite_text += "\n" + requirement_text
	card.tooltip_text = "%s\n%s\n当前阶数：%d / %d%s%s" % [str(item.get("title", item_id)), description, int(item.get("rank", 0)), int(item.get("max_rank", 1)), prerequisite_text, "\n路线前置缺失" if missing_prerequisite else ""]
	parent.add_child(card)
	var icon_size := clampf(minf(44.0, card.size.x * 0.52), 36.0, 44.0)
	var icon_frame := Control.new()
	icon_frame.position = Vector2((card.size.x - icon_size) * 0.5, 1.0)
	icon_frame.size = Vector2.ONE * icon_size
	icon_frame.clip_contents = true
	icon_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(icon_frame)
	var icon := TextureRect.new()
	icon.texture = _shop_icon_texture(str(item.get("icon", "crossed_swords")))
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_frame.add_child(icon)
	var rank := int(item.get("rank", 0))
	var max_rank := int(item.get("max_rank", 1))
	var locked := bool(item.get("locked", false))
	if rank <= 0 or locked:
		var shade := ColorRect.new()
		shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		shade.color = Color(0.025, 0.035, 0.04, 0.64 if locked else 0.42)
		shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_frame.add_child(shade)
	if locked:
		var lock := ShopLockMark.new()
		lock.position = Vector2.ONE * icon_size * 0.34
		lock.size = Vector2.ONE * icon_size * 0.32
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_frame.add_child(lock)
	var rank_label := _shop_label(card, "%d / %d" % [rank, max_rank], Vector2(3.0, icon_size - 3.0), Vector2(card.size.x - 6.0, 16.0), 12, GOLD_BRIGHT if rank > 0 else Color("95a099"), HORIZONTAL_ALIGNMENT_CENTER, true)
	rank_label.z_index = 1
	rank_label.clip_text = false
	var title_top := icon_size + 17.0
	var title_height := maxf(24.0, card.size.y - title_top - 2.0)
	var title := _shop_label(card, wrapped_title, Vector2(4.0, title_top), Vector2(card.size.x - 8.0, title_height), 16, Color("e2d2aa") if rank > 0 else Color("aab1a9"), HORIZONTAL_ALIGNMENT_CENTER, true)
	title.clip_text = false
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	title.add_theme_constant_override("line_spacing", 2)
	if missing_prerequisite:
		var warning := _shop_label(card, "!", Vector2(card.size.x - 16.0, 1.0), Vector2(14.0, 15.0), 12, Color("e6a15d"), HORIZONTAL_ALIGNMENT_CENTER, true)
		warning.tooltip_text = "配置的前置%s不在此路线中" % route_label
	shop_grid_buttons[item_key] = card

func _on_shop_talent_route_scroll_gui_input(event: InputEvent, scroll: ScrollContainer) -> void:
	if event is InputEventScreenTouch:
		if not event.pressed:
			scroll.set_meta("shop_talent_touch_card", null)
		return
	if event is InputEventScreenDrag:
		return
	_on_page_scroll_gui_input(event, scroll)

func _on_shop_talent_route_card_gui_input(event: InputEvent, scroll: ScrollContainer, card: Button) -> void:
	if not is_instance_valid(scroll) or not is_instance_valid(card):
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			card.set_meta("shop_talent_drag_cancelled", false)
			card.set_meta("shop_talent_touch_start", event.position)
			scroll.set_meta("shop_talent_touch_card", card)
		elif bool(card.get_meta("shop_talent_drag_cancelled", false)):
			call_deferred("_clear_shop_talent_drag_cancelled", card)
		return
	if event is InputEventScreenDrag:
		var start: Vector2 = card.get_meta("shop_talent_touch_start", event.position)
		if event.position.distance_to(start) >= PAGE_SCROLL_DRAG_THRESHOLD:
			card.set_meta("shop_talent_drag_cancelled", true)
		return
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		# The button and its scroll viewport use different local coordinates.
		_on_page_scroll_gui_input(event, scroll, card)
		if page_scroll_dragging:
			card.set_meta("shop_talent_drag_cancelled", true)
			card.accept_event()
		elif event is InputEventMouseButton and not event.pressed and bool(card.get_meta("shop_talent_drag_cancelled", false)):
			call_deferred("_clear_shop_talent_drag_cancelled", card)
func _clear_shop_talent_drag_cancelled(card: Button) -> void:
	if is_instance_valid(card):
		card.set_meta("shop_talent_drag_cancelled", false)

func _on_shop_talent_route_card_pressed(item: Dictionary, card: Button) -> void:
	if bool(card.get_meta("shop_talent_drag_cancelled", false)):
		card.set_meta("shop_talent_drag_cancelled", false)
		return
	_shop_item_callback(item).call()

func _create_shop_icon_grid(items: Array[Dictionary], viewport: Rect2, restore_scroll: int, tooltip: String) -> void:
	var scroll := ScrollContainer.new()
	scroll.position = viewport.position
	scroll.size = viewport.size
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = int(PAGE_SCROLL_DRAG_THRESHOLD)
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.tooltip_text = tooltip
	scroll.gui_input.connect(_on_page_scroll_gui_input.bind(scroll))
	shop_center_panel.add_child(scroll)
	page_controls.append(scroll)
	shop_list_scroll = scroll
	var grid_width := maxf(120.0, viewport.size.x - 18.0)
	var columns := clampi(int(floor(grid_width / 144.0)), 2, 5)
	var cell_width := grid_width / float(columns)
	var cell_height := 136.0
	var rows := int(ceil(float(items.size()) / float(columns)))
	var content := Control.new()
	content.custom_minimum_size = Vector2(grid_width, float(rows) * cell_height + 8.0)
	content.size = content.custom_minimum_size
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.add_child(content)
	for index in range(items.size()):
		var item: Dictionary = items[index]
		var item_id := str(item.get("id", ""))
		var item_key := "%s:%s" % [shop_section, item_id]
		var column := index % columns
		var row := int(index / columns)
		var at := Vector2(float(column) * cell_width + 5.0, float(row) * cell_height + 4.0)
		var cell := Button.new()
		cell.text = str(item.get("title", item_id))
		cell.position = at
		cell.size = Vector2(cell_width - 10.0, cell_height - 8.0)
		cell.clip_contents = true
		cell.focus_mode = Control.FOCUS_NONE
		cell.add_theme_font_size_override("font_size", 1)
		cell.add_theme_color_override("font_color", Color.TRANSPARENT)
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			cell.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		cell.add_theme_stylebox_override("hover", UITheme.flat_box_style(Color(0.07, 0.10, 0.09, 0.42), Color("9b8152"), 1))
		cell.add_theme_stylebox_override("pressed", UITheme.flat_box_style(Color(0.12, 0.14, 0.10, 0.64), GOLD_BRIGHT, 2))
		cell.pressed.connect(_shop_item_callback(item))
		cell.tooltip_text = "%s\n%s" % [str(item.get("title", item_id)), str(item.get("description", ""))]
		content.add_child(cell)
		var icon_size := minf(48.0, cell.size.x - 24.0)
		var icon_at := Vector2((cell.size.x - icon_size) * 0.5, 7.0)
		var icon_frame := Control.new()
		icon_frame.position = icon_at
		icon_frame.size = Vector2.ONE * icon_size
		icon_frame.clip_contents = true
		icon_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(icon_frame)
		var icon := TextureRect.new()
		icon.texture = _shop_icon_texture(str(item.get("icon", "crossed_swords")))
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_frame.add_child(icon)
		var base_soul := shop_section == "souls" and item_id != SOUL_RESONANCE.ID
		var rank := int(item.get("rank", 0)) + (1 if base_soul else 0)
		var max_rank := int(item.get("max_rank", 1)) + (1 if base_soul else 0)
		if rank <= 0 or bool(item.get("locked", false)):
			var shade := ColorRect.new()
			shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			shade.color = Color(0.025, 0.035, 0.04, 0.60 if bool(item.get("locked", false)) else 0.42)
			shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon_frame.add_child(shade)
		if bool(item.get("locked", false)):
			var lock := ShopLockMark.new()
			lock.position = Vector2.ONE * icon_size * 0.34
			lock.size = Vector2.ONE * icon_size * 0.32
			lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon_frame.add_child(lock)
		_shop_label(cell, "%d / %d" % [rank, max_rank], Vector2(0.0, icon_size + 11.0), Vector2(cell.size.x, 17.0), 12, GOLD_BRIGHT if rank > 0 else Color("9aa6a3"), HORIZONTAL_ALIGNMENT_CENTER)
		_shop_label(cell, str(item.get("title", item_id)), Vector2(3.0, icon_size + 32.0), Vector2(cell.size.x - 6.0, 20.0), 12, Color("e0d1aa") if rank > 0 else Color("a8b0aa"), HORIZONTAL_ALIGNMENT_CENTER)
		shop_grid_buttons[item_key] = cell
	_set_shop_grid_selection(str(items[0].get("id", "")))

func _shop_background_rect() -> Rect2:
	var texture_size := SHOP_BACKGROUND_TEXTURE.get_size()
	var scale_factor := maxf(size.x / texture_size.x, size.y / texture_size.y)
	var draw_size := texture_size * scale_factor
	return Rect2((size - draw_size) * 0.5, draw_size)

func _create_shop_altar_nodes(items: Array[Dictionary], tooltip: String) -> void:
	var art_rect := _shop_background_rect()
	var center_origin := shop_center_panel.get_global_rect().position
	var node_size := Vector2(clampf(size.x * 0.105, 92.0, 136.0), clampf(size.y * 0.134, 80.0, 108.0))
	if shop_section == "souls":
		var lines := SoulResonanceLines.new()
		lines.size = shop_center_panel.size
		lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lines.center = art_rect.position + art_rect.size * SHOP_SOUL_CENTER_POINT - center_origin
		lines.illuminated = SOUL_RESONANCE.rank_for(profile) > 0
		for corner in SHOP_ALTAR_POINTS:
			lines.points.append(art_rect.position + art_rect.size * corner - center_origin)
		shop_center_panel.add_child(lines)
	for index in range(items.size()):
		var item: Dictionary = items[index]
		var item_id := str(item.get("id", ""))
		var is_resonance := shop_section == "souls" and item_id == SOUL_RESONANCE.ID
		var point: Vector2
		if is_resonance:
			point = art_rect.position + art_rect.size * SHOP_SOUL_CENTER_POINT
		else:
			if index >= SHOP_ALTAR_POINTS.size() or (shop_section == "souls" and index >= SHOP_SOUL_POINT_SLOTS.size()):
				continue
			var slot := int(SHOP_SOUL_POINT_SLOTS[index]) if shop_section == "souls" else index
			if slot < 0 or slot >= SHOP_ALTAR_POINTS.size():
				continue
			point = art_rect.position + art_rect.size * (SHOP_ALTAR_POINTS[slot] as Vector2)
		var cell := Button.new()
		cell.text = str(item.get("title", item_id))
		cell.position = point - center_origin - node_size * 0.5
		cell.position.x = clampf(cell.position.x, 0.0, maxf(0.0, shop_center_panel.size.x - node_size.x))
		cell.position.y = clampf(cell.position.y, 0.0, maxf(0.0, shop_center_panel.size.y - node_size.y))
		cell.size = node_size
		cell.set_meta("shop_altar_node", true)
		cell.focus_mode = Control.FOCUS_NONE
		cell.mouse_filter = Control.MOUSE_FILTER_STOP
		# The node is a hit target, not the icon's clipping viewport.  Keeping the
		# icon outside the Button prevents Godot from cropping a large source texture
		# to the Button's content rect on mobile renderers.
		cell.clip_contents = false
		cell.add_theme_font_size_override("font_size", 1)
		cell.add_theme_color_override("font_color", Color.TRANSPARENT)
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			cell.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		cell.add_theme_stylebox_override("hover", UITheme.flat_box_style(Color(0.06, 0.08, 0.08, 0.55), GOLD, 2))
		cell.add_theme_stylebox_override("pressed", UITheme.flat_box_style(Color(0.08, 0.11, 0.11, 0.72), GOLD_BRIGHT, 2))
		cell.pressed.connect(_shop_item_callback(item))
		cell.tooltip_text = "%s · %s\n%s" % [tooltip, cell.text, str(item.get("description", ""))]
		shop_center_panel.add_child(cell)
		var selection_frame := Panel.new()
		selection_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		selection_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		selection_frame.visible = false
		selection_frame.add_theme_stylebox_override(
			"panel",
			StyleBoxEmpty.new() if is_resonance else UITheme.flat_box_style(Color(0.08, 0.11, 0.10, 0.66), GOLD_BRIGHT, 2)
		)
		cell.add_child(selection_frame)
		cell.set_meta("shop_selection_frame", selection_frame)
		# Keep the complete framed badge in an independent, fixed-size viewport.
		# These PNGs are full circular badges; placing the TextureRect directly under
		# the Button allowed the Button's content clipping to show only a corner.
		# Keep the source artwork inside the node's reserved area.  The source
		# textures are large framed badges, so using a quarter of the node size
		# prevents them from covering neighboring altar nodes.
		var altar_icon_size := clampf(minf(node_size.x, node_size.y) , 36.0, 80.0)
		var icon_frame := Control.new()
		icon_frame.position = cell.position + Vector2((node_size.x - altar_icon_size) * 0.5 - 2.0, 4.0)
		icon_frame.size = Vector2.ONE * altar_icon_size
		icon_frame.custom_minimum_size = Vector2.ZERO
		icon_frame.clip_contents = true
		icon_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_frame.z_index = 2
		shop_center_panel.add_child(icon_frame)
		var icon := TextureRect.new()
		icon.texture = _shop_icon_texture(str(item.get("icon", "crossed_swords")))
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.custom_minimum_size = Vector2.ZERO
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_frame.add_child(icon)
		var rank := int(item.get("rank", 0))
		var max_rank := int(item.get("max_rank", 1))
		var base_soul := shop_section == "souls" and not is_resonance
		var shown_rank := rank + 1 if base_soul else rank
		var shown_max := max_rank + 1 if base_soul else max_rank
		if (rank <= 0 and not base_soul) or bool(item.get("locked", false)):
			icon.modulate = Color(0.62, 0.65, 0.65, 0.85)
		var altar_title_y := altar_icon_size + 6.0
		var altar_rank_y := altar_title_y + 22.0
		_shop_label(cell, cell.text, Vector2(0.0, altar_title_y), Vector2(node_size.x, 24.0), 15, GOLD_BRIGHT if shown_rank > 0 else Color("d3c7a6"), HORIZONTAL_ALIGNMENT_CENTER, true)
		var rank_text := "%d / %d 级" % [shown_rank, shown_max]
		if is_resonance and rank == 0:
			rank_text = "锁定" if bool(item.get("locked", false)) else "未激活"
		_shop_label(cell, rank_text, Vector2(0.0, altar_rank_y), Vector2(node_size.x, 18.0), 12, Color("e6d8b4") if rank >= max_rank else Color("b3c7c5"), HORIZONTAL_ALIGNMENT_CENTER, true)
		shop_grid_buttons["%s:%s" % [shop_section, item_id]] = cell

func _shop_item_callback(item: Dictionary) -> Callable:
	var item_id := str(item.get("id", ""))
	return Callable(self, "_show_shop_item_detail").bind(item_id)

func _set_shop_grid_selection(item_id: String) -> void:
	var selected_key := "%s:%s" % [shop_section, item_id]
	for key_variant in shop_grid_buttons.keys():
		var key := str(key_variant)
		var candidate = shop_grid_buttons.get(key)
		if not is_instance_valid(candidate) or not candidate is Button:
			continue
		var button := candidate as Button
		var selected := key == selected_key
		if bool(button.get_meta("shop_altar_node", false)):
			button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
			var altar_selection_frame = button.get_meta("shop_selection_frame", null)
			if is_instance_valid(altar_selection_frame) and altar_selection_frame is Panel:
				(altar_selection_frame as Panel).visible = selected
		elif bool(button.get_meta("hero_talent_route_card", false)):
			for state in ["normal", "hover", "pressed", "disabled", "focus"]:
				button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
			var route_selection_frame = button.get_meta("shop_selection_frame", null)
			if is_instance_valid(route_selection_frame) and route_selection_frame is Panel:
				(route_selection_frame as Panel).visible = selected
		else:
			button.add_theme_stylebox_override(
				"normal",
				UITheme.flat_box_style(Color(0.08, 0.10, 0.08, 0.52), GOLD_BRIGHT, 2)
				if selected else StyleBoxEmpty.new()
			)

func _selected_shop_hero_name() -> String:
	return str(HERO_CATALOG.definition_for(selected_shop_hero_id).get("name", "武将"))

func _shop_selected_item_id(section: String) -> String:
	match section:
		"heroes": return selected_shop_talent_id
		"strategies": return selected_shop_strategy_id
		"tianji": return selected_shop_tianji_id
		"souls": return selected_shop_soul_id
	return ""

func _set_shop_selected_item_id(section: String, item_id: String) -> void:
	selected_shop_item_id = item_id
	match section:
		"heroes": selected_shop_talent_id = item_id
		"strategies": selected_shop_strategy_id = item_id
		"tianji": selected_shop_tianji_id = item_id
		"souls": selected_shop_soul_id = item_id

func _shop_talent_node(talent_id: String) -> Dictionary:
	for branch_variant in _shop_talent_branches():
		var branch: Dictionary = branch_variant as Dictionary
		for node_variant in branch.get("nodes", []) as Array:
			var node: Dictionary = node_variant as Dictionary
			if str(node.get("id", "")) == talent_id:
				return node
	return {}

func _show_shop_item_detail(item_id: String) -> void:
	if page != "shop" or not is_instance_valid(shop_detail_body) or not shop_detail_body.is_inside_tree():
		return
	_set_shop_grid_selection(item_id)
	_set_shop_selected_item_id(shop_section, item_id)
	match shop_section:
		"heroes": _render_shop_talent_detail(item_id)
		"strategies": _render_shop_strategy_detail(item_id)
		"tianji": _render_shop_tianji_detail(item_id)
		"souls": _render_shop_soul_detail(item_id)
	queue_redraw()

func _render_shop_detail(category: String, title: String, description: String, rank: int, max_rank: int, status: String, action_title: String, action_callback: Callable, action_disabled: bool, icon_id: String, prerequisite_text: String = "") -> void:
	if not is_instance_valid(shop_detail_body):
		return
	for child in shop_detail_body.get_children():
		child.queue_free()
	var body_width := shop_detail_body.size.x
	var icon_frame := Control.new()
	icon_frame.position = Vector2((body_width - 54.0) * 0.5, 2.0)
	icon_frame.size = Vector2(54.0, 54.0)
	icon_frame.clip_contents = true
	icon_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop_detail_body.add_child(icon_frame)
	var icon := TextureRect.new()
	icon.texture = _shop_icon_texture(icon_id)
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_frame.add_child(icon)
	_shop_label(shop_detail_body, category, Vector2(0.0, 59.0), Vector2(body_width, 27.0), 16, Color("c8a96b"), HORIZONTAL_ALIGNMENT_CENTER, true)
	_shop_label(shop_detail_body, title, Vector2(0.0, 88.0), Vector2(body_width, 72.0), 20, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_CENTER, true)
	_shop_label(shop_detail_body, "当前等级  %d / %d" % [rank, max_rank], Vector2(0.0, 149.0), Vector2(body_width, 27.0), 16, Color("d1dfda"), HORIZONTAL_ALIGNMENT_CENTER)
	var divider := ColorRect.new()
	divider.position = Vector2(12.0, 169.0)
	divider.size = Vector2(body_width - 24.0, 1.0)
	divider.color = Color("8d7749", 0.54)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop_detail_body.add_child(divider)
	var description_top := 194.0
	var description_height := 150.0
	var status_top := 354.0
	if not prerequisite_text.is_empty():
		_shop_label(shop_detail_body, prerequisite_text, Vector2(6.0, 193.0), Vector2(body_width - 12.0, 40.0), 15, Color("c8a96b"), HORIZONTAL_ALIGNMENT_LEFT, true)
		description_top = 240.0
		description_height = 108.0
		status_top = 356.0
	_shop_label(shop_detail_body, description, Vector2(6.0, description_top), Vector2(body_width - 12.0, description_height), 17, Color("d5e2dd"), HORIZONTAL_ALIGNMENT_LEFT)
	_shop_label(shop_detail_body, status, Vector2(6.0, status_top), Vector2(body_width - 12.0, 64.0), 16, Color("f0c879"), HORIZONTAL_ALIGNMENT_LEFT, true)
	if not action_title.is_empty():
		var action := _create_button(action_title, "", Vector2(8.0, shop_detail_body.size.y - 60.0), action_callback, Vector2(body_width - 16.0, 46.0), action_disabled, 15, shop_detail_body, false)
		if action_disabled:
			_set_button_locked_visual(action)
		else:
			action.add_theme_stylebox_override("normal", _make_box_style(Color("4b3a1c"), GOLD_BRIGHT, 2))
			action.add_theme_stylebox_override("hover", _make_box_style(Color("70572a"), Color("fff0a8"), 3))

func _shop_detail_section(title: String, top: float, body_width: float) -> void:
	_shop_label(shop_detail_body, title, Vector2(6.0, top), Vector2(body_width - 12.0, 28.0), 17, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_LEFT, true)
	var divider := ColorRect.new()
	divider.position = Vector2(6.0, top + 23.0)
	divider.size = Vector2(body_width - 12.0, 1.0)
	divider.color = Color("8d7749", 0.62)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop_detail_body.add_child(divider)

func _shop_detail_text(text: String, at: Vector2, area_size: Vector2, font_size: int, color: Color) -> void:
	var scroll := ScrollContainer.new()
	scroll.position = at
	scroll.size = area_size
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = int(PAGE_SCROLL_DRAG_THRESHOLD)
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.gui_input.connect(_on_page_scroll_gui_input.bind(scroll))
	shop_detail_body.add_child(scroll)
	var content := RichTextLabel.new()
	content.text = text
	content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.fit_content = true
	content.scroll_active = false
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.custom_minimum_size.x = maxf(1.0, area_size.x - 14.0)
	content.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	content.add_theme_font_override("normal_font", KAITI_FONT)
	content.add_theme_font_size_override("normal_font_size", font_size)
	content.add_theme_color_override("default_color", color)
	content.add_theme_constant_override("line_separation", 3)
	scroll.add_child(content)

func _render_shop_sectioned_detail(category: String, title: String, description: String, rank: int, max_rank: int, cost_text: String, action_title: String, action_callback: Callable, action_disabled: bool, icon_id: String, prerequisite_text: String, prerequisite_heading: String = "前置战法", effect_heading: String = "技能效果", cost_heading: String = "升级消耗") -> void:
	if not is_instance_valid(shop_detail_body):
		return
	for child in shop_detail_body.get_children():
		child.queue_free()
	var body_width := shop_detail_body.size.x
	var body_height := shop_detail_body.size.y
	var icon_frame := Control.new()
	icon_frame.position = Vector2(4.0, 6.0)
	icon_frame.size = Vector2(44.0, 44.0)
	icon_frame.clip_contents = true
	icon_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop_detail_body.add_child(icon_frame)
	var icon := TextureRect.new()
	icon.texture = _shop_icon_texture(icon_id)
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_frame.add_child(icon)
	var resonance_detail := title == SOUL_RESONANCE.TITLE
	icon_frame.visible = not resonance_detail
	var heading_left := 4.0 if resonance_detail else 55.0
	var heading_width := maxf(1.0, body_width - heading_left - 4.0)
	_shop_label(shop_detail_body, category, Vector2(heading_left, 0.0), Vector2(heading_width, 23.0), 15 if resonance_detail else 16, Color("c8a96b"))
	_shop_label(shop_detail_body, title, Vector2(heading_left, 20.0), Vector2(heading_width, 56.0), 20, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_LEFT, true)
	var rank_text := "未激活 · 0 / 3" if resonance_detail and rank == 0 else "等级 %d / %d" % [rank, max_rank]
	_shop_label(shop_detail_body, rank_text, Vector2(heading_left, 80.0), Vector2(heading_width, 24.0), 15, Color("d1dfda"))
	if resonance_detail:
		var body_text := "%s\n%s\n\n%s\n%s\n\n%s\n%s" % [prerequisite_heading, prerequisite_text, effect_heading, description, cost_heading, cost_text]
		_shop_detail_text(body_text, Vector2(4.0, 112.0), Vector2(body_width - 8.0, maxf(1.0, body_height - 166.0)), 16, Color("d5e2dd"))
		_create_shop_texture_button(shop_detail_body, action_title, Vector2(5.0, body_height - 46.0), Vector2(body_width - 10.0, 40.0), action_callback, true, action_disabled)
		return
	_shop_detail_section(prerequisite_heading, 96.0, body_width)
	_shop_detail_text(prerequisite_text if not prerequisite_text.is_empty() else "无", Vector2(7.0, 128.0), Vector2(body_width - 14.0, 54.0), 16, Color("c8a96b"))
	_shop_detail_section(effect_heading, 188.0, body_width)
	var button_top := body_height - 46.0
	var cost_top := body_height - (134.0 if not action_title.is_empty() else 88.0)
	_shop_detail_text(description, Vector2(7.0, 220.0), Vector2(body_width - 14.0, maxf(1.0, cost_top - 228.0)), 17, Color("d5e2dd"))
	_shop_detail_section(cost_heading, cost_top, body_width)
	_shop_detail_text(cost_text, Vector2(7.0, cost_top + 31.0), Vector2(body_width - 14.0, 54.0), 16, Color("f0c879"))
	if not action_title.is_empty():
		_create_shop_texture_button(shop_detail_body, action_title, Vector2(5.0, button_top), Vector2(body_width - 10.0, 40.0), action_callback, true, action_disabled)

func _render_shop_talent_detail(talent_id: String) -> void:
	var node := _shop_talent_node(talent_id)
	var definition: Dictionary = UpgradeSystem.DEFINITIONS.get(talent_id, {}) as Dictionary
	if definition.is_empty():
		return
	var is_core := bool(node.get("is_core", false))
	var is_run_upgrade := bool(node.get("is_run_upgrade", false))
	var is_auto_unlock := UpgradeSystem.is_auto_unlock_talent(talent_id)
	var hero_owned := SaveService.has_hero(selected_shop_hero_id)
	var rank := SaveService.talent_rank(selected_shop_hero_id, talent_id)
	var max_rank := maxi(1, SaveService.talent_max_rank(selected_shop_hero_id, talent_id))
	if is_core and hero_owned:
		rank = max_rank
	var prerequisite_ok := is_core or SaveService.talent_prerequisite_satisfied_for_purchase(selected_shop_hero_id, talent_id)
	var cost := SaveService.talent_cost(selected_shop_hero_id, talent_id, int(node.get("cost", 0)))
	var action_disabled := is_core or is_run_upgrade or is_auto_unlock or not hero_owned or not prerequisite_ok or rank >= max_rank or cost <= 0
	var action_title := "" if is_core or is_run_upgrade or is_auto_unlock or rank >= max_rank else ("升级" if rank > 0 else "购买")
	var action := Callable(self, "_buy_shop_talent").bind(selected_shop_hero_id, talent_id, int(node.get("cost", 0)))
	var cost_text := "已满阶" if rank >= max_rank else ("下一阶：%d 军功" % cost)
	if is_auto_unlock:
		cost_text = "随前置战法自动解锁"
	elif not is_core and not is_run_upgrade and not hero_owned:
		cost_text += "\n需先招募%s" % _selected_shop_hero_name()
	elif not is_core and not is_run_upgrade and not prerequisite_ok:
		cost_text += "\n需先解锁前置战法"
	elif is_run_upgrade:
		cost_text = "战斗中获得\n解锁前置战法后出现"
	elif is_core:
		cost_text = "默认开放"
	var prerequisite_text := ""
	var prerequisite_id := str(definition.get("requires", ""))
	if not prerequisite_id.is_empty():
		var prerequisite_definition: Dictionary = UpgradeSystem.DEFINITIONS.get(prerequisite_id, {}) as Dictionary
		var prerequisite_title := str(prerequisite_definition.get("title", prerequisite_id))
		var prerequisite_rank := maxi(1, int(definition.get("requires_stacks", 1)))
		prerequisite_text = "%s · 至少 %d 阶" % [prerequisite_title, prerequisite_rank]
	_render_shop_sectioned_detail("%s · 战法" % _selected_shop_hero_name(), str(definition.get("title", talent_id)), str(definition.get("description", "")), rank, max_rank, cost_text, action_title, action, action_disabled, _shop_item_icon(talent_id, "talent"), prerequisite_text)
	talent_detail_dialog = shop_detail_panel
	if SaveService.tutorial_stage() == 3 and selected_shop_hero_id == "guan_yu" and talent_id == "guan_drag_blade":
		SaveService.set_tutorial_stage(4)
	elif SaveService.tutorial_stage() == 7 and selected_shop_hero_id == "zhang_fei" and talent_id == "zhang_slam_leap":
		SaveService.set_tutorial_stage(8)
	if SaveService.tutorial_stage() in [4, 5, 8, 9]:
		call_deferred("_tutorial_refresh")

func _render_shop_strategy_detail(strategy_id: String) -> void:
	var definition := MILITARY_STRATEGY.definition_for(strategy_id)
	if definition.is_empty():
		return
	var rank := SaveService.strategy_rank(strategy_id)
	var max_rank := MILITARY_STRATEGY.max_rank_for(strategy_id)
	var cost := SaveService.strategy_cost(strategy_id)
	var prerequisite_ok := MILITARY_STRATEGY.prerequisite_satisfied_for(profile, strategy_id)
	var action_disabled := rank >= max_rank or not prerequisite_ok or int(profile.get("military_merit", 0)) < cost
	var action_title := "" if rank >= max_rank else "研习"
	var cost_text := "已满阶" if rank >= max_rank else "下一阶：%d 军功" % cost
	if not prerequisite_ok:
		cost_text += "\n%s" % MILITARY_STRATEGY.prerequisite_requirement_text(profile, strategy_id)
	elif int(profile.get("military_merit", 0)) < cost:
		cost_text += "\n军功不足"
	var prerequisite_text := MILITARY_STRATEGY.prerequisite_requirement_text(profile, strategy_id)
	if prerequisite_text.is_empty():
		prerequisite_text = "无"
	var branch_id := MILITARY_STRATEGY.branch_for(strategy_id)
	var branch_title := branch_id
	for branch_variant in MILITARY_STRATEGY.BRANCHES:
		var branch: Dictionary = branch_variant as Dictionary
		if str(branch.get("id", "")) == branch_id:
			branch_title = str(branch.get("title", branch_id))
			break
	var action := Callable(self, "_buy_shop_strategy").bind(strategy_id)
	_render_shop_sectioned_detail("军略 · %s" % branch_title, str(definition.get("title", strategy_id)), str(definition.get("description", "")), rank, max_rank, cost_text, action_title, action, action_disabled, _shop_item_icon(strategy_id, "strategy"), prerequisite_text, "前置条件", "军略效果", "研习消耗")
	strategy_detail_dialog = shop_detail_panel

func _render_shop_tianji_detail(skill_id: String) -> void:
	var definition := TIANJI_CATALOG.definition_for(skill_id)
	if definition.is_empty():
		return
	var rank := SaveService.tianji_rank(skill_id)
	var max_rank := TIANJI_CATALOG.max_rank_for(skill_id)
	var cost := SaveService.tianji_cost(skill_id)
	var action_disabled := rank >= max_rank or int(profile.get("military_merit", 0)) < cost
	var action_title := "" if rank >= max_rank else ("解锁" if rank <= 0 else "升级")
	var cost_text := "已满阶" if rank >= max_rank else "下一阶：%d 军功" % cost
	if int(profile.get("military_merit", 0)) < cost and rank < max_rank:
		cost_text += "\n军功不足"
	var action := Callable(self, "_buy_shop_tianji").bind(skill_id)
	_render_shop_sectioned_detail(
		"天机阵法 · 战斗中启阵",
		str(definition.get("title", skill_id)),
		TIANJI_CATALOG.description_for(skill_id, rank),
		rank,
		max_rank,
		cost_text,
		action_title,
		action,
		action_disabled,
		_shop_item_icon(skill_id, "tianji"),
		"无",
		"前置条件",
		"阵法效果",
		"解锁消耗"
	)
	tianji_detail_dialog = shop_detail_panel

func _render_shop_resonance_detail() -> void:
	var rank := SOUL_RESONANCE.rank_for(profile)
	var cost := SOUL_RESONANCE.cost_for(profile)
	var unlocked := SOUL_RESONANCE.unfinished_for(profile).is_empty()
	var cost_text := "已满级" if rank >= 3 else "%s：%d 军功" % ["激活" if rank == 0 else "升级", cost]
	if not unlocked:
		cost_text += "\n五魂铭刻全部四级后开放"
	elif rank < 3 and int(profile.get("military_merit", 0)) < cost:
		cost_text += "\n军功不足"
	_render_shop_sectioned_detail("战魂阁 · 永久共鸣", SOUL_RESONANCE.TITLE, SOUL_RESONANCE.description_for(profile), rank, 3, cost_text, "满级" if rank >= 3 else ("激活" if rank == 0 else "升级"), Callable(self, "_buy_shop_resonance"), not SaveService.can_purchase_soul_resonance(), "group_blessing", SOUL_RESONANCE.prerequisite_text(profile), "激活条件", "共鸣效果", "共鸣消耗")
	battle_soul_detail_dialog = shop_detail_panel

func _buy_shop_resonance() -> void:
	SaveService.purchase_soul_resonance()
	_show_shop("souls")
	_set_shop_selected_item_id("souls", SOUL_RESONANCE.ID)
	_show_shop_item_detail(SOUL_RESONANCE.ID)

func _render_shop_soul_detail(armory_id: String) -> void:
	if armory_id == SOUL_RESONANCE.ID:
		_render_shop_resonance_detail()
		return
	var definition := BATTLE_SOUL_ARMORY.definition_for(armory_id)
	if definition.is_empty():
		return
	var rank := SaveService.battle_soul_armory_rank(armory_id)
	var max_rank := BATTLE_SOUL_ARMORY.max_rank_for(armory_id)
	var cost := SaveService.battle_soul_armory_cost(armory_id)
	var action_disabled := rank >= max_rank or int(profile.get("military_merit", 0)) < cost
	var action_title := "" if rank >= max_rank else ("铭刻" if rank <= 0 else "升级")
	var cost_text := "已满阶" if rank >= max_rank else "下一阶：%d 军功" % cost
	if int(profile.get("military_merit", 0)) < cost and rank < max_rank:
		cost_text += "\n军功不足"
	var action := Callable(self, "_buy_shop_soul").bind(armory_id)
	_render_shop_sectioned_detail(
		"战魂阁 · 战场掉落后生效",
		str(definition.get("title", armory_id)),
		BATTLE_SOUL_ARMORY.description_for(armory_id, rank),
		rank + 1,
		max_rank + 1,
		cost_text,
		action_title,
		action,
		action_disabled,
		_shop_item_icon(armory_id, "soul"),
		"无",
		"前置条件",
		"战魂效果",
		"铭刻消耗"
	)
	battle_soul_detail_dialog = shop_detail_panel

func _buy_shop_talent(hero_id: String, talent_id: String, fallback_cost: int) -> void:
	selected_shop_hero_id = hero_id
	_set_shop_selected_item_id("heroes", talent_id)
	var previous_rank := SaveService.talent_rank(hero_id, talent_id)
	var tutorial_purchase := (SaveService.tutorial_stage() == 5 and hero_id == "guan_yu" and talent_id == "guan_drag_blade") or (SaveService.tutorial_stage() == 9 and hero_id == "zhang_fei" and talent_id == "zhang_slam_leap")
	if tutorial_purchase and previous_rank <= 0:
		var required_cost := SaveService.talent_cost(hero_id, talent_id, fallback_cost)
		var current_merit := int(SaveService.load_profile().get("military_merit", 0))
		if current_merit < required_cost:
			SaveService.grant_military_merit(required_cost - current_merit)
	_buy_talent(hero_id, talent_id, fallback_cost)
	if SaveService.talent_rank(hero_id, talent_id) > previous_rank and SaveService.tutorial_stage() == 5 and talent_id == "guan_drag_blade":
		SaveService.set_tutorial_stage(6)
	if SaveService.talent_rank(hero_id, talent_id) > previous_rank and SaveService.tutorial_stage() == 9 and talent_id == "zhang_slam_leap":
		SaveService.set_tutorial_stage(10)

func _buy_shop_strategy(strategy_id: String) -> void:
	_set_shop_selected_item_id("strategies", strategy_id)
	_buy_strategy(strategy_id)

func _buy_shop_tianji(skill_id: String) -> void:
	_set_shop_selected_item_id("tianji", skill_id)
	_buy_tianji(skill_id)

func _buy_shop_soul(armory_id: String) -> void:
	_set_shop_selected_item_id("souls", armory_id)
	if SaveService.purchase_battle_soul_armory(armory_id):
		_show_shop("souls")
		notice = "%s 已完成铭刻" % BATTLE_SOUL_ARMORY.title_for(armory_id)
	else:
		_show_shop("souls")
		notice = "军功不足或该战魂已满阶"
	queue_redraw()

func _shop_hero() -> Dictionary:
	return HERO_CATALOG.definition_for(selected_shop_hero_id)

func _shop_talent_branches() -> Array:
	return _shop_hero().get("talent_tree", []) as Array

func _hero_tree_viewport_rect() -> Rect2:
	var top := 286.0
	var bottom := maxf(top + 180.0, size.y - 44.0)
	return Rect2(40.0, top, maxf(320.0, size.x - 80.0), bottom - top)

func _populate_hero_talent_tree() -> void:
	var viewport := _hero_tree_viewport_rect()
	var scroll := ScrollContainer.new()
	scroll.position = viewport.position
	scroll.size = viewport.size
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = int(HERO_TREE_SCROLL_DRAG_THRESHOLD)
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.tooltip_text = "纵向滚动查看完整战法路线"
	scroll.gui_input.connect(_on_hero_tree_scroll_gui_input.bind(scroll))
	add_child(scroll)
	page_controls.append(scroll)
	var content := Control.new()
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	var content_width := maxf(320.0, viewport.size.x - 18.0)
	content.size = Vector2(content_width, 1.0)
	content.custom_minimum_size = content.size
	scroll.add_child(content)
	var shop_hero := _shop_hero()
	var is_owned := SaveService.has_hero(selected_shop_hero_id)
	var unlock_cost := int(shop_hero.get("unlock_cost", 0))
	var can_afford_unlock := int(profile.get("military_merit", 0)) >= unlock_cost
	var root_status := "已开放" if is_owned else "尚未开放"
	var root_callback: Callable = Callable(self, "_show_shop_heroes")
	var root_button := _create_button(str(shop_hero.get("name", "武将")), root_status, HERO_TREE_ROOT_RECT.position, root_callback, HERO_TREE_ROOT_RECT.size, not is_owned, 13, content, false)
	root_button.z_index = 1
	if is_owned:
		root_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_button_owned_visual(root_button)
	else:
		_set_button_locked_visual(root_button)
	var branches := _shop_talent_branches()
	if branches.is_empty():
		_create_tree_label(content, "该武将的专属战法路线筹备中", Vector2(HERO_TREE_BRANCH_START_X, 108.0), Vector2(360.0, 28.0), 18, MUTED)
		content.custom_minimum_size = Vector2(content_width, 164.0)
		content.size = content.custom_minimum_size
		return
	var tree_color := Color("af9154") if is_owned else Color("58727d")
	var branch_cursor := 106.0
	var connector_ys: Array[float] = []
	for branch_variant in branches:
		var branch: Dictionary = branch_variant as Dictionary
		var branch_result := _add_hero_tree_branch(content, branch, branch_cursor, is_owned, tree_color)
		branch_cursor = float(branch_result.get("next_y", branch_cursor + 120.0))
		connector_ys.append(float(branch_result.get("connector_y", branch_cursor)))
	var spine_x := HERO_TREE_ROOT_RECT.get_center().x
	if not connector_ys.is_empty():
		_add_tree_line(content, [Vector2(spine_x, HERO_TREE_ROOT_RECT.end.y), Vector2(spine_x, connector_ys.back())], tree_color)
		for connector_y in connector_ys:
			_add_tree_line(content, [Vector2(spine_x, connector_y), Vector2(HERO_TREE_BRANCH_START_X, connector_y)], tree_color)
	content.custom_minimum_size = Vector2(content_width, branch_cursor + 18.0)
	content.size = content.custom_minimum_size

func _add_hero_tree_branch(content: Control, branch: Dictionary, branch_y: float, is_owned: bool, tree_color: Color) -> Dictionary:
	_create_tree_label(content, str(branch.get("title", "战法")), Vector2(HERO_TREE_BRANCH_START_X, branch_y), Vector2(HERO_TREE_NODE_SIZE.x, HERO_TREE_BRANCH_TITLE_HEIGHT), 18, GOLD_BRIGHT if is_owned else MUTED)
	var base_rect := Rect2(Vector2(HERO_TREE_BRANCH_START_X, branch_y + HERO_TREE_BRANCH_TITLE_HEIGHT), HERO_TREE_NODE_SIZE)
	var nodes: Array = branch.get("nodes", []) as Array
	var layouts: Array[Dictionary] = []
	var layout_by_id: Dictionary = {}
	var occupied_cells := {}
	var core_row := 0
	var free_row := 0
	var maximum_row := 0
	for node_variant in nodes:
		var node: Dictionary = node_variant as Dictionary
		var talent_id := str(node.get("id", ""))
		var definition: Dictionary = UpgradeSystem.DEFINITIONS.get(talent_id, {}) as Dictionary
		var prerequisite_id := str(definition.get("requires", ""))
		var column := 2
		var row := 0
		if bool(node.get("is_core", false)) and prerequisite_id.is_empty():
			column = 1
			row = core_row
			core_row += 1
		elif not prerequisite_id.is_empty() and layout_by_id.has(prerequisite_id):
			var parent_layout: Dictionary = layout_by_id[prerequisite_id] as Dictionary
			column = int(parent_layout.get("column", 2)) + 1
			row = int(parent_layout.get("row", 0))
		else:
			row = free_row
			free_row += 1
		while occupied_cells.has("%d,%d" % [column, row]):
			row += 1
		occupied_cells["%d,%d" % [column, row]] = true
		maximum_row = maxi(maximum_row, row)
		var node_rect := Rect2(
			Vector2(HERO_TREE_BRANCH_START_X + float(column) * (HERO_TREE_NODE_SIZE.x + HERO_TREE_NODE_GAP), branch_y + HERO_TREE_BRANCH_TITLE_HEIGHT + float(row) * (HERO_TREE_NODE_SIZE.y + HERO_TREE_NODE_GAP)),
			HERO_TREE_NODE_SIZE
		)
		var layout := {"node": node, "definition": definition, "id": talent_id, "requires": prerequisite_id, "column": column, "row": row, "rect": node_rect}
		layouts.append(layout)
		layout_by_id[talent_id] = layout
	for layout_variant in layouts:
		var layout: Dictionary = layout_variant as Dictionary
		var prerequisite_id := str(layout.get("requires", ""))
		var parent_rect := base_rect
		if not prerequisite_id.is_empty() and layout_by_id.has(prerequisite_id):
			var parent_layout: Dictionary = layout_by_id[prerequisite_id] as Dictionary
			parent_rect = parent_layout.get("rect", base_rect) as Rect2
		var child_rect := layout.get("rect", base_rect) as Rect2
		_add_tree_connector(content, Vector2(parent_rect.end.x, parent_rect.get_center().y), Vector2(child_rect.position.x, child_rect.get_center().y), tree_color)
	var base_button := _create_button(str(branch.get("core_title", "基础战法")), "默认开放", base_rect.position, _show_shop_heroes, base_rect.size, false, 11, content, false)
	base_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_owned:
		_set_button_owned_visual(base_button)
	else:
		_set_button_locked_visual(base_button)
	for layout_variant in layouts:
		_create_hero_tree_talent_button(content, layout_variant as Dictionary, is_owned)
	var section_bottom := base_rect.end.y
	for layout_variant in layouts:
		var layout: Dictionary = layout_variant as Dictionary
		var node_rect := layout.get("rect", base_rect) as Rect2
		section_bottom = maxf(section_bottom, node_rect.end.y)
	return {"next_y": section_bottom + HERO_TREE_BRANCH_BOTTOM_GAP, "connector_y": base_rect.get_center().y}

func _create_hero_tree_talent_button(content: Control, layout: Dictionary, is_owned: bool) -> void:
	var node: Dictionary = layout.get("node", {}) as Dictionary
	var definition: Dictionary = layout.get("definition", {}) as Dictionary
	var talent_id := str(layout.get("id", ""))
	var node_rect := layout.get("rect", Rect2()) as Rect2
	var is_core := bool(node.get("is_core", false))
	var is_run_upgrade := bool(node.get("is_run_upgrade", false))
	var is_auto_unlock := UpgradeSystem.is_auto_unlock_talent(talent_id)
	if is_core or is_run_upgrade or is_auto_unlock:
		var core_button := _create_button(str(definition.get("title", talent_id)), _talent_tree_summary(node, selected_shop_hero_id, talent_id), node_rect.position, Callable(self, "_show_talent_detail").bind(selected_shop_hero_id, talent_id, 0, is_core, is_run_upgrade), node_rect.size, false, 11, content, false)
		core_button.tooltip_text = "随前置战法自动解锁\n%s" % str(definition.get("description", "")) if is_auto_unlock else str(definition.get("description", ""))
		if is_owned or is_core:
			_set_button_owned_visual(core_button)
		else:
			_set_button_locked_visual(core_button)
		return
	var rank := SaveService.talent_rank(selected_shop_hero_id, talent_id)
	var talent_button := _create_button(str(definition.get("title", talent_id)), _talent_tree_summary(node, selected_shop_hero_id, talent_id), node_rect.position, Callable(self, "_show_talent_detail").bind(selected_shop_hero_id, talent_id, int(node.get("cost", 0)), false), node_rect.size, false, 11, content, false)
	talent_button.tooltip_text = str(definition.get("description", ""))
	if rank > 0:
		_set_button_owned_visual(talent_button)
	else:
		_set_button_locked_visual(talent_button)

func _talent_tree_summary(node: Dictionary, hero_id: String = "", talent_id: String = "") -> String:
	if bool(node.get("is_run_upgrade", false)):
		var run_summary := str(node.get("summary", ""))
		return run_summary.left(6) if run_summary.length() > 6 else run_summary
	if not bool(node.get("is_core", false)) and not hero_id.is_empty() and not talent_id.is_empty():
		var rank := SaveService.talent_rank(hero_id, talent_id)
		var max_rank := SaveService.talent_max_rank(hero_id, talent_id)
		if rank >= max_rank:
			return "已满阶"
		var cost := SaveService.talent_cost(hero_id, talent_id, int(node.get("cost", 0)))
		return "升级 %d" % cost if rank > 0 else "解锁 %d" % cost
	var summary := str(node.get("summary", ""))
	return summary.left(6) if summary.length() > 6 else summary

func _show_talent_detail(hero_id: String, talent_id: String, cost: int, is_core: bool = false, is_run_upgrade: bool = false) -> void:
	if page != "shop" or shop_section != "heroes":
		return
	_close_talent_detail()
	_clear_tutorial_overlay()
	if SaveService.tutorial_stage() == 3 and hero_id == "guan_yu" and talent_id == "guan_drag_blade":
		SaveService.set_tutorial_stage(4)
	elif SaveService.tutorial_stage() == 7 and hero_id == "zhang_fei" and talent_id == "zhang_slam_leap":
		SaveService.set_tutorial_stage(8)
	var definition: Dictionary = UpgradeSystem.DEFINITIONS.get(talent_id, {}) as Dictionary
	if definition.is_empty():
		return
	var hero_owned := SaveService.has_hero(hero_id)
	var rank := SaveService.talent_rank(hero_id, talent_id)
	var max_rank := SaveService.talent_max_rank(hero_id, talent_id)
	var maxed := rank >= max_rank
	var next_cost := SaveService.talent_cost(hero_id, talent_id, cost)
	var prerequisite_id := str(definition.get("requires", ""))
	var is_auto_unlock := UpgradeSystem.is_auto_unlock_talent(talent_id)
	var prerequisite_unlocked := SaveService.talent_prerequisite_satisfied_for_purchase(hero_id, talent_id)
	var prerequisite_rank := maxi(1, int(definition.get("requires_stacks", 1)))
	var overlay := ColorRect.new()
	overlay.color = Color(0.01, 0.02, 0.03, 0.76)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 40
	add_child(overlay)
	page_controls.append(overlay)
	talent_detail_dialog = overlay
	var dialog_size := Vector2(minf(620.0, maxf(320.0, size.x - 40.0)), minf(430.0, maxf(360.0, size.y - 40.0)))
	var dialog := Panel.new()
	dialog.position = (size - dialog_size) * 0.5
	dialog.size = dialog_size
	dialog.add_theme_stylebox_override("panel", UITheme.panel_style())
	dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dialog)
	var content_width := dialog_size.x - 48.0
	var category_label := Label.new()
	category_label.text = "%s · %s" % [str(HERO_CATALOG.definition_for(hero_id).get("name", "武将")), str(definition.get("category", "战法"))]
	category_label.position = Vector2(24.0, 20.0)
	category_label.size = Vector2(content_width, 24.0)
	category_label.add_theme_font_size_override("font_size", 16)
	category_label.add_theme_color_override("font_color", GOLD)
	category_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(category_label)
	var title_label := Label.new()
	title_label.text = str(definition.get("title", talent_id))
	title_label.position = Vector2(24.0, 48.0)
	title_label.size = Vector2(content_width, 38.0)
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.add_theme_color_override("font_color", GOLD_BRIGHT)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(title_label)
	var description_label := RichTextLabel.new()
	description_label.bbcode_enabled = false
	description_label.text = str(definition.get("description", ""))
	description_label.position = Vector2(24.0, 104.0)
	description_label.size = Vector2(content_width, dialog_size.y - 220.0)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.fit_content = false
	description_label.scroll_active = true
	description_label.scroll_following = false
	description_label.add_theme_font_size_override("font_size", 19)
	description_label.add_theme_color_override("font_color", Color("d8e6e2"))
	description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(description_label)
	var status_label := Label.new()
	status_label.position = Vector2(24.0, dialog_size.y - 106.0)
	status_label.size = Vector2(content_width, 24.0)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var purchase_disabled := is_core or is_run_upgrade or is_auto_unlock or maxed or not hero_owned or not prerequisite_unlocked or next_cost <= 0
	if is_core:
		status_label.text = "默认开放"
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	elif is_auto_unlock:
		status_label.text = "随前置战法自动解锁"
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	elif is_run_upgrade:
		status_label.text = "解锁前置战法后，在战斗中的升级选择技能中获得"
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	elif maxed:
		status_label.text = "已满阶  %d / %d" % [rank, max_rank]
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	elif not hero_owned:
		status_label.text = "需先招募该武将"
		status_label.add_theme_color_override("font_color", MUTED)
	elif not prerequisite_unlocked:
		var prerequisite: Dictionary = UpgradeSystem.DEFINITIONS.get(prerequisite_id, {}) as Dictionary
		var prerequisite_label := str(prerequisite.get("title", prerequisite_id))
		status_label.text = "前置满阶：%s" % prerequisite_label if prerequisite_rank > 1 else "前置：%s" % prerequisite_label
		status_label.add_theme_color_override("font_color", Color("f1bd73"))
	else:
		status_label.text = "当前阶数  %d / %d · 下一阶消耗 %d 军功" % [rank, max_rank, next_cost]
		status_label.add_theme_color_override("font_color", GOLD_BRIGHT)
	dialog.add_child(status_label)
	var action_y := dialog_size.y - 62.0
	var purchase_title := "默认开放" if is_core else ("自动解锁" if is_auto_unlock else ("局内获取" if is_run_upgrade else ("已满阶" if maxed else ("升级 · %d 军功" % next_cost if rank > 0 else "购买 · %d 军功" % next_cost))))
	var purchase_button := _create_button(purchase_title, "", Vector2(24.0, action_y), Callable(self, "_buy_talent_from_detail").bind(hero_id, talent_id, cost), Vector2((content_width - 12.0) * 0.5, 44.0), purchase_disabled, 16, dialog, false)
	if purchase_disabled:
		_set_button_locked_visual(purchase_button)
	var close_button := _create_button("取消", "", Vector2(36.0 + (content_width - 12.0) * 0.5, action_y), _close_talent_detail, Vector2((content_width - 12.0) * 0.5, 44.0), false, 16, dialog, false)
	close_button.add_theme_stylebox_override("normal", _make_box_style(Color("17242a"), DRAGON_BLUE, 2))
	close_button.add_theme_stylebox_override("hover", _make_box_style(Color("20343c"), DRAGON_BLUE, 3))
	if SaveService.tutorial_stage() == 5 and hero_id == "guan_yu" and talent_id == "guan_drag_blade":
		_tutorial_show_for_control(purchase_button, TUTORIAL_HINTS[5])
	elif SaveService.tutorial_stage() == 9 and hero_id == "zhang_fei" and talent_id == "zhang_slam_leap":
		_tutorial_show_for_control(purchase_button, TUTORIAL_HINTS[9])
	if SaveService.tutorial_stage() in [4, 5, 8, 9]:
		_tutorial_refresh()

func _buy_talent_from_detail(hero_id: String, talent_id: String, cost: int) -> void:
	var previous_rank := SaveService.talent_rank(hero_id, talent_id)
	var tutorial_purchase := (SaveService.tutorial_stage() == 5 and hero_id == "guan_yu" and talent_id == "guan_drag_blade") or (SaveService.tutorial_stage() == 9 and hero_id == "zhang_fei" and talent_id == "zhang_slam_leap")
	if tutorial_purchase and previous_rank <= 0:
		var required_cost := SaveService.talent_cost(hero_id, talent_id, cost)
		var current_merit := int(SaveService.load_profile().get("military_merit", 0))
		if current_merit < required_cost:
			SaveService.grant_military_merit(required_cost - current_merit)
	_buy_talent(hero_id, talent_id, cost)
	var purchased := SaveService.talent_rank(hero_id, talent_id) > previous_rank
	if purchased and SaveService.tutorial_stage() == 5 and talent_id == "guan_drag_blade":
		SaveService.set_tutorial_stage(6)
		_show_shop("heroes")
		return
	if purchased and SaveService.tutorial_stage() == 9 and talent_id == "zhang_slam_leap":
		SaveService.set_tutorial_stage(10)
		_show_shop("heroes")
		return
	# _buy_talent rebuilds the page; reopen the same detail so the player can
	# continue comparing ranks without losing their place in the tree.
	_show_talent_detail(hero_id, talent_id, cost, false, false)

func _close_talent_detail() -> void:
	if not is_instance_valid(talent_detail_dialog):
		talent_detail_dialog = null
		return
	page_controls.erase(talent_detail_dialog)
	talent_detail_dialog.queue_free()
	talent_detail_dialog = null

func _show_strategy_detail(strategy_id: String, feedback: String = "") -> void:
	if page != "shop" or shop_section != "strategies":
		return
	_close_strategy_detail()
	var definition := MILITARY_STRATEGY.definition_for(strategy_id)
	if definition.is_empty():
		return
	var current_profile := SaveService.load_profile()
	profile = current_profile
	var rank := SaveService.strategy_rank(strategy_id)
	var max_rank := int(definition.get("max_rank", 0))
	var maxed := rank >= max_rank
	var cost := SaveService.strategy_cost(strategy_id)
	var current_merit := int(current_profile.get("military_merit", 0))
	var prerequisite_unlocked := MILITARY_STRATEGY.prerequisite_satisfied_for(current_profile, strategy_id)
	var prerequisite_requirement := MILITARY_STRATEGY.prerequisite_requirement_text(current_profile, strategy_id)
	var branch_title := "军略"
	var branch_id := str(definition.get("branch", ""))
	for branch_variant in MILITARY_STRATEGY.BRANCHES:
		var branch: Dictionary = branch_variant as Dictionary
		if str(branch.get("id", "")) == branch_id:
			branch_title = str(branch.get("title", branch_title))
			break
	var overlay := ColorRect.new()
	overlay.color = Color(0.01, 0.02, 0.03, 0.76)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 40
	add_child(overlay)
	page_controls.append(overlay)
	strategy_detail_dialog = overlay
	strategy_detail_notice = feedback
	var dialog_size := Vector2(minf(620.0, maxf(320.0, size.x - 40.0)), minf(438.0, maxf(366.0, size.y - 40.0)))
	var dialog := Panel.new()
	dialog.position = (size - dialog_size) * 0.5
	dialog.size = dialog_size
	dialog.add_theme_stylebox_override("panel", UITheme.panel_style())
	dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dialog)
	var content_width := dialog_size.x - 48.0
	var category_label := Label.new()
	category_label.text = "%s · 全英雄永久生效" % branch_title
	category_label.position = Vector2(24.0, 20.0)
	category_label.size = Vector2(content_width, 24.0)
	category_label.add_theme_font_size_override("font_size", 16)
	category_label.add_theme_color_override("font_color", GOLD)
	category_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(category_label)
	var title_label := Label.new()
	title_label.text = str(definition.get("title", strategy_id))
	title_label.position = Vector2(24.0, 48.0)
	title_label.size = Vector2(content_width, 38.0)
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.add_theme_color_override("font_color", GOLD_BRIGHT)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(title_label)
	var description_label := RichTextLabel.new()
	description_label.bbcode_enabled = false
	description_label.text = str(definition.get("description", ""))
	description_label.position = Vector2(24.0, 104.0)
	description_label.size = Vector2(content_width, 92.0)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.fit_content = false
	description_label.scroll_active = true
	description_label.scroll_following = false
	description_label.add_theme_font_size_override("font_size", 19)
	description_label.add_theme_color_override("font_color", Color("d8e6e2"))
	description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(description_label)
	var rank_label := Label.new()
	rank_label.text = "当前阶数  %d / %d" % [rank, max_rank]
	rank_label.position = Vector2(24.0, 210.0)
	rank_label.size = Vector2(content_width, 24.0)
	rank_label.add_theme_font_size_override("font_size", 17)
	rank_label.add_theme_color_override("font_color", Color("cfe1dd"))
	rank_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(rank_label)
	var merit_label := Label.new()
	merit_label.text = "现有军功  %d" % current_merit
	merit_label.position = Vector2(24.0, 240.0)
	merit_label.size = Vector2(content_width, 24.0)
	merit_label.add_theme_font_size_override("font_size", 17)
	merit_label.add_theme_color_override("font_color", GOLD_BRIGHT)
	merit_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(merit_label)
	var status_label := Label.new()
	status_label.position = Vector2(24.0, 274.0)
	status_label.size = Vector2(content_width, 24.0)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not feedback.is_empty():
		status_label.text = feedback
		status_label.add_theme_color_override("font_color", Color("e67363"))
	elif not prerequisite_unlocked:
		status_label.text = prerequisite_requirement
		status_label.add_theme_color_override("font_color", Color("f1bd73"))
	elif maxed:
		status_label.text = "该军略已满阶"
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	else:
		status_label.text = "下一阶消耗  %d 军功" % cost
		status_label.add_theme_color_override("font_color", Color("f1bd73") if current_merit < cost else Color("9ee0c6"))
	dialog.add_child(status_label)
	var action_y := dialog_size.y - 62.0
	var action_width := (content_width - 12.0) * 0.5
	var purchase_title := "已满阶" if maxed else ("需先满足前置" if not prerequisite_unlocked else "研习 · %d 军功" % cost)
	var purchase_disabled := maxed or not prerequisite_unlocked or current_merit < cost
	var purchase_button := _create_button(purchase_title, "", Vector2(24.0, action_y), Callable(self, "_buy_strategy_from_detail").bind(strategy_id), Vector2(action_width, 44.0), purchase_disabled, 16, dialog, false)
	if purchase_disabled:
		_set_button_locked_visual(purchase_button)
	var close_button := _create_button("取消", "", Vector2(36.0 + action_width, action_y), _close_strategy_detail, Vector2(action_width, 44.0), false, 16, dialog, false)
	close_button.add_theme_stylebox_override("normal", _make_box_style(Color("17242a"), DRAGON_BLUE, 2))
	close_button.add_theme_stylebox_override("hover", _make_box_style(Color("20343c"), DRAGON_BLUE, 3))

func _buy_strategy_from_detail(strategy_id: String) -> void:
	var current_profile := SaveService.load_profile()
	profile = current_profile
	var rank := SaveService.strategy_rank(strategy_id)
	var max_rank := MILITARY_STRATEGY.max_rank_for(strategy_id)
	if rank >= max_rank:
		_show_strategy_detail(strategy_id, "该军略已满阶")
		return
	if not MILITARY_STRATEGY.prerequisite_satisfied_for(current_profile, strategy_id):
		_show_strategy_detail(strategy_id, MILITARY_STRATEGY.prerequisite_requirement_text(current_profile, strategy_id))
		return
	var cost := SaveService.strategy_cost(strategy_id)
	if int(current_profile.get("military_merit", 0)) < cost:
		_show_strategy_detail(strategy_id, "军功不足")
		return
	_buy_strategy(strategy_id)
	_show_strategy_detail(strategy_id)

func _close_strategy_detail() -> void:
	strategy_detail_notice = ""
	if not is_instance_valid(strategy_detail_dialog):
		strategy_detail_dialog = null
		return
	page_controls.erase(strategy_detail_dialog)
	strategy_detail_dialog.queue_free()
	strategy_detail_dialog = null

func _create_tree_label(parent: Control, text: String, at: Vector2, label_size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at
	label.size = label_size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 1
	parent.add_child(label)
	return label

func _add_tree_connector(parent: Control, start: Vector2, finish: Vector2, color: Color) -> void:
	var middle_x := start.x + maxf(10.0, (finish.x - start.x) * 0.45)
	_add_tree_line(parent, [start, Vector2(middle_x, start.y), Vector2(middle_x, finish.y), finish], color)

func _add_tree_line(parent: Control, points: Array[Vector2], color: Color) -> void:
	if points.size() < 2:
		return
	var line_points := PackedVector2Array()
	for point in points:
		line_points.append(point)
	var line := Line2D.new()
	line.points = line_points
	line.width = 2.0
	line.default_color = color
	line.antialiased = true
	line.z_index = 0
	parent.add_child(line)

func _on_hero_tree_scroll_gui_input(event: InputEvent, scroll: ScrollContainer) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			hero_tree_touch_index = event.index
			hero_tree_drag_start = event.position
			hero_tree_drag_scroll_start = scroll.scroll_vertical
			hero_tree_dragging = false
		elif event.index == hero_tree_touch_index:
			if hero_tree_dragging:
				scroll.accept_event()
			hero_tree_touch_index = -1
			hero_tree_dragging = false
		return
	if event is InputEventScreenDrag and event.index == hero_tree_touch_index:
		if _update_hero_tree_scroll(scroll, event.position):
			scroll.accept_event()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			hero_tree_mouse_dragging = true
			hero_tree_drag_start = event.position
			hero_tree_drag_scroll_start = scroll.scroll_vertical
			hero_tree_dragging = false
		elif hero_tree_mouse_dragging:
			if hero_tree_dragging:
				scroll.accept_event()
			hero_tree_mouse_dragging = false
			hero_tree_dragging = false
		return
	if event is InputEventMouseMotion and hero_tree_mouse_dragging:
		if _update_hero_tree_scroll(scroll, event.position):
			scroll.accept_event()

func _update_hero_tree_scroll(scroll: ScrollContainer, pointer_position: Vector2) -> bool:
	var delta_y := pointer_position.y - hero_tree_drag_start.y
	if not hero_tree_dragging and absf(delta_y) < HERO_TREE_SCROLL_DRAG_THRESHOLD:
		return false
	hero_tree_dragging = true
	var bar := scroll.get_v_scroll_bar()
	var target_scroll := clampf(float(hero_tree_drag_scroll_start) - delta_y, bar.min_value, bar.max_value)
	scroll.scroll_vertical = int(round(target_scroll))
	return true

func _select_shop_hero(hero_id: String) -> void:
	if not RELEASE_HERO_IDS.has(hero_id):
		return
	selected_shop_hero_id = hero_id
	if SaveService.tutorial_stage() == 6 and hero_id == "zhang_fei":
		SaveService.set_tutorial_stage(7)
	_show_shop("heroes")

func _populate_strategy_shop(restore_scroll: int = 0) -> void:
	var items: Array[Dictionary] = []
	var all_route_ids: Dictionary = {}
	var branch_index := 0
	for branch_variant in MILITARY_STRATEGY.BRANCHES:
		var branch: Dictionary = branch_variant as Dictionary
		for strategy_variant in branch.get("nodes", []) as Array:
			var strategy_id := str(strategy_variant)
			var definition := MILITARY_STRATEGY.definition_for(strategy_id)
			if definition.is_empty():
				continue
			var rank := SaveService.strategy_rank(strategy_id)
			var max_rank := MILITARY_STRATEGY.max_rank_for(strategy_id)
			var prerequisite_id := MILITARY_STRATEGY.prerequisite_for(strategy_id)
			var prerequisite_ok := MILITARY_STRATEGY.prerequisite_satisfied_for(profile, strategy_id)
			items.append({
				"id": strategy_id,
				"title": str(definition.get("title", strategy_id)),
				"description": str(definition.get("description", "")),
				"summary": str(definition.get("card_summary", definition.get("description", ""))),
				"branch_index": branch_index,
				"branch_title": str(branch.get("title", "军略路线")),
				"rank": rank,
				"max_rank": max_rank,
				"cost": SaveService.strategy_cost(strategy_id),
				"icon": _shop_item_icon(strategy_id, "strategy"),
				"locked": not prerequisite_ok,
				"prerequisite_id": prerequisite_id,
				"prerequisite_rank": 1,
				"prerequisite_text": MILITARY_STRATEGY.prerequisite_requirement_text(profile, strategy_id),
				"route_kind": "strategy",
			})
			all_route_ids[strategy_id] = branch_index
		branch_index += 1
	for item in items:
		var prerequisite_id := str(item.get("prerequisite_id", ""))
		if prerequisite_id.is_empty():
			item["missing_prerequisite"] = false
			item["prerequisite_in_other_branch"] = false
			continue
		var prerequisite_exists := all_route_ids.has(prerequisite_id)
		item["missing_prerequisite"] = not prerequisite_exists
		item["prerequisite_in_other_branch"] = prerequisite_exists and int(all_route_ids[prerequisite_id]) != int(item.get("branch_index", -1))
	if items.is_empty():
		_render_shop_detail("军略", "暂未开放", "该商城模块暂未配置可用军略。", 0, 0, "敬请期待", "", Callable(), true, "crossed_swords")
		return
	var selected_id := _shop_selected_item_id("strategies")
	var first_id := str(items[0].get("id", ""))
	var selected_exists := false
	for item in items:
		if str(item.get("id", "")) == selected_id:
			selected_exists = true
			break
	if not selected_exists:
		selected_id = first_id
	_set_shop_selected_item_id("strategies", selected_id)
	var viewport := Rect2(Vector2(20.0, 24.0), Vector2(shop_center_panel.size.x - 40.0, shop_center_panel.size.y - 48.0))
	_create_shop_talent_route(items, viewport)
	_show_shop_item_detail(selected_id)

func _populate_shop_category_icons(items: Array[Dictionary], restore_scroll: int, tooltip: String) -> void:
	if items.is_empty():
		_render_shop_detail(str(SHOP_SECTION_LABELS.get(shop_section, "军需")), "暂无项目", "该商城模块暂未配置可用项目。", 0, 0, "敬请期待", "", Callable(), true, "crossed_swords")
		return
	if shop_section in ["tianji", "souls"]:
		_create_shop_altar_nodes(items, tooltip)
	else:
		var viewport := Rect2(20.0, 24.0, shop_center_panel.size.x - 40.0, shop_center_panel.size.y - 48.0)
		_create_shop_icon_grid(items, viewport, restore_scroll, tooltip)
	var first_id := str(items[0].get("id", ""))
	var selected_id := _shop_selected_item_id(shop_section)
	if selected_id.is_empty():
		selected_id = first_id
	var found := false
	for item in items:
		if str(item.get("id", "")) == selected_id:
			found = true
			break
	if not found:
		selected_id = first_id
	_set_shop_selected_item_id(shop_section, selected_id)
	_show_shop_item_detail(selected_id)

func _strategy_branch_for_id(branch_id: String) -> Dictionary:
	for branch_variant in MILITARY_STRATEGY.BRANCHES:
		var branch: Dictionary = branch_variant as Dictionary
		if str(branch.get("id", "")) == branch_id:
			return branch
	return {}

func _populate_battle_soul_shop(restore_scroll: int = 0) -> void:
	var items: Array[Dictionary] = []
	for armory_id in BATTLE_SOUL_ARMORY.DISPLAY_ORDER:
		var definition := BATTLE_SOUL_ARMORY.definition_for(armory_id)
		if definition.is_empty():
			continue
		items.append({
			"id": armory_id,
			"title": str(definition.get("title", armory_id)),
			"description": str(definition.get("description", "")),
			"rank": SaveService.battle_soul_armory_rank(armory_id),
			"max_rank": BATTLE_SOUL_ARMORY.max_rank_for(armory_id),
			"cost": SaveService.battle_soul_armory_cost(armory_id),
			"icon": _shop_item_icon(armory_id, "soul"),
			"locked": false,
		})
	items.append({
		"id": SOUL_RESONANCE.ID, "title": SOUL_RESONANCE.TITLE,
		"description": SOUL_RESONANCE.DESCRIPTION,
		"rank": SOUL_RESONANCE.rank_for(profile), "max_rank": 3,
		"icon": "res://assets/art/battle_souls/wuhun.png", "locked": not SOUL_RESONANCE.unfinished_for(profile).is_empty(),
	})
	_populate_shop_category_icons(items, restore_scroll, "战场掉落 · 接触后生效 %d 秒" % int(SOUL_RESONANCE.effects_for(profile).buff_duration))

func _create_battle_soul_card(armory_id: String, definition: Dictionary, rank: int, max_rank: int, cost: int, affordable: bool, at: Vector2, card_size: Vector2, parent: Control) -> Button:
	var accent: Color = definition.get("color", GOLD) as Color
	var card := _create_button("", "", at, Callable(self, "_show_battle_soul_detail").bind(armory_id), card_size, false, 16, parent, false)
	card.tooltip_text = "点击查看铭刻详情"
	card.add_theme_stylebox_override("normal", _make_box_style(Color("111d21"), accent.darkened(0.14), 2))
	card.add_theme_stylebox_override("hover", _make_box_style(Color("1a2b2f"), accent.lightened(0.22), 3))
	var icon_label := Label.new()
	icon_label.text = str(definition.get("icon", "魂"))
	icon_label.position = Vector2(16.0, 16.0)
	icon_label.size = Vector2(50.0, 50.0)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 27)
	icon_label.add_theme_color_override("font_color", accent.lightened(0.12))
	icon_label.add_theme_stylebox_override("normal", _make_box_style(Color(accent, 0.14), accent, 1))
	icon_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(icon_label)
	var title_label := Label.new()
	title_label.text = str(definition.get("title", armory_id))
	title_label.position = Vector2(80.0, 14.0)
	title_label.size = Vector2(card_size.x - 164.0, 28.0)
	title_label.add_theme_font_size_override("font_size", 21)
	title_label.add_theme_color_override("font_color", GOLD_BRIGHT)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(title_label)
	var rank_label := Label.new()
	rank_label.text = "%d / %d 阶" % [rank + 1, max_rank + 1]
	rank_label.position = Vector2(card_size.x - 76.0, 20.0)
	rank_label.size = Vector2(60.0, 20.0)
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	rank_label.add_theme_font_size_override("font_size", 14)
	rank_label.add_theme_color_override("font_color", accent.lightened(0.20))
	rank_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(rank_label)
	var rule_label := Label.new()
	rule_label.text = "战场掉落 · 接触后生效 %d 秒" % int(SOUL_RESONANCE.effects_for(profile).buff_duration)
	rule_label.position = Vector2(80.0, 45.0)
	rule_label.size = Vector2(card_size.x - 96.0, 18.0)
	rule_label.add_theme_font_size_override("font_size", 13)
	rule_label.add_theme_color_override("font_color", Color("9eb5b5"))
	rule_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(rule_label)
	var summary_label := Label.new()
	summary_label.text = str(definition.get("card_summary", ""))
	summary_label.position = Vector2(16.0, 80.0)
	summary_label.size = Vector2(card_size.x - 32.0, 44.0)
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.add_theme_font_size_override("font_size", 14)
	summary_label.add_theme_color_override("font_color", accent.lightened(0.12))
	summary_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(summary_label)
	var effect_label := Label.new()
	effect_label.text = BATTLE_SOUL_ARMORY.effect_summary_for(armory_id, rank)
	effect_label.position = Vector2(16.0, 128.0)
	effect_label.size = Vector2(card_size.x - 32.0, 72.0)
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect_label.add_theme_font_size_override("font_size", 13)
	effect_label.add_theme_color_override("font_color", Color("d2e2dc"))
	effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(effect_label)
	var action_label := Label.new()
	action_label.text = "已满阶" if rank >= max_rank else ("铭刻 · %d 军功" % cost if affordable else "还差 %d 军功" % (cost - int(profile.get("military_merit", 0))))
	action_label.position = Vector2(16.0, card_size.y - 30.0)
	action_label.size = Vector2(card_size.x - 32.0, 18.0)
	action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	action_label.add_theme_font_size_override("font_size", 14)
	action_label.add_theme_color_override("font_color", Color("9ee0c6") if rank >= max_rank or affordable else Color("e67363"))
	action_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(action_label)
	return card

func _show_battle_soul_detail(armory_id: String, feedback: String = "") -> void:
	if page != "shop" or shop_section != "souls":
		return
	_close_battle_soul_detail()
	var definition := BATTLE_SOUL_ARMORY.definition_for(armory_id)
	if definition.is_empty():
		return
	var current_profile := SaveService.load_profile()
	profile = current_profile
	var rank := SaveService.battle_soul_armory_rank(armory_id)
	var max_rank := BATTLE_SOUL_ARMORY.max_rank_for(armory_id)
	var maxed := rank >= max_rank
	var cost := SaveService.battle_soul_armory_cost(armory_id)
	var current_merit := int(current_profile.get("military_merit", 0))
	var can_afford := current_merit >= cost
	var overlay := ColorRect.new()
	overlay.color = Color(0.01, 0.02, 0.03, 0.78)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 40
	add_child(overlay)
	page_controls.append(overlay)
	battle_soul_detail_dialog = overlay
	var dialog_size := Vector2(minf(640.0, maxf(320.0, size.x - 40.0)), minf(460.0, maxf(388.0, size.y - 40.0)))
	var dialog := Panel.new()
	dialog.position = (size - dialog_size) * 0.5
	dialog.size = dialog_size
	dialog.add_theme_stylebox_override("panel", UITheme.panel_style())
	dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dialog)
	var content_width := dialog_size.x - 48.0
	var accent: Color = definition.get("color", GOLD) as Color
	var category_label := Label.new()
	category_label.text = "战魂阁 · 战场掉落后临时生效"
	category_label.position = Vector2(24.0, 20.0)
	category_label.size = Vector2(content_width, 24.0)
	category_label.add_theme_font_size_override("font_size", 16)
	category_label.add_theme_color_override("font_color", accent)
	category_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(category_label)
	var title_label := Label.new()
	title_label.text = "%s  ·  %s" % [str(definition.get("icon", "魂")), str(definition.get("title", armory_id))]
	title_label.position = Vector2(24.0, 50.0)
	title_label.size = Vector2(content_width, 38.0)
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.add_theme_color_override("font_color", GOLD_BRIGHT)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(title_label)
	var description_label := Label.new()
	var soul_timing := SOUL_RESONANCE.effects_for(profile)
	description_label.text = "%s\n战场内每 %s 秒随机掉落；走到掉落位置后生效 %d 秒。" % [str(definition.get("description", "")), str(soul_timing.drop_interval), int(soul_timing.buff_duration)]
	description_label.position = Vector2(24.0, 102.0)
	description_label.size = Vector2(content_width, 72.0)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 16)
	description_label.add_theme_color_override("font_color", Color("d8e6e2"))
	description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(description_label)
	var rank_label := Label.new()
	rank_label.text = "当前铭刻  %d / %d 阶" % [rank + 1, max_rank + 1]
	rank_label.position = Vector2(24.0, 194.0)
	rank_label.size = Vector2(content_width, 24.0)
	rank_label.add_theme_font_size_override("font_size", 17)
	rank_label.add_theme_color_override("font_color", Color("cfe1dd"))
	rank_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(rank_label)
	var effect_label := Label.new()
	effect_label.text = BATTLE_SOUL_ARMORY.effect_summary_for(armory_id, rank)
	effect_label.position = Vector2(24.0, 228.0)
	effect_label.size = Vector2(content_width, 84.0)
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect_label.add_theme_font_size_override("font_size", 17)
	effect_label.add_theme_color_override("font_color", accent.lightened(0.14))
	effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(effect_label)
	var merit_label := Label.new()
	merit_label.text = "现有军功  %d" % current_merit
	merit_label.position = Vector2(24.0, 306.0)
	merit_label.size = Vector2(content_width, 24.0)
	merit_label.add_theme_font_size_override("font_size", 17)
	merit_label.add_theme_color_override("font_color", GOLD_BRIGHT)
	merit_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(merit_label)
	var status_label := Label.new()
	status_label.position = Vector2(24.0, 340.0)
	status_label.size = Vector2(content_width, 24.0)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not feedback.is_empty():
		status_label.text = feedback
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	elif maxed:
		status_label.text = "该战魂铭刻已满阶"
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	elif not can_afford:
		status_label.text = "军功不足 · 还差 %d" % (cost - current_merit)
		status_label.add_theme_color_override("font_color", Color("e67363"))
	else:
		status_label.text = "下一阶消耗  %d 军功" % cost
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	dialog.add_child(status_label)
	var action_y := dialog_size.y - 62.0
	var action_width := (content_width - 12.0) * 0.5
	var purchase_title := "已满阶" if maxed else "铭刻 · %d 军功" % cost
	var purchase_disabled := maxed or not can_afford
	var purchase_button := _create_button(purchase_title, "", Vector2(24.0, action_y), Callable(self, "_buy_battle_soul_from_detail").bind(armory_id), Vector2(action_width, 44.0), purchase_disabled, 16, dialog, false)
	if purchase_disabled:
		_set_button_locked_visual(purchase_button)
	var close_button := _create_button("取消", "", Vector2(36.0 + action_width, action_y), _close_battle_soul_detail, Vector2(action_width, 44.0), false, 16, dialog, false)
	close_button.add_theme_stylebox_override("normal", _make_box_style(Color("17242a"), DRAGON_BLUE, 2))
	close_button.add_theme_stylebox_override("hover", _make_box_style(Color("20343c"), DRAGON_BLUE, 3))

func _buy_battle_soul_from_detail(armory_id: String) -> void:
	var current_profile := SaveService.load_profile()
	profile = current_profile
	var rank := SaveService.battle_soul_armory_rank(armory_id)
	var max_rank := BATTLE_SOUL_ARMORY.max_rank_for(armory_id)
	if rank >= max_rank:
		_show_battle_soul_detail(armory_id, "该战魂铭刻已满阶")
		return
	var cost := SaveService.battle_soul_armory_cost(armory_id)
	if int(current_profile.get("military_merit", 0)) < cost:
		_show_battle_soul_detail(armory_id, "军功不足")
		return
	if SaveService.purchase_battle_soul_armory(armory_id):
		_show_shop("souls")
		_show_battle_soul_detail(armory_id, "%s 已完成铭刻" % BATTLE_SOUL_ARMORY.title_for(armory_id))
	else:
		_show_battle_soul_detail(armory_id, "铭刻失败，请稍后重试")

func _close_battle_soul_detail() -> void:
	if not is_instance_valid(battle_soul_detail_dialog):
		battle_soul_detail_dialog = null
		return
	page_controls.erase(battle_soul_detail_dialog)
	battle_soul_detail_dialog.queue_free()
	battle_soul_detail_dialog = null

func _populate_tianji_shop(restore_scroll: int = 0) -> void:
	var items: Array[Dictionary] = []
	for skill_id in TIANJI_CATALOG.all_ids():
		var definition := TIANJI_CATALOG.definition_for(skill_id)
		if definition.is_empty():
			continue
		items.append({
			"id": skill_id,
			"title": str(definition.get("title", skill_id)),
			"description": str(definition.get("description", "")),
			"rank": SaveService.tianji_rank(skill_id),
			"max_rank": TIANJI_CATALOG.max_rank_for(skill_id),
			"cost": SaveService.tianji_cost(skill_id),
			"icon": _shop_item_icon(skill_id, "tianji"),
			"locked": false,
		})
	_populate_shop_category_icons(items, restore_scroll, "天机阵法 · 战斗中通过升级选择启阵")

func _set_tianji_node_visual(button: Button, color: Color, unlocked: bool, can_afford: bool) -> void:
	if unlocked:
		button.add_theme_color_override("font_color", color.lightened(0.18))
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_stylebox_override("normal", _make_box_style(Color("152127"), color, 2))
		button.add_theme_stylebox_override("hover", _make_box_style(Color("1b3036"), color.lightened(0.18), 3))
		button.add_theme_stylebox_override("pressed", _make_box_style(Color("233d42"), color.lightened(0.28), 3))
		return
	var locked_color := _alpha(color, 0.42)
	button.add_theme_color_override("font_color", Color("9ba9aa") if can_afford else Color("707d80"))
	button.add_theme_color_override("font_hover_color", Color("e7f0ed"))
	button.add_theme_stylebox_override("normal", _make_box_style(Color("10181c"), locked_color, 1))
	button.add_theme_stylebox_override("hover", _make_box_style(Color("17252a"), locked_color.lightened(0.32), 2))
	button.add_theme_stylebox_override("pressed", _make_box_style(Color("202d30"), locked_color.lightened(0.48), 2))

func _show_tianji_detail(skill_id: String, feedback: String = "") -> void:
	if page != "shop" or shop_section != "tianji":
		return
	_close_tianji_detail()
	var definition := TIANJI_CATALOG.definition_for(skill_id)
	if definition.is_empty():
		return
	var current_profile := SaveService.load_profile()
	profile = current_profile
	var rank := SaveService.tianji_rank(skill_id)
	var max_rank := TIANJI_CATALOG.max_rank_for(skill_id)
	var maxed := rank >= max_rank
	var cost := SaveService.tianji_cost(skill_id)
	var current_merit := int(current_profile.get("military_merit", 0))
	var can_afford := current_merit >= cost
	var overlay := ColorRect.new()
	overlay.color = Color(0.01, 0.02, 0.03, 0.76)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 40
	add_child(overlay)
	page_controls.append(overlay)
	tianji_detail_dialog = overlay
	tianji_detail_notice = feedback
	var dialog_size := Vector2(minf(640.0, maxf(340.0, size.x - 40.0)), minf(500.0, maxf(390.0, size.y - 40.0)))
	var dialog := Panel.new()
	dialog.position = (size - dialog_size) * 0.5
	dialog.size = dialog_size
	dialog.add_theme_stylebox_override("panel", UITheme.panel_style())
	dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dialog)
	var content_width := dialog_size.x - 48.0
	var category_label := Label.new()
	category_label.text = "天机阵法 · %s" % str(definition.get("subtitle", "永久启阵"))
	category_label.position = Vector2(24.0, 20.0)
	category_label.size = Vector2(content_width, 24.0)
	category_label.add_theme_font_size_override("font_size", 16)
	category_label.add_theme_color_override("font_color", GOLD)
	category_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(category_label)
	var title_label := Label.new()
	title_label.text = str(definition.get("title", skill_id))
	title_label.position = Vector2(24.0, 48.0)
	title_label.size = Vector2(content_width, 38.0)
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.add_theme_color_override("font_color", GOLD_BRIGHT)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(title_label)
	var description_label := RichTextLabel.new()
	description_label.bbcode_enabled = false
	description_label.text = str(definition.get("description", ""))
	description_label.position = Vector2(24.0, 102.0)
	description_label.size = Vector2(content_width, 66.0)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.fit_content = false
	description_label.scroll_active = true
	description_label.scroll_following = false
	description_label.add_theme_font_size_override("font_size", 19)
	description_label.add_theme_color_override("font_color", Color("d8e6e2"))
	description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(description_label)
	var rank_label := Label.new()
	rank_label.text = "当前阶数  %d / %d" % [rank, max_rank]
	rank_label.position = Vector2(24.0, 184.0)
	rank_label.size = Vector2(content_width, 24.0)
	rank_label.add_theme_font_size_override("font_size", 17)
	rank_label.add_theme_color_override("font_color", Color("cfe1dd"))
	rank_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(rank_label)
	var effect_label := Label.new()
	effect_label.text = _tianji_effect_summary(skill_id, rank, maxed)
	effect_label.position = Vector2(24.0, 218.0)
	effect_label.size = Vector2(content_width, 72.0)
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	effect_label.add_theme_font_size_override("font_size", 16)
	effect_label.add_theme_color_override("font_color", Color("cfe1dd"))
	effect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(effect_label)
	var merit_label := Label.new()
	merit_label.text = "现有军功  %d" % current_merit
	merit_label.position = Vector2(24.0, 302.0)
	merit_label.size = Vector2(content_width, 24.0)
	merit_label.add_theme_font_size_override("font_size", 17)
	merit_label.add_theme_color_override("font_color", GOLD_BRIGHT)
	merit_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(merit_label)
	var status_label := Label.new()
	status_label.position = Vector2(24.0, 336.0)
	status_label.size = Vector2(content_width, 24.0)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not feedback.is_empty():
		status_label.text = feedback
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	elif maxed:
		status_label.text = "该天机已满阶"
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	elif not can_afford:
		status_label.text = "军功不足 · 还差 %d" % (cost - current_merit)
		status_label.add_theme_color_override("font_color", Color("e67363"))
	else:
		status_label.text = "解锁后将在战斗中的升级选择技能中启阵"
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	dialog.add_child(status_label)
	var action_y := dialog_size.y - 62.0
	var action_width := (content_width - 12.0) * 0.5
	var purchase_title := "已满阶" if maxed else ("解锁 · %d 军功" % cost if rank == 0 else "升级 · %d 军功" % cost)
	var purchase_disabled := maxed or not can_afford
	var purchase_button := _create_button(purchase_title, "", Vector2(24.0, action_y), Callable(self, "_buy_tianji_from_detail").bind(skill_id), Vector2(action_width, 44.0), purchase_disabled, 16, dialog, false)
	if purchase_disabled:
		_set_button_locked_visual(purchase_button)
	var cancel_button := _create_button("取消", "", Vector2(36.0 + action_width, action_y), _close_tianji_detail, Vector2(action_width, 44.0), false, 16, dialog, false)
	cancel_button.add_theme_stylebox_override("normal", _make_box_style(Color("17242a"), DRAGON_BLUE, 2))
	cancel_button.add_theme_stylebox_override("hover", _make_box_style(Color("20343c"), DRAGON_BLUE, 3))

func _tianji_effect_summary(skill_id: String, rank: int, maxed: bool) -> String:
	if rank <= 0:
		return "解锁效果：%s" % TIANJI_CATALOG.effect_summary_for(skill_id, 1)
	if maxed:
		return TIANJI_CATALOG.effect_summary_for(skill_id, rank)
	return "%s\n下一阶：%s" % [TIANJI_CATALOG.effect_summary_for(skill_id, rank), TIANJI_CATALOG.effect_summary_for(skill_id, rank + 1)]

func _buy_tianji_from_detail(skill_id: String) -> void:
	var current_profile := SaveService.load_profile()
	profile = current_profile
	var rank := SaveService.tianji_rank(skill_id)
	var max_rank := TIANJI_CATALOG.max_rank_for(skill_id)
	if rank >= max_rank:
		_show_tianji_detail(skill_id, "该天机已满阶")
		return
	var cost := SaveService.tianji_cost(skill_id)
	if int(current_profile.get("military_merit", 0)) < cost:
		_show_tianji_detail(skill_id, "军功不足")
		return
	if SaveService.purchase_tianji(skill_id):
		_show_shop("tianji")
		_show_tianji_detail(skill_id, "%s 已解锁/升阶" % TIANJI_CATALOG.title_for(skill_id))
	else:
		_show_tianji_detail(skill_id, "购买失败，请稍后重试")
	queue_redraw()

func _close_tianji_detail() -> void:
	tianji_detail_notice = ""
	if not is_instance_valid(tianji_detail_dialog):
		tianji_detail_dialog = null
		return
	page_controls.erase(tianji_detail_dialog)
	tianji_detail_dialog.queue_free()
	tianji_detail_dialog = null

func _strategy_row_heights() -> Array[float]:
	var row_count := 0
	for branch_variant in MILITARY_STRATEGY.BRANCHES:
		var nodes: Array = (branch_variant as Dictionary).get("nodes", []) as Array
		row_count = maxi(row_count, nodes.size())
	var row_heights: Array[float] = []
	for node_index in range(row_count):
		var row_height := STRATEGY_CARD_MIN_HEIGHT
		for branch_variant in MILITARY_STRATEGY.BRANCHES:
			var nodes: Array = (branch_variant as Dictionary).get("nodes", []) as Array
			if node_index >= nodes.size():
				continue
			var strategy_id := str(nodes[node_index])
			row_height = maxf(row_height, _strategy_card_height_for(MILITARY_STRATEGY.card_summary_for(strategy_id)))
		row_heights.append(row_height)
	return row_heights

func _strategy_card_height_for(description: String, card_width: float = STRATEGY_CARD_WIDTH) -> float:
	return STRATEGY_CARD_MIN_HEIGHT

func _create_strategy_card(title: String, description: String, status: String, at: Vector2, card_size: Vector2, callback: Callable, disabled: bool, purchasable: bool, parent: Control = null) -> Button:
	var card := _create_button("", "", at, callback, card_size, disabled, 13, parent, parent == null)
	var text_width := card_size.x - 28.0
	var title_label := Label.new()
	title_label.text = title
	title_label.position = Vector2(14.0, 7.0)
	title_label.size = Vector2(text_width, 18.0)
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", GOLD_BRIGHT if purchasable else Color("a0abad"))
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.clip_text = true
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(title_label)
	var description_label := Label.new()
	description_label.text = description
	description_label.position = Vector2(14.0, 30.0)
	description_label.size = Vector2(text_width, 18.0)
	description_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	description_label.clip_text = true
	description_label.add_theme_font_size_override("font_size", 13)
	description_label.add_theme_color_override("font_color", Color("c1cecb") if purchasable else Color("7e8a8e"))
	description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(description_label)
	var status_label := Label.new()
	status_label.text = status
	status_label.position = Vector2(14.0, card_size.y - 24.0)
	status_label.size = Vector2(text_width, 17.0)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_label.clip_text = true
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", Color("dba86e") if not purchasable and not disabled else (Color("9ee0c6") if disabled else Color("b8d6d0")))
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(status_label)
	return card

func _show_settings() -> void:
	page = "settings"
	profile = SaveService.load_profile()
	notice = ""
	_clear_buttons()
	var panel_size := Vector2(minf(640.0, size.x - 56.0), minf(530.0, size.y - 48.0))
	var panel_origin := Vector2((size.x - panel_size.x) * 0.5, (size.y - panel_size.y) * 0.5 + 18.0)
	var panel := Panel.new()
	panel.position = panel_origin
	panel.size = panel_size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", UITheme.panel_style())
	add_child(panel)
	page_controls.append(panel)
	_create_settings_label(panel, "设置", Vector2(28.0, 22.0), Vector2(panel_size.x - 56.0, 34.0), 30, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_LEFT)
	_create_settings_label(panel, SETTINGS_VERSION_TEXT, Vector2(panel_size.x - 190.0, 26.0), Vector2(162.0, 24.0), 14, MUTED, HORIZONTAL_ALIGNMENT_RIGHT)
	_create_settings_label(panel, "中军帐 · 声音与战场反馈", Vector2(28.0, 58.0), Vector2(panel_size.x - 56.0, 22.0), 14, MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	var content_width := panel_size.x - 56.0
	var sound_text := "开启" if SaveService.setting_enabled("sound_enabled") else "关闭"
	var vibration_text := "开启" if SaveService.setting_enabled("vibration_enabled") else "关闭"
	_create_button("音量：%s" % sound_text, "点击切换总开关", panel_origin + Vector2(28.0, 96.0), _toggle_sound, Vector2(content_width, 52.0), false, 17)
	_create_settings_label(panel, "音乐", Vector2(28.0, 166.0), Vector2(120.0, 24.0), 18, Color("d6e5e2"))
	_create_volume_slider(panel_origin + Vector2(154.0, 166.0), _music_volume(), "背景音乐音量", _on_music_volume_changed)
	music_value_label = _create_settings_label(panel, "%d%%" % int(round(_music_volume() * 100.0)), Vector2(panel_size.x - 118.0, 166.0), Vector2(90.0, 24.0), 17, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_RIGHT)
	_create_settings_label(panel, "音效", Vector2(28.0, 228.0), Vector2(120.0, 24.0), 18, Color("d6e5e2"))
	_create_volume_slider(panel_origin + Vector2(154.0, 228.0), _sfx_volume(), "战斗音效音量", _on_sfx_volume_changed)
	sfx_value_label = _create_settings_label(panel, "%d%%" % int(round(_sfx_volume() * 100.0)), Vector2(panel_size.x - 118.0, 228.0), Vector2(90.0, 24.0), 17, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_RIGHT)
	_create_settings_label(panel, "环境", Vector2(28.0, 290.0), Vector2(120.0, 24.0), 18, Color("d6e5e2"))
	_create_weather_selector(panel_origin + Vector2(154.0, 284.0))
	_create_button("震动：%s" % vibration_text, "受击与阵法反馈", panel_origin + Vector2(28.0, 348.0), _toggle_vibration, Vector2(content_width, 52.0), false, 17)
	_create_button("隐私政策", "查看个人信息处理规则", panel_origin + Vector2(28.0, 412.0), Callable(TapAuthService, "show_privacy_policy"), Vector2(content_width, 52.0), false, 17)
	_create_shared_back_button(_show_main)
	queue_redraw()

func _create_settings_label(parent: Control, text: String, at: Vector2, label_size: Vector2, font_size: int, color: Color, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := UITheme.label(text, font_size, color)
	label.position = at
	label.size = label_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	parent.add_child(label)
	return label

func _show_hero_details() -> void:
	_show_hero_details_from("main")

func _show_hero_details_from(return_page: String) -> void:
	page = "hero_details"
	hero_details_return_page = return_page
	profile = SaveService.load_profile()
	notice = ""
	_clear_buttons()
	var return_callback := _show_hero_select_from_details if hero_details_return_page == "hero_select" else _show_main
	_create_button("返回", "", Vector2(_safe_margin(), 28.0), return_callback, Vector2(126.0, 46.0))
	queue_redraw()

func _show_hero_select(mode: String, battlefield_id: String, return_tab: String, preserve_selection: bool = false) -> void:
	var animate_hero_transition := hero_select_transition_pending or page == "expedition"
	page = "hero_select"
	departure_loading = false
	selected_run_mode = mode
	selected_run_battlefield_id = battlefield_id
	hero_select_return_tab = return_tab
	profile = SaveService.load_profile()
	notice = ""
	hero_select_idle_elapsed = 0.0
	hero_select_stat_fill_elapsed = 0.0
	hero_select_stat_fill_progress = 0.0
	_clear_buttons()
	hero_select_idle_sprite = null
	_refresh_hero_ids(preserve_selection)
	_populate_hero_select_portraits()
	_populate_hero_select_slots()
	_populate_hero_select_buttons()
	# Keep the full-body illustration inside one clipped layer so old or oversized
	# source canvases can never cover the title, buttons, or detail panel.
	# The portrait intentionally grows into the panel's left edge; the clipped
	# layer prevents the enlarged source canvas from covering the title.
	# Keep the portrait within the center stage; the info panel owns the right
	# column and must remain visually above the character art.
	var display_rect := Rect2(size.x * 0.32, size.y * 0.12, size.x * 0.34, size.y * 0.72)
	_setup_hero_select_portrait_layer(display_rect)
	_new_hero_display_portrait(_selected_hero_id(), display_rect)
	_setup_hero_select_info_overlay()
	if animate_hero_transition:
		_start_hero_select_portrait_flash()
		_start_hero_select_transition(_selected_hero_id())
	hero_select_transition_pending = false
	var can_depart := _is_release_hero_available(_selected_hero_id())
	_create_hero_select_logo()
	var depart_button := _create_hero_select_start_button(can_depart)
	var back_button := _create_shared_back_button(Callable(self, "_show_expedition").bind(hero_select_return_tab))
	back_button.z_index = 24
	# Reaching the Five Tiger selection page is the tutorial's completion point.
	# Mark it before refreshing the page so a restart cannot resume the old
	# final tutorial overlay on this screen.
	if not SaveService.tutorial_completed() and SaveService.tutorial_stage() >= 17 and SaveService.tutorial_stage() < TUTORIAL_FINAL_STAGE:
		SaveService.complete_tutorial()
	_tutorial_refresh()
	queue_redraw()

func _show_hero_select_from_details() -> void:
	_show_hero_select(selected_run_mode, selected_run_battlefield_id, hero_select_return_tab, true)

func _create_hero_select_logo() -> void:
	var logo := TextureRect.new()
	logo.name = "HeroSelectLogo"
	logo.texture = HERO_SELECT_LOGO_TEXTURE
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.position = _expedition_ui_position(Vector2(26.0 + SHARED_BACK_BUTTON_SIZE.x + 18.0, 18.0))
	logo.size = Vector2(390.0, 72.0)
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.z_index = 24
	add_child(logo)
	page_controls.append(logo)

func _create_hero_select_start_button(can_depart: bool) -> TextureButton:
	var button := TextureButton.new()
	button.name = "HeroSelectStartButton"
	button.texture_normal = HERO_SELECT_START_TEXTURE
	button.texture_hover = HERO_SELECT_START_TEXTURE
	button.texture_pressed = HERO_SELECT_START_TEXTURE
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.position = Vector2(size.x * 0.5 - 112.0, size.y - 94.0)
	button.size = Vector2(224.0, 70.0)
	button.disabled = not can_depart
	button.modulate = Color.WHITE if can_depart else Color(0.48, 0.52, 0.52, 0.78)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.tooltip_text = "出征" if can_depart else "当前武将不可出征"
	button.pressed.connect(_begin_selected_run)
	button.z_index = 24
	add_child(button)
	page_controls.append(button)
	return button

func _show_selected_hero_details() -> void:
	_show_hero_details_from("hero_select")

func _begin_selected_run() -> void:
	if departure_loading:
		return
	var hero_id := _selected_hero_id()
	if not _is_release_hero_available(hero_id):
		return
	departure_loading = true
	for button in buttons:
		if is_instance_valid(button):
			button.disabled = true
	# Display the transition before synchronous profile writes and scene loading.
	LoadingOverlay.show_transition("正在确认出战")
	LoadingOverlay.set_progress(0.0, "正在确认武将与军令")
	call_deferred("_commit_selected_run_departure", hero_id)

func _commit_selected_run_departure(hero_id: String) -> void:
	# A real frame boundary lets the CanvasLayer draw before file I/O begins.
	await get_tree().process_frame
	if not is_inside_tree():
		return
	var equipped := SaveService.equip_hero_for_trial(hero_id) if HERO_SELECT_TRIAL_IDS.has(hero_id) else SaveService.equip_hero(hero_id)
	if not equipped:
		departure_loading = false
		for button in buttons:
			if is_instance_valid(button):
				button.disabled = false
		LoadingOverlay.fail_transition("出征武将不可用，请重新选择")
		return
	if SaveService.tutorial_stage() == 19:
		SaveService.complete_tutorial()
	SceneRouter.start_run(selected_run_mode, selected_run_battlefield_id, selected_run_story_chapter)
	if not SceneRouter.scene_transition_pending:
		departure_loading = false
		for button in buttons:
			if is_instance_valid(button):
				button.disabled = false
		LoadingOverlay.fail_transition("当前战场暂不可出征，请重新选择")

func _start_story() -> void:
	SceneRouter.start_run("story", "xinye", 1)

func _start_selected_story() -> void:
	var chapter_index := STORY_CHAPTER_IDS.find(selected_story_chapter_id)
	if chapter_index < 0 or not SaveService.is_story_chapter_unlocked(chapter_index + 1):
		return
	selected_run_story_chapter = chapter_index + 1
	if SaveService.tutorial_stage() == 17 and selected_story_chapter_id == "story_01":
		SaveService.set_tutorial_stage(18)
	_show_hero_select("story", _story_battlefield_id(selected_run_story_chapter), "story")

func _story_battlefield_id(chapter: int) -> String:
	match chapter:
		1:
			return "xinye"
		2:
			return "huoshaoxinye"
		3:
			return "dangyangduanhou"
		_:
			return "xinye"

func _start_endless() -> void:
	SceneRouter.start_run("endless", "changban")

func _start_selected_endless() -> void:
	if not SaveService.is_battlefield_unlocked(selected_endless_battlefield_id):
		return
	var mode := "siege" if selected_endless_battlefield_id == "jingzhou_siege" else "endless"
	_show_hero_select(mode, selected_endless_battlefield_id, "endless")

func _start_boss_trial() -> void:
	if not SaveService.is_battlefield_unlocked("hulao"):
		return
	_show_hero_select("boss_trial", "hulao", "boss_trial")

func _buy_strategy(strategy_id: String) -> void:
	if SaveService.purchase_strategy(strategy_id):
		_show_shop("strategies")
		notice = "%s 已研习，永久作用于所有武将" % MILITARY_STRATEGY.title_for(strategy_id)
		queue_redraw()
		return
	var is_maxed := SaveService.strategy_rank(strategy_id) >= MILITARY_STRATEGY.max_rank_for(strategy_id)
	var current_profile := SaveService.load_profile()
	_show_shop("strategies")
	notice = "该军略已满阶" if is_maxed else (MILITARY_STRATEGY.prerequisite_requirement_text(current_profile, strategy_id) if not MILITARY_STRATEGY.prerequisite_satisfied_for(current_profile, strategy_id) else "军功不足")
	queue_redraw()

func _buy_tianji(skill_id: String) -> void:
	if SaveService.purchase_tianji(skill_id):
		_show_shop("tianji")
		notice = "%s 已解锁/升阶" % TIANJI_CATALOG.title_for(skill_id)
		queue_redraw()
		return
	var rank := SaveService.tianji_rank(skill_id)
	_show_shop("tianji")
	notice = "该天机已满阶" if rank >= TIANJI_CATALOG.max_rank_for(skill_id) else "军功不足"
	queue_redraw()

func _buy_talent(hero_id: String, talent_id: String, cost: int) -> void:
	var definition: Dictionary = UpgradeSystem.DEFINITIONS.get(talent_id, {}) as Dictionary
	if SaveService.purchase_talent(hero_id, talent_id, cost):
		var rank := SaveService.talent_rank(hero_id, talent_id)
		_show_shop("heroes")
		notice = "%s 的 %s 已%s" % [str(HERO_CATALOG.definition_for(hero_id).get("name", "武将")), str(definition.get("title", talent_id)), "升至 %d 阶" % rank if rank > 1 else "解锁"]
		queue_redraw()
		return
	_show_shop("heroes")
	notice = "军功不足或该战法已解锁"
	queue_redraw()

func _buy_hero(hero_id: String, cost: int) -> void:
	var hero := HERO_CATALOG.definition_for(hero_id)
	if SaveService.purchase_hero(hero_id, cost):
		selected_shop_hero_id = hero_id
		_show_shop("heroes")
		notice = "%s 已招募，可前往上阵" % str(hero.get("name", "武将"))
		queue_redraw()
		return
	_show_shop("heroes")
	notice = "军功不足或该武将已拥有"
	queue_redraw()

func _equip_shop_hero(hero_id: String) -> void:
	if SaveService.equip_hero(hero_id):
		_show_shop("heroes")
		notice = "%s 已上阵" % str(HERO_CATALOG.definition_for(hero_id).get("name", "武将"))
		queue_redraw()

func _toggle_sound() -> void:
	var enabled := not SaveService.setting_enabled("sound_enabled")
	SaveService.set_setting("sound_enabled", enabled)
	AudioService.apply_settings(SaveService.load_profile().get("settings", {}) as Dictionary)
	_show_settings()

func _toggle_vibration() -> void:
	SaveService.set_setting("vibration_enabled", not SaveService.setting_enabled("vibration_enabled"))
	_show_settings()

func _music_volume() -> float:
	return clampf(float(SaveService.setting_value("music_volume", 1.0)), 0.0, 1.0)

func _sfx_volume() -> float:
	return clampf(float(SaveService.setting_value("sfx_volume", 1.0)), 0.0, 1.0)

func _on_music_volume_changed(value: float) -> void:
	var volume := snappedf(clampf(value, 0.0, 1.0), 0.05)
	SaveService.set_setting_value("music_volume", volume)
	AudioService.set_music_volume(volume)
	if is_instance_valid(music_value_label):
		music_value_label.text = "%d%%" % int(round(volume * 100.0))
	queue_redraw()

func _on_sfx_volume_changed(value: float) -> void:
	var volume := snappedf(clampf(value, 0.0, 1.0), 0.05)
	SaveService.set_setting_value("sfx_volume", volume)
	AudioService.set_sfx_volume(volume)
	if is_instance_valid(sfx_value_label):
		sfx_value_label.text = "%d%%" % int(round(volume * 100.0))
	queue_redraw()

func _on_weather_mode_selected(index: int) -> void:
	var weather_modes: Array[String] = ["auto", "sunny", "rain", "storm", "snow"]
	if index < 0 or index >= weather_modes.size():
		return
	SaveService.set_setting_value("weather_mode", weather_modes[index])
	queue_redraw()

func _refresh_hero_ids(preserve_selection: bool = false) -> void:
	var previous_hero_id := _selected_hero_id()
	# The selectable carousel excludes the preview-only Huang Zhong slot.
	hero_ids = HERO_SELECT_PLAYABLE_IDS.duplicate()
	var preferred_hero_id := SaveService.equipped_hero_id()
	if preserve_selection and hero_ids.has(previous_hero_id):
		preferred_hero_id = previous_hero_id
	# Huang Zhong remains visible in the roster but is excluded from selectable IDs.
	if not HERO_SELECT_PLAYABLE_IDS.has(preferred_hero_id):
		preferred_hero_id = "guan_yu"
	selected_hero_index = maxi(0, HERO_SELECT_PLAYABLE_IDS.find(preferred_hero_id))

func _is_release_hero_available(hero_id: String) -> bool:
	return HERO_SELECT_TRIAL_IDS.has(hero_id) or (RELEASE_HERO_IDS.has(hero_id) and SaveService.has_hero(hero_id))

func _hero_select_portrait_rect(hero_id: String) -> Rect2:
	var right_rect: Rect2 = _hero_select_layout().get("right", Rect2())
	return Rect2(right_rect.position + Vector2(100.0, 8.0), right_rect.size - Vector2(200.0, 34.0))

func _hero_select_side_portrait_rect(direction: int) -> Rect2:
	var right_rect: Rect2 = _hero_select_layout().get("right", Rect2())
	var side_width := minf(190.0, right_rect.size.x * 0.32)
	var side_height := right_rect.size.y - 34.0
	if direction < 0:
		return Rect2(right_rect.position + Vector2(18.0, 8.0), Vector2(side_width, side_height))
	return Rect2(Vector2(right_rect.end.x - side_width - 18.0, right_rect.position.y + 8.0), Vector2(side_width, side_height))

func _hero_select_layout() -> Dictionary:
	var margin := _safe_margin()
	var top := 92.0
	var bottom := 104.0
	var content := Rect2(margin, top, maxf(320.0, size.x - margin * 2.0), maxf(220.0, size.y - top - bottom))
	var left := Rect2(content.position + Vector2(208.0, 0.0), Vector2(content.size.x * 0.36, content.size.y))
	var right := Rect2(Vector2(content.end.x - content.size.x * 0.29, content.position.y + 8.0), Vector2(content.size.x * 0.29, content.size.y - 16.0))
	var stats := right
	var model := Rect2(left.position + Vector2(12.0, left.size.y * 0.52), Vector2(left.size.x * 0.68, left.size.y * 0.35))
	return {"content": content, "left": left, "right": right, "stats": stats, "model": model}

func _hero_select_portrait_layer(hero_id: String) -> int:
	match hero_id:
		"huang_zhong": return 1
		"zhang_fei": return 2
		"ma_chao": return 3
		"guan_yu": return 4
		"zhao_yun": return 5
		_: return 1

func _hero_select_slot_rect(slot_index: int) -> Rect2:
	var slot_width := clampf(size.x * 0.118, 112.0, 156.0)
	var gap := maxf(18.0, (size.x - slot_width * 5.0) / 6.0)
	var slot_height := clampf(size.y * 0.265, 154.0, 190.0)
	return Rect2(gap + float(slot_index) * (slot_width + gap), size.y - slot_height - 22.0, slot_width, slot_height)

func _populate_hero_select_portraits() -> void:
	var model_rect: Rect2 = _hero_select_layout().get("model", Rect2())
	var swipe_area := Control.new()
	swipe_area.position = model_rect.position
	swipe_area.size = model_rect.size
	swipe_area.mouse_filter = Control.MOUSE_FILTER_STOP
	swipe_area.z_index = 8
	swipe_area.gui_input.connect(_on_hero_select_swipe_gui_input.bind(swipe_area))
	add_child(swipe_area)
	page_controls.append(swipe_area)
	var arrow_size := Vector2(38.0, 50.0)
	var left_arrow := _create_button("‹", "", Vector2(model_rect.position.x - 26.0, model_rect.get_center().y - arrow_size.y * 0.5), Callable(self, "_step_hero_selection").bind(-1), arrow_size, false, 26)
	var right_arrow := _create_button("›", "", Vector2(model_rect.end.x - 12.0, model_rect.get_center().y - arrow_size.y * 0.5), Callable(self, "_step_hero_selection").bind(1), arrow_size, false, 26)
	left_arrow.z_index = 24
	right_arrow.z_index = 24
	_configure_hero_select_action_button(left_arrow, false)
	_configure_hero_select_action_button(right_arrow, false)

func _create_hero_select_portrait(hero_id: String, portrait_rect: Rect2, selected: bool) -> void:
	# 旧版 portrait 入口保留签名以兼容旧调用，但不再创建任何节点。
	return
	var hero := HERO_CATALOG.definition_for(hero_id)
	var portrait_path := str(hero.get("portrait", ""))
	if portrait_path.is_empty():
		return
	var portrait := TextureRect.new()
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.texture = _portrait_for(portrait_path)
	portrait.position = portrait_rect.position
	portrait.size = portrait_rect.size
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if selected:
		# Unreleased heroes remain fully visible as previews; only released but
		# locked heroes use the dimmed treatment.
		portrait.material = null if not RELEASE_HERO_IDS.has(hero_id) or _is_release_hero_available(hero_id) else _hero_select_portrait_material()
		portrait.modulate = Color.WHITE
		portrait.z_index = 12
	else:
		portrait.material = _hero_select_side_portrait_material()
		portrait.modulate = Color(1.0, 1.0, 1.0, 0.42)
		portrait.z_index = 9
	add_child(portrait)
	page_controls.append(portrait)

func _populate_hero_select_slots() -> void:
	var hero_id := _selected_hero_id()
	var hero := _selected_hero()
	_populate_hero_select_skill_labels(_hero_select_info_rect(), hero)
	if _hero_has_idle_preview(hero_id):
		var stage_rect := Rect2(size.x * 0.19, size.y * 0.37, size.x * 0.25, size.y * 0.38)
		_create_hero_select_idle_sprite(stage_rect, hero_id, true, true)

func _setup_hero_select_info_overlay() -> void:
	if is_instance_valid(hero_select_info_overlay):
		hero_select_info_overlay.queue_free()
	var overlay := HeroSelectInfoOverlay.new()
	overlay.name = "HeroSelectInfoOverlay"
	overlay.position = Vector2.ZERO
	overlay.size = size
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 10
	add_child(overlay)
	page_controls.append(overlay)
	hero_select_info_overlay = overlay
	var hero_id := _selected_hero_id()
	var hero := _selected_hero()
	var is_release_hero := HERO_SELECT_PLAYABLE_IDS.has(hero_id)
	var unlock_cost := int(hero.get("unlock_cost", 0))
	var locked_status := "敬请期待" if hero_id == "huang_zhong" else ("" if hero_id == "ma_chao" else ("%d军功解锁" % unlock_cost if unlock_cost > 0 else "暂未解锁"))
	var available := _is_release_hero_available(hero_id)
	var status := "" if available else locked_status
	var status_color := Color("9ee0c6") if available else (Color("d0a875") if is_release_hero else MUTED)
	overlay.configure(_hero_select_info_rect(), hero, hero_id, HERO_CATALOG.display_stats_for(hero_id, profile), status, status_color)
	overlay.set_stat_fill_progress(hero_select_stat_fill_progress)

func _hero_select_info_rect() -> Rect2:
	# Lift and slightly enlarge the panel so the skill row has enough clearance
	# from the lower frame. The panel remains below the start button's z-layer.
	return Rect2(size.x * 0.68, size.y * 0.07, size.x * 0.28, size.y * 0.82)

func _skill_icon_path(hero_id: String, index: int) -> String:
	var names := {"guan_yu": "guanyu", "zhang_fei": "zhangfei", "zhao_yun": "zhaoyun", "ma_chao": "machao"}
	var stem := str(names.get(hero_id, ""))
	if stem.is_empty() or index < 0:
		return ""
	var hero := HERO_CATALOG.definition_for(hero_id)
	var skills: Array = hero.get("skills", []) as Array
	if index >= skills.size():
		return ""
	var skill_type := str((skills[index] as Dictionary).get("type", ""))
	var file_index := HERO_CATALOG.skill_icon_file_index(skill_type)
	if file_index <= 0:
		return ""
	return "res://assets/art/ui/hero_skills/%s%d.png" % [stem, file_index]

func _hero_select_info_sections(info_rect: Rect2) -> Dictionary:
	var inner := info_rect.grow(-18.0)
	var gap := 10.0
	var role_height := info_rect.size.y * 0.17
	var trait_height := info_rect.size.y * 0.23
	var stats_height := info_rect.size.y * 0.31
	var role := Rect2(inner.position, Vector2(inner.size.x, role_height))
	var trait_section := Rect2(Vector2(inner.position.x, role.end.y + gap), Vector2(inner.size.x, trait_height))
	var stats := Rect2(Vector2(inner.position.x, trait_section.end.y + gap), Vector2(inner.size.x, stats_height))
	var skills_y := stats.end.y + gap
	var skills := Rect2(Vector2(inner.position.x, skills_y), Vector2(inner.size.x, maxf(0.0, inner.end.y - skills_y)))
	return {"role": role, "trait": trait_section, "stats": stats, "skills": skills}

func _populate_hero_select_skill_labels(stats_rect: Rect2, hero: Dictionary) -> void:
	var hero_id := str(hero.get("id", ""))
	if hero_id == "huang_zhong":
		return
	var skills: Array = hero.get("skills", []) as Array
	var skill_count := mini(4, skills.size())
	if skill_count <= 0:
		return
	var sections := _hero_select_info_sections(stats_rect)
	var skill_rect: Rect2 = sections.get("skills", Rect2())
	var icon_size := Vector2(62.0, 62.0)
	# The section title occupies the first ~20 px. Pull the icon row up a little
	# so the skill names remain inside the panel's lower border.
	var start := skill_rect.position + Vector2(0.0, 24.0)
	var skill_gap := 4.0
	var available_width := skill_rect.size.x
	var cell_width := (available_width - skill_gap * float(skill_count - 1)) / float(skill_count)
	for index in range(skill_count):
		var skill: Dictionary = skills[index] as Dictionary
		var skill_type := str(skill.get("type", "技能"))
		var skill_name := str(skill.get("name", "")).trim_prefix("%s·" % skill_type)
		var cell := Button.new()
		cell.position = start + Vector2(float(index) * (cell_width + skill_gap), 0.0)
		cell.size = Vector2(cell_width, 90.0)
		cell.clip_contents = true
		cell.flat = true
		cell.focus_mode = Control.FOCUS_NONE
		cell.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		# Keep skill controls above the information overlay while the portrait
		# remains below it.
		cell.z_index = 12
		cell.tooltip_text = "点击查看技能说明"
		cell.pressed.connect(_show_hero_skill_popup.bind(skill, cell))
		var icon := TextureRect.new()
		var icon_path := _skill_icon_path(hero_id, index)
		if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
			icon.texture = load(icon_path) as Texture2D
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.position = Vector2((cell.size.x - icon_size.x) * 0.5, 0.0)
		icon.size = icon_size
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(icon)
		var label := UITheme.label(skill_name, 15, Color("f0e6ce"))
		label.position = Vector2(0.0, 64.0)
		label.size = Vector2(cell.size.x, 26.0)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.clip_text = true
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(label)
		add_child(cell)
		page_controls.append(cell)

func _show_hero_skill_popup(skill: Dictionary, source: Control) -> void:
	if is_instance_valid(hero_select_skill_popup):
		hero_select_skill_popup.queue_free()
		hero_select_skill_popup = null
	var popup_width := minf(clampf(size.x * 0.34, 340.0, 460.0), maxf(1.0, size.x - 36.0))
	var content_width := popup_width - 40.0
	var wrapped_title := _wrap_hero_skill_text(str(skill.get("name", "技能")), content_width, 22)
	var wrapped_description := _wrap_hero_skill_text(str(skill.get("description", "")), content_width - 14.0, 18)
	var title_height := float(maxi(1, wrapped_title.split("\n").size())) * 32.0
	var body_height := minf(float(maxi(1, wrapped_description.split("\n").size())) * 30.0, minf(size.y * 0.46, 360.0))
	var popup_height := minf(18.0 + title_height + 12.0 + body_height + 18.0, size.y - 36.0)
	var popup := Panel.new()
	popup.name = "HeroSkillPopup"
	popup.size = Vector2(popup_width, popup_height)
	var preferred_above := source.global_position.y - popup_height - 16.0
	var popup_y := preferred_above if preferred_above >= 24.0 else source.global_position.y + source.size.y + 16.0
	popup.position = Vector2(
		clampf(source.global_position.x + source.size.x * 0.5 - popup_width * 0.5, 18.0, size.x - popup_width - 18.0),
		clampf(popup_y, 18.0, size.y - popup_height - 18.0)
	)
	popup.z_index = 60
	popup.mouse_filter = Control.MOUSE_FILTER_STOP
	popup.add_theme_stylebox_override("panel", UITheme.flat_box_style(Color("10191f", 0.98), GOLD, 1))
	var title := UITheme.label(wrapped_title, 22, GOLD_BRIGHT)
	title.add_theme_font_override("font", KAITI_FONT)
	title.position = Vector2(20.0, 16.0)
	title.size = Vector2(content_width, title_height)
	title.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.clip_text = true
	popup.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(20.0, 18.0 + title_height + 12.0)
	scroll.size = Vector2(content_width, maxf(0.0, popup_height - scroll.position.y - 18.0))
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	popup.add_child(scroll)
	var description := UITheme.label(wrapped_description, 18, Color("f0e6ce"))
	description.add_theme_font_override("font", KAITI_FONT)
	description.size = Vector2(content_width - 14.0, maxf(body_height, float(maxi(1, wrapped_description.split("\n").size())) * 30.0))
	description.custom_minimum_size = description.size
	description.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	description.autowrap_mode = TextServer.AUTOWRAP_OFF
	description.clip_text = true
	scroll.add_child(description)
	add_child(popup)
	hero_select_skill_popup = popup

func _input(event: InputEvent) -> void:
	if not is_instance_valid(hero_select_skill_popup):
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		var mouse := event as InputEventMouseButton
		if not hero_select_skill_popup.get_global_rect().has_point(mouse.position):
			hero_select_skill_popup.queue_free()
			hero_select_skill_popup = null
	elif event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
		var touch := event as InputEventScreenTouch
		if not hero_select_skill_popup.get_global_rect().has_point(touch.position):
			hero_select_skill_popup.queue_free()
			hero_select_skill_popup = null

func _wrap_hero_skill_text(text: String, max_width: float, font_size: int) -> String:
	# Measure with the same Kai font used by the popup/detail panel.  Measuring
	# with the fallback font can make a line appear to fit here but overflow after
	# the actual font is applied to the label.
	var font := KAITI_FONT
	var safe_width := maxf(1.0, max_width)
	var lines: Array[String] = []
	var current := ""
	for character in text:
		if character == "\n":
			lines.append(current)
			current = ""
			continue
		var candidate := current + character
		var candidate_width := font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
		if not current.is_empty() and candidate_width > safe_width:
			lines.append(current)
			current = character
		else:
			current = candidate
	if not current.is_empty() or lines.is_empty():
		lines.append(current)
	return "\n".join(lines)

func _wrap_tutorial_text(text: String, max_width: float, font_size: int) -> String:
	# Chinese text has no spaces for word wrapping, so measure and break it one
	# character at a time to keep every line inside the tutorial panel.
	var font := UITheme.default_font()
	var lines: Array[String] = []
	var current := ""
	var safe_width := maxf(1.0, max_width)
	for character in text:
		if character == "\n":
			lines.append(current)
			current = ""
			continue
		var candidate := current + character
		var candidate_width := font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
		if not current.is_empty() and candidate_width > safe_width:
			lines.append(current)
			current = character
		else:
			current = candidate
	if not current.is_empty() or lines.is_empty():
		lines.append(current)
	return "\n".join(lines)

func _create_hero_select_slot_panel(slot_rect: Rect2, selected: bool, available: bool) -> void:
	var panel := Panel.new()
	panel.position = slot_rect.position
	panel.size = slot_rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = 16
	var border := GOLD_BRIGHT if selected else (Color("62747c") if available else Color("3a474c"))
	var fill := Color(0.01, 0.02, 0.025, 0.36) if selected else Color(0.01, 0.02, 0.025, 0.58)
	panel.add_theme_stylebox_override("panel", UITheme.panel_style())
	add_child(panel)
	page_controls.append(panel)

func _configure_hero_select_slot_button(button: Button) -> void:
	button.z_index = 18
	button.tooltip_text = "选择出战武将"
	button.add_theme_stylebox_override("normal", _make_box_style(Color(0.0, 0.0, 0.0, 0.0), Color(0.0, 0.0, 0.0, 0.0), 0))
	button.add_theme_stylebox_override("hover", _make_box_style(Color(0.93, 0.74, 0.30, 0.10), GOLD_BRIGHT, 2))
	button.add_theme_stylebox_override("pressed", _make_box_style(Color(0.95, 0.79, 0.35, 0.16), Color.WHITE, 2))

func _create_hero_select_portrait_hitbox(portrait_rect: Rect2, hero_id: String, selected: bool) -> void:
	var hero := HERO_CATALOG.definition_for(hero_id)
	var hitbox := Control.new()
	hitbox.position = portrait_rect.position
	hitbox.size = portrait_rect.size
	hitbox.mouse_filter = Control.MOUSE_FILTER_STOP
	hitbox.focus_mode = Control.FOCUS_NONE
	hitbox.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hitbox.z_index = _hero_select_portrait_layer(hero_id) + (8 if selected else 0) + 1
	hitbox.tooltip_text = "当前出战武将" if selected else "选择 %s 出战" % str(hero.get("name", "武将"))
	hitbox.gui_input.connect(_on_hero_select_portrait_gui_input.bind(hero_id, hitbox))
	add_child(hitbox)
	page_controls.append(hitbox)

func _on_hero_select_portrait_gui_input(event: InputEvent, hero_id: String, hitbox: Control) -> void:
	var activated := false
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		activated = mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		activated = touch_event.pressed
	if not activated:
		return
	hitbox.accept_event()
	_select_hero_for_run(hero_id)

func _configure_hero_select_action_button(button: Button, primary: bool) -> void:
	button.z_index = 19
	button.add_theme_font_size_override("font_size", 14)
	var border := GOLD_BRIGHT if primary else Color("7796a1")
	var fill := Color("5a451f") if primary else Color("17242a")
	button.add_theme_stylebox_override("normal", _make_box_style(fill, border, 1))
	button.add_theme_stylebox_override("hover", _make_box_style(Color("765a24") if primary else Color("213640"), border, 2))
	button.add_theme_stylebox_override("pressed", _make_box_style(Color("8a6828") if primary else Color("2a4650"), Color.WHITE, 2))

func _step_hero_selection(step: int) -> void:
	if hero_ids.is_empty():
		return
	var target_index := posmod(selected_hero_index + step, hero_ids.size())
	selected_hero_index = target_index
	hero_select_transition_pending = true
	_show_hero_select(selected_run_mode, selected_run_battlefield_id, hero_select_return_tab, true)

func _on_hero_select_swipe_gui_input(event: InputEvent, area: Control) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			hero_select_touch_index = touch.index
			hero_select_drag_start = touch.position
		elif touch.index == hero_select_touch_index:
			var delta := touch.position - hero_select_drag_start
			if absf(delta.x) >= 72.0 and absf(delta.x) > absf(delta.y) * 1.15:
				_step_hero_selection(1 if delta.x < 0.0 else -1)
			hero_select_touch_index = -1
			area.accept_event()
		return
	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == hero_select_touch_index:
			area.accept_event()
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			hero_select_mouse_dragging = true
			hero_select_drag_start = mouse.position
		else:
			if hero_select_mouse_dragging:
				var delta := mouse.position - hero_select_drag_start
				if absf(delta.x) >= 72.0 and absf(delta.x) > absf(delta.y) * 1.15:
					_step_hero_selection(1 if delta.x < 0.0 else -1)
			hero_select_mouse_dragging = false
			area.accept_event()

func _hero_has_idle_preview(hero_id: String) -> bool:
	return hero_id in ["guan_yu", "zhang_fei", "zhao_yun", "ma_chao"]

func _hero_is_expected_soon(hero_id: String) -> bool:
	return hero_id == "ma_chao"

func _new_hero_portrait(hero_id: String) -> Texture2D:
	var path := str(HERO_SELECT_NEW_PORTRAITS.get(hero_id, ""))
	return load(path) as Texture2D if not path.is_empty() else null

func _hero_select_portrait_material() -> ShaderMaterial:
	if hero_select_portrait_shader == null:
		hero_select_portrait_shader = Shader.new()
		hero_select_portrait_shader.code = HERO_SELECT_PORTRAIT_SHADER_CODE
	var material := ShaderMaterial.new()
	material.shader = hero_select_portrait_shader
	material.set_shader_parameter("dim_amount", 0.70)
	material.set_shader_parameter("brightness", 0.42)
	material.set_shader_parameter("flash_amount", 0.0)
	return material

func _hero_select_side_portrait_material() -> ShaderMaterial:
	if hero_select_portrait_shader == null:
		hero_select_portrait_shader = Shader.new()
		hero_select_portrait_shader.code = HERO_SELECT_PORTRAIT_SHADER_CODE
	var material := ShaderMaterial.new()
	material.shader = hero_select_portrait_shader
	material.set_shader_parameter("dim_amount", 0.58)
	material.set_shader_parameter("brightness", 0.68)
	material.set_shader_parameter("flash_amount", 0.0)
	return material

func _hero_select_display_portrait_material() -> ShaderMaterial:
	if hero_select_portrait_shader == null:
		hero_select_portrait_shader = Shader.new()
		hero_select_portrait_shader.code = HERO_SELECT_PORTRAIT_SHADER_CODE
	var material := ShaderMaterial.new()
	material.shader = hero_select_portrait_shader
	material.set_shader_parameter("dim_amount", 0.0)
	material.set_shader_parameter("brightness", 1.0)
	material.set_shader_parameter("flash_amount", 0.0)
	return material

func _select_hero_for_run(hero_id: String) -> void:
	var index := hero_ids.find(hero_id)
	if index < 0 or index == selected_hero_index:
		return
	selected_hero_index = index
	hero_select_transition_pending = true
	_show_hero_select(selected_run_mode, selected_run_battlefield_id, hero_select_return_tab, true)

func _selected_hero_id() -> String:
	return hero_ids[selected_hero_index] if not hero_ids.is_empty() else "zhao_yun"

func _populate_hero_select_buttons() -> void:
	var slot_height := clampf(size.y * 0.082, 54.0, 72.0)
	var slot_gap := clampf(size.y * 0.018, 10.0, 16.0)
	var start_y := size.y * 0.19
	for index in range(HERO_SELECT_SLOT_IDS.size()):
		var hero_id := str(HERO_SELECT_SLOT_IDS[index])
		var hero := HERO_CATALOG.definition_for(hero_id)
		var available := hero_id != "huang_zhong" and HERO_SELECT_PLAYABLE_IDS.has(hero_id)
		var selected := available and hero_id == _selected_hero_id()
		var button := _create_shop_texture_button(self, str(hero.get("name", hero_id)), Vector2(28.0, start_y + index * (slot_height + slot_gap)), Vector2(194.0, slot_height), Callable(self, "_select_hero_for_run").bind(hero_id), selected, not available)
		button.clip_contents = true
		# Adjust the hero-only label without changing shared shop buttons.
		for child in button.get_children():
			if child is Label:
				var name_label := child as Label
				name_label.position.x = 62.0
				name_label.size.x = button.size.x - 68.0
				name_label.add_theme_font_size_override("font_size", 23)
		button.z_index = 22
		button.tooltip_text = "敬请期待" if not available else "选择%s" % str(hero.get("name", hero_id))
		page_controls.append(button)
		buttons.append(button)
		if not available:
			button.modulate = Color(0.55, 0.60, 0.59, 0.82)
		var portrait := _new_hero_portrait(hero_id)
		if portrait != null:
			var icon := TextureRect.new()
			icon.texture = portrait
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.position = Vector2(8.0, 5.0)
			icon.size = Vector2(54.0, slot_height - 10.0)
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.modulate = Color(0.55, 0.60, 0.59, 0.72) if not available else Color.WHITE
			button.add_child(icon)

func _setup_hero_select_portrait_layer(display_rect: Rect2) -> void:
	var layer := Control.new()
	layer.name = "HeroSelectPortraitLayer"
	# Leave a narrow inset at the top and bottom so the background's golden frame
	# remains visible. The layer now reaches the viewport's right edge; this
	# prevents the portrait from being cropped at the information panel's left
	# edge. A separate high-z information overlay is responsible for covering
	# the portrait where the two areas overlap.
	layer.position = Vector2(
		display_rect.position.x - size.x * 0.015,
		HERO_SELECT_PORTRAIT_CLIP_TOP
	)
	layer.size = Vector2(
		maxf(display_rect.size.x, size.x - layer.position.x),
		maxf(display_rect.size.y, size.y - HERO_SELECT_PORTRAIT_CLIP_TOP - HERO_SELECT_PORTRAIT_CLIP_BOTTOM)
	)
	layer.clip_contents = true
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.z_index = 5
	add_child(layer)
	page_controls.append(layer)
	hero_select_portrait_layer = layer
	hero_select_display_portrait = null

func _new_hero_display_portrait(hero_id: String, rect: Rect2) -> void:
	if not is_instance_valid(hero_select_portrait_layer):
		_setup_hero_select_portrait_layer(rect)
	var layer := hero_select_portrait_layer
	for child in layer.get_children():
		if child is CanvasItem:
			(child as CanvasItem).visible = false
		child.queue_free()
	hero_select_display_portrait = null
	var texture := _new_hero_portrait(hero_id)
	if texture == null:
		return
	var layer_size := layer.size
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0 or layer_size.x <= 0.0 or layer_size.y <= 0.0:
		return
	# Keep the original visual scale/placement reference. The layer itself is now
	# wider only to remove the accidental crop at the info panel's left edge; it
	# must not make the portrait jump right or become larger.
	var portrait_reference_width := maxf(
		rect.size.x,
		_hero_select_info_rect().position.x - layer.position.x + 12.0
	)
	var scale_factor := minf(portrait_reference_width / texture_size.x, size.y / texture_size.y) * HERO_SELECT_PORTRAIT_SCALE
	var portrait_size := texture_size * scale_factor
	var portrait := TextureRect.new()
	portrait.name = "CurrentHeroPortrait"
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.texture = texture
	portrait.material = _hero_select_display_portrait_material()
	portrait.size = portrait_size
	# Move the portrait slightly upward and rightward. Compute the vertical
	# placement in viewport coordinates so the inset clipping does not shift it
	# down; the right shift lets the artwork meet/overlap the information panel.
	portrait.position = Vector2(
		(portrait_reference_width - portrait_size.x) * 0.5 + 58.0,
		size.y - portrait_size.y + 60.0 - layer.position.y
	)
	portrait.z_index = 1
	portrait.set_meta("hero_new_select_portrait", true)
	layer.add_child(portrait)
	hero_select_display_portrait = portrait

func _selected_hero() -> Dictionary:
	return HERO_CATALOG.definition_for(_selected_hero_id())

func _gui_input(event: InputEvent) -> void:
	if page != "title":
		return
	if TapAuthService.requires_taptap_login():
		return
	if not _is_title_start_input(event):
		return
	if event.is_pressed():
		if title_elapsed < TITLE_REVEAL_DURATION:
			title_start_input_held = true
		elif not title_start_input_held:
			_enter_from_title()
	else:
		title_start_input_held = false
	accept_event()

func _is_title_start_input(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		return true
	if event is InputEventMouseButton:
		return (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return key_event.keycode == KEY_ENTER or key_event.keycode == KEY_SPACE
	return false

func _create_button(title: String, subtitle: String, at: Vector2, callback: Callable, button_size: Vector2 = Vector2(340.0, 68.0), disabled: bool = false, font_size: int = 19, parent: Control = null, track_for_cleanup: bool = true) -> Button:
	var button := Button.new()
	button.text = title if subtitle.is_empty() else "%s\n%s" % [title, subtitle]
	button.position = at
	button.size = button_size
	button.disabled = disabled
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.clip_text = true
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color("f2e5c4"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color("829099"))
	button.add_theme_stylebox_override("normal", _make_box_style(PANEL_FILL, GOLD, 2))
	button.add_theme_stylebox_override("hover", _make_box_style(Color("1a2b33"), DRAGON_BLUE, 3))
	button.add_theme_stylebox_override("pressed", _make_box_style(Color("2e291d"), GOLD_BRIGHT, 3))
	button.add_theme_stylebox_override("disabled", _make_box_style(Color("131a1e"), Color("425058"), 1))
	button.pressed.connect(callback)
	if parent == null:
		add_child(button)
	else:
		button.z_index = 1
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		parent.add_child(button)
	if track_for_cleanup:
		buttons.append(button)
	return button

func _create_main_menu_button(title: String, icon_texture: Texture2D, at: Vector2, callback: Callable, button_size: Vector2) -> Button:
	var button := _create_button("", "", at, callback, button_size, false, 1)
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = title
	var transparent_style := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", transparent_style)
	button.add_theme_stylebox_override("hover", transparent_style)
	button.add_theme_stylebox_override("pressed", transparent_style)
	button.add_theme_stylebox_override("disabled", transparent_style)
	button.add_theme_stylebox_override("focus", transparent_style)

	var art := TextureRect.new()
	art.texture = MAIN_MENU_BUTTON_TEXTURE
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(art)

	var icon := TextureRect.new()
	icon.texture = icon_texture
	icon.position = Vector2(button_size.y * 0.17, -button_size.y * 0.065)
	icon.size = Vector2.ONE * button_size.y
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon)

	var label := Label.new()
	label.text = title
	label.position = Vector2(button_size.x * 0.16, button_size.y * 0.035)
	label.size = Vector2(button_size.x * 0.68, button_size.y - 4.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var font_variation := FontVariation.new()
	font_variation.base_font = KAITI_FONT
	font_variation.variation_embolden = 0.72
	label.add_theme_font_override("font", font_variation)
	label.add_theme_font_size_override("font_size", clampi(int(button_size.y * 0.44), 28, 44))
	label.add_theme_color_override("font_color", Color("ebc587"))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	button.add_child(label)

	button.mouse_entered.connect(func() -> void: button.modulate = Color(1.08, 1.08, 1.04, 1.0))
	button.mouse_exited.connect(func() -> void: button.modulate = Color.WHITE)
	button.button_down.connect(func() -> void: button.modulate = Color(0.82, 0.82, 0.78, 1.0))
	button.button_up.connect(func() -> void: button.modulate = Color(1.08, 1.08, 1.04, 1.0) if button.is_hovered() else Color.WHITE)
	return button

func _request_quit_game() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "退出游戏"
	dialog.dialog_text = "确认退出当前游戏？"
	dialog.ok_button_text = "确认退出"
	dialog.cancel_button_text = "取消"
	dialog.exclusive = true
	dialog.position = Vector2i((size.x - 360.0) * 0.5, (size.y - 180.0) * 0.5)
	dialog.size = Vector2i(360, 180)
	dialog.confirmed.connect(func() -> void: get_tree().quit())
	dialog.canceled.connect(func() -> void: dialog.queue_free())
	dialog.close_requested.connect(func() -> void: dialog.queue_free())
	add_child(dialog)
	page_controls.append(dialog)
	dialog.popup_centered()

func _create_page_scroll(viewport: Rect2, tooltip: String = "") -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.position = viewport.position
	scroll.size = viewport.size
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = int(PAGE_SCROLL_DRAG_THRESHOLD)
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.tooltip_text = tooltip
	scroll.gui_input.connect(_on_page_scroll_gui_input.bind(scroll))
	add_child(scroll)
	page_controls.append(scroll)
	return scroll

func _remember_shop_scroll(section: String) -> void:
	if section.is_empty():
		return
	for control in page_controls:
		if not is_instance_valid(control):
			continue
		if control is ScrollContainer:
			var scroll := control as ScrollContainer
			shop_scroll_positions[section] = scroll.scroll_vertical
			return

func _restore_shop_scroll(section: String, value: int, generation: int = -1) -> void:
	if generation >= 0 and generation != shop_build_id:
		return
	if page != "shop" or section != shop_section:
		return
	for control in page_controls:
		if not is_instance_valid(control):
			continue
		if control is ScrollContainer:
			var scroll := control as ScrollContainer
			if not scroll.is_inside_tree():
				continue
			var bar := scroll.get_v_scroll_bar()
			if not is_instance_valid(bar):
				continue
			var restored := clampi(value, int(bar.min_value), int(bar.max_value))
			scroll.scroll_vertical = restored
			shop_scroll_positions[section] = restored
			return

func _on_page_scroll_gui_input(event: InputEvent, scroll: ScrollContainer, source: Control = null) -> void:
	if not is_instance_valid(scroll):
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			page_scroll_touch_index = event.index
			page_scroll_drag_start = _page_scroll_event_position(event.position, scroll, source)
			page_scroll_drag_start_offset = Vector2(scroll.scroll_horizontal, scroll.scroll_vertical)
			page_scroll_dragging = false
		elif event.index == page_scroll_touch_index:
			if page_scroll_dragging:
				scroll.accept_event()
			page_scroll_touch_index = -1
			page_scroll_dragging = false
		return
	if event is InputEventScreenDrag and event.index == page_scroll_touch_index:
		if _update_page_scroll(scroll, _page_scroll_event_position(event.position, scroll, source)):
			scroll.accept_event()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			page_scroll_mouse_dragging = true
			page_scroll_drag_start = _page_scroll_event_position(event.position, scroll, source)
			page_scroll_drag_start_offset = Vector2(scroll.scroll_horizontal, scroll.scroll_vertical)
			page_scroll_dragging = false
		elif page_scroll_mouse_dragging:
			if page_scroll_dragging:
				scroll.accept_event()
			page_scroll_mouse_dragging = false
			page_scroll_dragging = false
		return
	if event is InputEventMouseMotion and page_scroll_mouse_dragging:
		if _update_page_scroll(scroll, _page_scroll_event_position(event.position, scroll, source)):
			scroll.accept_event()

func _page_scroll_event_position(position_in_source: Vector2, scroll: ScrollContainer, source: Control) -> Vector2:
	if not is_instance_valid(source):
		return position_in_source
	return scroll.get_global_transform_with_canvas().affine_inverse() * source.get_global_transform_with_canvas() * position_in_source
func _update_page_scroll(scroll: ScrollContainer, pointer_position: Vector2) -> bool:
	if not is_instance_valid(scroll):
		return false
	if not scroll.is_inside_tree():
		return false
	var delta := pointer_position - page_scroll_drag_start
	var horizontal_enabled := scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED
	var vertical_enabled := scroll.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED
	var drag_distance := 0.0
	if horizontal_enabled:
		drag_distance = maxf(drag_distance, absf(delta.x))
	if vertical_enabled:
		drag_distance = maxf(drag_distance, absf(delta.y))
	if not page_scroll_dragging and drag_distance < PAGE_SCROLL_DRAG_THRESHOLD:
		return false
	page_scroll_dragging = true
	var moved := false
	if horizontal_enabled:
		var hbar := scroll.get_h_scroll_bar()
		if is_instance_valid(hbar):
			var target_horizontal := clampf(page_scroll_drag_start_offset.x - delta.x, hbar.min_value, hbar.max_value)
			scroll.scroll_horizontal = int(round(target_horizontal))
			moved = true
	if vertical_enabled:
		var vbar := scroll.get_v_scroll_bar()
		if is_instance_valid(vbar):
			var target_vertical := clampf(page_scroll_drag_start_offset.y - delta.y, vbar.min_value, vbar.max_value)
			scroll.scroll_vertical = int(round(target_vertical))
			moved = true
	return moved

func _create_volume_slider(at: Vector2, value: float, tooltip: String, callback: Callable) -> HSlider:
	var slider := HSlider.new()
	slider.position = at
	slider.size = Vector2(356.0, 24.0)
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = value
	slider.tooltip_text = tooltip
	slider.value_changed.connect(callback)
	add_child(slider)
	setting_controls.append(slider)
	return slider

func _create_weather_selector(at: Vector2) -> OptionButton:
	var selector := OptionButton.new()
	var weather_modes: Array[String] = ["auto", "sunny", "rain", "storm", "snow"]
	var weather_labels: Array[String] = ["自动（每局随机）", "晴天", "雨天", "雷雨", "雪天"]
	var selected_mode := str(SaveService.setting_value("weather_mode", "auto"))
	selector.position = at
	selector.size = Vector2(356.0, 42.0)
	selector.tooltip_text = "战斗场景环境"
	selector.add_theme_font_size_override("font_size", 17)
	selector.add_theme_color_override("font_color", Color("f2e5c4"))
	selector.add_theme_stylebox_override("normal", _make_box_style(PANEL_FILL, GOLD, 2))
	selector.add_theme_stylebox_override("hover", _make_box_style(Color("1a2b33"), DRAGON_BLUE, 3))
	for index in range(weather_modes.size()):
		selector.add_item(weather_labels[index])
		if weather_modes[index] == selected_mode:
			selector.select(index)
	selector.item_selected.connect(_on_weather_mode_selected)
	add_child(selector)
	setting_controls.append(selector)
	return selector

func _set_button_owned_visual(button: Button) -> void:
	button.add_theme_color_override("font_color", GOLD_BRIGHT)
	button.add_theme_stylebox_override("normal", _make_box_style(Color("1b2a26"), GOLD_BRIGHT, 2))
	button.add_theme_stylebox_override("hover", _make_box_style(Color("25372f"), GOLD_BRIGHT, 3))
	button.add_theme_stylebox_override("pressed", _make_box_style(Color("313120"), GOLD_BRIGHT, 3))

func _set_button_locked_visual(button: Button) -> void:
	button.add_theme_color_override("font_color", Color("93a0a4"))
	button.add_theme_color_override("font_hover_color", Color("edf3f0"))
	button.add_theme_color_override("font_disabled_color", Color("6f7b80"))
	button.add_theme_stylebox_override("normal", _make_box_style(Color("11191d"), Color("435159"), 1))
	button.add_theme_stylebox_override("hover", _make_box_style(Color("17242a"), DRAGON_BLUE, 2))
	button.add_theme_stylebox_override("pressed", _make_box_style(Color("24271e"), GOLD, 2))
	button.add_theme_stylebox_override("disabled", _make_box_style(Color("11191d"), Color("37434a"), 1))

func _set_button_selected_visual(button: Button) -> void:
	button.add_theme_color_override("font_color", Color("fff2c4"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _make_box_style(Color("5a4520"), GOLD_BRIGHT, 3))
	button.add_theme_stylebox_override("hover", _make_box_style(Color("6d5425"), Color("fff0a8"), 3))
	button.add_theme_stylebox_override("pressed", _make_box_style(Color("473718"), Color("fff0a8"), 3))

func _tutorial_refresh_shop(generation: int = -1) -> void:
	if generation >= 0 and generation != shop_build_id:
		return
	_tutorial_refresh()

func _tutorial_refresh() -> void:
	_clear_tutorial_overlay()
	var stage := SaveService.tutorial_stage()
	if SaveService.tutorial_completed() or stage >= TUTORIAL_FINAL_STAGE:
		return
	var target: Control = null
	var message := str(TUTORIAL_HINTS.get(stage, ""))
	match stage:
		0:
			_tutorial_show_message(message, null, "", Callable())
			return
		1:
			if page == "main":
				target = _find_button_with_title("军需")
		2:
			if page == "shop" and shop_section == "heroes":
				_tutorial_show_message(message, null, "", Callable())
				return
		3:
			if page == "shop" and shop_section == "heroes":
				if SaveService.has_talent("guan_yu", "guan_drag_blade"):
					SaveService.set_tutorial_stage(6)
					call_deferred("_tutorial_refresh")
					return
				target = _find_button_with_title("拖刀计")
		4:
			if page == "shop" and shop_section == "heroes" and is_instance_valid(talent_detail_dialog):
				_tutorial_show_message(message, null, "", Callable())
				return
		5:
			if page == "shop" and shop_section == "heroes" and is_instance_valid(talent_detail_dialog):
				target = _find_button_with_prefix("购买")
		6:
			if page == "shop" and shop_section == "heroes":
				target = _find_button_with_title("张飞")
		7:
			if page == "shop" and shop_section == "heroes":
				if SaveService.has_talent("zhang_fei", "zhang_slam_leap"):
					SaveService.set_tutorial_stage(10)
					call_deferred("_tutorial_refresh")
					return
				target = _find_button_with_title("丈八跃砸·跃步")
		8:
			if page == "shop" and shop_section == "heroes" and is_instance_valid(talent_detail_dialog):
				_tutorial_show_message(message, null, "", Callable())
				return
		9:
			if page == "shop" and shop_section == "heroes" and is_instance_valid(talent_detail_dialog):
				target = _find_button_with_prefix("购买")
		10:
			if page == "shop" and shop_section == "heroes":
				target = _find_button_with_title("军略")
		11:
			if page == "shop" and shop_section == "strategies":
				_tutorial_show_message(message, null, "", Callable())
				return
		12:
			if page == "shop" and shop_section == "strategies":
				target = _find_button_with_title("天机")
		13:
			if page == "shop" and shop_section == "tianji":
				_tutorial_show_message(message, null, "", Callable())
				return
		14:
			if page == "shop" and shop_section == "tianji":
				target = _find_button_with_title("返回")
		15:
			if page == "main":
				target = _find_button_with_title("出征")
		16:
			if page == "expedition" and expedition_tab == "story":
				target = _find_button_with_title("新野练兵")
		17:
			if page == "expedition" and expedition_tab == "story":
				target = _find_button_with_title("出征")
		18:
			if page == "hero_select":
				_tutorial_show_message(message, null, "", Callable())
				return
		19:
			if page == "hero_select":
				target = _find_button_with_title("出征")
	if target != null:
		_tutorial_show_for_control(target, message)

func _tutorial_stage_has_next(stage: int) -> bool:
	return stage in [0, 2, 4, 8, 11, 13, 18]

func _tutorial_next_stage() -> void:
	var stage := SaveService.tutorial_stage()
	if not _tutorial_stage_has_next(stage):
		return
	if stage == 0:
		call_deferred("_tutorial_begin")
		return
	SaveService.set_tutorial_stage(stage + 1)
	call_deferred("_tutorial_refresh")

func _tutorial_begin() -> void:
	SaveService.set_tutorial_stage(1)
	_show_main()

func _restart_tutorial_from_menu() -> void:
	SaveService.restart_tutorial()
	selected_shop_hero_id = "guan_yu"
	selected_story_chapter_id = "story_01"
	_show_main()

func _skip_tutorial() -> void:
	if SaveService.tutorial_completed():
		return
	SaveService.complete_tutorial()
	# Let the pressed signal finish before rebuilding the page and queuing the
	# overlay controls for deletion. This avoids mutating the signal source.
	call_deferred("_show_main")

func _is_desktop_build() -> bool:
	return OS.has_feature("pc")

func _resume_tutorial_talent(hero_id: String, talent_id: String) -> void:
	if page == "shop" and shop_section == "heroes" and SaveService.tutorial_stage() in [4, 5, 8, 9]:
		selected_shop_hero_id = hero_id
		selected_shop_talent_id = talent_id
		_show_shop_item_detail(talent_id)

func _tutorial_show_for_control(control: Control, message: String) -> void:
	if not is_instance_valid(control):
		return
	_tutorial_show_message(message, control, "", Callable())

func _tutorial_show_message(message: String, target: Control, action_title: String, action: Callable) -> void:
	_clear_tutorial_overlay()
	tutorial_overlay = ColorRect.new()
	# Keep the full-screen container transparent. Dimming is drawn only by the
	# blocker rectangles, so the highlighted target remains visually clear.
	tutorial_overlay.color = Color.TRANSPARENT
	tutorial_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# The overlay itself stays transparent to input. Four blocker controls below
	# it intercept everything except the highlighted target's click-through hole.
	tutorial_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_overlay.z_index = 40
	add_child(tutorial_overlay)
	var target_local_rect := Rect2()
	if target != null:
		target_local_rect = Rect2(target.get_global_rect().position - tutorial_overlay.global_position, target.get_global_rect().size)
	var special_hero_select := page == "hero_select" and SaveService.tutorial_stage() in [18, 19]
	if special_hero_select:
		# The hero-select tutorial only locks the upper-left Back button.
		# Hero cards and the information panel remain visible and interactive.
		var back_button := _find_button_with_title("返回")
		if back_button != null:
			var back_rect := back_button.get_global_rect()
			_add_tutorial_blocker(Rect2(back_rect.position - tutorial_overlay.global_position, back_rect.size))
	elif target != null:
		var overlay_rect := Rect2(Vector2.ZERO, size)
		var target_rect := target.get_global_rect()
		var hole := Rect2(target_rect.position - tutorial_overlay.global_position, target_rect.size)
		hole = hole.intersection(overlay_rect)
		_add_tutorial_blocker(Rect2(0.0, 0.0, size.x, maxf(0.0, hole.position.y)))
		_add_tutorial_blocker(Rect2(0.0, hole.end.y, size.x, maxf(0.0, size.y - hole.end.y)))
		_add_tutorial_blocker(Rect2(0.0, hole.position.y, maxf(0.0, hole.position.x), hole.size.y))
		_add_tutorial_blocker(Rect2(hole.end.x, hole.position.y, maxf(0.0, size.x - hole.end.x), hole.size.y))
	else:
		_add_tutorial_blocker(Rect2(0.0, 0.0, size.x, size.y))
	var has_next := _tutorial_stage_has_next(SaveService.tutorial_stage())
	var panel_width := minf(700.0, maxf(120.0, size.x - 48.0))
	if special_hero_select:
		panel_width = minf(540.0, maxf(120.0, size.x - 48.0))
	var wrapped_message := _wrap_tutorial_text(message, panel_width - 44.0, 19)
	var message_line_count := maxi(1, wrapped_message.count("\n") + 1)
	var base_panel_height := 184.0 if has_next else (126.0 if action_title.is_empty() else 174.0)
	# Reserve enough vertical space for every wrapped line plus the bottom
	# controls. The cap keeps the panel inside compact mobile viewports.
	var panel_height := maxf(base_panel_height, 72.0 + float(message_line_count) * 25.0 + 8.0)
	panel_height = minf(panel_height, maxf(126.0, size.y - 48.0))
	var panel_size := Vector2(panel_width, panel_height)
	tutorial_panel = Panel.new()
	var panel_position := _tutorial_panel_position(panel_size, target_local_rect)
	if special_hero_select:
		# Keep the hero details and roster readable while the player chooses a
		# hero. The Back button is the only control locked on this page.
		panel_position = Vector2(
			maxf(24.0, (size.x - panel_size.x) * 0.5),
			maxf(24.0, size.y - panel_size.y - 24.0)
		)
	tutorial_panel.position = panel_position
	tutorial_panel.size = panel_size
	tutorial_panel.z_index = 1
	tutorial_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE if special_hero_select else Control.MOUSE_FILTER_STOP
	tutorial_panel.add_theme_stylebox_override("panel", _make_box_style(Color("17242a"), GOLD_BRIGHT, 2))
	tutorial_overlay.add_child(tutorial_panel)
	var label := Label.new()
	label.text = wrapped_message
	label.position = Vector2(22.0, 16.0)
	# Leave a dedicated bottom row for the navigation controls so wrapped text
	# cannot collide with “下一步>” or “跳过>>”.
	label.size = Vector2(panel_size.x - 44.0, maxf(24.0, panel_size.y - 80.0))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 19)
	label.add_theme_color_override("font_color", Color("e4eee9"))
	label.clip_text = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_panel.add_child(label)
	if not action_title.is_empty():
		var action_button := _create_button(action_title, "", Vector2((panel_size.x - 220.0) * 0.5, panel_size.y - 58.0), action, Vector2(220.0, 42.0), false, 16, tutorial_panel, false)
		action_button.z_index = 2
	if _tutorial_stage_has_next(SaveService.tutorial_stage()):
		var next_button := _create_button("下一步>", "", Vector2(22.0, panel_size.y - 52.0), _tutorial_next_stage, Vector2(132.0, 40.0), false, 15, tutorial_panel, false)
		next_button.z_index = 2
		next_button.add_theme_color_override("font_color", GOLD_BRIGHT)
		next_button.add_theme_stylebox_override("normal", _make_box_style(Color("1b2a26"), GOLD_BRIGHT, 2))
		next_button.add_theme_stylebox_override("hover", _make_box_style(Color("25372f"), Color("fff0a8"), 3))
	if target != null:
		tutorial_target_original_z_index = target.z_index
		tutorial_target_original_mouse_filter = target.mouse_filter
		target.z_index = maxi(target.z_index, 60)
		target.mouse_filter = Control.MOUSE_FILTER_STOP
		if target is Button:
			_set_button_selected_visual(target as Button)
		_create_tutorial_target_highlight(target)
	tutorial_target = target
	tutorial_skip_button = _create_button("跳过>>", "", Vector2(panel_size.x - 154.0, panel_size.y - 52.0), _skip_tutorial, Vector2(132.0, 40.0), false, 15, tutorial_panel, false)
	tutorial_skip_button.z_index = 2
	tutorial_skip_button.mouse_filter = Control.MOUSE_FILTER_STOP
	tutorial_skip_button.add_theme_color_override("font_color", GOLD_BRIGHT)
	tutorial_skip_button.add_theme_stylebox_override("normal", _make_box_style(Color("2a2115"), GOLD_BRIGHT, 2))
	tutorial_skip_button.add_theme_stylebox_override("hover", _make_box_style(Color("4b351a"), Color("fff0a8"), 3))

func _add_tutorial_blocker(rect: Rect2) -> void:
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var blocker := ColorRect.new()
	blocker.position = rect.position
	blocker.size = rect.size
	blocker.color = Color(0.08, 0.10, 0.11, 0.70)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	blocker.z_index = 1
	tutorial_overlay.add_child(blocker)

func _clear_tutorial_overlay() -> void:
	if is_instance_valid(tutorial_target):
		tutorial_target.z_index = tutorial_target_original_z_index
		tutorial_target.mouse_filter = tutorial_target_original_mouse_filter
	if is_instance_valid(tutorial_overlay):
		var overlay_parent := tutorial_overlay.get_parent()
		if overlay_parent != null:
			overlay_parent.remove_child(tutorial_overlay)
		if not tutorial_overlay.is_queued_for_deletion():
			tutorial_overlay.queue_free()
	if is_instance_valid(tutorial_skip_button) and tutorial_skip_button.get_parent() != tutorial_overlay:
		var skip_parent := tutorial_skip_button.get_parent()
		if skip_parent != null:
			skip_parent.remove_child(tutorial_skip_button)
		if not tutorial_skip_button.is_queued_for_deletion():
			tutorial_skip_button.queue_free()
	if is_instance_valid(tutorial_target_highlight):
		var highlight_parent := tutorial_target_highlight.get_parent()
		if highlight_parent != null:
			highlight_parent.remove_child(tutorial_target_highlight)
		if not tutorial_target_highlight.is_queued_for_deletion():
			tutorial_target_highlight.queue_free()
	tutorial_overlay = null
	tutorial_panel = null
	tutorial_target = null
	tutorial_skip_button = null
	tutorial_target_highlight = null
	tutorial_highlight_elapsed = 0.0

func _create_tutorial_target_highlight(target: Control) -> void:
	if not is_instance_valid(target):
		return
	var rect := target.get_global_rect()
	tutorial_target_highlight = Panel.new()
	tutorial_target_highlight.position = rect.position - global_position - Vector2(6.0, 6.0)
	tutorial_target_highlight.size = rect.size + Vector2(12.0, 12.0)
	tutorial_target_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_target_highlight.z_index = 70
	tutorial_target_highlight.modulate.a = 0.9
	tutorial_target_highlight.add_theme_stylebox_override("panel", UITheme.flat_box_style(Color.TRANSPARENT, GOLD_BRIGHT, 3))
	add_child(tutorial_target_highlight)
	tutorial_highlight_elapsed = 0.0

func _tutorial_panel_position(panel_size: Vector2, target_rect: Rect2, skip_rect: Rect2 = Rect2()) -> Vector2:
	var margin := 24.0
	var centered_x := (size.x - panel_size.x) * 0.5
	# Keep the panel clear of the target while fitting every viewport.
	var top_y := 76.0
	var bottom_y := size.y - panel_size.y - margin
	var target_center_y := target_rect.get_center().y if target_rect.has_area() else size.y * 0.5
	var side_y := clampf(target_center_y - panel_size.y * 0.5, margin, size.y - panel_size.y - margin)
	var candidates: Array[Vector2] = [
		Vector2(centered_x, top_y),
		Vector2(centered_x, bottom_y),
		Vector2(margin, side_y),
		Vector2(size.x - panel_size.x - margin, side_y),
	]
	for candidate in candidates:
		var panel_rect := Rect2(candidate, panel_size)
		if panel_rect.position.x < margin or panel_rect.end.x > size.x - margin:
			continue
		if panel_rect.position.y < margin or panel_rect.end.y > size.y - margin:
			continue
		if target_rect.has_area() and panel_rect.grow(8.0).intersects(target_rect):
			continue
		if skip_rect.has_area() and panel_rect.grow(4.0).intersects(skip_rect):
			continue
		return candidate
	return Vector2(centered_x, clampf(top_y, margin, size.y - panel_size.y - margin))

func _find_button_with_title(title: String) -> Button:
	return _find_button_in(self, title)

func _find_button_with_prefix(prefix: String) -> Button:
	return _find_button_prefix_in(self, prefix)

func _find_button_in(node: Node, title: String) -> Button:
	for child in node.get_children():
		if child is Button:
			var button := child as Button
			if button.text.split("\n")[0] == title:
				return button
		var nested := _find_button_in(child, title)
		if nested != null:
			return nested
	return null

func _find_button_prefix_in(node: Node, prefix: String) -> Button:
	for child in node.get_children():
		if child is Button:
			var button := child as Button
			if button.text.begins_with(prefix):
				return button
		var nested := _find_button_prefix_in(child, prefix)
		if nested != null:
			return nested
	return null

func _clear_buttons(preserve_expedition_plates: bool = false) -> void:
	for plate in expedition_exiting_plates:
		if is_instance_valid(plate):
			plate.queue_free()
	expedition_exiting_plates.clear()
	title_login_button = null
	_clear_tutorial_overlay()
	talent_detail_dialog = null
	strategy_detail_dialog = null
	tianji_detail_dialog = null
	battle_soul_detail_dialog = null
	strategy_detail_notice = ""
	tianji_detail_notice = ""
	page_scroll_touch_index = -1
	page_scroll_dragging = false
	page_scroll_mouse_dragging = false
	hero_select_touch_index = -1
	hero_select_mouse_dragging = false
	if is_instance_valid(hero_select_portrait_layer):
		hero_select_portrait_layer.visible = false
		for child in hero_select_portrait_layer.get_children():
			if child is CanvasItem:
				(child as CanvasItem).visible = false
	for control in page_controls:
		if preserve_expedition_plates and control in expedition_nameplates:
			continue
		if is_instance_valid(control):
			control.visible = false
			if control.get_parent() != null:
				control.get_parent().remove_child(control)
			control.queue_free()
	page_controls.clear()
	expedition_nameplates.clear()
	hero_select_portrait_layer = null
	hero_select_info_overlay = null
	hero_select_display_portrait = null
	for button in buttons:
		if is_instance_valid(button):
			if button.get_parent() != null:
				button.get_parent().remove_child(button)
			button.queue_free()
	buttons.clear()
	for control in setting_controls:
		if is_instance_valid(control):
			control.queue_free()
	setting_controls.clear()
	music_value_label = null
	sfx_value_label = null

func _rebuild_current_page() -> void:
	match page:
		"title": _show_title()
		"modes", "expedition": _show_expedition(expedition_tab)
		"hero_select": _show_hero_select(selected_run_mode, selected_run_battlefield_id, hero_select_return_tab, true)
		"shop": _show_shop(shop_section)
		"settings": _show_settings()
		"hero_details": _show_hero_details()
		_: _show_main()

func _safe_margin() -> float:
	return clampf(minf(size.x, size.y) * 0.045, 24.0, 56.0)

func _draw() -> void:
	if page == "title":
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		_draw_title_screen(ThemeDB.fallback_font)
		return
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if page == "expedition":
		_draw_expedition_background()
	elif page == "shop":
		draw_texture_rect(SHOP_BACKGROUND_TEXTURE, _shop_background_rect(), false)
	elif page == "hero_select":
		var art_size := HERO_SELECT_BACKGROUND_TEXTURE.get_size()
		var art_scale := maxf(size.x / art_size.x, size.y / art_size.y)
		var draw_size := art_size * art_scale
		draw_texture_rect(HERO_SELECT_BACKGROUND_TEXTURE, Rect2((size - draw_size) * 0.5, draw_size), false)
	else:
		_draw_non_combat_background(Rect2(Vector2.ZERO, size))
	var font := ThemeDB.fallback_font
	var margin := _safe_margin()
	if page == "shop":
		_draw_shop_merit_currency(font, margin)
	match page:
		"main": _draw_main(font)
		#"modes", "expedition": _draw_expedition(font)
		"hero_select": _draw_hero_select(font)
		"shop": _draw_shop(font)
		"settings": _draw_settings(font)
		"hero_details": _draw_hero_details(font)
	if not notice.is_empty():
		draw_string(font, Vector2(size.x * 0.5 - 156.0, size.y - 34.0), notice, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("9ee0c6"))
	if title_menu_fade_remaining > 0.0:
		var fade_alpha := clampf(title_menu_fade_remaining / TITLE_MENU_FADE_DURATION, 0.0, 1.0)
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, fade_alpha))

func _draw_shop_merit_currency(font: Font, margin: float) -> void:
	var texture_size := SHOP_MERIT_TEXTURE.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var target_height := 39.0
	if size.x < 900.0:
		target_height = 31.0
	var target_size := texture_size * (target_height / texture_size.y)
	var currency_rect := Rect2(Vector2(size.x - margin - target_size.x, 28.0), target_size)
	draw_texture_rect(SHOP_MERIT_TEXTURE, currency_rect, false)
	var merit_text := _format_merit_amount(int(profile.get("military_merit", 0)))
	var number_rect := Rect2(currency_rect.position.x + target_size.x * 0.40, currency_rect.position.y + target_size.y * 0.62, target_size.x * 0.51, target_size.y * 0.76)
	draw_string_outline(font, number_rect.position, merit_text, HORIZONTAL_ALIGNMENT_CENTER, number_rect.size.x, 20 if target_height >= 39.0 else 17, 3, Color("11191f", 0.92))
	draw_string(font, number_rect.position, merit_text, HORIZONTAL_ALIGNMENT_CENTER, number_rect.size.x, 20 if target_height >= 39.0 else 17, GOLD_BRIGHT)

func _format_merit_amount(amount: int) -> String:
	var digits := str(maxi(0, amount))
	var grouped := ""
	while digits.length() > 3:
		grouped = "," + digits.substr(digits.length() - 3, 3) + grouped
		digits = digits.substr(0, digits.length() - 3)
	return digits + grouped

func _draw_main(_font: Font) -> void:
	# 首页由主背景、边框与四个入口按钮构成，不再叠加文字标题，避免遮挡画面主体。
	pass

func _draw_non_combat_background(rect: Rect2) -> void:
	var texture_size := NON_COMBAT_FRAME_TEXTURE.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var scale_factor := maxf(rect.size.x / texture_size.x, rect.size.y / texture_size.y)
	var draw_size := texture_size * scale_factor
	var draw_rect := Rect2(rect.get_center() - draw_size * 0.5, draw_size)
	draw_texture_rect(NON_COMBAT_FRAME_TEXTURE, draw_rect, false)

func _draw_title_screen(font: Font) -> void:
	var intro_progress := clampf(title_elapsed / TITLE_INTRO_DURATION, 0.0, 1.0)
	var intro_eased := 1.0 - pow(1.0 - intro_progress, 3.0)
	var reveal_progress := clampf(title_elapsed / TITLE_REVEAL_DURATION, 0.0, 1.0)
	var reveal_eased := 1.0 - pow(1.0 - reveal_progress, 3.0)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.012, 0.016, 0.018, 0.22))
	var logo_size := minf(size.y * 0.46, size.x * 0.30)
	var logo_center := Vector2(size.x * 0.76, size.y * 0.39)
	var logo_rect := Rect2(logo_center - Vector2.ONE * logo_size * 0.5, Vector2.ONE * logo_size)
	draw_texture_rect(TITLE_LOGO_TEXTURE, Rect2(logo_rect.position + Vector2(5.0, 8.0), logo_rect.size), false, Color(0.0, 0.0, 0.0, intro_eased * 0.42))
	draw_texture_rect(TITLE_LOGO_TEXTURE, logo_rect, false, Color(1.0, 0.98, 0.92, intro_eased))
	var pulse_phase := (sin(title_elapsed * 3.1) + 1.0) * 0.5
	var pulse := 0.44 + 0.56 * pulse_phase
	var prompt_color := Color(0.84, 0.62, 0.30, pulse).lerp(Color(1.0, 0.94, 0.66, pulse), pulse_phase)
	var prompt_font_size := 24 if size.x >= 720.0 else 20
	var prompt_y := size.y * 0.79
	var prompt_center_x := size.x * 0.76
	var prompt_text := TITLE_PROMPT_TEXT
	if TapAuthService.requires_taptap_login():
		prompt_text = title_status if not title_status.is_empty() else ""
	var prompt_width := font.get_string_size(prompt_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, prompt_font_size).x
	var prompt_left := prompt_center_x - prompt_width * 0.5
	if not prompt_text.is_empty():
		var short_line_gap := 22.0
		var short_line_width := 42.0
		var guide_y := prompt_y - 13.0
		var guide_color := Color(prompt_color.r, prompt_color.g, prompt_color.b, 0.30 + pulse_phase * 0.62)
		var guide_width := 1.1 + pulse_phase * 1.0
		draw_line(Vector2(prompt_left - short_line_gap - short_line_width, guide_y), Vector2(prompt_left - short_line_gap, guide_y), guide_color, guide_width)
		draw_line(Vector2(prompt_center_x + prompt_width * 0.5 + short_line_gap, guide_y), Vector2(prompt_center_x + prompt_width * 0.5 + short_line_gap + short_line_width, guide_y), guide_color, guide_width)
		var blade_center := Vector2(prompt_center_x, guide_y)
		draw_line(blade_center - Vector2(4.0, 0.0), blade_center + Vector2(4.0, 0.0), Color(1.0, 0.82, 0.44, 0.38 + pulse_phase * 0.54), guide_width + 0.3)
		draw_line(blade_center - Vector2(2.4, 2.4), blade_center + Vector2(2.4, 2.4), Color(1.0, 0.82, 0.44, 0.22 + pulse_phase * 0.54), guide_width)
		draw_string_outline(font, Vector2(prompt_left, prompt_y), prompt_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, prompt_font_size, 4, Color(1.0, 0.57, 0.18, 0.10 + pulse_phase * 0.32))
		draw_string(font, Vector2(prompt_left, prompt_y), prompt_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, prompt_font_size, prompt_color)
	_draw_health_game_notice(font, reveal_eased, prompt_center_x)
	if reveal_progress < 1.0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 1.0 - reveal_eased))
	if title_enter_seal_remaining > 0.0:
		_draw_title_enter_seal(Vector2(prompt_center_x, size.y * 0.5))

func _draw_health_game_notice(font: Font, alpha: float, center_x: float) -> void:
	var bottom_inset := maxf(28.0, _safe_margin())
	var font_size := HEALTH_GAME_NOTICE_FONT_SIZE if size.x >= 720.0 else 12
	var line_height := HEALTH_GAME_NOTICE_LINE_HEIGHT if size.x >= 720.0 else 17.0
	var line_count := HEALTH_GAME_NOTICE_LINES.size() + 1
	var total_height := float(line_count - 1) * line_height + float(font_size)
	var first_baseline := size.y - bottom_inset - total_height + float(font_size)
	var content_width := clampf(size.x * 0.42, 220.0, 520.0)
	content_width = minf(content_width, maxf(160.0, size.x - bottom_inset * 2.0))
	var left := clampf(center_x - content_width * 0.5, bottom_inset, size.x - bottom_inset - content_width)
	var title_color := Color(0.96, 0.88, 0.68, alpha * 0.92)
	var body_color := Color(0.88, 0.91, 0.89, alpha * 0.78)
	draw_string(font, Vector2(left, first_baseline), HEALTH_GAME_NOTICE_TITLE, HORIZONTAL_ALIGNMENT_CENTER, content_width, font_size, title_color)
	for index in range(HEALTH_GAME_NOTICE_LINES.size()):
		var baseline := first_baseline + float(index + 1) * line_height
		draw_string(font, Vector2(left, baseline), HEALTH_GAME_NOTICE_LINES[index], HORIZONTAL_ALIGNMENT_CENTER, content_width, font_size, body_color)

func _setup_title_video_player() -> void:
	title_video_player = VideoStreamPlayer.new()
	title_video_player.stream = TITLE_VIDEO_STREAM
	title_video_player.expand = true
	title_video_player.loop = true
	title_video_player.volume = -80.0
	title_video_player.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_video_player.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_video_player.show_behind_parent = true
	title_video_player.z_index = -19
	title_video_player.hide()
	add_child(title_video_player)

func _play_title_video() -> void:
	if title_video_player == null:
		return
	title_video_player.show()
	title_video_player.stop()
	title_video_player.play()

func _stop_title_video() -> void:
	if title_video_player == null:
		return
	title_video_player.stop()
	title_video_player.hide()

func _draw_title_enter_seal(center: Vector2) -> void:
	var progress := 1.0 - title_enter_seal_remaining / TITLE_ENTER_SEAL_DURATION
	var eased := 1.0 - pow(1.0 - progress, 3.0)
	var flash_alpha := (1.0 - eased) * 0.46
	var seal_center := Vector2(center.x, size.y * 0.64)
	var half_width := lerpf(20.0, 112.0, eased)
	var half_height := lerpf(12.0, 58.0, eased)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.98, 0.49, 0.12, flash_alpha * 0.16))
	draw_rect(Rect2(seal_center - Vector2(half_width, half_height), Vector2(half_width * 2.0, half_height * 2.0)), Color(1.0, 0.77, 0.34, flash_alpha), false, 2.2)
	draw_line(seal_center - Vector2(half_width * 0.74, 0.0), seal_center + Vector2(half_width * 0.74, 0.0), Color(1.0, 0.85, 0.48, flash_alpha), 1.6)
	draw_line(seal_center - Vector2(0.0, half_height * 0.66), seal_center + Vector2(0.0, half_height * 0.66), Color(1.0, 0.68, 0.26, flash_alpha * 0.82), 1.6)
	for index in range(6):
		var angle := TAU * float(index) / 6.0 + PI * 0.5
		var direction := Vector2.from_angle(angle)
		var start := seal_center + direction * (half_width * 0.72)
		var finish := seal_center + direction * (half_width + 32.0 + eased * 42.0)
		draw_line(start, finish, Color(1.0, 0.69, 0.28, flash_alpha * 0.76), 1.2)

func _draw_hero_select(_font: Font) -> void:
	# The information panel is drawn by HeroSelectInfoOverlay so it can sit
	# above the full-body portrait without changing the page background order.
	var layout := _hero_select_layout()
	var model_rect: Rect2 = layout.get("model", Rect2())
	var hero_id := _selected_hero_id()
	if hero_id != "huang_zhong" and not _hero_has_idle_preview(hero_id):
		draw_string(KAITI_FONT, model_rect.get_center() + Vector2(-88.0, 12.0), "待机动画待补", HORIZONTAL_ALIGNMENT_CENTER, 176.0, 16, MUTED)

func _draw_hero_select_stat_bars(info_rect: Rect2, stats: Dictionary, canvas: Control = null) -> void:
	var target := self if canvas == null else canvas
	var rows := [
		["攻击", float(stats.get("attack", 0.0)), 40.0],
		["防御", float(stats.get("defense", 0.0)), 40.0],
		["生命", float(stats.get("health", 0.0)), 220.0],
		["移速", float(stats.get("move_speed", 0.0)), 140.0],
	]
	var bar_x := info_rect.position.x + 52.0
	var value_width := 36.0
	var bar_width := maxf(42.0, info_rect.size.x - 52.0 - value_width)
	var top := info_rect.position.y + 38.0
	var row_gap := clampf((info_rect.size.y - 50.0) / float(rows.size()), 23.0, 31.0)
	var fill_progress := 1.0 - pow(1.0 - clampf(hero_select_stat_fill_progress, 0.0, 1.0), 3.0)
	var bar_height := 12.0
	var tip := 5.0
	for index in range(rows.size()):
		var row: Array = rows[index]
		var y := top + float(index) * row_gap
		var value := float(row[1])
		var cap := float(row[2])
		var ratio := clampf(value / maxf(1.0, cap), 0.0, 1.0)
		var animated_ratio := ratio * fill_progress
		target.draw_string(KAITI_FONT, Vector2(info_rect.position.x, y + 12.0), str(row[0]), HORIZONTAL_ALIGNMENT_LEFT, 46.0, 13, Color("adc1c5"))
		var track := _hero_select_stat_bar_polygon(bar_x, y, bar_width, bar_height, tip)
		target.draw_colored_polygon(track, Color("22343b", 0.94))
		var fill_width := bar_width * animated_ratio
		if fill_width > 0.5:
			var fill := _hero_select_stat_bar_polygon(bar_x, y, fill_width, bar_height, minf(tip, fill_width * 0.28))
			target.draw_colored_polygon(fill, Color("c28c43", 0.96))
			var segment_count := 12
			var segment_start := bar_x + minf(tip, fill_width * 0.28)
			var segment_end := bar_x + fill_width - minf(tip, fill_width * 0.28)
			if segment_end > segment_start:
				for segment_index in range(segment_count):
					var from_ratio := float(segment_index) / float(segment_count)
					var to_ratio := float(segment_index + 1) / float(segment_count)
					var segment_x := lerpf(segment_start, segment_end, from_ratio)
					var segment_width := maxf(0.5, lerpf(segment_start, segment_end, to_ratio) - segment_x)
					var segment_color := Color("9e6c2f").lerp(Color("ffe8a3"), from_ratio)
					target.draw_rect(Rect2(segment_x, y + 2.0, segment_width, bar_height - 4.0), segment_color, true)
		target.draw_string(KAITI_FONT, Vector2(info_rect.end.x - value_width, y + 12.0), "%.0f" % value, HORIZONTAL_ALIGNMENT_RIGHT, value_width, 13, Color("f2e5c4"))

func _hero_select_stat_bar_polygon(x: float, y: float, width: float, height: float, tip: float) -> PackedVector2Array:
	var safe_width := maxf(1.0, width)
	var safe_tip := minf(maxf(0.0, tip), safe_width * 0.45)
	return PackedVector2Array([
		Vector2(x + safe_tip, y),
		Vector2(x + safe_width - safe_tip, y),
		Vector2(x + safe_width, y + height * 0.5),
		Vector2(x + safe_width - safe_tip, y + height),
		Vector2(x + safe_tip, y + height),
		Vector2(x, y + height * 0.5),
	])

func _populate_hero_select_slot_content(slot_rect: Rect2, hero: Dictionary, selected: bool, available: bool) -> void:
	var hero_name := str(hero.get("name", "武将"))
	var hero_id := str(hero.get("id", ""))
	var name_color := GOLD_BRIGHT if selected else (Color("d6e3e0") if available else Color("79878d"))
	_create_hero_select_slot_label(hero_name, Rect2(slot_rect.position + Vector2(4.0, 6.0), Vector2(slot_rect.size.x - 8.0, 24.0)), name_color, 19)
	if not available:
		_create_hero_select_slot_label("敬请期待", Rect2(slot_rect.position + Vector2(4.0, 35.0), Vector2(slot_rect.size.x - 8.0, 20.0)), Color("849198"), 14)
		return
	if not selected:
		_create_hero_select_idle_sprite(slot_rect, hero_id, false)
		return
	_create_hero_select_idle_sprite(slot_rect, hero_id, true)

func _create_hero_select_slot_label(label_text: String, label_rect: Rect2, color: Color, font_size: int) -> void:
	var label := Label.new()
	label.text = label_text
	label.position = label_rect.position
	label.size = label_rect.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 17
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	page_controls.append(label)

func _hero_select_idle_visible_bounds(hero_id: String, texture: Texture2D) -> Rect2:
	if texture == null:
		return Rect2(Vector2.ZERO, Vector2.ONE)
	var key := "%s:%s" % [hero_id, texture.resource_path]
	if hero_select_idle_bounds_cache.has(key):
		return hero_select_idle_bounds_cache[key] as Rect2
	var image := texture.get_image()
	if image == null or image.is_empty():
		return Rect2(Vector2.ZERO, texture.get_size())
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.05:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	var bounds := Rect2(Vector2.ZERO, texture.get_size()) if max_x < 0 else Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x + 1, max_y - min_y + 1))
	hero_select_idle_bounds_cache[key] = bounds
	return bounds

func _create_hero_select_idle_sprite(slot_rect: Rect2, hero_id: String, animated: bool, compact: bool = false) -> void:
	if not _hero_has_idle_preview(hero_id):
		return
	var model_area := Control.new()
	if compact:
		model_area.position = slot_rect.position
		model_area.size = slot_rect.size
	else:
		model_area.position = slot_rect.position + Vector2(0.0, HERO_SELECT_IDLE_MODEL_TOP)
		model_area.size = Vector2(slot_rect.size.x, maxf(0.0, slot_rect.size.y - HERO_SELECT_IDLE_MODEL_TOP - HERO_SELECT_IDLE_MODEL_BOTTOM_GAP))
	model_area.clip_contents = true
	model_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	model_area.z_index = 17
	add_child(model_area)
	page_controls.append(model_area)

	var sprite := TextureRect.new()
	sprite.texture = _hero_select_idle_texture(hero_id, animated)
	var base_size := Vector2(model_area.size.x * 0.78, model_area.size.y * 0.82)
	var texture_size := sprite.texture.get_size() if sprite.texture != null else Vector2(128.0, 96.0)
	var reference_bounds := _hero_select_idle_visible_bounds("guan_yu", GUAN_YU_SELECT_IDLE_TEXTURES[0] as Texture2D)
	var current_bounds := _hero_select_idle_visible_bounds(hero_id, sprite.texture)
	var reference_height := maxf(1.0, reference_bounds.size.y)
	var current_height := maxf(1.0, current_bounds.size.y)
	# Normalize by opaque-pixel height, not the source canvas height. This keeps
	# Zhang Fei and Zhao Yun visually as tall as Guan Yu despite different frame canvases.
	var visual_scale := reference_height / current_height
	# The central stage is 1.15x larger than the roster previews, keeping the
	# character grounded without letting the Q model dominate the scene.
	if compact:
		visual_scale *= 1.15
	visual_scale *= HERO_SELECT_IDLE_VISUAL_SCALE
	sprite.size = base_size * visual_scale
	var visible_bottom := current_bounds.position.y + current_bounds.size.y
	var canvas_bottom := maxf(1.0, texture_size.y)
	var bottom_gap_ratio := clampf((canvas_bottom - visible_bottom) / canvas_bottom, 0.0, 0.45)
	var baseline_y := model_area.size.y - model_area.size.y * 0.08
	var bottom_padding := float(HERO_SELECT_IDLE_BOTTOM_PADDING.get(hero_id, 12.0))
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var lift := model_area.size.y * 0.08 if compact else 0.0
	var visible_bottom_offset := sprite.size.y * (1.0 - bottom_gap_ratio)
	var vertical_offset := float(HERO_SELECT_IDLE_VERTICAL_OFFSETS.get(hero_id, 0.0))
	sprite.position = Vector2(
		(model_area.size.x - sprite.size.x) * 0.5,
		baseline_y - visible_bottom_offset + bottom_padding - lift + vertical_offset
	)
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	model_area.add_child(sprite)
	if animated:
		hero_select_idle_sprite = sprite

func _update_hero_select_idle_sprite() -> void:
	if not is_instance_valid(hero_select_idle_sprite):
		return
	if hero_select_transition_active and hero_select_transition_hero_id == _selected_hero_id():
		hero_select_transition_elapsed += get_process_delta_time()
		var progress := clampf(hero_select_transition_elapsed / HERO_SELECT_TRANSITION_DURATION, 0.0, 1.0)
		var eased := 1.0 - pow(1.0 - progress, 3.0)
		hero_select_idle_sprite.position = hero_select_transition_from_position.lerp(hero_select_transition_target_position, eased)
		hero_select_idle_sprite.texture = _hero_select_walk_texture(hero_select_transition_hero_id)
		if progress >= 1.0:
			hero_select_transition_active = false
			hero_select_idle_sprite.position = hero_select_transition_target_position
			hero_select_idle_elapsed = 0.0
			hero_select_idle_sprite.texture = _hero_select_idle_texture(_selected_hero_id(), true)
		return
	hero_select_idle_sprite.texture = _hero_select_idle_texture(_selected_hero_id(), true)

func _start_hero_select_transition(hero_id: String) -> void:
	if not is_instance_valid(hero_select_idle_sprite) or not _hero_has_idle_preview(hero_id):
		hero_select_transition_active = false
		return
	hero_select_transition_active = true
	hero_select_transition_elapsed = 0.0
	hero_select_transition_hero_id = hero_id
	hero_select_transition_target_position = hero_select_idle_sprite.position
	hero_select_transition_from_position = Vector2(
		-hero_select_idle_sprite.size.x - 24.0,
		hero_select_transition_target_position.y
	)
	hero_select_idle_sprite.position = hero_select_transition_from_position

func _hero_select_walk_texture(hero_id: String) -> Texture2D:
	var textures: Array = []
	match hero_id:
		"guan_yu":
			textures = GUAN_YU_SELECT_WALK_TEXTURES
		"zhang_fei":
			textures = ZHANG_FEI_SELECT_WALK_TEXTURES
		"zhao_yun":
			textures = ZHAO_YUN_SELECT_WALK_TEXTURES
		"ma_chao":
			textures = MA_CHAO_SELECT_WALK_TEXTURES
		_:
			return null
	if textures.is_empty():
		return null
	var frame := int(hero_select_transition_elapsed / 0.09) % textures.size()
	return textures[frame] as Texture2D

func _start_hero_select_portrait_flash() -> void:
	hero_select_portrait_flash_remaining = HERO_SELECT_PORTRAIT_FLASH_DURATION
	if not is_instance_valid(hero_select_display_portrait):
		return
	var material := hero_select_display_portrait.material as ShaderMaterial
	if material != null:
		material.set_shader_parameter("flash_amount", 1.0)

func _update_hero_select_portrait_flash(delta: float) -> void:
	if hero_select_portrait_flash_remaining <= 0.0:
		return
	hero_select_portrait_flash_remaining = maxf(
		0.0,
		hero_select_portrait_flash_remaining - delta
	)
	if not is_instance_valid(hero_select_display_portrait):
		return
	var material := hero_select_display_portrait.material as ShaderMaterial
	if material == null:
		return
	var ratio := clampf(
		hero_select_portrait_flash_remaining / HERO_SELECT_PORTRAIT_FLASH_DURATION,
		0.0,
		1.0
	)
	material.set_shader_parameter("flash_amount", ratio * 0.92)

func _hero_select_idle_texture(hero_id: String, animated: bool) -> Texture2D:
	if hero_id == "guan_yu":
		if not animated:
			return GUAN_YU_SELECT_IDLE_TEXTURES[0] as Texture2D
		var guan_frame := int(hero_select_idle_elapsed / 0.18) % GUAN_YU_SELECT_IDLE_TEXTURES.size()
		return GUAN_YU_SELECT_IDLE_TEXTURES[guan_frame] as Texture2D
	if hero_id == "zhang_fei":
		if not animated:
			return ZHANG_FEI_SELECT_IDLE_TEXTURES[0] as Texture2D
		var zhang_order: Array[int] = [0, 1, 2, 1]
		var zhang_frame := zhang_order[int(hero_select_idle_elapsed / 0.18) % zhang_order.size()]
		return ZHANG_FEI_SELECT_IDLE_TEXTURES[zhang_frame] as Texture2D
	if hero_id == "ma_chao":
		if not animated:
			return MA_CHAO_SELECT_IDLE_TEXTURES[0] as Texture2D
		var ma_chao_frame := int(hero_select_idle_elapsed / 0.16) % MA_CHAO_SELECT_IDLE_TEXTURES.size()
		return MA_CHAO_SELECT_IDLE_TEXTURES[ma_chao_frame] as Texture2D
	if not animated:
		return ZHAO_YUN_SELECT_IDLE_TEXTURES[0] as Texture2D
	var zhao_order: Array[int] = [0, 1, 2, 3, 2, 1]
	var zhao_frame := zhao_order[int(hero_select_idle_elapsed / 0.20) % zhao_order.size()]
	return ZHAO_YUN_SELECT_IDLE_TEXTURES[zhao_frame] as Texture2D

func _draw_ellipse_shadow(center: Vector2, radius: Vector2, color: Color) -> void:
	draw_set_transform(center, 0.0, radius)
	draw_circle(Vector2.ZERO, 1.0, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_expedition(font: Font) -> void:
	var map_rect := _expedition_map_rect()
	var layout_scale := _expedition_ui_scale()
	draw_string(font, Vector2(map_rect.get_center().x - 80.0 * layout_scale, map_rect.position.y + 54.0 * layout_scale), "出征", HORIZONTAL_ALIGNMENT_CENTER, 160.0 * layout_scale, roundi(32.0 * layout_scale), Color("f4d58d"))

func _draw_expedition_background() -> void:
	var map_rect := _expedition_map_rect()
	draw_texture_rect(EXPEDITION_BACKGROUND_TEXTURE, map_rect, false)
	# Preserve the map's illustrated border while gently subduing it beneath
	# the names. No home-screen frame or legacy route/preview panels belong here.
	draw_rect(map_rect, Color(0.01, 0.04, 0.04, 0.08))

func _expedition_subtitle() -> String:
	match expedition_tab:
		"endless":
			if not SaveService.is_battlefield_unlocked(selected_endless_battlefield_id):
				return "通关剧情第三关后解锁。"
			return "攻取荆州，护送攻城锤破门入城。" if selected_endless_battlefield_id == "jingzhou_siege" else "20分钟兵海生存。"
		"boss_trial": return "连续斗将，挑战名将。" if SaveService.is_battlefield_unlocked("hulao") else "通关剧情第三关后解锁。"
		_: return "新野至当阳，逐章推进。"

func _draw_story_expedition(font: Font) -> void:
	var definition := _story_chapter_definition(selected_story_chapter_id)
	var chapter_index := STORY_CHAPTER_IDS.find(selected_story_chapter_id)
	var unlocked := chapter_index >= 0 and SaveService.is_story_chapter_unlocked(chapter_index + 1)
	_draw_story_chapter_preview(_story_preview_rect(), definition, unlocked, font)
	_draw_story_chapter_details(_story_details_rect(), definition, unlocked, font)
	_draw_story_expedition_route(font)

func _draw_story_expedition_route(font: Font) -> void:
	draw_string(font, Vector2(82.0, 202.0), "荆州卷", HORIZONTAL_ALIGNMENT_LEFT, 328.0, 22, GOLD_BRIGHT)
	draw_string(font, Vector2(82.0, 224.0), "新野至当阳", HORIZONTAL_ALIGNMENT_LEFT, 328.0, 14, Color("a9c2c7"))
	var first_center_y := STORY_ROUTE_BUTTON_START.y + STORY_ROUTE_BUTTON_SIZE.y * 0.5
	var last_center_y := first_center_y + float(STORY_CHAPTER_IDS.size() - 1) * STORY_ROUTE_BUTTON_STEP
	draw_line(Vector2(STORY_ROUTE_RAIL_X, first_center_y), Vector2(STORY_ROUTE_RAIL_X, last_center_y), Color("8f7650"), 2.0)
	for index in range(STORY_CHAPTER_IDS.size()):
		var chapter_id := STORY_CHAPTER_IDS[index]
		var unlocked := SaveService.is_story_chapter_unlocked(index + 1)
		var selected := selected_story_chapter_id == chapter_id
		var center := Vector2(STORY_ROUTE_RAIL_X, first_center_y + float(index) * STORY_ROUTE_BUTTON_STEP)
		var node_color := GOLD_BRIGHT if selected else (Color("78b996") if unlocked else Color("55636a"))
		draw_circle(center, 12.0 if selected else 9.0, node_color)
		if selected:
			draw_arc(center, 16.0, 0.0, TAU, 20, Color("f7e7bd"), 1.5)
		draw_string(font, Vector2(center.x - 10.0, center.y + 4.0), "%d" % (index + 1), HORIZONTAL_ALIGNMENT_CENTER, 20.0, 11, PANEL_FILL if unlocked else Color("d7e0dc"))

func _draw_story_chapter_preview(rect: Rect2, definition: Dictionary, unlocked: bool, font: Font) -> void:
	_draw_panel(rect, GOLD if unlocked else Color("4c5960"), true)
	var inner := rect.grow(-8.0)
	var preview_texture: Texture2D = CHANGBAN_GROUND_CANVAS_TEXTURE
	match str(definition.get("battlefield_id", "changban")):
		"xinye":
			preview_texture = XINYE_GROUND_CANVAS_TEXTURE
		"bowangpo":
			preview_texture = BOWANGPO_GROUND_CANVAS_TEXTURE
		"huoshaoxinye":
			preview_texture = HUOSHAO_XINYE_GROUND_CANVAS_TEXTURE
		"xiangyangchetui":
			preview_texture = XIANGYANG_CHETUI_GROUND_CANVAS_TEXTURE
		"dangyangduanhou":
			preview_texture = DANGYANG_DUANHOU_GROUND_CANVAS_TEXTURE
	draw_texture_rect(preview_texture, inner, true, Color(0.54, 0.62, 0.66, 0.78) if unlocked else Color(0.34, 0.39, 0.40, 0.52))
	draw_rect(inner, Color(0.02, 0.04, 0.05, 0.38))
	draw_rect(Rect2(inner.position, Vector2(inner.size.x, 40.0)), Color(0.03, 0.06, 0.07, 0.60))
	var difficulty := str(STORY_CHAPTER_DIFFICULTIES.get(str(definition.get("id", "")), ""))
	var badge_rect := Rect2(inner.end.x - 112.0, inner.position.y + 8.0, 94.0, 24.0)
	if not difficulty.is_empty():
		draw_rect(badge_rect, Color(0.08, 0.10, 0.10, 0.86))
		draw_rect(badge_rect, GOLD_BRIGHT if unlocked else Color("8a7652"), false, 2.0)
		draw_string(font, badge_rect.position + Vector2(0.0, 17.0), difficulty, HORIZONTAL_ALIGNMENT_CENTER, badge_rect.size.x, 13, GOLD_BRIGHT if unlocked else MUTED)
	draw_string(font, inner.position + Vector2(18.0, 27.0), str(definition.get("title", "剧情关卡")), HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 150.0, 15, Color("d8e4df") if unlocked else MUTED)

func _draw_story_chapter_details(rect: Rect2, definition: Dictionary, unlocked: bool, font: Font) -> void:
	_draw_panel(rect, GOLD if unlocked else Color("4c5960"), true)
	var inner := rect.grow(-8.0)
	var chapter_text := str(definition.get("chapter", "荆州卷"))
	var status := "可出征" if unlocked else "尚未解锁"
	draw_string(font, inner.position + Vector2(16.0, 23.0), chapter_text, HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 160.0, 14, GOLD_BRIGHT if unlocked else MUTED)
	draw_string(font, Vector2(inner.end.x - 126.0, inner.position.y + 23.0), status, HORIZONTAL_ALIGNMENT_RIGHT, 110.0, 14, Color("9ee0c6") if unlocked else MUTED)
	draw_string(font, inner.position + Vector2(16.0, 52.0), str(definition.get("description", "")), HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 32.0, 15, Color("d0ddd9") if unlocked else MUTED)
	var tags: Array = definition.get("tags", []) as Array
	var tag_text := _battlefield_tag_text(tags)
	draw_string(font, inner.position + Vector2(16.0, 79.0), tag_text, HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 32.0, 14, Color("b9d6d8") if unlocked else MUTED)

func _draw_endless_expedition(font: Font) -> void:
	var preview := _expedition_preview_rect()
	var definition := _battlefield_definition("changban")
	_draw_battlefield_preview(preview, definition, SaveService.is_battlefield_unlocked("changban"), font)
	_draw_expedition_route(font, "战场", ["changban"], "changban")

func _draw_boss_trial_expedition(font: Font) -> void:
	var preview := _expedition_preview_rect()
	var unlocked := SaveService.is_battlefield_unlocked("hulao")
	_draw_battlefield_preview(preview, _battlefield_definition("hulao"), unlocked, font)
	draw_string(font, Vector2(68.0, 230.0), "规则", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, GOLD_BRIGHT)
	draw_string(font, Vector2(68.0, 268.0), "20级开局", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d5e1de") if unlocked else MUTED)
	draw_string(font, Vector2(68.0, 300.0), "三轮斗将", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d5e1de") if unlocked else MUTED)

func _draw_expedition_route(font: Font, title: String, battlefield_ids: Array[String], selected_id: String) -> void:
	var title_position := Vector2(70.0, 204.0)
	draw_string(font, title_position, title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, GOLD_BRIGHT)
	if battlefield_ids.size() > 1:
		var first_center_y := _expedition_route_button_position(0).y + EXPEDITION_ROUTE_BUTTON_SIZE.y * 0.5
		var last_center_y := _expedition_route_button_position(battlefield_ids.size() - 1).y + EXPEDITION_ROUTE_BUTTON_SIZE.y * 0.5
		draw_line(Vector2(EXPEDITION_ROUTE_RAIL_X, first_center_y), Vector2(EXPEDITION_ROUTE_RAIL_X, last_center_y), Color("8f7650"), 2.0)
	for index in range(battlefield_ids.size()):
		var battlefield_id := battlefield_ids[index]
		var definition := _battlefield_definition(battlefield_id)
		var unlocked := SaveService.is_battlefield_unlocked(battlefield_id)
		var button_position := _expedition_route_button_position(index)
		var center := Vector2(EXPEDITION_ROUTE_RAIL_X, button_position.y + EXPEDITION_ROUTE_BUTTON_SIZE.y * 0.5)
		var color := GOLD_BRIGHT if battlefield_id == selected_id else (Color("78b996") if unlocked else Color("55636a"))
		draw_circle(center, 8.0, color)
		draw_string(font, Vector2(button_position.x, button_position.y - 10.0), str(definition.get("chapter", "战场")), HORIZONTAL_ALIGNMENT_LEFT, EXPEDITION_ROUTE_BUTTON_SIZE.x, 13, Color("bdc9c6") if unlocked else MUTED)

func _draw_battlefield_preview(rect: Rect2, definition: Dictionary, unlocked: bool, font: Font) -> void:
	var battlefield_id := str(definition.get("id", ""))
	var title := str(definition.get("title", "战场"))
	_draw_panel(rect, GOLD if unlocked else Color("4c5960"), true)
	var inner := rect.grow(-8.0)
	match battlefield_id:
		"changban":
			draw_texture_rect(CHANGBAN_GROUND_CANVAS_TEXTURE, inner, true, Color(0.54, 0.62, 0.66, 0.72))
		"jingzhou_siege":
			draw_texture_rect(JINGZHOU_SIEGE_GROUND_CANVAS_TEXTURE, inner, true, Color(0.62, 0.68, 0.62, 0.82))
			draw_rect(Rect2(inner.position + Vector2(0.0, inner.size.y * 0.58), Vector2(inner.size.x, inner.size.y * 0.18)), Color("5d4b31", 0.68))
			var gate_rect := Rect2(inner.end.x - 104.0, inner.position.y + 94.0, 68.0, inner.size.y - 150.0)
			draw_rect(gate_rect.grow(8.0), Color("2d2722", 0.92))
			draw_rect(gate_rect, Color("75543a", 0.96))
			draw_rect(Rect2(gate_rect.position + Vector2(16.0, gate_rect.size.y * 0.54), Vector2(gate_rect.size.x - 32.0, gate_rect.size.y * 0.46)), Color("17191a", 0.96))
			draw_line(Vector2(inner.position.x + 78.0, inner.position.y + inner.size.y * 0.67), Vector2(gate_rect.position.x - 38.0, inner.position.y + inner.size.y * 0.67), Color("e4bd70", 0.84), 4.0)
			draw_colored_polygon(PackedVector2Array([
			Vector2(gate_rect.position.x - 38.0, inner.position.y + inner.size.y * 0.67 - 10.0),
			Vector2(gate_rect.position.x - 12.0, inner.position.y + inner.size.y * 0.67),
			Vector2(gate_rect.position.x - 38.0, inner.position.y + inner.size.y * 0.67 + 10.0),
		]), Color("f2d68d", 0.94))
			draw_string(font, Vector2(inner.position.x + 34.0, inner.end.y - 34.0), "左侧集结 · 向右推进 · 击破荆州城门", HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 68.0, 15, Color("e4d0a1", 0.92))
		"bowangpo":
			draw_texture_rect(BOWANGPO_GROUND_CANVAS_TEXTURE, inner, true, Color(0.54, 0.62, 0.66, 0.72))
			for index in range(5):
				var fire_y := inner.position.y + 72.0 + float(index) * 54.0
				draw_line(Vector2(inner.position.x + 30.0, fire_y), Vector2(inner.end.x - 34.0, fire_y + 24.0), Color(0.94, 0.34, 0.12, 0.50), 7.0)
				draw_line(Vector2(inner.position.x + 30.0, fire_y - 3.0), Vector2(inner.end.x - 34.0, fire_y + 21.0), Color(1.0, 0.70, 0.28, 0.70), 1.5)
			for index in range(8):
				var ash_x := inner.position.x + 38.0 + fmod(float(index * 91), inner.size.x - 76.0)
				draw_line(Vector2(ash_x, inner.position.y + 32.0), Vector2(ash_x + 24.0, inner.end.y - 22.0), Color(0.56, 0.62, 0.57, 0.16), 2.0)
		"hulao":
			draw_texture_rect(BOSS_TRIAL_PREVIEW_TEXTURE, inner, false, Color(0.90, 0.78, 0.66, 0.90))
		_:
			draw_rect(inner, Color("252229"))
			var center := inner.get_center()
			draw_arc(center, minf(inner.size.x, inner.size.y) * 0.30, 0.0, TAU, 32, Color("9b7bd2"), 3.0)
			for index in range(6):
				var angle := TAU * float(index) / 6.0
				draw_line(center + Vector2.from_angle(angle) * 34.0, center + Vector2.from_angle(angle) * 94.0, Color("d7b56a", 0.64), 2.0)
	draw_rect(inner, Color(0.02, 0.04, 0.05, 0.36))
	draw_string(font, Vector2(inner.position.x + 22.0, inner.position.y + 56.0), title, HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 44.0, 32, Color("f4e6c4") if unlocked else Color("9fa9aa"))
	draw_string(font, Vector2(inner.position.x + 22.0, inner.position.y + 86.0), str(definition.get("description", "")), HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 44.0, 16, Color("d0ddd9") if unlocked else MUTED)
	var tags: Array = definition.get("tags", []) as Array
	var tag_text := _battlefield_tag_text(tags)
	draw_string(font, Vector2(inner.position.x + 22.0, inner.end.y - 102.0), tag_text, HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 44.0, 15, Color("b9d6d8") if unlocked else MUTED)
	var status := "可出征" if bool(definition.get("implemented", false)) and unlocked else ("已解锁 · 战场筹备中" if unlocked else "尚未解锁")
	draw_string(font, Vector2(inner.position.x + 22.0, inner.end.y - 74.0), status, HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 44.0, 17, Color("9ee0c6") if bool(definition.get("implemented", false)) and unlocked else Color("f1bd73") if unlocked else MUTED)

func _battlefield_tag_text(tags: Array) -> String:
	var value := ""
	for tag in tags:
		if not value.is_empty():
			value += " · "
		value += str(tag)
	return value

func _draw_shop(font: Font) -> void:
	pass

func _draw_settings(_font: Font) -> void:
	pass

func _draw_hero_details(font: Font) -> void:
	var hero := _selected_hero()
	var stats := HERO_CATALOG.display_stats_for(_selected_hero_id(), profile)
	var margin := clampf(size.x * 0.055, 32.0, 76.0)
	var content_top := clampf(size.y * 0.16, 118.0, 168.0)
	var panel_height := maxf(300.0, size.y - content_top - 96.0)
	var stats_width := clampf(size.x * 0.32, 320.0, 430.0)
	draw_string(font, Vector2(margin, content_top - 56.0), "%s · %s" % [hero.get("name", "武将"), hero.get("role", "")], HORIZONTAL_ALIGNMENT_LEFT, -1, 32, GOLD_BRIGHT)
	draw_string(font, Vector2(margin, content_top - 24.0), "当前属性", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("b9c9cd"))
	var stats_rect := Rect2(margin, content_top, stats_width, panel_height)
	_draw_panel(stats_rect, DRAGON_BLUE, true)
	var stat_rows := [
		["攻击", "%.1f" % float(stats.get("attack", 0.0))],
		["防御", "%.1f" % float(stats.get("defense", 0.0))],
		["生命", "%d" % int(stats.get("health", 0.0))],
		["移速", "%d" % int(stats.get("move_speed", 0.0))],
		["普攻范围", "%d" % int(stats.get("basic_range", 0.0))],
		["普攻穿透", "%d" % int(stats.get("basic_pierce", 0))],
		["无视防御", "%.0f%%" % (float(stats.get("armor_ignore_ratio", 0.0)) * 100.0)],
		["主动冷却", "%.1f 秒" % float(stats.get("active_cooldown", 0.0))],
		["无双能量", "%d" % int(stats.get("ultimate_cost", 0.0))],
	]
	for index in range(stat_rows.size()):
		var row: Array = stat_rows[index]
		var y := stats_rect.position.y + 38.0 + index * 40.0
		draw_string(font, Vector2(stats_rect.position.x + 28.0, y), row[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("adc1c5"))
		draw_string(font, Vector2(stats_rect.end.x - 148.0, y), row[1], HORIZONTAL_ALIGNMENT_RIGHT, 120, 18, Color("f2e5c4"))
	var skill_x := stats_rect.end.x + clampf(size.x * 0.03, 28.0, 48.0)
	var skill_rect := Rect2(skill_x, content_top, maxf(300.0, size.x - skill_x - margin), panel_height)
	_draw_panel(skill_rect, GOLD, true)
	draw_string(font, Vector2(skill_rect.position.x + 28, skill_rect.position.y + 38), "技能", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, GOLD_BRIGHT)
	var skills: Array = hero.get("skills", [])
	for index in range(skills.size()):
		var skill: Dictionary = skills[index]
		var y := skill_rect.position.y + 78.0 + index * 82.0
		draw_string(font, Vector2(skill_rect.position.x + 28, y), "%s  %s" % [skill.get("type", ""), skill.get("name", "")], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("d6e5e2"))
		draw_string(font, Vector2(skill_rect.position.x + 28, y + 25.0), str(skill.get("description", "")), HORIZONTAL_ALIGNMENT_LEFT, skill_rect.size.x - 56.0, 14, Color("9fb3b8"))

func _portrait_for(path: String) -> Texture2D:
	if portrait_cache.has(path):
		return portrait_cache[path] as Texture2D
	var portrait := load(path) as Texture2D
	portrait_cache[path] = portrait
	return portrait

func _draw_panel(rect: Rect2, accent: Color, emphasize: bool = false) -> void:
	UITheme.draw_panel(self, rect, accent, emphasize)

func _make_box_style(background: Color, border: Color, border_width: int) -> StyleBox:
	return UITheme.box_style(background, border, border_width)

func _alpha(color: Color, opacity: float) -> Color:
	return Color(color.r, color.g, color.b, opacity)

class TianjiAltarCanvas extends Control:
	var node_centers: Array[Vector2] = []
	var node_colors: Array[Color] = []
	var node_unlocked: Array[bool] = []
	var altar_center := Vector2.ZERO
	var altar_radius := 0.0
	var altar_horizontal_scale := 1.0

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_PASS

	func configure(centers: Array[Vector2], colors: Array[Color], unlocked: Array[bool], center: Vector2, radius: float, horizontal_scale: float = 1.0) -> void:
		node_centers = centers.duplicate()
		node_colors = colors.duplicate()
		node_unlocked = unlocked.duplicate()
		altar_center = center
		altar_radius = radius
		altar_horizontal_scale = horizontal_scale
		queue_redraw()

	func _draw() -> void:
		if node_centers.size() != 5 or node_colors.size() != 5 or node_unlocked.size() != 5:
			return
		var outer_color := Color(0.82, 0.69, 0.40, 0.22)
		for index in range(node_centers.size()):
			draw_line(node_centers[index], node_centers[(index + 1) % node_centers.size()], outer_color, 1.0, true)
		var star_path := [0, 2, 4, 1, 3, 0]
		for index in range(star_path.size() - 1):
			var start_index := int(star_path[index])
			var end_index := int(star_path[index + 1])
			var start_color := node_colors[start_index]
			var end_color := node_colors[end_index]
			var highlighted := node_unlocked[start_index] or node_unlocked[end_index]
			var segment_color := start_color.lerp(end_color, 0.5)
			segment_color.a = 0.62 if highlighted else 0.18
			draw_line(node_centers[start_index], node_centers[end_index], segment_color, 2.0 if highlighted else 1.0, true)
		var ring_color := Color(0.96, 0.78, 0.41, 0.24)
		draw_set_transform(altar_center, 0.0, Vector2(altar_horizontal_scale, 1.0))
		draw_arc(Vector2.ZERO, altar_radius * 0.48, 0.0, TAU, 48, ring_color, 1.2, true)
		draw_arc(Vector2.ZERO, altar_radius * 0.32, 0.0, TAU, 36, Color(0.36, 0.70, 0.78, 0.24), 1.0, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		for index in range(node_centers.size()):
			var node_color := node_colors[index]
			node_color.a = 0.24 if node_unlocked[index] else 0.10
			draw_circle(node_centers[index], altar_radius * 0.18, node_color)
			var outline := node_colors[index]
			outline.a = 0.76 if node_unlocked[index] else 0.30
			draw_arc(node_centers[index], altar_radius * 0.18, 0.0, TAU, 24, outline, 1.0, true)

class HeroSelectInfoOverlay extends Control:
	const KAITI_FONT: Font = preload("res://assets/fonts/kaiti.ttf")
	const GOLD_BRIGHT := Color("f2d58d")
	const MUTED := Color("819294")
	var info_rect := Rect2()
	var hero: Dictionary = {}
	var hero_id := ""
	var stats: Dictionary = {}
	var status := ""
	var status_color := Color.WHITE
	var stat_fill_progress := 0.0

	func configure(panel_rect: Rect2, hero_data: Dictionary, selected_id: String, stats_data: Dictionary, hero_status: String, hero_status_color: Color) -> void:
		info_rect = panel_rect
		hero = hero_data.duplicate(true)
		hero_id = selected_id
		stats = stats_data.duplicate(true)
		status = hero_status
		status_color = hero_status_color
		queue_redraw()

	func set_stat_fill_progress(value: float) -> void:
		stat_fill_progress = clampf(value, 0.0, 1.0)
		queue_redraw()

	func _sections() -> Dictionary:
		var inner := info_rect.grow(-18.0)
		var gap := 10.0
		var role_height := info_rect.size.y * 0.17
		var trait_height := info_rect.size.y * 0.23
		var stats_height := info_rect.size.y * 0.31
		var role := Rect2(inner.position, Vector2(inner.size.x, role_height))
		var trait_section := Rect2(Vector2(inner.position.x, role.end.y + gap), Vector2(inner.size.x, trait_height))
		var stats_section := Rect2(Vector2(inner.position.x, trait_section.end.y + gap), Vector2(inner.size.x, stats_height))
		var skills_y := stats_section.end.y + gap
		var skills := Rect2(Vector2(inner.position.x, skills_y), Vector2(inner.size.x, maxf(0.0, inner.end.y - skills_y)))
		return {"role": role, "trait": trait_section, "stats": stats_section, "skills": skills}

	func _wrap_text(text: String, max_width: float, font_size: int) -> String:
		var safe_width := maxf(1.0, max_width)
		var lines: Array[String] = []
		var current := ""
		for character in text:
			if character == "\n":
				lines.append(current)
				current = ""
				continue
			var candidate := current + character
			if not current.is_empty() and KAITI_FONT.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x > safe_width:
				lines.append(current)
				current = character
			else:
				current = candidate
		if not current.is_empty() or lines.is_empty():
			lines.append(current)
		return "\n".join(lines)

	func _draw() -> void:
		if info_rect.size.x <= 0.0 or info_rect.size.y <= 0.0:
			return
		UITheme.draw_panel(self, info_rect, Color("d5af66"), true)
		var sections := _sections()
		var role_rect: Rect2 = sections.get("role", Rect2())
		var trait_rect: Rect2 = sections.get("trait", Rect2())
		var stats_rect: Rect2 = sections.get("stats", Rect2())
		var skills_rect: Rect2 = sections.get("skills", Rect2())
		var separator_color := Color("8c744b", 0.9)
		for section_rect in [role_rect, trait_rect, stats_rect]:
			draw_line(Vector2(info_rect.position.x + 16.0, section_rect.end.y + 5.0), Vector2(info_rect.end.x - 16.0, section_rect.end.y + 5.0), separator_color, 1.0)

		draw_string(KAITI_FONT, role_rect.position + Vector2(0.0, 23.0), "武将定位", HORIZONTAL_ALIGNMENT_LEFT, role_rect.size.x, 20, GOLD_BRIGHT)
		draw_string(KAITI_FONT, role_rect.position + Vector2(0.0, 22.0), status, HORIZONTAL_ALIGNMENT_RIGHT, role_rect.size.x, 14, status_color)
		var chip_x := role_rect.position.x
		var chip_y := role_rect.position.y + 33.0
		var chip_font_size := 18
		for word in str(hero.get("role", "")).split("·", false):
			var word_width := KAITI_FONT.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1.0, chip_font_size).x
			var chip_width := minf(word_width + 20.0, role_rect.end.x - chip_x)
			if chip_width <= 0.0:
				break
			var chip := Rect2(chip_x, chip_y, chip_width, 30.0)
			draw_style_box(UITheme.flat_box_style(Color("2c2416", 0.72), GOLD_BRIGHT, 1), chip)
			draw_string(KAITI_FONT, chip.position + Vector2(10.0, 21.0), word, HORIZONTAL_ALIGNMENT_LEFT, chip.size.x - 20.0, chip_font_size, Color("f3dfb0"))
			chip_x += chip_width + 9.0

		draw_string(KAITI_FONT, trait_rect.position + Vector2(0.0, 20.0), "武将特性", HORIZONTAL_ALIGNMENT_LEFT, trait_rect.size.x, 20, GOLD_BRIGHT)
		var trait_description := str(hero.get("trait_summary", ""))
		var trait_lines := _wrap_text(trait_description, trait_rect.size.x, 16).split("\n")
		var trait_bottom := trait_rect.size.y - 5.0
		for line_index in range(trait_lines.size()):
			var line_y := 48.0 + float(line_index) * 22.0
			if line_y > trait_bottom:
				break
			draw_string(KAITI_FONT, trait_rect.position + Vector2(0.0, line_y), str(trait_lines[line_index]), HORIZONTAL_ALIGNMENT_LEFT, trait_rect.size.x, 16, Color("d6e5e2"))
		draw_string(KAITI_FONT, stats_rect.position + Vector2(0.0, 20.0), "武将属性", HORIZONTAL_ALIGNMENT_LEFT, stats_rect.size.x, 20, GOLD_BRIGHT)
		_draw_stat_bars(stats_rect)
		draw_string(KAITI_FONT, skills_rect.position + Vector2(0.0, 20.0), "技能", HORIZONTAL_ALIGNMENT_LEFT, skills_rect.size.x, 20, GOLD_BRIGHT)
		if hero_id == "huang_zhong":
			var center := info_rect.get_center()
			draw_string(KAITI_FONT, center + Vector2(-100.0, -18.0), "黄忠正在筹备中", HORIZONTAL_ALIGNMENT_CENTER, 200.0, 24, Color("d0a875"))
			draw_string(KAITI_FONT, center + Vector2(-100.0, 16.0), "人物与技能制作中 · 敬请期待", HORIZONTAL_ALIGNMENT_CENTER, 200.0, 15, MUTED)

	func _draw_stat_bars(panel_rect: Rect2) -> void:
		var rows := [["攻击", float(stats.get("attack", 0.0)), 40.0], ["防御", float(stats.get("defense", 0.0)), 40.0], ["生命", float(stats.get("health", 0.0)), 220.0], ["移速", float(stats.get("move_speed", 0.0)), 170.0]]
		var label_width := 52.0
		var value_width := 40.0
		var bar_x := panel_rect.position.x + label_width
		var bar_width := maxf(42.0, panel_rect.size.x - label_width - value_width)
		var top := panel_rect.position.y + 38.0
		var row_gap := clampf((panel_rect.size.y - 50.0) / float(rows.size()), 23.0, 31.0)
		var fill_progress := 1.0 - pow(1.0 - stat_fill_progress, 3.0)
		var bar_height := 12.0
		var tip := 5.0
		for index in range(rows.size()):
			var row: Array = rows[index]
			var y := top + float(index) * row_gap
			var value := float(row[1])
			var cap := float(row[2])
			var ratio := clampf(value / maxf(1.0, cap), 0.0, 1.0)
			var animated_ratio := ratio * fill_progress
			draw_string(KAITI_FONT, Vector2(panel_rect.position.x, y + 12.0), str(row[0]), HORIZONTAL_ALIGNMENT_LEFT, label_width, 16, Color("adc1c5"))
			draw_colored_polygon(_bar_polygon(bar_x, y, bar_width, bar_height, tip), Color("22343b", 0.94))
			var fill_width := bar_width * animated_ratio
			if fill_width > 0.5:
				draw_colored_polygon(_bar_polygon(bar_x, y, fill_width, bar_height, minf(tip, fill_width * 0.28)), Color("c28c43", 0.96))
				var segment_count := 12
				var segment_start := bar_x + minf(tip, fill_width * 0.28)
				var segment_end := bar_x + fill_width - minf(tip, fill_width * 0.28)
				if segment_end > segment_start:
					for segment_index in range(segment_count):
						var from_ratio := float(segment_index) / float(segment_count)
						var to_ratio := float(segment_index + 1) / float(segment_count)
						var segment_x := lerpf(segment_start, segment_end, from_ratio)
						var segment_width := maxf(0.5, lerpf(segment_start, segment_end, to_ratio) - segment_x)
						var segment_color := Color("9e6c2f").lerp(Color("ffe8a3"), from_ratio)
						draw_rect(Rect2(segment_x, y + 2.0, segment_width, bar_height - 4.0), segment_color, true)
			draw_string(KAITI_FONT, Vector2(panel_rect.end.x - value_width, y + 12.0), "%.0f" % value, HORIZONTAL_ALIGNMENT_RIGHT, value_width, 16, Color("f2e5c4"))

	func _bar_polygon(x: float, y: float, width: float, height: float, tip: float) -> PackedVector2Array:
		var safe_width := maxf(1.0, width)
		var safe_tip := minf(maxf(0.0, tip), safe_width * 0.45)
		return PackedVector2Array([Vector2(x + safe_tip, y), Vector2(x + safe_width - safe_tip, y), Vector2(x + safe_width, y + height * 0.5), Vector2(x + safe_width - safe_tip, y + height), Vector2(x + safe_tip, y + height), Vector2(x, y + height * 0.5)])

class ShopLockMark extends Control:
	func _draw() -> void:
		var body := Rect2(size.x * 0.20, size.y * 0.40, size.x * 0.60, size.y * 0.45)
		draw_rect(body, Color("141b1d", 0.94), true)
		draw_rect(body, Color("e6c77a", 0.90), false, 1.5)
		draw_arc(Vector2(size.x * 0.50, size.y * 0.43), size.x * 0.24, PI, TAU, 16, Color("e6c77a", 0.90), 1.8)
