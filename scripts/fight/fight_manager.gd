class_name FightManager

extends Control

enum State {
	## The idle state, the fightmanager have nothing to do
	IDLE,
	## A card is selected and awaiting slot selection
	PLAYING_CARD,
	## Awaiting a cost to be pay
	PAYING_COST,
	## Hammer time!!! :DDDD
	HAMMER
}

@onready var hand_manager: HandManager = %HandManager
@onready var board_manager: BoardManager = %BoardManager
@onready var card_manager: CardsManager = %CardsManager

var state := State.IDLE
var turn := 1
var active_player := randi_range(0, 1)

var _got_opp_private := false
var _opp_private: Array[Action] = []


func _start_fight() -> void:
	visible = true
	_draw_card()


func _draw_card() -> void:
	hand_manager.draw_card({name = "Squirrel", attack = 0, health = 1})


func _ready() -> void:
	ConnectionManager.recieved_packet.connect(_on_recieved_packet)


func _on_recieved_packet(packet: Dictionary) -> void:
	if packet.type != ConnectionManager.GameMessage.ACTIONS:
		return

	var actions: Array[Action]
	actions.assign(
		(packet.actions as Array[Dictionary]).map(
			func(a: Dictionary) -> Action: return Action.from_dict(a)
		)
	)

	if packet.private as bool:
		assert(_got_opp_private == false, "Somehow got another private before processing the first")
		_got_opp_private = true
		_opp_private = actions
	else:
		_push_actions(actions)
		@warning_ignore("missing_await")
		_resolve_stack()


func _on_slot_selected(slot: BoardManager.Slot) -> void:
	if state == State.PLAYING_CARD and slot.pos.y == BoardManager.Row.MINE:
		var a := Action.new_play_card(
			hand_manager.selected.id, slot.pos, Action.PlacerType.PLAYER, Global.uuid
		)
		_add_then_resolve(a)
		a.data.pos -= Vector2i(0, board_manager.columns - 1)
		a.data.pos = abs(a.data.pos) as Vector2i
		ConnectionManager.send(
			ConnectionManager.GameMessage.ACTIONS, {actions = [a.as_dict()], private = false}
		)


func _on_card_selected(_card: Card) -> void:
	state = State.PLAYING_CARD


func _on_card_unselected(_card: Card) -> void:
	if state == State.PLAYING_CARD:
		state = State.IDLE


# --- STACK SHIT ---

## The top of the stack is at 0, this shouldn't be modify directly but instead through
## [method add_to_stack]
var _stack: Array[Action] = []


## Add an action to the stack. This should be use instead of changing [member _stack]
## manually.
func _push_action(action: Action) -> void:
	if not _stack.is_empty():
		seed(_stack[-1].id.hash())
		action.id = Global.gen_id()
	_stack.push_back(action)


func _push_actions(actions: Array[Action]) -> void:
	for a in actions:
		_push_action(a)


## This add an action to the stack then resolve the stack immedietly.
##
## Unless you know what you are doing, don't use this method and just use
## [method add_to_stack] instead and let the game handle the resolution for you
func _add_then_resolve(action: Action) -> void:
	_push_action(action)
	@warning_ignore("missing_await")
	_resolve_stack()


## resolve the first item on top of the stack
func _resolve_stack() -> void:
	while _stack.size() > 0:
		var action: Action = _stack.pop_back()
		match action.type as int:
			Action.Type.PLAY_CARD:
				_resolve_play_card(
					action.data.card_id as String,
					action.data.pos as Vector2i,
					action.data.placer_type as Action.PlacerType,
					action.data.placer_id as String
				)
			_:
				push_error("This stack action is not implemented: %s" % action.type)
		while not _got_opp_private:
			await ConnectionManager.recieved_packet
		_push_actions(_opp_private)
		_got_opp_private = false


func _resolve_play_card(
	card_id: String, pos: Vector2i, placer_type: Action.PlacerType, placer_id: String
) -> void:
	if not board_manager.is_slot_empty(pos):
		print("Someone is trying to play into a slot with a card already. This might be a bug.")
		return

	card_manager.move_card(card_id, Card.Zone.BOARD)
	var slot := board_manager.get_slot(pos)
	var card := card_manager.get_card_by_id(card_id)
	slot.card = card
	_activate_sigils(
		func(sigils: Sigil) -> void: sigils.on_played(card, pos, placer_type, placer_id)
	)


func _activate_sigils(callback: Callable) -> void:
	_activate_sigil_on_cards(_public_activation_order(), callback)
	var private := _activate_sigil_on_cards(_private_activation_order(), callback)
	ConnectionManager.send(
		ConnectionManager.GameMessage.ACTIONS,
		{actions = private.map(func(a: Action) -> Dictionary: return a.as_dict()), private = true}
	)


func _activate_sigil_on_cards(cards: Array[Card], callback: Callable) -> Array[Action]:
	var out: Array[Action] = []
	for card in cards:
		for sigil: Sigil in card.sigils.values():
			sigil._stack.clear()
			callback.call(sigil)
			_push_actions(sigil._stack)
			out.append_array(out)
	return out


func _public_activation_order() -> Array[Card]:
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


func _private_activation_order() -> Array[Card]:
	return card_manager.get_cards_by_zone(Card.Zone.HAND)
