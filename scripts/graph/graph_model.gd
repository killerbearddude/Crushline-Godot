extends RefCounted

var node_records := {}
var link_records := []

func add_node_record(record: RefCounted) -> void:
	node_records[record.id] = record

func add_link_record(record: RefCounted) -> void:
	link_records.append(record)

func node_count() -> int:
	return node_records.size()

func link_count() -> int:
	return link_records.size()
