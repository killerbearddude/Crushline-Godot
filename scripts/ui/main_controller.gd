extends Control

const Slice1MachineCatalog = preload("res://scripts/content/slice1_machine_catalog.gd")

const DETAIL_LINE_LIMIT := 9
const DEBUG_HEADER_COLOR := Color(0.62, 0.78, 0.86, 0.82)
const DEBUG_SUMMARY_COLOR := Color(0.88, 0.94, 1.0, 0.90)
const DEBUG_DETAIL_COLOR := Color(0.72, 0.80, 0.86, 0.78)

@onready var graph_view := get_node("Root/Body/WorkArea/ProductionGraphView") as GraphEdit
@onready var diagnostics_header := get_node("Root/Body/WorkArea/DiagnosticsOverlay/DiagnosticsContents/DiagnosticsHeader") as Label
@onready var diagnostics_summary_label := get_node("Root/Body/WorkArea/DiagnosticsOverlay/DiagnosticsContents/DiagnosticsSummaryLabel") as Label
@onready var diagnostics_label := get_node("Root/Body/WorkArea/DiagnosticsOverlay/DiagnosticsContents/DiagnosticsScroll/DiagnosticsLabel") as Label
@onready var save_graph_button := get_node("Root/Body/MachineLibraryPanel/MachineLibraryContents/SaveGraphButton") as Button
@onready var load_graph_button := get_node("Root/Body/MachineLibraryPanel/MachineLibraryContents/LoadGraphButton") as Button

func _ready() -> void:
	_style_diagnostics_overlay()
	_bind_graph_file_buttons()
	_bind_machine_buttons()

	if graph_view.has_signal("status_text_changed"):
		graph_view.connect("status_text_changed", _on_graph_status_text_changed)

	if graph_view.has_method("describe_graph_status"):
		_set_diagnostics_text(graph_view.call("describe_graph_status"))


func _bind_graph_file_buttons() -> void:
	save_graph_button.pressed.connect(_on_save_graph_pressed)
	load_graph_button.pressed.connect(_on_load_graph_pressed)


func _bind_machine_buttons() -> void:
	for machine_id in Slice1MachineCatalog.machine_ids():
		var definition := Slice1MachineCatalog.get_machine_definition(machine_id)
		_bind_machine_button(machine_id, definition)


func _bind_machine_button(machine_id: String, definition: Dictionary) -> void:
	var button_path := str(definition.get("button_path", ""))
	var button := get_node_or_null(button_path) as Button
	if button == null:
		push_warning("Missing machine library button for %s at %s" % [machine_id, button_path])
		return

	button.text = str(definition.get("display_name", machine_id))
	button.tooltip_text = Slice1MachineCatalog.button_tooltip(definition)
	button.pressed.connect(_on_add_machine_pressed.bind(machine_id))


func _on_add_machine_pressed(machine_id: String) -> void:
	if graph_view.has_method("add_machine_node"):
		graph_view.call("add_machine_node", machine_id)


func _on_save_graph_pressed() -> void:
	if graph_view.has_method("save_graph_to_default_path"):
		graph_view.call("save_graph_to_default_path")


func _on_load_graph_pressed() -> void:
	if graph_view.has_method("load_graph_from_default_path"):
		graph_view.call("load_graph_from_default_path")


func _on_graph_status_text_changed(text: String) -> void:
	_set_diagnostics_text(text)


func _style_diagnostics_overlay() -> void:
	diagnostics_header.add_theme_font_size_override("font_size", 9)
	diagnostics_header.add_theme_color_override("font_color", DEBUG_HEADER_COLOR)
	diagnostics_summary_label.add_theme_font_size_override("font_size", 10)
	diagnostics_summary_label.add_theme_color_override("font_color", DEBUG_SUMMARY_COLOR)
	diagnostics_label.add_theme_font_size_override("font_size", 9)
	diagnostics_label.add_theme_color_override("font_color", DEBUG_DETAIL_COLOR)


func _set_diagnostics_text(text: String) -> void:
	diagnostics_summary_label.text = _diagnostics_summary(text)
	diagnostics_label.text = _diagnostics_detail(text)


func _diagnostics_summary(text: String) -> String:
	var visual_nodes := _find_line_value(text, "Visual nodes:")
	var visual_connections := _find_line_value(text, "Visual connections:")
	var hard_errors := _find_line_value(text, "Hard errors:")
	var warnings := _find_line_value(text, "Warnings:")
	var objective := _find_objective_status(text)
	if visual_nodes.is_empty() and hard_errors.is_empty() and objective.is_empty():
		return "Waiting for graph activity."

	if not objective.is_empty():
		return "%s  hard %s  warn %s" % [
			objective,
			hard_errors if not hard_errors.is_empty() else "0",
			warnings if not warnings.is_empty() else "0",
		]

	return "nodes %s  links %s  hard %s  warn %s" % [
		visual_nodes if not visual_nodes.is_empty() else "0",
		visual_connections if not visual_connections.is_empty() else "0",
		hard_errors if not hard_errors.is_empty() else "0",
		warnings if not warnings.is_empty() else "0",
	]


func _diagnostics_detail(text: String) -> String:
	var selected_lines: Array[String] = []
	var objective := _find_objective_status(text)
	if not objective.is_empty():
		selected_lines.append("Objective: %s" % objective)

	for line in text.split("\n"):
		var clean_line := line.strip_edges()
		if clean_line.is_empty():
			continue
		if clean_line.begins_with("Graph status"):
			continue
		if clean_line.begins_with("Evaluator status"):
			continue
		if clean_line.begins_with("No hard structural errors"):
			continue
		if clean_line.begins_with("- Graph nodes"):
			continue
		if clean_line.begins_with("- Graph links"):
			continue
		if clean_line.begins_with("- Objective:") or clean_line.begins_with("Objective:"):
			continue
		selected_lines.append(clean_line)
		if selected_lines.size() >= DETAIL_LINE_LIMIT:
			break

	return "\n".join(selected_lines)


func _find_line_value(text: String, prefix: String) -> String:
	for line in text.split("\n"):
		var clean_line := line.strip_edges()
		if clean_line.begins_with(prefix):
			return clean_line.trim_prefix(prefix).strip_edges()
	return ""


func _find_objective_status(text: String) -> String:
	for line in text.split("\n"):
		var clean_line := line.strip_edges()
		if clean_line.begins_with("- Objective:"):
			return clean_line.trim_prefix("- Objective:").strip_edges()
		if clean_line.begins_with("Objective:"):
			return clean_line.trim_prefix("Objective:").strip_edges()
	return ""
