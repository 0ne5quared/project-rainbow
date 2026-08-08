extends Sigil


func quill_damage() -> int:
	return get_config("quill_damage", 1) as int


func on_card_damaged(
	victim: Card, _amount: int, attacker_type: Action.IDType, attacker_id: String
) -> void:
	if victim != attached_card or attacker_type == Action.IDType.PLAYER:
		return
	damage_card(attacker_id, quill_damage(), Action.IDType.CARD, victim.id)
