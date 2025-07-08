extends Node

var pose_counter: int = 0

func do_act_get_text(act: Act) -> String:
	if act.name == "Pose":
		if pose_counter == 0:
			pose_counter += 1
			return "* You did a clumsy little pose\n* Poseur seemed intrested !"
		elif pose_counter == 1:
			pose_counter += 1
			return "* You did a decent pose !\n* it was better than the last one ! !\n* Poseur got more intrested"
		elif pose_counter == 2:
			pose_counter += 1
			return "* You posed really hard !\n* Poseur is in tears !"
		else:
			return "* That's enough posing !"
	elif act.name == "Check":
		return act.text
	else:
		return "There was an error !!!"

func get_idle_text() -> String:
	if pose_counter == 0: "* Poseur is posing really hard !"
	if pose_counter == 1: return "* Poseur wants to see you pose more !"
	elif pose_counter == 2: return "* Poseur wants to see one last pose !"
	return "* Poseur is satsfied !"

func get_monster_text() -> String:
	if pose_counter == 1: return "Nice pose !"
	elif pose_counter == 2: return "Fabulous !"
	elif pose_counter == 3: return "absolutely beautiful"
	return  "Let's dance darling !"
