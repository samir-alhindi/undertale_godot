extends Node

var gonna_attack := false
var gonna_act := false
var is_choosing_act := false
var is_reading_act_text := false
var is_reading_item_text := false
var is_attacking := false
var gonna_spare := false
var is_choosing_item := false
var battle_won := false
var battle_lost := false
var can_spare := false
var turn_counter := 0

var player_hp := 20:
	set(new_value):
		player_hp = clamp(new_value, 0, 20)
		%HPBar.value = player_hp
		%HP2.text = str(player_hp) + " / 20"
		
var enemy_hp := 100
var enemy_name := "Godot"
var encounter_text := "* Godot is _ready() for a fight !"
var idle_text := "* Godot is _processing() what just happened"
var enemy_mercy := 0:
	set(new_value):
		enemy_mercy = new_value
		if enemy_mercy >= 100:
			can_spare = true

var acts: Array[Act] = [
	Act.new("Check", 0, "ATK 10 DEF 0\nLoves talking."),
	Act.new("Insult", 0, "* You told Godot that GDscript is slow...\nGodot got angry !"),
	Act.new("Chat", 100, "* You talked to Godot about GDscript...\nIt seemed pleased !")
]
@export var items: Array[Item] = []
var bullet_waves: Array[PackedScene] = [
	preload("uid://mj5bf0hhbi2k"),
	preload("uid://mlb50vg57cn7"),
]

var theme := preload("uid://cf0xm6i8snote")

func _ready() -> void:
	
	#acts.append(Act.new("Check", 0, "ATK 10 DEF 0\nLoves talking."))
	#acts.append(Act.new("Insult", 0, "* You told Godot that GDscript is slow...\nGodot got angry !"))
	#acts.append(Act.new("Chat", 100, "* You talked to Godot about GDscript...\nIt seemed pleased !"))
	
	%Text.display(encounter_text)
	
	Global.wave_done.connect(finish_hell)
	RenderingServer.set_default_clear_color(Color.BLACK)
	%AttackButton.grab_focus()
	
	# Make sure all waves are valid:
	for wave: PackedScene in bullet_waves:
		var wave_instance := wave.instantiate()
		assert(wave_instance.is_in_group("wave"), "Make sure all waves are in the 'Wave' group")
	
	for button: Button in %ButtonsContainer.get_children():
		button.focus_entered.connect(on_focus_entered)

func on_focus_entered() -> void:
	%MoveSound.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and gonna_attack:
		%SelectSound.play()
		%Text.modulate = Color.WHITE
		%AttackBar.show()
		%Text.text = ""
		%AttackLine.show()
		%Anim.play("attack")
		gonna_attack = false
		is_attacking = true
	elif event.is_action_pressed("ui_accept") and is_attacking:
		%KnifeSlashSound.play()
		%Anim.play("enemy_hurt")
		var hit_effect := preload("uid://jciddngihwq7").instantiate()
		hit_effect.global_position = get_tree().get_first_node_in_group("enemy").global_position
		add_child(hit_effect)
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
			%Music.stop()
			%BattleDone.play()
			# The rest of the logic happens in the fucntion "_on_anim_animation_finished()"...
	elif event.is_action_pressed("ui_accept") and gonna_act:
		%SelectSound.play()
		gonna_act = false
		is_choosing_act = true
		%Text.text = ""
		%Text.modulate = Color.WHITE
		for act: Act in acts:
			var button := Button.new()
			button.theme = theme
			button.text = act.name
			button.custom_minimum_size = Vector2(100, 50)
			button.add_theme_font_size_override("font_size", 50)
			button.pressed.connect(do_act.bind(act))
			%OptionsContainer.add_child(button)
		%OptionsContainer.get_child(0).grab_focus()
		%UiCooldownTimer.start()
		# Rest of the logic is in "do_act".
		
	elif event.is_action_pressed("ui_accept") and is_reading_act_text or is_reading_item_text:
		is_reading_act_text = false
		is_reading_item_text = false
		%Text.text = ""
		start_hell()
		
	elif event.is_action_pressed("ui_accept") and gonna_spare:
		if can_spare:
			%BattleDone.play()
			%Music.stop()
			battle_won = true
			%Sprite2D.modulate.a = 0.5
			%Text.modulate = Color.WHITE
			%Text.display("Battle won !\nGained 75 Gold and 0 EXP.")
			%Anim.play("fade_into_black")
		elif not can_spare:
			%SelectSound.play()
	
	
	elif event.is_action_pressed("ui_cancel"):
		if gonna_attack:
			gonna_attack = false
			%ButtonsContainer.show()
			%AttackButton.grab_focus()
			%Text.modulate = Color.WHITE
			%Text.display(idle_text if turn_counter > 0 else encounter_text)
		elif gonna_act:
			%ActButton.grab_focus()
			%ButtonsContainer.show()
			%OptionsContainer.hide()
			%Text.modulate = Color.WHITE
			%Text.display(idle_text if turn_counter > 0 else encounter_text)
			gonna_act = false
		elif is_choosing_act:
			for button: Button in %OptionsContainer.get_children():
				button.queue_free()
			%OptionsContainer.hide()
			if can_spare:
				%Text.modulate = Color.YELLOW
			%Text.text = "* " + enemy_name
			is_choosing_act = false
			gonna_act = true
		elif is_choosing_item:
			for button: Button in %OptionsContainer.get_children():
				button.queue_free()
			%OptionsContainer.hide()
			%ButtonsContainer.show()
			%ItemButton.grab_focus()
			%Text.modulate = Color.WHITE
			%Text.display(idle_text if turn_counter > 0 else encounter_text)
			is_choosing_item = false
		elif gonna_spare:
			%MercyButton.grab_focus()
			%ButtonsContainer.show()
			%OptionsContainer.hide()
			%Text.modulate = Color.WHITE
			%Text.display(idle_text if turn_counter > 0 else encounter_text)
			gonna_spare = false

