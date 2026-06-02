extends PanelContainer


func _ready() -> void:
	%VersionLb.text = Global.VERSION
	Global.ruleset_changed.connect(_on_ruleset_changed)


func _on_ruleset_changed(ruleset: Dictionary) -> void:
	%RulesetLb.text = ruleset.ruleset


func _on_host_btn_pressed() -> void:
	Global.player_name = %HostPlayerName.text
	await ConnectionManager.create_room()
	%Lobby.visible = true


func _on_join_btn_pressed() -> void:
	Global.player_name = %JoinPlayerName.text
	ConnectionManager.join_room(%JoinRoomCode.text as String)
	%Lobby.visible = true


func _on_quit_btn_pressed() -> void:
	get_tree().quit()
