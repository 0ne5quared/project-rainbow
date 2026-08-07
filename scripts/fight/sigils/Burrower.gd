extends Sigil


func pre_card_strike(striker: Card, victim_slot: BoardManager.Slot, _to_face: bool) -> void:
	if (
		(
			oppose_pos(victim_slot.pos).y
			== fight_manager.board_manager.get_card_pos(attached_card.id).y
		)
		or not victim_slot.is_empty()
	):
		return
	if not striker.sigils.has("Airborne") or attached_card.sigils.has("Mighty Leap"):
		move_card(attached_card.id, victim_slot.pos)
