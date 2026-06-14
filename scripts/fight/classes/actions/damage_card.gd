class_name DamageCard
extends Action


static func action_type() -> Type:
	return Type.CARD_DAMAGE


func resolve(fight_manager: FightManager) -> void:
	pass


func as_dict() -> Dictionary:
	pass


static func from_dict(dict: Dictionary) -> DamageCard:
	return
