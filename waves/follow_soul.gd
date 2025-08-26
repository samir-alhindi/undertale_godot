extends Wave

func _ready() -> void:
	var soul := get_tree().get_first_node_in_group("soul")
	var bullet := bullet_scene.instantiate()
	
	add_child(bullet)
	bullet.global_position = soul.global_position + Vector2(0, 100)
	

func _on_timer_timeout() -> void:
	Global.wave_done.emit(self, get_tree().get_first_node_in_group("soul"))
