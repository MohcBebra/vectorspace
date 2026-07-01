extends Control

@onready var main: Control = $Main
@onready var lobby: Control = $Lobby
@onready var start_btn: Button = $Lobby/Center/VBoxContainer/StartButton
@onready var players_list: VBoxContainer = $Lobby/Center/ScrollContainer/PlayerList
@onready var nickname: LineEdit = $Main/Center/Nickname

var host_player: String

func _ready() -> void:
	MultiplayerSteam.player_joined.connect(on_player_joined)
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)

func _create_button_pressed() -> void:
	if nickname.text.is_empty(): return
	MultiplayerSteam.player_info.set("name", nickname.text)
	MultiplayerSteam.host_lobby()
	main.hide()
	lobby.show()

func _join_button_pressed() -> void:
	pass

func _start_button_pressed() -> void:
	pass

func _leave_button_pressed() -> void:
	lobby.hide()
	start_btn.hide()
	main.show()

func on_player_joined(steam_id: int, pl_info: Dictionary):
	print("PLAYER JOINED: ", steam_id, " ", pl_info)
	main.hide()
	lobby.show()

func on_peer_connected(peer_id: int):
	print("PEER CONNECTED: ", peer_id)
	var label = Label.new()
	label.name = str(peer_id)
	label.text = Steam.getPlayerNickname(Steam.getSteamID())
	players_list.add_child(label)

func on_peer_disconnected(peer_id: int):
	print("PEER DISCONNECTED: ", peer_id)
	players_list.remove_child(players_list.get_node(str(Steam.getSteamID())))
