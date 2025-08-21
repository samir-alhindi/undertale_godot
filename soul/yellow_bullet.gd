extends Area2D

func _physics_process(delta: float) -> void:
	global_position += delta * 400 * Vector2.UP

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("shootable_bullet"):
		Global.bullet_destroyed.emit(area.global_position)
		area.queue_free()
		self.queue_free()
