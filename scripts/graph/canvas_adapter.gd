extends RefCounted

const GraphModel = preload("res://scripts/graph/graph_model.gd")
const GraphNodeRecord = preload("res://scripts/graph/graph_node_record.gd")
const GraphLinkRecord = preload("res://scripts/graph/graph_link_record.gd")

static func build_model(canvas: GraphEdit) -> RefCounted:
	var model := GraphModel.new()
	_add_nodes(canvas, model)
	_add_links(canvas, model)
	return model


static func _add_nodes(canvas: GraphEdit, model: RefCounted) -> void:
	for child in canvas.get_children():
		var item := child as GraphNode
		if item == null:
			continue

		var record := GraphNodeRecord.new()
		record.setup(String(item.name), String(item.name), str(item.get("machine_display_name")), str(item.get("input_port_label")), str(item.get("output_port_label")), item.position_offset)
		model.add_node_record(record)


static func _add_links(canvas: GraphEdit, model: RefCounted) -> void:
	var link_index := 0
	for connection in canvas.get_connection_list():
		var record := GraphLinkRecord.new()
		record.setup("link_%03d" % link_index, String(connection["from_node"]), int(connection["from_port"]), String(connection["to_node"]), int(connection["to_port"]))
		model.add_link_record(record)
		link_index += 1
