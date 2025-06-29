extends CanvasLayer

@export var enemies: Array[EnemyStats]

func _ready() -> void:
	var index := 0
	for enemy_stat in enemies:
		var button := Button.new()
		button.add_theme_font_size_override("font_size", 50)
		button.text = enemy_stat.name
		%BattlesContainer.add_child(button)
		button.pressed.connect(
			go_to_battle.bind(enemy_stat)
		)

func go_to_battle(enemy: EnemyStats) -> void:
	Battle.enemy_stat = enemy
	get_tree().change_scene_to_file("uid://45qmet5s5aix")
