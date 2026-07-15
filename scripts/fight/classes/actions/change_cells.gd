class_name ChangeCellsAction
extends Action

var amount: int
var player_id: String


static func action_type() -> Type:
	return Action.Type.CHANGE_CELLS


func _init(a: int, pid: String) -> void:
	amount = a
	player_id = pid


func resolve(fight_manager: FightManager) -> void:
	var data := fight_manager.get_data(player_id)
	data.cells += amount
	if amount < 0:
		data.energy += abs(amount)
	await fight_manager._activate_sigils(
		func(sigil: Sigil) -> void: sigil.on_cell_changed(amount, player_id)
	)


func as_dict() -> Dictionary:
	return {type = action_type(), amount = amount, player_id = player_id}


static func from_dict(dict: Dictionary) -> Action:
	return ChangeCellsAction.new(dict.amount as int, dict.player_id as String)
