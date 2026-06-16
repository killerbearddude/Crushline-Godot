extends Control

@onready var add_node_button := get_node("Root/Body/MachineLibraryPanel/MachineLibraryContents/AddNodeButton") as Button
@onready var graph_view := get_node("Root/Body/ProductionGraphView") as GraphEdit

func _ready() -> void:
	add_node_button.pressed.connect(_on_add_node_button_pressed)


func _on_add_node_button_pressed() -> void:
	if graph_view.has_method("add_placeholder_machine_node"):
		graph_view.call("add_placeholder_machine_node", "Processor", "In: input", "Out: output")
