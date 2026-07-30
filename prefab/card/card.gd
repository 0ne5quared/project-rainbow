class_name Card
extends Button

enum Zone {
	HAND,
	OPP_HAND,
	BOARD,
	GRAVEYARD,
	EXILE,
	LIMBO,
}
const PUBLIC_ZONE = [Zone.BOARD, Zone.GRAVEYARD, Zone.EXILE]


class Costs:
	class Mox:
		var green := 0
		var orange := 0
		var blue := 0

		func add(mox: Mox) -> void:
			green += mox.green
			orange += mox.orange
			blue += mox.blue

		func as_dict() -> Dictionary[String, int]:
			return {green = green, orange = orange, blue = blue}

		func is_empty() -> bool:
			return green == 0 and orange == 0 and blue == 0

		static func g(amount := 1) -> Mox:
			var m := Mox.new()
			m.green = amount
			return m

		static func o(amount := 1) -> Mox:
			var m := Mox.new()
			m.orange = amount
			return m

		static func b(amount := 1) -> Mox:
			var m := Mox.new()
			m.blue = amount
			return m

	var bone: int = 0
	var blood: int = 0
	var energy: int = 0
	var cell: int = 0
	var mox: Mox = Mox.new()

	func as_dict() -> Dictionary:
		return Global.as_dict_generator(
			self,
			func(prop: String, value: Variant) -> Dictionary:
				if prop == "mox":
					return (value as Variant).as_dict()
				return {}
		)


var card_data: Ruleset.CardData:
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
		%CostContainer.visible = zone != Zone.BOARD
		redraw_card()
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
## The list of sigils name on the card. If you want to get the list of actual [Sigil] objects, use
## [member _sigils]
var sigils: Array[String]:
	set(new):
		sigils = new
		redraw_card()
## The list of actual [Sigil] object on the card. If you want to get the list of names use
## [member sigils]
var _sigils: Array[Sigil]
## Trait of the card, these don't have any gameplay effect but instead they are checked by
## sigils and or cost.
var traits: Array[String]
var temples: String:
	set(new):
		temples = new
		redraw_card()
var tribes: String:
	set(new):
		temples = new
		redraw_card()
var costs: Costs:
	set(new):
		costs = new
		redraw_card()
var tokens: Array[String]
var card_name: String:
	set(new):
		card_name = new
		redraw_card()

var parsing_data := false

@onready var sac_marker: TextureRect = %SacMarker
@onready var submerge_overlay: TextureRect = %SubmergeOverlay


func blood_value() -> int:
	var t := 0
	for sigil: Sigil in _sigils:
		t += sigil.blood_value()
	return t if t != 0 else 1


func mox_value() -> Costs.Mox:
	var m := Costs.Mox.new()
	for sigil: Sigil in _sigils:
		m.add(sigil.mox_value())
	return m


## Parse and assign infomation in [param data]
func parse_data(data: Ruleset.CardData, show_warning := false) -> void:
	@warning_ignore("confusable_local_usage", "shadowed_global_identifier")
	var push_warning := push_warning if show_warning else func(_x: String) -> void: pass
	parsing_data = true
	sigils.clear()
	_sigils.clear()
	for prop: String in (
		data
		. get_property_list()
		. filter(func(d: Dictionary) -> bool: return d.usage & PROPERTY_USAGE_SCRIPT_VARIABLE > 0)
		. map(func(d: Dictionary) -> String: return d.name)
	):
		if prop == "sigils":
			for sigil: String in data[prop]:
				# Figuring out where the script is
				var script_path := "res://scripts/fight/sigils/%s.gd" % sigil
				if not FileAccess.file_exists(script_path):
					push_warning.call(
						(
							'Sigil script can\'t be found for "%s" so using missing script instead'
							% sigil
						)
					)
					script_path = "res://scripts/fight/sigils/MISSING.gd"
				var s: Sigil = load(script_path).new()
				s.attached_card = self

				# Now the texture
				var sigil_path := "res://asset/sigils/%s.png" % sigil
				if not FileAccess.file_exists(sigil_path):
					push_warning(
						(
							'Sigil icon can\'t be found for "%s" so using missing texture instead'
							% sigil
						)
					)
					sigil_path = "res://asset/sigils/MISSING.png"
				s.texture = load(sigil_path)
				sigils.append(sigil)
				_sigils.append(s)
			continue
		if prop == "costs":
			var c := Costs.new()
			c.bone = data.costs.bone
			c.blood = data.costs.blood
			c.energy = data.costs.energy
			c.cell = data.costs.cell

			costs = c
			continue
		set(prop, data[prop])
	card_name = data.name
	parsing_data = false


func redraw_card() -> void:
	# don't redraw while parsing card so that we don;t spam the log
	if parsing_data:
		return
	$SacMarker.visible = false
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
	for sigil in _sigils:
		%SigilsContainer.add_child(sigil)
	%Attack.text = str(attack)
	%Health.text = str(health)
	for n in %CostContainer.get_children():
		%CostContainer.remove_child(n)
		n.queue_free()
	if costs.bone != 0:
		%CostContainer.add_child(num_cost_icon("res://asset/cost/bone_cost.png", costs.bone as int))
	if costs.blood != 0:
		%CostContainer.add_child(
			num_cost_icon("res://asset/cost/blood_cost.png", costs.blood as int)
		)
	if costs.energy != 0:
		%CostContainer.add_child(
			num_cost_icon("res://asset/cost/energy_cost.png", costs.energy as int)
		)
	if costs.cell != 0:
		%CostContainer.add_child(num_cost_icon("res://asset/cost/cell_cost.png", costs.cell as int))

	if not costs.mox.is_empty():
		%CostContainer.add_child(mox_cost_icon())


func num_cost_icon(cost_icon: String, amount: int) -> HBoxContainer:
	var cost := HBoxContainer.new()
	cost.add_theme_constant_override("separation", -1)
	@warning_ignore("shadowed_variable_base_class")
	var icon := TextureRect.new()
	icon.texture = load(cost_icon)
	cost.add_child(icon)
	for d: String in str(amount):
		var digit := TextureRect.new()
		digit.texture = load("res://asset/cost/number/%s.png" % d)
		digit.stretch_mode = TextureRect.STRETCH_KEEP
		digit.size_flags_vertical = Control.SIZE_SHRINK_END
		cost.add_child(digit)
	return cost


func mox_cost_icon() -> HBoxContainer:
	var cost := HBoxContainer.new()
	cost.add_theme_constant_override("separation", -5)
	for i in range(costs.mox.green):
		var t := TextureRect.new()
		t.texture = load("res://asset/cost/mox/green.png")
		cost.add_child(t)
	for i in range(costs.mox.orange):
		var t := TextureRect.new()
		t.texture = load("res://asset/cost/mox/orange.png")
		cost.add_child(t)
	for i in range(costs.mox.blue):
		var t := TextureRect.new()
		t.texture = load("res://asset/cost/mox/blue.png")
		cost.add_child(t)
	for c in cost.get_children().size():
		cost.get_child(c).z_index = cost.get_child_count() - c
	return cost


func as_dict() -> Dictionary:
	return {data = card_data.as_dict(), id = id, zone = zone}
