extends CharacterBody2D

@export var player_path: NodePath
var player: CharacterBody2D

@export var x_position_equation: String
@export var y_position_equation: String
var spawn_radius: float
var proj_is_ready := false
var clamping := false

var expression_x = Expression.new()
var expression_y = Expression.new()

var t: float = 0
var inputs_variables: Dictionary = {
	't': t,
}

func _ready() -> void:
	player = get_parent().get_node(player_path)
	if (x_position_equation.is_empty() and y_position_equation.is_empty()):
		print_debug(self, " position is (0, 0)")
	
	$SpawnVFX.material.set_shader_parameter("spawn_time", $SpawnTimer.wait_time)
	$SpawnVFX.material.set_shader_parameter("time", $SpawnTimer.time_left)

var last_pos := Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player): return
	if velocity != Vector2.ZERO: ## первый кадр любая скорость
		clamping = true
	
	expression_x.parse(x_position_equation, inputs_variables.keys())
	expression_y.parse(y_position_equation, inputs_variables.keys())
	var x_pos: float = 0
	var y_pos: float = 0
	if not expression_x.has_execute_failed():
		var exec = expression_x.execute(inputs_variables.values(), self)
		#if exec is not float: return
		x_pos = exec
	if not expression_y.has_execute_failed():
		var exec = expression_y.execute(inputs_variables.values(), self)
		#if exec is not float: return
		y_pos = exec
	
	var pos := Vector2(x_pos * spawn_radius, y_pos * spawn_radius)
	if not clamping: ## ограничиваем если выходит за границы в первый кадр
		if pos.distance_to(Vector2.ZERO) > spawn_radius:
			var angle = Vector2.ZERO.angle_to(pos)
			pos.x = cos(angle) * spawn_radius
			pos.y = sin(angle) * spawn_radius
	
	var pre_velocity: Vector2 = (pos - last_pos) / delta
	if clamping: ## ограничиваем скорость
		pre_velocity = pre_velocity.clampf(-player.get_max_projectile_speed(), player.get_max_projectile_speed())
	velocity = pre_velocity
	#print(velocity, position)
	#print(position)
	last_pos = pos
	
	move_and_slide()
	
	t += delta
	inputs_variables.set('t', t)

func set_position_equations(x_pos_equation: String, y_pos_equation: String, spawn_rad: float) -> void:
	x_position_equation = x_pos_equation
	y_position_equation = y_pos_equation
	spawn_radius = spawn_rad

func set_player(player_p: NodePath):
	player_path = player_p

func die():
	if is_multiplayer_authority(): ## только у хоста
		Global.remove_projectile.rpc(get_path())

func initialize_die():
	print("proj_is_dead")
	player.projectile_dead()

func _on_timer_timeout() -> void:
	proj_is_ready = true
	$AttatckComponent/CollisionShape2D.disabled = false
	$HitboxComponent/CollisionShape2D.disabled = false

func _process(_delta: float) -> void:
	if not $SpawnTimer.is_stopped():
		$SpawnVFX.material.set_shader_parameter("time", $SpawnTimer.time_left)
