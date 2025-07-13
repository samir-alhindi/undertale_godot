extends Node2D

const bullet_scene := preload("uid://cw2m41h21w5dk")
var mode: Soul.Mode = Soul.Mode.BLUE

func _ready() -> void:
	_on_spawn_timer_timeout()

func _on_spawn_timer_timeout() -> void:
	var bullet := bullet_scene.instantiate()
	add_child(bullet)
	bullet.global_position = Vector2(986, 730)

func _on_end_timer_timeout() -> void:
	Global.wave_done.emit(self, get_tree().get_first_node_in_group("soul"))
