class_name KillCardAction
extends Action

var card_id: String


static func action_type() -> Type:
	return Action.Type.KILL_CARD


func _init(cid: String) -> void:
	card_id = cid


func resolve(fight_manager: FightManager) -> void:
	var card := fight_manager.card_manager.get_card_by_id(card_id)
	if card.zone == Card.Zone.BOARD:
		var slot := fight_manager.board_manager.get_slot_with_card(card_id)
		slot.card = null
	fight_manager.card_manager.move_card(card_id, Card.Zone.GRAVEYARD)
	card.visible = false
	fight_manager._activate_sigils(func(sigil: Sigil) -> void: sigil.on_card_perished(card))


func as_dict() -> Dictionary:
	return {type = action_type(), card_id = card_id}


static func from_dict(dict: Dictionary) -> Action:
	return KillCardAction.new(dict.card_id as String)
