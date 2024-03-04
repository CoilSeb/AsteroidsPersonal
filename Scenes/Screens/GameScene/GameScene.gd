extends Node

@onready var Ui = get_node("UI")
@onready var ScoreLabel = Ui.get_node("Score_Label")
@onready var spawnTimer = $SpawnTimer
@onready var wave_timer = $WaveTimer

var playerScene = preload("res://Scenes/Player/Player.tscn")
var player = true
var screen_size
var wave_timer_time = 10
var wave_time = 35
var wave_num = 0
var enemies

var basic_asteroid_scenes = {
	0: preload("res://Scenes/Asteroids/Medium Asteroid/Medium_asteroid.tscn"),
	1: preload("res://Scenes/Asteroids/Small Asteroid/Small_asteroid.tscn"),
	2: preload("res://Scenes/Asteroids/Big Asteroid/Big_Asteroid.tscn")
}

var special_asteroid_scenes = {
	0: preload("res://Scenes/Asteroids/Shard Asteroid/Shard_Asteroid.tscn"),
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
	#if wave_timer.time_left == 0:
		#spawn_wave()
	enemies = get_tree().get_nodes_in_group("Enemy")



func game_over():
	
	return
	##print ("game_over")
	##print (get_children())
	#for child in get_children():
		##print("Child: ", child.name)
		#if child.name != "UI": 
			##print("Deleting Child: ", child.name) 
			#child.queue_free()


func spawn_basic_Asteroid():
	var new_asteroid = basic_asteroid_scenes[randi_range(0,2)].instantiate()
	add_child(new_asteroid)
	new_asteroid.global_position = generate_spawn_point()


func spawn_special_Asteroid():
	var new_asteroid = special_asteroid_scenes[randi_range(0,2)].instantiate()
	add_child(new_asteroid)
	new_asteroid.global_position = generate_spawn_point()


func random_vector(left, right, bottom, top):
	return Vector2(randf_range(left, right), randf_range(bottom, top))


func generate_spawn_point():
	var locations = [
		# Upper Rectangle
		random_vector(0, screen_size.x, screen_size.y, screen_size.y),
		# Lower Rectangle
		random_vector(0, screen_size.x, -screen_size.y, -screen_size.y),
		# Right Rectangle
		random_vector(screen_size.x, screen_size.x, 0, screen_size.y),
		# Left Rectangle
		random_vector(-screen_size.x, -screen_size.x, 0, screen_size.y),
	]
	return locations[randi_range(0,3)]


func _on_spawn_timer_timeout():
	spawn_wave()


func spawn_wave():
	if wave_num == 0 && enemies.size() == 0:
		wave_num += 1
		for i in range(5):
			spawn_basic_Asteroid()
		return
	if wave_num == 1 && enemies.size() == 0:
		wave_num += 1
		for i in range(9):
			spawn_basic_Asteroid()
		for i in range(1):
			spawn_special_Asteroid()
		return
	if wave_num == 2 && enemies.size() == 0:
		wave_num += 1
		for i in range(8):
			spawn_basic_Asteroid()
		for i in range(2):
			spawn_special_Asteroid()
		return
