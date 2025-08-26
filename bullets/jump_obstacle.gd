class_name JumpObstacle extends Area2D

var dir := Vector2.LEFT
var speed := 300
var damage_amount := 5 
var freed_on_hit := true

static var battle_box_bottom: int = 751

func _physics_process(delta: float) -> void:
	global_position += delta * speed * dir
