class_name DamageCard
extends Action

var amount: int
var victim_id: String
var attacker_type: IDType
var attacker_id: String


static func action_type() -> Type:
	return Type.CARD_DAMAGE


func _init(a: int, vid: String, at: IDType, aid: String) -> void:
	amount = a
	victim_id = vid
	attacker_type = at
	attacker_id = aid


func resolve(fight_manager: FightManager) -> void:
	var victim := fight_manager.card_manager.get_card_by_id(victim_id)
	victim.health -= amount
	fight_manager._activate_sigils(
		func(sigil: Sigil) -> void:
			sigil.on_card_damaged(victim, amount, attacker_type, attacker_id)
	)


func as_dict() -> Dictionary:
	return {
		type = action_type(),
		amount = amount,
		victim_id = victim_id,
		attacker_type = attacker_type,
		attacker_id = attacker_id
	}


static func from_dict(dict: Dictionary) -> DamageCard:
	return DamageCard.new(
		dict.amount as int,
		dict.victim_id as String,
		dict.attack_type as IDType,
		dict.attacker_id as String
	)
