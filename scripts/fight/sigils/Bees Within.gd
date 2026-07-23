extends Sigil


func on_card_damaged(
	victim: Card, amount: int, attacker_type: Action.IDType, attacker_id: String
) -> void:
	if victim != attached_card:
		return

	create_and_add_token(
		{name = "Bee", attack = 1, health = 1, sigils = ["Airborne"]},
		controller_id(),
		attached_card.id
	)
