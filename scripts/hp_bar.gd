#@tool
extends TextureRect
class_name HPBar

@onready var hp_bar_shader: ShaderMaterial = %HPBar.material
@onready var label: Label = $MarginContainer/Label

@export var anim_duration := 0.3
@export var max_value := 100.0:
	set = set_max_value
@export var value := 100.0:
	set = set_value

var tween: Tween
var value_for_text: int = 0

func _ready() -> void:
	value = max_value
	value_for_text = int(value)
	update_texture()

func set_value(new_value: float):
	value = new_value
	if value_for_text == null:
		value_for_text = int(value)
	update_texture()
func set_max_value(max_health: float):
	max_value = max_health
	update_texture()

func update_texture():
	var progress: float = value / max_value
	get_tween().tween_property(hp_bar_shader, "shader_parameter/value", progress, anim_duration)
	tween.parallel().tween_property(self, "value_for_text", value, anim_duration)

func _process(_delta: float) -> void:
	label.text = str(value_for_text)

func get_tween() -> Tween:
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_EXPO)
	return tween
