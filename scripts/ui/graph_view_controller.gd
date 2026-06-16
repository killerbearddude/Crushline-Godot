extends GraphEdit

signal status_text_changed(text: String)

const TEST_NODE_NAME := "TestResourceSourceNode"
const MACHINE_GRAPH_NODE_SCENE_PATH := "res://scenes/graph/MachineGraphNode.tscn"
const GRAPH_SAVE_PATH := "user://slice1_graph_save.json"
const CanvasAdapter = preload("res://scripts/graph/canvas_adapter.gd")
const GraphEvaluator = preload("res://scripts/simulation/graph_evaluator.gd")
const Slice1MachineCatalog = preload("res://scripts/content/slice1_machine_catalog.gd")
const PORT_TYPE_RESOURCE := 0
const CANVAS_BG := Color(0.045, 0.050, 0.062)
const CANVAS_BORDER := Color(0.14, 0.18, 0.22)
const GRID_MAJOR := Color(0.22, 0.28, 0.33)
const GRID_MINOR := Color(0.11, 0.135, 0.16)
const LINK_COLOR := Color(0.70, 0.88, 0.92)
const PORT_GRAB_DISTANCE := 32

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


func add_machine_node(machine_id: String) -> void:
	var definition := Slice1MachineCatalog.get_machine_definition(machine_id)
	if definition.is_empty():
		status_text_changed.emit("Unknown machine definition: %s" % machine_id)
		return

	next_node_index += 1
	var display_name := str(definition.get("display_name", machine_id))
	var node_name := "%sNode%d" % [display_name.replace(" ", ""), next_node_index]
	var position := Vector2(360.0 + (next_node_index * 40.0), 120.0 + (next_node_index * 30.0))
	_create_machine_node_from_definition(node_name, definition, position)
	_refresh_graph_model()
	status_text_changed.emit(_describe_graph_status())


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


