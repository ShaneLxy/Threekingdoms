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
const DAMAGE_EDGE_FLASH_DURATION := 0.48
const DAMAGE_EDGE_FLASH_CYCLE_DURATION := DAMAGE_EDGE_FLASH_DURATION * 0.5
const NAMED_ELITE_ROW_HEIGHT := 76.0
const NAMED_BOSS_ROW_HEIGHT := 86.0
const NAMED_ROW_GAP := 5.0
const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")
const RESULT_HERO_PORTRAITS := {
	"guan_yu": "res://assets/art/characters/hero_new/guanyu.png",
	"zhang_fei": "res://assets/art/characters/hero_new/zhangfei.png",
	"zhao_yun": "res://assets/art/characters/hero_new/zhaoyun.png",
	"ma_chao": "res://assets/art/characters/hero_new/maochao.png",
}
const MOVE_BUTTON_TEXTURE: Texture2D = preload("res://assets/art/ui/battle/moveBtn.png")
const MOVE_KNOB_TEXTURE: Texture2D = preload("res://assets/art/ui/battle/moveBtn1.png")
const ATTACK_BUTTON_TEXTURE: Texture2D = preload("res://assets/art/ui/battle/attackBtn.png")
const SKILL_BUTTON_TEXTURE: Texture2D = preload("res://assets/art/ui/battle/skillBtn.png")
const SHIELD_TEXTURE: Texture2D = preload("res://assets/art/ui/battle/shield.png")
const HERO_INFO_TEXTURE: Texture2D = preload("res://assets/art/ui/battle/heroInfo.png")
const COMBO_BRUSH_TEXTURE: Texture2D = preload("res://assets/art/ui/battle/combo_brush.png")
const COMBO_KAITI_FONT: Font = preload("res://assets/fonts/kaiti.ttf")
const BATTLE_SOUL_LOGO_TEXTURES: Dictionary = {
	"gale": preload("res://assets/art/ui/shop/zhanhun/gangfeng.png"),
	"thunder": preload("res://assets/art/ui/shop/zhanhun/leiting.png"),
	"flame": preload("res://assets/art/ui/shop/zhanhun/baoyan.png"),
	"iron": preload("res://assets/art/ui/shop/zhanhun/xuanjia.png"),
	"machine": preload("res://assets/art/battle_souls/shenji.png"),
}
# The named dual-bar source contains baked-in fills. Reuse the clean single-bar
# frame twice so health and stance remain entirely runtime-driven.
const ENEMY_BAR_FRAME_TEXTURE: Texture2D = preload("res://assets/art/ui/guofeng/hud_bar_frame_2x.png")
const UPGRADE_FREE_REFRESH_LIMIT := 5
const UPGRADE_NOTIFICATION_DURATION := 4.0
const UPGRADE_NOTIFICATION_FADE_DURATION := 0.5
const SUMMARY_SCROLL_DRAG_THRESHOLD := 10.0

signal upgrade_selected(upgrade_id: String)
signal upgrade_refresh_requested()
signal run_strategy_selected(strategy_id: String)
signal revive_requested()
signal revive_declined()
signal result_reward_requested()
signal restart_requested()
signal pause_requested()
signal resume_requested()
signal combo_setting_changed(enabled: bool)
signal damage_numbers_setting_changed(enabled: bool)
signal upgrade_selection_mode_changed(mode: String)
signal selected_upgrades_requested()
signal home_requested()
signal retreat_requested()

var combo_display_font: FontVariation
var player: HeroActor
var boss: BossActor
var director: RunDirector
var siege_system: SiegeSystem
var elites: Array[EliteActor] = []
var elite_status_order: Array[int] = []
var elite_order_refresh_remaining := 0.0
var tianji: TianjiSystem
var message := ""
var message_time := 0.0
var duel_hint_active := false
var duel_hint_index := 0
var duel_hint_remaining := 0.0
const DUEL_HINTS := ["格挡领主普攻破除架势", "破势状态的领主受到伤害更大"]
const DUEL_HINT_DURATION := 2.8
var upgrade_buttons: Array[Button] = []
var upgrade_refresh_button: Button
var upgrade_refreshes_remaining := UPGRADE_FREE_REFRESH_LIMIT
var upgrade_ad_refreshes_remaining := 0
var upgrade_option_count := 0
var upgrade_selection_limit := 1
var upgrade_selection_count := 0
var strategy_choice_active := false
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
var revive_remaining_count := 1
var pause_active := false
var pause_buttons: Array[Button] = []
var retreat_confirm_active := false
var upgrade_selection_mode := "manual"
var upgrade_selection_mode_selector: Button
var selected_upgrades_button: Button
var selected_upgrades_summary_active := false
var selected_upgrades_summary_count := 0
var selected_upgrades_scroll: ScrollContainer
var selected_upgrades_list: VBoxContainer
var selected_upgrades_close_button: Button
var selected_upgrades_scroll_touch_index := -1
var selected_upgrades_scroll_drag_start := Vector2.ZERO
var selected_upgrades_scroll_drag_start_offset := 0
var selected_upgrades_scroll_dragging := false
var modal_dismiss_area: Control
var upgrade_notification_queue: Array[Dictionary] = []
var active_upgrade_notification: Dictionary = {}
var upgrade_notification_remaining := 0.0
var move_stick_offset := Vector2.ZERO
var run_gold := 0
var hero_portrait: Texture2D
var result_hero_portrait: Texture2D
var battle_skill_textures: Dictionary = {}
var offscreen_named_targets: Array[Dictionary] = []
var offscreen_soul_targets: Array[Dictionary] = []
var combo_count := 0
var combo_remaining := 0.0
var combo_pop_remaining := 0.0
var pressed_controls: Dictionary = {}
var combo_enabled := true
var combo_hint_remaining := 0.0
var combo_setting_button: Button
var damage_numbers_enabled := true
var damage_numbers_setting_button: Button
var damage_edge_flash_remaining := 0.0
var damage_edge_flash_severity := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	_create_modal_dismiss_area()
	_sync_viewport_layout()
	get_viewport().size_changed.connect(_sync_viewport_layout)

func configure(player_actor: HeroActor, boss_actor: BossActor, run_director: RunDirector, elite_actors: Array[EliteActor] = [], tianji_system: TianjiSystem = null) -> void:
	if player != null and is_instance_valid(player) and player.damaged.is_connected(_on_player_damaged):
		player.damaged.disconnect(_on_player_damaged)
	player = player_actor
	boss = boss_actor
	director = run_director
	elites = elite_actors
	elite_status_order.clear()
	elite_order_refresh_remaining = 0.0
	tianji = tianji_system
	offscreen_named_targets.clear()
	offscreen_soul_targets.clear()
	combo_count = 0
	combo_remaining = 0.0
	combo_pop_remaining = 0.0
	pressed_controls.clear()
	damage_edge_flash_remaining = 0.0
	damage_edge_flash_severity = 0.0
	upgrade_notification_queue.clear()
	active_upgrade_notification.clear()
	upgrade_notification_remaining = 0.0
	selected_upgrades_summary_active = false
	_create_selected_upgrades_button()
	if player != null and not player.damaged.is_connected(_on_player_damaged):
		player.damaged.connect(_on_player_damaged)
	hero_portrait = null
	result_hero_portrait = null
	if player != null:
		var portrait_path := str(HERO_CATALOG.definition_for(player.hero_id).get("portrait", ""))
		if not portrait_path.is_empty():
			hero_portrait = load(portrait_path) as Texture2D
		var result_portrait_path := str(RESULT_HERO_PORTRAITS.get(player.hero_id, ""))
		if not result_portrait_path.is_empty():
			result_hero_portrait = load(result_portrait_path) as Texture2D
	message = _idle_stage_label()
	message_time = 2.8
	queue_redraw()

func set_elites(elite_actors: Array[EliteActor]) -> void:
	elites = elite_actors
	elite_status_order.clear()
	elite_order_refresh_remaining = 0.0
	queue_redraw()

func set_siege_system(value: SiegeSystem) -> void:
	siege_system = value
	queue_redraw()

func set_named_target_indicators(targets: Array[Dictionary]) -> void:
	offscreen_named_targets = targets
	queue_redraw()

func set_soul_target_indicators(targets: Array[Dictionary]) -> void:
	offscreen_soul_targets = targets
	queue_redraw()

func clear_soul_target_indicators() -> void:
	if offscreen_soul_targets.is_empty():
		return
	offscreen_soul_targets.clear()
	queue_redraw()

