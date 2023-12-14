extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Exp")
	print(get_groups())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func destroy():
	queue_free()
