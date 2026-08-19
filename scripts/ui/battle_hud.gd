class_name BattleHud
extends Control

const PANEL_FILL := Color("11191f")
const PANEL_INNER := Color("18242b")
const PANEL_EDGE := Color("7b6644")
const GOLD := Color("d5af66")
const GOLD_BRIGHT := Color("f4d58d")
const DRAGON_BLUE := Color("63b9df")
const HEALTH_RED := Color("d45a58")
const DISABLED := Color("566069")
const COMBO_TIMEOUT := 1.20
const COMBO_POP_DURATION := 0.18
const COMBO_FADE_DURATION := 0.28
const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")

signal upgrade_selected(upgrade_id: String)
signal upgrade_refresh_requested()
signal restart_requested()
signal pause_requested()
signal resume_requested()
signal home_requested()

var player: HeroActor
var boss: BossActor
var director: RunDirector
var elites: Array[EliteActor] = []
var tianji: TianjiSystem
var message := ""
var message_time := 0.0
var upgrade_buttons: Array[Button] = []
var upgrade_refresh_button: Button
var upgrade_refreshes_remaining := 2
var modal_active := false
var ui_time := 0.0
var ultimate_denied_time := 0.0
var result_active := false
var result_victory := false
var result_message := ""
var restart_button: Button
var result_home_button: Button
var pause_active := false
var pause_buttons: Array[Button] = []
var move_stick_offset := Vector2.ZERO
var run_gold := 0
var hero_portrait: Texture2D
var offscreen_named_targets: Array[Dictionary] = []
var combo_count := 0
var combo_remaining := 0.0
var combo_pop_remaining := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	_sync_viewport_layout()
	get_viewport().size_changed.connect(_sync_viewport_layout)

func configure(player_actor: HeroActor, boss_actor: BossActor, run_director: RunDirector, elite_actors: Array[EliteActor] = [], tianji_system: TianjiSystem = null) -> void:
	player = player_actor
	boss = boss_actor
	director = run_director
	elites = elite_actors
	tianji = tianji_system
	combo_count = 0
	combo_remaining = 0.0
	combo_pop_remaining = 0.0
	hero_portrait = null
	if player != null:
		var portrait_path := str(HERO_CATALOG.definition_for(player.hero_id).get("portrait", ""))
		if not portrait_path.is_empty():
			hero_portrait = load(portrait_path) as Texture2D
	message = _idle_stage_label()
	message_time = 2.8
	queue_redraw()

func set_elites(elite_actors: Array[EliteActor]) -> void:
	elites = elite_actors
	queue_redraw()

func set_named_target_indicators(targets: Array[Dictionary]) -> void:
	offscreen_named_targets = targets
	queue_redraw()

func _process(delta: float) -> void:
	ui_time += delta
	message_time = maxf(0.0, message_time - delta)
	ultimate_denied_time = maxf(0.0, ultimate_denied_time - delta)
	combo_remaining = maxf(0.0, combo_remaining - delta)
	combo_pop_remaining = maxf(0.0, combo_pop_remaining - delta)
	if combo_remaining <= 0.0:
		combo_count = 0
	queue_redraw()

func record_combo_hits(hit_count: int) -> void:
	if hit_count <= 0:
		return
	combo_count += hit_count
	combo_remaining = COMBO_TIMEOUT
	combo_pop_remaining = COMBO_POP_DURATION
	queue_redraw()

func set_message(value: String) -> void:
	message = value
	message_time = 2.2

func announce_ultimate_ready() -> void:
	message = "无双已就绪！消耗 %d 能量" % _ultimate_cost()
	message_time = 3.4

func show_ultimate_unavailable(energy: float) -> void:
	message = "无双能量不足  %d / %d" % [int(energy), _ultimate_cost()]
	message_time = 1.4
	ultimate_denied_time = 0.7

func attack_center() -> Vector2:
	return Vector2(size.x - 112.0, size.y - 112.0)

func active_center() -> Vector2:
	return Vector2(size.x - 248.0, size.y - 122.0)

func ultimate_center() -> Vector2:
	return Vector2(size.x - 118.0, size.y - 252.0)

func weapon_stance_center() -> Vector2:
	return Vector2(size.x - 348.0, size.y - 246.0)

func is_weapon_stance_hit(at: Vector2) -> bool:
	return player != null and player.supports_weapon_stance() and at.distance_to(weapon_stance_center()) <= 46.0

func move_center() -> Vector2:
	return Vector2(142.0, size.y - 142.0)

func move_capture_radius() -> float:
	return 124.0

func set_move_stick_offset(value: Vector2) -> void:
	move_stick_offset = value.limit_length(82.0)
	queue_redraw()

func clear_move_stick_offset() -> void:
	move_stick_offset = Vector2.ZERO
	queue_redraw()

func set_run_gold(value: int) -> void:
	run_gold = value
	queue_redraw()

func set_upgrade_refreshes_remaining(value: int) -> void:
	upgrade_refreshes_remaining = maxi(0, value)
	if upgrade_refresh_button != null:
		_upgrade_refresh_button_sync()
	queue_redraw()

func pause_center() -> Vector2:
	return Vector2(size.x - 206.0, 38.0)

func is_pause_hit(at: Vector2) -> bool:
	return at.distance_to(pause_center()) <= 30.0

func show_pause() -> void:
	if result_active or pause_active:
		return
	pause_active = true
	modal_active = true
	_create_pause_button("继续", _on_resume_button_pressed)
	_create_pause_button("重新开始", _on_pause_restart_button_pressed)
	_create_pause_button("返回首页", _on_home_button_pressed)
	_layout_pause_buttons()
	queue_redraw()

func hide_pause() -> void:
	if not pause_active:
		return
	pause_active = false
	modal_active = false
	for button in pause_buttons:
		button.queue_free()
	pause_buttons.clear()
	queue_redraw()

