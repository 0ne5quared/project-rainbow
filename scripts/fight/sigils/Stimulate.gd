extends Sigil

func power_cost() -> int:
	return get_config("stimulate_cost", 3)


func is_active_sigil() -> bool:
	return true


func is_disable() -> bool:
	return fight_manager.my_data.energy <= 0


func on_sigil_activate(
	card: Card, sigil: Sigil, _source_id: String, _source_type: Action.IDType
) -> void:
	if card != attached_card or sigil != self:
		return
	attached_card.card_data.attack += 1;
	
