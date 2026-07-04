extends Node

signal player_joined(id: int, pl_info: Dictionary)

const LOBBY_TYPE := Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
const MAX_MEMBERS := 4

var peer: SteamMultiplayerPeer

var players: Dictionary[int, Dictionary]
var player_info: Dictionary = {"name": "Name"}

func _ready() -> void:
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(on_lobby_created)
	Steam.lobby_joined.connect(on_lobby_joined)
	Steam.join_requested.connect(on_join_requested)
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func host_lobby():
	Steam.createLobby(LOBBY_TYPE, MAX_MEMBERS)

## called after creating lobby locally
func on_lobby_created(lobby_connect: int, _lobby_id: int):
	if lobby_connect == Steam.RESULT_OK:
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		player_info.set("name", Steam.getPersonaName())
		players[Steam.getSteamID()] = player_info
		player_joined.emit(Steam.getSteamID(), player_info)

## called when joining a lobby (after creating a lobby or joining a friend)
## происходит только у создающего или подключаещегося один раз, для остальных ничего
func on_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int):
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		if Steam.getLobbyOwner(lobby_id) == Steam.getSteamID():
			return
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_client(Steam.getLobbyOwner(lobby_id))
		multiplayer.multiplayer_peer = peer
		player_info.set("name", Steam.getPersonaName())
		players[Steam.getSteamID()] = player_info
		player_joined.emit(Steam.getSteamID(), player_info)

## called when attemping to join from the Steam interface
func on_join_requested(lobby_id: int, _steam_id: int):
	Steam.joinLobby(lobby_id)

func on_peer_connected(peer_id: int):
	var new_pl_info: Dictionary = {"name": Steam.getPlayerNickname(peer_id)}
	players[peer_id] = new_pl_info
	player_joined.emit(peer_id, new_pl_info)

func on_peer_disconnected(peer_id: int):
	players.erase(peer_id)
