extends GraphEdit

const TEST_NODE_NAME := "TestResourceSourceNode"
const MACHINE_GRAPH_NODE_SCENE_PATH := "res://scenes/graph/MachineGraphNode.tscn"

func _ready() -> void:
	_create_test_resource_source_node()


func _create_test_resource_source_node() -> void:
	if has_node(TEST_NODE_NAME):
		return

	var machine_graph_node_scene := load(MACHINE_GRAPH_NODE_SCENE_PATH) as PackedScene
	var graph_node := machine_graph_node_scene.instantiate()
	graph_node.name = TEST_NODE_NAME
	graph_node.position_offset = Vector2(80.0, 80.0)
	graph_node.set("machine_display_name", "Resource Source")
	graph_node.set("input_port_label", "In: none")
	graph_node.set("output_port_label", "Out: Iron Ore")

	add_child(graph_node)
