class_name TextBox extends RichTextLabel

signal finished_scrolling

var normal_speed := 0.05
## Slow down dialouge if '.' or '\n' char is encountered:
var slow_speed := 0.5

func scroll(new_text: String) -> void:
	await clear_text()
	text = Util.shake(new_text, 5, 5)
	visible_characters = 0
	%Timer.start()
	%TextSound.play()

func set_new_text(new_text: String) -> void:
	await clear_text()
	visible_ratio = 1.0
	text = Util.shake(new_text)

func _on_timer_timeout() -> void:
	if visible_ratio == 1.0 or len(get_parsed_text()) == 0:
		%Timer.stop()
		finished_scrolling.emit()
		return
	%TextSound.play()
	%Timer.wait_time = slow_speed if next_char() in [".", "\n"] else normal_speed
	visible_characters += 1

func next_char() -> String:
	var t := get_parsed_text()
	return "" if visible_characters+1 == len(t) else t[visible_characters+1]

func clear_text() -> void:
	%Timer.stop()
	visible_ratio = 0.0