func _process(delta: float) -> void:
	ui_time += delta
	_sync_selected_upgrades_button_interaction()
	_sync_modal_dismiss_area()
	combo_hint_remaining = maxf(0.0, combo_hint_remaining - delta)
	elite_order_refresh_remaining = maxf(0.0, elite_order_refresh_remaining - delta)
	message_time = maxf(0.0, message_time - delta)
	if duel_hint_active:
		duel_hint_remaining -= delta
		if duel_hint_remaining <= 0.0:
			duel_hint_index = (duel_hint_index + 1) % DUEL_HINTS.size()
			duel_hint_remaining = DUEL_HINT_DURATION
	ultimate_denied_time = maxf(0.0, ultimate_denied_time - delta)
	combo_remaining = maxf(0.0, combo_remaining - delta)
	combo_pop_remaining = maxf(0.0, combo_pop_remaining - delta)
	damage_edge_flash_remaining = maxf(0.0, damage_edge_flash_remaining - delta)
	if damage_edge_flash_remaining <= 0.0:
		damage_edge_flash_severity = 0.0
	var expired_controls: Array[String] = []
	for control_id in pressed_controls.keys():
		var remaining := float(pressed_controls[control_id])
		if remaining > 0.0:
			pressed_controls[control_id] = remaining - delta
			if pressed_controls[control_id] <= 0.0:
				expired_controls.append(str(control_id))
	for control_id in expired_controls:
		pressed_controls.erase(control_id)
	if combo_remaining <= 0.0:
		combo_count = 0
	if not modal_active:
		_advance_upgrade_notification(delta)
	queue_redraw()

func set_control_pressed(control_id: String, pressed: bool) -> void:
	if pressed:
		pressed_controls[control_id] = 0.18
	else:
		pressed_controls.erase(control_id)
	queue_redraw()

func is_guan_drag_split() -> bool:
	return combo_enabled and player != null and player.supports_basic_hold()

func guan_drag_center() -> Vector2:
	return active_center() + Vector2(-132.0, 0.0)

func set_combo_enabled(value: bool) -> void:
	combo_enabled = value
	if combo_setting_button != null and is_instance_valid(combo_setting_button):
		combo_setting_button.text = "开启自动连击" if combo_enabled else "关闭自动连击"
		combo_setting_button.add_theme_stylebox_override("normal", _make_box_style(PANEL_FILL if combo_enabled else Color("20282b"), GOLD if combo_enabled else DISABLED, 2))
	queue_redraw()

func set_damage_numbers_enabled(value: bool) -> void:
	damage_numbers_enabled = value
	if damage_numbers_setting_button != null and is_instance_valid(damage_numbers_setting_button):
		damage_numbers_setting_button.text = "伤害数值：开" if damage_numbers_enabled else "伤害数值：关"
		damage_numbers_setting_button.add_theme_stylebox_override("normal", _make_box_style(PANEL_FILL if damage_numbers_enabled else Color("20282b"), GOLD if damage_numbers_enabled else DISABLED, 2))
	queue_redraw()

func set_upgrade_selection_mode(value: String) -> void:
	upgrade_selection_mode = "automatic" if value == "automatic" else "manual"
	if upgrade_selection_mode_selector != null and is_instance_valid(upgrade_selection_mode_selector):
		_sync_upgrade_selection_mode_button()
	queue_redraw()

func enqueue_upgrade_notification(title: String, description: String) -> void:
	upgrade_notification_queue.append({"title": title, "description": description})
	if active_upgrade_notification.is_empty():
		_start_next_upgrade_notification()
	queue_redraw()

func show_combo_hint() -> void:
	combo_hint_remaining = 2.4
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

func begin_duel_hints() -> void:
	duel_hint_active = true
	duel_hint_index = 0
	duel_hint_remaining = DUEL_HINT_DURATION
	queue_redraw()

func end_duel_hints() -> void:
	duel_hint_active = false
	duel_hint_remaining = 0.0
	queue_redraw()

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
	return at.distance_to(pause_center()) <= 44.0

func show_pause() -> void:
	if result_active or pause_active:
		return
	pause_active = true
	_set_modal_active(true)
	retreat_confirm_active = false
	selected_upgrades_summary_active = false
	_clear_selected_upgrades_summary_controls()
	combo_hint_remaining = 0.0
	_rebuild_pause_buttons()
	queue_redraw()

func hide_pause() -> void:
	if not pause_active:
		return
	pause_active = false
	_set_modal_active(false)
	retreat_confirm_active = false
	selected_upgrades_summary_active = false
	_clear_pause_buttons()
	_clear_selected_upgrades_summary_controls()
	queue_redraw()

func show_selected_upgrades(upgrade_ids: Array[String], upgrade_system: UpgradeSystem) -> void:
	if not pause_active:
		return
	retreat_confirm_active = false
	selected_upgrades_summary_active = true
	selected_upgrades_summary_count = upgrade_ids.size()
	_clear_pause_buttons()
	_clear_selected_upgrades_summary_controls()
	selected_upgrades_scroll = ScrollContainer.new()
	selected_upgrades_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	selected_upgrades_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	selected_upgrades_scroll.scroll_deadzone = int(SUMMARY_SCROLL_DRAG_THRESHOLD)
	selected_upgrades_scroll.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	selected_upgrades_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	selected_upgrades_scroll.gui_input.connect(_on_selected_upgrades_scroll_gui_input.bind(selected_upgrades_scroll))
	add_child(selected_upgrades_scroll)
	selected_upgrades_list = VBoxContainer.new()
	selected_upgrades_list.custom_minimum_size = Vector2(400.0, 0.0)
	selected_upgrades_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selected_upgrades_list.add_theme_constant_override("separation", 10)
	selected_upgrades_scroll.add_child(selected_upgrades_list)
	if upgrade_ids.is_empty():
		var empty_label := Label.new()
		empty_label.text = "尚未选择强化"
		empty_label.custom_minimum_size = Vector2(0.0, 64.0)
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 18)
		empty_label.add_theme_color_override("font_color", Color("b9c5c5"))
		selected_upgrades_list.add_child(empty_label)
	else:
		for upgrade_id in upgrade_ids:
			var card := Button.new()
			card.text = ""
			# The full descriptions are deliberately shown in the battle summary.
			# Reserve enough vertical space for wrapped Chinese text instead of
			# allowing the final line to bleed into the next card.
			card.custom_minimum_size = Vector2(400.0, 166.0)
			card.size = card.custom_minimum_size
			card.focus_mode = Control.FOCUS_NONE
			card.mouse_filter = Control.MOUSE_FILTER_IGNORE
			card.add_theme_stylebox_override("normal", _make_upgrade_card_style(PANEL_FILL, PANEL_EDGE, 2))
			var current_stacks := upgrade_system.stack_count_for(upgrade_id)
			var max_stacks := upgrade_system.max_stacks_for(upgrade_id)
			var stack_text := "%d/∞层" % current_stacks if max_stacks <= 0 else "%d/%d层" % [current_stacks, max_stacks]
			_add_upgrade_card_text(card, upgrade_system.category_for(upgrade_id), upgrade_system.title_for(upgrade_id), upgrade_system.description_for(upgrade_id), stack_text)
			selected_upgrades_list.add_child(card)
	selected_upgrades_close_button = _create_modal_action_button("关闭", _on_selected_upgrades_close_button_pressed, Vector2(200.0, 48.0), GOLD)
	_layout_selected_upgrades_summary()
	queue_redraw()

func show_upgrades(options: Array[String], upgrade_system: UpgradeSystem, selection_limit: int = 1) -> void:
	_set_modal_active(true)
	strategy_choice_active = false
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
		var current_stacks := upgrade_system.stack_count_for(options[index])
		var max_stacks := upgrade_system.max_stacks_for(options[index])
		var stack_text := "%d/∞层" % current_stacks if max_stacks <= 0 else "%d/%d层" % [current_stacks, max_stacks]
		_add_upgrade_card_text(button, upgrade_system.category_for(options[index]), upgrade_system.title_for(options[index]), upgrade_system.description_for(options[index]), stack_text)
		button.pressed.connect(_on_upgrade_button_pressed.bind(options[index]))
		add_child(button)
		upgrade_buttons.append(button)
	_create_upgrade_refresh_button()
	_layout_upgrade_buttons()
	queue_redraw()

func show_run_strategy_choice() -> void:
	_set_modal_active(true)
	strategy_choice_active = true
	upgrade_option_count = 3
	upgrade_selection_limit = 1
	upgrade_selection_count = 0
	_clear_upgrade_controls()
	var strategies := [
		{"id": "talent", "category": "英雄战法", "title": "战法", "description": "本局更容易遇见英雄战法；天机启阵与强化出现略少。"},
		{"id": "tianji", "category": "天机阵法", "title": "天机", "description": "本局更容易遇见天机启阵与强化；英雄战法出现略少。"},
		{"id": "balanced", "category": "均衡筹谋", "title": "均衡", "description": "英雄战法与天机阵法按原有机会出现；通用强化不受影响。"},
	]
	for strategy in strategies:
		var button := Button.new()
		button.text = ""
		button.size = Vector2(_upgrade_card_width(strategies.size()), 300.0)
		button.set_meta("strategy_id", str(strategy.get("id", "balanced")))
		button.add_theme_stylebox_override("normal", _make_upgrade_card_style(PANEL_FILL, PANEL_EDGE, 2))
		button.add_theme_stylebox_override("hover", _make_upgrade_card_style(Color("1a2b33"), DRAGON_BLUE, 3))
		button.add_theme_stylebox_override("pressed", _make_upgrade_card_style(Color("2e291d"), GOLD_BRIGHT, 3))
		_add_upgrade_card_text(button, str(strategy.get("category", "筹谋")), str(strategy.get("title", "均衡")), str(strategy.get("description", "")))
		button.pressed.connect(_on_run_strategy_button_pressed.bind(str(strategy.get("id", "balanced"))))
		add_child(button)
		upgrade_buttons.append(button)
	_layout_upgrade_buttons()
	queue_redraw()

