class_name HandManager
extends Control

@onready var cards_manager: CardsManager = %CardsManager

signal card_selected(card: Card)
signal card_unselected(card: Card)

#gdlint: disable=class-variable-name,class-definitions-order
## The center of this hand container where all the card "fan" around
var CENTER: Vector2
## The "start vector", basically a vector that point from the center to the
## start position, used to calculate the position and rotation to fan the card
var START_VECTOR: Vector2
## The maximum angle allows for the hand container "fan", basically the angle
## between the starting position and the ending position around the
## [member CENTER]
var MAX_ANGLE: float

## The maximum angle between the card in the fan.
## Note this is in radian, mostly for convenient, should be roughly 8 degree
const MAX_FAN_ANGLE = deg_to_rad(8)

var THETA: float
var ANGLE_OFFSET: float
#gdlint: enable=class-variable-name,class-definition-order

var cards: Array[Card]
var selected: Card


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	# this will give a vector point from the mid point to the start point
	# the intersection between the perpendicular bisector of this line and
	# the pependicular bisector of the line between the start and end point
	# (this line is the same as a line pointing down from the mid point)
	# will give us the center of the circle containing all 3 point
	var start := Vector2(0, 3 * size.y / 4)
	var mid := Vector2(size.x / 2, 20)
	var end := start + Vector2(size.x, 0)
	var t := start - mid

	CENTER = Geometry2D.line_intersects_line(mid + t / 2, t.rotated(PI / 2), mid, Vector2.DOWN)
	START_VECTOR = start - CENTER
	MAX_ANGLE = START_VECTOR.angle_to(end - CENTER)

	for i in range(5):
		draw_card({"name": "Squirrel", "attack": 1, "health": 5, "sigils": ["Dam Builder"]})
	arrage_card()


func _input(_event: InputEvent) -> void:
	pass
	#if Input.is_action_just_pressed("draw"):
	#for i in range(5):
	#draw_card(
	#{
	#"name": "Squirrel",
	#"attack": 1,
	#"health": 5,
	#}
	#)
	#elif Input.is_action_pressed("discard"):
	#remove_card(0)


func draw_card(card_data: Dictionary) -> void:
	var new: Card = %CardsManager.add_card(card_data, Card.Zone.HAND)
	var button: Button = new.get_node(^"CardContainer")
	button.mouse_entered.connect(_on_card_hovered.bind(new))
	button.mouse_exited.connect(_on_card_unhovered.bind(new))
	button.pressed.connect(_select_card.bind(new))


func remove_card(idx: int) -> void:
	# TODO rewrite with new card manager
	assert(idx in range(get_child_count()), "Can't remove child at %s, it does not exist" % idx)
	remove_child(cards[idx])
	cards[idx].queue_free()
	cards.remove_at(idx)


func update_angle() -> void:
	var t: int = cards.size() - 1
	THETA = min(MAX_FAN_ANGLE, MAX_ANGLE / (t))
	ANGLE_OFFSET = (MAX_ANGLE - THETA * (t)) / 2
	if t == 0:
		THETA = MAX_ANGLE / 2


## Arrange all the card within this container
##
## This method basically will get all of its children to fan around the
## [member CENTER] with radius equal to the length of [member START_VECTOR].
func arrage_card() -> void:
	update_angle()
	for i: int in cards.size():
		var child: Card = cards[i]
		var trans := calculate_card_transform(i)
		if child.zone == Card.Zone.HAND:
			var tween := child.create_tween()
			tween.set_parallel()
			tween.tween_property(child, "position", trans.get_origin(), 0.2)
			tween.tween_property(child, "rotation", trans.get_rotation(), 0.2)


func calculate_card_transform(i: int) -> Transform2D:
	var t := START_VECTOR.rotated(THETA * i + ANGLE_OFFSET)
	var pos := t + CENTER + global_position
	var rot := t.angle() + PI / 2
	return Transform2D(rot, pos)


func _on_card_hovered(card: Card) -> void:
	_raise_card(card)
	card.z_index = 2


func _on_card_unhovered(card: Card) -> void:
	if selected == card:
		return
	_unraise_card(card)


func _raise_card(card: Card) -> void:
	var trans := calculate_card_transform(cards.find(card))
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(
		card, ^"position", trans.get_origin() + Vector2.UP * (40 if selected == card else 20), 0.2
	)
	tween.tween_property(card, ^"rotation", 0.0, 0.2)
	card.z_index = 1


func _unraise_card(card: Card) -> void:
	var trans := calculate_card_transform(cards.find(card))
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(card, ^"position", trans.get_origin(), 0.2)
	tween.tween_property(card, ^"rotation", trans.get_rotation(), 0.2)
	card.z_index = 0


func _select_card(card: Card) -> void:
	if selected == card:
		_unraise_card(selected)
		selected = null
		card_unselected.emit(card)
		return
	if selected != null:
		_unraise_card(selected)
	selected = card
	_raise_card(card)
	card_selected.emit(card)


func _on_card_change_zone(card: Card, from: Card.Zone, to: Card.Zone) -> void:
	if card == selected and card.zone != Card.Zone.HAND:
		# oh the card i was holding is gone :(
		selected = null

	if from == Card.Zone.HAND or to == Card.Zone.HAND:
		cards = cards_manager.get_cards_from_zone(Card.Zone.HAND)
		if from == Card.Zone.HAND:
			# disconnect all the signal that was made by the hand
			var card_btn: Button = card.get_node(^"CardContainer")

			card_btn.disconnect(&"mouse_entered", _on_card_hovered)
			card_btn.disconnect(&"mouse_exited", _on_card_unhovered)
			card_btn.disconnect(&"pressed", _select_card)

		arrage_card()
