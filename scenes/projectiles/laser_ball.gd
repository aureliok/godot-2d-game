extends Area2D

@export var speed: int = 1000
var direction: Vector2 = Vector2.UP


func _ready():
	$LaserSFX.play()


func _process(delta):
	position += direction * speed * delta
	

func _on_body_entered(body):
	if body.has_method("hit"):
		var damage_amount: int = randi_range(8,12)
		body.hit(damage_amount)
		$EnemyHitSFX.play()
	speed = 0
	$AnimatedSprite2D.play("laser_blast")
	await $AnimatedSprite2D.animation_finished
	queue_free() 

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
