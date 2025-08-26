extends Wave

func _ready() -> void:
	# in the middle of the battle box:
	global_position = Vector2(950, 570)

func _physics_process(delta: float) -> void:
	rotation_degrees += delta * 100

func _on_spawn_timer_timeout() -> void:
	for spawner: Node2D in %Spawners.get_children():
		var instance := bullet_scene.instantiate()
		Global.add_bullet.emit(instance, spawner.global_transform)


func _on_end_timer_timeout() -> void:
	Global.wave_done.emit(self, get_tree().get_first_node_in_group("soul"))
