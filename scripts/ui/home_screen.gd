class_name HomeScreen
extends Control

const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")
const MILITARY_STRATEGY = preload("res://scripts/domain/military_strategy.gd")
const TIANJI_CATALOG = preload("res://scripts/domain/tianji_catalog.gd")
const CHANGBAN_GROUND_TEXTURE = preload("res://assets/art/environment/changbanpo/snow-ground-01.png")
const XINYE_GROUND_TEXTURE = preload("res://assets/art/environment/xinye1/1.png")
const BOWANGPO_GROUND_TEXTURE = preload("res://assets/art/environment/bowangpo1/1.png")
const XINYE_GROUND_CANVAS_TEXTURE = preload("res://assets/art/environment/xinye1/ground-canvas.png")
const BOWANGPO_GROUND_CANVAS_TEXTURE = preload("res://assets/art/environment/bowangpo1/ground-canvas.png")
const HUOSHAO_XINYE_GROUND_CANVAS_TEXTURE = preload("res://assets/art/environment/huoshaoxinye1/ground-canvas.png")
const XIANGYANG_CHETUI_GROUND_CANVAS_TEXTURE = preload("res://assets/art/environment/xiangyangchetui1/ground-canvas.png")
const DANGYANG_DUANHOU_GROUND_CANVAS_TEXTURE = preload("res://assets/art/environment/dangyangduanhou/ground-canvas.png")
const CHANGBAN_GROUND_CANVAS_TEXTURE = preload("res://assets/art/environment/changbanpo/ground-canvas.png")
const NON_COMBAT_BACKGROUND_TEXTURE = preload("res://assets/art/ui/backgrounds/bg.png")
const TITLE_LOGO_TEXTURE = preload("res://assets/art/ui/title/logo.png")
const TITLE_FRAME_DIRECTORY := "res://assets/art/ui/title/frames"
const TITLE_FRAME_COUNT := 226
const TITLE_FRAME_RATE := 15.0
const TITLE_FRAME_CACHE_SIZE := 12
const TITLE_FRAME_PREFETCH_COUNT := 5
const TITLE_FRAME_LOOP_CROSSFADE_FRAME_COUNT := 12
const TITLE_FRAME_LOOP_CROSSFADE_DURATION := float(TITLE_FRAME_LOOP_CROSSFADE_FRAME_COUNT) / TITLE_FRAME_RATE
const RELEASE_HERO_IDS: Array[String] = ["guan_yu", "zhang_fei", "zhao_yun"]
const HERO_SELECT_SLOT_IDS: Array[String] = ["huang_zhong", "zhang_fei", "guan_yu", "zhao_yun", "ma_chao"]
const HERO_SELECT_IDLE_SPRITE_SIZES := {
	"guan_yu": Vector2(92.0, 72.0),
	"zhao_yun": Vector2(92.0, 72.0),
	"zhang_fei": Vector2(116.0, 66.0),
}
const HERO_SELECT_IDLE_MODEL_TOP := 76.0
const HERO_SELECT_IDLE_MODEL_BOTTOM_GAP := 12.0
const HERO_SELECT_IDLE_BOTTOM_PADDING := {
	"guan_yu": 9.0,
	"zhao_yun": 16.0,
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
const HERO_SELECT_PORTRAIT_SHADER_CODE := """
shader_type canvas_item;

uniform float dim_amount : hint_range(0.0, 1.0) = 0.0;
uniform float brightness : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	if (source.a < 0.02) {
		discard;
	}
	float luminance = dot(source.rgb, vec3(0.299, 0.587, 0.114));
	vec3 shaded_rgb = mix(source.rgb, vec3(luminance), dim_amount) * brightness;
	COLOR = vec4(shaded_rgb, source.a);
}
"""
const PANEL_FILL := Color("10191f")
const PANEL_INNER := Color("18242b")
const GOLD := Color("d5af66")
const GOLD_BRIGHT := Color("f4d58d")
const DRAGON_BLUE := Color("63b9df")
const MUTED := Color("829099")
const HERO_TREE_NODE_SIZE := Vector2(156.0, 64.0)
const HERO_TREE_NODE_GAP := 16.0
const HERO_TREE_BRANCH_START_X := 140.0
const HERO_TREE_BRANCH_TITLE_HEIGHT := 28.0
const HERO_TREE_BRANCH_BOTTOM_GAP := 38.0
const HERO_TREE_ROOT_RECT := Rect2(16.0, 16.0, 108.0, 56.0)
const HERO_TREE_SCROLL_DRAG_THRESHOLD := 10.0
const PAGE_SCROLL_DRAG_THRESHOLD := 10.0
const STRATEGY_CARD_WIDTH := 286.0
const STRATEGY_CARD_MIN_HEIGHT := 84.0
const STRATEGY_CARD_DESCRIPTION_LINE_HEIGHT := 15.0
const STRATEGY_CARD_DESCRIPTION_CHARS_PER_LINE := 20
const STRATEGY_CARD_GAP := Vector2(12.0, 12.0)
const TITLE_MENU_FADE_DURATION := 0.36
const TITLE_INTRO_DURATION := 1.05
const TITLE_ENTER_SEAL_DURATION := 0.18
const TITLE_PROMPT_TEXT := "触碰屏幕开始游戏"
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
		"title": "长坂坡·单骑救主",
		"chapter": "主线 第一章",
		"description": "夜雪乱军中破开盾弓阵，直面张郃。",
		"tags": ["雪夜", "盾弓阵", "张郃"],
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
		"chapter": "名将试炼",
		"description": "紧凑斗将场原型：精英、Boss 与拼刀机制验证。",
		"tags": ["精英", "Boss", "拼刀"],
		"implemented": true,
	},
}
const STORY_CHAPTER_DEFINITIONS := {
	"story_01": {"chapter": "荆州卷 第一章", "title": "新野练兵", "description": "刘备屯兵新野，先熟悉近战推进与拒阵突破。", "tags": ["约5分钟", "刀盾", "初阵"], "duration": "约5分钟", "battlefield_id": "xinye"},
	"story_02": {"chapter": "荆州卷 第二章", "title": "博望坡·火攻", "description": "诸葛亮初出奇谋，在博望坡击破曹军前锋。", "tags": ["约6分钟", "火攻", "枪盾"], "duration": "约6分钟", "battlefield_id": "bowangpo"},
	"story_03": {"chapter": "荆州卷 第三章", "title": "火烧新野", "description": "曹军压境，新野城中组织撤离并突破追兵。", "tags": ["约6.5分钟", "撤离", "弓手"], "duration": "约6.5分钟", "battlefield_id": "huoshaoxinye"},
	"story_04": {"chapter": "荆州卷 第四章", "title": "襄阳撤退", "description": "百姓随军南撤，在襄阳北线挡住曹军合围。", "tags": ["约8分钟", "护送", "戟卫"], "duration": "约8分钟", "battlefield_id": "xiangyangchetui"},
	"story_05": {"chapter": "荆州卷 第五章", "title": "当阳断后", "description": "曹军骑兵紧追不舍，掩护队伍穿过当阳狭路。", "tags": ["约9分钟", "骑兵", "断后"], "duration": "约9分钟", "battlefield_id": "dangyangduanhou"},
	"story_06": {"chapter": "荆州卷 第六章", "title": "长坂坡·单骑救主", "description": "赵云杀入长坂坡乱军，救出阿斗并击破张郃防线。", "tags": ["约10分钟", "长坂坡", "张郃"], "duration": "约10分钟", "battlefield_id": "changban"},
}
const STORY_CHAPTER_IDS: Array[String] = ["story_01", "story_02", "story_03", "story_04", "story_05", "story_06"]

var page := "main"
var expedition_tab := "story"
var selected_story_chapter_id := "story_01"
var selected_endless_battlefield_id := "changban"
var selected_run_mode := "story"
var selected_run_battlefield_id := "changban"
var selected_run_story_chapter := 1
var hero_select_return_tab := "story"
var hero_details_return_page := "main"
var shop_section := "heroes"
var selected_shop_hero_id := "zhao_yun"
var profile: Dictionary = {}
var notice := ""
var buttons: Array[Button] = []
var setting_controls: Array[Control] = []
var music_value_label: Label
var sfx_value_label: Label
var page_controls: Array[Control] = []
var talent_detail_dialog: Control
var strategy_detail_dialog: Control
var strategy_detail_notice := ""
var hero_ids: Array[String] = []
var selected_hero_index := 0
var hero_tree_touch_index := -1
var hero_tree_drag_start := Vector2.ZERO
var hero_tree_drag_scroll_start := 0
var hero_tree_dragging := false
var hero_tree_mouse_dragging := false
var page_scroll_touch_index := -1
var page_scroll_drag_start := Vector2.ZERO
var page_scroll_drag_start_offset := 0
var page_scroll_dragging := false
var page_scroll_mouse_dragging := false
var title_elapsed := 0.0
var title_enter_seal_remaining := 0.0
var title_menu_fade_remaining := 0.0
var title_frame_layer: TextureRect
var title_frame_transition_layer: TextureRect
var title_frame_paths := PackedStringArray()
var title_frame_cache: Dictionary = {}
var title_frame_index := -1
var title_frame_transition_elapsed := 0.0
var title_frame_transition_outgoing_start_index := -1
var title_frame_transition_active := false
var title_frame_playback_offset := 0
var hero_select_idle_elapsed := 0.0
var hero_select_idle_sprite: TextureRect
var portrait_cache: Dictionary = {}
var hero_select_portrait_shader: Shader

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	UITheme.install(self)
	resized.connect(_rebuild_current_page)
	_setup_title_frame_player()
	profile = SaveService.load_profile()
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
		title_elapsed += delta
		_update_title_frame(delta)
		needs_redraw = true
	if title_enter_seal_remaining > 0.0:
		title_enter_seal_remaining = maxf(0.0, title_enter_seal_remaining - delta)
		needs_redraw = true
		if title_enter_seal_remaining <= 0.0:
			SceneRouter.title_seen = true
			title_menu_fade_remaining = TITLE_MENU_FADE_DURATION
			_show_main()
	if page == "hero_select":
		hero_select_idle_elapsed += delta
		_update_hero_select_idle_sprite()
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
	title_enter_seal_remaining = 0.0
	title_menu_fade_remaining = 0.0
	title_frame_playback_offset = 0
	title_frame_transition_elapsed = 0.0
	title_frame_transition_outgoing_start_index = -1
	title_frame_transition_active = false
	if title_frame_layer != null:
		title_frame_layer.show()
		if title_frame_transition_layer != null:
			title_frame_transition_layer.show()
			title_frame_transition_layer.modulate.a = 0.0
		_update_title_frame(0.0, true)
	_clear_buttons()
	grab_focus()
	queue_redraw()

