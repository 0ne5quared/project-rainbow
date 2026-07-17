extends Sigil


func on_turn_end(player_id: String) -> void:
	if player_id != controller_id():
		return
	var neighbour := get_neighbour_slot()
	push_warning(neighbour)
	var slot := neighbour[int(not flip_h)]
	if slot == null or slot.card != null:
		flip_h = true
	slot = neighbour[int(not flip_h)]
	if slot == null or slot.card != null:
		return
	move_card(attached_card.id, slot.pos)
