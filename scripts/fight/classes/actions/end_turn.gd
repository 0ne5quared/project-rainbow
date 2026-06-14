class_name EndTurnAction
extends Action


static func action_type() -> Type:
	return Type.END_TURN


func resolve(fight_manager: FightManager) -> void:
	fight_manager._push_action(CombatAction.new())
	fight_manager._activate_sigils(func(s: Sigil) -> void: s.on_turn_end())


func as_dict() -> Dictionary:
	return {type = action_type()}


static func from_dict(_dict: Dictionary) -> EndTurnAction:
	return EndTurnAction.new()
