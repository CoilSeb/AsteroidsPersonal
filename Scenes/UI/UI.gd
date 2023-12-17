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
var damage_upgrade
var health_upgrade
var utility_upgrade
var upgrading

func _ready():
	pause_button.connect("pressed", toggle_pause_menu)
	resume_button.connect("pressed", _on_ResumeButton_pressed)
	exit_button.connect("pressed", _on_ExitButton_pressed)
	pause_menu.visible = false
	restart_button.visible = false
	restart_pause.visible = false
	high_score_label.visible = false
	Global.exp = 0
	update_max_health(50000)



func _process(_delta):
	if Input.is_action_just_pressed("Escape"):
		toggle_pause_menu()
	if Global.health <= 0:
		if Input.is_action_just_pressed("shoot"):
			restart()


func toggle_pause_menu():
	if get_tree().paused:
		# If the game is currently paused, unpause it
		pause_dim_overlay.visible = false
		get_tree().paused = false
		pause_menu.visible = false
		restart_pause.visible = false
	else:
		# If the game is currently running, pause it
		pause_dim_overlay.visible = true
		get_tree().paused = true
		pause_menu.visible = true
		restart_pause.visible = true


func _on_ResumeButton_pressed():
	pause_dim_overlay.visible = false
	get_tree().paused = false
	pause_menu.visible = false


func _on_ExitButton_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Screens/Start Screen/StartScreen.tscn")


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
	health_bar.max_value = amount
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
		level_up()


func _on_health_upgrade_pressed():
	get_upgrade(health_upgrade)


func _on_damage_upgrade_pressed():
	if damage_upgrade != null:
		get_upgrade(damage_upgrade)
	get_tree().paused = false


func _on_utility_upgrade_pressed():
	get_upgrade(utility_upgrade)


func level_up():
	get_tree().paused = true
	upgrade_menu.visible = true
	var d = randi_range(0,1)
	if d == 0 && Global.tier1_damage["damage_up"] == false:
		damage_upgrade = "damage_up"
		damage_upgrade_button.text = "Damage Up \nIncrease bullet damage by 5" 
		return
	elif d == 1 && Global.tier1_damage["attack_speed_up"] == false:
		damage_upgrade = "attack_speed_up"
		damage_upgrade_button.text = "Attack Speed Up \nIncrease attack speed by 20%" 
		return 
	else: 
		print("Working")
		damage_upgrade = null
		damage_upgrade_button.text = "VOID" 
		return
	level_up()


func get_upgrade(upgrade):
	if upgrade == "damage_up":
		Global.damage += 5
		Global.tier1_damage["damage_up"] = true
	if upgrade == "attack_speed_up":
		Global.attack_speed += 0.2
		Global.tier1_damage["attack_speed_up"] = true
	upgrade_menu.visible = false


func _on_restart_pressed():
	restart()


func restart():
	Global.health = 300
	Global.max_health = 300
	Global.damage = 0
	Global.attack_speed = 1
	Global.bullet_speed = 0
	Global.collision_damage = 10
	Global.exp = 0
	Global.exp_level = 0
	Global.exp_threshold = 100
	
	if get_tree().paused:
		toggle_pause_menu()
		GameScene.get_tree().reload_current_scene()
	else:
		GameScene.get_tree().reload_current_scene()