func save_graph_to_default_path() -> void:
	var file := FileAccess.open(GRAPH_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		status_text_changed.emit("Save failed: could not open %s (error %s)." % [GRAPH_SAVE_PATH, FileAccess.get_open_error()])
		return

	file.store_string(JSON.stringify(_serialize_graph(), "\t"))
	file.close()
	_refresh_graph_model()
	status_text_changed.emit("Graph saved to %s\n\n%s" % [GRAPH_SAVE_PATH, _describe_graph_status()])


func load_graph_from_default_path() -> void:
	if not FileAccess.file_exists(GRAPH_SAVE_PATH):
		status_text_changed.emit("Load failed: no saved graph at %s." % GRAPH_SAVE_PATH)
		return

	var file := FileAccess.open(GRAPH_SAVE_PATH, FileAccess.READ)
	if file == null:
		status_text_changed.emit("Load failed: could not open %s (error %s)." % [GRAPH_SAVE_PATH, FileAccess.get_open_error()])
		return

	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		status_text_changed.emit("Load failed: saved graph is not valid JSON graph data.")
		return

	_rebuild_graph_from_save(parsed)
	_refresh_graph_model()
	status_text_changed.emit("Graph loaded from %s\n\n%s" % [GRAPH_SAVE_PATH, _describe_graph_status()])


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

	var definition := Slice1MachineCatalog.get_machine_definition("resource_source")
	if definition.is_empty():
		_create_machine_node(TEST_NODE_NAME, "Resource Source", "In: none", "Out: Iron Ore", Vector2(80.0, 80.0))
		return

	_create_machine_node_from_definition(TEST_NODE_NAME, definition, Vector2(80.0, 80.0))


func _create_machine_node(node_name: String, machine_display_name: String, input_port_label: String, output_port_label: String, position: Vector2, machine_id := "") -> void:
	var machine_graph_node_scene := load(MACHINE_GRAPH_NODE_SCENE_PATH) as PackedScene
	var graph_node := machine_graph_node_scene.instantiate()
	graph_node.name = node_name
	graph_node.position_offset = position
	graph_node.set("machine_display_name", machine_display_name)
	graph_node.set("input_port_label", input_port_label)
	graph_node.set("output_port_label", output_port_label)
	if not machine_id.is_empty():
		graph_node.set_meta("machine_id", machine_id)

	add_child(graph_node)


func _create_machine_node_from_definition(node_name: String, definition: Dictionary, position: Vector2) -> void:
	_create_machine_node(
		node_name,
		str(definition.get("display_name", node_name)),
		Slice1MachineCatalog.input_port_label(definition),
		Slice1MachineCatalog.output_port_label(definition),
		position,
		str(definition.get("id", ""))
	)


func _refresh_graph_model() -> void:
	graph_model = CanvasAdapter.build_model(self)
	graph_evaluation = GraphEvaluator.evaluate(graph_model)


func _serialize_graph() -> Dictionary:
	var nodes: Array[Dictionary] = []
	for child in get_children():
		var graph_node := child as GraphNode
		if graph_node == null:
			continue

		nodes.append({
			"name": String(graph_node.name),
			"machine_id": _machine_id_for_graph_node(graph_node),
			"display_name": str(graph_node.get("machine_display_name")),
			"input_port_label": str(graph_node.get("input_port_label")),
			"output_port_label": str(graph_node.get("output_port_label")),
			"position": {
				"x": graph_node.position_offset.x,
				"y": graph_node.position_offset.y,
			},
		})

	var connections: Array[Dictionary] = []
	for connection in get_connection_list():
		connections.append({
			"from_node": String(connection["from_node"]),
			"from_port": int(connection["from_port"]),
			"to_node": String(connection["to_node"]),
			"to_port": int(connection["to_port"]),
		})

	return {
		"version": 1,
		"nodes": nodes,
		"connections": connections,
	}


func _rebuild_graph_from_save(save_data: Dictionary) -> void:
	_clear_graph()
	var loaded_count := 0
	for node_data in save_data.get("nodes", []):
		var graph_node_data := node_data as Dictionary
		if graph_node_data == null:
			continue

		var machine_id := str(graph_node_data.get("machine_id", ""))
		var definition := Slice1MachineCatalog.get_machine_definition(machine_id)
		var node_name := str(graph_node_data.get("name", "LoadedNode%d" % loaded_count))
		var position := _vector2_from_save(graph_node_data.get("position", {}))
		if not definition.is_empty():
			_create_machine_node_from_definition(node_name, definition, position)
		else:
			_create_machine_node(
				node_name,
				str(graph_node_data.get("display_name", node_name)),
				str(graph_node_data.get("input_port_label", "In: input")),
				str(graph_node_data.get("output_port_label", "Out: output")),
				position,
				machine_id
			)
		loaded_count += 1

	for connection_data in save_data.get("connections", []):
		var graph_connection_data := connection_data as Dictionary
		if graph_connection_data == null:
			continue

		var from_node := StringName(str(graph_connection_data.get("from_node", "")))
		var to_node := StringName(str(graph_connection_data.get("to_node", "")))
		var from_port := int(graph_connection_data.get("from_port", 0))
		var to_port := int(graph_connection_data.get("to_port", 0))
		if has_node(NodePath(from_node)) and has_node(NodePath(to_node)) and not is_node_connected(from_node, from_port, to_node, to_port):
			connect_node(from_node, from_port, to_node, to_port)

	next_node_index = loaded_count


func _clear_graph() -> void:
	for connection in get_connection_list():
		disconnect_node(connection["from_node"], int(connection["from_port"]), connection["to_node"], int(connection["to_port"]))

	for child in get_children():
		if child is GraphNode:
			remove_child(child)
			child.queue_free()


func _vector2_from_save(position_data) -> Vector2:
	if typeof(position_data) != TYPE_DICTIONARY:
		return Vector2.ZERO
	return Vector2(float(position_data.get("x", 0.0)), float(position_data.get("y", 0.0)))


func _machine_id_for_graph_node(graph_node: GraphNode) -> String:
	if graph_node.has_meta("machine_id"):
		return str(graph_node.get_meta("machine_id"))

	var display_name := str(graph_node.get("machine_display_name"))
	for machine_id in Slice1MachineCatalog.machine_ids():
		var definition := Slice1MachineCatalog.get_machine_definition(machine_id)
		if str(definition.get("display_name", "")) == display_name:
			return machine_id
	return ""


func _apply_canvas_style() -> void:
	connection_lines_thickness = 3.0
	add_theme_stylebox_override("panel", _make_canvas_style())
	add_theme_color_override("grid_major", GRID_MAJOR)
	add_theme_color_override("grid_minor", GRID_MINOR)
	add_theme_color_override("connection_hover_tint_color", LINK_COLOR)
	add_theme_color_override("connection_valid_target_tint_color", LINK_COLOR)
	add_theme_constant_override("port_grab_distance_horizontal", PORT_GRAB_DISTANCE)
	add_theme_constant_override("port_grab_distance_vertical", PORT_GRAB_DISTANCE)


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
