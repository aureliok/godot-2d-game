extends RigidBody2D

@export var health: int = 30
@export var destroy_score: int = 5
var damage_display_scene: PackedScene = preload("res://scenes/characters/damage_display.tscn")

signal mob_destroyed(score, mob_position)

# Called when the node enters the scene tree for the first time.d
func _ready():
	$AnimatedSprite2D.play("default")
	if randf_range(0,1) > .9:
		$AnimatedSprite2D.scale = Vector2(.25, .25)
		$CollisionShape2D.scale = Vector2(.25, .25)
		health = 65
		destroy_score = 10
	
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
	
func hit(damage_amount):
	## TO DO: should probably try to clean up this code
#	var damage_amount: int = 10
	var damage_marker = damage_display_scene.instantiate()
	var damage_markers = $DamageDisplayMarkers.get_children()
	var selected_damage_marker = damage_markers[randi() % damage_markers.size()]
	
	damage_marker.amount = damage_amount
	damage_marker.position = selected_damage_marker.position ## on position, should work with angles? sin cosin and such to find where x should be when rotated 
	damage_marker.rotation_degrees -= selected_damage_marker.global_rotation_degrees
	$DamageText.add_child(damage_marker)
#	print($DamageDisplayMarker.global_rotation_degrees)
#	damage_marker.position = damage_marker_location
	
	health -= damage_amount
	$AnimatedSprite2D.material.set_shader_parameter("progress", 1)
	$HitFlashTimer.start()
	$HitSFX.play()
	if health <= 0:
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimatedSprite2D.hide()
		linear_velocity = Vector2.ZERO
		$DeathParticles.color = Color(randf(), randf(), randf(), 1)
		$DeathParticles.emitting = true
		$AnimatedSprite2D.material.set_shader_parameter("progress", 1)
		mob_destroyed.emit(destroy_score, $AnimatedSprite2D.global_position)
		$DeathTimer.start()
		await $DeathTimer.timeout
		queue_free()


func _on_hit_flash_timer_timeout():
	$AnimatedSprite2D.material.set_shader_parameter("progress", 0)
