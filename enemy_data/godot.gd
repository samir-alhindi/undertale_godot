extends Enemy

var chat_counter := 0
var just_insulted := false

func do_act_get_text(act: String) -> String:
	if act == "Chat":
		if chat_counter == 0:
			chat_counter += 1
			Global.change_mercy.emit(50)
			return "* You talked to Godot about GDscript...\n* It seemed interested!"
		elif chat_counter == 1:
			chat_counter += 1
			Global.change_mercy.emit(50)
			return "* You listed the data types of GDscript!\n* int, float, String...\n* Godot was very proud of you!"
		else:
			return "* That's enough talking!"
	elif act == "Insult":
		just_insulted = true
		return "* You told Godot that GDscript is slow...\n* Godot got angry!"
	elif act == "Check":
		return "* Godot - ATK 10 DEF 5\n* A Robot programmed in C++\n* He really likes talking"
	else:
		return "There was an error!!!"

func get_idle_text() -> String:
	if chat_counter == 0: return "* Godot is _processing() what just happened"
	if chat_counter == 1: return "* Godot is eager to hear more about GDscript"
	return "* Godot is very happy!"

func get_monster_text() -> String:
	if just_insulted:
		just_insulted = false
		return Util.shake("How dare you insult the best language!")
	if chat_counter == 1: return "Not bad!"
	elif chat_counter == 2: return Util.wave("You are a true Godot enthusiast!")
	return Util.shake("I will crush you to BITs!")
