extends HBoxContainer

@onready var line_edit_x: LineEdit = $VBoxContainer/pos_x/LineEditX
@onready var line_edit_y: LineEdit = $VBoxContainer/pos_y/LineEditY
@onready var label_projectiles_count: Label = $VBoxContainer/launch/projectiles_count
@onready var projectiles_sprites: VBoxContainer = $PanelContainer/HBoxContainer/ProjectilesSprites
@onready var delete_projectiles: VBoxContainer = $PanelContainer/HBoxContainer/DeleteProjectiles


var player: Player
var main_scene: Node2D

@export var projectiles_count: int:
	set = set_label_proj_count

var line_edit_x_is_wrong: bool = false
var line_edit_y_is_wrong: bool = false

var inputs_variables: Dictionary = {
	't': 0.0,
}
var expression = Expression.new()

func _ready() -> void:
	player = get_parent().get_parent().get_parent()
	main_scene = player.get_parent()
	projectiles_count = player.max_projectiles
	player.projectiles_appended.connect(on_player_proj_appended)
	player.projectiles_erased.connect(on_player_proj_erased)

func _on_button_button_up() -> void: ## запуск снаряда
	if (line_edit_x_is_wrong or line_edit_y_is_wrong) or (projectiles_count < 1): ## если формулы впордяке и есть проджектайлы
		return
	if line_edit_x.text.is_empty() and line_edit_y.text.is_empty():
		return
	
	## подгатавливаем текст
	var x_text_dedent = line_edit_x.text.dedent()
	var y_text_dedent = line_edit_y.text.dedent()
	x_text_dedent= x_text_dedent.replace(' ', '')
	y_text_dedent = y_text_dedent.replace(' ', '')
	if x_text_dedent.is_empty():
		x_text_dedent = '0.0'
	if y_text_dedent.is_empty():
		y_text_dedent = '0.0'
	
	## выполняем expressions
	var x_pos: float = 0
	var y_pos: float = 0
	
	var error = expression.parse(x_text_dedent, inputs_variables.keys())
	if error != OK: return
	var exec = expression.execute(inputs_variables.values(), self)
	if expression.has_execute_failed(): return
	if ((exec is not float) and (exec is not int)) or (exec == null): return
	x_pos = exec
	
	error = expression.parse(y_text_dedent, inputs_variables.keys())
	if error != OK: return
	exec = expression.execute(inputs_variables.values(), self)
	if expression.has_execute_failed(): return
	if ((exec is not float) and (exec is not int)) or (exec == null): return
	y_pos = exec
	
	## пропускаем только если в окружности
	var result: float = Vector2.ZERO.distance_to(Vector2(x_pos, y_pos))
	if result > 1:
		return
	
	Global.spawn_projectile.rpc(x_text_dedent, y_text_dedent, player.spawn_radius, player.get_path())
	
	projectiles_count -= 1

func on_player_proj_appended(_projs: Array[CharacterBody2D], proj: CharacterBody2D):
	var canvas_group: CanvasGroup = proj.get_node("SpawnVFX").duplicate()
	canvas_group.get_child(0).centered = false
	var texture_rect := TextureRect.new()
	texture_rect.name = proj.name
	texture_rect.custom_minimum_size.x = canvas_group.get_child(0).scale.x
	texture_rect.custom_minimum_size.y = canvas_group.get_child(0).scale.y
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	texture_rect.add_child(canvas_group)
	projectiles_sprites.add_child(texture_rect, true)
	
	var texture_button := TextureButton.new()
	texture_button.name = proj.name
	texture_button.stretch_mode = TextureButton.STRETCH_SCALE
	texture_button.texture_normal = CanvasTexture.new()
	texture_button.custom_minimum_size = Vector2(canvas_group.get_child(0).scale.x, canvas_group.get_child(0).scale.y)
	texture_button.use_parent_material = true
	delete_projectiles.add_child(texture_button, true)
	texture_button.button_down.connect(on_button_delete_proj_down.bind(proj))
	texture_button.mouse_entered.connect(on_button_delete_mouse_entered.bind(proj))
	texture_button.mouse_exited.connect(on_button_delete_mouse_exited.bind(proj))

