extends Node

@export var mob_scene: PackedScene = preload("res://scenes/characters/mob.tscn")
var laser_scene: PackedScene = preload("res://scenes/projectiles/laser_ball.tscn")
var laser_muzzle_scene: PackedScene = preload("res://scenes/projectiles/laser_ball_muzzle.tscn")
var super_laser_scene: PackedScene = preload("res://scenes/projectiles/super_laser.tscn")
var powerup_orb_scene: PackedScene = preload("res://scenes/items/power_up_orb.tscn")
var game_score: int
var game_active: bool = false


func _ready():
	$Player.hide()
	$HUD/ShieldEnergyUI.hide()
	
	
func _physics_process(_delta):
	$HUD.update_shield_energy()
	

func _on_player_hit():
	game_over()
	
	
func game_over():
	game_active = false
	$MobTimer.stop()
	$HUD.show_game_over()
	var tween = get_tree().create_tween()
	tween.tween_property($BackgroundMusic, "volume_db", -25, 2)
	await tween.finished
	$BackgroundMusic.stop()
	
func new_game():
	$BackgroundMusic.volume_db = -25
	var tween = get_tree().create_tween()
	tween.tween_property($BackgroundMusic, "volume_db", 0, 2)
	$BackgroundMusic.play()
	game_score = 0
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("items", "queue_free")
	$Player.start($StartPosition.position)
	$Player.show()
	$HUD/ShieldEnergyUI.show()
	$StartTimer.start()
	$HUD.update_score(game_score)
	$HUD.update_powerup_orb(Globals.powerup_orbs)
	$HUD.show_message("Get Ready")


func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	
	var direction = mob_spawn_location.rotation + PI / 2
	
	mob.position = mob_spawn_location.position
	
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	mob.connect("mob_destroyed", _on_mob_destroyed)
	$Enemies.add_child(mob)


#func _on_score_timer_timeout():
#	game_score += 1
#	$HUD.update_score(game_score)


func _on_start_timer_timeout():
	$MobTimer.start()
	$IncreaseMobTimer.start()
	game_active = true


func _on_player_laser_fire(laser_pos, laser_direction):
	if game_active:
		var laser_ball = laser_scene.instantiate()
		var laser_ball_muzzle = laser_muzzle_scene.instantiate()
		laser_ball.position = laser_pos
		laser_ball.rotation_degrees = rad_to_deg(laser_direction.angle()) + 90
		laser_ball.direction = laser_direction
		laser_ball_muzzle.position = laser_pos
		laser_ball_muzzle.rotation_degrees = rad_to_deg(laser_direction.angle())
		$Projectiles.add_child(laser_ball)
		$Projectiles.add_child(laser_ball_muzzle)
#		$LaserSFX.play()
#		$HUD.update_shield_energy()
		
		
func _on_player_super_laser_fire(laser_pos, laser_direction):
	if game_active:
		var super_laser_ball = super_laser_scene.instantiate()
		super_laser_ball.position = laser_pos
		super_laser_ball.rotation_degrees = rad_to_deg(laser_direction.angle())
		super_laser_ball.direction = laser_direction
		$Projectiles.add_child(super_laser_ball)
#		$SuperLaserSFX.play()
		$HUD.update_powerup_orb(Globals.powerup_orbs)
		


func _on_mob_destroyed(score, mob_position):
	game_score += score
	$HUD.update_score(game_score)
	
	if randf_range(0.0, 1.0) > .75:
		var powerup_orb = powerup_orb_scene.instantiate()
		powerup_orb.position = mob_position
#		$Items.add_child(powerup_orb)
		$Items.call_deferred("add_child", powerup_orb)


func _on_player_energy_recovery():
#	$HUD.update_shield_energy()
	pass
	

func _on_player_get_powerup_orb():
	$HUD.update_powerup_orb(Globals.powerup_orbs)


func _on_increase_mob_timer_timeout():
	$MobTimer.wait_time = .3
