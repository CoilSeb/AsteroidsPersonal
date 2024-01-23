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
@onready var health_upgrade_button = $Upgrade_Menu/Health_Upgrade
@onready var damage_upgrade_button = $Upgrade_Menu/Damage_Upgrade
@onready var utility_upgrade_button = $Upgrade_Menu/Utility_Upgrade
@onready var level_up_timer = $Level_Up_Timer

var score = 0
var num_of_damage_upgrades = 2
var damage_upgrade = null
var d 
var d_catch
var num_of_health_upgrades = 1
var health_upgrade = null
var h
var h_catch
var num_of_utility_upgrades = 1
var utility_upgrade = null
var u 
var u_catch


func _ready():
	pause_button.connect("pressed", toggle_pause_menu)
	resume_button.connect("pressed", _on_ResumeButton_pressed)
	exit_button.connect("pressed", _on_ExitButton_pressed)
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


func toggle_pause_menu():
	get_tree().paused = !get_tree().paused
	pause_menu.visible = !pause_menu.visible
	if upgrade_menu.visible == true:
		get_tree().paused = true
		health_upgrade_button.visible = !health_upgrade_button.visible
		damage_upgrade_button.visible = !damage_upgrade_button.visible
		utility_upgrade_button.visible = !utility_upgrade_button.visible


func _on_ResumeButton_pressed():
	get_tree().paused = false
	pause_menu.visible = false
	if upgrade_menu.visible == true:
		health_upgrade_button.visible = !health_upgrade_button.visible
		damage_upgrade_button.visible = !damage_upgrade_button.visible
		utility_upgrade_button.visible = !utility_upgrade_button.visible
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
	#print("Health: ", Global.health)
	health_bar.value = Global.health
	#print("Health_Bar: ", health_bar.value)
	#print(health_bar.value)
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
	#print("Max_Health: ", Global.max_health)
	health_bar.max_value = Global.max_health
	#print("Health_Bar_Max: ", health_bar.max_value)
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


func _on_health_upgrade_pressed():
	if level_up_timer.time_left == 0:
		if health_upgrade != null:
			apply_upgrade(health_upgrade)
		get_tree().paused = false
		upgrade_menu.visible = false
		#pause_menu.visible = false


func _on_damage_upgrade_pressed():
	if level_up_timer.time_left == 0:
		if damage_upgrade != null:
			apply_upgrade(damage_upgrade)
		get_tree().paused = false
		upgrade_menu.visible = false
		#pause_menu.visible = false


func _on_utility_upgrade_pressed():
	if level_up_timer.time_left == 0:
		if utility_upgrade != null:
			apply_upgrade(utility_upgrade)
		get_tree().paused = false
		upgrade_menu.visible = false
		#pause_menu.visible = false


func _on_reroll_button_pressed():
	level_up()


func level_up():
	d = randi_range(0, num_of_damage_upgrades)
	h = randi_range(0, num_of_health_upgrades)
	u = randi_range(0, num_of_utility_upgrades)
	d_catch = null
	h_catch = null
	u_catch = null
	get_tree().paused = true
	upgrade_menu.visible = true
	get_damage_upgrade()
	get_health_upgrade()
	get_utility_upgrade()
	level_up_timer.start()


func get_damage_upgrade():
	if(d_catch == d):
		print("Out d_catch: ", d_catch, " d: ", d)
		damage_upgrade_button.text = "OUT OF UPGRADES" 
		return
		
	else:
		if d == 0:
			if Global.damage_up["damage_up1"] == false:
				damage_upgrade = "damage_up1"
				damage_upgrade_button.text = "Damage Up \n\n\nIncrease bullet damage by 1.5" 
				return
			if Global.damage_up["damage_up2"] == false:
				damage_upgrade = "damage_up2"
				damage_upgrade_button.text = "Damage Up + \n\n\nIncrease bullet damage by 2.25 \nDecrease attack speed by 5%"
				return
			if Global.damage_up["damage_up3"] == false:
				damage_upgrade = "damage_up3"
				damage_upgrade_button.text = "Damage Up ++ \n\n\nIncrease bullet damage by 3 \nDecrease attack speed by 10%" 
				return
			if d_catch == null:
				print("d_catch: ", d_catch, " d: ", d)
				d_catch = d
			d += 1
			get_damage_upgrade()
			
		elif d == 1:
			if Global.attack_speed_up["attack_speed_up1"] == false:
				damage_upgrade = "attack_speed_up1"
				damage_upgrade_button.text = "Attack Speed Up \n\n\nIncrease attack speed by 10%"
				return
			if Global.attack_speed_up["attack_speed_up2"] == false:
				damage_upgrade = "attack_speed_up2"
				damage_upgrade_button.text = "Attack Speed Up + \n\n\nIncrease attack speed by 15% \nDecrease bullet damage by 1"
				return
			if Global.attack_speed_up["attack_speed_up3"] == false:
				damage_upgrade = "attack_speed_up3"
				damage_upgrade_button.text = "Attack Speed Up ++ \n\n\nIncrease attack speed by 20% \nDecrease bullet damage by 2"
				return
			if d_catch == null:
				d_catch = d
				print("d_catch: ", d_catch, " d: ", d)
			d += 1 
			get_damage_upgrade()
			
		elif d == 2:
			if Global.collision_damage_up["collision_damage_up1"] == false:
				damage_upgrade = "collision_damage_up1"
				damage_upgrade_button.text = "Collision Damage Up \n\n\nIncrease collsion damage by 10"
				return
			if Global.collision_damage_up["collision_damage_up2"] == false:
				damage_upgrade = "collision_damage_up2"
				damage_upgrade_button.text = "Collision Damage Up + \n\n\nIncrease collsion damage by 15"
				return
			if Global.collision_damage_up["collision_damage_up3"] == false:
				damage_upgrade = "collision_damage_up3"
				damage_upgrade_button.text = "Collision Damage Up ++ \n\n\nIncrease collsion damage by 25"
				return
			if d_catch == null:
				d_catch = d
				print("d_catch: ", d_catch, " d: ", d)
			d += 1 
			get_damage_upgrade()
			
		else:
			d = 0
			print("new d: ", d)
			get_damage_upgrade()



