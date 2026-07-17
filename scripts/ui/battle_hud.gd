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

signal upgrade_selected(upgrade_id: String)
signal restart_requested()
signal pause_requested()
signal resume_requested()
signal home_requested()

var player: PlayerActor
var boss: BossActor
var director: RunDirector
var elites: Array[EliteActor] = []
var message := "长坂坡 · 单骑救主"
var message_time := 3.0
var upgrade_buttons: Array[Button] = []
var modal_active := false
var ui_time := 0.0
var ultimate_denied_time := 0.0
var result_active := false
var result_victory := false
var result_message := ""
var restart_button: Button
var pause_active := false
var pause_buttons: Array[Button] = []
var move_stick_offset := Vector2.ZERO
var run_gold := 0
var health_trails: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	_sync_viewport_layout()
	get_viewport().size_changed.connect(_sync_viewport_layout)

func configure(player_actor: PlayerActor, boss_actor: BossActor, run_director: RunDirector, elite_actors: Array[EliteActor] = []) -> void:
	player = player_actor
	boss = boss_actor
	director = run_director
	elites = elite_actors
	queue_redraw()

func set_elites(elite_actors: Array[EliteActor]) -> void:
	elites = elite_actors
	queue_redraw()

func _process(delta: float) -> void:
	ui_time += delta
	message_time = maxf(0.0, message_time - delta)
	ultimate_denied_time = maxf(0.0, ultimate_denied_time - delta)
	_update_health_trails(delta)
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
	restart_button.size = Vector2(264.0, 58.0)
	restart_button.add_theme_font_size_override("font_size", 24)
	restart_button.add_theme_color_override("font_color", Color("fff0c7"))
	restart_button.add_theme_color_override("font_hover_color", Color.WHITE)
	restart_button.add_theme_stylebox_override("normal", _make_box_style(Color("28332f"), GOLD, 2))
	restart_button.add_theme_stylebox_override("hover", _make_box_style(Color("304039"), GOLD_BRIGHT, 3))
	restart_button.add_theme_stylebox_override("pressed", _make_box_style(Color("4a3b24"), GOLD_BRIGHT, 3))
	restart_button.pressed.connect(_on_restart_button_pressed)
	add_child(restart_button)
	_layout_restart_button()
	queue_redraw()

func _on_upgrade_button_pressed(upgrade_id: String) -> void:
	for button in upgrade_buttons:
		button.queue_free()
	upgrade_buttons.clear()
	modal_active = false
	upgrade_selected.emit(upgrade_id)
	queue_redraw()

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

func _layout_restart_button() -> void:
	if restart_button != null:
		restart_button.position = Vector2(size.x * 0.5 - restart_button.size.x * 0.5, size.y * 0.5 + 72.0)

func _layout_pause_buttons() -> void:
	if pause_buttons.is_empty():
		return
	var start_y := size.y * 0.5 - 12.0
	for index in range(pause_buttons.size()):
		pause_buttons[index].position = Vector2(size.x * 0.5 - pause_buttons[index].size.x * 0.5, start_y + index * 66.0)

func _draw() -> void:
	var font := ThemeDB.fallback_font
	_draw_top_hud(font)
	_draw_skill_cluster(font)
	_draw_modal_backdrop(font)

