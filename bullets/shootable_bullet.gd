extends Area2D

var speed := 500
var damage_amount := 5 
var freed_on_hit := true

func _physics_process(delta: float) -> void:
	global_position += delta * speed * global_transform.y


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
