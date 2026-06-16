extends RefCounted

var id := ""
var scene_name := ""
var display_name := ""
var input_label := ""
var output_label := ""
var position := Vector2.ZERO

func setup(node_id: String, node_scene_name: String, node_display_name: String, node_input_label: String, node_output_label: String, node_position: Vector2) -> void:
	id = node_id
	scene_name = node_scene_name
	display_name = node_display_name
	input_label = node_input_label
	output_label = node_output_label
	position = node_position


func describe() -> String:
	return "Node id: %s\nScene name: %s\nDisplay: %s\nPosition: %s\nInput: %s\nOutput: %s" % [
		id,
		scene_name,
		display_name,
		position,
		input_label,
		output_label,
	]
