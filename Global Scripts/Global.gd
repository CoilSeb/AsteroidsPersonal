extends Node

@onready var screen_size = get_viewport().get_visible_rect().size

var high_score
var health
var max_health
var move_speed
var damage 
var attack_speed 
var bullet_speed 
var collision_damage 
var exp 
var exp_threshold 
var exp_level

var damage_up = {
	"damage_up1": false, 
	"damage_up2": false,
	"damage_up3": false,
}

var health_up = {
	"health_up1": false, 
	"health_up2": false, 
	"health_up3": false, 
}


func _ready():
	Global.high_score = load_score()


func refresh():
	health = 300
	max_health = 300
	move_speed = 0
	damage = 0
	attack_speed = 1
	bullet_speed = 0
	collision_damage = 10
	exp = 0
	exp_threshold = 70
	exp_level = 0
	
	damage_up["damage_up1"] = false
	damage_up["damage_up2"] = false
	damage_up["damage_up3"] = false
	
	health_up["health_up1"] = false
	health_up["health_up2"] = false
	health_up["health_up3"] = false


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
