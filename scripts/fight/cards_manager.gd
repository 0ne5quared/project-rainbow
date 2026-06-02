class_name CardsManager
extends Control

const CARD_PREFAB: PackedScene = preload("res://prefab/card/card.tscn")

@onready var fight_manager: FightManager = $".."

var cards: Dictionary[int, Card]

signal card_change_zone(card: Card, from: Card.Zone, to: Card.Zone)


func add_card(card_data: Dictionary, zone: Card.Zone) -> Card:
	var card: Card = CARD_PREFAB.instantiate()
	card.zone = zone
	card.card_data = card_data
	add_child(card)
	cards[card.id] = card
	for sigil in card.sigils:
		sigil.fight_manager = fight_manager
	card_change_zone.emit(card, Card.Zone.LIMBO, zone)
	return card


func get_cards_from_zone(zone: Card.Zone) -> Array[Card]:
	return cards.values().filter(func(c: Card) -> bool: return c.zone == zone)


func get_card_by_id(id: int) -> Card:
	return cards[id]


func move_card(card_id: int, zone: Card.Zone) -> void:
	var card := cards[card_id]
	var from := card.zone
	card.zone = zone
	card_change_zone.emit(card, from, zone)
