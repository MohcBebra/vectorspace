extends Node2D

const PLAYER = preload("res://scenes/player.tscn")

var pl1_position: Vector2 = Vector2(-200, 0)
var pl2_position: Vector2 = Vector2(200, 0)

var spawned_player: int = 0
var spawned_projectiles: int = 0

var players: Array[CharacterBody2D]

func _ready() -> void:
	MultiplayerSteam.player_loaded.rpc_id(1)

func start_game():
	print_debug("All players loaded!")
	for peer in multiplayer.get_peers():
		spawn_player(peer)
	spawn_player(1)

func spawn_player(peer_id: int):
	var new_player := PLAYER.instantiate() as CharacterBody2D
	new_player.name = str(peer_id)
	initialize_player(new_player)
	add_child(new_player)

func  initialize_player(player: CharacterBody2D):
	if spawned_player == 0:
		player.position = pl1_position
	else:
		player.position = pl2_position
	players.append(player)
