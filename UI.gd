extends CanvasLayer

@export var game_speed = 1.0
@export var max_game_speed = 16.0
@export var min_game_speed = 0.5
@onready var debug_label = $DebugLabel


func _input(event):
	if event.is_action_pressed("change_game_speed_backward"):
		game_speed = game_speed / 2.0

		if game_speed < min_game_speed:
			game_speed = max_game_speed
			
		Engine.time_scale = game_speed
	elif event.is_action_pressed("change_game_speed"):
		game_speed = game_speed * 2.0
		
		if game_speed > max_game_speed:
			game_speed = min_game_speed
			
		Engine.time_scale = game_speed
		

func _process(delta):
	debug_label.text = ""
	debug_label.text += "FPS " + str(Engine.get_frames_per_second()) + "\n"
	debug_label.text += "Game speed %1.1f" % game_speed
