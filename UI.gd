extends Node2D

@export var game_speed = 1.0
@export var max_game_speed = 16.0
@export var min_game_speed = 0.5
@onready var debug_label = $UILayer/Panel/VBoxContainer/DebugLabel
@onready var cursor_image = $CursorImage
@onready var map: Map = $"/root/Main/World/Zone/Map"

enum UIMode { FREE, BUILDING }
var current_ui_mode: UIMode = UIMode.FREE
var current_blue_print: Item = null

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
		
	if event.is_action_pressed("ui_cancel"):
		reset_to_free_mode()
		
	if UIMode.BUILDING and current_blue_print != null and event.is_action_pressed("click"):
		place_building_order()

func place_building_order():
	OrderManager.place_building_order(current_blue_print)
	current_blue_print = null
	reset_to_free_mode()

func get_ui_mode_text():
	match current_ui_mode:
		UIMode.FREE:
			return "Free"
		UIMode.BUILDING:
			return "Building"

func reset_to_free_mode():
	current_ui_mode = UIMode.FREE
	for button: Button in get_tree().get_nodes_in_group("Button"):
		button.release_focus()
	cancel_order()
	
func cancel_order():
	if current_blue_print != null:
		current_blue_print.queue_free()
		current_blue_print = null

func _process(_delta):
	debug_label.text = ""
	debug_label.text += "FPS %s\n" % str(Engine.get_frames_per_second())
	debug_label.text += "Game speed %1.1f\n" % game_speed
	debug_label.text += "UI Mode: %s\n" % get_ui_mode_text()

	var foods = ItemManager.items.filter(func(item: Item): return item.type == Item.ItemType.FOOD)
	debug_label.text += "Foods: %s      " % foods.size()

	var materials = ItemManager.items.filter(func(item: Item): return item.type == Item.ItemType.MATERIAL)
	debug_label.text += "Materials: %s\n" % materials.size()

	var animals = ItemManager.items.filter(func(item: Item): return item.type == Item.ItemType.ANIMAL)
	debug_label.text += "Animals: %s    " % animals.size()

	var vegetations = ItemManager.items.filter(func(item: Item): return item.type == Item.ItemType.VEGETATION)
	debug_label.text += "Vegetations: %s\n" % vegetations.size()

	var buildings = ItemManager.items.filter(func(item: Item): return item.type == Item.ItemType.BUILDING)
	debug_label.text += "Buildings: %s\n" % buildings.size()

	debug_label.text += "Task taken: %s\n" % TaskManager.tasks_log.size()
	for task in TaskManager.tasks_log.slice(0, 10):
		debug_label.text += "  %s\n" % task.get_task_type_name()
		if task.target_item != null:
			debug_label.text += "    %s\n" % task.target_item.name
	
	
	if current_ui_mode == UIMode.FREE:
		var cursor_position = get_global_mouse_position()
		cursor_image.global_position = (floor(cursor_position / 16) * 16)
		
		cursor_image.visible = map.tile_map.get_cell_tile_data(0, cursor_image.global_position / 16) != null
	elif current_ui_mode == UIMode.BUILDING:
		var cursor_position = get_global_mouse_position()
		current_blue_print.global_position = (floor(cursor_position / 16) * 16)
		cursor_image.visible = false

func _on_build_bed_pressed():
	current_ui_mode = UIMode.BUILDING
	current_blue_print = ItemManager.create_blue_print_by_name("bed")

func _on_build_wall_pressed():
	current_ui_mode = UIMode.BUILDING
	current_blue_print = ItemManager.create_blue_print_by_name("wall")


func _on_build_door_pressed():
	current_ui_mode = UIMode.BUILDING
	current_blue_print = ItemManager.create_blue_print_by_name("door")


func _on_build_storage_pressed():
	current_ui_mode = UIMode.BUILDING
	current_blue_print = ItemManager.create_blue_print_by_name("storage")
