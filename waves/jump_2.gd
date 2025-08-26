extends Wave

func _ready() -> void:
	_on_spawn_timer_timeout()

func _on_spawn_timer_timeout() -> void:
	var bullet1: JumpObstacle = bullet_scene.instantiate()
	add_child(bullet1)
	bullet1.global_position = Vector2(0, JumpObstacle.battle_box_bottom)
	bullet1.dir = Vector2.RIGHT
	
	var bullet2: JumpObstacle = bullet_scene.instantiate()
	add_child(bullet2)
	bullet2.global_position = Vector2(get_viewport_rect().size.x, JumpObstacle.battle_box_bottom)
	bullet2.dir = Vector2.LEFT

func _on_end_timer_timeout() -> void:
	Global.wave_done.emit(self, get_tree().get_first_node_in_group("soul"))