func _enter_from_title() -> void:
	if page != "title" or title_enter_seal_remaining > 0.0:
		return
	title_enter_seal_remaining = TITLE_ENTER_SEAL_DURATION
	queue_redraw()

func _show_main() -> void:
	page = "main"
	profile = SaveService.load_profile()
	notice = ""
	_clear_title_frame_cache()
	if title_frame_layer != null:
		title_frame_layer.hide()
	if title_frame_transition_layer != null:
		title_frame_transition_layer.hide()
	_clear_buttons()
	var command_x := (size.x - HOME_ACTION_BUTTON_SIZE.x) * 0.5
	var command_y := clampf(size.y * 0.5 - 88.0, 180.0, size.y - 196.0)
	_create_button("出征", "剧情战役、无尽与试炼", Vector2(command_x, command_y), _show_modes, HOME_ACTION_BUTTON_SIZE, false, 20)
	_create_button("军需", "武将、战法与军略", Vector2(command_x, command_y + HOME_ACTION_BUTTON_SIZE.y + HOME_ACTION_BUTTON_GAP), _show_shop, HOME_ACTION_BUTTON_SIZE, false, 20)
	var margin := _safe_margin()
	if SceneRouter.is_map_editor_available():
		_create_button("地图编辑器", "战场布局与障碍", Vector2(size.x - margin - 250.0, 76.0), _open_map_editor, Vector2(132.0, 44.0), false, 14)
	_create_button("设置", "", Vector2(size.x - margin - 118.0, 76.0), _show_settings, Vector2(118.0, 44.0), false, 16)
	queue_redraw()

func _open_map_editor() -> void:
	SceneRouter.open_map_editor()

func _show_modes() -> void:
	_show_expedition()

func _show_expedition(tab: String = "story") -> void:
	page = "expedition"
	expedition_tab = tab if tab in ["story", "endless", "boss_trial"] else "story"
	profile = SaveService.load_profile()
	notice = ""
	_clear_buttons()
	var tabs_width := EXPEDITION_TAB_SIZE.x * 3.0 + 20.0 * 2.0
	var tab_start := Vector2(size.x * 0.5 - tabs_width * 0.5, 88.0)
	var story_tab := _create_button("剧情战役", "", tab_start, Callable(self, "_show_expedition").bind("story"), EXPEDITION_TAB_SIZE, false, 17)
	var endless_tab := _create_button("无尽模式", "", tab_start + Vector2(EXPEDITION_TAB_SIZE.x + 20.0, 0.0), Callable(self, "_show_expedition").bind("endless"), EXPEDITION_TAB_SIZE, false, 17)
	var trial_tab := _create_button("名将试炼", "", tab_start + Vector2((EXPEDITION_TAB_SIZE.x + 20.0) * 2.0, 0.0), Callable(self, "_show_expedition").bind("boss_trial"), EXPEDITION_TAB_SIZE, false, 17)
	var active_tab := story_tab if expedition_tab == "story" else (endless_tab if expedition_tab == "endless" else trial_tab)
	active_tab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_button_owned_visual(active_tab)
	match expedition_tab:
		"story": _populate_story_expedition()
		"endless": _populate_endless_expedition()
		"boss_trial": _populate_boss_trial_expedition()
	_create_button("返回", "", Vector2(_safe_margin(), 28.0), _show_main, Vector2(126.0, 46.0))
	queue_redraw()

func _populate_story_expedition() -> void:
	for index in range(STORY_CHAPTER_IDS.size()):
		var chapter_id := STORY_CHAPTER_IDS[index]
		var definition := _story_chapter_definition(chapter_id)
		var unlocked := SaveService.is_story_chapter_unlocked(index + 1)
		var selected := selected_story_chapter_id == chapter_id
		var status := "当前章节" if selected else ("可出征" if unlocked else "完成前章解锁")
		var chapter_title := str(definition.get("title", "第%d章" % (index + 1)))
		var chapter_button := _create_button(chapter_title, status, _story_route_button_position(index), Callable(self, "_select_story_chapter").bind(chapter_id), STORY_ROUTE_BUTTON_SIZE, not unlocked, 14)
		if not unlocked:
			_set_button_locked_visual(chapter_button)
		elif selected:
			chapter_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_set_button_owned_visual(chapter_button)
	var selected_definition := _story_chapter_definition(selected_story_chapter_id)
	var selected_index := STORY_CHAPTER_IDS.find(selected_story_chapter_id)
	var can_start := selected_index >= 0 and SaveService.is_story_chapter_unlocked(selected_index + 1)
	var action_title := "开始出征" if can_start else "战役筹备中"
	var action_subtitle := "剧情战役 · %s" % str(selected_definition.get("duration", "")) if can_start else "完成前一章节后可解锁"
	var preview := _story_preview_rect()
	var details := _story_details_rect()
	_create_button(action_title, action_subtitle, Vector2(preview.end.x - STORY_ACTION_SIZE.x, details.end.y + 18.0), _start_selected_story, STORY_ACTION_SIZE, not can_start, 16)

func _populate_endless_expedition() -> void:
	for index in range(2):
		var battlefield_id := "changban" if index == 0 else "bowangpo"
		var definition := _battlefield_definition(battlefield_id)
		var usable := bool(definition.get("implemented", false)) and SaveService.is_battlefield_unlocked(battlefield_id)
		var selected := selected_endless_battlefield_id == battlefield_id
		var status := "可用战场" if usable else ("战场筹备中" if SaveService.is_battlefield_unlocked(battlefield_id) else "完成长坂坡后解锁")
		var battlefield_button := _create_button(str(definition.get("title", battlefield_id)), status, _expedition_route_button_position(index), Callable(self, "_select_endless_battlefield").bind(battlefield_id), EXPEDITION_ROUTE_BUTTON_SIZE, not usable, 15)
		if not usable:
			_set_button_locked_visual(battlefield_button)
		elif selected:
			battlefield_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_set_button_owned_visual(battlefield_button)
	_create_button("开始无尽", "兵海生存 · 20 分钟", _expedition_preview_rect().end - Vector2(258.0, 66.0), _start_selected_endless, Vector2(236.0, 52.0), false, 16)

func _populate_boss_trial_expedition() -> void:
	var preview := _expedition_preview_rect()
	_create_button("进入试炼", "Lv.5 起战 · 三次整备 · 精英与张郃", preview.end - Vector2(258.0, 66.0), _start_boss_trial, Vector2(236.0, 52.0), false, 16)

func _select_story_chapter(chapter_id: String) -> void:
	var chapter_index := STORY_CHAPTER_IDS.find(chapter_id)
	if chapter_index < 0 or not SaveService.is_story_chapter_unlocked(chapter_index + 1):
		return
	selected_story_chapter_id = chapter_id
	_show_expedition("story")

func _select_endless_battlefield(battlefield_id: String) -> void:
	var definition := _battlefield_definition(battlefield_id)
	if not SaveService.is_battlefield_unlocked(battlefield_id) or not bool(definition.get("implemented", false)):
		return
	selected_endless_battlefield_id = battlefield_id
	_show_expedition("endless")

func _battlefield_definition(battlefield_id: String) -> Dictionary:
	return BATTLEFIELD_DEFINITIONS.get(battlefield_id, BATTLEFIELD_DEFINITIONS["changban"]) as Dictionary

