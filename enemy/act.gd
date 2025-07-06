class_name Act extends Resource

@export var name: String = "Act name here"
@export var mercy_amount: int = 50
@export_multiline var text: String = "* You said blah blah\n* Yup..."

func _init(name: String, mercy_amount: int, text: String) -> void:
	self.name = name
	self.mercy_amount = mercy_amount
	self.text = text
