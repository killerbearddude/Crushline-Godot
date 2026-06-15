extends GraphEdit

const TEST_NODE_NAME := "TestResourceSourceNode"

func _ready() -> void:
	_create_test_resource_source_node()


func _create_test_resource_source_node() -> void:
	if has_node(TEST_NODE_NAME):
		return

	var graph_node := GraphNode.new()
	graph_node.name = TEST_NODE_NAME
	graph_node.title = "Resource Source"
	graph_node.position_offset = Vector2(80.0, 80.0)
	graph_node.custom_minimum_size = Vector2(240.0, 120.0)

	var label := Label.new()
	label.text = "Output: Iron Ore\nRate: placeholder\n\nSlice 1 visual test node"
	graph_node.add_child(label)

	add_child(graph_node)