func show_revive_prompt(remaining_revives: int = 1) -> void:
	if result_active or revive_prompt_active:
		return
	revive_remaining_count = maxi(0, remaining_revives)
	revive_prompt_active = true
	_set_modal_active(true)
	revive_watch_button = _create_modal_action_button("复活", _on_revive_watch_button_pressed, Vector2(240.0, 52.0), GOLD)
	revive_skip_button = _create_modal_action_button("放弃复活并结算", _on_revive_skip_button_pressed, Vector2(240.0, 52.0), Color("7b6644"))
	_layout_revive_buttons()
	queue_redraw()

func hide_revive_prompt() -> void:
	if not revive_prompt_active:
		return
	revive_prompt_active = false
	_set_modal_active(false)
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

func _add_upgrade_card_text(button: Button, category: String, title: String, description: String, stack_text: String = "") -> void:
	var content := VBoxContainer.new()
	content.position = Vector2(18.0, 20.0)
	content.size = button.size - Vector2(36.0, 38.0)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 8)
	button.add_child(content)
	var category_label := Label.new()
	category_label.text = category
	if not stack_text.is_empty():
		category_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		category_label.custom_minimum_size = Vector2(0.0, 26.0)
	category_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	category_label.add_theme_font_size_override("font_size", 16)
	category_label.add_theme_color_override("font_color", GOLD)
	content.add_child(category_label)
	if not stack_text.is_empty():
		var stack_label := Label.new()
		stack_label.text = stack_text
		stack_label.position = Vector2(button.size.x - 98.0, 17.0)
		stack_label.size = Vector2(80.0, 28.0)
		stack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		stack_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		stack_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stack_label.add_theme_font_size_override("font_size", 17)
		stack_label.add_theme_color_override("font_color", Color("f4d58d"))
		button.add_child(stack_label)
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
	selected_upgrades_summary_active = false
	_clear_pause_buttons()
	_clear_selected_upgrades_summary_controls()
	_set_modal_active(true)
	restart_button = Button.new()
	restart_button.text = "重新开始"
	restart_button.size = Vector2(190.0, 56.0)
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
	result_home_button.size = Vector2(190.0, 56.0)
	result_home_button.add_theme_font_size_override("font_size", 21)
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
	upgrade_selection_count += 1
	for button in upgrade_buttons.duplicate():
		if str(button.get_meta("upgrade_id", "")) != upgrade_id:
			continue
		upgrade_buttons.erase(button)
		button.queue_free()
		break
	if upgrade_selection_count >= upgrade_selection_limit:
		_clear_upgrade_controls()
		_set_modal_active(false)
	else:
		_upgrade_refresh_button_sync()
		_layout_upgrade_buttons()
	upgrade_selected.emit(upgrade_id)
	queue_redraw()

func _on_run_strategy_button_pressed(strategy_id: String) -> void:
	if not strategy_choice_active:
		return
	strategy_choice_active = false
	_clear_upgrade_controls()
	_set_modal_active(false)
	run_strategy_selected.emit(strategy_id)
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
	upgrade_refresh_button.text = "刷新  %d / %d" % [upgrade_refreshes_remaining, UPGRADE_FREE_REFRESH_LIMIT] if upgrade_refreshes_remaining > 0 else "刷新次数已用尽"
	upgrade_refresh_button.disabled = upgrade_refreshes_remaining <= 0 or upgrade_selection_count > 0

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

func _create_selected_upgrades_button() -> void:
	if selected_upgrades_button != null and is_instance_valid(selected_upgrades_button):
		_layout_selected_upgrades_button()
		return
	selected_upgrades_button = Button.new()
	selected_upgrades_button.text = "本局强化"
	selected_upgrades_button.size = Vector2(388.0, 36.0)
	# This is regular HUD. Modal cards are drawn above it, while the parent HUD
	# backdrop naturally darkens it whenever a modal is active.
	selected_upgrades_button.z_index = -1
	selected_upgrades_button.show_behind_parent = true
	selected_upgrades_button.add_theme_font_size_override("font_size", 17)
	selected_upgrades_button.add_theme_color_override("font_color", Color("d9edf0"))
	selected_upgrades_button.add_theme_color_override("font_hover_color", Color("ffffff"))
	selected_upgrades_button.add_theme_stylebox_override("normal", _make_box_style(Color(0.05, 0.12, 0.15, 0.90), DRAGON_BLUE, 1))
	selected_upgrades_button.add_theme_stylebox_override("hover", _make_box_style(Color(0.08, 0.20, 0.24, 0.96), Color("8bd5e8"), 2))
	selected_upgrades_button.add_theme_stylebox_override("pressed", _make_box_style(Color(0.09, 0.18, 0.21, 0.96), GOLD, 2))
	selected_upgrades_button.pressed.connect(_on_selected_upgrades_button_pressed)
	add_child(selected_upgrades_button)
	_layout_selected_upgrades_button()
	_sync_selected_upgrades_button_interaction()

func _on_selected_upgrades_button_pressed() -> void:
	if modal_active or result_active:
		return
	selected_upgrades_requested.emit()

func _sync_selected_upgrades_button_interaction() -> void:
	if selected_upgrades_button == null or not is_instance_valid(selected_upgrades_button):
		return
	selected_upgrades_button.mouse_filter = Control.MOUSE_FILTER_IGNORE if modal_active else Control.MOUSE_FILTER_STOP

func _on_selected_upgrades_close_button_pressed() -> void:
	if not selected_upgrades_summary_active:
		return
	selected_upgrades_summary_active = false
	_clear_selected_upgrades_summary_controls()
	resume_requested.emit()

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
	_clear_pause_buttons()
	if selected_upgrades_summary_active:
		return
	if retreat_confirm_active:
		_create_pause_button("确认收兵", _on_retreat_confirm_button_pressed)
		_create_pause_button("继续战斗", _on_retreat_cancel_button_pressed)
	else:
		_create_combo_setting_button()
		_create_upgrade_selection_mode_button()
		_create_damage_numbers_setting_button()
		_create_pause_button("继续战斗", _on_resume_button_pressed)
		_create_pause_button("重新开始", _on_pause_restart_button_pressed)
		_create_pause_button("鸣金收兵", _on_retreat_button_pressed)
	_layout_pause_buttons()

func _clear_pause_buttons() -> void:
	for button in pause_buttons:
		if is_instance_valid(button):
			button.queue_free()
	pause_buttons.clear()
	combo_setting_button = null
	damage_numbers_setting_button = null
	upgrade_selection_mode_selector = null

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

func _create_combo_setting_button() -> void:
	combo_setting_button = Button.new()
	combo_setting_button.size = Vector2(240.0, 54.0)
	combo_setting_button.add_theme_font_size_override("font_size", 19)
	combo_setting_button.add_theme_color_override("font_color", Color("fff0c7"))
	combo_setting_button.add_theme_color_override("font_hover_color", Color.WHITE)
	combo_setting_button.add_theme_color_override("font_disabled_color", Color("929b9d"))
	combo_setting_button.add_theme_stylebox_override("hover", _make_box_style(Color("22323a"), GOLD_BRIGHT, 3))
	combo_setting_button.add_theme_stylebox_override("pressed", _make_box_style(Color("4a3b24"), GOLD_BRIGHT, 3))
	combo_setting_button.pressed.connect(_on_combo_setting_button_pressed)
	add_child(combo_setting_button)
	pause_buttons.append(combo_setting_button)
	set_combo_enabled(combo_enabled)

func _create_upgrade_selection_mode_button() -> void:
	upgrade_selection_mode_selector = Button.new()
	upgrade_selection_mode_selector.size = Vector2(240.0, 54.0)
	upgrade_selection_mode_selector.alignment = HORIZONTAL_ALIGNMENT_CENTER
	upgrade_selection_mode_selector.add_theme_font_size_override("font_size", 18)
	upgrade_selection_mode_selector.add_theme_color_override("font_color", Color("fff0c7"))
	upgrade_selection_mode_selector.add_theme_color_override("font_hover_color", Color.WHITE)
	upgrade_selection_mode_selector.add_theme_stylebox_override("hover", _make_box_style(Color("22323a"), Color("8bd5e8"), 3))
	upgrade_selection_mode_selector.add_theme_stylebox_override("pressed", _make_box_style(Color("28332f"), GOLD_BRIGHT, 3))
	upgrade_selection_mode_selector.pressed.connect(_on_upgrade_selection_mode_button_pressed)
	add_child(upgrade_selection_mode_selector)
	pause_buttons.append(upgrade_selection_mode_selector)
	_sync_upgrade_selection_mode_button()