func _story_chapter_definition(chapter_id: String) -> Dictionary:
	return STORY_CHAPTER_DEFINITIONS.get(chapter_id, STORY_CHAPTER_DEFINITIONS["story_01"]) as Dictionary

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
	page = "shop"
	shop_section = section if section in ["heroes", "strategies", "tianji"] else "heroes"
	profile = SaveService.load_profile()
	notice = ""
	_clear_buttons()
	if not HERO_CATALOG.has_hero(selected_shop_hero_id) or not _is_release_hero_available(selected_shop_hero_id):
		selected_shop_hero_id = "zhao_yun"
	var tab_size := Vector2(170.0, 48.0)
	var tab_gap := 12.0
	var tab_start := Vector2(size.x * 0.5 - (tab_size.x * 1.5 + tab_gap), 96.0)
	var hero_tab := _create_button("武将", "", tab_start, _show_shop_heroes, tab_size, false, 17)
	var strategy_tab := _create_button("军略", "", tab_start + Vector2(tab_size.x + tab_gap, 0.0), _show_shop_strategies, tab_size, false, 17)
	var tianji_tab := _create_button("天机", "", tab_start + Vector2((tab_size.x + tab_gap) * 2.0, 0.0), _show_shop_tianji, tab_size, false, 17)
	if shop_section == "heroes":
		hero_tab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_button_owned_visual(hero_tab)
		_set_button_locked_visual(strategy_tab)
		_set_button_locked_visual(tianji_tab)
	elif shop_section == "strategies":
		strategy_tab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_button_owned_visual(strategy_tab)
		_set_button_locked_visual(hero_tab)
		_set_button_locked_visual(tianji_tab)
	else:
		tianji_tab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_button_owned_visual(tianji_tab)
		_set_button_locked_visual(hero_tab)
		_set_button_locked_visual(strategy_tab)
	match shop_section:
		"heroes": _populate_hero_shop()
		"strategies": _populate_strategy_shop()
		"tianji": _populate_tianji_shop()
	_create_button("返回", "", Vector2(_safe_margin(), 28.0), _show_main, Vector2(126.0, 46.0))
	queue_redraw()

func _show_shop_heroes() -> void:
	_show_shop("heroes")

func _show_shop_strategies() -> void:
	_show_shop("strategies")

func _show_shop_tianji() -> void:
	_show_shop("tianji")

func _populate_hero_shop() -> void:
	var hero_catalog_ids: Array[String] = []
	for hero_id in HERO_CATALOG.all_ids():
		hero_catalog_ids.append(str(hero_id))
	var hero_selector_gap := 12.0
	var hero_selector_size := Vector2((size.x - 112.0 - hero_selector_gap * float(hero_catalog_ids.size() - 1)) / float(hero_catalog_ids.size()), 54.0)
	var selector_start := Vector2(56.0, 214.0)
	for index in range(hero_catalog_ids.size()):
		var hero_id := hero_catalog_ids[index]
		var hero := HERO_CATALOG.definition_for(hero_id)
		var available := _is_release_hero_available(hero_id)
		var owned := available and SaveService.has_hero(hero_id)
		var state := "敬请期待" if not _is_release_hero_available(hero_id) else ("已拥有" if owned else "未解锁")
		var hero_button := _create_button(str(hero.get("name", "武将")), state, selector_start + Vector2(float(index) * (hero_selector_size.x + 12.0), 0.0), Callable(self, "_select_shop_hero").bind(hero_id), hero_selector_size, not available, 14)
		if hero_id == selected_shop_hero_id:
			hero_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if owned:
			_set_button_owned_visual(hero_button)
		else:
			_set_button_locked_visual(hero_button)
	_populate_hero_talent_tree()

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
	var is_owned := SaveService.has_hero(selected_shop_hero_id)
	var root_button := _create_button(str(_shop_hero().get("name", "武将")), "专属战法", HERO_TREE_ROOT_RECT.position, _show_shop_heroes, HERO_TREE_ROOT_RECT.size, false, 13, content, false)
	root_button.z_index = 1
	root_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_owned:
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
		if bool(node.get("is_core", false)):
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
	if bool(node.get("is_core", false)):
		var core_button := _create_button(str(definition.get("title", talent_id)), _talent_tree_summary(node), node_rect.position, Callable(self, "_show_talent_detail").bind(selected_shop_hero_id, talent_id, 0, true), node_rect.size, false, 11, content, false)
		core_button.tooltip_text = str(definition.get("description", ""))
		if is_owned:
			_set_button_owned_visual(core_button)
		else:
			_set_button_locked_visual(core_button)
		return
	var prerequisite_id := str(definition.get("requires", ""))
	var prerequisite_unlocked := prerequisite_id.is_empty() or SaveService.is_talent_unlocked_for_purchase(selected_shop_hero_id, prerequisite_id)
	var purchased := SaveService.has_talent(selected_shop_hero_id, talent_id)
	var talent_button := _create_button(str(definition.get("title", talent_id)), _talent_tree_summary(node), node_rect.position, Callable(self, "_show_talent_detail").bind(selected_shop_hero_id, talent_id, int(node.get("cost", 0)), false), node_rect.size, false, 11, content, false)
	talent_button.tooltip_text = str(definition.get("description", ""))
	if purchased:
		_set_button_owned_visual(talent_button)
	else:
		_set_button_locked_visual(talent_button)

func _talent_tree_summary(node: Dictionary) -> String:
	var summary := str(node.get("summary", ""))
	return summary.left(6) if summary.length() > 6 else summary

func _show_talent_detail(hero_id: String, talent_id: String, cost: int, is_core: bool = false) -> void:
	if page != "shop" or shop_section != "heroes":
		return
	_close_talent_detail()
	var definition: Dictionary = UpgradeSystem.DEFINITIONS.get(talent_id, {}) as Dictionary
	if definition.is_empty():
		return
	var hero_owned := SaveService.has_hero(hero_id)
	var purchased := SaveService.has_talent(hero_id, talent_id)
	var prerequisite_id := str(definition.get("requires", ""))
	var prerequisite_unlocked := prerequisite_id.is_empty() or SaveService.is_talent_unlocked_for_purchase(hero_id, prerequisite_id)
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
	dialog.add_theme_stylebox_override("panel", _make_box_style(Color("10191f"), GOLD, 2))
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
	var description_label := Label.new()
	description_label.text = str(definition.get("description", ""))
	description_label.position = Vector2(24.0, 104.0)
	description_label.size = Vector2(content_width, dialog_size.y - 220.0)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	description_label.add_theme_font_size_override("font_size", 19)
	description_label.add_theme_color_override("font_color", Color("d8e6e2"))
	description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(description_label)
	var status_label := Label.new()
	status_label.position = Vector2(24.0, dialog_size.y - 106.0)
	status_label.size = Vector2(content_width, 24.0)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var purchase_disabled := is_core or purchased or not hero_owned or not prerequisite_unlocked
	if is_core:
		status_label.text = "默认开放"
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	elif purchased:
		status_label.text = "已解锁"
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	elif not hero_owned:
		status_label.text = "需先招募该武将"
		status_label.add_theme_color_override("font_color", MUTED)
	elif not prerequisite_unlocked:
		var prerequisite: Dictionary = UpgradeSystem.DEFINITIONS.get(prerequisite_id, {}) as Dictionary
		status_label.text = "前置：%s" % str(prerequisite.get("title", prerequisite_id))
		status_label.add_theme_color_override("font_color", Color("f1bd73"))
	else:
		status_label.text = "消耗 %d 军功" % cost
		status_label.add_theme_color_override("font_color", GOLD_BRIGHT)
	dialog.add_child(status_label)
	var action_y := dialog_size.y - 62.0
	var purchase_title := "默认开放" if is_core else ("已解锁" if purchased else "购买 · %d 军功" % cost)
	var purchase_button := _create_button(purchase_title, "", Vector2(24.0, action_y), Callable(self, "_buy_talent_from_detail").bind(hero_id, talent_id, cost), Vector2((content_width - 12.0) * 0.5, 44.0), purchase_disabled, 16, dialog, false)
	if purchase_disabled:
		_set_button_locked_visual(purchase_button)
	var close_button := _create_button("关闭", "", Vector2(36.0 + (content_width - 12.0) * 0.5, action_y), _close_talent_detail, Vector2((content_width - 12.0) * 0.5, 44.0), false, 16, dialog, false)
	close_button.add_theme_stylebox_override("normal", _make_box_style(Color("17242a"), DRAGON_BLUE, 2))
	close_button.add_theme_stylebox_override("hover", _make_box_style(Color("20343c"), DRAGON_BLUE, 3))

func _buy_talent_from_detail(hero_id: String, talent_id: String, cost: int) -> void:
	_close_talent_detail()
	_buy_talent(hero_id, talent_id, cost)

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
	var prerequisite_id := MILITARY_STRATEGY.prerequisite_for(strategy_id)
	var prerequisite_unlocked := prerequisite_id.is_empty() or SaveService.strategy_rank(prerequisite_id) > 0
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
	dialog.add_theme_stylebox_override("panel", _make_box_style(Color("10191f"), GOLD, 2))
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
	var description_label := Label.new()
	description_label.text = str(definition.get("description", ""))
	description_label.position = Vector2(24.0, 104.0)
	description_label.size = Vector2(content_width, 92.0)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
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
		status_label.text = "前置军略：%s" % MILITARY_STRATEGY.title_for(prerequisite_id)
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
	var purchase_title := "已满阶" if maxed else ("需先解锁前置" if not prerequisite_unlocked else "研习 · %d 军功" % cost)
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
	var prerequisite_id := MILITARY_STRATEGY.prerequisite_for(strategy_id)
	if not prerequisite_id.is_empty() and SaveService.strategy_rank(prerequisite_id) <= 0:
		_show_strategy_detail(strategy_id, "请先解锁前置军略：%s" % MILITARY_STRATEGY.title_for(prerequisite_id))
		return
	var cost := SaveService.strategy_cost(strategy_id)
	if int(current_profile.get("military_merit", 0)) < cost:
		_show_strategy_detail(strategy_id, "军功不足")
		return
	_close_strategy_detail()
	_buy_strategy(strategy_id)

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
	if not _is_release_hero_available(hero_id):
		return
	selected_shop_hero_id = hero_id
	_show_shop("heroes")

