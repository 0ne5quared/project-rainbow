@abstract class_name DrawDeathSigil
extends Sigil

## Return the data that is used to spawn the friend.
@abstract func new_form() -> Ruleset.CardData


func on_card_perished(card: Card) -> void:
	if card != attached_card:
		return
	create_and_add_token(new_form(), controller_id(), card.id)
