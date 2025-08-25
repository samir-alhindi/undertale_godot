extends RichTextLabel

signal play_monster_speak_anim

# Undertale text speed is 30 characters per second:
var text_speed := 1.0 / 30.0 

func display(new_text: String):
	text = new_text
	visible_characters = 0
	$TextTimer.start()
	play_monster_speak_anim.emit()

func _on_text_timer_timeout() -> void:
	%SpeakSound.play()
	visible_characters += 1
	if visible_ratio < 1.0:
		%TextTimer.start(text_speed)

func stop_talking() -> void:
	text = ""
	visible_ratio = 1.0
	%TextTimer.stop()
