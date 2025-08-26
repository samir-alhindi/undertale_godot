class_name Bullet extends Area2D

@export var speed := 500
@export var damage_amount := 5 
@export var freed_on_hit := true
@export var shootable := false

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	self.queue_free()
