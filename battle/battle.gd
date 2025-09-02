class_name Battle extends Node2D

static var battle_counter := -1

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
var acts: Array[String] = []
@export var items: Array[Item] = []
var bullet_waves: Array[PackedScene] = []

var theme := preload("uid://cf0xm6i8snote")
var button := preload("uid://ptt71q0lsxgx")

@onready var text_box: TextBox = %TextBox
@onready var monster_text_box: MonsterTextBox = %MonsterTextBox

static var enemy: Enemy

func _ready() -> void:
	
	Fade.fade_from_black()
	
	var songs: Array[AudioStream] = [
		preload("uid://dpexiickfpwht"),
		preload("uid://b5k27ym6e01c6")]
	
	randomize()
	Battle.battle_counter += 1
	%Music.stream = songs[battle_counter % songs.size()]
	%Music.play()
	
	var make_me_transparent: Array[CanvasItem] = [%AttackBar, %AttackLine,%SpeechBox, $Damage]
	for ui: CanvasItem in make_me_transparent:
		ui.show()
		ui.modulate.a = 0.0
	
	# set up enemy:
	%Monster.add_child(enemy)
	%MonsterSprite.texture = enemy.sprite
	%MonsterSprite.scale *= enemy.sprite_scale
	%Damage.global_position = monster_position()
	enemy_name = enemy.name
	enemy_hp = enemy.HP
	acts = enemy.acts.duplicate(true)
	bullet_waves = enemy.bullet_waves.duplicate(true)
	encounter_text = enemy.encounter_text
	text_box.scroll(encounter_text)            
	
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
	monster_text_box.play_monster_speak_anim.connect(monster_speaking_anim)
	Global.monster_visible.connect(func(new_val: bool):
		var tween := get_tree().create_tween()
		var final_val := 1.0 if new_val else 0.0
		tween.tween_property(%MonsterSprite, "modulate:a", final_val, 0.5)
		)
	Global.play_shoot_sound.connect(func():
		%ShootSound.play())
	RenderingServer.set_default_clear_color(Color.BLACK)
	%AttackButton.grab_focus()
	
	
	for button: Button in %ButtonsContainer.get_children():
		button.pivot_offset = button.size / 2
		button.focus_entered.connect(
			_on_focus_entered.bind(button)
		)

