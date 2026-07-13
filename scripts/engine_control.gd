extends HBoxContainer

@onready var polar_direction_texture: TextureRect = %PolarDirectionTexture
@onready var line_edit: LineEdit = $VBoxContainer/LineEdit
@onready var polar_direction_texture_shader: ShaderMaterial = %PolarDirectionTexture.material
@onready var button: Button = $VBoxContainer/Button
@onready var energy_bar_shader: ShaderMaterial = $EnergyBar.material
@onready var panel_container: PanelContainer = $PanelContainer

@export var recovery_time := 300
@export var max_energy := 3.0
@export var energy := 0.0:
	set = set_energy

var size_of_polar_texture := Vector2.ZERO
var mouse_inside_texture := false

var player: Player

func _ready() -> void:
	size_of_polar_texture = polar_direction_texture.custom_minimum_size
	player = get_parent().get_parent().get_parent()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("left_click") and mouse_inside_texture:
		var mouse_pos: Vector2 = polar_direction_texture.get_local_mouse_position() / size_of_polar_texture
		mouse_pos = mouse_pos * 2
		mouse_pos.x -= 1
		mouse_pos.y -= 1
		var angle: float = -mouse_pos.angle()
		polar_direction_texture_shader.set_shader_parameter("angle", angle)
		player.get_node("EnginePolygon").angle = angle

func _physics_process(delta: float) -> void:
	if button.button_pressed:
		if energy > 0.0:
			energy -= delta
			button.disabled = true
		else:
			energy = 0.0
			button.button_pressed = false
			_on_button_button_up()
	else:
		if energy < max_energy:
			energy += (delta * max_energy) / recovery_time
		else:
			energy = max_energy
			button.disabled = false

func _on_polar_direction_texture_mouse_entered() -> void:
	mouse_inside_texture = true
func _on_polar_direction_texture_mouse_exited() -> void:
	mouse_inside_texture = false

func set_energy(new_energy):
	energy = new_energy
	energy_bar_shader.set_shader_parameter("value", energy / max_energy)

func _on_button_button_down() -> void:
	if energy > 0.0:
		player.engine_is_running = button.button_pressed
func _on_button_button_up() -> void:
	player.engine_is_running = button.button_pressed
