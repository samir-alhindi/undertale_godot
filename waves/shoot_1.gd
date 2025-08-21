extends Node2D

var mode: Soul.Mode = Soul.Mode.YELLOW

const SHOOTABLE_BULLET := preload("uid://cy48yl222etyf")

func _ready() -> void:
	self.global_position = Vector2(650, 0)
	%Instructions.global_position = Vector2(425, 650)

func _on_end_timer_timeout() -> void:
	Global.wave_done.emit(self, get_tree().get_first_node_in_group("soul"))

func _on_spawn_timer_timeout() -> void:
	var bullet := SHOOTABLE_BULLET.instantiate()
	add_child(bullet)
	%PathFollow2D.progress_ratio = randf()
	bullet.global_transform = %PathFollow2D.global_transform
	bullet.speed = 250
