extends Sigil


func on_card_played(
	_card: Card, pos: Vector2i, _placer_type: Action.IDType, _placer_id: String
) -> void:
	if fight_manager.board_manager.get_card_pos(attached_card.id).y == pos.y:
		return
	move_card(attached_card.id, oppose_pos(pos))
