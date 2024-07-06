class_name Food
extends Item

@export var nutrition = 10.0

enum FoodQuality { RUBBISH, SIMPLE, GOOD, LAVISH }

func _init():
	add_to_group("Food")
	

