extends Sigil


func is_active_sigil() -> bool:
	return true


func is_disable() -> bool:
	return false if fight_manager.get_moxes().blue >= 1 else true


func on_sigil_activate(
	card: Card, sigil: Sigil, source_id: String, source_type: Action.IDType
) -> void:
	if card != attached_card or sigil != self:
		return
	sacrifice_card(card.id)
	draw_cards(DrawCardAction.Deck.MAIN, 3)
