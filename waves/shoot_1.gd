extends Wave

func _ready() -> void:
	self.global_position = Vector2(650, 0)
	%Instructions.global_position = get_viewport_rect().size / 2 + Vector2(-%Instructions.size.x, %Instructions.size.y) / 2
	%Instructions.text = Util.shake(%Instructions.text)

func _on_end_timer_timeout() -> void:
	Global.wave_done.emit(self, get_tree().get_first_node_in_group("soul"))

func _on_spawn_timer_timeout() -> void:
	var bullet := bullet_scene.instantiate()
	add_child(bullet)
	%PathFollow2D.progress_ratio = randf()
	bullet.global_transform = %PathFollow2D.global_transform
	bullet.speed = 250
