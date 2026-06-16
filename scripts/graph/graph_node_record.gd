extends RefCounted

var id := ""
var scene_name := ""
var display_name := ""
var input_label := ""
var output_label := ""
var input_resource := ""
var output_resource := ""
var nominal_rate_per_minute := 0
var position := Vector2.ZERO

func setup(node_id: String, node_scene_name: String, node_display_name: String, node_input_label: String, node_output_label: String, node_position: Vector2) -> void:
	id = node_id
	scene_name = node_scene_name
	display_name = node_display_name
	input_label = node_input_label
	output_label = node_output_label
	input_resource = _resource_from_port_label(input_label)
	output_resource = _resource_from_port_label(output_label)
	nominal_rate_per_minute = _nominal_rate_for_output_resource(output_resource)
	position = node_position


func accepts_resource(resource_name: String) -> bool:
	return input_resource == "none" or input_resource == resource_name


func is_source() -> bool:
	return input_resource == "none"


func describe() -> String:
	return "Node id: %s\nScene name: %s\nDisplay: %s\nPosition: %s\nInput: %s\nOutput: %s\nExpected input resource: %s\nProduced output resource: %s\nNominal rate: %d/m" % [
		id,
		scene_name,
		display_name,
		position,
		input_label,
		output_label,
		input_resource,
		output_resource,
		nominal_rate_per_minute,
	]


func _resource_from_port_label(port_label: String) -> String:
	return port_label.replace("In: ", "").replace("Out: ", "").strip_edges()


func _nominal_rate_for_output_resource(resource_name: String) -> int:
	match resource_name:
		"Iron Ore":
			return 720
		"Coal":
			return 240
		"Water":
			return 600
		"Crushed Iron Ore":
			return 480
		"Washed Iron Ore":
			return 360
		"Iron Ingot":
			return 180
		"Power":
			return 120
		_:
			return 0
