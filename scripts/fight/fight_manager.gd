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
signal just_resolved

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

var _opp_private: Array[Array] = []
var _opp_replacement: Array[Array] = []


class Player:
	var lives: int
	var bone: int
	var max_energy: int
	var energy: int


func _start_fight() -> void:
	visible = true
	_draw_card()


func lose_game() -> void:
	%Blocker.visible = true
	%ResultPopup.visible = true
	$Blocker/CenterContainer/Label.visible = false


func _draw_card() -> void:
	#hand_manager.draw_card({name = "Squirrel", attack = 1, health = 2, sigils = ["Airborne"]})
	#hand_manager.draw_card({name = "Squirrel", attack = 1, health = 2, sigils = ["Airborne"]})
	hand_manager.draw_card({name = "Squirrel", attack = 1, health = 2, sigils = ["Airborne"]})
	hand_manager.draw_card({name = "Squirrel", attack = 0, health = 2, sigils = []})
	hand_manager.draw_card({name = "Squirrel", attack = 0, health = 2, sigils = []})
	hand_manager.draw_card({name = "Squirrel", attack = 0, health = 2, sigils = ["Mighty Leap"]})


func _ready() -> void:
	ConnectionManager.recieved_packet.connect(_on_recieved_packet)
	visible = true
	await get_tree().process_frame
	visible = false


func _on_recieved_packet(packet: Dictionary) -> void:
	if (
		packet.type != ConnectionManager.GameMessage.ACTIONS
		and packet.type != ConnectionManager.GameMessage.REPLACEMENTS
	):
		return

	var actions: Array[Action]
	actions.assign(
		(packet.actions as Array[Dictionary]).map(
			func(a: Dictionary) -> Action: return Action.from_dict(a)
		)
	)

	if packet.type == ConnectionManager.GameMessage.ACTIONS:
		if packet.private as bool:
			_opp_private.push_front(actions)
		else:
			_push_actions(actions)
			@warning_ignore("missing_await")
			_resolve_stack()
	else:
		_opp_replacement.append(actions)


func _on_slot_selected(slot: BoardManager.Slot) -> void:
	if state == State.PLAYING_CARD and slot.pos.y == BoardManager.Row.MINE:
		hand_manager.selected.z_index = 0
		var a := PlayCardAction.new(
			hand_manager.selected.id, slot.pos, Action.IDType.PLAYER, Global.uuid
		)
		_add_then_resolve(a)
		a = a.duplicate()
		a.pos = BoardManager.oppose_pos(a.pos)
		ConnectionManager.send(
			ConnectionManager.GameMessage.ACTIONS, {actions = [a.as_dict()], private = false}
		)
		await stack_resolved
		state = State.IDLE


func _on_card_selected(_card: Card) -> void:
	state = State.PLAYING_CARD


func _on_card_unselected(_card: Card) -> void:
	if state == State.PLAYING_CARD:
		state = State.IDLE


func _on_end_pressed() -> void:
	if state != State.IDLE:
		return
	_add_then_resolve(EndTurnAction.new())
	ConnectionManager.send(
		ConnectionManager.GameMessage.ACTIONS,
		{actions = [EndTurnAction.new().as_dict()], private = false}
	)
	await stack_resolved


# --- STACK SHIT ---

## The top of the stack is at 0, this shouldn't be modify directly but instead through
## [method add_to_stack]
var _stack: Array[Action] = []


## Add an action to the stack. This should be use instead of changing [member _stack]
## manually.
func _push_action(action: Action) -> void:
	action.id = get_next_stack_id()
	_stack.push_back(action)


