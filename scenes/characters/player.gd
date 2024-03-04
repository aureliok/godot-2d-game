extends CharacterBody2D

signal hit
signal laser_fire(laser_pos, laser_direction)
signal super_laser_fire(laser_pos, laser_direction)
signal get_powerup_orb

@export var speed: int = 200
var mouse_pos = null
@onready var can_laser: bool = false
@onready var can_recover_energy: bool = false
@onready var shield_on: bool = false
@onready var shield_depleted_animation: bool = false
var support_blocky_active: bool = false
var screen_size
var shield_on_time_tick: int = 0

## TODO fix bug where shield energy is dropping to value before picking up item when shields active


func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play("idle")
	$Shield/ShieldSprite.visible = false
	$Shield/ShieldCollision.set_deferred("disabled", true)
	

func _physics_process(delta):
	Globals.player_pos = global_position
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
	
	
	if Input.is_action_pressed("fire") and can_laser:
#		$EnergyRecoveryTimer.stop()
		$AnimatedSprite2D.play("firing")
		var laser_marker = $LaserStartPositions/LaserStartPosition
		fire_laser(laser_marker)
#		var laser_marker = $LaserStartPositions/LaserStartPosition
#		var player_direction = (get_global_mouse_position() - position).normalized()
#		laser_fire.emit(laser_marker.global_position, player_direction)
#
#		can_laser = false

		if support_blocky_active:
			var laser_marker2 = $LaserStartPositions/LaserStartPosition2
			var laser_marker3 = $LaserStartPositions/LaserStartPosition3
			await get_tree().create_timer(.04).timeout
			fire_laser(laser_marker2)
			await get_tree().create_timer(.04).timeout
			fire_laser(laser_marker3)
		$LaserTimer.start()
		await $LaserTimer.timeout
#		Globals.laser_energy -= 1
#		can_recover_energy = false
		
	elif Input.is_action_just_released("fire"):
		$AnimatedSprite2D.play("idle")
	
	elif Input.is_action_just_pressed("super_fire") and can_laser and Globals.powerup_orbs == 3:
		## TO DO: DEFINE IF SHOULD PLAYER SHOULD HAVE A LASER COOLDOWN AFTER THIS ONE
		$AnimatedSprite2D.play("firing")
		var laser_marker = $LaserStartPositions/LaserStartPosition
		var player_direction = (get_global_mouse_position() - position).normalized()
		Globals.powerup_orbs -= 3
		super_laser_fire.emit(laser_marker.global_position, player_direction)

		$AnimatedSprite2D.play("idle")
		loop_animation_shader_powerup()
		
	if Input.is_action_just_pressed("shield"):
		if shield_on:
			## stopping shields
			var tween = get_tree().create_tween()
			tween.tween_property($Shield/ShieldSprite, "scale", Vector2(0,0), .3)
			$Shield/ShieldOffAudio.play()
			await tween.finished
			
			$Shield/ShieldSprite.visible = false
			$Shield/ShieldCollision.set_deferred("disabled", true)
			shield_on = false
			$EnergyStopUseTimer.start()
			can_recover_energy = false
		elif not shield_on and Globals.shield_energy > 0:
			## activating shield
			var tween = get_tree().create_tween()
			$Shield/ShieldSprite.visible = true
			tween.tween_property($Shield/ShieldSprite, "scale", Vector2(.19,.19), .3)
			$Shield/ShieldCollision.set_deferred("disabled", false)

			shield_on = true
			shield_on_time_tick = 0
			$Shield/ShieldOnAudio.play()
			can_recover_energy = false
			
	## draining shield energy	
	if shield_on:
		can_recover_energy = false
		shield_on_time_tick += 2
		if shield_on_time_tick % 3 == 0 and not support_blocky_active:
			Globals.shield_energy = clamp(Globals.shield_energy - 1, Globals.shield_energy_min, Globals.shield_energy_max)
			
			
		if Globals.shield_energy <= 0 and not shield_depleted_animation:
			shield_depleted_animation = true
			$Shield/ShieldDepletedTimer.start()
			_shield_depleted_tween_animation($Shield/ShieldDepletedTimer.wait_time)
			await $Shield/ShieldDepletedTimer.timeout
			
			
	if can_recover_energy:
		can_recover_energy = false
		$EnergyRecoveryTimer.start()
		await $EnergyRecoveryTimer.timeout
		
		
