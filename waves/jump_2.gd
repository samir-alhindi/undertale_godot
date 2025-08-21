extends Node2D

const bullet_scene := preload("uid://cw2m41h21w5dk")
var mode: Soul.Mode = Soul.Mode.BLUE

func _on_start_timer_timeout() -> void:
	_on_spawn_timer_timeout()
	$SpawnTimer.start()

func _on_spawn_timer_timeout() -> void:
	var bullet1 := bullet_scene.instantiate()
	add_child(bullet1)
	bullet1.global_position = Vector2(950, 730)
	
	var bullet2 := bullet_scene.instantiate()
	add_child(bullet2)
	bullet2.global_position = Vector2(350, 730)
	bullet2.get_child(0).dir = Vector2.RIGHT


func _on_end_timer_timeout() -> void:
	Global.wave_done.emit(self, get_tree().get_first_node_in_group("soul"))
