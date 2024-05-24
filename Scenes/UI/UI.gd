extends CanvasLayer

const MONEY_TIMER = preload("res://Scenes/Experience/money_timer.tscn")

@onready var GameScene = get_parent()
@onready var score_label = $Score_Label
@onready var pause_button = $PauseButton
@onready var pause_dim_overlay = $PauseMenu/Pause_Dim_Overlay
@onready var resume_button = $PauseMenu/ResumeButton
@onready var exit_button  = $PauseMenu/ExitButton
@onready var pause_menu = $PauseMenu
@onready var restart_button = $Restart
@onready var exit = $Exit
@onready var restart_pause = $PauseMenu/Restart
@onready var high_score_label = $High_Score
@onready var health_bar = $Health_Bar
@onready var health_bar_bg = $Health_Bar_BG
@onready var money_label = $Money_Label
@onready var money_v_box_container = $Money_Label/VBoxContainer
@onready var exp_bar = $Exp_Bar
@onready var exp_bar_bg = $Exp_Bar_BG
@onready var evo_bar = $Evo_Bar
@onready var evo_bar_bg = $Evo_Bar_BG
@onready var evo_label = $Evo_Label
@onready var upgrade_menu = $Upgrade_Menu
@onready var upgrade_dim_overlay = $Upgrade_Menu/Upgrade_Dim_Overlay
@onready var first_upgrade_button = $Upgrade_Menu/First_Upgrade
@onready var second_upgrade_button = $Upgrade_Menu/Second_Upgrade
@onready var third_upgrade_button = $Upgrade_Menu/Third_Upgrade
@onready var fourth_upgrade_button = $Upgrade_Menu/Fourth_Upgrade
@onready var fifth_upgrade_button = $Upgrade_Menu/Fifth_Upgrade
@onready var sixth_upgrade_button = $Upgrade_Menu/Sixth_Upgrade
@onready var reroll_button = $Upgrade_Menu/Reroll_Button
@onready var level_up_timer = $Level_Up_Timer
@onready var levels_label = $Levels_Label
@onready var settings_menu = $SettingsMenu
@onready var crt_shader = $CRT_Shader
@onready var level_up_sound = $Level_Up_Sound
@onready var moon_guy_layover = $Moon_Guy_Layover
@onready var moon_guy_health_bar_bg = $Moon_Guy_Layover/Moon_Guy_Health_Bar_BG
@onready var moon_guy_health_bar = $Moon_Guy_Layover/Moon_Guy_Health_Bar
@onready var wave_counter_label = $Wave_Counter_Label
@onready var wave_counter_timer = $Wave_Counter_Timer
@onready var wave_blink_timer = $Wave_Blink_Timer
@onready var wave_number_label = $Wave_Number_Label
@onready var wave_timer_label = $Wave_Timer_Label
@onready var next_wave_button = $Upgrade_Menu/Next_Wave_Button

@onready var buttons = [
	$Upgrade_Menu/First_Upgrade,
	$Upgrade_Menu/Second_Upgrade,
	$Upgrade_Menu/Third_Upgrade,
	$Upgrade_Menu/Fourth_Upgrade,
	$Upgrade_Menu/Fifth_Upgrade,
	$Upgrade_Menu/Sixth_Upgrade
]

@onready var textures = [
	$Upgrade_Menu/First_Upgrade/TextureRect1,
	$Upgrade_Menu/Second_Upgrade/TextureRect2,
	$Upgrade_Menu/Third_Upgrade/TextureRect3,
	$Upgrade_Menu/Fourth_Upgrade/TextureRect1,
	$Upgrade_Menu/Fifth_Upgrade/TextureRect2,
	$Upgrade_Menu/Sixth_Upgrade/TextureRect3
] 

