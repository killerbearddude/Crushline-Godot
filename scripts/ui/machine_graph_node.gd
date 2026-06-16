extends GraphNode

const PORT_TYPE_RESOURCE := 0
const PORT_COLOR := Color(0.52, 0.74, 0.84)
const PANEL_COLOR := Color(0.075, 0.09, 0.115)
const PANEL_SELECTED_COLOR := Color(0.10, 0.13, 0.16)
const BORDER_COLOR := Color(0.18, 0.72, 0.82)
const TEXT_COLOR := Color(0.88, 0.92, 0.96)
const MUTED_TEXT_COLOR := Color(0.64, 0.70, 0.76)

@export var machine_display_name := "Machine"
@export var input_port_label := "In: input"
@export var output_port_label := "Out: output"

func _ready() -> void:
	apply_placeholder_definition()
	apply_visual_style()


func apply_placeholder_definition() -> void:
	title = machine_display_name

	var input_label := get_node_or_null("InputRow/InputLabel") as Label
	if input_label != null:
		input_label.text = input_port_label

	var output_label := get_node_or_null("OutputRow/OutputLabel") as Label
	if output_label != null:
		output_label.text = output_port_label

	set_slot(0, true, PORT_TYPE_RESOURCE, PORT_COLOR, false, PORT_TYPE_RESOURCE, PORT_COLOR)
	set_slot(1, false, PORT_TYPE_RESOURCE, PORT_COLOR, true, PORT_TYPE_RESOURCE, PORT_COLOR)


func apply_visual_style() -> void:
	add_theme_stylebox_override("panel", _make_node_style(PANEL_COLOR, BORDER_COLOR, 1))
	add_theme_stylebox_override("panel_selected", _make_node_style(PANEL_SELECTED_COLOR, BORDER_COLOR, 3))
	add_theme_color_override("title_color", TEXT_COLOR)

	var input_label := get_node_or_null("InputRow/InputLabel") as Label
	if input_label != null:
		input_label.add_theme_color_override("font_color", MUTED_TEXT_COLOR)
		input_label.add_theme_font_size_override("font_size", 14)

	var output_label := get_node_or_null("OutputRow/OutputLabel") as Label
	if output_label != null:
		output_label.add_theme_color_override("font_color", TEXT_COLOR)
		output_label.add_theme_font_size_override("font_size", 14)


func _make_node_style(bg_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(10)
	return style
