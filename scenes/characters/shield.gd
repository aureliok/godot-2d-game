extends StaticBody2D

var damage_display_scene: PackedScene = preload("res://scenes/characters/damage_display.tscn")

func hit(damage_amount):
	if Globals.shield_energy > 0:
		var damage_marker = damage_display_scene.instantiate()
		var damage_markers = $"../DamageDisplayMarkers".get_children()
		var selected_damage_marker = damage_markers[randi() % damage_markers.size()]
		
		damage_marker.set_color("#61c1ff")
		damage_marker.amount = damage_amount
		damage_marker.position = selected_damage_marker.position ## on position, should work with angles? sin cosin and such to find where x should be when rotated 
		damage_marker.rotation_degrees -= selected_damage_marker.global_rotation_degrees
		$"../DamageText".add_child(damage_marker)
		damage_marker.set_deferred("theme_override_colors/font_color", "#9fd7ff")
		Globals.shield_energy = clamp(Globals.shield_energy - damage_amount, Globals.shield_energy_min, Globals.shield_energy_max) 
	
	$ShieldSprite.material.set_shader_parameter("progress", 1)
	$ShieldFlashTimer.start()


func _on_shield_flash_timer_timeout():
	$ShieldSprite.material.set_shader_parameter("progress", 0)
