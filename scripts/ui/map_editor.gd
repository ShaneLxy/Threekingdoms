class_name MapEditor
extends Control

const BATTLEFIELD_LAYOUT = preload("res://scripts/domain/battlefield_layout.gd")
const MAP_RECT := Rect2(252.0, 92.0, 1000.0, 568.0)
const PALETTE_PAGE_SIZE := 8
const PANEL_FILL := Color("10191f")
const PANEL_INNER := Color("18242b")
const GOLD := Color("d5af66")
const GOLD_BRIGHT := Color("f4d58d")
const DRAGON_BLUE := Color("63b9df")
const MUTED := Color("829099")
const OBSTACLE_RED := Color("d75d4c")
var objects: Array[Dictionary] = []
var collision_zones: Array[Rect2] = []
var current_battlefield_id := "xinye"
var selected_index := -1
var selected_zone_index := -1
var placement_asset_id := ""
var dragging := false
var collision_mode := false
var drawing_zone := false
var resizing_zone := false
var moving_zone := false
var zone_start_local := Vector2.ZERO
var zone_press_local := Vector2.ZERO
var zone_original := Rect2()
var zone_preview := Rect2()
var notice := ""
var notice_time := 0.0
var map_dirty := false
var palette_group := "map"
var palette_page := 0
var palette_buttons: Array[Button] = []
var toolbar_controls: Array[Control] = []
var selected_info_label: Label
var delete_button: Button
var battlefield_selector: OptionButton
var palette_title: Label
var palette_description: Label
var map_assets_button: Button
var common_assets_button: Button
var other_assets_button: Button
var previous_palette_button: Button
var next_palette_button: Button
var collision_mode_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	current_battlefield_id = BATTLEFIELD_LAYOUT.canonical_id(SceneRouter.active_battlefield_id)
	_load_map()
	_build_controls()
	queue_redraw()

func _process(delta: float) -> void:
	if notice_time > 0.0:
		notice_time = maxf(0.0, notice_time - delta)
		queue_redraw()

func _build_controls() -> void:
	var back := _make_button("返回首页", Vector2(18.0, 18.0), Vector2(126.0, 42.0), Callable(self, "_go_home"), 15)
	battlefield_selector = OptionButton.new()
	battlefield_selector.position = Vector2(156.0, 18.0)
	battlefield_selector.size = Vector2(184.0, 42.0)
	battlefield_selector.add_theme_font_size_override("font_size", 15)
	battlefield_selector.add_theme_color_override("font_color", Color("f2e5c4"))
	battlefield_selector.add_theme_stylebox_override("normal", _box(PANEL_FILL, GOLD, 2.0))
	var battlefield_ids := BATTLEFIELD_LAYOUT.editable_ids()
	for index in range(battlefield_ids.size()):
		var battlefield_id := battlefield_ids[index]
		battlefield_selector.add_item(BATTLEFIELD_LAYOUT.title_for(battlefield_id))
		if battlefield_id == current_battlefield_id:
			battlefield_selector.select(index)
	battlefield_selector.item_selected.connect(_switch_battlefield)
	add_child(battlefield_selector)
	var reset := _make_button("重置样板", Vector2(352.0, 18.0), Vector2(102.0, 42.0), Callable(self, "_reset_map"), 14)
	var save := _make_button("保存本地", Vector2(464.0, 18.0), Vector2(104.0, 42.0), Callable(self, "_save_map"), 14)
	var publish := _make_button("发布默认", Vector2(578.0, 18.0), Vector2(104.0, 42.0), Callable(self, "_publish_default_map"), 14)
	var select := _make_button("选择模式", Vector2(692.0, 18.0), Vector2(100.0, 42.0), Callable(self, "_select_mode"), 14)
	collision_mode_button = _make_button("绘制阻挡区", Vector2(802.0, 18.0), Vector2(110.0, 42.0), Callable(self, "_toggle_collision_mode"), 14)
	var cancel_place := _make_button("取消操作", Vector2(922.0, 18.0), Vector2(100.0, 42.0), Callable(self, "_cancel_placement"), 14)
	var zoom_out := _make_button("缩小", Vector2(1032.0, 18.0), Vector2(64.0, 42.0), Callable(self, "_scale_selected").bind(-0.1), 14)
	var zoom_in := _make_button("放大", Vector2(1104.0, 18.0), Vector2(64.0, 42.0), Callable(self, "_scale_selected").bind(0.1), 14)
	delete_button = _make_button("删除", Vector2(1176.0, 18.0), Vector2(72.0, 42.0), Callable(self, "_delete_selected"), 14)
	delete_button.add_theme_color_override("font_color", Color("f0b2a5"))
	delete_button.add_theme_color_override("font_disabled_color", Color("6d7377"))
	delete_button.add_theme_stylebox_override("normal", _box(Color("321d1d"), Color("bc5a4f"), 2.0))
	delete_button.add_theme_stylebox_override("hover", _box(Color("452222"), Color("ef8271"), 3.0))
	for control in [back, battlefield_selector, reset, save, publish, select, collision_mode_button, cancel_place, zoom_out, zoom_in, delete_button]:
		toolbar_controls.append(control)
	_create_palette()
	selected_info_label = Label.new()
	selected_info_label.position = Vector2(18.0, 650.0)
	selected_info_label.size = Vector2(1220.0, 28.0)
	selected_info_label.add_theme_font_size_override("font_size", 14)
	selected_info_label.add_theme_color_override("font_color", Color("c8d5d4"))
	add_child(selected_info_label)
	_update_selected_info()

