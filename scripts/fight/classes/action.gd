class_name Action
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
	## Action representing the card attacking. This will simply resolve into CARD_ST RIKE that
	## actually take care of the damage and whatnot.
	CARD_ATTACK,
	CARD_STRIKE,
	CARD_DAMAGE
}

enum PlacerType { CARD, PLAYER }

var type: int
var data: Dictionary
## A unique id for this stack action.
##
## If a previous stack action is on the stack this is use to seed the randomizer
var id := Global.gen_id()


func _init(t: int, d: Dictionary) -> void:
	type = t
	data = d


static func new_play_card(
	card_id: String, pos: Vector2i, placer_type: PlacerType, placer_id: String
) -> Action:
	return Action.new(
		Type.PLAY_CARD,
		{card_id = card_id, pos = pos, placer_type = placer_type, placer_id = placer_id}
	)


static func new_create_token(card_data: Dictionary, token_id: String, source_id: String) -> Action:
	return Action.new(
		Type.CREATE_TOKEN, {card_data = card_data, token_id = token_id, source_id = source_id}
	)


func as_dict() -> Dictionary:
	# TODO: this does not handle nested custom type just yet
	var s_dict := {}
	for prop: String in data:
		match typeof(data[prop]):
			TYPE_VECTOR2I:
				var v := data[prop] as Vector2i
				s_dict[prop] = {c_type = "Vector2i", x = v.x, y = v.y}
			_:
				s_dict[prop] = data[prop]
	return {a_type = type, data = s_dict}


static func from_dict(dict: Dictionary) -> Action:
	var t := dict.a_type as int
	var d := dict.data as Dictionary
	for k: String in d:
		var v: Variant = d[k]
		if typeof(v) == TYPE_DICTIONARY:
			if "c_type" in v:
				if v.c_type == "Vector2i":
					d[k] = Vector2i(v.x as int, v.y as int)
	return Action.new(t, d)
