extends TransformerSigil


func turn_threshold() -> int:
	return get_config("turn_threshold", 1)


func new_form() -> Dictionary:
	var elder_form := attached_card.card_data.duplicate(true)
	elder_form.attack += 1
	elder_form.health += 2
	elder_form.sigils.remove_at(elder_form.sigils.find("Fledgling"))
	return attached_card.card_data.evolve if "evolve" in attached_card.card_data else elder_form
