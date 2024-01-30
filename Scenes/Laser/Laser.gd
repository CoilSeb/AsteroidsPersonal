extends RayCast2D

@onready var laser = $"."
@onready var end = $End
@onready var line = $Line
@onready var shoot_timer = $Shoot_Timer

const MAX_LENGTH = 2000
var damage = Global.damage


func _ready():
	pass


func _process(delta):
	print(shoot_timer.time_left)
	if Input.is_action_pressed("shoot") || Input.is_action_pressed("M2"):
		laser.target_position = get_local_mouse_position().normalized() * MAX_LENGTH
		if laser.is_colliding():
			end.global_position = laser.get_collision_point()
		else:
			end.global_position = laser.target_position
		if laser.is_colliding() && shoot_timer.time_left == 0:
			get_collider().damage_asteroid(damage)
			shoot_timer.start()
		line.rotation = laser.target_position.angle()
		line.points[1].x = end.position.length()
