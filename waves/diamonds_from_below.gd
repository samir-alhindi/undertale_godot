extends Node2D

const LINEAR_BULLET := preload("uid://cd8wtan5lb4ls")

func  _ready() -> void:
	# Right Below the battle box:
	global_position = Vector2(656, 790)

func _on_spawn_timer_timeout() -> void:
	var bullet := LINEAR_BULLET.instantiate()
	add_child(bullet)
	%PathFollow2D.progress_ratio = randf()
	bullet.global_transform = %PathFollow2D.global_transform

func _on_end_timer_timeout() -> void:
	Global.wave_done.emit(self, get_tree().get_first_node_in_group("soul"))