func get_health_upgrade():
	#print("health_regen_up1 = ", Global.health_regen_up["health_regen_up1"])
	#print("health_regen_up2 = ", Global.health_regen_up["health_regen_up2"])
	#print("health_regen_up3 = ", Global.health_regen_up["health_regen_up3"])
	#print("health_up1 = ", Global.health_up["health_up1"])
	#print("health_up2 = ", Global.health_up["health_up2"])
	#print("health_up3 = ", Global.health_up["health_up3"])

	if(h_catch == h):
		print("Out h_catch: ", h_catch, " h: ", h)
		health_upgrade_button.text = "OUT OF UPGRADES" 
		return
		
	else:
		if h == 0:
			if Global.health_up["health_up1"] == false:
				health_upgrade = "health_up1"
				health_upgrade_button.text = "Health Up \n\n\nIncrease max health by 50" 
				return
			if Global.health_up["health_up2"] == false:
				health_upgrade = "health_up2"
				health_upgrade_button.text = "Health Up + \n\n\nIncrease max health by 100 \nReduce thrust by 10" 
				return
			if Global.health_up["health_up3"] == false:
				health_upgrade = "health_up3"
				health_upgrade_button.text = "Health Up ++ \n\n\nIncrease max health by 150 \nReduce thrust by 10" 
				return
				
			if h_catch == null:
				h_catch = h
				print("h_catch: ", h_catch, " h: ", h)
			h += 1
			get_health_upgrade()
			
		elif h == 1:
			if Global.health_regen_up["health_regen_up1"] == false:
				health_upgrade = "health_regen_up1"
				health_upgrade_button.text = "Health Regen Up \n\n\nIncrease health regeneration by 0.5" 
				return
			if Global.health_regen_up["health_regen_up2"] == false:
				health_upgrade = "health_regen_up2"
				health_upgrade_button.text = "Health Regen Up + \n\n\nIncrease health regeneration by 1.5" 
				return
			if Global.health_regen_up["health_regen_up3"] == false:
				health_upgrade = "health_regen_up3"
				health_upgrade_button.text = "Health Regen Up ++ \n\n\nIncrease health regeneration by 3" 
				return
				
			if h_catch == null:
				h_catch = h
				print("h_catch: ", h_catch, " h: ", h)
			h += 1
			get_health_upgrade()
			
		else:
			h = 0
			get_health_upgrade()


