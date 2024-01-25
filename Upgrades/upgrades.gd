extends Resource

class_name upgrade

@export var upgrade_name : String = ""
@export var upgrade_text : String = ""
@export var next_upgrade : upgrade = null

@export var upgrade_function : GDScript = null
