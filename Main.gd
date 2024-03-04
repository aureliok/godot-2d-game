extends Node

@export var mob_scene: PackedScene = preload("res://scenes/characters/mob.tscn")
var mob_shooter_scene: PackedScene = preload("res://scenes/characters/mob_shooter.tscn")
var mob_shooter_fire_scene: PackedScene = preload("res://scenes/characters/mob_fireball.tscn")
var laser_scene: PackedScene = preload("res://scenes/projectiles/laser_ball.tscn")
var laser_muzzle_scene: PackedScene = preload("res://scenes/projectiles/laser_ball_muzzle.tscn")
var super_laser_scene: PackedScene = preload("res://scenes/projectiles/super_laser.tscn")
var powerup_orb_scene: PackedScene = preload("res://scenes/items/power_up_orb.tscn")
var shield_energy_item_scene: PackedScene = preload("res://scenes/characters/shield_energy_item.tscn")
var support_blocky_scene: PackedScene = preload("res://scenes/characters/support_blocky.tscn")

var game_score: int
var game_active: bool = false
var time_elapsed: int = 0


func _ready():
	$Player.hide()
	$HUD/ShieldEnergyUI.hide()
	
	
func _physics_process(_delta):
	$HUD.update_shield_energy()
	$HUD/TimeLabel/TimeCounterLabel.text = str(time_elapsed)
	

func _on_player_hit():
	game_over()
	
	
func game_over():
	game_active = false
	$MobTimer.stop()
	$AddSecondTimer.stop()
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
	if randf_range(0.0, 1.0) >= .2:
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

	else:
		var mob_shooter = mob_shooter_scene.instantiate()
		var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
		mob_spawn_location.progress_ratio = randf()
		mob_shooter.position = mob_spawn_location.position
		mob_shooter.connect("mob_destroyed", _on_mob_destroyed)
		mob_shooter.connect("mob_shooter_fire", _on_mob_shooter_fire)
		$Enemies.add_child(mob_shooter)


func _on_start_timer_timeout():
	$MobTimer.start()
	$IncreaseMobTimer.start()
	$AddSecondTimer.start()
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
		
		
func _on_player_super_laser_fire(laser_pos, laser_direction):
	if game_active:
		var super_laser_ball = super_laser_scene.instantiate()
		super_laser_ball.position = laser_pos
		super_laser_ball.rotation_degrees = rad_to_deg(laser_direction.angle())
		super_laser_ball.direction = laser_direction
		$Projectiles.add_child(super_laser_ball)
		$HUD.update_powerup_orb(Globals.powerup_orbs)
		

func _on_mob_destroyed(score, mob_position):
	game_score += score
	$HUD.update_score(game_score)
	
	if randf_range(0.0, 1.0) > .75:
		if randf_range(0.0, 1.0) > .3:
			var powerup_orb = powerup_orb_scene.instantiate()
			powerup_orb.position = mob_position
			$Items.call_deferred("add_child", powerup_orb)
		else:
			var shield_energy_item = shield_energy_item_scene.instantiate()
			shield_energy_item.position = mob_position
			$Items.call_deferred("add_child", shield_energy_item)
	
	if $Support.get_child_count() == 0:
		if randf_range(0.0, 1.0) > .8:
			## another condition where only one support blocky can spawn and be active at a given time
			spawn_support_blocky(mob_position)
	

func _on_player_get_powerup_orb():
	$HUD.update_powerup_orb(Globals.powerup_orbs)


func _on_increase_mob_timer_timeout():
	$MobTimer.wait_time = .3


func _on_mob_shooter_fire(fire_pos, fire_direction):
	if game_active:
		var mob_shooter_fire = mob_shooter_fire_scene.instantiate()
		mob_shooter_fire.position = fire_pos
		mob_shooter_fire.direction = fire_direction
		$EnemiesProjectiles.add_child(mob_shooter_fire)


func _on_add_second_timer_timeout():
	time_elapsed += 1


func spawn_support_blocky(pos):
	var support_blocky = support_blocky_scene.instantiate()
#	var spawn_location = get_node("MobPath/MobSpawnLocation")
#	spawn_location.progress_ratio = randf()
	support_blocky.position = pos
	$Support.call_deferred("add_child", support_blocky)
