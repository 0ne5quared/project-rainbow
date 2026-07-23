extends Sigil


func on_card_played(
	card: Card, _pos: Vector2i, _placer_type: Action.IDType, _placer_id: String
) -> void:
	if card != attached_card:
		return
	create_and_add_token(
		{name = "Rabbit", health = 0, attack = 1},
	)
