class_name DrawCardAction
extends Action

enum Deck { MAIN, SIDE }

var deck: Deck
var player_id: String


static func action_type() -> Type:
	return Action.Type.DRAW_CARD


func _init(d: Deck, pid: String) -> void:
	deck = d
	player_id = pid


func resolve(fight_manager: FightManager) -> void:
	var data := fight_manager.get_data(player_id)
	if player_id == Global.uuid:
		if deck == Deck.MAIN:
			fight_manager.hand_manager.draw_card(fight_manager.main_deck.pop_front() as Dictionary)
		else:
			fight_manager.hand_manager.draw_card(fight_manager.side_deck.pop_front() as Dictionary)
	data.hand_size += 1
	fight_manager._no_activation()


func as_dict() -> Dictionary:
	return {type = action_type(), deck = deck, player_id = player_id}


static func from_dict(dict: Dictionary) -> Action:
	return DrawCardAction.new(dict.deck as Deck, dict.player_id as String)
