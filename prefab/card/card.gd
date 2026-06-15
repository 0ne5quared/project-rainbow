class_name Card
extends Button

enum Zone { HAND, BOARD, GRAVEYARD, EXILE, LIMBO }
const PUBLIC_ZONE = [Zone.BOARD, Zone.GRAVEYARD, Zone.EXILE]

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

var zone := Zone.LIMBO:
	set(new):
		zone = new
		visible = zone != Zone.LIMBO
var is_friendly := true
var id := Global.gen_id()

var attack_mod: int
var sigil_mod: int

# These are just extracted out of the card_data for type safety
## The attack of the card, if you want to temporarily buff the card use [member attack_mod]
var attack: int:
	set(new):
		attack = new
		redraw_card()
## The health of the card
var health: int:
	set(new):
		health = new
		redraw_card()
## The sigils on the card, if you want to temporarily add sigil to the card use [member sigils]
var sigils: Dictionary[String, Sigil]:
	set(new):
		sigils = new
		redraw_card()
## Trait of the card, these don't have any gameplay effect but instead they are checked by
## sigils and or cost.
var traits: Array[String]
var temples: String
var costs: Dictionary[String, Variant]
var tokens: Array[String]
var card_name: String

var parsing_data := false


## Parse and assign infomation in [param data]
func parse_data(data: Dictionary) -> Dictionary:
	parsing_data = true
	Global.validate_schema(data, _DATA_SCHEMA)
	for prop in _DATA_SCHEMA:
		if prop == &"sigils":
			for sigil: String in data[prop]:
				if FileAccess.file_exists("res://scripts/fight/sigils/%s.gd" % sigil):
					var s: Sigil = load("res://scripts/fight/sigils/%s.gd" % sigil).new()
					s.attached_card = self
					sigils[sigil] = (s)
					continue
				push_warning('Sigil "%s" script not found, skip loading' % sigil)
			continue
		set(prop, data[prop])
	card_name = data.name
	parsing_data = false
	return data


func redraw_card() -> void:
	# don't redraw while parsing card so that we don;t spam the log
	if parsing_data:
		return
	%Name.text = card_name

	var portrait_path := "res://asset/portraits/%s.png" % card_name
	if FileAccess.file_exists(portrait_path):
		%Portrait.texture = load(portrait_path)
	else:
		push_warning(
			'Portrait can\'t be found for "%s" so using missing texture instead' % card_name
		)
		%Portrait.texture = load("res://asset/portraits/MISSING.png")
	for n in %SigilsContainer.get_children():
		%SigilsContainer.remove_child(n)
		n.queue_free()
	for sigil in sigils:
		var sigil_path := "res://asset/sigils/%s.png" % sigil
		if not FileAccess.file_exists(sigil_path):
			push_warning(
				'Sigil icon can\'t be found for "%s" so using missing texture instead' % sigil
			)
			sigil_path = "res://asset/sigils/MISSING.png"
		var text_rect := TextureRect.new()
		text_rect.texture = load(sigil_path)
		%SigilsContainer.add_child(text_rect)
	%Attack.text = str(attack)
	%Health.text = str(health)


func as_dict() -> Dictionary:
	return {data = card_data, id = id, zone = zone}
