extends Sigil


func is_active_sigil() -> bool:
	return true


func is_disable() -> bool:
	return fight_manager.get_moxes().blue <= 0


func on_sigil_activate(
	card: Card, sigil: Sigil, _source_id: String, _source_type: Action.IDType
) -> void:
	if card != attached_card or sigil != self:
		return
	sacrifice_card(card.id)
	draw_cards(DrawCardAction.Deck.MAIN, 3)
