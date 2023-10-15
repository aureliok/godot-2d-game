extends Area2D

@export var powerup_orb_amount: int = 1


func _on_body_entered(body):
	if body.has_method("get_item"):
		if Globals.powerup_orbs < 3:
			body.get_item("powerup_orb", powerup_orb_amount)
			queue_free()
