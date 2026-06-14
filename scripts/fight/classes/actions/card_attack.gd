class_name CardAttackAction
extends Action

var attacker_id: String


static func action_type() -> Type:
	return Type.CARD_ATTACK


func _init(aid: String) -> void:
	attacker_id = aid


## A strike group for the card attacking. A strike group is a strike on a slot along with
## some extra stack modification. Card always have to strike from left to right and this strike
## group allow for strike and any other additional action that a single strike might cause to be move
## arround correctly in the event that multiple [method on_attack] affect the same card.
class StrikeGroup:
	var pos: Vector2i
	var actions: Array[Action]

	func _init(p: Vector2i) -> void:
		pos = p
		actions = []

	func add_action(action: Action) -> StrikeGroup:
		actions.push_front(action)
		return self

	func add_actions(actions: Array[Action]) -> StrikeGroup:
		actions.append_array(actions)
		return self

	func add_strike(striker_id: String, to_face := false) -> StrikeGroup:
		return add_action(CardStrikeAction.new(pos, striker_id, to_face))

	func as_dict() -> Dictionary:
		return {
			pos = {x = pos.x, y = pos.y},
			actions = actions.map(func(a: Action) -> Dictionary: return a.as_dict())
		}

	static func from_dict(dict: Dictionary) -> StrikeGroup:
		var actions: Array[Action]
		actions.assign(
			(dict.actions as Array).map(func(a: Dictionary) -> Action: return Action.from_dict(a))
		)
		return StrikeGroup.new(Vector2i(dict.pos.x as int, dict.pos.y as int)).add_actions(actions)


func resolve(fight_manager: FightManager) -> void:
	var strike_groups: Array[StrikeGroup] = []
	for card in fight_manager._public_activation_order():
		for sigil: Sigil in card.sigils.values():
			strike_groups.append_array(sigil.on_attack(card))
	# TODO: Actually never implemented this for private trigger.
	strike_groups.sort_custom(
		func(a: StrikeGroup, b: StrikeGroup) -> bool: return a.pos.x < b.pos.x
	)
	if strike_groups.is_empty():
		strike_groups.append(
			(
				StrikeGroup
				. new(
					BoardManager.oppose_pos(fight_manager.board_manager.get_card_pos(attacker_id))
				)
				. add_strike(attacker_id)
			)
		)
	for group in strike_groups:
		fight_manager._stack.append_array(group.actions)
	fight_manager._no_activation()


func as_dict() -> Dictionary:
	return {type = action_type(), attacker_id = attacker_id}


static func from_dict(dict: Dictionary) -> Action:
	return CardAttackAction.new(dict.attacker_id as String)
