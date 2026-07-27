class_name Ruleset
extends Object


## Settings for candle/lives.
class CandlesSettings:
	## The amount of candles each player start with.
	var amount: int
	## The name of the card that snuffing candle will produce. If not provided the candle cannot be
	## snuff.
	var smoke: String


## General settings for the ruleset.
class RulesetSettings:
	## Minimum deck size
	var deck_size_min: int
	## Wherever to enable the backrow, this currently does not work.
	var enable_backrow: bool
	## Candles settings, refer to [CandlesSettings].
	var candles: CandlesSettings


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


## Metadata for cards. This is a general class uses for tribes, temples and
## traits.
class Metadata:
	## Name of the metadata.
	var name: String
	## The icon to use for this metadata.
	var icon: Texture2D
	## The display name override for this metadata. If not provided the display name will be
	## [member name] capitalized.
	var name_override: String
	var is_hidden: bool


class CardData:
	const SCHEMA: Dictionary[String, Dictionary] = {
		name = {types = [TYPE_STRING], default = "MISSING"},
		attack = {types = [TYPE_INT, TYPE_STRING], default = 0},
		health = {types = [TYPE_INT], default = 1},
		sigils = {types = [TYPE_ARRAY], sub_type = TYPE_STRING, default = []},
		traits = {types = [TYPE_ARRAY], sub_type = TYPE_STRING, default = []},
		temple = {types = [TYPE_STRING], default = ""},
		tribes = {types = [TYPE_ARRAY], sub_type = TYPE_STRING, default = []},
		costs =
		{
			types = [TYPE_DICTIONARY],
			schema =
			{
				bone = {types = [TYPE_INT], default = 0},
				blood = {types = [TYPE_INT], default = 0},
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
			default = {}
		},
		tokens = {types = [TYPE_ARRAY], sub_type = TYPE_STRING, default = []}
	}
	var name: String
	var attack: Variant
	var health: Variant
	var sigils: Array[String]
	var traits: Array[String]
	var temple: String
	var tribes: Array[String]
	var costs: Card.Costs
	var tokens: Array[String]
	var sigils_config: Dictionary

	func as_dict() -> Dictionary:
		# TODO: Implement this
		return {}

	func _init(dict: Dictionary) -> void:
		Global.validate_schema(dict, SCHEMA)
		for prop in SCHEMA:
			if prop == "costs":
				costs = Card.Costs.new()
				costs.bone = dict.costs.bone
				costs.bone = dict.costs.bone
				costs.bone = dict.costs.bone
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
			set(prop, dict[prop])

	func duplicate() -> CardData:
		return CardData.new(as_dict().duplicate())


var name: String
var description: String
var setting: RulesetSettings
var rarities: Array[Rarity]
var default_rarity: Rarity
var traits: Array[Metadata]
var temples: Array[Metadata]
var tribes: Array[Metadata]
var cards: Dictionary[String, CardData]


func _init(ruleset: Dictionary) -> void:
	# TODO: Implement ruleset parsing
	pass
