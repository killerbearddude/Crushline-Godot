extends GraphEdit

signal status_text_changed(text: String)

const TEST_NODE_NAME := "TestResourceSourceNode"
const MACHINE_GRAPH_NODE_SCENE_PATH := "res://scenes/graph/MachineGraphNode.tscn"
const CanvasAdapter = preload("res://scripts/graph/canvas_adapter.gd")
const GraphEvaluator = preload("res://scripts/simulation/graph_evaluator.gd")
const PORT_TYPE_RESOURCE := 0
const CANVAS_BG := Color(0.045, 0.050, 0.062)
const CANVAS_BORDER := Color(0.14, 0.18, 0.22)
const GRID_MAJOR := Color(0.22, 0.28, 0.33)
const GRID_MINOR := Color(0.11, 0.135, 0.16)
const LINK_COLOR := Color(0.70, 0.88, 0.92)

var next_node_index := 0
var graph_model: RefCounted = null
var graph_evaluation: RefCounted = null

func _ready() -> void:
	_apply_canvas_style()
	add_valid_connection_type(PORT_TYPE_RESOURCE, PORT_TYPE_RESOURCE)
	add_valid_left_disconnect_type(PORT_TYPE_RESOURCE)
	add_valid_right_disconnect_type(PORT_TYPE_RESOURCE)
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)
	node_selected.connect(_on_node_selected)
	node_deselected.connect(_on_node_deselected)
	_create_test_resource_source_node()
	_refresh_graph_model()


func add_placeholder_machine_node(machine_display_name: String, input_port_label: String, output_port_label: String) -> void:
	next_node_index += 1
	var node_name := "%sNode%d" % [machine_display_name.replace(" ", ""), next_node_index]
	var position := Vector2(360.0 + (next_node_index * 40.0), 120.0 + (next_node_index * 30.0))
	_create_machine_node(node_name, machine_display_name, input_port_label, output_port_label, position)
	_refresh_graph_model()
	status_text_changed.emit(_describe_graph_status())


func describe_graph_status() -> String:
	_refresh_graph_model()
	return _describe_graph_status()


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if from_node == to_node:
		var rejected_text := "Connection rejected: a node cannot connect to itself.\n%s[%d] -> %s[%d]" % [from_node, from_port, to_node, to_port]
		print(rejected_text)
		status_text_changed.emit(rejected_text)
		return

	if is_node_connected(from_node, from_port, to_node, to_port):
		status_text_changed.emit("Connection already exists:\n%s[%d] -> %s[%d]" % [from_node, from_port, to_node, to_port])
		return

	connect_node(from_node, from_port, to_node, to_port)
	_refresh_graph_model()
	var added_text := _describe_connection("Connection added", from_node, from_port, to_node, to_port)
	print(added_text)
	status_text_changed.emit(added_text)


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	_refresh_graph_model()
	var removed_text := _describe_connection("Connection removed", from_node, from_port, to_node, to_port)
	print(removed_text)
	status_text_changed.emit(removed_text)


func _on_node_selected(node: Node) -> void:
	var graph_node := node as GraphNode
	if graph_node == null:
		return

	_refresh_graph_model()
	var node_record = graph_model.node_records.get(String(graph_node.name))
	if node_record != null:
		status_text_changed.emit(node_record.describe())
		return

	status_text_changed.emit(
		"Selected node: %s\nScene name: %s\nPosition: %s\nInput: %s\nOutput: %s" % [
			graph_node.title,
			graph_node.name,
			graph_node.position_offset,
			graph_node.get("input_port_label"),
			graph_node.get("output_port_label"),
		]
	)


func _on_node_deselected(_node: Node) -> void:
	_refresh_graph_model()
	status_text_changed.emit(_describe_graph_status())


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


func _refresh_graph_model() -> void:
	graph_model = CanvasAdapter.build_model(self)
	graph_evaluation = GraphEvaluator.evaluate(graph_model)


func _apply_canvas_style() -> void:
	connection_lines_thickness = 3.0
	add_theme_stylebox_override("panel", _make_canvas_style())
	add_theme_color_override("grid_major", GRID_MAJOR)
	add_theme_color_override("grid_minor", GRID_MINOR)
	add_theme_color_override("connection_hover_tint_color", LINK_COLOR)
	add_theme_color_override("connection_valid_target_tint_color", LINK_COLOR)


func _make_canvas_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = CANVAS_BG
	style.border_color = CANVAS_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	return style


func _describe_connection(action: String, from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> String:
	return "%s:\n%s[%d] -> %s[%d]\nVisual connections: %d\nGraph links: %d" % [
		action,
		from_node,
		from_port,
		to_node,
		to_port,
		get_connection_list().size(),
		graph_model.link_count(),
	]


func _describe_graph_status() -> String:
	return "Graph status:\nVisual nodes: %d\nVisual connections: %d\nGraph nodes: %d\nGraph links: %d\n\n%s" % [
		_count_graph_nodes(),
		get_connection_list().size(),
		graph_model.node_count(),
		graph_model.link_count(),
		graph_evaluation.describe(),
	]


func _count_graph_nodes() -> int:
	var count := 0
	for child in get_children():
		if child is GraphNode:
			count += 1
	return count
