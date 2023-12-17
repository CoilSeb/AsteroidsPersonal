extends Node2D

@onready var high_score_label = $Control/High_Score


# Called when the node enters the scene tree for the first time.
func _ready():
	high_score_label.text = "High Score: " + str(Global.high_score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("shoot"):
		start()


func start():
	Global.refresh()
	get_tree().change_scene_to_file("res://Scenes/Screens/Game Scene/GameScene.tscn")


func _on_start_pressed():
	start()


func _on_exit_pressed():
	get_tree().quit()
