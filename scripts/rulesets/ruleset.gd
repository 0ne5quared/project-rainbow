class_name Ruleset
extends Object


## Settings for candle/lives.
class CandlesSettings:
	## The amount of candles each player start with.
	var amount: int
	## The name of the card that snuffing candle will produce. If not provided the candle cannot be
	## snuff.
	var smoke: String

	func _init(candles_config: Dictionary) -> void:
		amount = candles_config.amount
		smoke = candles_config.smoke


## General settings for the ruleset.
class RulesetSettings:
	## Minimum deck size
	var deck_size_min: int
	## Wherever to enable the backrow, this currently does not work.
	var enable_backrow: bool
	## Candles settings, refer to [CandlesSettings].
	var candles_settings: CandlesSettings

	func _init(settings_config: Dictionary) -> void:
		deck_size_min = settings_config.deck_size_min
		enable_backrow = settings_config.enable_backrow
		candles_settings = CandlesSettings.new(settings_config.candles as Dictionary)


## Rarity config/data.
class Rarity:
	## The name of the rarity
	var name: String
	## The max allowed copy of this card belonging to this rarity in the main deck
	var max_main: int
	## The max allowed copy of this card belonging to this rarity in the side deck
	var max_side: int
	## The icon to use for this rarity
	var icon: Texture2D
	## The display name override for this rarity. If not provided the display name will be
	## [member name] capitalized.
	var name_override: String

	static var COMMON_RARITY: Rarity = _basic_config("common", 4, 10)
	static var RARE_RARITY: Rarity = _basic_config("rare", 1, 1)

	func _init(rarity_name: String, rarity_config: Dictionary) -> void:
		name = rarity_name
		max_main = rarity_config.max.main
		max_side = rarity_config.max.side

		var icon_path := "res://asset".path_join(rarity_config.icon as String)
		if icon_path.is_empty():
			icon_path = "res://asset/rarities/%s.png" % rarity_name
		if not FileAccess.file_exists(icon_path):
			icon_path = "res://asset/rarities/MISSING.png"
		icon = load(icon_path)

		name_override = rarity_config.name
		if name_override.is_empty():
			name_override = name.capitalize()

	static func _basic_config(rarity_name: String, main: int, side: int) -> Rarity:
		return Rarity.new(rarity_name, {name = "", icon = "", max = {main = main, side = side}})


class Temple:
	var name: String
	var icon: Texture2D
	var frame: Dictionary[String, Texture2D]
	var name_override: String

	static var BEAST := _basic_config("beast")
	static var UNDEAD := _basic_config("undead")
	static var TECHNOLOGY := _basic_config("technology")
	static var MAGICK := _basic_config("magick")

	func _init(temple_name: String, temple_config: Dictionary) -> void:
		name = temple_name
		var icon_path := "res://asset".path_join(temple_config.icon as String)
		if temple_config.icon.is_empty():
			icon_path = "res://asset/temples/%s.png" % temple_name
		if not FileAccess.file_exists(icon_path):
			icon_path = "res://asset/temples/MISSING.png"
		icon = load(icon_path)
		for rarity: String in (temple_config.frame as Dictionary).keys():
			frame[rarity] = load("res://asset".path_join(temple_config.frame[rarity] as String))

	static func _basic_config(temple_name: String) -> Temple:
		return Temple.new(
			temple_name,
			{
				name = "",
				icon = "",
				frame = {rare = "frame/rare/%s.png" % temple_name, common = "frame/common.png"}
			}
		)


class Tribe:
	var name: String
	var icon: Texture2D
	var name_override: String

	static var REPTILE := _basic_config("reptile")
	static var INSECT := _basic_config("insect")
	static var AVIAN := _basic_config("avian")
	static var CANINE := _basic_config("canine")
	static var HOOVED := _basic_config("hooved")
	static var CRUSTACEAN := _basic_config("crustacean")
	static var GEMS := _basic_config("gems")

	func _init(tribe_name: String, tribe_config: Dictionary) -> void:
		name = tribe_name
		var icon_path := "res://asset".path_join(tribe_config.icon as String)
		if icon_path == null or icon_path.is_empty():
			icon_path = "res://asset/tribes/%s.png" % tribe_name
		if not FileAccess.file_exists(icon_path):
			icon_path = "res://asset/tribes/MISSING.png"
		icon = load(icon_path)

		name_override = tribe_config.name
		if name_override == null or name_override.is_empty():
			name_override = name.capitalize()

	static func _basic_config(tribe_name: String) -> Tribe:
		return Tribe.new(tribe_name, {name = "", icon = ""})


