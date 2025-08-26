extends Bullet

func _physics_process(delta: float) -> void:
	position += delta * speed * global_transform.y
