extends Node

@onready var Projectile: PackedScene = preload("res://scenes/projectile.tscn")

var main_scene: Node2D
var players_loaded := 0

@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)

@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if not multiplayer.is_server():
		print("piska")
	else:
		players_loaded += 1
		if players_loaded >= MultiplayerSteam.players.size():
			main_scene.start_game()

@rpc("any_peer", "call_local")
func spawn_projectile(x_text: String, y_text: String, player_spawn_radius: float, player_path: NodePath):
	if not multiplayer.is_server(): return
	var player: CharacterBody2D = main_scene.get_node(player_path)
	var projectile: CharacterBody2D = Projectile.instantiate()
	projectile.name += str(main_scene.get_spawned_projectiles())
	if main_scene.has_node(str(projectile.name)): return ## если уже существует то не создаем
	
	#projectile.set_multiplayer_authority(peer_id) ## !!!
	projectile.global_position = player.global_position
	projectile.set_player(player_path)
	projectile.set_position_equations(x_text, y_text, player_spawn_radius)
	main_scene.add_child(projectile, true)
	
	main_scene.increase_spawned_projectiles()

@rpc("any_peer", "call_local")
func remove_projectile(proj_path: NodePath):
	if not multiplayer.is_server(): return
	main_scene.get_node(proj_path).queue_free()

@rpc("any_peer", "call_local")
func remove_player(player_path: NodePath):
	if not multiplayer.is_server(): return
	main_scene.get_node(player_path).queue_free()
