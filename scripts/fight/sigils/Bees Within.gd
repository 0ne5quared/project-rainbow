extends Sigil


func bee_data() -> Ruleset.CardData:
	return Global.get_card_by_name(get_config("bee_card", "Bee") as String)


func on_card_damaged(
	victim: Card, amount: int, attacker_type: Action.IDType, attacker_id: String
) -> void:
	if victim != attached_card:
		return

	create_and_add_token(bee_data(), controller_id(), attached_card.id)
