class_name PreCardStrikeAction
extends Action

var pos: Vector2i
var striker_id: String
## Wherever this will strike directly to face disregarding everything
var to_face: bool


static func action_type() -> Type:
	return Type.PRE_CARD_STRIKE


func _init(p: Vector2i, sid: String, tf := false) -> void:
	pos = p
	striker_id = sid
	to_face = tf


func resolve(fight_manager: FightManager) -> void:
	var striker := fight_manager.card_manager.get_card_by_id(striker_id)
	var victim_slot := fight_manager.board_manager.get_slot(pos)
	if victim_slot == null:
		push_warning("Nuh uh no striking into non-existence slot >:(")
		fight_manager._no_activation()
		return
	if striker.attack == 0:
		fight_manager._no_activation()
		return
	fight_manager._push_action(CardStrikeAction.new(pos, striker_id, to_face))
	await fight_manager._activate_sigils(
		func(sigil: Sigil) -> void: return sigil.pre_card_strike(striker, victim_slot, to_face)
	)


func as_dict() -> Dictionary:
	return {
		type = action_type(),
		pos = {x = pos.x, y = pos.y},
		striker_id = striker_id,
		to_face = to_face
	}


static func from_dict(dict: Dictionary) -> Action:
	return CardStrikeAction.new(
		Vector2i(dict.pos.x as int, dict.pos.y as int),
		dict.striker_id as String,
		dict.to_face as int
	)
