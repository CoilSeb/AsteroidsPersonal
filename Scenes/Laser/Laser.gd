extends RayCast2D

@onready var laser = $"."
@onready var end = $End
@onready var line = $Line
@onready var shoot_timer = $Shoot_Timer

const MAX_LENGTH = 20000
var direction


func _ready():
	pass


func _process(_delta):
	var damage = Global.damage / 11.0
	if Input.is_action_pressed("shoot") || Input.is_action_pressed("M2"):
		laser.target_position = direction * MAX_LENGTH
		if laser.is_colliding():
			end.global_position = laser.get_collision_point()
		else:
			end.global_position = laser.target_position
		if laser.is_colliding() && shoot_timer.time_left == 0:
			if get_collider():
				get_collider().damage_asteroid(damage)
				shoot_timer.start(Global.attack_speed)
		line.rotation = laser.target_position.angle()
		line.points[1].x = end.position.length()
		
	if get_tree().paused:
		Global.laser_made = false
		queue_free()
