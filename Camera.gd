extends Camera2D

@export var zoom_speed = Vector2(0.1, 0.1)
@export var pan_speed = 500.0

var drag_position = Vector2.ZERO
var dragging = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _input(event):
	var zoom_value = zoom
	if event.is_action_pressed("zoom_in"):
		zoom_value += zoom_speed
	
	if event.is_action_pressed("zoom_out"):
		zoom_value -= zoom_speed
	
	zoom = zoom_value.clamp(Vector2(0.1, 0.1), Vector2.ONE * 50)
	
	if event.is_action_pressed("click") and not dragging:
		drag_position = get_local_mouse_position()
		dragging = true
		
	if event.is_action_released("click") and dragging:
		dragging = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dragging:
		var drag_direction = drag_position - get_local_mouse_position()
		drag_position = get_local_mouse_position()
		
		global_position = global_position + drag_direction
	else:
		var pan_vector = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
		global_position += pan_vector * (pan_speed / zoom.x) * delta
		
