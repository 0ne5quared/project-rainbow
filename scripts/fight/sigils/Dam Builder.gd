extends Sigil


func on_card_played(
	played_card: Card, pos: Vector2i, _placer_type: Action.IDType, _placer_id: String
) -> void:
	if played_card != attached_card:
		return

	var dam_data := {
		name = "Dam",
		attack = 1,
		health = 2,
	}
	create_and_play_token(dam_data, pos + Vector2i.LEFT, attached_card.id)
	create_and_play_token(dam_data, pos + Vector2i.RIGHT, attached_card.id)
