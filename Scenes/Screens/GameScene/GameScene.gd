extends Node

@onready var Ui = get_node("UI")
@onready var ScoreLabel = Ui.get_node("Score_Label")
@onready var spawnTimer = $SpawnTimer
@onready var wave_timer = $WaveTimer
@onready var timer = $Timer
@onready var moon_guy_warning = $Moon_Guy_Warning

var playerScene = preload("res://Scenes/Player/Player.tscn")
var player = true
var screen_size
var wave_timer_time = 10
var wave_time = 35
var wave_num = 0
var start_moon_guy_warning = false

var basic_asteroid_scenes = {
	0: preload("res://Scenes/Asteroids/Medium Asteroid/Medium_asteroid.tscn"),
	1: preload("res://Scenes/Asteroids/Small Asteroid/Small_asteroid.tscn"),
	2: preload("res://Scenes/Asteroids/Big Asteroid/Big_Asteroid.tscn")
}

var special_asteroid_scenes = {
	0: preload("res://Scenes/Asteroids/Shard Asteroid/Shard_Asteroid.tscn"),
}

var moon_guy_scene = preload("res://Scenes/Asteroids/Moon_Guy/Moon_Guy.tscn")

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
	#print(Global.enemy_weight)
	
	if start_moon_guy_warning:
		if moon_guy_warning.scale <= Vector2(16, 16):
			moon_guy_warning.scale += Vector2(0.05, 0.05)
		else:
			moon_guy_warning.hide()
			var moon_guy = moon_guy_scene.instantiate()
			add_child(moon_guy)
			moon_guy.global_position = screen_size/2
			moon_guy.weighted = true
			start_moon_guy_warning = false


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
	var new_asteroid = basic_asteroid_scenes[randi_range(0,basic_asteroid_scenes.size() - 1)].instantiate()
	add_child(new_asteroid)
	new_asteroid.global_position = generate_spawn_point()


func spawn_special_Asteroid():
	var new_asteroid = special_asteroid_scenes[randi_range(0,special_asteroid_scenes.size() - 1)].instantiate()
	add_child(new_asteroid)
	new_asteroid.global_position = generate_spawn_point()


func spawn_basic_Asteroid_with_weight():
	var new_asteroid = basic_asteroid_scenes[randi_range(0,basic_asteroid_scenes.size() - 1)].instantiate()
	add_child(new_asteroid)
	new_asteroid.global_position = generate_spawn_point()
	new_asteroid.weighted = true


func spawn_special_Asteroid_with_weight():
	var new_asteroid = special_asteroid_scenes[randi_range(0,special_asteroid_scenes.size() - 1)].instantiate()
	add_child(new_asteroid)
	new_asteroid.global_position = generate_spawn_point()
	new_asteroid.weighted = true


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
	if wave_num == 0 && Global.enemy_weight <= 12:
		wave_num += 1
		for i in range(7):
			spawn_basic_Asteroid_with_weight()
		for i in range(3):
			spawn_special_Asteroid_with_weight()
		return
	if wave_num == 1 && Global.enemy_weight <= 12:
		wave_num += 1
		for i in range(6):
			spawn_basic_Asteroid_with_weight()
		for i in range(4):
			spawn_special_Asteroid_with_weight()
		return
	if wave_num == 2 && Global.enemy_weight <= 12:
		wave_num += 1
		for i in range(8):
			spawn_basic_Asteroid_with_weight()
		for i in range(4):
			spawn_special_Asteroid_with_weight()
		return
	if wave_num == 3 && Global.enemy_weight <= 12:
		wave_num += 1
		for i in range(10):
			spawn_basic_Asteroid_with_weight()
		for i in range(4):
			spawn_special_Asteroid_with_weight()
		return
	if wave_num == 4 && Global.enemy_weight <= 0:
		Global.enemy_weight += 16
		wave_num += 1
		moon_guy_warning.show()
		start_moon_guy_warning = true
		return
	if wave_num == 5 && Global.enemy_weight <= 12:
		timer.wait_time == 0.25
		timer.start(0.25)


func _on_timer_timeout():
	pass
	#var i = randi_range(0,19)
	#if i == 0:
		#spawn_special_Asteroid()
	#else:
		#spawn_basic_Asteroid()
