class_name TextBox extends RichTextLabel

signal finished_scrolling

var normal_speed := 0.05
## Slow down dialouge if '.' or '\n' char is encountered:
var slow_speed := 0.5

func scroll(new_text: String) -> void:
	await clear_text()
	text = new_text
	visible_characters = 0
	%Timer.start()
	%TextSound.play()

func set_new_text(new_text: String) -> void:
	await clear_text()
	visible_ratio = 1.0
	text = new_text

func _on_timer_timeout() -> void:
	if visible_ratio == 1.0 or len(text) == 0:
		%Timer.stop()
		finished_scrolling.emit()
		return
	%TextSound.play()
	%Timer.wait_time = slow_speed if text[visible_characters] in [".", "\n"] else normal_speed
	visible_characters += 1

func clear_text() -> void:
	%Timer.stop()
	visible_ratio = 0.0
