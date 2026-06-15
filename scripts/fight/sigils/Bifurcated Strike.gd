extends Sigil


func on_card_attacked(card: Card) -> Array[CardAttackAction.StrikeGroup]:
	if card != attached_card:
		return []
	var pos := oppose_pos(get_pos(card.id))
	return [
		CardAttackAction.StrikeGroup.new(pos + Vector2i.LEFT).add_strike(card.id),
		CardAttackAction.StrikeGroup.new(pos + Vector2i.RIGHT).add_strike(card.id)
	]