func _populate_strategy_shop() -> void:
	var row_heights := _strategy_row_heights()
	var current_merit := int(profile.get("military_merit", 0))
	var viewport := Rect2(36.0, 232.0, maxf(320.0, size.x - 72.0), maxf(260.0, size.y - 276.0))
	var scroll := _create_page_scroll(viewport, "纵向滚动查看完整军略")
	var content := Control.new()
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	var content_width := maxf(viewport.size.x - 18.0, 40.0 + float(MILITARY_STRATEGY.BRANCHES.size()) * (STRATEGY_CARD_WIDTH + STRATEGY_CARD_GAP.x) + 20.0)
	var content_height := 62.0
	for row_height in row_heights:
		content_height += row_height + STRATEGY_CARD_GAP.y
	content_height += 24.0
	content.custom_minimum_size = Vector2(content_width, content_height)
	content.size = content.custom_minimum_size
	scroll.add_child(content)
	for branch_index in range(MILITARY_STRATEGY.BRANCHES.size()):
		var branch: Dictionary = MILITARY_STRATEGY.BRANCHES[branch_index] as Dictionary
		var nodes: Array = branch.get("nodes", []) as Array
		var branch_origin := Vector2(20.0 + float(branch_index) * (STRATEGY_CARD_WIDTH + STRATEGY_CARD_GAP.x), 46.0)
		var branch_label := Label.new()
		branch_label.text = "%s\n%s" % [str(branch.get("title", "军略")), str(branch.get("subtitle", ""))]
		branch_label.position = branch_origin - Vector2(0.0, 42.0)
		branch_label.size = Vector2(STRATEGY_CARD_WIDTH, 40.0)
		branch_label.add_theme_font_size_override("font_size", 13)
		branch_label.add_theme_color_override("font_color", GOLD_BRIGHT)
		branch_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		branch_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(branch_label)
		var row_offset := 0.0
		for node_index in range(nodes.size()):
			var strategy_id := str(nodes[node_index])
			var definition := MILITARY_STRATEGY.definition_for(strategy_id)
			var rank := SaveService.strategy_rank(strategy_id)
			var max_rank := int(definition.get("max_rank", 0))
			var maxed := rank >= max_rank
			var cost := SaveService.strategy_cost(strategy_id)
			var can_afford := current_merit >= cost
			var prerequisite_id := MILITARY_STRATEGY.prerequisite_for(strategy_id)
			var prerequisite_unlocked := prerequisite_id.is_empty() or SaveService.strategy_rank(prerequisite_id) > 0
			var prerequisite_title := MILITARY_STRATEGY.title_for(prerequisite_id) if not prerequisite_id.is_empty() else ""
			var status := "下一阶 %d 军功 · %d/%d" % [cost, rank, max_rank]
			if maxed:
				status = "已满阶"
			elif not prerequisite_unlocked:
				status = "前置：%s" % prerequisite_title
			elif not can_afford:
				status = "军功不足 · 还差 %d" % (cost - current_merit)
			var card_height := row_heights[node_index]
			var card := _create_strategy_card(str(definition.get("title", strategy_id)), str(definition.get("description", "")), status, branch_origin + Vector2(0.0, row_offset), Vector2(STRATEGY_CARD_WIDTH, card_height), Callable(self, "_show_strategy_detail").bind(strategy_id), false, (can_afford or maxed) and prerequisite_unlocked, content)
			card.tooltip_text = "%s · 全英雄永久生效" % str(definition.get("description", ""))
			if rank > 0:
				_set_button_owned_visual(card)
			elif not can_afford or not prerequisite_unlocked:
				_set_button_locked_visual(card)
			row_offset += card_height + STRATEGY_CARD_GAP.y

func _populate_tianji_shop() -> void:
	var current_merit := int(profile.get("military_merit", 0))
	var tianji_info := Label.new()
	tianji_info.text = "军功研习 · 永久解锁与升阶 · 战斗中通过三选一启阵"
	tianji_info.position = Vector2(56.0, 204.0)
	tianji_info.size = Vector2(size.x - 112.0, 28.0)
	tianji_info.add_theme_font_size_override("font_size", 18)
	tianji_info.add_theme_color_override("font_color", GOLD_BRIGHT)
	tianji_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tianji_info)
	page_controls.append(tianji_info)
	var viewport := Rect2(48.0, 292.0, maxf(320.0, size.x - 96.0), maxf(240.0, size.y - 336.0))
	var scroll := _create_page_scroll(viewport, "纵向滚动查看天机卡牌")
	var content := Control.new()
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	var column_count := 3
	var content_width := maxf(320.0, viewport.size.x - 18.0)
	var card_size := Vector2((content_width - 24.0) / float(column_count), 148.0)
	var row_count := int(ceil(float(TIANJI_CATALOG.ORDER.size()) / float(column_count)))
	content.custom_minimum_size = Vector2(content_width, 12.0 + float(row_count) * (card_size.y + 14.0) + 12.0)
	content.size = content.custom_minimum_size
	scroll.add_child(content)
	for index in range(TIANJI_CATALOG.ORDER.size()):
		var skill_id := TIANJI_CATALOG.ORDER[index]
		var definition := TIANJI_CATALOG.definition_for(skill_id)
		var rank := SaveService.tianji_rank(skill_id)
		var max_rank := TIANJI_CATALOG.max_rank_for(skill_id)
		var maxed := rank >= max_rank
		var cost := SaveService.tianji_cost(skill_id)
		var can_afford := current_merit >= cost
		var state := "已满阶" if maxed else ("军功不足 · 还差 %d" % (cost - current_merit) if not can_afford else ("解锁消耗 %d 军功" % cost if rank == 0 else "下一阶消耗 %d 军功 · %d/%d" % [cost, rank, max_rank]))
		var subtitle := "%s\n%s\n%s\n战斗中需通过三选一“启阵”后生效。" % [str(definition.get("subtitle", "天机")), str(definition.get("description", "")), state]
		var column := index % column_count
		var row := int(index / column_count)
		var position := Vector2(12.0 + float(column) * (card_size.x + 12.0), 12.0 + float(row) * (card_size.y + 14.0))
		var card := _create_button(TIANJI_CATALOG.title_for(skill_id), subtitle, position, Callable(self, "_buy_tianji").bind(skill_id), card_size, maxed, 15, content, false)
		card.tooltip_text = str(definition.get("description", ""))
		if rank > 0:
			_set_button_owned_visual(card)
		elif not can_afford:
			_set_button_locked_visual(card)

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
			var definition := MILITARY_STRATEGY.definition_for(str(nodes[node_index]))
			row_height = maxf(row_height, _strategy_card_height_for(str(definition.get("description", ""))))
		row_heights.append(row_height)
	return row_heights

func _strategy_card_height_for(description: String) -> float:
	var line_count := maxi(1, ceili(float(description.length()) / float(STRATEGY_CARD_DESCRIPTION_CHARS_PER_LINE)))
	return maxf(STRATEGY_CARD_MIN_HEIGHT, 60.0 + float(line_count) * STRATEGY_CARD_DESCRIPTION_LINE_HEIGHT)

func _create_strategy_card(title: String, description: String, status: String, at: Vector2, card_size: Vector2, callback: Callable, disabled: bool, purchasable: bool, parent: Control = null) -> Button:
	var card := _create_button("", "", at, callback, card_size, disabled, 13, parent, parent == null)
	var text_width := card_size.x - 24.0
	var description_lines := maxi(1, ceili(float(description.length()) / float(STRATEGY_CARD_DESCRIPTION_CHARS_PER_LINE)))
	var description_height := float(description_lines) * STRATEGY_CARD_DESCRIPTION_LINE_HEIGHT
	var title_label := Label.new()
	title_label.text = title
	title_label.position = Vector2(12.0, 7.0)
	title_label.size = Vector2(text_width, 18.0)
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", GOLD_BRIGHT if purchasable else Color("a0abad"))
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(title_label)
	var description_label := Label.new()
	description_label.text = description
	description_label.position = Vector2(12.0, 27.0)
	description_label.size = Vector2(text_width, description_height + 2.0)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 12)
	description_label.add_theme_color_override("font_color", Color("c1cecb") if purchasable else Color("7e8a8e"))
	description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(description_label)
	var status_label := Label.new()
	status_label.text = status
	status_label.position = Vector2(12.0, card_size.y - 20.0)
	status_label.size = Vector2(text_width, 14.0)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_label.add_theme_font_size_override("font_size", 11)
	status_label.add_theme_color_override("font_color", Color("dba86e") if not purchasable and not disabled else (Color("9ee0c6") if disabled else Color("b8d6d0")))
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(status_label)
	return card

