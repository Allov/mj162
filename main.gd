extends Node2D

@onready var camera = $Camera

# Called when the node enters the scene tree for the first time.
func _ready():
	var map = $World/Zone/Map as Map
	camera.global_position = map.spawn_position