func _create_palette() -> void:
	palette_title = Label.new()
	palette_title.position = Vector2(18.0, 88.0)
	palette_title.size = Vector2(214.0, 28.0)
	palette_title.add_theme_font_size_override("font_size", 21)
	palette_title.add_theme_color_override("font_color", GOLD_BRIGHT)
	add_child(palette_title)
	palette_description = Label.new()
	palette_description.position = Vector2(18.0, 116.0)
	palette_description.size = Vector2(214.0, 34.0)
	palette_description.text = "地皮已自动组合 · 选择建筑或装饰后放置"
	palette_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	palette_description.add_theme_font_size_override("font_size", 12)
	palette_description.add_theme_color_override("font_color", MUTED)
	add_child(palette_description)
	map_assets_button = _make_button("本图", Vector2(18.0, 158.0), Vector2(66.0, 34.0), Callable(self, "_set_palette_group").bind("map"), 13)
	common_assets_button = _make_button("公共", Vector2(92.0, 158.0), Vector2(66.0, 34.0), Callable(self, "_set_palette_group").bind("common"), 13)
	other_assets_button = _make_button("跨图", Vector2(166.0, 158.0), Vector2(66.0, 34.0), Callable(self, "_set_palette_group").bind("other"), 13)
	previous_palette_button = _make_button("上一页", Vector2(18.0, 566.0), Vector2(102.0, 36.0), Callable(self, "_page_palette").bind(-1), 13)
	next_palette_button = _make_button("下一页", Vector2(130.0, 566.0), Vector2(102.0, 36.0), Callable(self, "_page_palette").bind(1), 13)
	_rebuild_palette_buttons()

func _palette_assets() -> Array[Dictionary]:
	if palette_group == "common":
		return BATTLEFIELD_LAYOUT.editor_asset_definitions_for(current_battlefield_id, true)
	if palette_group == "other":
		return BATTLEFIELD_LAYOUT.other_battlefield_asset_definitions_for(current_battlefield_id)
	return BATTLEFIELD_LAYOUT.editor_asset_definitions_for(current_battlefield_id, false)

func _rebuild_palette_buttons() -> void:
	for button in palette_buttons:
		if is_instance_valid(button):
			button.queue_free()
	palette_buttons.clear()
	var assets := _palette_assets()
	var page_count := maxi(1, ceili(float(assets.size()) / float(PALETTE_PAGE_SIZE)))
	palette_page = clampi(palette_page, 0, page_count - 1)
	var first_index := palette_page * PALETTE_PAGE_SIZE
	var last_index := mini(assets.size(), first_index + PALETTE_PAGE_SIZE)
	for index in range(first_index, last_index):
		var asset := assets[index]
		var button_index := index - first_index
		var button := _make_button(str(asset.get("label", "素材")), Vector2(18.0, 204.0 + float(button_index) * 44.0), Vector2(214.0, 38.0), Callable(self, "_choose_asset").bind(str(asset.get("id", ""))), 13)
		button.icon = load(str(asset.get("path", ""))) as Texture2D
		button.expand_icon = true
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		palette_buttons.append(button)
	if palette_title != null:
		palette_title.text = "公共素材库" if palette_group == "common" else ("跨图素材库" if palette_group == "other" else "本图专属素材")
	if palette_description != null:
		palette_description.text = "%s · 地皮自动组合，仅编辑建筑、装饰和阻挡区" % BATTLEFIELD_LAYOUT.title_for(current_battlefield_id)
	if map_assets_button != null:
		map_assets_button.disabled = palette_group == "map"
	if common_assets_button != null:
		common_assets_button.disabled = palette_group == "common"
	if other_assets_button != null:
		other_assets_button.disabled = palette_group == "other"
	if previous_palette_button != null:
		previous_palette_button.disabled = palette_page <= 0
	if next_palette_button != null:
		next_palette_button.disabled = palette_page >= page_count - 1