func on_player_proj_erased(_projs: Array[CharacterBody2D], proj: CharacterBody2D):
	projectiles_sprites.get_node(str(proj.name)).queue_free()
	delete_projectiles.get_node(str(proj.name)).queue_free()

func on_button_delete_proj_down(proj: CharacterBody2D):
	proj.die()

func on_button_delete_mouse_entered(proj: CharacterBody2D):
	proj.get_node("SpawnVFX").get_child(0).material.set_shader_parameter("alpha", 0.5)
func on_button_delete_mouse_exited(proj: CharacterBody2D):
	proj.get_node("SpawnVFX").get_child(0).material.set_shader_parameter("alpha", 1.0)

#proj.get_node("SpawnVFX").get_child(0).material.set_shader_parameter("color", Color.RED)

var text_corrects: Dictionary[String, bool] = {
	"trigonom": true,
	"operators": true,
	"brackets": true
}

func line_edit_text_control(line_edit: LineEdit, text: String) -> void:
	var regex = RegEx.new()
	
	## ЗАМЕНЫ
	## ограничиваем допустимые символы
	regex.compile("(?=[a-zA-Zа-яА-Я_\\[\\]{};:\'\",<>\\?`~!@#$%&=\\|])[^sincotabexp]")
	if regex.search(text) != null:
		line_edit.text = text.replace(regex.search(text).get_string(), "")
		line_edit.caret_column = line_edit.text.length()
	
	## заменяет несколько точек вместе на одну
	regex.compile("\\.{2,}")
	for regexmatch: RegExMatch in regex.search_all(text):
		line_edit.text = text.replace(regexmatch.get_string(), ".")
		line_edit.caret_column = line_edit.text.length()
	## удаляет точку в числе если точка уже есть до этого
	regex.compile("\\.\\d+\\.")
	for regexmatch: RegExMatch in regex.search_all(text):
		line_edit.text = text.replace(regexmatch.get_string(), regexmatch.get_string().left(-1))
		line_edit.caret_column = line_edit.text.length()
	
	## ПРОВЕРКИ
	## проверка на тригонометрические функции
	regex.compile("\\b(?!(?:sin|cos|tan|abs|exp)\\b)[^t \\(\\)\\d\\+\\*\\/\\.-]+")
	if regex.search(text) == null: text_corrects.set("trigonom", true)
	else: text_corrects.set("trigonom", false)
	
	## считаем кол-во открытых и закрытых скобок
	if text.count('(') != text.count(')'):
		text_corrects.set("brackets", false)
	else:
		text_corrects.set("brackets", true)
		regex.compile("[\\w\\)] +[\\w\\(]") ## проверяем нет ли переменных между которыми нет операторов
		if regex.search(text) == null: text_corrects.set("operators", true)
		else: text_corrects.set("operators", false)
	
	if text_corrects.find_key(false) == null:
		set_line_edit_is_wrong(line_edit, false)
	else:
		set_line_edit_is_wrong(line_edit, true)

func set_line_edit_is_wrong(line_edit: LineEdit, wrong: bool):
	if line_edit == line_edit_x: line_edit_x_is_wrong = wrong
	else: line_edit_y_is_wrong = wrong
	if wrong: line_edit["theme_override_colors/font_color"] = Color.LIGHT_CORAL
	else: line_edit["theme_override_colors/font_color"] = Color.WHITE

func _on_line_edit_x_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		return
	#line_edit_text_control(line_edit_x, new_text)
func _on_line_edit_y_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		return
	#line_edit_text_control(line_edit_y, new_text)

func set_label_proj_count(new_count):
	projectiles_count = new_count
	label_projectiles_count.text = str(projectiles_count)
