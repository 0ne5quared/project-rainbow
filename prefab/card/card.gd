class_name Card
extends Control

enum Zone { HAND, BOARD, GRAVEYARD, EXILE, LIMBO }

const _DATA_SCHEMA: Dictionary[StringName, Dictionary] = {
	&"name": {types = [TYPE_STRING], default = "MISSING"},
	&"attack": {types = [TYPE_INT, TYPE_STRING], default = 0},
	&"health": {types = [TYPE_INT], default = 1},
	&"sigils": {types = [TYPE_ARRAY], sub_type = TYPE_STRING, default = []},
	&"traits": {types = [TYPE_ARRAY], sub_type = TYPE_STRING, default = []},
	&"temples": {types = [TYPE_STRING], default = "Beast"},
	&"costs": {types = [TYPE_DICTIONARY], sub_type = TYPE_STRING, default = {}},
	&"tokens": {types = [TYPE_ARRAY], sub_type = TYPE_STRING, default = []}
}

var card_data: Dictionary:
	set(new_data):
		parse_data(new_data)
		card_data = new_data
		redraw_card()
	get:
		return card_data

var zone := Zone.LIMBO
var is_friendly := true
var id := Global.gen_id()

var attack_mod: int
var sigil_mod: int

# these are just extracted out of the card_data for type safety
## The attack of the card, if you want to temporarily buff the card use [member attack_mod]
var attack: int
## The health of the card
var health: int
## The sigils on the card, if you want to temporarily add sigil to the card use [member sigils]
var sigils: Array[Sigil]
## Trait of the card, these don't have any gameplay effect but instead they are checked by
## sigils and or cost.
var traits: Array[String]
var temples: String
var costs: Dictionary[String, Variant]
var tokens: Array[String]


## Parse and assign infomation in [param data]
func parse_data(data: Dictionary) -> Dictionary:
	Global.validate_schema(data, _DATA_SCHEMA)
	for prop in _DATA_SCHEMA:
		if prop == &"sigils":
			for sigil: String in data[prop]:
				print('attempting to load "%s" sigil' % sigil)
				if FileAccess.file_exists("res://scripts/fight/sigils/%s.gd" % sigil):
					print("File found, loading...")
					var s: Sigil = load("res://scripts/fight/sigils/%s.gd" % sigil).new()
					s.card = self
					sigils.append(s)
					continue
				push_warning('Sigil "%s" script not found, skip loading' % sigil)
			continue
		set(prop, data[prop])
	return data


func redraw_card() -> void:
	%Name.text = name

	var portrait_path := "res://asset/portraits/%s.png" % card_data.name
	if FileAccess.file_exists(portrait_path):
		%Portrait.texture = load(portrait_path)
	else:
		push_warning(
			'Portrait can\'t be found for "%s" so using missing texture instead', card_data.name
		)
		%Portrait.texture = load("res://asset/portraits/MISSING.png")
	%Attack.text = str(attack)
	%Health.text = str(health)
