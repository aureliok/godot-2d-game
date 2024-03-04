extends Area2D

@export var travel_speed: int = 800
@onready var speed: int = 0
@export var min_damage: int = 70
@export var max_damage: int = 95
var direction: Vector2 = Vector2.UP

func _ready():
	$SuperLaserStart/AnimationPlayer.play("super_laser_start")
	$SuperLaserSFX.play()
	await $SuperLaserStart/AnimationPlayer.animation_finished
	speed = travel_speed
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("super_laser_travel")
	$CollisionShape2D.set_deferred("disabled", false)
	
	
func _process(delta):
	position += direction * speed * delta
	
	
func _on_body_entered(body):
	_laser_hit_target(body)
		
		
func _on_area_entered(area):
	_laser_hit_target(area)
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
	
func _laser_hit_target(target):
	if target.has_method("hit"):
		var damage_amount: int = randi_range(min_damage,max_damage)
		target.hit(damage_amount)
		$EnemyHitSFX.play()


