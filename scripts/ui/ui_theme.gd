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
const PANEL_FRAME_TEXTURE: Texture2D = preload("res://assets/art/ui/guofeng/panel_frame_2x.png")
const UPGRADE_CARD_FRAME_TEXTURE: Texture2D = preload("res://assets/art/ui/guofeng/upgrade_card_frame_2x.png")
const BUTTON_NORMAL_TEXTURE: Texture2D = preload("res://assets/art/ui/guofeng/button_normal_2x.png")
const BUTTON_HOVER_TEXTURE: Texture2D = preload("res://assets/art/ui/guofeng/button_hover_2x.png")
const BUTTON_PRESSED_TEXTURE: Texture2D = preload("res://assets/art/ui/guofeng/button_pressed_2x.png")
const BUTTON_DISABLED_TEXTURE: Texture2D = preload("res://assets/art/ui/guofeng/button_disabled_2x.png")
const HUD_BAR_FRAME_TEXTURE: Texture2D = preload("res://assets/art/ui/guofeng/hud_bar_frame_2x.png")
const TITLE_DIVIDER_TEXTURE: Texture2D = preload("res://assets/art/ui/guofeng/title_divider_2x.png")

static var _panel_style: StyleBoxTexture
static var _hud_bar_style: StyleBoxTexture

static func install(root: Control) -> Theme:
	var theme := Theme.new()
	var font := default_font()
	for type_name in ["Button", "Label", "OptionButton", "LineEdit", "HSlider", "ProgressBar", "TooltipPanel"]:
		theme.set_font("font", type_name, font)
	theme.set_color("font_color", "Button", TEXT_MAIN)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_disabled_color", "Button", MUTED)
	theme.set_stylebox("normal", "Button", button_style(PANEL_FILL, GOLD, 2))
	theme.set_stylebox("hover", "Button", button_style(Color("1a2b33"), DRAGON_BLUE, 3))
	theme.set_stylebox("pressed", "Button", button_style(Color("2e291d"), GOLD_BRIGHT, 3))
	theme.set_stylebox("disabled", "Button", button_style(Color("131a1e"), Color("425058"), 1))
	theme.set_stylebox("panel", "Panel", panel_style())
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

static func box_style(background: Color, border: Color, border_width: int) -> StyleBox:
	if background.a <= 0.01 and border.a <= 0.01:
		return flat_box_style(background, border, border_width)
	return button_style(background, border, border_width)

static func flat_box_style(background: Color, border: Color, border_width: int) -> StyleBoxFlat:
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

static func panel_style() -> StyleBoxTexture:
	if _panel_style == null:
		_panel_style = _texture_style(PANEL_FRAME_TEXTURE, 26.0, true)
		_panel_style.content_margin_left = 12.0
		_panel_style.content_margin_top = 12.0
		_panel_style.content_margin_right = 12.0
		_panel_style.content_margin_bottom = 12.0
	return _panel_style

static func upgrade_card_style(background: Color, border: Color, border_width: int) -> StyleBoxTexture:
	var style := _texture_style(UPGRADE_CARD_FRAME_TEXTURE, 24.0, true)
	style.content_margin_left = 12.0
	style.content_margin_top = 12.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 12.0
	return style

static func button_style(background: Color, border: Color, border_width: int) -> StyleBoxTexture:
	var texture := BUTTON_NORMAL_TEXTURE
	if border_width <= 1 and border.r < 0.48:
		texture = BUTTON_DISABLED_TEXTURE
	elif background.r > background.g * 1.10 and background.r > background.b * 1.20:
		texture = BUTTON_PRESSED_TEXTURE
	elif background.g >= 0.16 and background.b >= 0.18 and background.b > background.r:
		texture = BUTTON_HOVER_TEXTURE
	return _texture_style(texture, 12.0, true)

static func hud_bar_style() -> StyleBoxTexture:
	if _hud_bar_style == null:
		_hud_bar_style = _texture_style(HUD_BAR_FRAME_TEXTURE, 16.0, false)
	return _hud_bar_style

static func draw_panel(canvas: CanvasItem, rect: Rect2, _accent: Color, _emphasize: bool = false) -> void:
	canvas.draw_style_box(panel_style(), rect)

static func draw_hud_bar(canvas: CanvasItem, rect: Rect2, ratio: float, fill: Color) -> void:
	var inset := 3.0
	canvas.draw_rect(rect, Color("080d11"))
	canvas.draw_rect(Rect2(rect.position + Vector2(inset, inset), Vector2(maxf(0.0, (rect.size.x - inset * 2.0) * clampf(ratio, 0.0, 1.0)), maxf(0.0, rect.size.y - inset * 2.0))), fill)
	canvas.draw_style_box(hud_bar_style(), rect)

static func draw_title_divider(canvas: CanvasItem, rect: Rect2) -> void:
	canvas.draw_texture_rect(TITLE_DIVIDER_TEXTURE, rect, false)

static func _texture_style(texture: Texture2D, margin: float, draw_center: bool) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = margin
	style.texture_margin_top = margin
	style.texture_margin_right = margin
	style.texture_margin_bottom = margin
	style.draw_center = draw_center
	return style

static func label(text: String, font_size: int, color: Color) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result
