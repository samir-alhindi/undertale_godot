extends Button

func _ready() -> void:
	focus_entered.connect(func():
		modulate.a = 1
		%MoveSound.play()
		var tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(self, "scale", Vector2(1.5,1.5), 0.2)
		tween.tween_property(self, "scale", Vector2(1,1), 0.1)
	)
