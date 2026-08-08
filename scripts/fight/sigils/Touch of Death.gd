extends Sigil


func on_card_damaged(
	victim: Card, _amount: int, attacker_type: Action.IDType, attacker_id: String
) -> void:
	if attacker_type == Action.IDType.PLAYER or attacker_id != attached_card.id:
		return
	if not victim.sigils.has("Made of Stone"):
		kill_card(victim.id)
