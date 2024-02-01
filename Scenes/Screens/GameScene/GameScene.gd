extends Node

@onready var Ui = get_node("UI")
@onready var ScoreLabel = Ui.get_node("Score_Label")
@onready var spawnTimer = $SpawnTimer
@onready var wave_timer = $WaveTimer
@onready var timer_wave = $Timer_Wave
@onready var timer_wave2 = $Timer_Wave2
@onready var timer_wave3 = $Timer_Wave3
@onready var timer_wave4 = $Timer_Wave4
@onready var timer_wave5 = $Timer_Wave5
@onready var timer_wave6 = $Timer_Wave6
@onready var timer_wave7 = $Timer_Wave7
@onready var timer_wave8 = $Timer_Wave8
@onready var timer_wave9 = $Timer_Wave9
@onready var timer_wave10 = $Timer_Wave10

var playerScene = preload("res://Scenes/Player/Player.tscn")
var player = true
var screen_size
var wave_timer_time = 10
var wave_time = 35

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
	print(Global.damage)


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



func game_over():
	
	return
	##print ("game_over")
	##print (get_children())
	#for child in get_children():
		##print("Child: ", child.name)
		#if child.name != "UI": 
			##print("Deleting Child: ", child.name) 
			#child.queue_free()


func spawn_wave():
	for i in range(5):
		#print("asteroid spawned")
		spawn_Asteroid()
	timer_wave.start(wave_time)


func spawn_Asteroid():
	var new_asteroid = asteroid_scenes[randi_range(0,2)].instantiate()
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
	pass


func _on_timer_wave_timeout():
	print("wave 1")
	for i in range(5):
		spawn_Asteroid()
	timer_wave2.start(wave_time)


func _on_timer_wave_2_timeout():
	print("wave 2")
	for i in range(7):
		spawn_Asteroid()
	timer_wave3.start(wave_time)


func _on_timer_wave_3_timeout():
	print("wave 3")
	for i in range(7):
		spawn_Asteroid()
	timer_wave4.start(wave_time)


func _on_timer_wave_4_timeout():
	print("wave 4")
	for i in range(7):
		spawn_Asteroid()
	timer_wave5.start(wave_time)


func _on_timer_wave_5_timeout():
	print("wave 5")
	for i in range(10):
		spawn_Asteroid()
	timer_wave6.start(wave_time)


func _on_timer_wave_6_timeout():
	print("wave 6")
	for i in range(10):
		spawn_Asteroid()
	timer_wave7.start(wave_time)


func _on_timer_wave_7_timeout():
	print("wave 7")
	for i in range(10):
		spawn_Asteroid()
	timer_wave8.start(wave_time)


func _on_timer_wave_8_timeout():
	print("wave 8")
	for i in range(12):
		spawn_Asteroid()
	timer_wave9.start(wave_time)


func _on_timer_wave_9_timeout():
	print("wave 9")
	for i in range(10):
		spawn_Asteroid()
	timer_wave10.start(wave_time)


func _on_timer_wave_10_timeout():
	print("wave 10")
	for i in range(10):
		spawn_Asteroid()
	timer_wave10.start(20)


func _on_wave_timer_timeout():
	print("wave 0")
	spawn_wave()
