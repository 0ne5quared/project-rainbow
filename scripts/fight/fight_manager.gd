class_name FightManager

extends Control

enum STATE {
	## The idle state, the fightmanager have nothing to do
	IDLE,
	## A card is selected and awaiting slot selection
	PLAYING_CARD,
	## Awaiting a cost to be pay
	PAYING_COST,
	## Hammer time!!! :DDDD
	HAMMER
}

var state := STATE.IDLE
var turn := 1
var active_player := randi_range(0, 1)

@onready var hand_manager: HandManager = %HandManager
@onready var board_manager: BoardManager = %BoardManager
@onready var card_manager: CardsManager = %CardsManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_slot_selected(slot: BoardManager.Slot) -> void:
	if state == STATE.PLAYING_CARD and slot.pos.y == BoardManager.Row.MINE:
		_add_then_resolve(
			Action.new_play_card_action(hand_manager.selected.id, slot.pos, ID.PLAYER, 0)
		)


func _on_card_selected(_card: Card) -> void:
	state = STATE.PLAYING_CARD


func _on_card_unselected(_card: Card) -> void:
	if state == STATE.PLAYING_CARD:
		state = STATE.IDLE


func _get_activation_order() -> Array[Card]:
	var out: Array[BoardManager.Slot] = board_manager.get_row(
		BoardManager.Row.MINE if active_player == 0 else BoardManager.Row.OPP
	)
	out.append_array(
		board_manager.get_row(BoardManager.Row.MINE if active_player != 0 else BoardManager.Row.OPP)
	)
	var res: Array[Card]
	res.assign(
		(
			out
			. map(func(s: BoardManager.Slot) -> Card: return s.card)
			. filter(func(c: Card) -> bool: return c != null)
		)
	)
	return res


func _activate_sigils(cb: Callable) -> void:
	for card in _get_activation_order():
		for sigil in card.sigils:
			_stack.append_array(cb.call(sigil) as Array[Dictionary])


# --- STACK SHIT ---

enum ID { CARD, PLAYER }


# IMPORTANT:
# When adding a new action, you should also implement these 3 things
# - A stack action constructor, like `PLAY_CARD` have `new_play_card_action`
# - A stack action resolver, like `PLAY_CARD` have `_resolve_play_card`
# - A sigil event hook, like `PLAY_CARD` have `on_played` (This can be found in the sigil
# class), also call said event hook.
# Should also document what the spec of the action look like/how to use them.
class Action:
	enum {
		## Action representing playing a card. The spec for this action include:
		## [code]card_id[/code], [code]pos[/code], [code]placer_type[/code],
		## [code]placer_id[/code]
		PLAY_CARD,
	}

	static func new_play_card_action(
		card_id: int, pos: Vector2i, placer_type: ID, placer_id: int
	) -> Dictionary:
		return {
			type = PLAY_CARD,
			card_id = card_id,
			pos = pos,
			placer_type = placer_type,
			placer_id = placer_id
		}


## The top of the stack is at 0, this shouldn't be modify directly but instead through
## [method add_to_stack]
var _stack: Array[Dictionary] = []


## Add an action to the stack. This should be use instead of changing [member _stack]
## manually.
func add_to_stack(action: Dictionary) -> void:
	_stack.push_back(action)


## This add an action to the stack then resolve the stack immedietly.
##
## Unless you know what you are doing, don't use this method and just use
## [method add_to_stack] instead and let the game handle the resolution for you
func _add_then_resolve(action: Dictionary) -> void:
	add_to_stack(action)
	_resolve_stack()


## resolve the first item on top of the stack
func _resolve_stack() -> void:
	while _stack.size() > 0:
		var action: Dictionary = _stack.pop_back()
		match action.type as int:
			Action.PLAY_CARD:
				_resolve_play_card(
					action.card_id as int,
					action.pos as Vector2i,
					action.placer_type as ID,
					action.placer_id as int
				)
			_:
				push_error("This stack action is not implemented: %s" % action.type)


func _resolve_play_card(card_id: int, pos: Vector2i, placer_type: ID, placer_id: int) -> void:
	if not board_manager.is_slot_empty(pos):
		print("Someone is trying to play into a slot with a card already. This might be a bug.")
		return

	card_manager.move_card(card_id, Card.Zone.BOARD)
	var slot := board_manager.get_slot(pos)
	var card := card_manager.get_card_by_id(card_id)
	slot.card = card
	_activate_sigils(
		func(sigils: Sigil) -> Array[Dictionary]:
			return sigils.on_played(card, pos, placer_type, placer_id)
	)
