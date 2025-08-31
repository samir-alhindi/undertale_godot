class_name Enemy extends Node

@export_category("Enemy data")
@export var enemy_name: String = "Enemy name here"
@export var HP: int = 100
@export var sprite: Texture
@export var sprite_scale: float = 1.0
@export var acts: Array[String]
@export var bullet_waves: Array[PackedScene]
@export_multiline var encounter_text := "* name here drew new!"


func do_act_get_text(act_name: String) -> String:
	return ""

func get_idle_text() -> String:
	return ""

func get_monster_text() -> String:
	return ""