func _show_settings() -> void:
	page = "settings"
	profile = SaveService.load_profile()
	notice = ""
	_clear_buttons()
	var panel_size := Vector2(minf(640.0, size.x - 56.0), minf(470.0, size.y - 96.0))
	var panel_origin := Vector2((size.x - panel_size.x) * 0.5, (size.y - panel_size.y) * 0.5 + 18.0)
	var panel := Panel.new()
	panel.position = panel_origin
	panel.size = panel_size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _make_box_style(PANEL_FILL, Color("7b6644"), 1))
	add_child(panel)
	page_controls.append(panel)
	_create_settings_label(panel, "设置", Vector2(28.0, 22.0), Vector2(panel_size.x - 56.0, 34.0), 30, GOLD_BRIGHT, HORIZONTAL_ALIGNMENT_LEFT)
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
	_create_button("震动：%s" % vibration_text, "命中与受击反馈", panel_origin + Vector2(28.0, 348.0), _toggle_vibration, Vector2(content_width, 52.0), false, 17)
	_create_button("返回", "", Vector2(_safe_margin(), 28.0), _show_main, Vector2(126.0, 46.0))
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
	page = "hero_select"
	selected_run_mode = mode
	selected_run_battlefield_id = battlefield_id
	hero_select_return_tab = return_tab
	profile = SaveService.load_profile()
	notice = ""
	hero_select_idle_elapsed = 0.0
	_clear_buttons()
	hero_select_idle_sprite = null
	_refresh_hero_ids(preserve_selection)
	_populate_hero_select_portraits()
	_populate_hero_select_slots()
	var can_depart := _is_release_hero_available(_selected_hero_id())
	var margin := _safe_margin()
	var depart_button := _create_button("出征", "", Vector2(size.x - margin - 174.0, 28.0), _begin_selected_run, Vector2(174.0, 46.0), not can_depart, 18)
	_configure_hero_select_action_button(depart_button, true)
	depart_button.add_theme_font_size_override("font_size", 18)
	depart_button.z_index = 24
	var back_button := _create_button("返回", "", Vector2(margin, 28.0), Callable(self, "_show_expedition").bind(hero_select_return_tab), Vector2(126.0, 46.0))
	back_button.z_index = 24
	queue_redraw()

func _show_hero_select_from_details() -> void:
	_show_hero_select(selected_run_mode, selected_run_battlefield_id, hero_select_return_tab, true)

func _show_selected_hero_details() -> void:
	_show_hero_details_from("hero_select")

func _begin_selected_run() -> void:
	var hero_id := _selected_hero_id()
	if not _is_release_hero_available(hero_id) or not SaveService.equip_hero(hero_id):
		return
	SceneRouter.start_run(selected_run_mode, selected_run_battlefield_id, selected_run_story_chapter)

func _start_story() -> void:
	SceneRouter.start_run("story", "xinye", 1)

func _start_selected_story() -> void:
	var chapter_index := STORY_CHAPTER_IDS.find(selected_story_chapter_id)
	if chapter_index < 0 or not SaveService.is_story_chapter_unlocked(chapter_index + 1):
		return
	selected_run_story_chapter = chapter_index + 1
	_show_hero_select("story", _story_battlefield_id(selected_run_story_chapter), "story")

func _story_battlefield_id(chapter: int) -> String:
	match chapter:
		1:
			return "xinye"
		2:
			return "bowangpo_story"
		3:
			return "huoshaoxinye"
		4:
			return "xiangyangchetui"
		5:
			return "dangyangduanhou"
		_:
			return "changban"

func _start_endless() -> void:
	SceneRouter.start_run("endless", selected_endless_battlefield_id)

func _start_selected_endless() -> void:
	_show_hero_select("endless", selected_endless_battlefield_id, "endless")

func _start_boss_trial() -> void:
	_show_hero_select("boss_trial", "hulao", "boss_trial")

func _buy_strategy(strategy_id: String) -> void:
	if SaveService.purchase_strategy(strategy_id):
		_show_shop("strategies")
		notice = "%s 已研习，永久作用于所有武将" % MILITARY_STRATEGY.title_for(strategy_id)
		queue_redraw()
		return
	var is_maxed := SaveService.strategy_rank(strategy_id) >= MILITARY_STRATEGY.max_rank_for(strategy_id)
	var prerequisite_id := MILITARY_STRATEGY.prerequisite_for(strategy_id)
	_show_shop("strategies")
	notice = "该军略已满阶" if is_maxed else ("请先解锁前置军略：%s" % MILITARY_STRATEGY.title_for(prerequisite_id) if not prerequisite_id.is_empty() and SaveService.strategy_rank(prerequisite_id) <= 0 else "军功不足")
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
		_show_shop("heroes")
		notice = "%s 的 %s 已解锁" % [str(HERO_CATALOG.definition_for(hero_id).get("name", "武将")), str(definition.get("title", talent_id))]
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
	var weather_modes: Array[String] = ["auto", "sunny", "rain", "storm"]
	if index < 0 or index >= weather_modes.size():
		return
	SaveService.set_setting_value("weather_mode", weather_modes[index])
	queue_redraw()

func _refresh_hero_ids(preserve_selection: bool = false) -> void:
	var previous_hero_id := _selected_hero_id()
	hero_ids.clear()
	for hero_id in RELEASE_HERO_IDS:
		if SaveService.has_hero(hero_id):
			hero_ids.append(hero_id)
	if hero_ids.is_empty():
		hero_ids.append("zhao_yun")
	var preferred_hero_id := SaveService.equipped_hero_id()
	if preserve_selection and hero_ids.has(previous_hero_id):
		preferred_hero_id = previous_hero_id
	if not hero_ids.has(preferred_hero_id):
		preferred_hero_id = "zhao_yun" if hero_ids.has("zhao_yun") else hero_ids.front()
	selected_hero_index = maxi(0, hero_ids.find(preferred_hero_id))

func _is_release_hero_available(hero_id: String) -> bool:
	return RELEASE_HERO_IDS.has(hero_id) and SaveService.has_hero(hero_id)

func _hero_select_portrait_rect(hero_id: String) -> Rect2:
	var layout_scale := minf(size.x / 1280.0, size.y / 720.0)
	var center_x := size.x * 0.5
	match hero_id:
		"guan_yu":
			return Rect2(Vector2(center_x - 175.0 * layout_scale, 40.0 * layout_scale), Vector2(340.0, 530.0) * layout_scale)
		"zhang_fei":
			return Rect2(Vector2(center_x - 432.0 * layout_scale, 72.0 * layout_scale), Vector2(330.0, 495.0) * layout_scale)
		"zhao_yun":
			return Rect2(Vector2(center_x + 65.0 * layout_scale, 54.0 * layout_scale), Vector2(326.0, 525.0) * layout_scale)
		"ma_chao":
			return Rect2(Vector2(center_x + 360.0 * layout_scale, 92.0 * layout_scale), Vector2(270.0, 480.0) * layout_scale)
		"huang_zhong":
			return Rect2(Vector2(center_x - 658.0 * layout_scale, 83.0 * layout_scale), Vector2(280.0, 498.0) * layout_scale)
		_:
			return Rect2(Vector2(center_x - 104.0 * layout_scale, 96.0 * layout_scale), Vector2(208.0, 360.0) * layout_scale)

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
	var catalog_ids: Array[String] = HERO_CATALOG.all_ids()
	for hero_id in catalog_ids:
		var hero := HERO_CATALOG.definition_for(hero_id)
		var portrait_rect := _hero_select_portrait_rect(hero_id)
		var available := _is_release_hero_available(hero_id)
		var selected := available and hero_id == _selected_hero_id()
		var portrait_path := str(hero.get("portrait", ""))
		if not portrait_path.is_empty():
			var portrait := TextureRect.new()
			# Disable the texture-driven minimum size before assigning the target layout rect.
			portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			portrait.texture = _portrait_for(portrait_path)
			portrait.position = portrait_rect.position
			portrait.size = portrait_rect.size
			# Each rect follows its source portrait ratio, so scale-to-fit keeps the five-hero layout legible.
			portrait.stretch_mode = TextureRect.STRETCH_SCALE
			portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
			# Selected portraits keep their source colors; all other portraits use the alpha-safe dim material.
			portrait.material = null if selected else _hero_select_portrait_material()
			portrait.z_index = _hero_select_portrait_layer(hero_id) + (8 if selected else 0)
			add_child(portrait)
			page_controls.append(portrait)
			if available:
				_create_hero_select_portrait_hitbox(portrait_rect, hero_id, selected)

func _populate_hero_select_slots() -> void:
	for slot_index in range(HERO_SELECT_SLOT_IDS.size()):
		var hero_id := HERO_SELECT_SLOT_IDS[slot_index]
		var slot_rect := _hero_select_slot_rect(slot_index)
		var hero := HERO_CATALOG.definition_for(hero_id)
		var available := _is_release_hero_available(hero_id)
		var selected := available and hero_id == _selected_hero_id()
		_create_hero_select_slot_panel(slot_rect, selected, available)
		_populate_hero_select_slot_content(slot_rect, hero, selected, available)
		if selected:
			var details_rect := Rect2(slot_rect.position + Vector2(13.0, 48.0), Vector2(slot_rect.size.x - 26.0, 24.0))
			var details_button := _create_button("属性详情", "", details_rect.position, _show_selected_hero_details, details_rect.size, false, 13)
			_configure_hero_select_action_button(details_button, false)
		elif available:
			var select_button := _create_button("", "", slot_rect.position, Callable(self, "_select_hero_for_run").bind(hero_id), slot_rect.size, false, 16)
			_configure_hero_select_slot_button(select_button)

