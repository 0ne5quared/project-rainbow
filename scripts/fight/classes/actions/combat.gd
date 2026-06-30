class_name CombatAction
extends Action


static func action_type() -> Type:
	return Type.COMBAT


func resolve(fight_manager: FightManager) -> void:
	fight_manager._activate_sigils(func(s: Sigil) -> void: s.on_combat_start())
	for slot in fight_manager.board_manager.get_active_row(fight_manager.is_active):
		if slot.card != null:
			fight_manager._push_action(CardAttackAction.new(slot.card.id))


func as_dict() -> Dictionary:
	return {type = action_type()}


static func from_dict(_dict: Dictionary) -> Action:
	return CombatAction.new()
