class_name NullAction
extends Action


static func action_type() -> Type:
	return Type.NULL


func resolve(fight_manager: FightManager) -> void:
	fight_manager._no_activation()


func as_dict() -> Dictionary:
	return {type = action_type()}


static func from_dict(_dict: Dictionary) -> Action:
	return NullAction.new()
