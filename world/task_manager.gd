extends Node

var tasks: Array[Task] = []
var tasks_log: Array[Task] = []
var rng = RandomNumberGenerator.new()


func request_task() -> Task:
	if tasks.size() > 0:
		var task = tasks[0]
		tasks_log.insert(0, task)
		tasks.erase(task)
		return task
	
	if rng.randf() < 0.005:
		return create_wander_task()
		
	return null

func request_find_and_eat_food() -> Task:
	return create_find_food_task()

func add_task(task: Task):
	tasks.append(task)

# Task Factory
func create_find_food_task() -> Task:
	var task = Task.new()
	task.type = Task.TaskType.FIND_FOOD
	
	var next_task = Task.new()
	next_task.type = Task.TaskType.EAT
	task.next_task = next_task
	
	return task
	
func create_harvest_task() -> Task:
	var task = Task.new()
	task.type = Task.TaskType.FIND_HARVEST
	
	var next_task = Task.new()
	next_task.type = Task.TaskType.HARVEST
	task.next_task = next_task
	
	return task
	
func create_build_task(building: Building):
	var task = Task.new()
	task.type = Task.TaskType.START_BUILDING_ORDER
	task.target_item = building
	
	var previous_task = task
	for i in building.mat_1_quantiy:
		var gather_next_task = Task.new()
		gather_next_task.type = Task.TaskType.GATHER_MATS
		gather_next_task.item_to_find = building.mat_1_name
		gather_next_task.quantity_to_find = building.mat_1_quantiy
		previous_task.next_task = gather_next_task
		previous_task = gather_next_task
		
	for i in building.mat_2_quantiy:
		var gather_next_task = Task.new()
		gather_next_task.type = Task.TaskType.GATHER_MATS
		gather_next_task.item_to_find = building.mat_2_name
		gather_next_task.quantity_to_find = building.mat_2_quantiy
		previous_task.next_task = gather_next_task
		previous_task = gather_next_task

	var find_building_next_task = Task.new()
	find_building_next_task.type = Task.TaskType.FIND_BUILDING
	previous_task.next_task = find_building_next_task

	var assemble_next_task = Task.new()
	assemble_next_task.type = Task.TaskType.ASSEMBLE
	find_building_next_task.next_task = assemble_next_task

	var build_next_task = Task.new()
	build_next_task.type = Task.TaskType.BUILD
	assemble_next_task.next_task = build_next_task

	return task
	
func create_wander_task() -> Task:
	var task = Task.new()
	task.type = Task.TaskType.WANDER
	
	return task

func create_haul_task() -> Task:
	var task = Task.new()
	task.type = Task.TaskType.FIND_HAUL
	
	var haul_task = Task.new()
	haul_task.type = Task.TaskType.HAUL
	task.next_task = haul_task
	
	var find_storage_task = Task.new()
	find_storage_task.type = Task.TaskType.FIND_STORAGE
	haul_task.next_task = find_storage_task
	
	var store_task = Task.new()
	store_task.type = Task.TaskType.STORE
	find_storage_task.next_task = store_task
	
	return task
	
	
	
