extends CharacterBody2D

@export var speed = 50
@export var max_hunger_level = 1200.0
@export var peckish_treshold = 0.8
@export var hungry_treshold = 0.5
@export var very_hungry_treshold = 0.3
@export var damage = 100.0
@export var construction = 10.0

@onready var pathfinding: Pathfinding = $"../Pathfinding"
@onready var terrain: TileMap = $"../Terrain"
@onready var map: Map = $".."
@onready var hunger_level = max_hunger_level
@onready var hunger_level_bar = $HungerLevelBar
@onready var action_cooldown: Timer = $ActionCooldown
@onready var chop_sound = $ChopSound
@onready var squish_sound = $SquishSound
@onready var hammer_sound = $HammerSound
@onready var debug_label = $DebugLabel

var inventory: Array[Item] = []
var path = []
var current_task: Task
var finding_order = false
var harvesting = false
var wandering = false
var gathering = false
var item_to_gather: Item = null
var finding_building = false
var constructing = false

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
	debug_label.text = ""
	if current_task != null:
		debug_label.text += current_task.get_task_type_name()
	else:
		debug_label.text += "doing nothing"

func _physics_process(delta):
	hunger_level -= delta
	var food_available = ItemManager.items.filter(func(item): return item.type == Item.ItemType.FOOD).size() > 0
	if current_task == null and hunger_level < max_hunger_level * peckish_treshold and food_available:
		current_task = TaskManager.request_find_and_eat_food()

	if hunger_level < max_hunger_level * very_hungry_treshold and food_available:
		current_task = TaskManager.request_find_and_eat_food()
	
	
	if hunger_level < 0:
		print(name + " starved to death.")
		queue_free()
		
	do_current_task(food_available)
	follow_path(delta)
	
func do_current_task(food_available):
	if current_task == null:
		current_task = TaskManager.request_task()
		
	if current_task == null:
		return
		
	if current_task.target_item == null and food_available and current_task.type == Task.TaskType.FIND_FOOD:
		var nearest_food = ItemManager.find_nearest_item_by_type(Item.ItemType.FOOD, position)
		path = pathfinding.request_path(global_position / 16, nearest_food.global_position / 16)
		current_task.target_item = nearest_food
		ItemManager.reserve_item(nearest_food)
	elif current_task.type == Task.TaskType.EAT and current_task.target_item != null:
		var food = current_task.target_item
		hunger_level = clamp(hunger_level + food.nutrition, 0, max_hunger_level)
		ItemManager.remove_item(food)
		current_task = current_task.request_next_task()
	elif not finding_order and current_task.type == Task.TaskType.FIND_HARVEST:
		if current_task.target_item != null:
			finding_order = true
			path = pathfinding.request_path(global_position / 16, current_task.target_item.global_position / 16)
	elif current_task.target_item != null and action_cooldown.time_left <= 0.0 and current_task.type == Task.TaskType.HARVEST:
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
				squish_sound.pitch_scale = randf_range(1.0, 1.5)
				squish_sound.play()
			
			if harvestable.health <= 0:
				var drop = harvestable.drop_item_name
				var quantity = harvestable.drop_quantity
				for i in quantity:
					ItemManager.spawn_item_by_name(drop, harvestable.position)
				ItemManager.remove_item(harvestable)
				current_task = current_task.request_next_task()
				harvesting = false
	elif not wandering and current_task.type == Task.TaskType.WANDER:
		wandering = true
		
		var random_target = Vector2(randi_range(-10, 10), randi_range(-10, 10))
		random_target = random_target.clamp(Vector2.ZERO, Vector2(map.width, map.height))
		
		path = pathfinding.request_path(global_position / 16, global_position / 16 + random_target)
	elif current_task.type == Task.TaskType.START_BUILDING_ORDER:
		current_task = current_task.request_next_task()
		
	elif not gathering and current_task.type == Task.TaskType.GATHER_MATS:
		var mat = ItemManager.find_nearest_item_by_name(current_task.item_to_find, position)
		if mat != null:
			gathering = true
			path = pathfinding.request_path(global_position / 16, mat.global_position / 16)
			ItemManager.reserve_item(mat)
			item_to_gather = mat
		else:
			print("no materials available for %s" % current_task.target_item)
			ItemManager.remove_item(current_task.target_item)
			current_task = null
			
	elif not finding_building and current_task.type == Task.TaskType.FIND_BUILDING and current_task.target_item != null:
		finding_building = true
		path = pathfinding.request_path(global_position / 16, current_task.target_item.global_position / 16)
	elif current_task.type == Task.TaskType.ASSEMBLE and current_task.target_item != null:
		var building: Building = current_task.target_item as Building
		
		if building != null:
			# first material
			var items_in_inventory = inventory.filter(func(item: Item): return item.item_name.to_lower().begins_with(building.mat_1_name))
			if items_in_inventory.size() >= building.mat_1_quantiy:
				for req_item in items_in_inventory:
					inventory.erase(req_item)
					ItemManager.remove_item(req_item)
					building.mat_1_quantiy -= 1
				
				items_in_inventory = inventory.filter(func(item: Item): return item.item_name.to_lower().begins_with(building.mat_2_name))
				for req_item in items_in_inventory:
					inventory.erase(req_item)
					ItemManager.remove_item(req_item)
					building.mat_2_quantiy -= 1
				
				current_task = current_task.request_next_task()
		else:
			print("not a building oops.")
			current_task = null

	elif current_task.type == Task.TaskType.BUILD and current_task.target_item != null and action_cooldown.time_left <= 0:
		var building = current_task.target_item as Building
		
		if building != null:
			action_cooldown.one_shot = true
			action_cooldown.start()
			building.health = min(building.health + construction, building.max_health)
			
			hammer_sound.pitch_scale = randf_range(1.0, 1.5)
			hammer_sound.play()

			if building.health >= building.max_health:
				building.blue_print = false
				current_task = current_task.request_next_task()
			
func follow_path(delta):
	if path.size() > 0:
		var direction = global_position.direction_to(path[0])
		
		var difficulty = pathfinding.get_tile_difficulty(path[0] / 16)
		
		velocity = direction * speed / difficulty
		if position.distance_to(path[0]) < speed * delta:
			path.remove_at(0)
	else:
		velocity = Vector2.ZERO
		path.clear()
		
		if current_task != null and current_task.target_item != null and not harvesting and current_task.type == Task.TaskType.FIND_HARVEST:
			current_task = current_task.request_next_task()
			
		if current_task != null and current_task.type == Task.TaskType.FIND_FOOD:
			current_task = current_task.request_next_task()

		if current_task != null and current_task.type == Task.TaskType.WANDER:
			wandering = false
			current_task = null
			
		if current_task != null and gathering and current_task.type == Task.TaskType.GATHER_MATS:
			inventory.append(item_to_gather)
			item_to_gather.visible = false
			item_to_gather = null
			gathering = false
			current_task = current_task.request_next_task()
			print(current_task.get_task_type_name())
		
		if current_task != null and finding_building and current_task.type == Task.TaskType.FIND_BUILDING:
			finding_building = false
			current_task = current_task.request_next_task()
		
	
	move_and_slide()
