extends Node

func do_act_get_text(act: Act) -> String:
	if act.name == "Check":
		return act.text
	elif act.name == "Beg":
		Global.heal_player.emit(10)
		return act.text
	
	return "Error"

func get_idle_text() -> String:
	return ""

func get_monster_text() -> String:
	return ""
