class_name BulletAttack extends Node

signal done

func _on_timer_timeout() -> void:
	done.emit()
