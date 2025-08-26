extends Bullet

func _physics_process(delta: float) -> void:
	var soul := get_tree().get_first_node_in_group("soul")
	if not is_instance_valid(soul): return
	var dir := global_position.direction_to(soul.global_position)
	global_position += delta * dir * speed
