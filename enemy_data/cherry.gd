extends Enemy

var cheered := false
var talked_football := false

var just_cheered := false
var just_talked_football := false

func do_act_get_text(act: String) -> String:
	if act == "Cheer" and not cheered:
		cheered = true
		just_cheered = true
		Global.change_mercy.emit(50)
		return "* You started cheering with Cherry...\n* She got more excited!"
	elif act == "Cheer" and cheered:
		return "* You cheered again with Cherry...\n* She didn't show much interest"
	elif act == "Football" and not talked_football:
		just_talked_football = true
		talked_football = true
		Global.change_mercy.emit(50)
		return "* You talked about human football...\n* Cherry started foaming from the mouth!"
	elif act == "Football" and talked_football:
		return "* You talked about human football again...\n* Cherry didn't care very much"
	elif act == "Check":
		return "* Cherry - ATK 15 DEF 11\n* Her helmet is too big for her...\n* She doesn't care"
	else:
		return "There was an error !!!"

func get_idle_text() -> String:
	if talked_football and cheered: return "* Cherry considers you her BFF now!"
	elif cheered: return "* Cherry wants to chat!"
	elif talked_football: return "* Cherry wants to see you cheer!"
	return "* Cherry is jumping up and down!"

var i := -1
func get_monster_text() -> String:
	if just_cheered:
		just_cheered = false
		return Util.wave("I love your moves <3")
	elif just_talked_football:
		just_talked_football = false
		return Util.wave("OMG you know that team too <3")
	i += 1
	return Util.wave("Go Go Hotland lizards <3") if i % 2 == 0 else Util.wave("Cheerleading is a lifestyle <3")