func _set_palette_group(group: String) -> void:
	if group not in ["map", "common", "other"] or palette_group == group:
		return
	palette_group = group
	palette_page = 0
	placement_asset_id = ""
	_rebuild_palette_buttons()
	_update_selected_info()
	queue_redraw()

func _page_palette(delta: int) -> void:
	palette_page = maxi(0, palette_page + delta)
	_rebuild_palette_buttons()

func _switch_battlefield(index: int) -> void:
	var battlefield_ids := BATTLEFIELD_LAYOUT.editable_ids()
	if index < 0 or index >= battlefield_ids.size():
		return
	var next_battlefield_id := battlefield_ids[index]
	if next_battlefield_id == current_battlefield_id:
		return
	if map_dirty:
		_save_map(false)
	current_battlefield_id = next_battlefield_id
	objects.clear()
	collision_zones.clear()
	selected_index = -1
	selected_zone_index = -1
	placement_asset_id = ""
	collision_mode = false
	palette_group = "map"
	palette_page = 0
	map_dirty = false
	_load_map()
	_update_mode_button()
	_rebuild_palette_buttons()
	_set_notice("已切换至%s" % BATTLEFIELD_LAYOUT.title_for(current_battlefield_id))
	_update_selected_info()
	queue_redraw()

func _make_button(title: String, at: Vector2, button_size: Vector2, callback: Callable, font_size: int) -> Button:
	var button := Button.new()
	button.text = title
	button.position = at
	button.size = button_size
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color("f2e5c4"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _box(PANEL_FILL, GOLD, 2.0))
	button.add_theme_stylebox_override("hover", _box(Color("1a2b33"), DRAGON_BLUE, 3.0))
	button.add_theme_stylebox_override("pressed", _box(Color("2e291d"), GOLD_BRIGHT, 3.0))
	button.pressed.connect(callback)
	add_child(button)
	return button

