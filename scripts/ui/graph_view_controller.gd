extends GraphEdit

const TEST_NODE_NAME := "TestResourceSourceNode"
const MACHINE_GRAPH_NODE_SCENE_PATH := "res://scenes/graph/MachineGraphNode.tscn"
const PORT_TYPE_RESOURCE := 0

var next_node_index := 0

func _ready() -> void:
	add_valid_connection_type(PORT_TYPE_RESOURCE, PORT_TYPE_RESOURCE)
	add_valid_left_disconnect_type(PORT_TYPE_RESOURCE)
	add_valid_right_disconnect_type(PORT_TYPE_RESOURCE)
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)
	_create_test_resource_source_node()


func add_placeholder_machine_node(machine_display_name: String, input_port_label: String, output_port_label: String) -> void:
	next_node_index += 1
	var node_name := "%sNode%d" % [machine_display_name.replace(" ", ""), next_node_index]
	var position := Vector2(360.0 + (next_node_index * 40.0), 120.0 + (next_node_index * 30.0))
	_create_machine_node(node_name, machine_display_name, input_port_label, output_port_label, position)


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if from_node == to_node:
		print("Connection rejected: a node cannot connect to itself.")
		return

	if is_node_connected(from_node, from_port, to_node, to_port):
		return

	connect_node(from_node, from_port, to_node, to_port)
	print("Connection added: %s[%d] -> %s[%d]" % [from_node, from_port, to_node, to_port])


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	print("Connection removed: %s[%d] -> %s[%d]" % [from_node, from_port, to_node, to_port])


func _create_test_resource_source_node() -> void:
	if has_node(TEST_NODE_NAME):
		return

	_create_machine_node(TEST_NODE_NAME, "Resource Source", "In: none", "Out: Iron Ore", Vector2(80.0, 80.0))


func _create_machine_node(node_name: String, machine_display_name: String, input_port_label: String, output_port_label: String, position: Vector2) -> void:
	var machine_graph_node_scene := load(MACHINE_GRAPH_NODE_SCENE_PATH) as PackedScene
	var graph_node := machine_graph_node_scene.instantiate()
	graph_node.name = node_name
	graph_node.position_offset = position
	graph_node.set("machine_display_name", machine_display_name)
	graph_node.set("input_port_label", input_port_label)
	graph_node.set("output_port_label", output_port_label)

	add_child(graph_node)
