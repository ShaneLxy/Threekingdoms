extends CanvasLayer

const FADE_DURATION := 0.18

var root: Control
var message_label: Label
var progress_bar: ProgressBar
var fade_tween: Tween

func _ready() -> void:
	layer = 127
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	visible = false

func show_transition(message: String) -> void:
	_build_if_needed()
	_kill_fade()
	message_label.text = message
	progress_bar.value = 0.0
	root.modulate.a = 1.0
	visible = true

func set_progress(value: float, message: String = "") -> void:
	_build_if_needed()
	if not message.is_empty():
		message_label.text = message
	progress_bar.value = clampf(value, 0.0, 100.0)

func finish_transition() -> void:
	if not visible:
		return
	_kill_fade()
	progress_bar.value = 100.0
	fade_tween = create_tween()
	fade_tween.tween_property(root, "modulate:a", 0.0, FADE_DURATION)
	fade_tween.tween_callback(func() -> void:
		visible = false
		root.modulate.a = 1.0
	)

func fail_transition(message: String) -> void:
	_build_if_needed()
	_kill_fade()
	message_label.text = message
	# Keep the error visible briefly so a failed departure is distinguishable
	# from a successful transition, then return control to the current page.
	progress_bar.value = 0.0
	root.modulate.a = 1.0
	visible = true
	fade_tween = create_tween()
	fade_tween.tween_interval(0.8)
	fade_tween.tween_property(root, "modulate:a", 0.0, FADE_DURATION)
	fade_tween.tween_callback(func() -> void:
		visible = false
		root.modulate.a = 1.0
	)

func _build_if_needed() -> void:
	if root == null:
		_build()

func _build() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)

	var scrim := ColorRect.new()
	scrim.color = Color(0.012, 0.016, 0.018, 0.92)
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(scrim)

	var panel := Panel.new()
	panel.size = Vector2(420.0, 182.0)
	panel.add_theme_stylebox_override("panel", UITheme.panel_style())
	root.add_child(panel)

	var title := UITheme.label("行军整备", 24, UITheme.GOLD_BRIGHT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(panel.size.x - 48.0, 34.0)
	panel.add_child(title)

	message_label = UITheme.label("正在点兵…", 18, UITheme.TEXT_SOFT)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.size = Vector2(panel.size.x - 48.0, 28.0)
	panel.add_child(message_label)

	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 8.0
	progress_bar.show_percentage = false
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(progress_bar)

	var hint := UITheme.label("军令已下 · 稍候片刻", 13, UITheme.MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.size = Vector2(panel.size.x - 48.0, 22.0)
	panel.add_child(hint)

	root.resized.connect(_layout_transition_panel.bind(panel, title, message_label, hint))
	_layout_transition_panel(panel, title, message_label, hint)

func _layout_transition_panel(panel: Panel, title: Label, message: Label, hint: Label) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	panel.size = Vector2(minf(420.0, maxf(280.0, viewport_size.x - 48.0)), 182.0)
	panel.position = (viewport_size - panel.size) * 0.5
	title.position = Vector2(24.0, 24.0)
	title.size = Vector2(panel.size.x - 48.0, 34.0)
	message.position = Vector2(24.0, 68.0)
	message.size = Vector2(panel.size.x - 48.0, 28.0)
	progress_bar.position = Vector2(24.0, 108.0)
	progress_bar.size = Vector2(panel.size.x - 48.0, 12.0)
	hint.position = Vector2(24.0, 132.0)
	hint.size = Vector2(panel.size.x - 48.0, 22.0)

func _kill_fade() -> void:
	if fade_tween != null and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = null
