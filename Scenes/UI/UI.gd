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

var score = 0
var num_of_damage_upgrades = 1
var damage_upgrade = null
var checked_damage = false
var d 
var num_of_health_upgrades = 0
var health_upgrade = null
var checked_health = false
var h
var num_of_utility_upgrades = 0
var utility_upgrade = null
var checked_utility = false
var u 


func _ready():
	pause_button.connect("pressed", toggle_pause_menu)
	resume_button.connect("pressed", _on_ResumeButton_pressed)
	exit_button.connect("pressed", _on_ExitButton_pressed)
	pause_menu.visible = false
	restart_button.visible = false
	update_max_health(5000)



func _process(_delta):
	if Input.is_action_just_pressed("Escape"):
		toggle_pause_menu()
	if Global.health <= 0:
		if Input.is_action_just_pressed("shoot"):
			restart()


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
	health_bar.value = Global.health
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
	health_bar.max_value += amount
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
		Global.exp_threshold *= 1.5
		exp_bar.max_value = Global.exp_threshold
		exp_bar.value = Global.exp
		d = randi_range(0, num_of_damage_upgrades)
		h = randi_range(0, num_of_health_upgrades)
		u = randi_range(0, num_of_utility_upgrades)
		level_up()


func _on_health_upgrade_pressed():
	if health_upgrade != null:
		apply_upgrade(health_upgrade)
	get_tree().paused = false
	upgrade_menu.visible = false
	#pause_menu.visible = false


func _on_damage_upgrade_pressed():
	if damage_upgrade != null:
		apply_upgrade(damage_upgrade)
	get_tree().paused = false
	upgrade_menu.visible = false
	#pause_menu.visible = false


func _on_utility_upgrade_pressed():
	if utility_upgrade != null:
		apply_upgrade(utility_upgrade)
	get_tree().paused = false
	upgrade_menu.visible = false
	#pause_menu.visible = false


func level_up():
	get_tree().paused = true
	upgrade_menu.visible = true
	get_damage_upgrade()
	get_health_upgrade()


func get_damage_upgrade():
	if d == 0 && Global.tier1_damage["damage_up"] == false:
		damage_upgrade = "damage_up"
		damage_upgrade_button.text = "Damage Up \nIncrease bullet damage by 2.5" 
		return
	elif d == 1 && Global.tier1_damage["attack_speed_up"] == false:
		damage_upgrade = "attack_speed_up"
		damage_upgrade_button.text = "Attack Speed Up \nIncrease attack speed by 20%" 
		return 
	else: 
		if(d > num_of_damage_upgrades && checked_damage == true):
			damage_upgrade_button.text = "OUT OF UPGRADES" 
			return
		if(d > num_of_damage_upgrades && checked_damage == false):
			d = -1
			checked_damage = true
		d += 1
		get_damage_upgrade()


func get_health_upgrade():
	if h == 0:
		if Global.health_up["1"] == false:
			health_upgrade = "1"
			health_upgrade_button.text = "Health Up \nIncrease health by 50" 
			return
		if Global.health_up["2"] == false:
			health_upgrade = "2"
			health_upgrade_button.text = "Health Up \nIncrease health by 100 and become % slower" 
			return
		if Global.health_up["3"] == false:
			health_upgrade = "3"
			health_upgrade_button.text = "Health Up \nIncrease health by 150 and become % slower" 
			return
		h += 1
		get_health_upgrade()
	else:
		if(h > num_of_health_upgrades && checked_health == true):
			health_upgrade_button.text = "OUT OF UPGRADES" 
			return
		if(h > num_of_health_upgrades && checked_health == false):
			h = -1
			checked_health = true
		h += 1
		get_health_upgrade()


func apply_upgrade(upgrade):
	if damage_upgrade != null:
		if upgrade == "damage_up":
			Global.damage += 2.5
			Global.tier1_damage["damage_up"] = true
		if upgrade == "attack_speed_up":
			Global.attack_speed += 0.1
			Global.tier1_damage["attack_speed_up"] = true
		damage_upgrade = null
	
	if health_upgrade != null:
		if upgrade == "1":
			update_max_health(50)
			update_health(50)
			Global.health_up["1"] = true
		if upgrade == "2":
			update_max_health(100)
			update_health(100)
			Global.move_speed -= 10
			Global.health_up["2"] = true
		if upgrade == "3":
			update_max_health(150)
			update_health(150)
			Global.move_speed -= 10
			Global.health_up["3"] = true
		health_upgrade = null
