extends Enemy

var just_peeked := false
var spared := false

func do_act_get_text(act: String) -> String:
	if act == "Check":
		return "* Present - ATK 9 DEF 8\n* A square box\n* Loves surprises"
	elif act == "Gift":
		Global.heal_player.emit(10)
		return "* You begged for an early christmas gift...\n* Present gave you a cookie\n* (10 HP recovered!)"
	elif act == "Peek":
		just_peeked = true
		return "* You tried to look inside Present...\n* It got very angry!"
	elif act == "Wait":
		Global.change_mercy.emit(100)
		spared = true
		return "* You waited patiently...\n* Present seemed pleased!"
	return "Error"

func get_idle_text() -> String:
	if spared:
		return "* Present is very proud of you"
	return "* Present is giving you a funny look"

func get_monster_text() -> String:
	if just_peeked:
		just_peeked = false
		return Util.shake("WAIT UNTIL CHRISTMAS!")
	elif spared:
		return Util.wave("You're going on the good list!")
	return Util.wave("No peeking till christmas!")
