extends Sigil


func replace_action(type: Action.Type, act: Action) -> Array[Action]:
	if type != Action.Type.CARD_STRIKE:
		return []
	var action := act as CardStrikeAction

	if (
		action.pos == fight_manager.board_manager.get_card_pos(attached_card.id)
		and fight_manager.card_manager.get_card_by_id(action.striker_id).sigils.has("Airborne")
	):
		return [CardStrikeAction.new(action.pos, action.striker_id)]
	return []
