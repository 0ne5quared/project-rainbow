extends Sigil


func on_card_played(
	card: Card, pos: Vector2i, placer_type: Action.IDType, placer_id: String
) -> void:
	if card != attached_card:
		return
	push_warning(card.id)
	push_warning(
		add_card(
			{
				name = "Rabbit",
			},
			controller_id()
		)
	)
