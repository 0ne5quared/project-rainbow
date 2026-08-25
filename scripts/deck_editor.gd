class_name DeckEditor
extends PanelContainer

var deck_builder_card := preload("res://prefab/card/card.tscn")
var card_listing := preload("res://prefab/card_listing/card_listing.tscn")


class Thing:
	var deck: Dictionary[String, int] = {}
	var listings: Dictionary[String, CardListing] = {}
	var ordered_deck: Array[Ruleset.CardData] = []
	var container: VBoxContainer

	func _init(c: Node) -> void:
		container = c


@onready var main_thing := Thing.new(%MainDeckContainer)
@onready var side_thing := Thing.new(%SideDeckContainer)
@onready var side_board_thing := Thing.new(%SideBoardContainer)
@onready var selected_thing := main_thing

## the [Variant] can be either [SideDeck] or [SideDeckCategory]
var side_deck_options: Array[Variant] = []
var category_options: Array[Ruleset.SideDeck] = []
var selected_side_deck: Ruleset.SideDeck

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

var filters_btn: Array[FilterButton] = []


func _ready() -> void:
	Global.ruleset_changed.connect(_ruleset_changed)
	var btn_group := ButtonGroup.new()
	for portrait in DirAccess.get_files_at("res://asset/portraits/"):
		if not portrait.ends_with(".png"):
			continue
		var texture: Texture2D = load("res://asset/portraits/%s" % portrait)
		if texture.get_size() != Vector2(41, 28):
			continue
		var btn := Button.new()
		btn.icon = texture
		btn.button_group = btn_group
		btn.toggle_mode = true
		btn.theme_type_variation = "IconSelectButton"
		btn.pressed.connect(_on_icon_selected.bind(texture))
		%DeckIconContainer.add_child(btn)
	pass


func _ruleset_changed(ruleset: Ruleset) -> void:
	Global.clear_children(%CardList)
	for card_data: Ruleset.CardData in ruleset.cards.values():
		var db_card: Card = deck_builder_card.instantiate()
		db_card.card_data = card_data
		db_card.is_db_card = true
		db_card.pressed.connect(_on_card_selected.bind(db_card))
		%CardList.add_child(db_card)

	_update_card_list()

	_update_filters_ui(ruleset)

	%SideOption.clear()
	for side_deck: Variant in ruleset.side_decks.values():
		%SideOption.add_item(side_deck.display_name)
		side_deck_options.append(side_deck)
	selected_thing = side_thing
	_on_side_option_item_selected(0)
	selected_thing = main_thing


func _update_card_list() -> void:
	%CardList.visible = false
	for card: Card in %CardList.get_children():
		if card.visible:
			%CardList.visible = true
			break
	%CardListLabel.visible = not %CardList.visible
	for card: Card in %CardList.get_children():
		if card.banned_overlay != null and card.banned_overlay.visible:
			%CardList.move_child(card, -1)


func _update_filters_ui(ruleset: Ruleset) -> void:
	# generate the new filter list
	filters.clear()
	filters_btn.clear()
	for group: Array in enabled_filters.values():
		group.clear()
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


func _update_card_count() -> void:
	var main_size := Global.sum(main_thing.deck.values())
	var side_size := Global.sum(side_thing.deck.values())
	var main_size_min := Global.ruleset.settings.deck_size_min
	%MainSizeLabel.text = (
		"Main: %s%s%s/%s+ Cards"
		% [
			"[color=#82051e]" if main_size < main_size_min else "",
			main_size,
			"[/color]" if main_size < main_size_min else "",
			main_size_min
		]
	)
	%SideSizeLabel.text = (
		("Side: %s/%s Cards" % [side_size, selected_side_deck.max_size])
		if selected_side_deck.type == Ruleset.SideDeck.Type.DRAFT
		else ("Side: %s Cards" % side_size)
	)


func _update_filters() -> void:
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
	_update_card_list()


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
	filters_btn.append(btn)
	return btn


func _on_card_selected(card: Card) -> void:
	if selected_thing == side_thing:
		if (
			selected_thing.deck.get(card.card_name, 0) >= card.rarity.max_side
			or Global.sum(side_thing.deck.values()) >= selected_side_deck.max_size
		):
			return
	else:
		if selected_thing.deck.get(card.card_name, 0) >= card.rarity.max_main:
			return
	_add_card(card.card_data)


