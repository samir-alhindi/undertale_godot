class_name JumpObstacle extends Bullet

@export var dir := Vector2.LEFT

static var battle_box_bottom: int = 751

func _physics_process(delta: float) -> void:
	global_position += delta * speed * dir
