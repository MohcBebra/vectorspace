extends Area2D
class_name AttackComponent

@export var damage: int = 1
@export var attack_self := false
@export var exeptions: Array[Node2D]

func _ready() -> void:
	exeptions.append(get_parent())

func _on_area_entered(area: HitboxComponent) -> void:
	for ex: Node2D in exeptions:
		if ex == area.get_parent():
			return
	
	var attack = Attack.new()
	attack.damage = damage
	area.damage(attack)
	if attack_self:
		if get_parent().has_node("HealthComponent"):
			get_parent().get_node("HealthComponent").damage(attack)
