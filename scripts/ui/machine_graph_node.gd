extends GraphNode

const PORT_TYPE_RESOURCE := 0
const PORT_COLOR := Color.WHITE

@export var machine_display_name := "Machine"
@export var input_port_label := "In: input"
@export var output_port_label := "Out: output"

func _ready() -> void:
	apply_placeholder_definition()


func apply_placeholder_definition() -> void:
	title = machine_display_name

	var input_label := get_node_or_null("InputRow/InputLabel") as Label
	if input_label != null:
		input_label.text = input_port_label

	var output_label := get_node_or_null("OutputRow/OutputLabel") as Label
	if output_label != null:
		output_label.text = output_port_label

	set_slot(0, true, PORT_TYPE_RESOURCE, PORT_COLOR, false, PORT_TYPE_RESOURCE, PORT_COLOR)
	set_slot(1, false, PORT_TYPE_RESOURCE, PORT_COLOR, true, PORT_TYPE_RESOURCE, PORT_COLOR)
