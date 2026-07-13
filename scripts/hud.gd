extends CanvasLayer

@onready var line_edit_x: LineEdit = $MarginContainer/Bottom/pos_x/LineEditX
@onready var line_edit_y: LineEdit = $MarginContainer/Bottom/pos_y/LineEditY
@onready var label_projectiles_count: Label = $MarginContainer/Bottom/launch/projectiles_count
@onready var hp_bar: HPBar = %HPBar

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
	$MarginContainer.grab_focus()
	player = get_parent()
	main_scene = get_parent().get_parent()
	projectiles_count = player.max_projectiles

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
	## пропускаем только если в окружности
	var x_pos: float = 0
	var y_pos: float = 0
	var error = expression.parse(x_text_dedent, inputs_variables.keys())
	if error != OK: return
	if not expression.has_execute_failed():
		var exec = expression.execute(inputs_variables.values(), self)
		if ((exec is not float) and (exec is not int)) or (exec == null): return
		x_pos = exec
	error = expression.parse(y_text_dedent, inputs_variables.keys())
	if error != OK: return
	if not expression.has_execute_failed():
		var exec = expression.execute(inputs_variables.values(), self)
		if ((exec is not float) and (exec is not int)) or (exec == null): return
		y_pos = exec
	var result: float = Vector2.ZERO.distance_to(Vector2(x_pos, y_pos))
	if result > 1:
		return
	
	Global.spawn_projectile.rpc(x_text_dedent, y_text_dedent, player.spawn_radius, player.get_path())
	
	projectiles_count -= 1

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
	line_edit_text_control(line_edit_x, new_text)
func _on_line_edit_y_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		return
	line_edit_text_control(line_edit_y, new_text)

func increase_projectile_count(amount: int):
	if projectiles_count + amount >= player.max_projectiles:
		projectiles_count = player.max_projectiles
	else:
		projectiles_count += amount

func set_health(health: int, max_health: int):
	hp_bar.max_value = max_health
	hp_bar.value = health

func set_label_proj_count(new_count):
	projectiles_count = new_count
	label_projectiles_count.text = str(projectiles_count)
