extends CanvasLayer

@onready var high_score_label = $Control/High_Score
@onready var color_rect = $ColorRect
@onready var settings_menu = $SettingsMenu
@onready var exit_button = $SettingsMenu/ExitButton
@onready var start = $Control/Start
@onready var settings_button = $Control/Settings
@onready var audio_stream_player_2d = $AudioStreamPlayer2D


func _ready():
	Global.shader_settings.connect(crt)
	color_rect.material.set_shader_parameter("aberration", Global.aberration)
	color_rect.material.set_shader_parameter("grille_opacity", Global.grille_opacity)
	high_score_label.text = "High Score: " + Global.get_score_text(Global.high_score)
	start.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_start_pressed():
	ButtonClick.play()
	Global.weapon = "Gun"
	get_tree().change_scene_to_file("res://Scenes/Screens/Start_Menu/start_menu.tscn")


func _on_settings_pressed():
	ButtonClick.play()
	settings_menu.show()


func _on_exit_pressed():
	get_tree().quit()


func crt():
	color_rect.material.set_shader_parameter("aberration", Global.aberration)
	color_rect.material.set_shader_parameter("grille_opacity", Global.grille_opacity)
