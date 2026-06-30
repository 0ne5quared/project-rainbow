class_name AddCardAction
extends Action

var card_data: Dictionary
var card_id: String
var player_id: String


static func action_type() -> Type:
	return Action.Type.ADD_CARD


func _init(cd: Dictionary, cid: String, pid: String) -> void:
	card_data = cd
	card_id = cid
	player_id = pid


func resolve(fight_manager: FightManager) -> void:
	var data := fight_manager.get_data(player_id)
	data.hand_size += 1
	var card: Card
	push_warning(player_id)
	if player_id == Global.uuid:
		card = fight_manager.hand_manager.draw_card(card_data)
	else:
		card = fight_manager.card_manager.add_card(card_data, Card.Zone.OPP_HAND)
		card.visible = false
	card.id = card_id
	fight_manager.card_manager.sync_id()
	push_warning(fight_manager.card_manager._cards)
	data.public_card.append(card)
	fight_manager._activate_sigils(func(sigil: Sigil) -> void: sigil.on_card_add(card))


func as_dict() -> Dictionary:
	return {type = action_type(), card_data = card_data, card_id = card_id, player_id = player_id}


static func from_dict(dict: Dictionary) -> Action:
	return (
		AddCardAction
		. new(
			dict.card_data as Dictionary,
			dict.card_id as String,
			dict.player_id as String,
		)
	)
