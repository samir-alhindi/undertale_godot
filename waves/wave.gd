class_name Wave extends Node2D

@export var mode: Soul.Mode = Soul.Mode.RED
@export var box_size: Vector2 = Vector2(0.5, 1.0)
@export var box_size_change_time := 0.3
@export var bullet_scene: PackedScene

func _on_end_timer_timeout() -> void:
	Global.wave_done.emit(self, get_tree().get_first_node_in_group("soul"))

func _on_spawn_timer_timeout() -> void:
	pass # Replace with function body.
