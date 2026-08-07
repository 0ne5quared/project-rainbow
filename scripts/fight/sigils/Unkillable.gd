extends Sigil


func on_card_perished(card: Card) -> void:
	if card != attached_card:
		return
	var cd := card.card_data
	if get_config("nerfed", false) as bool:
		cd.sigils.remove_at(cd.sigils.find("Unkillable"))
	add_card(controller_id(), attached_card.id)
