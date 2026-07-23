extends TransformerSigil


func turn_threshold() -> int:
	return 1


func new_form() -> Dictionary:
	return get_config("new_form", {})
