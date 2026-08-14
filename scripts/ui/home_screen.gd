class_name HomeScreen
extends Control

const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")
const MILITARY_STRATEGY = preload("res://scripts/domain/military_strategy.gd")
const TIANJI_CATALOG = preload("res://scripts/domain/tianji_catalog.gd")
const CHANGBAN_GROUND_TEXTURE = preload("res://assets/art/environment/changban/grass-dirt-base-01.png")
const XINYE_GROUND_TEXTURE = preload("res://assets/art/environment/xinye1/1.png")
const BOWANGPO_GROUND_TEXTURE = preload("res://assets/art/environment/bowangpo1/1.png")
const TITLE_BACKGROUND_TEXTURE = preload("res://assets/art/ui/backgrounds/main.png")
const NON_COMBAT_BACKGROUND_TEXTURE = preload("res://assets/art/ui/backgrounds/bg.png")
const RELEASE_HERO_IDS: Array[String] = ["guan_yu", "zhao_yun"]
const HERO_SELECT_SLOT_IDS: Array[String] = ["huang_zhong", "zhang_fei", "guan_yu", "zhao_yun", "ma_chao"]
const HERO_SELECT_IDLE_SPRITE_SIZE := Vector2(92.0, 72.0)
const HERO_SELECT_IDLE_MODEL_TOP := 76.0
const HERO_SELECT_IDLE_MODEL_BOTTOM_GAP := 12.0
const HERO_SELECT_IDLE_BOTTOM_PADDING := {
	"guan_yu": 9.0,
	"zhao_yun": 16.0,
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
const HERO_CAROUSEL_TRANSITION_DURATION := 0.32
const HERO_TREE_SCROLL_DRAG_THRESHOLD := 10.0
const STRATEGY_CARD_WIDTH := 286.0
const STRATEGY_CARD_MIN_HEIGHT := 84.0
const STRATEGY_CARD_DESCRIPTION_LINE_HEIGHT := 15.0
const STRATEGY_CARD_DESCRIPTION_CHARS_PER_LINE := 20
const STRATEGY_CARD_GAP := Vector2(12.0, 12.0)
const STRATEGY_GRID_START := Vector2(44.0, 246.0)
const TITLE_MENU_FADE_DURATION := 0.36
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
	"story_01": {"chapter": "荆州卷 第一章", "title": "新野练兵", "description": "刘备屯兵新野，先熟悉近战推进与拒阵突破。", "tags": ["约5分钟", "刀盾", "初阵"], "duration": "约5分钟"},
	"story_02": {"chapter": "荆州卷 第二章", "title": "博望坡·火攻", "description": "诸葛亮初出奇谋，在博望坡击破曹军前锋。", "tags": ["约6分钟", "火攻", "枪盾"], "duration": "约6分钟"},
	"story_03": {"chapter": "荆州卷 第三章", "title": "火烧新野", "description": "曹军压境，新野城中组织撤离并突破追兵。", "tags": ["约6.5分钟", "撤离", "弓手"], "duration": "约6.5分钟"},
	"story_04": {"chapter": "荆州卷 第四章", "title": "襄阳撤退", "description": "百姓随军南撤，在襄阳北线挡住曹军合围。", "tags": ["约8分钟", "护送", "戟卫"], "duration": "约8分钟"},
	"story_05": {"chapter": "荆州卷 第五章", "title": "当阳断后", "description": "曹军骑兵紧追不舍，掩护队伍穿过当阳狭路。", "tags": ["约9分钟", "骑兵", "断后"], "duration": "约9分钟"},
	"story_06": {"chapter": "荆州卷 第六章", "title": "长坂坡·单骑救主", "description": "赵云杀入长坂坡乱军，救出阿斗并击破张郃防线。", "tags": ["约10分钟", "长坂坡", "张郃"], "duration": "约10分钟"},
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
var page_controls: Array[Control] = []
var talent_detail_dialog: Control
var strategy_detail_dialog: Control
var strategy_detail_notice := ""
var equip_hero_button: Button
var hero_ids: Array[String] = []
var selected_hero_index := 0
var carousel_touch_index := -1
var carousel_start := Vector2.ZERO
var carousel_delta := Vector2.ZERO
var mouse_dragging_carousel := false
var carousel_transition_remaining := 0.0
var carousel_transition_direction := 0
var carousel_transition_from_index := 0
var carousel_transition_to_index := 0
var hero_tree_touch_index := -1
var hero_tree_drag_start := Vector2.ZERO
var hero_tree_drag_scroll_start := 0
var hero_tree_dragging := false
var hero_tree_mouse_dragging := false
var title_elapsed := 0.0
var title_menu_fade_remaining := 0.0
var hero_select_idle_elapsed := 0.0
var hero_select_idle_sprite: TextureRect
var portrait_cache: Dictionary = {}
var hero_select_portrait_shader: Shader

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	resized.connect(_rebuild_current_page)
	profile = SaveService.load_profile()
	AudioService.apply_settings(profile.get("settings", {}) as Dictionary)
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
		needs_redraw = true
	if page == "hero_select":
		hero_select_idle_elapsed += delta
		_update_hero_select_idle_sprite()
		needs_redraw = true
	if title_menu_fade_remaining > 0.0:
		title_menu_fade_remaining = maxf(0.0, title_menu_fade_remaining - delta)
		needs_redraw = true
	if carousel_transition_remaining > 0.0:
		carousel_transition_remaining = maxf(0.0, carousel_transition_remaining - delta)
		if carousel_transition_remaining <= 0.0:
			selected_hero_index = carousel_transition_to_index
			_refresh_equip_hero_button()
		needs_redraw = true
	if needs_redraw:
		queue_redraw()

func _show_title() -> void:
	page = "title"
	profile = SaveService.load_profile()
	notice = ""
	title_elapsed = 0.0
	title_menu_fade_remaining = 0.0
	_clear_buttons()
	grab_focus()
	queue_redraw()

func _enter_from_title() -> void:
	if page != "title":
		return
	SceneRouter.title_seen = true
	title_menu_fade_remaining = TITLE_MENU_FADE_DURATION
	_show_main()

func _show_main() -> void:
	page = "main"
	profile = SaveService.load_profile()
	notice = ""
	carousel_transition_remaining = 0.0
	carousel_transition_direction = 0
	_clear_buttons()
	var command_x := (size.x - HOME_ACTION_BUTTON_SIZE.x) * 0.5
	var command_y := clampf(size.y * 0.5 - 88.0, 180.0, size.y - 196.0)
	_create_button("出征", "剧情战役、无尽与试炼", Vector2(command_x, command_y), _show_modes, HOME_ACTION_BUTTON_SIZE, false, 20)
	_create_button("军需", "武将、战法与军略", Vector2(command_x, command_y + HOME_ACTION_BUTTON_SIZE.y + HOME_ACTION_BUTTON_GAP), _show_shop, HOME_ACTION_BUTTON_SIZE, false, 20)
	if SceneRouter.is_map_editor_available():
		_create_button("地图编辑器", "战场布局与障碍", Vector2(size.x - 286.0, 76.0), _open_map_editor, Vector2(132.0, 44.0), false, 14)
	_create_button("设置", "", Vector2(size.x - 146.0, 76.0), _show_settings, Vector2(118.0, 44.0), false, 16)
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
	_create_button("返回", "", Vector2(28.0, 28.0), _show_main, Vector2(126.0, 46.0))
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
	_create_button("返回", "", Vector2(28.0, 28.0), _show_main, Vector2(126.0, 46.0))
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
	overlay.z_index = 20
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
	overlay.z_index = 20
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
	elif maxed:
		status_label.text = "该军略已满阶"
		status_label.add_theme_color_override("font_color", Color("9ee0c6"))
	else:
		status_label.text = "下一阶消耗  %d 军功" % cost
		status_label.add_theme_color_override("font_color", Color("f1bd73") if current_merit < cost else Color("9ee0c6"))
	dialog.add_child(status_label)
	var action_y := dialog_size.y - 62.0
	var action_width := (content_width - 12.0) * 0.5
	var purchase_title := "已满阶" if maxed else "研习 · %d 军功" % cost
	var purchase_button := _create_button(purchase_title, "", Vector2(24.0, action_y), Callable(self, "_buy_strategy_from_detail").bind(strategy_id), Vector2(action_width, 44.0), maxed, 16, dialog, false)
	if maxed:
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
	for branch_index in range(MILITARY_STRATEGY.BRANCHES.size()):
		var branch: Dictionary = MILITARY_STRATEGY.BRANCHES[branch_index] as Dictionary
		var nodes: Array = branch.get("nodes", []) as Array
		var branch_origin := STRATEGY_GRID_START + Vector2(float(branch_index) * (STRATEGY_CARD_WIDTH + STRATEGY_CARD_GAP.x), 0.0)
		var branch_label := Label.new()
		branch_label.text = "%s\n%s" % [str(branch.get("title", "军略")), str(branch.get("subtitle", ""))]
		branch_label.position = branch_origin - Vector2(0.0, 46.0)
		branch_label.size = Vector2(STRATEGY_CARD_WIDTH, 42.0)
		branch_label.add_theme_font_size_override("font_size", 13)
		branch_label.add_theme_color_override("font_color", GOLD_BRIGHT)
		branch_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		branch_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(branch_label)
		page_controls.append(branch_label)
		var row_offset := 0.0
		for node_index in range(nodes.size()):
			var strategy_id := str(nodes[node_index])
			var definition := MILITARY_STRATEGY.definition_for(strategy_id)
			var rank := SaveService.strategy_rank(strategy_id)
			var max_rank := int(definition.get("max_rank", 0))
			var maxed := rank >= max_rank
			var cost := SaveService.strategy_cost(strategy_id)
			var can_afford := current_merit >= cost
			var status := "已满阶" if maxed else ("军功不足 · 还差 %d" % (cost - current_merit) if not can_afford else ("下一阶 %d 军功 · %d/%d" % [cost, rank, max_rank]))
			var card_height := row_heights[node_index]
			var card := _create_strategy_card(str(definition.get("title", strategy_id)), str(definition.get("description", "")), status, branch_origin + Vector2(0.0, row_offset), Vector2(STRATEGY_CARD_WIDTH, card_height), Callable(self, "_show_strategy_detail").bind(strategy_id), false, can_afford or maxed)
			card.tooltip_text = "%s · 全英雄永久生效" % str(definition.get("description", ""))
			if rank > 0:
				_set_button_owned_visual(card)
			elif not can_afford:
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
	var column_count := 3
	var card_size := Vector2((size.x - 136.0) / float(column_count), 148.0)
	var card_start := Vector2(56.0, 294.0)
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
		var position := card_start + Vector2(float(column) * (card_size.x + 12.0), float(row) * (card_size.y + 14.0))
		var card := _create_button(TIANJI_CATALOG.title_for(skill_id), subtitle, position, Callable(self, "_buy_tianji").bind(skill_id), card_size, maxed, 15)
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

func _create_strategy_card(title: String, description: String, status: String, at: Vector2, card_size: Vector2, callback: Callable, disabled: bool, purchasable: bool) -> Button:
	var card := _create_button("", "", at, callback, card_size, disabled, 13)
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
	var start := Vector2(size.x * 0.5 - 270.0, size.y * 0.5 - 150.0)
	var sound_text := "开启" if SaveService.setting_enabled("sound_enabled") else "关闭"
	var vibration_text := "开启" if SaveService.setting_enabled("vibration_enabled") else "关闭"
	_create_button("音量：%s" % sound_text, "点击切换", start, _toggle_sound, Vector2(540.0, 56.0))
	_create_volume_slider(start + Vector2(154.0, 102.0), _music_volume(), "背景音乐音量", _on_music_volume_changed)
	_create_volume_slider(start + Vector2(154.0, 170.0), _sfx_volume(), "战斗音效音量", _on_sfx_volume_changed)
	_create_weather_selector(start + Vector2(154.0, 229.0))
	_create_button("震动：%s" % vibration_text, "点击切换", start + Vector2(0, 292.0), _toggle_vibration, Vector2(540.0, 56.0))
	_create_button("返回", "", Vector2(28.0, 28.0), _show_main, Vector2(126.0, 46.0))
	queue_redraw()

func _show_hero_details() -> void:
	_show_hero_details_from("main")

func _show_hero_details_from(return_page: String) -> void:
	page = "hero_details"
	hero_details_return_page = return_page
	profile = SaveService.load_profile()
	notice = ""
	_clear_buttons()
	var return_callback := _show_hero_select_from_details if hero_details_return_page == "hero_select" else _show_main
	_create_button("返回", "", Vector2(28.0, 28.0), return_callback, Vector2(126.0, 46.0))
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
	var depart_button := _create_button("出征", "", Vector2(size.x - 202.0, 28.0), _begin_selected_run, Vector2(174.0, 46.0), not can_depart, 18)
	_configure_hero_select_action_button(depart_button, true)
	depart_button.add_theme_font_size_override("font_size", 18)
	depart_button.z_index = 24
	var back_button := _create_button("返回", "", Vector2(28.0, 28.0), Callable(self, "_show_expedition").bind(hero_select_return_tab), Vector2(126.0, 46.0))
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
	_show_shop("strategies")
	notice = "该军略已满阶" if is_maxed else "军功不足"
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

func _equip_selected_hero() -> void:
	var hero_id := _selected_hero_id()
	if SaveService.equip_hero(hero_id):
		profile = SaveService.load_profile()
		notice = "%s 已上阵" % str(_selected_hero().get("name", "武将"))
		_refresh_equip_hero_button()
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
	queue_redraw()

func _on_sfx_volume_changed(value: float) -> void:
	var volume := snappedf(clampf(value, 0.0, 1.0), 0.05)
	SaveService.set_setting_value("sfx_volume", volume)
	AudioService.set_sfx_volume(volume)
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

func _hero_carousel_rect() -> Rect2:
	return Rect2(size.x * 0.45, 170.0, size.x * 0.50, size.y - 300.0)

func _cycle_hero(delta: int) -> void:
	if hero_ids.size() <= 1 or carousel_transition_remaining > 0.0:
		return
	var next_index := clampi(selected_hero_index + delta, 0, hero_ids.size() - 1)
	if next_index == selected_hero_index:
		return
	carousel_transition_direction = delta
	carousel_transition_from_index = selected_hero_index
	carousel_transition_to_index = next_index
	carousel_transition_remaining = HERO_CAROUSEL_TRANSITION_DURATION
	queue_redraw()

func _refresh_equip_hero_button() -> void:
	if page != "main" or not is_instance_valid(equip_hero_button):
		return
	var equipped := SaveService.equipped_hero_id() == _selected_hero_id()
	equip_hero_button.text = "已上阵" if equipped else "上阵"
	equip_hero_button.disabled = equipped
	if equipped:
		_set_button_owned_visual(equip_hero_button)
	else:
		equip_hero_button.add_theme_color_override("font_color", Color("f2e5c4"))
		equip_hero_button.add_theme_color_override("font_hover_color", Color.WHITE)
		equip_hero_button.add_theme_stylebox_override("normal", _make_box_style(PANEL_FILL, GOLD, 2))
		equip_hero_button.add_theme_stylebox_override("hover", _make_box_style(Color("1a2b33"), DRAGON_BLUE, 3))
		equip_hero_button.add_theme_stylebox_override("pressed", _make_box_style(Color("2e291d"), GOLD_BRIGHT, 3))
		equip_hero_button.add_theme_stylebox_override("disabled", _make_box_style(Color("131a1e"), Color("425058"), 1))

func _finish_carousel_drag() -> void:
	if absf(carousel_delta.x) >= 42.0:
		_cycle_hero(1 if carousel_delta.x < 0.0 else -1)
	carousel_touch_index = -1
	mouse_dragging_carousel = false
	carousel_delta = Vector2.ZERO

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
	for control in page_controls:
		if is_instance_valid(control):
			control.queue_free()
	page_controls.clear()
	for button in buttons:
		button.queue_free()
	buttons.clear()
	equip_hero_button = null
	for control in setting_controls:
		control.queue_free()
	setting_controls.clear()

func _rebuild_current_page() -> void:
	match page:
		"title": _show_title()
		"modes", "expedition": _show_expedition(expedition_tab)
		"hero_select": _show_hero_select(selected_run_mode, selected_run_battlefield_id, hero_select_return_tab, true)
		"shop": _show_shop(shop_section)
		"settings": _show_settings()
		"hero_details": _show_hero_details()
		_: _show_main()

func _draw() -> void:
	if page == "title":
		draw_texture_rect(TITLE_BACKGROUND_TEXTURE, Rect2(Vector2.ZERO, size), false)
		_draw_title_screen(ThemeDB.fallback_font)
		return
	var background_rect := Rect2(Vector2.ZERO, size)
	draw_texture_rect(NON_COMBAT_BACKGROUND_TEXTURE, background_rect, false, Color(0.78, 0.78, 0.78, 0.94))
	draw_rect(background_rect, Color(0.02, 0.025, 0.03, 0.48))
	var font := ThemeDB.fallback_font
	if page == "main":
		draw_string(font, Vector2(68, 96), "三国 破阵无双", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, GOLD_BRIGHT)
		draw_string(font, Vector2(72, 128), "名将破阵 · 兵海无双", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("a9c2c7"))
	draw_string(font, Vector2(size.x - 318, 52), "军功  %d" % int(profile.get("military_merit", 0)), HORIZONTAL_ALIGNMENT_LEFT, -1, 21, GOLD_BRIGHT)
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
	var center := size * 0.5
	var frame_color := Color(0.80, 0.67, 0.42, 0.18)
	var inset := 42.0
	var corner := 46.0
	draw_line(Vector2(inset, inset), Vector2(inset + corner, inset), frame_color, 1.0)
	draw_line(Vector2(inset, inset), Vector2(inset, inset + corner), frame_color, 1.0)
	draw_line(Vector2(size.x - inset, inset), Vector2(size.x - inset - corner, inset), frame_color, 1.0)
	draw_line(Vector2(size.x - inset, inset), Vector2(size.x - inset, inset + corner), frame_color, 1.0)
	draw_line(Vector2(inset, size.y - inset), Vector2(inset + corner, size.y - inset), frame_color, 1.0)
	draw_line(Vector2(inset, size.y - inset), Vector2(inset, size.y - inset - corner), frame_color, 1.0)
	draw_line(Vector2(size.x - inset, size.y - inset), Vector2(size.x - inset - corner, size.y - inset), frame_color, 1.0)
	draw_line(Vector2(size.x - inset, size.y - inset), Vector2(size.x - inset, size.y - inset - corner), frame_color, 1.0)
	var pulse := 0.46 + 0.44 * (sin(title_elapsed * 2.4) + 1.0) * 0.5
	var prompt_color := Color(0.96, 0.88, 0.68, pulse)
	var prompt_y := size.y - 84.0
	draw_line(Vector2(center.x - 176.0, prompt_y - 10.0), Vector2(center.x - 84.0, prompt_y - 10.0), Color(prompt_color.r, prompt_color.g, prompt_color.b, pulse * 0.42), 1.0)
	draw_line(Vector2(center.x + 84.0, prompt_y - 10.0), Vector2(center.x + 176.0, prompt_y - 10.0), Color(prompt_color.r, prompt_color.g, prompt_color.b, pulse * 0.42), 1.0)
	draw_string(font, Vector2(center.x - 130.0, prompt_y), "点击任意位置进入游戏", HORIZONTAL_ALIGNMENT_CENTER, 260.0, 18, prompt_color)

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
	sprite.size = HERO_SELECT_IDLE_SPRITE_SIZE
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
	if not animated:
		return ZHAO_YUN_SELECT_IDLE_TEXTURES[0] as Texture2D
	var zhao_order: Array[int] = [0, 1, 2, 3, 2, 1]
	var zhao_frame := zhao_order[int(hero_select_idle_elapsed / 0.20) % zhao_order.size()]
	return ZHAO_YUN_SELECT_IDLE_TEXTURES[zhao_frame] as Texture2D

func _draw_ellipse_shadow(center: Vector2, radius: Vector2, color: Color) -> void:
	draw_set_transform(center, 0.0, radius)
	draw_circle(Vector2.ZERO, 1.0, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_hero_carousel(font: Font) -> void:
	var area := _hero_carousel_rect()
	draw_string(font, Vector2(area.position.x, area.position.y - 28.0), "选择上阵武将", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, GOLD_BRIGHT)
	var center_rect := Rect2(area.get_center() - Vector2(132.0, 171.0), Vector2(264.0, 342.0))
	var side_width := 112.0
	var left_rect := Rect2(center_rect.position.x - side_width - 22.0, center_rect.position.y + 58.0, side_width, 222.0)
	var right_rect := Rect2(center_rect.end.x + 22.0, center_rect.position.y + 58.0, side_width, 222.0)
	if carousel_transition_remaining > 0.0:
		_draw_hero_carousel_transition(center_rect, left_rect, right_rect, font)
	else:
		var left_hero := _hero_at_offset(-1)
		var right_hero := _hero_at_offset(1)
		if left_hero.is_empty():
			_draw_placeholder_hero(left_rect, font)
		else:
			_draw_compact_hero_card(left_rect, left_hero, font)
		if right_hero.is_empty():
			_draw_placeholder_hero(right_rect, font)
		else:
			_draw_compact_hero_card(right_rect, right_hero, font)
		_draw_hero_card(center_rect, _selected_hero(), true, font)
	draw_string(font, Vector2(area.get_center().x - 134.0, area.end.y - 14.0), "左右拖动切换武将", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, MUTED)

func _draw_hero_carousel_transition(center_rect: Rect2, left_rect: Rect2, right_rect: Rect2, font: Font) -> void:
	var progress := 1.0 - carousel_transition_remaining / HERO_CAROUSEL_TRANSITION_DURATION
	var eased := 1.0 - pow(1.0 - progress, 3.0)
	var outgoing_slot := left_rect if carousel_transition_direction > 0 else right_rect
	var incoming_slot := right_rect if carousel_transition_direction > 0 else left_rect
	var outgoing_rect := _interpolate_hero_card_rect(center_rect, outgoing_slot, eased)
	var incoming_rect := _interpolate_hero_card_rect(incoming_slot, center_rect, eased)
	var outgoing_hero := _hero_at_index(carousel_transition_from_index)
	var incoming_hero := _hero_at_index(carousel_transition_to_index)
	_draw_hero_card(outgoing_rect, outgoing_hero, progress < 0.5, font, outgoing_rect.size.x >= 168.0)
	_draw_hero_card(incoming_rect, incoming_hero, progress >= 0.5, font, incoming_rect.size.x >= 168.0)

func _interpolate_hero_card_rect(from: Rect2, to: Rect2, progress: float) -> Rect2:
	return Rect2(from.position.lerp(to.position, progress), from.size.lerp(to.size, progress))

func _hero_at_offset(offset: int) -> Dictionary:
	return _hero_at_index(selected_hero_index + offset)

func _hero_at_index(index: int) -> Dictionary:
	if index < 0 or index >= hero_ids.size():
		return {}
	return HERO_CATALOG.definition_for(hero_ids[index])

func _draw_hero_card(rect: Rect2, hero: Dictionary, selected: bool, font: Font, show_text: bool = true) -> void:
	_draw_panel(rect, GOLD if selected else Color("485762"), selected)
	var portrait_path := str(hero.get("portrait", ""))
	if not portrait_path.is_empty():
		var portrait := _portrait_for(portrait_path)
		if portrait != null:
			var portrait_margin := maxf(14.0, rect.size.x * 0.10)
			var portrait_height := maxf(86.0, rect.size.y - 88.0)
			_draw_hero_portrait_top_crop(portrait, Rect2(rect.position + Vector2(portrait_margin, 14.0), Vector2(rect.size.x - portrait_margin * 2.0, portrait_height)))
	elif str(hero.get("id", "")) == "guan_yu":
		_draw_guan_yu_card_placeholder(rect)
	else:
		_draw_unarted_hero_card_placeholder(Rect2(rect.position + Vector2(18.0, 14.0), Vector2(rect.size.x - 36.0, maxf(76.0, rect.size.y - 88.0))), str(hero.get("id", "")))
	if not show_text:
		return
	draw_string(font, Vector2(rect.position.x, rect.end.y - 46.0), str(hero.get("name", "武将")), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 27, Color("f4e6c4"))
	draw_string(font, Vector2(rect.position.x, rect.end.y - 20.0), str(hero.get("role", "")), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 14, Color("9db7bd"))

func _draw_guan_yu_card_placeholder(rect: Rect2) -> void:
	var center := Vector2(rect.get_center().x, rect.position.y + rect.size.y * 0.42)
	draw_circle(center + Vector2(0, -62), 24.0, Color("d7b98c"))
	draw_rect(Rect2(center + Vector2(-26, -88), Vector2(52, 11)), Color("17221d"))
	var robe := PackedVector2Array([
		center + Vector2(-72, 82), center + Vector2(-48, -24), center + Vector2(-18, -42),
		center + Vector2(25, -42), center + Vector2(59, -18), center + Vector2(78, 82),
	])
	draw_colored_polygon(robe, Color("164b3b"))
	draw_rect(Rect2(center + Vector2(-53, -6), Vector2(108, 8)), Color("c7a544"))
	draw_line(center + Vector2(-72, 46), center + Vector2(92, -106), Color("b99a42"), 8.0)
	draw_arc(center + Vector2(92, -106), 28.0, -2.94, 0.28, 12, Color("85c998"), 12.0)
	draw_line(center + Vector2(5, -48), center + Vector2(7, -16), Color("1a1712"), 8.0)

func _draw_compact_hero_card(rect: Rect2, hero: Dictionary, font: Font) -> void:
	_draw_panel(rect, Color("485762"))
	var portrait_rect := Rect2(rect.position + Vector2(12, 15), Vector2(rect.size.x - 24, 116))
	var portrait_path := str(hero.get("portrait", ""))
	if not portrait_path.is_empty():
		var portrait := _portrait_for(portrait_path)
		if portrait != null:
			_draw_hero_portrait_top_crop(portrait, portrait_rect)
	elif str(hero.get("id", "")) == "guan_yu":
		_draw_compact_guan_yu_placeholder(portrait_rect)
	else:
		_draw_unarted_hero_card_placeholder(portrait_rect, str(hero.get("id", "")))
	draw_string(font, Vector2(rect.position.x, rect.end.y - 42.0), str(hero.get("name", "武将")), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 18, Color("e5d5ad"))
	draw_string(font, Vector2(rect.position.x, rect.end.y - 20.0), str(hero.get("role", "")), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 11, MUTED)

func _draw_hero_portrait_top_crop(portrait: Texture2D, rect: Rect2) -> void:
	var texture_size := portrait.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0 or rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var target_aspect := rect.size.x / rect.size.y
	var source_height := minf(texture_size.y, texture_size.x / target_aspect)
	var source_rect := Rect2(Vector2.ZERO, Vector2(texture_size.x, source_height))
	draw_texture_rect_region(portrait, rect, source_rect)

func _draw_compact_guan_yu_placeholder(rect: Rect2) -> void:
	var center := Vector2(rect.get_center().x, rect.position.y + 69.0)
	draw_circle(center + Vector2(0, -37), 13.0, Color("d7b98c"))
	draw_rect(Rect2(center + Vector2(-14, -50), Vector2(28, 6)), Color("17221d"))
	var robe := PackedVector2Array([
		center + Vector2(-33, 40), center + Vector2(-24, -13), center + Vector2(-9, -23),
		center + Vector2(12, -23), center + Vector2(27, -10), center + Vector2(37, 40),
	])
	draw_colored_polygon(robe, Color("164b3b"))
	draw_line(center + Vector2(-30, 26), center + Vector2(37, -47), Color("b99a42"), 4.0)
	draw_arc(center + Vector2(37, -47), 13.0, -2.94, 0.28, 8, Color("85c998"), 5.0)

func _draw_unarted_hero_card_placeholder(rect: Rect2, hero_id: String) -> void:
	var scale := minf(rect.size.x / 184.0, rect.size.y / 184.0)
	var center := Vector2(rect.get_center().x, rect.position.y + rect.size.y * 0.56)
	var robe := Color("5e6978")
	var accent := Color("d4a956")
	var weapon_color := Color("dfe5e6")
	match hero_id:
		"zhang_fei":
			robe = Color("653d36")
			accent = Color("de8545")
		"ma_chao":
			robe = Color("667b9d")
			accent = Color("c8dbe5")
		"huang_zhong":
			robe = Color("8b633d")
			accent = Color("d9b661")
		_:
			return
	draw_circle(center + Vector2(0, -48.0 * scale), 16.0 * scale, Color("d7b88e"))
	draw_rect(Rect2(center + Vector2(-17.0, -66.0) * scale, Vector2(34.0, 8.0) * scale), Color("28272a"))
	var body := PackedVector2Array([
		center + Vector2(-38.0, 46.0) * scale, center + Vector2(-28.0, -26.0) * scale,
		center + Vector2(-12.0, -36.0) * scale, center + Vector2(16.0, -34.0) * scale,
		center + Vector2(30.0, -18.0) * scale, center + Vector2(42.0, 46.0) * scale,
	])
	draw_colored_polygon(body, robe)
	draw_rect(Rect2(center + Vector2(-28.0, -4.0) * scale, Vector2(56.0, 6.0) * scale), accent)
	if hero_id == "huang_zhong":
		var bow_center := center + Vector2(34.0, -18.0) * scale
		draw_arc(bow_center, 28.0 * scale, -1.1, 1.1, 10, accent, 3.0 * scale)
		draw_line(center + Vector2(-8.0, -18.0) * scale, center + Vector2(74.0, -18.0) * scale, weapon_color, 1.4 * scale)
	else:
		var endpoint := center + Vector2(78.0, -90.0) * scale
		if hero_id == "zhang_fei":
			endpoint = center + Vector2(92.0, -58.0) * scale
		draw_line(center + Vector2(-34.0, 26.0) * scale, endpoint, Color("845735"), 5.0 * scale)
		var direction := (endpoint - center).normalized()
		var side := Vector2(-direction.y, direction.x)
		var tip := endpoint + direction * 10.0 * scale
		draw_colored_polygon(PackedVector2Array([tip, endpoint - direction * 10.0 * scale + side * 6.0 * scale, endpoint - direction * 10.0 * scale - side * 6.0 * scale]), weapon_color)
	if hero_id == "ma_chao":
		for index in range(3):
			draw_line(center + Vector2(-65.0 - float(index) * 12.0, 28.0 + float(index) * 4.0) * scale, center + Vector2(-32.0 - float(index) * 8.0, 18.0 + float(index) * 4.0) * scale, Color(accent.r, accent.g, accent.b, 0.40 - float(index) * 0.08), 2.0 * scale)

func _draw_placeholder_hero(rect: Rect2, font: Font) -> void:
	draw_rect(rect, Color("10171c"))
	draw_rect(rect, Color("43515a"), false, 1.0)
	draw_string(font, Vector2(rect.get_center().x - 24.0, rect.get_center().y - 4.0), "未解锁", HORIZONTAL_ALIGNMENT_CENTER, 48, 14, MUTED)

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
	var preview_texture: Texture2D = CHANGBAN_GROUND_TEXTURE
	var preview_label := "长坂坡"
	match selected_story_chapter_id:
		"story_01":
			preview_texture = XINYE_GROUND_TEXTURE
			preview_label = "新野校场"
		"story_02":
			preview_texture = BOWANGPO_GROUND_TEXTURE
			preview_label = "博望坡火谷"
		_:
			pass
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
			draw_texture_rect(CHANGBAN_GROUND_TEXTURE, inner, true, Color(0.54, 0.62, 0.66, 0.72))
		"bowangpo":
			draw_rect(inner, Color("1c2422"))
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

func _draw_settings(font: Font) -> void:
	var start := Vector2(size.x * 0.5 - 270.0, size.y * 0.5 - 150.0)
	var music_percent := int(round(_music_volume() * 100.0))
	var sfx_percent := int(round(_sfx_volume() * 100.0))
	draw_string(font, Vector2(size.x * 0.5 - 56.0, start.y - 46.0), "设置", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, GOLD_BRIGHT)
	draw_string(font, Vector2(start.x, start.y + 94.0), "音乐", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("d6e5e2"))
	draw_string(font, Vector2(start.x + 454.0, start.y + 94.0), "%d%%" % music_percent, HORIZONTAL_ALIGNMENT_RIGHT, 86.0, 17, GOLD_BRIGHT)
	draw_string(font, Vector2(start.x, start.y + 162.0), "音效", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("d6e5e2"))
	draw_string(font, Vector2(start.x + 454.0, start.y + 162.0), "%d%%" % sfx_percent, HORIZONTAL_ALIGNMENT_RIGHT, 86.0, 17, GOLD_BRIGHT)
	draw_string(font, Vector2(start.x, start.y + 221.0), "环境", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("d6e5e2"))

func _draw_hero_details(font: Font) -> void:
	var hero := _selected_hero()
	var stats := HERO_CATALOG.display_stats_for(_selected_hero_id(), profile)
	draw_string(font, Vector2(190, 102), "%s · %s" % [hero.get("name", "武将"), hero.get("role", "")], HORIZONTAL_ALIGNMENT_LEFT, -1, 32, GOLD_BRIGHT)
	draw_string(font, Vector2(190, 134), "当前属性", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("b9c9cd"))
	var stats_rect := Rect2(190, 158, 370, 374)
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
	var skill_rect := Rect2(600, 158, size.x - 700, 420)
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
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
	style.shadow_size = 7
	style.shadow_offset = Vector2(0, 4)
	return style

func _alpha(color: Color, opacity: float) -> Color:
	return Color(color.r, color.g, color.b, opacity)
