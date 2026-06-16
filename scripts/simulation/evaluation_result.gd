extends RefCounted

var hard_errors: Array[String] = []
var warnings: Array[String] = []
var facts: Array[String] = []

func add_hard_error(message: String) -> void:
	hard_errors.append(message)

func add_warning(message: String) -> void:
	warnings.append(message)

func add_fact(message: String) -> void:
	facts.append(message)

func hard_error_count() -> int:
	return hard_errors.size()

func warning_count() -> int:
	return warnings.size()

func passed() -> bool:
	return hard_errors.is_empty()

func describe() -> String:
	var lines: Array[String] = []
	lines.append("Evaluator status:")
	lines.append("Hard errors: %d" % hard_error_count())
	lines.append("Warnings: %d" % warning_count())

	if hard_errors.is_empty():
		lines.append("No hard structural errors.")
	else:
		lines.append("Hard structural errors:")
		for message in hard_errors:
			lines.append("- %s" % message)

	if not warnings.is_empty():
		lines.append("Warnings:")
		for message in warnings:
			lines.append("- %s" % message)

	if not facts.is_empty():
		lines.append("Facts:")
		for message in facts:
			lines.append("- %s" % message)

	return _join_lines(lines)

func _join_lines(lines: Array[String]) -> String:
	var text := ""
	for line in lines:
		if text != "":
			text += "\n"
		text += line
	return text
