extends Sigil


func dig_yield() -> int:
	return get_config("dig_yield", 1) as int


func on_turn_end(player_id: String) -> void:
	if player_id != controller_id() or attached_card.zone != Card.Zone.BOARD:
		return
	change_bone(dig_yield(), player_id)
