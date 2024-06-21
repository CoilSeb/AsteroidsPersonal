extends Area2D

var move_time = 0.5
var timer = 0.0
var health = 30.0

func _physics_process(delta):
	if timer < move_time:
		timer += delta
		var center_of_screen = Vector2(960, 540)
		position = lerp(position, center_of_screen, delta * 2)


func damage_asteroid(damage_taken):
	health -= damage_taken
	if health <= 0:
		queue_free()
