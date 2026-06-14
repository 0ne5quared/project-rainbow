class_name CardStrikeAction
extends Action

var pos: Vector2i
var striker_id: String
## Wherever this will strike directly to face disregarding everything
var to_face: bool


static func action_type() -> Type:
	return Type.CARD_STRIKE


func _init(p: Vector2i, sid: String, tf := false) -> void:
	pos = p
	striker_id = sid
	to_face = tf


func resolve(fight_manager: FightManager) -> void:
	var card := fight_manager.card_manager.get_card_by_id(striker_id)
	var slot := fight_manager.board_manager.get_slot(pos)
	print(card.attack)
	if slot.is_empty() or to_face:
		fight_manager._push_action(
			TipScaleAction.new(card.attack * (-1 if slot.pos.y == BoardManager.Row.MINE else 1))
		)
	else:
		slot.card.health -= card.attack
	fight_manager._no_activation()


func as_dict() -> Dictionary:
	return {
		type = action_type(),
		pos = {x = pos.x, y = pos.y},
		striker_id = striker_id,
		to_face = to_face
	}


static func from_dict(dict: Dictionary) -> CardStrikeAction:
	return CardStrikeAction.new(
		Vector2i(dict.pos.x as int, dict.pos.y as int),
		dict.striker_id as String,
		dict.to_face as int
	)
