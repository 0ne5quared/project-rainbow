extends Sigil


func on_turn_start(player_id: String) -> void:
	if attached_card.zone != Card.Zone.BOARD:
		return
	attached_card.submerge_overlay.visible = player_id != controller_id()


func replace_action(type: Action.Type, act: Action) -> Array[Action]:
	if type != Action.Type.CARD_STRIKE or attached_card.zone != Card.Zone.BOARD:
		return []
	var action := act as CardStrikeAction
	if action.pos != fight_manager.board_manager.get_card_pos(attached_card.id):
		return []
	return [CardStrikeAction.new(action.pos, action.striker_id, true)]