func _box(fill: Color, border: Color, width: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(int(width))
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style

func _choose_asset(asset_id: String) -> void:
	collision_mode = false
	_update_mode_button()
	placement_asset_id = asset_id
	selected_index = -1
	selected_zone_index = -1
	_set_notice("已选择%s，点击地图放置" % _asset_label(asset_id))
	_update_selected_info()
	queue_redraw()

func _select_mode() -> void:
	collision_mode = false
	placement_asset_id = ""
	selected_zone_index = -1
	_update_mode_button()
	_set_notice("选择模式：点击地图素材后可拖动、缩放或删除")
	_update_selected_info()
	queue_redraw()

func _toggle_collision_mode() -> void:
	collision_mode = not collision_mode
	placement_asset_id = ""
	selected_index = -1
	selected_zone_index = -1
	drawing_zone = false
	moving_zone = false
	resizing_zone = false
	_update_mode_button()
	_set_notice("阻挡区模式：拖动绘制矩形，可选择、移动、调整大小或删除" if collision_mode else "已返回素材选择模式")
	_update_selected_info()
	queue_redraw()

func _update_mode_button() -> void:
	if collision_mode_button == null:
		return
	collision_mode_button.text = "返回素材模式" if collision_mode else "绘制阻挡区"
	collision_mode_button.disabled = false

func _cancel_placement() -> void:
	placement_asset_id = ""
	drawing_zone = false
	moving_zone = false
	resizing_zone = false
	_set_notice("已取消摆放")
	_update_selected_info()
	queue_redraw()

func _scale_selected(amount: float) -> void:
	if collision_mode:
		if selected_zone_index < 0 or selected_zone_index >= collision_zones.size():
			_set_notice("请先选择一个阻挡区域")
			return
		var zone := collision_zones[selected_zone_index]
		var delta := 8.0 if amount > 0.0 else -8.0
		zone = zone.grow(delta)
		if zone.size.x >= 16.0 and zone.size.y >= 16.0:
			collision_zones[selected_zone_index] = _clamp_zone(zone)
			map_dirty = true
		_update_selected_info()
		queue_redraw()
		return
	if selected_index < 0 or selected_index >= objects.size():
		_set_notice("请先选择一个地图素材")
		return
	var current_scale := float(objects[selected_index].get("scale", 1.0))
	objects[selected_index]["scale"] = clampf(current_scale + amount, 0.35, 2.2)
	map_dirty = true
	_update_selected_info()
	queue_redraw()

func _delete_selected() -> void:
	if collision_mode:
		if selected_zone_index < 0 or selected_zone_index >= collision_zones.size():
			_set_notice("请先选择一个阻挡区域")
			return
		collision_zones.remove_at(selected_zone_index)
		selected_zone_index = -1
		drawing_zone = false
		map_dirty = true
		_set_notice("已删除阻挡区域")
		_update_selected_info()
		queue_redraw()
		return
	if selected_index < 0 or selected_index >= objects.size():
		_set_notice("请先选择一个地图素材")
		return
	objects.remove_at(selected_index)
	map_dirty = true
	selected_index = -1
	placement_asset_id = ""
	_set_notice("已删除素材")
	_update_selected_info()
	queue_redraw()

func _go_home() -> void:
	if map_dirty:
		_save_map(false)
	SceneRouter.go_home()

func _set_notice(value: String) -> void:
	notice = value
	notice_time = 3.0

func _asset_definition(asset_id: String) -> Dictionary:
	return BATTLEFIELD_LAYOUT.asset_definition_for(current_battlefield_id, asset_id)

func _asset_label(asset_id: String) -> String:
	return str(_asset_definition(asset_id).get("label", "素材"))

func _texture_for(asset_id: String) -> Texture2D:
	return load(str(_asset_definition(asset_id).get("path", ""))) as Texture2D

func _load_map() -> void:
	objects = BATTLEFIELD_LAYOUT.objects_for(current_battlefield_id)
	collision_zones = BATTLEFIELD_LAYOUT.collision_zones_for(current_battlefield_id)

func _reset_map() -> void:
	objects = BATTLEFIELD_LAYOUT.default_objects_for(current_battlefield_id)
	collision_zones = BATTLEFIELD_LAYOUT.default_collision_zones_for(current_battlefield_id)
	selected_index = -1
	selected_zone_index = -1
	placement_asset_id = ""
	collision_mode = false
	_update_mode_button()
	map_dirty = true
	_set_notice("已恢复%s内置样板，保存本地或发布默认地图" % BATTLEFIELD_LAYOUT.title_for(current_battlefield_id))
	_update_selected_info()
	queue_redraw()

func _save_map(show_notice: bool = true) -> bool:
	if not BATTLEFIELD_LAYOUT.save_map_for(current_battlefield_id, objects, collision_zones):
		if show_notice:
			_set_notice("地图保存失败")
		return false
	map_dirty = false
	if show_notice:
		_set_notice("%s地图已保存到本机" % BATTLEFIELD_LAYOUT.title_for(current_battlefield_id))
	return true

func _publish_default_map() -> void:
	if not BATTLEFIELD_LAYOUT.can_publish_default_maps():
		_set_notice("正式发布版不可修改内置地图")
		return
	if not _save_map(false):
		_set_notice("本地地图保存失败，未发布")
		return
	if not BATTLEFIELD_LAYOUT.publish_default_map_for(current_battlefield_id, objects, collision_zones):
		_set_notice("内置地图发布失败")
		return
	map_dirty = false
	_set_notice("已发布%s默认地图，下一次打包将包含此布局" % BATTLEFIELD_LAYOUT.title_for(current_battlefield_id))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			if MAP_RECT.has_point(mouse_event.position):
				_handle_map_press(mouse_event.position)
				accept_event()
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			if collision_mode:
				_handle_zone_release(mouse_event.position)
			dragging = false
			accept_event()
		elif MAP_RECT.has_point(mouse_event.position) and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_scale_selected(0.08)
			accept_event()
		elif MAP_RECT.has_point(mouse_event.position) and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_scale_selected(-0.08)
			accept_event()
	elif event is InputEventMouseMotion and dragging:
		_handle_drag_motion((event as InputEventMouseMotion).position)
		accept_event()
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			if MAP_RECT.has_point(touch_event.position):
				_handle_map_press(touch_event.position)
				accept_event()
		else:
			if collision_mode:
				_handle_zone_release(touch_event.position)
			dragging = false
			accept_event()
	elif event is InputEventScreenDrag and dragging:
		_handle_drag_motion((event as InputEventScreenDrag).position)
		accept_event()

func _handle_drag_motion(at: Vector2) -> void:
	if collision_mode:
		_handle_zone_motion(at)
		return
	if selected_index >= 0 and selected_index < objects.size():
		var local := _map_local_position(at)
		objects[selected_index]["position"] = Vector2(clampf(local.x, 28.0, MAP_RECT.size.x - 28.0), clampf(local.y, 28.0, MAP_RECT.size.y - 28.0))
		map_dirty = true
		_update_selected_info()
		queue_redraw()

func _handle_map_press(at: Vector2) -> void:
	if collision_mode:
		_handle_zone_press(at)
		return
	if not placement_asset_id.is_empty():
		var local := _map_local_position(at)
		var asset: Dictionary = _asset_definition(placement_asset_id)
		objects.append({"id": placement_asset_id, "position": local, "scale": float(asset.get("default_scale", 1.0)), "obstacle": false})
		selected_index = objects.size() - 1
		map_dirty = true
		_set_notice("已放置%s，可继续拖动或缩放" % _asset_label(placement_asset_id))
		_update_selected_info()
		queue_redraw()
		return
	selected_index = _hit_test(at)
	dragging = selected_index >= 0
	if selected_index >= 0:
		_set_notice("已选择%s" % _asset_label(str(objects[selected_index].get("id", ""))))
	else:
		_set_notice("未选中素材")
	_update_selected_info()
	queue_redraw()

func _handle_zone_press(at: Vector2) -> void:
	var local := _map_local_position(at)
	var hit := _zone_hit_test(at)
	if hit >= 0:
		selected_zone_index = hit
		selected_index = -1
		zone_original = collision_zones[hit]
		zone_press_local = local
		var screen_rect := _zone_screen_rect(zone_original)
		resizing_zone = _zone_resize_handle(screen_rect).has_point(at)
		moving_zone = not resizing_zone
		dragging = true
		_set_notice("已选择阻挡区域，可拖动移动；拖右下角调整大小")
	else:
		selected_zone_index = -1
		selected_index = -1
		zone_start_local = local
		zone_preview = Rect2(local, Vector2.ZERO)
		drawing_zone = true
		dragging = true
		_set_notice("正在绘制阻挡区域，拖动后松开完成")
	_update_selected_info()
	queue_redraw()

func _handle_zone_motion(at: Vector2) -> void:
	var local := _map_local_position(at)
	if drawing_zone:
		zone_preview = Rect2(zone_start_local, local - zone_start_local).abs()
		_update_selected_info()
		queue_redraw()
		return
	if selected_zone_index < 0 or selected_zone_index >= collision_zones.size():
		return
	var delta := local - zone_press_local
	if moving_zone:
		var moved := zone_original
		moved.position += delta
		collision_zones[selected_zone_index] = _clamp_zone(moved)
	elif resizing_zone:
		var resized := Rect2(zone_original.position, local - zone_original.position).abs()
		resized.size.x = maxf(16.0, resized.size.x)
		resized.size.y = maxf(16.0, resized.size.y)
		collision_zones[selected_zone_index] = _clamp_zone(resized)
	map_dirty = true
	_update_selected_info()
	queue_redraw()

func _handle_zone_release(at: Vector2) -> void:
	if not collision_mode:
		return
	if drawing_zone:
		var local := _map_local_position(at)
		var completed := Rect2(zone_start_local, local - zone_start_local).abs()
		if completed.size.x >= 16.0 and completed.size.y >= 16.0:
			collision_zones.append(_clamp_zone(completed))
			selected_zone_index = collision_zones.size() - 1
			map_dirty = true
			_set_notice("已新增阻挡区域，可继续调整或保存")
		else:
			_set_notice("阻挡区域太小，已取消")
		drawing_zone = false
	zone_preview = Rect2()
	moving_zone = false
	resizing_zone = false
	_update_selected_info()
	queue_redraw()

func _map_local_position(at: Vector2) -> Vector2:
	return Vector2(clampf(at.x - MAP_RECT.position.x, 0.0, MAP_RECT.size.x), clampf(at.y - MAP_RECT.position.y, 0.0, MAP_RECT.size.y))

func _hit_test(at: Vector2) -> int:
	for index in range(objects.size() - 1, -1, -1):
		if not BATTLEFIELD_LAYOUT.is_editor_editable_asset(current_battlefield_id, str(objects[index].get("id", ""))):
			continue
		if _object_visual_rect(objects[index]).grow(8.0).has_point(at):
			return index
	return -1

func _zone_hit_test(at: Vector2) -> int:
	for index in range(collision_zones.size() - 1, -1, -1):
		if _zone_screen_rect(collision_zones[index]).grow(8.0).has_point(at):
			return index
	return -1

func _zone_screen_rect(zone: Rect2) -> Rect2:
	return Rect2(MAP_RECT.position + zone.position, zone.size)

func _zone_resize_handle(rect: Rect2) -> Rect2:
	return Rect2(rect.end - Vector2(14.0, 14.0), Vector2(28.0, 28.0))

func _clamp_zone(zone: Rect2) -> Rect2:
	var normalized := zone.abs()
	var position := Vector2(
		clampf(normalized.position.x, 0.0, MAP_RECT.size.x - normalized.size.x),
		clampf(normalized.position.y, 0.0, MAP_RECT.size.y - normalized.size.y)
	)
	var size := Vector2(
		minf(normalized.size.x, MAP_RECT.size.x),
		minf(normalized.size.y, MAP_RECT.size.y)
	)
	return Rect2(position, size)

func _update_selected_info() -> void:
	if delete_button != null:
		delete_button.disabled = (selected_zone_index < 0 or selected_zone_index >= collision_zones.size()) if collision_mode else (selected_index < 0 or selected_index >= objects.size())
	if selected_info_label == null:
		return
	if not placement_asset_id.is_empty():
		selected_info_label.text = "摆放模式：%s · 点击地图添加 · 鼠标滚轮可缩放已选素材" % _asset_label(placement_asset_id)
		return
	if collision_mode:
		if drawing_zone:
			selected_info_label.text = "绘制阻挡区域 · 松开鼠标完成 · 所有单位均不可穿过该区域"
		elif selected_zone_index >= 0 and selected_zone_index < collision_zones.size():
			var zone := collision_zones[selected_zone_index]
			selected_info_label.text = "已选阻挡区域 #%d · %.0f × %.0f · 拖动移动，拖右下角调整大小，手机可用删除按钮" % [selected_zone_index + 1, zone.size.x, zone.size.y]
		else:
			selected_info_label.text = "阻挡区模式 · 拖动空白处绘制矩形 · 空地也可以设置为不可通行"
		return
	if selected_index < 0 or selected_index >= objects.size():
		selected_info_label.text = "选择模式 · 点击素材进行编辑 · 选中后可拖动、缩放或删除"
		return
	var object: Dictionary = objects[selected_index]
	selected_info_label.text = "已选：%s · 纯视觉素材 · 缩放 %.2fx · 碰撞请切换到阻挡区模式单独绘制" % [_asset_label(str(object.get("id", ""))), float(object.get("scale", 1.0))]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_ESCAPE:
			_cancel_placement()
		elif key_event.keycode == KEY_DELETE:
			_delete_selected()

func _object_visual_rect(object: Dictionary) -> Rect2:
	var texture: Texture2D = _texture_for(str(object.get("id", "")))
	if texture == null:
		return Rect2()
	var source_size := texture.get_size()
	var max_dimension := maxf(1.0, maxf(source_size.x, source_size.y))
	var base_scale := 190.0 / max_dimension
	var display_size := source_size * base_scale * float(object.get("scale", 1.0))
	var center: Vector2 = MAP_RECT.position + (object.get("position", Vector2.ZERO) as Vector2)
	return Rect2(center - display_size * 0.5, display_size)

func _draw() -> void:
	var background := Rect2(Vector2.ZERO, size)
	draw_texture_rect(preload("res://assets/art/ui/backgrounds/bg.png"), background, false, Color(0.78, 0.78, 0.78, 0.94))
	draw_rect(background, Color(0.02, 0.025, 0.03, 0.62))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(166.0, 47.0), "%s · 地图编辑器" % BATTLEFIELD_LAYOUT.title_for(current_battlefield_id), HORIZONTAL_ALIGNMENT_LEFT, -1, 25, GOLD_BRIGHT)
	draw_string(font, Vector2(166.0, 70.0), "地皮自动组合 · 建筑仅作背景 · 发布默认地图后将随 APK 一同打包", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("a9c2c7"))
	_draw_palette_panel()
	_draw_map_canvas(font)
	if notice_time > 0.0 and not notice.is_empty():
		draw_string(font, Vector2(420.0, 690.0), notice, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("9ee0c6"))

