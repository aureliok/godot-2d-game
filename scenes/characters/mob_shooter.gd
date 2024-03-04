extends CharacterBody2D


@export var health: int = 20
@export var destroy_score: int = 5
var player_in_range: bool = false
var enemy_can_fire: bool = true
var speed: int = 2350
var inflict_touch_damage: int
var damage_display_scene: PackedScene = preload("res://scenes/characters/damage_display.tscn")

signal mob_shooter_fire(fire_pos, fire_direction)
signal mob_destroyed(score, mob_position)


func _ready():
	var seek_player_time: float = randf_range(1, 2.5)
	var scale_collision: float = randf_range(1.5, 2)
	$DetectPlayerArea/CollisionShape2D.scale = Vector2(scale_collision, scale_collision)
	$SeekPlayerTimer.wait_time = seek_player_time


func _physics_process(delta):
	var direction = (Globals.player_pos - position).normalized()
	look_at(Globals.player_pos)
	if not player_in_range:
		velocity = direction * speed * delta
	else:
		velocity = Vector2(0,0)
		if enemy_can_fire:
			enemy_can_fire = false
			mob_shooter_fire.emit($FireMarker.global_position, direction)
			$FireCooldownTimer.start()
			await $FireCooldownTimer.timeout
			
	move_and_slide()
			
	if $DetectPlayerArea.has_overlapping_bodies():
		player_in_range = true
	
		
		
func hit(damage_amount):
	## TO DO: should probably try to clean up this code
	var damage_marker = damage_display_scene.instantiate()
	var damage_markers = $DamageDisplayMarkers.get_children()
	var selected_damage_marker = damage_markers[randi() % damage_markers.size()]
	
	damage_marker.set_color("#ffff1a")
	damage_marker.amount = damage_amount
	damage_marker.position = selected_damage_marker.position ## on position, should work with angles? sin cosin and such to find where x should be when rotated 
	damage_marker.rotation_degrees -= selected_damage_marker.global_rotation_degrees
	$DamageText.add_child(damage_marker)
#	print($DamageDisplayMarker.global_rotation_degrees)
#	damage_marker.position = damage_marker_location
	
	health -= damage_amount
	$Sprite2D.material.set_shader_parameter("progress", 1)
	$HitFlashTimer.start()
	if health <= 0:
		$DetectPlayerArea/CollisionShape2D.set_deferred("disabled", true)
		player_in_range = false
		$CollisionCore.set_deferred("disabled", true)
		$CollisionLeftArm.set_deferred("disabled", true)
		$CollisionRightArm.set_deferred("disabled", true)
		$Sprite2D.hide()
		speed = 0
		$DeathParticles.color = Color(randf(), randf(), randf(), 1)
		$DeathParticles.emitting = true
		$Sprite2D.material.set_shader_parameter("progress", 1)
		mob_destroyed.emit(destroy_score, $Sprite2D.global_position)
		$DeathTimer.start()
		await $DeathTimer.timeout
		queue_free()


func _on_detect_player_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
#		$DetectPlayerArea/CollisionShape2D.set_deferred("disabled", true)


func _on_detect_player_area_body_exited(body):
	if body.is_in_group("player"):
		$SeekPlayerTimer.start()
		await $SeekPlayerTimer.timeout


func _on_seek_player_timer_timeout():
	player_in_range = false


func _on_hit_flash_timer_timeout():
	$Sprite2D.material.set_shader_parameter("progress", 0)


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_fire_cooldown_timer_timeout():
	enemy_can_fire = true
