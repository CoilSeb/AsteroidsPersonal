extends Button

@onready var UI = get_parent().get_parent()
@onready var level_up_timer = UI.get_node("Level_Up_Timer")
@onready var sprite2D = $Sprite2D
@onready var texture_rect_1 = $TextureRect1
@onready var color_rect = $ColorRect
@onready var rich_text_label_1 = $RichTextLabel1
@onready var title = $Title
@onready var cost_label = $Cost_Label
@onready var gpuParticles = [
	$GPUParticles2D,
	$GPUParticles2D2,
	$GPUParticles2D3,
]

var index
var upgrade_cost

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	if level_up_timer.time_left == 0 && Global.money >= upgrade_cost:
		Global.update_money.emit(-upgrade_cost)
		UI.apply_my_upgrade(UI.upgrades[index])
		UI.upgrades[index] = null
		UI.upgrades[index] = null
		UI.sold(index)


func start_particles():
	for particle in gpuParticles:
		particle.emitting = true


func stop_particles():
	for particle in gpuParticles:
		particle.emitting = false
