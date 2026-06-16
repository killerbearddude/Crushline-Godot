extends Control

const Slice1MachineCatalog = preload("res://scripts/content/slice1_machine_catalog.gd")

@onready var graph_view := get_node("Root/Body/WorkArea/ProductionGraphView") as GraphEdit
@onready var diagnostics_label := get_node("Root/Body/WorkArea/DiagnosticsOverlay/DiagnosticsLabel") as Label

func _ready() -> void:
	_bind_machine_buttons()

	if graph_view.has_signal("status_text_changed"):
		graph_view.connect("status_text_changed", _on_graph_status_text_changed)

	if graph_view.has_method("describe_graph_status"):
		diagnostics_label.text = graph_view.call("describe_graph_status")


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


func _on_graph_status_text_changed(text: String) -> void:
	diagnostics_label.text = text
