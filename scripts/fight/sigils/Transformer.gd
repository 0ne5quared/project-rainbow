extends TransformerSigil


func turn_threshold() -> int:
	return 1


func new_form() -> Ruleset.CardData:
	return Global.get_card_by_name(get_config("transform_form", "MISSING") as String)
