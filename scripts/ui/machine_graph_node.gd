extends GraphNode

const PORT_TYPE_RESOURCE := 0
const PORT_COLOR := Color(0.52, 0.74, 0.84)
const PANEL_COLOR := Color(0.055, 0.070, 0.090)
const PANEL_SELECTED_COLOR := Color(0.070, 0.095, 0.120)
const BORDER_COLOR := Color(0.18, 0.72, 0.82)
const TEXT_COLOR := Color(0.88, 0.92, 0.96)
const MUTED_TEXT_COLOR := Color(0.58, 0.66, 0.74)
const CAPTION_COLOR := Color(0.40, 0.78, 0.88)
const STATUS_COLOR := Color(0.25, 0.95, 0.42)
const WARNING_COLOR := Color(0.95, 0.68, 0.22)

@export var machine_display_name := "Machine"
@export var input_port_label := "In: input"
@export var output_port_label := "Out: output"

func _ready() -> void:
	apply_placeholder_definition()
	apply_visual_style()


func apply_placeholder_definition() -> void:
	title = ""

	_set_label_text("HeaderRow/HeaderText/TitleLabel", machine_display_name)
	_set_label_text("HeaderRow/HeaderText/SubtitleLabel", _machine_subtitle())
	_set_label_text("StatusRow/StatusLabel", "100% nominal")
	_set_label_text("InputRow/InputLabel", _clean_port_label(input_port_label))
	_set_label_text("OutputRow/OutputLabel", _clean_port_label(output_port_label))
	_set_label_text("MeterRow/MeterLabel", _flow_label())
	_set_label_text("FooterRow/FooterLabel", _footer_label())

	set_slot(2, true, PORT_TYPE_RESOURCE, _port_color(input_port_label), false, PORT_TYPE_RESOURCE, PORT_COLOR)
	set_slot(3, false, PORT_TYPE_RESOURCE, PORT_COLOR, true, PORT_TYPE_RESOURCE, _port_color(output_port_label))


func apply_visual_style() -> void:
	custom_minimum_size = Vector2(380, 220)
	add_theme_stylebox_override("panel", _make_node_style(PANEL_COLOR, _machine_accent(), 2))
	add_theme_stylebox_override("panel_selected", _make_node_style(PANEL_SELECTED_COLOR, BORDER_COLOR, 3))
	add_theme_color_override("title_color", Color(0, 0, 0, 0))

	_apply_label_style("HeaderRow/HeaderText/TitleLabel", TEXT_COLOR, 18)
	_apply_label_style("HeaderRow/HeaderText/SubtitleLabel", MUTED_TEXT_COLOR, 11)
	_apply_label_style("StatusRow/StatusLabel", STATUS_COLOR, 13)
	_apply_label_style("InputRow/InputCaption", CAPTION_COLOR, 11)
	_apply_label_style("InputRow/InputLabel", TEXT_COLOR, 14)
	_apply_label_style("OutputRow/OutputCaption", CAPTION_COLOR, 11)
	_apply_label_style("OutputRow/OutputLabel", TEXT_COLOR, 14)
	_apply_label_style("MeterRow/MeterLabel", MUTED_TEXT_COLOR, 12)
	_apply_label_style("FooterRow/FooterLabel", MUTED_TEXT_COLOR, 12)

	_set_rect_color("HeaderRow/MachineGlyph", _machine_accent())
	_set_rect_color("StatusRow/StatusDot", STATUS_COLOR)
	_set_rect_color("MeterRow/MeterFill", STATUS_COLOR)


func _machine_subtitle() -> String:
	match machine_display_name:
		"Resource Source":
			return "RESOURCE INPUT"
		"Crusher":
			return "MECHANICAL PROCESSOR"
		"Washer":
			return "FLUID PROCESSOR"
		"Smelter":
			return "THERMAL PROCESSOR"
		_:
			return "PROCESS NODE"


func _flow_label() -> String:
	return "flow route pending"


func _footer_label() -> String:
	if input_port_label.contains("none"):
		return "source node"
	return "awaiting evaluator"


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
			return BORDER_COLOR


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
	return PORT_COLOR


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


func _make_node_style(bg_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(12)
	return style