func _create_damage_numbers_setting_button() -> void:
	damage_numbers_setting_button = Button.new()
	damage_numbers_setting_button.size = Vector2(240.0, 54.0)
	damage_numbers_setting_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	damage_numbers_setting_button.add_theme_font_size_override("font_size", 18)
	damage_numbers_setting_button.add_theme_color_override("font_color", Color("fff0c7"))
	damage_numbers_setting_button.add_theme_color_override("font_hover_color", Color.WHITE)
	damage_numbers_setting_button.add_theme_stylebox_override("hover", _make_box_style(Color("22323a"), GOLD_BRIGHT, 3))
	damage_numbers_setting_button.add_theme_stylebox_override("pressed", _make_box_style(Color("4a3b24"), GOLD_BRIGHT, 3))
	damage_numbers_setting_button.pressed.connect(_on_damage_numbers_setting_button_pressed)
	add_child(damage_numbers_setting_button)
	pause_buttons.append(damage_numbers_setting_button)
	set_damage_numbers_enabled(damage_numbers_enabled)

func _on_upgrade_selection_mode_button_pressed() -> void:
	var selected_mode := "manual" if upgrade_selection_mode == "automatic" else "automatic"
	set_upgrade_selection_mode(selected_mode)
	upgrade_selection_mode_changed.emit(selected_mode)

func _on_damage_numbers_setting_button_pressed() -> void:
	set_damage_numbers_enabled(not damage_numbers_enabled)
	damage_numbers_setting_changed.emit(damage_numbers_enabled)

func _sync_upgrade_selection_mode_button() -> void:
	if upgrade_selection_mode_selector == null or not is_instance_valid(upgrade_selection_mode_selector):
		return
	var automatic := upgrade_selection_mode == "automatic"
	upgrade_selection_mode_selector.text = "强化选择：自动" if automatic else "强化选择：手动"
	upgrade_selection_mode_selector.add_theme_stylebox_override("normal", _make_box_style(Color("173037") if automatic else PANEL_FILL, DRAGON_BLUE if automatic else GOLD, 2))

func _on_combo_setting_button_pressed() -> void:
	combo_enabled = not combo_enabled
	set_combo_enabled(combo_enabled)
	combo_setting_changed.emit(combo_enabled)
	if combo_enabled:
		show_combo_hint()
	else:
		combo_hint_remaining = 0.0
		queue_redraw()

func _create_modal_dismiss_area() -> void:
	if modal_dismiss_area != null and is_instance_valid(modal_dismiss_area):
		return
	modal_dismiss_area = Control.new()
	modal_dismiss_area.mouse_filter = Control.MOUSE_FILTER_STOP
	modal_dismiss_area.focus_mode = Control.FOCUS_NONE
	modal_dismiss_area.visible = false
	modal_dismiss_area.gui_input.connect(_on_modal_dismiss_area_gui_input)
	add_child(modal_dismiss_area)

func _set_modal_active(value: bool) -> void:
	modal_active = value
	_sync_modal_dismiss_area()
	_sync_selected_upgrades_button_interaction()

func _sync_modal_dismiss_area() -> void:
	if modal_dismiss_area == null or not is_instance_valid(modal_dismiss_area):
		return
	modal_dismiss_area.position = Vector2.ZERO
	modal_dismiss_area.size = size
	modal_dismiss_area.visible = modal_active

func _on_modal_dismiss_area_gui_input(event: InputEvent) -> void:
	# Only the non-destructive pause and summary panels support tap-outside
	# dismissal. Retreat confirmation, revive and settlement still require an
	# explicit choice.
	if not modal_active or retreat_confirm_active or not (pause_active or selected_upgrades_summary_active):
		return
	# Android dispatches an emulated mouse press immediately after each physical
	# screen touch. A pause opened by that touch must not be closed again by its
	# paired emulated event; real touch and desktop mouse input still dismiss.
	if event is InputEventMouseButton and event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if not ((event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventScreenTouch and event.pressed)):
		return
	var panel_rect := _selected_upgrades_summary_panel_rect() if selected_upgrades_summary_active else _pause_panel_rect()
	if panel_rect.has_point(event.position):
		return
	modal_dismiss_area.accept_event()
	resume_requested.emit()

func _on_selected_upgrades_scroll_gui_input(event: InputEvent, scroll: ScrollContainer) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			selected_upgrades_scroll_touch_index = event.index
			selected_upgrades_scroll_drag_start = event.position
			selected_upgrades_scroll_drag_start_offset = scroll.scroll_vertical
			selected_upgrades_scroll_dragging = false
		elif event.index == selected_upgrades_scroll_touch_index:
			if selected_upgrades_scroll_dragging:
				scroll.accept_event()
			selected_upgrades_scroll_touch_index = -1
			selected_upgrades_scroll_dragging = false
		return
	if event is InputEventScreenDrag and event.index == selected_upgrades_scroll_touch_index:
		if _update_selected_upgrades_scroll(scroll, event.position):
			scroll.accept_event()

func _update_selected_upgrades_scroll(scroll: ScrollContainer, pointer_position: Vector2) -> bool:
	var delta_y := pointer_position.y - selected_upgrades_scroll_drag_start.y
	if not selected_upgrades_scroll_dragging and absf(delta_y) < SUMMARY_SCROLL_DRAG_THRESHOLD:
		return false
	selected_upgrades_scroll_dragging = true
	var bar := scroll.get_v_scroll_bar()
	var target_scroll := clampf(float(selected_upgrades_scroll_drag_start_offset) - delta_y, bar.min_value, bar.max_value)
	scroll.scroll_vertical = int(round(target_scroll))
	return true

func _sync_viewport_layout() -> void:
	position = Vector2.ZERO
	size = get_viewport().get_visible_rect().size
	_sync_modal_dismiss_area()
	_layout_selected_upgrades_button()
	_layout_upgrade_buttons()
	_layout_upgrade_refresh_button()
	_layout_restart_button()
	_layout_pause_buttons()
	_layout_revive_buttons()
	_layout_selected_upgrades_summary()
	queue_redraw()

func _layout_selected_upgrades_button() -> void:
	if selected_upgrades_button == null or not is_instance_valid(selected_upgrades_button):
		return
	var width := minf(388.0, maxf(180.0, size.x - 32.0))
	selected_upgrades_button.size = Vector2(width, 36.0)
	selected_upgrades_button.position = Vector2(16.0, 202.0)

func _layout_selected_upgrades_summary() -> void:
	if not selected_upgrades_summary_active:
		return
	var panel := _selected_upgrades_summary_panel_rect()
	if selected_upgrades_scroll != null and is_instance_valid(selected_upgrades_scroll):
		selected_upgrades_scroll.position = panel.position + Vector2(28.0, 112.0)
		selected_upgrades_scroll.size = Vector2(panel.size.x - 56.0, maxf(80.0, panel.size.y - 190.0))
	if selected_upgrades_close_button != null and is_instance_valid(selected_upgrades_close_button):
		selected_upgrades_close_button.position = Vector2(panel.get_center().x - selected_upgrades_close_button.size.x * 0.5, panel.end.y - selected_upgrades_close_button.size.y - 22.0)

func _clear_selected_upgrades_summary_controls() -> void:
	if selected_upgrades_scroll != null and is_instance_valid(selected_upgrades_scroll):
		selected_upgrades_scroll.queue_free()
	selected_upgrades_scroll = null
	selected_upgrades_list = null
	selected_upgrades_scroll_touch_index = -1
	selected_upgrades_scroll_dragging = false
	if selected_upgrades_close_button != null and is_instance_valid(selected_upgrades_close_button):
		selected_upgrades_close_button.queue_free()
	selected_upgrades_close_button = null

func _advance_upgrade_notification(delta: float) -> void:
	if active_upgrade_notification.is_empty():
		_start_next_upgrade_notification()
		return
	upgrade_notification_remaining = maxf(0.0, upgrade_notification_remaining - delta)
	if upgrade_notification_remaining <= 0.0:
		active_upgrade_notification.clear()
		_start_next_upgrade_notification()

