extends Node

@onready var screen_size = get_viewport().get_visible_rect().size

var high_score
var health 
var max_health
var health_regen
var move_speed
var counter_thrust
var damage 
var attack_speed 
var bullet_speed 
var collision_damage 
var exp 
var exp_threshold 

signal update_max_health(value)
signal update_health(value)

var upgrades_test = [
	preload("res://Upgrades/Solo_Upgrades/damage_up.tres"),
	#"attack_speed_up1",
	#"collision_damage_up1", 
	preload("res://Upgrades/Solo_Upgrades/health_up.tres"),
	#"health_regen_up1",
	#"move_speed_up1",
	#"counter_thrust_up1",
]

func _ready():
	Global.high_score = load_score()


func refresh():
	health = 300
	max_health = health
	health_regen = 0
	
	move_speed = 0
	counter_thrust = 0
	
	damage = 10
	attack_speed = 0.35
	bullet_speed = 700
	collision_damage = 10
	
	exp = 0
	exp_threshold = 50


func save_score():
	var saved_score = FileAccess.open("user://high_score.save", FileAccess.WRITE)
	var save_text = JSON.stringify({"High Score": Global.high_score})
	saved_score.store_line(save_text)


func load_score():
	if not FileAccess.file_exists("user://high_score.save"):
		print_debug("File does not exist")
		return 0
	var saved_score = FileAccess.open("user://high_score.save", FileAccess.READ)
	var json_string = saved_score.get_line()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print_debug("No JSON")
		return 0
	var data = json.get_data()
	return data["High Score"]
