extends Wave

func _on_spawn_timer_timeout() -> void:
	var instance: Bullet = bullet_scene.instantiate()
	add_child(instance)
	instance.global_position = Vector2(get_viewport_rect().size.x/2, 0)
	instance.rotate(PI)
