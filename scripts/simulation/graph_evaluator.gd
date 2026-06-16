extends RefCounted

const EvaluationResult = preload("res://scripts/simulation/evaluation_result.gd")

static func evaluate(model: RefCounted) -> RefCounted:
	var output := EvaluationResult.new()
	output.add_fact("Graph nodes: %d" % model.node_count())
	output.add_fact("Graph links: %d" % model.link_count())

	if model.node_count() == 0:
		output.add_warning("Graph has no machine nodes.")
		return output

	_check_links(model, output)
	_check_disconnected_nodes(model, output)
	_check_basic_iron_chain(model, output)
	return output


static func _check_links(model: RefCounted, output: RefCounted) -> void:
	for link_record in model.link_records:
		if link_record.from_node_id == link_record.to_node_id:
			output.add_hard_error("Self-link found in model: %s" % link_record.describe())

		if not model.node_records.has(link_record.from_node_id):
			output.add_hard_error("Link source is missing: %s" % link_record.describe())

		if not model.node_records.has(link_record.to_node_id):
			output.add_hard_error("Link target is missing: %s" % link_record.describe())


static func _check_disconnected_nodes(model: RefCounted, output: RefCounted) -> void:
	var linked_node_ids := {}
	for link_record in model.link_records:
		linked_node_ids[link_record.from_node_id] = true
		linked_node_ids[link_record.to_node_id] = true

	for node_id in model.node_records.keys():
		if linked_node_ids.has(node_id):
			continue

		var node_record = model.node_records[node_id]
		output.add_warning("Disconnected node: %s (%s)" % [node_record.display_name, node_record.id])


static func _check_basic_iron_chain(model: RefCounted, output: RefCounted) -> void:
	var required_names := ["Resource Source", "Crusher", "Washer", "Smelter"]
	var missing_names: Array[String] = []
	for display_name in required_names:
		if not _has_node_named(model, display_name):
			missing_names.append(display_name)

	if not missing_names.is_empty():
		output.add_warning("Basic iron chain missing machines: %s" % ", ".join(missing_names))
		return

	var missing_steps: Array[String] = []
	if not _has_link_between_names(model, "Resource Source", "Crusher"):
		missing_steps.append("Resource Source -> Crusher")
	if not _has_link_between_names(model, "Crusher", "Washer"):
		missing_steps.append("Crusher -> Washer")
	if not _has_link_between_names(model, "Washer", "Smelter"):
		missing_steps.append("Washer -> Smelter")

	if missing_steps.is_empty():
		output.add_fact("Basic iron chain scaffold is connected.")
	else:
		output.add_warning("Basic iron chain missing links: %s" % ", ".join(missing_steps))


static func _has_node_named(model: RefCounted, display_name: String) -> bool:
	for node_record in model.node_records.values():
		if node_record.display_name == display_name:
			return true
	return false


static func _has_link_between_names(model: RefCounted, from_display_name: String, to_display_name: String) -> bool:
	for link_record in model.link_records:
		var from_record = model.node_records.get(link_record.from_node_id)
		var to_record = model.node_records.get(link_record.to_node_id)
		if from_record == null or to_record == null:
			continue

		if from_record.display_name == from_display_name and to_record.display_name == to_display_name:
			return true

	return false
