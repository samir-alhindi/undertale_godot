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

func tornado(text: String, radius: float = 10.0, freq: float = 3.0) -> String:
	return "[tornado radius=%f freq=%f]%s[/tornado]" % [radius, freq, text]

func shake(text: String, rate: float = 20.0, level: float = 5.0) -> String:
	return "[shake rate=%f level=%f]%s[/shake]" % [rate, level, text]

func wave(text: String, amp: float = 100.0, freq = 10.0) -> String:
	return "[wave amp%f freq=%f]%s[/wave]" % [amp, freq, text]
