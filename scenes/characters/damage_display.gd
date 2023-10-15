extends Node2D

var amount: int = 0

func _ready():
	$Label.text = str(amount)
