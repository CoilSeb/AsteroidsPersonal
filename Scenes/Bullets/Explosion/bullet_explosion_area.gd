extends Area2D

@export var damage: float
@export var size: float
@export var child1: Area2D
@export var child2: Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = Vector2(size, size)
	$AnimatedSprite2D.play("default")
	await $AnimatedSprite2D.animation_finished
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_entered(area):
	if area != child1 && area != child2:
		area.damage_asteroid(damage)
