extends RefCounted

var id := ""
var from_node_id := ""
var from_port_index := 0
var to_node_id := ""
var to_port_index := 0

func setup(link_id: String, source_node_id: String, source_port_index: int, target_node_id: String, target_port_index: int) -> void:
	id = link_id
	from_node_id = source_node_id
	from_port_index = source_port_index
	to_node_id = target_node_id
	to_port_index = target_port_index


func describe() -> String:
	return "%s[%d] -> %s[%d]" % [from_node_id, from_port_index, to_node_id, to_port_index]
