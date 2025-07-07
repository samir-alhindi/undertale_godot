extends RichTextLabel

func display(new_text: String):
	text = new_text
	visible_ratio = 0.0
	$TextTimer.start()

func _on_text_timer_timeout() -> void:
	visible_ratio += 0.025
	if visible_ratio < 1.0:
		$TextTimer.start()
