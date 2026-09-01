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
const COMBO_TIMEOUT := 5.0
const COMBO_POP_DURATION := 0.18
const COMBO_FADE_DURATION := 0.28
const NAMED_ELITE_ROW_HEIGHT := 76.0
const NAMED_BOSS_ROW_HEIGHT := 86.0
const NAMED_ROW_GAP := 5.0
const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")
const GUAN_YU_HUD_Q_TEXTURE: Texture2D = preload("res://assets/art/characters/guan_yu/sprites/idle_right/guan-yu-idle-01.png")
const ZHANG_FEI_HUD_Q_TEXTURE: Texture2D = preload("res://assets/art/characters/zhang_fei/sprites/idle_right/zhang-fei-idle-01.png")
const ZHAO_YUN_HUD_Q_TEXTURE: Texture2D = preload("res://assets/art/characters/zhao_yun/sprites/idle_right/zhaoyun-idle-right-01.png")
const ATTACK_BUTTON_TEXTURE: Texture2D = preload("res://assets/art/ui/attack_button.png")
const ATTACK_BUTTON_SOURCE_RECT := Rect2(181.0, 178.0, 690.0, 667.0)
# The named dual-bar source contains baked-in fills. Reuse the clean single-bar
# frame twice so health and stance remain entirely runtime-driven.
const ENEMY_BAR_FRAME_TEXTURE: Texture2D = preload("res://assets/art/ui/guofeng/hud_bar_frame_2x.png")

signal upgrade_selected(upgrade_id: String)
signal upgrade_refresh_requested()
signal revive_requested()
signal revive_declined()
signal result_reward_requested()
signal restart_requested()
signal pause_requested()
signal resume_requested()
signal home_requested()
signal retreat_requested()

var player: HeroActor
var boss: BossActor
var director: RunDirector
var elites: Array[EliteActor] = []
var elite_status_order: Array[int] = []
var elite_order_refresh_remaining := 0.0
var tianji: TianjiSystem
var message := ""
var message_time := 0.0
var upgrade_buttons: Array[Button] = []
var upgrade_refresh_button: Button
var upgrade_refreshes_remaining := 2
var upgrade_ad_refreshes_remaining := 3
var upgrade_option_count := 0
var upgrade_selection_limit := 1
var upgrade_selection_count := 0
var modal_active := false
var ui_time := 0.0
var ultimate_denied_time := 0.0
var result_active := false
var result_victory := false
var result_message := ""
var result_stats: Dictionary = {}
var restart_button: Button
var result_home_button: Button
var result_reward_button: Button
var revive_watch_button: Button
var revive_skip_button: Button
var revive_prompt_active := false
var pause_active := false
var pause_buttons: Array[Button] = []
var retreat_confirm_active := false
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
	elite_status_order.clear()
	elite_order_refresh_remaining = 0.0
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
	elite_status_order.clear()
	elite_order_refresh_remaining = 0.0
	queue_redraw()

func set_named_target_indicators(targets: Array[Dictionary]) -> void:
	offscreen_named_targets = targets
	queue_redraw()

func _process(delta: float) -> void:
	ui_time += delta
	elite_order_refresh_remaining = maxf(0.0, elite_order_refresh_remaining - delta)
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

func guard_center() -> Vector2:
	return Vector2(size.x - 244.0, size.y - 252.0)

func is_guard_hit(at: Vector2) -> bool:
	return at.distance_to(guard_center()) <= 58.0

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

func set_upgrade_ad_refreshes_remaining(value: int) -> void:
	upgrade_ad_refreshes_remaining = maxi(0, value)
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
	retreat_confirm_active = false
	_rebuild_pause_buttons()
	queue_redraw()

func hide_pause() -> void:
	if not pause_active:
		return
	pause_active = false
	modal_active = false
	retreat_confirm_active = false
	for button in pause_buttons:
		button.queue_free()
	pause_buttons.clear()
	queue_redraw()

func show_upgrades(options: Array[String], upgrade_system: UpgradeSystem, selection_limit: int = 1) -> void:
	modal_active = true
	upgrade_option_count = options.size()
	upgrade_selection_limit = clampi(selection_limit, 1, maxi(1, options.size()))
	upgrade_selection_count = 0
	_clear_upgrade_controls()
	for index in range(options.size()):
		var button := Button.new()
		button.text = ""
		button.size = Vector2(_upgrade_card_width(options.size()), 300.0)
		button.set_meta("upgrade_id", options[index])
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

func show_revive_prompt() -> void:
	if result_active or revive_prompt_active:
		return
	revive_prompt_active = true
	modal_active = true
	revive_watch_button = _create_modal_action_button("观看广告复活", _on_revive_watch_button_pressed, Vector2(240.0, 52.0), GOLD)
	revive_skip_button = _create_modal_action_button("放弃复活并结算", _on_revive_skip_button_pressed, Vector2(240.0, 52.0), Color("7b6644"))
	_layout_revive_buttons()
	queue_redraw()

func hide_revive_prompt() -> void:
	if not revive_prompt_active:
		return
	revive_prompt_active = false
	modal_active = false
	for button in [revive_watch_button, revive_skip_button]:
		if is_instance_valid(button):
			button.queue_free()
	revive_watch_button = null
	revive_skip_button = null
	queue_redraw()

func set_result_rewarded(total_merit: int) -> void:
	result_stats["military_merit"] = total_merit
	result_stats["rewarded_double_claimed"] = true
	if result_reward_button != null:
		result_reward_button.disabled = true
		result_reward_button.text = "已领取双倍军功"
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

func show_result(victory: bool, value: String, stats: Dictionary = {}) -> void:
	if result_active:
		return
	result_active = true
	result_victory = victory
	result_message = value
	result_stats = stats.duplicate(true)
	pause_active = false
	retreat_confirm_active = false
	for button in pause_buttons:
		button.queue_free()
	pause_buttons.clear()
	modal_active = true
	restart_button = Button.new()
	restart_button.text = "重新开始"
	restart_button.size = Vector2(174.0, 52.0)
	restart_button.add_theme_font_size_override("font_size", 21)
	restart_button.add_theme_color_override("font_color", Color("fff0c7"))
	restart_button.add_theme_color_override("font_hover_color", Color.WHITE)
	restart_button.add_theme_stylebox_override("normal", _make_box_style(Color("28332f"), GOLD, 2))
	restart_button.add_theme_stylebox_override("hover", _make_box_style(Color("304039"), GOLD_BRIGHT, 3))
	restart_button.add_theme_stylebox_override("pressed", _make_box_style(Color("4a3b24"), GOLD_BRIGHT, 3))
	restart_button.pressed.connect(_on_restart_button_pressed)
	add_child(restart_button)
	result_home_button = Button.new()
	result_home_button.text = "返回首页"
	result_home_button.size = Vector2(174.0, 52.0)
	result_home_button.add_theme_font_size_override("font_size", 21)
	result_home_button.add_theme_color_override("font_color", Color("fff0c7"))
	result_home_button.add_theme_color_override("font_hover_color", Color.WHITE)
	result_home_button.add_theme_stylebox_override("normal", _make_box_style(PANEL_FILL, GOLD, 2))
	result_home_button.add_theme_stylebox_override("hover", _make_box_style(Color("22323a"), GOLD_BRIGHT, 3))
	result_home_button.add_theme_stylebox_override("pressed", _make_box_style(Color("4a3b24"), GOLD_BRIGHT, 3))
	result_home_button.pressed.connect(_on_home_button_pressed)
	add_child(result_home_button)
	if int(result_stats.get("military_merit", 0)) > 0:
		result_reward_button = _create_modal_action_button("观看广告 · 军功翻倍", _on_result_reward_button_pressed, Vector2(230.0, 46.0), GOLD)
	_layout_restart_button()
	queue_redraw()

func _on_upgrade_button_pressed(upgrade_id: String) -> void:
	upgrade_selection_count += 1
	for button in upgrade_buttons.duplicate():
		if str(button.get_meta("upgrade_id", "")) != upgrade_id:
			continue
		upgrade_buttons.erase(button)
		button.queue_free()
		break
	if upgrade_selection_count >= upgrade_selection_limit:
		_clear_upgrade_controls()
		modal_active = false
	else:
		_upgrade_refresh_button_sync()
		_layout_upgrade_buttons()
	upgrade_selected.emit(upgrade_id)
	queue_redraw()

