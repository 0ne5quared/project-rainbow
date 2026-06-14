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

signal stack_resolved

var state := State.IDLE
var turn := 1
## Am I the active player
var is_active: bool:
	set(new):
		is_active = new
		%Blocker.visible = not is_active
## The current scale position. Positive is me winnig and negative is me losing.
var scale_position := 0:
	set(new):
		scale_position = new
		$VBoxContainer/HBoxContainer2/LeftUI/RichTextLabel.text = "Scales: " + str(scale_position)

var _got_opp_private := false
var _opp_private: Array[Action] = []


func _start_fight() -> void:
	visible = true
	_draw_card()


func _draw_card() -> void:
	hand_manager.draw_card({name = "Squirrel", attack = 1, health = 1, sigils = ["Dam Builder"]})
	hand_manager.draw_card({name = "Squirrel", attack = 1, health = 1, sigils = ["Dam Builder"]})
	hand_manager.draw_card({name = "Squirrel", attack = 1, health = 1, sigils = ["Dam Builder"]})
	hand_manager.draw_card({name = "Squirrel", attack = 1, health = 1, sigils = ["Dam Builder"]})
	hand_manager.draw_card({name = "Squirrel", attack = 1, health = 1, sigils = ["Dam Builder"]})


func _ready() -> void:
	ConnectionManager.recieved_packet.connect(_on_recieved_packet)
	visible = true
	await get_tree().process_frame
	visible = false


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
		var a := PlayCardAction.new(
			hand_manager.selected.id, slot.pos, PlayCardAction.PlacerType.PLAYER, Global.uuid
		)
		_add_then_resolve(a)
		a.pos = BoardManager.oppose_pos(a.pos)
		ConnectionManager.send(
			ConnectionManager.GameMessage.ACTIONS, {actions = [a.as_dict()], private = false}
		)


func _on_card_selected(_card: Card) -> void:
	state = State.PLAYING_CARD


func _on_card_unselected(_card: Card) -> void:
	if state == State.PLAYING_CARD:
		state = State.IDLE


func _on_end_pressed() -> void:
	_add_then_resolve(EndTurnAction.new())
	ConnectionManager.send(
		ConnectionManager.GameMessage.ACTIONS,
		{actions = [EndTurnAction.new().as_dict()], private = false}
	)
	await stack_resolved
	is_active = not is_active


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
		$VBoxContainer/HBoxContainer2/RightUI/RichTextLabel.text = (
			"TOP: "
			+ action.fmt()
			+ "\n"
			+ "\n".join(_stack.map(func(x: Action) -> String: return x.fmt()))
		)
		action.resolve(self)
		while not _got_opp_private:
			await ConnectionManager.recieved_packet
		_push_actions(_opp_private)
		_got_opp_private = false
		await get_tree().create_timer(0.2).timeout
	print("Finish stack resolution")
	stack_resolved.emit()
	$VBoxContainer/HBoxContainer2/RightUI/RichTextLabel.text = ""


func _no_activation() -> void:
	ConnectionManager.send(ConnectionManager.GameMessage.ACTIONS, {actions = [], private = true})


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
			seed(card.id.hash() + (0 if _stack.is_empty() else _stack[-1].id.hash()))
			sigil._stack.clear()
			callback.call(sigil)
			_push_actions(sigil._stack)
			out.append_array(out)
	return out


func _public_activation_order() -> Array[Card]:
	var out: Array[BoardManager.Slot] = board_manager.get_active_row(is_active)
	out.append_array(board_manager.get_active_row(not is_active))
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