func player_take_damage(amount: int, soul: Soul) -> void:
	player_hp -= amount
	%SoulHitSound.play()
	
	if player_hp <= 0:
		%Music.stop()
		%SoulBreak.play()
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
	%SelectSound.play()
	%ButtonsContainer.hide()
	if can_spare:
		%Text.modulate = Color.YELLOW
	%Text.text = "* " + enemy_name
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
		%Text.display("Battle won\nGot 50 EXP and 27 Gold.")
		%Anim.play("fade_into_black")
	elif anim_name == "end_hell" and battle_lost:
		%Text.display("Battle Lost...")
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
	
	var wave: Node2D = bullet_waves[wave_index % bullet_waves.size()].instantiate()
	wave_index += 1
	
	var soul := Soul.new_soul(wave.mode)
	add_child(soul)
	soul.global_position = %AttackBar.global_position
	soul.took_damage.connect(player_take_damage)
	add_child(wave)
	
	# The wave finishes when the Node emits the global "wave_done" signal.

func finish_hell(wave: Node2D, soul: Soul) -> void:
	wave.queue_free()
	if battle_won or battle_lost: return
	turn_counter += 1
	%Anim.play("end_hell")
	%ButtonsContainer.show()
	soul.queue_free()
	%AttackButton.grab_focus()
	%Text.display(idle_text)

func _on_act_button_pressed() -> void:
	%SelectSound.play()
	%ButtonsContainer.hide()
	%OptionsContainer.show()
	if can_spare:
		%Text.modulate = Color.YELLOW
	%Text.text = "* " + enemy_name
	gonna_act = true

func do_act(act: Act) -> void:
	if %UiCooldownTimer.time_left: return
	%SelectSound.play()
	for button: Button in %OptionsContainer.get_children():
		button.queue_free()
	%OptionsContainer.hide()
	enemy_mercy += act.mercy_amount
	%Text.display(act.text)
	is_choosing_act = false
	is_reading_act_text = true

func use_item(item: Item) -> void:
	if %UiCooldownTimer.time_left: return
	%UseItemSound.play()
	for button: Button in %OptionsContainer.get_children():
		button.queue_free()
		%OptionsContainer.hide()
	player_hp += item.amount
	%Text.display(item.text)
	items.erase(item)
	is_choosing_item = false
	is_reading_item_text = true

func _on_mercy_button_pressed() -> void:
	%SelectSound.play()
	gonna_spare = true
	%ButtonsContainer.hide()
	if can_spare:
		%Text.modulate = Color.YELLOW
	%Text.text = "* " + enemy_name

func _on_item_button_pressed() -> void:
	%SelectSound.play()
	if items.size() <= 0: return
	is_choosing_item = true
	%ButtonsContainer.hide()
	%OptionsContainer.show()
	%Text.text = ""
	for item: Item in items:
		var button := Button.new()
		button.theme = theme
		button.text = item.item_name
		button.custom_minimum_size = Vector2(100, 50)
		button.add_theme_font_size_override("font_size", 50)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(use_item.bind(item))
		%OptionsContainer.add_child(button)
	%OptionsContainer.get_child(0).grab_focus()
	%UiCooldownTimer.start()
	# Rest of the logic is in "use_item".