## Metadata for cards. This is a general class uses for tribes, traits.
class Trait:
	## Name of the trait.
	var name: String
	## The icon to use for this trait.
	var icon: Texture2D
	## The display name override for this trait. If not provided the display name will be
	## [member name] capitalized.
	var name_override: String
	## Wherever this trait should be hidden
	var is_hidden: bool

	static var UNHAMMERABLE := _basic_config("unhammerable")
	static var BLOODLESS := _basic_config("bloodless")
	static var BONELESS := _basic_config("boneless")

	func _init(trait_name: String, trait_config: Dictionary) -> void:
		name = trait_name
		var icon_path := "res://asset".path_join(trait_config.icon as String)
		if icon_path.is_empty():
			icon_path = "res://asset/traits/%s.png" % trait_config
		if not FileAccess.file_exists(icon_path):
			icon_path = "res://asset/traits/MISSING.png"
		icon = load(icon_path)

		is_hidden = trait_config.hidden

		name_override = trait_config.name
		if name_override == null or name_override.is_empty():
			name_override = name.capitalize()

	static func _basic_config(trait_name: String) -> Trait:
		return Trait.new(trait_name, {name = "", icon = "", hidden = false})


class CardData:
	const SCHEMA: Dictionary[String, Dictionary] = {
		name = {types = [TYPE_STRING], default = "MISSING"},
		attack = {types = [TYPE_INT], default = 0},
		special_attack = {types = [TYPE_STRING], default = ""},
		health = {types = [TYPE_INT], default = 1},
		sigils = {types = [TYPE_ARRAY], sub_type = TYPE_STRING, default = []},
		rarity = {types = [TYPE_STRING], default = "common"},
		traits = {types = [TYPE_ARRAY], sub_type = TYPE_STRING, default = []},
		temple = {types = [TYPE_STRING], default = "beast"},
		tribes = {types = [TYPE_ARRAY], sub_type = TYPE_STRING, default = []},
		costs =
		{
			types = [TYPE_DICTIONARY],
			schema =
			{
				blood = {types = [TYPE_INT], default = 0},
				bone = {types = [TYPE_INT], default = 0},
				energy = {types = [TYPE_INT], default = 0},
				cell = {types = [TYPE_INT], default = 0},
				mox =
				{
					types = [TYPE_ARRAY, TYPE_DICTIONARY],
					sub_type = TYPE_STRING,
					schema =
					{
						orange = {types = [TYPE_INT], default = 0},
						blue = {types = [TYPE_INT], default = 0},
						green = {types = [TYPE_INT], default = 0},
					},
					default = []
				}
			},
		},
		tokens = {types = [TYPE_ARRAY], sub_type = TYPE_STRING, default = []},
		# TYPE_MAX is used for variant type
		metadata = {types = [TYPE_DICTIONARY], key_type = TYPE_STRING, value_TYPE = TYPE_MAX}
	}
	var name: String
	var attack: int
	var special_attack: String
	var health: Variant
	var sigils: Array[String]
	var rarity: String
	var traits: Array[String]
	var temple: String
	var tribes: Array[String]
	var costs: Card.Costs
	var tokens: Array[String]
	var metadata: Dictionary

	func as_dict() -> Dictionary:
		return Global.as_dict_generator(
			self,
			func(prop: String, value: Variant) -> Dictionary:
				if prop == "costs":
					return (value as Card.Costs).as_dict()
				return {}
		)

	func _init(dict: Dictionary) -> void:
		Global.validate_schema(dict, SCHEMA)
		for prop in SCHEMA:
			if prop == "costs":
				costs = Card.Costs.new()
				costs.blood = dict.costs.blood
				costs.bone = dict.costs.bone
				costs.energy = dict.costs.energy
				if typeof(dict.costs.mox) == TYPE_ARRAY:
					var mox_array: Array[String]
					mox_array.assign(dict.costs.mox as Array)
					costs.mox.green = mox_array.count("green")
					costs.mox.orange = mox_array.count("orange")
					costs.mox.blue = mox_array.count("blue")
				elif typeof(dict.costs.mox) == TYPE_DICTIONARY:
					var mox_dict: Dictionary[String, int]
					mox_dict.assign(dict.costs.mox as Dictionary)
					costs.mox.green = mox_dict.green
					costs.mox.orange = mox_dict.orange
					costs.mox.blue = mox_dict.blue
				continue
			# Godot hate "unsafe" type cast
			if typeof(dict[prop]) == TYPE_ARRAY:
				get(prop).assign(dict[prop])
				continue
			set(prop, dict[prop])

	func duplicate() -> CardData:
		return CardData.new(as_dict().duplicate())


