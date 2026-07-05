extends Node2D
class_name HealthComponent

@export var max_health := 1
@export var health: int

func _ready() -> void:
	health = max_health

func damage(attack: Attack):
	health -= attack.damage
	
	if get_parent().has_method("health_changed"):
		get_parent().health_changed(health, max_health)
	
	if health <= 0:
		get_parent().die()