func _draw_palette_panel() -> void:
	draw_rect(Rect2(12.0, 78.0, 226.0, 558.0), Color("0b1318", 0.88))
	draw_rect(Rect2(12.0, 78.0, 226.0, 558.0), Color("42606a"), false, 1.0)

func _draw_map_canvas(font: Font) -> void:
	draw_rect(MAP_RECT.grow(4.0), Color("0b1115", 0.95))
	_draw_auto_ground_layers(MAP_RECT)
	draw_rect(MAP_RECT, Color("d5af66", 0.85), false, 2.0)
	for x in range(0, int(MAP_RECT.size.x) + 1, 64):
		draw_line(MAP_RECT.position + Vector2(x, 0), MAP_RECT.position + Vector2(x, MAP_RECT.size.y), Color(1.0, 1.0, 1.0, 0.05), 1.0)
	for y in range(0, int(MAP_RECT.size.y) + 1, 64):
		draw_line(MAP_RECT.position + Vector2(0, y), MAP_RECT.position + Vector2(MAP_RECT.size.x, y), Color(1.0, 1.0, 1.0, 0.05), 1.0)
	var order: Array[int] = []
	for index in range(objects.size()):
		order.append(index)
	order.sort_custom(Callable(self, "_sort_object_indices"))
	for index in order:
		_draw_object(index)
	_draw_collision_zones()
	draw_string(font, MAP_RECT.position + Vector2(14.0, 26.0), "地皮：%s" % BATTLEFIELD_LAYOUT.ground_summary_for(current_battlefield_id), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("e6d4a6"))

