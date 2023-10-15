extends CharacterBody2D

signal hit
signal laser_fire(laser_pos, laser_direction)
signal super_laser_fire(laser_pos, laser_direction)
signal energy_recovery
signal get_powerup_orb

@export var speed: int = 200
var mouse_pos = null
@onready var can_laser: bool = false
@onready var can_recover_energy: bool = false
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	

func _physics_process(delta):
	look_at(get_global_mouse_position())
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	move_and_slide()
	
	
	if Input.is_action_pressed("fire") and can_laser and Globals.laser_energy > 0:
		$EnergyRecoveryTimer.stop()
		$AnimatedSprite2D.play("firing")
		var laser_marker = $LaserStartPosition
		var player_direction = (get_global_mouse_position() - position).normalized()
		laser_fire.emit(laser_marker.global_position, player_direction)
		
		can_laser = false
		$LaserTimer.start()
		await $LaserTimer.timeout
		Globals.laser_energy -= 1
		can_recover_energy = false
		
	elif Input.is_action_just_released("fire"):
		$AnimatedSprite2D.play("idle")
		$LaserStoppedTimer.start()
		await $LaserStoppedTimer.timeout
		
	
	elif Input.is_action_just_pressed("super_fire") and can_laser and Globals.powerup_orbs == 3:
		$AnimatedSprite2D.play("firing")
		var laser_marker = $LaserStartPosition
		var player_direction = (get_global_mouse_position() - position).normalized()
		Globals.powerup_orbs -= 3
		super_laser_fire.emit(laser_marker.global_position, player_direction)

		$AnimatedSprite2D.play("idle")
		loop_animation_shader_powerup()
	
		
	if can_recover_energy:
		can_recover_energy = false
		$EnergyRecoveryTimer.start()
		await $EnergyRecoveryTimer.timeout
	

func start(pos): ## rename this function
	position = pos
	show()
	can_laser = true
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
	$AnimatedSprite2D.material.set_shader_parameter('line_thickness', 0)
	$AnimatedSprite2D.material.set_shader_parameter('line_color', Vector4(1,1,1,0))
	

func _on_laser_timer_timeout():
	can_laser = true


func _on_area_2d_body_entered(_body):
	if $AnimatedSprite2D/AnimationPlayer.assigned_animation:
		$AnimatedSprite2D/AnimationPlayer.stop()
	$AnimatedSprite2D.play("death")
	can_laser = false
	$PowerUpParticles.emitting = false
	$DeathTimer.start()
	await $DeathTimer.timeout
	hide()
	hit.emit()
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	Globals.powerup_orbs = 0
	

func _on_energy_recovery_timer_timeout():
	Globals.laser_energy += 3
	if Globals.laser_energy > 150:
		Globals.laser_energy = 150
	energy_recovery.emit()
	if Globals.laser_energy < 150:
		can_recover_energy = true


func _on_laser_stopped_timer_timeout():
	can_recover_energy = true
	

func get_item(item_type, item_amount):
	if item_type == "powerup_orb":
		Globals.powerup_orbs += item_amount
		get_powerup_orb.emit()
		loop_animation_shader_powerup()
		
		
func loop_animation_shader_powerup():
	var powerup_orbs: int = Globals.powerup_orbs
	
	if powerup_orbs == 1:
		$AnimatedSprite2D/AnimationPlayer.play("poweruplvl1")
	elif powerup_orbs == 2:
		$AnimatedSprite2D/AnimationPlayer.play("poweruplvl2")
	elif powerup_orbs == 3:
		$AnimatedSprite2D/AnimationPlayer.play("poweruplvl3")
	else:
		if $AnimatedSprite2D/AnimationPlayer.assigned_animation:
			$AnimatedSprite2D/AnimationPlayer.stop()
			$PowerUpParticles.emitting = false
			$PowerUpLight.enabled = false
		else:
			pass
