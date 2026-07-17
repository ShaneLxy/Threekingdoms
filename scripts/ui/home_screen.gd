class_name HomeScreen
extends Control

const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")
const PANEL_FILL := Color("10191f")
const PANEL_INNER := Color("18242b")
const GOLD := Color("d5af66")
const GOLD_BRIGHT := Color("f4d58d")
const DRAGON_BLUE := Color("63b9df")
const MUTED := Color("829099")

var page := "main"
var profile: Dictionary = {}
var notice := ""
var buttons: Array[Button] = []
var hero_ids: Array[String] = []
var selected_hero_index := 0
var carousel_touch_index := -1
var carousel_start := Vector2.ZERO
var carousel_delta := Vector2.ZERO
var mouse_dragging_carousel := false
var portrait_cache: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_rebuild_current_page)
	profile = SaveService.load_profile()
	AudioService.set_master_volume(0.0 if SaveService.setting_enabled("sound_enabled") else -80.0)
	_show_main()

func _show_main() -> void:
	page = "main"
	profile = SaveService.load_profile()
	notice = ""
	_refresh_hero_ids()
	_clear_buttons()
	var start := Vector2(70.0, size.y * 0.5 - 54.0)
	_create_button("征战", "进入剧情或无尽兵海", start, _show_modes, Vector2(310.0, 70.0))
	_create_button("商店", "武将、天赋与技能", start + Vector2(0, 86), _show_shop, Vector2(310.0, 70.0))
	_create_button("设置", "声音与操作偏好", start + Vector2(0, 172), _show_settings, Vector2(310.0, 70.0))
	var actions_y := size.y - 110.0
	_create_button("技能", "属性与招式", Vector2(size.x * 0.60, actions_y), _show_hero_details, Vector2(170.0, 58.0))
	var equipped := SaveService.equipped_hero_id() == _selected_hero_id()
	_create_button("已上阵" if equipped else "上阵", "", Vector2(size.x * 0.60 + 188.0, actions_y), _equip_selected_hero, Vector2(170.0, 58.0), equipped)
	queue_redraw()

func _show_modes() -> void:
	page = "modes"
	notice = ""
	_clear_buttons()
	var start := Vector2(size.x * 0.5 - 300.0, size.y * 0.5 - 66.0)
	_create_button("剧情模式", "长坂坡突围 · 10 分钟", start, _start_story, Vector2(600.0, 72.0))
	_create_button("无尽模式", "20 分钟兵海试炼", start + Vector2(0, 92), _start_endless, Vector2(600.0, 72.0))
	_create_button("返回", "", Vector2(28.0, 28.0), _show_main, Vector2(126.0, 46.0))
	queue_redraw()

func _show_shop() -> void:
	page = "shop"
	profile = SaveService.load_profile()
	notice = ""
	_clear_buttons()
	var start := Vector2(size.x * 0.5 - 300.0, size.y * 0.5 - 42.0)
	_create_button("赵云 · 已拥有", "龙胆枪 · 当前可出战武将", start, _show_shop, Vector2(600.0, 64.0), true)
	var tactics_owned := SaveService.has_upgrade("dragon_tactics")
	var tactics_text := "已拥有" if tactics_owned else "30 铜钱"
	_create_button("龙胆军略 I", "初始攻击 +5% · %s" % tactics_text, start + Vector2(0, 80), _buy_dragon_tactics, Vector2(600.0, 64.0), tactics_owned)
	var drill_owned := SaveService.has_upgrade("seven_drill")
	var drill_text := "已拥有" if drill_owned else "35 铜钱"
	_create_button("破军演练 I", "破军冷却 -0.5 秒 · %s" % drill_text, start + Vector2(0, 160), _buy_seven_drill, Vector2(600.0, 64.0), drill_owned)
	_create_button("返回", "", Vector2(28.0, 28.0), _show_main, Vector2(126.0, 46.0))
	queue_redraw()

func _show_settings() -> void:
	page = "settings"
	notice = ""
	_clear_buttons()
	var start := Vector2(size.x * 0.5 - 270.0, size.y * 0.5 - 42.0)
	var sound_text := "开启" if SaveService.setting_enabled("sound_enabled") else "关闭"
	var vibration_text := "开启" if SaveService.setting_enabled("vibration_enabled") else "关闭"
	_create_button("音量：%s" % sound_text, "点击切换", start, _toggle_sound, Vector2(540.0, 64.0))
	_create_button("震动：%s" % vibration_text, "点击切换", start + Vector2(0, 80), _toggle_vibration, Vector2(540.0, 64.0))
	_create_button("返回", "", Vector2(28.0, 28.0), _show_main, Vector2(126.0, 46.0))
	queue_redraw()

func _show_hero_details() -> void:
	page = "hero_details"
	notice = ""
	_clear_buttons()
	_create_button("返回", "", Vector2(28.0, 28.0), _show_main, Vector2(126.0, 46.0))
	queue_redraw()

