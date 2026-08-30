class_name ChangeStatsAction
extends Action

# This class also serves as an example with documentation if you want to implement a new action

# You should provide a description for the action, better if you also include the field that it have
# and what they mean/do.
## This action represents a card gaining permanent stats
## [card_id] the id of the card gaining permanent stats
## [add_power] the amount of permanent attack the card is gaining
## [add_health] there are two types of people in the world; those that can extrapolate from incomplete data...

# Define here any data your action might hold
var card_id: String
var add_power: int
var add_health: int


# This is the unique action type that you define in Action.Type
static func action_type() -> Type:
	return Type.CHANGE_STATS


# A constructor for this action so we can make them
func _init(cid: String, p: int, h: int) -> void:
	card_id = cid
	add_power = p;
	add_health = h;


# Resolver for this sigil action, the fight manager is the copy of the current fight manager
func resolve(fight_manager: FightManager) -> void:
	var card := fight_manager.card_manager.get_card_by_id(card_id)
	card.attack_buf += add_power
	card.health += add_health

	# Always call some sort of sigil activation function event if there are no sigil hook.
	# in that case you can use fight_manager._no_activation() as the activation. If you don't
	# include this your stack will stall indefinitely.
	await fight_manager._activate_sigils(
		func(sigil: Sigil) -> void: sigil.on_card_changed_stats(card, add_power, add_health)
	)
	if card.health <= 0:
		fight_manager._push_action(KillCardAction.new(card_id))


# Because playing a card can be trigger manually by the player, implement al the serialization
# method


func as_dict() -> Dictionary:
	return {
		type = action_type(),
		card_id = card_id,
		add_power = add_power,
		add_health = add_health
	}


func duplicate() -> Action:
	return ChangeStatsAction.new(card_id, add_power, add_health)


static func from_dict(dict: Dictionary) -> Action:
	return ChangeStatsAction.new(
		dict.card_id as String,
		dict.add_power as int,
		dict.add_health as int
	)
