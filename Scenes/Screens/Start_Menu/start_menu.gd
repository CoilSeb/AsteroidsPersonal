extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var start = $Control/Start


func _ready():
	Global.dev_mode = false
	Global.shader_settings.connect(crt)
	color_rect.material.set_shader_parameter("aberration", Global.aberration)
	color_rect.material.set_shader_parameter("grille_opacity", Global.grille_opacity)
	$Gun_Text.visible = true
	start.grab_focus()


func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_exit_pressed()
	$Control/Current_Weapon_Label.text = "Current Weapon: \n" + Global.weapon


func _on_gun_button_pressed():
	delete_text()
	ButtonClick.play()
	Global.weapon = "Gun"
	Global.damage = 10
	$Gun_Text.visible = true


func _on_laser_button_pressed():
	delete_text()
	ButtonClick.play()
	Global.weapon = "Laser"
	Global.damage = 2
	$Laser_Text.visible = true


func _on_start_pressed():
	ButtonClick.play()
	Global.refresh()
	get_tree().change_scene_to_file("res://Scenes/Screens/GameScene/GameScene.tscn")


func delete_text():
	for child in get_children():
		if child.name.contains("Text"):
			child.visible = false


func crt(value):
	color_rect.material.set_shader_parameter("aberration", Global.aberration)
	color_rect.material.set_shader_parameter("grille_opacity", Global.grille_opacity)


func _on_exit_pressed():
	ButtonClick.play()
	get_tree().change_scene_to_file("res://Scenes/Screens/Start Screen/StartScreen.tscn")


func _on_check_box_toggled(toggled_on):
	if toggled_on:
		Global.dev_mode = true
	else: 
		Global.dev_mode = false
