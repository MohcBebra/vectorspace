extends Control

@onready var main: Control = $Main
@onready var lobby: Control = $Lobby
@onready var start_btn: Button = $Lobby/Center/VBoxContainer/StartButton
@onready var players_list: VBoxContainer = %PlayerList

var host_player: String

func _ready() -> void:
	MultiplayerSteam.player_joined.connect(on_player_joined)
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	Steam.avatar_loaded.connect(on_avatar_loaded)

func _create_button_pressed() -> void:
	MultiplayerSteam.host_lobby()
	main.hide()
	lobby.show()

func _join_button_pressed() -> void:
	pass

func _start_button_pressed() -> void:
	Global.load_game.rpc("res://scenes/multiplayer_main_scene.tscn")
	$/root/MultiplayerMainScene.start_game()

func _leave_button_pressed() -> void:
	lobby.hide()
	start_btn.hide()
	main.show()
	for c: HBoxContainer in players_list.get_children():
		c.queue_free()

func on_player_joined(steam_id: int, pl_info: Dictionary):
	print("PLAYER JOINED: ", steam_id, " ", pl_info)
	add_to_player_list(steam_id, pl_info)
	main.hide()
	lobby.show()

func on_peer_connected(peer_id: int):
	print("PEER CONNECTED: ", peer_id)
	print(MultiplayerSteam.players)
	add_to_player_list(peer_id, MultiplayerSteam.players.get(peer_id))
	start_btn.show()

func add_to_player_list(steam_id: int, pl_info: Dictionary):
	var label := Label.new()
	label["theme_override_font_sizes/font_size"] = 7
	label.text = pl_info.get("name")
	
	Steam.getPlayerAvatar(Steam.AVATAR_LARGE, steam_id)
	var texture_rect := TextureRect.new()
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.custom_minimum_size = Vector2(32, 32)
	
	var h_container: HBoxContainer = HBoxContainer.new()
	h_container.name = str(steam_id)
	h_container.add_child(texture_rect)
	h_container.add_child(label)
	
	players_list.add_child(h_container)

func on_peer_disconnected(peer_id: int):
	print("PEER DISCONNECTED: ", peer_id)
	players_list.remove_child(players_list.get_node(str(peer_id)))

func on_avatar_loaded(steam_id: int, avatar_size: int, avatar_buffer: PackedByteArray):
	var avatar_image: Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)
	var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)
	var texture_rect: TextureRect = players_list.get_node(str(steam_id)).get_child(0)
	texture_rect.texture = avatar_texture
