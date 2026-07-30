extends Sigil


func rabbit_data() -> Ruleset.CardData:
	return Global.get_card_by_name(get_config("rabbit_card", "Rabbit") as String)


func on_card_played(
	card: Card, _pos: Vector2i, _placer_type: Action.IDType, _placer_id: String
) -> void:
	if card != attached_card:
		return
	create_and_add_token(rabbit_data())
