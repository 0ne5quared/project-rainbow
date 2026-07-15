class_name EndTurnAction
extends Action

var player_id: String


static func action_type() -> Type:
	return Type.END_TURN


func _init(pid: String = "") -> void:
	player_id = pid


func resolve(fight_manager: FightManager) -> void:
	if player_id.is_empty():
		player_id = fight_manager.active_id()
	fight_manager._push_action(
		StartTurnAction.new(
			fight_manager.opp_id if player_id == Global.uuid else (Global.uuid as String)
		)
	)
	fight_manager._push_action(CombatAction.new())
	await fight_manager._activate_sigils(func(sigil: Sigil) -> void: sigil.on_turn_end(player_id))


func as_dict() -> Dictionary:
	return {type = action_type(), player_id = player_id}


static func from_dict(dict: Dictionary) -> Action:
	return EndTurnAction.new(dict.player_id as String)
