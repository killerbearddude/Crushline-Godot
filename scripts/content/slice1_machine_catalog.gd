extends RefCounted

const MACHINE_IDS: Array[String] = [
	"resource_source",
	"coal_source",
	"water_source",
	"crusher",
	"washer",
	"smelter",
	"basic_generator",
]

const DEFINITIONS := {
	"resource_source": {
		"id": "resource_source",
		"display_name": "Resource Source",
		"subtitle": "SOURCE",
		"button_path": "Root/Body/MachineLibraryPanel/MachineLibraryContents/AddResourceSourceButton",
		"input_resource": "none",
		"output_resource": "Iron Ore",
		"nominal_rate_per_minute": 720,
		"rate_label": "720/m",
		"footer_label": "external feed / no input required",
	},
	"coal_source": {
		"id": "coal_source",
		"display_name": "Coal Source",
		"subtitle": "SOURCE",
		"button_path": "Root/Body/MachineLibraryPanel/MachineLibraryContents/AddCoalSourceButton",
		"input_resource": "none",
		"output_resource": "Coal",
		"nominal_rate_per_minute": 240,
		"rate_label": "240/m",
		"footer_label": "fuel feed / no input required",
	},
	"water_source": {
		"id": "water_source",
		"display_name": "Water Source",
		"subtitle": "SOURCE",
		"button_path": "Root/Body/MachineLibraryPanel/MachineLibraryContents/AddWaterSourceButton",
		"input_resource": "none",
		"output_resource": "Water",
		"nominal_rate_per_minute": 600,
		"rate_label": "600/m",
		"footer_label": "fluid feed / no input required",
	},
	"crusher": {
		"id": "crusher",
		"display_name": "Crusher",
		"subtitle": "MECHANICAL",
		"button_path": "Root/Body/MachineLibraryPanel/MachineLibraryContents/AddCrusherButton",
		"input_resource": "Iron Ore",
		"output_resource": "Crushed Iron Ore",
		"nominal_rate_per_minute": 480,
		"rate_label": "480/m",
		"footer_label": "route pending",
	},
	"washer": {
		"id": "washer",
		"display_name": "Washer",
		"subtitle": "FLUID",
		"button_path": "Root/Body/MachineLibraryPanel/MachineLibraryContents/AddWasherButton",
		"input_resource": "Crushed Iron Ore",
		"output_resource": "Washed Iron Ore",
		"byproduct_resource": "Slurry",
		"nominal_rate_per_minute": 360,
		"rate_label": "360/m",
		"footer_label": "water support coming soon / byproduct: Slurry",
	},
	"smelter": {
		"id": "smelter",
		"display_name": "Smelter",
		"subtitle": "THERMAL",
		"button_path": "Root/Body/MachineLibraryPanel/MachineLibraryContents/AddSmelterButton",
		"input_resource": "Washed Iron Ore",
		"output_resource": "Iron Ingot",
		"nominal_rate_per_minute": 180,
		"rate_label": "180/m",
		"footer_label": "power required soon",
	},
	"basic_generator": {
		"id": "basic_generator",
		"display_name": "Basic Generator",
		"subtitle": "POWER",
		"button_path": "Root/Body/MachineLibraryPanel/MachineLibraryContents/AddBasicGeneratorButton",
		"input_resource": "Coal",
		"output_resource": "Power",
		"nominal_rate_per_minute": 120,
		"rate_label": "120 power/m",
		"footer_label": "burns coal / powers machines soon",
	},
}

static func machine_ids() -> Array[String]:
	return MACHINE_IDS.duplicate()


static func get_machine_definition(machine_id: String) -> Dictionary:
	return DEFINITIONS.get(machine_id, {}).duplicate(true)


static func input_port_label(definition: Dictionary) -> String:
	return "In: %s" % definition.get("input_resource", "input")


static func output_port_label(definition: Dictionary) -> String:
	return "Out: %s" % definition.get("output_resource", "output")


static func button_tooltip(definition: Dictionary) -> String:
	var input_resource := str(definition.get("input_resource", "input"))
	var output_resource := str(definition.get("output_resource", "output"))
	var rate_label := str(definition.get("rate_label", "ready"))
	var byproduct := str(definition.get("byproduct_resource", ""))
	var text := "%s -> %s at %s" % [input_resource, output_resource, rate_label]
	if not byproduct.is_empty():
		text += "\nByproduct: %s" % byproduct
	return text