func _remove_card(listing: CardListing) -> void:
	var card_data := listing.card_data
	listing.amount -= 1
	selected_thing.deck[card_data.name] -= 1
	if Input.is_key_pressed(KEY_SHIFT):
		listing.amount = 0
		selected_thing.deck[card_data.name] = 0
	if listing.amount <= 0:
		# Clean up the ui
		selected_thing.container.remove_child(listing)
		listing.queue_free()

		# Clean up internal tracker
		selected_thing.ordered_deck.remove_at(selected_thing.ordered_deck.find(card_data))
		selected_thing.deck.erase(card_data.name)
	_update_card_count()


func _add_card(card_data: Ruleset.CardData) -> void:
	var card_name := card_data.name
	var rarity := Global.ruleset.rarities[card_data.rarity]
	var max_amount: int
	if selected_thing == side_thing:
		var side_size := Global.sum(side_thing.deck.values())
		max_amount = min(rarity.max_side, selected_side_deck.max_size - side_size)
	else:
		max_amount = rarity.max_main
	if card_name in selected_thing.deck:
		selected_thing.listings[card_name].amount += 1
		selected_thing.deck[card_name] += 1
		if Input.is_key_pressed(KEY_SHIFT):
			selected_thing.listings[card_name].amount = max_amount
			selected_thing.deck[card_data.name] = max_amount
	else:
		var listing: CardListing = card_listing.instantiate()
		listing.card_data = card_data
		if selected_thing != side_thing or selected_side_deck.type == Ruleset.SideDeck.Type.DRAFT:
			listing.pressed.connect(_remove_card.bind(listing))

		selected_thing.listings[card_name] = listing
		selected_thing.deck[card_name] = 1
		if Input.is_key_pressed(KEY_SHIFT):
			listing.amount = max_amount
			selected_thing.deck[card_data.name] = max_amount
		var index := (
			selected_thing.ordered_deck.rfind_custom(Global.compare_card.bind(card_data)) + 1
		)
		selected_thing.ordered_deck.insert(index, card_data)
		selected_thing.container.add_child(listing)
		selected_thing.container.move_child(listing, index)
	_update_card_count()


func _on_side_option_item_selected(index: int) -> void:
	# cleanse everything no matter what
	Global.clear_children(selected_thing.container)
	selected_thing.listings.clear()
	selected_thing.deck.clear()
	selected_thing.ordered_deck.clear()
	%CatOptContainer.visible = false
	%CatOption.clear()

	var option: Variant = side_deck_options[index]
	if option is Ruleset.SideDeck:
		selected_side_deck = option as Ruleset.SideDeck
		_process_side_deck()
		return

	var category := option as Ruleset.SideDeckCategory
	%CatOptContainer.visible = true
	for deck: Ruleset.SideDeck in category.decks.values():
		%CatOption.add_item(deck.display_name)
		category_options.append(deck)
	_on_cat_option_item_selected(0)


func _on_cat_option_item_selected(index: int) -> void:
	# cleanse everything no matter what
	Global.clear_children(selected_thing.container)
	selected_thing.listings.clear()
	selected_thing.deck.clear()
	selected_thing.ordered_deck.clear()
	selected_side_deck = category_options[index]
	_process_side_deck()


func _process_side_deck() -> void:
	match selected_side_deck.type:
		Ruleset.SideDeck.Type.CONSTRUCTED:
			for card_name in selected_side_deck.cards:
				_add_card(Global.get_card_by_name(card_name))
		Ruleset.SideDeck.Type.DRAFT:
			for card: Card in %CardList.get_children():
				card.visible = true
				card.banned_overlay.visible = card.card_name not in selected_side_deck.cards
			_update_card_list()
	_update_card_count()


func _on_name_filter_text_changed(_new_text: String) -> void:
	_update_filters()


func _on_tab_container_tab_changed(tab: int) -> void:
	for card: Card in %CardList.get_children():
		if tab == 1:
			if selected_side_deck.type == Ruleset.SideDeck.Type.CONSTRUCTED:
				card.visible = false
			else:
				card.visible = true
				card.banned_overlay.visible = card.card_name not in selected_side_deck.cards
		else:
			card.visible = true
			card.banned_overlay.visible = card.card_data.banned
	_update_card_list()
	match tab:
		0:
			selected_thing = main_thing
		1:
			selected_thing = side_thing
		2:
			selected_thing = side_board_thing


func _on_clear_filter_pressed() -> void:
	for group: Array in enabled_filters.values():
		group.clear()
	for btn in filters_btn:
		btn.button_pressed = false
		btn._on_toggled(false)
	for btn in %CostsFiltersContainer.get_children():
		if btn is not FilterButton:
			continue
		btn.button_pressed = false
		btn._on_toggled(false)


func _on_icon_selected(texture: Texture2D) -> void:
	%DeckIcon.texture = texture


func _on_deck_name_changed(new_text: String) -> void:
	%DeckName.text = new_text
