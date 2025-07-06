extends Node2D

const mode := Soul.Mode.BLUE
const PIPES := preload("uid://dj1ajm43ujw1g")

func _ready() -> void:
	_on_spawn_timer_timeout()

func _on_spawn_timer_timeout() -> void:
	var pipes := PIPES.instantiate()
	add_child(pipes)
	pipes.global_position = Vector2(1161.0, 578.0)
	
func _on_end_timer_timeout() -> void:
	Global.wave_done.emit(self, get_tree().get_first_node_in_group("soul"))
