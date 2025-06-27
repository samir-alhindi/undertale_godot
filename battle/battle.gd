extends Node

var gonna_attack := false
var gonna_act := false
var is_choosing_act := false
var is_reading_act_text := false
var is_attacking := false
var gonna_spare := false
var battle_won := false
var battle_lost := false
var can_spare := false

var player_hp := 20
var enemy_hp := 100
var enemy_mercy := 0:
	set(new_value):
		enemy_mercy = new_value
		if enemy_mercy >= 100:
			can_spare = true

var enemy_acts := {
	"Check" : "Godot: 10 ATK 15 DFN\nLoves talking.",
	"Chat" : "* You talked to Godot about GDscript...\nIt seemed pleased !",
	"Insult" : "* You told Godot that GDscript is slow...\nGodot got angry !",
}

var enemy_act_stats := {
	"Check" : 0,
	"Chat" : 100,
	"Insult" : 0,
}

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
	if event.is_action_pressed("ui_accept") and gonna_attack:
		%Text.modulate = Color.WHITE
		%AttackBar.show()
		%Text.text = ""
		%AttackLine.show()
		%Anim.play("attack")
		gonna_attack = false
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
	elif event.is_action_pressed("ui_accept") and gonna_act:
		gonna_act = false
		is_choosing_act = true
		%Text.text = ""
		%Text.modulate = Color.WHITE
		for act: String in enemy_acts.keys():
			var button := Button.new()
			button.text = act
			button.custom_minimum_size = Vector2(100, 50)
			button.add_theme_font_size_override("font_size", 50)
			button.pressed.connect(do_act.bind(button.text))
			%OptionsContainer.add_child(button)
		%OptionsContainer.get_child(0).grab_focus()
		%UiCooldownTimer.start()
		# Rest of the logic is in "do_act".
		
	elif event.is_action_pressed("ui_accept") and is_reading_act_text:
		is_reading_act_text = false
		%Text.text = ""
		start_hell()
		
	elif event.is_action_pressed("ui_accept") and gonna_spare and can_spare:
		battle_won = true
		%Sprite2D.modulate.a = 0.5
		%Text.modulate = Color.WHITE
		%Text.text = "Battle won !\nGained 75 Gold and 0 EXP."
		%Anim.play("fade_into_black")
	
	elif event.is_action_pressed("ui_cancel"):
		if gonna_attack:
			gonna_attack = false
			%ButtonsContainer.show()
			%AttackButton.grab_focus()
			%Text.modulate = Color.WHITE
			%Text.text = "* Godot hopped close !"
		elif gonna_act:
			%ActButton.grab_focus()
			%ButtonsContainer.show()
			%OptionsContainer.hide()
			%Text.modulate = Color.WHITE
			%Text.text = "* Godot hopped close !"
			gonna_act = false
		elif is_choosing_act:
			for button: Button in %OptionsContainer.get_children():
				button.queue_free()
			%OptionsContainer.hide()
			if can_spare:
				%Text.modulate = Color.YELLOW
			%Text.text = "* Godot"
			is_choosing_act = false
			gonna_act = true

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
	if can_spare:
		%Text.modulate = Color.YELLOW
	%Text.text = "* Godot"
	gonna_attack = true

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


func _on_act_button_pressed() -> void:
	%ButtonsContainer.hide()
	%OptionsContainer.show()
	if can_spare:
		%Text.modulate = Color.YELLOW
	%Text.text = "* Godot"
	gonna_act = true

func do_act(act_name: String) -> void:
	if %UiCooldownTimer.time_left: return
	for button: Button in %OptionsContainer.get_children():
		button.queue_free()
	%OptionsContainer.hide()
	enemy_mercy += enemy_act_stats[act_name]
	%Text.text = enemy_acts[act_name]
	is_choosing_act = false
	is_reading_act_text = true


func _on_mercy_button_pressed() -> void:
	gonna_spare = true
	%ButtonsContainer.hide()
	if can_spare:
		%Text.modulate = Color.YELLOW
	%Text.text = "* Godot"
