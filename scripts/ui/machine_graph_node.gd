extends GraphNode

const PORT_TYPE_RESOURCE := 0
const PANEL_COLOR := Color(0.030, 0.042, 0.058)
const PANEL_SELECTED_COLOR := Color(0.045, 0.070, 0.095)
const ROW_COLOR := Color(0.070, 0.090, 0.115)
const ROW_BORDER := Color(0.16, 0.24, 0.30)
const TEXT_COLOR := Color(0.92, 0.96, 1.0)
const MUTED_TEXT_COLOR := Color(0.58, 0.66, 0.74)
const CAPTION_COLOR := Color(0.42, 0.84, 0.96)
const STATUS_COLOR := Color(0.25, 0.95, 0.42)
const DEFAULT_ACCENT := Color(0.18, 0.72, 0.82)

@export var machine_display_name := "Machine"
@export var input_port_label := "In: input"
@export var output_port_label := "Out: output"

func _ready() -> void:
	apply_placeholder_definition()
	apply_visual_style()


func apply_placeholder_definition() -> void:
	title = "  %s" % machine_display_name
	_set_label_text("StatusStrip/StatusLabel", "100% NOMINAL")
	_set_label_text("StatusStrip/RateLabel", _rate_label())
	_set_label_text("InputRow/InputContents/InputLabel", _clean_port_label(input_port_label))
	_set_label_text("OutputRow/OutputContents/OutputLabel", _clean_port_label(output_port_label))
	_set_label_text("MeterRow/MeterLabel", _flow_label())
	_set_label_text("FooterRow/FooterLabel", _footer_label())

	set_slot(1, true, PORT_TYPE_RESOURCE, _port_color(input_port_label), false, PORT_TYPE_RESOURCE, DEFAULT_ACCENT)
	set_slot(2, false, PORT_TYPE_RESOURCE, DEFAULT_ACCENT, true, PORT_TYPE_RESOURCE, _port_color(output_port_label))


func apply_visual_style() -> void:
	custom_minimum_size = Vector2(420, 250)
	var accent := _machine_accent()
	add_theme_stylebox_override("panel", _make_card_style(PANEL_COLOR, accent, 2, 14))
	add_theme_stylebox_override("panel_selected", _make_card_style(PANEL_SELECTED_COLOR, Color(0.75, 0.95, 1.0), 4, 14))
	add_theme_stylebox_override("titlebar", _make_title_style(accent))
	add_theme_stylebox_override("titlebar_selected", _make_title_style(accent.lightened(0.12)))
	add_theme_color_override("title_color", TEXT_COLOR)
	add_theme_font_size_override("title_font_size", 18)

	_style_row("InputRow")
	_style_row("OutputRow")
	_apply_label_style("StatusStrip/StatusLabel", STATUS_COLOR, 13)
	_apply_label_style("StatusStrip/RateLabel", MUTED_TEXT_COLOR, 13)
	_apply_label_style("InputRow/InputContents/InputCaption", CAPTION_COLOR, 12)
	_apply_label_style("InputRow/InputContents/InputLabel", TEXT_COLOR, 16)
	_apply_label_style("OutputRow/OutputContents/OutputCaption", CAPTION_COLOR, 12)
	_apply_label_style("OutputRow/OutputContents/OutputLabel", TEXT_COLOR, 16)
	_apply_label_style("MeterRow/MeterLabel", MUTED_TEXT_COLOR, 12)
	_apply_label_style("FooterRow/FooterLabel", MUTED_TEXT_COLOR, 12)

	_set_rect_color("StatusStrip/StatusDot", STATUS_COLOR)
	_set_rect_color("MeterRow/MeterBlockA", STATUS_COLOR)
	_set_rect_color("MeterRow/MeterBlockB", STATUS_COLOR)
	_set_rect_color("MeterRow/MeterBlockC", STATUS_COLOR)


func _style_row(path: String) -> void:
	var panel := get_node_or_null(path) as PanelContainer
	if panel != null:
		panel.add_theme_stylebox_override("panel", _make_card_style(ROW_COLOR, ROW_BORDER, 1, 8))


func _rate_label() -> String:
	if output_port_label.contains("Iron Ore"):
		return "720/m"
	if output_port_label.contains("Iron Ingot"):
		return "360/m"
	return "READY"


func _flow_label() -> String:
	if input_port_label.contains("none"):
		return "SOURCE ONLINE"
	return "ROUTE READY"


func _footer_label() -> String:
	if input_port_label.contains("none"):
		return "external feed / no input required"
	return "awaiting full production evaluator"


func _machine_accent() -> Color:
	match machine_display_name:
		"Resource Source":
			return Color(0.30, 0.70, 0.44)
		"Crusher":
			return Color(0.62, 0.66, 0.70)
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


func _make_card_style(bg_color: Color, border_color: Color, border_width: int, corner_radius: int) -> StyleBoxFlat:
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


func _make_title_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = accent.darkened(0.35)
	style.border_color = accent
	style.set_border_width_all(0)
	style.border_width_bottom = 2
	style.set_corner_radius_all(14)
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.content_margin_left = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style
