extends Polygon2D

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

@export var angle := 0.0:
	set = set_angle

var player: Player

func _ready() -> void:
	player = get_parent()

func _process(_delta: float) -> void:
	gpu_particles_2d.position = offset
	if player.engine_is_running:
		gpu_particles_2d.emitting = true
	else:
		gpu_particles_2d.emitting = false

func set_angle(new_angle):
	angle = new_angle
	rotation = -angle
