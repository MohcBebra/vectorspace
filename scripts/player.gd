extends CharacterBody2D
class_name Player

@onready var camera: Camera2D = $Camera2D
@onready var hud: CanvasLayer = $HUD
@onready var label_name: Label = $LabelName
@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite_2d_shader: ShaderMaterial = $Sprite2D.material
@onready var engine_polygon: Polygon2D = $EnginePolygon

@export var spawn_radius := 50.0
@export var max_projectiles: int = 2
@export var max_projectile_speed: float = 70.0
@export var camera_speed: int = 3
@export var engine_is_running := false;

var start_mouse_position := Vector2.ZERO

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
		return
	
	camera.make_current()
	hud.show()
	label_name.text = MultiplayerSteam.player_info.name
	$ProjectileAreaSprite.scale = Vector2(spawn_radius * 2, spawn_radius * 2)
	health_changed(health_component.health, health_component.max_health)

func _physics_process(_delta: float) -> void:
	camera_control()
	engine_control()
	
	move_and_slide()

func camera_control(): ## управление камерой
	if Input.is_action_pressed("middle_mouse"): ## управление колесиком
		if Input.is_action_just_pressed("middle_mouse"):
			start_mouse_position = get_local_mouse_position()
			camera.position_smoothing_enabled = false
		var difference = get_local_mouse_position() - start_mouse_position
		camera.position = camera.position - difference
	elif Input.is_action_just_released("middle_mouse"):
		camera.position_smoothing_enabled = true
	
	if not hud.get_node("MarginContainer").has_focus(): ## нельзя перемещаться wasd если редактируются лайн едиты
		return
	if camera.position_smoothing_enabled: ## управление wasd
		var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
		if direction:
			camera.position += direction * camera_speed

func engine_control(): ## управление двигателем
	var engine_dir = Vector2.RIGHT.rotated(engine_polygon.rotation)
	if engine_is_running:
		velocity += -engine_dir / 32

func health_changed(health: int, max_health: int):
	hud.set_health(health, max_health)

func die():
	if is_multiplayer_authority():
		Global.remove_player.rpc(get_path())

func projectile_dead():
	hud.increase_projectile_count(1)

func get_spawn_radius() -> float:
	return spawn_radius

func get_max_projectiles() -> int:
	return max_projectiles
func get_max_projectile_speed() -> float:
	return max_projectile_speed
