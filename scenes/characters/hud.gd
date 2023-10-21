extends CanvasLayer

signal start_game

@onready var shield_energy_bar: TextureProgressBar = $ShieldEnergyUI/TextureProgressBar

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
	
func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	
	$Message.text = "DODGE"
	$Message.show()
	
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
	
func update_score(score):
	$ScoreLabel.text = str(score)
	
	
func _on_message_timer_timeout():
	$Message.hide()


func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()
	
	
func update_shield_energy():
	shield_energy_bar.value = Globals.shield_energy
	

func update_powerup_orb(powerup_amount):
	$PowerUpOrb.text = str(powerup_amount)
	