@onready var text_labels = [
	$Upgrade_Menu/First_Upgrade/RichTextLabel1,
	$Upgrade_Menu/Second_Upgrade/RichTextLabel2,
	$Upgrade_Menu/Third_Upgrade/RichTextLabel3,
	$Upgrade_Menu/Fourth_Upgrade/RichTextLabel1,
	$Upgrade_Menu/Fifth_Upgrade/RichTextLabel2,
	$Upgrade_Menu/Sixth_Upgrade/RichTextLabel3
]

@onready var cost_labels = [
	$Upgrade_Menu/First_Upgrade/Cost_Label,
	$Upgrade_Menu/Second_Upgrade/Cost_Label,
	$Upgrade_Menu/Third_Upgrade/Cost_Label,
	$Upgrade_Menu/Fourth_Upgrade/Cost_Label,
	$Upgrade_Menu/Fifth_Upgrade/Cost_Label,
	$Upgrade_Menu/Sixth_Upgrade/Cost_Label
]

var score = 0
var first_upgrade: upgrade
var second_upgrade: upgrade
var third_upgrade: upgrade
var fourth_upgrade: upgrade
var fifth_upgrade: upgrade
var sixth_upgrade: upgrade
var first_upgrade_cost: int
var second_upgrade_cost: int
var third_upgrade_cost: int
var fourth_upgrade_cost: int
var fifth_upgrade_cost: int
var sixth_upgrade_cost: int
var stored_levels = 0
var total_level = 0
var evolved = false
var upgrades = [
	first_upgrade,
	second_upgrade,
	third_upgrade,
	fourth_upgrade,
	fifth_upgrade,
	sixth_upgrade
]
var upgrades_cost = [
	first_upgrade_cost,
	second_upgrade_cost,
	third_upgrade_cost,
	fourth_upgrade_cost,
	fifth_upgrade_cost,
	sixth_upgrade_cost
]


func _ready():
	Global.wave_num_update.connect(wave_num)
	Global.update_money.connect(update_money)
	Global.moon_guy_health.connect(moon_guy_health)
	Global.update_sound_effects_volume.connect(sound_effects)
	sound_effects()
	Global.shader_settings.connect(crt)
	crt_shader.material.set_shader_parameter("aberration", Global.aberration)
	crt_shader.material.set_shader_parameter("grille_opacity", Global.grille_opacity)
	pause_button.connect("pressed", toggle_pause_menu)
	resume_button.connect("pressed", _on_ResumeButton_pressed)
	exit_button.connect("pressed", _on_ExitButton_pressed)
	Global.connect("update_max_health", update_max_health)
	Global.connect("update_health", update_health)
	$PauseMenu/Pause_High_Score_Label.text = "High Score: " + Global.get_score_text(Global.high_score)
	pause_menu.visible = false
	restart_button.visible = false
	update_max_health(0)
	update_health(0)
	exp_bar.max_value = Global.exp_threshold



func _process(_delta):
	wave_timer_label.text = str(round(Global.wave_time))
	money_label.text = "$" + str(Global.money)
	if !settings_menu.visible:
		if Input.is_action_just_pressed("ui_cancel"):
			toggle_pause_menu()
	if Global.health <= 0:
		if Input.is_action_just_pressed("ui_select"):
			restart()
	if upgrade_menu.visible == true:
		if Input.is_action_just_pressed("reroll"):
			level_up()
	if Input.is_action_just_pressed("reroll") && (stored_levels > 0 || Global.god_mode):
		level_up()
	if Input.is_action_just_pressed("E") && (total_level >= 10 || Global.god_mode) && !evolved:
		evo_level_up()
		
	$PauseMenu/VBoxContainer/Health_Label.text = "Health: " + str(snapped(Global.health, 1)) + " / " + str(Global.max_health)
	$PauseMenu/VBoxContainer/Health_Regen_Label.text = "Health Regen: " + str(Global.health_regen) + " (sec)"
	$PauseMenu/VBoxContainer/Damage_Reduction_Label.text = "Damage Reduction: " + str(snapped(Global.damage_reduction * 100, 0.1)) + "%"
	$PauseMenu/VBoxContainer/Collision_Damage_Label.text = "Collision Damage: " + str(Global.collision_damage)
	$PauseMenu/VBoxContainer/Weapon_Damage_Label.text = "Weapon Damage: " + str(snapped(Global.damage, 0.01))
	$PauseMenu/VBoxContainer/Attack_Speed_Label.text = "Attack Cooldown: " + str(snapped(Global.attack_speed, 0.01)) + " (sec)"
	$PauseMenu/VBoxContainer/Bullet_Velocity_Label.text = "Bullet Velocity: " + str(snapped(Global.bullet_velocity, 1))
	$PauseMenu/VBoxContainer/Move_Speed_Label.text = "Thrust: " + str(Global.move_speed)
	$PauseMenu/VBoxContainer/Counter_Thrust_Label.text = "Counter Thrust: " + str(Global.counter_thrust)
	reroll_button.text = "Reroll\n$" + str(Global.reroll_cost)
	next_wave_button.text = "Next Wave\n(Interest = $" + str(round(Global.money * 0.5)) + ")"


