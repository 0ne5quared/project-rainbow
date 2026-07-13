class_name HandManager
extends Control

@onready var cards_manager: CardsManager = %CardsManager

signal card_selected(card: Card)
signal card_unselected(card: Card)

var selected: Card


func _ready() -> void:
	cards_manager.card_changed_zone.connect(_on_card_changed_zone)


func draw_card(card_data: Dictionary) -> Card:
	var new: Card = cards_manager.add_card(card_data, Card.Zone.HAND)
	new.mouse_entered.connect(_on_card_hovered.bind(new))
	new.mouse_exited.connect(_on_card_unhovered.bind(new))
	new.pressed.connect(_select_card.bind(new))
	return new


## Arrange all the card within this container
##
## This method basically will get all of its children to fan around the
## [member CENTER] with radius equal to the length of [member START_VECTOR].
func position_card() -> void:
	var cards: Array[Card] = cards_manager.get_cards_by_zone(Card.Zone.HAND)
	var count := cards.size()
	if count == 0:
		return

	var spacing := 0.0
	if count > 1:
		spacing = min(
			(custom_minimum_size.x - Global.CARD_SIZE.x) / (count - 1), Global.CARD_SIZE.x + 2
		)

	var x := (
		global_position.x
		+ (custom_minimum_size.x - (Global.CARD_SIZE.x + spacing * (count - 1))) / 2.0
	)

	var y := _get_y()

	for i in count:
		cards[i].position = Vector2(x + spacing * i, y)


func _get_y() -> float:
	return global_position.y + (custom_minimum_size.y - Global.CARD_SIZE.y) / 2.0


func _on_card_hovered(card: Card) -> void:
	_raise_card(card)
	card.z_index = 2


func _on_card_unhovered(card: Card) -> void:
	if selected == card:
		return
	_unraise_card(card)


func _raise_card(card: Card) -> void:
	create_tween().tween_property(
		card, ^"position", Vector2(card.position.x, _get_y()) + Vector2.UP * 20, 0.2
	)
	card.z_index = 1


func _unraise_card(card: Card) -> void:
	create_tween().tween_property(card, ^"position", Vector2(card.position.x, _get_y()), 0.2)
	card.z_index = 0


func _select_card(card: Card, emit_event := true) -> void:
	if selected == card:
		_unraise_card(selected)
		selected = null
		card_unselected.emit(card)
		return
	if selected != null:
		_unselect_card(selected)
	selected = card
	_raise_card(card)
	if emit_event:
		card_selected.emit(card)


func _unselect_card(card: Card, emit_event := true) -> void:
	_unraise_card(selected)
	selected = null
	if emit_event:
		card_unselected.emit(card)


func _on_card_changed_zone(card: Card, from: Card.Zone, to: Card.Zone) -> void:
	if card == selected and card.zone != Card.Zone.HAND:
		# Oh the card I was holding is gone :(
		selected = null
	if from == Card.Zone.HAND or to == Card.Zone.HAND:
		if from == Card.Zone.HAND:
			card.disconnect(&"mouse_entered", _on_card_hovered)
			card.disconnect(&"mouse_exited", _on_card_unhovered)
			card.disconnect(&"pressed", _select_card)

		position_card()
