extends CanvasLayer

@onready var GameScene = get_parent()
@onready var score_label = $Score_Label
@onready var pause_button = $PauseButton
@onready var dim_overlay = $PauseMenu/DimOverlay
@onready var resume_button = $PauseMenu/ResumeButton
@onready var exit_button  = $PauseMenu/ExitButton
@onready var pause_menu = $PauseMenu
@onready var restart_button = $Restart
@onready var restart_pause = $PauseMenu/Restart
@onready var high_score_label = $High_Score
@onready var health_bar = $Health_Bar
@onready var exp_bar = $Exp_Bar
var score = 0


func _ready():
	pause_button.connect("pressed", toggle_pause_menu)
	resume_button.connect("pressed", _on_ResumeButton_pressed)
	exit_button.connect("pressed", _on_ExitButton_pressed)
	pause_menu.visible = false
	dim_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	restart_button.visible = false
	restart_pause.visible = false
	high_score_label.visible = false
	health_bar.max_value = Global.health
	Global.exp = 0


func _process(_delta):
	if Input.is_action_just_pressed("Escape"):
		toggle_pause_menu()
	if Global.health <= 0:
		if Input.is_action_just_pressed("shoot"):
			restart()


func toggle_pause_menu():
	if get_tree().paused:
		# If the game is currently paused, unpause it
		dim_overlay.visible = false
		get_tree().paused = false
		pause_menu.visible = false
		restart_pause.visible = false
	else:
		# If the game is currently running, pause it
		dim_overlay.visible = true
		get_tree().paused = true
		pause_menu.visible = true
		restart_pause.visible = true


func _on_ResumeButton_pressed():
	dim_overlay.visible = false
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

func update_exp(amount):
	Global.exp += amount
	exp_bar.value = Global.exp
	if Global.exp >= Global.exp_threshold:
		Global.exp -= Global.exp_threshold
		Global.exp_threshold *= 1.5
		exp_bar.max_value = Global.exp_threshold
		exp_bar.value = Global.exp


func _on_restart_pressed():
	restart()


func restart():
	Global.health = 500
	Global.damage_multiplier = 1.0
	Global.collision_damage = 10
	Global.exp = 0
	Global.exp_level = 0
	Global.exp_threshold = 100
	if get_tree().paused:
		toggle_pause_menu()
		GameScene.get_tree().reload_current_scene()
	else:
		GameScene.get_tree().reload_current_scene()

