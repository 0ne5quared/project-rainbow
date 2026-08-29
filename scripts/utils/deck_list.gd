class_name DeckList
extends VBoxContainer

var _card_listing := preload("res://prefab/card_listing/card_listing.tscn")

var deck: Dictionary[String, int] = {}
var listings: Dictionary[String, CardListing] = {}
var ordered_deck: Array[Ruleset.CardData] = []
@export var allow_remove: bool = true

signal on_card_added
signal on_card_removed


func load_deck(deck_dict: Dictionary[String, int]) -> void:
	for card_name: String in deck_dict.keys():
		var card_data := Global.get_card_by_name(card_name)
		if card_data == null:
			continue
		add_card(card_data, deck_dict[card_name])


func clear() -> void:
	Global.clear_children(self)
	listings.clear()
	deck.clear()
	ordered_deck.clear()
	pass


func remove_card(listing: CardListing) -> void:
	var card_data := listing.card_data
	listing.amount -= 1
	deck[card_data.name] -= 1
	if Input.is_key_pressed(KEY_SHIFT):
		listing.amount = 0
		deck[card_data.name] = 0
	if listing.amount <= 0:
		# Clean up the ui
		remove_child(listing)
		listing.queue_free()

		# Clean up internal tracker
		ordered_deck.remove_at(ordered_deck.find(card_data))
		deck.erase(card_data.name)


func add_card(card_data: Ruleset.CardData, amount: int) -> void:
	var card_name := card_data.name
	if card_name in deck:
		listings[card_name].amount += amount
		deck[card_name] += amount
	else:
		var listing: CardListing = _card_listing.instantiate()
		listing.card_data = card_data
		if allow_remove:
			listing.pressed.connect(remove_card.bind(listing))

		listings[card_name] = listing

		listing.amount = amount
		deck[card_name] = amount

		var index := ordered_deck.rfind_custom(Global.compare_card.bind(card_data)) + 1
		ordered_deck.insert(index, card_data)
		add_child(listing)
		move_child(listing, index)
