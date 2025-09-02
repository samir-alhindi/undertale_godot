extends CanvasLayer

@export var enemies: Array[PackedScene]

func _ready() -> void:
	Fade.fade_from_black()
	%Title.text = Util.shake(%Title.text)
	for scene: PackedScene in enemies:
		var instance: Node = scene.instantiate()
		assert(instance is Enemy, "Only put Enemy scenes in the enemies array")
		var enemy := instance as Enemy
		var button := Button.new()
		button.add_theme_font_size_override("font_size", 50)
		button.text = enemy.enemy_name
		%BattlesContainer.add_child(button)
		button.pivot_offset = button.size / 2
		button.focus_entered.connect(
			_on_focus_entered.bind(button)
		)
		button.focus_exited.connect(
			_on_focus_exited.bind(button)
		)
		button.pressed.connect(
			go_to_battle.bind(enemy)
			)
	
	%BattlesContainer.get_child(0).grab_focus()

func _on_focus_entered(button: Button) -> void:
	button.modulate.a = 1
	%MoveSound.play()
	var tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(button, "scale", Vector2(1.5,1.5), 0.2)
	tween.tween_property(button, "scale", Vector2(1,1), 0.1)

func _on_focus_exited(button: Button) -> void:
	button.modulate.a = 0.5

func go_to_battle(enemy: Enemy) -> void:
	%Song.stop()
	%Encounter1.play()
	for button: Button in %BattlesContainer.get_children():
		button.modulate.a = 1.0 if button.text == enemy.enemy_name else 0.0
	await get_tree().create_timer(0.25).timeout
	%Encounter2.play()
	await Fade.fade_into_black()
	Battle.enemy = enemy
	get_tree().change_scene_to_file("uid://45qmet5s5aix")
