extends Sigil


func new_form() -> Ruleset.CardData:
	return Global.get_card_by_name(get_config("defrost_form", "Opposum") as String)


func on_card_perished(card: Card) -> void:
	if card != attached_card:
		return
	create_and_play_token(new_form(), get_pos(attached_card.id))
