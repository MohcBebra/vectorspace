extends Node2D

const PLAYER = preload("res://scenes/player.tscn")
@onready var sprite_2d_bg: Sprite2D = $Sprite2D_bg
@onready var polygon_grid: PolygonGrid = $PolygonGrid

@export var h_split := 8
@export var v_split := 8

var pl1_position: Vector2 = Vector2(-200, 0)
var pl2_position: Vector2 = Vector2(200, 0)

var spawned_player: int = 0
var spawned_projectiles: int = 0

var players: Array[Player]

func _ready() -> void:
	Global.main_scene = self
	Global.player_loaded.rpc_id(1)

func start_game():
	print_debug("All players loaded!")
	for peer in multiplayer.get_peers():
		spawn_player(peer)
	spawn_player(1)
	triangulate_map()

func spawn_player(peer_id: int):
	var new_player := PLAYER.instantiate() as Player
	new_player.name = str(peer_id)
	initialize_player(new_player)
	await get_tree().physics_frame
	add_child(new_player, true)

func initialize_player(player: Player):
	if spawned_player == 0:
		player.position = pl1_position
	else:
		player.position = pl2_position
	players.append(player)

func triangulate_map():
	var map_size: Vector2 = sprite_2d_bg.scale
	var map_vertices: PackedVector2Array
	map_vertices.append(Vector2(-map_size / 2))
	map_vertices.append(Vector2(map_size.x / 2, -map_size.y / 2))
	map_vertices.append(Vector2(map_size / 2))
	map_vertices.append(Vector2(-map_size.x / 2, map_size.y / 2))
	
	var result_vertices: PackedVector2Array = map_vertices
	result_vertices.append(pl1_position)
	result_vertices.append(pl2_position)
	result_vertices.append(Vector2.ZERO)
	#result_vertices.append(Vector2(0., -map_size.y / 2))
	#result_vertices.append(Vector2(0., map_size.y / 2))
	#result_vertices.append(Vector2(-map_size.x / 2, 0.))
	#result_vertices.append(Vector2(map_size.x / 2, 0.))
	
	var h_split_points: PackedVector2Array
	var h_dist = map_size.x / h_split
	for i: int in h_split + 1:
		var new_point: Vector2 = Vector2(-map_size.x / 2 + h_dist * i, -map_size.y / 2)
		h_split_points.append(new_point)
		new_point = Vector2(-map_size.x / 2 + h_dist * i, map_size.y / 2)
		h_split_points.append(new_point)
	
	var v_split_points: PackedVector2Array
	var v_dist = map_size.y / v_split
	for i: int in v_split + 1:
		var new_point: Vector2 = Vector2(-map_size.x / 2, -map_size.y / 2 + v_dist * i)
		v_split_points.append(new_point)
		new_point = Vector2(map_size.x / 2, -map_size.y / 2 + v_dist * i)
		v_split_points.append(new_point)
	
	
	
	h_split_points.append_array(v_split_points)
	for p: Vector2 in h_split_points:
		if not result_vertices.has(p):
			result_vertices.append(p)
	
	var insides_points: PackedVector2Array
	for i: int in h_split:
		if i != 0:
			for j: int in v_split:
				if j != 0:
					var new_point: Vector2 = Vector2(-map_size.x / 2 + h_dist * i, -map_size.y / 2 + v_dist * j)
					insides_points.append(new_point)
	
	for p: Vector2 in insides_points:
		if not result_vertices.has(p):
			if randi_range(0, 2) == 0:
				p += Vector2((randf()*2-1) * h_dist / 4, (randf()*2-1) * v_dist / 4)
				p = Vector2(clampf(p.x, -map_size.x / 2, map_size.x / 2), clampf(p.y, -map_size.y / 2, map_size.y / 2))
			result_vertices.append(p)
	
	
	polygon_grid.polygon = result_vertices
	polygon_grid.triangulate()
	polygon_grid.set_point_found(pl1_position)
	polygon_grid.set_point_found(pl2_position)

func get_spawned_projectiles() -> int:
	return spawned_projectiles

func increase_spawned_projectiles():
	spawned_projectiles += 1

func erase_player(player: Player):
	players.erase(player)
