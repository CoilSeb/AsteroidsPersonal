extends CanvasLayer

@onready var GameScene = get_parent()
@onready var score_label = $Score_Label
@onready var pause_button = $PauseButton
@onready var pause_dim_overlay = $PauseMenu/Pause_Dim_Overlay
@onready var resume_button = $PauseMenu/ResumeButton
@onready var exit_button  = $PauseMenu/ExitButton
@onready var pause_menu = $PauseMenu
@onready var restart_button = $Restart
@onready var restart_pause = $PauseMenu/Restart
@onready var high_score_label = $High_Score
@onready var health_bar = $Health_Bar
@onready var health_bar_bg = $Health_Bar_BG
@onready var exp_bar = $Exp_Bar
@onready var exp_bar_bg = $Exp_Bar_BG
@onready var upgrade_menu = $Upgrade_Menu
@onready var upgrade_dim_overlay = $Upgrade_Menu/Upgrade_Dim_Overlay
@onready var first_upgrade_button = $Upgrade_Menu/First_Upgrade
@onready var second_upgrade_button = $Upgrade_Menu/Second_Upgrade
@onready var third_upgrade_button = $Upgrade_Menu/Third_Upgrade
@onready var level_up_timer = $Level_Up_Timer

var score = 0
var first_upgrade: upgrade
var second_upgrade: upgrade
var third_upgrade: upgrade
var upgrades = [
	first_upgrade,
	second_upgrade,
	third_upgrade,
]


func _ready():
	pause_button.connect("pressed", toggle_pause_menu)
	resume_button.connect("pressed", _on_ResumeButton_pressed)
	exit_button.connect("pressed", _on_ExitButton_pressed)
	Global.connect("update_max_health", update_max_health)
	Global.connect("update_health", update_health)
	pause_menu.visible = false
	restart_button.visible = false
	update_max_health(0)
	update_health(0)
	exp_bar.max_value = Global.exp_threshold



func _process(_delta):
	if Input.is_action_just_pressed("Escape"):
		toggle_pause_menu()
	if Global.health <= 0:
		if Input.is_action_just_pressed("shoot"):
			restart()
	if upgrade_menu.visible == true:
		if Input.is_action_just_pressed("reroll"):
			level_up()
	if Input.is_action_just_pressed("Ctrl+L"):
		level_up()


func toggle_pause_menu():
	get_tree().paused = !get_tree().paused
	pause_menu.visible = !pause_menu.visible
	if upgrade_menu.visible == true:
		get_tree().paused = true
		first_upgrade_button.visible = !first_upgrade_button.visible
		second_upgrade_button.visible = !second_upgrade_button.visible
		third_upgrade_button.visible = !third_upgrade_button.visible


func _on_ResumeButton_pressed():
	get_tree().paused = false
	pause_menu.visible = false
	if upgrade_menu.visible == true:
		first_upgrade_button.visible = !first_upgrade_button.visible
		second_upgrade_button.visible = !second_upgrade_button.visible
		third_upgrade_button.visible = !third_upgrade_button.visible
		get_tree().paused = true


func _on_ExitButton_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Screens/Start Screen/StartScreen.tscn")	


func _on_restart_pressed():
	restart()


func restart():
	Global.refresh()
	if get_tree().paused:
		upgrade_menu.visible = false
		toggle_pause_menu()
		GameScene.get_tree().reload_current_scene()
	else:
		GameScene.get_tree().reload_current_scene()


func increase_score(amount):
	score += amount
	score_label.text = "Score: " + str(score)


func update_health(amount):
	Global.health += amount
	health_bar.value = Global.health
	if Global.health <= 0:
		score_label.set("theme_override_font_sizes/font_size", 56)
		score_label.position.y = Global.screen_size.y/2 - 45
		restart_button.visible = true
		high_score_label.visible = true
		high_score_label.text = "High Score: " + str(Global.high_score)
		if score > Global.high_score:
			Global.high_score = score
			Global.save_score()
		GameScene.game_over()


func update_max_health(amount):
	Global.max_health += amount
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
	if Global.exp >= Global.exp_threshold:
		Global.exp -= Global.exp_threshold
		Global.exp_threshold *= 1.2
		exp_bar.max_value = Global.exp_threshold
		exp_bar.value = Global.exp
		level_up()


func _on_first_upgrade_pressed():
	if level_up_timer.time_left == 0:
		get_tree().paused = false
		upgrade_menu.visible = false
		apply_my_upgrade(first_upgrade)


func _on_second_upgrade_pressed():
	if level_up_timer.time_left == 0:
		get_tree().paused = false
		upgrade_menu.visible = false
		apply_my_upgrade(second_upgrade)