func _on_upgrade_refresh_button_pressed() -> void:
	if upgrade_refreshes_remaining <= 0 and upgrade_ad_refreshes_remaining <= 0:
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
	upgrade_refresh_button.text = "刷新  %d / 2" % upgrade_refreshes_remaining if upgrade_refreshes_remaining > 0 else "看广告刷新  %d / 3" % upgrade_ad_refreshes_remaining
	upgrade_refresh_button.disabled = (upgrade_refreshes_remaining <= 0 and upgrade_ad_refreshes_remaining <= 0) or upgrade_selection_count > 0 or AdService.is_showing_rewarded_video()

func _clear_upgrade_controls() -> void:
	for button in upgrade_buttons:
		button.queue_free()
	upgrade_buttons.clear()
	if upgrade_refresh_button != null:
		upgrade_refresh_button.queue_free()
		upgrade_refresh_button = null

func _create_modal_action_button(label: String, callback: Callable, button_size: Vector2, border: Color) -> Button:
	var button := Button.new()
	button.text = label
	button.size = button_size
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color("fff0c7"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _make_box_style(PANEL_FILL, border, 2))
	button.add_theme_stylebox_override("hover", _make_box_style(Color("22323a"), GOLD_BRIGHT, 3))
	button.add_theme_stylebox_override("pressed", _make_box_style(Color("4a3b24"), GOLD_BRIGHT, 3))
	button.pressed.connect(callback)
	add_child(button)
	return button

func _on_revive_watch_button_pressed() -> void:
	if AdService.is_showing_rewarded_video():
		return
	revive_requested.emit()

func _on_revive_skip_button_pressed() -> void:
	revive_declined.emit()

func _on_result_reward_button_pressed() -> void:
	if result_reward_button == null or result_reward_button.disabled or AdService.is_showing_rewarded_video():
		return
	result_reward_requested.emit()

func _on_restart_button_pressed() -> void:
	restart_requested.emit()

func _on_resume_button_pressed() -> void:
	resume_requested.emit()

func _on_pause_restart_button_pressed() -> void:
	restart_requested.emit()

func _on_home_button_pressed() -> void:
	home_requested.emit()

func _on_retreat_button_pressed() -> void:
	if not pause_active:
		return
	retreat_confirm_active = true
	_rebuild_pause_buttons()
	queue_redraw()

func _on_retreat_confirm_button_pressed() -> void:
	retreat_requested.emit()

func _on_retreat_cancel_button_pressed() -> void:
	resume_requested.emit()

func _rebuild_pause_buttons() -> void:
	for button in pause_buttons:
		button.queue_free()
	pause_buttons.clear()
	if retreat_confirm_active:
		_create_pause_button("确认收兵", _on_retreat_confirm_button_pressed)
		_create_pause_button("继续战斗", _on_retreat_cancel_button_pressed)
	else:
		_create_pause_button("继续", _on_resume_button_pressed)
		_create_pause_button("重新开始", _on_pause_restart_button_pressed)
		_create_pause_button("鸣金收兵", _on_retreat_button_pressed)
	_layout_pause_buttons()

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
	_layout_revive_buttons()
	queue_redraw()

func _layout_upgrade_buttons() -> void:
	if upgrade_buttons.is_empty():
		return
	var gap := 16.0
	var card_width := _upgrade_card_width(upgrade_option_count if upgrade_option_count > 0 else upgrade_buttons.size())
	var total_width := upgrade_buttons.size() * card_width + (upgrade_buttons.size() - 1) * gap
	var start_x := size.x * 0.5 - total_width * 0.5
	for index in range(upgrade_buttons.size()):
		upgrade_buttons[index].size.x = card_width
		upgrade_buttons[index].position = Vector2(start_x + index * (card_width + gap), size.y * 0.5 - 142.0)
	_layout_upgrade_refresh_button()

func _upgrade_card_width(card_count: int) -> float:
	var count := maxi(1, card_count)
	var gap := 16.0
	return minf(216.0, maxf(112.0, (size.x - 72.0 - float(count - 1) * gap) / float(count)))

func _layout_upgrade_refresh_button() -> void:
	if upgrade_refresh_button == null:
		return
	var card_y := size.y * 0.5 - 142.0
	upgrade_refresh_button.position = Vector2(size.x * 0.5 - upgrade_refresh_button.size.x * 0.5, card_y + 312.0)

func _layout_restart_button() -> void:
	if restart_button == null:
		return
	if result_home_button == null:
		var single_result_rect := _result_panel_rect()
		restart_button.position = Vector2(single_result_rect.get_center().x - restart_button.size.x * 0.5, single_result_rect.end.y - restart_button.size.y - 22.0)
		return
	var gap := 18.0
	var result_buttons: Array[Button] = [restart_button, result_home_button]
	var total_width := 0.0
	for button in result_buttons:
		total_width += button.size.x
	total_width += gap * float(result_buttons.size() - 1)
	var start_x := size.x * 0.5 - total_width * 0.5
	var button_y := _result_panel_rect().end.y - restart_button.size.y - 22.0
	var cursor_x := start_x
	for button in result_buttons:
		button.position = Vector2(cursor_x, button_y)
		cursor_x += button.size.x + gap
	if result_reward_button != null:
		result_reward_button.position = Vector2(size.x * 0.5 - result_reward_button.size.x * 0.5, button_y - result_reward_button.size.y - 10.0)

func _layout_revive_buttons() -> void:
	if not revive_prompt_active or revive_watch_button == null or revive_skip_button == null:
		return
	var panel := _pause_panel_rect()
	var gap := 12.0
	var total_height := revive_watch_button.size.y + revive_skip_button.size.y + gap
	var start_y := panel.end.y - 28.0 - total_height
	revive_watch_button.position = Vector2(panel.get_center().x - revive_watch_button.size.x * 0.5, start_y)
	revive_skip_button.position = Vector2(panel.get_center().x - revive_skip_button.size.x * 0.5, start_y + revive_watch_button.size.y + gap)

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
	_draw_low_health_warning()

