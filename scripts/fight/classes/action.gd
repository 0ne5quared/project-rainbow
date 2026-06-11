@abstract class_name Action
extends Object

# IMPORTANT:
# When adding a new action, you should also implement these 3 things
# - A stack action constructor, like `PLAY_CARD` have `new_play_card_action`
# - A stack action resolver, like `PLAY_CARD` have `_resolve_play_card`.
# - A sigil event hook, like `PLAY_CARD` have `on_played` (This can be found in the sigil
# class), also call said event hook.
# Should also document what the spec of the action look like/how to use them.

enum Type {
	## Action representing playing a card.[br]
	## The spec for this action include:[br]
	## - [code]card_id[/code]: [String]: The card id being placed, use something like
	## [enum CREATE_TOKEN] if this card did not exist before.[br]
	## - [code]pos[/code]: [Vector2i]: The position to play the card in[br],
	## - [code]placer_type[/code]: [enum Action.PlacerType],
	## - [code]placer_id[/code]
	PLAY_CARD,
	## Action representing creating a new token, this token will just float around in limbo.
	## You need another action to do something with this token.[br]
	## The spec for this action include:[br]
	## - [code]card_data[/code]: [Dictionary]: The data to create this token.[br]
	## - [code]token_id[/code]: [String]: The id of the new token, this id need to be deterministic
	## on both client.[br]
	## - [code]source_id[/code]: [String]: The source id that created this token. Usually is a card.
	CREATE_TOKEN,
	## Action representing ending the turn. This action have no additonal information.
	END_TURN,
	## Action representing the start of combat. This action have no additional information.
	COMBAT,
	## Action representing the start of a card attack. This will simply resolve into CARD_STRIKE that
	## actually take care of the damage and whatnot. Implementing [method Sigil.on_attack] will
	## override the default of adding a center strike for this action
	CARD_ATTACK,
	## Action representing the card striking. This is the actual damage dealing action.
	CARD_STRIKE,
	## Action representing a card taking damage.
	CARD_DAMAGE
}

## A unique id for this stack action.
##
## If a previous stack action is on the stack this is use to seed the randomizer
var id := Global.gen_id()

@abstract func resolve(fight_manager: FightManager) -> void
@abstract func as_dict() -> Dictionary

static var _action_registry: Dictionary = {}


static func from_dict(dict: Dictionary) -> Action:
	if _action_registry.is_empty():
		var path := "res://scripts/fight/classes/actions"
		var dir := DirAccess.open(path)
		for file in dir.get_files():
			if not file.ends_with(".gd"):
				continue
			@warning_ignore("confusable_local_declaration")
			var script := load("%s/%s" % [path, file])
			_action_registry[script.action_type()] = script

	if "type" not in dict:
		dict.type = -1
	dict.type = dict.type as int

	var script: Script = _action_registry.get(dict.type)
	return script.from_dict(dict)