func _on_third_upgrade_pressed():
	if level_up_timer.time_left == 0:
		get_tree().paused = false
		upgrade_menu.visible = false
		apply_my_upgrade(third_upgrade)


func _on_reroll_button_pressed():
	level_up()


func level_up():
	get_tree().paused = true
	upgrade_menu.visible = true
	get_upgrades()
	level_up_timer.start()


func get_upgrades():
	Global.upgrades_test.shuffle()

	var buttons = [
		first_upgrade_button,
		second_upgrade_button,
		third_upgrade_button,
	]
	
	for i in range(3):
		var my_upgrade = Global.upgrades_test.pop_front()
		
		if my_upgrade == null:
			buttons[i].text = "null"
			upgrades[i] = null
			continue
			
		buttons[i].text = my_upgrade.upgrade_text
		upgrades[i] = my_upgrade
		
	first_upgrade = upgrades[0]
	second_upgrade = upgrades[1]
	third_upgrade = upgrades[2]


func apply_my_upgrade(my_upgrade):
	
	#if my_upgrade == "damage_up1":
		#Global.damage += 1.5
		#Global.my_upgrades_test[0] = "damage_up2"
	#if my_upgrade == "damage_up2":
		#Global.damage += 2.25
		#Global.attack_speed += (Global.attack_speed * 0.1)
		#Global.my_upgrades_test[0] = "damage_up3"
	#if my_upgrade == "damage_up3":
		#Global.damage += 3
		#Global.attack_speed += (Global.attack_speed * 0.20)
		#Global.my_upgrades_test[0] = " "
	##Attack Speed
	#if my_upgrade == "attack_speed_up1":
		#Global.attack_speed -= (Global.attack_speed * 0.15)
		#Global.my_upgrades_test[1] = "attack_speed_up2"
	#if my_upgrade == "attack_speed_up2":
		#Global.attack_speed -= (Global.attack_speed * 0.15)
		#Global.damage -= 1
		#Global.my_upgrades_test[1] = "attack_speed_up3"
	#if my_upgrade == "attack_speed_up3":
		#Global.attack_speed -= (Global.attack_speed * 0.2)
		#Global.damage -= 2
		#Global.my_upgrades_test[1] = " "
	##Collision Damage
	#if my_upgrade == "collision_damage_up1":
		#Global.collision_damage += 10
		#Global.my_upgrades_test[2] = "collision_damage_up2"
	#if my_upgrade == "collision_damage_up2":
		#Global.collision_damage += 15
		#Global.my_upgrades_test[2] = "collision_damage_up3"
	#if my_upgrade == "collision_damage_up3":
		#Global.collision_damage += 25
		#Global.my_upgrades_test[2] = " "

	#Health
	my_upgrade.upgrade_player()
	Global.upgrades_test.append(my_upgrade.next_upgrade)
	
	##Health Regen
	#if my_upgrade == "health_regen_up1":
		#Global.health_regen += 0.5
		#Global.my_upgrades_test[4] = "health_regen_up2"
	#if my_upgrade == "health_regen_up2":
		#Global.health_regen += 1.5
		#Global.my_upgrades_test[4] = "health_regen_up3"
	#if my_upgrade == "health_regen_up3":
		#Global.health_regen += 3
		#Global.my_upgrades_test[4] = " "
#
	##Move Speed
	#if my_upgrade == "move_speed_up1":
		#Global.move_speed += 100
		#Global.my_upgrades_test[5] = "move_speed_up2"
	#if my_upgrade == "move_speed_up2":
		#Global.move_speed += 150
		#update_max_health(-50)
		#Global.my_upgrades_test[5] = "move_speed_up3"
		#if Global.health > 50:
			#update_health(-50)
	#if my_upgrade == "move_speed_up3":
		#Global.move_speed += 200
		#update_max_health(-50)
		#Global.my_upgrades_test[5] = " "
		#if Global.health > 50:
			#update_health(-50)
	##Counter Thrust
	#if my_upgrade == "counter_thrust_up1":
		#Global.counter_thrust += 100
		#Global.my_upgrades_test[6] = "counter_thrust_up2"
	#if my_upgrade == "counter_thrust_up2":
		#Global.counter_thrust += 150
		#Global.my_upgrades_test[6] = "counter_thrust_up3"
	#if my_upgrade == "counter_thrust_up3":
		#Global.counter_thrust += 250
		#Global.my_upgrades_test[6] = " "
		
	for i in range(upgrades.size()-1):
		upgrades[i] = null
	first_upgrade = null
	second_upgrade = null
	third_upgrade = null
	#print(first_upgrade)
	if my_upgrade == null:
		return
