extends GraphNode

const PORT_TYPE_RESOURCE := 0
const CARD_BG := Color(0.045, 0.065, 0.085)
const CARD_BG_SELECTED := Color(0.055, 0.085, 0.110)
const TEXT_COLOR := Color(0.90, 0.96, 1.0)
const MUTED_TEXT_COLOR := Color(0.56, 0.66, 0.76)
const STATUS_COLOR := Color(0.25, 0.95, 0.42)
const DEFAULT_ACCENT := Color(0.18, 0.72, 0.82)

@export var machine_display_name := "Machine"
@export var input_port_label := "In: input"
@export var output_port_label := "Out: output"

func _ready() -> void:
	apply_placeholder_definition()
	apply_visual_style()


func apply_placeholder_definition() -> void:
	title = ""
	_set_label_text("Card/CardContents/HeaderRow/HeaderText/TitleLabel", machine_display_name)
	_set_label_text("Card/CardContents/HeaderRow/HeaderText/SubtitleLabel", _machine_subtitle())
	_set_label_text("Card/CardContents/HeaderRow/StatusLabel", "100%")
	_set_label_text("Card/CardContents/NeedsRow/NeedsChip/NeedsLabel", _clean_port_label(input_port_label))
	_set_label_text("Card/CardContents/MakesRow/MakesChip/MakesLabel", _clean_port_label(output_port_label))
	_set_label_text("Card/CardContents/FooterRow/FooterLabel", _footer_label())
	_set_label_text("Card/CardContents/FooterRow/RateLabel", _rate_label())

	set_slot(0, true, PORT_TYPE_RESOURCE, _port_color(input_port_label), true, PORT_TYPE_RESOURCE, _port_color(output_port_label))


func apply_visual_style() -> void:
	custom_minimum_size = Vector2(280, 136)
	var accent := _machine_accent()
	add_theme_stylebox_override("panel", _transparent_style())
	add_theme_stylebox_override("panel_selected", _transparent_style())
	add_theme_stylebox_override("titlebar", _transparent_style())
	add_theme_stylebox_override("titlebar_selected", _transparent_style())
	add_theme_color_override("title_color", Color(0, 0, 0, 0))

	_style_card("Card", CARD_BG, accent, 1, 10)
	_apply_label_style("Card/CardContents/HeaderRow/HeaderText/TitleLabel", TEXT_COLOR, 13)
	_apply_label_style("Card/CardContents/HeaderRow/HeaderText/SubtitleLabel", MUTED_TEXT_COLOR, 8)
	_apply_label_style("Card/CardContents/HeaderRow/StatusLabel", STATUS_COLOR, 11)
	_apply_label_style("Card/CardContents/NeedsRow/NeedsCaption", MUTED_TEXT_COLOR, 9)
	_apply_label_style("Card/CardContents/MakesRow/MakesCaption", MUTED_TEXT_COLOR, 9)
	_apply_label_style("Card/CardContents/NeedsRow/NeedsChip/NeedsLabel", _port_color(input_port_label), 9)
	_apply_label_style("Card/CardContents/MakesRow/MakesChip/MakesLabel", _port_color(output_port_label), 9)
	_apply_label_style("Card/CardContents/FooterRow/FooterLabel", MUTED_TEXT_COLOR, 8)
	_apply_label_style("Card/CardContents/FooterRow/RateLabel", MUTED_TEXT_COLOR, 8)

	_style_card("Card/CardContents/NeedsRow/NeedsChip", Color(0.055, 0.075, 0.095), _port_color(input_port_label), 1, 5)
	_style_card("Card/CardContents/MakesRow/MakesChip", Color(0.055, 0.075, 0.095), _port_color(output_port_label), 1, 5)
	_set_rect_color("Card/CardContents/HeaderRow/MachineGlyph", accent)
	_set_rect_color("Card/CardContents/FooterRow/StatusDot", STATUS_COLOR)


func _machine_subtitle() -> String:
	match machine_display_name:
		"Resource Source":
			return "SOURCE"
		"Crusher":
			return "MECHANICAL"
		"Washer":
			return "FLUID"
		"Smelter":
			return "THERMAL"
		_:
			return "MACHINE"


func _rate_label() -> String:
	if output_port_label.contains("Iron Ingot"):
		return "360/m"
	if output_port_label.contains("Iron Ore"):
		return "720/m"
	return "ready"


func _footer_label() -> String:
	if input_port_label.contains("none"):
		return "no input"
	return "route pending"


func _machine_accent() -> Color:
	match machine_display_name:
		"Resource Source":
			return Color(0.30, 0.70, 0.44)
		"Crusher":
			return Color(0.55, 0.64, 0.70)
		"Washer":
			return Color(0.25, 0.58, 0.92)
		"Smelter":
			return Color(0.95, 0.45, 0.18)
		_:
			return DEFAULT_ACCENT


func _port_color(label_text: String) -> Color:
	if label_text.contains("Iron Ingot"):
		return Color(0.95, 0.64, 0.23)
	if label_text.contains("Washed Iron Ore"):
		return Color(0.70, 0.84, 0.88)
	if label_text.contains("Crushed Iron Ore"):
		return Color(0.62, 0.66, 0.70)
	if label_text.contains("Iron Ore"):
		return Color(0.78, 0.45, 0.24)
	if label_text.contains("none"):
		return MUTED_TEXT_COLOR
	return DEFAULT_ACCENT


func _clean_port_label(label_text: String) -> String:
	return label_text.replace("In: ", "").replace("Out: ", "")


func _set_label_text(path: String, text_value: String) -> void:
	var label := get_node_or_null(path) as Label
	if label != null:
		label.text = text_value


func _set_rect_color(path: String, color: Color) -> void:
	var rect := get_node_or_null(path) as ColorRect
	if rect != null:
		rect.color = color


func _apply_label_style(path: String, color: Color, font_size: int) -> void:
	var label := get_node_or_null(path) as Label
	if label == null:
		return
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)


func _style_card(path: String, bg_color: Color, border_color: Color, border_width: int, corner_radius: int) -> void:
	var panel := get_node_or_null(path) as PanelContainer
	if panel != null:
		panel.add_theme_stylebox_override("panel", _make_style(bg_color, border_color, border_width, corner_radius))


func _make_style(bg_color: Color, border_color: Color, border_width: int, corner_radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style


func _transparent_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = Color(0, 0, 0, 0)
	style.set_border_width_all(0)
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	return style
