extends CanvasLayer

func fade_into_black() -> void:
	%Anim.play("to_black")
	await %Anim.animation_finished

func fade_from_black() -> void:
	%Anim.play("from_black")
