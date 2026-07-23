extends Sigil

var sac_time := 0


func sac_limit() -> int:
	# (1 << 63) - 1 is the integer limit
	return get_config("sac_limit", (1 << 63) - 1)


func new_form() -> Dictionary:
	return get_config("new_form", {})


func replace_action(type: Action.Type, act: Action) -> Array[Action]:
	if type != Action.Type.SACRIFICE_CARD:
		return []

	var action := act as SacrificeCardAction
	if action.card_id != attached_card.id:
		return []
	sac_time += 1
	if sac_time >= sac_limit():
		return [TransformCardAction.new(attached_card.id, new_form())]
	return [NullAction.new()]