func get_utility_upgrade():
	if(u_catch == u):
		print("Out U_catch: ", u_catch, " U: ", u)
		utility_upgrade_button.text = "OUT OF UPGRADES" 
		return
		
	else:
		if u == 0:
			if Global.move_speed_up["move_speed_up1"] == false:
				utility_upgrade = "move_speed_up1"
				utility_upgrade_button.text = "Move Speed Up \n\n\nIncrease move speed by 10" 
				return
			if Global.move_speed_up["move_speed_up2"] == false:
				utility_upgrade = "move_speed_up2"
				utility_upgrade_button.text = "Move Speed Up + \n\n\nIncrease move speed by 15 \nReduce max health by 50" 
				return
			if Global.move_speed_up["move_speed_up3"] == false:
				utility_upgrade = "move_speed_up3"
				utility_upgrade_button.text = "Move Speed Up ++ \n\n\nIncrease move speed by 20 \nReduce max health by 75" 
				return
				
			if u_catch == null:
				u_catch = u
				print("U_catch: ", u_catch, " U: ", u)
			u += 1
			get_utility_upgrade()
			
		elif u == 1:
			if Global.counter_thrust_up["counter_thrust_up1"] == false:
				utility_upgrade = "counter_thrust_up1"
				utility_upgrade_button.text = "Counter Thrust Up \n\n\nPress 'S' to counter thrust \n Increase counter thrust by 10" 
				return
			if Global.counter_thrust_up["counter_thrust_up2"] == false:
				utility_upgrade = "counter_thrust_up2"
				utility_upgrade_button.text = "Counter Thrust Up + \n\n\nIncrease counter thrust by 15" 
				return
			if Global.counter_thrust_up["counter_thrust_up3"] == false:
				utility_upgrade = "counter_thrust_up3" 
				utility_upgrade_button.text = "Counter Thrust Up ++ \n\n\nIncrease counter thrust by 25" 
				return
				
			if u_catch == null:
				u_catch = u
				print("U_catch: ", u_catch, " U: ", u)
			u += 1
			get_utility_upgrade()
			
		else:
			u = 0
			get_utility_upgrade()


func apply_upgrade(upgrade):
	if damage_upgrade != null:
		#Bullet_Damage
		if upgrade == "damage_up1":
			Global.damage += 1.5
			Global.damage_up["damage_up1"] = true
		if upgrade == "damage_up2":
			Global.damage += 2.25
			Global.attack_speed += (Global.attack_speed * 0.1)
			Global.damage_up["damage_up2"] = true
		if upgrade == "damage_up3":
			Global.damage += 3
			Global.attack_speed += (Global.attack_speed * 0.20)
			Global.damage_up["damage_up3"] = true
		#Attack Speed
		if upgrade == "attack_speed_up1":
			Global.attack_speed -= (Global.attack_speed * 0.15)
			Global.attack_speed_up["attack_speed_up1"] = true
		if upgrade == "attack_speed_up2":
			Global.attack_speed -= (Global.attack_speed * 0.15)
			Global.damage -= 1
			Global.attack_speed_up["attack_speed_up2"] = true
		if upgrade == "attack_speed_up3":
			Global.attack_speed -= (Global.attack_speed * 0.2)
			Global.damage -= 2
			Global.attack_speed_up["attack_speed_up3"] = true
		#Collision Damage
		if upgrade == "collision_damage_up1":
			Global.collision_damage += 10
			Global.collision_damage_up["collision_damage_up1"] = true
		if upgrade == "collision_damage_up2":
			Global.collision_damage += 15
			Global.collision_damage_up["collision_damage_up2"] = true
		if upgrade == "collision_damage_up3":
			Global.collision_damage += 25
			Global.collision_damage_up["collision_damage_up3"] = true
		damage_upgrade = null
	
	if health_upgrade != null:
		#Health
		if upgrade == "health_up1":
			update_max_health(50)
			update_health(50)
			Global.health_up["health_up1"] = true
		if upgrade == "health_up2":
			update_max_health(100)
			update_health(100)
			Global.move_speed -= 10
			Global.health_up["health_up2"] = true
		if upgrade == "health_up3":
			update_max_health(150)
			update_health(150)
			Global.move_speed -= 15
			Global.health_up["health_up3"] = true
		#Health Regen
		if upgrade == "health_regen_up1":
			Global.health_regen += 0.5
			Global.health_regen_up["health_regen_up1"] = true
		if upgrade == "health_regen_up2":
			Global.health_regen += 1.5
			Global.health_regen_up["health_regen_up2"] = true
		if upgrade == "health_regen_up3":
			Global.health_regen += 3
			Global.health_regen_up["health_regen_up3"] = true
		health_upgrade = null
	
	if utility_upgrade != null:
		#Move Speed
		if upgrade == "move_speed_up1":
			Global.move_speed += 10
			Global.move_speed_up["move_speed_up1"] = true
		if upgrade == "move_speed_up2":
			Global.move_speed += 15
			update_max_health(-50)
			if Global.health > 50:
				update_health(-50)
			Global.move_speed_up["move_speed_up2"] = true
		if upgrade == "move_speed_up3":
			Global.move_speed += 20
			update_max_health(-50)
			if Global.health > 50:
				update_health(-50)
			Global.move_speed_up["move_speed_up3"] = true
		#Counter Thrust
		if upgrade == "counter_thrust_up1":
			Global.counter_thrust += 10
			Global.counter_thrust_up["counter_thrust_up1"] = true
		if upgrade == "counter_thrust_up2":
			Global.counter_thrust += 15
			Global.counter_thrust_up["counter_thrust_up2"] = true
		if upgrade == "counter_thrust_up3":
			Global.counter_thrust += 25
			Global.counter_thrust_up["counter_thrust_up3"] = true
		utility_upgrade = null
		
	print("\n\n\n")
