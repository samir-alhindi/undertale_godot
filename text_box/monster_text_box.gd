class_name MonsterTextBox extends RichTextLabel

signal play_monster_speak_anim

var scroll_speed := 0.05

func speak(new_text: String) -> void:
	await stop_talking()
	text = new_text
	visible_characters = 0
	%Timer.start()
	%TextSound.play()
	play_monster_speak_anim.emit()

func _on_timer_timeout() -> void:
	if visible_ratio == 1.0:
		%Timer.stop()
		return
	visible_characters += 1
	%TextSound.play()
	%Timer.wait_time = scroll_speed

func stop_talking() -> void:
	%Timer.stop()
	visible_ratio = 0.0
