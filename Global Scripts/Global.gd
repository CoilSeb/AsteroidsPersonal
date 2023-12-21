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
var exp_level

var damage_up = {
	"damage_up1": false, 
	"damage_up2": false,
	"damage_up3": false,
}

var attack_speed_up = {
	"attack_speed_up1": false,
	"attack_speed_up2": false,
	"attack_speed_up3": false,
}

var collision_damage_up = {
	"collision_damage_up1": false, 
	"collision_damage_up2": false, 
	"collision_damage_up3": false, 
}

var health_up = {
	"health_up1": false, 
	"health_up2": false, 
	"health_up3": false, 
}

var health_regen_up = {
	"health_regen_up1": false,
	"health_regen_up2": false,
	"health_regen_up3": false, 
}

var move_speed_up = {
	"move_speed_up1": false,
	"move_speed_up2": false,
	"move_speed_up3": false, 
}

var counter_thrust_up = {
	"counter_thrust_up1": false, 
	"counter_thrust_up2": false, 
	"counter_thrust_up3": false,
}


func _ready():
	Global.high_score = load_score()


func refresh():
	health = 3000000
	max_health = 3000000
	health_regen = 0
	move_speed = 0
	counter_thrust = 0
	damage = 100
	attack_speed = 0.35
	bullet_speed = 0
	collision_damage = 100
	exp = 0
	exp_threshold = 1
	exp_level = 0
	
	damage_up["damage_up1"] = false
	damage_up["damage_up2"] = false
	damage_up["damage_up3"] = false
	
	health_up["health_up1"] = false
	health_up["health_up2"] = false
	health_up["health_up3"] = false
	
	collision_damage_up["collision_damage_up1"] = false
	collision_damage_up["collision_damage_up2"] = false
	collision_damage_up["collision_damage_up3"] = false
	
	attack_speed_up["attack_speed_up1"] = false
	attack_speed_up["attack_speed_up2"] = false
	attack_speed_up["attack_speed_up3"] = false
	
	health_regen_up["health_regen_up1"] = false
	health_regen_up["health_regen_up2"] = false
	health_regen_up["health_regen_up3"] = false
	
	move_speed_up["move_speed_up1"] = false
	move_speed_up["move_speed_up2"] = false
	move_speed_up["move_speed_up3"] = false
	
	counter_thrust_up["counter_thrust_up1"] = false
	counter_thrust_up["counter_thrust_up2"] = false
	counter_thrust_up["counter_thrust_up3"] = false


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
