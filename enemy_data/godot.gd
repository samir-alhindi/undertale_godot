extends Node

var chat_counter := 0
var just_insulted := false

func do_act_get_text(act: Act) -> String:
	if act.name == "Chat":
		if chat_counter == 0:
			chat_counter += 1
			return "* You talked to Godot about GDscript...\n* It seemed intrested !"
		elif chat_counter == 1:
			chat_counter += 1
			return "* You listed the data types of GDscript !\n* int, float, String...\n* Godot was very proud of you !"
		else:
			return "* That's enough talking !"
	elif act.name == "Insult":
		just_insulted = true
		return act.text
	elif act.name == "Check":
		return act.text
	else:
		return "There was an error !!!"

func get_idle_text() -> String:
	if chat_counter == 0: return "* Godot is _processing() what just happened"
	if chat_counter == 1: return "* Godot is very eager to hear more about GDscript !"
	return "* Godot is very happy !"

func get_monster_text() -> String:
	if just_insulted:
		just_insulted = false
		return "How dare you insult the best language !"
	if chat_counter == 1: return "Not bad !"
	elif chat_counter == 2: return "You are a true Godot enthusiast !"
	return  "I will crush you to BITs !"