func _start_next_upgrade_notification() -> void:
	if upgrade_notification_queue.is_empty():
		active_upgrade_notification.clear()
		upgrade_notification_remaining = 0.0
		return
	active_upgrade_notification = upgrade_notification_queue.pop_front() as Dictionary
	upgrade_notification_remaining = UPGRADE_NOTIFICATION_DURATION + UPGRADE_NOTIFICATION_FADE_DURATION

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
	var result_rect := _result_panel_rect()
	if result_home_button == null:
		restart_button.position = Vector2(result_rect.get_center().x - restart_button.size.x * 0.5, result_rect.end.y - restart_button.size.y - 18.0)
		return
	var gap := 18.0
	var result_buttons: Array[Button] = [restart_button, result_home_button]
	var total_width := 0.0
	for button in result_buttons:
		total_width += button.size.x
	total_width += gap * float(result_buttons.size() - 1)
	var start_x := size.x * 0.5 - total_width * 0.5
	var button_y := result_rect.end.y - restart_button.size.y - 18.0
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
	var horizontal_gap := 12.0
	var vertical_gap := 10.0
	var side_margin := 32.0
	var button_width := (pause_rect.size.x - side_margin * 2.0 - horizontal_gap) * 0.5
	var row_count := ceili(float(pause_buttons.size()) * 0.5)
	var button_height := pause_buttons[0].size.y
	var total_height := button_height * row_count + vertical_gap * float(maxi(0, row_count - 1))
	var content_top := pause_rect.position.y + 132.0
	var content_bottom := pause_rect.end.y - 28.0
	var start_y := content_top + maxf(0.0, (content_bottom - content_top - total_height) * 0.5)
	for index in range(pause_buttons.size()):
		var button := pause_buttons[index]
		var column := index % 2
		var row := index / 2
		button.size.x = button_width
		button.position = Vector2(pause_rect.position.x + side_margin + float(column) * (button_width + horizontal_gap), start_y + float(row) * (button_height + vertical_gap))

func _draw() -> void:
	var font := ThemeDB.fallback_font
	_draw_top_hud(font)
	_draw_upgrade_notification(font)
	_draw_combo_counter(font)
	_draw_tianji_slots(font)
	_draw_skill_cluster(font)
	_draw_named_target_indicators()
	_draw_soul_target_indicators()
	_draw_modal_backdrop(font)
	_draw_low_health_warning()

func _draw_low_health_warning() -> void:
	if player == null or player.health_component == null:
		return
	if modal_active or result_active:
		return
	var current_health := player.health_component.current
	var low_health_strength := 0.0
	var low_health_color := Color("83131d")
	if current_health > 0.0 and current_health < 40.0:
		var pulse := 0.5 + 0.5 * sin(ui_time * TAU * 1.7)
		var health_factor := clampf((40.0 - current_health) / 20.0, 0.0, 1.0)
		low_health_strength = lerpf(0.24, 0.44, health_factor) * lerpf(0.82, 1.0, pulse)
		low_health_color = Color("83131d").lerp(Color("ff858a"), pulse)
	var damage_strength := _damage_edge_flash_strength()
	if damage_strength <= 0.0 and low_health_strength <= 0.0:
		return
	var strength := low_health_strength
	var edge_color := low_health_color
	if damage_strength > low_health_strength:
		strength = damage_strength
		edge_color = _damage_edge_flash_color()
	_draw_red_edge_bands(strength, edge_color)

func _draw_red_edge_bands(strength: float, edge_color: Color) -> void:
	var band_count := 16
	var band_size := 11.0
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

func _on_player_damaged(amount: float) -> void:
	if amount <= 0.0 or player == null or player.health_component == null:
		return
	var maximum_health := maxf(1.0, player.health_component.maximum)
	var damage_ratio := clampf(amount / maximum_health, 0.0, 1.0)
	# Keep light hits visible while reserving the darkest red for substantial hits.
	var severity := clampf(0.22 + damage_ratio * 3.2, 0.22, 1.0)
	damage_edge_flash_severity = maxf(damage_edge_flash_severity, severity)
	damage_edge_flash_remaining = maxf(damage_edge_flash_remaining, DAMAGE_EDGE_FLASH_DURATION)
	queue_redraw()

func _damage_edge_flash_strength() -> float:
	if damage_edge_flash_remaining <= 0.0:
		return 0.0
	var elapsed := DAMAGE_EDGE_FLASH_DURATION - damage_edge_flash_remaining
	var phase := fposmod(elapsed, DAMAGE_EDGE_FLASH_CYCLE_DURATION) / DAMAGE_EDGE_FLASH_CYCLE_DURATION
	var pulse := 1.0 - absf(phase * 2.0 - 1.0)
	return lerpf(0.30, 0.82, damage_edge_flash_severity) * maxf(0.08, pulse)

func _damage_edge_flash_color() -> Color:
	return Color("ff7772").lerp(Color("861019"), damage_edge_flash_severity)

func _draw_combo_counter(_font: Font) -> void:
	if combo_count <= 0 or modal_active or result_active:
		return
	if combo_display_font == null:
		combo_display_font = FontVariation.new()
		combo_display_font.base_font = COMBO_KAITI_FONT
		combo_display_font.variation_embolden = 0.85
	var pop_ratio := clampf(combo_pop_remaining / COMBO_POP_DURATION, 0.0, 1.0)
	var fade_ratio := clampf(combo_remaining / COMBO_FADE_DURATION, 0.0, 1.0)
	var alpha := minf(1.0, fade_ratio)
	var text_scale := 1.0 + pop_ratio * 0.14
	var font_size := maxi(30, roundi(39.0 * text_scale))
	var label := "连击 x %d" % combo_count
	var width := maxf(356.0, combo_display_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 88.0)
	var lift := (1.0 - fade_ratio) * 10.0
	var brush_rect := Rect2(size.x * 0.5 - width * 0.5, 54.0 - lift, width, 96.0 * text_scale)
	draw_texture_rect(COMBO_BRUSH_TEXTURE, brush_rect, false, Color(1.0, 1.0, 1.0, alpha * 0.82))
	var origin := Vector2(brush_rect.position.x, brush_rect.position.y + brush_rect.size.y * 0.70)
	draw_string_outline(combo_display_font, origin, label, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, 5, Color(0.15, 0.025, 0.01, alpha))
	draw_string(combo_display_font, origin, label, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, Color(1.0, 0.72, 0.24, alpha))

func _draw_top_hud(font: Font) -> void:
	var player_panel := Rect2(16, 14, 388, 184)
	# Match the original HUD footprint, stretching the frame to its full height.
	draw_texture_rect(HERO_INFO_TEXTURE, player_panel, false)
	if player != null:
		var content_rect := _panel_content_rect(player_panel, Vector2(14.0, 10.0))
		var hero_name := HERO_CATALOG.hud_name_for(player.hero_id)
		var hero_marker := hero_name.left(1)
		var badge_rect := Rect2(content_rect.position + Vector2(1.0, 2.0), Vector2(46.0, 46.0))
		draw_rect(badge_rect, Color("0b1519"))
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
		var stage_text: String = str(DUEL_HINTS[duel_hint_index]) if duel_hint_active else (message if message_time > 0.0 else _idle_stage_label())
		draw_string(font, stage_content.position + Vector2(0.0, 19.0), stage_text, HORIZONTAL_ALIGNMENT_LEFT, stage_content.size.x, 18, Color("f3e3bd"))
		if siege_system != null and siege_system.is_active():
			var gate_rect := Rect2(size.x * 0.5 - 184.0, 60, 368, 34)
			_draw_panel(gate_rect, Color("b66a44"))
			var gate_content := _panel_content_rect(gate_rect, Vector2(10.0, 6.0))
			_draw_bar(Rect2(gate_content.position, Vector2(gate_content.size.x, 12.0)), siege_system.objective_ratio(), Color("ba624b"), siege_system.objective_label(), font)
			var siege_status := siege_system.phase_status_label()
			var siege_color := Color("f5d37d") if siege_system.is_counterattack_active() else (Color("efcf8e") if not siege_system.is_lone_stand() else HEALTH_RED)
			draw_string(font, gate_content.position + Vector2(0.0, 25.0), siege_status, HORIZONTAL_ALIGNMENT_CENTER, gate_content.size.x, 12, siege_color)
		var time_rect := Rect2(size.x - 170.0, 14, 154, 48)
		_draw_panel(time_rect, GOLD)
		var time_content := _panel_content_rect(time_rect, Vector2(14.0, 8.0))
		if director.is_boss_trial():
			draw_string(font, time_content.position + Vector2(0.0, 23.0), "试炼", HORIZONTAL_ALIGNMENT_CENTER, time_content.size.x, 23, Color("f5e5bb"))
		elif director.is_siege():
			draw_string(font, time_content.position + Vector2(0.0, 23.0), "攻城 %02d:%02d" % [int(director.elapsed) / 60, int(director.elapsed) % 60], HORIZONTAL_ALIGNMENT_CENTER, time_content.size.x, 18, Color("f5e5bb"))
		else:
			draw_string(font, time_content.position + Vector2(0.0, 24.0), "%02d:%02d" % [int(director.remaining_time()) / 60, int(director.remaining_time()) % 60], HORIZONTAL_ALIGNMENT_CENTER, time_content.size.x, 25, Color("f5e5bb"))
	var pause_at := pause_center()
	draw_circle(pause_at, 28.0, Color("10191f"))
	draw_arc(pause_at, 28.0, 0.0, TAU, 20, GOLD, 2.0)
	draw_line(pause_at + Vector2(-6, -9), pause_at + Vector2(-6, 9), GOLD_BRIGHT, 4.0)
	draw_line(pause_at + Vector2(6, -9), pause_at + Vector2(6, 9), GOLD_BRIGHT, 4.0)
	_draw_enemy_status_rack(font)

