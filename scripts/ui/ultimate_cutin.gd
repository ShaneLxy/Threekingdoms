class_name UltimateCutin
extends Control

signal finished()

const ENTRY_DURATION := 0.08
const HOLD_DURATION := 0.34
const EXIT_DURATION := 0.08
const DURATION := ENTRY_DURATION + HOLD_DURATION + EXIT_DURATION
const COMBAT_TIME_SCALE := 0.20
const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")

var elapsed := 0.0
var active := false
var enters_from_top := true
var portrait: Texture2D
var active_hero_id := ""
var active_hero_name := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

func play(hero_id: String) -> void:
	active_hero_id = hero_id
	active_hero_name = HERO_CATALOG.display_name_for(hero_id)
	var portrait_path := HERO_CATALOG.ultimate_cutin_for(hero_id)
	portrait = load(portrait_path) as Texture2D if not portrait_path.is_empty() else null
	elapsed = 0.0
	active = true
	enters_from_top = randi() % 2 == 0
	visible = true
	queue_redraw()

func is_playing() -> bool:
	return active

func cancel() -> void:
	if not active:
		return
	active = false
	visible = false
	queue_redraw()

func combat_time_scale() -> float:
	if not active:
		return 1.0
	if elapsed < ENTRY_DURATION + HOLD_DURATION:
		return COMBAT_TIME_SCALE
	var recovery := clampf((elapsed - ENTRY_DURATION - HOLD_DURATION) / EXIT_DURATION, 0.0, 1.0)
	return lerpf(COMBAT_TIME_SCALE, 1.0, recovery)

func _process(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	if elapsed >= DURATION:
		active = false
		visible = false
		finished.emit()
		return
	queue_redraw()

func _draw() -> void:
	if not active:
		return
	_draw_portrait()

func _draw_portrait() -> void:
	if portrait == null:
		_draw_placeholder_portrait()
		return
	var banner_height := size.y * 1.18
	var banner_size := portrait.get_size() * (banner_height / portrait.get_height())
	var banner_position := Vector2(size.x * 0.60 - banner_size.x * 0.5, _banner_y(banner_size.y))
	var banner := Rect2(banner_position, banner_size)
	var opacity := _banner_opacity()
	draw_texture_rect(portrait, banner, false, Color(1.0, 1.0, 1.0, opacity))
	var movement_sign := 1.0 if enters_from_top else -1.0
	for index in range(3):
		var x := banner.position.x - 20.0 + float(index) * 22.0
		var start := Vector2(x, banner.position.y - movement_sign * (52.0 + float(index) * 18.0))
		var end := start + Vector2(0, movement_sign * (76.0 + float(index) * 14.0))
		draw_line(start, end, Color(0.66, 0.92, 1.0, opacity * (0.48 - float(index) * 0.09)), 2.0)

func _draw_placeholder_portrait() -> void:
	var banner_size := Vector2(size.x * 0.31, size.y * 1.18)
	var banner_position := Vector2(size.x * 0.60 - banner_size.x * 0.5, _banner_y(banner_size.y))
	var banner := Rect2(banner_position, banner_size)
	var opacity := _banner_opacity()
	var outer := PackedVector2Array([
		banner.position + Vector2(18, 0), banner.position + Vector2(banner.size.x - 28, 0),
		banner.position + Vector2(banner.size.x, 48), banner.position + Vector2(banner.size.x - 12, banner.size.y * 0.34),
		banner.position + Vector2(banner.size.x, banner.size.y - 74), banner.position + Vector2(banner.size.x - 38, banner.size.y),
		banner.position + Vector2(26, banner.size.y), banner.position + Vector2(0, banner.size.y - 54),
		banner.position + Vector2(12, banner.size.y * 0.58), banner.position + Vector2(0, 72),
	])
	draw_colored_polygon(outer, Color(0.05, 0.16, 0.14, opacity * 0.94))
	var inner := banner.grow_individual(-18.0, -22.0, -18.0, -22.0)
	draw_rect(inner, Color(0.10, 0.36, 0.28, opacity * 0.90))
	for index in range(6):
		var y := inner.position.y + 28.0 + float(index) * 62.0
		draw_line(Vector2(inner.position.x + 8.0, y), Vector2(inner.end.x - 8.0, y - 18.0), Color(0.24, 0.68, 0.47, opacity * 0.22), 2.0)
	var center := Vector2(inner.get_center().x, inner.position.y + inner.size.y * 0.48)
	draw_circle(center + Vector2(0, -62), 34.0, Color(0.84, 0.73, 0.56, opacity))
	var robe := PackedVector2Array([
		center + Vector2(-86, 86), center + Vector2(-58, -18), center + Vector2(-18, -42),
		center + Vector2(25, -42), center + Vector2(70, -14), center + Vector2(102, 86),
	])
	draw_colored_polygon(robe, Color(0.06, 0.29, 0.20, opacity))
	draw_line(center + Vector2(-72, 42), center + Vector2(112, -116), Color(0.84, 0.72, 0.31, opacity), 13.0)
	draw_arc(center + Vector2(112, -116), 31.0, -2.90, 0.38, 12, Color(0.70, 0.91, 0.72, opacity), 9.0)
	draw_line(center + Vector2(-8, -28), center + Vector2(0, 18), Color(0.12, 0.10, 0.08, opacity), 10.0)
	draw_string(ThemeDB.fallback_font, Vector2(inner.position.x, inner.end.y - 30), active_hero_name, HORIZONTAL_ALIGNMENT_CENTER, inner.size.x, 30, Color(0.98, 0.86, 0.48, opacity))

func _banner_y(height: float) -> float:
	var rest_y := (size.y - height) * 0.5
	var entry_y := -height - 36.0 if enters_from_top else size.y + 36.0
	var exit_y := size.y + 36.0 if enters_from_top else -height - 36.0
	if elapsed < ENTRY_DURATION:
		return lerpf(entry_y, rest_y, ease(elapsed / ENTRY_DURATION, -2.4))
	if elapsed < ENTRY_DURATION + HOLD_DURATION:
		return rest_y
	var progress := ease((elapsed - ENTRY_DURATION - HOLD_DURATION) / EXIT_DURATION, 1.7)
	return lerpf(rest_y, exit_y, progress)

func _banner_opacity() -> float:
	if elapsed < ENTRY_DURATION:
		return ease(elapsed / ENTRY_DURATION, 1.5)
	if elapsed < ENTRY_DURATION + HOLD_DURATION:
		return 1.0
	if elapsed < DURATION:
		return 1.0 - ease((elapsed - ENTRY_DURATION - HOLD_DURATION) / EXIT_DURATION, 1.8)
	return 0.0
