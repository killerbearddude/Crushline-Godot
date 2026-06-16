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
	_check_resource_compatibility(model, output)
	_evaluate_basic_rate_flow(model, output)
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


static func _check_resource_compatibility(model: RefCounted, output: RefCounted) -> void:
	var checked_links := 0
	var compatible_links := 0
	for link_record in model.link_records:
		var from_record: RefCounted = model.node_records.get(link_record.from_node_id)
		var to_record: RefCounted = model.node_records.get(link_record.to_node_id)
		if from_record == null or to_record == null:
			continue

		checked_links += 1
		var produced_resource := str(from_record.output_resource_for_port(link_record.from_port_index))
		var expected_resource := str(to_record.input_resource_for_port(link_record.to_port_index))
		if produced_resource.is_empty() or expected_resource.is_empty():
			output.add_warning("Port mismatch: %s has no compatible target slot on %s. Link remains connected; target output is zero until the route is fixed." % [from_record.display_name, to_record.display_name])
			continue

		if to_record.accepts_resource_at_port(produced_resource, link_record.to_port_index):
			compatible_links += 1
			continue

		output.add_warning(
			"Resource mismatch: %s outputs %s, but %s port %d expects %s. Link remains connected; target output is zero until the route is fixed." % [
				from_record.display_name,
				produced_resource,
				to_record.display_name,
				link_record.to_port_index + 1,
				expected_resource,
			]
		)

	if checked_links > 0:
		output.add_fact("Compatible resource links: %d/%d" % [compatible_links, checked_links])


static func _evaluate_basic_rate_flow(model: RefCounted, output: RefCounted) -> void:
	var outgoing_rates: Dictionary = {}
	var consuming_rates: Dictionary = {}
	var bottleneck: Dictionary = {}
	for node_id in model.node_records.keys():
		outgoing_rates[node_id] = _resolve_output_rate(model, str(node_id), outgoing_rates, consuming_rates, [], output)

	for node_id in model.node_records.keys():
		var node_record: RefCounted = model.node_records[node_id]
		var produced_rate := int(outgoing_rates.get(node_id, 0))
		var consumed_rate := int(consuming_rates.get(node_id, 0))
		if node_record.is_source():
			output.add_fact("%s produces %d/m %s." % [node_record.display_name, produced_rate, node_record.output_resource])
		else:
			output.add_fact("%s consumes %d/m %s and produces %d/m %s." % [node_record.display_name, consumed_rate, node_record.input_resource, produced_rate, node_record.output_resource])

		if not node_record.is_source() and produced_rate == 0:
			var reason := _zero_output_reason(model, node_record, outgoing_rates)
			output.add_warning("Zero output: %s produces 0/m %s because %s." % [node_record.display_name, node_record.output_resource, reason])

	for link_record in model.link_records:
		var from_record: RefCounted = model.node_records.get(link_record.from_node_id)
		var to_record: RefCounted = model.node_records.get(link_record.to_node_id)
		if from_record == null or to_record == null:
			continue
		var produced_resource := str(from_record.output_resource_for_port(link_record.from_port_index))
		if not to_record.accepts_resource_at_port(produced_resource, link_record.to_port_index):
			continue

		var source_rate := int(outgoing_rates.get(link_record.from_node_id, 0))
		var target_consumption := int(consuming_rates.get(link_record.to_node_id, 0))
		var link_rate := mini(source_rate, target_consumption)
		output.add_fact("Flow %s -> %s: %d/m %s." % [from_record.display_name, to_record.display_name, link_rate, produced_resource])
		if link_rate > 0 and (bottleneck.is_empty() or link_rate < int(bottleneck.get("rate", 0))):
			bottleneck = {
				"from": from_record.display_name,
				"to": to_record.display_name,
				"resource": produced_resource,
				"rate": link_rate,
			}

	if not bottleneck.is_empty():
		output.add_fact("Bottleneck link: %s -> %s at %d/m %s." % [bottleneck["from"], bottleneck["to"], bottleneck["rate"], bottleneck["resource"]])

	_add_basic_iron_objective(model, output, outgoing_rates)


static func _add_basic_iron_objective(model: RefCounted, output: RefCounted, outgoing_rates: Dictionary) -> void:
	var has_ingot_machine := false
	var best_ingot_rate := 0
	for node_id in model.node_records.keys():
		var node_record: RefCounted = model.node_records[node_id]
		if node_record.output_resource != "Iron Ingot":
			continue

		has_ingot_machine = true
		best_ingot_rate = maxi(best_ingot_rate, int(outgoing_rates.get(node_id, 0)))

	if best_ingot_rate > 0:
		output.add_fact("Objective: Basic Iron Processing producing %d/m Iron Ingot." % best_ingot_rate)
		return

	if has_ingot_machine:
		output.add_fact("Objective: Basic Iron Processing incomplete - Smelter is not producing Iron Ingot.")
	else:
		output.add_fact("Objective: Basic Iron Processing incomplete - add a Smelter output route.")


