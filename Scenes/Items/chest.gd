extends Node2D

@onready var instructions_label = $Instructions_Label
@onready var cost_label = $Cost
#@onready var cost = Global.base_chest_cost * Global.inflation
var cost = 0

const ATTACK_SPEED_ITEM = preload("res://Scenes/Items/attack_speed_item.tscn")
var can_interact = false


func _ready():
	Global.asteroid_spawned.emit(self)
	cost_label.text = "$" + str(cost)


func _process(delta):
	if can_interact and Input.is_action_just_pressed("E") and Global.money >= cost:
		Global.money -= cost
		var item = ATTACK_SPEED_ITEM.instantiate()
		item.position = position
		get_parent().add_child(item)
		queue_free()


func _on_interact_area_2d_area_entered(area):
	instructions_label.show()
	can_interact = true


func _on_interact_area_2d_area_exited(area):
	instructions_label.hide()
	can_interact = false
