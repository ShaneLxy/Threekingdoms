class_name UITheme
extends RefCounted

const PANEL_FILL := Color("10191f")
const PANEL_INNER := Color("18242b")
const PANEL_EDGE := Color("7b6644")
const GOLD := Color("d5af66")
const GOLD_BRIGHT := Color("f4d58d")
const DRAGON_BLUE := Color("63b9df")
const MUTED := Color("829099")
const TEXT_MAIN := Color("f2e5c4")
const TEXT_SOFT := Color("d6e5e2")
const CINNABAR := Color("b23a2e")

static func install(root: Control) -> Theme:
	var theme := Theme.new()
	var font := default_font()
	for type_name in ["Button", "Label", "OptionButton", "LineEdit", "HSlider", "ProgressBar", "TooltipPanel"]:
		theme.set_font("font", type_name, font)
	theme.set_color("font_color", "Button", TEXT_MAIN)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_disabled_color", "Button", MUTED)
	theme.set_stylebox("normal", "Button", box_style(PANEL_FILL, GOLD, 2))
	theme.set_stylebox("hover", "Button", box_style(Color("1a2b33"), DRAGON_BLUE, 3))
	theme.set_stylebox("pressed", "Button", box_style(Color("2e291d"), GOLD_BRIGHT, 3))
	theme.set_stylebox("disabled", "Button", box_style(Color("131a1e"), Color("425058"), 1))
	theme.set_stylebox("panel", "Panel", box_style(PANEL_FILL, PANEL_EDGE, 1))
	root.theme = theme
	return theme

static func default_font() -> Font:
	for path in [
		"res://assets/fonts/ui-title.ttf",
		"res://assets/fonts/ui-title.otf",
		"res://assets/fonts/ui-regular.ttf",
		"res://assets/fonts/ui-regular.otf",
	]:
		if ResourceLoader.exists(path):
			return load(path) as Font
	return ThemeDB.fallback_font

static func box_style(background: Color, border: Color, border_width: int) -> StyleBoxFlat:
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

static func label(text: String, font_size: int, color: Color) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result