func _create_hero_select_slot_panel(slot_rect: Rect2, selected: bool, available: bool) -> void:
	var panel := Panel.new()
	panel.position = slot_rect.position
	panel.size = slot_rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = 16
	var border := GOLD_BRIGHT if selected else (Color("62747c") if available else Color("3a474c"))
	var fill := Color(0.01, 0.02, 0.025, 0.36) if selected else Color(0.01, 0.02, 0.025, 0.58)
	panel.add_theme_stylebox_override("panel", _make_box_style(fill, border, 2 if selected else 1))
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

func _hero_select_portrait_material() -> ShaderMaterial:
	if hero_select_portrait_shader == null:
		hero_select_portrait_shader = Shader.new()
		hero_select_portrait_shader.code = HERO_SELECT_PORTRAIT_SHADER_CODE
	var material := ShaderMaterial.new()
	material.shader = hero_select_portrait_shader
	material.set_shader_parameter("dim_amount", 0.70)
	material.set_shader_parameter("brightness", 0.42)
	return material

func _select_hero_for_run(hero_id: String) -> void:
	var index := hero_ids.find(hero_id)
	if index < 0 or index == selected_hero_index:
		return
	selected_hero_index = index
	_show_hero_select(selected_run_mode, selected_run_battlefield_id, hero_select_return_tab, true)

func _selected_hero_id() -> String:
	return hero_ids[selected_hero_index] if not hero_ids.is_empty() else "zhao_yun"

func _selected_hero() -> Dictionary:
	return HERO_CATALOG.definition_for(_selected_hero_id())

func _gui_input(event: InputEvent) -> void:
	if page != "title":
		return
	if event is InputEventScreenTouch and event.pressed:
		_enter_from_title()
		accept_event()
	elif event is InputEventMouseButton and event.pressed:
		_enter_from_title()
		accept_event()
	elif event is InputEventKey and event.pressed and not event.echo:
		_enter_from_title()
		accept_event()

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

func _on_page_scroll_gui_input(event: InputEvent, scroll: ScrollContainer) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			page_scroll_touch_index = event.index
			page_scroll_drag_start = event.position
			page_scroll_drag_start_offset = scroll.scroll_vertical
			page_scroll_dragging = false
		elif event.index == page_scroll_touch_index:
			if page_scroll_dragging:
				scroll.accept_event()
			page_scroll_touch_index = -1
			page_scroll_dragging = false
		return
	if event is InputEventScreenDrag and event.index == page_scroll_touch_index:
		if _update_page_scroll(scroll, event.position):
			scroll.accept_event()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			page_scroll_mouse_dragging = true
			page_scroll_drag_start = event.position
			page_scroll_drag_start_offset = scroll.scroll_vertical
			page_scroll_dragging = false
		elif page_scroll_mouse_dragging:
			if page_scroll_dragging:
				scroll.accept_event()
			page_scroll_mouse_dragging = false
			page_scroll_dragging = false
		return
	if event is InputEventMouseMotion and page_scroll_mouse_dragging:
		if _update_page_scroll(scroll, event.position):
			scroll.accept_event()

func _update_page_scroll(scroll: ScrollContainer, pointer_position: Vector2) -> bool:
	var delta_y := pointer_position.y - page_scroll_drag_start.y
	if not page_scroll_dragging and absf(delta_y) < PAGE_SCROLL_DRAG_THRESHOLD:
		return false
	page_scroll_dragging = true
	var bar := scroll.get_v_scroll_bar()
	var target_scroll := clampf(float(page_scroll_drag_start_offset) - delta_y, bar.min_value, bar.max_value)
	scroll.scroll_vertical = int(round(target_scroll))
	return true

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
	var weather_modes: Array[String] = ["auto", "sunny", "rain", "storm"]
	var weather_labels: Array[String] = ["自动（每局随机）", "晴天", "雨天", "雷雨"]
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

func _clear_buttons() -> void:
	talent_detail_dialog = null
	strategy_detail_dialog = null
	strategy_detail_notice = ""
	page_scroll_touch_index = -1
	page_scroll_dragging = false
	page_scroll_mouse_dragging = false
	for control in page_controls:
		if is_instance_valid(control):
			control.queue_free()
	page_controls.clear()
	for button in buttons:
		button.queue_free()
	buttons.clear()
	for control in setting_controls:
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
	var background_rect := Rect2(Vector2.ZERO, size)
	draw_texture_rect(NON_COMBAT_BACKGROUND_TEXTURE, background_rect, false, Color(0.78, 0.78, 0.78, 0.94))
	draw_rect(background_rect, Color(0.02, 0.025, 0.03, 0.48))
	var font := ThemeDB.fallback_font
	var margin := _safe_margin()
	if page == "main":
		draw_string(font, Vector2(margin + 12.0, 96), "三国 破阵无双", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, GOLD_BRIGHT)
		draw_string(font, Vector2(margin + 16.0, 128), "名将破阵 · 兵海无双", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("a9c2c7"))
	if page == "shop":
		draw_string(font, Vector2(size.x - margin - 240.0, 52), "军功  %d" % int(profile.get("military_merit", 0)), HORIZONTAL_ALIGNMENT_LEFT, 220.0, 21, GOLD_BRIGHT)
	match page:
		"modes", "expedition": _draw_expedition(font)
		"hero_select": _draw_hero_select(font)
		"shop": _draw_shop(font)
		"settings": _draw_settings(font)
		"hero_details": _draw_hero_details(font)
	if not notice.is_empty():
		draw_string(font, Vector2(size.x * 0.5 - 156.0, size.y - 34.0), notice, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("9ee0c6"))
	if title_menu_fade_remaining > 0.0:
		var fade_alpha := clampf(title_menu_fade_remaining / TITLE_MENU_FADE_DURATION, 0.0, 1.0)
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, fade_alpha))

func _draw_title_screen(font: Font) -> void:
	var intro_progress := clampf(title_elapsed / TITLE_INTRO_DURATION, 0.0, 1.0)
	var intro_eased := 1.0 - pow(1.0 - intro_progress, 3.0)
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
	var prompt_width := font.get_string_size(TITLE_PROMPT_TEXT, HORIZONTAL_ALIGNMENT_LEFT, -1.0, prompt_font_size).x
	var prompt_center_x := size.x * 0.76
	var prompt_left := prompt_center_x - prompt_width * 0.5
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
	draw_string_outline(font, Vector2(prompt_left, prompt_y), TITLE_PROMPT_TEXT, HORIZONTAL_ALIGNMENT_LEFT, -1.0, prompt_font_size, 4, Color(1.0, 0.57, 0.18, 0.10 + pulse_phase * 0.32))
	draw_string(font, Vector2(prompt_left, prompt_y), TITLE_PROMPT_TEXT, HORIZONTAL_ALIGNMENT_LEFT, -1.0, prompt_font_size, prompt_color)
	if intro_progress < 1.0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, (1.0 - intro_eased) * 0.62))
	if title_enter_seal_remaining > 0.0:
		_draw_title_enter_seal(Vector2(prompt_center_x, size.y * 0.5))

func _setup_title_frame_player() -> void:
	title_frame_layer = TextureRect.new()
	title_frame_layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_frame_layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	title_frame_layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	title_frame_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_frame_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_frame_layer.show_behind_parent = true
	title_frame_layer.z_index = -19
	title_frame_layer.hide()
	add_child(title_frame_layer)
	title_frame_transition_layer = TextureRect.new()
	title_frame_transition_layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_frame_transition_layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	title_frame_transition_layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	title_frame_transition_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_frame_transition_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_frame_transition_layer.show_behind_parent = true
	title_frame_transition_layer.z_index = -18
	title_frame_transition_layer.modulate.a = 0.0
	title_frame_transition_layer.hide()
	add_child(title_frame_transition_layer)
	_load_title_frame_paths()
	_update_title_frame(0.0, true)

func _load_title_frame_paths() -> void:
	title_frame_paths.clear()
	# Build the list from known resource names so Android can load frames from the PCK.
	for frame_number in range(1, TITLE_FRAME_COUNT + 1):
		title_frame_paths.append(TITLE_FRAME_DIRECTORY.path_join("frame_%04d.webp" % frame_number))