func _draw_upgrade_notification(font: Font) -> void:
	if modal_active or active_upgrade_notification.is_empty() or upgrade_notification_remaining <= 0.0:
		return
	var button_rect := _selected_upgrades_button_rect()
	var alpha := 1.0
	if upgrade_notification_remaining < UPGRADE_NOTIFICATION_FADE_DURATION:
		alpha = upgrade_notification_remaining / UPGRADE_NOTIFICATION_FADE_DURATION
	var bubble_rect := Rect2(button_rect.position.x, button_rect.end.y + 10.0, button_rect.size.x, 62.0)
	var arrow_center := Vector2(button_rect.get_center().x, bubble_rect.position.y)
	draw_colored_polygon(PackedVector2Array([
		arrow_center + Vector2(-9.0, 0.0),
		arrow_center + Vector2(0.0, -8.0),
		arrow_center + Vector2(9.0, 0.0),
	]), Color(0.05, 0.12, 0.15, 0.88 * alpha))
	draw_rect(bubble_rect, Color(0.05, 0.12, 0.15, 0.88 * alpha))
	draw_rect(bubble_rect, Color(0.39, 0.73, 0.87, 0.82 * alpha), false, 1.0)
	var status_label := "已获强化"
	var status_width := font.get_string_size(status_label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14).x
	var title_width := maxf(64.0, bubble_rect.size.x - 36.0 - status_width)
	var title := _truncate_upgrade_notification_text(str(active_upgrade_notification.get("title", "强化")), 4, font, 17, title_width)
	var description := _truncate_upgrade_notification_text(str(active_upgrade_notification.get("description", "")), 20, font, 14, bubble_rect.size.x - 24.0)
	draw_string(font, bubble_rect.position + Vector2(12.0, 23.0), title, HORIZONTAL_ALIGNMENT_LEFT, title_width, 17, Color(0.96, 0.88, 0.66, alpha))
	draw_string(font, Vector2(bubble_rect.end.x - status_width - 12.0, bubble_rect.position.y + 22.0), status_label, HORIZONTAL_ALIGNMENT_LEFT, status_width, 14, Color(0.55, 0.80, 0.90, alpha))
	draw_string(font, bubble_rect.position + Vector2(12.0, 47.0), description, HORIZONTAL_ALIGNMENT_LEFT, bubble_rect.size.x - 24.0, 14, Color(0.84, 0.93, 0.92, alpha))

func _truncate_upgrade_notification_text(value: String, character_limit: int, font: Font, font_size: int, max_width: float) -> String:
	var clipped := value
	if clipped.length() > character_limit:
		clipped = clipped.left(character_limit) + "..."
	return _truncate_hud_text(clipped, font, font_size, max_width)

func _selected_upgrades_button_rect() -> Rect2:
	if selected_upgrades_button != null and is_instance_valid(selected_upgrades_button):
		return Rect2(selected_upgrades_button.position, selected_upgrades_button.size)
	return Rect2(16.0, 202.0, minf(388.0, maxf(180.0, size.x - 32.0)), 36.0)

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
	if director.is_siege():
		return "无尽 · 攻城略地"
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
	if director.is_siege():
		return "攻取荆州 · 破门入城"
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
	var arrow_towers: Array[Dictionary] = []
	if siege_system != null and siege_system.is_active():
		arrow_towers = siege_system.active_arrow_towers()
	if not arrow_towers.is_empty():
		_draw_arrow_tower_status_rack(arrow_towers, font)
		return
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
		_draw_enemy_status_bar(boss_rect, "领主", boss.display_name(), boss.health_component.current, boss.health_component.maximum, boss.health_layer_capacity(), boss.stance, boss.stance_max(), boss_state, boss.is_stance_broken(), font)

func _draw_arrow_tower_status_rack(towers: Array[Dictionary], font: Font) -> void:
	var rack_width := clampf(size.x * 0.54, 460.0, 700.0)
	var gap := 6.0
	var row_height := 42.0
	var column_width := (rack_width - gap) * 0.5
	var total_height := 22.0 + row_height * 2.0 + gap
	var rack_x := clampf(size.x * 0.5 - rack_width * 0.5, 14.0, size.x - rack_width - 14.0)
	var rack_y := maxf(138.0, size.y - 16.0 - total_height)
	draw_string(font, Vector2(rack_x, rack_y + 15.0), "箭楼防线 · 摧毁箭楼即可突破拒马", HORIZONTAL_ALIGNMENT_CENTER, rack_width, 14, Color("f4d58d"))
	for index in range(mini(4, towers.size())):
		var row := index / 2
		var column := index % 2
		var tower_rect := Rect2(rack_x + float(column) * (column_width + gap), rack_y + 22.0 + float(row) * (row_height + gap), column_width, row_height)
		_draw_arrow_tower_status_entry(tower_rect, towers[index], index, font)

func _draw_arrow_tower_status_entry(rect: Rect2, tower: Dictionary, index: int, font: Font) -> void:
	var current := maxf(0.0, float(tower.get("health", 0.0)))
	var maximum := maxf(1.0, float(tower.get("maximum", 1.0)))
	var destroyed := current <= 0.0
	_draw_panel(rect, Color("566069") if destroyed else Color("b87d3f"))
	var content := _panel_content_rect(rect, Vector2(8.0, 5.0))
	var name := "箭楼 %d" % (index + 1)
	draw_string(font, content.position + Vector2(0.0, 12.0), name, HORIZONTAL_ALIGNMENT_LEFT, 58.0, 13, Color("7b858a") if destroyed else Color("fff1d8"))
	var status := "已毁" if destroyed else "%d%%" % int(round(current / maximum * 100.0))
	draw_string(font, Vector2(content.end.x - 44.0, content.position.y + 12.0), status, HORIZONTAL_ALIGNMENT_RIGHT, 44.0, 12, Color("8b9599") if destroyed else Color("f5d37d"))
	var bar := Rect2(content.position + Vector2(0.0, 19.0), Vector2(content.size.x, 11.0))
	draw_rect(bar, Color("160f13"))
	var fill_width := bar.size.x * clampf(current / maximum, 0.0, 1.0)
	if fill_width > 0.0:
		draw_rect(Rect2(bar.position + Vector2(1.0, 1.0), Vector2(maxf(0.0, fill_width - 2.0), maxf(1.0, bar.size.y - 2.0))), Color("d95f4c") if not destroyed else Color("596169"))
	draw_rect(bar, Color("d3a45e") if not destroyed else Color("687278"), false, 1.0)

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
	# Keep the existing hit areas while replacing only the control artwork.
	var split_guan_controls := is_guan_drag_split()
	_draw_skill_button(attack_center(), 68.0, "", "", DRAGON_BLUE, true, font, "attack")
	if split_guan_controls:
		_draw_skill_button(guan_drag_center(), 50.0, "拖刀", "蓄力", GOLD, true, font, "drag")
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

func _draw_soul_target_indicators() -> void:
	if modal_active or result_active or pause_active or offscreen_soul_targets.is_empty():
		return
	var lane_counts: Dictionary = {}
	for target in offscreen_named_targets:
		var named_direction: Vector2 = target.get("direction", Vector2.UP)
		if named_direction.length_squared() <= 0.01:
			named_direction = Vector2.UP
		lane_counts[_named_indicator_lane(named_direction.normalized())] = int(lane_counts.get(_named_indicator_lane(named_direction.normalized()), 0)) + 1
	for target in offscreen_soul_targets:
		var direction: Vector2 = target.get("direction", Vector2.UP)
		if direction.length_squared() <= 0.01:
			direction = Vector2.UP
		else:
			direction = direction.normalized()
		var lane := _named_indicator_lane(direction)
		var slot := int(lane_counts.get(lane, 0))
		lane_counts[lane] = slot + 1
		var center := _named_indicator_position(direction, lane, slot)
		_draw_soul_target_indicator(center, direction, str(target.get("soul_id", "gale")))

func _draw_soul_target_indicator(center: Vector2, direction: Vector2, soul_id: String) -> void:
	var texture: Texture2D = BATTLE_SOUL_LOGO_TEXTURES.get(soul_id, null)
	var radius := 17.0
	var accent := Color("d8a84e")
	draw_circle(center, radius + 5.0, Color(0.03, 0.04, 0.05, 0.78))
	draw_circle(center, radius, Color("1d1715"))
	if texture != null:
		_draw_texture_centered(texture, center, Vector2(27.0, 27.0), Color.WHITE)
	else:
		draw_circle(center, 8.0, accent)
	var perpendicular := Vector2(-direction.y, direction.x)
	var arrow_base := center + direction * (radius + 5.0)
	var arrow_tip := center + direction * (radius + 15.0)
	draw_colored_polygon(PackedVector2Array([
		arrow_tip,
		arrow_base + perpendicular * 5.0,
		arrow_base - perpendicular * 5.0,
	]), accent.lightened(0.14))

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
	var distance: float = 54.0 * ceil(float(slot) * 0.5)
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
	_draw_texture_centered(MOVE_BUTTON_TEXTURE, center, Vector2(178.0, 178.0), Color.WHITE)
	# The two source sprites have slightly different visual centers. Keep the
	# resting knob aligned with the visible base, without altering input math.
	var knob := center + Vector2(-3.0, 3.0) + move_stick_offset
	_draw_texture_centered(MOVE_KNOB_TEXTURE, knob, Vector2(58.0, 58.0), Color.WHITE)
	draw_string(font, center + Vector2(-24, 118), "移动", HORIZONTAL_ALIGNMENT_CENTER, 48, 14, Color("9ab5bd"))