func wave_num(wave_num):
	wave_counter_label.hide()
	wave_timer_label.hide()
	wave_counter_timer.start()
	wave_blink_timer.one_shot = false
	wave_blink_timer.start()
	if str(wave_num) == "moon_guy":
		wave_counter_label.text = "MOON GUY"
		return
	wave_counter_label.text = "WAVE " + str(wave_num)


func _on_wave_counter_timer_timeout():
	wave_blink_timer.one_shot = true
	wave_counter_label.visible = true
	wave_timer_label.show()


func _on_wave_blink_timer_timeout():
	wave_counter_label.visible = !wave_counter_label.visible


func update_money(amount):
	var new_label = Label.new()
	if amount >= 0:
		new_label.text = "+$" + str(amount)
	else:
		new_label.text = "-$" + str(amount)
	money_v_box_container.add_child(new_label)
	var new_timer = MONEY_TIMER.instantiate()
	new_label.add_child(new_timer)


func moon_guy_health(damage):
	moon_guy_layover.show()
	moon_guy_health_bar.value -= damage
	if moon_guy_health_bar.value <= 0:
		moon_guy_layover.hide()


func sound_effects():
	level_up_sound.volume_db = Global.sound_effects_volume


func crt():
	crt_shader.material.set_shader_parameter("aberration", Global.aberration)
	crt_shader.material.set_shader_parameter("grille_opacity", Global.grille_opacity)


func toggle_pause_menu():
	ButtonClick.play()
	get_tree().paused = !get_tree().paused
	pause_menu.visible = !pause_menu.visible
	resume_button.grab_focus()
	if upgrade_menu.visible == true:
		get_tree().paused = true
		for button in buttons:
			button.visible != button.visible
	if upgrade_menu.visible && !pause_menu.visible:
		second_upgrade_button.grab_focus()


func _on_ResumeButton_pressed():
	ButtonClick.play()
	get_tree().paused = false
	pause_menu.visible = false
	if upgrade_menu.visible == true:
		for button in buttons:
			button.visible = true
		get_tree().paused = true


func _on_settings_button_pressed():
	ButtonClick.play()
	settings_menu.show()


func _on_ExitButton_pressed():
	ButtonClick.play()
	#pause menu exit button
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Screens/Start Screen/StartScreen.tscn")


func _on_restart_pressed():
	ButtonClick.play()
	restart()


func restart():
	Global.refresh()
	if get_tree().paused:
		upgrade_menu.visible = false
		toggle_pause_menu()
		get_tree().change_scene_to_file("res://Scenes/Screens/Start_Menu/start_menu.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Screens/Start_Menu/start_menu.tscn")


func increase_score(amount):
	score += amount
	$Score_Label.text = "Score: " + Global.get_score_text(score)