func _update_title_frame(delta: float = 0.0, force: bool = false) -> void:
	if title_frame_layer == null or title_frame_paths.is_empty():
		return
	var frame_count := title_frame_paths.size()
	var base_frame_index := posmod(int(floor(title_elapsed * TITLE_FRAME_RATE)), frame_count)
	var frame_index := posmod(base_frame_index + title_frame_playback_offset, frame_count)
	if title_frame_transition_active:
		title_frame_transition_elapsed = minf(TITLE_FRAME_LOOP_CROSSFADE_DURATION, title_frame_transition_elapsed + maxf(0.0, delta))
		var transition_progress := clampf(title_frame_transition_elapsed / TITLE_FRAME_LOOP_CROSSFADE_DURATION, 0.0, 1.0)
		var transition_frame_offset := mini(TITLE_FRAME_LOOP_CROSSFADE_FRAME_COUNT, int(floor(title_frame_transition_elapsed * TITLE_FRAME_RATE)))
		var outgoing_index := mini(frame_count - 1, title_frame_transition_outgoing_start_index + transition_frame_offset)
		var incoming_index := mini(frame_count - 1, transition_frame_offset)
		var outgoing_texture := _load_title_frame_texture(outgoing_index)
		var incoming_texture := _load_title_frame_texture(incoming_index)
		if outgoing_texture != null:
			title_frame_layer.texture = outgoing_texture
		if incoming_texture != null and title_frame_transition_layer != null:
			title_frame_transition_layer.texture = incoming_texture
		# Smoothstep keeps both layers moving continuously without a visible opacity kink.
		var eased_progress := transition_progress * transition_progress * (3.0 - 2.0 * transition_progress)
		title_frame_layer.modulate.a = 1.0 - eased_progress
		if title_frame_transition_layer != null:
			title_frame_transition_layer.modulate.a = eased_progress
		title_frame_index = outgoing_index
		for offset in range(1, TITLE_FRAME_PREFETCH_COUNT + 1):
			_load_title_frame_texture(posmod(outgoing_index + offset, frame_count))
			_load_title_frame_texture(posmod(incoming_index + offset, frame_count))
		if transition_progress >= 1.0:
			if incoming_texture != null:
				title_frame_layer.texture = incoming_texture
			title_frame_layer.modulate.a = 1.0
			if title_frame_transition_layer != null:
				title_frame_transition_layer.modulate.a = 0.0
				title_frame_transition_layer.hide()
			title_frame_transition_active = false
			title_frame_transition_elapsed = 0.0
			title_frame_transition_outgoing_start_index = -1
			# Resume normal playback at the first frame after the overlap, not at raw frame 0.
			title_frame_playback_offset = posmod(incoming_index - base_frame_index, frame_count)
			title_frame_index = incoming_index
			_trim_title_frame_cache(incoming_index)
		return
	if not force and frame_index == title_frame_index:
		return
	var texture := _load_title_frame_texture(frame_index)
	if texture == null:
		return
	var transition_start_threshold := maxi(0, frame_count - TITLE_FRAME_LOOP_CROSSFADE_FRAME_COUNT)
	var is_loop_boundary := not force and frame_index >= transition_start_threshold and title_frame_index < transition_start_threshold
	if is_loop_boundary and title_frame_transition_layer != null:
		title_frame_transition_outgoing_start_index = frame_index
		title_frame_transition_elapsed = 0.0
		title_frame_transition_layer.texture = _load_title_frame_texture(0)
		title_frame_transition_layer.show()
		title_frame_transition_layer.modulate.a = 0.0
		title_frame_layer.texture = texture
		title_frame_layer.modulate.a = 1.0
		title_frame_transition_active = true
		title_frame_index = frame_index
		return
	title_frame_layer.texture = texture
	title_frame_layer.modulate.a = 1.0
	title_frame_index = frame_index
	for offset in range(1, TITLE_FRAME_PREFETCH_COUNT + 1):
		_load_title_frame_texture(posmod(frame_index + offset, title_frame_paths.size()))
	_trim_title_frame_cache(frame_index)

