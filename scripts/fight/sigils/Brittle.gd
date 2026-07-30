extends Sigil


func on_card_strike(striker: Card, _pos: Vector2i, _to_face: bool) -> void:
	if striker != attached_card:
		return
	kill_card(striker.id)
