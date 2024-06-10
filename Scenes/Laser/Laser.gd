extends RayCast2D

@onready var laser = $"."
@onready var end = $End
@onready var line = $Line
@onready var shoot_timer = $Shoot_Timer
@onready var damage_modifier = 1
@onready var gpu_particles_2d = $End/GPUParticles2D

const MAX_LENGTH = -2000
#var direction


func _ready():
	pass


func _process(_delta):
	var damage = Global.damage / (Global.max_lasers + Global.bonus_lasers) * damage_modifier
	line.default_color = Color(-.5+damage_modifier, -.5+damage_modifier, -.5+damage_modifier)
	gpu_particles_2d.global_position = end.global_position
	if Input.is_action_pressed("shoot"):
		laser.target_position = Vector2(0, MAX_LENGTH)
		if laser.is_colliding():
			end.global_position = laser.get_collision_point()
			line.points[1].y = -(end.position - position).length()
			end.show()
		else:
			line.points[1].y = MAX_LENGTH
			end.hide()
		if laser.is_colliding() && shoot_timer.time_left == 0:
			if get_collider():
				get_collider().damage_asteroid(damage)
				shoot_timer.start(Global.attack_speed)