func update_health(amount):
	Global.health += amount
	if Global.health > Global.max_health:
		Global.health = Global.max_health
	health_bar.value = Global.health
	if Global.health <= 0:
		score_label.set("theme_override_font_sizes/font_size", 56)
		score_label.position.y = Global.screen_size.y/2 - 45
		restart_button.visible = true
		restart_button.grab_focus()
		exit.show()
		high_score_label.visible = true
		high_score_label.text = "High Score: " + Global.get_score_text(Global.high_score)
		if score > Global.high_score:
			high_score_label.text = "New High Score: " + Global.get_score_text(Global.high_score)
			Global.high_score = score
			Global.save_score()
		GameScene.game_over()


func update_max_health(amount):
	Global.max_health += amount
	#update_health(Global.max_health - Global.health)
	health_bar.max_value = Global.max_health
	if health_bar.max_value >= 950:
		health_bar.size.x = 1900
		health_bar_bg.size.x = 1900
	else: 
		health_bar.size.x = health_bar.max_value * 2
		health_bar_bg.size.x = health_bar.size.x
	health_bar.position.x = ((1920 - health_bar.size.x)/2)
	health_bar_bg.position.x = ((1920 - health_bar.size.x)/2)


func update_exp(amount):
	Global.exp += amount
	exp_bar.value = Global.exp
	update_max_exp()


func update_max_exp():
	if total_level == 9:
		evo_label.show()
	if Global.exp >= Global.exp_threshold:
		total_level += 1
		evo_bar.value = total_level
		level_up_sound.play()
		Global.exp -= Global.exp_threshold
		Global.exp_threshold *= 1.1
		exp_bar.max_value = Global.exp_threshold
		exp_bar.value = Global.exp
		stored_levels += 1
	if stored_levels == 1:
		levels_label.text = "'R' to level up (" + str(stored_levels) + " level stored)"
		levels_label.show()
	if stored_levels > 1:
		levels_label.text = "'R' to level up (" + str(stored_levels) + " levels stored)"
		levels_label.show()
	if Global.god_mode:
		levels_label.text = "'R' to level up (INF levels stored)"
		levels_label.show()


func _on_first_upgrade_pressed():
	if level_up_timer.time_left == 0 && Global.money >= first_upgrade_cost:
		Global.update_money.emit(-first_upgrade_cost)
		apply_my_upgrade(first_upgrade)
		first_upgrade = null
		upgrades[0] = null
		first_upgrade_button.hide()


func _on_second_upgrade_pressed():
	if level_up_timer.time_left == 0 && Global.money >= second_upgrade_cost:
		Global.update_money.emit(-second_upgrade_cost)
		apply_my_upgrade(second_upgrade)
		second_upgrade = null
		upgrades[1] = null
		second_upgrade_button.hide()


func _on_third_upgrade_pressed():
	if level_up_timer.time_left == 0 && Global.money >= third_upgrade_cost:
		Global.update_money.emit(-third_upgrade_cost)
		apply_my_upgrade(third_upgrade)
		third_upgrade = null
		upgrades[2] = null
		third_upgrade_button.hide()


func _on_fourth_upgrade_pressed():
	if level_up_timer.time_left == 0 && Global.money >= fourth_upgrade_cost:
		Global.update_money.emit(-fourth_upgrade_cost)
		apply_my_upgrade(fourth_upgrade)
		fourth_upgrade = null
		upgrades[3] = null
		fourth_upgrade_button.hide()


func _on_fifth_upgrade_pressed():
	if level_up_timer.time_left == 0 && Global.money >= fifth_upgrade_cost:
		Global.update_money.emit(-fifth_upgrade_cost)
		apply_my_upgrade(fifth_upgrade)
		fifth_upgrade = null
		upgrades[4] = null
		fifth_upgrade_button.hide()


func _on_sixth_upgrade_pressed():
	if level_up_timer.time_left == 0 && Global.money >= sixth_upgrade_cost:
		Global.update_money.emit(-sixth_upgrade_cost)
		apply_my_upgrade(sixth_upgrade)
		sixth_upgrade = null
		upgrades[5] = null
		sixth_upgrade_button.hide()


