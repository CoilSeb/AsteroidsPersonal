extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_grab_area_2d_area_entered(area):
	var my_upgrade = preload("res://Upgrades/Gun_Upgrades/attack_speed_up.tres")
	my_upgrade.upgrade_player()
	queue_free()
