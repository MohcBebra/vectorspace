extends Area2D
class_name AttackComponent

@export var damage: int = 1
@export var attack_self := false

func _on_area_entered(area: HitboxComponent) -> void:
	if not get_parent().is_multiplayer_authority(): return
	if area.get_parent() == get_parent():
		return
	
	var attack = Attack.new()
	attack.damage = damage
	area.damage(attack)
	if attack_self:
		if get_parent().has_node("HealthComponent"):
			get_parent().get_node("HealthComponent").damage(attack)