func _draw_low_health_warning() -> void:
	if player == null or player.health_component == null:
		return
	if modal_active or result_active:
		return
	var current_health := player.health_component.current
	if current_health <= 0.0 or current_health >= 40.0:
		return
	var pulse := 0.5 + 0.5 * sin(ui_time * TAU * 1.7)
	var health_factor := clampf((40.0 - current_health) / 20.0, 0.0, 1.0)
	var strength := lerpf(0.24, 0.44, health_factor) * lerpf(0.82, 1.0, pulse)
	var band_count := 16
	var band_size := 11.0
	var edge_color := Color("83131d").lerp(Color("ff858a"), pulse)
	for index in range(band_count):
		var falloff := 1.0 - float(index) / float(band_count)
		var gradient := float(index) / float(maxi(1, band_count - 1))
		var color := edge_color
		color.a = strength * lerpf(0.92, 0.20, gradient) * falloff
		var inset := float(index) * band_size
		var horizontal_width := size.x - inset * 2.0
		var vertical_height := size.y - inset * 2.0 - band_size * 2.0
		if horizontal_width > 0.0:
			draw_rect(Rect2(inset, inset, horizontal_width, band_size), color)
			draw_rect(Rect2(inset, size.y - inset - band_size, horizontal_width, band_size), color)
		if vertical_height > 0.0:
			draw_rect(Rect2(inset, inset + band_size, band_size, vertical_height), color)
			draw_rect(Rect2(size.x - inset - band_size, inset + band_size, band_size, vertical_height), color)

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
	var player_panel := Rect2(16, 14, 388, 184)
	_draw_panel(player_panel, DRAGON_BLUE)
	if player != null:
		var content_rect := _panel_content_rect(player_panel, Vector2(14.0, 10.0))
		var hero_name := HERO_CATALOG.hud_name_for(player.hero_id)
		var hero_marker := hero_name.left(1)
		var badge_rect := Rect2(content_rect.position + Vector2(1.0, 2.0), Vector2(46.0, 46.0))
		draw_rect(badge_rect, Color("0b1519"))
		if not _draw_hero_q_badge(player.hero_id, badge_rect):
			if hero_portrait != null:
				_draw_hero_badge(hero_portrait, badge_rect)
			else:
				draw_circle(badge_rect.get_center(), 21.0, Color("0d1318"))
				draw_string(font, badge_rect.position + Vector2(10.0, 28.0), hero_marker, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, GOLD_BRIGHT)
		draw_rect(badge_rect, GOLD, false, 2.0)
		var text_origin := content_rect.position + Vector2(56.0, 0.0)
		var hero_text_width := content_rect.end.x - text_origin.x - 2.0
		var level_label := "Lv.%d" % director.level if director != null else "Lv.1"
		var merit_label := "军功 %d" % run_gold
		var name_font_size := 17
		var level_font_size := 16
		var merit_font_size := 13
		var level_width := font.get_string_size(level_label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, level_font_size).x
		var merit_width := font.get_string_size(merit_label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, merit_font_size).x
		var name_level_gap := 16.0
		var level_merit_gap := 14.0
		var name_width := maxf(1.0, hero_text_width - level_width - merit_width - name_level_gap - level_merit_gap)
		var displayed_name := _truncate_hud_text(hero_name, font, name_font_size, name_width)
		draw_string(font, text_origin + Vector2(0.0, 15.0), displayed_name, HORIZONTAL_ALIGNMENT_LEFT, name_width, name_font_size, Color("f1e1bd"))
		var displayed_name_width := font.get_string_size(displayed_name, HORIZONTAL_ALIGNMENT_LEFT, -1.0, name_font_size).x
		var level_origin_x := displayed_name_width + name_level_gap
		draw_string(font, text_origin + Vector2(level_origin_x, 15.0), level_label, HORIZONTAL_ALIGNMENT_LEFT, level_width, level_font_size, GOLD_BRIGHT)
		draw_string(font, text_origin + Vector2(level_origin_x + level_width + level_merit_gap, 15.0), merit_label, HORIZONTAL_ALIGNMENT_LEFT, merit_width, merit_font_size, GOLD_BRIGHT)
		var health_ratio := player.health_component.current / maxf(1.0, player.health_component.maximum)
		var main_bar_width := maxf(196.0, content_rect.size.x - 56.0)
		_draw_bar(Rect2(text_origin + Vector2(0.0, 31.0), Vector2(main_bar_width, 16.0)), health_ratio, HEALTH_RED, "生命  %d / %d" % [player.health_component.current, player.health_component.maximum], font)
		var ultimate_ratio := player.ultimate_energy / 100.0
		var ultimate_ready := player.is_ultimate_ready()
		var energy_color := GOLD if ultimate_ready else DRAGON_BLUE
		_draw_bar(Rect2(text_origin + Vector2(0.0, 52.0), Vector2(main_bar_width, 16.0)), ultimate_ratio, energy_color, "无双  %d / 100" % int(player.ultimate_energy), font)
		if director != null:
			_draw_bar(Rect2(text_origin + Vector2(0.0, 73.0), Vector2(188.0, 13.0)), director.progress(), GOLD, "经验  %d / %d" % [director.experience, director.next_level_experience], font)
		var attribute_rect := Rect2(content_rect.position + Vector2(0.0, 94.0), Vector2(content_rect.size.x, 24.0))
		_draw_hero_attribute_rack(font, attribute_rect)
		var status_rect := Rect2(content_rect.position + Vector2(0.0, 123.0), Vector2(content_rect.size.x, 28.0))
		_draw_hero_status_rack(font, status_rect)
	if director != null:
		var stage_rect := Rect2(size.x * 0.5 - 184.0, 14, 368, 40)
		_draw_panel(stage_rect, GOLD)
		var stage_content := _panel_content_rect(stage_rect, Vector2(14.0, 7.0))
		var stage_text := message if message_time > 0.0 else _idle_stage_label()
		draw_string(font, stage_content.position + Vector2(0.0, 19.0), stage_text, HORIZONTAL_ALIGNMENT_LEFT, stage_content.size.x, 18, Color("f3e3bd"))
		var time_rect := Rect2(size.x - 170.0, 14, 154, 48)
		_draw_panel(time_rect, GOLD)
		var time_content := _panel_content_rect(time_rect, Vector2(14.0, 8.0))
		if director.is_boss_trial():
			draw_string(font, time_content.position + Vector2(0.0, 23.0), "试炼", HORIZONTAL_ALIGNMENT_CENTER, time_content.size.x, 23, Color("f5e5bb"))
		else:
			draw_string(font, time_content.position + Vector2(0.0, 24.0), "%02d:%02d" % [int(director.remaining_time()) / 60, int(director.remaining_time()) % 60], HORIZONTAL_ALIGNMENT_CENTER, time_content.size.x, 25, Color("f5e5bb"))
	var pause_at := pause_center()
	draw_circle(pause_at, 28.0, Color("10191f"))
	draw_arc(pause_at, 28.0, 0.0, TAU, 20, GOLD, 2.0)
	draw_line(pause_at + Vector2(-6, -9), pause_at + Vector2(-6, 9), GOLD_BRIGHT, 4.0)
	draw_line(pause_at + Vector2(6, -9), pause_at + Vector2(6, 9), GOLD_BRIGHT, 4.0)
	_draw_enemy_status_rack(font)

func _draw_hero_status_rack(font: Font, rack_rect: Rect2) -> void:
	if player == null:
		return
	var effects := player.hud_status_effects()
	draw_rect(rack_rect, Color(0.06, 0.11, 0.12, 0.26))
	draw_line(rack_rect.position, Vector2(rack_rect.end.x, rack_rect.position.y), Color("52696f", 0.66), 1.0)
	if effects.is_empty():
		return
	var content_rect := _panel_content_rect(rack_rect, Vector2(8.0, 2.0))
	var cursor_x := content_rect.position.x
	for effect in effects:
		if cursor_x + 164.0 > content_rect.end.x:
			break
		var effect_width := _draw_hero_status_effect(Vector2(cursor_x, content_rect.position.y - 2.0), effect, font)
		cursor_x += effect_width + 8.0
		if cursor_x >= content_rect.end.x - 96.0:
			break

func _draw_hero_attribute_rack(font: Font, rack_rect: Rect2) -> void:
	if player == null:
		return
	draw_rect(rack_rect, Color(0.06, 0.11, 0.12, 0.32))
	draw_line(rack_rect.position, Vector2(rack_rect.end.x, rack_rect.position.y), Color("52696f", 0.66), 1.0)
	var content_rect := _panel_content_rect(rack_rect, Vector2(8.0, 3.0))
	var stats := player.current_stats()
	var attack := int(round(float(stats.get("attack", 0.0))))
	var defense := int(round(float(stats.get("defense", 0.0))))
	var move_speed := int(round(player.effective_move_speed()))
	var pierce := _hero_pierce_value(stats)
	var values := ["攻 %d" % attack, "防 %d" % defense, "速 %d" % move_speed, "穿 %d" % pierce]
	var value_width := content_rect.size.x / float(values.size())
	for index in range(values.size()):
		var item_rect := Rect2(content_rect.position + Vector2(float(index) * value_width, 0.0), Vector2(value_width, content_rect.size.y))
		if index > 0:
			draw_line(Vector2(item_rect.position.x, content_rect.position.y + 1.0), Vector2(item_rect.position.x, content_rect.end.y - 1.0), Color("59707a", 0.72), 1.0)
		draw_string(font, item_rect.position + Vector2(0.0, 14.0), str(values[index]), HORIZONTAL_ALIGNMENT_CENTER, item_rect.size.x, 14, GOLD_BRIGHT if index == 0 else Color("d7e8e3"))

func _hero_pierce_value(stats: Dictionary) -> int:
	if stats.has("basic_pierce"):
		return int(stats.get("basic_pierce", 0))
	return maxi(0, 12 + int(player.get("projectile_pierce_bonus")))

