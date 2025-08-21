class_name Battle extends Node

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
var monster_speaking := false
var turn_counter := 0

var player_hp := 20:
	set(new_value):
		player_hp = clamp(new_value, 0, 20)
		%HPBar.value = player_hp
		%HP2.text = str(player_hp) + " / 20"
var enemy_hp := 100
var enemy_name := "Name here"
var encounter_text := "* name here drew new !"
var idle_text := "* name here is staring at you angerly"
var monster_text: String
var enemy_mercy := 0:
	set(new_value):
		enemy_mercy = new_value
		if enemy_mercy >= 100:
			can_spare = true
var acts: Array[Act] = []
@export var items: Array[Item] = []
var bullet_waves: Array[PackedScene] = []
var monster_manager: Node

var theme := preload("uid://cf0xm6i8snote")

static var enemy_stat: EnemyStats

func _ready() -> void:
	 
	# set up enemy:
	monster_manager = enemy_stat.manager.instantiate()
	%Monster.add_child(monster_manager)
	%MonsterSprite.texture = enemy_stat.sprite
	%MonsterSprite.scale *= enemy_stat.sprite_scale
	%Damage.scale /= enemy_stat.sprite_scale # Keep the Damage label as is.
	%Damage.global_position = monster_position()
	enemy_name = enemy_stat.name
	enemy_hp = enemy_stat.HP
	acts = enemy_stat.acts.duplicate(true)
	bullet_waves = enemy_stat.bullet_waves.duplicate(true)
	encounter_text = enemy_stat.encounter_text
	%Text.display(encounter_text)
	
	Global.wave_done.connect(finish_hell)
	Global.add_bullet.connect(func(bullet: Node2D, transform: Transform2D):
		$Bullets.add_child(bullet)
		bullet.global_transform = transform
		)
	Global.change_mercy.connect(func(amount: int):
		enemy_mercy += amount
		)
	Global.heal_player.connect(func(amount: int):
		player_hp += amount
		%UseItemSound.play()
		)
	Global.bullet_destroyed.connect(func(pos: Vector2):
		const BULLET_PARTICLE := preload("uid://jciddngihwq7")
		var instance := BULLET_PARTICLE.instantiate()
		instance.global_position = pos
		add_child(instance)
		)
	%MonsterDialouge.play_monster_speak_anim.connect(monster_speaking_anim)
	Global.monster_visible.connect(func(new_val: bool):
		var tween := get_tree().create_tween()
		var final_val := 1.0 if new_val else 0.0
		tween.tween_property(%MonsterSprite, "modulate:a", final_val, 0.5)
		)
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

func monster_position() -> Vector2:
	return get_tree().get_first_node_in_group("enemy").global_position

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
		monster_text = monster_manager.get_monster_text()
	elif event.is_action_pressed("ui_accept") and is_attacking:
		is_attacking = false
		%Anim.pause() # Stop the attack line from moving so it doesn't trigger the 'Miss' animation.
		%KnifeSlashSound.play()
		%Knife.show()
		%Knife.global_position = monster_position()
		%Knife.play()
		# Rest of the logic is in '_on_knife_animation_finished()'

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
		monster_speaking = true
		monster_text = monster_manager.get_monster_text()
		%SpeechBox.show()
		%MonsterDialouge.display(monster_text)
		
	elif event.is_action_pressed("ui_accept") and gonna_spare:
		if can_spare:
			can_spare = false
			%BattleDone.play()
			%Music.stop()
			battle_won = true
			%MonsterSprite.modulate.a = 0.5
			%Text.modulate = Color.WHITE
			%Text.display("Battle won !\nGained 75 Gold and 0 EXP.")
			%Anim.play("fade_into_black")
		elif not can_spare:
			%SelectSound.play()
	
	elif event.is_action_pressed("ui_accept") and monster_speaking:
		monster_speaking = false
		%SpeechBox.hide()
		start_hell()
	
	
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
		%MissTimer.start()
		# Rest of the logic is in '_on_miss_timer_timeout'.
	elif anim_name == "die":
		%Anim.play("end_hell")
	elif anim_name == "end_hell" and battle_won:
		%Text.display("Battle won\nGot 50 EXP and 27 Gold.")
		%Anim.play("fade_into_black")
	elif anim_name == "end_hell" and battle_lost:
		%Text.display("Battle Lost...")
		%Anim.play("fade_into_black")
	elif anim_name == "fade_into_black":
		get_tree().change_scene_to_file("uid://cnxrqinpyif6b")
	elif anim_name == "monster_hurt":
		%Damage.hide()
		%AttackBar.hide()
		if enemy_hp <= 0:
			battle_won = true
			%Anim.play("die")
			%Music.stop()
			%BattleDone.play()
			return
			# The rest of the logic happens in the fucntion "_on_anim_animation_finished()"...
		monster_speaking = true
		%SpeechBox.show()
		%MonsterDialouge.display(monster_text)

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
	idle_text = monster_manager.get_idle_text()
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
	%Text.display(monster_manager.do_act_get_text(act))
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


func _on_knife_animation_finished() -> void:
	%Knife.hide()
	%AttackLine.hide()
	%MonsterHurtSound.play()
	var distance_from_centre: int = round(abs(%AttackLine.global_position.x - %AttackBar.global_position.x))
	var damage: int = round((575  - distance_from_centre) / 10)
	%Damage.text = str(damage)
	%Damage.show()
	enemy_hp -= damage
	%Anim.play("monster_hurt")
	# The rest of the logic happens in the fucntion "_on_anim_animation_finished()"...

func _on_miss_timer_timeout() -> void:
	_on_anim_animation_finished("monster_hurt")

func monster_speaking_anim() -> void:
	# Aniamtion:-
	var tween := get_tree().create_tween()
	var og_dim: Vector2 = %MonsterSprite.scale
	var anim_dim: Vector2 = og_dim + Vector2(og_dim.x*0.1, og_dim.y*-0.05)
	var delta := 0.2
	for i in range(2):
		tween.tween_property(%MonsterSprite, "scale", anim_dim, delta)
		tween.tween_property(%MonsterSprite, "scale", og_dim, delta)
