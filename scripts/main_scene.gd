extends Node2D

var pl1_position: Vector2 = Vector2(-200, 0)
var pl2_position: Vector2 = Vector2(200, 0)

var spawned_player: int = 0
var spawned_projectiles: int = 0

func _ready() -> void:
	Multiplayer.player_loaded.rpc_id(1)
	Global.main_scene = self
	start_game()

func start_game():
	print_debug("All players loaded")
	for peer in multiplayer.get_peers():
		spawn_player(peer)
	spawn_player(1)

func spawn_player(peer_id: int):
	var player: CharacterBody2D = preload("res://scenes/player.tscn").instantiate()
	player.name = str(peer_id)
	if spawned_player == 0:
		player.global_position = pl1_position
	else:
		player.global_position = pl2_position
	
	add_child(player)
	spawned_player += 1

func get_spawned_projectiles() -> int:
	return spawned_projectiles
func increase_spawned_projectiles():
	spawned_projectiles += 1