func _start_story() -> void:
	SceneRouter.start_run("story")

func _start_endless() -> void:
	SceneRouter.start_run("endless")

func _buy_dragon_tactics() -> void:
	_buy_upgrade("dragon_tactics", 30, "龙胆军略已研习")

func _buy_seven_drill() -> void:
	_buy_upgrade("seven_drill", 35, "破军演练已完成")

func _buy_upgrade(upgrade_id: String, cost: int, success_message: String) -> void:
	if SaveService.purchase_upgrade(upgrade_id, cost):
		_show_shop()
		notice = success_message
		queue_redraw()
		return
	_show_shop()
	notice = "铜钱不足或该强化已拥有"
	queue_redraw()

func _equip_selected_hero() -> void:
	var hero_id := _selected_hero_id()
	if SaveService.equip_hero(hero_id):
		profile = SaveService.load_profile()
		notice = "%s 已上阵" % str(_selected_hero().get("name", "武将"))
		_show_main()
		notice = "%s 已上阵" % str(_selected_hero().get("name", "武将"))
		queue_redraw()

func _toggle_sound() -> void:
	var enabled := not SaveService.setting_enabled("sound_enabled")
	SaveService.set_setting("sound_enabled", enabled)
	AudioService.set_master_volume(0.0 if enabled else -80.0)
	_show_settings()

func _toggle_vibration() -> void:
	SaveService.set_setting("vibration_enabled", not SaveService.setting_enabled("vibration_enabled"))
	_show_settings()

func _refresh_hero_ids() -> void:
	hero_ids.clear()
	var unlocked: Array = profile.get("unlocked_heroes", [])
	for hero_id in HERO_CATALOG.all_ids():
		if unlocked.has(hero_id):
			hero_ids.append(hero_id)
	if hero_ids.is_empty():
		hero_ids.append("zhao_yun")
	var equipped_index := hero_ids.find(SaveService.equipped_hero_id())
	if equipped_index >= 0:
		selected_hero_index = equipped_index
	selected_hero_index = clampi(selected_hero_index, 0, hero_ids.size() - 1)

func _selected_hero_id() -> String:
	return hero_ids[selected_hero_index] if not hero_ids.is_empty() else "zhao_yun"

func _selected_hero() -> Dictionary:
	return HERO_CATALOG.definition_for(_selected_hero_id())

func _hero_carousel_rect() -> Rect2:
	return Rect2(size.x * 0.45, 170.0, size.x * 0.50, size.y - 300.0)

func _cycle_hero(delta: int) -> void:
	if hero_ids.size() <= 1:
		return
	selected_hero_index = posmod(selected_hero_index + delta, hero_ids.size())
	queue_redraw()

func _finish_carousel_drag() -> void:
	if absf(carousel_delta.x) >= 42.0:
		_cycle_hero(1 if carousel_delta.x < 0.0 else -1)
	carousel_touch_index = -1
	mouse_dragging_carousel = false
	carousel_delta = Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if page != "main":
		return
	var carousel_rect := _hero_carousel_rect()
	if event is InputEventScreenTouch:
		if event.pressed and carousel_rect.has_point(event.position):
			carousel_touch_index = event.index
			carousel_start = event.position
			carousel_delta = Vector2.ZERO
			accept_event()
		elif not event.pressed and event.index == carousel_touch_index:
			_finish_carousel_drag()
			accept_event()
	elif event is InputEventScreenDrag and event.index == carousel_touch_index:
		carousel_delta = event.position - carousel_start
		queue_redraw()
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and carousel_rect.has_point(event.position):
			mouse_dragging_carousel = true
			carousel_start = event.position
			carousel_delta = Vector2.ZERO
			accept_event()
		elif not event.pressed and mouse_dragging_carousel:
			_finish_carousel_drag()
			accept_event()
	elif event is InputEventMouseMotion and mouse_dragging_carousel:
		carousel_delta = event.position - carousel_start
		queue_redraw()
		accept_event()

