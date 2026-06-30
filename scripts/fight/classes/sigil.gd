@abstract class_name Sigil

## Most method in this class create a token that is appended to the internal stack of this sigil.
## They are promises that this will happens

## The fight manager that is current "active".
## Just a reference to the fightmanager so you can access like the board, hand,
## play card and general utils offer by the fight manager.
var fight_manager: FightManager
## The card this sigil is attached to.
var attached_card: Card

var _stack: Array[Action]

# --- All the sigil event hook ---

@warning_ignore_start("unused_parameter")  # keep the signature clean while avoiding warning


## Called after [AddCardAction] is resolved. This mean that the card have already been added.
## [param card] can be null if the card added is private to the opponent
func on_card_add(card: Card) -> void:
	return


## Called after [PlayCardAction] is resolved. This mean that the card is already on board.
func on_card_played(
	card: Card, pos: Vector2i, placer_type: Action.IDType, placer_id: String
) -> void:
	return


## Called after [EndTurnAction] is resolved. This however
func on_turn_end() -> void:
	return


## Called when [CombatAction] resolved bef fore all the strike and attack are put onto the stack. For
## those that change how the card attack use [method on_attack].
func on_combat_start() -> void:
	return


## Called after [CardAttackAction] resolved. This will dictate what [CardStrikeAction] the card will
## do whatever strike group this function spit out. If by the end of all the strike sigils activation
## the card still have no [StrikeGroup] the default center strike is issued.
func on_card_attacked(card: Card) -> Array[CardAttackAction.StrikeGroup]:
	return []


func on_card_damaged(
	victim: Card, amount: int, attacker_type: Action.IDType, attacker_id: String
) -> void:
	return


func on_card_perished(card: Card) -> void:
	return


## Called after [TipScaleAction] resolved. This mean that the scale is already tipped.
func on_scale_tipped(amount: int) -> void:
	pass


## Called whenever an action is added to the stack. If this return a non empty array the top action
## of the stack is replace with the returned value.
## Unless it is absolutely necessary don't use this hook.
func replace_action(type: Action.Type, action: Action) -> Array[Action]:
	return []


@warning_ignore_restore("unused_parameter")

# --- Helper function and utils ---


func add_action(action: Action) -> void:
	_stack.push_front(action)


## Play [param card_id] at [param pos] by [param placer_id] which is a [param placer_type]
func play_card(
	card_id: String, pos: Vector2i, placer_type: Action.IDType, placer_id: String
) -> void:
	add_action(PlayCardAction.new(card_id, pos, placer_type, placer_id))


## Create a new token with [param card_data] by [param source_id]. Return the new token's id[br]
func create_token(card_data: Dictionary, source_id: String) -> String:
	var token_id := Global.gen_id()
	add_action(CreateTokenAction.new(card_data, token_id, source_id))
	return token_id


## Create a new token with [param card_data] by [param source_id] amd play it at [param pos].
## Return the new token's id.[br]
func create_and_play_token(card_data: Dictionary, pos: Vector2i, source_id: String) -> String:
	var id := create_token(card_data, source_id)
	play_card(id, pos, Action.IDType.CARD, source_id)
	return id


func kill_card(card_id: String) -> void:
	add_action(KillCardAction.new(card_id))


func damage_card(
	victim_id: String, amount: int, attacker_type: Action.IDType, attacker_id: String
) -> void:
	add_action(DamageCard.new(victim_id, amount, attacker_type, attacker_id))


func draw_card(deck: DrawDeckAction.Deck, player_id := "") -> void:
	if player_id.is_empty():
		player_id = Global.uuid
	add_action(DrawDeckAction.new(deck, player_id))


## Add a new card to the hand with [param card_data ] by [param source_id] amd play it at [param pos].
## Return the new token's id.[br]
func add_card(card_data: Dictionary, player_id := "") -> String:
	if player_id.is_empty():
		player_id = Global.uuid
	var card_id := Global.gen_id()
	add_action(AddCardAction.new(card_data, card_id, player_id))
	return card_id


func oppose_pos(pos: Vector2i) -> Vector2i:
	return BoardManager.oppose_pos(pos)


func get_pos(card_id: String) -> Vector2i:
	return fight_manager.board_manager.get_card_pos(card_id)
