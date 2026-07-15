extends Sigil


func replace_action(type: Action.Type, act: Action) -> Array[Action]:
	if type != Action.Type.CARD_STRIKE:
		return []
	var action := act as CardStrikeAction
	if fight_manager.card_manager.get_card_by_id(action.striker_id) != attached_card:
		return []
	var slot := await request_target(
		controller_id(), func(s: BoardManager.Slot) -> bool: return s.pos.y == BoardManager.Row.OPP
	)
	return [CardStrikeAction.new(slot.pos, action.striker_id, action.to_face)]
