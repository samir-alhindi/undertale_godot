extends Node

var cheered := false
var talked_football := false

var just_cheered := false
var just_talked_football := false

func do_act_get_text(act: Act) -> String:
	if act.name == "Cheer" and not cheered:
		cheered = true
		just_cheered = true
		Global.change_mercy.emit(50)
		return act.text
	elif act.name == "Cheer" and cheered:
		return "* You cheered again with Cherry...\n* She didn't show much intrest"
	elif act.name == "Football" and not talked_football:
		just_talked_football = true
		talked_football = true
		Global.change_mercy.emit(50)
		return act.text
	elif act.name == "Football" and talked_football:
		return "* You talked about human football again...\n* Cherry didn't care very much."
	elif act.name == "Check":
		return act.text
	else:
		return "There was an error !!!"

func get_idle_text() -> String:
	if talked_football and cheered: return "* Cherry considers you her BFF now !"
	elif cheered: return "* Cherry wants to chat !"
	elif talked_football: return "* Cherry wants to see you cheer !"
	return "* Cherry is jumping up and down !"

var i := -1
func get_monster_text() -> String:
	if just_cheered:
		just_cheered = false
		return "I love your moves <3"
	elif just_talked_football:
		just_talked_football = false
		return "OMG you know that team too <3"
	i += 1
	return "Go Go Hotland lizards <3" if i % 2 == 0 else "Cheerleading is a lifestyle <3"
