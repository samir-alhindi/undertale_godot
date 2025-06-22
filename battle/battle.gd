extends Node

var is_selecting := false
var is_attacking := false

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	%AttackButton.grab_focus()
	%AttackBar.hide()
	%AttackLine.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and is_selecting:
		%AttackBar.show()
		%Text.text = ""
		%AttackLine.show()
		%Anim.play("attack")
		is_selecting = false
		is_attacking = true
	elif event.is_action_pressed("ui_accept") and is_attacking:
		is_attacking = false
		%AttackLine.hide()
		var distance_from_centre: int = round(abs(%AttackLine.global_position.x - %AttackBar.global_position.x))
		var damage: int = round((575  - distance_from_centre) / 10)
		%Damage.text = str(damage)
		%Damage.show()
		%Anim.stop()
		%LabelTimer.start()

func _on_attack_button_pressed() -> void:
	%ButtonsContainer.hide()
	%Text.text = "* Godot"
	is_selecting = true

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
		%AttackLine.hide()
		%Damage.text = "miss"
		%Damage.show()
		%LabelTimer.start()

func _on_damage_label_timer_timeout() -> void:
	%Damage.hide()
	%AttackBar.hide()
	start_hell()

func start_hell() -> void:
	%ButtonsContainer.hide()
	%Anim.play("start_hell")
	var soul := Soul.new_soul(Soul.Mode.RED)
	add_child(soul)
	soul.global_position = %AttackBar.global_position
