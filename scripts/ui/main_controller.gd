extends Control

@onready var graph_view := get_node("Root/Body/ProductionGraphView") as GraphEdit

func _ready() -> void:
	_bind_button("Root/Body/MachineLibraryPanel/MachineLibraryContents/AddResourceSourceButton", "Resource Source", "In: none", "Out: Iron Ore")
	_bind_button("Root/Body/MachineLibraryPanel/MachineLibraryContents/AddCrusherButton", "Crusher", "In: Iron Ore", "Out: Crushed Iron Ore")
	_bind_button("Root/Body/MachineLibraryPanel/MachineLibraryContents/AddWasherButton", "Washer", "In: Crushed Iron Ore", "Out: Washed Iron Ore")
	_bind_button("Root/Body/MachineLibraryPanel/MachineLibraryContents/AddSmelterButton", "Smelter", "In: Washed Iron Ore", "Out: Iron Ingot")


func _bind_button(button_path: String, machine_display_name: String, input_port_label: String, output_port_label: String) -> void:
	var button := get_node(button_path) as Button
	button.pressed.connect(_on_add_machine_pressed.bind(machine_display_name, input_port_label, output_port_label))


func _on_add_machine_pressed(machine_display_name: String, input_port_label: String, output_port_label: String) -> void:
	if graph_view.has_method("add_placeholder_machine_node"):
		graph_view.call("add_placeholder_machine_node", machine_display_name, input_port_label, output_port_label)
