extends RichTextLabel

# Undertale text speed is 30 characters per second:
var text_speed := 1.0 / 40.0 
# Slow down dialouge if '.' char is encountered:
var dot_speed := 0.75

var i := -1
func display(new_text: String):
	text = new_text
	visible_characters = 0
	i = -1
	%TextTimer.start()
	%TextSound.play()

func _on_text_timer_timeout() -> void:
	%TextSound.play()
	visible_characters += 1
	i += 1
	if visible_ratio < 1.0 and text[i] != ".":
		%TextTimer.start(text_speed)
	elif visible_ratio < 1.0 and text[i] == ".":
		%TextTimer.start(dot_speed)

func clear_text() -> void:
	%TextTimer.stop()
	text = ""
