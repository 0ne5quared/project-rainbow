extends Sigil


func replace_action(type: Action.Type, act: Action) -> Array[Action]:
	if type != Action.Type.CHANGE_BONES:
		return []
	var action := act as ChangeBonesAction
	if action.death_source_id == null or action.death_source_id != attached_card.id:
		return []
	return [ChangeBonesAction.new(4, action.player_id, action.death_source_id)]
