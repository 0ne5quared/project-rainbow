extends PanelContainer

var code: String
var players: Dictionary[String, ConnectionManager.Player]
var host_uuid: String

var player_listing := preload("res://prefab/player_listing/player_listing.tscn")


func _ready() -> void:
	ConnectionManager.room_created.connect(_on_room_created)
	ConnectionManager.room_joined.connect(_on_room_joined)
	ConnectionManager.player_joined.connect(_on_player_joined)
	ConnectionManager.player_left.connect(_on_player_left)
	ConnectionManager.room_closed.connect(_on_room_closed)


func add_player(player: ConnectionManager.Player) -> void:
	if Global.is_host:
		players[player.uuid] = player
	var listing: PlayerListing = player_listing.instantiate()
	listing.player_name = player.name
	listing.pfp = player.pfp
	listing.is_host = player.uuid == host_uuid
	listing.name = player.uuid
	%PlayerList.add_child(listing)
	if player.uuid == host_uuid:
		%PlayerList.move_child(listing, 1)  # not zero because of the heading


func _on_room_created(room_code: String) -> void:
	%Lobby.code = room_code
	Global.is_host = true
	host_uuid = Global.uuid
	add_player(ConnectionManager.Player.new(Global.player_name, Global.pfp, Global.uuid))


func _on_room_joined(players_: Array[ConnectionManager.Player], host_uuid_: String) -> void:
	host_uuid = host_uuid_
	for player in players_:
		add_player(player)
	add_player(ConnectionManager.Player.new(Global.player_name, Global.pfp, Global.uuid))


func _on_room_closed() -> void:
	for n in %PlayerList.get_children():
		%PlayerList.remove_child(n)
		n.queue_free()
	%Lobby.visible = false


func _on_player_joined(player: ConnectionManager.Player) -> void:
	add_player(player)


func _on_player_left(uuid: String) -> void:
	if Global.is_host:
		players.erase(uuid)
	for listing in %PlayerList.get_children():
		if listing.name == uuid:
			%PlayerList.remove_child(listing)
			listing.queue_free()


func _on_room_code_pressed() -> void:
	if %RoomCode.text != code:
		%RoomCode.text = code
	else:
		%RoomCode.text = "VIEW CODE"


func _on_copy_code_btn_pressed() -> void:
	DisplayServer.clipboard_set(code)


func _on_end_btn_pressed() -> void:
	visible = false
	if ConnectionManager.is_host:
		ConnectionManager.close_room()
		_on_room_closed()
	else:
		ConnectionManager.leave_room()
		_on_room_closed()
