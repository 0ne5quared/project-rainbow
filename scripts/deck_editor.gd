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


func _ready() -> void:
	Global.ruleset_changed.connect(_ruleset_changed)
	pass


func _ruleset_changed(ruleset: Ruleset) -> void:
	for child in %CardList.get_children():
		%CardList.remove_child(child)
		child.queue_free()
	for card_data: Ruleset.CardData in Global.ruleset.cards.values():
		var db_card: Card = deck_builder_card.instantiate()
		db_card.card_data = card_data
		db_card.pressed.connect(_on_card_selected.bind(db_card))
		%CardList.add_child(db_card)


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
