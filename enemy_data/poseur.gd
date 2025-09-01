extends Enemy

var pose_counter: int = 0

func do_act_get_text(act: String) -> String:
	if act == "Pose":
		if pose_counter == 0:
			pose_counter += 1
			Global.change_mercy.emit(35)
			return "* You did a clumsy little pose...\n* Poseur seemed interested!"
		elif pose_counter == 1:
			pose_counter += 1
			Global.change_mercy.emit(35)
			return "* You did a decent pose...\n* it was better than the last one!\n* Poseur got more interested!"
		elif pose_counter == 2:
			pose_counter += 1
			Global.change_mercy.emit(35)
			return "* You posed really hard...\n* Poseur is in tears!"
		else:
			return "* That's enough posing!"
	elif act == "Check":
		return "* Poseur - ATK 12 DEF 7\n* A featureless doll\n* Lives to pose"
	else:
		return "There was an error !!!"

func get_idle_text() -> String:
	if pose_counter == 0: return "* Poseur is posing really hard!"
	elif pose_counter == 1: return "* Poseur wants to see you pose more!"
	elif pose_counter == 2: return "* Poseur wants to see one last pose!"
	return "* Poseur is satsfied!"

func get_monster_text() -> String:
	if pose_counter == 1: return Util.tornado("Nice pose!")
	elif pose_counter == 2: return Util.tornado("Fabulous!")
	elif pose_counter == 3: return Util.tornado("absolutely beautiful!")
	return  Util.tornado("Let's dance darling!")