func _load_title_frame_texture(frame_index: int) -> Texture2D:
	if frame_index < 0 or frame_index >= title_frame_paths.size():
		return null
	if title_frame_cache.has(frame_index):
		return title_frame_cache[frame_index] as Texture2D
	var texture := ResourceLoader.load(title_frame_paths[frame_index], "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
	if texture == null:
		push_warning("Unable to load title frame: %s" % title_frame_paths[frame_index])
		return null
	title_frame_cache[frame_index] = texture
	return texture

func _trim_title_frame_cache(active_index: int) -> void:
	while title_frame_cache.size() > TITLE_FRAME_CACHE_SIZE:
		var discard_index := -1
		var furthest_distance := -1
		for cached_index_variant in title_frame_cache.keys():
			var cached_index := int(cached_index_variant)
			if cached_index == active_index:
				continue
			var distance := absi(cached_index - active_index)
			distance = mini(distance, title_frame_paths.size() - distance)
			if distance > furthest_distance:
				furthest_distance = distance
				discard_index = cached_index
		if discard_index < 0:
			break
		title_frame_cache.erase(discard_index)

func _clear_title_frame_cache() -> void:
	title_frame_index = -1
	title_frame_cache.clear()
	title_frame_transition_elapsed = 0.0
	title_frame_transition_outgoing_start_index = -1
	title_frame_transition_active = false
	title_frame_playback_offset = 0
	if title_frame_layer != null:
		title_frame_layer.texture = null
		title_frame_layer.modulate.a = 1.0
	if title_frame_transition_layer != null:
		title_frame_transition_layer.texture = null
		title_frame_transition_layer.modulate.a = 0.0

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

func _draw_hero_select(font: Font) -> void:
	var battlefield := _battlefield_definition(selected_run_battlefield_id)
	var first_slot := _hero_select_slot_rect(0)
	var stage_base := Rect2(0.0, 0.0, size.x, first_slot.position.y + 32.0)
	var card_band := Rect2(Vector2(0.0, stage_base.end.y), Vector2(size.x, maxf(0.0, size.y - stage_base.end.y)))
	draw_rect(card_band, Color(0.01, 0.02, 0.025, 0.30))
	for index in range(10):
		var slash_x := 32.0 + float(index) * maxf(80.0, size.x / 9.0)
		draw_line(Vector2(slash_x, 0.0), Vector2(slash_x - 168.0, stage_base.end.y), Color(0.85, 0.69, 0.43, 0.045), 1.0)
	var header_color := Color(0.93, 0.83, 0.64, 0.86)
	draw_string(font, Vector2(size.x * 0.5 - 100.0, 46.0), "五虎点将", HORIZONTAL_ALIGNMENT_CENTER, 200.0, 26, header_color)
	var destination_title := str(battlefield.get("title", "战场"))
	if selected_run_mode == "story" and selected_run_story_chapter >= 1 and selected_run_story_chapter <= STORY_CHAPTER_IDS.size():
		var chapter_id := STORY_CHAPTER_IDS[selected_run_story_chapter - 1]
		destination_title = str(_story_chapter_definition(chapter_id).get("title", destination_title))
	draw_string(font, Vector2(168.0, 44.0), destination_title, HORIZONTAL_ALIGNMENT_LEFT, 300.0, 16, Color("b9c9cd"))
	var selected_rect := _hero_select_portrait_rect(_selected_hero_id())
	var selected_ground := Vector2(selected_rect.get_center().x, stage_base.end.y - 28.0)
	_draw_ellipse_shadow(selected_ground, Vector2(104.0, 15.0), Color(0.92, 0.69, 0.26, 0.20))
	draw_arc(selected_ground, 76.0, PI, TAU, 20, Color(0.94, 0.73, 0.34, 0.30), 1.0)

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

func _create_hero_select_idle_sprite(slot_rect: Rect2, hero_id: String, animated: bool) -> void:
	var model_area := Control.new()
	model_area.position = slot_rect.position + Vector2(0.0, HERO_SELECT_IDLE_MODEL_TOP)
	model_area.size = Vector2(slot_rect.size.x, maxf(0.0, slot_rect.size.y - HERO_SELECT_IDLE_MODEL_TOP - HERO_SELECT_IDLE_MODEL_BOTTOM_GAP))
	model_area.clip_contents = true
	model_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	model_area.z_index = 17
	add_child(model_area)
	page_controls.append(model_area)

	var sprite := TextureRect.new()
	sprite.texture = _hero_select_idle_texture(hero_id, animated)
	sprite.size = HERO_SELECT_IDLE_SPRITE_SIZES.get(hero_id, Vector2(92.0, 72.0))
	var bottom_padding := float(HERO_SELECT_IDLE_BOTTOM_PADDING.get(hero_id, 12.0))
	sprite.position = Vector2((model_area.size.x - sprite.size.x) * 0.5, model_area.size.y - sprite.size.y + bottom_padding)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	model_area.add_child(sprite)
	if animated:
		hero_select_idle_sprite = sprite

func _update_hero_select_idle_sprite() -> void:
	if not is_instance_valid(hero_select_idle_sprite):
		return
	hero_select_idle_sprite.texture = _hero_select_idle_texture(_selected_hero_id(), true)

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
	draw_string(font, Vector2(size.x * 0.5 - 48.0, 52.0), "出征", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, GOLD_BRIGHT)
	draw_string(font, Vector2(size.x * 0.5 - 300.0, 162.0), _expedition_subtitle(), HORIZONTAL_ALIGNMENT_CENTER, 600.0, 16, Color("a9c2c7"))
	match expedition_tab:
		"story": _draw_story_expedition(font)
		"endless": _draw_endless_expedition(font)
		"boss_trial": _draw_boss_trial_expedition(font)

func _expedition_subtitle() -> String:
	match expedition_tab:
		"endless": return "选择已开放战场，在不断升级的兵海中守住阵线。"
		"boss_trial": return "紧凑斗将场，集中验证名将构筑、拼刀与破势。"
		_: return "荆州卷：从新野练兵推进至长坂坡救主。"

func _draw_story_expedition(font: Font) -> void:
	var definition := _story_chapter_definition(selected_story_chapter_id)
	var chapter_index := STORY_CHAPTER_IDS.find(selected_story_chapter_id)
	var unlocked := chapter_index >= 0 and SaveService.is_story_chapter_unlocked(chapter_index + 1)
	_draw_story_chapter_preview(_story_preview_rect(), definition, unlocked, font)
	_draw_story_chapter_details(_story_details_rect(), definition, chapter_index, unlocked, font)
	_draw_story_expedition_route(font)

func _draw_story_expedition_route(font: Font) -> void:
	draw_string(font, Vector2(82.0, 202.0), "荆州卷", HORIZONTAL_ALIGNMENT_LEFT, 328.0, 22, GOLD_BRIGHT)
	draw_string(font, Vector2(82.0, 224.0), "新野至长坂坡 · 章节推进", HORIZONTAL_ALIGNMENT_LEFT, 328.0, 14, Color("a9c2c7"))
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
	var preview_label := "长坂坡雪夜"
	match str(definition.get("battlefield_id", "changban")):
		"xinye":
			preview_texture = XINYE_GROUND_CANVAS_TEXTURE
			preview_label = "新野练兵"
		"bowangpo":
			preview_texture = BOWANGPO_GROUND_CANVAS_TEXTURE
			preview_label = "博望坡火谷"
		"huoshaoxinye":
			preview_texture = HUOSHAO_XINYE_GROUND_CANVAS_TEXTURE
			preview_label = "火烧新野"
		"xiangyangchetui":
			preview_texture = XIANGYANG_CHETUI_GROUND_CANVAS_TEXTURE
			preview_label = "襄阳撤退"
		"dangyangduanhou":
			preview_texture = DANGYANG_DUANHOU_GROUND_CANVAS_TEXTURE
			preview_label = "当阳断后"
	draw_texture_rect(preview_texture, inner, true, Color(0.54, 0.62, 0.66, 0.78) if unlocked else Color(0.34, 0.39, 0.40, 0.52))
	draw_rect(inner, Color(0.02, 0.04, 0.05, 0.38))
	draw_rect(Rect2(inner.position, Vector2(inner.size.x, 40.0)), Color(0.03, 0.06, 0.07, 0.60))
	draw_string(font, inner.position + Vector2(18.0, 27.0), "场景预览 · %s" % preview_label, HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 36.0, 15, Color("d8e4df") if unlocked else MUTED)
	draw_string(font, Vector2(inner.position.x + 18.0, inner.end.y - 24.0), str(definition.get("title", "剧情关卡")), HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 36.0, 25, Color("f4e6c4") if unlocked else Color("9fa9aa"))

func _draw_story_chapter_details(rect: Rect2, definition: Dictionary, chapter_index: int, unlocked: bool, font: Font) -> void:
	_draw_panel(rect, GOLD if unlocked else Color("4c5960"), true)
	var inner := rect.grow(-8.0)
	var chapter_text := str(definition.get("chapter", "荆州卷"))
	var status := "可出征" if unlocked else "尚未解锁"
	draw_string(font, inner.position + Vector2(16.0, 23.0), chapter_text, HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 160.0, 14, GOLD_BRIGHT if unlocked else MUTED)
	draw_string(font, Vector2(inner.end.x - 126.0, inner.position.y + 23.0), status, HORIZONTAL_ALIGNMENT_RIGHT, 110.0, 14, Color("9ee0c6") if unlocked else MUTED)
	draw_string(font, inner.position + Vector2(16.0, 52.0), str(definition.get("title", "剧情关卡")), HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 32.0, 23, Color("f4e6c4") if unlocked else Color("9fa9aa"))
	draw_string(font, inner.position + Vector2(16.0, 79.0), str(definition.get("description", "")), HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 32.0, 15, Color("d0ddd9") if unlocked else MUTED)
	var tags: Array = definition.get("tags", []) as Array
	var tag_text := _battlefield_tag_text(tags)
	var chapter_label := "第 %d 章" % (chapter_index + 1) if chapter_index >= 0 else "剧情章节"
	draw_string(font, inner.position + Vector2(16.0, 106.0), "%s · %s" % [chapter_label, tag_text], HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 32.0, 14, Color("b9d6d8") if unlocked else MUTED)

func _draw_endless_expedition(font: Font) -> void:
	var preview := _expedition_preview_rect()
	var definition := _battlefield_definition(selected_endless_battlefield_id)
	_draw_battlefield_preview(preview, definition, true, font)
	_draw_expedition_route(font, "可用战场", ["changban", "bowangpo"], selected_endless_battlefield_id)
	draw_string(font, Vector2(preview.position.x + 22.0, preview.end.y - 84.0), "敌军会随时间提高密度、兵种复杂度与精英频率。", HORIZONTAL_ALIGNMENT_LEFT, preview.size.x - 44.0, 15, Color("d1ddd9"))

func _draw_boss_trial_expedition(font: Font) -> void:
	var preview := _expedition_preview_rect()
	_draw_battlefield_preview(preview, _battlefield_definition("hulao"), true, font)
	draw_string(font, Vector2(68.0, 230.0), "试炼规则", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, GOLD_BRIGHT)
	draw_string(font, Vector2(68.0, 268.0), "Lv.5 开局", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d5e1de"))
	draw_string(font, Vector2(68.0, 300.0), "三次整备", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d5e1de"))
	draw_string(font, Vector2(68.0, 332.0), "夏侯恩 → 淳于导 → 张郃", HORIZONTAL_ALIGNMENT_LEFT, 246.0, 16, Color("d5e1de"))

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
		"bowangpo":
			draw_texture_rect(BOWANGPO_GROUND_CANVAS_TEXTURE, inner, true, Color(0.54, 0.62, 0.66, 0.72))
			for index in range(5):
				var fire_y := inner.position.y + 72.0 + float(index) * 54.0
				draw_line(Vector2(inner.position.x + 30.0, fire_y), Vector2(inner.end.x - 34.0, fire_y + 24.0), Color(0.94, 0.34, 0.12, 0.50), 7.0)
				draw_line(Vector2(inner.position.x + 30.0, fire_y - 3.0), Vector2(inner.end.x - 34.0, fire_y + 21.0), Color(1.0, 0.70, 0.28, 0.70), 1.5)
			for index in range(8):
				var ash_x := inner.position.x + 38.0 + fmod(float(index * 91), inner.size.x - 76.0)
				draw_line(Vector2(ash_x, inner.position.y + 32.0), Vector2(ash_x + 24.0, inner.end.y - 22.0), Color(0.56, 0.62, 0.57, 0.16), 2.0)
		_:
			draw_rect(inner, Color("252229"))
			var center := inner.get_center()
			draw_arc(center, minf(inner.size.x, inner.size.y) * 0.30, 0.0, TAU, 32, Color("9b7bd2"), 3.0)
			for index in range(6):
				var angle := TAU * float(index) / 6.0
				draw_line(center + Vector2.from_angle(angle) * 34.0, center + Vector2.from_angle(angle) * 94.0, Color("d7b56a", 0.64), 2.0)
	draw_rect(inner, Color(0.02, 0.04, 0.05, 0.36))
	draw_string(font, Vector2(inner.position.x + 22.0, inner.position.y + 42.0), str(definition.get("chapter", "战场")), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, GOLD_BRIGHT if unlocked else MUTED)
	draw_string(font, Vector2(inner.position.x + 22.0, inner.position.y + 82.0), title, HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 44.0, 32, Color("f4e6c4") if unlocked else Color("9fa9aa"))
	draw_string(font, Vector2(inner.position.x + 22.0, inner.position.y + 112.0), str(definition.get("description", "")), HORIZONTAL_ALIGNMENT_LEFT, inner.size.x - 44.0, 16, Color("d0ddd9") if unlocked else MUTED)
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
	draw_string(font, Vector2(size.x * 0.5 - 32.0, 58.0), "军需", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, GOLD_BRIGHT)
	var subtitle := "招募武将，并在其专属战法树中解锁三选一蓝图。"
	if shop_section == "strategies":
		subtitle = "四营军略 · 全英雄永久生效 · 不占用战斗三选一机会。"
	elif shop_section == "tianji":
		subtitle = "诸葛天机 · 军功研习 · 战斗中通过三选一启阵。"
	draw_string(font, Vector2(size.x * 0.5 - 230.0, 178.0), subtitle, HORIZONTAL_ALIGNMENT_CENTER, 460.0, 16, Color("a9c2c7"))

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
	var border_width := 2.5 if emphasize else 1.5
	draw_rect(rect, _alpha(PANEL_FILL, 0.94))
	draw_rect(rect.grow(-4.0), _alpha(PANEL_INNER, 0.82))
	draw_rect(rect, accent, false, border_width)
	draw_line(rect.position + Vector2(8, 8), rect.position + Vector2(34, 8), GOLD, 1.0)
	draw_line(rect.position + Vector2(8, 8), rect.position + Vector2(8, 26), GOLD, 1.0)
	draw_line(rect.end - Vector2(8, 8), rect.end - Vector2(34, 8), GOLD, 1.0)
	draw_line(rect.end - Vector2(8, 8), rect.end - Vector2(8, 26), GOLD, 1.0)

func _make_box_style(background: Color, border: Color, border_width: int) -> StyleBoxFlat:
	return UITheme.box_style(background, border, border_width)

func _alpha(color: Color, opacity: float) -> Color:
	return Color(color.r, color.g, color.b, opacity)
