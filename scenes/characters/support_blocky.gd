extends CharacterBody2D


const speed: int = 150
@onready var pickup_by_player: bool = false
@onready var at_range_player: bool = false


func _physics_process(_delta):
	var direction = (Globals.player_pos - position).normalized()
	look_at(Globals.player_pos)
	if pickup_by_player and not at_range_player:
		velocity = direction * speed 
	else:
		velocity = Vector2(0,0)

	move_and_slide()


func _on_close_range_player_body_entered(body):
	if body.is_in_group("player"):
		at_range_player = true

		if not pickup_by_player:
			pickup_by_player = true
			
		body.change_support_blocky_activity(true)


func _on_close_range_player_body_exited(body):
	if body.is_in_group("player"):
		at_range_player = false
		
		body.change_support_blocky_activity(false)


func _on_active_timer_timeout():
	queue_free()
