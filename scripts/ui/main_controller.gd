extends Control

@onready var add_crusher_button := get_node("Root/Body/MachineLibraryPanel/MachineLibraryContents/AddCrusherButton") as Button
@onready var graph_view := get_node("Root/Body/ProductionGraphView") as GraphEdit

func _ready() -> void:
	add_crusher_button.pressed.connect(_on_add_crusher_button_pressed)


func _on_add_crusher_button_pressed() -> void:
	if graph_view.has_method("add_placeholder_machine_node"):
		graph_view.call("add_placeholder_machine_node", "Crusher", "In: Iron Ore", "Out: Crushed Iron Ore")
