class_name TipScaleAction
extends Action

## The amount to tip the scale by. Positive mean to me and negative to them
var amount: int


static func action_type() -> Type:
	return Type.TIP_SCALE


func _init(a: int) -> void:
	amount = a


func resolve(fight_manager: FightManager) -> void:
	fight_manager.scale_position += amount
	fight_manager._no_activation()


func as_dict() -> Dictionary:
	return {type = action_type(), amount = amount}


static func from_dict(dict: Dictionary) -> TipScaleAction:
	return TipScaleAction.new(dict.amount as int)
