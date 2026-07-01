extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

var players: Dictionary = {}
var player_info: Dictionary = {"name": "Name"}
var players_loaded: int = 0

func _ready() -> void:
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_server_connected)
	multiplayer.connection_failed.connect(_fail_connected)
	multiplayer.server_disconnected.connect(_server_disconnected)

func create_server() -> bool:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(8888, 2)
	if err != OK:
		return false
	multiplayer.multiplayer_peer = peer
	players[1] = player_info
	player_connected.emit(1, player_info)
	return true

func join_server(ip_address: String, port: int) -> bool:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip_address, port)
	if err != OK:
		return false
	multiplayer.multiplayer_peer = peer
	return true

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

func _peer_connected(_id):
	_register_player.rpc_id(_id, player_info)

func _peer_disconnected(_id):
	players.erase(_id)
	player_disconnected.emit(_id)

func _server_connected():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _fail_connected():
	remove_multiplayer_peer()

func _server_disconnected():
	remove_multiplayer_peer()
	server_disconnected.emit()

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()

@rpc("call_local", "reliable")
func load_game(scene_path):
	get_tree().change_scene_to_file(scene_path)

@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/MultiplayerMainScene.start_game()
			players_loaded = 0