func _draw_tianji_slots(font: Font) -> void:
	if tianji == null:
		return
	var slots := tianji.hud_slots()
	if slots.is_empty():
		return
	var rack_rect := Rect2(size.x - 274.0, 74.0, 258.0, 62.0)
	_draw_panel(rack_rect, Color("82c8cb"))
	var content_rect := _panel_content_rect(rack_rect, Vector2(12.0, 8.0))
	draw_string(font, content_rect.position + Vector2(0.0, 15.0), "天机", HORIZONTAL_ALIGNMENT_LEFT, 34.0, 14, GOLD_BRIGHT)
	var slot_width := (content_rect.size.x - 36.0) / float(slots.size())
	for index in range(slots.size()):
		var slot: Dictionary = slots[index] as Dictionary
		var title := str(slot.get("title", "天机"))
		var icon := str(slot.get("icon", "天"))
		var rank := int(slot.get("rank", 1))
		var accent: Color = slot.get("color", DRAGON_BLUE)
		var cooldown := maxf(0.1, float(slot.get("cooldown", 1.0)))
		var cooldown_remaining := maxf(0.0, float(slot.get("cooldown_remaining", 0.0)))
		var windup_remaining := maxf(0.0, float(slot.get("windup_remaining", 0.0)))
		var active_remaining := maxf(0.0, float(slot.get("active_remaining", 0.0)))
		var active_duration := maxf(0.1, float(slot.get("active_duration", 1.0)))
		var origin := content_rect.position + Vector2(36.0 + float(index) * slot_width, 0.0)
		var icon_center := origin + Vector2(13.0, 13.0)
		var ready := cooldown_remaining <= 0.0 and windup_remaining <= 0.0 and active_remaining <= 0.0
		var ratio := 1.0 - cooldown_remaining / cooldown
		if windup_remaining > 0.0:
			ratio = 0.68
		elif active_remaining > 0.0:
			ratio = active_remaining / active_duration
		draw_circle(icon_center, 12.0, Color("101c22"))
		draw_arc(icon_center, 12.0, -PI * 0.5, -PI * 0.5 + TAU * clampf(ratio, 0.0, 1.0), 16, accent, 2.4)
		draw_string(font, icon_center + Vector2(-8.0, 5.0), icon, HORIZONTAL_ALIGNMENT_CENTER, 16.0, 13, accent.lightened(0.24))
		draw_string(font, origin + Vector2(30.0, 12.0), title, HORIZONTAL_ALIGNMENT_LEFT, slot_width - 34.0, 12, Color("d9efeb"))
		var status := "演算" if windup_remaining > 0.0 else ("施放" if active_remaining > 0.0 else ("就绪" if ready else "%.1fs" % cooldown_remaining))
		draw_string(font, origin + Vector2(30.0, 29.0), "%s  Lv.%d" % [status, rank], HORIZONTAL_ALIGNMENT_LEFT, slot_width - 34.0, 11, accent if ready else Color("a8bab9"))

func _draw_hero_status_effect(origin: Vector2, effect: Dictionary, font: Font) -> float:
	var accent: Color = effect.get("color", DRAGON_BLUE)
	var label := str(effect.get("label", "状态"))
	var icon := str(effect.get("icon", "·"))
	var stacks := maxi(0, int(effect.get("stacks", 0)))
	var stack_text := str(effect.get("stack_text", ""))
	var timed := bool(effect.get("timed", true))
	var remaining := maxf(0.0, float(effect.get("remaining", 0.0)))
	var duration := maxf(0.1, float(effect.get("duration", 1.0)))
	var width := 164.0
	var icon_center := origin + Vector2(12.0, 14.0)
	draw_circle(icon_center, 10.0, accent.darkened(0.46))
	draw_arc(icon_center, 10.0, 0.0, TAU, 12, accent.lightened(0.18), 1.2)
	draw_string(font, icon_center + Vector2(-8.0, 6.0), icon, HORIZONTAL_ALIGNMENT_CENTER, 16.0, 13, Color("e8f7ff"))
	draw_string(font, origin + Vector2(27.0, 18.0), label, HORIZONTAL_ALIGNMENT_LEFT, 44.0, 13, Color("d8eff7"))
	draw_string(font, origin + Vector2(73.0, 18.0), stack_text if not stack_text.is_empty() else "x%d" % stacks, HORIZONTAL_ALIGNMENT_LEFT, 84.0, 13, accent.lightened(0.20))
	if timed:
		var timer_start := origin + Vector2(108.0, 20.0)
		var timer_end := origin + Vector2(158.0, 20.0)
		var timer_ratio := clampf(remaining / duration, 0.0, 1.0)
		draw_string(font, origin + Vector2(108.0, 14.0), "%.1fs" % remaining, HORIZONTAL_ALIGNMENT_LEFT, 50.0, 10, accent.lightened(0.20))
		draw_line(timer_start, timer_end, Color("49616b"), 2.0)
		draw_line(timer_start, timer_start.lerp(timer_end, timer_ratio), accent, 3.0)
	return width

func _battle_mode_label() -> String:
	if director == null:
		return "剧情战役"
	if director.is_boss_trial():
		return "名将斗阵"
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
	if player != null:
		active_elites = _ordered_active_elites(active_elites)
	var has_boss := boss != null and boss.active
	if not has_boss and active_elites.is_empty():
		return
	var rack_width := clampf(size.x * 0.52, 500.0, 740.0)
	var rack_x := clampf(size.x * 0.5 - rack_width * 0.5, 16.0, size.x - rack_width - 16.0)
	var elite_count := mini(3, active_elites.size())
	var hidden_elite_count := maxi(0, active_elites.size() - elite_count)
	var total_height := float(elite_count) * NAMED_ELITE_ROW_HEIGHT + float(maxi(0, elite_count - 1)) * NAMED_ROW_GAP
	if hidden_elite_count > 0:
		total_height += 20.0
	if has_boss:
		total_height += (NAMED_ROW_GAP if elite_count > 0 else 0.0) + NAMED_BOSS_ROW_HEIGHT
	var row_y := maxf(144.0, size.y - 18.0 - total_height)
	if hidden_elite_count > 0:
		draw_string(font, Vector2(rack_x, row_y + 13.0), "其余精英  ×%d" % hidden_elite_count, HORIZONTAL_ALIGNMENT_CENTER, rack_width, 12, Color("d5e8e9"))
		row_y += 20.0
	for index in range(elite_count):
		var elite := active_elites[index]
		var elite_rect := Rect2(rack_x, row_y, rack_width, NAMED_ELITE_ROW_HEIGHT)
		var elite_state := "破势" if elite.is_stance_broken() else ("反击" if elite.has_counterattack() else "")
		_draw_enemy_status_bar(elite_rect, "精英", elite.display_name(), elite.health_component.current, elite.health_component.maximum, EliteActor.HEALTH_LAYER_CAPACITY, elite.stance, EliteActor.STANCE_MAX, elite_state, elite.is_stance_broken(), font)
		row_y += NAMED_ELITE_ROW_HEIGHT + NAMED_ROW_GAP
	if has_boss:
		var boss_rect := Rect2(rack_x, row_y, rack_width, NAMED_BOSS_ROW_HEIGHT)
		var boss_state := "破势" if boss.is_stance_broken() else ("虚弱" if boss.is_vulnerable() else ("天魔降世" if boss.is_ultimate_airborne() or boss.is_ultimate_landing() else ("反击" if boss.has_counterattack() else "第 %d 阶段" % boss.phase)))
		_draw_enemy_status_bar(boss_rect, "领主", boss.display_name(), boss.health_component.current, boss.health_component.maximum, boss.health_layer_capacity(), boss.stance, BossActor.STANCE_MAX, boss_state, boss.is_stance_broken(), font)

func _sort_elites_by_player_distance(left: EliteActor, right: EliteActor) -> bool:
	return left.position.distance_squared_to(player.position) < right.position.distance_squared_to(player.position)

func _ordered_active_elites(source: Array[EliteActor]) -> Array[EliteActor]:
	var active_ids: Dictionary = {}
	for elite in source:
		active_ids[elite.get_instance_id()] = elite
	var must_refresh := elite_order_refresh_remaining <= 0.0 or elite_status_order.size() != source.size()
	if not must_refresh:
		for instance_id in elite_status_order:
			if not active_ids.has(instance_id):
				must_refresh = true
				break
	if must_refresh:
		var sorted_elites: Array[EliteActor] = []
		sorted_elites.append_array(source)
		sorted_elites.sort_custom(_sort_elites_by_player_distance)
		elite_status_order.clear()
		for elite in sorted_elites:
			elite_status_order.append(elite.get_instance_id())
		elite_order_refresh_remaining = 0.75
	var ordered: Array[EliteActor] = []
	for instance_id in elite_status_order:
		if active_ids.has(instance_id):
			ordered.append(active_ids[instance_id] as EliteActor)
	return ordered

