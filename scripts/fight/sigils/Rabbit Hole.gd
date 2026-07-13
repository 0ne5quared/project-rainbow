extends Sigil


func on_card_played(
	card: Card, _pos: Vector2i, _placer_type: Action.IDType, _placer_id: String
) -> void:
	if card != attached_card:
		return
	add_card(
		{
			name = "Rabbit",
		},
		controller_id()
	)
