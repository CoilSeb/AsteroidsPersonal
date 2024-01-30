extends RayCast2D

var is_casting = false


func _ready():
	pass # Replace with function body.


func _process(delta):
	force_raycast_update()
	
	if is_colliding():
		target_position = to_local(get_collision_point())
		
	$Line2D.points[1] = target_position