func get_next_stack_id(base: Action = null) -> String:
	if base == null and not _stack.is_empty():
		seed(_stack[-1].id.hash())
	return Global.gen_id()


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
	push_warning("TOP")
	var gotta_end_turn := false
	while _stack.size() > 0:
		var action: Action = _stack.pop_back()
		just_resolved.emit()
		var replacement := await _get_replacement(action)
		if not replacement.is_empty():
			push_warning(replacement.map(func(a: Action) -> String: return a.fmt()))
			_stack.append_array(replacement)
			continue

		@warning_ignore("static_called_on_instance")
		if action.action_type() == Action.Type.END_TURN:
			gotta_end_turn = true
		$VBoxContainer/HBoxContainer2/RightUI/RichTextLabel.text = (
			"TOP: "
			+ action.fmt()
			+ "\n"
			+ "\n".join(_stack.map(func(x: Action) -> String: return x.fmt()))
		)
		# HACK: Super janky fix that slightly delay play card on card that don't exist on the
		# current client and so the other client can resolve it first and transfer the information
		# over
		@warning_ignore("static_called_on_instance")
		if (
			not is_active
			and action.action_type() == Action.Type.PLAY_CARD
			and action.card_id not in card_manager._cards
		):
			await ConnectionManager.recieved_packet
		action.resolve(self)
		while _opp_private.is_empty():
			await ConnectionManager.recieved_packet
		var private_trigger: Array[Action]
		private_trigger.assign(_opp_private.pop_back() as Array)
		_push_actions(private_trigger)
		#await get_tree().create_timer(0.5).timeout
	stack_resolved.emit()
	replacement_history.clear()
	if gotta_end_turn:
		is_active = not is_active
	$VBoxContainer/HBoxContainer2/RightUI/RichTextLabel.text = ""


var replacement_history: Dictionary[Sigil, Array]


func _find_replacement(cards: Array[Card], action: Action) -> Dictionary:
	for card in cards:
		for sigil: Sigil in card.sigils.values():
			if sigil in replacement_history and replacement_history[sigil].has(action.id):
				continue

			@warning_ignore("static_called_on_instance")
			var replacement := sigil.replace_action(action.action_type(), action)

			if not replacement.is_empty():
				return {
					replacement = replacement,
					source = sigil,
				}

	return {
		replacement = [],
		source = null,
	}


# HACK: This code is kinda stinky :(
func _get_replacement(action: Action) -> Array[Action]:
	# Public information has priority.
	var result := _find_replacement(_public_activation_order(), action)
	var replacement: Array[Action] = []
	replacement.assign(result.replacement as Array)
	var replacement_source: Sigil = result.source

	# If no public replacement exists, determine our own private replacement.
	var private_replacement: Array[Action] = []
	if replacement.is_empty():
		result = _find_replacement(_private_activation_order(), action)
		private_replacement.assign(result.replacement as Array)
		replacement_source = result.source

	# Tell the opponent our private replacement.
	ConnectionManager.send(
		ConnectionManager.GameMessage.REPLACEMENTS,
		{actions = private_replacement.map(func(a: Action) -> Dictionary: return a.as_dict())}
	)

	push_warning("Waiting for Replacment")
	# Wait for the opponent's replacement.
	while _opp_replacement.is_empty():
		await ConnectionManager.recieved_packet
	push_warning("Got it")

	var opp_replacement: Array[Action]
	opp_replacement.assign(_opp_replacement.pop_back() as Array)

	if replacement.is_empty():
		var primary := private_replacement if is_active else opp_replacement
		var secondary := opp_replacement if is_active else private_replacement

		if not primary.is_empty():
			replacement = primary
		elif not secondary.is_empty():
			replacement = secondary
		else:
			replacement = []

	# ID fixing
	# The _push_action function also do this ID fixing stuff but I don't like side effect
	if not replacement.is_empty():
		replacement[0].id = action.id
		for i in range(1, replacement.size()):
			replacement[i].id = get_next_stack_id(replacement[i - 1])
		# Now we add to the replacement history this sigil and actions
		if replacement_source != null:
			for a in replacement:
				if replacement_source not in replacement_history:
					replacement_history[replacement_source] = []
				replacement_history[replacement_source].append(a.id)
	return replacement


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
