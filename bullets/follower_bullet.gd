extends Area2D

var damage_amount := 2

func _physics_process(delta: float) -> void:
	var soul := get_tree().get_first_node_in_group("soul")
	var dir := global_position.direction_to(soul.global_position)
	global_position += delta * dir * 100
