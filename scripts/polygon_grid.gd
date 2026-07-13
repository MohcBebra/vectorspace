extends Area2D
class_name PolygonGrid

@export var polygon: PackedVector2Array
@export var current_shard: CollisionPolygon2D

var shards_angles: Array[Array]
var found_angles: Array[Array]
var shards_centers: Array[Vector2]
var labels_offset := 0.6

func triangulate():
	var points: PackedVector2Array = polygon
	var triangles: PackedInt32Array = Geometry2D.triangulate_delaunay(points)
	
	if not triangles:
		print_debug("triangles error")
		return
	
	for i: int in floori(triangles.size() / 3.):
		var shard_pool: PackedVector2Array
		for n in range(3):
			shard_pool.append(points[triangles[i * 3 + n]])
		
		## создание осколков
		var coll_shard := CollisionPolygon2D.new() 
		coll_shard.polygon = shard_pool
		var shard := Polygon2D.new()
		shard.polygon = shard_pool
		shard.color = Color(randf(), randf(), randf(), 0.0)
		var outline := Line2D.new()
		outline.points = shard_pool
		outline.closed = true
		outline.width = 0.5
		outline.default_color.a = 0.05
		
		coll_shard.add_child(shard, true)
		coll_shard.add_child(outline, true)
		add_child(coll_shard, true)
		
		## высчитывание углов
		var angles: Array = calculate_angles(shard_pool)
		shards_angles.append(angles)
		var found: Array[bool]
		for j: int in angles.size():
			found.append(false)
		found_angles.append(found)
		
		## вычисляем центр
		var center := Vector2.ZERO
		for p: Vector2 in shard_pool:
			center.x += p.x
			center.y += p.y
		center /= 3.
		shards_centers.append(center)
		
		## лейблы углов
		var label_node := Control.new()
		label_node.name = "Labels"
		for j: int in shard_pool.size():
			var label := Label.new()
			label.text = str(angles[j]) + "°"
			label["theme_override_font_sizes/font_size"] = 7
			label.label_settings = LabelSettings.new()
			label.label_settings.font_size = 7
			label.label_settings.outline_size = 2
			label.label_settings.outline_color = Color.BLACK
			var dir: Vector2 = center.direction_to(shard_pool[j])
			label.position = center + dir * center.distance_to(shard_pool[j]) * labels_offset
			label.position -= label.size / (4 / labels_offset)
			label.visible = false
			label_node.add_child(label)
		label_node.modulate = Color(1.0, 1.0, 1.0, 0.1)
		label_node.z_index = 3
		coll_shard.add_child(label_node, true)

func calculate_angles(points: Array[Vector2]) -> Array:
	var angles: Array[int]
	var ind_of_incorrect: int = 0
	for j: int in points.size():
		var first_angle: float
		if j + 1 < points.size(): first_angle = points[j].angle_to_point(points[j+1])
		else: first_angle = points[j].angle_to_point(points[0])
		var second_angle: float
		if j + 2 < points.size(): second_angle = points[j].angle_to_point(points[j+2])
		elif j + 2 == points.size(): second_angle = points[j].angle_to_point(points[0])
		else: second_angle = points[j].angle_to_point(points[1])
		
		if sign(first_angle) + sign(second_angle) != 0:
			var result_angle: float = first_angle - second_angle
			result_angle = abs(result_angle)
			result_angle = rad_to_deg(result_angle)
			result_angle = round(result_angle) #snapped(result_angle, 0.1)
			angles.append(result_angle)
		else:
			ind_of_incorrect = j
	if angles.size() < 3:
		angles.insert(ind_of_incorrect, (180. - angles[0] - angles[1]))
	return angles

func set_angle_found(shape_idx: int, angle_idx: int):
	found_angles[shape_idx][angle_idx] = true
	get_child(shape_idx).get_child(2).get_child(angle_idx).visible = true

func set_point_found(point: Vector2):
	for i: int in shards_angles.size():
		var idx_of_point: int = get_child(i).polygon.find(point)
		if idx_of_point != -1:
			set_angle_found(i, idx_of_point)

func _on_mouse_shape_entered(shape_idx: int) -> void:
	var col_shard: CollisionPolygon2D = get_child(shape_idx)
	var shard: Polygon2D = col_shard.get_child(0)
	shard.color += Color(0.2, 0.2, 0.2, 0.1)
	current_shard = col_shard
	#print(shards_angles[shape_idx], shards_centers[shape_idx])
	var label_node: Control = col_shard.get_child(2)
	label_node.modulate.a = 1.0

func _on_mouse_shape_exited(shape_idx: int) -> void:
	var col_shard: CollisionPolygon2D = get_child(shape_idx)
	var shard: Polygon2D = col_shard.get_child(0)
	shard.color -= Color(0.2, 0.2, 0.2, 0.1)
	var label_node: Control = col_shard.get_child(2)
	label_node.modulate.a = 0.1
