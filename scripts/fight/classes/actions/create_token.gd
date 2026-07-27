class_name CreateTokenAction
extends Action

var card_data: Ruleset.CardData
var token_id: String
var source_id: String


static func action_type() -> Type:
	return Type.CREATE_TOKEN


func _init(cd: Ruleset.CardData, ti: String, si: String) -> void:
	card_data = cd
	token_id = ti
	source_id = si


func resolve(fight_manager: FightManager) -> void:
	fight_manager.card_manager.add_card(card_data, Card.Zone.LIMBO, token_id)
	fight_manager._no_activation()


func as_dict() -> Dictionary:
	return {card_data = card_data, token_id = token_id, source_id = source_id}


static func from_dict(dict: Dictionary) -> Action:
	return CreateTokenAction.new(
		Ruleset.CardData.new(dict.card_data as Dictionary),
		dict.token_id as String,
		dict.source_id as String
	)