func _draw_enemy_status_bar(rect: Rect2, _rank: String, name: String, current: float, maximum: float, layer_capacity: float, stance_current: float, stance_maximum: float, state_label: String, stance_broken: bool, font: Font) -> void:
	var is_boss := _rank == "领主"
	var horizontal_inset := 13.0
	var vertical_inset := 9.0
	var health_height := 38.0 if is_boss else 34.0
	var stance_height := 24.0 if is_boss else 21.0
	var bar_gap := 3.0
	_draw_panel(rect, GOLD if is_boss else Color("b87d3f"))
	var health_frame_rect := Rect2(rect.position + Vector2(horizontal_inset, vertical_inset), Vector2(rect.size.x - horizontal_inset * 2.0, health_height))
	var stance_frame_rect := Rect2(rect.position + Vector2(horizontal_inset, vertical_inset + health_height + bar_gap), Vector2(rect.size.x - horizontal_inset * 2.0, stance_height))
	var health_rect := _enemy_bar_interior(health_frame_rect)
	var stance_rect := _enemy_bar_interior(stance_frame_rect)
	_draw_enemy_bar_frame(health_frame_rect)
	_draw_enemy_bar_frame(stance_frame_rect)
	_draw_layered_enemy_health(health_rect, current, maximum, layer_capacity)
	_draw_enemy_stance(stance_rect, stance_current, stance_maximum, stance_broken, state_label, font)
	var remaining_layers := 0 if current <= 0.0 else maxi(1, ceili(current / maxf(1.0, layer_capacity)))
	var layer_label := "×%d" % remaining_layers
	var count_width := 58.0 if is_boss else 52.0
	var name_font_size := 18 if is_boss else 16
	var label_padding := 10.0
	var name_width := maxf(80.0, health_rect.size.x - count_width - label_padding * 3.0)
	var name_label := _truncate_hud_text("%s %s" % [_rank, name], font, name_font_size, name_width)
	var text_baseline := health_rect.get_center().y + float(name_font_size) * 0.34
	draw_string(font, health_rect.position + Vector2(label_padding, text_baseline - health_rect.position.y), name_label, HORIZONTAL_ALIGNMENT_LEFT, name_width, name_font_size, Color("fff1d8"))
	draw_string(font, Vector2(health_rect.end.x - count_width - label_padding, text_baseline), layer_label, HORIZONTAL_ALIGNMENT_RIGHT, count_width, name_font_size, Color("fff8df"))

func _enemy_bar_interior(frame_rect: Rect2) -> Rect2:
	var inset_x := maxf(5.0, frame_rect.size.y * 0.30)
	var inset_y := clampf(frame_rect.size.y * 0.16, 2.0, 4.0)
	return Rect2(
		frame_rect.position + Vector2(inset_x, inset_y),
		Vector2(maxf(2.0, frame_rect.size.x - inset_x * 2.0), maxf(2.0, frame_rect.size.y - inset_y * 2.0))
	)

func _draw_enemy_bar_frame(rect: Rect2) -> void:
	var source_size := ENEMY_BAR_FRAME_TEXTURE.get_size()
	var source_cap_width := minf(48.0, source_size.x * 0.16)
	var cap_width := minf(rect.size.x * 0.32, source_cap_width * rect.size.y / maxf(1.0, source_size.y))
	var center_width := maxf(1.0, rect.size.x - cap_width * 2.0)
	var source_center_width := maxf(1.0, source_size.x - source_cap_width * 2.0)
	draw_texture_rect_region(ENEMY_BAR_FRAME_TEXTURE, Rect2(rect.position, Vector2(cap_width, rect.size.y)), Rect2(0.0, 0.0, source_cap_width, source_size.y))
	draw_texture_rect_region(ENEMY_BAR_FRAME_TEXTURE, Rect2(rect.position + Vector2(cap_width, 0.0), Vector2(center_width, rect.size.y)), Rect2(source_cap_width, 0.0, source_center_width, source_size.y))
	draw_texture_rect_region(ENEMY_BAR_FRAME_TEXTURE, Rect2(Vector2(rect.end.x - cap_width, rect.position.y), Vector2(cap_width, rect.size.y)), Rect2(source_size.x - source_cap_width, 0.0, source_cap_width, source_size.y))

func _compact_enemy_value(value: float) -> String:
	if value >= 1000.0:
		return "%.1fk" % (value / 1000.0)
	return str(int(value))