func fire_laser(laser_marker):
#	var laser_marker = $LaserStartPositions/LaserStartPosition
	var player_direction = (get_global_mouse_position() - position).normalized()
	laser_fire.emit(laser_marker.global_position, player_direction)
	
	can_laser = false
	$LaserTimer.start()
#	await $LaserTimer.timeout
		
	

func start(pos): ## rename this function
	position = pos
	show()
	can_laser = true
	$HitDetector/CollisionShape2D.set_deferred("disabled", false)
	$AnimatedSprite2D.material.set_shader_parameter('line_thickness', 0)
	$AnimatedSprite2D.material.set_shader_parameter('line_color', Vector4(1,1,1,0))
	can_recover_energy = false
	shield_on = false
	shield_depleted_animation = false
	Globals.shield_energy = 100
	$Shield/ShieldSprite.scale = Vector2(0,0)
	

func _on_laser_timer_timeout():
	can_laser = true


func _on_area_2d_body_entered(_body):
	player_hit()
	

func player_hit():
	if $AnimatedSprite2D/AnimationPlayer.assigned_animation:
		$AnimatedSprite2D/AnimationPlayer.stop()
	$AnimatedSprite2D.play("death")
	can_laser = false
	$PowerUpParticles.emitting = false
	$DeathTimer.start()
	await $DeathTimer.timeout
	hide()
	hit.emit()
	$HitDetector/CollisionShape2D.set_deferred("disabled", true)
	Globals.powerup_orbs = 0
	

func _on_energy_recovery_timer_timeout():
	Globals.shield_energy += 1
	if Globals.shield_energy > 100:
		Globals.shield_energy = 100
		can_recover_energy = false
	if Globals.shield_energy < 100:
		can_recover_energy = true


func get_item(item_type, item_amount):
	if item_type == "powerup_orb":
		Globals.powerup_orbs += item_amount
		get_powerup_orb.emit()
		loop_animation_shader_powerup()
	elif item_type == "shield_energy":
		Globals.shield_energy += item_amount
		
		
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


func _on_energy_stop_use_timer_timeout():
	can_recover_energy = true


func _on_shield_depleted_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property($Shield/ShieldSprite, "scale", Vector2(0,0), .3)
	$Shield/ShieldOffAudio.play()
	await tween.finished
	
	$Shield/ShieldSprite.visible = false
	$Shield/ShieldCollision.set_deferred("disabled", true)
	shield_on = false
	shield_depleted_animation = false
	$Shield/ShieldSprite.material.set_shader_parameter("progress", 0)
	$EnergyStopUseTimer.start()
	
	
func _shield_depleted_tween_animation(animation_duration):
	var animation_cycles_duration = animation_duration / 8
	var tween = get_tree().create_tween()
	var shield_flashing: bool = false
	
	for i in range(8):
		if not shield_flashing:
			tween.tween_method(_set_shader_value, 0, 1, animation_cycles_duration)
			shield_flashing = true
		else:
			tween.tween_method(_set_shader_value, 1, 0, animation_cycles_duration)
			shield_flashing = false
		
	tween.tween_method(_set_shader_value, 1, 0, .001)
	await tween.finished
	shield_flashing = false
	
	
func _set_shader_value(value: float):
	$Shield/ShieldSprite.material.set_shader_parameter("progress", value)
	

func change_support_blocky_activity(status):
	support_blocky_active = status
	
