@abstract class_name Sigil

## The fight manager that is current "active".
## Just a reference to the fightmanager so you can access like the board, hand,
## play card and general utils offer by the fight manager.
var fight_manager: FightManager
## The card this sigil is attached to.
var card: Card


## Called after a PLAY_CARD action is resolved. This mean that the card is already on
## board. If you instead want to override the card placement use [method stack_added]
## instead
func on_played(
	_card: Card, _pos: Vector2i, _placer_type: FightManager.ID, _placer_id: int
) -> Array[Dictionary]:
	return []


## Called whenever an action is added to the stack. If this return a non empty array
## the top action of the stack is replace with the returned value
func stack_added(_action: Dictionary) -> Array[FightManager.Action]:
	return []