func _truncate_hud_text(value: String, font: Font, font_size: int, max_width: float) -> String:
	if font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x <= max_width:
		return value
	var suffix := "..."
	var clipped := value
	while not clipped.is_empty() and font.get_string_size(clipped + suffix, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x > max_width:
		clipped = clipped.left(clipped.length() - 1)
	return clipped + suffix

func _draw_enemy_stance(rect: Rect2, current: float, maximum: float, broken: bool = false, state_label: String = "", font: Font = null) -> void:
	var ratio := clampf(current / maxf(1.0, maximum), 0.0, 1.0)
	draw_rect(rect, Color("07141a", 0.94))
	var inner_rect := rect.grow(-1.0)
	draw_rect(inner_rect, Color(0.08, 0.18, 0.22, 0.82))
	var fill_color := Color("e08b3c")
	if broken:
		var pulse := 0.35 + 0.65 * (sin(ui_time * 3.0) + 1.0) * 0.5
		fill_color = Color(1.0, 0.68, 0.32, 0.45 + pulse * 0.35)
		draw_rect(inner_rect, Color(0.94, 0.78, 0.38, 0.18 + pulse * 0.52), false, 1.0)
	elif state_label == "虚弱":
		var weak_pulse := 0.70 + 0.30 * (sin(ui_time * 7.0) + 1.0) * 0.5
		fill_color = Color(1.0, 0.38, 0.14, 0.72 + weak_pulse * 0.18)
		draw_rect(inner_rect, Color(1.0, 0.42, 0.16, 0.18 + weak_pulse * 0.22), false, 1.0)
	if ratio > 0.0:
		var fill_rect := Rect2(inner_rect.position, Vector2(maxf(0.0, inner_rect.size.x * ratio), inner_rect.size.y))
		draw_rect(fill_rect, fill_color.darkened(0.20))
		draw_rect(Rect2(fill_rect.position + Vector2(1.0, 1.0), Vector2(maxf(0.0, fill_rect.size.x - 2.0), maxf(1.0, fill_rect.size.y * 0.38))), Color(1.0, 0.93, 0.78, 0.20))
	draw_line(inner_rect.position + Vector2(2.0, 1.0), Vector2(inner_rect.end.x - 2.0, inner_rect.position.y + 1.0), Color(1.0, 0.89, 0.68, 0.26), 1.0)
	draw_line(inner_rect.position + Vector2(1.0, inner_rect.size.y - 1.0), Vector2(inner_rect.end.x - 1.0, inner_rect.end.y - 1.0), Color(0.0, 0.05, 0.08, 0.40), 1.0)
	if font != null and not state_label.is_empty():
		var label_size := 12 if rect.size.y >= 11.0 else 10
		var label_baseline := rect.get_center().y + float(label_size) * 0.32
		var state_color := Color("ffe5a3") if broken else (Color("ff9e5a") if state_label == "虚弱" else (Color("ffae58") if state_label == "反击" else Color("d5e8eb")))
		draw_string(font, Vector2(rect.position.x, label_baseline), state_label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, label_size, state_color)

func _draw_layered_enemy_health(rect: Rect2, current: float, maximum: float, layer_capacity: float) -> void:
	draw_rect(rect, Color("160f13"))
	var main_rect := rect.grow(-1.0)
	draw_rect(main_rect, Color(0.13, 0.07, 0.09, 0.88))
	if current <= 0.0:
		return
	var safe_capacity := maxf(1.0, layer_capacity)
	var total_layers := maxi(1, ceili(maximum / safe_capacity))
	var active_layer := maxi(1, ceili(current / safe_capacity))
	var active_capacity := _health_layer_capacity(active_layer, total_layers, maximum, safe_capacity)
	var active_value := clampf(current - float(active_layer - 1) * safe_capacity, 0.0, active_capacity)
	var active_ratio := active_value / maxf(1.0, active_capacity)
	var active_color := _health_layer_color(active_layer, total_layers)
	var fill_rect := Rect2(main_rect.position, Vector2(main_rect.size.x * active_ratio, main_rect.size.y))
	if fill_rect.size.x > 0.0:
		draw_rect(fill_rect, active_color.darkened(0.18))
		draw_rect(Rect2(fill_rect.position + Vector2(1.0, 1.0), Vector2(maxf(0.0, fill_rect.size.x - 2.0), maxf(1.0, fill_rect.size.y * 0.38))), Color(1.0, 0.95, 0.86, 0.18))
	draw_line(main_rect.position + Vector2(2.0, 1.0), Vector2(main_rect.end.x - 2.0, main_rect.position.y + 1.0), Color(1.0, 0.92, 0.78, 0.18), 1.0)
	draw_line(main_rect.position + Vector2(1.0, main_rect.size.y - 1.0), Vector2(main_rect.end.x - 1.0, main_rect.end.y - 1.0), Color(0.04, 0.0, 0.01, 0.46), 1.0)

func _health_layer_capacity(layer_number: int, total_layers: int, maximum: float, layer_capacity: float) -> float:
	if layer_number != total_layers:
		return layer_capacity
	var top_layer_capacity := fmod(maximum, layer_capacity)
	return layer_capacity if is_zero_approx(top_layer_capacity) else top_layer_capacity

func _health_layer_color(layer_number: int, _total_layers: int) -> Color:
	var palette := [Color("e24a45"), Color("e68d35"), Color("d8bf3f"), Color("68aa62"), Color("43b6b8"), Color("4b84d8"), Color("9a61c7")]
	return palette[(layer_number - 1) % palette.size()]

func _draw_skill_cluster(font: Font) -> void:
	_draw_move_pad(font)
	# The combat controls keep their established hit areas, but the visual layer
	# now reads as a compact wuxia ability wheel: weapon-first attack icon and
	# very short labels for the three ability buttons.
	_draw_skill_button(attack_center(), 64.0, "", "", DRAGON_BLUE, true, font, "attack")
	# The active skill is charge-based: a non-empty reserve stays visually usable
	# even while the next charge is recovering in the background.
	var active_enabled := player != null and player.active_charge_count > 0
	var active_color := Color("6bbd9f") if active_enabled else DISABLED
	var active_subtitle := "可用" if active_enabled else "冷却"
	if player != null:
		if player.is_active_hold_charging():
			active_subtitle = "%d%%" % int(round(player.active_hold_ratio() * 100.0))
		else:
			active_subtitle = player.active_charges_label() if active_enabled else "冷却"
		if not active_enabled:
			active_subtitle = "%.1fs" % maxf(0.0, player.active_cooldown)
	_draw_skill_button(active_center(), 50.0, "技能", active_subtitle, active_color, active_enabled, font, "active")
	var ultimate_ready := player != null and player.is_ultimate_ready()
	_draw_skill_button(ultimate_center(), 52.0, "无双", "就绪" if ultimate_ready else "充能", GOLD if ultimate_ready else DISABLED, ultimate_ready, font, "ultimate")
	var guard_active := player != null and player.is_guard_active()
	var guard_ready := player != null and player.can_use_guard()
	var guard_subtitle := "生效" if guard_active else ("%.1fs" % player.guard_cooldown_remaining if player != null and player.guard_cooldown_remaining > 0.0 else "可用")
	var guard_color := Color("85d5dc") if guard_active else (Color("6fabb6") if guard_ready else DISABLED)
	_draw_skill_button(guard_center(), 50.0, "格挡", guard_subtitle, guard_color, guard_ready or guard_active, font, "guard")
	if player != null and player.guard_cooldown_remaining > 0.0 and not guard_active:
		var cooldown_ratio := player.guard_cooldown_ratio()
		draw_arc(guard_center(), 43.0, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - cooldown_ratio), 24, Color("9bcbd0"), 3.0)
	if player != null and player.active_cooldown > 0.0:
		var active_cooldown_duration := 8.0
		var configured_duration = player.get("active_cooldown_duration")
		if configured_duration != null:
			active_cooldown_duration = maxf(0.1, float(configured_duration))
		var active_cooldown_ratio := clampf(player.active_cooldown / active_cooldown_duration, 0.0, 1.0)
		draw_arc(active_center(), 43.0, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - active_cooldown_ratio), 24, Color("8ac9b2"), 3.0)
	if player != null:
		var ultimate_ratio := clampf(player.ultimate_energy / 100.0, 0.0, 1.0)
		draw_arc(ultimate_center(), 45.0, -PI * 0.5, -PI * 0.5 + TAU * ultimate_ratio, 28, GOLD if ultimate_ready else Color("5e8588"), 2.5)
	if player != null and player.supports_weapon_stance():
		var stance_is_bow := player.is_bow_stance()
		var stance_color := Color("d7ad5a") if stance_is_bow else Color("c66d52")
		_draw_skill_button(weapon_stance_center(), 38.0, "", "", stance_color, not player.is_action_locked(), font, "weapon")
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
		UITheme.draw_title_divider(self, Rect2(pause_rect.get_center().x - 118.0, pause_rect.position.y + 82.0, 236.0, 18.0))
		if retreat_confirm_active:
			draw_string(font, Vector2(pause_rect.position.x + 34.0, pause_rect.position.y + 112.0), "是否结束当前战斗并结算已获得军功？", HORIZONTAL_ALIGNMENT_LEFT, pause_rect.size.x - 68.0, 16, Color("e3d0a4"))
			draw_string(font, Vector2(pause_rect.position.x + 34.0, pause_rect.position.y + 138.0), "收兵后无法继续本局", HORIZONTAL_ALIGNMENT_LEFT, pause_rect.size.x - 68.0, 14, Color("b9c5c5"))
		else:
			draw_string(font, Vector2(pause_rect.get_center().x - 115.0, pause_rect.position.y + 108.0), "军势暂歇，整顿后再破阵", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("b9c5c5"))
	elif revive_prompt_active:
		var revive_rect := _pause_panel_rect()
		_draw_panel(revive_rect, HEALTH_RED, true)
		draw_string(font, Vector2(revive_rect.get_center().x - 104.0, revive_rect.position.y + 74.0), "力竭待援", HORIZONTAL_ALIGNMENT_LEFT, -1, 29, Color("ffaaa0"))
		UITheme.draw_title_divider(self, Rect2(revive_rect.get_center().x - 118.0, revive_rect.position.y + 82.0, 236.0, 18.0))
		draw_string(font, Vector2(revive_rect.position.x + 34.0, revive_rect.position.y + 116.0), "观看激励视频可复活并继续战斗", HORIZONTAL_ALIGNMENT_LEFT, revive_rect.size.x - 68.0, 16, Color("e3d0a4"))
		draw_string(font, Vector2(revive_rect.position.x + 34.0, revive_rect.position.y + 144.0), "每局仅可复活一次", HORIZONTAL_ALIGNMENT_LEFT, revive_rect.size.x - 68.0, 14, Color("b9c5c5"))
	elif result_active:
		var result_rect := _result_panel_rect()
		_draw_panel(result_rect, GOLD if result_victory else HEALTH_RED, true)
		var is_boss_trial := director != null and director.is_boss_trial()
		var voluntary_end := bool(result_stats.get("voluntary_end", false))
		var title := "鸣金收兵" if voluntary_end else ("名将斗阵完成" if is_boss_trial and result_victory else ("名将斗阵失败" if is_boss_trial else ("长坂坡突围成功" if result_victory else "长坂坡突围失败")))
		var title_color := GOLD_BRIGHT if result_victory or voluntary_end else Color("ffaaa0")
		var portrait_rect := _result_portrait_rect(result_rect)
		var content_width := maxf(178.0, portrait_rect.position.x - result_rect.position.x - 34.0)
		draw_string(font, result_rect.position + Vector2(30.0, 52.0), title, HORIZONTAL_ALIGNMENT_LEFT, content_width, 29, title_color)
		UITheme.draw_title_divider(self, Rect2(result_rect.position.x + 28.0, result_rect.position.y + 62.0, content_width, 16.0))
		draw_string(font, result_rect.position + Vector2(30.0, 84.0), result_message, HORIZONTAL_ALIGNMENT_LEFT, content_width, 16, Color("d7dfda"))
		_draw_result_stat(font, result_rect.position + Vector2(30.0, 132.0), "击破", "%d" % int(result_stats.get("defeated", 0)), GOLD_BRIGHT)
		_draw_result_stat(font, result_rect.position + Vector2(146.0, 132.0), "受伤", "%d" % int(round(float(result_stats.get("damage_taken", 0.0)))), Color("e99186"))
		_draw_result_stat(font, result_rect.position + Vector2(30.0, 190.0), "战时", _format_result_time(float(result_stats.get("combat_time", 0.0))), DRAGON_BLUE)
		_draw_result_stat(font, result_rect.position + Vector2(146.0, 190.0), "军功", "%d" % int(result_stats.get("military_merit", run_gold)), GOLD_BRIGHT)
		_draw_result_hero_portrait(portrait_rect)
	else:
		var choice_count := maxi(1, upgrade_option_count)
		var card_width := _upgrade_card_width(choice_count)
		var total_cards_width := float(choice_count) * card_width + float(choice_count - 1) * 16.0
		var panel_width := minf(maxf(320.0, size.x - 24.0), maxf(780.0, total_cards_width + 48.0))
		var upgrade_rect := Rect2(size.x * 0.5 - panel_width * 0.5, 112.0, panel_width, 472.0)
		_draw_panel(upgrade_rect, GOLD, true)
		draw_string(font, Vector2(upgrade_rect.position.x, 162), "临阵抉择", HORIZONTAL_ALIGNMENT_CENTER, upgrade_rect.size.x, 27, GOLD_BRIGHT)
		UITheme.draw_title_divider(self, Rect2(upgrade_rect.get_center().x - 126.0, 169.0, 252.0, 18.0))
		var choice_label := "%d选%d" % [choice_count, upgrade_selection_limit]
		if upgrade_selection_limit > 1:
			choice_label += "（已选 %d / %d）" % [upgrade_selection_count, upgrade_selection_limit]
		draw_string(font, Vector2(upgrade_rect.position.x, 188), choice_label + " · 选择强化，重整枪势", HORIZONTAL_ALIGNMENT_CENTER, upgrade_rect.size.x, 15, Color("b9c5c5"))

