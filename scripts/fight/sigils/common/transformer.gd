@abstract class_name TransformerSigil
extends Sigil

var turn_on_board := 0

@abstract func turn_threshold() -> int

@abstract func new_form() -> Ruleset.CardData


func on_turn_start(player_id: String) -> void:
	if player_id != controller_id():
		return
	turn_on_board += 1
	if turn_on_board >= turn_threshold():
		transform_card(attached_card.id, new_form())
