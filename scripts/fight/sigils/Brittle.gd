extends Sigil


func on_card_strike(striker: Card, pos: Vector2i, to_face: bool) -> void:
	if striker != attached_card:
		return
	kill_card(striker.id)
