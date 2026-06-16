extends GraphNode

const PORT_TYPE_RESOURCE := 0
const CARD_BG := Color(0.035, 0.050, 0.068)
const CARD_BODY_BG := Color(0.040, 0.060, 0.082)
const CARD_ROW_BG := Color(0.050, 0.070, 0.092)
const TEXT_COLOR := Color(0.90, 0.96, 1.0)
const MUTED_TEXT_COLOR := Color(0.56, 0.66, 0.76)
const STATUS_COLOR := Color(0.25, 0.95, 0.42)
const DEFAULT_ACCENT := Color(0.18, 0.72, 0.82)
const SOCKET_OUTER := Color(0.018, 0.026, 0.036)

@export var machine_display_name := "Machine"
@export var input_port_label := "In: input"
@export var output_port_label := "Out: output"

func _ready() -> void:
	apply_placeholder_definition()
	apply_visual_style()
	_set_child_controls_mouse_passthrough()
	queue_redraw()


func _draw() -> void:
	_draw_card_background()


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
	add_theme_stylebox_override("panel", _transparent_style())
	add_theme_stylebox_override("panel_selected", _transparent_style())
	add_theme_stylebox_override("titlebar", _transparent_style())
	add_theme_stylebox_override("titlebar_selected", _transparent_style())
	add_theme_color_override("title_color", Color(0, 0, 0, 0))

	_style_card("Card", Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 10, 0)
	_apply_label_style("Card/CardContents/HeaderRow/HeaderText/TitleLabel", TEXT_COLOR, 13)
	_apply_label_style("Card/CardContents/HeaderRow/HeaderText/SubtitleLabel", MUTED_TEXT_COLOR, 8)
	_apply_label_style("Card/CardContents/HeaderRow/StatusLabel", STATUS_COLOR, 11)
	_apply_label_style("Card/CardContents/NeedsRow/NeedsCaption", MUTED_TEXT_COLOR, 9)
	_apply_label_style("Card/CardContents/MakesRow/MakesCaption", MUTED_TEXT_COLOR, 9)
	_apply_label_style("Card/CardContents/NeedsRow/NeedsChip/NeedsLabel", _port_color(input_port_label), 9)
	_apply_label_style("Card/CardContents/MakesRow/MakesChip/MakesLabel", _port_color(output_port_label), 9)
	_apply_label_style("Card/CardContents/FooterRow/FooterLabel", MUTED_TEXT_COLOR, 8)
	_apply_label_style("Card/CardContents/FooterRow/RateLabel", MUTED_TEXT_COLOR, 8)

	_style_card("Card/CardContents/NeedsRow/NeedsChip", Color(0.045, 0.060, 0.080), _port_color(input_port_label).darkened(0.25), 1, 5, 0)
	_style_card("Card/CardContents/MakesRow/MakesChip", Color(0.045, 0.060, 0.080), _port_color(output_port_label).darkened(0.25), 1, 5, 0)
	_set_rect_color("Card/CardContents/HeaderRow/MachineGlyph", _machine_accent())
	_set_rect_color("Card/CardContents/FooterRow/StatusDot", STATUS_COLOR)


func _set_child_controls_mouse_passthrough() -> void:
	for child in get_children():
		_set_mouse_passthrough_recursive(child)


func _set_mouse_passthrough_recursive(node: Node) -> void:
	var control := node as Control
	if control != null:
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for child in node.get_children():
		_set_mouse_passthrough_recursive(child)


