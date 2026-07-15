extends CanvasLayer

@onready var ui: MarginContainer = $UI
@onready var projectiles_control: HBoxContainer = $UI/ProjectilesControl
@onready var hp_bar: HPBar = %HPBar
@onready var pause_menu: PanelContainer = $PauseMenu

var player: Player

func _ready() -> void:
	ui.grab_focus()
	player = get_parent()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if pause_menu.visible == false:
			pause_menu.show()
		else:
			pause_menu.hide()
			$PauseMenu/Center.show()
			$PauseMenu/Settings.hide()

func set_health(health: int, max_health: int):
	hp_bar.max_value = max_health
	hp_bar.value = health

func increase_projectile_count(amount: int):
	if projectiles_control.projectiles_count + amount >= player.max_projectiles:
		projectiles_control.projectiles_count = player.max_projectiles
	else:
		projectiles_control.projectiles_count += amount