func _pause_panel_rect() -> Rect2:
	return Rect2(size.x * 0.5 - 236.0, size.y * 0.5 - 176.0, 472.0, 324.0)

func _result_panel_rect() -> Rect2:
	# Keep the result card close to its actual content. The portrait still
	# overlaps the right edge, so the card does not need a large empty reserve.
	var panel_width := minf(560.0, maxf(342.0, size.x - 36.0))
	var panel_height := minf(326.0, maxf(300.0, size.y - 96.0))
	return Rect2(size.x * 0.5 - panel_width * 0.5, size.y * 0.5 - panel_height * 0.5, panel_width, panel_height)

func _draw_result_stat(font: Font, origin: Vector2, label: String, value: String, accent: Color) -> void:
	draw_string(font, origin, label, HORIZONTAL_ALIGNMENT_LEFT, 92.0, 13, Color("9fb0b1"))
	draw_string(font, origin + Vector2(0.0, 23.0), value, HORIZONTAL_ALIGNMENT_LEFT, 96.0, 21, accent)

func _format_result_time(total_seconds: float) -> String:
	var seconds := maxi(0, int(round(total_seconds)))
	return "%02d:%02d" % [seconds / 60, seconds % 60]

func _result_portrait_rect(result_rect: Rect2) -> Rect2:
	if hero_portrait == null:
		return Rect2()
	var texture_size := hero_portrait.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Rect2()
	var target_width := minf(308.0, result_rect.size.x * 0.54)
	var target_height := target_width * texture_size.y / texture_size.x
	var max_height := maxf(1.0, result_rect.size.y * 1.18)
	if target_height > max_height:
		target_height = max_height
		target_width = target_height * texture_size.x / texture_size.y
	var portrait_x := result_rect.end.x - target_width * 0.72
	var portrait_y := result_rect.end.y - target_height * 0.93
	return Rect2(portrait_x, portrait_y, target_width, target_height)

func _draw_result_hero_portrait(rect: Rect2) -> void:
	if hero_portrait == null:
		return
	draw_circle(rect.get_center() + Vector2(0.0, rect.size.y * 0.12), rect.size.x * 0.46, Color(0.72, 0.53, 0.24, 0.13))
	draw_texture_rect(hero_portrait, rect, false, Color(1.0, 1.0, 1.0, 0.98))

func _draw_panel(rect: Rect2, accent: Color, emphasize: bool = false) -> void:
	UITheme.draw_panel(self, rect, accent, emphasize)

func _panel_content_rect(rect: Rect2, padding: Vector2 = Vector2(12.0, 9.0)) -> Rect2:
	return Rect2(
		rect.position + padding,
		Vector2(maxf(1.0, rect.size.x - padding.x * 2.0), maxf(1.0, rect.size.y - padding.y * 2.0))
	)

func _draw_bar(rect: Rect2, ratio: float, fill: Color, label: String, font: Font) -> void:
	var clamped_ratio := clampf(ratio, 0.0, 1.0)
	var inset := 3.0
	var inner_rect := Rect2(rect.position + Vector2(inset, inset), rect.size - Vector2(inset * 2.0, inset * 2.0))
	var fill_rect := Rect2(inner_rect.position, Vector2(inner_rect.size.x * clamped_ratio, inner_rect.size.y))
	# Clean glass treatment keeps the resource bars readable without a second ornate panel frame.
	draw_rect(rect, Color(0.02, 0.04, 0.05, 0.84))
	draw_rect(inner_rect, Color(0.10, 0.16, 0.18, 0.76))
	if fill_rect.size.x > 0.0:
		draw_rect(fill_rect, Color(fill.r, fill.g, fill.b, 0.88))
		draw_rect(Rect2(fill_rect.position + Vector2(0.0, 1.0), Vector2(fill_rect.size.x, maxf(1.0, fill_rect.size.y * 0.34))), Color(1.0, 0.96, 0.86, 0.20))
	draw_line(inner_rect.position + Vector2(1.0, 1.0), Vector2(inner_rect.end.x - 1.0, inner_rect.position.y + 1.0), Color(0.80, 0.92, 0.90, 0.25), 1.0)
	draw_line(inner_rect.position + Vector2(1.0, inner_rect.size.y - 1.0), Vector2(inner_rect.end.x - 1.0, inner_rect.end.y - 1.0), Color(0.0, 0.02, 0.03, 0.50), 1.0)
	draw_rect(rect, Color(0.58, 0.68, 0.66, 0.68), false, 1.0)
	draw_string(font, rect.position + Vector2(8, rect.size.y - 1), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("f5ead0"))

func _draw_hero_badge(texture: Texture2D, rect: Rect2) -> void:
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var source_size := minf(texture_size.x, texture_size.y)
	var source_rect := Rect2(Vector2((texture_size.x - source_size) * 0.5, 0.0), Vector2(source_size, source_size))
	draw_texture_rect_region(texture, rect, source_rect)

func _draw_hero_q_badge(hero_id: String, rect: Rect2) -> bool:
	var texture: Texture2D = null
	var source_rect := Rect2()
	match hero_id:
		"guan_yu":
			texture = GUAN_YU_HUD_Q_TEXTURE
			source_rect = Rect2(37.0, 4.0, 44.0, 44.0)
		"zhang_fei":
			texture = ZHANG_FEI_HUD_Q_TEXTURE
			source_rect = Rect2(40.0, 0.0, 48.0, 46.0)
		"zhao_yun":
			texture = ZHAO_YUN_HUD_Q_TEXTURE
			source_rect = Rect2(42.0, 19.0, 48.0, 48.0)
		_:
			return false
	if texture == null:
		return false
	draw_texture_rect_region(texture, rect, source_rect)
	return true

func _draw_skill_button(center: Vector2, radius: float, title: String, subtitle: String, accent: Color, enabled: bool, font: Font, icon_kind: String = "") -> void:
	var pulse := 0.72 + 0.28 * (sin(ui_time * 5.0) + 1.0) * 0.5 if enabled else 0.48
	var ring_color := accent if enabled else Color("4b555b")
	var plate_color := Color("17262b") if enabled else Color("141b1f")
	# Layered metal rim and inset plate make the controls legible over any map.
	draw_circle(center, radius + 9.0, Color(0.01, 0.015, 0.018, 0.78))
	draw_arc(center, radius + 7.0, 0.0, TAU, 40, Color(0.70, 0.57, 0.35, 0.28), 2.0)
	draw_circle(center, radius + 3.0, Color("30251b"))
	draw_circle(center, radius, plate_color)
	draw_arc(center, radius, 0.0, TAU, 40, ring_color, 3.0)
	draw_arc(center, radius - 7.0, -PI * 0.88, PI * 0.15, 28, _alpha(Color("f4d58d"), pulse * 0.82), 1.5)
	draw_arc(center, radius - 8.5, PI * 0.18, PI * 0.82, 18, _alpha(ring_color, 0.52), 1.0)
	if enabled:
		draw_circle(center + Vector2(-radius * 0.26, -radius * 0.30), radius * 0.33, Color(1.0, 0.93, 0.75, 0.055))
	else:
		draw_circle(center, radius - 4.0, Color(0.02, 0.03, 0.035, 0.24))
	var has_icon := icon_kind == "attack" or icon_kind == "weapon"
	if has_icon:
		_draw_skill_icon(center, radius, icon_kind, ring_color, enabled)
	if not title.is_empty():
		var title_size := 15 if radius <= 50.0 else 17
		var title_y := center.y + radius * 0.62 if has_icon else center.y + 6.0
		draw_string(font, Vector2(center.x - radius, title_y), title, HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, title_size, Color("f0ddb0") if enabled else Color("929b9d"))
	if not subtitle.is_empty() and radius >= 45.0:
		var subtitle_width := clampf(maxf(42.0, float(subtitle.length()) * 7.0 + 8.0), 42.0, radius * 1.75)
		var subtitle_y := center.y + radius * 0.84 if has_icon else center.y + 27.0
		draw_string(font, Vector2(center.x - subtitle_width * 0.5, subtitle_y), subtitle, HORIZONTAL_ALIGNMENT_CENTER, subtitle_width, 11, Color("d5e5df") if enabled else Color("7d898d"))

