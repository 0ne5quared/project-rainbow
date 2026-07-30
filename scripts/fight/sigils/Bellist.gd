extends SpawnFriendSigil


func friend_data() -> Ruleset.CardData:
	return Global.get_card_by_name(get_config("chime_card", "Chime") as String)