func _create_button(title: String, subtitle: String, at: Vector2, callback: Callable, button_size: Vector2 = Vector2(340.0, 68.0), disabled: bool = false) -> void:
	var button := Button.new()
	button.text = title if subtitle.is_empty() else "%s\n%s" % [title, subtitle]
	button.position = at
	button.size = button_size
	button.disabled = disabled
	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_color_override("font_color", Color("f2e5c4"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color("829099"))
	button.add_theme_stylebox_override("normal", _make_box_style(PANEL_FILL, GOLD, 2))
	button.add_theme_stylebox_override("hover", _make_box_style(Color("1a2b33"), DRAGON_BLUE, 3))
	button.add_theme_stylebox_override("pressed", _make_box_style(Color("2e291d"), GOLD_BRIGHT, 3))
	button.add_theme_stylebox_override("disabled", _make_box_style(Color("131a1e"), Color("425058"), 1))
	button.pressed.connect(callback)
	add_child(button)
	buttons.append(button)

func _clear_buttons() -> void:
	for button in buttons:
		button.queue_free()
	buttons.clear()

func _rebuild_current_page() -> void:
	match page:
		"modes": _show_modes()
		"shop": _show_shop()
		"settings": _show_settings()
		"hero_details": _show_hero_details()
		_: _show_main()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("111a20"))
	for x in range(0, int(size.x) + 80, 56):
		draw_line(Vector2(x, 0), Vector2(x - 128, size.y), Color(0.50, 0.63, 0.69, 0.06), 1.0)
	var font := ThemeDB.fallback_font
	if page == "main":
		draw_string(font, Vector2(68, 90), "三国·破阵", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, GOLD_BRIGHT)
		draw_string(font, Vector2(72, 122), "名将破阵 · 兵海无双", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("a9c2c7"))
	draw_string(font, Vector2(size.x - 220, 52), "铜钱  %d" % int(profile.get("military_merit", 0)), HORIZONTAL_ALIGNMENT_LEFT, -1, 21, GOLD_BRIGHT)
	match page:
		"main": _draw_hero_carousel(font)
		"modes": _draw_modes(font)
		"shop": _draw_shop(font)
		"settings": _draw_settings(font)
		"hero_details": _draw_hero_details(font)
	if not notice.is_empty():
		draw_string(font, Vector2(size.x * 0.5 - 156.0, size.y - 34.0), notice, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("9ee0c6"))

func _draw_hero_carousel(font: Font) -> void:
	var area := _hero_carousel_rect()
	draw_string(font, Vector2(area.position.x, area.position.y - 28.0), "选择上阵武将", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, GOLD_BRIGHT)
	var hero := _selected_hero()
	var center_rect := Rect2(area.get_center() - Vector2(150, 150), Vector2(300, 300))
	_draw_hero_card(center_rect, hero, true, font)
	var side_width := 112.0
	var left_rect := Rect2(center_rect.position.x - side_width - 18.0, center_rect.position.y + 42.0, side_width, 212.0)
	var right_rect := Rect2(center_rect.end.x + 18.0, center_rect.position.y + 42.0, side_width, 212.0)
	_draw_placeholder_hero(left_rect, font)
	_draw_placeholder_hero(right_rect, font)
	draw_string(font, Vector2(area.get_center().x - 134.0, area.end.y - 14.0), "左右拖动切换武将", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, MUTED)

func _draw_hero_card(rect: Rect2, hero: Dictionary, selected: bool, font: Font) -> void:
	_draw_panel(rect, GOLD if selected else Color("485762"), selected)
	var portrait_path := str(hero.get("portrait", ""))
	if not portrait_path.is_empty():
		var portrait := _portrait_for(portrait_path)
		if portrait != null:
			draw_texture_rect(portrait, Rect2(rect.position + Vector2(48, 16), Vector2(204, 204)), false)
	draw_string(font, Vector2(rect.get_center().x - 48.0, rect.end.y - 46.0), str(hero.get("name", "武将")), HORIZONTAL_ALIGNMENT_CENTER, 96, 27, Color("f4e6c4"))
	draw_string(font, Vector2(rect.get_center().x - 70.0, rect.end.y - 20.0), str(hero.get("title", "")), HORIZONTAL_ALIGNMENT_CENTER, 140, 14, Color("9db7bd"))

func _draw_placeholder_hero(rect: Rect2, font: Font) -> void:
	draw_rect(rect, Color("10171c"))
	draw_rect(rect, Color("43515a"), false, 1.0)
	draw_string(font, Vector2(rect.get_center().x - 24.0, rect.get_center().y - 4.0), "待招募", HORIZONTAL_ALIGNMENT_CENTER, 48, 14, MUTED)

func _draw_modes(font: Font) -> void:
	draw_string(font, Vector2(size.x * 0.5 - 72.0, size.y * 0.5 - 132.0), "选择征战", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, GOLD_BRIGHT)

func _draw_shop(font: Font) -> void:
	draw_string(font, Vector2(size.x * 0.5 - 56.0, size.y * 0.5 - 108.0), "商店", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, GOLD_BRIGHT)

func _draw_settings(font: Font) -> void:
	draw_string(font, Vector2(size.x * 0.5 - 56.0, size.y * 0.5 - 108.0), "设置", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, GOLD_BRIGHT)

func _draw_hero_details(font: Font) -> void:
	var hero := _selected_hero()
	var stats := HERO_CATALOG.display_stats_for(_selected_hero_id(), profile)
	draw_string(font, Vector2(190, 102), "%s · %s" % [hero.get("name", "武将"), hero.get("title", "")], HORIZONTAL_ALIGNMENT_LEFT, -1, 32, GOLD_BRIGHT)
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