func _draw_card_background() -> void:
	var card := get_node_or_null("Card") as Control
	if card == null:
		return

	var rect := Rect2(card.position, card.size)
	var accent := _machine_accent()

	_draw_style(rect, CARD_BG, 0, 10)

	var header_rect := Rect2(rect.position + Vector2(6, 6), Vector2(rect.size.x - 12, 34))
	_draw_style(header_rect, Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.16, 0.96), 0, 8)

	var body_rect := Rect2(rect.position + Vector2(6, 42), Vector2(rect.size.x - 12, rect.size.y - 52))
	_draw_style(body_rect, CARD_BODY_BG, 0, 8)

	var inner_edge_color := Color(accent.r, accent.g, accent.b, 0.08)
	draw_line(rect.position + Vector2(12, 8), rect.position + Vector2(rect.size.x - 12, 8), inner_edge_color, 1.0)
	draw_line(rect.position + Vector2(12, rect.size.y - 8), rect.position + Vector2(rect.size.x - 12, rect.size.y - 8), Color(0, 0, 0, 0.18), 1.0)

	_draw_socket(rect.position + Vector2(1, rect.size.y * 0.50), _port_color(input_port_label), true)
	_draw_socket(rect.position + Vector2(rect.size.x - 1, rect.size.y * 0.50), _port_color(output_port_label), false)


func _draw_socket(center: Vector2, color: Color, is_input: bool) -> void:
	draw_circle(center, 10.0, SOCKET_OUTER)
	draw_circle(center, 7.0, Color(color.r, color.g, color.b, 0.34))
	draw_circle(center, 3.5, color)
	var notch_direction := -1.0 if is_input else 1.0
	draw_line(center, center + Vector2(notch_direction * 12.0, 0.0), Color(color.r, color.g, color.b, 0.58), 2.0)


func _draw_style(rect: Rect2, bg_color: Color, border_width: int, corner_radius: int) -> void:
	var style := _make_style(bg_color, Color(0, 0, 0, 0), border_width, corner_radius, 0)
	draw_style_box(style, rect)


func _machine_subtitle() -> String:
	match machine_display_name:
		"Resource Source", "Coal Source", "Water Source":
			return "SOURCE"
		"Crusher":
			return "MECHANICAL"
		"Washer":
			return "FLUID"
		"Smelter":
			return "THERMAL"
		"Basic Generator":
			return "POWER"
		_:
			return "MACHINE"


func _rate_label() -> String:
	if output_port_label.contains("Power"):
		return "120/m"
	if output_port_label.contains("Coal"):
		return "240/m"
	if output_port_label.contains("Water"):
		return "600/m"
	if output_port_label.contains("Iron Ingot"):
		return "180/m"
	if output_port_label.contains("Washed Iron Ore"):
		return "360/m"
	if output_port_label.contains("Crushed Iron Ore"):
		return "480/m"
	if output_port_label.contains("Iron Ore"):
		return "720/m"
	return "ready"


func _footer_label() -> String:
	if machine_display_name == "Coal Source":
		return "fuel feed"
	if machine_display_name == "Water Source":
		return "fluid feed"
	if machine_display_name == "Basic Generator":
		return "burns coal"
	if machine_display_name == "Washer":
		return "water soon / slurry"
	if input_port_label.contains("none"):
		return "no input"
	return "route pending"


func _machine_accent() -> Color:
	match machine_display_name:
		"Resource Source":
			return Color(0.30, 0.70, 0.44)
		"Coal Source":
			return Color(0.34, 0.32, 0.30)
		"Water Source":
			return Color(0.20, 0.54, 0.95)
		"Crusher":
			return Color(0.55, 0.64, 0.70)
		"Washer":
			return Color(0.25, 0.58, 0.92)
		"Smelter":
			return Color(0.95, 0.45, 0.18)
		"Basic Generator":
			return Color(0.95, 0.78, 0.22)
		_:
			return DEFAULT_ACCENT


func _port_color(label_text: String) -> Color:
	if label_text.contains("Power"):
		return Color(0.95, 0.86, 0.28)
	if label_text.contains("Coal"):
		return Color(0.48, 0.44, 0.40)
	if label_text.contains("Water"):
		return Color(0.25, 0.58, 0.92)
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


func _style_card(path: String, bg_color: Color, border_color: Color, border_width: int, corner_radius: int, shadow_size: int) -> void:
	var panel := get_node_or_null(path) as PanelContainer
	if panel != null:
		panel.add_theme_stylebox_override("panel", _make_style(bg_color, border_color, border_width, corner_radius, shadow_size))


func _make_style(bg_color: Color, border_color: Color, border_width: int, corner_radius: int, shadow_size: int) -> StyleBoxFlat:
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
