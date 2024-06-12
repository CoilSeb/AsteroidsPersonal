extends Area2D

@onready var timer = $Timer
@onready var gpu_particles_2d = $GPUParticles2D

const AUDIO_CONTROL = preload("res://Audio/Audio_Control.tscn")
const EXPLOSION_AREA = preload("res://Scenes/Bullets/Explosion/bullet_explosion_area.tscn")
var direction: Vector2
var bullet_speed = Global.bullet_velocity
var screen_size
var damage = Global.damage
var health = Global.bulldozer_bullet_health
var bullet_time_offset = randf_range(0, 0.075)


func _ready():
	screen_size = get_viewport_rect().size
	gpu_particles_2d.process_material.scale_min = scale.x * 0.5
	gpu_particles_2d.process_material.scale_max = scale.y * 0.8
	if !Global.bulldozer:
		timer.start(Global.bullet_time + bullet_time_offset)
	elif Global.ghost_bullets:
		timer.start(Global.bullet_time + bullet_time_offset)


func _process(delta):
	if Global.homing_strength > 0:
		var areas: Array = $Area2D.get_overlapping_areas()
		if areas:
			var closest_area = areas[0]
			for area in areas:
				if global_position.distance_to(area.position) < global_position.distance_to(closest_area.position):
					closest_area = area
			var new_direction = global_position.direction_to(closest_area.global_position)
			direction = lerp(direction, new_direction, delta * Global.homing_strength)
	position += (direction * bullet_speed * delta)
	rotation = direction.angle() + (0.5 * PI)
	if position.x < 0:
		position.x = screen_size.x
	if position.x > screen_size.x:
		position.x = 0
	if position.y < 0:
		position.y = screen_size.y
	if position.y > screen_size.y:
		position.y = 0


func _on_area_entered(area):
	if Global.bulldozer:
		health -= area.damage
		area.damage_asteroid(damage)
		if area.health > 0 && !Global.ghost_bullets:
			direction *= -1
		if health <= 0:
			pass
		else:
			if Global.explosive_rounds:
				var explosion = EXPLOSION_AREA.instantiate()
				explosion.damage = Global.explosion_base_damage * (log(damage)/log(10))
				if damage > 10:
					explosion.size = Global.explosion_base_radius * (log(damage)/log(10))
				else:
					explosion.size = Global.explosion_base_radius
				explosion.position = position
				get_parent().call_deferred("add_child", explosion)
			return
	var audio_player = AUDIO_CONTROL.instantiate()
	audio_player.stream = load("res://Audio/Sounds/hurt_c_08-102842.mp3")
	audio_player.volume_db = Global.sound_effects_volume
	get_parent().add_child(audio_player)
	area.damage_asteroid(damage)
	destroy(area)


func destroy(_area):
	if Global.explosive_rounds:
			var explosion = EXPLOSION_AREA.instantiate()
			explosion.damage = Global.explosion_base_damage * (log(damage)/log(10)) * 2
			if damage > 10:
				explosion.size = Global.explosion_base_radius * (log(damage)/log(10))
			else:
				explosion.size = Global.explosion_base_radius
			explosion.position = position
			get_parent().call_deferred("add_child", explosion)
	queue_free()


func _on_timer_timeout():
	destroy(self)
