extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta):
	## TODO: need to code movement towards the player
	move_and_slide()
