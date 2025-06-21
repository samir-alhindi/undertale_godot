extends Node

var is_selecting := false 

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	%AttackButton.grab_focus()
	%AttackBar.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and is_selecting:
		%AttackBar.show()
		%Text.text = ""

func _on_attack_button_pressed() -> void:
	%ButtonsContainer.hide()
	%Text.text = "* Godot"
	is_selecting = true
