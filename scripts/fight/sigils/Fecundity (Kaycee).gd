extends Sigil


func on_card_played(
	card: Card, pos: Vector2i, placer_type: Action.IDType, placer_id: String
) -> void:
	if card != attached_card:
		return
	var cd := card.card_data
	cd.sigils.remove_at(cd.sigils.find("Fecundity (Kaycee)"))
	create_and_add_token(cd, controller_id(), card.id)