func _on_reroll_button_pressed():
	if level_up_timer.time_left == 0 && Global.money >= Global.reroll_cost:
		Global.update_money.emit(-Global.reroll_cost)
		level_up()
		first_upgrade_button.show()
		second_upgrade_button.show()
		third_upgrade_button.show()
		fourth_upgrade_button.show()
		fifth_upgrade_button.show()
		sixth_upgrade_button.show()


func _on_next_wave_button_pressed():
	wave_number_label.text = "Wave " + str(Global.wave_num)
	Global.update_money.emit(int(Global.money * .5))
	get_tree().paused = false
	upgrade_menu.visible = false
	first_upgrade_button.show()
	second_upgrade_button.show()
	third_upgrade_button.show()
	fourth_upgrade_button.show()
	fifth_upgrade_button.show()
	sixth_upgrade_button.show()


func level_up():
	ButtonClick.play()
	second_upgrade_button.grab_focus()
	if !upgrade_menu.visible:
		stored_levels -= 1
	update_max_exp()
	if stored_levels == 0 && !Global.god_mode:
		levels_label.hide()
	get_tree().paused = true
	upgrade_menu.visible = true
	get_upgrades()
	level_up_timer.start()


func evo_level_up():
	ButtonClick.play()
	second_upgrade_button.grab_focus()
	if !upgrade_menu.visible:
		evolved = true
	evo_label.hide()
	get_tree().paused = true
	upgrade_menu.visible = true
	get_evolutions()
	level_up_timer.start()


func get_upgrades():
	Global.upgrades_test.shuffle()
	Global.reroll_cost = round(25 * Global.inflation)

	for i in range(6):
		if Global.upgrades_test.size() - 1 >= i:
			var my_upgrade = Global.upgrades_test[i]
			
			text_labels[i].text = "[center]" + my_upgrade.upgrade_text
			textures[i].texture = my_upgrade.upgrade_texture
			upgrades[i] = my_upgrade
			upgrades_cost[i] = round(randi_range(50, 75) * Global.inflation)
			cost_labels[i].text = "$" + str(upgrades_cost[i])
		else:
			text_labels[i].text = "null"
			textures[i].texture = null
			upgrades[i] = null
		
	first_upgrade = upgrades[0]
	second_upgrade = upgrades[1]
	third_upgrade = upgrades[2]
	fourth_upgrade = upgrades[3]
	fifth_upgrade = upgrades[4]
	sixth_upgrade = upgrades[5]
	first_upgrade_cost = upgrades_cost[0]
	second_upgrade_cost = upgrades_cost[1]
	third_upgrade_cost = upgrades_cost[2]
	fourth_upgrade_cost = upgrades_cost[3]
	fifth_upgrade_cost = upgrades_cost[4]
	sixth_upgrade_cost = upgrades_cost[5]


func get_evolutions():
	Global.evolutions_test.shuffle()

	for i in range(3):
		if Global.evolutions_test.size() - 1 >= i:
			var my_upgrade = Global.evolutions_test[i]
			
			text_labels[i].text = "[center]" + my_upgrade.upgrade_text
			textures[i].texture = my_upgrade.upgrade_texture
			upgrades[i] = my_upgrade
		else:
			text_labels[i].text = "null"
			textures[i].texture = null
			upgrades[i] = null
		
	first_upgrade = upgrades[0]
	second_upgrade = upgrades[1]
	third_upgrade = upgrades[2]


func apply_my_upgrade(my_upgrade):
	ButtonClick.play()
	if my_upgrade == null:
		return
	Global.upgrades_test.erase(my_upgrade)
	my_upgrade.upgrade_player()
	if my_upgrade.next_upgrade:
		Global.upgrades_test.append(my_upgrade.next_upgrade)
