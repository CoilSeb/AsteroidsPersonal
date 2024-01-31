extends CanvasLayer

@onready var high_score_label = $Control/High_Score


# Called when the node enters the scene tree for the first time.
func _ready():
	high_score_label.text = "High Score: " + str(Global.high_score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("shoot"):
		_on_start_pressed()


func _on_start_pressed():
	Global.refresh()
	get_tree().change_scene_to_file("res://Scenes/Screens/Start_Menu/start_menu.tscn")
	Global.weapon = "Gun"


func _on_exit_pressed():
	get_tree().quit()
