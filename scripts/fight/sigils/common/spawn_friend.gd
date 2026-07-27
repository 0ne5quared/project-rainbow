@abstract class_name SpawnFriendSigil
extends Sigil

## Return the data that is used to spawn the friend.
@abstract func friend_data() -> Ruleset.CardData


func on_card_played(
	played_card: Card, pos: Vector2i, _placer_type: Action.IDType, _placer_id: String
) -> void:
	if played_card != attached_card:
		return

	var f_data := friend_data()
	create_and_play_token(f_data, pos + Vector2i.LEFT, attached_card.id)
	create_and_play_token(f_data, pos + Vector2i.RIGHT, attached_card.id)
