extends Area2D

@export var speed: int = 125
@export var health: int = 5
var direction: Vector2 = Vector2.UP


func _ready():
	$FireballSFX.play()
	
	
func _process(delta):
	position += direction * speed * delta
	

func _on_body_entered(body):
	if body.has_method("hit"):
		var damage_amount: int = randi_range(8,12)
		body.hit(damage_amount)
		$HitSFX.play()
		
	elif body.has_method("player_hit"):
		body.player_hit()
		
	speed = 0
	queue_free() 
	
	
func hit(damage_amount):
	health -= damage_amount
	$AnimatedSprite2D.material.set_shader_parameter("progress", 1)
	$HitFlashTimer.start()
	if health <= 0:
		$FireballDestroyTimer.start()
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_hit_flash_timer_timeout():
	$AnimatedSprite2D.material.set_shader_parameter("progress", 0)


func _on_fireball_destroy_timer_timeout():
	queue_free()
