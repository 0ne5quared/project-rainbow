class_name PlayCardAction
extends Action

enum PlacerType { CARD, PLAYER }

var card_id: String
var pos: Vector2i
var placer_type: PlacerType
var placer_id: String


static func action_type() -> Type:
	return Action.Type.PLAY_CARD


func _init(c: String, p: Vector2i, pt: PlacerType, pi: String) -> void:
	card_id = c
	pos = p
	placer_type = pt
	placer_id = pi


func resolve(fight_manager: FightManager) -> void:
	if not fight_manager.board_manager.is_slot_empty(pos):
		print("Someone is trying to play into a slot with a card already. This might be a bug.")
		return

	fight_manager.card_manager.move_card(card_id, Card.Zone.BOARD)
	var slot := fight_manager.board_manager.get_slot(pos)
	var card := fight_manager.card_manager.get_card_by_id(card_id)
	slot.card = card
	fight_manager._activate_sigils(
		func(sigils: Sigil) -> void: sigils.on_played(card, pos, placer_type, placer_id)
	)


func as_dict() -> Dictionary:
	return {
		type = action_type(),
		card_id = card_id,
		pos = {x = pos.x, y = pos.y},
		placer_type = placer_type,
		placer_id = placer_id
	}


static func from_dict(dict: Dictionary) -> PlayCardAction:
	return PlayCardAction.new(
		dict.card_id as String,
		Vector2i(dict.pos.x as int, dict.pos.y as int),
		dict.placer_type as PlacerType,
		dict.placer_id as String
	)