func _draw_top_hud(font: Font) -> void:
	var player_panel := Rect2(16, 14, 372, 118)
	_draw_panel(player_panel, DRAGON_BLUE)
	if player != null:
		draw_circle(Vector2(48, 62), 22.0, Color("0d1318"))
		draw_arc(Vector2(48, 62), 22.0, 0.0, TAU, 20, GOLD, 2.0)
		draw_string(font, Vector2(36, 68), "赵", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, GOLD_BRIGHT)
		draw_string(font, Vector2(82, 35), "赵云 · 龙胆枪", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("f1e1bd"))
		var level_label := "Lv.%d  长坂坡突围" % director.level if director != null else "Lv.1  长坂坡突围"
		draw_string(font, Vector2(82, 55), level_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("9cb4bf"))
		var health_ratio := player.health_component.current / maxf(1.0, player.health_component.maximum)
		_draw_bar(Rect2(82, 62, 256, 11), health_ratio, HEALTH_RED, "生命  %d / %d" % [player.health_component.current, player.health_component.maximum], font)
		var ultimate_ratio := player.ultimate_energy / 100.0
		var ultimate_ready := player.is_ultimate_ready()
		var energy_color := GOLD if ultimate_ready else DRAGON_BLUE
		_draw_bar(Rect2(82, 82, 256, 10), ultimate_ratio, energy_color, "无双  %d / 100" % int(player.ultimate_energy), font)
		if director != null:
			_draw_bar(Rect2(82, 102, 256, 9), director.progress(), DRAGON_BLUE, "经验  %d / %d" % [director.experience, director.next_level_experience], font)
		if ultimate_ready:
			var pulse := 0.55 + 0.45 * (sin(ui_time * 7.0) + 1.0) * 0.5
			draw_string(font, Vector2(342, 96), "可释放", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, _alpha(GOLD_BRIGHT, pulse))
		draw_string(font, Vector2(16, 124), "铜钱  %d" % run_gold, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, GOLD_BRIGHT)
	if director != null:
		var stage_rect := Rect2(size.x * 0.5 - 184.0, 14, 368, 40)
		_draw_panel(stage_rect, GOLD)
		var stage_text := message if message_time > 0.0 else "长坂坡 · 夜雪战场"
		draw_string(font, Vector2(stage_rect.position.x + 16, 40), stage_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f3e3bd"))
		var time_rect := Rect2(size.x - 170.0, 14, 154, 48)
		_draw_panel(time_rect, GOLD)
		draw_string(font, Vector2(time_rect.position.x + 22, 45), "%02d:%02d" % [int(director.remaining_time()) / 60, int(director.remaining_time()) % 60], HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("f5e5bb"))
	var pause_at := pause_center()
	draw_circle(pause_at, 28.0, Color("10191f"))
	draw_arc(pause_at, 28.0, 0.0, TAU, 20, GOLD, 2.0)
	draw_line(pause_at + Vector2(-6, -9), pause_at + Vector2(-6, 9), GOLD_BRIGHT, 4.0)
	draw_line(pause_at + Vector2(6, -9), pause_at + Vector2(6, 9), GOLD_BRIGHT, 4.0)
	_draw_enemy_status_rack(font)

func _draw_enemy_status_rack(font: Font) -> void:
	var active_elites: Array[EliteActor] = []
	for elite in elites:
		if is_instance_valid(elite) and elite.active:
			active_elites.append(elite)
	var has_boss := boss != null and boss.active
	if not has_boss and active_elites.is_empty():
		return
	var row_y := 140.0
	if has_boss:
		var boss_rect := Rect2(size.x * 0.05, row_y, size.x * 0.90, 32.0)
		_draw_enemy_status_bar(boss_rect, "敌将", boss.display_name(), boss.weapon_title(), boss.health_component.current, boss.health_component.maximum, boss.health_layer_capacity(), Color("d55345"), "第 %d 阶段" % boss.phase, "boss", font)
		row_y += 40.0
	if active_elites.size() == 1:
		var elite := active_elites[0]
		var centered_rect := Rect2(size.x * 0.20, row_y, size.x * 0.60, 23.0)
		_draw_enemy_status_bar(centered_rect, "精英", elite.display_name(), elite.weapon_title(), elite.health_component.current, elite.health_component.maximum, EliteActor.HEALTH_LAYER_CAPACITY, elite.hud_color(), "破绽" if elite.is_recovering() else "", "elite:%d" % elite.get_instance_id(), font)
		return
	for index in range(mini(4, active_elites.size())):
		var elite := active_elites[index]
		var column := index % 2
		var row := index / 2
		var elite_rect := Rect2(size.x * (0.05 + column * 0.46), row_y + row * 28.0, size.x * 0.44, 22.0)
		_draw_enemy_status_bar(elite_rect, "精英", elite.display_name(), elite.weapon_title(), elite.health_component.current, elite.health_component.maximum, EliteActor.HEALTH_LAYER_CAPACITY, elite.hud_color(), "破绽" if elite.is_recovering() else "", "elite:%d" % elite.get_instance_id(), font)

func _draw_enemy_status_bar(rect: Rect2, rank: String, name: String, weapon: String, current: float, maximum: float, layer_capacity: float, accent: Color, state_label: String, target_key: String, font: Font) -> void:
	draw_rect(rect, Color("0a0e12", 0.94))
	draw_rect(rect, accent, false, 2.0)
	var label_width := 192.0 if rank == "敌将" else 132.0
	var title_color := Color("f4d6c4") if rank == "敌将" else Color("f1dfbd")
	draw_string(font, rect.position + Vector2(10, 13), rank, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, accent.lightened(0.24))
	draw_string(font, rect.position + Vector2(49, 14), "%s · %s" % [name, weapon], HORIZONTAL_ALIGNMENT_LEFT, label_width - 54.0, 15 if rank == "敌将" else 13, title_color)
	if not state_label.is_empty():
		draw_string(font, rect.position + Vector2(label_width - 8, 14), state_label, HORIZONTAL_ALIGNMENT_RIGHT, 72, 11, GOLD_BRIGHT)
	var health_rect := Rect2(rect.position + Vector2(label_width, 8), Vector2(rect.size.x - label_width - 11, rect.size.y - 16))
	_draw_layered_enemy_health(health_rect, current, maximum, layer_capacity, accent, target_key)

func _draw_layered_enemy_health(rect: Rect2, current: float, maximum: float, layer_capacity: float, accent: Color, target_key: String) -> void:
	draw_rect(rect, Color("241518"))
	var trail := float(health_trails.get(target_key, current))
	var trail_ratio := clampf(trail / maxf(1.0, maximum), 0.0, 1.0)
	draw_rect(Rect2(rect.position + Vector2(1, 1), Vector2((rect.size.x - 2) * trail_ratio, rect.size.y - 2)), Color("6f302e"))
	if current > 0.0:
		var active_layer := maxi(1, ceili(current / maxf(1.0, layer_capacity)))
		var layer_value := fmod(current, layer_capacity)
		var top_ratio := layer_value / layer_capacity
		if is_zero_approx(layer_value):
			top_ratio = 1.0
		var visible_layers := mini(4, active_layer)
		for depth in range(visible_layers - 1, -1, -1):
			var layer_number := active_layer - depth
			var inset := float(depth) * 2.0
			var layer_rect := Rect2(rect.position + Vector2(1, 1 + inset), Vector2(rect.size.x - 2, rect.size.y - 2 - inset))
			var fill_ratio := top_ratio if depth == 0 else 1.0
			draw_rect(Rect2(layer_rect.position, Vector2(layer_rect.size.x * fill_ratio, layer_rect.size.y)), _health_layer_color(layer_number, accent))
	draw_rect(rect, Color("c99762"), false, 1.0)

func _health_layer_color(layer_number: int, accent: Color) -> Color:
	var palette := [Color("7f4d2e"), Color("b45a31"), accent, accent.lightened(0.17)]
	return palette[mini(layer_number - 1, palette.size() - 1)]

func _update_health_trails(delta: float) -> void:
	if boss != null and boss.active:
		_update_health_trail("boss", boss.health_component.current, boss.health_component.maximum, delta)
	for elite in elites:
		if is_instance_valid(elite) and elite.active:
			_update_health_trail("elite:%d" % elite.get_instance_id(), elite.health_component.current, elite.health_component.maximum, delta)

func _update_health_trail(target_key: String, current: float, maximum: float, delta: float) -> void:
	var displayed := float(health_trails.get(target_key, current))
	if current >= displayed:
		health_trails[target_key] = current
		return
	health_trails[target_key] = move_toward(displayed, current, maximum * 1.8 * delta)

func _draw_skill_cluster(font: Font) -> void:
	_draw_move_pad(font)
	_draw_skill_button(attack_center(), 64.0, "普攻", "龙胆枪", DRAGON_BLUE, true, font)
	var active_enabled := player != null and player.active_cooldown <= 0.0 and player.ultimate_time <= 0.0
	var active_color := Color("6bbd9f") if active_enabled else DISABLED
	_draw_skill_button(active_center(), 50.0, "主动", "破军", active_color, active_enabled, font)
	var ultimate_ready := player != null and player.is_ultimate_ready()
	_draw_skill_button(ultimate_center(), 52.0, "无双", "七进", GOLD if ultimate_ready else DISABLED, ultimate_ready, font)
	if player != null:
		var button_text := "消耗 %d" % _ultimate_cost() if ultimate_ready else "%d / %d" % [int(player.ultimate_energy), _ultimate_cost()]
		draw_string(font, ultimate_center() + Vector2(-30, 72), button_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GOLD_BRIGHT if ultimate_ready else Color("aab2b9"))
	if ultimate_denied_time > 0.0:
		draw_string(font, ultimate_center() + Vector2(-36, -66), "能量不足", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("ff9b7b"))
	if player != null and player.is_ultimate_ready():
		draw_string(font, Vector2(size.x * 0.5 - 100, 236), "无双已就绪 · 消耗 %d" % _ultimate_cost(), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("ffe49a"))

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
		var pause_rect := Rect2(size.x * 0.5 - 236.0, size.y * 0.5 - 176.0, 472.0, 324.0)
		_draw_panel(pause_rect, GOLD, true)
		draw_string(font, Vector2(pause_rect.get_center().x - 58.0, pause_rect.position.y + 74.0), "战斗暂停", HORIZONTAL_ALIGNMENT_LEFT, -1, 29, GOLD_BRIGHT)
		draw_string(font, Vector2(pause_rect.get_center().x - 115.0, pause_rect.position.y + 108.0), "军势暂歇，整顿后再破阵", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("b9c5c5"))
	elif result_active:
		var result_rect := Rect2(size.x * 0.5 - 238.0, 188.0, 476.0, 330.0)
		_draw_panel(result_rect, GOLD if result_victory else HEALTH_RED, true)
		var title := "长坂坡突围成功" if result_victory else "长坂坡突围失败"
		var title_color := GOLD_BRIGHT if result_victory else Color("ffaaa0")
		draw_string(font, Vector2(result_rect.get_center().x - 128, result_rect.position.y + 76), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, title_color)
		draw_string(font, Vector2(result_rect.position.x + 52, result_rect.position.y + 130), result_message, HORIZONTAL_ALIGNMENT_CENTER, result_rect.size.x - 104, 20, Color("e5e8e4"))
		draw_string(font, Vector2(result_rect.position.x + 110, result_rect.position.y + 182), "整军再战，夺路而出", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("a8b8bd"))
		draw_string(font, Vector2(result_rect.position.x + 145, result_rect.position.y + 212), "本局铜钱  %d" % run_gold, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, GOLD_BRIGHT)
	else:
		var upgrade_rect := Rect2(size.x * 0.5 - 390.0, 112.0, 780.0, 472.0)
		_draw_panel(upgrade_rect, GOLD, true)
		draw_string(font, Vector2(size.x * 0.5 - 56, 162), "军略抉择", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, GOLD_BRIGHT)
		draw_string(font, Vector2(size.x * 0.5 - 128, 188), "选择一项强化，重整枪势", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("b9c5c5"))

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

func _draw_skill_button(center: Vector2, radius: float, title: String, subtitle: String, accent: Color, enabled: bool, font: Font) -> void:
	var pulse := 0.70 + 0.30 * (sin(ui_time * 6.0) + 1.0) * 0.5 if enabled else 0.65
	draw_circle(center, radius + 7.0, Color(0.01, 0.02, 0.03, 0.72))
	draw_circle(center, radius, Color("142027"))
	draw_arc(center, radius, 0.0, TAU, 32, accent, 3.0)
	draw_arc(center, radius - 8.0, 0.2, TAU - 0.2, 28, _alpha(accent, pulse), 1.0)
	draw_line(center + Vector2(-radius * 0.45, 0), center + Vector2(radius * 0.45, 0), _alpha(accent, 0.45), 2.0)
	draw_line(center + Vector2(0, -radius * 0.32), center + Vector2(0, radius * 0.32), _alpha(accent, 0.45), 2.0)
	draw_string(font, center + Vector2(-22, -5), title, HORIZONTAL_ALIGNMENT_CENTER, 44, 18, accent.lightened(0.18))
	draw_string(font, center + Vector2(-20, 18), subtitle, HORIZONTAL_ALIGNMENT_CENTER, 40, 12, Color("d1d9d5") if enabled else Color("899198"))

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
