extends Area2D
class_name AttackComponent

@export var damage: int = 1

func _on_area_entered(area: HitboxComponent) -> void:
	if area.get_parent() == get_parent():
		return
	
	var attack = Attack.new()
	attack.damage = damage
	area.damage(attack)