func _draw_skill_icon(center: Vector2, radius: float, icon_kind: String, accent: Color, enabled: bool) -> void:
	var icon_color := Color("f3dfaa") if enabled else Color("7d898d")
	var icon_shadow := Color(0.02, 0.03, 0.035, 0.82)
	var scale := clampf(radius / 58.0, 0.62, 1.15)
	match icon_kind:
		"attack":
			_draw_attack_button_icon(center, radius)
		"weapon":
			if player != null and player.is_bow_stance():
				_draw_bow_icon(center, scale * 0.72, icon_color, icon_shadow)
			else:
				_draw_sword_icon(center, scale * 0.72, icon_color, icon_shadow)

func _draw_attack_button_icon(center: Vector2, radius: float) -> void:
	if ATTACK_BUTTON_TEXTURE == null:
		return
	var icon_scale := clampf(radius / 64.0, 0.92, 1.08)
	var icon_size := Vector2(124.0, 120.0) * icon_scale
	var icon_rect := Rect2(center - icon_size * 0.5, icon_size)
	# A restrained shadow keeps the supplied ivory blade readable against the dark plate.
	draw_texture_rect_region(ATTACK_BUTTON_TEXTURE, Rect2(icon_rect.position + Vector2(2.0, 3.0), icon_rect.size), ATTACK_BUTTON_SOURCE_RECT, Color(0.01, 0.02, 0.02, 0.34))
	draw_texture_rect_region(ATTACK_BUTTON_TEXTURE, icon_rect, ATTACK_BUTTON_SOURCE_RECT, Color(1.0, 0.98, 0.90, 0.72))

func _draw_spear_icon(center: Vector2, scale: float, color: Color, shadow: Color) -> void:
	var shaft_start := center + Vector2(-24.0, 19.0) * scale
	var shaft_end := center + Vector2(23.0, -23.0) * scale
	var tip := center + Vector2(31.0, -31.0) * scale
	draw_line(shaft_start + Vector2(2.0, 2.0) * scale, shaft_end + Vector2(2.0, 2.0) * scale, shadow, 6.0 * scale)
	draw_line(shaft_start, shaft_end, color, 3.5 * scale)
	draw_colored_polygon(PackedVector2Array([tip, center + Vector2(20.0, -19.0) * scale, center + Vector2(25.0, -27.0) * scale]), color)
	draw_line(center + Vector2(-5.0, 6.0) * scale, center + Vector2(8.0, 19.0) * scale, color, 2.0 * scale)

func _draw_glaive_icon(center: Vector2, scale: float, color: Color, shadow: Color) -> void:
	var base := center + Vector2(-22.0, 22.0) * scale
	var blade_root := center + Vector2(12.0, -12.0) * scale
	draw_line(base + Vector2(2.0, 2.0) * scale, blade_root + Vector2(2.0, 2.0) * scale, shadow, 6.0 * scale)
	draw_line(base, blade_root, color, 3.5 * scale)
	draw_arc(blade_root + Vector2(7.0, -7.0) * scale, 14.0 * scale, -PI * 0.1, PI * 0.85, 16, color, 4.0 * scale)
	draw_line(blade_root + Vector2(4.0, -2.0) * scale, blade_root + Vector2(17.0, -16.0) * scale, color, 2.0 * scale)

func _draw_halberd_icon(center: Vector2, scale: float, color: Color, shadow: Color) -> void:
	_draw_spear_icon(center + Vector2(1.0, 0.0) * scale, scale, color, shadow)
	draw_line(center + Vector2(13.0, -17.0) * scale, center + Vector2(25.0, -8.0) * scale, color, 3.0 * scale)
	draw_line(center + Vector2(13.0, -17.0) * scale, center + Vector2(28.0, -22.0) * scale, color, 2.0 * scale)

func _draw_bow_icon(center: Vector2, scale: float, color: Color, shadow: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(-18.0, -23.0) * scale,
		center + Vector2(-30.0, -8.0) * scale,
		center + Vector2(-25.0, 13.0) * scale,
		center + Vector2(-12.0, 25.0) * scale,
	])
	draw_polyline(points, shadow, 6.0 * scale)
	draw_polyline(points, color, 3.0 * scale)
	draw_line(center + Vector2(-18.0, -23.0) * scale, center + Vector2(22.0, 21.0) * scale, color, 1.8 * scale)
	draw_line(center + Vector2(-2.0, 0.0) * scale, center + Vector2(27.0, -6.0) * scale, shadow, 5.0 * scale)
	draw_line(center + Vector2(-2.0, 0.0) * scale, center + Vector2(27.0, -6.0) * scale, color, 2.4 * scale)

func _draw_sword_icon(center: Vector2, scale: float, color: Color, shadow: Color) -> void:
	draw_line(center + Vector2(-20.0, 21.0) * scale, center + Vector2(24.0, -23.0) * scale, shadow, 7.0 * scale)
	draw_line(center + Vector2(-20.0, 21.0) * scale, center + Vector2(24.0, -23.0) * scale, color, 3.5 * scale)
	draw_line(center + Vector2(-22.0, 8.0) * scale, center + Vector2(-8.0, 22.0) * scale, color, 3.0 * scale)

func _draw_guard_icon(center: Vector2, scale: float, color: Color, shadow: Color) -> void:
	var shield := PackedVector2Array([
		center + Vector2(0.0, -27.0) * scale,
		center + Vector2(22.0, -15.0) * scale,
		center + Vector2(17.0, 12.0) * scale,
		center + Vector2(0.0, 27.0) * scale,
		center + Vector2(-17.0, 12.0) * scale,
		center + Vector2(-22.0, -15.0) * scale,
	])
	draw_colored_polygon(shield, shadow)
	draw_polyline(shield, color, 3.0 * scale)
	draw_arc(center + Vector2(0.0, 2.0) * scale, 23.0 * scale, PI * 1.08, PI * 1.92, 18, color, 3.0 * scale)

func _draw_starburst_icon(center: Vector2, scale: float, color: Color, shadow: Color) -> void:
	for index in range(8):
		var angle := TAU * float(index) / 8.0
		var direction := Vector2(cos(angle), sin(angle))
		draw_line(center + direction * 8.0 * scale, center + direction * (27.0 if index % 2 == 0 else 20.0) * scale, shadow, 5.0 * scale)
		draw_line(center + direction * 8.0 * scale, center + direction * (27.0 if index % 2 == 0 else 20.0) * scale, color, 2.4 * scale)
	draw_circle(center, 7.0 * scale, color)

func _draw_flame_icon(center: Vector2, scale: float, color: Color, shadow: Color) -> void:
	var flame := PackedVector2Array([
		center + Vector2(0.0, -29.0) * scale,
		center + Vector2(15.0, -8.0) * scale,
		center + Vector2(12.0, 20.0) * scale,
		center + Vector2(0.0, 28.0) * scale,
		center + Vector2(-17.0, 17.0) * scale,
		center + Vector2(-10.0, -4.0) * scale,
	])
	draw_colored_polygon(flame, shadow)
	draw_polyline(flame, color, 3.0 * scale)
	draw_line(center + Vector2(0.0, -16.0) * scale, center + Vector2(6.0, 9.0) * scale, color, 2.0 * scale)

func _make_box_style(background: Color, border: Color, border_width: int) -> StyleBox:
	return UITheme.box_style(background, border, border_width)

func _make_upgrade_card_style(background: Color, border: Color, border_width: int) -> StyleBox:
	return UITheme.upgrade_card_style(background, border, border_width)

func _ultimate_cost() -> int:
	return int(player.ultimate_cost()) if player != null else 40

func _alpha(color: Color, opacity: float) -> Color:
	return Color(color.r, color.g, color.b, opacity)
