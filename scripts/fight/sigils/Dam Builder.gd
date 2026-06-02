extends Sigil


func on_played(
	_card: Card, _pos: Vector2i, _placer_type: FightManager.ID, _placer_id: int
) -> Array[Dictionary]:
	if _card != card:
		return []

	return [
		fight_manager.Action.new_play_card_action(
			(
				fight_manager
				. card_manager
				. add_card({name = "Dam", attack = 1, health = 1}, Card.Zone.LIMBO)
				. id
			),
			_pos + Vector2i.RIGHT,
			FightManager.ID.CARD,
			card.id
		),
		fight_manager.Action.new_play_card_action(
			(
				fight_manager
				. card_manager
				. add_card({name = "Dam", attack = 1, health = 1}, Card.Zone.LIMBO)
				. id
			),
			_pos + Vector2i.LEFT,
			FightManager.ID.CARD,
			card.id
		)
	]
