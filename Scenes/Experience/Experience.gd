extends Area2D

@onready var destroy_ring = $Destroy_Ring

var following = false
var d 
var t = 0.0
var player_area
const FOLLOW_SPEED = 4.0


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Exp")
	destroy_ring.add_to_group("Destroy_Ring")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	d = delta
	if following == true:
		follow(delta)


func destroy():
	queue_free()


func _on_area_entered(area):
	#while self:
	following = true
	player_area = area.get_parent()
		#print(player_area)


func _on_area_exited(_area):
	following = false


func follow(delta):
	t += delta * 0.2
	position = position.lerp(player_area.position, t)
	
