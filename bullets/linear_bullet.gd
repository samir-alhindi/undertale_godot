extends Node2D

var dir := Vector2.UP
var speed := 500
var damage_amount := 5 
var freed_on_hit := true

func _physics_process(delta: float) -> void:
	position += delta * speed * global_transform.y
