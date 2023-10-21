extends Node2D

var amount: int = 0
var hex_color: String

func set_color(hex_color_string):
	hex_color = hex_color_string
	

func _ready():
	$Label.text = str(amount)
	$Label.set_deferred("theme_override_colors/font_color", hex_color)
	#ffff1a
	#9fd7ff
