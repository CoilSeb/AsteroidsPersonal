extends CanvasLayer

@onready var high_score_label = $Control/High_Score
@onready var color_rect = $ColorRect
@onready var h_slider = $Control/HSlider


func _ready():
	Global.shader_settings.connect(crt)
	color_rect.material.set_shader_parameter("aberration", Global.aberration)
	color_rect.material.set_shader_parameter("grille_opacity", Global.grille_opacity)
	h_slider.value = Global.aberration * 20000
	high_score_label.text = "High Score: " + Global.get_score_text(Global.high_score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("shoot"):
		_on_start_pressed()


func _on_start_pressed():
	Global.weapon = "Gun"
	get_tree().change_scene_to_file("res://Scenes/Screens/Start_Menu/start_menu.tscn")


func _on_exit_pressed():
	get_tree().quit()


func crt():
	color_rect.material.set_shader_parameter("aberration", Global.aberration)
	color_rect.material.set_shader_parameter("grille_opacity", Global.grille_opacity)


func _on_h_slider_value_changed(value):
	Global.shader_settings.emit()
	Global.aberration = value / 20000
	Global.grille_opacity = value / 333