func monster_position() -> Vector2:
	return get_tree().get_first_node_in_group("enemy").global_position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and gonna_attack:
		%SelectSound.play()
		text_box.modulate = Color.WHITE
		attack_bar_visibility(true)
		text_box.clear_text()
		%Anim.play("attack")
		gonna_attack = false
		is_attacking = true
		monster_text = enemy.get_monster_text()
	elif event.is_action_pressed("ui_accept") and is_attacking:
		is_attacking = false
		%Anim.pause() # Stop the attack line from moving so it doesn't trigger the 'Miss' animation.
		var tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
		tween.tween_property(%AttackLine, "scale", Vector2(1.25, 1.25), .25)
		tween.tween_property(%AttackLine, "scale", Vector2(1, 1), .25)
		%KnifeSlashSound.play()
		%Knife.show()
		%Knife.global_position = monster_position()
		%Knife.play()
		# Rest of the logic is in '_on_knife_animation_finished()'

	elif event.is_action_pressed("ui_accept") and gonna_act:
		%SelectSound.play()
		gonna_act = false
		is_choosing_act = true
		text_box.clear_text()
		text_box.modulate = Color.WHITE
		for act: String in acts:
			var button: Button = button.instantiate()
			button.get_node("text").text = Util.shake(act)
			button.focus_exited.connect(func():
				button.modulate.a  = 0.5)
			button.pressed.connect(do_act.bind(act))
			%OptionsContainer.add_child(button)
		%OptionsContainer.get_child(0).grab_focus()
		%UiCooldownTimer.start()
		# Rest of the logic is in "do_act".
		
	elif event.is_action_pressed("ui_accept") and is_reading_act_text or is_reading_item_text:
		is_reading_act_text = false
		is_reading_item_text = false
		text_box.clear_text()
		monster_speaking = true
		monster_text = enemy.get_monster_text()
		speech_bubble_visibility(true)
		monster_text_box.speak(monster_text)
		
	elif event.is_action_pressed("ui_accept") and gonna_spare:
		if can_spare:
			gonna_spare = false
			can_spare = false
			%BattleDone.play()
			%Music.stop()
			battle_won = true
			%MonsterSprite.modulate.a = 0.5
			
			create_tween().tween_property(%Box, "scale", Vector2(2, 2), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			create_tween().tween_property(%Box, "scale", Vector2(1, 1), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			
			var gold := randi_range(50, 75)
			text_box.scroll("Battle won\nGot 0 EXP and %d Gold" % gold)
			await text_box.finished_scrolling
			await Fade.fade_into_black()
			get_tree().change_scene_to_file("uid://cnxrqinpyif6b")
		elif not can_spare:
			%SelectSound.play()
	
	elif event.is_action_pressed("ui_accept") and monster_speaking:
		monster_speaking = false
		monster_text_box.stop_talking()
		speech_bubble_visibility(false)
		start_hell()
	
	
	elif event.is_action_pressed("ui_cancel"):
		if gonna_attack:
			gonna_attack = false
			%ButtonsContainer.show()
			%AttackButton.grab_focus()
			text_box.modulate = Color.WHITE
			text_box.scroll(idle_text if turn_counter > 0 else encounter_text)
		elif gonna_act:
			%ActButton.grab_focus()
			%ButtonsContainer.show()
			%OptionsContainer.hide()
			text_box.modulate = Color.WHITE
			text_box.scroll(idle_text if turn_counter > 0 else encounter_text)
			gonna_act = false
		elif is_choosing_act:
			for button: Button in %OptionsContainer.get_children():
				button.queue_free()
			%OptionsContainer.hide()
			if can_spare:
				text_box.modulate = Color.YELLOW
			text_box.set_new_text("* " + enemy_name)
			is_choosing_act = false
			gonna_act = true
		elif is_choosing_item:
			for button: Button in %OptionsContainer.get_children():
				button.queue_free()
			%OptionsContainer.hide()
			%ButtonsContainer.show()
			%ItemButton.grab_focus()
			text_box.modulate = Color.WHITE
			text_box.scroll(idle_text if turn_counter > 0 else encounter_text)
			is_choosing_item = false
		elif gonna_spare:
			%MercyButton.grab_focus()
			%ButtonsContainer.show()
			%OptionsContainer.hide()
			text_box.modulate = Color.WHITE
			text_box.scroll(idle_text if turn_counter > 0 else encounter_text)
			gonna_spare = false

func player_take_damage(amount: int, soul: Soul) -> void:
	player_hp -= amount
	%SoulHitSound.play()
	
	if player_hp <= 0:
		%Music.stop()
		%SoulBreak.play()
		battle_lost = true
		var attack := get_tree().get_first_node_in_group("wave")
		if is_instance_valid(attack): attack.queue_free()
		const DEATH_PARTICLE := preload("uid://cvsoixker4k6d")
		var particles := DEATH_PARTICLE.instantiate()
		particles.color = soul.color
		particles.global_position = soul.global_position
		add_child(particles)
		soul.call_deferred("queue_free")
		change_box_size(Vector2(1.0, 1.0))
		particles.finished.connect(func():
			text_box.scroll("Battle Lost...")
			await text_box.finished_scrolling
			await Fade.fade_into_black()
			get_tree().change_scene_to_file("uid://cnxrqinpyif6b")
			)

func _on_attack_button_pressed() -> void:
	%SelectSound.play()
	%ButtonsContainer.hide()
	if can_spare:
		text_box.modulate = Color.YELLOW
	text_box.set_new_text("* " + enemy_name)
	gonna_attack = true

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
		%AttackLine.modulate.a = 0.0
		%Damage.text = "miss"
		await damage_label_bounce()
		_on_anim_animation_finished("monster_hurt")
	elif anim_name == "die":
		change_box_size(Vector2(1.0, 1.0))
		text_box.modulate = Color.RED
		var exp := randi_range(25, 50)
		var gold := randi_range(20, 30)
		text_box.scroll("Battle won\nGot %d EXP and %d Gold" % [exp, gold])
		await text_box.finished_scrolling
		await Fade.fade_into_black()
		get_tree().change_scene_to_file("uid://cnxrqinpyif6b")
	elif anim_name == "monster_hurt":
		attack_bar_visibility(false)
		if enemy_hp <= 0:
			battle_won = true
			%Anim.play("die")
			%Music.stop()
			%BattleDone.play()
			return
			# The rest of the logic happens in the fucntion "_on_anim_animation_finished()"...
		monster_speaking = true
		speech_bubble_visibility(true)
		monster_text_box.speak(monster_text)

var wave_index := 0
func start_hell() -> void:
	%ButtonsContainer.hide()
	var wave: Node2D = bullet_waves[wave_index % bullet_waves.size()].instantiate()
	wave_index += 1
	var soul := Soul.new_soul(wave.mode)
	soul.global_position = %AttackBar.global_position
	soul.took_damage.connect(player_take_damage)
	await change_box_size(wave.box_size, wave.box_size_change_time)
	add_child(soul)
	add_child(wave)
	# The wave finishes when the Node emits the global "wave_done" signal.

func finish_hell(wave: Node2D, soul: Soul) -> void:
	wave.queue_free()
	if battle_won or battle_lost: return
	turn_counter += 1
	%ButtonsContainer.show()
	soul.queue_free()
	await change_box_size(Vector2(1.0, 1.0), wave.box_size_change_time)
	idle_text = enemy.get_idle_text()
	text_box.scroll(idle_text)
	%AttackButton.grab_focus()


func _on_act_button_pressed() -> void:
	%SelectSound.play()
	%ButtonsContainer.hide()
	%OptionsContainer.show()
	if can_spare:
		text_box.modulate = Color.YELLOW
	text_box.set_new_text("* " + enemy_name)
	gonna_act = true

func do_act(act_name: String) -> void:
	if %UiCooldownTimer.time_left: return
	%SelectSound.play()
	for button: Button in %OptionsContainer.get_children():
		button.queue_free()
	%OptionsContainer.hide()
	text_box.scroll(enemy.do_act_get_text(act_name))
	is_choosing_act = false
	is_reading_act_text = true

func use_item(item: Item) -> void:
	if %UiCooldownTimer.time_left: return
	%UseItemSound.play()
	for button: Button in %OptionsContainer.get_children():
		button.queue_free()
		%OptionsContainer.hide()
	player_hp += item.amount
	text_box.scroll(item.text)
	items.erase(item)
	is_choosing_item = false
	is_reading_item_text = true

func _on_mercy_button_pressed() -> void:
	%SelectSound.play()
	gonna_spare = true
	%ButtonsContainer.hide()
	if can_spare:
		text_box.modulate = Color.YELLOW
	text_box.set_new_text("* " + enemy_name)

func _on_item_button_pressed() -> void:
	%SelectSound.play()
	if items.size() <= 0: return
	is_choosing_item = true
	%ButtonsContainer.hide()
	%OptionsContainer.show()
	text_box.clear_text()
	for item: Item in items:
		var button: Button = button.instantiate()
		button.get_node("text").text = Util.shake(item.item_name)
		button.focus_exited.connect(func():
			button.modulate.a  = 0.5)
		button.pressed.connect(use_item.bind(item))
		%OptionsContainer.add_child(button)
	%OptionsContainer.get_child(0).grab_focus()
	%UiCooldownTimer.start()
	# Rest of the logic is in "use_item".

func add_choices_buttons() -> void:
	pass

func _on_knife_animation_finished() -> void:
	%Knife.hide()
	%MonsterHurtSound.play()
	var distance_from_centre: int = round(abs(%AttackLine.global_position.x - %AttackBar.global_position.x))
	var damage: int = round((575  - distance_from_centre) / 10)
	%Damage.text = str(damage)
	damage_label_bounce()
	enemy_hp -= damage
	%Anim.play("monster_hurt")
	# The rest of the logic happens in the fucntion "_on_anim_animation_finished()"...

func monster_speaking_anim() -> void:
	# Aniamtion:-
	var tween := get_tree().create_tween()
	var og_dim: Vector2 = %MonsterSprite.scale
	var anim_dim: Vector2 = og_dim + Vector2(og_dim.x*0.1, og_dim.y*-0.05)
	var delta := 0.2
	for i in range(2):
		tween.tween_property(%MonsterSprite, "scale", anim_dim, delta)
		tween.tween_property(%MonsterSprite, "scale", og_dim, delta)

func change_box_size(new_size: Vector2, delta: float = 0.3) -> void:
	var tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%Box, "scale:x", new_size.x, delta)
	tween.tween_property(%Box, "scale:y", new_size.y, delta)
	await tween.finished

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var box_rect := Rect2(%Box.global_position, %Box.size  * %Box.scale)
	draw_rect(box_rect, Color.WHITE, false, 10)

func attack_bar_visibility(visible_: bool) -> void:
	var new_val := 1.0 if visible_ else 0.0
	var delta := 0.05 if visible_ else 0.2
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE).set_parallel()
	tween.tween_property(%AttackLine, "modulate:a", new_val, delta)
	tween.tween_property(%AttackBar, "modulate:a", new_val, delta)

func speech_bubble_visibility(visible_: bool) -> void:
	var new_val := 1.0 if visible_ else 0.0
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE).set_parallel()
	tween.tween_property(%SpeechBox, "modulate:a", new_val, 0.25)

func _on_focus_entered(button : Button) -> void:
	button.modulate.a = 1
	%MoveSound.play()
	var tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(button, "scale", Vector2(1.5,1.5), 0.2)
	tween.tween_property(button, "scale", Vector2(1,1), 0.1)

func damage_label_bounce() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%Damage, "modulate:a", 1.0, 0.1)
	tween.tween_property(%Damage, "scale", Vector2(1.5,1.5), .2)
	tween.tween_property(%Damage, "scale", Vector2(1,1), .1)
	tween.tween_property(%Damage, "modulate:a", 0.0, 0.1)
	await tween.finished
