extends Wave

func  _ready() -> void:
	# Right Below the battle box:
	global_position = Vector2(656, get_viewport_rect().size.y)

func _on_spawn_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	%PathFollow2D.progress_ratio = randf()
	bullet.global_transform = %PathFollow2D.global_transform
	bullet.rotation_degrees += 180

func _on_end_timer_timeout() -> void:
	Global.wave_done.emit(self, get_tree().get_first_node_in_group("soul"))
