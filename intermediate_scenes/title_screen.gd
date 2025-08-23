extends CanvasLayer

@export var enemies: Array[PackedScene]

func _ready() -> void:
	for scene: PackedScene in enemies:
		var instance: Node = scene.instantiate()
		assert(instance is Enemy, "Only put Enemy scenes in the enemies array")
		var enemy := instance as Enemy
		var button := Button.new()
		button.add_theme_font_size_override("font_size", 50)
		button.text = enemy.enemy_name
		%BattlesContainer.add_child(button)
		button.pressed.connect(
			go_to_battle.bind(enemy)
			)
	%BattlesContainer.get_child(0).grab_focus()

func go_to_battle(enemy: Enemy) -> void:
	Battle.enemy = enemy
	get_tree().change_scene_to_file("uid://45qmet5s5aix")
