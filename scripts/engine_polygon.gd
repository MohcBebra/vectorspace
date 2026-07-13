extends Polygon2D

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

@export var angle := 0.0:
	set = set_angle
@export var rotation_speed := 3.0

var player: Player
var tween: Tween

func _ready() -> void:
	player = get_parent()

func _process(_delta: float) -> void:
	gpu_particles_2d.position = offset
	if player.engine_is_running:
		gpu_particles_2d.emitting = true
	else:
		gpu_particles_2d.emitting = false
	if is_equal_approx(rotation, PI):
		rotation = -PI + 0.001 
		get_tween().tween_property(self, "rotation", -angle, abs(-angle - rotation) / rotation_speed)
	elif is_equal_approx(rotation, -PI):
		rotation = PI - 0.001 
		get_tween().tween_property(self, "rotation", -angle, abs(-angle - rotation) / rotation_speed)

func set_angle(new_angle):
	angle = new_angle
	if abs(-angle - rotation) > PI:
		if sign(rotation) >= 0:
			get_tween().tween_property(self, "rotation", PI, abs(PI - rotation) / rotation_speed)
		else:
			get_tween().tween_property(self, "rotation", -PI, abs(-PI - rotation) / rotation_speed)
	else:
		get_tween().tween_property(self, "rotation", -angle, abs(-angle - rotation) / rotation_speed)

func get_tween() -> Tween:
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	return tween
