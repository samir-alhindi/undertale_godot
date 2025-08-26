extends Wave

func _ready() -> void:
	_on_spawn_timer_timeout()

func _on_spawn_timer_timeout() -> void:
	var bullet: JumpObstacle = bullet_scene.instantiate()
	add_child(bullet)
	bullet.global_position = Vector2(DisplayServer.screen_get_size().x, JumpObstacle.battle_box_bottom)

func _on_end_timer_timeout() -> void:
	Global.wave_done.emit(self, get_tree().get_first_node_in_group("soul"))
