extends Node

var is_selecting := false
var is_attacking := false
var battle_won := false
var battle_lost := false

var player_hp := 20
var enemy_hp := 100

@export var bullet_waves: Array[PackedScene]

func _ready() -> void:
	Global.wave_done.connect(finish_hell)
	RenderingServer.set_default_clear_color(Color.BLACK)
	%AttackButton.grab_focus()
	
	# Make sure all waves are valid:
	for wave: PackedScene in bullet_waves:
		var wave_instance := wave.instantiate()
		assert(wave_instance.is_in_group("wave"), "Make sure all waves are in the 'Wave' group")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and is_selecting:
		%AttackBar.show()
		%Text.text = ""
		%AttackLine.show()
		%Anim.play("attack")
		is_selecting = false
		is_attacking = true
	elif event.is_action_pressed("ui_accept") and is_attacking:
		is_attacking = false
		%AttackLine.hide()
		var distance_from_centre: int = round(abs(%AttackLine.global_position.x - %AttackBar.global_position.x))
		var damage: int = round((575  - distance_from_centre) / 10)
		%Damage.text = str(damage)
		%Damage.show()
		%Anim.stop()
		%LabelTimer.start()
		
		enemy_hp -= damage
		if enemy_hp <= 0:
			battle_won = true
			%Anim.play("die")
			# The rest of the logic happens in the fucntion "_on_anim_animation_finished()"...

func player_take_damage(amount: int, soul: Soul) -> void:
	player_hp -= amount
	var formated_hp: int = clamp(player_hp, 0, 20)
	%HPBar.value = formated_hp
	%HP2.text = str(formated_hp) + " / 20"
	
	if player_hp <= 0:
		battle_lost = true
		var attack := get_tree().get_first_node_in_group("bullet_attack")
		if is_instance_valid(attack): attack.queue_free()
		const DEATH_PARTICLE := preload("uid://cvsoixker4k6d")
		var particles := DEATH_PARTICLE.instantiate()
		particles.color = soul.color
		particles.global_position = soul.global_position
		add_child(particles)
		soul.call_deferred("queue_free")
		%Anim.play("end_hell")
		# The rest of the logic happens in the fucntion "_on_anim_animation_finished()"...

func _on_attack_button_pressed() -> void:
	%ButtonsContainer.hide()
	%Text.text = "* Godot"
	is_selecting = true

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
		%AttackLine.hide()
		%Damage.text = "miss"
		%Damage.show()
		%LabelTimer.start()
	elif anim_name == "die":
		%Anim.play("end_hell")
	elif anim_name == "end_hell" and battle_won:
		%Text.text = "Battle won\nGot 50 EXP and 27 Gold."
		%Anim.play("fade_into_black")
	elif anim_name == "end_hell" and battle_lost:
		%Text.text = "Battle Lost..."
		%Anim.play("fade_into_black")
	elif anim_name == "fade_into_black":
		get_tree().quit(0)

func _on_damage_label_timer_timeout() -> void:
	%Damage.hide()
	%AttackBar.hide()
	if battle_won or battle_lost: return
	start_hell()

var wave_index := 0
func start_hell() -> void:
	%ButtonsContainer.hide()
	%Anim.play("start_hell")
	
	var soul := Soul.new_soul(Soul.Mode.RED)
	add_child(soul)
	soul.global_position = %AttackBar.global_position
	soul.took_damage.connect(player_take_damage)
	
	var wave: Node2D = bullet_waves[wave_index % bullet_waves.size()].instantiate()
	wave_index += 1
	add_child(wave)
	# The wave finishes when the Node emits the global "wave_done" signal.

func finish_hell(wave: Node2D, soul: Soul) -> void:
	wave.queue_free()
	if battle_won or battle_lost: return
	%Anim.play("end_hell")
	%ButtonsContainer.show()
	soul.queue_free()
	%AttackButton.grab_focus()
	%Text.text = "* Godot hopped close !"
