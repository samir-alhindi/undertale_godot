class_name Soul extends CharacterBody2D

signal took_damage(amount: int, soul: Soul)
var color: Color
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
			color = Color.RED
		Mode.BLUE:
			color = Color.BLUE
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

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("bullet") or %invincibilityTimer.time_left: return
	took_damage.emit(area.damage_amount, self)
	%invincibilityTimer.start()
