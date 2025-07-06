extends Node2D

@export var dir := Vector2.UP
@export var speed := 500
var damage_amount := 5 
var freed_on_hit := true

func _physics_process(delta: float) -> void:
	global_position += delta * speed * dir
