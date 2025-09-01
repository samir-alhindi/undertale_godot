class_name LinearBullet extends Bullet

func _physics_process(delta: float) -> void:
	position += delta * speed * global_transform.y

func new(rotate_by: float) -> LinearBullet:
	rotate(rotate_by)
	return self
