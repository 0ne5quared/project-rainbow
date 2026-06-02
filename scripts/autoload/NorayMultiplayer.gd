# This Script is completely unused </3
"""
extends Node

const HOST := "134.41.236.54"
const PORT := 8890
var is_host := false
var ext_oid: String


func _ready() -> void:
	await Noray.connect_to_host(HOST, PORT)
	var err := Noray.register_host()
	if err != OK:
		push_error("Can't connect to Noray server")
	await Noray.on_pid
	err = await Noray.register_remote()
	print(err)
	Noray.on_connect_nat.connect(_on_nat_connect)
	Noray.on_connect_relay.connect(_on_relay_connect)


func host() -> Error:
	print("Creating a host")
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(Noray.local_port)
	if err != OK:
		push_error("Can't create host")
		return err
	multiplayer.multiplayer_peer = peer

	while peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
		await get_tree().process_frame
	print("Connected")
	is_host = true
	get_tree().get_multiplayer().server_relay = true
	print("Creating host succeed")
	return OK


func join(oid: String) -> Error:
	ext_oid = oid
	print("Joing host")
	var err := Noray.connect_relay(oid)
	return err


func _on_nat_connect(address: String, port: int) -> void:
	var err := await connect_server(address, port)
	if err != OK:
		push_error("Can't join using NAT as well")


func _on_relay_connect(address: String, port: int) -> void:
	var err := await connect_server(address, port)
	if err != OK and not is_host:
		push_warning("Can't join using relay, trying NAT")
		Noray.connect_nat(ext_oid)


func connect_server(address: String, port: int) -> Error:
	print("Establishing Handshake")
	if is_host:
		print("host handshake with %s:%d" % [address, port])
		@warning_ignore("confusable_local_declaration")
		var peer: ENetMultiplayerPeer = multiplayer.multiplayer_peer
		@warning_ignore("confusable_local_declaration")
		var err := await PacketHandshake.over_enet(peer.host, address, port)
		return err

	var udp := PacketPeerUDP.new()
	var err := udp.bind(Noray.local_port)
	if err != OK:
		push_error("Can't bind to udp")
		return err
	err = udp.set_dest_address(address, port)
	if err != OK:
		push_error("Can't set udp destination")
		return err
	print("Attempting handshake with %s:%d" % [address, port])
	err = await PacketHandshake.over_packet_peer(udp)
	udp.close()

	if err != OK:
		if err == ERR_BUSY:
			push_warning("Partial handshake, continuing...")
		else:
			push_error("Can't establish handshake")
			return err

	var peer := ENetMultiplayerPeer.new()
	err = peer.create_client(address, port, 0, 0, 0, Noray.local_port)
	if err != OK:
		push_error("Can't connect to host")

	multiplayer.multiplayer_peer = peer
	print("Handshake succeed")
	return err
"""