static func _resolve_output_rate(model: RefCounted, node_id: String, outgoing_rates: Dictionary, consuming_rates: Dictionary, visiting: Array, output: RefCounted) -> int:
	if outgoing_rates.has(node_id) and int(outgoing_rates[node_id]) > 0:
		return int(outgoing_rates[node_id])

	if visiting.has(node_id):
		output.add_warning("Cycle detected at %s; Slice 1 rate flow treats cyclic output as 0/m." % node_id)
		return 0

	var node_record: RefCounted = model.node_records.get(node_id)
	if node_record == null:
		return 0

	if node_record.is_source():
		var source_rate := int(node_record.nominal_rate_per_minute)
		outgoing_rates[node_id] = source_rate
		consuming_rates[node_id] = 0
		return source_rate

	var next_visiting: Array = visiting.duplicate()
	next_visiting.append(node_id)
	var input_available := _resolve_required_input_rate(model, node_record, outgoing_rates, consuming_rates, next_visiting, output)
	var output_rate := mini(input_available, int(node_record.nominal_rate_per_minute))
	outgoing_rates[node_id] = output_rate
	consuming_rates[node_id] = output_rate
	return output_rate


static func _resolve_required_input_rate(model: RefCounted, node_record: RefCounted, outgoing_rates: Dictionary, consuming_rates: Dictionary, visiting: Array, output: RefCounted) -> int:
	var required_count := int(node_record.required_resource_count())
	if required_count == 0:
		return int(node_record.nominal_rate_per_minute)

	var rates_by_resource: Dictionary = {}
	for resource in node_record.input_resources:
		rates_by_resource[str(resource)] = 0

	for link_record in model.link_records:
		if link_record.to_node_id != node_record.id:
			continue

		var from_record: RefCounted = model.node_records.get(link_record.from_node_id)
		if from_record == null:
			continue
		var produced_resource := str(from_record.output_resource_for_port(link_record.from_port_index))
		if not node_record.accepts_resource_at_port(produced_resource, link_record.to_port_index):
			continue

		var upstream_rate := _resolve_output_rate(model, link_record.from_node_id, outgoing_rates, consuming_rates, visiting, output)
		var previous_rate := int(rates_by_resource.get(produced_resource, 0))
		rates_by_resource[produced_resource] = previous_rate + upstream_rate

	var limiting_rate := 0
	var first_resource := true
	for resource in node_record.input_resources:
		var resource_rate := int(rates_by_resource.get(str(resource), 0))
		if first_resource:
			limiting_rate = resource_rate
			first_resource = false
		else:
			limiting_rate = mini(limiting_rate, resource_rate)

	return limiting_rate


static func _zero_output_reason(model: RefCounted, node_record: RefCounted, outgoing_rates: Dictionary) -> String:
	var has_incoming := false
	var has_wrong_resource := false
	var supplied_resources: Dictionary = {}
	for link_record in model.link_records:
		if link_record.to_node_id != node_record.id:
			continue

		has_incoming = true
		var from_record: RefCounted = model.node_records.get(link_record.from_node_id)
		if from_record == null:
			continue
		var produced_resource := str(from_record.output_resource_for_port(link_record.from_port_index))
		if not node_record.accepts_resource_at_port(produced_resource, link_record.to_port_index):
			has_wrong_resource = true
			continue
		if int(outgoing_rates.get(link_record.from_node_id, 0)) > 0:
			supplied_resources[produced_resource] = true

	for resource in node_record.input_resources:
		var resource_name := str(resource)
		if resource_name != "none" and not supplied_resources.has(resource_name):
			return "missing required input resource: %s" % resource_name

	if has_wrong_resource:
		return "incoming links provide the wrong resource"
	if not has_incoming:
		return "it has no input link"
	return "upstream flow is 0/m"


static func _check_disconnected_nodes(model: RefCounted, output: RefCounted) -> void:
	var linked_node_ids := {}
	for link_record in model.link_records:
		linked_node_ids[link_record.from_node_id] = true
		linked_node_ids[link_record.to_node_id] = true

	for node_id in model.node_records.keys():
		if linked_node_ids.has(node_id):
			continue

		var node_record: RefCounted = model.node_records[node_id]
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
		var from_record: RefCounted = model.node_records.get(link_record.from_node_id)
		var to_record: RefCounted = model.node_records.get(link_record.to_node_id)
		if from_record == null or to_record == null:
			continue

		if from_record.display_name == from_display_name and to_record.display_name == to_display_name:
			return true

	return false