func _draw_modal_backdrop(font: Font) -> void:
	if not modal_active:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.02, 0.03, 0.68))
	if selected_upgrades_summary_active:
		var summary_rect := _selected_upgrades_summary_panel_rect()
		_draw_panel(summary_rect, DRAGON_BLUE, true)
		draw_string(font, Vector2(summary_rect.get_center().x - 58.0, summary_rect.position.y + 66.0), "本局强化", HORIZONTAL_ALIGNMENT_LEFT, -1, 29, GOLD_BRIGHT)
		UITheme.draw_title_divider(self, Rect2(summary_rect.get_center().x - 118.0, summary_rect.position.y + 74.0, 236.0, 18.0))
		var summary_hint := "已选择 %d 项强化，可上下滑动查看" % selected_upgrades_summary_count if selected_upgrades_summary_count > 0 else "本局尚未获得强化"
		draw_string(font, Vector2(summary_rect.position.x + 28.0, summary_rect.position.y + 106.0), summary_hint, HORIZONTAL_ALIGNMENT_LEFT, summary_rect.size.x - 56.0, 15, Color("b9c5c5"))
	elif pause_active:
		var pause_rect := _pause_panel_rect()
		_draw_panel(pause_rect, GOLD, true)
		draw_string(font, Vector2(pause_rect.get_center().x - 58.0, pause_rect.position.y + 74.0), "战斗暂停", HORIZONTAL_ALIGNMENT_LEFT, -1, 29, GOLD_BRIGHT)
		UITheme.draw_title_divider(self, Rect2(pause_rect.get_center().x - 118.0, pause_rect.position.y + 82.0, 236.0, 18.0))
		if retreat_confirm_active:
			draw_string(font, Vector2(pause_rect.position.x + 34.0, pause_rect.position.y + 112.0), "是否结束当前战斗并结算已获得军功？", HORIZONTAL_ALIGNMENT_LEFT, pause_rect.size.x - 68.0, 16, Color("e3d0a4"))
			draw_string(font, Vector2(pause_rect.position.x + 34.0, pause_rect.position.y + 138.0), "收兵后无法继续本局", HORIZONTAL_ALIGNMENT_LEFT, pause_rect.size.x - 68.0, 14, Color("b9c5c5"))
		else:
			draw_string(font, Vector2(pause_rect.get_center().x - 115.0, pause_rect.position.y + 108.0), "军势暂歇，整顿后再破阵", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("b9c5c5"))
		if combo_hint_remaining > 0.0 and not retreat_confirm_active:
			var hint_rect := Rect2(Vector2(pause_rect.get_center().x - 150.0, pause_rect.position.y - 54.0), Vector2(300.0, 42.0))
			draw_rect(hint_rect, Color(0.05, 0.10, 0.12, 0.86))
			draw_rect(hint_rect, Color("63b9df"), false, 1.0)
			draw_string(font, Vector2(hint_rect.position.x, hint_rect.position.y + 27.0), "长按攻击按钮自动攻击", HORIZONTAL_ALIGNMENT_CENTER, hint_rect.size.x, 16, Color("e3f2ef"))
	elif revive_prompt_active:
		var revive_rect := _pause_panel_rect()
		_draw_panel(revive_rect, HEALTH_RED, true)
		draw_string(font, Vector2(revive_rect.get_center().x - 104.0, revive_rect.position.y + 74.0), "力竭待援", HORIZONTAL_ALIGNMENT_LEFT, -1, 29, Color("ffaaa0"))
		UITheme.draw_title_divider(self, Rect2(revive_rect.get_center().x - 118.0, revive_rect.position.y + 82.0, 236.0, 18.0))
		draw_string(font, Vector2(revive_rect.position.x + 34.0, revive_rect.position.y + 116.0), "可复活并继续战斗", HORIZONTAL_ALIGNMENT_LEFT, revive_rect.size.x - 68.0, 16, Color("e3d0a4"))
		draw_string(font, Vector2(revive_rect.position.x + 34.0, revive_rect.position.y + 144.0), "本局还可复活 %d 次" % revive_remaining_count, HORIZONTAL_ALIGNMENT_LEFT, revive_rect.size.x - 68.0, 14, Color("b9c5c5"))
	elif result_active:
		var result_rect := _result_panel_rect()
		_draw_panel(result_rect, GOLD if result_victory else HEALTH_RED, true)
		var title_font := FontVariation.new()
		title_font.base_font = COMBO_KAITI_FONT
		title_font.variation_embolden = 0.9
		# The portrait sits directly above the settlement card, while the title
		# and data text are drawn afterward so they remain readable.
		var portrait_rect := _result_portrait_rect(result_rect)
		_draw_result_hero_portrait(portrait_rect)
		# Let the heading float above the compact card instead of consuming the
		# card's useful content height, and shift it slightly left.
		var title_brush_rect := Rect2(result_rect.position.x + 20.0, result_rect.position.y - 24.0, result_rect.size.x - 126.0, 70.0)
		draw_texture_rect(COMBO_BRUSH_TEXTURE, title_brush_rect, false, Color(1.0, 1.0, 1.0, 0.88))
		draw_string_outline(title_font, Vector2(title_brush_rect.position.x, title_brush_rect.position.y + 50.0), "鸣金收兵", HORIZONTAL_ALIGNMENT_CENTER, title_brush_rect.size.x, 36, 5, Color(0.10, 0.015, 0.01, 0.96))
		draw_string(title_font, Vector2(title_brush_rect.position.x, title_brush_rect.position.y + 50.0), "鸣金收兵", HORIZONTAL_ALIGNMENT_CENTER, title_brush_rect.size.x, 36, GOLD_BRIGHT)
		# Keep the battle data column on the left and reserve the right side for
		# the enlarged portrait.
		var data_x := result_rect.position.x + 26.0
		var data_width := result_rect.size.x * 0.43
		# Move the whole data column upward so the last row stays clear of the
		# bottom action buttons.
		draw_string(title_font, Vector2(data_x, result_rect.position.y + 84.0), "战斗数据", HORIZONTAL_ALIGNMENT_LEFT, data_width, 22, GOLD_BRIGHT)
		UITheme.draw_title_divider(self, Rect2(data_x, result_rect.position.y + 91.0, data_width, 12.0))
		draw_string(font, Vector2(data_x, result_rect.position.y + 114.0), result_message, HORIZONTAL_ALIGNMENT_LEFT, data_width, 14, Color("d7dfda"))
		var stat_rect := Rect2(data_x, result_rect.position.y + 130.0, data_width, 37.0)
		_draw_result_stat(font, stat_rect, "击破", "%d" % int(result_stats.get("defeated", 0)), GOLD_BRIGHT)
		stat_rect.position.y += 42.0
		_draw_result_stat(font, stat_rect, "受伤", "%d" % int(round(float(result_stats.get("damage_taken", 0.0)))), Color("e99186"))
		stat_rect.position.y += 42.0
		_draw_result_stat(font, stat_rect, "战时", _format_result_time(float(result_stats.get("combat_time", 0.0))), DRAGON_BLUE)
		stat_rect.position.y += 42.0
		_draw_result_stat(font, stat_rect, "军功", "%d" % int(result_stats.get("military_merit", run_gold)), GOLD_BRIGHT)
	else:
		var choice_count := maxi(1, upgrade_option_count)
		var card_width := _upgrade_card_width(choice_count)
		var total_cards_width := float(choice_count) * card_width + float(choice_count - 1) * 16.0
		var panel_width := minf(maxf(320.0, size.x - 24.0), maxf(780.0, total_cards_width + 48.0))
		var upgrade_rect := Rect2(size.x * 0.5 - panel_width * 0.5, 112.0, panel_width, 472.0)
		_draw_panel(upgrade_rect, GOLD, true)
		var modal_title := "本局策略" if strategy_choice_active else "临阵抉择"
		draw_string(font, Vector2(upgrade_rect.position.x, 162), modal_title, HORIZONTAL_ALIGNMENT_CENTER, upgrade_rect.size.x, 27, GOLD_BRIGHT)
		UITheme.draw_title_divider(self, Rect2(upgrade_rect.get_center().x - 126.0, 169.0, 252.0, 18.0))
		if strategy_choice_active:
			draw_string(font, Vector2(upgrade_rect.position.x, 188), "选择本局倾向，不影响通用强化", HORIZONTAL_ALIGNMENT_CENTER, upgrade_rect.size.x, 15, Color("b9c5c5"))
		else:
			var choice_label := "%d选%d" % [choice_count, upgrade_selection_limit]
			if upgrade_selection_limit > 1:
				choice_label += "（已选 %d / %d）" % [upgrade_selection_count, upgrade_selection_limit]
			draw_string(font, Vector2(upgrade_rect.position.x, 188), choice_label + " · 选择强化，重整枪势", HORIZONTAL_ALIGNMENT_CENTER, upgrade_rect.size.x, 15, Color("b9c5c5"))

