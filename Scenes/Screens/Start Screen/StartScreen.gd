extends CanvasLayer

@onready var high_score_label = $Control/High_Score
@onready var color_rect = $ColorRect
@onready var settings_menu = $SettingsMenu
@onready var exit_button = $SettingsMenu/ExitButton


func _ready():
	Global.shader_settings.connect(crt)
	color_rect.material.set_shader_parameter("aberration", Global.aberration)
	color_rect.material.set_shader_parameter("grille_opacity", Global.grille_opacity)
	high_score_label.text = "High Score: " + Global.get_score_text(Global.high_score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("shoot"):
		_on_start_pressed()


func _on_start_pressed():
	Global.weapon = "Gun"
	get_tree().change_scene_to_file("res://Scenes/Screens/Start_Menu/start_menu.tscn")


func _on_exit_button_pressed():
	#settings menu exit button
	settings_menu.hide()


func _on_settings_pressed():
	settings_menu.show()


func _on_exit_pressed():
	get_tree().quit()


func crt():
	color_rect.material.set_shader_parameter("aberration", Global.aberration)
	color_rect.material.set_shader_parameter("grille_opacity", Global.grille_opacity)
