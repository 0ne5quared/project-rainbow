extends Sigil


func on_turn_end(player_id: String) -> void:
	if player_id != controller_id() or attached_card.zone != Card.Zone.BOARD:
		return
	change_bone(1, player_id)
