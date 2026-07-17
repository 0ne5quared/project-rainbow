extends Sigil


func on_card_perished(card: Card) -> void:
	if card != attached_card:
		return
	add_card(controller_id(), attached_card.id)
