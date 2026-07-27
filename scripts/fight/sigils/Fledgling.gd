extends TransformerSigil


func turn_threshold() -> int:
	return get_config("evolve_time", 1)


func new_form() -> Ruleset.CardData:
	var elder_form := attached_card.card_data.duplicate()
	elder_form.attack += 1
	elder_form.health += 2
	elder_form.sigils.remove_at(elder_form.sigils.find("Fledgling"))
	var evolve_form: String = get_config("evolve_form", "")
	return elder_form if evolve_form.is_empty else Global.get_card_by_name(evolve_form)
