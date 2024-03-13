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
@onready var levels_label = $Levels_Label
@onready var settings_menu = $SettingsMenu
@onready var h_slider = $SettingsMenu/HSlider
@onready var settings_exit_button = $SettingsMenu/ExitButton
@onready var crt_shader = $CRT_Shader

@onready var buttons = [
	$Upgrade_Menu/First_Upgrade,
	$Upgrade_Menu/Second_Upgrade,
	$Upgrade_Menu/Third_Upgrade
]

@onready var textures = [
	$Upgrade_Menu/First_Upgrade/TextureRect1,
	$Upgrade_Menu/Second_Upgrade/TextureRect2,
	$Upgrade_Menu/Third_Upgrade/TextureRect3,
] 

@onready var text_labels = [
	$Upgrade_Menu/First_Upgrade/RichTextLabel1,
	$Upgrade_Menu/Second_Upgrade/RichTextLabel2,
	$Upgrade_Menu/Third_Upgrade/RichTextLabel3
]

var score = 0
var first_upgrade: upgrade
var second_upgrade: upgrade
var third_upgrade: upgrade
var levels = 0
var upgrades = [
	first_upgrade,
	second_upgrade,
	third_upgrade,
]


func _ready():
	Global.shader_settings.connect(crt)
	h_slider.value = Global.grille_opacity * 200
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
	if Input.is_action_just_pressed("Escape"):
		toggle_pause_menu()
	if Global.health <= 0:
		if Input.is_action_just_pressed("shoot"):
			restart()
	if upgrade_menu.visible == true:
		if Input.is_action_just_pressed("reroll"):
			level_up()
	if Input.is_action_just_pressed("reroll") && levels > 0:
		level_up()
		
	$PauseMenu/VBoxContainer/Health_Label.text = "Health: " + str(snapped(Global.health, 1)) + " / " + str(Global.max_health)
	$PauseMenu/VBoxContainer/Health_Regen_Label.text = "Health Regen: " + str(Global.health_regen) + " (sec)"
	$PauseMenu/VBoxContainer/Damage_Reduction_Label.text = "Damage Reduction: " + str(snapped(Global.damage_reduction * 100, 0.1)) + "%"
	$PauseMenu/VBoxContainer/Collision_Damage_Label.text = "Collision Damage: " + str(Global.collision_damage)
	$PauseMenu/VBoxContainer/Weapon_Damage_Label.text = "Weapon Damage: " + str(snapped(Global.damage, 0.01))
	$PauseMenu/VBoxContainer/Attack_Speed_Label.text = "Attack Cooldown: " + str(snapped(Global.attack_speed, 0.01)) + " (sec)"
	$PauseMenu/VBoxContainer/Bullet_Velocity_Label.text = "Bullet Velocity: " + str(Global.bullet_velocity)
	$PauseMenu/VBoxContainer/Move_Speed_Label.text = "Thrust: " + str(Global.move_speed)
	$PauseMenu/VBoxContainer/Counter_Thrust_Label.text = "Counter Thrust: " + str(Global.counter_thrust)


func crt():
	crt_shader.material.set_shader_parameter("aberration", Global.aberration)
	crt_shader.material.set_shader_parameter("grille_opacity", Global.grille_opacity)


func _on_h_slider_value_changed(value):
	Global.shader_settings.emit()
	Global.aberration = value / 33333
	Global.grille_opacity = value / 200


func _on_exit_button_pressed():
	#settings menu exit button
	settings_menu.hide()


func toggle_pause_menu():
	get_tree().paused = !get_tree().paused
	pause_menu.visible = !pause_menu.visible
	if upgrade_menu.visible == true:
		get_tree().paused = true
		for button in buttons:
			button.visible != button.visible


func _on_ResumeButton_pressed():
	get_tree().paused = false
	pause_menu.visible = false
	if upgrade_menu.visible == true:
		for button in buttons:
			button.visible = true
		get_tree().paused = true


func _on_settings_button_pressed():
	settings_menu.show()


func _on_ExitButton_pressed():
	#pause menu exit button
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
	if Global.exp >= Global.exp_threshold:
		Global.exp -= Global.exp_threshold
		Global.exp_threshold *= 1.1
		exp_bar.max_value = Global.exp_threshold
		exp_bar.value = Global.exp
		levels += 1
	if levels == 1:
		levels_label.text = "'R' to level up (" + str(levels) + " level stored)"
		levels_label.show()
	if levels > 1:
		levels_label.text = "'R' to level up (" + str(levels) + " levels stored)"
		levels_label.show()


func _on_first_upgrade_pressed():
	if level_up_timer.time_left == 0:
		get_tree().paused = false
		upgrade_menu.visible = false
		apply_my_upgrade(first_upgrade, 0)


func _on_second_upgrade_pressed():
	if level_up_timer.time_left == 0:
		get_tree().paused = false
		upgrade_menu.visible = false
		apply_my_upgrade(second_upgrade, 1)


func _on_third_upgrade_pressed():
	if level_up_timer.time_left == 0:
		get_tree().paused = false
		upgrade_menu.visible = false
		apply_my_upgrade(third_upgrade, 2)


func _on_reroll_button_pressed():
	level_up()


func level_up():
	if !upgrade_menu.visible:
		levels -= 1
	update_max_exp()
	if levels == 0:
		levels_label.hide()
	get_tree().paused = true
	upgrade_menu.visible = true
	get_upgrades()
	level_up_timer.start()


func get_upgrades():
	Global.upgrades_test.shuffle()

	for i in range(3):
		if Global.upgrades_test.size() - 1 >= i:
			var my_upgrade = Global.upgrades_test[i]
			
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


func apply_my_upgrade(my_upgrade, index):
	if my_upgrade == null:
		return
	Global.upgrades_test.pop_at(index)
	my_upgrade.upgrade_player()
	if my_upgrade.next_upgrade != null:
		Global.upgrades_test.append(my_upgrade.next_upgrade)
		
	for i in range(upgrades.size()-1):
		upgrades[i] = null
	first_upgrade = null
	second_upgrade = null
	third_upgrade = null
