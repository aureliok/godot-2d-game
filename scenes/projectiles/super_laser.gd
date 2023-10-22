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
	if body.has_method("hit"):
		var damage_amount: int = randi_range(min_damage,max_damage)
		body.hit(damage_amount)
		

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