func _pause_panel_rect() -> Rect2:
	var panel_width := minf(560.0, maxf(342.0, size.x - 36.0))
	return Rect2(size.x * 0.5 - panel_width * 0.5, size.y * 0.5 - 236.0, panel_width, 472.0)

func _selected_upgrades_summary_panel_rect() -> Rect2:
	return Rect2(size.x * 0.5 - 236.0, size.y * 0.5 - 236.0, 472.0, 472.0)

func _result_panel_rect() -> Rect2:
	# Keep the settlement card close to the compact modal scale used elsewhere.
	# The portrait is rendered independently and may extend past the card, so the
	# card does not need extra width or height just to contain the artwork.
	var panel_width := minf(560.0, maxf(400.0, size.x - 32.0))
	var panel_height := minf(380.0, maxf(330.0, size.y - 32.0))
	return Rect2(size.x * 0.5 - panel_width * 0.5, size.y * 0.5 - panel_height * 0.5, panel_width, panel_height)

func _draw_result_stat(font: Font, rect: Rect2, label: String, value: String, accent: Color) -> void:
	draw_rect(rect, Color(0.035, 0.055, 0.063, 0.78), true)
	draw_rect(rect, Color(0.61, 0.49, 0.29, 0.62), false, 1.0)
	draw_string(font, rect.position + Vector2(12.0, 24.0), label, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x * 0.52, 16, Color("bdc6c0"))
	draw_string(font, rect.position + Vector2(rect.size.x * 0.52, 26.0), value, HORIZONTAL_ALIGNMENT_RIGHT, rect.size.x * 0.40, 20, accent)

func _format_result_time(total_seconds: float) -> String:
	var seconds := maxi(0, int(round(total_seconds)))
	return "%02d:%02d" % [seconds / 60, seconds % 60]

func _result_portrait_rect(result_rect: Rect2) -> Rect2:
	if result_hero_portrait == null:
		return Rect2()
	var texture_size := result_hero_portrait.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Rect2()
	# The portrait is intentionally allowed to extend beyond the compact card.
	# This keeps the data panel tight without sacrificing the new full-size artwork.
	# Scale the new portrait to 1.5x its previous 270px display width.
	var target_width := minf(405.0, maxf(300.0, result_rect.size.x * 0.724))
	var target_size := Vector2(target_width, target_width * texture_size.y / texture_size.x)
	# Place the enlarged portrait on the right side of the data column and
	# lift it slightly so the upper body remains visible above the compact card.
	var portrait_x := result_rect.position.x + result_rect.size.x * 0.58 - target_width * 0.25
	var portrait_y := result_rect.position.y - 42.0
	return Rect2(Vector2(portrait_x, portrait_y), target_size)

func _draw_result_hero_portrait(rect: Rect2) -> void:
	if result_hero_portrait == null or rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	# The portrait should sit directly on the settlement background; do not add
	# a decorative circle behind it.
	draw_texture_rect(result_hero_portrait, rect, false, Color(1.0, 1.0, 1.0, 0.98))

func _draw_texture_centered(texture: Texture2D, center: Vector2, max_size: Vector2, modulate: Color = Color.WHITE) -> void:
	if texture == null:
		return
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0 or max_size.x <= 0.0 or max_size.y <= 0.0:
		return
	var scale_factor := minf(max_size.x / texture_size.x, max_size.y / texture_size.y)
	var draw_size := texture_size * scale_factor
	draw_texture_rect(texture, Rect2(center - draw_size * 0.5, draw_size), false, modulate)

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

func _draw_skill_button(center: Vector2, radius: float, title: String, subtitle: String, accent: Color, enabled: bool, font: Font, icon_kind: String = "") -> void:
	var pressed := pressed_controls.has(icon_kind)
	if pressed:
		radius *= 0.90
	var pulse := 0.72 + 0.28 * (sin(ui_time * 5.0) + 1.0) * 0.5 if enabled else 0.48
	var ring_color := accent if enabled else Color("4b555b")
	var button_texture: Texture2D = SKILL_BUTTON_TEXTURE
	var button_size := Vector2(radius * 2.12, radius * 2.30)
	if icon_kind == "attack":
		button_texture = ATTACK_BUTTON_TEXTURE
		button_size = Vector2(radius * 2.16, radius * 1.98)
	var button_modulate := Color.WHITE if enabled else Color(0.55, 0.60, 0.61, 0.86)
	# attackBtn.png already contains the weapon artwork; do not cover it with
	# another skill icon. Draw the other icons UNDER skillBtn.png so its gold
	# frame masks the square logo corners and keeps the ornament unobstructed.
	var has_icon := icon_kind == "active" or icon_kind == "ultimate" or icon_kind == "drag" or icon_kind == "guard" or icon_kind == "weapon"
	if has_icon:
		_draw_skill_icon(center, radius, icon_kind, ring_color, enabled)
	_draw_texture_centered(button_texture, center, button_size, button_modulate)
	if not title.is_empty():
		var title_size := 15 if radius <= 50.0 else 17
		var title_y := center.y + radius - 2.0 if has_icon else center.y + 6.0
		var title_at := Vector2(center.x - radius, title_y)
		draw_string_outline(font, title_at, title, HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, title_size, 3, Color("152022"))
		draw_string(font, title_at, title, HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, title_size, Color("f0ddb0") if enabled else Color("929b9d"))
	if not subtitle.is_empty() and radius >= 45.0:
		var subtitle_width := clampf(maxf(42.0, float(subtitle.length()) * 7.0 + 8.0), 42.0, radius * 1.75)
		var subtitle_y := center.y + radius + 14.0 if has_icon else center.y + 27.0
		var subtitle_at := Vector2(center.x - subtitle_width * 0.5, subtitle_y)
		draw_string_outline(font, subtitle_at, subtitle, HORIZONTAL_ALIGNMENT_CENTER, subtitle_width, 11, 3, Color("152022"))
		draw_string(font, subtitle_at, subtitle, HORIZONTAL_ALIGNMENT_CENTER, subtitle_width, 11, Color("d5e5df") if enabled else Color("7d898d"))
	if enabled:
		draw_arc(center, radius + 4.0, -PI * 0.88, PI * 0.15, 28, _alpha(Color("f4d58d"), pulse * 0.82), 1.5)

func _draw_skill_icon(center: Vector2, radius: float, icon_kind: String, accent: Color, enabled: bool) -> void:
	var icon_modulate := Color.WHITE if enabled else Color(0.55, 0.60, 0.61, 0.86)
	match icon_kind:
		"guard":
			# Match the shield to the transparent well in skillBtn.png.
			_draw_texture_centered(SHIELD_TEXTURE, center, Vector2(radius * 1.74, radius * 1.74), icon_modulate)
		"weapon":
			var icon_color := Color("f3dfaa") if enabled else Color("7d898d")
			var icon_shadow := Color(0.02, 0.03, 0.035, 0.82)
			if player != null and player.is_bow_stance():
				_draw_bow_icon(center, clampf(radius / 58.0, 0.62, 1.15) * 0.62, icon_color, icon_shadow)
			else:
				_draw_sword_icon(center, clampf(radius / 58.0, 0.62, 1.15) * 0.62, icon_color, icon_shadow)
		_:
			var skill_index := 0
			var skill_hero_id := player.hero_id if player != null else "guan_yu"
			if icon_kind == "active":
				skill_index = HERO_CATALOG.skill_icon_file_index("主动")
			elif icon_kind == "ultimate":
				skill_index = HERO_CATALOG.skill_icon_file_index("无双")
			elif icon_kind == "drag":
				skill_hero_id = "guan_yu"
				skill_index = HERO_CATALOG.skill_icon_file_index("普攻")
			var texture := _hero_skill_texture(skill_hero_id, skill_index)
			if texture != null:
				# Fill the transparent center while keeping the logo proportional.
				var icon_size := Vector2(radius * 1.78, radius * 1.78)
				_draw_texture_centered(texture, center, icon_size, icon_modulate)

func _hero_skill_texture(hero_id: String, skill_index: int) -> Texture2D:
	var names := {
		"guan_yu": "guanyu",
		"zhang_fei": "zhangfei",
		"zhao_yun": "zhaoyun",
		"ma_chao": "machao",
	}
	var stem := str(names.get(hero_id, ""))
	if stem.is_empty() or skill_index <= 0:
		return null
	var cache_key := "%s:%d" % [hero_id, skill_index]
	if battle_skill_textures.has(cache_key):
		return battle_skill_textures[cache_key] as Texture2D
	var icon_path := "res://assets/art/ui/hero_skills/%s%d.png" % [stem, skill_index]
	var texture := load(icon_path) as Texture2D if ResourceLoader.exists(icon_path) else null
	battle_skill_textures[cache_key] = texture
	return texture

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
