extends Area2D

var direction: Vector2
var bullet_speed = Global.bullet_velocity
var screen_size
var damage = Global.damage


func _ready():
	screen_size = get_viewport_rect().size


func _process(delta):
	position += direction * bullet_speed * delta
	if position.x < 0:
		position.x = screen_size.x
	if position.x > screen_size.x:
		position.x = 0
	if position.y < 0:
		position.y = screen_size.y
	if position.y > screen_size.y:
		position.y = 0


func _on_area_entered(area):
	if area.is_in_group("Shard"):
		queue_free()
		return
	area.damage_asteroid(damage)
	queue_free()


func _on_timer_timeout():
	queue_free()
