extends Sigil


func on_card_perished(card: Card) -> void:
	push_warning(not fight_manager.in_combat)
	if (
		not fight_manager.in_combat
		or attached_card.zone != Card.Zone.HAND
		or fight_manager.board_manager.get_card_pos(card.id).y != BoardManager.Row.MINE
	):
		return
	play_card(
		attached_card.id,
		fight_manager.board_manager.get_card_pos(card.id),
		Action.IDType.CARD,
		attached_card.id
	)
