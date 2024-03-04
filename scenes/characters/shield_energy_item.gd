extends Area2D

@export var shield_energy_amount: int = 20

func _on_body_entered(body):
	if body.has_method("get_item"):
		if Globals.shield_energy < 100:
			body.get_item("shield_energy", shield_energy_amount)
			
			$GetShieldEnergy.play()
			$Sprite2D.visible = false
			$CollisionShape2D.set_deferred("disabled", true)
			await $GetShieldEnergy.finished
			queue_free()
