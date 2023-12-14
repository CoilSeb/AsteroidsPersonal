extends Node

@onready var Ui = get_node("UI")
@onready var ScoreLabel = Ui.get_node("Score_Label")
@onready var spawnTimer = $SpawnTimer
var playerScene = preload("res://Scenes/Player/Player.tscn")
var player = true
var screen_size
var asteroid_scenes = {
	0: preload("res://Scenes/Asteroids/Medium Asteroid/Medium_asteroid.tscn"),
	1: preload("res://Scenes/Asteroids/Small Asteroid/Small_asteroid.tscn"),
	2: preload("res://Scenes/Asteroids/Big Asteroid/Big_Asteroid.tscn")
}

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	if !find_child("Player"):
		player = false
		#print(player)


func _process(_delta): 
	if !player:
		#print(player)
		var playerInstance = playerScene.instantiate()
		add_child(playerInstance)
		playerInstance.position = Vector2(screen_size.x/2, screen_size.y/2)
		#print(playerInstance.position)
		player = true


func game_over():
	
	return
	##print ("game_over")
	##print (get_children())
	#for child in get_children():
		##print("Child: ", child.name)
		#if child.name != "UI": 
			##print("Deleting Child: ", child.name) 
			#child.queue_free()


func spawn_Asteroid():
	var new_asteroid = asteroid_scenes[randi_range(0,2)].instantiate()
	add_child(new_asteroid)
	new_asteroid.position = generate_spawn_point()


func generate_spawn_point() -> Vector2:
	var x = randf_range(-(100 + screen_size.x), screen_size.x + 100)
	var y = randf_range(-(100 + screen_size.y), screen_size.y + 100)
	
	if (x > screen_size.x/2 && x < screen_size.x/2) or (y > screen_size.y/2 && y < screen_size.y/2):
			generate_spawn_point()
		
	return Vector2(x,y)


func _on_spawn_timer_timeout():
	spawn_Asteroid()