static var RULESET_SCHEMA: Dictionary[String, Dictionary] = {
	name = {types = [TYPE_STRING], default = "Placeholder ruleset name"},
	description = {types = [TYPE_STRING], default = "Placeholder description"},
	icon = {types = [TYPE_STRING], default = "ruleset_icon/MISSING.png"},
	settings =
	{
		types = [TYPE_DICTIONARY],
		schema =
		{
			deck_size_min = {types = [TYPE_INT], default = 30},
			enable_backrow = {types = [TYPE_BOOL], default = false},
			candles =
			{
				types = [TYPE_DICTIONARY],
				schema =
				{
					amount = {types = [TYPE_INT], default = 2},
					smoke = {types = [TYPE_STRING], default = "Greater Smoke"}
				}
			}
		}
	},
	rarities =
	{
		types = [TYPE_DICTIONARY],
		key_type = TYPE_STRING,
		value_type = TYPE_DICTIONARY,
		schema =
		{
			default = {types = [TYPE_BOOL], default = false},
			max =
			{
				types = [TYPE_DICTIONARY],
				schema =
				{main = {types = [TYPE_INT], default = 1}, side = {types = [TYPE_INT], default = 1}}
			},
			icon = {types = [TYPE_STRING], default = ""},
			name = {types = [TYPE_STRING], default = ""}
		}
	},
	traits =
	{
		types = [TYPE_DICTIONARY],
		key_type = TYPE_STRING,
		value_type = TYPE_DICTIONARY,
		schema =
		{
			icon = {types = [TYPE_STRING], default = ""},
			name = {types = [TYPE_STRING], default = ""},
			hidden = {types = [TYPE_BOOL], default = false}
		}
	},
	temples =
	{
		types = [TYPE_DICTIONARY],
		key_type = TYPE_STRING,
		value_type = TYPE_DICTIONARY,
		schema =
		{
			icon = {types = [TYPE_STRING], default = ""},
			name = {types = [TYPE_STRING], default = ""},
			frame = {types = [TYPE_DICTIONARY], key_type = TYPE_STRING, value_type = TYPE_STRING},
		}
	},
	tribes =
	{
		types = [TYPE_DICTIONARY],
		key_type = TYPE_STRING,
		value_type = TYPE_DICTIONARY,
		schema =
		{icon = {types = [TYPE_STRING], default = ""}, name = {types = [TYPE_STRING], default = ""}}
	},
	cards =
	{
		types = [TYPE_DICTIONARY],
		key_type = TYPE_STRING,
		value_type = TYPE_DICTIONARY,
		schema = CardData.SCHEMA,
		default = {}
	}
	# TODO: Implement side deck later
}

var name: String
var description: String
var icon: Texture2D
var settings: RulesetSettings
var rarities: Dictionary[String, Rarity] = {
	common = Rarity.COMMON_RARITY, rare = Rarity.RARE_RARITY
}
var default_rarity: Rarity = Rarity.COMMON_RARITY
var traits: Dictionary[String, Trait] = {
	unhammerable = Trait.UNHAMMERABLE, bloodless = Trait.BLOODLESS, boneless = Trait.BONELESS
}
var temples: Dictionary[String, Temple] = {
	beast = Temple.BEAST,
	undead = Temple.UNDEAD,
	technology = Temple.TECHNOLOGY,
	magick = Temple.MAGICK
}
var tribes: Dictionary[String, Tribe] = {
	reptile = Tribe.REPTILE,
	insect = Tribe.INSECT,
	avian = Tribe.AVIAN,
	canine = Tribe.CANINE,
	hooved = Tribe.HOOVED,
	crustacean = Tribe.CRUSTACEAN,
	gems = Tribe.GEMS,
}
var cards: Dictionary[String, CardData]
# TODO: Implement side deck later


func _init(ruleset: Dictionary) -> void:
	Global.validate_schema(ruleset, RULESET_SCHEMA)
	name = ruleset.name
	description = ruleset.description
	icon = load("res://asset".path_join(ruleset.icon as String))
	settings = RulesetSettings.new(ruleset.settings as Dictionary)

	for rarity_name: String in (ruleset.rarities as Dictionary).keys():
		rarities[rarity_name] = Rarity.new(rarity_name, ruleset.rarities[rarity_name] as Dictionary)

	for trait_name: String in (ruleset.traits as Dictionary).keys():
		traits[trait_name] = Trait.new(trait_name, ruleset.traits[trait_name] as Dictionary)

	for temple_name: String in (ruleset.temples as Dictionary).keys():
		temples[temple_name] = Temple.new(temple_name, ruleset.temples[temple_name] as Dictionary)

	for card_name: String in (ruleset.cards as Dictionary).keys():
		cards[card_name] = CardData.new(ruleset.cards[card_name] as Dictionary)
