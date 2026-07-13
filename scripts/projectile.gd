extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $SpawnVFX/Sprite2D
@onready var attatck_component: AttackComponent = $AttatckComponent

@export var x_position_equation: String
@export var y_position_equation: String
@export var speed_multiplier_in_spawn := 2.0

@export var player_path: NodePath
var player: Player
var spawn_radius: float

var expression_x = Expression.new()
var expression_y = Expression.new()

var t: float = 0
var inputs_variables: Dictionary = {
	't': t,
}

var proj_is_ready := false
var clamping := false
var max_speed: float
@export var inside_spawn := true

func _ready() -> void:
	player = get_parent().get_node(player_path)
	player.projectiles.append(self)
	player.add_exeption_to_attack_component(self)
	max_speed = player.max_projectile_speed
	
	attatck_component.exeptions.append(player)
	
	$SpawnVFX.material.set_shader_parameter("spawn_time", $SpawnTimer.wait_time)
	$SpawnVFX.material.set_shader_parameter("time", $SpawnTimer.time_left)

var last_pos := Vector2.ZERO

func _physics_process(delta: float) -> void:
	if velocity != Vector2.ZERO: ## первый кадр любая скорость
		clamping = true
	
	expression_x.parse(x_position_equation, inputs_variables.keys())
	expression_y.parse(y_position_equation, inputs_variables.keys())
	var x_pos: float = 0
	var y_pos: float = 0
	if not expression_x.has_execute_failed():
		x_pos = expression_x.execute(inputs_variables.values(), self)
	if not expression_y.has_execute_failed():
		y_pos = expression_y.execute(inputs_variables.values(), self)
	
	var pos := Vector2(x_pos * spawn_radius, y_pos * spawn_radius)
	if not clamping: ## ограничиваем если выходит за границы в первый кадр
		if pos.distance_to(Vector2.ZERO) > spawn_radius:
			var angle = Vector2.ZERO.angle_to(pos)
			pos.x = cos(angle) * spawn_radius
			pos.y = sin(angle) * spawn_radius
	
	var pre_velocity: Vector2 = (pos - last_pos) / delta
	if clamping: ## ограничиваем скорость
		if pos.distance_to(Vector2.ZERO) < spawn_radius + 0.1:
			inside_spawn = true
		else:
			inside_spawn = false
			sprite_2d.material.set_shader_parameter("color", Color(0.561, 0.612, 0.894))
		
		if check_all_pr_is_inside_spawn():
			pre_velocity = pre_velocity.clampf(-max_speed * speed_multiplier_in_spawn, max_speed * speed_multiplier_in_spawn)
		else:
			pre_velocity = pre_velocity.clampf(-max_speed, max_speed)
	velocity = pre_velocity 
	last_pos = pos
	
	move_and_slide()

	if check_all_pr_is_inside_spawn():
		t += delta * 2
	else:
		t += delta
	inputs_variables.set('t', t)

func set_position_equations(x_pos_equation: String, y_pos_equation: String, spawn_rad: float) -> void:
	x_position_equation = x_pos_equation
	y_position_equation = y_pos_equation
	spawn_radius = spawn_rad

func set_player(player_p: NodePath):
	player_path = player_p

func check_all_pr_is_inside_spawn() -> bool:
	if not is_instance_valid(player): return false
	
	var projectiles: Array[CharacterBody2D] = player.projectiles
	if projectiles.size() < player.max_projectiles:
		return false
	
	var all_pr_inside_spawn := true
	for pr: CharacterBody2D in projectiles:
		if not pr.inside_spawn:
			all_pr_inside_spawn = false
	
	if all_pr_inside_spawn:
		sprite_2d.material.set_shader_parameter("color", Color.GREEN_YELLOW)
		for pr: CharacterBody2D in projectiles:
			if pr != self:
				attatck_component.exeptions.append(pr)
	else:
		sprite_2d.material.set_shader_parameter("color", Color(0.561, 0.612, 0.894))
		for pr: CharacterBody2D in projectiles:
			if pr != self:
				attatck_component.exeptions.erase(pr)
	
	return all_pr_inside_spawn

func die():
	if is_multiplayer_authority(): ## только у хоста
		Global.remove_projectile.rpc(get_path())

func initialize_die():
	if not is_instance_valid(player): return
	#print("proj_is_dead")
	player.projectiles.erase(self)
	player.projectile_dead()

func _on_timer_timeout() -> void:
	proj_is_ready = true
	$AttatckComponent/CollisionShape2D.disabled = false
	$HitboxComponent/CollisionShape2D.disabled = false

func _process(_delta: float) -> void:
	if not $SpawnTimer.is_stopped():
		$SpawnVFX.material.set_shader_parameter("time", $SpawnTimer.time_left)
