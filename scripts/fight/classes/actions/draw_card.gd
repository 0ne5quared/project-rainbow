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
			if len(fight_manager.deck.main) <= 0:
				push_warning("Can't draw card from an empty deck :(")
				return
				# TODO: trigger starvation
			fight_manager.hand_manager.draw_card(
				fight_manager.deck.main.pop_front() as Ruleset.CardData
			)
		else:
			if len(fight_manager.deck.side) <= 0:
				push_warning("Can't draw card from an empty deck :(")
				return

				# TODO: trigger starvation
			fight_manager.hand_manager.draw_card(
				fight_manager.deck.side.pop_front() as Ruleset.CardData
			)
	# TODO: only change this when deck can be drawn fr
	data.hand_size += 1
	fight_manager._no_activation()


func as_dict() -> Dictionary:
	return {type = action_type(), deck = deck, player_id = player_id}


static func from_dict(dict: Dictionary) -> Action:
	return DrawCardAction.new(dict.deck as Deck, dict.player_id as String)
