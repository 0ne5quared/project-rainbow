extends Sigil


func on_card_damaged(
	victim: Card, amount: int, attacker_type: Action.IDType, attacker_id: String
) -> void:
	if victim != attached_card or attacker_type == Action.IDType.PLAYER:
		return
	damage_card(attacker_id, 1, Action.IDType.CARD, victim.id)
