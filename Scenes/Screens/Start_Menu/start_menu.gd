extends CanvasLayer


func _ready():
	$Gun_Text.visible = true


func _process(_delta):
	if Input.is_action_just_pressed("shoot"):
		_on_start_pressed()
	$Control/Current_Weapon_Label.text = "Current Weapon: \n" + Global.weapon


func _on_gun_button_pressed():
	delete_text()
	
	Global.weapon = "Gun"
	Global.damage = 10
	$Gun_Text.visible = true


func _on_laser_button_pressed():
	delete_text()
	
	Global.weapon = "Laser"
	Global.damage = 2
	$Laser_Text.visible = true


func _on_start_pressed():
	Global.refresh()
	get_tree().change_scene_to_file("res://Scenes/Screens/GameScene/GameScene.tscn")


func delete_text():
	for child in get_children():
		if child.name.contains("Text"):
			child.visible = false