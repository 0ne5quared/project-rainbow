class_name DeckEditor
extends PanelContainer

var deck_builder_card := preload("res://prefab/card/card.tscn")
var card_listing := preload("res://prefab/card_listing/card_listing.tscn")

var main: Dictionary[String, int]
var side: Dictionary
var draft_side: Dictionary[String, int]

var listings: Dictionary[String, CardListing]
var side_listings: Dictionary[String, CardListing]

var ordered_deck: Array[Ruleset.CardData]
var side_ordered_deck: Array[Ruleset.CardData]

var current_deck: Dictionary[String, int] = main
var current_listings: Dictionary[String, CardListing] = listings
var current_ordered_deck: Array[Ruleset.CardData] = ordered_deck
@onready var current_container: Node = %MainDeckContainer

var _cost_filters: Dictionary[String, Callable] = {
	blood = func(c: Card) -> bool: return c.costs.blood > 0,
	bone = func(c: Card) -> bool: return c.costs.bone > 0,
	energy = func(c: Card) -> bool: return c.costs.energy > 0,
	cell = func(c: Card) -> bool: return c.costs.cell > 0,
	green = func(c: Card) -> bool: return c.costs.mox.green > 0,
	orange = func(c: Card) -> bool: return c.costs.mox.orange > 0,
	blue = func(c: Card) -> bool: return c.costs.mox.blue > 0,
}
var filters: Dictionary[String, Callable] = _cost_filters.duplicate()
var enabled_filters: Dictionary[FilterButton.FilterGroup, Array] = {
	FilterButton.FilterGroup.COST: [],
	FilterButton.FilterGroup.RARITY: [],
	FilterButton.FilterGroup.TRAIT: [],
	FilterButton.FilterGroup.TEMPLE: [],
	FilterButton.FilterGroup.TRIBE: []
}


func _ready() -> void:
	Global.ruleset_changed.connect(_ruleset_changed)
	pass


func _ruleset_changed(ruleset: Ruleset) -> void:
	Global.clear_children(%CardList)
	for card_data: Ruleset.CardData in ruleset.cards.values():
		var db_card: Card = deck_builder_card.instantiate()
		db_card.card_data = card_data
		db_card.pressed.connect(_on_card_selected.bind(db_card))
		%CardList.add_child(db_card)

	# generate the new filter list
	filters.clear()
	var containers: Array[GridContainer] = [
		%RarityFiltersContainer,
		%TraitFiltersContainer,
		%TempleFiltersContainer,
		%TribeFiltersContainer
	]
	for container in containers:
		Global.clear_children(container)
	filters = _cost_filters.duplicate()

	for rarity: Ruleset.Rarity in ruleset.rarities.values():
		filters[rarity.name] = func(c: Card) -> bool: return c.rarity == rarity
		%RarityFiltersContainer.add_child(
			_new_filter_btn(
				rarity.icon, rarity.display_name, rarity.name, FilterButton.FilterGroup.RARITY
			)
		)
	# trait is keyword so trait_ it is :(
	for trait_: Ruleset.Trait in ruleset.traits.values():
		filters[trait_.name] = func(c: Card) -> bool: return trait_ in c.traits
		%TraitFiltersContainer.add_child(
			_new_filter_btn(
				trait_.icon, trait_.display_name, trait_.name, FilterButton.FilterGroup.TRAIT
			)
		)

	for temple: Ruleset.Temple in ruleset.temples.values():
		filters[temple.name] = func(c: Card) -> bool: return c.temple == temple
		%TempleFiltersContainer.add_child(
			_new_filter_btn(
				temple.icon, temple.display_name, temple.name, FilterButton.FilterGroup.TEMPLE
			)
		)

	for tribe: Ruleset.Tribe in ruleset.tribes.values():
		filters[tribe.name] = func(c: Card) -> bool: return tribe in c.tribes
		%TribeFiltersContainer.add_child(
			_new_filter_btn(
				tribe.icon, tribe.display_name, tribe.name, FilterButton.FilterGroup.TRIBE
			)
		)


func _on_card_selected(card: Card) -> void:
	if main.get(card.card_name, 0) >= card.rarity.max_main:
		return
	_add_card(card.card_data)


func _remove_card(listing: CardListing) -> void:
	var card_data := listing.card_data
	listing.amount -= 1
	current_deck[card_data.name] -= 1
	if listing.amount <= 0:
		# Clean up the ui
		current_container.remove_child(listing)
		listing.queue_free()

		# Clean up internal tracker
		current_ordered_deck.remove_at(current_ordered_deck.find(card_data))
		current_deck.erase(card_data.name)
	pass


func _add_card(card_data: Ruleset.CardData) -> void:
	var card_name := card_data.name
	if card_name in current_deck:
		current_listings[card_name].amount += 1
		current_deck[card_name] += 1
	else:
		var listing: CardListing = card_listing.instantiate()
		listing.card_data = card_data
		current_listings[card_name] = listing
		listing.pressed.connect(_remove_card.bind(listing))
		current_deck[card_name] = 1
		var index := current_ordered_deck.rfind_custom(Global.compare_card.bind(card_data)) + 1
		current_ordered_deck.insert(index, card_data)
		current_container.add_child(listing)
		current_container.move_child(listing, index)


func update_filters() -> void:
	for card: Card in %CardList.get_children():
		var name_keep: bool = (
			%NameFilter.text.is_empty() or %NameFilter.text.to_lower() in card.card_name.to_lower()
		)

		var apply_filter := func(f: String) -> bool: return filters[f].call(card)
		var identity := func(b: bool) -> bool: return b

		var filters_results := enabled_filters.values().map(
			func(fs: Array) -> bool:
				return true if fs.is_empty() else fs.map(apply_filter).any(identity)
		)

		card.visible = filters_results.all(identity) and name_keep


func _on_name_filter_text_changed(_new_text: String) -> void:
	update_filters()


func _new_filter_btn(
	icon: Texture2D,
	display_name: String,
	filter_name: String,
	filter_group: FilterButton.FilterGroup
) -> FilterButton:
	var btn := FilterButton.new()
	btn.icon = icon
	btn.text = display_name
	btn.filter_name = filter_name
	btn.filter_group = filter_group
	btn.deck_editor = self
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return btn