func show_upgrades(options: Array[String], upgrade_system: UpgradeSystem) -> void:
	modal_active = true
	_clear_upgrade_controls()
	for index in range(options.size()):
		var button := Button.new()
		button.text = ""
		button.size = Vector2(216.0, 300.0)
		button.add_theme_stylebox_override("normal", _make_upgrade_card_style(PANEL_FILL, PANEL_EDGE, 2))
		button.add_theme_stylebox_override("hover", _make_upgrade_card_style(Color("1a2b33"), DRAGON_BLUE, 3))
		button.add_theme_stylebox_override("pressed", _make_upgrade_card_style(Color("2e291d"), GOLD_BRIGHT, 3))
		_add_upgrade_card_text(button, upgrade_system.category_for(options[index]), upgrade_system.title_for(options[index]), upgrade_system.description_for(options[index]))
		button.pressed.connect(_on_upgrade_button_pressed.bind(options[index]))
		add_child(button)
		upgrade_buttons.append(button)
	_create_upgrade_refresh_button()
	_layout_upgrade_buttons()
	queue_redraw()

func _add_upgrade_card_text(button: Button, category: String, title: String, description: String) -> void:
	var content := VBoxContainer.new()
	content.position = Vector2(18.0, 20.0)
	content.size = button.size - Vector2(36.0, 38.0)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 8)
	button.add_child(content)
	var category_label := Label.new()
	category_label.text = category
	category_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	category_label.add_theme_font_size_override("font_size", 14)
	category_label.add_theme_color_override("font_color", GOLD)
	content.add_child(category_label)
	var title_label := Label.new()
	title_label.text = title
	title_label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color("f5e5bf"))
	content.add_child(title_label)
	var description_label := Label.new()
	description_label.text = description
	description_label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	description_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	description_label.add_theme_font_size_override("font_size", 16)
	description_label.add_theme_color_override("font_color", Color("c5d3d2"))
	content.add_child(description_label)

func show_result(victory: bool, value: String) -> void:
	if result_active:
		return
	result_active = true
	result_victory = victory
	result_message = value
	pause_active = false
	for button in pause_buttons:
		button.queue_free()
	pause_buttons.clear()
	modal_active = true
	restart_button = Button.new()
	restart_button.text = "重新开始"
	restart_button.size = Vector2(206.0, 58.0)
	restart_button.add_theme_font_size_override("font_size", 24)
	restart_button.add_theme_color_override("font_color", Color("fff0c7"))
	restart_button.add_theme_color_override("font_hover_color", Color.WHITE)
	restart_button.add_theme_stylebox_override("normal", _make_box_style(Color("28332f"), GOLD, 2))
	restart_button.add_theme_stylebox_override("hover", _make_box_style(Color("304039"), GOLD_BRIGHT, 3))
	restart_button.add_theme_stylebox_override("pressed", _make_box_style(Color("4a3b24"), GOLD_BRIGHT, 3))
	restart_button.pressed.connect(_on_restart_button_pressed)
	add_child(restart_button)
	result_home_button = Button.new()
	result_home_button.text = "返回首页"
	result_home_button.size = Vector2(206.0, 58.0)
	result_home_button.add_theme_font_size_override("font_size", 24)
	result_home_button.add_theme_color_override("font_color", Color("fff0c7"))
	result_home_button.add_theme_color_override("font_hover_color", Color.WHITE)
	result_home_button.add_theme_stylebox_override("normal", _make_box_style(PANEL_FILL, GOLD, 2))
	result_home_button.add_theme_stylebox_override("hover", _make_box_style(Color("22323a"), GOLD_BRIGHT, 3))
	result_home_button.add_theme_stylebox_override("pressed", _make_box_style(Color("4a3b24"), GOLD_BRIGHT, 3))
	result_home_button.pressed.connect(_on_home_button_pressed)
	add_child(result_home_button)
	_layout_restart_button()
	queue_redraw()

func _on_upgrade_button_pressed(upgrade_id: String) -> void:
	_clear_upgrade_controls()
	modal_active = false
	upgrade_selected.emit(upgrade_id)
	queue_redraw()

func _on_upgrade_refresh_button_pressed() -> void:
	if upgrade_refreshes_remaining <= 0:
		return
	upgrade_refresh_requested.emit()

func _create_upgrade_refresh_button() -> void:
	upgrade_refresh_button = Button.new()
	upgrade_refresh_button.size = Vector2(174.0, 42.0)
	upgrade_refresh_button.add_theme_font_size_override("font_size", 17)
	upgrade_refresh_button.add_theme_color_override("font_color", Color("fff0c7"))
	upgrade_refresh_button.add_theme_color_override("font_hover_color", Color.WHITE)
	upgrade_refresh_button.add_theme_color_override("font_disabled_color", Color("777f82"))
	upgrade_refresh_button.add_theme_stylebox_override("normal", _make_box_style(Color("28332f"), GOLD, 2))
	upgrade_refresh_button.add_theme_stylebox_override("hover", _make_box_style(Color("304039"), GOLD_BRIGHT, 3))
	upgrade_refresh_button.add_theme_stylebox_override("pressed", _make_box_style(Color("4a3b24"), GOLD_BRIGHT, 3))
	upgrade_refresh_button.add_theme_stylebox_override("disabled", _make_box_style(Color("20282b"), DISABLED, 1))
	upgrade_refresh_button.pressed.connect(_on_upgrade_refresh_button_pressed)
	add_child(upgrade_refresh_button)
	_upgrade_refresh_button_sync()

func _upgrade_refresh_button_sync() -> void:
	if upgrade_refresh_button == null:
		return
	upgrade_refresh_button.text = "刷新  %d / 2" % upgrade_refreshes_remaining
	upgrade_refresh_button.disabled = upgrade_refreshes_remaining <= 0

func _clear_upgrade_controls() -> void:
	for button in upgrade_buttons:
		button.queue_free()
	upgrade_buttons.clear()
	if upgrade_refresh_button != null:
		upgrade_refresh_button.queue_free()
		upgrade_refresh_button = null

func _on_restart_button_pressed() -> void:
	restart_requested.emit()

func _on_resume_button_pressed() -> void:
	resume_requested.emit()

func _on_pause_restart_button_pressed() -> void:
	restart_requested.emit()

func _on_home_button_pressed() -> void:
	home_requested.emit()