func _draw_auto_ground_layers(target: Rect2) -> void:
	var drew_base := false
	for layer in BATTLEFIELD_LAYOUT.ground_layers_for(current_battlefield_id):
		var texture := load(str(layer.get("path", ""))) as Texture2D
		if texture == null:
			continue
		var tint := Color(str(layer.get("tint", "ffffff")))
		tint.a = clampf(float(layer.get("opacity", 1.0)), 0.0, 1.0)
		var role := str(layer.get("role", "blend"))
		if role == "base":
			draw_texture_rect(texture, target, true, tint)
			drew_base = true
			continue
		if role == "blend":
			draw_texture_rect(texture, target, true, tint)
			continue
		var regions: Array = layer.get("regions", []) as Array
		for raw_region in regions:
			if not raw_region is Rect2:
				continue
			var region := raw_region as Rect2
			var region_rect := Rect2(target.position + target.size * region.position, target.size * region.size)
			draw_texture_rect(texture, region_rect, true, tint)
	if not drew_base:
		draw_rect(target, Color("31372a"))

func _sort_object_indices(first: int, second: int) -> bool:
	return float(objects[first].get("position", Vector2.ZERO).y) < float(objects[second].get("position", Vector2.ZERO).y)

func _draw_object(index: int) -> void:
	var object: Dictionary = objects[index]
	var texture: Texture2D = _texture_for(str(object.get("id", "")))
	if texture == null:
		return
	var visual_rect := _object_visual_rect(object)
	draw_texture_rect(texture, visual_rect, false, Color.WHITE)
	if index == selected_index:
		draw_rect(visual_rect.grow(4.0), GOLD_BRIGHT, false, 2.0)
		draw_string(ThemeDB.fallback_font, visual_rect.position + Vector2(0.0, -8.0), "素材", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("c0d1d0"))

func _draw_collision_zones() -> void:
	for index in range(collision_zones.size()):
		var rect := _zone_screen_rect(collision_zones[index])
		var selected := collision_mode and index == selected_zone_index
		draw_rect(rect, Color(0.78, 0.18, 0.14, 0.27 if selected else 0.18))
		draw_rect(rect, Color("ef7563") if selected else OBSTACLE_RED, false, 3.0 if selected else 2.0)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(6.0, 17.0), "阻挡区 %d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("ffe0bf"))
		if selected:
			var handle := _zone_resize_handle(rect)
			draw_rect(handle, Color("f4d58d", 0.9))
			draw_rect(handle, Color("5b3f22"), false, 2.0)
