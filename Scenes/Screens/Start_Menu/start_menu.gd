extends CanvasLayer


func _ready():
	pass


func _process(_delta):
	if Input.is_action_just_pressed("shoot"):
		_on_start_pressed()
	$Control/Current_Weapon_Label.text = "Current Weapon: \n" + Global.weapon


func _on_gun_button_pressed():
	Global.weapon = "Gun"
	Global.damage = 10


func _on_laser_button_pressed():
	Global.weapon = "Laser"
	Global.damage = 2


func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/Screens/GameScene/GameScene.tscn")