func _create_pause_button(label: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.size = Vector2(240.0, 54.0)
	button.add_theme_font_size_override("font_size", 21)
	button.add_theme_color_override("font_color", Color("fff0c7"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _make_box_style(PANEL_FILL, GOLD, 2))
	button.add_theme_stylebox_override("hover", _make_box_style(Color("22323a"), GOLD_BRIGHT, 3))
	button.add_theme_stylebox_override("pressed", _make_box_style(Color("4a3b24"), GOLD_BRIGHT, 3))
	button.pressed.connect(callback)
	add_child(button)
	pause_buttons.append(button)

func _sync_viewport_layout() -> void:
	position = Vector2.ZERO
	size = get_viewport().get_visible_rect().size
	_layout_upgrade_buttons()
	_layout_upgrade_refresh_button()
	_layout_restart_button()
	_layout_pause_buttons()
	queue_redraw()

func _layout_upgrade_buttons() -> void:
	if upgrade_buttons.is_empty():
		return
	var gap := 20.0
	var card_width := 216.0
	var total_width := upgrade_buttons.size() * card_width + (upgrade_buttons.size() - 1) * gap
	var start_x := size.x * 0.5 - total_width * 0.5
	for index in range(upgrade_buttons.size()):
		upgrade_buttons[index].position = Vector2(start_x + index * (card_width + gap), size.y * 0.5 - 142.0)
	_layout_upgrade_refresh_button()

func _layout_upgrade_refresh_button() -> void:
	if upgrade_refresh_button == null:
		return
	var card_y := size.y * 0.5 - 142.0
	upgrade_refresh_button.position = Vector2(size.x * 0.5 - upgrade_refresh_button.size.x * 0.5, card_y + 312.0)

func _layout_restart_button() -> void:
	if restart_button == null:
		return
	if result_home_button == null:
		restart_button.position = Vector2(size.x * 0.5 - restart_button.size.x * 0.5, size.y * 0.5 + 72.0)
		return
	var gap := 18.0
	var total_width := restart_button.size.x + result_home_button.size.x + gap
	var start_x := size.x * 0.5 - total_width * 0.5
	var button_y := size.y * 0.5 + 72.0
	restart_button.position = Vector2(start_x, button_y)
	result_home_button.position = Vector2(start_x + restart_button.size.x + gap, button_y)

func _layout_pause_buttons() -> void:
	if pause_buttons.is_empty():
		return
	var pause_rect := _pause_panel_rect()
	var gap := 10.0
	var total_height := 0.0
	for button in pause_buttons:
		total_height += button.size.y
	total_height += gap * float(maxi(0, pause_buttons.size() - 1))
	var start_y := pause_rect.end.y - 24.0 - total_height
	for index in range(pause_buttons.size()):
		var offset_y := 0.0
		for previous_index in range(index):
			offset_y += pause_buttons[previous_index].size.y
			offset_y += gap
		pause_buttons[index].position = Vector2(pause_rect.get_center().x - pause_buttons[index].size.x * 0.5, start_y + offset_y)

func _draw() -> void:
	var font := ThemeDB.fallback_font
	_draw_top_hud(font)
	_draw_combo_counter(font)
	_draw_tianji_slots(font)
	_draw_skill_cluster(font)
	_draw_named_target_indicators()
	_draw_modal_backdrop(font)

func _draw_combo_counter(font: Font) -> void:
	if combo_count <= 0 or modal_active or result_active:
		return
	var pop_ratio := clampf(combo_pop_remaining / COMBO_POP_DURATION, 0.0, 1.0)
	var fade_ratio := clampf(combo_remaining / COMBO_FADE_DURATION, 0.0, 1.0)
	var alpha := minf(1.0, fade_ratio)
	var text_scale := 1.0 + pop_ratio * 0.20
	var font_size := maxi(18, int(27.0 * text_scale))
	var text_width := 320.0 * text_scale
	var lift := (1.0 - fade_ratio) * 10.0
	var origin := Vector2(size.x * 0.5 - text_width * 0.5, 91.0 - lift)
	var label := "连击 x %d" % combo_count
	var outline := Color(0.20, 0.07, 0.015, alpha * 0.94)
	var fill := Color(1.0, 0.72, 0.20, alpha)
	for offset in [Vector2(-2, -2), Vector2(2, -2), Vector2(-2, 2), Vector2(2, 2)]:
		draw_string(font, origin + offset, label, HORIZONTAL_ALIGNMENT_CENTER, text_width, font_size, outline)
	draw_string(font, origin, label, HORIZONTAL_ALIGNMENT_CENTER, text_width, font_size, fill)

func _draw_top_hud(font: Font) -> void:
	var player_panel := Rect2(16, 14, 372, 116)
	_draw_panel(player_panel, DRAGON_BLUE)
	if player != null:
		var hero_name := HERO_CATALOG.display_name_for(player.hero_id)
		var hero_marker := hero_name.left(1)
		var badge_rect := Rect2(25.0, 27.0, 44.0, 44.0)
		if hero_portrait != null:
			_draw_hero_badge(hero_portrait, badge_rect)
		else:
			draw_circle(badge_rect.get_center(), 21.0, Color("0d1318"))
			draw_string(font, Vector2(35, 55), hero_marker, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, GOLD_BRIGHT)
		draw_rect(badge_rect, GOLD, false, 2.0)
		draw_string(font, Vector2(78, 34), "%s · %s" % [hero_name, player.basic_ability_label()], HORIZONTAL_ALIGNMENT_LEFT, 246.0, 17, Color("f1e1bd"))
		var mode_label := _battle_mode_label()
		var level_label := "Lv.%d · %s" % [director.level, mode_label] if director != null else "Lv.1 · 剧情战役"
		draw_string(font, Vector2(78, 53), level_label, HORIZONTAL_ALIGNMENT_LEFT, 246.0, 13, Color("9cb4bf"))
		var health_ratio := player.health_component.current / maxf(1.0, player.health_component.maximum)
		_draw_bar(Rect2(78, 61, 260, 11), health_ratio, HEALTH_RED, "生命  %d / %d" % [player.health_component.current, player.health_component.maximum], font)
		var ultimate_ratio := player.ultimate_energy / 100.0
		var ultimate_ready := player.is_ultimate_ready()
		var energy_color := GOLD if ultimate_ready else DRAGON_BLUE
		_draw_bar(Rect2(78, 80, 260, 12), ultimate_ratio, energy_color, "无双  %d / 100" % int(player.ultimate_energy), font)
		if director != null:
			_draw_bar(Rect2(78, 99, 176, 10), director.progress(), GOLD, "经验  %d / %d" % [director.experience, director.next_level_experience], font)
		var merit_color := GOLD_BRIGHT if run_gold > 0 else Color("c1c9c6")
		draw_string(font, Vector2(266, 107), "军功  %d" % run_gold, HORIZONTAL_ALIGNMENT_LEFT, 76.0, 13, merit_color)
	if director != null:
		var stage_rect := Rect2(size.x * 0.5 - 184.0, 14, 368, 40)
		_draw_panel(stage_rect, GOLD)
		var stage_text := message if message_time > 0.0 else _idle_stage_label()
		draw_string(font, Vector2(stage_rect.position.x + 16, 40), stage_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f3e3bd"))
		var time_rect := Rect2(size.x - 170.0, 14, 154, 48)
		_draw_panel(time_rect, GOLD)
		if director.is_boss_trial():
			draw_string(font, Vector2(time_rect.position.x + 34, 44), "试炼", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("f5e5bb"))
		else:
			draw_string(font, Vector2(time_rect.position.x + 22, 45), "%02d:%02d" % [int(director.remaining_time()) / 60, int(director.remaining_time()) % 60], HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("f5e5bb"))
	var pause_at := pause_center()
	draw_circle(pause_at, 28.0, Color("10191f"))
	draw_arc(pause_at, 28.0, 0.0, TAU, 20, GOLD, 2.0)
	draw_line(pause_at + Vector2(-6, -9), pause_at + Vector2(-6, 9), GOLD_BRIGHT, 4.0)
	draw_line(pause_at + Vector2(6, -9), pause_at + Vector2(6, 9), GOLD_BRIGHT, 4.0)
	_draw_hero_status_rack(font)
	_draw_enemy_status_rack(font)

func _draw_hero_status_rack(font: Font) -> void:
	if player == null:
		return
	var effects := player.hud_status_effects()
	if effects.is_empty():
		return
	var rack_rect := Rect2(16.0, 140.0, 372.0, 38.0)
	_draw_panel(rack_rect, DRAGON_BLUE)
	var cursor_x := rack_rect.position.x + 10.0
	for effect in effects:
		var effect_width := _draw_hero_status_effect(Vector2(cursor_x, rack_rect.position.y + 5.0), effect, font)
		cursor_x += effect_width + 8.0
		if cursor_x >= rack_rect.end.x - 96.0:
			break

func _draw_tianji_slots(font: Font) -> void:
	if tianji == null:
		return
	var slots := tianji.hud_slots()
	if slots.is_empty():
		return
	var rack_rect := Rect2(size.x - 274.0, 74.0, 258.0, 62.0)
	_draw_panel(rack_rect, Color("82c8cb"))
	draw_string(font, rack_rect.position + Vector2(12.0, 23.0), "天机", HORIZONTAL_ALIGNMENT_LEFT, 34.0, 14, GOLD_BRIGHT)
	var slot_width := (rack_rect.size.x - 48.0) / float(slots.size())
	for index in range(slots.size()):
		var slot: Dictionary = slots[index] as Dictionary
		var title := str(slot.get("title", "天机"))
		var rank := int(slot.get("rank", 1))
		var accent: Color = slot.get("color", DRAGON_BLUE)
		var cooldown := maxf(0.1, float(slot.get("cooldown", 1.0)))
		var cooldown_remaining := maxf(0.0, float(slot.get("cooldown_remaining", 0.0)))
		var windup_remaining := maxf(0.0, float(slot.get("windup_remaining", 0.0)))
		var active_remaining := maxf(0.0, float(slot.get("active_remaining", 0.0)))
		var active_duration := maxf(0.1, float(slot.get("active_duration", 1.0)))
		var origin := rack_rect.position + Vector2(48.0 + float(index) * slot_width, 7.0)
		var icon_center := origin + Vector2(13.0, 13.0)
		var ready := cooldown_remaining <= 0.0 and windup_remaining <= 0.0 and active_remaining <= 0.0
		var ratio := 1.0 - cooldown_remaining / cooldown
		if windup_remaining > 0.0:
			ratio = 0.68
		elif active_remaining > 0.0:
			ratio = active_remaining / active_duration
		draw_circle(icon_center, 12.0, Color("101c22"))
		draw_arc(icon_center, 12.0, -PI * 0.5, -PI * 0.5 + TAU * clampf(ratio, 0.0, 1.0), 16, accent, 2.4)
		draw_string(font, icon_center + Vector2(-8.0, 5.0), title.left(1), HORIZONTAL_ALIGNMENT_CENTER, 16.0, 13, accent.lightened(0.24))
		draw_string(font, origin + Vector2(30.0, 12.0), title, HORIZONTAL_ALIGNMENT_LEFT, slot_width - 34.0, 12, Color("d9efeb"))
		var status := "演算" if windup_remaining > 0.0 else ("施放" if active_remaining > 0.0 else ("就绪" if ready else "%.1fs" % cooldown_remaining))
		draw_string(font, origin + Vector2(30.0, 29.0), "%s  Lv.%d" % [status, rank], HORIZONTAL_ALIGNMENT_LEFT, slot_width - 34.0, 11, accent if ready else Color("a8bab9"))

func _draw_hero_status_effect(origin: Vector2, effect: Dictionary, font: Font) -> float:
	var accent: Color = effect.get("color", DRAGON_BLUE)
	var label := str(effect.get("label", "状态"))
	var icon := str(effect.get("icon", "·"))
	var stacks := maxi(0, int(effect.get("stacks", 0)))
	var timed := bool(effect.get("timed", true))
	var remaining := maxf(0.0, float(effect.get("remaining", 0.0)))
	var duration := maxf(0.1, float(effect.get("duration", 1.0)))
	var width := 164.0
	var icon_center := origin + Vector2(12.0, 14.0)
	draw_circle(icon_center, 10.0, accent.darkened(0.46))
	draw_arc(icon_center, 10.0, 0.0, TAU, 12, accent.lightened(0.18), 1.2)
	draw_string(font, icon_center + Vector2(-8.0, 6.0), icon, HORIZONTAL_ALIGNMENT_CENTER, 16.0, 13, Color("e8f7ff"))
	draw_string(font, origin + Vector2(27.0, 18.0), label, HORIZONTAL_ALIGNMENT_LEFT, 44.0, 13, Color("d8eff7"))
	draw_string(font, origin + Vector2(73.0, 18.0), "x%d" % stacks, HORIZONTAL_ALIGNMENT_LEFT, 28.0, 13, accent.lightened(0.20))
	if timed:
		var timer_start := origin + Vector2(108.0, 20.0)
		var timer_end := origin + Vector2(158.0, 20.0)
		var timer_ratio := clampf(remaining / duration, 0.0, 1.0)
		draw_line(timer_start, timer_end, Color("49616b"), 2.0)
		draw_line(timer_start, timer_start.lerp(timer_end, timer_ratio), accent, 3.0)
	return width

func _battle_mode_label() -> String:
	if director == null:
		return "剧情战役"
	if director.is_boss_trial():
		return "名将试炼"
	if director.mode == "story":
		return "剧情 · %s" % director.story_chapter_title()
	match director.battlefield_id:
		"xinye":
			return "无尽 · 新野"
		"bowangpo", "bowangpo_story":
			return "无尽 · 博望坡"
		_:
			return "无尽 · 长坂坡"

func _idle_stage_label() -> String:
	if director == null:
		return "战场推进"
	if director.is_boss_trial():
		return "虎牢关外 · 斗将台"
	if director.mode == "story":
		return director.story_chapter_title()
	match director.battlefield_id:
		"xinye":
			return "新野 · 练兵校场"
		"bowangpo", "bowangpo_story":
			return "博望坡 · 火谷战场"
		_:
			return "长坂坡 · 夜雪战场"

func _draw_enemy_status_rack(font: Font) -> void:
	var active_elites: Array[EliteActor] = []
	for elite in elites:
		if is_instance_valid(elite) and elite.active:
			active_elites.append(elite)
	var has_boss := boss != null and boss.active
	if not has_boss and active_elites.is_empty():
		return
	var row_y := 188.0
	if has_boss:
		var boss_rect := Rect2(size.x * 0.05, row_y, size.x * 0.90, 60.0)
		var boss_state := "第 %d 阶段" % boss.phase
		if boss.is_stance_broken():
			boss_state += " · 破势"
		elif boss.has_counterattack():
			boss_state += " · 反击"
		_draw_enemy_status_bar(boss_rect, "敌将", boss.display_name(), boss.health_component.current, boss.health_component.maximum, boss.health_layer_capacity(), boss.stance, BossActor.STANCE_MAX, Color("d55345"), boss_state, "boss", font)
		row_y += 68.0
	if active_elites.size() == 1:
		var elite := active_elites[0]
		var centered_rect := Rect2(size.x * 0.10, row_y, size.x * 0.80, 48.0)
		var elite_state := "破势" if elite.is_stance_broken() else ("反击" if elite.has_counterattack() else "")
		_draw_enemy_status_bar(centered_rect, "精英", elite.display_name(), elite.health_component.current, elite.health_component.maximum, EliteActor.HEALTH_LAYER_CAPACITY, elite.stance, EliteActor.STANCE_MAX, elite.hud_color(), elite_state, "elite:%d" % elite.get_instance_id(), font)
		return
	for index in range(mini(4, active_elites.size())):
		var elite := active_elites[index]
		var column := index % 2
		var row := index / 2
		var elite_rect := Rect2(size.x * (0.05 + column * 0.46), row_y + row * 48.0, size.x * 0.44, 44.0)
		var elite_state := "破势" if elite.is_stance_broken() else ("反击" if elite.has_counterattack() else "")
		_draw_enemy_status_bar(elite_rect, "精英", elite.display_name(), elite.health_component.current, elite.health_component.maximum, EliteActor.HEALTH_LAYER_CAPACITY, elite.stance, EliteActor.STANCE_MAX, elite.hud_color(), elite_state, "elite:%d" % elite.get_instance_id(), font)

func _draw_enemy_status_bar(rect: Rect2, rank: String, name: String, current: float, maximum: float, layer_capacity: float, stance_current: float, stance_maximum: float, accent: Color, state_label: String, target_key: String, font: Font) -> void:
	draw_rect(rect, Color("0a0e12", 0.94))
	draw_rect(rect, accent, false, 2.0)
	var is_boss := rank == "敌将"
	var label_width := 196.0 if is_boss else 138.0
	var health_height := 32.0 if is_boss else 24.0
	var stance_height := 10.0 if is_boss else 8.0
	var health_top := 5.0
	var stance_top := health_top + health_height + 5.0
	var title_color := Color("f4d6c4") if rank == "敌将" else Color("f1dfbd")
	draw_string(font, rect.position + Vector2(10, 14), rank, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, accent.lightened(0.24))
	draw_string(font, rect.position + Vector2(49, 15), name, HORIZONTAL_ALIGNMENT_LEFT, label_width - 54.0, 16 if is_boss else 14, title_color)
	draw_string(font, rect.position + Vector2(10, 30), "生命 %s / %s" % [_compact_enemy_value(current), _compact_enemy_value(maximum)], HORIZONTAL_ALIGNMENT_LEFT, label_width - 16.0, 11, Color("e5c9ba"))
	draw_string(font, rect.position + Vector2(10, stance_top + stance_height), "架势 %d / %d" % [int(stance_current), int(stance_maximum)], HORIZONTAL_ALIGNMENT_LEFT, label_width - 16.0, 10, Color("9bd7ed"))
	if not state_label.is_empty():
		draw_string(font, rect.position + Vector2(label_width - 78, 15), state_label, HORIZONTAL_ALIGNMENT_RIGHT, 70, 12, GOLD_BRIGHT)
	var health_rect := Rect2(rect.position + Vector2(label_width, health_top), Vector2(rect.size.x - label_width - 11, health_height))
	_draw_layered_enemy_health(health_rect, current, maximum, layer_capacity)
	_draw_enemy_stance(Rect2(health_rect.position + Vector2(0.0, health_height + 5.0), Vector2(health_rect.size.x, stance_height)), stance_current, stance_maximum)

func _compact_enemy_value(value: float) -> String:
	if value >= 1000.0:
		return "%.1fk" % (value / 1000.0)
	return str(int(value))

func _draw_enemy_stance(rect: Rect2, current: float, maximum: float) -> void:
	var ratio := clampf(current / maxf(1.0, maximum), 0.0, 1.0)
	draw_rect(rect, Color("0b1217", 0.94))
	if ratio > 0.0:
		draw_rect(Rect2(rect.position + Vector2(1, 1), Vector2(maxf(0.0, (rect.size.x - 2.0) * ratio), maxf(0.0, rect.size.y - 2.0))), Color("62bddf"))
	draw_rect(rect, Color("c99762"), false, 1.0)

func _draw_layered_enemy_health(rect: Rect2, current: float, maximum: float, layer_capacity: float) -> void:
	draw_rect(rect, Color("14090d"))
	if current <= 0.0:
		draw_rect(rect, Color("c99762"), false, 1.0)
		return
	var safe_capacity := maxf(1.0, layer_capacity)
	var total_layers := maxi(1, ceili(maximum / safe_capacity))
	var active_layer := maxi(1, ceili(current / safe_capacity))
	var active_capacity := _health_layer_capacity(active_layer, total_layers, maximum, safe_capacity)
	var active_value := clampf(current - float(active_layer - 1) * safe_capacity, 0.0, active_capacity)
	var active_ratio := active_value / maxf(1.0, active_capacity)
	var main_rect := Rect2(rect.position + Vector2(1.0, 1.0), rect.size - Vector2(2.0, 2.0))
	var active_color := _health_layer_color(active_layer, total_layers)
	draw_rect(main_rect, active_color.darkened(0.58))
	if active_layer > 1:
		var next_color := _health_layer_color(active_layer - 1, total_layers)
		var next_rect := Rect2(main_rect.position + Vector2(main_rect.size.x * active_ratio, 0.0), Vector2(main_rect.size.x * (1.0 - active_ratio), main_rect.size.y))
		draw_rect(next_rect, next_color)
	draw_rect(Rect2(main_rect.position, Vector2(main_rect.size.x * active_ratio, main_rect.size.y)), active_color)
	draw_rect(main_rect, Color("ffd0c4"), false, 1.0)
	draw_rect(rect, Color("c99762"), false, 1.0)

func _health_layer_capacity(layer_number: int, total_layers: int, maximum: float, layer_capacity: float) -> float:
	if layer_number != total_layers:
		return layer_capacity
	var top_layer_capacity := fmod(maximum, layer_capacity)
	return layer_capacity if is_zero_approx(top_layer_capacity) else top_layer_capacity

func _health_layer_color(layer_number: int, total_layers: int) -> Color:
	var palette := [Color("f05a4a"), Color("b8353e"), Color("7c202c"), Color("49131e")]
	return palette[(total_layers - layer_number) % palette.size()]

func _draw_skill_cluster(font: Font) -> void:
	_draw_move_pad(font)
	var basic_label := player.basic_ability_label() if player != null else "普攻"
	_draw_skill_button(attack_center(), 64.0, "普攻", basic_label, DRAGON_BLUE, true, font)
	# The active skill is charge-based: a non-empty reserve stays visually usable
	# even while the next charge is recovering in the background.
	var active_enabled := player != null and player.active_charge_count > 0
	var active_color := Color("6bbd9f") if active_enabled else DISABLED
	var active_label := player.active_ability_label() if player != null else "主动"
	var active_subtitle := active_label
	if player != null:
		active_subtitle = player.active_charges_label()
		if not active_enabled:
			active_subtitle += " · %.1fs" % maxf(0.0, player.active_cooldown)
	_draw_skill_button(active_center(), 50.0, "主动", active_subtitle, active_color, active_enabled, font)
	var ultimate_ready := player != null and player.is_ultimate_ready()
	var ultimate_label := player.ultimate_ability_label() if player != null else "无双"
	_draw_skill_button(ultimate_center(), 52.0, "无双", ultimate_label, GOLD if ultimate_ready else DISABLED, ultimate_ready, font)
	if player != null and player.supports_weapon_stance():
		var stance_is_bow := player.is_bow_stance()
		var stance_color := Color("d7ad5a") if stance_is_bow else Color("c66d52")
		_draw_skill_button(weapon_stance_center(), 38.0, "切换", player.weapon_stance_label(), stance_color, not player.is_action_locked(), font)
	if ultimate_denied_time > 0.0:
		draw_string(font, ultimate_center() + Vector2(-36, -66), "能量不足", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("ff9b7b"))
	if player != null and player.is_ultimate_ready():
		draw_string(font, Vector2(size.x * 0.5 - 100, 236), "无双已就绪 · 消耗 %d" % _ultimate_cost(), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("ffe49a"))

func _draw_named_target_indicators() -> void:
	if modal_active or offscreen_named_targets.is_empty():
		return
	var lane_counts: Dictionary = {}
	for target in offscreen_named_targets:
		var direction: Vector2 = target.get("direction", Vector2.UP)
		if direction.length_squared() <= 0.01:
			direction = Vector2.UP
		else:
			direction = direction.normalized()
		var lane := _named_indicator_lane(direction)
		var slot := int(lane_counts.get(lane, 0))
		lane_counts[lane] = slot + 1
		var center := _named_indicator_position(direction, lane, slot)
		_draw_named_target_indicator(center, direction, str(target.get("kind", "elite_xiahou")))

func _named_indicator_safe_rect() -> Rect2:
	var margin := Vector2(38.0, 0.0)
	var top := minf(300.0, maxf(278.0, size.y * 0.52))
	var bottom := maxf(top + 72.0, size.y - 238.0)
	return Rect2(Vector2(margin.x, top), Vector2(maxf(72.0, size.x - margin.x * 2.0), maxf(72.0, bottom - top)))

func _named_indicator_lane(direction: Vector2) -> String:
	var safe_rect := _named_indicator_safe_rect()
	if absf(direction.x) * safe_rect.size.y > absf(direction.y) * safe_rect.size.x:
		return "right" if direction.x >= 0.0 else "left"
	return "bottom" if direction.y >= 0.0 else "top"

func _named_indicator_position(direction: Vector2, lane: String, slot: int) -> Vector2:
	var safe_rect := _named_indicator_safe_rect()
	var safe_center := safe_rect.get_center()
	var x_scale := INF if absf(direction.x) <= 0.001 else (safe_rect.size.x * 0.5) / absf(direction.x)
	var y_scale := INF if absf(direction.y) <= 0.001 else (safe_rect.size.y * 0.5) / absf(direction.y)
	var center := safe_center + direction * minf(x_scale, y_scale)
	var offset := _named_indicator_slot_offset(slot)
	if lane == "left" or lane == "right":
		center.y += offset
	else:
		center.x += offset
	center.x = clampf(center.x, safe_rect.position.x, safe_rect.end.x)
	center.y = clampf(center.y, safe_rect.position.y, safe_rect.end.y)
	return center

func _named_indicator_slot_offset(slot: int) -> float:
	if slot <= 0:
		return 0.0
	var distance: float = 42.0 * ceil(float(slot) * 0.5)
	return distance if slot % 2 == 1 else -distance

func _draw_named_target_indicator(center: Vector2, direction: Vector2, kind: String) -> void:
	var is_boss := kind == "boss"
	var radius := 23.0 if is_boss else 19.0
	var accent := Color("d85b4b") if is_boss else Color("e0a044")
	var pulse := 0.66 + 0.34 * (sin(ui_time * (4.0 if is_boss else 3.2)) + 1.0) * 0.5
	draw_circle(center, radius + 5.0, Color(0.03, 0.04, 0.05, 0.78))
	draw_circle(center, radius, Color("1d1715"))
	draw_arc(center, radius, 0.0, TAU, 20, _alpha(accent, pulse), 2.5 if is_boss else 2.0)
	if is_boss:
		draw_arc(center, radius + 3.0, 0.22, TAU - 0.22, 20, Color(1.0, 0.77, 0.48, pulse * 0.82), 1.0)
	_draw_named_target_avatar(center, kind)
	var perpendicular := Vector2(-direction.y, direction.x)
	var arrow_base := center + direction * (radius + 7.0)
	var arrow_tip := center + direction * (radius + 19.0)
	var arrow := PackedVector2Array([
		arrow_tip,
		arrow_base + perpendicular * 6.0,
		arrow_base - perpendicular * 6.0,
	])
	draw_colored_polygon(arrow, accent.lightened(0.14))

func _draw_named_target_avatar(center: Vector2, kind: String) -> void:
	match kind:
		"boss":
			draw_rect(Rect2(center + Vector2(-10, 2), Vector2(20, 12)), Color("6b2941"))
			draw_circle(center + Vector2(0, -5), 8.5, Color("ddc6ae"))
			draw_rect(Rect2(center + Vector2(-8, -13), Vector2(16, 6)), Color("785873"))
			draw_line(center + Vector2(8, 6), center + Vector2(17, -8), Color("d9e1e6"), 2.4)
		"elite_chunyu":
			draw_rect(Rect2(center + Vector2(-9, 3), Vector2(18, 11)), Color("8d5529"))
			draw_circle(center + Vector2(0, -5), 7.6, Color("dec2a3"))
			draw_rect(Rect2(center + Vector2(-8, -12), Vector2(16, 5)), Color("ba813b"))
			draw_line(center + Vector2(7, 6), center + Vector2(15, -5), Color("d8cfb6"), 3.0)
		"elite_xiahou_lan":
			draw_rect(Rect2(center + Vector2(-9, 3), Vector2(18, 11)), Color("7b473b"))
			draw_circle(center + Vector2(0, -5), 7.6, Color("dec2a3"))
			draw_rect(Rect2(center + Vector2(-8, -12), Vector2(16, 5)), Color("465568"))
			draw_line(center + Vector2(4, 6), center + Vector2(18, -8), Color("e0e4df"), 2.2)
		"elite_han_hao":
			draw_rect(Rect2(center + Vector2(-9, 3), Vector2(18, 11)), Color("574037"))
			draw_circle(center + Vector2(-2, -5), 7.3, Color("dec2a3"))
			draw_circle(center + Vector2(8, 3), 8.0, Color("2b373b"))
			draw_arc(center + Vector2(8, 3), 8.0, 0.0, TAU, 10, Color("d2b26d"), 1.5)
		_:
			draw_rect(Rect2(center + Vector2(-9, 3), Vector2(18, 11)), Color("86413b"))
			draw_circle(center + Vector2(0, -5), 7.6, Color("dec2a3"))
			draw_rect(Rect2(center + Vector2(-8, -12), Vector2(16, 5)), Color("5e6680"))
			draw_line(center + Vector2(7, 6), center + Vector2(15, -6), Color("e0e4df"), 2.6)

func _draw_move_pad(font: Font) -> void:
	var center := move_center()
	draw_circle(center, 88.0, Color(0.01, 0.02, 0.03, 0.52))
	draw_arc(center, 88.0, 0.0, TAU, 32, Color("5d7680"), 2.5)
	draw_arc(center, 64.0, 0.0, TAU, 28, Color("334c57"), 1.2)
	var knob := center + move_stick_offset
	draw_circle(knob, 25.0, Color("253740"))
	draw_arc(knob, 25.0, 0.0, TAU, 20, DRAGON_BLUE, 2.0)
	draw_string(font, center + Vector2(-24, 118), "移动", HORIZONTAL_ALIGNMENT_CENTER, 48, 14, Color("9ab5bd"))

func _draw_modal_backdrop(font: Font) -> void:
	if not modal_active:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.02, 0.03, 0.68))
	if pause_active:
		var pause_rect := _pause_panel_rect()
		_draw_panel(pause_rect, GOLD, true)
		draw_string(font, Vector2(pause_rect.get_center().x - 58.0, pause_rect.position.y + 74.0), "战斗暂停", HORIZONTAL_ALIGNMENT_LEFT, -1, 29, GOLD_BRIGHT)
		draw_string(font, Vector2(pause_rect.get_center().x - 115.0, pause_rect.position.y + 108.0), "军势暂歇，整顿后再破阵", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("b9c5c5"))
	elif result_active:
		var result_rect := Rect2(size.x * 0.5 - 238.0, 188.0, 476.0, 330.0)
		_draw_panel(result_rect, GOLD if result_victory else HEALTH_RED, true)
		var is_boss_trial := director != null and director.is_boss_trial()
		var title := "名将试炼完成" if is_boss_trial and result_victory else ("名将试炼失败" if is_boss_trial else ("长坂坡突围成功" if result_victory else "长坂坡突围失败"))
		var title_color := GOLD_BRIGHT if result_victory else Color("ffaaa0")
		draw_string(font, Vector2(result_rect.get_center().x - 128, result_rect.position.y + 76), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, title_color)
		draw_string(font, Vector2(result_rect.position.x + 52, result_rect.position.y + 130), result_message, HORIZONTAL_ALIGNMENT_CENTER, result_rect.size.x - 104, 20, Color("e5e8e4"))
		draw_string(font, Vector2(result_rect.position.x + 110, result_rect.position.y + 182), "整军再战，夺路而出", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("a8b8bd"))
		draw_string(font, Vector2(result_rect.position.x + 145, result_rect.position.y + 212), "本局军功  %d" % run_gold, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, GOLD_BRIGHT)
	else:
		var upgrade_rect := Rect2(size.x * 0.5 - 390.0, 112.0, 780.0, 472.0)
		_draw_panel(upgrade_rect, GOLD, true)
		draw_string(font, Vector2(size.x * 0.5 - 56, 162), "临阵抉择", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, GOLD_BRIGHT)
		draw_string(font, Vector2(size.x * 0.5 - 128, 188), "选择一项强化，重整枪势", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("b9c5c5"))

func _pause_panel_rect() -> Rect2:
	return Rect2(size.x * 0.5 - 236.0, size.y * 0.5 - 176.0, 472.0, 324.0)

func _draw_panel(rect: Rect2, accent: Color, emphasize: bool = false) -> void:
	var border_width := 2.5 if emphasize else 1.5
	draw_rect(rect, _alpha(PANEL_FILL, 0.94))
	draw_rect(rect.grow(-4.0), _alpha(PANEL_INNER, 0.82))
	draw_rect(rect, accent, false, border_width)
	draw_line(rect.position + Vector2(8, 8), rect.position + Vector2(34, 8), GOLD, 1.0)
	draw_line(rect.position + Vector2(8, 8), rect.position + Vector2(8, 26), GOLD, 1.0)
	draw_line(rect.end - Vector2(8, 8), rect.end - Vector2(34, 8), GOLD, 1.0)
	draw_line(rect.end - Vector2(8, 8), rect.end - Vector2(8, 26), GOLD, 1.0)

func _draw_bar(rect: Rect2, ratio: float, fill: Color, label: String, font: Font) -> void:
	draw_rect(rect, Color("080d11"))
	draw_rect(Rect2(rect.position + Vector2(1, 1), Vector2((rect.size.x - 2) * clampf(ratio, 0.0, 1.0), rect.size.y - 2)), fill)
	draw_rect(rect, Color("9d8456"), false, 1.0)
	draw_string(font, rect.position + Vector2(8, rect.size.y - 1), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("f5ead0"))

func _draw_hero_badge(texture: Texture2D, rect: Rect2) -> void:
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var source_size := minf(texture_size.x, texture_size.y)
	var source_rect := Rect2(Vector2((texture_size.x - source_size) * 0.5, 0.0), Vector2(source_size, source_size))
	draw_texture_rect_region(texture, rect, source_rect)

func _draw_skill_button(center: Vector2, radius: float, title: String, subtitle: String, accent: Color, enabled: bool, font: Font) -> void:
	var pulse := 0.70 + 0.30 * (sin(ui_time * 6.0) + 1.0) * 0.5 if enabled else 0.65
	var subtitle_width := clampf(maxf(40.0, float(subtitle.length()) * 7.0 + 8.0), 40.0, radius * 2.1)
	draw_circle(center, radius + 7.0, Color(0.01, 0.02, 0.03, 0.72))
	draw_circle(center, radius, Color("142027"))
	draw_arc(center, radius, 0.0, TAU, 32, accent, 3.0)
	draw_arc(center, radius - 8.0, 0.2, TAU - 0.2, 28, _alpha(accent, pulse), 1.0)
	draw_line(center + Vector2(-radius * 0.45, 0), center + Vector2(radius * 0.45, 0), _alpha(accent, 0.45), 2.0)
	draw_line(center + Vector2(0, -radius * 0.32), center + Vector2(0, radius * 0.32), _alpha(accent, 0.45), 2.0)
	draw_string(font, center + Vector2(-22, -5), title, HORIZONTAL_ALIGNMENT_CENTER, 44, 18, accent.lightened(0.18))
	draw_string(font, center + Vector2(-subtitle_width * 0.5, 18), subtitle, HORIZONTAL_ALIGNMENT_CENTER, subtitle_width, 12, Color("d1d9d5") if enabled else Color("899198"))

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
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.52)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0, 3)
	return style

func _make_upgrade_card_style(background: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := _make_box_style(background, border, border_width)
	style.content_margin_left = 18.0
	style.content_margin_top = 20.0
	style.content_margin_right = 18.0
	style.content_margin_bottom = 18.0
	return style

func _ultimate_cost() -> int:
	return int(player.ultimate_cost()) if player != null else 40

func _alpha(color: Color, opacity: float) -> Color:
	return Color(color.r, color.g, color.b, opacity)
