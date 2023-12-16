extends Area2D

var direction: Vector2
var bullet_speed = 700 + Global.bullet_speed
var screen_size
var damage = 10 + Global.damage

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	position += direction * bullet_speed * delta
	if position.x < 0:
		queue_free()
	if position.x > screen_size.x:
		queue_free()
	if position.y < 0:
		queue_free()
	if position.y > screen_size.y:
		queue_free()

func _on_area_entered(area):
	#area.destroy()
	area.damage_asteroid(damage)
	queue_free()
