extends Sigil


func replace_action(type: Action.Type, act: Action) -> Array[Action]:
	if type != Action.Type.CARD_STRIKE:
		return []
	var action := act as CardStrikeAction
	if action.striker_id != attached_card.id:
		return []
	return [CardStrikeAction.new(action.pos, action.striker_id, true)]
