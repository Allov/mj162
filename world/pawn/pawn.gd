extends CharacterBody2D

@export var speed = 50
@export var max_hunger_level = 300.0
@export var hungry_treshold = 0.8
@export var damage = 100.0

@onready var pathfinding: Pathfinding = $"../Pathfinding"
@onready var terrain: TileMap = $"../Terrain"
@onready var map: Map = $".."
@onready var hunger_level = max_hunger_level
@onready var hunger_level_bar = $HungerLevelBar
@onready var action_cooldown = $ActionCooldown
@onready var chop_sound = $ChopSound
@onready var squish_sound = $SquishSound


var path = []
var current_task: Task
var finding_order = false
var harvesting = false
var wandering = false

func _ready():
	pass

func _input(event):
	if false and event.is_action("debug_click"):
		var current_position = position / 16
		var desired_position = get_global_mouse_position() / 16
		path = pathfinding.request_path(current_position, desired_position)
		path.remove_at(0)
		
func _process(_delta):
	hunger_level_bar.value = hunger_level / max_hunger_level

func _physics_process(delta):
	hunger_level -= delta
	if current_task == null and hunger_level < max_hunger_level * hungry_treshold:
		current_task = TaskManager.request_find_and_eat_food()
	elif hunger_level < 0:
		queue_free()
		
	do_current_task()
	follow_path(delta)
	
func do_current_task():
	if current_task == null:
		current_task = TaskManager.request_task()
		
	if current_task == null:
		return
	
	if current_task.target_item == null and current_task.type == Task.TaskType.FIND_FOOD:
		var food = ItemManager.find_nearest_item(Item.ItemType.FOOD, position)
		if food != null:
			path = pathfinding.request_path(global_position / 16, food.global_position / 16)
			current_task.target_item = food
	elif current_task.type == Task.TaskType.EAT and current_task.target_item != null:
		var food = current_task.target_item
		hunger_level = clamp(hunger_level + food.nutrition, 0, max_hunger_level)
		ItemManager.remove_item(food)
		current_task = current_task.request_sub_task()
	elif not finding_order and current_task.type == Task.TaskType.FIND_ORDER:
		finding_order = true
		path = pathfinding.request_path(global_position / 16, current_task.target_item.global_position / 16)
	elif action_cooldown.time_left <= 0.0 and current_task.type == Task.TaskType.HARVEST:
		finding_order = false
		harvesting = true
		if "health" in current_task.target_item:
			var harvestable = current_task.target_item
			harvestable.health -= damage
			action_cooldown.one_shot = true
			action_cooldown.start()
			
			if current_task.target_item is Vegetation:
				chop_sound.pitch_scale = randf_range(1.0, 1.5)
				chop_sound.play()
			elif current_task.target_item is Animal:
				print("yo")
				squish_sound.pitch_scale = randf_range(1.0, 1.5)
				squish_sound.play()
			
			if harvestable.health <= 0:
				var drop = harvestable.drop_item_name
				ItemManager.spawn_item_by_name(drop, harvestable.position)
				ItemManager.remove_item(harvestable)
				current_task = current_task.request_sub_task()
				harvesting = false
	elif not wandering and current_task.type == Task.TaskType.WANDER:
		wandering = true
		
		var random_target = Vector2(randi_range(-10, 10), randi_range(-10, 10))
		random_target = random_target.clamp(Vector2.ZERO, Vector2(map.width, map.height))
		
		path = pathfinding.request_path(global_position / 16, global_position / 16 + random_target)
			
func follow_path(delta):
	if path.size() > 0:
		var direction = global_position.direction_to(path[0])
		
		var difficulty = pathfinding.get_tile_difficulty(path[0] / 16)
		
		velocity = direction * speed / difficulty
		if position.distance_to(path[0]) < speed * delta:
			path.remove_at(0)
	else:
		velocity = Vector2.ZERO
		
		if current_task != null and current_task.target_item != null and not harvesting:
			current_task = current_task.request_sub_task()

		if current_task != null and current_task.type == Task.TaskType.WANDER:
			wandering = false
			current_task = null
		
	
	move_and_slide()
