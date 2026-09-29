class_name UltimateCutin
extends Control

signal finished()

const ENTRY_DURATION := 0.32
const HOLD_DURATION := 0.50
const NUDGE_DURATION := 0.10
const NUDGE_PAUSE_DURATION := 0.08
const EXIT_DURATION := 0.24
const DURATION := ENTRY_DURATION + HOLD_DURATION + NUDGE_DURATION + NUDGE_PAUSE_DURATION + EXIT_DURATION
const COMBAT_TIME_SCALE := 0.20
const PORTRAIT_HEIGHT_RATIO := 0.92
const PORTRAIT_SIDE_MARGIN := 48.0
const PORTRAIT_NUDGE_DISTANCE := 24.0
const HERO_CATALOG = preload("res://scripts/domain/hero_catalog.gd")

enum CutinPhase { ENTER, HOLD, NUDGE, NUDGE_PAUSE, EXIT }

var elapsed := 0.0
var active := false
var phase := CutinPhase.ENTER
var enters_from_left := true
var portrait: Texture2D
var active_hero_id := ""
var active_hero_name := ""
var portrait_size := Vector2.ZERO
var target_position := Vector2.ZERO
var entry_position := Vector2.ZERO
var nudge_position := Vector2.ZERO

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

func play(hero_id: String) -> void:
	active_hero_id = hero_id
	active_hero_name = HERO_CATALOG.display_name_for(hero_id)
	var portrait_path := HERO_CATALOG.new_portrait_for(hero_id)
	portrait = load(portrait_path) as Texture2D if not portrait_path.is_empty() else null
	enters_from_left = randf() < 0.5
	elapsed = 0.0
	phase = CutinPhase.ENTER
	active = true
	visible = true
	_recalculate_layout()
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
	if phase != CutinPhase.EXIT:
		return COMBAT_TIME_SCALE
	var exit_progress := clampf(_phase_progress(), 0.0, 1.0)
	return lerpf(COMBAT_TIME_SCALE, 1.0, exit_progress)

func _process(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	_update_phase()
	if elapsed >= DURATION:
		active = false
		visible = false
		finished.emit()
		return
	queue_redraw()

func _update_phase() -> void:
	if elapsed < ENTRY_DURATION:
		phase = CutinPhase.ENTER
	elif elapsed < ENTRY_DURATION + HOLD_DURATION:
		phase = CutinPhase.HOLD
	elif elapsed < ENTRY_DURATION + HOLD_DURATION + NUDGE_DURATION:
		phase = CutinPhase.NUDGE
	elif elapsed < ENTRY_DURATION + HOLD_DURATION + NUDGE_DURATION + NUDGE_PAUSE_DURATION:
		phase = CutinPhase.NUDGE_PAUSE
	else:
		phase = CutinPhase.EXIT

func _phase_progress() -> float:
	var phase_start := 0.0
	var phase_duration := ENTRY_DURATION
	match phase:
		CutinPhase.ENTER:
			phase_start = 0.0
			phase_duration = ENTRY_DURATION
		CutinPhase.HOLD:
			phase_start = ENTRY_DURATION
			phase_duration = HOLD_DURATION
		CutinPhase.NUDGE:
			phase_start = ENTRY_DURATION + HOLD_DURATION
			phase_duration = NUDGE_DURATION
		CutinPhase.NUDGE_PAUSE:
			phase_start = ENTRY_DURATION + HOLD_DURATION + NUDGE_DURATION
			phase_duration = NUDGE_PAUSE_DURATION
		CutinPhase.EXIT:
			phase_start = ENTRY_DURATION + HOLD_DURATION + NUDGE_DURATION + NUDGE_PAUSE_DURATION
			phase_duration = EXIT_DURATION
	return clampf((elapsed - phase_start) / maxf(0.001, phase_duration), 0.0, 1.0)

func _recalculate_layout() -> void:
	var source_size := portrait.get_size() if portrait != null else Vector2(980.0, 1280.0)
	var portrait_height := size.y * PORTRAIT_HEIGHT_RATIO
	portrait_size = source_size * (portrait_height / maxf(1.0, source_size.y))
	# Keep the final portrait close to the side it entered from.  At the old
	# 27%/73% positions the large portrait left a conspicuous empty gutter.
	var target_center_x := size.x * (0.22 if enters_from_left else 0.78)
	target_position = Vector2(target_center_x - portrait_size.x * 0.5, (size.y - portrait_size.y) * 0.5)
	var direction := 1.0 if enters_from_left else -1.0
	var entry_x := -portrait_size.x - PORTRAIT_SIDE_MARGIN if enters_from_left else size.x + PORTRAIT_SIDE_MARGIN
	entry_position = Vector2(entry_x, target_position.y)
	nudge_position = target_position + Vector2(direction * PORTRAIT_NUDGE_DISTANCE, 0.0)

func _draw() -> void:
	if not active:
		return
	_draw_portrait()

func _draw_portrait() -> void:
	var position := _portrait_position()
	var opacity := _portrait_opacity()
	if portrait == null:
		_draw_placeholder_portrait(Rect2(position, portrait_size), opacity)
		return
	draw_texture_rect(portrait, Rect2(position, portrait_size), false, Color(1.0, 1.0, 1.0, opacity))
	_draw_motion_streaks(position, opacity)

func _portrait_position() -> Vector2:
	match phase:
		CutinPhase.ENTER:
			return entry_position.lerp(target_position, ease(_phase_progress(), -2.2))
		CutinPhase.HOLD:
			return target_position
		CutinPhase.NUDGE:
			return target_position.lerp(nudge_position, ease(_phase_progress(), -1.4))
		CutinPhase.NUDGE_PAUSE:
			return nudge_position
		CutinPhase.EXIT:
			return nudge_position.lerp(entry_position, ease(_phase_progress(), 1.8))
	return target_position

func _portrait_opacity() -> float:
	if phase == CutinPhase.ENTER:
		return lerpf(0.0, 1.0, ease(_phase_progress(), -1.8))
	if phase == CutinPhase.EXIT:
		return 1.0 - ease(_phase_progress(), 1.6)
	return 1.0

func _draw_motion_streaks(position: Vector2, opacity: float) -> void:
	var direction := 1.0 if enters_from_left else -1.0
	var streak_origin := position + Vector2(-direction * 14.0, portrait_size.y * 0.22)
	for index in range(3):
		var offset := Vector2(0.0, float(index) * 22.0)
		var start := streak_origin - Vector2(direction * (42.0 + float(index) * 16.0), 0.0) + offset
		var end := start + Vector2(direction * (58.0 + float(index) * 16.0), 0.0)
		draw_line(start, end, Color(0.74, 0.90, 1.0, opacity * (0.25 - float(index) * 0.05)), 2.0)

func _draw_placeholder_portrait(banner: Rect2, opacity: float) -> void:
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
