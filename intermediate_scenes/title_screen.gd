extends CanvasLayer

@export var battles: Dictionary[PackedScene, String]

func _ready() -> void:
	var index := 0
	for battle: PackedScene in battles.keys():
		var button := Button.new()
		button.add_theme_font_size_override("font_size", 50)
		button.text = battles[battle]
		%BattlesContainer.add_child(button)
		button.pressed.connect(
			go_to_battle.bind(battle)
		)
	%BattlesContainer.get_child(0).grab_focus()

func go_to_battle(battle: PackedScene) -> void:
	get_tree().change_scene_to_packed(battle)
