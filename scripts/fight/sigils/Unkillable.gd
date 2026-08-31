extends DrawDeathSigil


func new_form() -> Ruleset.CardData:
	var cd := attached_card.card_data
	if get_config("nerfed", false) as bool:
		cd.sigils.remove_at(cd.sigils.find("Unkillable"))
	return cd
