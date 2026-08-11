extends Sigil


func static_ability(is_reset: bool) -> void:
	var neighbour_slot := get_neighbour_slot(false)
	for slot in neighbour_slot:
		if is_reset:
			if slot.attack_buf >= 1:
				slot.attack_buf -= 1
		else:
			slot.attack_buf += 1
