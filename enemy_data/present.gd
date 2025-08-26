extends Enemy

func do_act_get_text(act: String) -> String:
	if act == "Check":
		return "* Present - ATK 9 DEF 8\n* A square box\n* Loves surprises"
	elif act == "Beg":
		Global.heal_player.emit(10)
		return "* You begged Present for mercy...\n* Present gave you a cookie* (10 HP recovered !)"
	
	return "Error"

func get_idle_text() -> String:
	return ""

func get_monster_text() -> String:
	return "Get ready!"
