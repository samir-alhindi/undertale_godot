class_name Soul extends CharacterBody2D

enum Mode {RED, BLUE, YELLOW, GREEN, PURPLE}
var mode: Mode
const SOUL := preload("uid://tly4ac72poq7")

static func new_soul(mode: Mode) -> Soul:
	var soul := SOUL.instantiate()
	soul.mode = mode
	return soul

func _ready() -> void:
	match mode:
		Mode.RED:
			pass
		Mode.BLUE:
			%Sprite2D.texture = preload("uid://bgfotjyiv112h")

func _physics_process(delta: float) -> void:
	match mode:
		Mode.RED:
			var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			velocity = dir * 200
			move_and_slide()
		Mode.BLUE:
			var dir := Input.get_axis("ui_left", "ui_right")
			velocity.x = dir * 200
			if Input.is_action_just_pressed("ui_up") and is_on_floor():
				velocity.y = -400
			velocity.y += 800 * delta
			
			move_and_slide()
